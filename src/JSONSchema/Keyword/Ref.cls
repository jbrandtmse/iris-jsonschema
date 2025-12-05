/// JSONSchema.Keyword.Ref - $ref reference resolution
/// <p>
/// Resolves JSON Schema $ref references to their target schemas.
/// Supports internal references (#/path) and remote references (http/https).
/// </p>
/// <p>
/// Per JSON Schema specification, when $ref is present, ALL sibling keywords
/// are ignored - the $ref completely replaces the schema.
/// </p>
Class JSONSchema.Keyword.Ref Extends %RegisteredObject
{

/// Validate data against a referenced schema
/// @param pData The data to validate
/// @param pRefValue The $ref value (JSON Pointer or URL)
/// @param pContext Validation context
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateRef(pData, pRefValue As %String, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    
    Try {
        // Check for circular reference - uses counter-based detection
        // IsRefVisited returns true if counter > 0 (currently being resolved)
        If pContext.IsRefVisited(pRefValue) {
            Do pContext.AddError("$ref", "Circular reference detected: " _ pRefValue)
            Set tValid = 0
            Quit
        }
        
        // Mark this ref as being resolved (increment counter)
        Do pContext.MarkRefVisited(pRefValue)
        
        // Determine reference type and resolve
        If $Extract(pRefValue, 1, 1) = "#" {
            // Internal reference
            Set tResolvedSchema = ..ResolveInternalRef(pRefValue, pContext)
        }
        ElseIf ($Extract(pRefValue, 1, 4) = "http") {
            // Remote reference
            Set tResolvedSchema = ..ResolveRemoteRef(pRefValue, pContext)
        }
        Else {
            Do pContext.AddError("$ref", "Invalid $ref format: " _ pRefValue)
            Do pContext.UnmarkRefVisited(pRefValue)
            Set tValid = 0
            Quit
        }
        
        // Check if resolved schema has $ref at top level - potential direct circular
        // If so, keep marked during validation to detect circular chains (A -> B -> A)
        If $IsObject(tResolvedSchema) && tResolvedSchema.%IsDefined("$ref") {
            // Keep marked - validation will detect if it tries to resolve same ref
            Set tValid = ##class(JSONSchema.Validator).ValidateNode(pData, tResolvedSchema, pContext)
            Do pContext.UnmarkRefVisited(pRefValue)
            Quit
        }
        
        // Resolved schema doesn't have top-level $ref - safe to unmark before validate
        // This allows recursive schemas (tree nodes) to work
        Do pContext.UnmarkRefVisited(pRefValue)
        
        // Validate data against resolved schema
        Set tValid = ##class(JSONSchema.Validator).ValidateNode(pData, tResolvedSchema, pContext)
        Quit
    }
    Catch ex {
        // Ensure we unmark on error (may already be unmarked)
        Do pContext.UnmarkRefVisited(pRefValue)
        Do pContext.AddError("$ref", "Failed to resolve $ref '" _ pRefValue _ "': " _ ex.DisplayString())
        Set tValid = 0
    }
    
    Quit tValid
}

/// Resolve an internal JSON Pointer reference
/// @param pRefPath The JSON Pointer (e.g., #/definitions/Address)
/// @param pContext Validation context containing RootSchema
/// @return The resolved schema object
ClassMethod ResolveInternalRef(pRefPath As %String, pContext As JSONSchema.Context) As %DynamicObject
{
    Set tResult = ""
    
    Try {
        // Remove leading # and parse pointer
        Set tPointer = $Extract(pRefPath, 2, *)
        Set tSegments = ..ParseJSONPointer(tPointer)
        
        // Navigate from root schema
        Set tCurrent = pContext.RootSchema
        Set tIter = tSegments.%GetIterator()
        While tIter.%GetNext(.tIdx, .tSegment) {
            If '$IsObject(tCurrent) {
                Throw ##class(%Exception.General).%New("InvalidRef", , , "Cannot navigate to '" _ tSegment _ "' - not an object")
            }
            If 'tCurrent.%IsDefined(tSegment) {
                Throw ##class(%Exception.General).%New("InvalidRef", , , "Reference path not found: " _ pRefPath)
            }
            Set tCurrent = tCurrent.%Get(tSegment)
        }
        
        Set tResult = tCurrent
        Quit
    }
    Catch ex {
        Throw ex
    }
    
    Quit tResult
}

/// Parse a JSON Pointer string into path segments
/// @param pPointer The JSON Pointer without leading # (e.g., /definitions/Address)
/// @return %DynamicArray of path segments
ClassMethod ParseJSONPointer(pPointer As %String) As %DynamicArray
{
    Set tSegments = ##class(%DynamicArray).%New()
    
    // Empty pointer = root
    If pPointer = "" || (pPointer = "/") {
        Quit tSegments
    }
    
    // Remove leading / if present
    If $Extract(pPointer, 1, 1) = "/" {
        Set pPointer = $Extract(pPointer, 2, *)
    }
    
    // Split by /
    For tIdx = 1:1:$Length(pPointer, "/") {
        Set tSegment = $Piece(pPointer, "/", tIdx)
        // Decode escaped characters per RFC 6901
        // ~1 must be decoded before ~0 to handle ~01 correctly
        Set tSegment = $Replace(tSegment, "~1", "/")
        Set tSegment = $Replace(tSegment, "~0", "~")
        Do tSegments.%Push(tSegment)
    }
    
    Quit tSegments
}

/// Resolve a remote HTTP/HTTPS reference
/// @param pRefUrl The remote URL
/// @param pContext Validation context
/// @return The resolved schema object
ClassMethod ResolveRemoteRef(pRefUrl As %String, pContext As JSONSchema.Context) As %DynamicObject
{
    Set tResult = ""
    
    Try {
        // Check cache first
        If pContext.RemoteSchemaCache.%IsDefined(pRefUrl) {
            Set tResult = pContext.RemoteSchemaCache.%Get(pRefUrl)
            Quit
        }
        
        // Fetch remote schema
        Set tResult = ..FetchRemoteSchema(pRefUrl)
        
        // Cache for future use
        Do pContext.RemoteSchemaCache.%Set(pRefUrl, tResult)
        Quit
    }
    Catch ex {
        Throw ex
    }
    
    Quit tResult
}

/// Fetch a schema from a remote URL
/// @param pUrl The HTTP/HTTPS URL
/// @return Parsed JSON schema
ClassMethod FetchRemoteSchema(pUrl As %String) As %DynamicObject
{
    Set tResult = ""
    
    Try {
        Set tRequest = ##class(%Net.HttpRequest).%New()
        
        // Parse URL to extract server, port, and path
        Set tIsHttps = ($Extract(pUrl, 1, 5) = "https")
        Set tUrl = $Select(tIsHttps: $Extract(pUrl, 9, *), 1: $Extract(pUrl, 8, *))  // Remove protocol
        Set tServer = $Piece(tUrl, "/", 1)
        Set tPath = "/" _ $Piece(tUrl, "/", 2, *)
        
        // Handle port in server
        If tServer [ ":" {
            Set tRequest.Port = $Piece(tServer, ":", 2)
            Set tServer = $Piece(tServer, ":", 1)
        }
        
        Set tRequest.Server = tServer
        Set tRequest.Https = tIsHttps
        If tIsHttps {
            // Ensure SSL configuration exists, create if needed
            Set tSSLConfig = ..EnsureSSLConfig()
            Set tRequest.SSLConfiguration = tSSLConfig
        }
        
        // Execute request
        Set tSC = tRequest.Get(tPath)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Check HTTP status
        If tRequest.HttpResponse.StatusCode '= 200 {
            Throw ##class(%Exception.General).%New("HTTPError", , , "HTTP " _ tRequest.HttpResponse.StatusCode _ " fetching " _ pUrl)
        }
        
        // Parse response
        Set tJSON = tRequest.HttpResponse.Data.Read()
        Set tResult = ##class(%DynamicAbstractObject).%FromJSON(tJSON)
        Quit
    }
    Catch ex {
        Throw ex
    }
    
    Quit tResult
}

/// Ensure SSL configuration exists for HTTPS requests
/// Returns the name of the SSL configuration to use
/// Note: The SSL configuration must be pre-configured in the IRIS environment
/// @return Name of SSL configuration to use
ClassMethod EnsureSSLConfig() As %String
{
    // Return standard SSL config name - must be pre-configured in IRIS
    // Configuration can be created via Management Portal > System Administration > 
    // Security > SSL/TLS Configurations
    Quit "DefaultClient"
}

}

/// JSONSchema.Validator - Main entry point for JSON Schema validation
/// <p>
/// Provides stateless validation of JSON data against JSON Schema.
/// All methods are ClassMethods to enable concurrent usage without instance state.
/// </p>
/// <p>
/// <b>Supported Versions:</b>
/// <ul>
/// <li>JSON Schema Draft 7</li>
/// </ul>
/// </p>
/// <p>
/// <b>Input Formats Supported:</b>
/// <ul>
/// <li><b>JSON Data:</b> %DynamicObject, %DynamicArray, JSON string, %Stream.GlobalCharacter, or primitive values</li>
/// <li><b>Schema:</b> %DynamicObject, %DynamicArray, JSON string, or %Stream.GlobalCharacter</li>
/// </ul>
/// </p>
/// <p>
/// <b>Examples:</b>
/// <example>
/// // With %DynamicObject
/// Set tData = {"name": "John", "age": 30}
/// Set tSchema = {"type": "object"}
/// Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
/// 
/// // With JSON strings
/// Set tDataStr = "{""name"": ""John""}"
/// Set tSchemaStr = "{""type"": ""object""}"
/// Set tValid = ##class(JSONSchema.Validator).Validate(tDataStr, tSchemaStr, .tErrors)
/// 
/// // With stream
/// Set tStream = ##class(%Stream.GlobalCharacter).%New()
/// Do tStream.Write("{""type"": ""string""}")
/// Do tStream.Rewind()
/// Set tValid = ##class(JSONSchema.Validator).Validate("test", tStream, .tErrors)
/// 
/// // With primitive data
/// Set tValid = ##class(JSONSchema.Validator).Validate("hello", {"type": "string"}, .tErrors)
/// </example>
/// </p>
Class JSONSchema.Validator Extends %RegisteredObject
{

/// Validate JSON data against a JSON Schema
/// <p>
/// Main entry point for validation. Accepts JSON data and schema in multiple formats
/// with automatic type detection and parsing. Parse errors are distinguished from
/// validation errors using keyword "$parse" or "$parseSchema".
/// </p>
/// <p>
/// <b>Accepted Input Formats:</b>
/// <ul>
/// <li><b>pJSON (data):</b> %DynamicObject, %DynamicArray, JSON string, %Stream.GlobalCharacter, or primitive value</li>
/// <li><b>pSchema:</b> %DynamicObject, %DynamicArray, JSON string, or %Stream.GlobalCharacter</li>
/// </ul>
/// </p>
/// <p>
/// <b>Error Handling:</b>
/// <ul>
/// <li>Parse errors use keyword "$parse" (data) or "$parseSchema" (schema)</li>
/// <li>Validation errors use specific keyword names (type, enum, const, etc.)</li>
/// </ul>
/// </p>
/// @param pJSON The JSON data to validate (multiple formats supported)
/// @param pSchema The JSON Schema to validate against (multiple formats supported)
/// @param pErrors Output parameter receiving %DynamicArray of error objects
/// @param pSchemaVersion Schema version to use (default: "draft-07")
/// @return 1 if validation passes, 0 if validation fails
ClassMethod Validate(pJSON, pSchema, Output pErrors As %DynamicArray, pSchemaVersion As %String = "draft-07") As %Boolean
{
    Set tResult = 1
    Set pErrors = ##class(%DynamicArray).%New()
    Set tSchemaParseError = 0
    Set tDataParseError = 0
    
    Try {
        // Parse schema first (must be an object or boolean)
        Try {
            Set tSchema = ..ParseInput(pSchema)
            Quit
        }
        Catch exSchema {
            Set tSchemaParseError = 1
            Set tError = ##class(%DynamicObject).%New()
            Set tError.keyword = "$parseSchema"
            Set tError.dataPath = "#"
            Set tError.schemaPath = "#"
            Set tError.message = "Invalid JSON schema: " _ exSchema.DisplayString()
            Do pErrors.%Push(tError)
            Set tResult = 0
        }
        
        // If schema parse failed, cannot proceed
        If tSchemaParseError {
            Quit
        }
        
        // Parse data (can be any JSON value - don't parse primitives as JSON strings)
        Try {
            Set tData = ..ParseData(pJSON)
            Quit
        }
        Catch exData {
            Set tDataParseError = 1
            Set tError = ##class(%DynamicObject).%New()
            Set tError.keyword = "$parse"
            Set tError.dataPath = "#"
            Set tError.schemaPath = "#"
            Set tError.message = "Invalid JSON data: " _ exData.DisplayString()
            Do pErrors.%Push(tError)
            Set tResult = 0
        }
        
        // If data parse failed, cannot proceed
        If tDataParseError {
            Quit
        }
        
        // Create validation context
        Set tContext = ##class(JSONSchema.Context).%New(pSchemaVersion)
        Set tContext.RootSchema = tSchema
        
        // Perform validation
        Set tResult = ..ValidateNode(tData, tSchema, tContext)
        
        // Return collected errors
        Set pErrors = tContext.Errors
        Quit
    }
    Catch ex {
        // Handle unexpected exceptions
        Set tResult = 0
        Set tError = ##class(%DynamicObject).%New()
        Set tError.keyword = "$internal"
        Set tError.dataPath = "#"
        Set tError.schemaPath = "#"
        Set tError.message = "Internal error: " _ ex.DisplayString()
        Do pErrors.%Push(tError)
    }
    Quit tResult
}

/// Validate a single node of JSON data against a schema
/// <p>
/// Recursively validates data against schema, processing each applicable keyword.
/// </p>
/// @param pData The data node to validate
/// @param pSchema The schema node to validate against
/// @param pContext The validation context for error tracking
/// @return 1 if node is valid, 0 if invalid
ClassMethod ValidateNode(pData, pSchema, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    
    // Check recursion depth
    If 'pContext.IncrementDepth() {
        Quit 0
    }
    
    Try {
        // Handle boolean schemas (true = allow all, false = deny all)
        If '$IsObject(pSchema) {
            If pSchema = 1 || (pSchema = "true") {
                // Schema is true - everything validates
                Quit
            }
            ElseIf pSchema = 0 || (pSchema = "false") {
                // Schema is false - nothing validates
                Do pContext.AddError("$schema", "Schema is false, no data is valid")
                Set tValid = 0
                Quit
            }
        }
        
        // Process type keyword if present
        If $IsObject(pSchema) && pSchema.%IsDefined("type") {
            Set tTypeValue = pSchema.%Get("type")
            Set tTypeValid = ##class(JSONSchema.Keyword.Type).Validate(pData, tTypeValue, pContext)
            If 'tTypeValid {
                Set tValid = 0
            }
        }
        
        // Check for enum keyword
        If $IsObject(pSchema) && pSchema.%IsDefined("enum") {
            Set tEnumValid = ##class(JSONSchema.Keyword.Enum).Validate(pData, pSchema.enum, pContext)
            Set tValid = tValid && tEnumValid
        }
        
        // Check for const keyword
        If $IsObject(pSchema) && pSchema.%IsDefined("const") {
            Set tConstValid = ##class(JSONSchema.Keyword.Const).Validate(pData, pSchema.const, pContext)
            Set tValid = tValid && tConstValid
        }
        
        Quit
    }
    Catch ex {
        Do pContext.AddError("$internal", "Internal error: " _ ex.DisplayString())
        Set tValid = 0
    }
    
    // Decrement depth before returning
    Do pContext.DecrementDepth()
    
    Quit tValid
}

/// Parse data input - preserves primitives, only parses JSON strings that look like JSON
/// <p>
/// Unlike ParseInput (for schemas), this method preserves primitive values
/// (strings, numbers, booleans) as-is for validation. Strings that start with
/// { or [ are treated as JSON and parsed (will throw if invalid).
/// </p>
/// @param pInput The data input to process
/// @return The data value (primitive or object)
/// @throws Exception if JSON-like string fails to parse
ClassMethod ParseData(pInput)
{
    // Already a dynamic object/array - return as-is
    If $IsObject(pInput) {
        If pInput.%IsA("%Library.DynamicAbstractObject") {
            Quit pInput
        }
        // Handle streams - read and parse as JSON (will throw if invalid)
        If pInput.%IsA("%Stream.Object") {
            Set tJSON = ""
            While 'pInput.AtEnd {
                Set tJSON = tJSON _ pInput.Read(32000)
            }
            Quit ##class(%DynamicAbstractObject).%FromJSON(tJSON)
        }
    }
    
    // For string inputs that look like JSON (start with { or [), parse them
    // This allows auto-parsing of JSON string representations
    If $Extract(pInput, 1, 1) = "{" || ($Extract(pInput, 1, 1) = "[") {
        // Looks like JSON - parse it (will throw if invalid)
        Quit ##class(%DynamicAbstractObject).%FromJSON(pInput)
    }
    
    // For other inputs (numbers, non-JSON strings, etc.), return as-is
    // This allows validation of raw primitive values
    Quit pInput
}

/// Parse input and return %DynamicAbstractObject (for schemas)
/// <p>
/// Handles multiple input types with automatic type detection:
/// <ul>
/// <li>%DynamicObject/%DynamicArray - returned as-is</li>
/// <li>JSON string - parsed to dynamic object/array</li>
/// <li>%Stream.GlobalCharacter or %Stream.Object - read and parsed as JSON</li>
/// </ul>
/// Throws exception if input cannot be parsed as valid JSON.
/// </p>
/// @param pInput The input to parse (multiple formats supported)
/// @return Parsed %DynamicAbstractObject (object or array)
/// @throws Exception if JSON parsing fails
ClassMethod ParseInput(pInput) As %DynamicAbstractObject
{
    Set tResult = ""
    
    Try {
        // Case 1: Already a dynamic object/array - return as-is
        If $IsObject(pInput) {
            If pInput.%IsA("%Library.DynamicAbstractObject") {
                Set tResult = pInput
                Quit
            }
            
            // Case 2: Stream - read content and parse
            If pInput.%IsA("%Stream.Object") {
                Set tJSON = ""
                While 'pInput.AtEnd {
                    Set tJSON = tJSON _ pInput.Read(32000)
                }
                Set tResult = ##class(%DynamicAbstractObject).%FromJSON(tJSON)
                Quit
            }
            
            // Unknown object type
            Throw ##class(%Exception.General).%New("Invalid input type", , , "Input must be %DynamicObject, %DynamicArray, JSON string, or %Stream")
        }
        
        // Case 3: String - parse as JSON
        Set tResult = ##class(%DynamicAbstractObject).%FromJSON(pInput)
        Quit
    }
    Catch ex {
        // Re-throw with context
        Throw ex
    }
    
    Quit tResult
}

/// Get the JSON Schema type of a value
/// <p>
/// Determines the JSON type of a value for type keyword validation.
/// Maps ObjectScript types to JSON Schema types: string, number, integer,
/// boolean, null, array, object.
/// </p>
/// @param pData The data to get the type of
/// @return JSON Schema type name
ClassMethod GetJSONType(pData) As %String
{
    // Handle objects and arrays
    If $IsObject(pData) {
        If pData.%IsA("%Library.DynamicArray") Quit "array"
        If pData.%IsA("%Library.DynamicObject") Quit "object"
        Quit "object"
    }
    
    // For primitives, wrap in temporary object to detect type
    Set tWrapper = ##class(%DynamicObject).%New()
    Set tWrapper.value = pData
    Set tType = tWrapper.%GetTypeOf("value")
    
    // Map %DynamicObject types to JSON Schema types
    If tType = "string" Quit "string"
    If tType = "number" {
        // Check if integer or number (float)
        If (pData = (pData \ 1)) && (pData '[ ".") Quit "integer"
        Quit "number"
    }
    If tType = "boolean" Quit "boolean"
    If tType = "null" Quit "null"
    
    Quit "unknown"
}

}

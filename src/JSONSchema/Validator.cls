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
/// <example>
/// Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
/// If 'tValid { Write "Validation failed with ", tErrors.%Size(), " errors" }
/// </example>
Class JSONSchema.Validator Extends %RegisteredObject
{

/// Validate JSON data against a JSON Schema
/// <p>
/// Main entry point for validation. Accepts JSON data and schema as either
/// %DynamicObject/%DynamicArray or JSON strings, and returns validation result
/// with any errors collected.
/// </p>
/// @param pJSON The JSON data to validate (string, %DynamicObject, %DynamicArray, or %Stream)
/// @param pSchema The JSON Schema to validate against (string, %DynamicObject, or %Stream)
/// @param pErrors Output parameter receiving %DynamicArray of error objects
/// @param pSchemaVersion Schema version to use (default: "draft-07")
/// @return 1 if validation passes, 0 if validation fails
ClassMethod Validate(pJSON, pSchema, Output pErrors As %DynamicArray, pSchemaVersion As %String = "draft-07") As %Boolean
{
    Set tResult = 1
    Set pErrors = ##class(%DynamicArray).%New()
    
    Try {
        // Parse schema (must be an object or boolean)
        Set tSchema = ..ParseInput(pSchema)
        
        // Data can be any JSON value - don't parse primitives as JSON strings
        Set tData = ..ParseData(pJSON)
        
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
        // Handle parse errors or unexpected exceptions
        Set tResult = 0
        Set tError = ##class(%DynamicObject).%New()
        Set tError.keyword = "$parse"
        Set tError.dataPath = "#"
        Set tError.schemaPath = "#"
        Set tError.message = "Parse error: " _ ex.DisplayString()
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
/// (strings, numbers, booleans) as-is for validation. Only parses strings
/// that look like JSON objects/arrays.
/// </p>
/// @param pInput The data input to process
/// @return The data value (primitive or object)
ClassMethod ParseData(pInput)
{
    // Already a dynamic object/array - return as-is
    If $IsObject(pInput) {
        If pInput.%IsA("%Library.DynamicAbstractObject") {
            Quit pInput
        }
        // Handle streams - read and parse as JSON
        If pInput.%IsA("%Stream.Object") {
            Set tJSON = ""
            While 'pInput.AtEnd {
                Set tJSON = tJSON _ pInput.Read(32000)
            }
            Quit ##class(%DynamicAbstractObject).%FromJSON(tJSON)
        }
    }
    
    // For non-object inputs, return as-is (primitives: string, number, boolean)
    // This allows validation of raw primitive values
    Quit pInput
}

/// Parse input and return %DynamicAbstractObject (for schemas)
/// <p>
/// Handles multiple input types:
/// <ul>
/// <li>%DynamicObject/%DynamicArray - returned as-is</li>
/// <li>JSON string - parsed to dynamic object</li>
/// <li>%Stream - read and parsed as JSON</li>
/// </ul>
/// </p>
/// @param pInput The input to parse
/// @return Parsed %DynamicAbstractObject or primitive value wrapper
ClassMethod ParseInput(pInput) As %DynamicAbstractObject
{
    Set tResult = ""
    
    // Already a dynamic object/array - return as-is
    If $IsObject(pInput) {
        If pInput.%IsA("%Library.DynamicAbstractObject") {
            Set tResult = pInput
            Quit tResult
        }
        // Handle streams
        If pInput.%IsA("%Stream.Object") {
            Set tJSON = ""
            While 'pInput.AtEnd {
                Set tJSON = tJSON _ pInput.Read(32000)
            }
            Set tResult = ##class(%DynamicAbstractObject).%FromJSON(tJSON)
            Quit tResult
        }
    }
    
    // String input - parse as JSON
    Set tResult = ##class(%DynamicAbstractObject).%FromJSON(pInput)
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

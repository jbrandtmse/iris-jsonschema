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
        
        // Schema combinators (apply to any data type)
        If $IsObject(pSchema) && pSchema.%IsDefined("allOf") {
            Set tAllOfValid = ##class(JSONSchema.Keyword.Combinator).ValidateAllOf(pData, pSchema.allOf, pContext)
            Set tValid = tValid && tAllOfValid
        }
        
        If $IsObject(pSchema) && pSchema.%IsDefined("anyOf") {
            Set tAnyOfValid = ##class(JSONSchema.Keyword.Combinator).ValidateAnyOf(pData, pSchema.anyOf, pContext)
            Set tValid = tValid && tAnyOfValid
        }
        
        If $IsObject(pSchema) && pSchema.%IsDefined("oneOf") {
            Set tOneOfValid = ##class(JSONSchema.Keyword.Combinator).ValidateOneOf(pData, pSchema.oneOf, pContext)
            Set tValid = tValid && tOneOfValid
        }
        
        If $IsObject(pSchema) && pSchema.%IsDefined("not") {
            Set tNotValid = ##class(JSONSchema.Keyword.Combinator).ValidateNot(pData, pSchema.not, pContext)
            Set tValid = tValid && tNotValid
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
        
        // String validation keywords (only apply to string data)
        Set tDataType = ..GetJSONType(pData)
        If tDataType = "string" {
            
            // Check minLength
            If $IsObject(pSchema) && pSchema.%IsDefined("minLength") {
                Set tMinLengthValid = ##class(JSONSchema.Keyword.String).ValidateMinLength(pData, pSchema.minLength, pContext)
                Set tValid = tValid && tMinLengthValid
            }
            
            // Check maxLength
            If $IsObject(pSchema) && pSchema.%IsDefined("maxLength") {
                Set tMaxLengthValid = ##class(JSONSchema.Keyword.String).ValidateMaxLength(pData, pSchema.maxLength, pContext)
                Set tValid = tValid && tMaxLengthValid
            }
            
            // Check pattern
            If $IsObject(pSchema) && pSchema.%IsDefined("pattern") {
                Set tPatternValid = ##class(JSONSchema.Keyword.String).ValidatePattern(pData, pSchema.pattern, pContext)
                Set tValid = tValid && tPatternValid
            }
            
            // Check format
            If $IsObject(pSchema) && pSchema.%IsDefined("format") {
                Set tFormatValid = ##class(JSONSchema.Keyword.String).ValidateFormat(pData, pSchema.format, pContext)
                Set tValid = tValid && tFormatValid
            }
        }
        
        // Numeric validation keywords (only apply to numeric data)
        If (tDataType = "number") || (tDataType = "integer") {
            
            // Check minimum
            If $IsObject(pSchema) && pSchema.%IsDefined("minimum") {
                Set tMinimumValid = ##class(JSONSchema.Keyword.Numeric).ValidateMinimum(pData, pSchema.minimum, pContext)
                Set tValid = tValid && tMinimumValid
            }
            
            // Check maximum
            If $IsObject(pSchema) && pSchema.%IsDefined("maximum") {
                Set tMaximumValid = ##class(JSONSchema.Keyword.Numeric).ValidateMaximum(pData, pSchema.maximum, pContext)
                Set tValid = tValid && tMaximumValid
            }
            
            // Check exclusiveMinimum
            If $IsObject(pSchema) && pSchema.%IsDefined("exclusiveMinimum") {
                Set tExMinValid = ##class(JSONSchema.Keyword.Numeric).ValidateExclusiveMinimum(pData, pSchema.exclusiveMinimum, pContext)
                Set tValid = tValid && tExMinValid
            }
            
            // Check exclusiveMaximum
            If $IsObject(pSchema) && pSchema.%IsDefined("exclusiveMaximum") {
                Set tExMaxValid = ##class(JSONSchema.Keyword.Numeric).ValidateExclusiveMaximum(pData, pSchema.exclusiveMaximum, pContext)
                Set tValid = tValid && tExMaxValid
            }
            
            // Check multipleOf
            If $IsObject(pSchema) && pSchema.%IsDefined("multipleOf") {
                Set tMultipleValid = ##class(JSONSchema.Keyword.Numeric).ValidateMultipleOf(pData, pSchema.multipleOf, pContext)
                Set tValid = tValid && tMultipleValid
            }
        }
        
        // Object validation keywords (only apply to object data)
        If tDataType = "object" {
            
            // Track which properties have been validated by properties/patternProperties
            Set tValidatedProps = ##class(%DynamicObject).%New()
            
            // Check required
            If $IsObject(pSchema) && pSchema.%IsDefined("required") {
                Set tRequiredValid = ##class(JSONSchema.Keyword.Object).ValidateRequired(pData, pSchema.required, pContext)
                Set tValid = tValid && tRequiredValid
            }
            
            // Check minProperties
            If $IsObject(pSchema) && pSchema.%IsDefined("minProperties") {
                Set tMinPropsValid = ##class(JSONSchema.Keyword.Object).ValidateMinProperties(pData, pSchema.minProperties, pContext)
                Set tValid = tValid && tMinPropsValid
            }
            
            // Check maxProperties
            If $IsObject(pSchema) && pSchema.%IsDefined("maxProperties") {
                Set tMaxPropsValid = ##class(JSONSchema.Keyword.Object).ValidateMaxProperties(pData, pSchema.maxProperties, pContext)
                Set tValid = tValid && tMaxPropsValid
            }
            
            // Check propertyNames
            If $IsObject(pSchema) && pSchema.%IsDefined("propertyNames") {
                Set tPropNamesValid = ##class(JSONSchema.Keyword.Object).ValidatePropertyNames(pData, pSchema.propertyNames, pContext)
                Set tValid = tValid && tPropNamesValid
            }
            
            // Check properties (validates and tracks covered properties)
            If $IsObject(pSchema) && pSchema.%IsDefined("properties") {
                Set tPropsSchema = pSchema.properties
                Set tPropsIter = tPropsSchema.%GetIterator()
                While tPropsIter.%GetNext(.tPropName, .tPropSchema) {
                    // Mark this property as covered by 'properties'
                    Do tValidatedProps.%Set(tPropName, 1)
                    
                    // If property exists in data, validate it
                    If pData.%IsDefined(tPropName) {
                        Set tPropValue = pData.%Get(tPropName)
                        Do pContext.PushDataPath(tPropName)
                        Set tPropValid = ..ValidateNode(tPropValue, tPropSchema, pContext)
                        Do pContext.PopDataPath()
                        Set tValid = tValid && tPropValid
                    }
                }
            }
            
            // Check patternProperties
            If $IsObject(pSchema) && pSchema.%IsDefined("patternProperties") {
                Set tPatternProps = pSchema.patternProperties
                Set tDataIter = pData.%GetIterator()
                While tDataIter.%GetNext(.tDataPropName, .tDataPropValue) {
                    // Check each pattern
                    Set tPatternIter = tPatternProps.%GetIterator()
                    While tPatternIter.%GetNext(.tPattern, .tPatternSchema) {
                        If $Match(tDataPropName, tPattern) {
                            // Mark this property as covered by patternProperties
                            Do tValidatedProps.%Set(tDataPropName, 1)
                            
                            // Validate against pattern schema
                            Do pContext.PushDataPath(tDataPropName)
                            Set tPatternValid = ..ValidateNode(tDataPropValue, tPatternSchema, pContext)
                            Do pContext.PopDataPath()
                            Set tValid = tValid && tPatternValid
                        }
                    }
                }
            }
            
            // Check additionalProperties (for properties not covered above)
            If $IsObject(pSchema) && pSchema.%IsDefined("additionalProperties") {
                Set tAdditionalSchema = pSchema.additionalProperties
                Set tDataIter = pData.%GetIterator()
                While tDataIter.%GetNext(.tDataPropName, .tDataPropValue) {
                    // Skip if property was validated by properties or patternProperties
                    If tValidatedProps.%IsDefined(tDataPropName) {
                        Continue
                    }
                    
                    // This is an additional property
                    If tAdditionalSchema = 0 || (tAdditionalSchema = "false") {
                        // additionalProperties: false - reject additional properties
                        Set tMessage = "Additional property '" _ tDataPropName _ "' is not allowed"
                        Do pContext.AddError("additionalProperties", tMessage)
                        Set tValid = 0
                    }
                    ElseIf $IsObject(tAdditionalSchema) {
                        // additionalProperties: {schema} - validate against schema
                        Do pContext.PushDataPath(tDataPropName)
                        Set tAddValid = ..ValidateNode(tDataPropValue, tAdditionalSchema, pContext)
                        Do pContext.PopDataPath()
                        Set tValid = tValid && tAddValid
                    }
                    // additionalProperties: true (or anything else) - allow without validation
                }
            }
        }
        
        // Array validation keywords (only apply to array data)
        If tDataType = "array" {
            
            // Check minItems
            If $IsObject(pSchema) && pSchema.%IsDefined("minItems") {
                Set tMinItemsValid = ##class(JSONSchema.Keyword.Array).ValidateMinItems(pData, pSchema.minItems, pContext)
                Set tValid = tValid && tMinItemsValid
            }
            
            // Check maxItems
            If $IsObject(pSchema) && pSchema.%IsDefined("maxItems") {
                Set tMaxItemsValid = ##class(JSONSchema.Keyword.Array).ValidateMaxItems(pData, pSchema.maxItems, pContext)
                Set tValid = tValid && tMaxItemsValid
            }
            
            // Check uniqueItems
            If $IsObject(pSchema) && pSchema.%IsDefined("uniqueItems") && pSchema.uniqueItems {
                Set tUniqueValid = ##class(JSONSchema.Keyword.Array).ValidateUniqueItems(pData, pContext)
                Set tValid = tValid && tUniqueValid
            }
            
            // Check contains
            If $IsObject(pSchema) && pSchema.%IsDefined("contains") {
                Set tContainsValid = ##class(JSONSchema.Keyword.Array).ValidateContains(pData, pSchema.contains, pContext)
                Set tValid = tValid && tContainsValid
            }
            
            // Check items
            If $IsObject(pSchema) && pSchema.%IsDefined("items") {
                Set tItemsSchema = pSchema.items
                
                If $IsObject(tItemsSchema) && tItemsSchema.%IsA("%Library.DynamicArray") {
                    // Tuple validation - items is array of schemas
                    Set tTupleLen = tItemsSchema.%Size()
                    Set tDataLen = pData.%Size()
                    
                    // Validate each position against corresponding schema
                    For tIdx = 0:1:(tTupleLen - 1) {
                        If tIdx < tDataLen {
                            Set tItemValue = pData.%Get(tIdx)
                            Set tItemSchema = tItemsSchema.%Get(tIdx)
                            Do pContext.PushDataPath(tIdx)
                            // Pass source type info for correct boolean handling
                            Set tSourceType = pData.%GetTypeOf(tIdx)
                            Set tItemValid = ..ValidateNodeWithType(tItemValue, tItemSchema, pContext, tSourceType)
                            Do pContext.PopDataPath()
                            Set tValid = tValid && tItemValid
                        }
                    }
                    
                    // Check additionalItems (only applies to tuple validation)
                    If pSchema.%IsDefined("additionalItems") && (tDataLen > tTupleLen) {
                        Set tAdditionalSchema = pSchema.additionalItems
                        
                        If tAdditionalSchema = 0 || (tAdditionalSchema = "false") {
                            // additionalItems: false - reject extra items
                            Set tMessage = "Array has " _ tDataLen _ " items but only " _ tTupleLen _ " are allowed"
                            Do pContext.AddError("additionalItems", tMessage)
                            Set tValid = 0
                        }
                        ElseIf $IsObject(tAdditionalSchema) {
                            // additionalItems: {schema} - validate extra items
                            For tIdx = tTupleLen:1:(tDataLen - 1) {
                                Set tItemValue = pData.%Get(tIdx)
                                Do pContext.PushDataPath(tIdx)
                                Set tAddValid = ..ValidateNode(tItemValue, tAdditionalSchema, pContext)
                                Do pContext.PopDataPath()
                                Set tValid = tValid && tAddValid
                            }
                        }
                        // additionalItems: true - allow without validation
                    }
                }
                ElseIf $IsObject(tItemsSchema) {
                    // Single schema - all items must match
                    Set tIter = pData.%GetIterator()
                    While tIter.%GetNext(.tIdx, .tItemValue) {
                        Do pContext.PushDataPath(tIdx)
                        // Pass source type info for correct boolean handling
                        Set tSourceType = pData.%GetTypeOf(tIdx)
                        Set tItemValid = ..ValidateNodeWithType(tItemValue, tItemsSchema, pContext, tSourceType)
                        Do pContext.PopDataPath()
                        Set tValid = tValid && tItemValid
                    }
                }
            }
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

/// Validate a node with explicit source type information
/// <p>
/// Used for array item validation where type info can be lost during extraction.
/// </p>
/// @param pData The data node to validate
/// @param pSchema The schema node to validate against
/// @param pContext The validation context for error tracking
/// @param pSourceType The original type from source container (e.g., "boolean", "number")
/// @return 1 if node is valid, 0 if invalid
ClassMethod ValidateNodeWithType(pData, pSchema, pContext As JSONSchema.Context, pSourceType As %String = "") As %Boolean
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
                Quit
            }
            ElseIf pSchema = 0 || (pSchema = "false") {
                Do pContext.AddError("$schema", "Schema is false, no data is valid")
                Set tValid = 0
                Quit
            }
        }
        
        // Process type keyword if present - use source type if available
        If $IsObject(pSchema) && pSchema.%IsDefined("type") {
            Set tTypeValue = pSchema.%Get("type")
            // Use source type for validation if provided
            If pSourceType '= "" {
                Set tTypeValid = ##class(JSONSchema.Keyword.Type).ValidateWithSourceType(pData, tTypeValue, pContext, pSourceType)
            }
            Else {
                Set tTypeValid = ##class(JSONSchema.Keyword.Type).Validate(pData, tTypeValue, pContext)
            }
            If 'tTypeValid {
                Set tValid = 0
            }
        }
        
        // For remaining validations, delegate to regular ValidateNode
        // (only type checking needs source type info)
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
        
        // Get data type for conditional keyword processing
        Set tDataType = ..GetJSONTypeFromSource(pData, pSourceType)
        
        // String validation keywords
        If tDataType = "string" {
            If $IsObject(pSchema) && pSchema.%IsDefined("minLength") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.String).ValidateMinLength(pData, pSchema.minLength, pContext)
            }
            If $IsObject(pSchema) && pSchema.%IsDefined("maxLength") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.String).ValidateMaxLength(pData, pSchema.maxLength, pContext)
            }
            If $IsObject(pSchema) && pSchema.%IsDefined("pattern") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.String).ValidatePattern(pData, pSchema.pattern, pContext)
            }
            If $IsObject(pSchema) && pSchema.%IsDefined("format") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.String).ValidateFormat(pData, pSchema.format, pContext)
            }
        }
        
        // Numeric validation keywords
        If (tDataType = "number") || (tDataType = "integer") {
            If $IsObject(pSchema) && pSchema.%IsDefined("minimum") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.Numeric).ValidateMinimum(pData, pSchema.minimum, pContext)
            }
            If $IsObject(pSchema) && pSchema.%IsDefined("maximum") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.Numeric).ValidateMaximum(pData, pSchema.maximum, pContext)
            }
            If $IsObject(pSchema) && pSchema.%IsDefined("exclusiveMinimum") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.Numeric).ValidateExclusiveMinimum(pData, pSchema.exclusiveMinimum, pContext)
            }
            If $IsObject(pSchema) && pSchema.%IsDefined("exclusiveMaximum") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.Numeric).ValidateExclusiveMaximum(pData, pSchema.exclusiveMaximum, pContext)
            }
            If $IsObject(pSchema) && pSchema.%IsDefined("multipleOf") {
                Set tValid = tValid && ##class(JSONSchema.Keyword.Numeric).ValidateMultipleOf(pData, pSchema.multipleOf, pContext)
            }
        }
        
        // Array validation keywords (only apply to array data)
        If tDataType = "array" {
            
            // Check minItems
            If $IsObject(pSchema) && pSchema.%IsDefined("minItems") {
                Set tMinItemsValid = ##class(JSONSchema.Keyword.Array).ValidateMinItems(pData, pSchema.minItems, pContext)
                Set tValid = tValid && tMinItemsValid
            }
            
            // Check maxItems
            If $IsObject(pSchema) && pSchema.%IsDefined("maxItems") {
                Set tMaxItemsValid = ##class(JSONSchema.Keyword.Array).ValidateMaxItems(pData, pSchema.maxItems, pContext)
                Set tValid = tValid && tMaxItemsValid
            }
            
            // Check uniqueItems
            If $IsObject(pSchema) && pSchema.%IsDefined("uniqueItems") && pSchema.uniqueItems {
                Set tUniqueValid = ##class(JSONSchema.Keyword.Array).ValidateUniqueItems(pData, pContext)
                Set tValid = tValid && tUniqueValid
            }
            
            // Check contains
            If $IsObject(pSchema) && pSchema.%IsDefined("contains") {
                Set tContainsValid = ##class(JSONSchema.Keyword.Array).ValidateContains(pData, pSchema.contains, pContext)
                Set tValid = tValid && tContainsValid
            }
            
            // Check items
            If $IsObject(pSchema) && pSchema.%IsDefined("items") {
                Set tItemsSchema = pSchema.items
                
                If $IsObject(tItemsSchema) && tItemsSchema.%IsA("%Library.DynamicArray") {
                    // Tuple validation - items is array of schemas
                    Set tTupleLen = tItemsSchema.%Size()
                    Set tDataLen = pData.%Size()
                    
                    // Validate each position against corresponding schema
                    For tIdx = 0:1:(tTupleLen - 1) {
                        If tIdx < tDataLen {
                            Set tItemValue = pData.%Get(tIdx)
                            Set tItemSchema = tItemsSchema.%Get(tIdx)
                            Do pContext.PushDataPath(tIdx)
                            Set tSourceType = pData.%GetTypeOf(tIdx)
                            Set tItemValid = ..ValidateNodeWithType(tItemValue, tItemSchema, pContext, tSourceType)
                            Do pContext.PopDataPath()
                            Set tValid = tValid && tItemValid
                        }
                    }
                    
                    // Check additionalItems (only applies to tuple validation)
                    If pSchema.%IsDefined("additionalItems") && (tDataLen > tTupleLen) {
                        Set tAdditionalSchema = pSchema.additionalItems
                        
                        If tAdditionalSchema = 0 || (tAdditionalSchema = "false") {
                            Set tMessage = "Array has " _ tDataLen _ " items but only " _ tTupleLen _ " are allowed"
                            Do pContext.AddError("additionalItems", tMessage)
                            Set tValid = 0
                        }
                        ElseIf $IsObject(tAdditionalSchema) {
                            For tIdx = tTupleLen:1:(tDataLen - 1) {
                                Set tItemValue = pData.%Get(tIdx)
                                Do pContext.PushDataPath(tIdx)
                                Set tAddValid = ..ValidateNode(tItemValue, tAdditionalSchema, pContext)
                                Do pContext.PopDataPath()
                                Set tValid = tValid && tAddValid
                            }
                        }
                    }
                }
                ElseIf $IsObject(tItemsSchema) {
                    // Single schema - all items must match
                    Set tIter = pData.%GetIterator()
                    While tIter.%GetNext(.tIdx, .tItemValue) {
                        Do pContext.PushDataPath(tIdx)
                        Set tSourceType = pData.%GetTypeOf(tIdx)
                        Set tItemValid = ..ValidateNodeWithType(tItemValue, tItemsSchema, pContext, tSourceType)
                        Do pContext.PopDataPath()
                        Set tValid = tValid && tItemValid
                    }
                }
            }
        }
        
        Quit
    }
    Catch ex {
        Do pContext.AddError("$internal", "Internal error: " _ ex.DisplayString())
        Set tValid = 0
    }
    
    Do pContext.DecrementDepth()
    Quit tValid
}

/// Get JSON type using source type info when available
ClassMethod GetJSONTypeFromSource(pData, pSourceType As %String = "") As %String
{
    // If source type provided, use it (handles boolean correctly)
    If pSourceType = "boolean" Quit "boolean"
    If pSourceType = "null" Quit "null"
    
    // Otherwise use standard detection
    Quit ..GetJSONType(pData)
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

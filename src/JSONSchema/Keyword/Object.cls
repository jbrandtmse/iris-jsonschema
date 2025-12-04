/// JSONSchema.Keyword.Object - Object constraint validators
/// <p>
/// Validates JSON Schema object keywords: required, properties,
/// additionalProperties, patternProperties, propertyNames,
/// minProperties, maxProperties
/// </p>
/// <p>
/// <b>Supported Keywords:</b>
/// <ul>
/// <li><b>required:</b> Array of property names that must exist</li>
/// <li><b>minProperties:</b> Minimum number of properties allowed</li>
/// <li><b>maxProperties:</b> Maximum number of properties allowed</li>
/// <li><b>propertyNames:</b> Schema that all property names must match</li>
/// </ul>
/// </p>
/// <p>
/// Note: properties, patternProperties, and additionalProperties are handled
/// in Validator.cls due to their recursive nature requiring ValidateNode calls.
/// </p>
/// <p>
/// Originally from Story 2.3: Object Validation Keywords
/// </p>
Class JSONSchema.Keyword.Object Extends %RegisteredObject
{

/// Validate required constraint
/// <p>
/// Checks that all properties listed in the required array exist in the object.
/// Reports each missing property as a separate error.
/// </p>
/// @param pData The object data to validate
/// @param pRequired %DynamicArray of required property names
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateRequired(pData As %DynamicObject, pRequired As %DynamicArray, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    
    // Iterate through required property names
    Set tIter = pRequired.%GetIterator()
    While tIter.%GetNext(.tIndex, .tPropertyName) {
        // Check if property exists in data
        If 'pData.%IsDefined(tPropertyName) {
            Set tMessage = "Required property '" _ tPropertyName _ "' is missing"
            Do pContext.AddError("required", tMessage)
            Set tValid = 0
        }
    }
    
    Quit tValid
}

/// Validate minProperties constraint
/// <p>
/// Checks that an object has at least the specified number of properties.
/// </p>
/// @param pData The object data to validate
/// @param pMinProperties Minimum number of properties required
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMinProperties(pData As %DynamicObject, pMinProperties As %Integer, pContext As JSONSchema.Context) As %Boolean
{
    // Count properties using iterator
    Set tCount = 0
    Set tIter = pData.%GetIterator()
    While tIter.%GetNext(.tKey, .tValue) {
        Set tCount = tCount + 1
    }
    
    If tCount < pMinProperties {
        Set tMessage = "Object has " _ tCount _ " properties, minimum is " _ pMinProperties
        Do pContext.AddError("minProperties", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate maxProperties constraint
/// <p>
/// Checks that an object has at most the specified number of properties.
/// </p>
/// @param pData The object data to validate
/// @param pMaxProperties Maximum number of properties allowed
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMaxProperties(pData As %DynamicObject, pMaxProperties As %Integer, pContext As JSONSchema.Context) As %Boolean
{
    // Count properties using iterator
    Set tCount = 0
    Set tIter = pData.%GetIterator()
    While tIter.%GetNext(.tKey, .tValue) {
        Set tCount = tCount + 1
    }
    
    If tCount > pMaxProperties {
        Set tMessage = "Object has " _ tCount _ " properties, maximum is " _ pMaxProperties
        Do pContext.AddError("maxProperties", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate propertyNames constraint
/// <p>
/// Validates that all property names in the object match the specified schema.
/// The schema is applied to each property name as a string value.
/// </p>
/// @param pData The object data to validate
/// @param pSchema Schema that all property names must match
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidatePropertyNames(pData As %DynamicObject, pSchema, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    
    // Iterate all property names
    Set tIter = pData.%GetIterator()
    While tIter.%GetNext(.tPropertyName, .tValue) {
        // Validate property name against schema (as a string value)
        // Use ValidateNode to validate the property name string against the schema
        Set tNameValid = ##class(JSONSchema.Validator).ValidateNode(tPropertyName, pSchema, pContext)
        If 'tNameValid {
            // Add specific context error for propertyNames
            Set tMessage = "Property name '" _ tPropertyName _ "' does not match propertyNames schema"
            Do pContext.AddError("propertyNames", tMessage)
            Set tValid = 0
        }
    }
    
    Quit tValid
}

}

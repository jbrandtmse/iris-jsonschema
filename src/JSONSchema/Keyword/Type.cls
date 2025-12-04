/// JSONSchema.Keyword.Type - Type keyword validator
/// <p>
/// Validates the JSON Schema "type" keyword which specifies the expected
/// data type of a JSON value.
/// </p>
/// <p>
/// <b>Supported Types:</b>
/// <ul>
/// <li>string - JSON string values</li>
/// <li>number - JSON numeric values (integer or float)</li>
/// <li>integer - JSON integer values only</li>
/// <li>boolean - JSON true/false values</li>
/// <li>null - JSON null value</li>
/// <li>array - JSON arrays</li>
/// <li>object - JSON objects</li>
/// </ul>
/// </p>
Class JSONSchema.Keyword.Type Extends %RegisteredObject
{

/// Validate data against the type keyword
/// <p>
/// Checks if the provided data matches the expected JSON Schema type.
/// Supports both single type (string) and multiple types (array of strings).
/// </p>
/// @param pData The data to validate
/// @param pExpectedType The expected type (string) or types (array)
/// @param pContext The validation context for error reporting
/// @return 1 if data type matches, 0 if mismatch
ClassMethod Validate(pData, pExpectedType, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 0
    
    // Get actual type of the data
    Set tActualType = ##class(JSONSchema.Validator).GetJSONType(pData)
    
    // Handle array of types (e.g., ["string", "null"])
    If $IsObject(pExpectedType) && pExpectedType.%IsA("%Library.DynamicArray") {
        Set tIter = pExpectedType.%GetIterator()
        While tIter.%GetNext(.tKey, .tType) {
            If ..TypeMatches(tActualType, tType) {
                Set tValid = 1
                Quit
            }
        }
        If 'tValid {
            Set tTypeList = ..FormatTypeList(pExpectedType)
            Do pContext.AddError("type", "Expected type " _ tTypeList _ " but got '" _ tActualType _ "'")
        }
    }
    Else {
        // Single type validation
        If ..TypeMatches(tActualType, pExpectedType) {
            Set tValid = 1
        }
        Else {
            Do pContext.AddError("type", "Expected type '" _ pExpectedType _ "' but got '" _ tActualType _ "'")
        }
    }
    
    Quit tValid
}

/// Check if actual type matches expected type
/// <p>
/// Handles special case where "integer" is a subset of "number" -
/// an integer value matches both "integer" and "number" types.
/// </p>
/// @param pActualType The actual JSON type of the data
/// @param pExpectedType The expected JSON type from schema
/// @return 1 if types match, 0 if not
ClassMethod TypeMatches(pActualType As %String, pExpectedType As %String) As %Boolean
{
    // Direct match
    If pActualType = pExpectedType {
        Quit 1
    }
    
    // Integer is also a valid number
    If (pExpectedType = "number") && (pActualType = "integer") {
        Quit 1
    }
    
    Quit 0
}

/// Format array of types for error message
/// @param pTypeArray Dynamic array of type names
/// @return Formatted string like "['string', 'null']"
ClassMethod FormatTypeList(pTypeArray As %DynamicArray) As %String
{
    Set tResult = "["
    Set tFirst = 1
    Set tIter = pTypeArray.%GetIterator()
    While tIter.%GetNext(.tKey, .tType) {
        If 'tFirst {
            Set tResult = tResult _ ", "
        }
        Set tResult = tResult _ "'" _ tType _ "'"
        Set tFirst = 0
    }
    Set tResult = tResult _ "]"
    Quit tResult
}

}

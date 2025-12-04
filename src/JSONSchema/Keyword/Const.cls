/// JSONSchema.Keyword.Const - Const keyword validator
/// <p>
/// Validates the JSON Schema "const" keyword which specifies that a value
/// must exactly match a specific constant value.
/// </p>
/// <p>
/// Supports all JSON types including deep equality comparison for objects and arrays.
/// </p>
Class JSONSchema.Keyword.Const Extends %RegisteredObject
{

/// Validate data against the const keyword
/// <p>
/// Checks if the provided data exactly equals the const value.
/// Uses deep comparison via Enum.ValueEquals() for objects and arrays.
/// </p>
/// @param pData The data to validate
/// @param pConstValue The constant value to match
/// @param pContext The validation context for error reporting
/// @return 1 if data equals const value, 0 if mismatch
ClassMethod Validate(pData, pConstValue, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 0
    
    Try {
        Set tValid = ##class(JSONSchema.Keyword.Enum).ValueEquals(pData, pConstValue)
        
        If 'tValid {
            // Format const value for error message
            Set tExpected = ""
            If $IsObject(pConstValue) {
                Set tExpected = pConstValue.%ToJSON()
            } Else {
                Set tExpected = pConstValue
            }
            Set tMessage = "Value must equal: " _ tExpected
            Do pContext.AddError("const", tMessage)
        }
        
        Quit
    }
    Catch ex {
        Set tValid = 0
        Do pContext.AddError("const", "Error during const validation: " _ ex.DisplayString())
    }
    
    Quit tValid
}

}

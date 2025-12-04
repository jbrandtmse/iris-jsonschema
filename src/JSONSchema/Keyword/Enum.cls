/// JSONSchema.Keyword.Enum - Enum keyword validator
/// <p>
/// Validates the JSON Schema "enum" keyword which specifies that a value
/// must be one of a fixed set of allowed values.
/// </p>
/// <p>
/// Supports all JSON types including deep equality comparison for objects and arrays.
/// </p>
Class JSONSchema.Keyword.Enum Extends %RegisteredObject
{

/// Validate data against the enum keyword
/// <p>
/// Checks if the provided data matches one of the allowed enum values.
/// Uses deep comparison for objects and arrays.
/// </p>
/// @param pData The data to validate
/// @param pAllowedValues Dynamic array of allowed values
/// @param pContext The validation context for error reporting
/// @return 1 if data matches any allowed value, 0 if no match
ClassMethod Validate(pData, pAllowedValues As %DynamicArray, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 0
    
    Try {
        // Check if data matches any allowed value
        Set tIter = pAllowedValues.%GetIterator()
        While tIter.%GetNext(.tIdx, .tAllowedValue) {
            If ..ValueEquals(pData, tAllowedValue) {
                Set tValid = 1
                Quit
            }
        }
        
        // If no match, add error
        If 'tValid {
            Set tMessage = "Value must be one of: " _ ..FormatEnumList(pAllowedValues)
            Do pContext.AddError("enum", tMessage)
        }
        
        Quit
    }
    Catch ex {
        Set tValid = 0
        Do pContext.AddError("enum", "Error during enum validation: " _ ex.DisplayString())
    }
    
    Quit tValid
}

/// Deep equality comparison for any JSON value type
/// <p>
/// Handles primitives (string, number, boolean, null) and complex types
/// (objects and arrays) with recursive deep comparison.
/// </p>
/// @param pValue1 First value to compare
/// @param pValue2 Second value to compare
/// @return 1 if values are equal, 0 if not
ClassMethod ValueEquals(pValue1, pValue2) As %Boolean
{
    Set tResult = 0
    
    Try {
        // If both are objects, use deep comparison
        If $IsObject(pValue1) && $IsObject(pValue2) {
            // Array comparison
            If pValue1.%IsA("%Library.DynamicArray") && pValue2.%IsA("%Library.DynamicArray") {
                Set tResult = ..ArrayEquals(pValue1, pValue2)
                Quit
            }
            // Object comparison
            If pValue1.%IsA("%Library.DynamicObject") && pValue2.%IsA("%Library.DynamicObject") {
                Set tResult = ..ObjectEquals(pValue1, pValue2)
                Quit
            }
        }
        
        // If only one is object, not equal
        If $IsObject(pValue1) '= $IsObject(pValue2) {
            Set tResult = 0
            Quit
        }
        
        // Primitive comparison
        Set tResult = (pValue1 = pValue2)
        Quit
    }
    Catch ex {
        Set tResult = 0
    }
    
    Quit tResult
}

/// Deep equality comparison for arrays
/// <p>
/// Compares two arrays element by element in order.
/// Uses recursive ValueEquals() for each element to handle nested structures.
/// </p>
/// @param pArr1 First array to compare
/// @param pArr2 Second array to compare
/// @return 1 if arrays are equal, 0 if not
ClassMethod ArrayEquals(pArr1 As %DynamicArray, pArr2 As %DynamicArray) As %Boolean
{
    Set tResult = 1
    
    // Different lengths = not equal
    If pArr1.%Size() '= pArr2.%Size() {
        Quit 0
    }
    
    // Compare each element recursively
    Set tIter = pArr1.%GetIterator()
    While tIter.%GetNext(.tIdx, .tVal1) {
        Set tVal2 = pArr2.%Get(tIdx)
        If '..ValueEquals(tVal1, tVal2) {
            Set tResult = 0
            Quit
        }
    }
    
    Quit tResult
}

/// Deep equality comparison for objects
/// <p>
/// Compares two objects by checking key sets and values.
/// Key order is irrelevant - only keys and their values matter.
/// Uses recursive ValueEquals() for values to handle nested structures.
/// </p>
/// @param pObj1 First object to compare
/// @param pObj2 Second object to compare
/// @return 1 if objects are equal, 0 if not
ClassMethod ObjectEquals(pObj1 As %DynamicObject, pObj2 As %DynamicObject) As %Boolean
{
    Set tResult = 1
    
    // Compare key counts
    Set tKeys1 = ##class(%DynamicArray).%New()
    Set tIter1 = pObj1.%GetIterator()
    While tIter1.%GetNext(.tKey, .tVal) {
        Do tKeys1.%Push(tKey)
    }
    
    Set tKeys2 = ##class(%DynamicArray).%New()
    Set tIter2 = pObj2.%GetIterator()
    While tIter2.%GetNext(.tKey, .tVal) {
        Do tKeys2.%Push(tKey)
    }
    
    If tKeys1.%Size() '= tKeys2.%Size() {
        Quit 0
    }
    
    // Compare all key-value pairs
    Set tIter = pObj1.%GetIterator()
    While tIter.%GetNext(.tKey, .tVal1) {
        If 'pObj2.%IsDefined(tKey) {
            Set tResult = 0
            Quit
        }
        Set tVal2 = pObj2.%Get(tKey)
        If '..ValueEquals(tVal1, tVal2) {
            Set tResult = 0
            Quit
        }
    }
    
    Quit tResult
}

/// Format enum values for error message
/// <p>
/// Creates a human-readable list of allowed values for error messages.
/// Handles both primitives and objects/arrays by converting to JSON.
/// </p>
/// @param pAllowedValues Dynamic array of allowed values
/// @return Formatted string like "[1, "two", true]"
ClassMethod FormatEnumList(pAllowedValues As %DynamicArray) As %String
{
    Set tList = "["
    Set tIter = pAllowedValues.%GetIterator()
    Set tFirst = 1
    While tIter.%GetNext(.tIdx, .tVal) {
        If 'tFirst {
            Set tList = tList _ ", "
        }
        Set tFirst = 0
        // Format value appropriately (strings in quotes, etc.)
        If $IsObject(tVal) {
            Set tList = tList _ tVal.%ToJSON()
        } Else {
            Set tList = tList _ tVal
        }
    }
    Set tList = tList _ "]"
    Quit tList
}

}

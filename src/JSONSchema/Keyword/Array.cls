/// JSONSchema.Keyword.Array - Array constraint validators
/// <p>
/// Validates JSON Schema array keywords: items, additionalItems,
/// minItems, maxItems, uniqueItems, contains
/// </p>
Class JSONSchema.Keyword.Array Extends %RegisteredObject
{

/// Validate minItems constraint
/// @param pData The array data to validate
/// @param pMinItems Minimum required items
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMinItems(pData As %DynamicArray, pMinItems As %Integer, pContext As JSONSchema.Context) As %Boolean
{
    Set tSize = pData.%Size()

    If tSize < pMinItems {
        Set tMessage = "Array has " _ tSize _ " items, minimum is " _ pMinItems
        Do pContext.AddError("minItems", tMessage)
        Quit 0
    }

    Quit 1
}

/// Validate maxItems constraint
/// @param pData The array data to validate
/// @param pMaxItems Maximum allowed items
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMaxItems(pData As %DynamicArray, pMaxItems As %Integer, pContext As JSONSchema.Context) As %Boolean
{
    Set tSize = pData.%Size()

    If tSize > pMaxItems {
        Set tMessage = "Array has " _ tSize _ " items, maximum is " _ pMaxItems
        Do pContext.AddError("maxItems", tMessage)
        Quit 0
    }

    Quit 1
}

/// Validate uniqueItems constraint
/// @param pData The array data to validate
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateUniqueItems(pData As %DynamicArray, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    Set tSeen = ##class(%DynamicObject).%New()
    Set tIter = pData.%GetIterator()

    While tIter.%GetNext(.tIndex, .tValue) {
        // Get the source type from the array before extraction
        Set tSourceType = pData.%GetTypeOf(tIndex)
        // Serialize to JSON string for comparison (handles objects/arrays)
        Set tKey = ..SerializeForComparison(tValue, tSourceType)

        If tSeen.%IsDefined(tKey) {
            Set tMessage = "Array item at index " _ tIndex _ " is a duplicate"
            Do pContext.AddError("uniqueItems", tMessage)
            Set tValid = 0
        }
        Else {
            Do tSeen.%Set(tKey, tIndex)
        }
    }

    Quit tValid
}

/// Serialize a value for comparison in uniqueItems
/// Uses JSON serialization for deep comparison of objects/arrays
/// Normalizes numeric values so 1 and 1.0 are considered equal
/// @param pValue The value to serialize
/// @param pSourceType The original type from the source container
ClassMethod SerializeForComparison(pValue, pSourceType As %String = "") As %String
{
    If $IsObject(pValue) {
        If pValue.%IsA("%Library.DynamicAbstractObject") {
            Quit pValue.%ToJSON()
        }
    }
    
    // Use source type if provided (preserves boolean/null correctly)
    Set tType = pSourceType
    If tType = "" {
        // Fallback to wrapper detection
        Set tWrapper = ##class(%DynamicObject).%New()
        Set tWrapper.v = pValue
        Set tType = tWrapper.%GetTypeOf("v")
    }
    
    // Normalize numbers: 1 and 1.0 should be the same
    If tType = "number" {
        // Use numeric comparison key - convert to canonical form
        // Integer check: if value equals its integer part
        If pValue = (pValue \ 1) {
            Quit "num:" _ (pValue \ 1)
        }
        Quit "num:" _ pValue
    }
    
    // Boolean - use fixed representation
    If tType = "boolean" {
        If pValue {
            Quit "bool:true"
        }
        Quit "bool:false"
    }
    
    // Null
    If tType = "null" {
        Quit "null:null"
    }
    
    // For other types, use JSON serialization with type prefix
    Set tWrapper = ##class(%DynamicObject).%New()
    Set tWrapper.v = pValue
    Quit tType _ ":" _ tWrapper.%ToJSON()
}

/// Validate contains constraint (at least one item matches schema)
/// @param pData The array data to validate
/// @param pContainsSchema Schema that at least one item must match
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateContains(pData As %DynamicArray, pContainsSchema, pContext As JSONSchema.Context) As %Boolean
{
    Set tSize = pData.%Size()

    // Empty array always fails contains
    If tSize = 0 {
        Do pContext.AddError("contains", "Array is empty, no item can match the contains schema")
        Quit 0
    }

    // Check if any item matches
    Set tFound = 0
    Set tIter = pData.%GetIterator()
    While tIter.%GetNext(.tIndex, .tValue) {
        // Create temporary context to avoid polluting errors
        Set tTempContext = ##class(JSONSchema.Context).%New()
        Set tTempContext.RootSchema = pContext.RootSchema

        Set tMatches = ##class(JSONSchema.Validator).ValidateNode(tValue, pContainsSchema, tTempContext)
        If tMatches {
            // Found a match - contains is satisfied
            Set tFound = 1
            Quit
        }
    }

    // Return based on whether we found a match
    If tFound {
        Quit 1
    }

    // No items matched
    Do pContext.AddError("contains", "No array item matches the contains schema")
    Quit 0
}

}

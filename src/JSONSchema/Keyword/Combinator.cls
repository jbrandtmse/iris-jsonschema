/// JSONSchema.Keyword.Combinator - Schema combinator validators
/// <p>
/// Validates JSON Schema combinator keywords: allOf, anyOf, oneOf, not
/// </p>
/// <p>
/// <b>Supported Keywords:</b>
/// <ul>
/// <li><b>allOf:</b> Data must match ALL schemas in the array</li>
/// <li><b>anyOf:</b> Data must match AT LEAST ONE schema in the array</li>
/// <li><b>oneOf:</b> Data must match EXACTLY ONE schema in the array</li>
/// <li><b>not:</b> Data must NOT match the specified schema</li>
/// </ul>
/// </p>
/// <p>
/// Originally from Story 2.5: Schema Combinators
/// </p>
Class JSONSchema.Keyword.Combinator Extends %RegisteredObject
{

/// Validate allOf constraint - data must match ALL schemas
/// <p>
/// Iterates through all schemas in the array and validates data against each.
/// Returns valid only if ALL schemas pass. Errors accumulate in context.
/// </p>
/// @param pData The data to validate
/// @param pSchemas %DynamicArray of schemas
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateAllOf(pData, pSchemas As %DynamicArray, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    Set tFailedIndices = ""
    Set tIter = pSchemas.%GetIterator()
    
    While tIter.%GetNext(.tIndex, .tSchema) {
        // Validate against each schema - errors accumulate in context
        Set tSchemaValid = ##class(JSONSchema.Validator).ValidateNode(pData, tSchema, pContext)
        If 'tSchemaValid {
            Set tValid = 0
            Set tFailedIndices = tFailedIndices _ $Select(tFailedIndices="":"", 1:", ") _ tIndex
        }
    }
    
    If 'tValid {
        Set tMessage = "Data does not match all schemas in allOf (failed schema indices: " _ tFailedIndices _ ")"
        Do pContext.AddError("allOf", tMessage)
    }
    
    Quit tValid
}

/// Validate anyOf constraint - data must match AT LEAST ONE schema
/// <p>
/// Iterates through schemas checking if at least one matches.
/// Uses temporary context for each attempt to avoid polluting main error list.
/// </p>
/// @param pData The data to validate
/// @param pSchemas %DynamicArray of schemas
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateAnyOf(pData, pSchemas As %DynamicArray, pContext As JSONSchema.Context) As %Boolean
{
    Set tMatched = 0
    Set tIter = pSchemas.%GetIterator()
    
    While tIter.%GetNext(.tIndex, .tSchema) {
        // Use temporary context to avoid polluting main error list
        Set tTempContext = ##class(JSONSchema.Context).%New()
        Set tTempContext.RootSchema = pContext.RootSchema
        
        Set tSchemaValid = ##class(JSONSchema.Validator).ValidateNode(pData, tSchema, tTempContext)
        If tSchemaValid {
            Set tMatched = 1
            Quit  // Exit loop - found a match
        }
    }
    
    If 'tMatched {
        Set tMessage = "Data does not match any schema in anyOf (0 of " _ pSchemas.%Size() _ " matched)"
        Do pContext.AddError("anyOf", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate oneOf constraint - data must match EXACTLY ONE schema
/// <p>
/// Iterates through all schemas counting matches.
/// Returns valid only if EXACTLY ONE schema matches.
/// Reports error if zero or more than one schema matches.
/// </p>
/// @param pData The data to validate
/// @param pSchemas %DynamicArray of schemas
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateOneOf(pData, pSchemas As %DynamicArray, pContext As JSONSchema.Context) As %Boolean
{
    Set tMatchCount = 0
    Set tMatchedIndices = ""
    Set tIter = pSchemas.%GetIterator()
    
    While tIter.%GetNext(.tIndex, .tSchema) {
        // Use temporary context for each validation
        Set tTempContext = ##class(JSONSchema.Context).%New()
        Set tTempContext.RootSchema = pContext.RootSchema
        
        Set tSchemaValid = ##class(JSONSchema.Validator).ValidateNode(pData, tSchema, tTempContext)
        If tSchemaValid {
            Set tMatchCount = tMatchCount + 1
            Set tMatchedIndices = tMatchedIndices _ $Select(tMatchedIndices="":"", 1:", ") _ tIndex
        }
    }
    
    If tMatchCount = 0 {
        Set tMessage = "Data does not match any schema in oneOf (0 of " _ pSchemas.%Size() _ " matched)"
        Do pContext.AddError("oneOf", tMessage)
        Quit 0
    }
    
    If tMatchCount > 1 {
        Set tMessage = "Data matches " _ tMatchCount _ " schemas in oneOf, but must match exactly 1 (matched indices: " _ tMatchedIndices _ ")"
        Do pContext.AddError("oneOf", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate not constraint - data must NOT match the schema
/// <p>
/// Validates data against schema using temporary context.
/// Returns valid if schema validation FAILS.
/// Returns invalid if schema validation PASSES.
/// </p>
/// @param pData The data to validate
/// @param pSchema Schema that data must NOT match
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateNot(pData, pSchema, pContext As JSONSchema.Context) As %Boolean
{
    // Use temporary context to check if data matches
    Set tTempContext = ##class(JSONSchema.Context).%New()
    Set tTempContext.RootSchema = pContext.RootSchema
    
    Set tMatches = ##class(JSONSchema.Validator).ValidateNode(pData, pSchema, tTempContext)
    
    // not is valid when the data does NOT match the schema
    If tMatches {
        Do pContext.AddError("not", "Data matches schema in 'not', but should not")
        Quit 0
    }
    
    Quit 1
}

}

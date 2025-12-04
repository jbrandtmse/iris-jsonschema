/// JSONSchema.Keyword.Conditional - Conditional schema validators
/// <p>
/// Validates JSON Schema conditional keywords: if/then/else, dependencies
/// </p>
/// <p>
/// <b>Supported Keywords:</b>
/// <ul>
/// <li><b>if/then/else:</b> Conditional schema application based on if schema evaluation</li>
/// <li><b>dependencies:</b> Property and schema dependencies (Draft 7 style)</li>
/// </ul>
/// </p>
/// <p>
/// <b>if/then/else Semantics:</b>
/// <ul>
/// <li>if schema is evaluated silently (errors not collected)</li>
/// <li>If if passes AND then exists, data must validate against then</li>
/// <li>If if fails AND else exists, data must validate against else</li>
/// <li>Missing then/else means no constraint (passes by default)</li>
/// </ul>
/// </p>
/// <p>
/// Originally from Story 2.6: Conditional Schema Keywords
/// </p>
Class JSONSchema.Keyword.Conditional Extends %RegisteredObject
{

/// Validate if/then/else conditional schema
/// <p>
/// Evaluates the if schema silently using a temporary context.
/// If if passes and then exists, validates against then.
/// If if fails and else exists, validates against else.
/// </p>
/// @param pData The data to validate
/// @param pSchema The full schema containing if/then/else
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateIfThenElse(pData, pSchema, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    
    // Get the if schema
    Set tIfSchema = pSchema.if
    
    // Evaluate if schema using temporary context (silent evaluation)
    // This prevents if-schema errors from polluting the main error list
    Set tTempContext = ##class(JSONSchema.Context).%New()
    Set tTempContext.RootSchema = pContext.RootSchema
    
    Set tIfPasses = ##class(JSONSchema.Validator).ValidateNode(pData, tIfSchema, tTempContext)
    
    If tIfPasses {
        // if passed - apply then schema if exists
        If pSchema.%IsDefined("then") {
            Set tThenSchema = pSchema.then
            Set tThenValid = ##class(JSONSchema.Validator).ValidateNode(pData, tThenSchema, pContext)
            If 'tThenValid {
                Do pContext.AddError("then", "Data fails 'then' schema after passing 'if' condition")
                Set tValid = 0
            }
        }
        // No then schema - passes by default
    }
    Else {
        // if failed - apply else schema if exists
        If pSchema.%IsDefined("else") {
            Set tElseSchema = pSchema.else
            Set tElseValid = ##class(JSONSchema.Validator).ValidateNode(pData, tElseSchema, pContext)
            If 'tElseValid {
                Do pContext.AddError("else", "Data fails 'else' schema after failing 'if' condition")
                Set tValid = 0
            }
        }
        // No else schema - passes by default
    }
    
    Quit tValid
}

/// Validate dependencies constraint
/// <p>
/// Iterates through each dependency definition. If the trigger property
/// exists in the data, validates the dependency (either property or schema).
/// </p>
/// @param pData The object data to validate
/// @param pDependencies Object mapping property names to dependencies
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateDependencies(pData, pDependencies, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    Set tIter = pDependencies.%GetIterator()
    
    While tIter.%GetNext(.tPropName, .tDependency) {
        // Only check if trigger property exists in data
        If 'pData.%IsDefined(tPropName) {
            Continue
        }
        
        // Check dependency type
        If $IsObject(tDependency) && tDependency.%IsA("%Library.DynamicArray") {
            // Property dependency - array of required property names
            Set tPropValid = ..ValidatePropertyDependency(pData, tPropName, tDependency, pContext)
            Set tValid = tValid && tPropValid
        }
        ElseIf $IsObject(tDependency) {
            // Schema dependency - schema that must validate
            Set tSchemaValid = ..ValidateSchemaDependency(pData, tPropName, tDependency, pContext)
            Set tValid = tValid && tSchemaValid
        }
    }
    
    Quit tValid
}

/// Validate property dependency (array of required properties)
/// <p>
/// If trigger property exists in data, all required properties must also exist.
/// </p>
/// @param pData The object data to validate
/// @param pPropertyName The trigger property name
/// @param pRequiredProps Array of property names that must exist
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidatePropertyDependency(pData, pPropertyName As %String, pRequiredProps As %DynamicArray, pContext As JSONSchema.Context) As %Boolean
{
    Set tValid = 1
    Set tIter = pRequiredProps.%GetIterator()
    
    While tIter.%GetNext(.tIdx, .tRequiredProp) {
        If 'pData.%IsDefined(tRequiredProp) {
            Set tMessage = "Property '" _ pPropertyName _ "' requires property '" _ tRequiredProp _ "' to be present"
            Do pContext.AddError("dependencies", tMessage)
            Set tValid = 0
        }
    }
    
    Quit tValid
}

/// Validate schema dependency (schema that must validate when property exists)
/// <p>
/// If trigger property exists in data, the entire data must validate
/// against the dependency schema.
/// </p>
/// @param pData The object data to validate
/// @param pPropertyName The trigger property name
/// @param pSchema The schema that must validate
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateSchemaDependency(pData, pPropertyName As %String, pSchema, pContext As JSONSchema.Context) As %Boolean
{
    // Validate entire data against the dependency schema
    Set tValid = ##class(JSONSchema.Validator).ValidateNode(pData, pSchema, pContext)
    
    If 'tValid {
        Set tMessage = "Property '" _ pPropertyName _ "' dependency schema failed"
        Do pContext.AddError("dependencies", tMessage)
    }
    
    Quit tValid
}

}

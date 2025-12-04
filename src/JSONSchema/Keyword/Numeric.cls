/// JSONSchema.Keyword.Numeric - Numeric constraint validators
/// <p>
/// Validates JSON Schema numeric keywords: minimum, maximum,
/// exclusiveMinimum, exclusiveMaximum, multipleOf
/// </p>
/// <p>
/// <b>Supported Keywords:</b>
/// <ul>
/// <li><b>minimum:</b> Number must be >= this value (inclusive)</li>
/// <li><b>maximum:</b> Number must be <= this value (inclusive)</li>
/// <li><b>exclusiveMinimum:</b> Number must be > this value (exclusive)</li>
/// <li><b>exclusiveMaximum:</b> Number must be < this value (exclusive)</li>
/// <li><b>multipleOf:</b> Number must be evenly divisible by this value</li>
/// </ul>
/// </p>
/// <p>
/// Originally from Story 2.2: Numeric Validation Keywords
/// </p>
Class JSONSchema.Keyword.Numeric Extends %RegisteredObject
{

/// Validate minimum constraint
/// <p>
/// Checks that a number is greater than or equal to the specified minimum value.
/// Works with both integers and floating-point numbers.
/// </p>
/// @param pData The numeric data to validate
/// @param pMinimum Minimum value from schema
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMinimum(pData, pMinimum, pContext As JSONSchema.Context) As %Boolean
{
    If pData < pMinimum {
        Set tMessage = "Value " _ pData _ " is less than minimum " _ pMinimum
        Do pContext.AddError("minimum", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate maximum constraint
/// <p>
/// Checks that a number is less than or equal to the specified maximum value.
/// Works with both integers and floating-point numbers.
/// </p>
/// @param pData The numeric data to validate
/// @param pMaximum Maximum value from schema
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMaximum(pData, pMaximum, pContext As JSONSchema.Context) As %Boolean
{
    If pData > pMaximum {
        Set tMessage = "Value " _ pData _ " exceeds maximum " _ pMaximum
        Do pContext.AddError("maximum", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate exclusiveMinimum constraint (Draft 7 style)
/// <p>
/// Checks that a number is strictly greater than the specified value.
/// In JSON Schema Draft 7, exclusiveMinimum is a numeric value, not boolean.
/// </p>
/// @param pData The numeric data to validate
/// @param pExclusiveMinimum Exclusive minimum value from schema
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateExclusiveMinimum(pData, pExclusiveMinimum, pContext As JSONSchema.Context) As %Boolean
{
    If pData <= pExclusiveMinimum {
        Set tMessage = "Value " _ pData _ " is not greater than exclusiveMinimum " _ pExclusiveMinimum
        Do pContext.AddError("exclusiveMinimum", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate exclusiveMaximum constraint (Draft 7 style)
/// <p>
/// Checks that a number is strictly less than the specified value.
/// In JSON Schema Draft 7, exclusiveMaximum is a numeric value, not boolean.
/// </p>
/// @param pData The numeric data to validate
/// @param pExclusiveMaximum Exclusive maximum value from schema
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateExclusiveMaximum(pData, pExclusiveMaximum, pContext As JSONSchema.Context) As %Boolean
{
    If pData >= pExclusiveMaximum {
        Set tMessage = "Value " _ pData _ " is not less than exclusiveMaximum " _ pExclusiveMaximum
        Do pContext.AddError("exclusiveMaximum", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate multipleOf constraint with floating-point precision handling
/// <p>
/// Checks that a number is evenly divisible by the specified value.
/// Handles floating-point precision issues using epsilon comparison.
/// </p>
/// <p>
/// <b>DEFENSIVE:</b> multipleOf must be strictly greater than 0 per JSON Schema spec.
/// A schema with multipleOf <= 0 is invalid, but we handle gracefully with an error.
/// </p>
/// @param pData The numeric data to validate
/// @param pMultipleOf The divisor value from schema (must be > 0)
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMultipleOf(pData, pMultipleOf, pContext As JSONSchema.Context) As %Boolean
{
    // DEFENSIVE: multipleOf must be strictly greater than 0 per JSON Schema spec
    // A schema with multipleOf <= 0 is invalid, but we handle gracefully
    If pMultipleOf <= 0 {
        Set tMessage = "Invalid schema: multipleOf must be greater than 0, got " _ pMultipleOf
        Do pContext.AddError("multipleOf", tMessage)
        Quit 0
    }
    
    // Handle zero data - 0 is a multiple of any positive number
    If pData = 0 {
        Quit 1
    }
    
    // Calculate remainder using modulo
    // For floating-point precision, check if remainder is effectively zero
    Set tRemainder = pData # pMultipleOf
    
    // Handle floating-point precision issues
    // Consider it a valid multiple if remainder is very close to 0 or to pMultipleOf
    Set tEpsilon = 0.0000001
    If ($ZAbs(tRemainder) < tEpsilon) || ($ZAbs(tRemainder - pMultipleOf) < tEpsilon) {
        Quit 1
    }
    
    Set tMessage = "Value " _ pData _ " is not a multiple of " _ pMultipleOf
    Do pContext.AddError("multipleOf", tMessage)
    Quit 0
}

}

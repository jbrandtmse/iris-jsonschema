/// JSONSchema.Keyword.String - String constraint validators
/// <p>
/// Validates JSON Schema string keywords: minLength, maxLength, pattern, format
/// </p>
/// <p>
/// <b>Supported Keywords:</b>
/// <ul>
/// <li><b>minLength:</b> Minimum string length in characters</li>
/// <li><b>maxLength:</b> Maximum string length in characters</li>
/// <li><b>pattern:</b> ECMAScript regex pattern for string matching</li>
/// <li><b>format:</b> Semantic format validation (lenient by default)</li>
/// </ul>
/// </p>
/// <p>
/// <b>Supported Formats:</b>
/// <ul>
/// <li>date-time: ISO 8601 date-time (e.g., 2023-12-04T14:30:00Z)</li>
/// <li>date: ISO 8601 date (e.g., 2023-12-04)</li>
/// <li>time: Time format (e.g., 14:30:00)</li>
/// <li>email: Email address</li>
/// <li>uri: URI/URL</li>
/// <li>uuid: UUID format</li>
/// </ul>
/// </p>
/// <p>
/// Originally from Story 2.1: String Validation Keywords
/// </p>
Class JSONSchema.Keyword.String Extends %RegisteredObject
{

/// Validate minLength constraint
/// <p>
/// Checks that a string has at least the specified number of characters.
/// Uses $Length() which correctly counts Unicode characters, not bytes.
/// </p>
/// @param pData The string data to validate
/// @param pMinLength Minimum length value from schema
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMinLength(pData As %String, pMinLength As %Integer, pContext As JSONSchema.Context) As %Boolean
{
    // Get actual length - $Length() handles Unicode correctly
    Set tActualLength = $Length(pData)
    
    If tActualLength < pMinLength {
        Set tMessage = "String length " _ tActualLength _ " is less than minLength " _ pMinLength
        Do pContext.AddError("minLength", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate maxLength constraint
/// <p>
/// Checks that a string has at most the specified number of characters.
/// Uses $Length() which correctly counts Unicode characters, not bytes.
/// </p>
/// @param pData The string data to validate
/// @param pMaxLength Maximum length value from schema
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidateMaxLength(pData As %String, pMaxLength As %Integer, pContext As JSONSchema.Context) As %Boolean
{
    Set tActualLength = $Length(pData)
    
    If tActualLength > pMaxLength {
        Set tMessage = "String length " _ tActualLength _ " exceeds maxLength " _ pMaxLength
        Do pContext.AddError("maxLength", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate pattern constraint using regex
/// <p>
/// Checks that a string matches the specified ECMAScript regex pattern.
/// Uses ObjectScript $Match() function for regex validation.
/// </p>
/// @param pData The string data to validate
/// @param pPattern The regex pattern from schema
/// @param pContext Validation context for error reporting
/// @return 1 if valid, 0 if invalid
ClassMethod ValidatePattern(pData As %String, pPattern As %String, pContext As JSONSchema.Context) As %Boolean
{
    // Use ObjectScript $Match() for regex validation
    // $Match() returns 1 if string matches pattern, 0 otherwise
    If '$Match(pData, pPattern) {
        Set tMessage = "String does not match pattern /" _ pPattern _ "/"
        Do pContext.AddError("pattern", tMessage)
        Quit 0
    }
    
    Quit 1
}

/// Validate format constraint (lenient - format is advisory)
/// <p>
/// Per JSON Schema specification, format is an annotation and validation
/// is lenient by default. Invalid format does NOT cause validation failure.
/// This method validates known formats but always returns 1 (pass).
/// </p>
/// @param pData The string data to validate
/// @param pFormat The format name from schema
/// @param pContext Validation context for error reporting
/// @return 1 (always passes - format is lenient)
ClassMethod ValidateFormat(pData As %String, pFormat As %String, pContext As JSONSchema.Context) As %Boolean
{
    // Per JSON Schema spec, format is lenient - invalid format should not fail validation
    // We validate known formats but return 1 (pass) even if format is invalid
    // This allows strict mode in future if needed
    
    Set tValid = 1
    
    If pFormat = "date-time" {
        Set tValid = ..ValidateDateTime(pData)
    }
    ElseIf pFormat = "date" {
        Set tValid = ..ValidateDate(pData)
    }
    ElseIf pFormat = "time" {
        Set tValid = ..ValidateTime(pData)
    }
    ElseIf pFormat = "email" {
        Set tValid = ..ValidateEmail(pData)
    }
    ElseIf pFormat = "uri" {
        Set tValid = ..ValidateUri(pData)
    }
    ElseIf pFormat = "uuid" {
        Set tValid = ..ValidateUuid(pData)
    }
    // Unknown formats are ignored per spec
    
    // LENIENT MODE: Always return 1 (pass) even if format check failed
    // Could add error as warning in future enhancement
    Quit 1
}

/// Validate ISO 8601 date-time format
/// <p>
/// Validates date-time strings in ISO 8601 format.
/// Examples: 2023-12-04T14:30:00Z, 2023-12-04T14:30:00+05:30
/// </p>
/// @param pData The string to validate
/// @return 1 if valid date-time format, 0 otherwise
ClassMethod ValidateDateTime(pData As %String) As %Boolean
{
    // Basic ISO 8601 check: YYYY-MM-DDTHH:MM:SS or with timezone
    // Example: 2023-12-04T14:30:00Z or 2023-12-04T14:30:00+05:30
    // Also support optional milliseconds: 2023-12-04T14:30:00.123Z
    Set tPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})?$"
    Quit $Match(pData, tPattern)
}

/// Validate ISO 8601 date format
/// <p>
/// Validates date strings in ISO 8601 format: YYYY-MM-DD
/// </p>
/// @param pData The string to validate
/// @return 1 if valid date format, 0 otherwise
ClassMethod ValidateDate(pData As %String) As %Boolean
{
    // YYYY-MM-DD
    Set tPattern = "^\d{4}-\d{2}-\d{2}$"
    Quit $Match(pData, tPattern)
}

/// Validate time format
/// <p>
/// Validates time strings in format HH:MM:SS with optional milliseconds.
/// </p>
/// @param pData The string to validate
/// @return 1 if valid time format, 0 otherwise
ClassMethod ValidateTime(pData As %String) As %Boolean
{
    // HH:MM:SS or HH:MM:SS.mmm (supports up to 6 decimal places)
    Set tPattern = "^\d{2}:\d{2}:\d{2}(\.\d{1,6})?$"
    Quit $Match(pData, tPattern)
}

/// Validate email format (simple pattern)
/// <p>
/// Validates email addresses using a simple pattern: localpart@domain.
/// Note: This is a basic check, not full RFC 5322 compliance.
/// </p>
/// @param pData The string to validate
/// @return 1 if valid email format, 0 otherwise
ClassMethod ValidateEmail(pData As %String) As %Boolean
{
    // Simple email pattern: localpart@domain
    Set tPattern = "^[^@]+@[^@]+\.[^@]+$"
    Quit $Match(pData, tPattern)
}

/// Validate URI format
/// <p>
/// Validates URI strings by checking for scheme prefix.
/// </p>
/// @param pData The string to validate
/// @return 1 if valid URI format, 0 otherwise
ClassMethod ValidateUri(pData As %String) As %Boolean
{
    // Basic URI pattern: scheme://... or scheme:...
    Set tPattern = "^[a-zA-Z][a-zA-Z0-9+.-]*:"
    Quit $Match(pData, tPattern)
}

/// Validate UUID format
/// <p>
/// Validates UUID strings in format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.
/// </p>
/// @param pData The string to validate
/// @return 1 if valid UUID format, 0 otherwise
ClassMethod ValidateUuid(pData As %String) As %Boolean
{
    // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    Set tPattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
    Quit $Match(pData, tPattern)
}

}

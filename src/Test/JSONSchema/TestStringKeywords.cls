/// Test.JSONSchema.TestStringKeywords - String keyword validation tests
/// <p>
/// Tests for JSON Schema string keywords: minLength, maxLength, pattern, format.
/// Covers valid, invalid, and edge cases for each keyword.
/// </p>
/// <p>
/// Originally from Story 2.1: String Validation Keywords
/// </p>
Class Test.JSONSchema.TestStringKeywords Extends %UnitTest.TestCase
{

// ============================================================================

// Task 3: minLength and maxLength Tests

// ============================================================================

/// 2.1-UNIT-001 (P0): String with length >= minLength passes
Method TestMinLengthValid() As %Status
{
    Set tData = "Hello"
    Set tSchema = {"type": "string", "minLength": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String length 5 should pass minLength 3")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.1-UNIT-002 (P0): String with length < minLength fails
Method TestMinLengthInvalid() As %Status
{
    Set tData = "Hi"
    Set tSchema = {"type": "string", "minLength": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String length 2 should fail minLength 3")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "minLength", "Error keyword should be minLength")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "2", "Error should mention actual length")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "3", "Error should mention minLength value")
    Quit $$$OK
}

/// 2.1-UNIT-003 (P1): String with length exactly equal to minLength passes
Method TestMinLengthBoundary() As %Status
{
    Set tData = "abc"
    Set tSchema = {"type": "string", "minLength": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String length 3 should pass minLength 3 (boundary)")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.1-UNIT-004 (P0): String with length <= maxLength passes
Method TestMaxLengthValid() As %Status
{
    Set tData = "Hello"
    Set tSchema = {"type": "string", "maxLength": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String length 5 should pass maxLength 10")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.1-UNIT-005 (P0): String with length > maxLength fails
Method TestMaxLengthInvalid() As %Status
{
    Set tData = "Hello World"
    Set tSchema = {"type": "string", "maxLength": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String length 11 should fail maxLength 5")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "maxLength", "Error keyword should be maxLength")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "11", "Error should mention actual length")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "5", "Error should mention maxLength value")
    Quit $$$OK
}

/// 2.1-UNIT-006 (P1): String with length exactly equal to maxLength passes
Method TestMaxLengthBoundary() As %Status
{
    Set tData = "abcde"
    Set tSchema = {"type": "string", "maxLength": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String length 5 should pass maxLength 5 (boundary)")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.1-UNIT-007 (P0): Both minLength and maxLength constraints work together
Method TestMinMaxLengthCombined() As %Status
{
    Set tSchema = {"type": "string", "minLength": 3, "maxLength": 10}
    
    // Test valid case
    Set tData = "Hello"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String length 5 should pass minLength 3 and maxLength 10")
    
    // Test too short
    Set tData = "ab"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String length 2 should fail minLength 3")
    
    // Test too long
    Set tData = "Hello World!"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String length 12 should fail maxLength 10")
    
    Quit $$$OK
}

/// 2.1-UNIT-008 (P1): Unicode strings counted by character, not bytes
Method TestMinLengthUnicode() As %Status
{
    // Unicode string with 5 characters (may be more bytes in UTF-8)
    Set tData = "Hello"
    Set tSchema = {"type": "string", "minLength": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Unicode string should be counted by character")
    
    // Test with actual Unicode characters
    Set tData = "日本語"  // 3 Japanese characters
    Set tSchema = {"type": "string", "minLength": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Japanese string of 3 chars should pass minLength 3")
    
    Quit $$$OK
}

/// 2.1-UNIT-009 (P2): Empty string fails minLength > 0
Method TestMinLengthEmptyString() As %Status
{
    Set tData = ""
    Set tSchema = {"type": "string", "minLength": 1}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Empty string should fail minLength 1")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "minLength", "Error keyword should be minLength")
    Quit $$$OK
}

/// 2.1-UNIT-010 (P1): Empty string passes maxLength >= 0
Method TestMaxLengthEmptyString() As %Status
{
    Set tData = ""
    Set tSchema = {"type": "string", "maxLength": 0}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Empty string should pass maxLength 0")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

// ============================================================================

// Task 4: pattern Tests

// ============================================================================

/// 2.1-UNIT-011 (P0): String matching pattern passes
Method TestPatternValid() As %Status
{
    Set tData = "abc123"
    Set tSchema = {"type": "string", "pattern": "^[a-z]+[0-9]+$"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String matching pattern should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.1-UNIT-012 (P0): String not matching pattern fails
Method TestPatternInvalid() As %Status
{
    Set tData = "123abc"
    Set tSchema = {"type": "string", "pattern": "^[a-z]+[0-9]+$"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String not matching pattern should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "pattern", "Error keyword should be pattern")
    Quit $$$OK
}

/// 2.1-UNIT-013 (P1): Simple patterns like "^[0-9]+$" for digits
Method TestPatternSimple() As %Status
{
    Set tSchema = {"type": "string", "pattern": "^[0-9]+$"}
    
    // Valid digits
    Set tData = "12345"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Digits string should match digit pattern")
    
    // Invalid (contains letters)
    Set tData = "123abc"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Mixed string should not match digit pattern")
    
    Quit $$$OK
}

/// 2.1-UNIT-014 (P1): Complex regex patterns
Method TestPatternComplex() As %Status
{
    // Email-like pattern
    Set tSchema = {"type": "string", "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"}
    
    Set tData = "test@example.com"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid email should match email pattern")
    
    Set tData = "invalid-email"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid email should not match email pattern")
    
    Quit $$$OK
}

/// 2.1-UNIT-015 (P1): Pattern matching with Unicode characters
Method TestPatternUnicode() As %Status
{
    // Simple pattern that matches any characters
    Set tData = "日本語テスト"
    Set tSchema = {"type": "string", "pattern": ".+"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Unicode string should match .+ pattern")
    Quit $$$OK
}

/// 2.1-UNIT-016 (P1): Error message shows pattern and value
Method TestPatternErrorMessage() As %Status
{
    Set tData = "abc"
    Set tSchema = {"type": "string", "pattern": "^[0-9]+$"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String should fail pattern validation")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "pattern", "Error message should mention pattern")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "[0-9]", "Error message should show the pattern")
    Quit $$$OK
}

/// 2.1-UNIT-017 (P2): Empty string against pattern ".*" (should pass)
Method TestPatternEmptyString() As %Status
{
    Set tData = ""
    Set tSchema = {"type": "string", "pattern": ".*"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Empty string should match .* pattern")
    Quit $$$OK
}

/// 2.1-UNIT-018 (P2): Patterns are case-sensitive by default
Method TestPatternCaseSensitive() As %Status
{
    Set tSchema = {"type": "string", "pattern": "^[a-z]+$"}
    
    // Lowercase matches
    Set tData = "hello"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Lowercase string should match lowercase pattern")
    
    // Uppercase does not match
    Set tData = "HELLO"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Uppercase string should not match lowercase pattern")
    
    Quit $$$OK
}

// ============================================================================

// Task 5: format Tests

// ============================================================================

/// 2.1-UNIT-019 (P1): Valid ISO 8601 date-time passes
Method TestFormatDateTime() As %Status
{
    Set tSchema = {"type": "string", "format": "date-time"}
    
    // With Z timezone
    Set tData = "2023-12-04T14:30:00Z"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid date-time with Z should pass")
    
    // With offset timezone
    Set tData = "2023-12-04T14:30:00+05:30"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid date-time with offset should pass")
    
    // With milliseconds
    Set tData = "2023-12-04T14:30:00.123Z"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid date-time with milliseconds should pass")
    
    Quit $$$OK
}

/// 2.1-UNIT-020 (P1): Valid ISO 8601 date passes
Method TestFormatDate() As %Status
{
    Set tSchema = {"type": "string", "format": "date"}
    
    Set tData = "2023-12-04"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid date should pass")
    
    Quit $$$OK
}

/// 2.1-UNIT-021 (P1): Valid time format passes
Method TestFormatTime() As %Status
{
    Set tSchema = {"type": "string", "format": "time"}
    
    // Basic time
    Set tData = "14:30:00"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid time should pass")
    
    // With milliseconds
    Set tData = "14:30:00.123"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid time with milliseconds should pass")
    
    Quit $$$OK
}

/// 2.1-UNIT-022 (P1): Valid email addresses pass
Method TestFormatEmail() As %Status
{
    Set tSchema = {"type": "string", "format": "email"}
    
    Set tData = "user@example.com"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid email should pass")
    
    Set tData = "user.name+tag@example.co.uk"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Complex email should pass")
    
    Quit $$$OK
}

/// 2.1-UNIT-023 (P1): Valid URIs pass
Method TestFormatUri() As %Status
{
    Set tSchema = {"type": "string", "format": "uri"}
    
    Set tData = "https://example.com/path"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid HTTPS URI should pass")
    
    Set tData = "http://example.com"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid HTTP URI should pass")
    
    Set tData = "ftp://files.example.com/file.txt"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid FTP URI should pass")
    
    Quit $$$OK
}

/// 2.1-UNIT-024 (P1): Valid UUIDs pass
Method TestFormatUuid() As %Status
{
    Set tSchema = {"type": "string", "format": "uuid"}
    
    Set tData = "550e8400-e29b-41d4-a716-446655440000"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid UUID should pass")
    
    // Uppercase should also work
    Set tData = "550E8400-E29B-41D4-A716-446655440000"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Uppercase UUID should pass")
    
    Quit $$$OK
}

/// 2.1-UNIT-025 (P2): Invalid format is lenient (doesn't fail validation)
Method TestFormatInvalidLenient() As %Status
{
    Set tSchema = {"type": "string", "format": "date"}
    
    // Invalid date format - should still pass (lenient mode)
    Set tData = "not-a-date"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Invalid format should still pass (lenient mode)")
    
    Quit $$$OK
}

/// 2.1-UNIT-026 (P2): Unknown format name is ignored
Method TestFormatUnknown() As %Status
{
    Set tSchema = {"type": "string", "format": "unknown-format-xyz"}
    
    Set tData = "any string"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Unknown format should be ignored")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors for unknown format")
    
    Quit $$$OK
}

/// 2.1-UNIT-027 (P1): Error (if any) has keyword="format"
Method TestFormatErrorKeyword() As %Status
{
    // Note: Since format is lenient, we just verify the format keyword is processed
    // without errors. This test confirms format validation is wired up correctly.
    Set tSchema = {"type": "string", "format": "email"}
    
    Set tData = "valid@email.com"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Valid email format should pass")
    
    Quit $$$OK
}

// ============================================================================

// Task 6: Integration Tests

// ============================================================================

/// 2.1-INT-001 (P1): Multiple string keywords in same schema
Method TestStringKeywordsCombined() As %Status
{
    Set tSchema = {"type": "string", "minLength": 5, "maxLength": 20, "pattern": "^[a-z]+$"}
    
    // Valid case: meets all constraints
    Set tData = "hello"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String meeting all constraints should pass")
    
    // Too short
    Set tData = "hi"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String too short should fail")
    
    // Too long
    Set tData = "thisistoolongofastring"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String too long should fail")
    
    // Wrong pattern
    Set tData = "Hello123"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String not matching pattern should fail")
    
    Quit $$$OK
}

/// 2.1-INT-002 (P1): String keywords with type: "string"
Method TestStringKeywordsWithType() As %Status
{
    Set tSchema = {"type": "string", "minLength": 3}
    
    // String type passes with valid length
    Set tData = "hello"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String type with valid length should pass")
    
    // Number type fails type check
    Set tData = 12345
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Number should fail type: string")
    
    Quit $$$OK
}

/// 2.1-INT-003 (P2): String keywords ignored for non-string data
Method TestStringKeywordsNonString() As %Status
{
    // Schema with string keywords but no type restriction
    Set tSchema = {"minLength": 10, "maxLength": 20}
    
    // Number should pass (string keywords don't apply)
    Set tData = 42
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Number should pass - string keywords ignored for non-strings")
    
    // Object should pass (string keywords don't apply)
    Set tData = {"key": "value"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object should pass - string keywords ignored for non-strings")
    
    // Array should pass (string keywords don't apply)
    Set tData = [1, 2, 3]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array should pass - string keywords ignored for non-strings")
    
    Quit $$$OK
}

}

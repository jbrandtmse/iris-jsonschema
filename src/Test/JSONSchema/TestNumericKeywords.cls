/// Test.JSONSchema.TestNumericKeywords - Numeric keyword validation tests
/// <p>
/// Tests for JSON Schema numeric keywords: minimum, maximum,
/// exclusiveMinimum, exclusiveMaximum, multipleOf
/// </p>
/// <p>
/// Originally from Story 2.2: Numeric Validation Keywords
/// </p>
Class Test.JSONSchema.TestNumericKeywords Extends %UnitTest.TestCase
{

// =============================================================================

// Task 3: Unit Tests for minimum and maximum (AC: 1, 2, 6, 8, 9)

// =============================================================================

/// 2.2-UNIT-001 (P0): Number >= minimum passes
Method TestMinimumValid() As %Status
{
    Set tData = 10
    Set tSchema = {"type": "number", "minimum": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 10 should pass minimum 5")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-002 (P0): Number < minimum fails
Method TestMinimumInvalid() As %Status
{
    Set tData = 3
    Set tSchema = {"type": "number", "minimum": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 3 should fail minimum 5")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "minimum", "Error keyword should be minimum")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "3", "Error should mention actual value")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "5", "Error should mention minimum value")
    Quit $$$OK
}

/// 2.2-UNIT-003 (P1): Number exactly equal to minimum passes
Method TestMinimumBoundary() As %Status
{
    Set tData = 5
    Set tSchema = {"type": "number", "minimum": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 5 should pass minimum 5 (inclusive)")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-004 (P0): Number <= maximum passes
Method TestMaximumValid() As %Status
{
    Set tData = 8
    Set tSchema = {"type": "number", "maximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 8 should pass maximum 10")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-005 (P0): Number > maximum fails
Method TestMaximumInvalid() As %Status
{
    Set tData = 15
    Set tSchema = {"type": "number", "maximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 15 should fail maximum 10")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "maximum", "Error keyword should be maximum")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "15", "Error should mention actual value")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "10", "Error should mention maximum value")
    Quit $$$OK
}

/// 2.2-UNIT-006 (P1): Number exactly equal to maximum passes
Method TestMaximumBoundary() As %Status
{
    Set tData = 10
    Set tSchema = {"type": "number", "maximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 10 should pass maximum 10 (inclusive)")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-007 (P0): Both minimum and maximum constraints work together
Method TestMinMaxCombined() As %Status
{
    // Test value in range
    Set tData = 7
    Set tSchema = {"type": "number", "minimum": 5, "maximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 7 should pass range 5-10")
    
    // Test value below range
    Set tData = 3
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 3 should fail range 5-10")
    
    // Test value above range
    Set tData = 15
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 15 should fail range 5-10")
    
    Quit $$$OK
}

/// 2.2-UNIT-008 (P1): Floating-point minimum validation
Method TestMinimumFloat() As %Status
{
    Set tData = 5.5
    Set tSchema = {"minimum": 5.25}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 5.5 should pass minimum 5.25")
    
    Set tData = 5.1
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 5.1 should fail minimum 5.25")
    
    Quit $$$OK
}

/// 2.2-UNIT-009 (P1): Floating-point maximum validation
Method TestMaximumFloat() As %Status
{
    Set tData = 9.5
    Set tSchema = {"maximum": 9.75}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 9.5 should pass maximum 9.75")
    
    Set tData = 9.9
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 9.9 should fail maximum 9.75")
    
    Quit $$$OK
}

/// 2.2-UNIT-010 (P1): Negative minimum values work correctly
Method TestMinimumNegative() As %Status
{
    Set tData = -50
    Set tSchema = {"minimum": -100}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value -50 should pass minimum -100")
    
    Set tData = -150
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value -150 should fail minimum -100")
    
    Quit $$$OK
}

// =============================================================================

// Task 4: Unit Tests for exclusiveMinimum and exclusiveMaximum (AC: 3, 4, 6, 8, 9)

// =============================================================================

/// 2.2-UNIT-011 (P0): Number > exclusiveMinimum passes
Method TestExclusiveMinimumValid() As %Status
{
    Set tData = 6
    Set tSchema = {"exclusiveMinimum": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 6 should pass exclusiveMinimum 5")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-012 (P0): Number <= exclusiveMinimum fails
Method TestExclusiveMinimumInvalid() As %Status
{
    Set tData = 4
    Set tSchema = {"exclusiveMinimum": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 4 should fail exclusiveMinimum 5")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "exclusiveMinimum", "Error keyword should be exclusiveMinimum")
    Quit $$$OK
}

/// 2.2-UNIT-013 (P1): Number exactly equal to exclusiveMinimum fails
Method TestExclusiveMinimumBoundary() As %Status
{
    Set tData = 5
    Set tSchema = {"exclusiveMinimum": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 5 should fail exclusiveMinimum 5 (exclusive)")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Quit $$$OK
}

/// 2.2-UNIT-014 (P0): Number < exclusiveMaximum passes
Method TestExclusiveMaximumValid() As %Status
{
    Set tData = 9
    Set tSchema = {"exclusiveMaximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 9 should pass exclusiveMaximum 10")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-015 (P0): Number >= exclusiveMaximum fails
Method TestExclusiveMaximumInvalid() As %Status
{
    Set tData = 11
    Set tSchema = {"exclusiveMaximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 11 should fail exclusiveMaximum 10")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "exclusiveMaximum", "Error keyword should be exclusiveMaximum")
    Quit $$$OK
}

/// 2.2-UNIT-016 (P1): Number exactly equal to exclusiveMaximum fails
Method TestExclusiveMaximumBoundary() As %Status
{
    Set tData = 10
    Set tSchema = {"exclusiveMaximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 10 should fail exclusiveMaximum 10 (exclusive)")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Quit $$$OK
}

/// 2.2-UNIT-017 (P1): exclusiveMinimum and exclusiveMaximum together
Method TestExclusiveCombined() As %Status
{
    // Value in exclusive range (5 < x < 10)
    Set tData = 7
    Set tSchema = {"exclusiveMinimum": 5, "exclusiveMaximum": 10}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 7 should pass exclusive range 5-10")
    
    // Value at lower boundary (should fail)
    Set tData = 5
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 5 should fail exclusive range")
    
    // Value at upper boundary (should fail)
    Set tData = 10
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 10 should fail exclusive range")
    
    Quit $$$OK
}

/// 2.2-UNIT-018 (P1): minimum with exclusiveMaximum
Method TestMixedMinMaxExclusive() As %Status
{
    // Range: 5 <= x < 10
    Set tSchema = {"minimum": 5, "exclusiveMaximum": 10}
    
    // Value at inclusive minimum (should pass)
    Set tData = 5
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 5 should pass minimum 5")
    
    // Value at exclusive maximum (should fail)
    Set tData = 10
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 10 should fail exclusiveMaximum 10")
    
    // Value in range
    Set tData = 7
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 7 should pass mixed range")
    
    Quit $$$OK
}

// =============================================================================

// Task 5: Unit Tests for multipleOf (AC: 5, 6, 7, 8, 10)

// =============================================================================

/// 2.2-UNIT-019 (P0): Number that is exact multiple passes
Method TestMultipleOfValid() As %Status
{
    Set tData = 12
    Set tSchema = {"multipleOf": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 12 should pass multipleOf 3")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-020 (P0): Number that is not multiple fails
Method TestMultipleOfInvalid() As %Status
{
    Set tData = 13
    Set tSchema = {"multipleOf": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 13 should fail multipleOf 3")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "multipleOf", "Error keyword should be multipleOf")
    Quit $$$OK
}

/// 2.2-UNIT-021 (P1): Integer multipleOf validation
Method TestMultipleOfInteger() As %Status
{
    // 100 is a multiple of 5
    Set tData = 100
    Set tSchema = {"multipleOf": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 100 should pass multipleOf 5")
    
    // 101 is not a multiple of 5
    Set tData = 101
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 101 should fail multipleOf 5")
    
    Quit $$$OK
}

/// 2.2-UNIT-022 (P1): Floating-point multipleOf (e.g., multipleOf: 0.1)
Method TestMultipleOfFloat() As %Status
{
    Set tData = 0.5
    Set tSchema = {"multipleOf": 0.1}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 0.5 should pass multipleOf 0.1")
    
    Set tData = 1.2
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 1.2 should pass multipleOf 0.1")
    
    Quit $$$OK
}

/// 2.2-UNIT-023 (P2): Floating-point precision edge case
Method TestMultipleOfFloatPrecision() As %Status
{
    // Test floating-point precision: 0.7 should be multipleOf 0.1
    // This tests IEEE 754 precision handling
    Set tData = 0.7
    Set tSchema = {"multipleOf": 0.1}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "0.7 should be valid multipleOf 0.1")
    
    // Test 0.3 (known floating-point issue: 0.1 + 0.2)
    Set tData = 0.3
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "0.3 should be valid multipleOf 0.1")
    
    Quit $$$OK
}

/// 2.2-UNIT-024 (P1): Data value 0 is multiple of any positive number
Method TestMultipleOfZeroData() As %Status
{
    Set tData = 0
    Set tSchema = {"multipleOf": 7}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 0 should pass multipleOf 7 (0 is multiple of any number)")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.2-UNIT-025 (P1): Negative data numbers with multipleOf
Method TestMultipleOfNegativeData() As %Status
{
    // -6 is a multiple of 3
    Set tData = -6
    Set tSchema = {"multipleOf": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value -6 should pass multipleOf 3")
    
    // -7 is not a multiple of 3
    Set tData = -7
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value -7 should fail multipleOf 3")
    
    Quit $$$OK
}

/// 2.2-UNIT-026 (P1): Error message shows value and multipleOf
Method TestMultipleOfErrorMessage() As %Status
{
    Set tData = 7
    Set tSchema = {"multipleOf": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 7 should fail multipleOf 3")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "7", "Error should mention actual value")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "3", "Error should mention multipleOf value")
    Quit $$$OK
}

/// 2.2-UNIT-027 (P0): multipleOf: 0 in schema returns error (defensive)
Method TestMultipleOfZeroSchema() As %Status
{
    // DEFENSIVE: multipleOf: 0 is invalid schema, must return error not crash
    Set tData = 10
    Set tSchema = {"multipleOf": 0}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "multipleOf: 0 should fail validation")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "multipleOf", "Error keyword should be multipleOf")
    Do $$$AssertTrue(tErrors.%Get(0).message [ "greater than 0", "Error should mention invalid schema")
    Quit $$$OK
}

/// 2.2-UNIT-028 (P1): multipleOf with negative schema value returns error
Method TestMultipleOfNegativeSchema() As %Status
{
    // DEFENSIVE: multipleOf: -1 is invalid schema, must return error not crash
    Set tData = 10
    Set tSchema = {"multipleOf": -1}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "multipleOf: -1 should fail validation")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "multipleOf", "Error keyword should be multipleOf")
    Quit $$$OK
}

// =============================================================================

// Task 6: Integration Tests (AC: 6, 9)

// =============================================================================

/// 2.2-INT-001 (P1): Multiple numeric keywords in same schema
Method TestNumericKeywordsCombined() As %Status
{
    // Schema with minimum, maximum, and multipleOf
    Set tSchema = {"minimum": 10, "maximum": 100, "multipleOf": 5}
    
    // Valid: 50 is in range and multiple of 5
    Set tData = 50
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value 50 should pass all constraints")
    
    // Invalid: 7 is below minimum
    Set tData = 7
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 7 should fail minimum")
    
    // Invalid: 52 is not a multiple of 5
    Set tData = 52
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value 52 should fail multipleOf 5")
    
    Quit $$$OK
}

/// 2.2-INT-002 (P1): Numeric keywords with type: "number" or "integer"
Method TestNumericKeywordsWithType() As %Status
{
    // With type: "number"
    Set tSchema = {"type": "number", "minimum": 0, "maximum": 100}
    Set tData = 50.5
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Float 50.5 should pass number type with range")
    
    // With type: "integer"
    Set tSchema = {"type": "integer", "minimum": 0, "maximum": 100}
    Set tData = 50
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Integer 50 should pass integer type with range")
    
    // Integer type with float data should fail type but numeric constraints would pass
    Set tData = 50.5
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Float 50.5 should fail integer type")
    
    Quit $$$OK
}

/// 2.2-INT-003 (P2): Numeric keywords ignored for non-numeric data
Method TestNumericKeywordsNonNumeric() As %Status
{
    // String data with numeric keywords - keywords should be ignored
    Set tSchema = {"type": "string", "minimum": 0, "maximum": 100}
    Set tData = "hello"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String 'hello' should pass - numeric keywords ignored for strings")
    
    // Boolean data with numeric keywords
    Set tSchema = {"minimum": 0, "maximum": 100}
    Set tWrapper = ##class(%DynamicObject).%New()
    Set tWrapper.value = 1  // Boolean true
    Set tSchema2 = {"type": "boolean", "minimum": 0}
    // Note: Using true/false directly needs special handling
    // For now, test with object type
    Set tData = {"key": "value"}
    Set tSchema = {"minimum": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object should pass - numeric keywords ignored for objects")
    
    Quit $$$OK
}

}

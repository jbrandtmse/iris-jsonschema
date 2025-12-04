/// Test.JSONSchema.TestCombinators - Unit tests for schema combinator keywords
/// <p>
/// Tests for allOf, anyOf, oneOf, and not combinator keywords.
/// Originally from Story 2.5: Schema Combinators
/// </p>
Class Test.JSONSchema.TestCombinators Extends %UnitTest.TestCase
{

// ============================================================================

// Task 3: allOf Tests

// ============================================================================

/// 2.5-UNIT-001 (P0): Data matches all schemas passes
Method TestAllOfValid() As %Status
{
    // Data: number >= 5 AND <= 10
    Set tData = 7
    Set tSchema = {
        "allOf": [
            {"type": "number", "minimum": 5},
            {"type": "number", "maximum": 10}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Data matching all schemas should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.5-UNIT-002 (P0): Data fails one schema fails
Method TestAllOfInvalid() As %Status
{
    // Data: 12 is > 10 so fails second schema
    Set tData = 12
    Set tSchema = {
        "allOf": [
            {"type": "number", "minimum": 5},
            {"type": "number", "maximum": 10}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Data failing any schema should fail")
    Quit $$$OK
}

/// 2.5-UNIT-003 (P1): Error indicates which sub-schema failed
Method TestAllOfErrorMessage() As %Status
{
    Set tData = 12
    Set tSchema = {
        "allOf": [
            {"type": "number", "minimum": 5},
            {"type": "number", "maximum": 10}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail validation")
    // Check that allOf error is present
    Set tFoundAllOf = 0
    For tIdx = 0:1:(tErrors.%Size()-1) {
        Set tError = tErrors.%Get(tIdx)
        If tError.keyword = "allOf" {
            Set tFoundAllOf = 1
            Do $$$AssertTrue(tError.message [ "failed", "Error message should mention failed schemas")
        }
    }
    Do $$$AssertTrue(tFoundAllOf, "Should have allOf error")
    Quit $$$OK
}

/// 2.5-UNIT-004 (P1): allOf combines type + properties
Method TestAllOfMultipleConstraints() As %Status
{
    Set tData = {"name": "John", "age": 30}
    Set tSchema = {
        "allOf": [
            {"type": "object"},
            {"required": ["name"]},
            {"required": ["age"]}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object with both required props should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.5-UNIT-005 (P1): allOf containing allOf (nested)
Method TestAllOfNested() As %Status
{
    Set tData = 7
    Set tSchema = {
        "allOf": [
            {"type": "number"},
            {
                "allOf": [
                    {"minimum": 5},
                    {"maximum": 10}
                ]
            }
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Nested allOf should work correctly")
    Quit $$$OK
}

// ============================================================================

// Task 4: anyOf Tests

// ============================================================================

/// 2.5-UNIT-006 (P0): Data matches one schema passes
Method TestAnyOfValid() As %Status
{
    // Data: string OR number - "hello" is string
    Set tData = "hello"
    Set tSchema = {
        "anyOf": [
            {"type": "string"},
            {"type": "number"}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Data matching any schema should pass")
    Quit $$$OK
}

/// 2.5-UNIT-007 (P0): Data matches multiple schemas passes
Method TestAnyOfValidMultiple() As %Status
{
    // Data: 5 matches both number schemas
    Set tData = 5
    Set tSchema = {
        "anyOf": [
            {"type": "number", "minimum": 0},
            {"type": "number", "maximum": 10}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Data matching multiple schemas should still pass")
    Quit $$$OK
}

/// 2.5-UNIT-008 (P0): Data matches no schemas fails
Method TestAnyOfInvalid() As %Status
{
    // Data: object is neither string nor number
    Set tData = {"key": "value"}
    Set tSchema = {
        "anyOf": [
            {"type": "string"},
            {"type": "number"}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Data matching no schemas should fail")
    Quit $$$OK
}

/// 2.5-UNIT-009 (P1): Error shows attempted schemas count
Method TestAnyOfErrorMessage() As %Status
{
    // Data: object is neither string nor number
    Set tData = {"key": "value"}
    Set tSchema = {
        "anyOf": [
            {"type": "string"},
            {"type": "number"}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail validation")
    // Check error message
    Set tFoundAnyOf = 0
    For tIdx = 0:1:(tErrors.%Size()-1) {
        Set tError = tErrors.%Get(tIdx)
        If tError.keyword = "anyOf" {
            Set tFoundAnyOf = 1
            Do $$$AssertTrue(tError.message [ "0 of 2", "Error should show 0 of 2 matched")
        }
    }
    Do $$$AssertTrue(tFoundAnyOf, "Should have anyOf error")
    Quit $$$OK
}

/// 2.5-UNIT-010 (P1): anyOf with type constraints
Method TestAnyOfWithType() As %Status
{
    Set tData = "hello"
    Set tSchema = {
        "anyOf": [
            {"type": "string", "minLength": 3},
            {"type": "number", "minimum": 0}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String matching first option should pass")
    Quit $$$OK
}

// ============================================================================

// Task 5: oneOf Tests

// ============================================================================

/// 2.5-UNIT-011 (P0): Data matches exactly one schema passes
Method TestOneOfValid() As %Status
{
    // Data: 5 matches first schema (multipleOf 5), not second (multipleOf 3)
    Set tData = 5
    Set tSchema = {
        "oneOf": [
            {"type": "number", "multipleOf": 5},
            {"type": "number", "multipleOf": 3}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Data matching exactly one schema should pass")
    Quit $$$OK
}

/// 2.5-UNIT-012 (P0): Data matches no schemas fails
Method TestOneOfZeroMatches() As %Status
{
    // Data: 7 matches neither multipleOf 5 nor multipleOf 3
    Set tData = 7
    Set tSchema = {
        "oneOf": [
            {"type": "number", "multipleOf": 5},
            {"type": "number", "multipleOf": 3}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Data matching zero schemas should fail")
    Quit $$$OK
}

/// 2.5-UNIT-013 (P0): Data matches 2+ schemas fails
Method TestOneOfMultipleMatches() As %Status
{
    // Data: 15 matches BOTH multipleOf 5 AND multipleOf 3
    Set tData = 15
    Set tSchema = {
        "oneOf": [
            {"type": "number", "multipleOf": 5},
            {"type": "number", "multipleOf": 3}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Data matching multiple schemas should fail")
    Quit $$$OK
}

/// 2.5-UNIT-014 (P1): Error message when zero match
Method TestOneOfErrorZero() As %Status
{
    Set tData = 7
    Set tSchema = {
        "oneOf": [
            {"type": "number", "multipleOf": 5},
            {"type": "number", "multipleOf": 3}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail")
    Set tFoundOneOf = 0
    For tIdx = 0:1:(tErrors.%Size()-1) {
        Set tError = tErrors.%Get(tIdx)
        If tError.keyword = "oneOf" {
            Set tFoundOneOf = 1
            Do $$$AssertTrue(tError.message [ "0 of 2", "Error should show 0 of 2 matched")
        }
    }
    Do $$$AssertTrue(tFoundOneOf, "Should have oneOf error")
    Quit $$$OK
}

/// 2.5-UNIT-015 (P1): Error message shows which schemas matched
Method TestOneOfErrorMultiple() As %Status
{
    Set tData = 15
    Set tSchema = {
        "oneOf": [
            {"type": "number", "multipleOf": 5},
            {"type": "number", "multipleOf": 3}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail")
    Set tFoundOneOf = 0
    For tIdx = 0:1:(tErrors.%Size()-1) {
        Set tError = tErrors.%Get(tIdx)
        If tError.keyword = "oneOf" {
            Set tFoundOneOf = 1
            Do $$$AssertTrue(tError.message [ "matches 2", "Error should show 2 schemas matched")
        }
    }
    Do $$$AssertTrue(tFoundOneOf, "Should have oneOf error")
    Quit $$$OK
}

/// 2.5-UNIT-016 (P1): oneOf selecting object variants
Method TestOneOfWithProperties() As %Status
{
    // Object with "type": "A" should match first variant only
    Set tData = {"type": "A", "value": 10}
    Set tSchema = {
        "oneOf": [
            {"type": "object", "properties": {"type": {"const": "A"}}, "required": ["type"]},
            {"type": "object", "properties": {"type": {"const": "B"}}, "required": ["type"]}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object matching exactly one variant should pass")
    Quit $$$OK
}

// ============================================================================

// Task 6: not Tests

// ============================================================================

/// 2.5-UNIT-017 (P0): Data NOT matching schema passes
Method TestNotValid() As %Status
{
    // Data: "hello" is NOT a number
    Set tData = "hello"
    Set tSchema = {"not": {"type": "number"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Data NOT matching schema should pass")
    Quit $$$OK
}

/// 2.5-UNIT-018 (P0): Data matching schema fails
Method TestNotInvalid() As %Status
{
    // Data: 42 IS a number
    Set tData = 42
    Set tSchema = {"not": {"type": "number"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Data matching 'not' schema should fail")
    // Check error keyword
    Set tFoundNot = 0
    For tIdx = 0:1:(tErrors.%Size()-1) {
        Set tError = tErrors.%Get(tIdx)
        If tError.keyword = "not" {
            Set tFoundNot = 1
        }
    }
    Do $$$AssertTrue(tFoundNot, "Error keyword should be 'not'")
    Quit $$$OK
}

/// 2.5-UNIT-019 (P1): not with type constraint
Method TestNotWithType() As %Status
{
    // Any non-string should pass
    Set tData = 42
    Set tSchema = {"not": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Number should pass 'not string' schema")
    Quit $$$OK
}

/// 2.5-UNIT-020 (P1): not with enum constraint
Method TestNotWithEnum() As %Status
{
    Set tData = "green"
    Set tSchema = {"not": {"enum": ["red", "blue"]}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "'green' should pass 'not red/blue' schema")
    
    // Test failure case
    Set tData2 = "red"
    Set tValid2 = ##class(JSONSchema.Validator).Validate(tData2, tSchema, .tErrors2)
    Do $$$AssertEquals(tValid2, 0, "'red' should fail 'not red/blue' schema")
    Quit $$$OK
}

/// 2.5-UNIT-021 (P1): not containing allOf
Method TestNotNested() As %Status
{
    // Should pass if data does NOT match (number AND >= 5)
    Set tData = 3
    Set tSchema = {
        "not": {
            "allOf": [
                {"type": "number"},
                {"minimum": 5}
            ]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "3 does not match 'number >= 5' so should pass 'not'")
    
    // Test failure - 7 matches number >= 5
    Set tData2 = 7
    Set tValid2 = ##class(JSONSchema.Validator).Validate(tData2, tSchema, .tErrors2)
    Do $$$AssertEquals(tValid2, 0, "7 matches 'number >= 5' so should fail 'not'")
    Quit $$$OK
}

// ============================================================================

// Task 7: Integration Tests

// ============================================================================

/// 2.5-INT-001 (P1): allOf with anyOf inside
Method TestNestedCombinators() As %Status
{
    Set tData = {"type": "A", "value": 10}
    Set tSchema = {
        "type": "object",
        "allOf": [
            {"required": ["type"]},
            {
                "anyOf": [
                    {"properties": {"type": {"const": "A"}}},
                    {"properties": {"type": {"const": "B"}}}
                ]
            }
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Nested combinators should work correctly")
    Quit $$$OK
}

/// 2.5-INT-002 (P1): items schema using oneOf
Method TestCombinatorWithArrayItems() As %Status
{
    Set tData = [1, "two", 3]
    Set tSchema = {
        "type": "array",
        "items": {
            "oneOf": [
                {"type": "number"},
                {"type": "string"}
            ]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array items using oneOf should validate")
    Quit $$$OK
}

/// 2.5-INT-003 (P1): property using anyOf
Method TestCombinatorWithObjectProps() As %Status
{
    Set tData = {"id": "abc123"}
    Set tSchema = {
        "type": "object",
        "properties": {
            "id": {
                "anyOf": [
                    {"type": "string"},
                    {"type": "number"}
                ]
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Property with anyOf should validate")
    Quit $$$OK
}

/// 2.5-INT-004 (P1): Deep combinator nesting scenario
Method TestComplexNesting() As %Status
{
    Set tData = {"status": "active", "count": 5}
    Set tSchema = {
        "allOf": [
            {"type": "object"},
            {
                "oneOf": [
                    {
                        "allOf": [
                            {"properties": {"status": {"const": "active"}}},
                            {"required": ["count"]}
                        ]
                    },
                    {
                        "allOf": [
                            {"properties": {"status": {"const": "inactive"}}},
                            {"not": {"required": ["count"]}}
                        ]
                    }
                ]
            }
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Complex nested combinators should work")
    Quit $$$OK
}

/// 2.5-INT-005 (P2): Error paths through combinators
Method TestCombinatorErrorPaths() As %Status
{
    Set tData = {"name": 123}
    Set tSchema = {
        "allOf": [
            {"type": "object"},
            {"properties": {"name": {"type": "string"}}}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail - name is number not string")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have errors")
    Quit $$$OK
}

/// 2.5-INT-006 (P2): Combinator placeholder for $ref support
Method TestCombinatorWithRef() As %Status
{
    // Placeholder test - $ref support will be in Story 2.7
    // For now, test combinator with inline schemas only
    Set tData = {"value": 10}
    Set tSchema = {
        "anyOf": [
            {"type": "object", "properties": {"value": {"type": "number"}}},
            {"type": "object", "properties": {"value": {"type": "string"}}}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "anyOf with inline schemas should work")
    Quit $$$OK
}

}

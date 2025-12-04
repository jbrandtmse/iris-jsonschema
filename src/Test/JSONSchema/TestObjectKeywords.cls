/// Test.JSONSchema.TestObjectKeywords - Object keyword validation tests
/// <p>
/// Tests for JSON Schema object keywords: required, properties,
/// additionalProperties, patternProperties, propertyNames,
/// minProperties, maxProperties
/// </p>
/// <p>
/// Originally from Story 2.3: Object Validation Keywords
/// </p>
Class Test.JSONSchema.TestObjectKeywords Extends %UnitTest.TestCase
{

// ============================================================================

// Task 7: Tests for required and properties (AC: 1, 2, 10, 11)

// ============================================================================

/// 2.3-UNIT-001 (P0): Object with all required properties passes
Method TestRequiredValid() As %Status
{
    Set tData = {"name": "John", "age": 30}
    Set tSchema = {"type": "object", "required": ["name", "age"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object with all required properties should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-002 (P0): Object missing required property fails
Method TestRequiredMissing() As %Status
{
    Set tData = {"name": "John"}
    Set tSchema = {"type": "object", "required": ["name", "age"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Object missing required property should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "required", "Error keyword should be required")
    Quit $$$OK
}

/// 2.3-UNIT-003 (P1): Multiple missing required properties all reported
Method TestRequiredMultipleMissing() As %Status
{
    Set tData = {"other": "value"}
    Set tSchema = {"type": "object", "required": ["name", "age", "email"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Object missing multiple required properties should fail")
    Do $$$AssertEquals(tErrors.%Size(), 3, "Three errors expected for three missing properties")
    Quit $$$OK
}

/// 2.3-UNIT-004 (P0): Object properties validate against sub-schemas
Method TestPropertiesValid() As %Status
{
    Set tData = {"name": "John", "age": 30}
    Set tSchema = {
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer"}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object properties matching sub-schemas should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-005 (P0): Property failing sub-schema validation fails
Method TestPropertiesInvalid() As %Status
{
    Set tData = {"name": 123, "age": "thirty"}
    Set tSchema = {
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer"}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Object with invalid property types should fail")
    Do $$$AssertTrue(tErrors.%Size() >= 2, "At least two errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-006 (P1): Error dataPath points to failing property
Method TestPropertiesErrorPath() As %Status
{
    Set tData = {"user": {"name": 123}}
    Set tSchema = {
        "type": "object",
        "properties": {
            "user": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"}
                }
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid nested property should fail")
    Do $$$AssertEquals(tErrors.%Get(0).dataPath, "#/user/name", "Error path should point to nested property")
    Quit $$$OK
}

// ============================================================================

// Task 8: Tests for additionalProperties (AC: 3, 4)

// ============================================================================

/// 2.3-UNIT-007 (P0): No extra properties passes with additionalProperties: false
Method TestAdditionalPropertiesFalseValid() As %Status
{
    Set tData = {"name": "John"}
    Set tSchema = {
        "type": "object",
        "properties": {"name": {"type": "string"}},
        "additionalProperties": false
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object with no extra properties should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-008 (P0): Extra properties rejected with additionalProperties: false
Method TestAdditionalPropertiesFalseInvalid() As %Status
{
    Set tData = {"name": "John", "extra": "value"}
    Set tSchema = {
        "type": "object",
        "properties": {"name": {"type": "string"}},
        "additionalProperties": false
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Extra property should fail with additionalProperties: false")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "additionalProperties", "Error keyword should be additionalProperties")
    Quit $$$OK
}

/// 2.3-UNIT-009 (P1): Extra properties matching schema pass
Method TestAdditionalPropertiesSchemaValid() As %Status
{
    Set tData = {"name": "John", "extra": "value"}
    Set tSchema = {
        "type": "object",
        "properties": {"name": {"type": "string"}},
        "additionalProperties": {"type": "string"}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Extra properties matching schema should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-010 (P1): Extra properties failing schema rejected
Method TestAdditionalPropertiesSchemaInvalid() As %Status
{
    Set tData = {"name": "John", "extra": 123}
    Set tSchema = {
        "type": "object",
        "properties": {"name": {"type": "string"}},
        "additionalProperties": {"type": "string"}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Extra properties failing schema should fail")
    Quit $$$OK
}

/// 2.3-UNIT-011 (P1): additionalProperties: true allows all
Method TestAdditionalPropertiesTrueAllowed() As %Status
{
    Set tData = {"name": "John", "extra": 123, "another": true}
    Set tSchema = {
        "type": "object",
        "properties": {"name": {"type": "string"}},
        "additionalProperties": true
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "additionalProperties: true should allow all extra properties")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

// ============================================================================

// Task 9: Tests for patternProperties (AC: 5, 9)

// ============================================================================

/// 2.3-UNIT-012 (P0): Properties matching pattern validate
Method TestPatternPropertiesValid() As %Status
{
    Set tData = {"str_name": "John", "str_city": "NYC"}
    Set tSchema = {
        "type": "object",
        "patternProperties": {
            "^str_.*": {"type": "string"}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Properties matching pattern should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-013 (P0): Properties failing pattern schema rejected
Method TestPatternPropertiesInvalid() As %Status
{
    Set tData = {"str_name": 123, "str_city": "NYC"}
    Set tSchema = {
        "type": "object",
        "patternProperties": {
            "^str_.*": {"type": "string"}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Properties failing pattern schema should fail")
    Quit $$$OK
}

/// 2.3-UNIT-014 (P1): Multiple patterns work correctly
Method TestPatternPropertiesMultiplePatterns() As %Status
{
    Set tData = {"str_name": "John", "num_age": 30}
    Set tSchema = {
        "type": "object",
        "patternProperties": {
            "^str_.*": {"type": "string"},
            "^num_.*": {"type": "integer"}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Multiple patterns should work correctly")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-015 (P1): patternProperties works with properties
Method TestPatternPropertiesWithProperties() As %Status
{
    Set tData = {"name": "John", "str_city": "NYC"}
    Set tSchema = {
        "type": "object",
        "properties": {
            "name": {"type": "string"}
        },
        "patternProperties": {
            "^str_.*": {"type": "string"}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "properties and patternProperties should work together")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-016 (P2): patternProperties + additionalProperties: false
Method TestPatternPropertiesWithAdditional() As %Status
{
    Set tData = {"str_name": "John", "other": "value"}
    Set tSchema = {
        "type": "object",
        "patternProperties": {
            "^str_.*": {"type": "string"}
        },
        "additionalProperties": false
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Unmatched property should fail with additionalProperties: false")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "additionalProperties", "Error should be additionalProperties")
    Quit $$$OK
}

// ============================================================================

// Task 10: Tests for propertyNames, minProperties, maxProperties (AC: 6, 7, 8)

// ============================================================================

/// 2.3-UNIT-017 (P0): All property names match schema
Method TestPropertyNamesValid() As %Status
{
    Set tData = {"abc": 1, "def": 2}
    Set tSchema = {
        "type": "object",
        "propertyNames": {"minLength": 3}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "All property names matching schema should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-018 (P0): Invalid property name rejected
Method TestPropertyNamesInvalid() As %Status
{
    Set tData = {"ab": 1, "def": 2}
    Set tSchema = {
        "type": "object",
        "propertyNames": {"minLength": 3}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid property name should fail")
    Quit $$$OK
}

/// 2.3-UNIT-019 (P1): propertyNames with pattern constraint
Method TestPropertyNamesPattern() As %Status
{
    Set tData = {"prop_a": 1, "prop_b": 2}
    Set tSchema = {
        "type": "object",
        "propertyNames": {"pattern": "^prop_.*"}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Property names matching pattern should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-020 (P0): Object with enough properties passes minProperties
Method TestMinPropertiesValid() As %Status
{
    Set tData = {"a": 1, "b": 2, "c": 3}
    Set tSchema = {"type": "object", "minProperties": 2}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object with enough properties should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-021 (P0): Object with too few properties fails minProperties
Method TestMinPropertiesInvalid() As %Status
{
    Set tData = {"a": 1}
    Set tSchema = {"type": "object", "minProperties": 2}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Object with too few properties should fail")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "minProperties", "Error keyword should be minProperties")
    Quit $$$OK
}

/// 2.3-UNIT-022 (P0): Object within max properties passes
Method TestMaxPropertiesValid() As %Status
{
    Set tData = {"a": 1, "b": 2}
    Set tSchema = {"type": "object", "maxProperties": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object within max properties should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-UNIT-023 (P0): Object exceeding max properties fails
Method TestMaxPropertiesInvalid() As %Status
{
    Set tData = {"a": 1, "b": 2, "c": 3, "d": 4}
    Set tSchema = {"type": "object", "maxProperties": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Object exceeding max properties should fail")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "maxProperties", "Error keyword should be maxProperties")
    Quit $$$OK
}

/// 2.3-UNIT-024 (P1): Both min and max constraints work together
Method TestMinMaxPropertiesCombined() As %Status
{
    Set tData = {"a": 1, "b": 2}
    Set tSchema = {"type": "object", "minProperties": 2, "maxProperties": 4}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object within min/max range should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

// ============================================================================

// Task 11: Integration Tests (AC: 9, 12)

// ============================================================================

/// 2.3-INT-001 (P1): Objects within objects validate correctly
Method TestNestedObjectValidation() As %Status
{
    Set tData = {
        "person": {
            "name": "John",
            "address": {
                "city": "NYC",
                "zip": "10001"
            }
        }
    }
    Set tSchema = {
        "type": "object",
        "properties": {
            "person": {
                "type": "object",
                "required": ["name", "address"],
                "properties": {
                    "name": {"type": "string"},
                    "address": {
                        "type": "object",
                        "required": ["city"],
                        "properties": {
                            "city": {"type": "string"},
                            "zip": {"type": "string"}
                        }
                    }
                }
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Nested object with valid structure should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-INT-002 (P1): Deeply nested objects (3+ levels) with path tracking
Method TestDeepNestedObjects() As %Status
{
    Set tData = {
        "level1": {
            "level2": {
                "level3": {
                    "value": 123
                }
            }
        }
    }
    Set tSchema = {
        "type": "object",
        "properties": {
            "level1": {
                "type": "object",
                "properties": {
                    "level2": {
                        "type": "object",
                        "properties": {
                            "level3": {
                                "type": "object",
                                "properties": {
                                    "value": {"type": "string"}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Deeply nested invalid value should fail")
    Do $$$AssertEquals(tErrors.%Get(0).dataPath, "#/level1/level2/level3/value", "Error path should be deeply nested")
    Quit $$$OK
}

/// 2.3-INT-003 (P1): properties + required + additionalProperties combined
Method TestCombinedObjectKeywords() As %Status
{
    Set tData = {"name": "John", "age": 30}
    Set tSchema = {
        "type": "object",
        "required": ["name"],
        "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer"}
        },
        "additionalProperties": false
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Combined keywords should work together")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-INT-004 (P2): All three property keywords together
Method TestPropertiesPatternAdditional() As %Status
{
    Set tData = {"name": "John", "str_city": "NYC"}
    Set tSchema = {
        "type": "object",
        "properties": {
            "name": {"type": "string"}
        },
        "patternProperties": {
            "^str_.*": {"type": "string"}
        },
        "additionalProperties": false
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "All three property keywords should work together")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.3-INT-005 (P1): Object keywords with type, enum, etc.
Method TestObjectWithOtherKeywords() As %Status
{
    Set tData = {"status": "active", "count": 5}
    Set tSchema = {
        "type": "object",
        "required": ["status"],
        "properties": {
            "status": {"type": "string", "enum": ["active", "inactive"]},
            "count": {"type": "integer", "minimum": 0}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object with nested type/enum/numeric keywords should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

}

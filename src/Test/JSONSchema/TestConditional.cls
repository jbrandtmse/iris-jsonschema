/// Test.JSONSchema.TestConditional - Conditional schema keyword validation tests
/// <p>
/// Tests for JSON Schema conditional keywords: if/then/else and dependencies.
/// Covers property dependencies, schema dependencies, and conditional schema
/// application patterns.
/// </p>
/// <p>
/// Originally from Story 2.6: Conditional Schema Keywords
/// </p>
Class Test.JSONSchema.TestConditional Extends %UnitTest.TestCase
{

// ============================================================================

// if/then/else Unit Tests (Tasks 4: UNIT-001 to UNIT-008)

// ============================================================================

/// 2.6-UNIT-001 (P0): Test if passes, then applies, data valid
Method TestIfThenValid() As %Status
{
    // if property type=string, then minLength=3
    Set tData = {"type": "string", "value": "hello"}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "then": {"properties": {"value": {"minLength": 3}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Data matching then schema should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.6-UNIT-002 (P0): Test if passes, then applies, data invalid
Method TestIfThenInvalid() As %Status
{
    // if property type=string, then minLength=3, but value is "ab" (too short)
    Set tData = {"type": "string", "value": "ab"}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "then": {"properties": {"value": {"minLength": 3}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Data failing then schema should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Errors expected")
    Quit $$$OK
}

/// 2.6-UNIT-003 (P0): Test if fails, else applies, data valid
Method TestIfElseValid() As %Status
{
    // if type=string fails (type is number), else requires minimum
    Set tData = {"type": "number", "value": 10}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "then": {"properties": {"value": {"minLength": 3}}},
        "else": {"properties": {"value": {"minimum": 0}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Data matching else schema should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.6-UNIT-004 (P0): Test if fails, else applies, data invalid
Method TestIfElseInvalid() As %Status
{
    // if type=string fails (type is number), else requires minimum >= 0, but value is -5
    Set tData = {"type": "number", "value": -5}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "then": {"properties": {"value": {"minLength": 3}}},
        "else": {"properties": {"value": {"minimum": 0}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Data failing else schema should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Errors expected")
    Quit $$$OK
}

/// 2.6-UNIT-005 (P1): Test if fails, no else, passes
Method TestIfThenNoElse() As %Status
{
    // if type=string fails, no else defined - should pass
    Set tData = {"type": "number", "value": 10}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "then": {"properties": {"value": {"minLength": 3}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "No else with failing if should pass")
    Quit $$$OK
}

/// 2.6-UNIT-006 (P1): Test if passes, no then, passes
Method TestIfElseNoThen() As %Status
{
    // if type=string passes, no then defined - should pass
    Set tData = {"type": "string", "value": "x"}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "else": {"properties": {"value": {"minimum": 0}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "No then with passing if should pass")
    Quit $$$OK
}

/// 2.6-UNIT-007 (P1): Test error indicates branch (then/else)
Method TestIfThenElseErrorMessage() As %Status
{
    // Verify error message indicates which branch failed
    Set tData = {"type": "string", "value": "ab"}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "then": {"properties": {"value": {"minLength": 3}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail")
    // Check that there's an error related to 'then' branch
    Set tFoundThenError = 0
    For tIdx = 0:1:(tErrors.%Size() - 1) {
        Set tError = tErrors.%Get(tIdx)
        If tError.keyword = "then" {
            Set tFoundThenError = 1
            Quit
        }
    }
    Do $$$AssertTrue(tFoundThenError, "Error should indicate 'then' branch")
    Quit $$$OK
}

/// 2.6-UNIT-008 (P1): Test if with combinators in then/else
Method TestIfWithCombinators() As %Status
{
    // then schema uses allOf combinator
    Set tData = {"type": "special", "value": "hello", "extra": 10}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "special"}}},
        "then": {
            "allOf": [
                {"properties": {"value": {"type": "string"}}},
                {"properties": {"extra": {"type": "integer"}}}
            ]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "then with allOf combinator should work")
    Quit $$$OK
}

// ============================================================================

// dependencies Unit Tests (Tasks 5: UNIT-009 to UNIT-016)

// ============================================================================

/// 2.6-UNIT-009 (P0): Test property dependency - required props exist
Method TestPropertyDependencyValid() As %Status
{
    // If "credit_card" exists, "billing_address" must exist
    Set tData = {"credit_card": "1234", "billing_address": "123 Main St"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "credit_card": ["billing_address"]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Property dependency satisfied should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.6-UNIT-010 (P0): Test property dependency - required prop missing
Method TestPropertyDependencyInvalid() As %Status
{
    // If "credit_card" exists, "billing_address" must exist (but doesn't)
    Set tData = {"credit_card": "1234"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "credit_card": ["billing_address"]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Missing required dependency should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Errors expected")
    // Check keyword
    Set tError = tErrors.%Get(0)
    Do $$$AssertEquals(tError.keyword, "dependencies", "Error keyword should be dependencies")
    Quit $$$OK
}

/// 2.6-UNIT-011 (P0): Test property dependency not triggered (trigger prop absent)
Method TestPropertyDependencyNotTriggered() As %Status
{
    // If "credit_card" doesn't exist, no dependency check
    Set tData = {"name": "John"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "credit_card": ["billing_address"]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Dependency not triggered should pass")
    Quit $$$OK
}

/// 2.6-UNIT-012 (P0): Test schema dependency - schema validates
Method TestSchemaDependencyValid() As %Status
{
    // If "name" exists, object must have "age" property (via schema)
    Set tData = {"name": "John", "age": 30}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "name": {"required": ["age"]}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Schema dependency satisfied should pass")
    Quit $$$OK
}

/// 2.6-UNIT-013 (P0): Test schema dependency - schema fails
Method TestSchemaDependencyInvalid() As %Status
{
    // If "name" exists, object must have "age" property (but doesn't)
    Set tData = {"name": "John"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "name": {"required": ["age"]}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Schema dependency failure should fail")
    Quit $$$OK
}

/// 2.6-UNIT-014 (P1): Test schema dependency not triggered
Method TestSchemaDependencyNotTriggered() As %Status
{
    // If "name" doesn't exist, no schema dependency check
    Set tData = {"email": "test@example.com"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "name": {"required": ["age"]}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Schema dependency not triggered should pass")
    Quit $$$OK
}

/// 2.6-UNIT-015 (P1): Test multiple dependencies
Method TestMultipleDependencies() As %Status
{
    // Multiple dependency keys
    Set tData = {"credit_card": "1234", "billing_address": "123 Main", "shipping_address": "456 Oak"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "credit_card": ["billing_address"],
            "billing_address": ["shipping_address"]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Multiple dependencies satisfied should pass")
    Quit $$$OK
}

/// 2.6-UNIT-016 (P1): Test dependency error message
Method TestDependencyErrorMessage() As %Status
{
    // Verify error message indicates missing property
    Set tData = {"credit_card": "1234"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "credit_card": ["billing_address"]
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail")
    Set tError = tErrors.%Get(0)
    Do $$$AssertTrue(tError.message [ "billing_address", "Error should mention missing property")
    Quit $$$OK
}

// ============================================================================

// Integration Tests (Task 6: INT-001 to INT-007)

// ============================================================================

/// 2.6-INT-001 (P1): Test conditional with object properties
Method TestConditionalWithProperties() As %Status
{
    // Conditional combined with properties validation
    Set tData = {"type": "person", "name": "John", "age": 30}
    Set tSchema = {
        "type": "object",
        "properties": {
            "type": {"type": "string"},
            "name": {"type": "string"}
        },
        "if": {"properties": {"type": {"const": "person"}}},
        "then": {"required": ["name", "age"]}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Conditional with properties should work")
    Quit $$$OK
}

/// 2.6-INT-002 (P1): Test type switching based on property value
Method TestConditionalTypeSwitching() As %Status
{
    // Different validation based on "format" property
    Set tData = {"format": "email", "value": "test@example.com"}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"format": {"const": "email"}}},
        "then": {"properties": {"value": {"format": "email"}}},
        "else": {"properties": {"value": {"type": "string"}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Type switching based on property should work")
    Quit $$$OK
}

/// 2.6-INT-003 (P1): Test multiple if/then/else with allOf
Method TestMultipleIfThenElseAllOf() As %Status
{
    // allOf combining multiple conditionals
    Set tData = {"type": "premium", "level": "gold", "discount": 20}
    Set tSchema = {
        "type": "object",
        "allOf": [
            {
                "if": {"properties": {"type": {"const": "premium"}}},
                "then": {"required": ["level"]}
            },
            {
                "if": {"properties": {"level": {"const": "gold"}}},
                "then": {"properties": {"discount": {"minimum": 15}}}
            }
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Multiple conditionals via allOf should work")
    Quit $$$OK
}

/// 2.6-INT-004 (P1): Test nested conditional (then contains another if/then)
Method TestNestedConditional() As %Status
{
    // then contains another if/then
    Set tData = {"type": "premium", "level": "gold", "discount": 20}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "premium"}}},
        "then": {
            "if": {"properties": {"level": {"const": "gold"}}},
            "then": {"properties": {"discount": {"minimum": 15}}}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Nested conditional should validate correctly")
    Quit $$$OK
}

/// 2.6-INT-005 (P1): Test conditional inside oneOf
Method TestConditionalWithCombinators() As %Status
{
    // if/then/else inside anyOf (oneOf won't work as both pass without else)
    // This tests that conditionals work within combinator schemas
    Set tData = {"type": "A", "value": 10}
    Set tSchema = {
        "anyOf": [
            {
                "if": {"properties": {"type": {"const": "A"}}},
                "then": {"properties": {"value": {"type": "integer"}}},
                "else": {"properties": {"value": {"type": "string"}}}
            }
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Conditional inside anyOf should work")
    
    // Also test with a failing case
    Set tData2 = {"type": "A", "value": "not-a-number"}
    Set tValid2 = ##class(JSONSchema.Validator).Validate(tData2, tSchema, .tErrors2)
    Do $$$AssertEquals(tValid2, 0, "Conditional inside anyOf should fail when then fails")
    Quit $$$OK
}

/// 2.6-INT-006 (P2): Test dependencies combined with if/then/else
Method TestDependenciesWithConditional() As %Status
{
    // Both dependencies and if/then on same schema
    Set tData = {"payment_method": "card", "card_number": "1234", "billing_address": "123 Main"}
    Set tSchema = {
        "type": "object",
        "dependencies": {
            "card_number": ["billing_address"]
        },
        "if": {"properties": {"payment_method": {"const": "card"}}},
        "then": {"required": ["card_number"]}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Dependencies with conditional should work together")
    Quit $$$OK
}

/// 2.6-INT-007 (P2): Test error paths through conditionals
Method TestConditionalErrorPaths() As %Status
{
    // Verify error paths are correct through conditional validation
    Set tData = {"type": "string", "value": "ab"}
    Set tSchema = {
        "type": "object",
        "if": {"properties": {"type": {"const": "string"}}},
        "then": {"properties": {"value": {"minLength": 5}}}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail minLength validation")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have errors")
    Quit $$$OK
}

}

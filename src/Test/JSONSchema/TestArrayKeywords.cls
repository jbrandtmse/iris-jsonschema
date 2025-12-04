/// Test.JSONSchema.TestArrayKeywords - Array validation keywords tests
/// <p>
/// Tests for JSON Schema array validation keywords: items, additionalItems,
/// minItems, maxItems, uniqueItems, contains
/// </p>
/// <p>
/// Originally from Story 2.4: Array Validation Keywords
/// </p>
Class Test.JSONSchema.TestArrayKeywords Extends %UnitTest.TestCase
{

/// ============================================================================
/// Task 5: minItems/maxItems Tests
/// ============================================================================
/// 2.4-UNIT-001 (P0): TestMinItemsValid - Array with enough items passes
Method TestMinItemsValid() As %Status
{
    Set tData = [1, 2, 3]
    Set tSchema = {"type": "array", "minItems": 2}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array with enough items should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.4-UNIT-002 (P0): TestMinItemsInvalid - Array with too few items fails
Method TestMinItemsInvalid() As %Status
{
    Set tData = [1]
    Set tSchema = {"type": "array", "minItems": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with too few items should fail")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "minItems", "Error keyword should be minItems")
    Quit $$$OK
}

/// 2.4-UNIT-003 (P0): TestMaxItemsValid - Array within max items passes
Method TestMaxItemsValid() As %Status
{
    Set tData = [1, 2, 3]
    Set tSchema = {"type": "array", "maxItems": 5}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array within max items should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.4-UNIT-004 (P0): TestMaxItemsInvalid - Array exceeding max items fails
Method TestMaxItemsInvalid() As %Status
{
    Set tData = [1, 2, 3, 4, 5]
    Set tSchema = {"type": "array", "maxItems": 3}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array exceeding max items should fail")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "maxItems", "Error keyword should be maxItems")
    Quit $$$OK
}

/// 2.4-UNIT-005 (P1): TestMinMaxItemsCombined - Both constraints work together
Method TestMinMaxItemsCombined() As %Status
{
    Set tSchema = {"type": "array", "minItems": 2, "maxItems": 5}
    
    // Test valid: within range
    Set tData = [1, 2, 3]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array within range should pass")
    
    // Test invalid: too few
    Set tData = [1]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with too few items should fail")
    
    // Test invalid: too many
    Set tData = [1, 2, 3, 4, 5, 6]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with too many items should fail")
    
    Quit $$$OK
}

/// 2.4-UNIT-006 (P1): TestMinItemsEmpty - Empty array with minItems: 0 passes
Method TestMinItemsEmpty() As %Status
{
    Set tData = []
    Set tSchema = {"type": "array", "minItems": 0}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Empty array with minItems: 0 should pass")
    Quit $$$OK
}

/// ============================================================================
/// Task 6: items (schema) Tests
/// ============================================================================
/// 2.4-UNIT-007 (P0): TestItemsSchemaValid - All items match schema
Method TestItemsSchemaValid() As %Status
{
    Set tData = ["hello", "world", "test"]
    Set tSchema = {"type": "array", "items": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array with all items matching schema should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.4-UNIT-008 (P0): TestItemsSchemaInvalid - Item failing schema fails validation
Method TestItemsSchemaInvalid() As %Status
{
    Set tData = ["hello", 123, "world"]
    Set tSchema = {"type": "array", "items": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with invalid item should fail")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "type", "Error keyword should be type")
    Quit $$$OK
}

/// 2.4-UNIT-009 (P1): TestItemsSchemaErrorPath - Error dataPath shows array index
Method TestItemsSchemaErrorPath() As %Status
{
    Set tData = ["hello", 123, "world"]
    Set tSchema = {"type": "array", "items": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with invalid item should fail")
    Do $$$AssertEquals(tErrors.%Get(0).dataPath, "#/1", "Error path should show array index")
    Quit $$$OK
}

/// 2.4-UNIT-010 (P1): TestItemsSchemaEmpty - Empty array passes items validation
Method TestItemsSchemaEmpty() As %Status
{
    Set tData = []
    Set tSchema = {"type": "array", "items": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Empty array should pass items validation")
    Quit $$$OK
}

/// 2.4-UNIT-011 (P1): TestItemsSchemaComplex - Items with complex schema
Method TestItemsSchemaComplex() As %Status
{
    Set tData = [{"name": "John", "age": 30}, {"name": "Jane", "age": 25}]
    Set tSchema = {
        "type": "array",
        "items": {
            "type": "object",
            "required": ["name", "age"],
            "properties": {
                "name": {"type": "string"},
                "age": {"type": "number"}
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array with complex items should pass")
    Quit $$$OK
}

/// ============================================================================
/// Task 7: Tuple Validation Tests
/// ============================================================================
/// 2.4-UNIT-012 (P0): TestTupleValid - Array matches tuple schema
Method TestTupleValid() As %Status
{
    Set tData = ["hello", 42, true]
    Set tSchema = {
        "type": "array",
        "items": [
            {"type": "string"},
            {"type": "number"},
            {"type": "boolean"}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Tuple with correct types should pass")
    Quit $$$OK
}

/// 2.4-UNIT-013 (P0): TestTupleInvalid - Item at wrong position fails
Method TestTupleInvalid() As %Status
{
    Set tData = ["hello", "wrong", true]
    Set tSchema = {
        "type": "array",
        "items": [
            {"type": "string"},
            {"type": "number"},
            {"type": "boolean"}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Tuple with wrong type at position should fail")
    Do $$$AssertEquals(tErrors.%Get(0).dataPath, "#/1", "Error path should show position 1")
    Quit $$$OK
}

/// 2.4-UNIT-014 (P1): TestTupleAdditionalFalse - Extra items rejected with additionalItems: false
Method TestTupleAdditionalFalse() As %Status
{
    Set tData = ["hello", 42, true, "extra"]
    Set tSchema = {
        "type": "array",
        "items": [
            {"type": "string"},
            {"type": "number"},
            {"type": "boolean"}
        ],
        "additionalItems": false
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Extra items should be rejected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "additionalItems", "Error keyword should be additionalItems")
    Quit $$$OK
}

/// 2.4-UNIT-015 (P1): TestTupleAdditionalSchema - Extra items validated against schema
Method TestTupleAdditionalSchema() As %Status
{
    Set tData = ["hello", 42, "extra1", "extra2"]
    Set tSchema = {
        "type": "array",
        "items": [
            {"type": "string"},
            {"type": "number"}
        ],
        "additionalItems": {"type": "string"}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Extra items matching schema should pass")
    
    // Test invalid extra item
    Set tData = ["hello", 42, "extra1", 999]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Extra item not matching schema should fail")
    
    Quit $$$OK
}

/// 2.4-UNIT-016 (P1): TestTupleAdditionalTrue - Extra items allowed with additionalItems: true
Method TestTupleAdditionalTrue() As %Status
{
    Set tData = ["hello", 42, "anything", 999, true]
    Set tSchema = {
        "type": "array",
        "items": [
            {"type": "string"},
            {"type": "number"}
        ],
        "additionalItems": true
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Extra items should be allowed with additionalItems: true")
    Quit $$$OK
}

/// 2.4-UNIT-017 (P1): TestTupleShorterThanSchema - Array shorter than tuple schema is valid
Method TestTupleShorterThanSchema() As %Status
{
    Set tData = ["hello"]
    Set tSchema = {
        "type": "array",
        "items": [
            {"type": "string"},
            {"type": "number"},
            {"type": "boolean"}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array shorter than tuple schema should be valid")
    Quit $$$OK
}

/// ============================================================================
/// Task 8: uniqueItems Tests
/// ============================================================================
/// 2.4-UNIT-018 (P0): TestUniqueItemsValid - Array with unique items passes
Method TestUniqueItemsValid() As %Status
{
    Set tData = [1, 2, 3, 4]
    Set tSchema = {"type": "array", "uniqueItems": true}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array with unique items should pass")
    Quit $$$OK
}

/// 2.4-UNIT-019 (P0): TestUniqueItemsInvalid - Array with duplicates fails
Method TestUniqueItemsInvalid() As %Status
{
    Set tData = [1, 2, 3, 2]
    Set tSchema = {"type": "array", "uniqueItems": true}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with duplicates should fail")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "uniqueItems", "Error keyword should be uniqueItems")
    Quit $$$OK
}

/// 2.4-UNIT-020 (P1): TestUniqueItemsObjects - Deep comparison of object duplicates
Method TestUniqueItemsObjects() As %Status
{
    Set tData = [{"a": 1}, {"a": 2}, {"a": 1}]
    Set tSchema = {"type": "array", "uniqueItems": true}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Duplicate objects should fail uniqueItems")
    
    // Test unique objects
    Set tData = [{"a": 1}, {"a": 2}, {"a": 3}]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Unique objects should pass")
    
    Quit $$$OK
}

/// 2.4-UNIT-021 (P1): TestUniqueItemsArrays - Deep comparison of nested arrays
Method TestUniqueItemsArrays() As %Status
{
    Set tData = [[1, 2], [3, 4], [1, 2]]
    Set tSchema = {"type": "array", "uniqueItems": true}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Duplicate arrays should fail uniqueItems")
    
    // Test unique arrays
    Set tData = [[1, 2], [3, 4], [5, 6]]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Unique arrays should pass")
    
    Quit $$$OK
}

/// 2.4-UNIT-022 (P1): TestUniqueItemsEmpty - Empty array passes uniqueItems
Method TestUniqueItemsEmpty() As %Status
{
    Set tData = []
    Set tSchema = {"type": "array", "uniqueItems": true}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Empty array should pass uniqueItems")
    Quit $$$OK
}

/// 2.4-UNIT-023 (P2): TestUniqueItemsMixed - Mixed types that are unique
Method TestUniqueItemsMixed() As %Status
{
    Set tData = [1, "1", true, 1.0]
    Set tSchema = {"type": "array", "uniqueItems": true}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    // Note: 1 and 1.0 are the same numeric value, so should be duplicates
    Do $$$AssertEquals(tValid, 0, "1 and 1.0 should be considered duplicates")
    
    // Test truly unique mixed types
    Set tData = [1, "1", true, null]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Different types with same representation should be unique")
    
    Quit $$$OK
}

/// ============================================================================
/// Task 9: contains Tests
/// ============================================================================
/// 2.4-UNIT-024 (P0): TestContainsValid - At least one item matches
Method TestContainsValid() As %Status
{
    Set tData = [1, "hello", 3]
    Set tSchema = {"type": "array", "contains": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array with at least one matching item should pass")
    Quit $$$OK
}

/// 2.4-UNIT-025 (P0): TestContainsInvalid - No items match schema
Method TestContainsInvalid() As %Status
{
    Set tData = [1, 2, 3]
    Set tSchema = {"type": "array", "contains": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with no matching items should fail")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "contains", "Error keyword should be contains")
    Quit $$$OK
}

/// 2.4-UNIT-026 (P1): TestContainsMultipleMatches - Multiple items match (still valid)
Method TestContainsMultipleMatches() As %Status
{
    Set tData = ["hello", "world", 123]
    Set tSchema = {"type": "array", "contains": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array with multiple matching items should pass")
    Quit $$$OK
}

/// 2.4-UNIT-027 (P1): TestContainsEmptyArray - Empty array fails contains
Method TestContainsEmptyArray() As %Status
{
    Set tData = []
    Set tSchema = {"type": "array", "contains": {"type": "string"}}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Empty array should fail contains")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "contains", "Error keyword should be contains")
    Quit $$$OK
}

/// 2.4-UNIT-028 (P1): TestContainsComplexSchema - Contains with object schema
Method TestContainsComplexSchema() As %Status
{
    Set tData = [{"type": "A"}, {"type": "B"}, {"type": "C"}]
    Set tSchema = {
        "type": "array",
        "contains": {
            "type": "object",
            "properties": {"type": {"const": "B"}}
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array containing object matching complex schema should pass")
    
    // Test when no objects match
    Set tData = [{"type": "A"}, {"type": "C"}]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with no matching objects should fail")
    
    Quit $$$OK
}

/// ============================================================================
/// Task 10: Integration Tests
/// ============================================================================
/// 2.4-INT-001 (P1): TestNestedArrays - Arrays within arrays validate correctly
Method TestNestedArrays() As %Status
{
    Set tData = [[1, 2], [3, 4], [5, 6]]
    Set tSchema = {
        "type": "array",
        "items": {
            "type": "array",
            "items": {"type": "integer"},
            "minItems": 2,
            "maxItems": 2
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Nested arrays should validate correctly")
    
    // Test invalid nested array
    Set tData = [[1, 2], [3], [5, 6]]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Nested array violating minItems should fail")
    
    Quit $$$OK
}

/// 2.4-INT-002 (P1): TestArrayOfObjects - Array of objects with object validation
Method TestArrayOfObjects() As %Status
{
    Set tData = [
        {"name": "John", "age": 30},
        {"name": "Jane", "age": 25}
    ]
    Set tSchema = {
        "type": "array",
        "minItems": 1,
        "items": {
            "type": "object",
            "required": ["name", "age"],
            "properties": {
                "name": {"type": "string", "minLength": 1},
                "age": {"type": "integer", "minimum": 0}
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array of objects should validate correctly")
    Quit $$$OK
}

/// 2.4-INT-003 (P1): TestDeepNestedArrayPath - Path tracking for deeply nested arrays
Method TestDeepNestedArrayPath() As %Status
{
    Set tData = [[[1, "wrong", 3]]]
    Set tSchema = {
        "type": "array",
        "items": {
            "type": "array",
            "items": {
                "type": "array",
                "items": {"type": "integer"}
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid deeply nested item should fail")
    Do $$$AssertEquals(tErrors.%Get(0).dataPath, "#/0/0/1", "Error path should show deep nesting")
    Quit $$$OK
}

/// 2.4-INT-004 (P1): TestCombinedArrayKeywords - items + minItems + maxItems + uniqueItems
Method TestCombinedArrayKeywords() As %Status
{
    Set tSchema = {
        "type": "array",
        "items": {"type": "integer"},
        "minItems": 2,
        "maxItems": 5,
        "uniqueItems": true
    }
    
    // Valid case
    Set tData = [1, 2, 3]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array meeting all constraints should pass")
    
    // Invalid: duplicate items
    Set tData = [1, 2, 2]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with duplicates should fail")
    
    // Invalid: too few items
    Set tData = [1]
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with too few items should fail")
    
    Quit $$$OK
}

/// 2.4-INT-005 (P2): TestArrayWithObjectKeywords - Array inside object with all constraints
Method TestArrayWithObjectKeywords() As %Status
{
    Set tData = {
        "users": [
            {"name": "John", "age": 30},
            {"name": "Jane", "age": 25}
        ]
    }
    Set tSchema = {
        "type": "object",
        "properties": {
            "users": {
                "type": "array",
                "minItems": 1,
                "maxItems": 10,
                "items": {
                    "type": "object",
                    "required": ["name", "age"],
                    "properties": {
                        "name": {"type": "string"},
                        "age": {"type": "integer"}
                    }
                }
            }
        }
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array inside object with constraints should validate correctly")
    Quit $$$OK
}

}

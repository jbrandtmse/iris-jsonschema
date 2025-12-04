/// Test.JSONSchema.TestEnumConst - Enum and const keyword validation tests
/// <p>
/// Tests for JSON Schema "enum" and "const" keywords covering:
/// - Enum validation with primitive types, objects, and arrays
/// - Const validation with deep equality checking
/// - Mixed type enums
/// - Error message formatting
/// </p>
/// <p>
/// Originally from Story 1.3: Enum and Const Keywords
/// </p>
Class Test.JSONSchema.TestEnumConst Extends %UnitTest.TestCase
{

// ============================================================================

// ENUM KEYWORD TESTS (Story 1.3)

// ============================================================================

/// 1.3-UNIT-001 (P1): String matches one of enum values (happy path)
Method TestEnumStringValid() As %Status
{
    Set tData = "red"
    Set tSchema = {"enum": ["red", "green", "blue"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Value in enum should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-002 (P1): String not in enum values (unhappy path)
Method TestEnumStringInvalid() As %Status
{
    Set tData = "yellow"
    Set tSchema = {"enum": ["red", "green", "blue"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Value not in enum should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "enum", "Error keyword should be 'enum'")
    Quit $$$OK
}

/// 1.3-UNIT-003 (P1): Enum validation passes for first value in list (boundary)
Method TestEnumFirstValue() As %Status
{
    Set tData = "first"
    Set tSchema = {"enum": ["first", "middle", "last"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "First enum value should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-004 (P1): Enum validation passes for last value in list (boundary)
Method TestEnumLastValue() As %Status
{
    Set tData = "last"
    Set tSchema = {"enum": ["first", "middle", "last"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Last enum value should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-005 (P1): Number matches enum value
Method TestEnumNumberValid() As %Status
{
    Set tData = 42
    Set tSchema = {"enum": [10, 42, 100]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Number in enum should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-006 (P1): Number not in enum values
Method TestEnumNumberInvalid() As %Status
{
    Set tData = 50
    Set tSchema = {"enum": [10, 42, 100]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Number not in enum should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "enum", "Error keyword should be 'enum'")
    Quit $$$OK
}

/// 1.3-UNIT-007 (P1): Boolean in enum passes
Method TestEnumBooleanValid() As %Status
{
    Set tWrapper = {"value": true}
    Set tData = tWrapper.value
    Set tTrue = tWrapper.value
    Set tSchema = {"enum": [(tTrue), "yes", 1]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Boolean in enum should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-007-EXT: Null in enum values (use JSON extraction pattern)
Method TestEnumNullValid() As %Status
{
    Set tWrapper = {"value": null}
    Set tData = tWrapper.value
    Set tNull = tWrapper.value
    Set tSchema = {"enum": [(tNull), "none", 0]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Null in enum should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-008 (P0): Enum validates object equality (deep comparison critical)
Method TestEnumObjectEquality() As %Status
{
    Set tData = {"name": "John", "age": 30}
    Set tObj1 = {"name": "Jane", "age": 25}
    Set tObj2 = {"name": "John", "age": 30}
    Set tObj3 = {"name": "Bob", "age": 40}
    Set tSchema = {"enum": [(tObj1), (tObj2), (tObj3)]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object matching enum value should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-009 (P0): Enum validates array equality (deep comparison critical)
Method TestEnumArrayEquality() As %Status
{
    Set tData = [1, 2, 3]
    Set tArr1 = [1, 2]
    Set tArr2 = [1, 2, 3]
    Set tArr3 = [1, 2, 3, 4]
    Set tSchema = {"enum": [(tArr1), (tArr2), (tArr3)]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array matching enum value should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-010 (P1): Enum with multiple types [1, "two", true]
Method TestEnumMixedTypes() As %Status
{
    Set tWrapper = {"bool": true}
    Set tTrue = tWrapper.bool
    Set tData = tTrue
    Set tSchema = {"enum": [1, "two", (tTrue)]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Boolean in mixed-type enum should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-011 (P2): Enum fails with empty enum array (nothing allowed)
Method TestEnumEmptyArray() As %Status
{
    Set tData = "anything"
    Set tSchema = {"enum": []}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Empty enum should reject all values")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "enum", "Error keyword should be 'enum'")
    Quit $$$OK
}

/// 1.3-UNIT-025 (P1): Verify error message lists allowed values
Method TestEnumErrorMessage() As %Status
{
    Set tData = "invalid"
    Set tSchema = {"enum": ["red", "green", "blue"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail validation")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Set tMessage = tErrors.%Get(0).message
    Do $$$AssertTrue(tMessage [ "red", "Error should list enum values")
    Do $$$AssertTrue(tMessage [ "Value must be one of:", "Error should have correct format")
    Quit $$$OK
}

/// 1.3-UNIT-027 (P1): Enum error has keyword="enum"
Method TestEnumErrorKeyword() As %Status
{
    Set tData = "invalid"
    Set tSchema = {"enum": ["valid"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail validation")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "enum", "Error keyword must be 'enum'")
    Quit $$$OK
}

/// 1.3-INT-001 (P1): Enum keyword processed by Validator.Validate()
Method TestEnumIntegration() As %Status
{
    Set tData = "green"
    Set tSchema = {"type": "string", "enum": ["red", "green", "blue"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Enum with type should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

// ============================================================================

// CONST KEYWORD TESTS (Story 1.3)

// ============================================================================

/// 1.3-UNIT-012 (P1): String equals const value (happy path)
Method TestConstStringValid() As %Status
{
    Set tData = "hello"
    Set tSchema = {"const": "hello"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "String matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-013 (P1): String differs from const (unhappy path)
Method TestConstStringInvalid() As %Status
{
    Set tData = "world"
    Set tSchema = {"const": "hello"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "String not matching const should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "const", "Error keyword should be 'const'")
    Quit $$$OK
}

/// 1.3-UNIT-014 (P1): Number equals const value
Method TestConstNumberValid() As %Status
{
    Set tData = 42
    Set tSchema = {"const": 42}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Number matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-015 (P1): Boolean equals const
Method TestConstBooleanValid() As %Status
{
    Set tWrapper = {"value": true}
    Set tData = tWrapper.value
    Set tConst = tWrapper.value
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Boolean matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-016 (P1): Null equals const (extract from JSON)
Method TestConstNullValid() As %Status
{
    Set tWrapper = {"value": null}
    Set tData = tWrapper.value
    Set tConst = tWrapper.value
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Null matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-017 (P0): Const validates deep object equality (critical)
Method TestConstObjectValid() As %Status
{
    Set tData = {"name": "John", "age": 30}
    Set tConst = {"name": "John", "age": 30}
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Object matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-018 (P0): Const fails for object with different values
Method TestConstObjectInvalid() As %Status
{
    Set tData = {"name": "John", "age": 31}
    Set tConst = {"name": "John", "age": 30}
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Object with different values should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "const", "Error keyword should be 'const'")
    Quit $$$OK
}

/// 1.3-UNIT-019 (P0): Const fails for object with different keys
Method TestConstObjectDifferentKeys() As %Status
{
    Set tData = {"name": "John", "city": "NYC"}
    Set tConst = {"name": "John", "age": 30}
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Object with different keys should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "const", "Error keyword should be 'const'")
    Quit $$$OK
}

/// 1.3-UNIT-020 (P0): Const validates deep array equality (critical)
Method TestConstArrayValid() As %Status
{
    Set tData = [1, 2, 3]
    Set tConst = [1, 2, 3]
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Array matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-021 (P1): Array differs from const
Method TestConstArrayInvalid() As %Status
{
    Set tData = [1, 2, 4]
    Set tConst = [1, 2, 3]
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with different values should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "const", "Error keyword should be 'const'")
    Quit $$$OK
}

/// 1.3-UNIT-022 (P1): Const fails for array with different order
Method TestConstArrayDifferentOrder() As %Status
{
    Set tData = [3, 2, 1]
    Set tConst = [1, 2, 3]
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Array with different order should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "const", "Error keyword should be 'const'")
    Quit $$$OK
}

/// 1.3-UNIT-023 (P0): Nested object/array equals const (most complex)
Method TestConstNestedValid() As %Status
{
    Set tData = {"user": {"name": "John", "tags": ["admin", "user"]}, "count": 5}
    Set tConst = {"user": {"name": "John", "tags": ["admin", "user"]}, "count": 5}
    Set tSchema = {"const": (tConst)}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Nested structure matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-024 (P2): Const handles floating point comparison
Method TestConstFloatingPoint() As %Status
{
    Set tData = 3.14
    Set tSchema = {"const": 3.14}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Floating point matching const should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.3-UNIT-026 (P1): Verify error message shows expected const
Method TestConstErrorMessage() As %Status
{
    Set tData = "wrong"
    Set tSchema = {"const": "expected"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail validation")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One error expected")
    Set tMessage = tErrors.%Get(0).message
    Do $$$AssertTrue(tMessage [ "expected", "Error should show const value")
    Do $$$AssertTrue(tMessage [ "Value must equal:", "Error should have correct format")
    Quit $$$OK
}

/// 1.3-UNIT-028 (P1): Const error has keyword="const"
Method TestConstErrorKeyword() As %Status
{
    Set tData = "wrong"
    Set tSchema = {"const": "right"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Should fail validation")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "const", "Error keyword must be 'const'")
    Quit $$$OK
}

/// 1.3-INT-002 (P1): Const keyword processed by Validator.Validate()
Method TestConstIntegration() As %Status
{
    Set tData = 42
    Set tSchema = {"type": "number", "const": 42}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Const with type should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

}

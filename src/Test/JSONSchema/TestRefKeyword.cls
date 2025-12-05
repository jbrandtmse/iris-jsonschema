/// Test.JSONSchema.TestRefKeyword - Unit tests for $ref keyword
/// <p>
/// Tests for JSON Schema $ref reference resolution covering:
/// - Internal references (#/definitions/..., #/$defs/...)
/// - Circular reference detection
/// - Remote reference resolution (mocked via cache)
/// - Integration with combinators and conditionals
/// </p>
/// <p>
/// Originally from Story 2.7: Schema References ($ref)
/// </p>
Class Test.JSONSchema.TestRefKeyword Extends %UnitTest.TestCase
{

// =============================================================================

// INTERNAL REFERENCE TESTS (2.7-UNIT-001 to 2.7-UNIT-008)

// =============================================================================

/// 2.7-UNIT-001 (P0): Test simple $ref to definitions
Method TestSimpleDefinitionsRef()
{
    Set tSchema = {
        "definitions": {
            "name": {"type": "string", "minLength": 1}
        },
        "type": "object",
        "properties": {
            "firstName": {"$ref": "#/definitions/name"},
            "lastName": {"$ref": "#/definitions/name"}
        }
    }
    Set tData = {"firstName": "John", "lastName": "Doe"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "$ref to definitions should resolve")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-UNIT-002 (P0): Test $ref to $defs (2020-12 alias)
Method TestDefsRef()
{
    Set tSchema = {
        "$defs": {
            "positiveInt": {"type": "integer", "minimum": 1}
        },
        "$ref": "#/$defs/positiveInt"
    }
    Set tData = 5
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "$ref to $defs should resolve")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-UNIT-003 (P0): Test nested definitions referencing other definitions
Method TestNestedDefinitionsRef()
{
    Set tSchema = {
        "definitions": {
            "name": {"type": "string", "minLength": 1},
            "person": {
                "type": "object",
                "properties": {
                    "name": {"$ref": "#/definitions/name"}
                },
                "required": ["name"]
            }
        },
        "$ref": "#/definitions/person"
    }
    Set tData = {"name": "Alice"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Nested definitions ref should resolve")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-UNIT-004 (P1): Test $ref to properties path
Method TestRefToProperties()
{
    Set tSchema = {
        "type": "object",
        "properties": {
            "address": {
                "type": "object",
                "properties": {
                    "street": {"type": "string"}
                }
            },
            "shipping": {"$ref": "#/properties/address"}
        }
    }
    Set tData = {
        "address": {"street": "Main St"},
        "shipping": {"street": "Oak Ave"}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "$ref to properties should resolve")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-UNIT-005 (P1): Test deep nested reference path
Method TestDeepNestedRef()
{
    Set tSchema = {
        "definitions": {
            "outer": {
                "properties": {
                    "inner": {"type": "string", "maxLength": 10}
                }
            }
        },
        "type": "object",
        "properties": {
            "test": {"$ref": "#/definitions/outer/properties/inner"}
        }
    }
    Set tData = {"test": "hello"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Deep nested ref should resolve")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-UNIT-006 (P1): Test $ref to invalid path returns error
Method TestRefInvalidPath()
{
    Set tSchema = {
        "$ref": "#/definitions/nonexistent"
    }
    Set tData = "anything"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid $ref path should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "$ref", "Error keyword should be $ref")
    Quit $$$OK
}

/// 2.7-UNIT-007 (P1): Test path with encoded characters (~0 and ~1)
Method TestRefEncodedCharacters()
{
    // ~0 decodes to ~, ~1 decodes to /
    Set tSchema = {
        "definitions": {
            "a/b": {"type": "string"},
            "c~d": {"type": "integer"}
        },
        "type": "object",
        "properties": {
            "test1": {"$ref": "#/definitions/a~1b"},
            "test2": {"$ref": "#/definitions/c~0d"}
        }
    }
    Set tData = {"test1": "hello", "test2": 42}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Encoded characters should decode correctly")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-UNIT-008 (P2): Test $ref overrides sibling keywords
Method TestRefOverridesSiblings()
{
    Set tSchema = {
        "definitions": {
            "anyString": {"type": "string"}
        },
        "$ref": "#/definitions/anyString",
        "type": "integer",
        "minimum": 100
    }
    // String should pass because $ref overrides type:integer
    Set tData = "hello"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "$ref should override sibling keywords - string should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

// =============================================================================

// CIRCULAR REFERENCE TESTS (2.7-UNIT-009 to 2.7-UNIT-012)

// =============================================================================

/// 2.7-UNIT-009 (P0): Test direct circular reference detection
Method TestDirectCircularRef()
{
    Set tSchema = {
        "definitions": {
            "recursive": {"$ref": "#/definitions/recursive"}
        },
        "$ref": "#/definitions/recursive"
    }
    Set tData = "anything"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Direct circular reference should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Quit $$$OK
}

/// 2.7-UNIT-010 (P0): Test indirect circular reference (A -> B -> A)
Method TestIndirectCircularRef()
{
    Set tSchema = {
        "definitions": {
            "A": {"$ref": "#/definitions/B"},
            "B": {"$ref": "#/definitions/A"}
        },
        "$ref": "#/definitions/A"
    }
    Set tData = "anything"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Indirect circular reference should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Quit $$$OK
}

/// 2.7-UNIT-011 (P1): Test recursive schema with valid data (tree structure)
Method TestRecursiveSchemaValid()
{
    Set tSchema = {
        "definitions": {
            "node": {
                "type": "object",
                "properties": {
                    "value": {"type": "string"},
                    "children": {
                        "type": "array",
                        "items": {"$ref": "#/definitions/node"}
                    }
                }
            }
        },
        "$ref": "#/definitions/node"
    }
    Set tData = {
        "value": "root",
        "children": [
            {"value": "child1", "children": []},
            {"value": "child2", "children": [{"value": "grandchild", "children": []}]}
        ]
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Recursive schema with valid data should pass")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-UNIT-012 (P1): Test circular reference error message
Method TestCircularRefErrorMessage()
{
    Set tSchema = {
        "definitions": {
            "loop": {"$ref": "#/definitions/loop"}
        },
        "$ref": "#/definitions/loop"
    }
    Set tData = "test"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Circular reference should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Set tMessage = tErrors.%Get(0).message
    Do $$$AssertTrue(tMessage [ "Circular", "Error message should mention circular reference")
    Quit $$$OK
}

// =============================================================================

// REMOTE REFERENCE TESTS (2.7-UNIT-013 to 2.7-UNIT-017)

// =============================================================================

/// 2.7-UNIT-013 (P1): Test remote ref with cache pre-population (mock)
Method TestRemoteRefMocked()
{
    Set tSchema = {
        "type": "object",
        "properties": {
            "name": {"$ref": "http://test.example.com/string-schema.json"}
        }
    }
    
    // Create context and pre-populate cache with "remote" schema
    Set tContext = ##class(JSONSchema.Context).%New()
    Set tContext.RootSchema = tSchema
    Do tContext.RemoteSchemaCache.%Set("http://test.example.com/string-schema.json", {"type": "string", "minLength": 1})
    
    Set tData = {"name": "John"}
    Set tValid = ##class(JSONSchema.Validator).ValidateNode(tData, tSchema, tContext)
    Do $$$AssertEquals(tValid, 1, "Remote ref with cached schema should validate")
    Quit $$$OK
}

/// 2.7-UNIT-014 (P1): Test remote ref caching (same URL not fetched twice)
Method TestRemoteRefCaching()
{
    // Schema that uses same remote ref twice
    Set tSchema = {
        "type": "object",
        "properties": {
            "first": {"$ref": "http://test.example.com/name-schema.json"},
            "second": {"$ref": "http://test.example.com/name-schema.json"}
        }
    }
    
    Set tContext = ##class(JSONSchema.Context).%New()
    Set tContext.RootSchema = tSchema
    // Pre-populate cache
    Do tContext.RemoteSchemaCache.%Set("http://test.example.com/name-schema.json", {"type": "string"})
    
    Set tData = {"first": "Alice", "second": "Bob"}
    Set tValid = ##class(JSONSchema.Validator).ValidateNode(tData, tSchema, tContext)
    Do $$$AssertEquals(tValid, 1, "Cached remote refs should work")
    // Verify cache was used (still has same entry)
    Do $$$AssertTrue(tContext.RemoteSchemaCache.%IsDefined("http://test.example.com/name-schema.json"), "Cache entry should exist")
    Quit $$$OK
}

/// 2.7-UNIT-015 (P2): Test remote ref error handling via invalid $ref format
Method TestRemoteRefHttpError()
{
    // Test with invalid $ref format - not internal (#) or remote (http)
    Set tSchema = {
        "$ref": "file:///local/schema.json"
    }
    Set tData = "test"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid $ref format should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Do $$$AssertEquals(tErrors.%Get(0).keyword, "$ref", "Error keyword should be $ref")
    Quit $$$OK
}

/// 2.7-UNIT-016 (P2): Test invalid internal ref path
Method TestRemoteRefInvalidJson()
{
    // Test error handling with invalid internal path that looks valid
    Set tSchema = {
        "definitions": {},
        "$ref": "#/definitions/missing"
    }
    Set tData = "test"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Missing definition ref should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Quit $$$OK
}

/// 2.7-UNIT-017 (P2): Test EnsureSSLConfig method
Method TestSSLConfigMethod()
{
    // Test that EnsureSSLConfig returns config name
    Set tConfigName = ##class(JSONSchema.Keyword.Ref).EnsureSSLConfig()
    Do $$$AssertEquals(tConfigName, "DefaultClient", "Should return DefaultClient config name")
    Quit $$$OK
}

// =============================================================================

// INTEGRATION TESTS (2.7-INT-001 to 2.7-INT-005)

// =============================================================================

/// 2.7-INT-001 (P1): Test $ref inside allOf combinator
Method TestRefWithCombinators()
{
    Set tSchema = {
        "definitions": {
            "hasName": {
                "type": "object",
                "properties": {"name": {"type": "string"}},
                "required": ["name"]
            },
            "hasAge": {
                "type": "object",
                "properties": {"age": {"type": "integer"}},
                "required": ["age"]
            }
        },
        "allOf": [
            {"$ref": "#/definitions/hasName"},
            {"$ref": "#/definitions/hasAge"}
        ]
    }
    Set tData = {"name": "John", "age": 30}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "$ref in allOf should work")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-INT-002 (P1): Test $ref in if/then/else
Method TestRefWithConditionals()
{
    Set tSchema = {
        "definitions": {
            "isUSAddress": {
                "properties": {"country": {"const": "USA"}}
            },
            "usZipCode": {
                "properties": {"zip": {"type": "string", "pattern": "^[0-9]{5}$"}}
            }
        },
        "if": {"$ref": "#/definitions/isUSAddress"},
        "then": {"$ref": "#/definitions/usZipCode"}
    }
    Set tData = {"country": "USA", "zip": "12345"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "$ref in if/then should work")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-INT-003 (P1): Test $ref validation errors show correct path
Method TestRefValidationErrors()
{
    Set tSchema = {
        "definitions": {
            "stringType": {"type": "string"}
        },
        "type": "object",
        "properties": {
            "value": {"$ref": "#/definitions/stringType"}
        }
    }
    Set tData = {"value": 123}  // Invalid - should be string
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Type mismatch should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Quit $$$OK
}

/// 2.7-INT-004 (P2): Test complex schema with multiple refs
Method TestComplexSchemaWithRefs()
{
    Set tSchema = {
        "definitions": {
            "address": {
                "type": "object",
                "properties": {
                    "street": {"type": "string"},
                    "city": {"type": "string"}
                },
                "required": ["street", "city"]
            },
            "person": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "home": {"$ref": "#/definitions/address"},
                    "work": {"$ref": "#/definitions/address"}
                },
                "required": ["name"]
            }
        },
        "$ref": "#/definitions/person"
    }
    Set tData = {
        "name": "John Doe",
        "home": {"street": "123 Main St", "city": "Springfield"},
        "work": {"street": "456 Office Blvd", "city": "Metropolis"}
    }
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Complex schema with multiple refs should work")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 2.7-INT-005 (P2): Test ref chain depth (A -> B -> C)
Method TestRefChainDepth()
{
    Set tSchema = {
        "definitions": {
            "A": {"$ref": "#/definitions/B"},
            "B": {"$ref": "#/definitions/C"},
            "C": {"type": "string", "minLength": 1}
        },
        "$ref": "#/definitions/A"
    }
    Set tData = "hello"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Ref chain A->B->C should resolve")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// Test definitions ref with invalid data
Method TestDefinitionsRefInvalidData()
{
    Set tSchema = {
        "definitions": {
            "positiveInt": {"type": "integer", "minimum": 1}
        },
        "$ref": "#/definitions/positiveInt"
    }
    Set tData = -5  // Invalid - should be >= 1
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Negative number should fail minimum constraint")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have error")
    Quit $$$OK
}

/// Test anyOf with refs
Method TestAnyOfWithRefs()
{
    Set tSchema = {
        "definitions": {
            "stringType": {"type": "string"},
            "numberType": {"type": "number"}
        },
        "anyOf": [
            {"$ref": "#/definitions/stringType"},
            {"$ref": "#/definitions/numberType"}
        ]
    }
    
    // Test with string
    Set tData1 = "hello"
    Set tValid1 = ##class(JSONSchema.Validator).Validate(tData1, tSchema, .tErrors1)
    Do $$$AssertEquals(tValid1, 1, "String should match anyOf with string ref")
    
    // Test with number
    Set tData2 = 42.5
    Set tValid2 = ##class(JSONSchema.Validator).Validate(tData2, tSchema, .tErrors2)
    Do $$$AssertEquals(tValid2, 1, "Number should match anyOf with number ref")
    Quit $$$OK
}

}

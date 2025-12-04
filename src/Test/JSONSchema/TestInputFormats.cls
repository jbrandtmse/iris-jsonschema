/// Test.JSONSchema.TestInputFormats - Flexible input format handling tests
/// <p>
/// Tests for JSONSchema.Validator's ability to accept multiple input formats:
/// - %DynamicObject and %DynamicArray data
/// - JSON string data and schemas
/// - %Stream.GlobalCharacter inputs
/// - Parse error handling and distinction
/// </p>
/// <p>
/// Originally from Story 1.5: Flexible Input Handling
/// </p>
Class Test.JSONSchema.TestInputFormats Extends %UnitTest.TestCase
{

/// 1.5-UNIT-001 (P0): Validate with %DynamicObject data
Method TestValidateWithDynamicObject() As %Status
{
    Set tData = {"name": "John", "age": 30}
    Set tSchema = {"type": "object"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "DynamicObject data should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.5-UNIT-002 (P0): Validate with %DynamicArray data
Method TestValidateWithDynamicArray() As %Status
{
    Set tData = ["item1", "item2", "item3"]
    Set tSchema = {"type": "array"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "DynamicArray data should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.5-UNIT-003 (P0): Validate with JSON string data
Method TestValidateWithJSONString() As %Status
{
    Set tDataString = "{""name"": ""John"", ""age"": 30}"
    Set tSchema = {"type": "object"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tDataString, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "JSON string data should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.5-UNIT-004 (P1): Validate with %Stream.GlobalCharacter data
Method TestValidateWithStream() As %Status
{
    Set tStream = ##class(%Stream.GlobalCharacter).%New()
    Do tStream.Write("{""name"": ""John"", ""age"": 30}")
    Do tStream.Rewind()
    Set tSchema = {"type": "object"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tStream, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Stream data should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.5-UNIT-005 (P0): Invalid JSON string data returns parse error
Method TestInvalidJSONStringData() As %Status
{
    Set tInvalidJSON = "{invalid json}"
    Set tSchema = {"type": "object"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tInvalidJSON, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid JSON data should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One parse error expected")
    Set tError = tErrors.%Get(0)
    Do $$$AssertEquals(tError.keyword, "$parse", "Error keyword should be $parse")
    Do $$$AssertTrue(tError.message [ "Invalid JSON data", "Error message should indicate data parse error")
    Quit $$$OK
}

/// 1.5-UNIT-006 (P0): Validate with %DynamicObject schema
Method TestValidateWithDynamicObjectSchema() As %Status
{
    Set tData = "hello"
    Set tSchema = {"type": "string"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "DynamicObject schema should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.5-UNIT-007 (P0): Validate with JSON string schema
Method TestValidateWithJSONStringSchema() As %Status
{
    Set tData = "hello"
    Set tSchemaString = "{""type"": ""string""}"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchemaString, .tErrors)
    Do $$$AssertEquals(tValid, 1, "JSON string schema should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected")
    Quit $$$OK
}

/// 1.5-UNIT-008 (P0): Invalid JSON string schema returns parse error
Method TestInvalidJSONStringSchema() As %Status
{
    Set tData = "hello"
    Set tInvalidSchema = "{invalid schema}"
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tInvalidSchema, .tErrors)
    Do $$$AssertEquals(tValid, 0, "Invalid JSON schema should fail")
    Do $$$AssertEquals(tErrors.%Size(), 1, "One parse error expected")
    Set tError = tErrors.%Get(0)
    Do $$$AssertEquals(tError.keyword, "$parseSchema", "Error keyword should be $parseSchema")
    Do $$$AssertTrue(tError.message [ "Invalid JSON schema", "Error message should indicate schema parse error")
    Quit $$$OK
}

/// 1.5-INT-001 (P1): Test valid combinations of data/schema formats
Method TestAllFormatCombinations() As %Status
{
    // Test 1: DynamicObject data + DynamicObject schema
    Set tData1 = {"name": "John"}
    Set tSchema1 = {"type": "object"}
    Set tValid1 = ##class(JSONSchema.Validator).Validate(tData1, tSchema1, .tErrors1)
    Do $$$AssertEquals(tValid1, 1, "DynamicObject + DynamicObject should work")
    
    // Test 2: DynamicArray data + DynamicObject schema
    Set tData2 = [1, 2, 3]
    Set tSchema2 = {"type": "array"}
    Set tValid2 = ##class(JSONSchema.Validator).Validate(tData2, tSchema2, .tErrors2)
    Do $$$AssertEquals(tValid2, 1, "DynamicArray + DynamicObject should work")
    
    // Test 3: JSON string data + JSON string schema
    Set tData3 = "{""name"": ""John""}"
    Set tSchema3 = "{""type"": ""object""}"
    Set tValid3 = ##class(JSONSchema.Validator).Validate(tData3, tSchema3, .tErrors3)
    Do $$$AssertEquals(tValid3, 1, "JSON string + JSON string should work")
    
    // Test 4: Primitive data + DynamicObject schema
    Set tData4 = "test string"
    Set tSchema4 = {"type": "string"}
    Set tValid4 = ##class(JSONSchema.Validator).Validate(tData4, tSchema4, .tErrors4)
    Do $$$AssertEquals(tValid4, 1, "Primitive + DynamicObject should work")
    
    Quit $$$OK
}

/// 1.5-INT-002 (P1): Verify data vs schema parse errors are distinct
Method TestParseErrorsDistinct() As %Status
{
    // Test data parse error
    Set tInvalidData = "{bad data}"
    Set tValidSchema = {"type": "string"}
    Set tValid1 = ##class(JSONSchema.Validator).Validate(tInvalidData, tValidSchema, .tErrors1)
    Do $$$AssertEquals(tValid1, 0, "Invalid data should fail")
    Do $$$AssertEquals(tErrors1.%Get(0).keyword, "$parse", "Data error should use $parse")
    Do $$$AssertTrue(tErrors1.%Get(0).message [ "Invalid JSON data", "Data error message should be clear")
    
    // Test schema parse error
    Set tValidData = "hello"
    Set tInvalidSchema = "{bad schema}"
    Set tValid2 = ##class(JSONSchema.Validator).Validate(tValidData, tInvalidSchema, .tErrors2)
    Do $$$AssertEquals(tValid2, 0, "Invalid schema should fail")
    Do $$$AssertEquals(tErrors2.%Get(0).keyword, "$parseSchema", "Schema error should use $parseSchema")
    Do $$$AssertTrue(tErrors2.%Get(0).message [ "Invalid JSON schema", "Schema error message should be clear")
    
    Quit $$$OK
}

/// 1.5-INT-003 (P1): Test stream handling with large JSON (>32K)
Method TestStreamLargeJSON() As %Status
{
    // Create a large JSON string (>32K)
    Set tStream = ##class(%Stream.GlobalCharacter).%New()
    Do tStream.Write("{""items"": [")
    For i=1:1:5000 {
        If i > 1 {
            Do tStream.Write(", ")
        }
        Do tStream.Write("{""id"": " _ i _ ", ""name"": ""Item " _ i _ """}")
    }
    Do tStream.Write("]}")
    Do tStream.Rewind()
    
    // Validate that the stream is actually large
    Set tSize = tStream.Size
    Do $$$AssertTrue(tSize > 32000, "Stream should be larger than 32K, got " _ tSize)
    
    // Validate with schema
    Do tStream.Rewind()
    Set tSchema = {"type": "object"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tStream, tSchema, .tErrors)
    Do $$$AssertEquals(tValid, 1, "Large stream data should validate")
    Do $$$AssertEquals(tErrors.%Size(), 0, "No errors expected for large stream")
    
    Quit $$$OK
}

}

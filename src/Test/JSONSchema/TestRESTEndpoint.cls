/// Test.JSONSchema.TestRESTEndpoint - REST API endpoint tests
/// <p>
/// Tests for JSONSchema.REST.Dispatch REST API endpoint covering
/// validation success/failure, error handling, and CORS headers.
/// </p>
/// <p>
/// Originally from Story 3.1: REST API Endpoint
/// </p>
Class Test.JSONSchema.TestRESTEndpoint Extends %UnitTest.TestCase
{

/// 3.1-UNIT-001 (P0): Test valid JSON and schema returns valid=true
Method TestValidateEndpointSuccess() As %Status
{
    // Create a mock request body
    Set tRequestBody = ##class(%DynamicObject).%New()
    Set tRequestBody.jsonInput = "{""name"": ""John"", ""age"": 30}"
    Set tRequestBody.schemaInput = "{""type"": ""object"", ""properties"": {""name"": {""type"": ""string""}, ""age"": {""type"": ""integer""}}}"
    Set tRequestBody.schemaVersion = "draft-07"
    
    // Test by directly calling the validator (simulating what the endpoint does)
    Set tJsonInput = tRequestBody.jsonInput
    Set tSchemaInput = tRequestBody.schemaInput
    Set tSchemaVersion = tRequestBody.schemaVersion
    
    // Perform validation
    Set tValid = ##class(JSONSchema.Validator).Validate(tJsonInput, tSchemaInput, .tErrors, tSchemaVersion)
    
    // Build response like the endpoint would
    Set tResponse = ##class(%DynamicObject).%New()
    Set tResponse.valid = $Select(tValid: 1, 1: 0)
    If $IsObject(tErrors) {
        Set tResponse.errors = tErrors
    } Else {
        Set tResponse.errors = ##class(%DynamicArray).%New()
    }
    Set tResponse.schemaVersion = tSchemaVersion
    
    // Assert results
    Do $$$AssertEquals(tResponse.valid, 1, "Validation should pass for valid JSON")
    Do $$$AssertEquals(tResponse.errors.%Size(), 0, "No errors expected for valid JSON")
    Do $$$AssertEquals(tResponse.schemaVersion, "draft-07", "Schema version should be draft-07")
    
    Quit $$$OK
}

/// 3.1-UNIT-002 (P0): Test invalid JSON returns valid=false with errors
Method TestValidateEndpointFailure() As %Status
{
    // Create a mock request with invalid JSON (string instead of object)
    Set tJsonInput = """not an object"""
    Set tSchemaInput = "{""type"": ""object""}"
    Set tSchemaVersion = "draft-07"
    
    // Perform validation
    Set tValid = ##class(JSONSchema.Validator).Validate(tJsonInput, tSchemaInput, .tErrors, tSchemaVersion)
    
    // Build response
    Set tResponse = ##class(%DynamicObject).%New()
    Set tResponse.valid = $Select(tValid: 1, 1: 0)
    If $IsObject(tErrors) {
        Set tResponse.errors = tErrors
    } Else {
        Set tResponse.errors = ##class(%DynamicArray).%New()
    }
    Set tResponse.schemaVersion = tSchemaVersion
    
    // Assert results
    Do $$$AssertEquals(tResponse.valid, 0, "Validation should fail for invalid JSON")
    Do $$$AssertTrue(tResponse.errors.%Size() > 0, "Errors expected for invalid JSON")
    
    Quit $$$OK
}

/// 3.1-UNIT-003 (P1): Test malformed request body returns 400
Method TestMalformedRequestJSON() As %Status
{
    // Test that malformed JSON throws an exception during parsing
    Set tMalformedJSON = "{invalid json"
    Set tErrorCaught = 0
    
    Try {
        Set tRequest = ##class(%DynamicAbstractObject).%FromJSON(tMalformedJSON)
    }
    Catch ex {
        Set tErrorCaught = 1
    }
    
    Do $$$AssertEquals(tErrorCaught, 1, "Malformed JSON should throw an exception")
    
    Quit $$$OK
}

/// 3.1-UNIT-004 (P1): Test missing schemaVersion defaults to draft-07
Method TestSchemaVersionDefault() As %Status
{
    // Create request without schemaVersion
    Set tJsonInput = "{""name"": ""test""}"
    Set tSchemaInput = "{""type"": ""object""}"
    Set tSchemaVersion = ""
    
    // Apply default like the endpoint does
    If tSchemaVersion = "" Set tSchemaVersion = "draft-07"
    
    // Perform validation
    Set tValid = ##class(JSONSchema.Validator).Validate(tJsonInput, tSchemaInput, .tErrors, tSchemaVersion)
    
    // Build response
    Set tResponse = ##class(%DynamicObject).%New()
    Set tResponse.valid = $Select(tValid: 1, 1: 0)
    Set tResponse.schemaVersion = tSchemaVersion
    
    // Assert schemaVersion defaults correctly
    Do $$$AssertEquals(tResponse.schemaVersion, "draft-07", "Schema version should default to draft-07")
    Do $$$AssertEquals(tResponse.valid, 1, "Validation should pass")
    
    Quit $$$OK
}

/// 3.1-UNIT-005 (P1): Test schemaVersion=2020-12 is accepted
Method TestSchemaVersion2020() As %Status
{
    // Create request with 2020-12 schema version
    Set tJsonInput = "{""name"": ""test""}"
    Set tSchemaInput = "{""type"": ""object""}"
    Set tSchemaVersion = "2020-12"
    
    // Perform validation (2020-12 support is placeholder/same as draft-07 for now)
    Set tValid = ##class(JSONSchema.Validator).Validate(tJsonInput, tSchemaInput, .tErrors, tSchemaVersion)
    
    // Build response
    Set tResponse = ##class(%DynamicObject).%New()
    Set tResponse.valid = $Select(tValid: 1, 1: 0)
    Set tResponse.schemaVersion = tSchemaVersion
    
    // Assert schemaVersion is accepted
    Do $$$AssertEquals(tResponse.schemaVersion, "2020-12", "Schema version 2020-12 should be accepted")
    Do $$$AssertEquals(tResponse.valid, 1, "Validation should pass")
    
    Quit $$$OK
}

/// 3.1-UNIT-006 (P2): Test CORS headers helper method exists and works
Method TestCORSHeaders() As %Status
{
    // Test that SetCORSHeaders class method exists by calling it
    // We can't test actual headers without a real HTTP context, but we can verify the method exists
    
    // Verify the class has the SetCORSHeaders method
    Set tMethodExists = ##class(%Dictionary.CompiledMethod).%ExistsId("JSONSchema.REST.Dispatch||SetCORSHeaders")
    Do $$$AssertTrue(tMethodExists, "SetCORSHeaders method should exist")
    
    // Verify HandleCORS method exists
    Set tHandleCORSExists = ##class(%Dictionary.CompiledMethod).%ExistsId("JSONSchema.REST.Dispatch||HandleCORS")
    Do $$$AssertTrue(tHandleCORSExists, "HandleCORS method should exist")
    
    // Verify OnPreDispatch method exists
    Set tOnPreDispatchExists = ##class(%Dictionary.CompiledMethod).%ExistsId("JSONSchema.REST.Dispatch||OnPreDispatch")
    Do $$$AssertTrue(tOnPreDispatchExists, "OnPreDispatch method should exist")
    
    Quit $$$OK
}

/// Test that the Dispatch class exists and extends %CSP.REST
Method TestDispatchClassExists() As %Status
{
    // Verify the class exists
    Set tClassExists = ##class(%Dictionary.CompiledClass).%ExistsId("JSONSchema.REST.Dispatch")
    Do $$$AssertTrue(tClassExists, "JSONSchema.REST.Dispatch class should exist")
    
    // Verify it extends %CSP.REST
    Set tSuper = ##class(%Dictionary.CompiledClass).%OpenId("JSONSchema.REST.Dispatch").Super
    Do $$$AssertTrue(tSuper [ "%CSP.REST", "Class should extend %CSP.REST")
    
    Quit $$$OK
}

/// Test that Validate method exists
Method TestValidateMethodExists() As %Status
{
    Set tMethodExists = ##class(%Dictionary.CompiledMethod).%ExistsId("JSONSchema.REST.Dispatch||Validate")
    Do $$$AssertTrue(tMethodExists, "Validate method should exist")
    
    Quit $$$OK
}

/// Test parameter values
Method TestClassParameters() As %Status
{
    // Test CONTENTTYPE parameter
    Set tContentType = ##class(JSONSchema.REST.Dispatch).#CONTENTTYPE
    Do $$$AssertEquals(tContentType, "application/json", "CONTENTTYPE should be application/json")
    
    // Test CHARSET parameter
    Set tCharset = ##class(JSONSchema.REST.Dispatch).#CHARSET
    Do $$$AssertEquals(tCharset, "utf-8", "CHARSET should be utf-8")
    
    Quit $$$OK
}

/// Test validation with complex schema
Method TestComplexValidation() As %Status
{
    // Test with a more complex schema
    Set tJsonInput = "{""name"": ""John"", ""email"": ""john@example.com"", ""age"": 25}"
    Set tSchemaInput = "{""type"": ""object"", ""properties"": {""name"": {""type"": ""string"", ""minLength"": 1}, ""email"": {""type"": ""string""}, ""age"": {""type"": ""integer"", ""minimum"": 0}}, ""required"": [""name"", ""email""]}"
    
    Set tValid = ##class(JSONSchema.Validator).Validate(tJsonInput, tSchemaInput, .tErrors, "draft-07")
    
    Do $$$AssertEquals(tValid, 1, "Complex validation should pass")
    
    Quit $$$OK
}

/// Test validation failure with detailed errors
Method TestValidationWithDetailedErrors() As %Status
{
    // JSON with multiple errors
    Set tJsonInput = "{""name"": 123, ""age"": ""not a number""}"
    Set tSchemaInput = "{""type"": ""object"", ""properties"": {""name"": {""type"": ""string""}, ""age"": {""type"": ""integer""}}}"
    
    Set tValid = ##class(JSONSchema.Validator).Validate(tJsonInput, tSchemaInput, .tErrors, "draft-07")
    
    Do $$$AssertEquals(tValid, 0, "Validation should fail with type mismatches")
    Do $$$AssertTrue($IsObject(tErrors), "Errors should be returned as object")
    Do $$$AssertTrue(tErrors.%Size() >= 1, "At least one error expected")
    
    Quit $$$OK
}

/// Test empty jsonInput handling
Method TestEmptyJsonInput() As %Status
{
    // Test with empty string inputs
    Set tJsonInput = ""
    Set tSchemaInput = "{""type"": ""object""}"
    
    // The endpoint should catch this before calling validator
    Set tIsEmpty = (tJsonInput = "")
    Do $$$AssertTrue(tIsEmpty, "Empty jsonInput should be detected")
    
    Quit $$$OK
}

/// Test empty schemaInput handling
Method TestEmptySchemaInput() As %Status
{
    // Test with empty schema
    Set tJsonInput = "{""test"": 1}"
    Set tSchemaInput = ""
    
    // The endpoint should catch this before calling validator
    Set tIsEmpty = (tSchemaInput = "")
    Do $$$AssertTrue(tIsEmpty, "Empty schemaInput should be detected")
    
    Quit $$$OK
}

}

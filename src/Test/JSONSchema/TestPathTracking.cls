/// Test.JSONSchema.TestPathTracking - Integration tests for path tracking
/// <p>
/// Tests the integration of Context path tracking with the Validator
/// to ensure errors include accurate path information.
/// </p>
Class Test.JSONSchema.TestPathTracking Extends %UnitTest.TestCase
{

/// 1.4-INT-003 (P1): Root-level validation error uses "#" as path
Method TestRootLevelError() As %Status
{
    Set tData = 123
    Set tSchema = {"type": "string"}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    
    Do $$$AssertEquals(tValid, 0, "Validation should fail")
    Do $$$AssertTrue(tErrors.%Size() > 0, "Should have at least one error")
    
    Set tError = tErrors.%Get(0)
    Do $$$AssertEquals(tError.dataPath, "#", "Root-level error should have dataPath=#")
    Do $$$AssertTrue(tError.schemaPath '= "", "Schema path should not be empty")
    Quit $$$OK
}

/// 1.4-INT-004 (P1): Multiple validation errors each have correct paths
Method TestMultipleErrorsWithPaths() As %Status
{
    Set tData = 123
    Set tSchema = {"type": "string", "enum": ["red", "green", "blue"]}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    
    Do $$$AssertEquals(tValid, 0, "Validation should fail")
    Do $$$AssertEquals(tErrors.%Size(), 2, "Should have two errors (type and enum)")
    
    // Both errors should have the same paths since both apply at root level
    For tIdx=0:1:tErrors.%Size()-1 {
        Set tError = tErrors.%Get(tIdx)
        Do $$$AssertEquals(tError.dataPath, "#", "Each error should have dataPath=#")
        Do $$$AssertTrue(tError.schemaPath '= "", "Each error should have schemaPath")
    }
    Quit $$$OK
}

}

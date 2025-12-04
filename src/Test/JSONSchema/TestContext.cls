/// Test.JSONSchema.TestContext - Unit tests for JSONSchema.Context
/// <p>
/// Tests the Context class functionality including path management,
/// error tracking, and depth management.
/// </p>
Class Test.JSONSchema.TestContext Extends %UnitTest.TestCase
{

/// 1.4-UNIT-001 (P1): Context initializes with root paths "#"
Method TestContextInitialization() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    Do $$$AssertEquals(tContext.DataPath, "#", "DataPath should initialize to #")
    Do $$$AssertEquals(tContext.SchemaPath, "#", "SchemaPath should initialize to #")
    Do $$$AssertEquals(tContext.Depth, 0, "Depth should initialize to 0")
    Do $$$AssertEquals(tContext.MaxDepth, 100, "MaxDepth should initialize to 100")
    Do $$$AssertTrue($IsObject(tContext.Errors), "Errors should be initialized")
    Do $$$AssertEquals(tContext.Errors.%Size(), 0, "Errors should be empty")
    Quit $$$OK
}

/// 1.4-UNIT-002 (P1): AddError creates error with keyword, message, paths
Method TestAddError() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    Do tContext.PushDataPath("users")
    Do tContext.PushSchemaPath("properties")
    Do tContext.AddError("type", "Expected string but got number")
    
    Do $$$AssertEquals(tContext.Errors.%Size(), 1, "Should have one error")
    Set tError = tContext.Errors.%Get(0)
    Do $$$AssertEquals(tError.keyword, "type", "Error keyword should be 'type'")
    Do $$$AssertEquals(tError.message, "Expected string but got number", "Error message should match")
    Do $$$AssertEquals(tError.dataPath, "#/users", "Error dataPath should match context")
    Do $$$AssertTrue(tError.schemaPath [ "properties", "Error schemaPath should include properties")
    Quit $$$OK
}

/// 1.4-UNIT-003 (P1): PushDataPath/PopDataPath manage path correctly
Method TestDataPathManagement() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    Do $$$AssertEquals(tContext.DataPath, "#", "Initial path should be #")
    
    Do tContext.PushDataPath("user")
    Do $$$AssertEquals(tContext.DataPath, "#/user", "Path should be #/user")
    
    Do tContext.PushDataPath("name")
    Do $$$AssertEquals(tContext.DataPath, "#/user/name", "Path should be #/user/name")
    
    Do tContext.PopDataPath()
    Do $$$AssertEquals(tContext.DataPath, "#/user", "Path should be back to #/user")
    
    Do tContext.PopDataPath()
    Do $$$AssertEquals(tContext.DataPath, "#", "Path should be back to #")
    Quit $$$OK
}

/// 1.4-UNIT-004 (P1): PushSchemaPath/PopSchemaPath manage path
Method TestSchemaPathManagement() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    Do $$$AssertEquals(tContext.SchemaPath, "#", "Initial schema path should be #")
    
    Do tContext.PushSchemaPath("properties")
    Do $$$AssertEquals(tContext.SchemaPath, "#/properties", "Schema path should be #/properties")
    
    Do tContext.PushSchemaPath("user")
    Do $$$AssertEquals(tContext.SchemaPath, "#/properties/user", "Schema path should be #/properties/user")
    
    Do tContext.PopSchemaPath()
    Do $$$AssertEquals(tContext.SchemaPath, "#/properties", "Schema path should be back to #/properties")
    
    Do tContext.PopSchemaPath()
    Do $$$AssertEquals(tContext.SchemaPath, "#", "Schema path should be back to #")
    Quit $$$OK
}

/// 1.4-UNIT-005 (P1): PushDataPath manages array index in path
Method TestDataPathArrayIndex() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    Do tContext.PushDataPath("items")
    Do tContext.PushDataPath("0")
    Do $$$AssertEquals(tContext.DataPath, "#/items/0", "Path should include array index")
    
    Do tContext.PushDataPath("tags")
    Do tContext.PushDataPath("1")
    Do $$$AssertEquals(tContext.DataPath, "#/items/0/tags/1", "Path should handle nested array indices")
    Quit $$$OK
}

/// 1.4-UNIT-006 (P1): Multiple push/pop operations maintain path integrity
Method TestMultiplePushPop() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    
    // Simulate nested navigation
    Do tContext.PushDataPath("level1")
    Do tContext.PushDataPath("level2")
    Do tContext.PushDataPath("level3")
    Do $$$AssertEquals(tContext.DataPath, "#/level1/level2/level3", "Path should be 3 levels deep")
    
    Do tContext.PopDataPath()
    Do tContext.PushDataPath("alternate3")
    Do $$$AssertEquals(tContext.DataPath, "#/level1/level2/alternate3", "Path should handle pop and push")
    
    Do tContext.PopDataPath()
    Do tContext.PopDataPath()
    Do tContext.PopDataPath()
    Do $$$AssertEquals(tContext.DataPath, "#", "Path should return to root")
    Quit $$$OK
}

/// 1.4-UNIT-007 (P1): IncrementDepth/DecrementDepth track depth correctly
Method TestDepthTracking() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    Do $$$AssertEquals(tContext.Depth, 0, "Initial depth should be 0")
    
    Set tResult = tContext.IncrementDepth()
    Do $$$AssertEquals(tResult, 1, "IncrementDepth should return 1 (success)")
    Do $$$AssertEquals(tContext.Depth, 1, "Depth should be 1")
    
    Set tResult = tContext.IncrementDepth()
    Do $$$AssertEquals(tContext.Depth, 2, "Depth should be 2")
    
    Do tContext.DecrementDepth()
    Do $$$AssertEquals(tContext.Depth, 1, "Depth should be back to 1")
    
    Do tContext.DecrementDepth()
    Do $$$AssertEquals(tContext.Depth, 0, "Depth should be back to 0")
    Quit $$$OK
}

/// 1.4-UNIT-008 (P0): MaxDepth check adds error when exceeded
Method TestMaxDepthExceeded() As %Status
{
    Set tContext = ##class(JSONSchema.Context).%New()
    Set tContext.MaxDepth = 3
    
    Set tResult = tContext.IncrementDepth()
    Do $$$AssertEquals(tResult, 1, "Depth 1 should succeed")
    Set tResult = tContext.IncrementDepth()
    Do $$$AssertEquals(tResult, 1, "Depth 2 should succeed")
    Set tResult = tContext.IncrementDepth()
    Do $$$AssertEquals(tResult, 1, "Depth 3 should succeed")
    Set tResult = tContext.IncrementDepth()
    Do $$$AssertEquals(tResult, 0, "Depth 4 should fail (exceeds MaxDepth)")
    
    Do $$$AssertEquals(tContext.Errors.%Size(), 1, "Should have one error")
    Set tError = tContext.Errors.%Get(0)
    Do $$$AssertEquals(tError.keyword, "$recursion", "Error keyword should be $recursion")
    Do $$$AssertTrue(tError.message [ "depth", "Error message should mention depth")
    Quit $$$OK
}

}

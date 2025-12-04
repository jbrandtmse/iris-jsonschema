/// JSONSchema.Context - Validation context for JSON Schema validation
/// <p>
/// Maintains state during validation including:
/// <ul>
/// <li>Current data and schema paths for error reporting</li>
/// <li>Accumulated validation errors</li>
/// <li>Recursion depth tracking</li>
/// <li>Schema version and root schema reference</li>
/// </ul>
/// </p>
Class JSONSchema.Context Extends %RegisteredObject
{

/// Current location in the JSON data being validated (JSON Pointer format)
Property DataPath As %String [ InitialExpression = "#" ];

/// Current location in the schema being processed (JSON Pointer format)
Property SchemaPath As %String [ InitialExpression = "#" ];

/// Collection of validation errors accumulated during validation
Property Errors As %DynamicArray;

/// Current recursion depth for nested validation
Property Depth As %Integer [ InitialExpression = 0 ];

/// Maximum allowed recursion depth to prevent stack overflow
Property MaxDepth As %Integer [ InitialExpression = 100 ];

/// JSON Schema version being used for validation
Property SchemaVersion As %String [ InitialExpression = "draft-07" ];

/// Reference to the root schema for $ref resolution
Property RootSchema As %DynamicObject;

/// Constructor - Initialize context with optional schema version
/// <p>
/// Creates a new validation context with an empty errors array.
/// </p>
/// @param pSchemaVersion Optional schema version (default: "draft-07")
Method %OnNew(pSchemaVersion As %String = "draft-07") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Errors = ##class(%DynamicArray).%New()
        Set ..SchemaVersion = pSchemaVersion
        Quit
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Add a validation error to the context
/// <p>
/// Creates an error object with the current paths and adds it to the errors array.
/// </p>
/// @param pKeyword The JSON Schema keyword that failed validation
/// @param pMessage Human-readable error description
Method AddError(pKeyword As %String, pMessage As %String)
{
    Set tError = ##class(%DynamicObject).%New()
    Set tError.keyword = pKeyword
    Set tError.dataPath = ..DataPath
    Set tError.schemaPath = ..SchemaPath _ "/" _ pKeyword
    Set tError.message = pMessage
    Do ..Errors.%Push(tError)
}

/// Increment recursion depth and check for overflow
/// <p>
/// Call at the start of ValidateNode() to track recursion depth.
/// </p>
/// @return 1 if depth is within limits, 0 if maximum depth exceeded
Method IncrementDepth() As %Boolean
{
    Set ..Depth = ..Depth + 1
    If ..Depth > ..MaxDepth {
        Do ..AddError("$recursion", "Maximum validation depth exceeded")
        Quit 0
    }
    Quit 1
}

/// Decrement recursion depth
/// <p>
/// Call before exiting ValidateNode() to maintain proper depth tracking.
/// </p>
Method DecrementDepth()
{
    Set ..Depth = ..Depth - 1
}

/// Push a segment onto the data path
/// @param pSegment Path segment to add
Method PushDataPath(pSegment As %String)
{
    Set ..DataPath = ..DataPath _ "/" _ pSegment
}

/// Pop the last segment from the data path
Method PopDataPath()
{
    Set tLastSlash = $Length(..DataPath) - $Length($Piece(..DataPath, "/", $Length(..DataPath, "/")))
    If tLastSlash > 0 {
        Set ..DataPath = $Extract(..DataPath, 1, tLastSlash - 1)
    }
}

/// Push a segment onto the schema path
/// @param pSegment Path segment to add
Method PushSchemaPath(pSegment As %String)
{
    Set ..SchemaPath = ..SchemaPath _ "/" _ pSegment
}

/// Pop the last segment from the schema path
Method PopSchemaPath()
{
    Set tLastSlash = $Length(..SchemaPath) - $Length($Piece(..SchemaPath, "/", $Length(..SchemaPath, "/")))
    If tLastSlash > 0 {
        Set ..SchemaPath = $Extract(..SchemaPath, 1, tLastSlash - 1)
    }
}

}

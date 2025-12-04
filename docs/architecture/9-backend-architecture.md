# 9. Backend Architecture

### 9.1 Validator Implementation

```objectscript
Class JSONSchema.Validator Extends %RegisteredObject
{

ClassMethod Validate(pJSON, pSchema, Output pErrors As %DynamicArray, pSchemaVersion As %String = "draft-07") As %Boolean
{
    Set tResult = 1
    Set pErrors = ##class(%DynamicArray).%New()
    
    Try {
        Set tData = ..ParseInput(pJSON)
        Set tSchema = ..ParseInput(pSchema)
        Set tContext = ##class(JSONSchema.Context).%New(pSchemaVersion)
        Set tContext.RootSchema = tSchema
        Set tResult = ..ValidateNode(tData, tSchema, tContext)
        Set pErrors = tContext.Errors
        Quit  // Argumentless QUIT in Try block
    }
    Catch ex {
        Set tError = ##class(%DynamicObject).%New()
        Set tError.keyword = "parse"
        Set tError.dataPath = "#"
        Set tError.schemaPath = "#"
        Set tError.message = ex.DisplayString()
        Do pErrors.%Push(tError)
        Set tResult = 0
    }
    Quit tResult
}

}
```

### 9.2 Context Implementation

```objectscript
Class JSONSchema.Context Extends %RegisteredObject
{

Property DataPath As %String [ InitialExpression = "#" ];
Property SchemaPath As %String [ InitialExpression = "#" ];
Property Errors As %DynamicArray;
Property VisitedRefs As %DynamicObject;
Property Depth As %Integer [ InitialExpression = 0 ];
Property MaxDepth As %Integer [ InitialExpression = 100 ];
Property SchemaVersion As %String [ InitialExpression = "draft-07" ];
Property RootSchema As %DynamicObject;

Method %OnNew(pSchemaVersion As %String = "draft-07") As %Status
{
    Set ..Errors = ##class(%DynamicArray).%New()
    Set ..VisitedRefs = ##class(%DynamicObject).%New()
    Set ..SchemaVersion = pSchemaVersion
    Quit $$$OK
}

Method AddError(pKeyword As %String, pMessage As %String)
{
    Set tError = ##class(%DynamicObject).%New()
    Set tError.keyword = pKeyword
    Set tError.dataPath = ..DataPath
    Set tError.schemaPath = ..SchemaPath _ "/" _ pKeyword
    Set tError.message = pMessage
    Do ..Errors.%Push(tError)
}

Method IncrementDepth() As %Boolean
{
    Set ..Depth = ..Depth + 1
    Quit (..Depth <= ..MaxDepth)
}

}
```

---

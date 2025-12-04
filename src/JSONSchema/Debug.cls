/// Debug helper class
Class JSONSchema.Debug Extends %RegisteredObject
{

/// Debug uniqueItems mixed types
ClassMethod DebugUniqueItemsMixed() As %String
{
    Set tResult = ""
    Set tData = [1, "1", true, 1.0]
    
    // Check what types we have
    Set tIter = tData.%GetIterator()
    While tIter.%GetNext(.tIdx, .tValue) {
        Set tType = tData.%GetTypeOf(tIdx)
        Set tSer = ##class(JSONSchema.Keyword.Array).SerializeForComparison(tValue)
        Set tResult = tResult _ "Idx" _ tIdx _ " type=" _ tType _ " ser=" _ tSer _ "; "
    }
    
    // Run validation
    Set tSchema = {"type": "array", "uniqueItems": true}
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Set tResult = tResult _ "Valid=" _ tValid _ " Errors=" _ tErrors.%Size() _ "; "
    
    Quit tResult
}

/// Debug tuple validation
ClassMethod DebugTupleValid() As %String
{
    Set tResult = ""
    Set tData = ["hello", 42, true]
    Set tSchema = {"type": "array", "items": [{"type": "string"}, {"type": "number"}, {"type": "boolean"}]}
    
    Set tResult = tResult _ "Items type: " _ tSchema.items.%ClassName(1) _ "; "
    Set tResult = tResult _ "IsArray: " _ tSchema.items.%IsA("%Library.DynamicArray") _ "; "
    Set tResult = tResult _ "IsObject: " _ $IsObject(tSchema.items) _ "; "
    
    Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)
    Set tResult = tResult _ "Valid: " _ tValid _ "; "
    Set tResult = tResult _ "ErrorCount: " _ tErrors.%Size() _ "; "
    
    If tErrors.%Size() > 0 {
        Set tResult = tResult _ "Error0: " _ tErrors.%Get(0).%ToJSON() _ "; "
    }
    
    // Also check the data types
    Set tResult = tResult _ "Data[2] type: " _ ##class(JSONSchema.Validator).GetJSONType(tData.%Get(2)) _ "; "
    
    Quit tResult
}

}

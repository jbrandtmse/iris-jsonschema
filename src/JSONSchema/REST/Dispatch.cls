/// JSONSchema.REST.Dispatch - REST API for JSON Schema Validation
/// <p>
/// Provides REST endpoints for validating JSON data against JSON Schema.
/// </p>
/// <p>
/// <b>Endpoints:</b>
/// <ul>
/// <li>POST /validate - Validate JSON against a schema</li>
/// <li>OPTIONS /validate - CORS preflight handling</li>
/// </ul>
/// </p>
/// <p>
/// <b>Request Format:</b>
/// <pre>
/// {
///   "jsonInput": "&lt;json-string&gt;",
///   "schemaInput": "&lt;schema-string&gt;",
///   "schemaVersion": "draft-07"  // Optional, defaults to "draft-07"
/// }
/// </pre>
/// </p>
/// <p>
/// <b>Response Format:</b>
/// <pre>
/// {
///   "valid": true|false,
///   "errors": [...],
///   "schemaVersion": "&lt;version-used&gt;"
/// }
/// </pre>
/// </p>
Class JSONSchema.REST.Dispatch Extends %CSP.REST
{

/// Content type for all responses
Parameter CONTENTTYPE = "application/json";

/// Character set for all responses
Parameter CHARSET = "utf-8";

/// URL routing map
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/validate" Method="POST" Call="Validate"/>
    <Route Url="/validate" Method="OPTIONS" Call="HandleCORS"/>
</Routes>
}

/// Handle CORS preflight requests
/// <p>
/// Returns empty response with CORS headers for OPTIONS requests.
/// </p>
ClassMethod HandleCORS() As %Status
{
    Set tSC = $$$OK
    Try {
        Set %response.ContentType = "application/json"
        Do ..SetCORSHeaders()
        Quit
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Set CORS headers for cross-origin requests
/// <p>
/// Configures headers to allow cross-origin requests from web UI.
/// </p>
ClassMethod SetCORSHeaders()
{
    Do %response.SetHeader("Access-Control-Allow-Origin", "*")
    Do %response.SetHeader("Access-Control-Allow-Methods", "POST, OPTIONS")
    Do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type")
    Do %response.SetHeader("Access-Control-Max-Age", "3600")
}

/// Validate JSON against a schema
/// <p>
/// Main validation endpoint. Accepts JSON input and schema, returns validation result.
/// </p>
/// <p>
/// <b>Request Body:</b>
/// <ul>
/// <li>jsonInput (required): JSON string to validate</li>
/// <li>schemaInput (required): JSON Schema string</li>
/// <li>schemaVersion (optional): "draft-07" or "2020-12", defaults to "draft-07"</li>
/// </ul>
/// </p>
ClassMethod Validate() As %Status
{
    Set tSC = $$$OK
    Try {
        Do ..SetCORSHeaders()
        
        // Read request body
        Set tRequestBody = ""
        If $IsObject(%request.Content) {
            Set tRequestBody = %request.Content.Read()
        }
        
        // Check for empty request body
        If tRequestBody = "" {
            Set %response.Status = "400 Bad Request"
            Set tError = {"error": {"code": "BAD_REQUEST", "message": "Empty request body"}}
            Write tError.%ToJSON()
            Quit
        }
        
        // Parse request JSON
        Set tRequest = ##class(%DynamicAbstractObject).%FromJSON(tRequestBody)
        
        // Extract parameters
        Set tJsonInput = tRequest.jsonInput
        Set tSchemaInput = tRequest.schemaInput
        Set tSchemaVersion = tRequest.schemaVersion
        If tSchemaVersion = "" Set tSchemaVersion = "draft-07"
        
        // Validate required fields
        If (tJsonInput = "") || (tSchemaInput = "") {
            Set %response.Status = "400 Bad Request"
            Set tError = {"error": {"code": "BAD_REQUEST", "message": "Missing required fields: jsonInput and schemaInput"}}
            Write tError.%ToJSON()
            Quit
        }
        
        // Perform validation
        Set tValid = ##class(JSONSchema.Validator).Validate(tJsonInput, tSchemaInput, .tErrors, tSchemaVersion)
        
        // Build response
        Set tResponse = ##class(%DynamicObject).%New()
        Set tResponse.valid = $Select(tValid: $$$YES, 1: $$$NO)
        If $IsObject(tErrors) {
            Set tResponse.errors = tErrors
        } Else {
            Set tResponse.errors = ##class(%DynamicArray).%New()
        }
        Set tResponse.schemaVersion = tSchemaVersion
        
        Write tResponse.%ToJSON()
        Quit
    }
    Catch ex {
        Set %response.Status = "400 Bad Request"
        Set tErrorMsg = ex.DisplayString()
        If tErrorMsg = "" Set tErrorMsg = "Invalid request body"
        Set tError = ##class(%DynamicObject).%New()
        Set tErrorObj = ##class(%DynamicObject).%New()
        Set tErrorObj.code = "BAD_REQUEST"
        Set tErrorObj.message = tErrorMsg
        Set tError.error = tErrorObj
        Write tError.%ToJSON()
    }
    Quit tSC
}

/// Called before dispatch - set content type and CORS headers
/// <p>
/// Intercepts all requests to set common response headers.
/// </p>
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
    Set %response.ContentType = "application/json"
    Set pContinue = 1
    Quit $$$OK
}

}

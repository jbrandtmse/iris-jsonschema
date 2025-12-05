# CSP Application Setup for JSONSchema REST API

This document provides instructions for setting up the CSP (Caché Server Pages) web application to expose the JSONSchema REST API.

## Overview

The JSONSchema REST API is implemented in `JSONSchema.REST.Dispatch` and provides a `/validate` endpoint for validating JSON data against JSON Schema.

## REST API Endpoint

| Method | Path | Description |
|--------|------|-------------|
| POST | `/validate` | Validate JSON against a schema |
| OPTIONS | `/validate` | CORS preflight handling |

## Request Format

```json
{
  "jsonInput": "<json-string>",
  "schemaInput": "<schema-string>",
  "schemaVersion": "draft-07"  // Optional, defaults to "draft-07"
}
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `jsonInput` | string | Yes | The JSON data to validate (as a JSON-encoded string) |
| `schemaInput` | string | Yes | The JSON Schema to validate against (as a JSON-encoded string) |
| `schemaVersion` | string | No | Schema version: `"draft-07"` (default) or `"2020-12"` |

## Response Format

### Success (HTTP 200)

```json
{
  "valid": true,
  "errors": [],
  "schemaVersion": "draft-07"
}
```

### Validation Failure (HTTP 200)

```json
{
  "valid": false,
  "errors": [
    {
      "keyword": "type",
      "dataPath": "/name",
      "schemaPath": "#/properties/name/type",
      "message": "Type mismatch: expected string, got integer"
    }
  ],
  "schemaVersion": "draft-07"
}
```

### Bad Request (HTTP 400)

```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "Missing required fields: jsonInput and schemaInput"
  }
}
```

## CSP Application Setup

### Option 1: Management Portal (Recommended for Development)

1. Open the InterSystems Management Portal
2. Navigate to: **System Administration** → **Security** → **Applications** → **Web Applications**
3. Click **Create New Web Application**
4. Configure the following settings:

| Setting | Value |
|---------|-------|
| Name | `/api/jsonschema` |
| Description | JSONSchema Validator REST API |
| Namespace | `HSCUSTOM` (or your target namespace) |
| Dispatch Class | `JSONSchema.REST.Dispatch` |
| Enable Application | Yes |

5. Under **Security Settings**:
   - For **Development**: Select "Unauthenticated" 
   - For **Production**: Configure appropriate authentication (Password, Delegated, etc.)

6. Click **Save**

### Option 2: Programmatic Creation (ObjectScript)

Execute the following in the IRIS terminal or via a routine:

```objectscript
/// Create the JSONSchema REST API web application
ClassMethod CreateWebApplication() As %Status
{
    Set tSC = $$$OK
    Try {
        Set tAppName = "/api/jsonschema"
        
        // Check if application already exists
        If ##class(Security.Applications).Exists(tAppName) {
            Write "Application already exists: "_tAppName,!
            Quit
        }
        
        // Define application properties
        Set props("DispatchClass") = "JSONSchema.REST.Dispatch"
        Set props("Namespace") = "HSCUSTOM"
        Set props("NameSpace") = "HSCUSTOM"
        Set props("IsNameSpaceDefault") = 0
        Set props("MatchRoles") = "%All"
        Set props("AutheEnabled") = 64  // 64 = Unauthenticated
        Set props("Description") = "JSONSchema Validator REST API"
        Set props("Enabled") = 1
        
        // Create the application
        Set tSC = ##class(Security.Applications).Create(tAppName, .props)
        If $$$ISERR(tSC) {
            Write "Error creating application: "_$System.Status.GetErrorText(tSC),!
            Quit
        }
        
        Write "Successfully created web application: "_tAppName,!
        Quit
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
```

## Testing the API

### Using cURL

```bash
# Successful validation
curl -X POST http://localhost:52773/api/jsonschema/validate \
  -H "Content-Type: application/json" \
  -d '{
    "jsonInput": "{\"name\": \"John\", \"age\": 30}",
    "schemaInput": "{\"type\": \"object\", \"properties\": {\"name\": {\"type\": \"string\"}, \"age\": {\"type\": \"integer\"}}}"
  }'

# Expected response:
# {"valid":true,"errors":[],"schemaVersion":"draft-07"}
```

```bash
# Validation failure
curl -X POST http://localhost:52773/api/jsonschema/validate \
  -H "Content-Type: application/json" \
  -d '{
    "jsonInput": "\"not an object\"",
    "schemaInput": "{\"type\": \"object\"}"
  }'

# Expected response:
# {"valid":false,"errors":[...],"schemaVersion":"draft-07"}
```

### Using PowerShell

```powershell
$body = @{
    jsonInput = '{"name": "John", "age": 30}'
    schemaInput = '{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}}'
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:52773/api/jsonschema/validate" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### Using JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:52773/api/jsonschema/validate', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    jsonInput: '{"name": "John", "age": 30}',
    schemaInput: '{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}}'
  })
});

const result = await response.json();
console.log(result);
// { valid: true, errors: [], schemaVersion: "draft-07" }
```

## CORS Configuration

The REST API includes CORS headers for cross-origin requests:

| Header | Value |
|--------|-------|
| Access-Control-Allow-Origin | `*` |
| Access-Control-Allow-Methods | `POST, OPTIONS` |
| Access-Control-Allow-Headers | `Content-Type` |
| Access-Control-Max-Age | `3600` |

For production environments, consider restricting `Access-Control-Allow-Origin` to specific domains.

## Security Considerations

### Development Environment

- Use "Unauthenticated" access for ease of testing
- Ensure the IRIS instance is not accessible from public networks

### Production Environment

1. **Authentication**: Configure appropriate authentication method (Password, Delegated, OAuth)
2. **HTTPS**: Always use HTTPS in production
3. **CORS**: Restrict `Access-Control-Allow-Origin` to specific trusted domains
4. **Input Validation**: The API validates required fields but additional rate limiting may be needed
5. **Logging**: Consider enabling CSP application logging for audit trails

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| 404 Not Found | Verify web application is enabled and path is correct |
| 401 Unauthorized | Check authentication settings for the web application |
| 500 Internal Server Error | Check IRIS logs for detailed error messages |
| CORS errors | Verify browser allows cross-origin requests; check OPTIONS handling |

### Checking Application Status

```objectscript
// List all web applications
Do ##class(Security.Applications).ListAll(.apps)
ZWrite apps

// Check specific application
If ##class(Security.Applications).Exists("/api/jsonschema") {
    Write "Application exists",!
}
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-04 | Initial release (Story 3.1) |

---

*This documentation is part of the iris-jsonschema project.*

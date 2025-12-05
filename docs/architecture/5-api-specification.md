# 5. API Specification

### REST API (OpenAPI 3.0)

```yaml
openapi: 3.0.3
info:
  title: JSONSchema Validator API
  version: 1.0.0
  description: REST API for validating JSON data against JSON Schema specifications.

servers:
  - url: /api/jsonschema
    description: IRIS CSP Application base path (configured via JSONSchema.REST.Setup class)

paths:
  /validate:
    post:
      summary: Validate JSON against Schema
      operationId: validateJSON
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ValidationRequest'
      responses:
        '200':
          description: Validation completed
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ValidationResponse'
        '400':
          description: Malformed request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

components:
  schemas:
    ValidationRequest:
      type: object
      required: [jsonInput, schemaInput]
      properties:
        jsonInput:
          type: string
        schemaInput:
          type: string
        schemaVersion:
          type: string
          enum: ["draft-07", "2020-12"]
          default: "draft-07"

    ValidationResponse:
      type: object
      properties:
        valid:
          type: boolean
        errors:
          type: array
          items:
            $ref: '#/components/schemas/ValidationError'
        schemaVersion:
          type: string

    ValidationError:
      type: object
      properties:
        keyword:
          type: string
        dataPath:
          type: string
        schemaPath:
          type: string
        message:
          type: string

    ErrorResponse:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
            message:
              type: string
```

### CSP Application Setup

The REST API requires a CSP web application to be configured in IRIS. The `JSONSchema.REST.Setup` class provides programmatic setup:

```objectscript
// Create the /api/jsonschema web application
Do ##class(JSONSchema.REST.Setup).CreateApplication()

// Create with custom namespace
Do ##class(JSONSchema.REST.Setup).CreateApplication("MYNAMESPACE")

// Remove the web application
Do ##class(JSONSchema.REST.Setup).DeleteApplication()
```

The Setup class handles:
- Namespace switching to %SYS for Security.Applications access
- CSP application creation with correct dispatch class
- CORS configuration for cross-origin requests
- Authentication settings for unauthenticated access

---

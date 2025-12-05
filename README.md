# IRIS JSON Schema Validator

A JSON Schema Draft-07 validator implemented in InterSystems ObjectScript for IRIS.

## Overview

This project provides a native ObjectScript implementation of JSON Schema validation, enabling IRIS developers to validate JSON data against JSON Schema specifications directly within their IRIS applications.

## Features

- **JSON Schema Draft-07 Support** - Complete implementation of the JSON Schema Draft-07 specification
- **Native ObjectScript** - No external dependencies, runs entirely within IRIS
- **Comprehensive Type Validation** - Supports all JSON types (string, number, integer, boolean, null, array, object)
- **Schema Composition** - Full support for allOf, anyOf, oneOf, not combinators
- **Conditional Schemas** - if/then/else and dependencies support
- **Schema References** - $ref resolution for internal and remote references
- **Detailed Error Reporting** - Returns structured error objects with keyword, path, and message information

## Installation

### Manual Installation

1. Clone this repository
2. Import the classes from `/src/JSONSchema/` into your IRIS namespace
3. Compile the package:

```objectscript
Do $System.OBJ.CompilePackage("JSONSchema", "ck")
Do $System.OBJ.CompilePackage("Test.JSONSchema", "ck")
```

## Quick Start

```objectscript
// Define a schema for a person object
Set tSchema = {
    "type": "object",
    "required": ["name", "email", "age"],
    "properties": {
        "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 100
        },
        "email": {
            "type": "string",
            "format": "email"
        },
        "age": {
            "type": "integer",
            "minimum": 0,
            "maximum": 150
        },
        "address": {
            "type": "object",
            "properties": {
                "street": {"type": "string"},
                "city": {"type": "string"},
                "zipCode": {"type": "string", "pattern": "^[0-9]{5}(-[0-9]{4})?$"}
            }
        },
        "tags": {
            "type": "array",
            "items": {"type": "string"},
            "uniqueItems": true
        }
    },
    "additionalProperties": false
}

// Define the data to validate
Set tData = {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "age": 35,
    "address": {
        "street": "123 Main St",
        "city": "Springfield",
        "zipCode": "12345"
    },
    "tags": ["developer", "team-lead"]
}

// Validate the data
Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)

If tValid {
    Write "Validation passed!", !
}
Else {
    Write "Validation failed with ", tErrors.%Size(), " errors", !
    Set tIter = tErrors.%GetIterator()
    While tIter.%GetNext(.tKey, .tError) {
        Write "  - [", tError.dataPath, "] ", tError.message, !
    }
}
```

## API Reference

### JSONSchema.Validator

#### Validate()

```objectscript
ClassMethod Validate(pJSON, pSchema, Output pErrors As %DynamicArray, pSchemaVersion As %String = "draft-07") As %Boolean
```

**Parameters:**
- `pJSON` - JSON data to validate (string, %DynamicObject, %DynamicArray, or %Stream)
- `pSchema` - JSON Schema to validate against (string, %DynamicObject, or %Stream)
- `pErrors` - Output parameter receiving array of error objects
- `pSchemaVersion` - Schema version (default: "draft-07")

**Returns:** `1` if valid, `0` if invalid

### Error Object Structure

Each error object contains:

| Property | Description |
|----------|-------------|
| `keyword` | The JSON Schema keyword that failed (e.g., "type") |
| `dataPath` | JSON Pointer to the failing data location |
| `schemaPath` | JSON Pointer to the schema location |
| `message` | Human-readable error description |

## Project Structure

```
iris-jsonschema/
├── src/
│   ├── JSONSchema/
│   │   ├── Validator.cls      # Main entry point
│   │   ├── Context.cls        # Validation context
│   │   └── Keyword/
│   │       ├── Type.cls       # Type keyword validation
│   │       ├── Enum.cls       # Enum keyword validation
│   │       ├── Const.cls      # Const keyword validation
│   │       ├── String.cls     # String keywords (minLength, maxLength, pattern, format)
│   │       ├── Numeric.cls    # Numeric keywords (minimum, maximum, multipleOf, etc.)
│   │       ├── Object.cls     # Object keywords (properties, required, additionalProperties, etc.)
│   │       ├── Array.cls      # Array keywords (items, minItems, maxItems, uniqueItems, etc.)
│   │       ├── Combinator.cls # Schema combinators (allOf, anyOf, oneOf, not)
│   │       ├── Conditional.cls # Conditional schemas (if/then/else, dependencies)
│   │       └── Ref.cls        # Schema references ($ref, definitions, $defs)
│   └── Test/JSONSchema/
│       ├── TestValidator.cls        # Foundation tests
│       ├── TestTypeValidation.cls   # Type keyword tests
│       ├── TestEnumConst.cls        # Enum/Const tests
│       ├── TestInputFormats.cls     # Input format tests
│       ├── TestContext.cls          # Context tests
│       ├── TestPathTracking.cls     # Path tracking tests
│       ├── TestStringKeywords.cls   # String keyword tests
│       ├── TestNumericKeywords.cls  # Numeric keyword tests
│       ├── TestObjectKeywords.cls   # Object keyword tests
│       ├── TestArrayKeywords.cls    # Array keyword tests
│       ├── TestCombinators.cls      # Schema combinator tests
│       ├── TestConditional.cls      # Conditional schema tests
│       └── TestRefKeyword.cls       # $ref keyword tests
├── docs/                      # Documentation
│   ├── stories/               # User stories
│   ├── qa/                    # QA gates and assessments
│   ├── prd/                   # Product requirements
│   └── architecture/          # Architecture documentation
├── module.xml                 # Package definition
└── README.md
```

## Development Status

### Epic 1: Foundation & Core Type Validation ✅ Complete
- ✅ Story 1.1: Project Foundation with String Type Validation
- ✅ Story 1.2: Complete Type Keyword Support
- ✅ Story 1.3: Enum and Const Keywords
- ✅ Story 1.4: Context Class and Error Path Tracking
- ✅ Story 1.5: Flexible Input Handling
- ✅ Story 1.6: Test File Organization (800-line limit)

### Epic 2: Complete JSON Schema Draft-07 Support ✅ Complete
- ✅ Story 2.1: String Validation Keywords (minLength, maxLength, pattern, format)
- ✅ Story 2.2: Numeric Validation Keywords (minimum, maximum, exclusiveMinimum, exclusiveMaximum, multipleOf)
- ✅ Story 2.3: Object Validation Keywords (properties, required, additionalProperties, patternProperties, propertyNames, minProperties, maxProperties)
- ✅ Story 2.4: Array Validation Keywords (items, minItems, maxItems, uniqueItems, contains, additionalItems)
- ✅ Story 2.5: Schema Composition Keywords (allOf, anyOf, oneOf, not)
- ✅ Story 2.6: Conditional Schema Keywords (if/then/else, dependencies)
- ✅ Story 2.7: Reference and Definition Keywords ($ref, definitions, $defs)

### Epic 3: Web Application & Distribution
- 🔜 Upcoming

## REST API

The JSON Schema Validator also provides a REST API for programmatic access.

### Setup Web Application

Configure the CSP web application using the helper class:

```objectscript
// Create the /api/jsonschema web application
Do ##class(JSONSchema.REST.Setup).CreateApplication()

// Check if application exists
Write ##class(JSONSchema.REST.Setup).ApplicationExists()

// Delete application (if needed)
Do ##class(JSONSchema.REST.Setup).DeleteApplication()
```

### API Endpoint

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/jsonschema/validate` | Validate JSON against a schema |
| OPTIONS | `/api/jsonschema/validate` | CORS preflight |

### Request Format

```json
{
  "jsonInput": "<json-string>",
  "schemaInput": "<schema-string>",
  "schemaVersion": "draft-07"  // Optional, defaults to "draft-07"
}
```

### Response Format

```json
{
  "valid": true,
  "errors": [],
  "schemaVersion": "draft-07"
}
```

### Example: curl

```bash
# Valid JSON example
curl -X POST http://localhost:52773/api/jsonschema/validate \
  -H "Content-Type: application/json" \
  -d '{
    "jsonInput": "{\"name\": \"John\", \"age\": 30}",
    "schemaInput": "{\"type\": \"object\", \"properties\": {\"name\": {\"type\": \"string\"}, \"age\": {\"type\": \"integer\"}}}"
  }'

# Response: {"valid":1,"errors":[],"schemaVersion":"draft-07"}
```

```bash
# Invalid JSON example (wrong type)
curl -X POST http://localhost:52773/api/jsonschema/validate \
  -H "Content-Type: application/json" \
  -d '{
    "jsonInput": "\"not an object\"",
    "schemaInput": "{\"type\": \"object\"}"
  }'

# Response: {"valid":0,"errors":[{"keyword":"type","dataPath":"#","schemaPath":"#/type","message":"Expected type 'object' but got 'string'"}],"schemaVersion":"draft-07"}
```

### Example: PowerShell

```powershell
$body = @{
    jsonInput = '{"name": "John", "age": 30}'
    schemaInput = '{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}}'
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:52773/api/jsonschema/validate" `
    -Method POST -ContentType "application/json" -Body $body
```

## Testing

Run the unit tests using IRIS terminal:

```objectscript
Do ##class(%UnitTest.Manager).RunTest("Test.JSONSchema")
```

**Current test coverage: 303 tests, all passing.**

## Requirements

- InterSystems IRIS 2020.1 or later

## License

MIT License

## Contributing

Contributions are welcome! Please read the documentation in `/docs/` for architecture and coding standards.

## Acknowledgments

Built with [BMAD Framework](https://github.com/bmad-code-org/BMAD-METHOD) for AI-assisted development.

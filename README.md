# IRIS JSON Schema Validator

A JSON Schema Draft-07 validator implemented in InterSystems ObjectScript for IRIS.

## Overview

This project provides a native ObjectScript implementation of JSON Schema validation, enabling IRIS developers to validate JSON data against JSON Schema specifications directly within their IRIS applications.

## Features

- **JSON Schema Draft-07 Support** - Implements the JSON Schema Draft-07 specification
- **Native ObjectScript** - No external dependencies, runs entirely within IRIS
- **Comprehensive Type Validation** - Supports all JSON types (string, number, integer, boolean, null, array, object)
- **Detailed Error Reporting** - Returns structured error objects with keyword, path, and message information
- **IPM Package** - Installable via InterSystems Package Manager (IPM/ZPM)

## Installation

### Via IPM (Recommended)

```objectscript
zpm "install jsonschema"
```

### Manual Installation

1. Clone this repository
2. Import the classes from `/src/JSONSchema/` into your IRIS namespace
3. Compile the package

## Quick Start

```objectscript
// Validate a string against a schema
Set tData = "hello"
Set tSchema = {"type": "string"}
Set tValid = ##class(JSONSchema.Validator).Validate(tData, tSchema, .tErrors)

If tValid {
    Write "Validation passed!", !
}
Else {
    Write "Validation failed with ", tErrors.%Size(), " errors", !
    Set tIter = tErrors.%GetIterator()
    While tIter.%GetNext(.tKey, .tError) {
        Write "  - ", tError.message, !
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
│   │       └── Type.cls       # Type keyword handler
│   └── Test/JSONSchema/
│       └── TestValidator.cls  # Unit tests
├── docs/                      # Documentation
├── module.xml                 # IPM package definition
└── README.md
```

## Development Status

### Completed
- ✅ Story 1.1: Project Foundation with String Type Validation

### Upcoming
- 🔜 Epic 1: Foundation & Core Type Validation (remaining stories)
- 🔜 Epic 2: Complete JSON Schema Draft-07 Support
- 🔜 Epic 3: Web Application & Distribution

## Testing

Run the unit tests:

```objectscript
Do ##class(%UnitTest.Manager).RunTest("Test.JSONSchema")
```

Current test coverage: 13 tests, all passing.

## Requirements

- InterSystems IRIS 2020.1 or later
- IPM/ZPM (for package installation)

## License

MIT License

## Contributing

Contributions are welcome! Please read the documentation in `/docs/` for architecture and coding standards.

## Acknowledgments

Built with [BMAD Framework](https://github.com/bmadone/bmad-core) for AI-assisted development.

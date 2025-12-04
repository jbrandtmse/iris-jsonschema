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
│   │       ├── Type.cls       # Type keyword validation
│   │       ├── Enum.cls       # Enum keyword validation
│   │       ├── Const.cls      # Const keyword validation
│   │       ├── String.cls     # String keywords (minLength, maxLength, pattern, format)
│   │       ├── Numeric.cls    # Numeric keywords (minimum, maximum, multipleOf, etc.)
│   │       └── Object.cls     # Object keywords (properties, required, additionalProperties, etc.)
│   └── Test/JSONSchema/
│       ├── TestValidator.cls        # Foundation tests
│       ├── TestTypeValidation.cls   # Type keyword tests
│       ├── TestEnumConst.cls        # Enum/Const tests
│       ├── TestInputFormats.cls     # Input format tests
│       ├── TestContext.cls          # Context tests
│       ├── TestPathTracking.cls     # Path tracking tests
│       ├── TestStringKeywords.cls   # String keyword tests
│       ├── TestNumericKeywords.cls  # Numeric keyword tests
│       └── TestObjectKeywords.cls   # Object keyword tests
├── docs/                      # Documentation
│   ├── stories/               # User stories
│   ├── qa/                    # QA gates and assessments
│   ├── prd/                   # Product requirements
│   └── architecture/          # Architecture documentation
├── module.xml                 # IPM package definition
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

### Epic 2: Complete JSON Schema Draft-07 Support 🔄 In Progress
- ✅ Story 2.1: String Validation Keywords (minLength, maxLength, pattern, format)
- ✅ Story 2.2: Numeric Validation Keywords (minimum, maximum, exclusiveMinimum, exclusiveMaximum, multipleOf)
- ✅ Story 2.3: Object Validation Keywords (properties, required, additionalProperties, patternProperties, propertyNames, minProperties, maxProperties)
- 🔜 Story 2.4: Array Validation Keywords
- 🔜 Story 2.5: Schema Composition Keywords (allOf, anyOf, oneOf, not)
- 🔜 Story 2.6: Conditional Schema Keywords (if/then/else)
- 🔜 Story 2.7: Reference and Definition Keywords ($ref, definitions)

### Epic 3: Web Application & Distribution
- 🔜 Upcoming

## Testing

Run the unit tests using MCP tools or IRIS terminal:

```objectscript
Do ##class(%UnitTest.Manager).RunTest("Test.JSONSchema")
```

**Current test coverage: 183 tests, all passing.**

## Requirements

- InterSystems IRIS 2020.1 or later
- IPM/ZPM (for package installation)

## License

MIT License

## Contributing

Contributions are welcome! Please read the documentation in `/docs/` for architecture and coding standards.

## Acknowledgments

Built with [BMAD Framework](https://github.com/bmadone/bmad-core) for AI-assisted development.

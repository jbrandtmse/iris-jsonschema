# JSONSchema Validator for InterSystems IRIS
## Product Requirements Document (PRD)

**Version:** 1.1  
**Date:** December 3, 2025  
**Status:** ✅ COMPLETE - Ready for Development  

---

## Goals and Background Context

### Goals

- **Native JSON Schema Validation:** Deliver a 100% ObjectScript implementation of JSON Schema validation for IRIS with zero external dependencies
- **Draft 7 & 2020-12 Compliance:** Achieve full compliance with both JSON Schema Draft 7 and 2020-12 specifications
- **Developer Experience:** Enable IRIS developers to validate JSON in under 5 minutes from installation with <10 lines of code integration
- **Portability:** Ensure the validator works on any IRIS instance without configuration or gateway dependencies
- **Community Adoption:** Establish the validator as a standard utility in the IRIS developer ecosystem via IPM/ZPM distribution
- **Testing Interface:** Provide a web-based UI for immediate schema validation testing and debugging

### Background Context

InterSystems IRIS developers currently lack a native solution for validating JSON data against industry-standard JSON Schemas. The available workarounds—external language gateways (Python, Java, .NET), custom validation code, or skipping validation entirely—each introduce significant trade-offs in portability, maintainability, or data quality. As JSON becomes the dominant data exchange format for modern APIs, microservices, and healthcare integrations (including FHIR), the need for robust, standards-compliant validation within IRIS has become critical.

This project addresses that gap with a two-component solution: a core ObjectScript validation library with a simple `Validate()` API, and an Angular-based web application for interactive testing. The 100% native implementation ensures maximum portability and aligns with IRIS's strength as a self-contained platform.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-12-03 | 1.0 | Initial PRD creation | PM Agent |
| 2025-12-03 | 1.1 | Added FR23 (User Manual) and Story 3.8; marked complete | PO Agent |

---

## Requirements

### Functional Requirements

**Core Validator Library:**

- **FR1:** The validator SHALL support JSON Schema Draft 7 specification keywords (type, properties, required, items, allOf, anyOf, oneOf, not, if/then/else, enum, const, minimum, maximum, minLength, maxLength, pattern, format, etc.)
- **FR2:** The validator SHALL support JSON Schema 2020-12 specification keywords
- **FR3:** The validator SHALL support remote references (`$ref`) resolving external URLs and internal relative paths
- **FR4:** The validator SHALL accept JSON data input as `%Library.DynamicObject`, `%Library.DynamicArray`, JSON string, or `%Stream.GlobalCharacter`
- **FR5:** The validator SHALL accept schema input as `%Library.DynamicObject`, JSON string, XData block reference, or server-side file path
- **FR6:** The validator SHALL return a `%Boolean` status (`1` for valid, `0` for invalid) from the `Validate()` method
- **FR7:** The validator SHALL populate an Output parameter with `%Library.DynamicArray` of error objects when validation fails
- **FR8:** Each error object SHALL contain `keyword`, `dataPath`, `message`, and `schemaPath` properties
- **FR9:** The validator SHALL accept a schema version parameter (defaulting to Draft 7) to specify which specification to validate against
- **FR10:** The validator SHALL implement circular reference protection using depth-limited traversal with visited node registry

**Web Application - Backend:**

- **FR11:** A REST dispatch class SHALL expose a `POST /validate` endpoint
- **FR12:** The API SHALL accept JSON payload containing `jsonInput` (string) and `schemaInput` (string)
- **FR13:** The API SHALL return JSON response containing validation status and error array

**Web Application - Frontend:**

- **FR14:** The Angular SPA SHALL feature a split-pane design with JSON data input (Pane A) and Schema input (Pane B)
- **FR15:** The application SHALL pre-populate default sample JSON and schema on initial load
- **FR16:** A "Validate" button SHALL invoke the backend API
- **FR17:** The UI SHALL display green "Valid" indicator for successful validation
- **FR18:** The UI SHALL display red "Invalid" indicator with error list in readable format for failed validation
- **FR19:** The UI SHALL provide schema version selection dropdown (Draft 7, 2020-12), defaulting to Draft 7

**Distribution:**

- **FR20:** The project SHALL include `module.xml` for IPM/ZPM package installation
- **FR21:** The repository SHALL follow structure: `/src/JSONSchema` (core), `/src/Test/JSONSchema` (tests), `/web` (frontend)
- **FR22:** Documentation SHALL include README with installation/usage, MIT LICENSE, and CONTRIBUTING.md
- **FR23:** A comprehensive User Manual SHALL be created covering all validator features, schema syntax examples, error message interpretation, and troubleshooting guides

### Non-Functional Requirements

**Performance:**

- **NFR1:** Validation of a typical JSON document (<100KB) SHALL complete in <100ms
- **NFR2:** The validator SHALL handle deeply nested structures (10+ levels) without stack overflow
- **NFR3:** Web UI response from "Validate" click to result display SHALL be <500ms

**Implementation:**

- **NFR4:** The core library SHALL be implemented 100% in ObjectScript with zero external language gateways
- **NFR5:** The validator SHALL be stateless - no persistent validator instances required

**Quality:**

- **NFR6:** Unit test coverage of core validation logic SHALL exceed 90%
- **NFR7:** Error accuracy (correct dataPath and message) SHALL be 100%

**Compatibility:**

- **NFR8:** The library SHALL support IRIS 2020.1+ versions
- **NFR9:** The web UI SHALL support modern browsers (Chrome, Firefox, Edge, Safari - latest 2 versions)

**Security (MVP):**

- **NFR10:** Remote `$ref` resolution SHALL be implemented with basic HTTP support (SSRF protection deferred to post-MVP)

**Localization:**

- **NFR11:** Error messages SHALL be in English only for MVP

---

## User Interface Design Goals

### Overall UX Vision

A **clean, developer-focused utility interface** that prioritizes immediate usability. The web application serves as a testing and debugging tool, not a production workflow system. The design should feel familiar to developers who have used similar JSON tools (like JSONLint, JSON Editor Online, or Swagger Editor) - functional, fast, and uncluttered.

**Key UX Principles:**
- **Immediate utility** - User can validate JSON within 30 seconds of page load
- **Visibility** - Both input and output visible simultaneously
- **Developer-friendly** - Monospace fonts, syntax highlighting, line numbers
- **Clear feedback** - Unmistakable valid/invalid visual states

### Key Interaction Paradigms

- **Edit-in-place** - Users type or paste directly into editor panes
- **Instant feedback loop** - Single "Validate" action, immediate results
- **Non-blocking errors** - Error display doesn't hide input, allowing quick iteration
- **Copy-paste optimized** - Easy to paste JSON from other tools, copy results

### Core Screens and Views

| Screen | Purpose | Priority |
|--------|---------|----------|
| **Main Validation View** | Split-pane JSON/Schema editors with validate button | MVP - Primary |
| **Error Results Panel** | Displays validation errors in table/list format | MVP - Primary |
| **Success State** | Green indicator showing validation passed | MVP - Primary |

*Note: This is a single-page application. No navigation, authentication, or multi-view complexity needed for MVP.*

### Accessibility

**WCAG AA** (recommended)
- Sufficient color contrast for valid/invalid indicators
- Keyboard navigable (Tab through panes, Enter to validate)
- Screen reader compatible status announcements

### Branding

**Minimal/Technical branding:**
- No elaborate visual identity required for MVP
- Clean, professional appearance suitable for developer tools
- Dark mode support would be valuable but is post-MVP

### Target Devices and Platforms

**Web Responsive** (Desktop-first)
- **Primary:** Desktop browsers (Chrome, Firefox, Edge, Safari)
- **Secondary:** Tablet landscape mode (functional but not optimized)
- **Out of scope:** Mobile phone optimization

---

## Technical Assumptions

### Repository Structure: Monorepo

**Rationale:** Single repository containing both ObjectScript library and Angular web application simplifies versioning, CI/CD, and release coordination.

```
/
├── src/JSONSchema/           # ObjectScript core library
├── src/Test/JSONSchema/      # ObjectScript unit tests
├── web/                      # Angular frontend
├── module.xml                # IPM package definition
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

### Service Architecture: Monolith (IRIS-hosted)

| Component | Technology | Hosting |
|-----------|------------|---------|
| Core Library | ObjectScript | IRIS namespace |
| REST API | IRIS REST Dispatch | IRIS web server |
| Web UI | Angular SPA | Static files (IRIS CSP or external) |

### Testing Requirements: Unit + Integration

| Test Type | Framework | Scope |
|-----------|-----------|-------|
| Unit Tests | %UnitTest | Core keyword validators, error formatting |
| Compliance Tests | JSON Schema Test Suite | Draft 7 / 2020-12 specification |
| API Tests | %UnitTest or manual | REST endpoint validation |
| UI Tests | Manual (MVP) | Angular component functionality |

### Additional Technical Assumptions

**Languages & Frameworks:**
- **ObjectScript:** 100% for core library (non-negotiable per NFR4)
- **Angular:** Latest LTS version for web frontend
- **TypeScript:** For Angular development

**Key Libraries & Dependencies:**

*ObjectScript (Core):*
- `%Library.DynamicObject` / `%Library.DynamicArray` - JSON handling
- `%Net.HttpRequest` - Remote `$ref` resolution
- `%UnitTest.TestCase` - Unit testing framework

*Angular (Web):*
- Monaco Editor or CodeMirror - JSON/Schema editing
- Angular Material (optional) - UI components
- Angular HTTP client - API communication

**API Design:**
- REST endpoint: `POST /validate`
- Request: `{ "jsonInput": "<json>", "schemaInput": "<schema>", "schemaVersion": "draft-07" | "2020-12" }`
- Response: `{ "valid": true|false, "errors": [...] }`

---

## Epic List

| Epic | Title | Goal Statement |
|------|-------|----------------|
| **Epic 1** | Foundation & Core Type Validation | Establish project infrastructure with Git, IPM skeleton, and deliver a working validator that can validate basic JSON types with proper error reporting |
| **Epic 2** | Complete JSON Schema Draft 7 Support | Implement all Draft 7 keywords including object/array validation, combinators, conditionals, and `$ref` resolution to achieve full specification compliance |
| **Epic 3** | Web Application & Distribution | Deliver the Angular-based testing interface with REST API integration and complete IPM packaging for community distribution |

---

## Epic 1: Foundation & Core Type Validation

### Epic Goal

Establish the project infrastructure including repository structure, IPM skeleton, and core ObjectScript classes. Deliver a functional validator capable of validating basic JSON types (`string`, `number`, `integer`, `boolean`, `null`, `array`, `object`) with proper error reporting structure.

### Story 1.1: Project Foundation with String Type Validation

**As a** developer,  
**I want** a working JSONSchema validator class with basic string type validation,  
**so that** I have a functional foundation to build additional validation features upon.

**Acceptance Criteria:**

1. Repository folder structure created: `/src/JSONSchema/`, `/src/Test/JSONSchema/`
2. `JSONSchema.Validator` class exists with `ClassMethod Validate(pJSON, pSchema, Output pErrors) As %Boolean`
3. Method accepts `%DynamicObject` for both pJSON and pSchema parameters
4. Validation of `{"type": "string"}` schema correctly identifies string vs non-string data
5. Returns `1` (true) when JSON data matches schema type
6. Returns `0` (false) when JSON data does not match schema type
7. pErrors output parameter populated with `%DynamicArray` containing at least one error object when validation fails
8. Error object contains `keyword` property set to `"type"`
9. Error object contains `message` property with human-readable error description
10. `module.xml` skeleton exists with package name `JSONSchema`
11. At least one unit test class exists in `/src/Test/JSONSchema/` that validates the string type checking

### Story 1.2: Complete Type Keyword Support

**As a** developer,  
**I want** the validator to support all JSON Schema type keywords,  
**so that** I can validate any basic JSON data type.

**Acceptance Criteria:**

1. Type validation works for `"number"` - validates numeric values (integers and floats)
2. Type validation works for `"integer"` - validates whole numbers only (rejects floats)
3. Type validation works for `"boolean"` - validates true/false values
4. Type validation works for `"null"` - validates null values only
5. Type validation works for `"array"` - validates JSON arrays
6. Type validation works for `"object"` - validates JSON objects
7. Type validation supports array of types: `{"type": ["string", "null"]}` accepts either type
8. Error messages clearly indicate expected type(s) vs actual type received
9. Unit tests exist for each type validation scenario
10. Unit tests exist for array-of-types scenarios

### Story 1.3: Enum and Const Keywords

**As a** developer,  
**I want** the validator to support enum and const keywords,  
**so that** I can validate that values match specific allowed values.

**Acceptance Criteria:**

1. `enum` keyword validates that value is one of the specified values in the enum array
2. `enum` works with all JSON types (strings, numbers, booleans, null, objects, arrays)
3. `const` keyword validates that value exactly matches the specified constant
4. `const` works with all JSON types including deep object/array comparison
5. Error message for `enum` failure lists the allowed values
6. Error message for `const` failure shows the expected constant value
7. Error object `keyword` property correctly set to `"enum"` or `"const"`
8. Unit tests cover enum with various types
9. Unit tests cover const with various types including nested structures

### Story 1.4: Context Class and Error Path Tracking

**As a** developer,  
**I want** validation errors to include precise path information,  
**so that** I can quickly locate the exact location of validation failures in nested structures.

**Acceptance Criteria:**

1. `JSONSchema.Context` class created to manage validation state
2. Context tracks current data path as JSON pointer format (e.g., `#/users/0/name`)
3. Context tracks current schema path (e.g., `#/properties/users/items/properties/name`)
4. All error objects include `dataPath` property with current data location
5. All error objects include `schemaPath` property with current schema location
6. Path tracking works correctly for nested object properties
7. Path tracking works correctly for array indices
8. Root-level validation errors use `#` as the path
9. Unit tests validate correct path tracking for nested objects (3+ levels)
10. Unit tests validate correct path tracking for arrays within objects

### Story 1.5: Flexible Input Handling

**As a** developer,  
**I want** the validator to accept multiple input formats for JSON and schema,  
**so that** I can use whichever format is most convenient for my use case.

**Acceptance Criteria:**

1. `Validate()` accepts `%DynamicObject` as JSON data input
2. `Validate()` accepts `%DynamicArray` as JSON data input  
3. `Validate()` accepts JSON string as JSON data input (auto-parsed)
4. `Validate()` accepts `%Stream.GlobalCharacter` as JSON data input (auto-parsed)
5. `Validate()` accepts `%DynamicObject` as schema input
6. `Validate()` accepts JSON string as schema input (auto-parsed)
7. Invalid JSON string input returns appropriate error (not validation error, parse error)
8. Input type detection is automatic - no separate parameter needed
9. Unit tests exist for each input format combination
10. Documentation comments in Validator class describe accepted input formats

---

## Epic 2: Complete JSON Schema Draft 7 Support

### Epic Goal

Implement all remaining JSON Schema Draft 7 keywords to achieve full specification compliance. This includes string/numeric constraints, object and array validation keywords, schema combinators (allOf, anyOf, oneOf, not), conditional schemas (if/then/else), and `$ref` reference resolution with circular reference protection. Epic completion is verified by passing the official JSON Schema Test Suite for Draft 7.

### Story 2.1: String Validation Keywords

**As a** developer,  
**I want** the validator to enforce string constraints,  
**so that** I can validate string length, patterns, and formats.

**Acceptance Criteria:**

1. `minLength` keyword validates string has at least N characters
2. `maxLength` keyword validates string has at most N characters
3. Combined `minLength` and `maxLength` work together correctly
4. `pattern` keyword validates string matches ECMAScript regex pattern
5. `format` keyword validates common formats: `date-time`, `date`, `time`, `email`, `uri`, `uuid`
6. Format validation is lenient (warns but doesn't fail) per JSON Schema spec, OR configurable
7. Error messages indicate which constraint failed and the actual vs expected values
8. Error object includes correct `keyword` (`minLength`, `maxLength`, `pattern`, `format`)
9. Unit tests cover each keyword with valid and invalid cases
10. Unit tests cover edge cases (empty string, unicode characters)

### Story 2.2: Numeric Validation Keywords

**As a** developer,  
**I want** the validator to enforce numeric constraints,  
**so that** I can validate number ranges and precision.

**Acceptance Criteria:**

1. `minimum` keyword validates number >= specified value
2. `maximum` keyword validates number <= specified value
3. `exclusiveMinimum` keyword validates number > specified value
4. `exclusiveMaximum` keyword validates number < specified value
5. `multipleOf` keyword validates number is a multiple of specified value
6. All numeric keywords work with both integers and floating-point numbers
7. `multipleOf` handles floating-point precision correctly
8. Error messages show expected constraint vs actual value
9. Unit tests cover boundary conditions (exactly at min/max)
10. Unit tests cover floating-point edge cases

### Story 2.3: Object Validation Keywords

**As a** developer,  
**I want** the validator to validate object structure and properties,  
**so that** I can enforce object schemas with required fields and property constraints.

**Acceptance Criteria:**

1. `properties` keyword validates each defined property against its sub-schema
2. `required` keyword validates that specified properties exist in the object
3. `additionalProperties: false` rejects objects with properties not in `properties`
4. `additionalProperties: {schema}` validates extra properties against the schema
5. `patternProperties` validates properties matching regex patterns
6. `propertyNames` validates that all property names match a schema
7. `minProperties` validates object has at least N properties
8. `maxProperties` validates object has at most N properties
9. `properties`, `patternProperties`, and `additionalProperties` work together correctly
10. Error messages indicate which property failed validation
11. Error `dataPath` correctly points to the failing property
12. Unit tests cover nested object validation (objects within objects)

### Story 2.4: Array Validation Keywords

**As a** developer,  
**I want** the validator to validate array structure and items,  
**so that** I can enforce array schemas with item constraints.

**Acceptance Criteria:**

1. `items` as object schema validates all array items against that schema
2. `items` as array of schemas validates each position against corresponding schema (tuple validation)
3. `additionalItems` validates items beyond the `items` array schemas
4. `additionalItems: false` rejects arrays longer than `items` array
5. `minItems` validates array has at least N items
6. `maxItems` validates array has at most N items
7. `uniqueItems: true` validates all array items are unique (deep comparison)
8. `contains` validates at least one item matches the schema (Draft 7+)
9. Error messages indicate which array index failed
10. Error `dataPath` correctly shows array index (e.g., `#/items/2`)
11. Unit tests cover arrays of objects and nested arrays
12. Unit tests cover `uniqueItems` with complex objects

### Story 2.5: Schema Combinators

**As a** developer,  
**I want** the validator to support allOf, anyOf, oneOf, and not combinators,  
**so that** I can create complex schemas combining multiple sub-schemas.

**Acceptance Criteria:**

1. `allOf` validates data matches ALL schemas in the array
2. `anyOf` validates data matches AT LEAST ONE schema in the array
3. `oneOf` validates data matches EXACTLY ONE schema in the array
4. `not` validates data does NOT match the specified schema
5. Combinators work with nested combinators (e.g., `allOf` containing `anyOf`)
6. Combinators work with all other keywords (type, properties, etc.)
7. `oneOf` correctly fails when data matches zero schemas
8. `oneOf` correctly fails when data matches more than one schema
9. Error messages for `anyOf`/`oneOf` indicate which sub-schemas were attempted
10. Error messages for `allOf` indicate which sub-schema failed
11. Unit tests cover complex nested combinator scenarios
12. Unit tests verify correct behavior when combinators reference `$ref`

### Story 2.6: Conditional Schema Keywords

**As a** developer,  
**I want** the validator to support if/then/else conditional validation,  
**so that** I can create schemas with conditional requirements.

**Acceptance Criteria:**

1. `if` schema evaluated first - if passes, `then` is applied; if fails, `else` is applied
2. `if/then` without `else` - validation passes if `if` fails (no `else` constraint)
3. `if/else` without `then` - validation passes if `if` succeeds (no `then` constraint)
4. `then` and `else` can be any valid schema (including combinators, refs)
5. Multiple `if/then/else` can be combined using `allOf`
6. Conditional schemas work with object property validation
7. Error messages indicate which branch (then/else) failed
8. `dependencies` keyword validates property dependencies (Draft 7 style)
9. Property dependencies: if property A exists, properties B and C must exist
10. Schema dependencies: if property A exists, additional schema must validate
11. Unit tests cover common conditional patterns (required-if, type-switching)
12. Unit tests cover nested conditionals

### Story 2.7: Schema References ($ref)

**As a** developer,  
**I want** the validator to resolve $ref references,  
**so that** I can reuse schema definitions and compose schemas from external sources.

**Acceptance Criteria:**

1. Internal `$ref` resolves references within same schema (e.g., `#/definitions/Address`)
2. Support for `definitions` (Draft 7) schema section for reusable schemas
3. Support for `$defs` (2020-12 alias) schema section
4. Relative `$ref` resolves correctly (e.g., `#/properties/shipping/properties/address`)
5. `$ref` can reference any schema location, not just definitions
6. Remote `$ref` fetches schema from HTTP/HTTPS URLs using `%Net.HttpRequest`
7. Fetched remote schemas are cached for the duration of the validation call
8. Circular reference protection: track visited `$ref` paths, use depth limit (configurable, default 100)
9. Circular reference detection returns clear error, not stack overflow
10. `$ref` overrides sibling keywords per JSON Schema spec (other keywords ignored)
11. Error messages for failed `$ref` indicate the reference path
12. Unit tests cover internal references, nested references, circular references
13. Unit tests cover remote references (may use mock or localhost test server)

### Story 2.8: JSON Schema Test Suite Compliance

**As a** developer,  
**I want** the validator to pass the official JSON Schema Test Suite,  
**so that** I have confidence in specification compliance.

**Acceptance Criteria:**

1. JSON Schema Test Suite Draft 7 tests downloaded/integrated into test structure
2. Test runner class executes all Draft 7 test files
3. Test results report shows pass/fail count per test file
4. All core vocabulary tests pass (type, enum, const, properties, items, etc.)
5. All combinator tests pass (allOf, anyOf, oneOf, not)
6. All conditional tests pass (if/then/else, dependencies)
7. All reference tests pass ($ref, definitions)
8. Optional format tests documented (pass/fail acceptable per spec)
9. Any failing tests documented with explanation (spec interpretation differences)
10. Test suite can be re-run as regression test
11. Compliance report generated showing overall pass rate (target: 100% required, optional documented)

---

## Epic 3: Web Application & Distribution

### Epic Goal

Deliver the complete MVP product including a REST API endpoint for programmatic validation, an Angular-based web application with split-pane JSON/Schema editors, visual validation feedback, and full distribution packaging via IPM/ZPM. This epic also adds JSON Schema 2020-12 support and completes all documentation for community release.

### Story 3.1: REST API Endpoint

**As a** developer,  
**I want** a REST API endpoint for JSON validation,  
**so that** I can integrate validation into my applications programmatically.

**Acceptance Criteria:**

1. `JSONSchema.REST.Dispatch` class created extending `%CSP.REST`
2. `POST /validate` endpoint accepts JSON request body
3. Request format: `{ "jsonInput": "<json-string>", "schemaInput": "<schema-string>", "schemaVersion": "draft-07" }`
4. `schemaVersion` parameter is optional, defaults to `"draft-07"`
5. `schemaVersion` accepts `"draft-07"` or `"2020-12"`
6. Response format: `{ "valid": true|false, "errors": [...], "schemaVersion": "<version-used>" }`
7. Response Content-Type is `application/json`
8. Invalid JSON in request returns HTTP 400 with error message
9. CORS headers configured for cross-origin requests from web UI
10. Unit/integration test validates endpoint with valid and invalid JSON
11. Web application mapping documented (CSP application setup instructions)

### Story 3.2: Angular Project Foundation

**As a** developer,  
**I want** an Angular web application with basic structure,  
**so that** I have a foundation for the validation testing UI.

**Acceptance Criteria:**

1. Angular project created in `/web` directory using Angular CLI (LTS version)
2. Project builds successfully with `ng build`
3. Basic single-page layout with header showing "JSONSchema Validator"
4. Split-pane layout implemented (left pane for JSON, right pane for Schema)
5. Panes are resizable (drag divider to adjust widths)
6. "Validate" button positioned prominently below or between panes
7. Results area below editors for displaying validation output
8. Basic responsive behavior (panes stack vertically on narrow screens)
9. Project configured for production build optimization
10. README in `/web` folder with build instructions

### Story 3.3: JSON and Schema Editors

**As a** user,  
**I want** proper code editors for JSON and Schema input,  
**so that** I can easily write and edit JSON with syntax highlighting.

**Acceptance Criteria:**

1. Monaco Editor (VS Code's editor) or CodeMirror integrated for both panes
2. JSON syntax highlighting enabled
3. Line numbers displayed
4. Auto-indentation and bracket matching functional
5. JSON pane pre-populated with sample valid JSON on load
6. Schema pane pre-populated with sample schema (matching the sample JSON) on load
7. Sample JSON demonstrates object with string, number, and array properties
8. Sample schema demonstrates type, properties, required keywords
9. Editor content persists during session (not lost on validation)
10. Clear visual distinction between JSON pane and Schema pane (labels/headers)
11. Error indicators in editor when JSON is malformed (red underline/icon)

### Story 3.4: Validation Integration and Results Display

**As a** user,  
**I want** to validate my JSON against a schema and see clear results,  
**so that** I can quickly identify and fix validation errors.

**Acceptance Criteria:**

1. "Validate" button triggers API call to REST endpoint
2. Loading indicator shown while validation in progress
3. **Valid result:** Green "✓ Valid" badge/banner displayed prominently
4. **Invalid result:** Red "✗ Invalid" badge/banner displayed prominently
5. Error list displayed in table/list format below editors when invalid
6. Error list shows: dataPath, keyword, message for each error
7. Error list is scrollable if many errors
8. Clicking error in list highlights/scrolls to relevant location in JSON editor (if feasible)
9. Schema version dropdown selector (Draft 7 / 2020-12) above or near Validate button
10. Dropdown defaults to Draft 7
11. Network/API errors display user-friendly error message (not raw error)
12. Validation result clears when user edits JSON or Schema

### Story 3.5: JSON Schema 2020-12 Support

**As a** developer,  
**I want** the validator to support JSON Schema 2020-12,  
**so that** I can validate against the latest specification.

**Acceptance Criteria:**

1. Validator accepts `schemaVersion` parameter in `Validate()` method
2. `schemaVersion` parameter accepts `"draft-07"` or `"2020-12"` (default: `"draft-07"`)
3. 2020-12 keyword differences handled: `$defs` (not just `definitions`), `prefixItems` (replaces array `items`), `items` (for additional items in 2020-12)
4. 2020-12 `$dynamicRef` and `$dynamicAnchor` NOT required for MVP (document as limitation)
5. 2020-12 vocabulary declarations NOT required for MVP (document as limitation)
6. Version detection based on `$schema` keyword if present, parameter overrides
7. Unit tests verify Draft 7 vs 2020-12 keyword behavior differences
8. Test suite includes 2020-12 specific tests (where different from Draft 7)
9. Documentation notes which 2020-12 features are/aren't supported

### Story 3.6: IPM Package and Distribution

**As a** developer,  
**I want** to install the validator via IPM/ZPM with a single command,  
**so that** I can easily add it to my IRIS projects.

**Acceptance Criteria:**

1. `module.xml` complete with all required metadata (name, version, description, author)
2. Package name: `jsonschema` (lowercase per IPM convention)
3. Source mappings correctly map `/src/JSONSchema` to target namespace
4. Test mappings correctly map `/src/Test/JSONSchema`
5. Dependencies section lists any required IRIS version constraints
6. Installation via `zpm "install jsonschema"` works correctly
7. Web application resources included or documented for separate deployment
8. Post-install verification: `Do ##class(JSONSchema.Validator).Validate()` compiles and runs
9. `module.xml` includes repository URL for Open Exchange listing
10. Package tested on clean IRIS instance to verify installation process

### Story 3.7: Documentation and Release Preparation

**As a** developer,  
**I want** comprehensive documentation,  
**so that** I can quickly learn how to use the validator.

**Acceptance Criteria:**

1. `README.md` includes: Project description, features list, installation instructions
2. `README.md` includes: Quick start code example (5-line validation)
3. `README.md` includes: Full API reference for `Validate()` method
4. `README.md` includes: Error object structure documentation
5. `README.md` includes: REST API endpoint documentation with curl examples
6. `README.md` includes: Web UI deployment instructions
7. `README.md` includes: Supported JSON Schema versions and any limitations
8. `LICENSE` file contains MIT license text
9. `CONTRIBUTING.md` includes: How to submit issues, PR process, coding standards
10. Code comments/documentation in Validator class are complete (method signatures, parameters)
11. CHANGELOG.md created with version 1.0.0 release notes
12. Repository has appropriate GitHub topics/tags for discoverability

### Story 3.8: User Manual

**As a** developer or integration engineer,  
**I want** a comprehensive user manual,  
**so that** I can understand all validator features, learn JSON Schema syntax, interpret error messages, and troubleshoot issues.

**Acceptance Criteria:**

1. User manual created as `docs/user-manual.md` (or equivalent multi-page structure)
2. **Getting Started** section covers: installation methods (IPM, manual), first validation example, web UI access
3. **JSON Schema Fundamentals** section covers: basic syntax overview, type system, common patterns
4. **Keyword Reference** section documents all supported keywords with examples:
   - Type keywords (type, enum, const)
   - String keywords (minLength, maxLength, pattern, format)
   - Numeric keywords (minimum, maximum, multipleOf)
   - Object keywords (properties, required, additionalProperties, patternProperties)
   - Array keywords (items, minItems, maxItems, uniqueItems, contains)
   - Combinators (allOf, anyOf, oneOf, not)
   - Conditionals (if/then/else, dependencies)
   - References ($ref, definitions/$defs)
5. **Error Message Guide** section explains each error type with:
   - Error keyword meaning
   - Common causes
   - How to fix examples
6. **API Reference** section covers ObjectScript API with method signatures, parameters, return values
7. **REST API Guide** section covers endpoint usage with request/response examples
8. **Web UI Guide** section covers all UI features with screenshots/descriptions
9. **Schema Version Differences** section documents Draft 7 vs 2020-12 differences
10. **Troubleshooting** section addresses common issues and solutions
11. **Advanced Topics** section covers: circular references, remote $ref resolution, performance tips
12. Table of contents with hyperlinks to all sections

---

## Checklist Results Report

### PM Checklist Validation Results

| Metric | Result |
|--------|--------|
| **Overall PRD Completeness** | 94% |
| **MVP Scope Appropriateness** | Just Right |
| **Readiness for Architecture Phase** | ✅ READY |

### Category Statuses

| Category | Status | Issues |
|----------|--------|--------|
| 1. Problem Definition & Context | ✅ PASS | None |
| 2. MVP Scope Definition | ✅ PASS | None |
| 3. User Experience Requirements | ✅ PASS | None |
| 4. Functional Requirements | ✅ PASS | None |
| 5. Non-Functional Requirements | ✅ PASS | None |
| 6. Epic & Story Structure | ✅ PASS | None |
| 7. Technical Guidance | ✅ PASS | None |
| 8. Cross-Functional Requirements | ⚠️ PARTIAL | Data schema left to Architect |
| 9. Clarity & Communication | ✅ PASS | None |

### Final Decision

✅ **READY FOR ARCHITECT** - PRD is comprehensive and ready for architectural design.

---

## Next Steps

### UX Expert Prompt

```
Review the PRD for JSONSchema Validator (docs/prd.md), specifically the 
"User Interface Design Goals" section. Create a detailed front-end 
specification covering split-pane editor layout, validation result 
display patterns, responsive behavior, and component hierarchy.

Input: docs/prd.md
Output: docs/front-end-spec.md
```

### Architect Prompt

```
Create the fullstack architecture document for JSONSchema Validator.
The project requires 100% ObjectScript core library, Angular web app 
with REST API, and IPM/ZPM packaging.

Key decisions needed:
- JSONSchema.Validator class design
- Keyword handler architecture (modular/extensible)
- Context object for validation state
- Error object structure
- REST dispatch class design
- Remote $ref resolution with circular protection

Input: docs/prd.md, docs/brief.md
Output: docs/architecture.md
```

---

*Document generated via BMad Method - PM Agent*

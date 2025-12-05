# Epic 3: Web Application & Distribution

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
12. `JSONSchema.REST.Setup` helper class provides programmatic CSP application creation

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

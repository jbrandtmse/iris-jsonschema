# Requirements

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

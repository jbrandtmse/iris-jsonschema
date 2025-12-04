# Software Requirements Specification (SRS)
## Project: JSONSchema Validator for InterSystems IRIS
**Version:** 1.4
**Date:** December 03, 2025
**Package:** `JSONSchema`
**Repository:** GitHub (Open Source)

---

## 1. Introduction
### 1.1 Purpose
The purpose of this project is to develop a native **JSON Schema Validator** library implemented entirely in **InterSystems ObjectScript**. This library will enable IRIS developers to validate JSON data structures against standard JSON Schemas (Draft 7 and 2020-12).

### 1.2 Scope
The MVP (Minimum Viable Product) delivery encompasses two required components:
1.  **Core Validator Library:** A backend ObjectScript package (`JSONSchema`) handling the parsing and validation logic.
2.  **Web Application:** An Angular-based user interface to facilitate immediate usage, testing, and interaction with the validation logic.

---

## 2. Functional Requirements: Core Library

### 2.1 Standards Compliance
* **FR-STD-01:** The validator **must** support **JSON Schema Specification Draft 7**.
* **FR-STD-02:** The validator **must** support **JSON Schema Specification 2020-12**.
* **FR-STD-03:** The validator **must** support **Remote References (`$ref`)**, allowing schemas to validate against definitions hosted at external URLs or internal relative paths.

### 2.2 API & Interface
* **FR-API-01:** The primary entry point shall be the class `JSONSchema.Validator`.
* **FR-API-02:** The validation method shall be named `Validate`.
* **FR-API-03 (Return Value):** The method must return a `%Boolean` status (`1` for Valid, `0` for Invalid).
* **FR-API-04 (Error Output):** The method must populate an Output parameter with a `%Library.DynamicArray` containing detailed error objects if validation fails.

### 2.3 Input Handling
* **FR-IN-01 (Data):** The validator must accept JSON data in the following formats:
    * `%Library.DynamicObject` / `%Library.DynamicArray`
    * JSON String
    * `%Stream.GlobalCharacter` (or compatible character stream)
* **FR-IN-02 (Schema):** The validator must accept JSON Schemas in the following formats:
    * `%Library.DynamicObject`
    * JSON String
    * XData block reference (Internal class storage)
    * External file path (Server-side)

### 2.4 Error Reporting Structure
* **FR-ERR-01:** The error object in the output array must contain at least:
    * `keyword`: The schema keyword that triggered the failure (e.g., `"required"`, `"minimum"`).
    * `dataPath`: The JSON pointer path to the invalid data node (e.g., `#/order/items/0/price`).
    * `message`: A human-readable description of the error.
    * `schemaPath`: The path within the schema that caused the rejection.

### 2.5 Implementation Constraints
* **FR-IMP-01:** The core library must be written **100% in ObjectScript**.
* **FR-IMP-02:** No external language gateways (Python, Java, .NET) may be used for the core logic to ensure maximum portability across IRIS instances.

---

## 3. Functional Requirements: MVP Web Application

### 3.1 Backend Service (IRIS REST)
* **FR-WEB-BE-01:** A REST dispatch class (e.g., `JSONSchema.Web.REST`) must be implemented to support the frontend.
* **FR-WEB-BE-02:** The API must expose an endpoint `POST /validate`.
* **FR-WEB-BE-03:** The API must accept a JSON payload containing `jsonInput` (string) and `schemaInput` (string).
* **FR-WEB-BE-04:** The API must return a JSON response containing the boolean status and the array of errors derived from the Core Library.

### 3.2 Frontend Client (Angular SPA)
* **FR-WEB-FE-01:** The client must be built using a stable version of **Angular**.
* **FR-WEB-FE-02:** The interface must feature a **Split-Pane Design**:
    * **Pane A:** Input text area for the JSON Data.
    * **Pane B:** Input text area for the JSON Schema.
* **FR-WEB-FE-03 (Initialization):** Upon application load, the input panes must be pre-populated with a valid **Default Sample JSON** and a corresponding **Default Sample Schema** to facilitate immediate testing.
* **FR-WEB-FE-04:** A "Validate" action button must invoke the backend API.
* **FR-WEB-FE-05:** Visual Feedback:
    * **Valid:** Display a green "Valid" indicator/badge.
    * **Invalid:** Display a red "Invalid" indicator and render the error list in a readable table or list format.

---

## 4. Technical Architecture Specifications

### 4.1 Class Structure (Proposed)
To ensure modularity and extensibility for future schema versions, the architecture should follow a pattern where keywords are isolated.

* **`JSONSchema.Validator`**: The orchestrator class.
* **`JSONSchema.Context`**: A class to hold the state of the current validation (current path, current schema scope).
* **`JSONSchema.Keyword.*`**: A set of classes or a dispatch mechanism where each schema keyword (e.g., `type`, `properties`, `allOf`) is handled by specific logic.

### 4.2 Proposed API Signature

```objectscript
Class JSONSchema.Validator Extends %RegisteredObject
{

/// Validates JSON against a Schema.
/// pJSON: The data to validate (DynamicObject, String, or Stream)
/// pSchema: The schema definition (DynamicObject, String, or XData)
/// Output pErrorList: A DynamicArray of error objects
/// Returns: 1 if valid, 0 if invalid
ClassMethod Validate(
    pJSON As %DataType, 
    pSchema As %DataType, 
    Output pErrorList As %Library.DynamicArray
) As %Boolean
{
    // Implementation
}

}
```

---

## 5. Non-Functional Requirements
* **NFR-01 (Performance):** The validator should be optimized for deep recursion, as JSON Schemas can be highly nested.
* **NFR-02 (Caching):** While not required for MVP, the architecture should allow for the future addition of a "Compiled Schema" cache to avoid re-parsing schema strings on every request.
* **NFR-03 (Security):** The remote reference (`$ref`) loader must have safeguards (e.g., timeouts, allowed domain lists) to prevent SSRF (Server-Side Request Forgery) in production environments. Note: For MVP, unrestricted access is acceptable.

---

## 6. Distribution & Documentation (Open Source)

### 6.1 Repository Structure
* **FR-OS-01:** The project must be hosted on GitHub.
* **FR-OS-02:** The repository must follow this specific folder structure:
    * `/src/JSONSchema`: Core ObjectScript source code.
    * `/src/Test/JSONSchema`: ObjectScript Unit Tests (using %UnitTest).
    * `/web`: Angular frontend source code.

### 6.2 Documentation Artifacts
* **FR-DOC-01 (README):** A root `README.md` must be provided containing:
    * Project Description.
    * Installation Instructions (focus on IPM/ZPM).
    * Basic Usage Examples (ObjectScript and REST).
* **FR-DOC-02 (LICENSE):** A standard Open Source license file (e.g., MIT) must be present.
* **FR-DOC-03 (CONTRIBUTING):** A `CONTRIBUTING.md` file outlining how community members can submit Pull Requests and report issues.

### 6.3 Packaging
* **FR-PKG-01 (IPM):** The project must include a `module.xml` file to support installation via the InterSystems Package Manager (IPM/ZPM). Mapping should map `/src` to the appropriate namespace locations.

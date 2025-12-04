# Goals and Background Context

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

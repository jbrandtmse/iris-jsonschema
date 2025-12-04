# Project Brief: JSONSchema Validator for InterSystems IRIS

**Version:** 1.0  
**Date:** December 3, 2025  
**Status:** Complete  

---

## Executive Summary

**JSONSchema Validator for InterSystems IRIS** is a native ObjectScript library that enables IRIS developers to validate JSON data structures against standard JSON Schemas (Draft 7 and 2020-12). The library addresses a critical gap in the IRIS ecosystem where developers currently lack a native, portable solution for JSON Schema validation without relying on external language gateways.

**Primary Problem:** IRIS developers need to validate JSON data against schemas but have no native ObjectScript solution, forcing them to use external gateways (Python, Java, .NET) which reduces portability and adds complexity.

**Target Market:** InterSystems IRIS developers and organizations building applications that process JSON data and require schema validation for data integrity, API contract enforcement, or configuration validation.

**Key Value Proposition:** 100% native ObjectScript implementation ensuring maximum portability across all IRIS instances, with a modern Angular web interface for immediate testing and interaction.

---

## Problem Statement

### Current State & Pain Points

InterSystems IRIS developers working with JSON data face a significant challenge: there is no native ObjectScript solution for validating JSON against industry-standard JSON Schemas. This forces development teams into one of several suboptimal paths:

1. **External Gateway Dependency** - Using Python, Java, or .NET gateways to access JSON Schema validators, which:
   - Reduces portability across IRIS instances
   - Adds deployment complexity and dependencies
   - Creates performance overhead from cross-process communication
   - Requires additional licensing and infrastructure considerations

2. **Manual Validation Code** - Writing custom validation logic for each data structure, which:
   - Is time-consuming and error-prone
   - Doesn't scale as schemas evolve
   - Lacks standardization across projects
   - Cannot leverage existing JSON Schema definitions

3. **Skipping Validation Entirely** - Accepting JSON data without formal validation, which:
   - Risks data integrity issues
   - Makes debugging data problems more difficult
   - Cannot enforce API contracts effectively

### Impact of the Problem

- **Development Velocity:** Teams spend significant time writing custom validation code or managing gateway integrations
- **Portability:** Applications become tied to specific infrastructure configurations
- **Interoperability:** Cannot easily adopt industry-standard JSON Schemas from external APIs or standards bodies
- **Quality:** Inconsistent validation approaches lead to data quality issues

### Why Existing Solutions Fall Short

The IRIS ecosystem lacks a purpose-built, native solution. External libraries (AJV for JavaScript, jsonschema for Python) are excellent but require gateway overhead that defeats IRIS's strength as a self-contained platform.

### Urgency

JSON has become the de facto data exchange format. As IRIS applications increasingly integrate with modern APIs, microservices, and cloud platforms, the need for robust JSON Schema validation grows daily.

---

## Proposed Solution

### Core Concept & Approach

The **JSONSchema Validator for InterSystems IRIS** is a two-component solution:

**1. Core Validator Library (`JSONSchema` Package)**
A 100% native ObjectScript implementation providing:
- Full compliance with JSON Schema Draft 7 and 2020-12 specifications
- Support for remote references (`$ref`) for external and internal schema definitions
- Flexible input handling (DynamicObject, JSON strings, streams, XData blocks, file paths)
- Rich, structured error reporting with JSON pointer paths for precise error location
- Modular keyword-based architecture for extensibility

**2. MVP Web Application**
An Angular-based testing interface with:
- Split-pane design for simultaneous JSON data and schema editing
- Pre-populated sample data for immediate testing
- Visual validation feedback (green/red indicators)
- Detailed error display for debugging

### Key Differentiators

| Approach | Our Solution |
|----------|--------------|
| External gateways | 100% ObjectScript - zero external dependencies |
| Custom validation | Standards-compliant - leverage existing schemas |
| Complex APIs | Simple `Validate()` method with boolean return |
| Black-box errors | Rich error objects with paths, messages, keywords |

### Why This Solution Will Succeed

1. **Zero friction adoption** - Install via IPM/ZPM, use immediately
2. **Portable by design** - Works on any IRIS instance without configuration
3. **Standards-first** - Validates against the same schemas used by JavaScript, Python, and other ecosystems
4. **Developer experience** - Web UI for testing, clear API for integration

### High-Level Vision

Position this as the definitive JSON Schema validation solution for the IRIS community - an open-source, community-driven project that becomes a standard utility in every IRIS developer's toolkit.

---

## Target Users

### Primary User Segment: IRIS Application Developers

**Profile:**
- Software developers and engineers working with InterSystems IRIS
- Building applications that consume or produce JSON data
- Range from individual developers to enterprise teams
- Technical skill level: Intermediate to advanced ObjectScript proficiency

**Current Behaviors & Workflows:**
- Regularly work with REST APIs, HL7 FHIR, or JSON-based integrations
- Currently writing manual validation code or using gateway solutions
- May be adopting IRIS for the first time from other platforms where JSON Schema validation is standard

**Specific Needs & Pain Points:**
- Need to validate incoming JSON payloads from external APIs
- Want to enforce data contracts in microservices architectures
- Require configuration file validation for application settings
- Need to ensure data quality before persistence to IRIS globals/tables

**Goals:**
- Reduce time spent on validation code
- Improve application reliability through standardized validation
- Maintain portability across different IRIS environments
- Leverage existing JSON Schemas from API specifications (OpenAPI/Swagger)

### Secondary User Segment: HealthCare Integration Specialists

**Profile:**
- Healthcare IT professionals working with FHIR, HL7, and health data standards
- Often work in regulated environments requiring data validation
- Use InterSystems HealthShare or Health Connect platforms

**Current Behaviors & Workflows:**
- Process high volumes of healthcare data in JSON format
- Must ensure compliance with FHIR resource schemas
- Need audit trails and validation reports for compliance

**Specific Needs & Pain Points:**
- Validate FHIR resources against standard schemas
- Ensure data integrity in patient data exchanges
- Support for complex nested healthcare data structures

**Goals:**
- Ensure healthcare data compliance
- Reduce integration errors in clinical workflows
- Provide validation evidence for audits

---

## Goals & Success Metrics

### Business Objectives

- **Community Adoption:** Achieve 100+ GitHub stars within 6 months of release (indicates developer interest)
- **IPM Downloads:** Reach 50+ unique installations via IPM/ZPM package manager in first quarter
- **Specification Coverage:** Achieve 100% compliance with JSON Schema Draft 7 core keywords by MVP release
- **Documentation Quality:** Maintain comprehensive README with usage examples achieving <5 support issues for basic usage questions

### User Success Metrics

- **Time to First Validation:** New users can run their first validation within 5 minutes of installation
- **Integration Effort:** Developers can integrate validation into existing code with <10 lines of ObjectScript
- **Error Resolution Time:** Structured error output enables developers to identify and fix JSON data issues 50% faster than manual debugging
- **Web UI Utility:** 80% of first-time users successfully validate custom JSON within their first session

### Key Performance Indicators (KPIs)

| KPI | Definition | Target |
|-----|------------|--------|
| **Specification Compliance** | % of JSON Schema Draft 7 keywords implemented | 100% at MVP |
| **Test Coverage** | Unit test coverage of core validation logic | >90% |
| **Validation Performance** | Average validation time for 100KB JSON document | <100ms |
| **Error Accuracy** | % of validation errors with correct dataPath and message | 100% |
| **Web UI Response** | Time from "Validate" click to result display | <500ms |
| **Zero Dependencies** | External language gateways required | 0 |

---

## MVP Scope

### Core Features (Must Have)

**Core Validator Library:**
- **JSON Schema Draft 7 Support:** Full compliance with Draft 7 specification keywords (type, properties, required, items, allOf, anyOf, oneOf, not, if/then/else, etc.)
- **JSON Schema 2020-12 Support:** Compliance with the latest specification
- **Remote Reference Support (`$ref`):** Resolve external URLs and internal relative paths for schema composition
- **Flexible JSON Input:** Accept `%Library.DynamicObject`, `%Library.DynamicArray`, JSON strings, and `%Stream.GlobalCharacter`
- **Flexible Schema Input:** Accept `%Library.DynamicObject`, JSON strings, XData blocks, and server-side file paths
- **Structured Error Output:** Return `%Library.DynamicArray` of error objects containing `keyword`, `dataPath`, `message`, and `schemaPath`
- **Simple API:** Single `Validate()` class method returning `%Boolean` status

**MVP Web Application:**
- **REST API Endpoint:** `POST /validate` accepting `jsonInput` and `schemaInput` strings
- **Angular Frontend:** Split-pane interface with JSON data (Pane A) and Schema (Pane B) editors
- **Default Sample Data:** Pre-populated valid JSON and schema on load for immediate testing
- **Visual Validation Feedback:** Green "Valid" badge or red "Invalid" indicator with error list

**Distribution:**
- **GitHub Repository:** Open source with proper folder structure (`/src/JSONSchema`, `/src/Test/JSONSchema`, `/web`)
- **IPM/ZPM Package:** `module.xml` for easy installation
- **Documentation:** README with installation, usage examples; LICENSE (MIT); CONTRIBUTING.md

### Out of Scope for MVP

- Schema compilation/caching for performance optimization
- SSRF protection safeguards for remote `$ref` (basic implementation only)
- JSON Schema Draft 4 or Draft 6 support
- Asynchronous validation
- Batch validation API
- Custom keyword extensions
- Schema generation from ObjectScript classes
- Integration with IRIS %JSON.Adaptor validation
- GUI schema builder/editor
- Validation result persistence/logging

### MVP Success Criteria

The MVP is successful when:
1. ✅ All JSON Schema Draft 7 core keywords validate correctly (verified by test suite)
2. ✅ Web UI can validate user-provided JSON and display results
3. ✅ Library installable via single IPM command (`zpm "install jsonschema"`)
4. ✅ Zero external language dependencies (100% ObjectScript)
5. ✅ Documentation enables new users to validate JSON within 5 minutes

---

## Post-MVP Vision

### Phase 2 Features (Near-term priorities)

**Performance & Optimization:**
- **Compiled Schema Cache:** Pre-parse and cache schema structures to avoid re-parsing on every validation request
- **Batch Validation API:** Validate multiple JSON documents against the same schema in a single call
- **Async Validation Support:** Non-blocking validation for large documents or high-throughput scenarios

**Security Hardening:**
- **SSRF Protection:** Configurable safeguards for remote `$ref` resolution including:
  - Timeout limits on remote fetches
  - Allowed/blocked domain lists
  - Local-only mode option
- **Schema Validation:** Validate schemas themselves before use (meta-schema validation)

**Developer Experience:**
- **Enhanced Error Messages:** Contextual suggestions for common validation failures
- **Validation Hints:** Optional warnings for schema anti-patterns
- **IDE Integration:** VS Code extension for ObjectScript with schema intellisense

### Long-term Vision (1-2 Years)

- **Schema Registry:** Central repository for storing and versioning schemas within IRIS
- **Automatic Schema Generation:** Generate JSON Schemas from ObjectScript classes, SQL tables, or sample JSON
- **%JSON.Adaptor Integration:** Seamless validation tied to IRIS's native JSON serialization
- **FHIR Profile Support:** Pre-bundled FHIR resource schemas with HealthShare integration
- **OpenAPI Integration:** Extract and validate against schemas from OpenAPI/Swagger specifications
- **GraphQL Schema Bridge:** Support for GraphQL schema validation use cases

### Expansion Opportunities

| Opportunity | Description | Market Impact |
|-------------|-------------|---------------|
| **HealthShare Marketplace** | Certified HealthShare component | Healthcare integration customers |
| **Enterprise Features** | Audit logging, validation metrics, compliance reports | Large organizations |
| **Cloud Deployment** | Containerized microservice version | Cloud-native IRIS users |
| **Community Ecosystem** | Plugin architecture for custom keywords | Developer community growth |
| **Training/Certification** | JSON Schema validation course for IRIS | Education revenue |

---

## Technical Considerations

### Platform Requirements

- **Target Platform:** InterSystems IRIS (all editions including HealthShare, Health Connect)
- **IRIS Version Support:** IRIS 2020.1+ (versions with robust %Library.Dynamic* support)
- **Browser Support (Web UI):** Modern browsers - Chrome, Firefox, Edge, Safari (latest 2 versions)
- **Performance Requirements:** <100ms validation for typical documents (<100KB), handle deep nesting (10+ levels)

### Technology Preferences

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Core Library** | 100% ObjectScript | Portability requirement - no external gateways |
| **Frontend** | Angular (stable LTS) | Modern SPA framework, TypeScript support |
| **REST API** | IRIS REST Dispatch Class | Native IRIS web serving |
| **Package Manager** | IPM/ZPM | Standard IRIS package distribution |
| **Testing** | %UnitTest Framework | Native IRIS testing |

### Architecture Considerations

**Repository Structure:**
```
/
├── src/
│   └── JSONSchema/           # Core ObjectScript classes
│       ├── Validator.cls     # Main entry point
│       ├── Context.cls       # Validation state management
│       └── Keyword/          # Keyword handlers
├── src/Test/
│   └── JSONSchema/           # %UnitTest test classes
├── web/                      # Angular frontend source
├── module.xml                # IPM package definition
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

**Service Architecture:**
- **Modular Keyword Design:** Each JSON Schema keyword (type, properties, required, etc.) handled by isolated logic for maintainability and extensibility
- **Context Object Pattern:** `JSONSchema.Context` class maintains validation state (current path, schema scope) through recursive validation
- **Stateless API:** `Validate()` method is stateless - no persistent validator instances required

**Integration Requirements:**
- REST endpoint accessible via standard IRIS web application configuration
- No external service dependencies for core validation
- Optional: HTTP client for remote `$ref` resolution (using IRIS %Net.HttpRequest)

**Security/Compliance:**
- MVP: Basic remote `$ref` support without safeguards (development use)
- Post-MVP: Configurable timeout, domain allowlist for production environments
- No sensitive data persistence in validation process

---

## Constraints & Assumptions

### Constraints

**Budget:**
- Open source project - no direct budget for licensing or paid tools
- Development resources limited to available contributor time
- Hosting: GitHub (free), IPM Open Exchange (free)

**Timeline:**
- MVP target: Deliver functional validator within reasonable development cycle
- No hard deadline - quality over speed for open source credibility
- Phased delivery: Core library first, then web application

**Resources:**
- Primary development in ObjectScript (specialized skill set)
- Angular development for web UI (common skill set)
- Testing requires IRIS instance access
- Community contributions welcome but not guaranteed

**Technical Constraints:**
- **100% ObjectScript mandate** - No Python, Java, .NET gateways
- **IRIS platform dependency** - Cannot run outside IRIS environment
- **Deep recursion handling** - ObjectScript stack limitations for deeply nested schemas
- **String handling** - IRIS string size limits for very large JSON documents
- **HTTP for remote $ref** - Network access required for external schema resolution

### Key Assumptions

- **Market Need Exists:** IRIS developers actively need JSON Schema validation and will adopt a native solution
- **Specification Stability:** JSON Schema Draft 7 and 2020-12 are stable specifications unlikely to change significantly
- **ObjectScript Capability:** ObjectScript can implement all required JSON Schema keywords without performance degradation
- **Community Interest:** The IRIS developer community will engage with an open-source validation library
- **IPM Adoption:** Target users are familiar with or willing to use IPM/ZPM for package installation
- **Angular Viability:** Angular remains a viable choice for the web UI throughout development
- **IRIS Compatibility:** Core %Library.DynamicObject functionality is consistent across target IRIS versions
- **Documentation Sufficiency:** Comprehensive README and examples will reduce support burden

---

## Risks & Open Questions

### Key Risks

| Risk | Description & Impact | Probability | Severity |
|------|---------------------|-------------|----------|
| **Specification Complexity** | JSON Schema specifications are extensive; implementing all keywords correctly may take longer than expected | Medium | High |
| **Deep Recursion Limits** | ObjectScript may hit stack limitations with deeply nested schemas/data | Medium | Medium |
| **Performance Degradation** | Native ObjectScript may be slower than compiled language validators for large documents | Medium | Medium |
| **Remote $ref Security** | Without safeguards, remote schema fetching could be exploited (SSRF) | Low (MVP) | High (Post-MVP) |
| **Draft 7 vs 2020-12 Complexity** | Supporting both specification versions increases scope | Medium | Medium |
| **Community Adoption** | Open source project may not gain traction without promotion | Medium | Medium |

### Resolved Questions

| Question | Resolution |
|----------|------------|
| **Keyword Priority** | Core type validation first, then combinators (allOf, anyOf, oneOf, etc.) |
| **Error Message Localization** | English only for MVP; internationalization is post-MVP |
| **Schema Version Detection** | Passed as parameter (or UI selection, defaulting to Draft 7) |
| **Circular Reference Handling** | Use depth-limited traversal + visited node registry pattern |
| **Large Document Strategy** | Follow IRIS limits: max string length, max DynamicObject size, max stream size |
| **Web UI Persistence** | No persistence required between sessions |
| **Test Suite Strategy** | Use official JSON Schema Test Suite for compliance verification |

### Research Findings

**JSON Schema Test Suite:**
- Official repository at `json-schema-org/JSON-Schema-Test-Suite` provides language-agnostic compliance tests
- Tests organized by specification version in subdirectories
- Implementation approach: Traverse test files, load schemas, validate instances, compare against expected `valid` boolean
- Remote references served from `http://localhost:1234` during testing

**Circular Reference Best Practice:**
- Use **RefResolver pattern** with visited node registry to track traversal path
- Implement **depth-limited traversal** as safety bound (configurable MaxDepth)
- Upon encountering already-visited node in current path, cease traversal of that branch
- No infinite recursion regardless of schema complexity

---

## Next Steps

### Immediate Actions

1. **Finalize Project Brief** - ✅ Saved to `docs/brief.md`
2. **Create PRD** - Use PM agent to develop detailed Product Requirements Document from this brief
3. **Design Architecture** - Create fullstack architecture document covering core library + web application
4. **Set Up Repository** - Initialize GitHub repo with proper folder structure (`/src/JSONSchema`, `/src/Test/JSONSchema`, `/web`)
5. **Configure IPM/ZPM** - Create initial `module.xml` for package distribution
6. **Download JSON Schema Test Suite** - Clone official test suite for compliance testing reference

### PM Handoff

This Project Brief provides the full context for **JSONSchema Validator for InterSystems IRIS**. 

**Next workflow step:** Start with PM agent (`@pm`) to create the PRD using the `prd-tmpl.yaml` template. The PRD will:
- Break down features into implementable stories
- Define acceptance criteria for each feature
- Establish story priority and sequencing
- Prepare for architecture design phase

---

*Document generated via BMad Method - Greenfield Fullstack Workflow*

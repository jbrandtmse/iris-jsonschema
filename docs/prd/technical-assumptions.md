# Technical Assumptions

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

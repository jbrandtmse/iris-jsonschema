# 3. Tech Stack

This is the **definitive technology selection** for the JSONSchema Validator project. All development must use these exact technologies and versions.

| Category | Technology | Version | Purpose | Rationale |
|----------|------------|---------|---------|-----------|
| **Backend Language** | ObjectScript | IRIS 2020.1+ | Core validation library | 100% native requirement, maximum portability |
| **Backend Platform** | InterSystems IRIS | 2020.1+ | Runtime environment | Target platform, provides all services |
| **JSON Handling** | %Library.DynamicObject | Native | JSON parsing and manipulation | Built-in IRIS, high performance |
| **HTTP Client** | %Net.HttpRequest | Native | Remote $ref resolution | Built-in IRIS, no dependencies |
| **REST Framework** | %CSP.REST | Native | REST API dispatch | Native IRIS REST support |
| **Backend Testing** | %UnitTest.TestCase | Native | Unit testing framework | Standard IRIS testing |
| **Frontend Language** | TypeScript | 5.x | Angular development | Type safety, modern JS |
| **Frontend Framework** | Angular | 18.x LTS | Single Page Application | PRD requirement, modern SPA |
| **UI Components** | Angular Material | 18.x | UI component library | Consistent design, accessibility |
| **Code Editor** | CodeMirror 6 | Latest | JSON/Schema editing | ~95% smaller bundle than Monaco, better mobile support |
| **Frontend HTTP** | Angular HttpClient | 18.x | API communication | Built-in Angular, observables |
| **Frontend Testing** | Jasmine + Karma | Latest | Unit testing | Angular default, well-supported |
| **E2E Testing** | Manual (MVP) | - | End-to-end validation | Post-MVP: Playwright or Cypress |
| **CSS Framework** | Angular Material | 18.x | Styling and theming | Integrated with components |
| **Build Tool (FE)** | Angular CLI | 18.x | Frontend builds | Standard Angular tooling |
| **Build Tool (BE)** | IRIS Compiler | Native | ObjectScript compilation | Built-in IRIS |
| **Package Manager** | IPM/ZPM | Latest | IRIS package distribution | Community standard for IRIS |
| **Package Manager (FE)** | npm | 10.x | Frontend dependencies | Node.js standard |
| **Version Control** | Git | Latest | Source control | Industry standard |
| **CI/CD** | GitHub Actions | Latest | Automated builds/tests | Free for open source |
| **Documentation** | Markdown | - | README, docs | Universal, GitHub rendering |

---

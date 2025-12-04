# 11. Development Workflow

### Prerequisites

- InterSystems IRIS 2020.1+
- Node.js 20.x LTS
- IPM/ZPM installed
- VS Code with ObjectScript extension

### Development Commands

```bash
# ObjectScript - Load classes
Do $System.OBJ.LoadDir("/path/to/src/cls", "ck", .errors, 1)

# ObjectScript - Run tests
Do ##class(%UnitTest.Manager).RunTest("Test.JSONSchema")

# Angular - Development server
cd web && npm start

# Angular - Production build
cd web && npm run build
```

### Environment Configuration

```typescript
// environment.ts (development)
export const environment = {
  production: false,
  apiBaseUrl: 'http://localhost:52773/api/jsonschema'
};

// environment.prod.ts (production)
export const environment = {
  production: true,
  apiBaseUrl: '/api/jsonschema'
};
```

---

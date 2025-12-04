# 14. Testing Strategy

### Testing Pyramid

| Level | Framework | Coverage |
|-------|-----------|----------|
| Unit (ObjectScript) | %UnitTest | 90%+ |
| Unit (Angular) | Jasmine/Karma | 80%+ |
| Compliance | JSON Schema Test Suite | 100% required |
| E2E | Manual (MVP) | Critical paths |

### Test Commands

```bash
# ObjectScript
Do ##class(%UnitTest.Manager).RunTest("Test.JSONSchema")

# Angular
cd web && npm test

# JSON Schema Test Suite
Do ##class(%UnitTest.Manager).RunTest("Test.JSONSchema.TestSuite.TestSuiteRunner")
```

---

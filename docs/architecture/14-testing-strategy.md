# 14. Testing Strategy

### Test File Organization

Tests must be organized into files of no more than 800 lines, grouped by feature or functionality.

**File Naming:** `Test{Feature}.cls`

**Examples:**
- `TestTypeValidation.cls` - Type keyword tests (Story 1.2)
- `TestEnumConst.cls` - Enum and const keyword tests (Story 1.3)
- `TestInputFormats.cls` - Input format handling (Story 1.5)
- `TestValidator.cls` - Foundation and cross-cutting tests (Story 1.1)

**When to Create a New Test File:**
1. Current file approaching 800-line limit
2. New feature/keyword with 5+ test methods
3. Logical grouping by story or JSON Schema specification section

**File Organization Strategies:**
1. **By Keyword**: Group all tests for a specific JSON Schema keyword
2. **By Story**: When story represents a cohesive feature (e.g., input formats)
3. **By Complexity**: Separate basic validation from complex/integration tests

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

# 16. Error Handling

### Error Response Format

```typescript
// Validation errors (HTTP 200)
interface ValidationResponse {
  valid: boolean;
  errors: ValidationError[];
  schemaVersion: string;
}

// System errors (HTTP 400/500)
interface ErrorResponse {
  error: {
    code: string;
    message: string;
  };
}
```

### Error Codes

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| `PARSE_ERROR` | 400 | Invalid JSON in request |
| `INVALID_JSON_INPUT` | 400 | jsonInput not valid JSON |
| `INVALID_SCHEMA_INPUT` | 400 | schemaInput not valid JSON |
| `INTERNAL_ERROR` | 500 | Unexpected server error |

---

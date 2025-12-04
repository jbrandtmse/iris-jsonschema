# 4. Data Models

This project is a **stateless validation library** - there are no persistent entities or database tables. However, there are critical data structures that must be consistent between the ObjectScript backend and Angular frontend.

### 4.1 ValidationError

**Purpose:** Represents a single validation error with location and context information.

**TypeScript Interface:**
```typescript
interface ValidationError {
  keyword: string;
  dataPath: string;
  schemaPath: string;
  message: string;
}
```

### 4.2 ValidationRequest

**Purpose:** API request payload for validation endpoint.

```typescript
interface ValidationRequest {
  jsonInput: string;
  schemaInput: string;
  schemaVersion?: 'draft-07' | '2020-12';
}
```

### 4.3 ValidationResponse

**Purpose:** API response payload from validation endpoint.

```typescript
interface ValidationResponse {
  valid: boolean;
  errors: ValidationError[];
  schemaVersion: 'draft-07' | '2020-12';
}
```

### 4.4 ValidationContext (Internal)

**Purpose:** Internal state management during validation traversal. Not exposed to API.

```objectscript
Class JSONSchema.Context Extends %RegisteredObject
{
    Property DataPath As %String;
    Property SchemaPath As %String;
    Property Errors As %Library.DynamicArray;
    Property VisitedRefs As %Library.DynamicObject;
    Property Depth As %Integer [ InitialExpression = 0 ];
    Property MaxDepth As %Integer [ InitialExpression = 100 ];
    Property SchemaVersion As %String [ InitialExpression = "draft-07" ];
}
```

---

# 7. Core Workflows

### 7.1 Web UI Validation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Angular App
    participant REST as REST.Dispatch
    participant VAL as Validator
    
    U->>UI: Enter JSON + Schema
    U->>UI: Click "Validate"
    UI->>REST: POST /validate
    REST->>VAL: Validate(json, schema, .errors)
    VAL-->>REST: valid, errors[]
    REST-->>UI: {valid, errors, schemaVersion}
    UI->>UI: Display result (green/red + error list)
```

### 7.2 Core Validation Flow

The validator processes keywords in priority order:
1. **$ref** - Resolved first, overrides all other keywords
2. **type** - Basic type checking
3. **enum/const** - Value matching
4. **String keywords** - minLength, maxLength, pattern, format
5. **Numeric keywords** - minimum, maximum, multipleOf
6. **Object keywords** - properties, required, additionalProperties
7. **Array keywords** - items, minItems, maxItems, uniqueItems
8. **Combinators** - allOf, anyOf, oneOf, not
9. **Conditionals** - if/then/else, dependencies

---

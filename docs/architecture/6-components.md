# 6. Components

### 6.1 Core ObjectScript Components

#### JSONSchema.Validator (Main Entry Point)

**Responsibility:** Public API for JSON Schema validation. Single entry point for all validation operations.

**Key Interface:**
```objectscript
ClassMethod Validate(pJSON, pSchema, Output pErrors As %DynamicArray, pSchemaVersion As %String = "draft-07") As %Boolean
```

#### JSONSchema.Context (Validation State)

**Responsibility:** Maintains validation state during recursive traversal. Tracks paths, errors, and circular reference protection.

#### JSONSchema.RefResolver ($ref Resolution)

**Responsibility:** Resolves JSON Schema `$ref` references - internal (#/definitions/...) and external (http://...).

#### JSONSchema.Keyword.* (Keyword Handlers)

**Responsibility:** Each class handles validation for a specific JSON Schema keyword (Strategy Pattern).

| Class | Keywords Handled |
|-------|-----------------|
| `JSONSchema.Keyword.Type` | type |
| `JSONSchema.Keyword.Enum` | enum, const |
| `JSONSchema.Keyword.String` | minLength, maxLength, pattern, format |
| `JSONSchema.Keyword.Numeric` | minimum, maximum, exclusiveMinimum, exclusiveMaximum, multipleOf |
| `JSONSchema.Keyword.Object` | properties, required, additionalProperties, patternProperties |
| `JSONSchema.Keyword.Array` | items, additionalItems, minItems, maxItems, uniqueItems, contains |
| `JSONSchema.Keyword.Combinator` | allOf, anyOf, oneOf, not |
| `JSONSchema.Keyword.Conditional` | if, then, else, dependencies |
| `JSONSchema.Keyword.Ref` | $ref |

### 6.2 REST API Component

#### JSONSchema.REST.Dispatch

**Responsibility:** REST endpoint routing and request/response handling.

```objectscript
Class JSONSchema.REST.Dispatch Extends %CSP.REST
{
    Parameter HandleCorsRequest = 1;
    
    XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
    {
        <Routes>
            <Route Url="/validate" Method="POST" Call="Validate"/>
        </Routes>
    }
}
```

### 6.3 Angular Frontend Components

| Component | Purpose |
|-----------|---------|
| `AppComponent` | Root component, layout |
| `JsonEditorComponent` | Monaco editor for JSON data |
| `SchemaEditorComponent` | Monaco editor for schema |
| `ValidationResultComponent` | Results display |
| `SchemaVersionSelectorComponent` | Version dropdown |
| `ValidationService` | API client service |

---

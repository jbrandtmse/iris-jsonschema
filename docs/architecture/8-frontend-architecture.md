# 8. Frontend Architecture

### 8.1 Component Organization

```
web/src/app/
├── components/
│   ├── json-editor/
│   ├── schema-editor/
│   ├── validation-result/
│   └── schema-version-selector/
├── services/
│   └── validation.service.ts
├── models/
│   ├── validation-request.model.ts
│   ├── validation-response.model.ts
│   └── validation-error.model.ts
├── app.component.ts
└── app.config.ts
```

### 8.2 State Management

**Approach:** Angular Signals (no external library needed)

```typescript
// State signals
jsonInput = signal<string>(DEFAULT_JSON);
schemaInput = signal<string>(DEFAULT_SCHEMA);
schemaVersion = signal<'draft-07' | '2020-12'>('draft-07');
isValidating = signal<boolean>(false);
validationResult = signal<ValidationResponse | null>(null);

// Computed
hasResult = computed(() => this.validationResult() !== null);
isValid = computed(() => this.validationResult()?.valid ?? false);
```

### 8.3 API Client

```typescript
@Injectable({ providedIn: 'root' })
export class ValidationService {
  private readonly apiUrl = `${environment.apiBaseUrl}/validate`;

  async validate(
    jsonInput: string,
    schemaInput: string,
    schemaVersion: 'draft-07' | '2020-12' = 'draft-07'
  ): Promise<ValidationResponse> {
    return firstValueFrom(
      this.http.post<ValidationResponse>(this.apiUrl, {
        jsonInput,
        schemaInput,
        schemaVersion
      })
    );
  }
}
```

---

# 10. Project Structure

```
iris-jsonschema/
├── .github/workflows/           # CI/CD
│   ├── ci.yaml
│   └── release.yaml
├── src/                         # ObjectScript source
│   ├── JSONSchema/
│   │   ├── Validator.cls
│   │   ├── Context.cls
│   │   ├── RefResolver.cls
│   │   ├── REST/
│   │   │   └── Dispatch.cls
│   │   └── Keyword/
│   │       ├── Type.cls
│   │       ├── Enum.cls
│   │       ├── String.cls
│   │       ├── Numeric.cls
│   │       ├── Object.cls
│   │       ├── Array.cls
│   │       ├── Combinator.cls
│   │       ├── Conditional.cls
│   │       └── Ref.cls
│   └── Test/JSONSchema/         # Unit tests
├── web/                         # Angular frontend
│   ├── src/app/
│   ├── angular.json
│   └── package.json
├── csp/jsonschema/              # Built web app
├── docs/                        # Documentation
├── module.xml                   # IPM package
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

---

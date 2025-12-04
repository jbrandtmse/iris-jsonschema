# 12. Deployment Architecture

### Deployment Strategy

- **ObjectScript:** IPM/ZPM package installation
- **Web UI:** IRIS CSP Application (bundled with package)
- **Distribution:** Open Exchange / GitHub releases

### Installation

```objectscript
// Production installation
ZPM "install jsonschema"

// Development - load from local
ZPM "load /path/to/iris-jsonschema"
```

---

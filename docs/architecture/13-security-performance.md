# 13. Security & Performance

### Security

| Aspect | Implementation |
|--------|----------------|
| Input Validation | JSON parsing with try/catch |
| CORS | Disabled (same-origin CSP) |
| Authentication | None required (stateless) |
| Remote $ref | Basic HTTP (SSRF protection post-MVP) |

### Performance Targets

| Metric | Target |
|--------|--------|
| Validation (100KB JSON) | < 100ms |
| Deep nesting | Handle 10+ levels |
| Web UI response | < 500ms |
| Bundle size | < 500KB gzipped |

---

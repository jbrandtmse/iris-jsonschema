# Next Steps

### UX Expert Prompt

```
Review the PRD for JSONSchema Validator (docs/prd.md), specifically the 
"User Interface Design Goals" section. Create a detailed front-end 
specification covering split-pane editor layout, validation result 
display patterns, responsive behavior, and component hierarchy.

Input: docs/prd.md
Output: docs/front-end-spec.md
```

### Architect Prompt

```
Create the fullstack architecture document for JSONSchema Validator.
The project requires 100% ObjectScript core library, Angular web app 
with REST API, and IPM/ZPM packaging.

Key decisions needed:
- JSONSchema.Validator class design
- Keyword handler architecture (modular/extensible)
- Context object for validation state
- Error object structure
- REST dispatch class design
- Remote $ref resolution with circular protection

Input: docs/prd.md, docs/brief.md
Output: docs/architecture.md
```

---

*Document generated via BMad Method - PM Agent*

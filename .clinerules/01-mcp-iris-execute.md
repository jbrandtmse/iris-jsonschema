# IRIS MCP Tool Parameter Formats

## compile_objectscript_class

**CRITICAL**: The `class_names` parameter must be a comma-separated string, NOT an array.

### Correct Usage

```json
{
  "class_names": "JSONSchema.Keyword.Array,JSONSchema.Validator",
  "namespace": "HSCUSTOM"
}
```

### Incorrect Usage (will fail)

```json
{
  "class_names": ["JSONSchema.Keyword.Array", "JSONSchema.Validator"],
  "namespace": "HSCUSTOM"
}
```

## execute_classmethod

**CRITICAL**: Parameter names are `class_name` and `method_name`, not `classname` and `method`.

### Correct Usage

```json
{
  "class_name": "JSONSchema.Debug",
  "method_name": "DebugUniqueItemsMixed",
  "namespace": "HSCUSTOM"
}
```

### Incorrect Usage (will fail)

```json
{
  "classname": "JSONSchema.Debug",
  "method": "DebugUniqueItemsMixed",
  "namespace": "HSCUSTOM"
}

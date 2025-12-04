# Epic 1: Foundation & Core Type Validation

### Epic Goal

Establish the project infrastructure including repository structure, IPM skeleton, and core ObjectScript classes. Deliver a functional validator capable of validating basic JSON types (`string`, `number`, `integer`, `boolean`, `null`, `array`, `object`) with proper error reporting structure.

### Story 1.1: Project Foundation with String Type Validation

**As a** developer,  
**I want** a working JSONSchema validator class with basic string type validation,  
**so that** I have a functional foundation to build additional validation features upon.

**Acceptance Criteria:**

1. Repository folder structure created: `/src/JSONSchema/`, `/src/Test/JSONSchema/`
2. `JSONSchema.Validator` class exists with `ClassMethod Validate(pJSON, pSchema, Output pErrors) As %Boolean`
3. Method accepts `%DynamicObject` for both pJSON and pSchema parameters
4. Validation of `{"type": "string"}` schema correctly identifies string vs non-string data
5. Returns `1` (true) when JSON data matches schema type
6. Returns `0` (false) when JSON data does not match schema type
7. pErrors output parameter populated with `%DynamicArray` containing at least one error object when validation fails
8. Error object contains `keyword` property set to `"type"`
9. Error object contains `message` property with human-readable error description
10. `module.xml` skeleton exists with package name `JSONSchema`
11. At least one unit test class exists in `/src/Test/JSONSchema/` that validates the string type checking

### Story 1.2: Complete Type Keyword Support

**As a** developer,  
**I want** the validator to support all JSON Schema type keywords,  
**so that** I can validate any basic JSON data type.

**Acceptance Criteria:**

1. Type validation works for `"number"` - validates numeric values (integers and floats)
2. Type validation works for `"integer"` - validates whole numbers only (rejects floats)
3. Type validation works for `"boolean"` - validates true/false values
4. Type validation works for `"null"` - validates null values only
5. Type validation works for `"array"` - validates JSON arrays
6. Type validation works for `"object"` - validates JSON objects
7. Type validation supports array of types: `{"type": ["string", "null"]}` accepts either type
8. Error messages clearly indicate expected type(s) vs actual type received
9. Unit tests exist for each type validation scenario
10. Unit tests exist for array-of-types scenarios

### Story 1.3: Enum and Const Keywords

**As a** developer,  
**I want** the validator to support enum and const keywords,  
**so that** I can validate that values match specific allowed values.

**Acceptance Criteria:**

1. `enum` keyword validates that value is one of the specified values in the enum array
2. `enum` works with all JSON types (strings, numbers, booleans, null, objects, arrays)
3. `const` keyword validates that value exactly matches the specified constant
4. `const` works with all JSON types including deep object/array comparison
5. Error message for `enum` failure lists the allowed values
6. Error message for `const` failure shows the expected constant value
7. Error object `keyword` property correctly set to `"enum"` or `"const"`
8. Unit tests cover enum with various types
9. Unit tests cover const with various types including nested structures

### Story 1.4: Context Class and Error Path Tracking

**As a** developer,  
**I want** validation errors to include precise path information,  
**so that** I can quickly locate the exact location of validation failures in nested structures.

**Acceptance Criteria:**

1. `JSONSchema.Context` class created to manage validation state
2. Context tracks current data path as JSON pointer format (e.g., `#/users/0/name`)
3. Context tracks current schema path (e.g., `#/properties/users/items/properties/name`)
4. All error objects include `dataPath` property with current data location
5. All error objects include `schemaPath` property with current schema location
6. Path tracking works correctly for nested object properties
7. Path tracking works correctly for array indices
8. Root-level validation errors use `#` as the path
9. Unit tests validate correct path tracking for nested objects (3+ levels)
10. Unit tests validate correct path tracking for arrays within objects

### Story 1.5: Flexible Input Handling

**As a** developer,  
**I want** the validator to accept multiple input formats for JSON and schema,  
**so that** I can use whichever format is most convenient for my use case.

**Acceptance Criteria:**

1. `Validate()` accepts `%DynamicObject` as JSON data input
2. `Validate()` accepts `%DynamicArray` as JSON data input  
3. `Validate()` accepts JSON string as JSON data input (auto-parsed)
4. `Validate()` accepts `%Stream.GlobalCharacter` as JSON data input (auto-parsed)
5. `Validate()` accepts `%DynamicObject` as schema input
6. `Validate()` accepts JSON string as schema input (auto-parsed)
7. Invalid JSON string input returns appropriate error (not validation error, parse error)
8. Input type detection is automatic - no separate parameter needed
9. Unit tests exist for each input format combination
10. Documentation comments in Validator class describe accepted input formats

---

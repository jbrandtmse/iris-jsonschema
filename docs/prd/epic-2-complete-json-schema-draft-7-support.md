# Epic 2: Complete JSON Schema Draft 7 Support

### Epic Goal

Implement all remaining JSON Schema Draft 7 keywords to achieve full specification compliance. This includes string/numeric constraints, object and array validation keywords, schema combinators (allOf, anyOf, oneOf, not), conditional schemas (if/then/else), and `$ref` reference resolution with circular reference protection. Epic completion is verified by passing the official JSON Schema Test Suite for Draft 7.

### Story 2.1: String Validation Keywords

**As a** developer,  
**I want** the validator to enforce string constraints,  
**so that** I can validate string length, patterns, and formats.

**Acceptance Criteria:**

1. `minLength` keyword validates string has at least N characters
2. `maxLength` keyword validates string has at most N characters
3. Combined `minLength` and `maxLength` work together correctly
4. `pattern` keyword validates string matches ECMAScript regex pattern
5. `format` keyword validates common formats: `date-time`, `date`, `time`, `email`, `uri`, `uuid`
6. Format validation is lenient (warns but doesn't fail) per JSON Schema spec, OR configurable
7. Error messages indicate which constraint failed and the actual vs expected values
8. Error object includes correct `keyword` (`minLength`, `maxLength`, `pattern`, `format`)
9. Unit tests cover each keyword with valid and invalid cases
10. Unit tests cover edge cases (empty string, unicode characters)

### Story 2.2: Numeric Validation Keywords

**As a** developer,  
**I want** the validator to enforce numeric constraints,  
**so that** I can validate number ranges and precision.

**Acceptance Criteria:**

1. `minimum` keyword validates number >= specified value
2. `maximum` keyword validates number <= specified value
3. `exclusiveMinimum` keyword validates number > specified value
4. `exclusiveMaximum` keyword validates number < specified value
5. `multipleOf` keyword validates number is a multiple of specified value
6. All numeric keywords work with both integers and floating-point numbers
7. `multipleOf` handles floating-point precision correctly
8. Error messages show expected constraint vs actual value
9. Unit tests cover boundary conditions (exactly at min/max)
10. Unit tests cover floating-point edge cases

### Story 2.3: Object Validation Keywords

**As a** developer,  
**I want** the validator to validate object structure and properties,  
**so that** I can enforce object schemas with required fields and property constraints.

**Acceptance Criteria:**

1. `properties` keyword validates each defined property against its sub-schema
2. `required` keyword validates that specified properties exist in the object
3. `additionalProperties: false` rejects objects with properties not in `properties`
4. `additionalProperties: {schema}` validates extra properties against the schema
5. `patternProperties` validates properties matching regex patterns
6. `propertyNames` validates that all property names match a schema
7. `minProperties` validates object has at least N properties
8. `maxProperties` validates object has at most N properties
9. `properties`, `patternProperties`, and `additionalProperties` work together correctly
10. Error messages indicate which property failed validation
11. Error `dataPath` correctly points to the failing property
12. Unit tests cover nested object validation (objects within objects)

### Story 2.4: Array Validation Keywords

**As a** developer,  
**I want** the validator to validate array structure and items,  
**so that** I can enforce array schemas with item constraints.

**Acceptance Criteria:**

1. `items` as object schema validates all array items against that schema
2. `items` as array of schemas validates each position against corresponding schema (tuple validation)
3. `additionalItems` validates items beyond the `items` array schemas
4. `additionalItems: false` rejects arrays longer than `items` array
5. `minItems` validates array has at least N items
6. `maxItems` validates array has at most N items
7. `uniqueItems: true` validates all array items are unique (deep comparison)
8. `contains` validates at least one item matches the schema (Draft 7+)
9. Error messages indicate which array index failed
10. Error `dataPath` correctly shows array index (e.g., `#/items/2`)
11. Unit tests cover arrays of objects and nested arrays
12. Unit tests cover `uniqueItems` with complex objects

### Story 2.5: Schema Combinators

**As a** developer,  
**I want** the validator to support allOf, anyOf, oneOf, and not combinators,  
**so that** I can create complex schemas combining multiple sub-schemas.

**Acceptance Criteria:**

1. `allOf` validates data matches ALL schemas in the array
2. `anyOf` validates data matches AT LEAST ONE schema in the array
3. `oneOf` validates data matches EXACTLY ONE schema in the array
4. `not` validates data does NOT match the specified schema
5. Combinators work with nested combinators (e.g., `allOf` containing `anyOf`)
6. Combinators work with all other keywords (type, properties, etc.)
7. `oneOf` correctly fails when data matches zero schemas
8. `oneOf` correctly fails when data matches more than one schema
9. Error messages for `anyOf`/`oneOf` indicate which sub-schemas were attempted
10. Error messages for `allOf` indicate which sub-schema failed
11. Unit tests cover complex nested combinator scenarios
12. Unit tests verify correct behavior when combinators reference `$ref`

### Story 2.6: Conditional Schema Keywords

**As a** developer,  
**I want** the validator to support if/then/else conditional validation,  
**so that** I can create schemas with conditional requirements.

**Acceptance Criteria:**

1. `if` schema evaluated first - if passes, `then` is applied; if fails, `else` is applied
2. `if/then` without `else` - validation passes if `if` fails (no `else` constraint)
3. `if/else` without `then` - validation passes if `if` succeeds (no `then` constraint)
4. `then` and `else` can be any valid schema (including combinators, refs)
5. Multiple `if/then/else` can be combined using `allOf`
6. Conditional schemas work with object property validation
7. Error messages indicate which branch (then/else) failed
8. `dependencies` keyword validates property dependencies (Draft 7 style)
9. Property dependencies: if property A exists, properties B and C must exist
10. Schema dependencies: if property A exists, additional schema must validate
11. Unit tests cover common conditional patterns (required-if, type-switching)
12. Unit tests cover nested conditionals

### Story 2.7: Schema References ($ref)

**As a** developer,  
**I want** the validator to resolve $ref references,  
**so that** I can reuse schema definitions and compose schemas from external sources.

**Acceptance Criteria:**

1. Internal `$ref` resolves references within same schema (e.g., `#/definitions/Address`)
2. Support for `definitions` (Draft 7) schema section for reusable schemas
3. Support for `$defs` (2020-12 alias) schema section
4. Relative `$ref` resolves correctly (e.g., `#/properties/shipping/properties/address`)
5. `$ref` can reference any schema location, not just definitions
6. Remote `$ref` fetches schema from HTTP/HTTPS URLs using `%Net.HttpRequest`
7. Fetched remote schemas are cached for the duration of the validation call
8. Circular reference protection: track visited `$ref` paths, use depth limit (configurable, default 100)
9. Circular reference detection returns clear error, not stack overflow
10. `$ref` overrides sibling keywords per JSON Schema spec (other keywords ignored)
11. Error messages for failed `$ref` indicate the reference path
12. Unit tests cover internal references, nested references, circular references
13. Unit tests cover remote references (may use mock or localhost test server)

### Story 2.8: JSON Schema Test Suite Compliance

**As a** developer,  
**I want** the validator to pass the official JSON Schema Test Suite,  
**so that** I have confidence in specification compliance.

**Acceptance Criteria:**

1. JSON Schema Test Suite Draft 7 tests downloaded/integrated into test structure
2. Test runner class executes all Draft 7 test files
3. Test results report shows pass/fail count per test file
4. All core vocabulary tests pass (type, enum, const, properties, items, etc.)
5. All combinator tests pass (allOf, anyOf, oneOf, not)
6. All conditional tests pass (if/then/else, dependencies)
7. All reference tests pass ($ref, definitions)
8. Optional format tests documented (pass/fail acceptable per spec)
9. Any failing tests documented with explanation (spec interpretation differences)
10. Test suite can be re-run as regression test
11. Compliance report generated showing overall pass rate (target: 100% required, optional documented)

---

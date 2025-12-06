/**
 * Default sample content for JSON and Schema editors
 * 
 * These samples demonstrate multiple data types (string, integer, array, object),
 * nested objects, required properties, format validation, and array items validation.
 * 
 * Source: docs/front-end-spec.md#11
 */

export const DEFAULT_JSON = `{
  "name": "John Doe",
  "age": 30,
  "email": "john.doe@example.com",
  "address": {
    "street": "123 Main St",
    "city": "Springfield",
    "zipCode": "12345"
  },
  "tags": ["developer", "iris"]
}`;

export const DEFAULT_SCHEMA = `{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1
    },
    "age": {
      "type": "integer",
      "minimum": 0
    },
    "email": {
      "type": "string",
      "format": "email"
    },
    "address": {
      "type": "object",
      "properties": {
        "street": { "type": "string" },
        "city": { "type": "string" },
        "zipCode": { "type": "string" }
      },
      "required": ["street", "city"]
    },
    "tags": {
      "type": "array",
      "items": { "type": "string" }
    }
  },
  "required": ["name", "email"]
}`;

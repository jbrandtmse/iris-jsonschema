/**
 * Validation error returned from JSON Schema validation
 */
export interface ValidationError {
  /** JSON Schema keyword that failed (e.g., "type", "required", "minLength") */
  keyword: string;
  /** JSON Pointer to error location in the data (e.g., "#/name", "#/items/0") */
  dataPath: string;
  /** JSON Pointer to schema location that caused the error */
  schemaPath: string;
  /** Human-readable error message */
  message: string;
}

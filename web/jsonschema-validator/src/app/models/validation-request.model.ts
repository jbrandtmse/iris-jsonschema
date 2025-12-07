/**
 * Request body for JSON Schema validation API
 */
export interface ValidationRequest {
  /** JSON data as string to validate */
  jsonInput: string;
  /** JSON Schema as string to validate against */
  schemaInput: string;
  /** Schema version to use for validation (default: 'draft-07') */
  schemaVersion?: 'draft-07' | '2020-12';
}

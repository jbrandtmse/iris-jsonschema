import { ValidationError } from './validation-error.model';

/**
 * Response body from JSON Schema validation API
 */
export interface ValidationResponse {
  /** Whether the JSON data is valid against the schema */
  valid: boolean;
  /** Array of validation errors (empty if valid) */
  errors: ValidationError[];
  /** Schema version used for validation */
  schemaVersion: string;
}

/**
 * Error response from API (HTTP 400/500)
 */
export interface ErrorResponse {
  error: {
    code: string;
    message: string;
  };
}

import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { firstValueFrom, catchError, throwError } from 'rxjs';
import { environment } from '../../environments/environment';
import { ValidationRequest } from '../models/validation-request.model';
import { ValidationResponse, ErrorResponse } from '../models/validation-response.model';

/**
 * Service for validating JSON data against JSON Schema via REST API
 */
@Injectable({ providedIn: 'root' })
export class ValidationService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiBaseUrl}/validate`;

  /**
   * Validate JSON data against a JSON Schema
   * @param jsonInput JSON data as string
   * @param schemaInput JSON Schema as string
   * @param schemaVersion Schema version ('draft-07' or '2020-12')
   * @returns Promise with validation response
   * @throws Error with user-friendly message on failure
   */
  async validate(
    jsonInput: string,
    schemaInput: string,
    schemaVersion: 'draft-07' | '2020-12' = 'draft-07'
  ): Promise<ValidationResponse> {
    const request: ValidationRequest = {
      jsonInput,
      schemaInput,
      schemaVersion
    };

    return firstValueFrom(
      this.http.post<ValidationResponse>(this.apiUrl, request).pipe(
        catchError((error: HttpErrorResponse) => {
          return throwError(() => this.transformError(error));
        })
      )
    );
  }

  /**
   * Transform HTTP errors to user-friendly messages
   */
  private transformError(error: HttpErrorResponse): Error {
    // Network error (no response)
    if (error.status === 0) {
      return new Error('Unable to connect to validation service. Please check your network connection and try again.');
    }

    // Timeout (status 0 with specific error message patterns)
    if (error.status === 0 && error.message?.includes('timeout')) {
      return new Error('Validation request timed out. Please try again.');
    }

    // Server returned error response
    if (error.status === 400) {
      const errorBody = error.error as ErrorResponse;
      if (errorBody?.error?.message) {
        return new Error(errorBody.error.message);
      }
      return new Error('Invalid request. Please check your JSON and schema syntax.');
    }

    if (error.status === 500) {
      return new Error('Server error occurred during validation. Please try again later.');
    }

    if (error.status === 503) {
      return new Error('Validation service is temporarily unavailable. Please try again later.');
    }

    // Generic error
    return new Error(`Validation failed: ${error.message || 'Unknown error'}`);
  }
}

import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { ValidationResponse } from '../../models/validation-response.model';
import { ValidationError } from '../../models/validation-error.model';
import { ErrorListComponent } from '../error-list/error-list.component';

/**
 * State of the validation result display
 */
export type ValidationState = 'ready' | 'loading' | 'valid' | 'invalid' | 'error';

/**
 * Component for displaying validation results
 * Supports multiple states: Ready, Loading, Valid, Invalid, Error
 */
@Component({
  selector: 'app-validation-result',
  standalone: true,
  imports: [CommonModule, MatIconModule, MatProgressSpinnerModule, MatButtonModule, ErrorListComponent],
  templateUrl: './validation-result.component.html',
  styleUrl: './validation-result.component.scss'
})
export class ValidationResultComponent {
  /** Current validation state */
  @Input() state: ValidationState = 'ready';

  /** Validation response (for valid/invalid states) */
  @Input() result: ValidationResponse | null = null;

  /** Error message (for error state) */
  @Input() errorMessage: string = '';

  /** Schema version used in validation */
  @Input() schemaVersion: string = 'draft-07';

  /** Emits when user clicks an error row */
  @Output() errorClick = new EventEmitter<ValidationError>();

  /** Emits when user clicks retry button */
  @Output() retry = new EventEmitter<void>();

  /**
   * Get the list of validation errors
   */
  get errors(): ValidationError[] {
    return this.result?.errors ?? [];
  }

  /**
   * Get error count for display
   */
  get errorCount(): number {
    return this.errors.length;
  }

  /**
   * Handle error row click
   */
  onErrorClick(error: ValidationError): void {
    this.errorClick.emit(error);
  }

  /**
   * Handle retry button click
   */
  onRetry(): void {
    this.retry.emit();
  }
}

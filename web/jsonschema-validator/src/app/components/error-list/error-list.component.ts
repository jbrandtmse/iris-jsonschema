import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ValidationError } from '../../models/validation-error.model';

/**
 * Component for displaying a list of validation errors in a table format
 */
@Component({
  selector: 'app-error-list',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './error-list.component.html',
  styleUrl: './error-list.component.scss'
})
export class ErrorListComponent {
  /** List of validation errors to display */
  @Input() errors: ValidationError[] = [];

  /** Emits when user clicks an error row */
  @Output() errorClick = new EventEmitter<ValidationError>();

  /**
   * Handle error row click
   */
  onErrorClick(error: ValidationError): void {
    this.errorClick.emit(error);
  }

  /**
   * Track function for ngFor optimization
   */
  trackError(index: number, error: ValidationError): string {
    return `${error.dataPath}-${error.keyword}-${index}`;
  }
}

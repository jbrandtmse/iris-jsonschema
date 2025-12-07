import { Component, signal, computed, inject, ViewChild, HostListener } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { AngularSplitModule } from 'angular-split';
import { JsonEditorComponent } from './components/json-editor/json-editor.component';
import { SchemaEditorComponent } from './components/schema-editor/schema-editor.component';
import { ValidationResultComponent, ValidationState } from './components/validation-result/validation-result.component';
import { SchemaVersionSelectorComponent } from './components/schema-version-selector/schema-version-selector.component';
import { ValidationService } from './services/validation.service';
import { ValidationResponse } from './models/validation-response.model';
import { ValidationError } from './models/validation-error.model';
import { DEFAULT_JSON, DEFAULT_SCHEMA } from './constants/default-content';

/**
 * App Component
 * 
 * Main application component that integrates JSON and Schema editors
 * with split-pane layout and validation functionality.
 * 
 * Source: docs/stories/3.3.story.md - Task 6, Task 9
 * Updated: docs/stories/3.4.story.md - Task 8
 */
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    MatToolbarModule, 
    MatButtonModule,
    MatIconModule,
    AngularSplitModule,
    JsonEditorComponent,
    SchemaEditorComponent,
    ValidationResultComponent,
    SchemaVersionSelectorComponent
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  private validationService = inject(ValidationService);
  
  @ViewChild('jsonEditor') jsonEditorRef!: JsonEditorComponent;
  
  title = 'JSONSchema Validator';
  
  /** State signal for JSON input content */
  jsonInput = signal<string>(DEFAULT_JSON);
  
  /** State signal for Schema input content */
  schemaInput = signal<string>(DEFAULT_SCHEMA);
  
  /** State signal for schema version selection */
  schemaVersion = signal<'draft-07' | '2020-12'>('draft-07');
  
  /** State signal for validation in progress */
  isValidating = signal<boolean>(false);
  
  /** State signal for validation result */
  validationResult = signal<ValidationResponse | null>(null);
  
  /** State signal for error message (API/network errors) */
  errorMessage = signal<string>('');
  
  /** Computed: current validation state for display */
  validationState = computed<ValidationState>(() => {
    if (this.isValidating()) return 'loading';
    if (this.errorMessage()) return 'error';
    if (this.validationResult()) {
      return this.validationResult()!.valid ? 'valid' : 'invalid';
    }
    return 'ready';
  });
  
  /** Computed: whether we have a validation result */
  hasResult = computed(() => this.validationResult() !== null);
  
  /** Computed: whether the validation result is valid */
  isValid = computed(() => this.validationResult()?.valid ?? false);
  
  /**
   * Keyboard shortcut: Ctrl+Enter triggers validation
   */
  @HostListener('document:keydown.control.enter', ['$event'])
  onCtrlEnter(event: KeyboardEvent): void {
    event.preventDefault();
    this.onValidate();
  }
  
  /**
   * Handle JSON editor content changes
   * Clears validation result when content changes
   * @param content New JSON content
   */
  onJsonChange(content: string): void {
    this.jsonInput.set(content);
    this.clearValidationResult();
  }
  
  /**
   * Handle Schema editor content changes
   * Clears validation result when content changes
   * @param content New Schema content
   */
  onSchemaChange(content: string): void {
    this.schemaInput.set(content);
    this.clearValidationResult();
  }
  
  /**
   * Handle schema version change from selector
   * @param version New schema version
   */
  onSchemaVersionChange(version: 'draft-07' | '2020-12'): void {
    this.schemaVersion.set(version);
    // Optionally clear result when version changes
    this.clearValidationResult();
  }
  
  /**
   * Clear validation result and error state
   */
  private clearValidationResult(): void {
    this.validationResult.set(null);
    this.errorMessage.set('');
  }
  
  /**
   * Trigger validation via API call
   */
  async onValidate(): Promise<void> {
    // Don't validate if already validating
    if (this.isValidating()) return;
    
    // Clear previous results and errors
    this.clearValidationResult();
    
    // Set loading state
    this.isValidating.set(true);
    
    try {
      const result = await this.validationService.validate(
        this.jsonInput(),
        this.schemaInput(),
        this.schemaVersion()
      );
      
      this.validationResult.set(result);
    } catch (error) {
      // Handle error - extract message from Error object
      const errorMsg = error instanceof Error ? error.message : 'An unexpected error occurred';
      this.errorMessage.set(errorMsg);
    } finally {
      this.isValidating.set(false);
    }
  }
  
  /**
   * Handle retry button click in error state
   */
  onRetry(): void {
    this.onValidate();
  }
  
  /**
   * Handle error click from validation result
   * Scrolls JSON editor to the error location
   * @param error The validation error clicked
   */
  onErrorClick(error: ValidationError): void {
    if (this.jsonEditorRef && error.dataPath) {
      this.jsonEditorRef.scrollToJsonPath(error.dataPath);
    }
  }
}

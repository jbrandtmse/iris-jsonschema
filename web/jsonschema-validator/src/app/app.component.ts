import { Component, signal } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { AngularSplitModule } from 'angular-split';
import { JsonEditorComponent } from './components/json-editor/json-editor.component';
import { SchemaEditorComponent } from './components/schema-editor/schema-editor.component';
import { DEFAULT_JSON, DEFAULT_SCHEMA } from './constants/default-content';

/**
 * App Component
 * 
 * Main application component that integrates JSON and Schema editors
 * with split-pane layout and validation functionality.
 * 
 * Source: docs/stories/3.3.story.md - Task 6, Task 9
 */
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    MatToolbarModule, 
    MatButtonModule, 
    AngularSplitModule,
    JsonEditorComponent,
    SchemaEditorComponent
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'JSONSchema Validator';
  
  /** State signal for JSON input content */
  jsonInput = signal<string>(DEFAULT_JSON);
  
  /** State signal for Schema input content */
  schemaInput = signal<string>(DEFAULT_SCHEMA);
  
  /** State signal for validation in progress */
  isValidating = signal<boolean>(false);
  
  /**
   * Handle JSON editor content changes
   * @param content New JSON content
   */
  onJsonChange(content: string): void {
    this.jsonInput.set(content);
  }
  
  /**
   * Handle Schema editor content changes
   * @param content New Schema content
   */
  onSchemaChange(content: string): void {
    this.schemaInput.set(content);
  }
  
  /**
   * Trigger validation - actual implementation in Story 3.4
   */
  onValidate(): void {
    console.log('Validate button clicked - implementation in Story 3.4');
    console.log('JSON Input:', this.jsonInput());
    console.log('Schema Input:', this.schemaInput());
  }
}

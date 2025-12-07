import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';

/**
 * Schema version options
 */
export interface SchemaVersionOption {
  value: 'draft-07' | '2020-12';
  label: string;
}

/**
 * Dropdown selector for JSON Schema version
 */
@Component({
  selector: 'app-schema-version-selector',
  standalone: true,
  imports: [CommonModule, FormsModule, MatSelectModule, MatFormFieldModule],
  templateUrl: './schema-version-selector.component.html',
  styleUrl: './schema-version-selector.component.scss'
})
export class SchemaVersionSelectorComponent {
  /** Currently selected schema version */
  @Input() selectedVersion: 'draft-07' | '2020-12' = 'draft-07';

  /** Emits when user selects a different version */
  @Output() versionChange = new EventEmitter<'draft-07' | '2020-12'>();

  /** Available schema version options */
  readonly schemaVersions: SchemaVersionOption[] = [
    { value: 'draft-07', label: 'Draft 7' },
    { value: '2020-12', label: '2020-12' }
  ];

  /**
   * Handle version selection change
   */
  onVersionChange(version: 'draft-07' | '2020-12'): void {
    this.versionChange.emit(version);
  }
}

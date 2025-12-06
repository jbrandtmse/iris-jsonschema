import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-schema-editor',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './schema-editor.component.html',
  styleUrl: './schema-editor.component.scss'
})
export class SchemaEditorComponent {
  schemaContent = '';
}

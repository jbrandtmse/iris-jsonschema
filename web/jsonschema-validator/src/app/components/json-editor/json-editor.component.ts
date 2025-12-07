import { 
  Component, 
  ElementRef, 
  ViewChild, 
  AfterViewInit, 
  OnDestroy, 
  Input, 
  Output, 
  EventEmitter,
  inject
} from '@angular/core';
import { EditorView } from 'codemirror';
import { EditorSelection } from '@codemirror/state';
import { EditorConfigService } from '../../services/editor-config.service';
import { DEFAULT_JSON } from '../../constants/default-content';

/**
 * JSON Editor Component
 * 
 * CodeMirror 6 based JSON editor with syntax highlighting, line numbers,
 * bracket matching, and JSON validation with error indicators.
 * 
 * Source: docs/stories/3.3.story.md - Task 3
 */
@Component({
  selector: 'app-json-editor',
  standalone: true,
  imports: [],
  templateUrl: './json-editor.component.html',
  styleUrl: './json-editor.component.scss'
})
export class JsonEditorComponent implements AfterViewInit, OnDestroy {
  @ViewChild('editorContainer', { static: true }) 
  editorContainer!: ElementRef<HTMLDivElement>;

  /** Initial content for the editor */
  @Input() initialContent: string = DEFAULT_JSON;

  /** Event emitted when editor content changes */
  @Output() contentChange = new EventEmitter<string>();

  private editorConfigService = inject(EditorConfigService);
  private editor: EditorView | null = null;
  private resizeObserver: ResizeObserver | null = null;

  ngAfterViewInit(): void {
    this.initializeEditor();
    this.setupResizeObserver();
  }

  ngOnDestroy(): void {
    this.cleanup();
  }

  /**
   * Initialize CodeMirror editor
   */
  private initializeEditor(): void {
    this.editor = this.editorConfigService.createEditor(
      this.editorContainer.nativeElement,
      this.initialContent,
      (content: string) => {
        this.contentChange.emit(content);
      }
    );
  }

  /**
   * Setup ResizeObserver for proper editor resize handling with split-pane
   */
  private setupResizeObserver(): void {
    this.resizeObserver = new ResizeObserver(() => {
      if (this.editor) {
        this.editor.requestMeasure();
      }
    });
    this.resizeObserver.observe(this.editorContainer.nativeElement);
  }

  /**
   * Cleanup editor and observers
   */
  private cleanup(): void {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
    if (this.editor) {
      this.editor.destroy();
      this.editor = null;
    }
  }

  /**
   * Get current editor content
   */
  getContent(): string {
    return this.editor 
      ? this.editorConfigService.getEditorContent(this.editor) 
      : this.initialContent;
  }

  /**
   * Set editor content programmatically
   */
  setContent(content: string): void {
    if (this.editor) {
      this.editorConfigService.setEditorContent(this.editor, content);
    }
  }

  /**
   * Get EditorView instance for testing purposes
   */
  getEditorView(): EditorView | null {
    return this.editor;
  }

  /**
   * Scroll to a specific line in the editor and highlight it briefly
   * @param lineNumber 1-based line number
   */
  scrollToLine(lineNumber: number): void {
    if (!this.editor) return;

    const doc = this.editor.state.doc;
    const maxLine = doc.lines;
    
    // Clamp line number to valid range
    const targetLine = Math.max(1, Math.min(lineNumber, maxLine));
    
    try {
      const line = doc.line(targetLine);
      
      // Set cursor at the beginning of the line and scroll into view
      this.editor.dispatch({
        selection: EditorSelection.single(line.from),
        scrollIntoView: true
      });

      // Apply a brief highlight effect
      this.highlightLine(line.from, line.to);
    } catch (e) {
      // If line access fails, just scroll to beginning
      console.warn('Failed to scroll to line', lineNumber, e);
    }
  }

  /**
   * Navigate to a JSON path location in the editor
   * @param jsonPath JSON Pointer format path (e.g., "#/name" or "/items/0")
   */
  scrollToJsonPath(jsonPath: string): void {
    const lineNumber = this.jsonPathToLine(jsonPath);
    if (lineNumber > 0) {
      this.scrollToLine(lineNumber);
    }
  }

  /**
   * Convert JSON Pointer path to approximate line number
   * Best-effort implementation - may not be exact for all cases
   * @param jsonPath JSON Pointer format (e.g., "#/name", "/items/0")
   * @returns 1-based line number, or 1 if not found
   */
  private jsonPathToLine(jsonPath: string): number {
    if (!this.editor) return 1;

    const content = this.getContent();
    
    // Remove leading # if present
    const path = jsonPath.replace(/^#/, '');
    
    // Handle root path
    if (path === '' || path === '/') {
      return 1;
    }

    // Parse path segments (e.g., "/items/0/name" -> ["items", "0", "name"])
    const segments = path.split('/').filter(s => s !== '');
    
    if (segments.length === 0) {
      return 1;
    }

    // Search for the property in the JSON content
    const lines = content.split('\n');
    const targetProperty = segments[segments.length - 1];
    
    // Try to find the line containing this property
    // This is a simplified approach - for complex nested structures
    // we'd need full JSON parsing
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // Check if this line contains the target property as a key
      const propertyPattern = new RegExp(`"${targetProperty}"\\s*:`);
      if (propertyPattern.test(line)) {
        return i + 1; // Convert to 1-based line number
      }
      
      // For array indices, look for array brackets
      if (!isNaN(Number(targetProperty))) {
        // This is an array index - harder to locate precisely
        // Just return the first match if found
        const arrayIndex = Number(targetProperty);
        if (line.includes('[') && arrayIndex === 0) {
          return i + 1;
        }
      }
    }

    // Fallback: return line 1
    return 1;
  }

  /**
   * Briefly highlight a range in the editor
   */
  private highlightLine(from: number, to: number): void {
    if (!this.editor) return;

    // Add a CSS class to the editor for the highlight effect
    const container = this.editorContainer.nativeElement;
    container.classList.add('line-highlight-active');
    
    // Remove the class after animation completes
    setTimeout(() => {
      container.classList.remove('line-highlight-active');
    }, 300);
  }
}

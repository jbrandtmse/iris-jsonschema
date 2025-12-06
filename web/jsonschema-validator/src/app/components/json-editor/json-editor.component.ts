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
}

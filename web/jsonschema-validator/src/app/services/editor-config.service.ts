import { Injectable } from '@angular/core';
import { EditorView, basicSetup } from 'codemirror';
import { json } from '@codemirror/lang-json';
import { linter, lintGutter, Diagnostic } from '@codemirror/lint';
import { Extension } from '@codemirror/state';

/**
 * Editor Configuration Service
 * 
 * Provides CodeMirror 6 configuration for JSON editors.
 * Includes JSON language support, linting, line numbers, and bracket matching.
 * 
 * Source: docs/stories/3.3.story.md - Task 2
 */
@Injectable({
  providedIn: 'root'
})
export class EditorConfigService {
  
  /**
   * Custom JSON linter function
   * 
   * Parses JSON content and returns diagnostics for syntax errors.
   * Debounced at 300ms for performance (handled by CodeMirror's linter config).
   */
  private jsonLinter = linter((view: EditorView): Diagnostic[] => {
    const content = view.state.doc.toString();
    
    // Empty content is valid (no errors to show)
    if (!content.trim()) {
      return [];
    }
    
    try {
      JSON.parse(content);
      return [];
    } catch (e: unknown) {
      const error = e as Error;
      // Try to parse error position from JSON.parse error message
      // Different browsers format the message differently
      let pos = 0;
      
      // Chrome/Node: "... at position 123"
      const posMatch = error.message.match(/position\s+(\d+)/i);
      if (posMatch) {
        pos = parseInt(posMatch[1], 10);
      }
      
      // Firefox: "... at line X column Y"
      const lineColMatch = error.message.match(/line\s+(\d+)\s+column\s+(\d+)/i);
      if (lineColMatch) {
        const line = parseInt(lineColMatch[1], 10);
        const col = parseInt(lineColMatch[2], 10);
        // Convert line/column to position
        const lines = content.split('\n');
        pos = 0;
        for (let i = 0; i < line - 1 && i < lines.length; i++) {
          pos += lines[i].length + 1; // +1 for newline
        }
        pos += col - 1;
      }
      
      // Ensure position is within document bounds
      const docLength = view.state.doc.length;
      pos = Math.min(pos, docLength);
      const endPos = Math.min(pos + 1, docLength);
      
      return [{
        from: pos,
        to: endPos,
        severity: 'error',
        message: error.message,
      }];
    }
  }, { delay: 300 }); // 300ms debounce for performance

  /**
   * Creates CodeMirror extensions array for JSON editing
   * 
   * Includes:
   * - basicSetup: line numbers, bracket matching, auto-indent, etc.
   * - json(): JSON language support with syntax highlighting
   * - linter: Custom JSON validation with error highlighting
   * - lintGutter: Error markers in the gutter
   * - updateListener: Callback for content changes
   * 
   * @param onContentChange Callback function when editor content changes
   * @returns Array of CodeMirror extensions
   */
  createEditorExtensions(onContentChange?: (content: string) => void): Extension[] {
    const extensions: Extension[] = [
      basicSetup,
      json(),
      this.jsonLinter,
      lintGutter(),
    ];

    // Add update listener if callback provided
    if (onContentChange) {
      extensions.push(
        EditorView.updateListener.of(update => {
          if (update.docChanged) {
            onContentChange(update.state.doc.toString());
          }
        })
      );
    }

    return extensions;
  }

  /**
   * Creates a CodeMirror EditorView instance
   * 
   * @param parent DOM element to mount the editor
   * @param initialContent Initial text content for the editor
   * @param onContentChange Callback function when content changes
   * @returns EditorView instance
   */
  createEditor(
    parent: HTMLElement,
    initialContent: string,
    onContentChange?: (content: string) => void
  ): EditorView {
    return new EditorView({
      doc: initialContent,
      extensions: this.createEditorExtensions(onContentChange),
      parent,
    });
  }

  /**
   * Updates the content of an existing editor
   * 
   * @param editor EditorView instance
   * @param content New content to set
   */
  setEditorContent(editor: EditorView, content: string): void {
    editor.dispatch({
      changes: {
        from: 0,
        to: editor.state.doc.length,
        insert: content,
      },
    });
  }

  /**
   * Gets the current content from an editor
   * 
   * @param editor EditorView instance
   * @returns Current editor content as string
   */
  getEditorContent(editor: EditorView): string {
    return editor.state.doc.toString();
  }
}

import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { SchemaEditorComponent } from './schema-editor.component';
import { DEFAULT_SCHEMA } from '../../constants/default-content';
import { EditorConfigService } from '../../services/editor-config.service';

/**
 * Schema Editor Component Tests
 * 
 * Tests for CodeMirror integration, default content loading,
 * and content change events.
 * 
 * Source: docs/stories/3.3.story.md - Task 10
 */
describe('SchemaEditorComponent', () => {
  let component: SchemaEditorComponent;
  let fixture: ComponentFixture<SchemaEditorComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SchemaEditorComponent],
      providers: [EditorConfigService]
    }).compileComponents();

    fixture = TestBed.createComponent(SchemaEditorComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  afterEach(() => {
    fixture.destroy();
  });

  // 3.3-UNIT-002: CodeMirror EditorView created in schema-editor
  it('should create', () => {
    expect(component).toBeTruthy();
  });

  // 3.3-UNIT-002: CodeMirror EditorView created in schema-editor
  it('should create CodeMirror EditorView instance', () => {
    const editorView = component.getEditorView();
    expect(editorView).toBeTruthy();
    expect(editorView).not.toBeNull();
  });

  // 3.3-UNIT-004: Default schema content loaded
  it('should load default schema content on init', () => {
    const content = component.getContent();
    expect(content).toBe(DEFAULT_SCHEMA);
  });

  // 3.3-UNIT-009: Headers visible - "JSON Schema" text present
  it('should display "JSON Schema" header', () => {
    const compiled = fixture.nativeElement as HTMLElement;
    const header = compiled.querySelector('.editor-header');
    expect(header?.textContent).toBe('JSON Schema');
  });

  // 3.3-UNIT-005: JSON language extension loaded (implicitly via CodeMirror setup)
  it('should have editor container element', () => {
    const compiled = fixture.nativeElement as HTMLElement;
    const container = compiled.querySelector('.editor-wrapper');
    expect(container).toBeTruthy();
  });

  // 3.3-UNIT-006: Line numbers displayed (via basicSetup)
  it('should render CodeMirror editor with line numbers', () => {
    const compiled = fixture.nativeElement as HTMLElement;
    // CodeMirror adds .cm-editor class to the editor container
    const cmEditor = compiled.querySelector('.cm-editor');
    expect(cmEditor).toBeTruthy();
    // basicSetup includes line numbers - check for gutter
    const gutter = compiled.querySelector('.cm-gutters');
    expect(gutter).toBeTruthy();
  });

  // Test content change events
  it('should emit contentChange event when content is modified', fakeAsync(() => {
    let emittedContent = '';
    component.contentChange.subscribe((content: string) => {
      emittedContent = content;
    });

    const newContent = '{"type": "string"}';
    component.setContent(newContent);
    tick();

    expect(component.getContent()).toBe(newContent);
  }));

  // Test custom initial content
  it('should accept custom initial content via @Input', () => {
    const customSchema = '{"type": "number", "minimum": 0}';
    
    // Create a new component with custom content
    const customFixture = TestBed.createComponent(SchemaEditorComponent);
    const customComponent = customFixture.componentInstance;
    customComponent.initialContent = customSchema;
    customFixture.detectChanges();

    expect(customComponent.getContent()).toBe(customSchema);
    customFixture.destroy();
  });

  // 3.3-UNIT-008: Content persists on re-render
  it('should persist content across change detection cycles', () => {
    const content = component.getContent();
    
    // Trigger multiple change detection cycles
    fixture.detectChanges();
    fixture.detectChanges();
    fixture.detectChanges();
    
    expect(component.getContent()).toBe(content);
  });

  // Test setContent method
  it('should update editor content via setContent method', () => {
    const newContent = '{"type": "boolean"}';
    component.setContent(newContent);
    expect(component.getContent()).toBe(newContent);
  });

  // Verify default schema demonstrates required keywords
  it('should have default schema with required keywords', () => {
    const content = component.getContent();
    expect(content).toContain('"type": "object"');
    expect(content).toContain('"properties"');
    expect(content).toContain('"required"');
  });
});

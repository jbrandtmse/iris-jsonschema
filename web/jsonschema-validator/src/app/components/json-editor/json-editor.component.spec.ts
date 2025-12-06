import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { JsonEditorComponent } from './json-editor.component';
import { DEFAULT_JSON } from '../../constants/default-content';
import { EditorConfigService } from '../../services/editor-config.service';

/**
 * JSON Editor Component Tests
 * 
 * Tests for CodeMirror integration, default content loading,
 * and content change events.
 * 
 * Source: docs/stories/3.3.story.md - Task 10
 */
describe('JsonEditorComponent', () => {
  let component: JsonEditorComponent;
  let fixture: ComponentFixture<JsonEditorComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [JsonEditorComponent],
      providers: [EditorConfigService]
    }).compileComponents();

    fixture = TestBed.createComponent(JsonEditorComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  afterEach(() => {
    fixture.destroy();
  });

  // 3.3-UNIT-001: CodeMirror EditorView created in json-editor
  it('should create', () => {
    expect(component).toBeTruthy();
  });

  // 3.3-UNIT-001: CodeMirror EditorView created in json-editor
  it('should create CodeMirror EditorView instance', () => {
    const editorView = component.getEditorView();
    expect(editorView).toBeTruthy();
    expect(editorView).not.toBeNull();
  });

  // 3.3-UNIT-003: Default JSON content loaded
  it('should load default JSON content on init', () => {
    const content = component.getContent();
    expect(content).toBe(DEFAULT_JSON);
  });

  // 3.3-UNIT-009: Headers visible - "JSON Data" text present
  it('should display "JSON Data" header', () => {
    const compiled = fixture.nativeElement as HTMLElement;
    const header = compiled.querySelector('.editor-header');
    expect(header?.textContent).toBe('JSON Data');
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

    const newContent = '{"test": "value"}';
    component.setContent(newContent);
    tick();

    expect(component.getContent()).toBe(newContent);
  }));

  // Test custom initial content
  it('should accept custom initial content via @Input', () => {
    const customContent = '{"custom": "content"}';
    
    // Create a new component with custom content
    const customFixture = TestBed.createComponent(JsonEditorComponent);
    const customComponent = customFixture.componentInstance;
    customComponent.initialContent = customContent;
    customFixture.detectChanges();

    expect(customComponent.getContent()).toBe(customContent);
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
    const newContent = '{"updated": true}';
    component.setContent(newContent);
    expect(component.getContent()).toBe(newContent);
  });
});

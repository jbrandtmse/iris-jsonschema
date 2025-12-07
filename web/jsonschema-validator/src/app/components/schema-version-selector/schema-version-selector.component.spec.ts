import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { SchemaVersionSelectorComponent } from './schema-version-selector.component';

describe('SchemaVersionSelectorComponent', () => {
  let component: SchemaVersionSelectorComponent;
  let fixture: ComponentFixture<SchemaVersionSelectorComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SchemaVersionSelectorComponent, NoopAnimationsModule]
    }).compileComponents();

    fixture = TestBed.createComponent(SchemaVersionSelectorComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should render dropdown', () => {
    const compiled = fixture.nativeElement as HTMLElement;
    const matSelect = compiled.querySelector('mat-select');
    expect(matSelect).toBeTruthy();
  });

  it('should have Draft 7 and 2020-12 options', () => {
    expect(component.schemaVersions.length).toBe(2);
    expect(component.schemaVersions[0].value).toBe('draft-07');
    expect(component.schemaVersions[0].label).toBe('Draft 7');
    expect(component.schemaVersions[1].value).toBe('2020-12');
    expect(component.schemaVersions[1].label).toBe('2020-12');
  });

  it('should default to draft-07', () => {
    expect(component.selectedVersion).toBe('draft-07');
  });

  it('should emit version change event', () => {
    spyOn(component.versionChange, 'emit');
    
    component.onVersionChange('2020-12');
    
    expect(component.versionChange.emit).toHaveBeenCalledWith('2020-12');
  });

  it('should accept selectedVersion input', () => {
    component.selectedVersion = '2020-12';
    fixture.detectChanges();
    
    expect(component.selectedVersion).toBe('2020-12');
  });
});

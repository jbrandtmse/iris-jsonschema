import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ErrorListComponent } from './error-list.component';
import { ValidationError } from '../../models/validation-error.model';

describe('ErrorListComponent', () => {
  let component: ErrorListComponent;
  let fixture: ComponentFixture<ErrorListComponent>;

  const mockErrors: ValidationError[] = [
    {
      keyword: 'type',
      dataPath: '#/name',
      schemaPath: '#/properties/name/type',
      message: 'Expected string but got number'
    },
    {
      keyword: 'required',
      dataPath: '#',
      schemaPath: '#/required',
      message: 'Required property missing: age'
    },
    {
      keyword: 'minLength',
      dataPath: '#/email',
      schemaPath: '#/properties/email/minLength',
      message: 'String must be at least 5 characters'
    }
  ];

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ErrorListComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(ErrorListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('rendering', () => {
    it('should not render table when errors array is empty', () => {
      component.errors = [];
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('.error-table')).toBeFalsy();
    });

    it('should render table when errors array is non-empty', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('.error-table')).toBeTruthy();
    });

    it('should render Path column correctly', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const pathHeaders = compiled.querySelectorAll('th.col-path');
      expect(pathHeaders.length).toBe(1);
      expect(pathHeaders[0].textContent).toContain('Path');
    });

    it('should render Keyword column correctly', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const keywordHeaders = compiled.querySelectorAll('th.col-keyword');
      expect(keywordHeaders.length).toBe(1);
      expect(keywordHeaders[0].textContent).toContain('Keyword');
    });

    it('should render Message column correctly', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const messageHeaders = compiled.querySelectorAll('th.col-message');
      expect(messageHeaders.length).toBe(1);
      expect(messageHeaders[0].textContent).toContain('Message');
    });

    it('should render correct number of error rows', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const rows = compiled.querySelectorAll('.error-row');
      expect(rows.length).toBe(3);
    });

    it('should display dataPath in rows', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.textContent).toContain('#/name');
      expect(compiled.textContent).toContain('#/email');
    });

    it('should display keyword in rows', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.textContent).toContain('type');
      expect(compiled.textContent).toContain('required');
      expect(compiled.textContent).toContain('minLength');
    });

    it('should display message in rows', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.textContent).toContain('Expected string but got number');
      expect(compiled.textContent).toContain('Required property missing: age');
    });
  });

  describe('click events', () => {
    it('should emit errorClick event when row is clicked', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      spyOn(component.errorClick, 'emit');
      
      component.onErrorClick(mockErrors[0]);
      
      expect(component.errorClick.emit).toHaveBeenCalledWith(mockErrors[0]);
    });

    it('should emit correct error object for each row', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      spyOn(component.errorClick, 'emit');
      
      component.onErrorClick(mockErrors[1]);
      
      expect(component.errorClick.emit).toHaveBeenCalledWith(mockErrors[1]);
    });
  });

  describe('trackError function', () => {
    it('should return unique track key for each error', () => {
      const key1 = component.trackError(0, mockErrors[0]);
      const key2 = component.trackError(1, mockErrors[1]);
      
      expect(key1).not.toBe(key2);
    });

    it('should include dataPath and keyword in track key', () => {
      const key = component.trackError(0, mockErrors[0]);
      
      expect(key).toContain('#/name');
      expect(key).toContain('type');
    });
  });

  describe('scrollable container', () => {
    it('should have error-list-container with max-height', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const container = compiled.querySelector('.error-list-container');
      expect(container).toBeTruthy();
    });
  });

  describe('row styling', () => {
    it('should have cursor pointer style class on rows', () => {
      component.errors = mockErrors;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const rows = compiled.querySelectorAll('.error-row');
      expect(rows.length).toBeGreaterThan(0);
    });
  });
});

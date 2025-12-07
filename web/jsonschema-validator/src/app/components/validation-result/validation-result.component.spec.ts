import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { ValidationResultComponent } from './validation-result.component';
import { ValidationResponse } from '../../models/validation-response.model';

describe('ValidationResultComponent', () => {
  let component: ValidationResultComponent;
  let fixture: ComponentFixture<ValidationResultComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ValidationResultComponent, NoopAnimationsModule]
    }).compileComponents();

    fixture = TestBed.createComponent(ValidationResultComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('ready state', () => {
    it('should show ready message when state is ready', () => {
      component.state = 'ready';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('.result-message.ready')).toBeTruthy();
      expect(compiled.textContent).toContain('Ready to validate');
    });
  });

  describe('loading state', () => {
    it('should show spinner when state is loading', () => {
      component.state = 'loading';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('.result-message.loading')).toBeTruthy();
      expect(compiled.querySelector('mat-spinner')).toBeTruthy();
      expect(compiled.textContent).toContain('Validating...');
    });
  });

  describe('valid state', () => {
    it('should show green badge when valid', () => {
      component.state = 'valid';
      component.schemaVersion = 'draft-07';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('.result-badge.valid')).toBeTruthy();
      expect(compiled.textContent).toContain('✓ Valid');
    });

    it('should show check_circle icon for valid state', () => {
      component.state = 'valid';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const icon = compiled.querySelector('.result-badge.valid mat-icon');
      expect(icon).toBeTruthy();
      expect(icon?.textContent).toContain('check_circle');
    });

    it('should display schema version info', () => {
      component.state = 'valid';
      component.schemaVersion = 'draft-07';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.textContent).toContain('draft-07');
    });
  });

  describe('invalid state', () => {
    const mockResult: ValidationResponse = {
      valid: false,
      errors: [
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
        }
      ],
      schemaVersion: 'draft-07'
    };

    it('should show red badge when invalid', () => {
      component.state = 'invalid';
      component.result = mockResult;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('.result-badge.invalid')).toBeTruthy();
      expect(compiled.textContent).toContain('✗ Invalid');
    });

    it('should show cancel icon for invalid state', () => {
      component.state = 'invalid';
      component.result = mockResult;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const icon = compiled.querySelector('.result-badge.invalid mat-icon');
      expect(icon).toBeTruthy();
      expect(icon?.textContent).toContain('cancel');
    });

    it('should display error count', () => {
      component.state = 'invalid';
      component.result = mockResult;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.textContent).toContain('2 errors');
    });

    it('should display singular "error" for single error', () => {
      component.state = 'invalid';
      component.result = {
        valid: false,
        errors: [mockResult.errors[0]],
        schemaVersion: 'draft-07'
      };
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.textContent).toContain('1 error');
    });

    it('should render error list component', () => {
      component.state = 'invalid';
      component.result = mockResult;
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('app-error-list')).toBeTruthy();
    });
  });

  describe('error state (API/network)', () => {
    it('should show warning badge when state is error', () => {
      component.state = 'error';
      component.errorMessage = 'Unable to connect';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.querySelector('.result-badge.error')).toBeTruthy();
    });

    it('should show warning icon for error state', () => {
      component.state = 'error';
      component.errorMessage = 'Unable to connect';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const icon = compiled.querySelector('.result-badge.error mat-icon');
      expect(icon).toBeTruthy();
      expect(icon?.textContent).toContain('warning');
    });

    it('should display error message', () => {
      component.state = 'error';
      component.errorMessage = 'Network connection failed';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      expect(compiled.textContent).toContain('Network connection failed');
    });

    it('should show retry button', () => {
      component.state = 'error';
      component.errorMessage = 'Error occurred';
      fixture.detectChanges();

      const compiled = fixture.nativeElement as HTMLElement;
      const retryButton = compiled.querySelector('button');
      expect(retryButton).toBeTruthy();
      expect(retryButton?.textContent).toContain('Retry');
    });

    it('should emit retry event when button clicked', () => {
      component.state = 'error';
      component.errorMessage = 'Error occurred';
      fixture.detectChanges();

      spyOn(component.retry, 'emit');
      
      component.onRetry();
      
      expect(component.retry.emit).toHaveBeenCalled();
    });
  });

  describe('error click handling', () => {
    it('should emit errorClick event when error row clicked', () => {
      const mockError = {
        keyword: 'type',
        dataPath: '#/name',
        schemaPath: '#/properties/name/type',
        message: 'Type error'
      };

      spyOn(component.errorClick, 'emit');
      
      component.onErrorClick(mockError);
      
      expect(component.errorClick.emit).toHaveBeenCalledWith(mockError);
    });
  });

  describe('computed properties', () => {
    it('should return empty errors array when result is null', () => {
      component.result = null;
      expect(component.errors).toEqual([]);
    });

    it('should return errors from result', () => {
      component.result = {
        valid: false,
        errors: [{ keyword: 'type', dataPath: '#', schemaPath: '#', message: 'Error' }],
        schemaVersion: 'draft-07'
      };
      expect(component.errors.length).toBe(1);
    });

    it('should return correct error count', () => {
      component.result = {
        valid: false,
        errors: [
          { keyword: 'type', dataPath: '#', schemaPath: '#', message: 'Error 1' },
          { keyword: 'required', dataPath: '#', schemaPath: '#', message: 'Error 2' }
        ],
        schemaVersion: 'draft-07'
      };
      expect(component.errorCount).toBe(2);
    });
  });
});

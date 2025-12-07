import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { ValidationService } from './validation.service';
import { ValidationResponse } from '../models/validation-response.model';
import { environment } from '../../environments/environment';

describe('ValidationService', () => {
  let service: ValidationService;
  let httpMock: HttpTestingController;
  const apiUrl = `${environment.apiBaseUrl}/validate`;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [ValidationService]
    });
    service = TestBed.inject(ValidationService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  describe('validate()', () => {
    const mockJsonInput = '{"name": "test"}';
    const mockSchemaInput = '{"type": "object"}';

    it('should send correct HTTP method (POST)', async () => {
      const mockResponse: ValidationResponse = {
        valid: true,
        errors: [],
        schemaVersion: 'draft-07'
      };

      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.method).toBe('POST');
      req.flush(mockResponse);

      const result = await validatePromise;
      expect(result).toEqual(mockResponse);
    });

    it('should send to correct URL (/api/jsonschema/validate)', async () => {
      const mockResponse: ValidationResponse = {
        valid: true,
        errors: [],
        schemaVersion: 'draft-07'
      };

      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.url).toBe(apiUrl);
      req.flush(mockResponse);

      await validatePromise;
    });

    it('should send correct request body structure', async () => {
      const mockResponse: ValidationResponse = {
        valid: true,
        errors: [],
        schemaVersion: 'draft-07'
      };

      const validatePromise = service.validate(mockJsonInput, mockSchemaInput, 'draft-07');

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.body).toEqual({
        jsonInput: mockJsonInput,
        schemaInput: mockSchemaInput,
        schemaVersion: 'draft-07'
      });
      req.flush(mockResponse);

      await validatePromise;
    });

    it('should return typed ValidationResponse on success', async () => {
      const mockResponse: ValidationResponse = {
        valid: false,
        errors: [
          {
            keyword: 'type',
            dataPath: '#/name',
            schemaPath: '#/properties/name/type',
            message: 'Expected string but got number'
          }
        ],
        schemaVersion: 'draft-07'
      };

      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      req.flush(mockResponse);

      const result = await validatePromise;
      expect(result.valid).toBe(false);
      expect(result.errors.length).toBe(1);
      expect(result.errors[0].keyword).toBe('type');
    });

    it('should use default schema version draft-07 when not specified', async () => {
      const mockResponse: ValidationResponse = {
        valid: true,
        errors: [],
        schemaVersion: 'draft-07'
      };

      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.body.schemaVersion).toBe('draft-07');
      req.flush(mockResponse);

      await validatePromise;
    });

    it('should pass 2020-12 schema version when specified', async () => {
      const mockResponse: ValidationResponse = {
        valid: true,
        errors: [],
        schemaVersion: '2020-12'
      };

      const validatePromise = service.validate(mockJsonInput, mockSchemaInput, '2020-12');

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.body.schemaVersion).toBe('2020-12');
      req.flush(mockResponse);

      await validatePromise;
    });
  });

  describe('error handling', () => {
    const mockJsonInput = '{"name": "test"}';
    const mockSchemaInput = '{"type": "object"}';

    it('should transform HTTP 400 to user-friendly message', async () => {
      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      req.flush(
        { error: { code: 'INVALID_JSON', message: 'Invalid JSON syntax' } },
        { status: 400, statusText: 'Bad Request' }
      );

      await expectAsync(validatePromise).toBeRejectedWithError('Invalid JSON syntax');
    });

    it('should provide generic message for 400 without error body', async () => {
      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      req.flush(null, { status: 400, statusText: 'Bad Request' });

      await expectAsync(validatePromise).toBeRejectedWithError(
        'Invalid request. Please check your JSON and schema syntax.'
      );
    });

    it('should transform HTTP 500 to user-friendly message', async () => {
      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      req.flush(null, { status: 500, statusText: 'Internal Server Error' });

      await expectAsync(validatePromise).toBeRejectedWithError(
        'Server error occurred during validation. Please try again later.'
      );
    });

    it('should transform HTTP 503 to user-friendly message', async () => {
      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      req.flush(null, { status: 503, statusText: 'Service Unavailable' });

      await expectAsync(validatePromise).toBeRejectedWithError(
        'Validation service is temporarily unavailable. Please try again later.'
      );
    });

    it('should handle network errors (status 0)', async () => {
      const validatePromise = service.validate(mockJsonInput, mockSchemaInput);

      const req = httpMock.expectOne(apiUrl);
      req.error(new ProgressEvent('error'), { status: 0, statusText: '' });

      await expectAsync(validatePromise).toBeRejectedWithError(
        'Unable to connect to validation service. Please check your network connection and try again.'
      );
    });
  });
});

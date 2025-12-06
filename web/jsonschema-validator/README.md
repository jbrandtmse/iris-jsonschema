# JSONSchema Validator - Web Application

A modern Angular-based web application for validating JSON data against JSON Schema specifications.

## Project Overview

This web application provides a user-friendly interface for testing and validating JSON data against JSON Schema definitions. It features a split-pane editor layout where users can input JSON data on the left and JSON Schema on the right, then validate with a single click.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** - Version 18.x, 20.x, or 22.x LTS
- **npm** - Version 10.x or higher (comes with Node.js)
- **Angular CLI** - Version 18.x

### Installing Angular CLI

```bash
npm install -g @angular/cli@18
```

### Verify Installation

```bash
node --version    # Should show v18.x, v20.x, or v22.x
npm --version     # Should show 10.x+
ng version        # Should show Angular CLI 18.x
```

## Installation

1. Navigate to the web application directory:
   ```bash
   cd web/jsonschema-validator
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

## Development Server

Start the development server:

```bash
ng serve
```

Navigate to `http://localhost:4200/`. The application will automatically reload if you change any of the source files.

### Development Server with Specific Port

```bash
ng serve --port 4201
```

## Production Build

Build the application for production:

```bash
ng build
```

The build artifacts will be stored in the `dist/jsonschema-validator/` directory.

### Production Build with Source Maps

```bash
ng build --source-map
```

## Running Tests

### Unit Tests

Execute unit tests via Karma:

```bash
ng test
```

### Unit Tests with Code Coverage

```bash
ng test --no-watch --code-coverage
```

Coverage reports are generated in the `coverage/` directory.

### Single Run (CI/CD)

```bash
ng test --no-watch --browsers=ChromeHeadless
```

## Folder Structure

```
jsonschema-validator/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── json-editor/        # JSON input editor
│   │   │   ├── schema-editor/      # Schema input editor
│   │   │   └── validation-result/  # Validation results display
│   │   ├── services/               # Angular services (future)
│   │   ├── models/                 # TypeScript interfaces (future)
│   │   ├── app.component.*         # Main application component
│   │   └── app.config.ts           # Application configuration
│   ├── environments/
│   │   ├── environment.ts          # Development environment
│   │   └── environment.prod.ts     # Production environment
│   ├── styles.scss                 # Global styles
│   └── index.html                  # Main HTML file
├── angular.json                    # Angular CLI configuration
├── package.json                    # NPM dependencies
├── tsconfig.json                   # TypeScript configuration
└── README.md                       # This file
```

## Key Features

- **Split-Pane Layout**: Resizable dual-editor interface for JSON and Schema input
- **Angular Material UI**: Professional Deep Purple/Amber theme
- **Responsive Design**: Adapts to different screen sizes (stacks vertically on mobile)
- **Monaco Editor Integration**: Coming in future story (currently uses textarea placeholders)

## Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Angular | 18.x LTS | Frontend framework |
| Angular Material | 18.x | UI component library |
| TypeScript | 5.x | Type-safe JavaScript |
| angular-split | 17.x | Split-pane layout |
| SCSS | - | Styling |
| Jasmine/Karma | Latest | Unit testing |

## API Integration

The application is configured to connect to the IRIS backend REST API:

- **Development**: `http://localhost:52773/api/jsonschema`
- **Production**: `/api/jsonschema`

API endpoint: `POST /api/jsonschema/validate`

## Environment Configuration

Environment files are located in `src/environments/`:

- `environment.ts` - Development configuration
- `environment.prod.ts` - Production configuration

## Contributing

1. Follow the project's coding standards (see `docs/architecture/15-coding-standards.md`)
2. Write unit tests for new features
3. Ensure all tests pass before submitting changes
4. Follow Angular best practices for standalone components

## Related Documentation

- [Architecture Documentation](../../docs/architecture/8-frontend-architecture.md)
- [Coding Standards](../../docs/architecture/15-coding-standards.md)
- [API Specification](../../docs/architecture/5-api-specification.md)

# Angular UI + InterSystems IRIS Integration – Coding Agent Instructions

## 1. Purpose and Scope

This document tells a coding agent **exactly what it needs to know and do** to implement a simple but realistic **Angular UI** on top of an **InterSystems IRIS ObjectScript backend** within this repository.

The goal is to:

- Add a **JSON REST API** implemented in **ObjectScript on IRIS**.
- Add a **Single Page Application (SPA) in Angular** that consumes that API.
- Respect the project’s **coding standards**, **security rules**, and **file organization** (see root `.clinerules` and memory-bank docs).

This document **does not** ask you to implement everything now; it defines **how you should implement it when requested**.


## 2. High-Level Architecture

### 2.1 Overall pattern

- **Backend (IRIS / ObjectScript)**  
  - Domain classes (e.g., `Patient`, `Widget`) stored in IRIS.
  - REST API using `%CSP.REST` (or `%REST` if future stories require OpenAPI).
  - JSON in/out for all endpoints.

- **Frontend (Angular SPA)**  
  - TypeScript + Angular CLI application.
  - Uses Angular `HttpClient` to call IRIS REST endpoints.
  - Runs with:
    - `ng serve` in development, and
    - a built `/dist` bundle for deployment.

- **Deployment patterns** (both should be supported in design; pick the one the user requests when actually implementing):
  1. **Same origin:** Angular static files served by IRIS under a CSP application (e.g. `/ui`), REST under `/api`. No CORS required.
  2. **Split origin:** Angular hosted separately (e.g. Nginx, Node, CDN) and calls IRIS REST via HTTPS. CORS and/or reverse proxy required.


## 3. Repository Layout Expectations

When implementing, follow these layout conventions unless the user explicitly chooses alternatives.

### 3.1 Backend ObjectScript code location

- Place new **backend classes** under `src/` in a new package tree that follows `.clinerules` naming:

  - **Package prefix:** `Cloud.Deployment.*`
  - Recommended structure for this UI/API feature:

    - `src/Cloud/Deployment/UI/`  
      - `Domain/` – persistent domain model classes  
      - `REST/` – REST dispatch / controller classes  
      - `Config/` – any helper/config classes if needed later

  Examples:

  - `src/Cloud/Deployment/UI/Domain/Patient.cls`
  - `src/Cloud/Deployment/UI/REST/PatientREST.cls`

- Respect ObjectScript coding conventions from `.clinerules`:
  - Class names: `Cloud.Deployment.Xxx`.
  - 4-space indentation, K&R braces, etc.
  - Error handling with `$$$ThrowStatus($$$ERROR($$$GeneralError, ...))` in new logic.
  - Include the **required copyright header** at the top of any new class files, updated with current date and developer name.

### 3.2 Angular frontend location

- Create a dedicated directory for the Angular project at repo root:

  ```text
  /Users/jbrandt/cloud-deployment
  └── ui/
      └── angular-client/  (Angular workspace root)
  ```

- All Angular code, configs and build artifacts belong under `ui/angular-client/`.
- Do **not** scatter Angular files into existing `src/`, `setup/`, `software/`, etc.

### 3.3 Documentation location

- This file: `documents/angular-instructions.md`.
- Any additional Angular- or UI-related docs should live under `documents/` (for cloud-deployment) or the appropriate memory-bank for long-lived design decisions if requested.

## 4. Backend Implementation Plan (IRIS / ObjectScript)

This section defines what you should implement on the IRIS side when instructed.

### 4.1 Prerequisites and assumptions

- There is an IRIS instance available (often installed via this repo’s `setup/` scripts).
- There is a namespace (e.g., `HCUSTOM`, `USER`, or a dedicated UI namespace).  
  **Do not invent mappings**; when implementing, either:
  - Ask the user which namespace to target, or
  - Use the namespace explicitly provided in the task.

- Source-mapping between this repo’s `src/` tree and the IRIS namespace may be managed externally; do **not** change mapping rules unless asked. You **can**:
  - Create new classes under `src/Cloud/Deployment/...`,
  - Compile them into the chosen namespace using either:
    - `iris-session-mcp` tools, or
    - the normal VS Code ObjectScript extension workflow.

### 4.2 Domain model classes

When asked to implement a concrete use case (e.g., basic `Patient` list/edit):

1. For each entity that must be exposed to the Angular UI, create a `%Persistent` + `%JSON.Adaptor` class:

   ```objectscript
   Class Cloud.Deployment.UI.Domain.Patient Extends (%Persistent, %JSON.Adaptor)
   {
       Property Name   As %String;
       Property DOB    As %Date;
       Property Gender As %String;
   }
   ```

2. Follow project rules:
   - Add the standard copyright header.
   - Use 4-space indentation, no tabs.
   - Avoid hardcoded configuration (use utility/config classes instead if needed).

3. If relationships are needed (e.g., `Patient` ↔ `Address`), model them with foreign keys / references consistent with IRIS best practices. Expose only what Angular needs for the current user story.

### 4.3 REST dispatch class

Create a REST controller class per logical API area. For a simple example, a `Patient` REST API:

```objectscript
Class Cloud.Deployment.UI.REST.PatientREST Extends %CSP.REST
{

XData UrlMap
{
<Routes>
  <Route Url="/patients"      Method="GET"    Call="ListPatients"/>
  <Route Url="/patients/:id"  Method="GET"    Call="GetPatient"/>
  <Route Url="/patients"      Method="POST"   Call="CreatePatient"/>
  <Route Url="/patients/:id"  Method="PUT"    Call="UpdatePatient"/>
  <Route Url="/patients/:id"  Method="DELETE" Call="DeletePatient"/>
</Routes>
}

ClassMethod ListPatients() As %Status
{
    Set tSC = $$$OK
    Try {
        Set arr = ##class(%DynamicArray).%New()
        Set rs = ##class(%ResultSet).%New("%DynamicQuery:SQL")
        Do rs.Prepare("SELECT ID FROM Cloud_Deployment_UI.Domain_Patient")
        Do rs.Execute()
        While rs.Next() {
            Set p = ##class(Cloud.Deployment.UI.Domain.Patient).%OpenId(rs.Get("ID"))
            Do arr.%Push(p)
        }
        Do %response.SetContentType("application/json")
        Do %response.Write(arr.%ToJSON())
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

// Implement GetPatient, CreatePatient, UpdatePatient, DeletePatient using:
// - %request.Content for JSON body
// - %DynamicObject/%DynamicArray for JSON parsing/creation
// - Proper status codes and error handling
}
```

Key rules for handler methods:

- Always set `Content-Type` correctly (`application/json` for JSON).
- Return valid HTTP status codes:
  - `200 OK` for success.
  - `201 Created` for resource creation.
  - `400` for invalid input.
  - `404` when entity not found.
  - `500` for unexpected errors.
- Use project-standard error handling macros (`$$$ThrowStatus`, `$$$ERROR`) in new utility code; REST handlers may translate those into JSON error bodies.

### 4.4 CORS handling

When Angular is on a different origin (e.g. `http://localhost:4200` in dev), you must enable CORS in the REST dispatch class:

```objectscript
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pHandled As %Boolean) As %Status
{
    // Allowed origin MUST be explicitly configured; do not use "*" in production
    Set allowedOrigin = "http://localhost:4200"  // dev default; make configurable for prod

    Do %response.SetHeader("Access-Control-Allow-Origin", allowedOrigin)
    Do %response.SetHeader("Access-Control-Allow-Credentials", "true")
    Do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    Do %response.SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")

    If $ZConvert(pMethod,"U")="OPTIONS" {
        Set %response.Status = 204
        Set pHandled = 1
    }

    Quit $$$OK
}
```

Guidelines:

- In **development**, `allowedOrigin` may be `http://localhost:4200` for Angular dev server.
- In **production**, restrict this to actual UI origin(s); **never** use `"*"` in this project unless an explicit task demands it.

### 4.5 Authentication and authorization (when required)

If/when a story requires security:

- Prefer **token‑based or IRIS session** authentication:
  - Session: rely on IRIS login + cookies (`withCredentials: true` in Angular).
  - Token/JWT: implement a `/login` or `/auth` endpoint that returns a token; validate the token on each API call in `OnPreDispatch` or a shared validation routine.

- Do **not**:
  - Hardcode credentials in source.
  - Log secrets.
  - Bypass existing HealthShare / IRIS security models without explicit design sign‑off.

### 4.6 Web application registration

You cannot change Management Portal settings purely via file edits, but:

- Document in comments and/or docs what web application is required, e.g.:

  - REST API app: `/ui/api` dispatching to `Cloud.Deployment.UI.REST.PatientREST`.
  - (optional) UI app: `/ui` for serving Angular static assets if using IRIS as host.

- If IRIS automation via `iris-session-mcp` is explicitly requested:
  - Use its tools to run ObjectScript commands that create/update `%SYS` web application definitions.
  - Keep those scripts clearly separated (e.g., in a dedicated config/automation class).

## 5. Frontend Implementation Plan (Angular)

### 5.1 Angular project creation

When instructed to implement the Angular UI:

1. Ensure Node.js LTS and Angular CLI are available.
2. From repo root (`/Users/jbrandt/cloud-deployment`):

   ```bash
   mkdir -p ui
   cd ui
   ng new angular-client --routing --style=scss
   ```

   - Use `--routing` to enable Angular Router for views.
   - Use `scss` unless the user/stories specify otherwise.

3. Commit structure:

   ```text
   ui/angular-client/
     src/
     angular.json
     package.json
     tsconfig.json
     ...
   ```

### 5.2 Environment configuration

Configure API base URLs as Angular environments:

- In `src/environments/environment.ts` (development):

  ```ts
  export const environment = {
    production: false,
    apiBaseUrl: 'http://localhost:52773/ui/api'  // or /myapp/api: adjust when REST URL is known
  };
  ```

- In `src/environments/environment.prod.ts` (production):

  ```ts
  export const environment = {
    production: true,
    apiBaseUrl: '/ui/api'  // assumes same-origin deployment behind reverse proxy or IRIS
  };
  ```

When implementing, **align this `apiBaseUrl` with the actual REST path** configured in IRIS.

### 5.3 Angular models

For each IRIS domain class you expose, define a TypeScript model that matches the JSON shape:

```ts
// src/app/models/patient.ts
export interface Patient {
  id?: number;
  name: string;
  dob: string;      // ISO string from IRIS; you may convert to Date in the UI
  gender: string;
}
```

Keep models:

- Simple,
- 1:1 with backend JSON,
- Located under `src/app/models/`.

### 5.4 Angular services for API calls

Generate a dedicated service for each logical API area:

```bash
cd ui/angular-client
ng generate service services/patient
```

Example implementation:

```ts
// src/app/services/patient.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { Patient } from '../models/patient';

@Injectable({ providedIn: 'root' })
export class PatientService {
  private apiBase = environment.apiBaseUrl;

  constructor(private http: HttpClient) {}

  list(): Observable<Patient[]> {
    return this.http.get<Patient[]>(`${this.apiBase}/patients`);
  }

  get(id: number): Observable<Patient> {
    return this.http.get<Patient>(`${this.apiBase}/patients/${id}`);
  }

  create(p: Patient): Observable<Patient> {
    return this.http.post<Patient>(`${this.apiBase}/patients`, p);
  }

  update(id: number, p: Patient): Observable<Patient> {
    return this.http.put<Patient>(`${this.apiBase}/patients/${id}`, p);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiBase}/patients/${id}`);
  }
}
```

Notes:

- Always derive `apiBase` from `environment.apiBaseUrl`, not from hardcoded strings.
- For authenticated requests:
  - Attach tokens via Angular `HttpInterceptor` if needed (implemented only when user/stories require).

### 5.5 Angular components and routing

1. Generate components for list/detail views (or others as specified in stories):

   ```bash
   ng generate component patients/patient-list
   ng generate component patients/patient-detail
   ```

2. Wire components to services:

   ```ts
   // src/app/patients/patient-list/patient-list.component.ts
   import { Component, OnInit } from '@angular/core';
   import { PatientService } from '../../services/patient.service';
   import { Patient } from '../../models/patient';

   @Component({
     selector: 'app-patient-list',
     templateUrl: './patient-list.component.html'
   })
   export class PatientListComponent implements OnInit {
     patients: Patient[] = [];

     constructor(private patientService: PatientService) {}

     ngOnInit(): void {
       this.patientService.list().subscribe(p => this.patients = p);
     }
   }
   ```

3. Update routing in `app-routing.module.ts` as needed, e.g.:

   ```ts
   const routes: Routes = [
     { path: 'patients', component: PatientListComponent },
     { path: '', redirectTo: '/patients', pathMatch: 'full' }
   ];
   ```

### 5.6 Dev server & proxy (optional but recommended)

To avoid CORS complexity in development, configure a proxy:

1. In `ui/angular-client`, create `proxy.conf.json`:

   ```json
   {
     "/ui/api": {
       "target": "http://localhost:52773",
       "secure": false,
       "changeOrigin": true
     }
   }
   ```

2. Update `package.json` scripts:

   ```json
   "scripts": {
     "start": "ng serve --proxy-config proxy.conf.json",
     ...
   }
   ```

3. Ensure `environment.apiBaseUrl` is `/ui/api` in dev, so all calls route through the dev server to IRIS.

---

## 6. Deployment Patterns for This Project

When asked to integrate deployment, you must respect this project’s **Cloud Deployment Patterns** (IaC, tagging, least privilege, etc.). At a high level:

### 6.1 Option A – IRIS serves Angular

- Build Angular:

  ```bash
  cd ui/angular-client
  ng build --configuration production
  ```

  Produces `dist/angular-client/`.

- Copy build output into a directory served by IRIS/CSP (path will depend on system installation).
- Configure a CSP web application (e.g. `/ui`) to serve static SPA files.
- Set `environment.prod.apiBaseUrl` to `/ui/api` (or equivalent) so SPA and API share an origin.

### 6.2 Option B – Separate web server

- Build Angular as above.
- Deploy the `dist` folder to a dedicated web server (Nginx, Apache, CDN).
- Configure:
  - Angular `environment.prod.apiBaseUrl` to `https://api.<domain>/ui/api`.
  - IRIS CORS headers to allow the UI origin.
- Optionally, put a reverse proxy in front of IRIS to hide internal host/port and enforce HTTPS.

**Never** hardcode deployment secrets or credentials into Angular or ObjectScript code. Use environment-specific configuration mechanisms consistent with project security requirements.


## 7. Constraints and Safety Rules for the Coding Agent

When acting on instructions that reference this document:

1. **Do not**:
   - Modify or commit license keys under `license/` or `setup/`.
   - Commit any secrets (passwords, tokens, private keys) anywhere in the repo.
   - Change foundational deployment scripts (`setup/*.sh`, `software/*.sh`) without explicit user instruction.

2. **Do**:
   - Follow `.clinerules` coding standards for ObjectScript and infrastructure conventions.
   - Place new IRIS classes under `src/Cloud/Deployment/UI/...` (or a clearly documented alternative chosen by the user).
   - Place Angular artifacts under `ui/angular-client/`.
   - Document any manual IRIS Management Portal steps that you cannot automate directly via code.

3. If there is ambiguity (e.g., which namespace to target, which URL path to use for REST), you must:
   - Either use a clearly marked **TODO** comment and conservative defaults, or
   - Ask the user for clarification before proceeding (depending on the active instructions).

---

## 8. Summary: When Asked to Implement

When a future task asks you to “create an IRIS + Angular app using these instructions,” you should:

1. Confirm:
   - Target IRIS namespace.
   - Desired REST base path (e.g., `/ui/api`).
   - Deployment mode (IRIS-hosted Angular vs. separate web host).

2. Implement backend:
   - Add domain classes under `src/Cloud/Deployment/UI/Domain/`.
   - Add REST class(es) under `src/Cloud/Deployment/UI/REST/` with `UrlMap` and handlers.
   - Implement CORS and (if requested) authentication.
   - Ensure classes compile in the chosen namespace.

3. Implement frontend:
   - Create or reuse `ui/angular-client/`.
   - Configure environments (`apiBaseUrl`).
   - Implement models, services, components, routing.
   - Use proxy config for dev if needed.

4. Validate:
   - `ng serve` shows Angular UI and can perform CRUD calls against IRIS REST.
   - CORS and/or proxy config allow requests without browser errors.
   - No secrets are committed; coding standards and file organization rules are respected.

These are the complete instructions you (the coding agent) should follow to implement an IRIS ObjectScript backend with an Angular UI in this repository.

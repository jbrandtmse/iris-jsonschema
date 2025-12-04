# 15. Coding Standards

These are **CRITICAL** standards for AI agents. Following these rules prevents common mistakes and ensures consistent, compilable code.

### 15.1 ObjectScript Naming Conventions (REQUIRED)

| Element | Convention | Example |
|---------|------------|---------|
| **Parameters** | `p` prefix | `pSchema`, `pJSON`, `pErrors` |
| **Local Variables** | `t` prefix | `tValid`, `tSchema`, `tContext` |
| **Class Properties** | PascalCase, no prefix | `DataPath`, `Errors`, `MaxDepth` |
| **Class Parameters** | UPPERCASE or PascalCase, NO underscores | `MAXDEPTH`, `MaxDepth` |
| **Access Parameters** | Use `#` character | `..#MAXDEPTH` |
| **Classes/Packages** | PascalCase, match exact case | `JSONSchema.Validator` |

### 15.2 Macro Syntax (CRITICAL)

```objectscript
// ✓ CORRECT: Triple dollar signs ($$$)
Set tSC = $$$OK
If $$$ISERR(tSC) { ... }
Do $$$AssertTrue(condition, "message")
Quit $$$NULLOREF

// ✗ WRONG: Double dollar signs - WILL NOT COMPILE
Set tSC = $$OK     // INCORRECT!
If $$ISERR(tSC)    // INCORRECT!
```

### 15.3 Method Pattern (REQUIRED for void methods)

```objectscript
/// Standard pattern for methods returning %Status
ClassMethod MyMethod(pInput As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        // Logic here
        Set tResult = ..DoSomething(pInput)
        If tResult = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Operation failed")
            Quit  // Argumentless QUIT in Try block
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC  // Return status AFTER Try/Catch
}
```

### 15.4 QUIT Statement Restrictions (CRITICAL)

**ERROR #1043:** QUIT with arguments is NOT allowed within Try/Catch blocks.

```objectscript
// ✗ WRONG: QUIT with argument inside Try/Catch causes ERROR #1043
Method CreateObject() As %DynamicObject
{
    Try {
        Set tObj = ##class(%DynamicObject).%New()
        Quit tObj  // ERROR #1043!
    } Catch ex { }
}

// ✓ CORRECT: Initialize before Try, argumentless QUIT inside, return after
Method CreateObject() As %DynamicObject
{
    Set tResult = ""  // Initialize return variable
    Try {
        Set tResult = ##class(%DynamicObject).%New()
        Quit  // Argumentless QUIT
    }
    Catch ex {
        // Handle error
        Quit  // Argumentless QUIT
    }
    Quit tResult  // Return AFTER Try/Catch
}
```

### 15.5 %DynamicObject Properties with Underscores

```objectscript
// ✓ CORRECT: Quote properties containing underscores
Set tRequest."max_depth" = 100
Set tRequest."schema_version" = "draft-07"

// ✗ WRONG: Underscore is concatenation operator
Set tRequest.max_depth = 100  // This concatenates variables!
```

### 15.6 Command Spacing Rules

```objectscript
// ✓ CORRECT: 1 space after command with arguments
Set tValue = 1
Write tValue

// ✓ CORRECT: 2 spaces after argumentless command
Quit  Do ..Method()  // 2 spaces between Quit and Do

// All commands execute left-to-right on same line
Set x = 1 Set y = 2 Set z = 3  // All execute in order
```

### 15.7 Indentation (CRITICAL)

```objectscript
// ✓ CORRECT: Always indent code inside methods (at least 1 space/tab)
Method MyMethod()
{
    Set x = 1
    If x = 1 {
        Set y = 2
    }
}

// ✗ WRONG: No indentation causes compile errors
Method MyMethod()
{
Set x = 1  // Compile error - no indentation!
}
```

### 15.8 Prohibited Characters

```objectscript
// ✗ WRONG: No '%' or '_' in custom class/property names
Class JSONSchema._Validator  // INVALID
Property _internal As %String  // INVALID
Parameter MAX_DEPTH = 100      // INVALID (underscore in parameter)

// ✓ CORRECT: Use PascalCase or UPPERCASE
Class JSONSchema.Validator
Property Internal As %String
Parameter MAXDEPTH = 100
Parameter MaxDepth = 100
```

### 15.9 Abstract Methods (CRITICAL)

Despite documentation, abstract methods MUST have code blocks with return values:

```objectscript
// ✓ CORRECT: Abstract methods MUST have code blocks with return values
Method ValidateKeyword() As %Boolean [ Abstract ]
{
    Quit 0
}

Method GetHandler() As JSONSchema.Handler [ Abstract ]
{
    Quit $$$NULLOREF
}

Method Process() As %Status [ Abstract ]
{
    Quit $$$OK
}

// ✗ WRONG: Empty abstract method - WILL NOT COMPILE
Method ValidateKeyword() As %Boolean [ Abstract ]
// Missing curly braces and body!
```

### 15.10 Object Handling (CRITICAL)

```objectscript
// ✗ WRONG: $listbuild() serializes objects, losing object identity
Set tList = $listbuild(tObj1, tObj2)  // Objects become strings!
Set tRetrieved = $list(tList, 1)      // <INVALID OREF> error

// ✓ CORRECT: Use individual variables for object storage
Set tObj1 = ##class(MyClass).%New()
Set tObj2 = ##class(MyClass).%New()

// ✓ CORRECT: Use %DynamicArray for object collections
Set tArray = ##class(%DynamicArray).%New()
Do tArray.%Push(tObj1)
Do tArray.%Push(tObj2)
```

### 15.11 Built-in Classes Usage

```objectscript
// ✓ CORRECT: Use IRIS built-in classes
Set tJSON = ##class(%DynamicObject).%New()
Set tArray = ##class(%DynamicArray).%New()
Set tRequest = ##class(%Net.HttpRequest).%New()

// For JSON parsing
Set tData = ##class(%DynamicAbstractObject).%FromJSON(pJSONString)

// For iteration
Set tIter = tObject.%GetIterator()
While tIter.%GetNext(.tKey, .tValue) { }
```

### 15.12 Storage Sections

```objectscript
// IMPORTANT: NEVER manually edit Storage sections
// The IRIS compiler automatically generates and maintains storage
// based on declared properties

// Storage XML is auto-generated - DO NOT MODIFY
```

### 15.13 Documentation (DocBook/HTML)

```objectscript
/// JSONSchema.Validator - Main entry point for JSON Schema validation
/// <p>
/// Provides stateless validation of JSON data against JSON Schema.
/// <p>
/// <b>Supported Versions:</b>
/// <ul>
/// <li>JSON Schema Draft 7</li>
/// <li>JSON Schema 2020-12</li>
/// </ul>
/// <example>
/// Set valid = ##class(JSONSchema.Validator).Validate(data, schema, .errors)
/// </example>
Class JSONSchema.Validator Extends %RegisteredObject
{
```

### 15.14 Angular/TypeScript Conventions

```typescript
// ✓ CORRECT: Use interfaces for API models
interface ValidationError {
  keyword: string;
  dataPath: string;
  schemaPath: string;
  message: string;
}

// ✓ CORRECT: Use signals for state (Angular 18+)
const isValidating = signal<boolean>(false);

// ✓ CORRECT: Async/await for HTTP calls
async validate(): Promise<ValidationResponse> {
  return firstValueFrom(this.http.post<ValidationResponse>(url, body));
}

// ✗ WRONG: Direct process.env access
const apiUrl = process.env.API_URL;  // Use environment.ts instead

// ✓ CORRECT: Environment config
import { environment } from '../environments/environment';
const apiUrl = environment.apiBaseUrl;

// ✓ CORRECT: Standalone components (Angular 18)
@Component({
  selector: 'app-json-editor',
  standalone: true,
  imports: [CommonModule, MonacoEditorModule],
})
```

### 15.15 Project-Specific Critical Rules

| Rule | Description | Why Critical |
|------|-------------|--------------|
| **Stateless Methods** | All Validator methods must be ClassMethods, no instance state | Enables concurrent usage |
| **Error Accumulation** | Never throw exceptions from keyword handlers; add to Context.Errors | Collect all errors, not just first |
| **Path Tracking** | Always Push/Pop paths symmetrically in validation recursion | Accurate error locations |
| **Depth Check First** | Call IncrementDepth() at start of ValidateNode(), DecrementDepth() before all exits | Prevent stack overflow |
| **JSON Type Safety** | Always check $IsObject() before calling %IsA() | Prevent <INVALID OREF> errors |
| **Boolean Returns** | Use 1/0 for validation boolean returns | Consistent API |
| **Context Isolation** | Create new Context for each Validate() call | No cross-request pollution |

### 15.16 Code Quality Validation

**ObjectScript Quality Tools:**
- Use VS Code ObjectScript formatter
- Compile using MCP tool: `compile_objectscript_class` or `compile_objectscript_package`
- Use ObjectScriptQuality tool for automated validation

**Angular Quality Tools:**
- ESLint with Angular rules
- Prettier for formatting
- Run `npm run lint` before commits

### 15.17 Test File Organization

Test files must follow size and organization standards to maintain readability:

| Standard | Rule | Example |
|----------|------|---------|
| **Max File Size** | 800 lines maximum | TestTypeValidation.cls = 340 lines ✓ |
| **Organization** | By feature/keyword | TestEnumConst.cls, TestTypeValidation.cls |
| **Naming** | `Test{Feature}.cls` | TestInputFormats.cls, TestStringKeywords.cls |
| **Base Class** | Extends %UnitTest.TestCase | `Class Test.JSONSchema.TestTypeValidation Extends %UnitTest.TestCase` |
| **Story Alignment** | Group by story when natural | Story 1.3 → TestEnumConst.cls |

**Rationale:**
- Files over 800 lines become difficult to navigate and review
- Feature-based organization makes it easier to find relevant tests
- Aligning with stories creates clear ownership and context
- Allows room for test growth within each feature area

**Class Header Documentation Pattern:**
```objectscript
/// Test.JSONSchema.TestTypeValidation - Type keyword validation tests
/// <p>
/// Tests for JSON Schema "type" keyword covering all primitive types
/// (string, number, integer, boolean, null, array, object) and
/// array-of-types validation.
/// </p>
/// <p>
/// Originally from Story 1.2: Complete Type Keyword Support
/// </p>
Class Test.JSONSchema.TestTypeValidation Extends %UnitTest.TestCase
{
```

---

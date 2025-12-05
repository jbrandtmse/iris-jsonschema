/// JSONSchema.REST.Setup - Helper class for CSP application setup
/// <p>
/// Provides methods to create and configure the CSP web application
/// for the JSONSchema REST API.
/// </p>
Class JSONSchema.REST.Setup
{

/// Check if the CSP application exists
ClassMethod ApplicationExists() As %Boolean
{
    // Switch to %SYS namespace for Security.Applications access
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
    Quit ##class(Security.Applications).Exists("/api/jsonschema")
}

/// Create the CSP web application for JSONSchema REST API
/// Can be run from any namespace - switches to %SYS internally
ClassMethod CreateApplication() As %Status
{
    Set tSC = $$$OK
    Try {
        // Switch to %SYS namespace for Security.Applications access
        New $NAMESPACE
        Set $NAMESPACE = "%SYS"
        
        Set tAppName = "/api/jsonschema"
        
        // Check if application already exists
        If ##class(Security.Applications).Exists(tAppName) {
            Write "Application already exists: "_tAppName,!
            Quit
        }
        
        // Define application properties
        Set props("DispatchClass") = "JSONSchema.REST.Dispatch"
        Set props("Namespace") = "HSCUSTOM"
        Set props("NameSpace") = "HSCUSTOM"
        Set props("IsNameSpaceDefault") = 0
        Set props("MatchRoles") = ":%All"
        Set props("AutheEnabled") = 64  // 64 = Unauthenticated
        Set props("Description") = "JSONSchema Validator REST API"
        Set props("Enabled") = 1
        Set props("CSPZENEnabled") = 1
        Set props("InbndWebServicesEnabled") = 1
        Set props("Resource") = ""
        
        // Create the application
        Set tSC = ##class(Security.Applications).Create(tAppName, .props)
        If $$$ISERR(tSC) {
            Write "Error creating application: "_$System.Status.GetErrorText(tSC),!
            Quit
        }
        
        Write "Successfully created web application: "_tAppName,!
        Quit
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "Exception: "_ex.DisplayString(),!
    }
    Quit tSC
}

/// Delete the CSP web application (for cleanup)
ClassMethod DeleteApplication() As %Status
{
    Set tSC = $$$OK
    Try {
        // Switch to %SYS namespace for Security.Applications access
        New $NAMESPACE
        Set $NAMESPACE = "%SYS"
        
        Set tAppName = "/api/jsonschema"
        
        If '##class(Security.Applications).Exists(tAppName) {
            Write "Application does not exist: "_tAppName,!
            Quit
        }
        
        Set tSC = ##class(Security.Applications).Delete(tAppName)
        If $$$ISERR(tSC) {
            Write "Error deleting application: "_$System.Status.GetErrorText(tSC),!
            Quit
        }
        
        Write "Successfully deleted web application: "_tAppName,!
        Quit
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}

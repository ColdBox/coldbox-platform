# ColdBox Framework Development Guide

## Architecture Overview

ColdBox is an HMVC (Hierarchical Model-View-Controller) framework designed for two languages: BoxLang (which the ColdBox team owns and directs) and CFML. ColdBox provides four main subsystems:

- **ColdBox MVC**: Core framework in `/system/web/` - handles routing, events, interceptions, and request lifecycle
- **WireBox DI**: Dependency injection container in `/system/ioc/` - manages object creation, injection and aop
- **CacheBox**: Caching framework in `/system/cache/` - provides multi-provider caching abstraction and it's own caching engine
- **LogBox**: Logging framework in `/system/logging/` - structured logging with multiple appenders

## JavaScript Coding Standards

### Spacing and Formatting
- **Always add spaces inside parentheses**: Use `if ( condition )` not `if (condition)`
- **Function parameters**: Use `functionName( param1, param2 )` with spaces
- **Array/Object access**: Use `array[ index ]` and `object[ key ]` with spaces
- **Method calls**: Use `obj.method( param )` with spaces in parentheses
- **Template literals**: Use spaces in template expressions `${ variable }`
- **Arrow functions**: Use `array.filter( item => condition )` with spaces
- **Operators**: Always space around operators `a === b`, `x + y`, `result = value`

### Structure and Organization
- Use consistent indentation (tabs preferred to match CFML style)
- Group related methods together
- Add proper JSDoc comments for all functions
- Use descriptive variable names
- Separate logical sections with blank lines for readability

### Examples
```javascript
// Good - ColdBox JavaScript Style
if ( condition && anotherCondition ) {
    const result = someFunction( param1, param2 );
    array.forEach( item => {
        processItem( item );
    } );
}

// Bad - Inconsistent spacing
if (condition&&anotherCondition) {
    const result = someFunction(param1,param2);
    array.forEach(item => {
        processItem(item);
    });
}
```

## Key Components

- **Bootstrap.cfc**: Framework initialization and application lifecycle management
- **Controller.cfc**: Central dispatcher that processes events and manages services
- **Settings.cfc**: Default configuration values and conventions (handlers, views, layouts, models)
- **EventHandler.cfc/RestHandler.cfc**: Base classes for request handlers with dependency injection
- **RequestContext**: Event object containing RC/PRC scopes, routing info, and rendering methods
- **WireBox.cfc**: Dependency injection container for managing service creation and injection
- **CacheBox.cfc**: Caching container for managing cache providers and entries
- **LogBox.cfc**: Logging container for managing loggers, appenders, and log entries
- **BugReport.cfm**: Error reporting template showing framework state, routing info, and scopes
- **ModuleConfig.cfc**: Module configuration for routes, models, and interceptors

## Key Web Application Services

The ColdBox framework includes several core services in `/system/web/services/` that manage different aspects of the application lifecycle:

- **BaseService.cfc**: Base helper class providing common functionality for all ColdBox services
- **HandlerService.cfc**: Manages event handling, handler caching, event caching, and handler execution lifecycle
- **InterceptorService.cfc**: Manages interception points, interceptor registration, and announcement of framework events
- **LoaderService.cfc**: Responsible for loading and configuring a ColdBox application with all its services during startup
- **ModuleService.cfc**: Oversees HMVC module management including registration, activation, and CF mapping management
- **RequestService.cfc**: Handles request context preparation, FORM/URL processing, and flash scope management
- **RoutingService.cfc**: Manages URL routing, route registration, and request-to-handler mapping via the Router component
- **SchedulerService.cfc**: Manages application schedulers in an HMVC fashion for background task execution

## Development Workflows

### Testing

```bash
# Run specific test suites
box run-script tests:integration
box run-script tests:cachebox
box run-script tests:wirebox
box run-script tests:logbox

# Start test servers for different engines
box run-script start:boxlang     # BoxLang engine (preferred)
box run-script start:lucee       # Lucee CFML engine
box run-script start:2023        # Adobe ColdFusion 2023
```

### Building & Formatting

```bash
box run-script build          # Build without docs
box run-script format         # Format all CFC files
box run-script format:check   # Check formatting compliance
```

## Framework Conventions

- **Handlers**: `/handlers/` - event handlers (controllers) with `index()` as default action
- **Models**: `/models/` - business logic with automatic DI registration when `autoMapModels=true`
- **Views**: `/views/` - organized by handler name, rendered with `event.setView()`
- **Layouts**: `/layouts/` - page templates with `renderView()` placeholder
- **Modules**: `/modules/` - self-contained HMVC sub-applications with `ModuleConfig.cfc`

## Dependency Injection Patterns

WireBox uses several injection approaches:
- **Property injection**: `property name="myService" inject="MyService";`
- **Constructor injection**: Arguments automatically resolved by type/name
- **Setter injection**: `setMyService()` methods called automatically
- **Provider pattern**: `inject="provider:MyService"` for lazy loading

## Testing Patterns

Tests extend `BaseModelTest` or `BaseIntegrationTest`:
```cfml
component extends="coldbox.system.testing.BaseModelTest" {
    function run(testResults, testBox) {
        describe("My Service", function() {
            beforeEach(function() {
                mockService = createMock("app.models.MyService");
            });

            it("can do something", function() {
                expect(mockService.doSomething()).toBe("expected");
            });
        });
    }
}
```

## Error Handling & Debugging

- **BugReport.cfm**: Comprehensive error template showing framework state, routing info, scopes
- **Exception handling**: Uses `exceptionHandler` setting pointing to handler.action
- **Reinit**: Use `?fwreinit=1` to reload framework or specific password via `reinitPassword` setting
- **Debug mode**: Set `debugMode=true` in configuration for enhanced error reporting

## Module Development

Modules are self-contained with:
- **ModuleConfig.cfc**: Configuration, routes, model mappings, interceptors
- **handlers/models/views**: Standard MVC structure
- **settings**: Module-specific configuration accessible via `getModuleSettings()`
- **dependencies**: Other modules this module depends on

## Multi-Language & Engine Support

### Language Support

ColdBox is designed for two programming languages:

**BoxLang** (Owned and directed by the ColdBox team):
- `.bx` - Components (classes, services, handlers)
- `.bxm` - Templates (views, layouts, includes)
- `.bxs` - Script files
- Strategic future language with enhanced features and performance
- Modern JVM language with superior type safety and performance

**CFML** (ColdFusion Markup Language):
- `.cfc` - Components (classes, services, handlers)
- `.cfm` - Templates (views, layouts, includes)
- Legacy language support maintained for existing applications

BoxLang is the recommended language for new projects due to its modern design, enhanced performance, and direct support from the ColdBox team.

### Engine Compatibility

Framework supports BoxLang, Lucee 5+, and Adobe ColdFusion 2023+. Use engine-specific server configs:
- `server-boxlang@1.json` - BoxLang development (port 8599, debug enabled)
- `server-boxlang-cfml@1.json` - BoxLang with CFML compatibility
- `server-lucee@5.json` - Lucee CFML engine
- `server-adobe@2023.json` - Adobe ColdFusion

Key consideration: BoxLang requires `enableNullSupport` in Application.cfc/bx for full null handling.

<p align="center">
	<img src="https://www.ortussolutions.com/__media/wirebox-185.png" height="125" >
</p>

<p align="center">
	<a href="https://forgebox.io/view/wirebox"><img src="https://forgebox.io/api/v1/entry/wirebox/badges/downloads" alt="Total Downloads" /></a>
	<a href="https://forgebox.io/view/wirebox"><img src="https://forgebox.io/api/v1/entry/wirebox/badges/version" alt="Latest Stable Version" /></a>
	<a href="https://forgebox.io/view/wirebox"><img src="https://img.shields.io/badge/License-Apache2-brightgreen" alt="Apache2 License" /></a>
</p>

<p align="center">
	Copyright Since 2005 ColdBox Platform by Luis Majano and Ortus Solutions, Corp
	<br>
	<a href="https://www.coldbox.org">www.coldbox.org</a> |
	<a href="https://www.ortussolutions.com">www.ortussolutions.com</a>
</p>

----

Because of God's grace, this project exists. If you don't like this, then don't read it, its not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the
Holy Ghost which is given unto us. ." Romans 5:5

----

# 🚀 Welcome to WireBox

**Enterprise Dependency Injection Container for Modern Applications**

WireBox is a powerful, flexible dependency injection and AOP (Aspect-Oriented Programming) framework designed for two modern programming languages:

- **[BoxLang](https://www.boxlang.io)** 🥇 - A modern JVM language owned and directed by the ColdBox team
- **CFML (ColdFusion)** - Full support for existing enterprise applications

**✨ Use WireBox Standalone** - While part of the ColdBox Platform, WireBox can be installed and used independently in **ANY BoxLang or CFML application** without requiring the full ColdBox framework.

## 🏆 Proven & Professional

**19+ Years of Excellence** - Since 2006, WireBox has been battle-tested in enterprise environments worldwide, evolving with modern development practices and industry standards.

**Professional Open Source** - Backed by [Ortus Solutions](https://www.ortussolutions.com), WireBox provides the reliability and support that businesses demand. With dedicated full-time development, comprehensive documentation, and professional services, enterprises can confidently build mission-critical applications on WireBox.

**Enterprise Ready** - Trusted by Fortune 500 companies and organizations globally, WireBox delivers the stability, performance, and long-term support that enterprise applications require. Learn more at [www.coldbox.org](https://www.coldbox.org).

## 🚀 Why Choose WireBox?

- **🔧 Standalone Ready** - Use independently in any BoxLang/CFML application
- **� Dependency Injection** - Constructor, setter, and property injection
- **🎯 Auto-Discovery** - Automatic component registration and wiring
- **⚡ High Performance** - Optimized object creation and caching
- **🔄 Object Scoping** - Singleton, prototype, cachebox, session, and custom scopes
- **📈 Scalable** - From single application to distributed enterprise systems
- **🛡️ Thread-Safe** - Production-ready concurrent object management
- **🔌 Extensible** - Custom scopes, providers, and listeners
- **🎛️ AOP Support** - Aspect-Oriented Programming with method interceptors
- **📋 Rich DSL** - Flexible Domain Specific Language for object definitions

## ⚡ Quick Start

### 1. Install WireBox Standalone

```bash
# Install WireBox independently
box install wirebox

# Or with ColdBox Platform
box install coldbox
```

### 2. Basic Standalone Usage

```javascript
// Create WireBox injector
injector = new wirebox.system.ioc.Injector()

// Configure with mappings
injector.mapDirectory( "models" )
injector.map( "UserService" ).to( "models.UserService" ).asSingleton()

// Get instances with automatic dependency injection
userService = injector.getInstance( "UserService" )
user = injector.getInstance( "User" )

// Property injection example
class {
    @inject( "UserService" )
	property userService;

	@inject( "logbox:logger:{this}" )
    property logger;

}

// Configure and get logger
logBox.configure( config )
logger = logBox.getLogger( "MyApp" )
```

### 3. With ColdBox Framework

```javascript
	// Inject dependencies in any ColdBox Enabled Class
	@inject( "UserService" )
	property userService

	@inject( "logbox:logger:{this}" )
	property logger

	function index( event, rc, prc ) {
		// Dependencies are automatically injected
		user = userService.getUser( getUserId() )
		logger.info( "User retrieved", user )
	}
```

## 💾 Installation Options

### CommandBox (Recommended)

```bash
# Standalone WireBox
box install wirebox

# With ColdBox Platform
box install coldbox

# Bleeding Edge
box install wirebox@be
```

### ForgeBox Package Manager

Visit [ForgeBox](https://forgebox.io/view/wirebox) for additional installation options.

## 🛠️ VS Code Development Tools

Enhance your WireBox development experience with our official VS Code extensions:

### ColdBox Extension

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-coldbox)**

Features:

- WireBox configuration scaffolding
- Built-in WireBox commands integration
- Syntax highlighting for WireBox configurations

### BoxLang Developer Pack

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-boxlang-developer-pack)**

Complete development suite including:

- BoxLang language server with IntelliSense
- Integrated debugging for dependency injection
- Advanced code completion for WireBox APIs
- CFML compatibility layer

## 🏗️ Architecture Overview

WireBox provides a comprehensive dependency injection architecture:

### Core Components

- **Injector** - Central IoC container and object factory
- **Binder** - Configuration DSL for object mappings and dependencies
- **Provider** - Lazy object creation and lifecycle management
- **Scopes** - Object lifecycle management (singleton, prototype, etc.)
- **Aspects** - AOP interceptors and method advice

### Supported Scopes

- **Singleton** - Single instance per injector
- **Prototype** - New instance every time
- **CacheBox** - Cached instances with TTL
- **Session** - Instance per user session
- **Request** - Instance per request
- **Custom Scopes** - Build your own lifecycle management

### Injection Types

- **Constructor Injection** - Dependencies passed as constructor arguments
- **Setter Injection** - Dependencies set via setter methods
- **Property Injection** - Dependencies injected directly into properties
- **Provider Injection** - Lazy loading via provider pattern

### 🔧 Standalone Library Support

**Use Independently** - WireBox is designed as a standalone library that can be used in **ANY BoxLang or CFML application** without requiring the full ColdBox framework. This modular architecture allows you to:

- **Add dependency injection** to existing applications
- **Integrate with legacy systems** seamlessly
- **Mix and match** with other IoC containers
- **Independent installation** via CommandBox

## 💻 System Requirements

### Supported Languages & Engines

**BoxLang (Recommended)**

- BoxLang 1.0+
- Modern JVM language with enhanced performance
- Owned and directed by the ColdBox team

**CFML Support**

- Adobe ColdFusion 2023+
- Lucee 5.0+
- Legacy application support

## 📚 Documentation

**Comprehensive documentation is available at: [https://wirebox.ortusbooks.com](https://wirebox.ortusbooks.com)**

### Quick Links

- 📖 **[Getting Started Guide](https://wirebox.ortusbooks.com/getting-started/overview)** - Your first WireBox application
- 🏗️ **[Configuration](https://wirebox.ortusbooks.com/configuration)** - Setup and configuration options
- � **[Injection DSL](https://wirebox.ortusbooks.com/usage/injection-dsl)** - Dependency injection syntax
- � **[Object Scopes](https://wirebox.ortusbooks.com/usage/scopes)** - Object lifecycle management
- 🔧 **[ColdBox CLI](https://github.com/coldbox/coldbox-cli)** - Essential command-line tools
- 📋 **[API Documentation](https://apidocs.coldbox.org)** - Complete API reference
- 💻 **[VS Code ColdBox Extension](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** - WireBox development tools
- 🧰 **[VS Code BoxLang Developer Pack](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** - Complete BoxLang development suite

## 🌟 Ecosystem

### Core Libraries (Standalone Compatible)

- **[WireBox](https://github.com/coldbox/wirebox)** - Dependency injection (this library)
- **[CacheBox](https://github.com/coldbox/cachebox)** - Enterprise caching for any BoxLang/CFML app
- **[LogBox](https://github.com/coldbox/logbox)** - Logging framework for any BoxLang/CFML app

### Extended Ecosystem

- **[ForgeBox.io](https://forgebox.io)** - Package repository with 1000+ modules
- **[ColdBox Modules](https://forgebox.io/type/coldbox-modules)** - 200+ modules available
- **[CB Security](https://forgebox.io/view/cbsecurity)** - Enterprise security framework
- **[CB Validation](https://forgebox.io/view/cbvalidation)** - Validation framework
- **[CB ORM](https://forgebox.io/view/cborm)** - ORM enhancements

## 🤝 Contributing & Community

### Get Involved

- 📖 **[Contributing Guide](https://github.com/coldbox/coldbox-platform/blob/development/CONTRIBUTING.md)** - How to contribute
- 🐛 **[Issue Tracker](https://ortussolutions.atlassian.net/browse/WIREBOX)** - Report bugs and request features
- 💬 **[Community Slack](https://boxteam.ortussolutions.com/)** - Join the conversation
- 📺 **[YouTube Channel](https://www.youtube.com/ortussolutions)** - Tutorials and presentations
- 🎓 **[CFCasts](https://www.cfcasts.com)** - CFML Video Learning Platform
- 🎓 **[BoxLang Academy](https://learn.boxlang.io)** - BoxLang Video Learning Platform

### Professional Support

- 🏢 **[Enterprise Support](https://www.ortussolutions.com/services/support)** - Professional support plans
- 🎯 **[Training](https://www.ortussolutions.com/services/training)** - Official WireBox training
- 💼 **[Consulting](https://www.ortussolutions.com/services/consulting)** - Expert implementation services

## ⭐ Support & Sponsors

WireBox is a professional open source project. Support us by:

- ⭐ **Star this repository**
- 💝 **[Become a Patreon](https://www.patreon.com/ortussolutions)**
- 🏢 **[Enterprise Support](https://www.ortussolutions.com/services/support)**

## 🚀 Quick Examples

### Basic Dependency Injection

```javascript
// Model with dependency injection
class {
    @inject( "UserService" )
	property userService;

	@inject( "logbox:logger:{this}" )
	property logger;

    function getUser( id ) {
        logger.info( "Getting user: #arguments.id#" );
        return userService.findById( arguments.id );
    }
}

// Constructor injection
class {
	@inject( "dsl:myDSN" )
    property datasource;

    function init( required userService inject="UserService" ) {
        variables.userService = arguments.userService;
        return this;
    }
}
```

### Advanced Configuration

```javascript
// Configure WireBox mappings
map( "UserService" )
    .to( "models.security.UserService" )
    .asSingleton()
    .initWith( datasource="myDSN" )

// Factory method pattern
map( "PaymentGateway" )
    .toFactoryMethod( "PaymentFactory", "createGateway" )
    .initArg( name="type", value="stripe" )

// Virtual inheritance mapping
map( "BaseService" )
    .to( "models.BaseService" )
    .asTransient()

map( "UserService" )
    .to( "models.UserService" )
    .parent( "BaseService" )
```

### Aspect-Oriented Programming (AOP)

```javascript
// Method interceptor
class extends="wirebox.system.aop.MethodInterceptor" {

    function invokeMethod( required invocation ) {
        var start = getTickCount()

        try {
            var result = arguments.invocation.proceed()
            var duration = getTickCount() - start

            writeLog( "Method #invocation.getMethod()# took #duration#ms" )

            return result;
        } catch( any e ) {
            writeLog( "Error in #invocation.getMethod()#: #e.message#" )
            rethrow
        }
    }
}

// Map the Aspect so it can be used
mapAspect( "PerformanceInterceptor" )
	.to( "aspects.PerformanceInterceptor" )

// Aspect Binding now applies interceptor to mappings
bindAspect(
	classes : match().mappings( "UserService" ),
	methods : match().all(),
	aspects : "PerformanceInterceptor"
)
```

### Provider Pattern

```javascript
// Lazy loading with providers
class {
	@inject( "provider:UserService" )
    property userServiceProvider;

    function getUser( id ) {
        // Service is created only when needed
        var userService = userServiceProvider.get()
        return userService.findById( arguments.id )
    }
}
```

## 📄 License

Apache License, Version 2.0 - See [LICENSE](https://github.com/coldbox/coldbox-platform/blob/development/license.txt) file for details.

> The ColdBox websites, logos and content have separate licensing and are separate entities.

## 🔗 Important Links

### Source Code

- **WireBox Repository**: https://github.com/coldbox/coldbox-platform/tree/development/system/ioc
- **ColdBox Platform**: https://github.com/coldbox/coldbox-platform
- **ColdBox CLI**: https://github.com/coldbox/coldbox-cli

### Documentation

- **WireBox Docs**: https://wirebox.ortusbooks.com
- **ColdBox Platform**: https://coldbox.ortusbooks.com
- **API Reference**: https://apidocs.coldbox.org

### Issue Tracking

- **WireBox Issues**: https://ortussolutions.atlassian.net/browse/WIREBOX

### Official Sites

- **ColdBox Framework**: https://www.coldbox.org
- **Ortus Solutions**: https://www.ortussolutions.com/products/wirebox

----

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12

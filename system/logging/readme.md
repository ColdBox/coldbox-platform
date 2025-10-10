<p align="center">
	<img src="https://www.ortussolutions.com/__media/logbox-185.png" height="125" >
</p>

<p align="center">
	<a href="https://forgebox.io/view/logbox"><img src="https://forgebox.io/api/v1/entry/logbox/badges/downloads" alt="Total Downloads" /></a>
	<a href="https://forgebox.io/view/logbox"><img src="https://forgebox.io/api/v1/entry/logbox/badges/version" alt="Latest Stable Version" /></a>
	<a href="https://forgebox.io/view/logbox"><img src="https://img.shields.io/badge/License-Apache2-brightgreen" alt="Apache2 License" /></a>
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

# 🚀 Welcome to LogBox

**Enterprise Logging Engine for Modern Applications**

LogBox is a powerful, flexible logging framework designed for two modern programming languages:

- **[BoxLang](https://www.boxlang.io)** 🥇 - A modern JVM language owned and directed by the ColdBox team
- **CFML (ColdFusion)** - Full support for existing enterprise applications

**✨ Use LogBox Standalone** - While part of the ColdBox Platform, LogBox can be installed and used independently in **ANY BoxLang or CFML application** without requiring the full ColdBox framework.

## 🏆 Proven & Professional

**19+ Years of Excellence** - Since 2006, LogBox has been battle-tested in enterprise environments worldwide, evolving with modern development practices and industry standards.

**Professional Open Source** - Backed by [Ortus Solutions](https://www.ortussolutions.com), LogBox provides the reliability and support that businesses demand. With dedicated full-time development, comprehensive documentation, and professional services, enterprises can confidently build mission-critical applications on LogBox.

**Enterprise Ready** - Trusted by Fortune 500 companies and organizations globally, LogBox delivers the stability, performance, and long-term support that enterprise applications require. Learn more at [www.coldbox.org](https://www.coldbox.org).

## 🚀 Why Choose LogBox?

- **🔧 Standalone Ready** - Use independently in any BoxLang/CFML application
- **📊 Multiple Appenders** - File, database, email, console, and custom appenders
- **🎯 Structured Logging** - Support for JSON, XML, and custom log formats
- **⚡ High Performance** - Asynchronous logging with minimal overhead
- **🔄 Log Rotation** - Automatic file rotation and archiving
- **📈 Scalable** - From single application to distributed enterprise systems
- **🛡️ Thread-Safe** - Production-ready concurrent logging
- **🔌 Extensible** - Custom appenders, layouts, and filters
- **🎛️ Fine-Grained Control** - Category-based log levels and filtering
- **📋 Rich Layouts** - Pattern, JSON, XML, and custom formatting

## ⚡ Quick Start

### 1. Install LogBox Standalone

```bash
# Install LogBox independently
box install logbox

# Or with ColdBox Platform
box install coldbox
```

### 2. Basic Standalone Usage

```javascript
// Create LogBox instance
logBox = new logbox.system.logging.LogBox();

// Simple configuration
config = {
    appenders: {
        console: {
            class: "logbox.system.logging.appenders.ConsoleAppender"
        },
        file: {
            class: "logbox.system.logging.appenders.RollingFileAppender",
            properties: {
                filePath: "logs/",
                fileName: "application.log",
                maxFileSize: "10MB",
                maxFiles: 5
            }
        }
    },
    root: {
        levelMin: "INFO",
        appenders: "*"
    }
};

// Configure and get logger
logBox.configure( config );
logger = logBox.getLogger( "MyApp" );

// Start logging
logger.info( "Application started successfully" );
logger.error( "An error occurred", exception );
```

### 3. With ColdBox Framework

```javascript
// Inject logger in any ColdBox component
property name="log" inject="logbox:logger:{this}";

function index( event, rc, prc ) {
    // Use logger in handlers
    log.info( "User #getUserId()# accessed homepage" );
    log.debug( "Request data", rc );
}
```



## 💾 Installation Options

### CommandBox (Recommended)

```bash
# Standalone LogBox
box install logbox

# With ColdBox Platform
box install coldbox

# Bleeding Edge
box install logbox@be
```

### ForgeBox Package Manager

Visit [ForgeBox](https://forgebox.io/view/logbox) for additional installation options.

## 🛠️ VS Code Development Tools

Enhance your LogBox development experience with our official VS Code extensions:

### ColdBox Extension

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-coldbox)**

Features:

- LogBox configuration scaffolding
- Built-in LogBox commands integration
- Syntax highlighting for log configurations

### BoxLang Developer Pack

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-boxlang-developer-pack)**

Complete development suite including:

- BoxLang language server with IntelliSense
- Integrated debugging for log operations
- Advanced code completion for LogBox APIs
- CFML compatibility layer

## 🏗️ Architecture Overview

LogBox provides a comprehensive logging architecture:

### 📊 Core Components

- **LogBox** - Central logging factory and configuration manager
- **Logger** - Individual logger instances with category-based control
- **Appenders** - Output destinations (file, console, database, email, etc.)
- **Layouts** - Message formatting and structure
- **Filters** - Log entry filtering and routing

### 📝 Supported Appenders

- **FileAppender** - Simple file logging
- **RollingFileAppender** - Automatic file rotation and archiving
- **ConsoleAppender** - Console/stdout output
- **DatabaseAppender** - Database table logging
- **EmailAppender** - Email notifications for critical events
- **SocketAppender** - Network socket logging
- **SyslogAppender** - System log integration
- **Custom Appenders** - Build your own output destinations

### 🎨 Supported Layouts

- **SimpleLayout** - Basic message formatting
- **Custom Layouts** - Create your own formatting

### 🔧 Standalone Library Support

**Use Independently** - LogBox is designed as a standalone library that can be used in **ANY BoxLang or CFML application** without requiring the full ColdBox framework. This modular architecture allows you to:

- **Add enterprise logging** to existing applications
- **Integrate with legacy systems** seamlessly
- **Mix and match** with other logging solutions
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

**Comprehensive documentation is available at: [https://logbox.ortusbooks.com](https://logbox.ortusbooks.com)**

### Quick Links

- 📖 **[Getting Started Guide](https://logbox.ortusbooks.com/getting-started/overview)** - Your first LogBox application
- 🏗️ **[Configuration](https://logbox.ortusbooks.com/configuration)** - Setup and configuration options
- 📝 **[Appenders](https://logbox.ortusbooks.com/appenders)** - All available appenders
- 🎨 **[Layouts](https://logbox.ortusbooks.com/layouts)** - Message formatting options
- 🔧 **[ColdBox CLI](https://github.com/coldbox/coldbox-cli)** - Essential command-line tools
- 📋 **[API Documentation](https://apidocs.coldbox.org)** - Complete API reference
- 💻 **[VS Code ColdBox Extension](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** - LogBox development tools
- 🧰 **[VS Code BoxLang Developer Pack](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** - Complete BoxLang development suite

## Quick Links


## 🤝 Contributing & Community

### Get Involved

- 📖 **[Contributing Guide](https://github.com/coldbox/coldbox-platform/blob/development/CONTRIBUTING.md)** - How to contribute
- 🐛 **[Issue Tracker](https://ortussolutions.atlassian.net/browse/LOGBOX)** - Report bugs and request features
- 💬 **[Community Slack](https://boxteam.ortussolutions.com/)** - Join the conversation
- 📺 **[YouTube Channel](https://www.youtube.com/ortussolutions)** - Tutorials and presentations
- 🎓 **[CFCasts](https://www.cfcasts.com)** - CFML Video Learning Platform
- 🎓 **[BoxLang Academy](https://learn.boxlang.io)** - BoxLang Video Learning Platform

### Professional Support

- 🏢 **[Enterprise Support](https://www.ortussolutions.com/services/support)** - Professional support plans
- 🎯 **[Training](https://www.ortussolutions.com/services/training)** - Official CacheBox training
- 💼 **[Consulting](https://www.ortussolutions.com/services/consulting)** - Expert implementation services

## ⭐ Support & Sponsors

LogBox is a professional open source project. Support us by:

- ⭐ **Star this repository**
- 💝 **[Become a Patreon](https://www.patreon.com/ortussolutions)**
- 🏢 **[Enterprise Support](https://www.ortussolutions.com/services/support)**

## 🚀 Quick Examples

```javascript
// Different log levels
logger.fatal( "Critical system failure" );
logger.error( "Database connection failed", exception );
logger.warn( "Memory usage is high" );
logger.info( "User #getUserId()# logged in" );
logger.debug( "Processing request data", requestData );
logger.trace( "Detailed execution flow" );

// Structured logging with extra data
logger.info( "Order processed", {
    orderId: order.getId(),
    customerId: customer.getId(),
    amount: order.getTotal()
} );
```

## 📄 License

Apache License, Version 2.0 - See [LICENSE](https://github.com/coldbox/coldbox-platform/blob/development/license.txt) file for details.

> The ColdBox websites, logos and content have separate licensing and are separate entities.

## 🔗 Important Links

### Source Code

- **LogBox Repository**: https://github.com/coldbox/coldbox-platform/tree/development/system/logging
- **ColdBox Platform**: https://github.com/coldbox/coldbox-platform
- **ColdBox CLI**: https://github.com/coldbox/coldbox-cli

### Documentation

- **LogBox Docs**: https://logbox.ortusbooks.com
- **ColdBox Platform**: https://coldbox.ortusbooks.com
- **API Reference**: https://apidocs.coldbox.org

### Issue Tracking

- **LogBox Issues**: https://ortussolutions.atlassian.net/browse/LOGBOX

### Official Sites

- **ColdBox Framework**: https://www.coldbox.org
- **Ortus Solutions**: https://www.ortussolutions.com/products/logbox

----

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12

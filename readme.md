<p align="center">
	<img src="https://www.ortussolutions.com/__media/coldbox-185-logo.png">
	<br>
	<img src="https://www.ortussolutions.com/__media/wirebox-185.png" height="125">
	<img src="https://www.ortussolutions.com/__media/cachebox-185.png" height="125" >
	<img src="https://www.ortussolutions.com/__media/logbox-185.png"  height="125">
</p>

<p align="center">
	<a href="https://github.com/ColdBox/coldbox-platform/actions/workflows/snapshot.yml"><img src="https://github.com/ColdBox/coldbox-platform/actions/workflows/snapshot.yml/badge.svg" alt="ColdBox Snapshots" /></a>
	<a href="https://forgebox.io/view/coldbox"><img src="https://forgebox.io/api/v1/entry/coldbox/badges/downloads" alt="Total Downloads" /></a>
	<a href="https://forgebox.io/view/coldbox"><img src="https://forgebox.io/api/v1/entry/coldbox/badges/version" alt="Latest Stable Version" /></a>
	<a href="https://forgebox.io/view/coldbox"><img src="https://img.shields.io/badge/License-Apache2-brightgreen" alt="Apache2 License" /></a>
</p>

<p align="center">
	Copyright Since 2005 ColdBox Platform by Luis Majano and Ortus Solutions, Corp
	<br>
	<a href="https://www.coldbox.org">www.coldbox.org</a> |
	<a href="https://www.ortussolutions.com">www.ortussolutions.com</a>
</p>

----

Because of God's grace, this project exists. If you don't like this, then don't read it, it's not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the
Holy Ghost which is given unto us. ." Romans 5:5

----

# Welcome to ColdBox HMVC Platform

ColdBox is the **enterprise-level HMVC (Hierarchical Model-View-Controller) framework** designed for two powerful programming languages:

- **[BoxLang](https://www.boxlang.io)** - A modern JVM language owned and directed by the ColdBox team
- **CFML (ColdFusion)** - Legacy support for existing enterprise applications

Built for scalability, modularity, and developer productivity, ColdBox eliminates the complexity of modern web development through **conventions over configuration** and a comprehensive ecosystem of integrated tools.

## 🏆 Proven & Professional

**19+ Years of Excellence** - Since 2006, ColdBox has been battle-tested in enterprise environments worldwide, evolving with modern development practices and industry standards.

**Professional Open Source** - Backed by [Ortus Solutions](https://www.ortussolutions.com), ColdBox provides the reliability and support that businesses demand. With dedicated full-time development, comprehensive documentation, and professional services, enterprises can confidently build mission-critical applications on ColdBox.

**Enterprise Ready** - Trusted by Fortune 500 companies and organizations globally, ColdBox delivers the stability, performance, and long-term support that enterprise applications require. Learn more at [www.coldbox.org](https://www.coldbox.org).

## 🚀 Why Choose ColdBox?

### Modern Web Development Made Simple

- **Zero Configuration**: Get started immediately with sensible defaults
- **Convention-Based**: Write less boilerplate, focus on business logic
- **Enterprise Ready**: 19+ years proven, professionally backed by Ortus Solutions
- **Full-Stack Framework**: Everything you need in one cohesive platform and module ecosystem

### Powerful Features

- 🛣️ **[Modern URL Routing](https://coldbox.ortusbooks.com/the-basics/routing)** - RESTful routes with parameter binding
- 📦 **[Hierarchical Modules](https://coldbox.ortusbooks.com/hmvc/modules)** - Build scalable applications with HMVC architecture
- 🔧 **[Dependency Injection](https://wirebox.ortusbooks.com)** - Built-in IoC container (WireBox)
- ⚡ **[Enterprise Caching](https://cachebox.ortusbooks.com)** - Multi-provider caching engine (CacheBox)
- 📝 **[Advanced Logging](https://logbox.ortusbooks.com)** - Structured logging framework (LogBox)
- 🧪 **[Testing Framework](https://coldbox.ortusbooks.com/testing/testing-coldbox-applications)** - Built-in BDD/TDD testing
- 🔄 **[Event-Driven Architecture](https://coldbox.ortusbooks.com/digging-deeper/interceptors)** - Interceptor-based programming
- 🔀 **[Async Programming](https://coldbox.ortusbooks.com/digging-deeper/promises-async-programming)** - Modern concurrent programming constructs
- 🌐 **[RESTful APIs](https://coldbox.ortusbooks.com/the-basics/event-handlers/rendering-data)** - Built-in REST support with auto-marshalling
- 🧩 **[Module Ecosystem](https://forgebox.io)** - 1000+ community modules on ForgeBox

## 📚 Documentation

We have made a firm commitment to our community that our Documentation will always be complete and up to date.  We have have a dedicated team that works full time on keeping the documentation accurate and relevant, with over 20 years of delivering quality documentation to the community.

- [https://coldbox.ortusbooks.com](https://coldbox.ortusbooks.com)
- [https://cachebox.ortusbooks.com](https://cachebox.ortusbooks.com)
- [https://logbox.ortusbooks.com](https://logbox.ortusbooks.com)
- [https://wirebox.ortusbooks.com](https://wirebox.ortusbooks.com)

**Please note that all of our docs include embedded MCP servers that you can easily use in any of your AI tools.**

### Quick Links

- 📖 **[Getting Started Guide](https://coldbox.ortusbooks.com/getting-started/installation)** - Your first ColdBox application
- 🏗️ **[Application Templates](https://github.com/coldbox-templates)** - Jumpstart with pre-built templates
- 🔧 **[ColdBox CLI](https://github.com/coldbox/coldbox-cli)** - Essential command-line tools
- 🎯 **[Conventions Guide](https://coldbox.ortusbooks.com/getting-started/conventions)** - Framework conventions
- 📋 **[API Documentation](https://apidocs.coldbox.org)** - Complete API reference
- 💻 **[VS Code ColdBox Extension](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** - ColdBox development tools
- 🧰 **[VS Code BoxLang Developer Pack](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** - Complete BoxLang development suite

## ⚡ Quick Start

### 1. Install ColdBox CLI (Essential Tool)

The [ColdBox CLI](https://github.com/coldbox/coldbox-cli) is essential for ColdBox development:

```bash
# Install CommandBox (if not already installed)
# Visit: https://www.ortussolutions.com/products/commandbox

# Install ColdBox CLI globally
box install coldbox-cli
```

### 2. Create Your First Application

```bash
# Generate a new ColdBox application
coldbox create app MyApp --template=Advanced

# Navigate to your app
cd MyApp

# Start the development server
box server start
```

### 3. Explore Starter Templates

Choose from production-ready templates at [https://github.com/coldbox-templates](https://github.com/coldbox-templates):

```bash
# Default application template
coldbox create app MyDefaultApp

# REST API template
coldbox create app MyAPI skeleton=rest

# BoxLang application template
coldbox create app MyApp skeleton=boxlang

# Microservice template
coldbox create app MyService skeleton=rest-hmvc
```

## 💾 Installation Options

### CommandBox (Recommended)

```bash
# Stable Release
box install coldbox

# Bleeding Edge (Auto-updated from commits)
box install coldbox@be
```

### ForgeBox Software Directory

Visit [ForgeBox](https://forgebox.io/view/coldbox) for additional installation options.

## 🛠️ VS Code Development Tools

Enhance your ColdBox development experience with our official VS Code extensions:

### ColdBox Extension

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-coldbox)**

Features:

- ColdBox application scaffolding
- Handler, model, and view generators
- Built-in ColdBox commands integration
- Project templates and snippets
- Syntax highlighting for ColdBox conventions

### BoxLang Developer Pack

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-boxlang-developer-pack)**

Complete development suite including:

- BoxLang language server with IntelliSense
- Syntax highlighting and code formatting
- Integrated debugging capabilities
- CFML compatibility layer
- Advanced code completion and navigation

## 🏗️ Architecture Overview

ColdBox provides four integrated subsystems:

### 🌐 ColdBox MVC Core

- Modern HMVC architecture
- Convention-based routing
- Event-driven request lifecycle
- Built-in security features

### 💉 WireBox - Dependency Injection

- Powerful IoC container
- AOP (Aspect-Oriented Programming)
- Object lifecycle management
- Auto-discovery and registration

### ⚡ CacheBox - Enterprise Caching

- Multi-provider architecture
- Distributed caching support
- Cache regions and policies
- Built-in cache providers

### 📊 LogBox - Structured Logging

- Multiple appender support
- Configurable log levels
- Structured logging patterns
- Performance optimized

### 🔧 Standalone Library Support

**Use Independently** - WireBox, CacheBox, and LogBox are designed as standalone libraries that can be used in **ANY BoxLang or CFML application** without requiring the full ColdBox framework. This modular architecture allows you to:

- **Integrate WireBox** for dependency injection in existing applications
- **Add CacheBox** for enterprise caching to legacy systems
- **Implement LogBox** for structured logging in any project
- **Mix and match** components based on your specific needs

Each library maintains its own documentation and can be installed independently via CommandBox.

## 🔄 Long Term Support (LTS)

ColdBox follows a predictable release cycle with extensive support:

| Version | Release | Bug Fixes Until | Security Fixes Until |
|---------|---------|------------------|---------------------|
| 6.x     | 2022    | 2024            | 2025               |
| 7.x     | 2023    | 2025            | 2026               |
| 8.x     | 2025    | 2026            | 2027               |
| 9.x     | 2026    | 2027            | 2028               |

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

## 🤝 Contributing & Community

### Get Involved

- 📖 **[Contributing Guide](CONTRIBUTING.md)** - How to contribute
- 🐛 **[Issue Tracker](https://ortussolutions.atlassian.net/browse/COLDBOX)** - Report bugs and request features
- 💬 **[Community Slack](https://boxteam.ortussolutions.com/)** - Join the conversation
- 📺 **[YouTube Channel](https://www.youtube.com/ortussolutions)** - Tutorials and presentations
- 🎓 **[CFCasts](https://www.cfcasts.com)** - CFML Video Learning Platform
- 🎓 **[BoxLang Academy](https://learn.boxlang.io)** - BoxLang Video Learning Platform

### Development Setup

```bash
# Clone the repository
git clone https://github.com/ColdBox/coldbox-platform.git
cd coldbox-platform

# Install dependencies
box install

# Start development server
box server start

# Run test suites
box run-script tests:integration
```

## 🌟 Ecosystem

ColdBox powers a rich ecosystem:

### Core Libraries (Standalone Compatible)

- **[WireBox DI](https://wirebox.ortusbooks.com)** - Dependency injection for any BoxLang/CFML app
- **[CacheBox](https://cachebox.ortusbooks.com)** - Enterprise caching for any BoxLang/CFML app
- **[LogBox](https://logbox.ortusbooks.com)** - Structured logging for any BoxLang/CFML app

### Extended Ecosystem

- **[ForgeBox.io](https://forgebox.io)** - Package repository with 1000+ modules
- **[ColdBox Modules](https://forgebox.io/type/modules)** - Extend functionality with modules
- **[CB Security](https://forgebox.io/view/cbsecurity)** - Enterprise security framework
- **[CB Rest](https://forgebox.io/view/cbrest)** - REST API development
- **[CB Validation](https://forgebox.io/view/cbvalidation)** - Server-side validation
- **[CB ORM](https://forgebox.io/view/cborm)** - ORM enhancements

## 📄 License

Apache License, Version 2.0 - See [LICENSE](license.txt) file for details.

> The ColdBox websites, logos and content have separate licensing and are separate entities.

## 🔗 Important Links

### Source Code

- **GitHub Repository**: https://github.com/coldbox/coldbox-platform
- **ColdBox CLI**: https://github.com/coldbox/coldbox-cli
- **Application Templates**: https://github.com/coldbox-templates

### Documentation

- **ColdBox Platform**: https://coldbox.ortusbooks.com
- **WireBox DI**: https://wirebox.ortusbooks.com
- **CacheBox**: https://cachebox.ortusbooks.com
- **LogBox**: https://logbox.ortusbooks.com

### Issue Tracking

- **ColdBox Issues**: https://ortussolutions.atlassian.net/browse/COLDBOX
- **WireBox Issues**: https://ortussolutions.atlassian.net/browse/WIREBOX
- **CacheBox Issues**: https://ortussolutions.atlassian.net/browse/CACHEBOX
- **LogBox Issues**: https://ortussolutions.atlassian.net/browse/LOGBOX

### Official Sites

- **ColdBox Framework**: https://www.coldbox.org
- **Ortus Solutions**: https://www.ortussolutions.com/products/coldbox

----

## THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12

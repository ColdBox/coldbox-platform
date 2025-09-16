<p align="center">
	<img src="https://www.ortussolutions.com/__media/cachebox-185.png" height="125" >
</p>

<p align="center">
	<a href="https://forgebox.io/view/cachebox"><img src="https://forgebox.io/api/v1/entry/cachebox/badges/downloads" alt="Total Downloads" /></a>
	<a href="https://forgebox.io/view/cachebox"><img src="https://forgebox.io/api/v1/entry/cachebox/badges/version" alt="Latest Stable Version" /></a>
	<a href="https://forgebox.io/view/cachebox"><img src="https://img.shields.io/badge/License-Apache2-brightgreen" alt="Apache2 License" /></a>
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

# 🚀 Welcome to CacheBox

**Enterprise Caching Engine for Modern Applications**

CacheBox is a powerful, flexible caching framework designed for two modern programming languages:

- **[BoxLang](https://www.boxlang.io)** 🥇 - A modern JVM language owned and directed by the ColdBox team
- **CFML (ColdFusion)** - Full support for existing enterprise applications

**✨ Use CacheBox Standalone** - While part of the ColdBox Platform, CacheBox can be installed and used independently in **ANY BoxLang or CFML application** without requiring the full ColdBox framework.

## 🏆 Proven & Professional

**19+ Years of Excellence** - Since 2006, CacheBox has been battle-tested in enterprise environments worldwide, evolving with modern development practices and industry standards.

**Professional Open Source** - Backed by [Ortus Solutions](https://www.ortussolutions.com), CacheBox provides the reliability and support that businesses demand. With dedicated full-time development, comprehensive documentation, and professional services, enterprises can confidently build mission-critical applications on CacheBox.

**Enterprise Ready** - Trusted by Fortune 500 companies and organizations globally, CacheBox delivers the stability, performance, and long-term support that enterprise applications require. Learn more at [www.coldbox.org](https://www.coldbox.org).

## 🚀 Why Choose CacheBox?

- **🔧 Standalone Ready** - Use independently in any BoxLang/CFML application
- **⚡ High Performance** - Enterprise-grade caching with multiple provider support
- **🌐 Multi-Provider** - Support for Redis, EhCache, RAM, and custom providers
- **📊 Rich Monitoring** - Built-in statistics, events, and performance metrics
- **🔄 Cache Aggregation** - Combine multiple cache providers seamlessly
- **⚙️ Easy Configuration** - Simple XML or programmatic configuration
- **🎯 Event-Driven** - Comprehensive event model for cache lifecycle
- **📈 Scalable** - From single server to distributed enterprise clusters
- **🛡️ Thread-Safe** - Production-ready concurrent access handling
- **🔌 Extensible** - Custom providers, stores, and event listeners

## ⚡ Quick Start

### 1. Install CacheBox Standalone

```bash
# Install CacheBox independently
box install cachebox

# Or with ColdBox Platform
box install coldbox
```

### 2. Basic Standalone Usage

```javascript
// Create CacheBox instance
cacheBox = new cachebox.system.cache.CacheFactory();

// Get cache and use it
cache = cacheBox.getDefaultCache();
cache.set( "myKey", "myValue", 30 );
value = cache.get( "myKey" );

// Or fluently
value = cacheBox.getDefaultCache().getOrSet( "myKey", () => {
	return "computedValue";
}, 30 );
```

### 3. With ColdBox Framework

```javascript
// Inject cache in any ColdBox component
property name="cache" inject="cachebox:default";

function index( event, rc, prc ) {
    // Use cache in handlers
    cache.set( "user:#getUserId()#", getUserData(), 60 );
    userData = cache.get( "user:#getUserId()#" );
}
```

## 💾 Installation

```bash
# Standalone CacheBox
box install cachebox

# With ColdBox Platform
box install coldbox

# Bleeding Edge
box install cachebox@be
```

## 🛠️ VS Code Development Tools

Enhance your CacheBox development experience with our official VS Code extensions:

### ColdBox Extension

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-coldbox)**

Features:

- CacheBox configuration scaffolding
- Cache provider templates
- Built-in CacheBox commands integration
- Syntax highlighting for cache configurations

### BoxLang Developer Pack

**[Download from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** | **[Open VSX Registry](https://open-vsx.org/extension/ortus-solutions/vscode-boxlang-developer-pack)**

Complete development suite including:

- BoxLang language server with IntelliSense
- Integrated debugging for cache operations
- Advanced code completion for CacheBox APIs
- CFML compatibility layer

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

**Comprehensive documentation is available at: [https://cachebox.ortusbooks.com](https://cachebox.ortusbooks.com)**

## Quick Links

- 📖 **[Getting Started Guide](https://cachebox.ortusbooks.com/getting-started/overview)** - Your first CacheBox application
- 🏗️ **[Configuration](https://cachebox.ortusbooks.com/configuration)** - Setup and configuration options
- 💾 **[Cache Providers](https://cachebox.ortusbooks.com/cache-providers)** - All available providers
- 📊 **[Monitoring](https://cachebox.ortusbooks.com/monitoring-debugging)** - Performance and debugging
- 🔧 **[ColdBox CLI](https://github.com/coldbox/coldbox-cli)** - Essential command-line tools
- 📋 **[API Documentation](https://apidocs.coldbox.org)** - Complete API reference
- 💻 **[VS Code ColdBox Extension](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-coldbox)** - CacheBox development tools
- 🧰 **[VS Code BoxLang Developer Pack](https://marketplace.visualstudio.com/items?itemName=ortus-solutions.vscode-boxlang-developer-pack)** - Complete BoxLang development suite

## 🤝 Contributing & Community

### Get Involved

- 📖 **[Contributing Guide](https://github.com/coldbox/coldbox-platform/blob/development/CONTRIBUTING.md)** - How to contribute
- 🐛 **[Issue Tracker](https://ortussolutions.atlassian.net/browse/CACHEBOX)** - Report bugs and request features
- 💬 **[Community Slack](https://boxteam.ortussolutions.com/)** - Join the conversation
- 📺 **[YouTube Channel](https://www.youtube.com/ortussolutions)** - Tutorials and presentations
- 🎓 **[CFCasts](https://www.cfcasts.com)** - CFML Video Learning Platform
- 🎓 **[BoxLang Academy](https://learn.boxlang.io)** - BoxLang Video Learning Platform

### Professional Support

- 🏢 **[Enterprise Support](https://www.ortussolutions.com/services/support)** - Professional support plans
- 🎯 **[Training](https://www.ortussolutions.com/services/training)** - Official CacheBox training
- 💼 **[Consulting](https://www.ortussolutions.com/services/consulting)** - Expert implementation services

## ⭐ Support & Sponsors

CacheBox is a professional open source project. Support us by:

- ⭐ **Star this repository**
- 💝 **[Become a Patreon](https://www.patreon.com/ortussolutions)**
- 🏢 **[Enterprise Support](https://www.ortussolutions.com/services/support)**

## 🚀 Quick Examples

### Basic Cache Operations

```javascript
// Store and retrieve data
cache.set( "user:123", userData, 60 ); // 60 minutes
cache.set( "temp:data", tempData, 5 );  // 5 minutes

// Conditional operations
if( !cache.lookup( "expensive:data" ) ) {
    cache.set( "expensive:data", generateExpensiveData() );
}

// Bulk operations
cache.setMulti( {
    "key1": "value1",
    "key2": "value2"
}, 30 );
```

### Statistics

```javascript
// Get cache statistics
stats = cache.getStats();
writeOutput( "Cache hits: #stats.hits#" );
writeOutput( "Cache misses: #stats.misses#" );
writeOutput( "Hit ratio: #stats.hitRatio#%" );
```

## 📄 License

Apache License, Version 2.0 - See [LICENSE](https://github.com/coldbox/coldbox-platform/blob/development/license.txt) file for details.

> The ColdBox websites, logos and content have separate licensing and are separate entities.

----

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
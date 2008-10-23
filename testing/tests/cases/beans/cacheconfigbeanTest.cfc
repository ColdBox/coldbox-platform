<cfcomponent name="cacheConfigBeanTest" extends="mxunit.framework.TestCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.ccbean = createObject("component","coldbox.system.cache.config.CacheConfigBean");
			this.memento = structnew();
			
			this.memento.CacheObjectDefaultTimeout = 20;
			this.memento.CacheObjectDefaultLastAccessTimeout = 20;
			this.memento.CacheReapFrequency = 1;
			this.memento.CacheMaxObjects = 100;
			this.memento.CacheFreeMemoryPercentageThreshold = 1;
			this.memento.CacheUseLastAccessTimeouts = true;
			this.memento.CacheEvictionPolicy = "LFU";
			
			this.ccbean.init(argumentCollection=this.memento);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testgetCacheEvictionPolicy" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getCacheEvictionPolicy(), this.memento.cacheEvictionPolicy);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheFreeMemoryPercentageThreshold" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getCacheFreeMemoryPercentageThreshold(), this.memento.CacheFreeMemoryPercentageThreshold);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheMaxObjects" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getCacheMaxObjects(), this.memento.CacheMaxObjects);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheObjectDefaultLastAccessTimeout" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getCacheObjectDefaultLastAccessTimeout(), this.memento.CacheObjectDefaultLastAccessTimeout);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheObjectDefaultTimeout" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getCacheObjectDefaultTimeout(), this.memento.CacheObjectDefaultTimeout);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheReapFrequency" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getCacheReapFrequency(), this.memento.CacheReapFrequency);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheUseLastAccessTimeouts" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getCacheUseLastAccessTimeouts(), this.memento.CacheUseLastAccessTimeouts);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ccbean.getMemento(), this.memento);
		</cfscript>
	</cffunction>		

	<cffunction name="testpopulate" access="public" returnType="void">
		<cfscript>
			this.ccbean.populate( this.memento );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			this.ccbean.setMemento( this.memento );
			assertEquals( this.ccbean.getMemento(), this.memento);
		</cfscript>
	</cffunction>		
	

</cfcomponent>
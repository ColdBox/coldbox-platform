<cfcomponent name="CacheConfigTest" extends="coldbox.system.testing.BaseTestCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.ccbean = createObject("component","coldbox.system.cache.config.CacheConfig");
			this.memento = structnew();
			
			this.memento.ObjectDefaultTimeout = 20;
			this.memento.ObjectDefaultLastAccessTimeout = 20;
			this.memento.ReapFrequency = 1;
			this.memento.MaxObjects = 100;
			this.memento.FreeMemoryPercentageThreshold = 1;
			this.memento.UseLastAccessTimeouts = true;
			this.memento.EvictionPolicy = "LFU";
			this.memento.EvictCount = 10;
			
			this.ccbean.init(argumentCollection=this.memento);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testgetCacheEvictionPolicy" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getEvictionPolicy(), this.memento.EvictionPolicy);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheFreeMemoryPercentageThreshold" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getFreeMemoryPercentageThreshold(), this.memento.FreeMemoryPercentageThreshold);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheMaxObjects" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getMaxObjects(), this.memento.MaxObjects);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheObjectDefaultLastAccessTimeout" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getObjectDefaultLastAccessTimeout(), this.memento.ObjectDefaultLastAccessTimeout);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheObjectDefaultTimeout" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getObjectDefaultTimeout(), this.memento.ObjectDefaultTimeout);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheReapFrequency" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getReapFrequency(), this.memento.ReapFrequency);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetCacheUseLastAccessTimeouts" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getUseLastAccessTimeouts(), this.memento.UseLastAccessTimeouts);
		</cfscript>
	</cffunction>	
	
	<cffunction name="testGetCacheEvictCount" access="public" returnType="void">
		<cfscript>
			assertEquals(this.ccbean.getEvictCount(), this.memento.EvictCount);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			this.ccbean.setMemento( this.memento );
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
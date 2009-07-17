<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This is an object cache pool.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="MTObjectPool" 
			 hint="I manage persistance for objects." 
			 output="false"
			 extends="coldbox.system.cache.ObjectPool">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="MTObjectPool" hint="Constructor">
		<cfscript>
			/* Since we use JDK 5> we can use the concurrent package. */
			var Map = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init();
			var MetadataMap = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init();
			var SoftRefKeyMap = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init();
			
			/* Prepare instance */
			variables.instance = structnew();
			
			/* set object pools */
			setPool(Map);
			setPool_metadata( MetadataMap );
			setSoftRefKeyMap( SoftRefKeyMap );
			
			/* Register the reference queue for our soft references */
			setReferenceQueue( CreateObject("java","java.lang.ref.ReferenceQueue").init() );
			
			/* Return pool */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	

<!------------------------------------------- PRIVATE ------------------------------------------->



</cfcomponent>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
A cool remoting utililty component
----------------------------------------------------------------------->
<cfcomponent output="false" hint="A cool remoting utililty component" >
	
	<!--- 
	Based on original function by Elliot Sprehn, found here
	http://livedocs.adobe.com/coldfusion/7/htmldocs/wwhelp/wwhimpl/common/html/wwhelp.htm?context=ColdFusion_Documentation&file=00000271.htm
	BlueDragon and Railo by Chris Blackwell
	--->
	<cffunction name="clearHeaderBuffer" output="false" access="public" returntype="void" hint="Clear the CFHTMLHead buffer">
		<cfset var my = structnew() />
	
		<cfswitch expression="#trim(server.coldfusion.productname)#">
	
			<cfcase value="ColdFusion Server">
				<cfset my.out = getPageContext().getOut() />
	
				<!--- It's necessary to iterate over this until we get to a coldfusion.runtime.NeoJspWriter --->
				<cfloop condition="getMetaData(my.out).getName() is 'coldfusion.runtime.NeoBodyContent'">
					<cfset my.out = my.out.getEnclosingWriter() />
				</cfloop>
	
				<cfset my.method = my.out.getClass().getDeclaredMethod("initHeaderBuffer", arrayNew(1)) />
				<cfset my.method.setAccessible(true) />
				<cfset my.method.invoke(my.out, arrayNew(1)) />
	
			</cfcase>
	
	
			<cfcase value="Railo,Lucee">
	
				<cfset my.out = getPageContext().getOut() />
	
				<cfloop condition="getMetaData(my.out).getName() is 'railo.runtime.writer.BodyContentImpl'">
					<cfset my.out = my.out.getEnclosingWriter() />
				</cfloop>
	
				<cfset my.headData = my.out.getClass().getDeclaredField("headData") />
				<cfset my.headData.setAccessible(true) />
				<cfset my.headData.set(my.out, createObject("java", "java.lang.String").init("")) />
	
			</cfcase>
	
		</cfswitch>	
	</cffunction>

</cfcomponent>
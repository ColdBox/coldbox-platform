<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
	
			<cfcase value="BlueDragon">
	
				<cfset my.resp = getPageContext().getResponse() />
	
				<cfloop condition="true">
					<cfset my.parentf = my.resp.getClass().getDeclaredField('parent') />
					<cfset my.parentf.setAccessible(true) />
					<cfset my.parent = my.parentf.get(my.resp) />
	
					<cfif isObject(my.parent) AND getMetaData(my.parent).getName() is 'com.naryx.tagfusion.cfm.engine.cfHttpServletResponse'>
						<cfset my.resp = my.parent />
					<cfelse>
						<cfbreak />
					</cfif>
				</cfloop>
	
				<cfset my.writer = my.resp.getClass().getDeclaredField('writer') />
				<cfset my.writer.setAccessible(true) />
				<cfset my.writer = my.writer.get(my.resp) />
	
				<cfset my.headbuf = my.writer.getClass().getDeclaredField('headElement') />
				<cfset my.headbuf.setAccessible(true) />
				<cfset my.headbuf.get(my.writer).setLength(0) />
	
			</cfcase>
	
			<cfcase value="Railo">
	
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
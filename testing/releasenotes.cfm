<cfsavecontent variable="ticket">664
SendFile method of utilities plugin should accept binaryFiles too
closed	evdlinden	normal	Plugin Utilities	
665
New setting: ModelObjectCaching
closed	lmajano	normal	Coldbox.xml	2.6.2
667
logger plugin addition of utility methods for logging: debug(), info(), warn(), error() and fatal()
closed	lmajano	normal	Plugin Logger	2.6.2
676
Transfer Loader - Updated to use the TDO Bean Injector via properties. New properties
closed		normal	Extras	
680
New Model Settings: ModelsSetterInjection,ModelsDebugMode,ModelsStopRecursion,ModelsDICompleteUDF
closed	lmajano	normal	Architecture	
684
SES-addRoute() - Add ability to pass in a string of name-value pairs to create in the rc when a route is matched, new argument: matchStructure
closed	lmajano	normal	Interceptors - SES	
685
New setting: IOCFrameworkReload (true/false) which can reload the factory on every request, great for development
closed	lmajano	normal	Coldbox (cfc-cfm) (Front Controller)	
687
Added new argument to getModel() - stopRecursion. This is a comma-delimmitted list of classes to stop on recursion.
closed	lmajano	normal	Plugin BeanFactory	
688
beanFactory stopRecursion should now accept a comma delimitted list of recursion stopping classes
closed	lmajano	normal	Plugin BeanFactory	
689
New setting: DefaultLogLevel for choosing your application's logging level: 0-4
closed	lmajano	normal	Coldbox.xml	
691
Auto app mapping detection in j2ee fully functional now
closed	lmajano	normal	Architecture	2.6.2
</cfsavecontent>

<cfset split = ticket.split(chr(13))>
<cfset sb = createObject("java","java.lang.StringBuffer").init('')>

<cfset marker = 1>
<cfloop from="1" to="#arrayLen(split)#" index="i">
	<cfset thisVal = replace(trim(split[i]),chr(10),"")>
	<cfif len(trim(thisVal))>
		<cfif marker eq 1 >
			<cfset sb.append(" * ##" & thisVal)>
			<cfset marker++>
		<cfelseif marker eq 2>
			<cfset sb.append(" " & thisVal)>
			<cfset marker++>
		<cfelseif marker eq 3>
			<cfset sb.append(chr(13))>
			<cfset marker =1>
		</cfif>
	</cfif>
</cfloop>

<cfoutput>
<textarea rows="30" cols="120">
#sb.toString()#
</textarea>
</cfoutput>


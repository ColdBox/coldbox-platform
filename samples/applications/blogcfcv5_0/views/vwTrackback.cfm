<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : c:\projects\blog\client\trackbackb.cfm
	Author       : Dave Lobb
	Created      : 09/22/05
	Last Updated : 9/22/05
	History      : Ray modified it for 4.0
--->

<cfcontent type="text/xml; charset=UTF-8">

<!---
http://www.sixapart.com/pronet/docs/trackback_spec
--->


<cfset getPageContext().getOut().clear()>
<cfoutput>#trim(response)#</cfoutput>

<cfsetting enablecfoutputonly=false>


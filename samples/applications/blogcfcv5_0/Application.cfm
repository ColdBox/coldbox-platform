<!--- Edit this line if you are not using a default blog --->
<cfset blogname = "default">
<!--- The prefix is now dynamic in case 2 people want to run blog.cfc on the same machine. Normally they
	  would run both blogs with the same org, and use different names, but on an ISP that may not be possible.
	  So I base part of the application name on the file path.
	  
	Name can only be 64 max. So we will take right most part.
--->
<cfset prefix = getCurrentTemplatePath()>
<cfset prefix = reReplace(prefix, "[^a-zA-Z]","","all")>
<cfset prefix = right(prefix, 64 - len("_blog_#blogname#"))>

<cfapplication name="#prefix#_blog_#blogname#"
			   sessionmanagement="yes"
			   setclientcookies="true" loginstorage="session">
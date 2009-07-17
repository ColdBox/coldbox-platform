	&lt;!---
	DUMP
	---&gt;
	&lt;cffunction name="dump" access="public" output="true" return="void"&gt;
		&lt;cfargument name="abort" type="boolean" default="false" /&gt;
		&lt;cfdump var="#variables.instance#" /&gt;
		&lt;cfif arguments.abort&gt;
			&lt;cfabort /&gt;
		&lt;/cfif&gt;
	&lt;/cffunction&gt;
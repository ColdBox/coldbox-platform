This interceptor provides security to an application. It is very flexible
and customizable. It bases off on the ability to secure events by creating
rules. This interceptor will then try to match a rule to the incoming event
and the user's credentials on roles and/or permissions. 

For the latest documentation refer to the online guide:
http://wiki.coldbox.org/wiki/Interceptors:Security.cfm
	
Default Security:
This interceptor will try to use ColdFusion's cflogin + cfloginuser authentication
by default. However, if you are using your own authentication mechanisims you can
still use this interceptor by implementing a Security Validator Object.

Ex:
<cflogin>
	Your login logic here
	<cfloginuser name="name" password="password" roles="ROLES HERE">
</cflogin>

Security Validator Object:
A security validator object is a simple cfc that implements the following function:

userValidator(rule, messagebox) : boolean

This function must return a boolean variable and it must validate a user according
to the rule that just ran by testing the rule that got sent in. It will also receive
a reference to a messagebox plugin, so it can set messages on it if needed.

Declaring the Validator:
You have two ways to declare the security validator: 

1) This validator object can be set as a property in the interceptor declaration as an 
instantiation path. The interceptor will create it and try to execute it.  

2) You can register the validator via the "registerValidator()" method on this interceptor. 
This must be called from the application start handler or other interceptors as long as it 
executes before any preProcess execution occurs:

<cfset getInterceptor('coldbox.system.interceptors.Security').registerValidator(myValidator)>

That validator object can from anywhere you want using the mentioned technique above.


Interceptor Properties:

 - useRegex : boolean [default=true] Whether to use regex on event matching
 - useRoutes : boolean [default=false] Whether to redirec to events or routes
 - rulesSource : string [xml|db|ioc|ocm] Where to get the rules from.
 - debugMode : boolean [default=false] If on, then it logs actions via the logger plugin.
 - validator : string [default=""] If set, it must be a valid instantiation path to a security validator object.

* Please note that when using regular expressions, you specify and escape the metadata characters.

XML properties:
The rules will be extracted from an xml configuration file. The format is
defined in the sample.
 - rulesFile : string The relative or absolute location of the rules file.

DB properties:
The rules will be taken off a cfquery using the properties below.
 - rulesDSN : string The datasource to use to connect to the rules table.
 - rulesTable : string The table of where the rules are
 - rulesSQL* : string You can write your own sql if you want. (optional)
 - rulesOrderBy* : string How to order the rules (optional)

The table MUST have the following columns:
Rules Query
 - whitelist : varchar [null]
 - securelist : varchar
 - roles : varchar [null]
 - permissions : varchar [null]
 - redirect : varchar

IOC properties:
The rules will be grabbed off an IoC bean as a query. They must be a valid rules query.
 - rulesBean : string The bean to call on the IoC container
 - rulesBeanMethod : string The method to call on the bean
 - rulesBeanArgs* : string The arguments to send if any (optional)

OCM Properties:
The rules will be placed by the user in the ColdBox cache manager
and then extracted by this interceptor. They must be a valid rules query.
 - rulesOCMkey : string The key of the rules that will be placed in the OCM.

* Optional properties
The security interceptor provides security to an application. It is very flexible
and customizable. It bases off on the ability to secure events by creating
rules. This interceptor will then try to match a rule to the incoming even
and the user's credentials. The only requirement is that the developer
use the coldfusion <cfloging> and <cfloginuser> and set the roles accordingly.

Ex:
<cflogin>
	Your login logic here
	<cfloginuser name="name" password="password" roles="ROLES HERE">
</cflogin>

Interceptor Properties:

 - useRegex : boolean [default=true] Whether to use regex on event matching for secure and whitelist. (remember that a . must be escaped \.)
 - useRoutes : boolean [default=false] Whether to redirect to events or routes
 - rulesSource : string [xml|db|ioc|ocm] Where to get the rules from.
 - debugMode : boolean [default=false] If on, then it logs actions via the logger plugin.
 
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

The sql used by default is:
select *
from #rulesTable#
if( rulesOrderBy exists )
order by #rulesOrderBy#

The table MUST have the following columns in order to be a Rules Query the interceptor accepts
 - whitelist
 - securelist
 - roles
 - redirect

IOC properties:
The rules will be grabbed off an IoC bean as a query. They must be a valid rules query.
 - rulesBean : string The bean to call on the IoC container
 - rulesBeanMethod : string The method to call on the bean
 - rulesBeanArgs* : string The arguments to send if any (optional)

OCM Properties:
The rules will be placed by the user in the ColdBox cache manager by using the 
application start handler, and then extracted by this interceptor. They must be a valid rules query.
 - rulesOCMkey : string The key of the rules that will be placed in the OCM.

* Are Optional properties

Please note that when using regular expressions, you specify and escape the metadata characters.
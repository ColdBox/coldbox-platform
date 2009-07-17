<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Services test suites
	
----------------------------------------------------------------------->
<cfinvoke component="mxunit.runner.DirectoryTestSuite"   
           method="run"  
           directory="#expandPath('cases/services')#"   
           recurse="true"   
           returnvariable="results" />  
   
<cfoutput>#results.getResultsOutput('extjs')#</cfoutput> 
<cfinvoke component="mxunit.runner.DirectoryTestSuite"   
          method="run"  
          directory="#expandPath('.')#"   
          recurse="true"   
          returnvariable="results"/>  
<cfoutput>#results.getResultsOutput('html')#</cfoutput>   
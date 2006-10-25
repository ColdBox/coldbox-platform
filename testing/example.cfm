<html>
	<head>JavaLoader Example</head>
	<style type="text/css">
		body {
			font-family: Verdana, Helvetica, san-serif;
			font-size: small;
		}
	</style>
	<body>
		<p>
			Example of creating a 'HelloWorld' Java object, by pulling in an external JAR file.
		</p>
		
		<p>
			The Jar file only contains a single class, 'HelloWorld', which is outlined below:
		</p>
		
		<cfscript>
			paths = arrayNew(1);
			
			/*
			This points to the jar we want to load. 
			Could also load a directory of .class files
			*/
			paths[1] = expandPath("helloworld.jar");
		
			//create the loader
			loader = createObject("component", "JavaLoader").init(paths);
			
			//at this stage we only have access to the class, but we don't have an instance
			HelloWorld = loader.create("HelloWorld");
			
			/*
			Create the instance, just like me would in createObject("java", "HelloWorld").init()
			This also could have been done in one line - loader.create("HelloWorld").init();
			*/
			hello = HelloWorld.init();	
		</cfscript>
		
		<p>I say: Hello Java!  <br/>
		   Java says: 
			<!--- let's say hello --->
			<cfoutput>#hello.hello()#</cfoutput>
		</p>
		
HelloWorld.java
<pre>
public class HelloWorld
{
	public HelloWorld()
	{
		//do nothing
	}
	
	public String hello()
	{
		return "Hello World";
	}
}
</pre>		
	</body>
</html>


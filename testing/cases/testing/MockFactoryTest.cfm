<cfscript>
factory = createObject("component","coldbox.system.testing.MockFactory").init();
Test = factory.createMock("Test");
</cfscript>

<cfoutput>
<h1>Mocking Methods</h1>
Normal Test.getData() = #test.getData()#<br />

NOT MOCKED: Method called #test.mockMethodCallCount("getData")# times<br />
<cfset test.mockMethod("getData",1000)>
Mock Method called #test.mockMethodCallCount("getData")# times<br />
Mocked Test.getData() = #test.getData()#<br />
Mocked Test.getData() = #test.getData()#<br />
Mock Method called #test.mockMethodCallCount("getData")# times

<hr />

<h1>Mocking Properties</h1>
Original Reload property value: #test.getReload()#<br />
<cfset test.mockProperty(propertyName="reload",mockObject=true)>
Mocked Reload Property value:  #test.getReload()#<br />

<hr />
<h1>Mocking Private Methods</h1>
Normal Test.getFullName() = #test.getFullName()#<br />

<cfset test.mockMethod("getName","My Mock Name")>
Mocked Test.getFullName() = #test.getFullName()#<br />

</cfoutput>

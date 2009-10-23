<cfset test = {name="luis",age="2",test=[1,34,5]}>
<cfset obj = createObject("component","coldbox.testing.testmodel.formBean")>
<cfdump var="#test#">

<cfset converter = createObject("component","coldbox.system.core.util.conversion.ObjectMarshaller").init()>

<cfdump var="#converter.serializeObject(test)#">
<cfdump var="#converter.serializeObject(obj)#">

<cfset client.test = converter.serializeObject(test)>

<cfdump var="#client#">


<cfset des = objectLoad(toBinary(client.test))>
<cfdump var="#des#">
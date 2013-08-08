<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Declare as many rule elements as you want, order is important 
Remember that the securelist can contain a list of regular
expression if you want

ex: All events in the user handler
 user\..*
ex: All events
 .*
ex: All events that start with admin
 ^admin

If you are not using regular expression, just write the text
that can be found in an event.
        <whitelist>ehSecurity\.dspLogin,ehSecurity\.doLogin,ehSecurity\.dspLogoff</whitelist>

-->
<rules>
    <rule>
        <whitelist>ehUser\..*</whitelist>
        <securelist>^ehSecure</securelist>
        <roles>Administrator</roles>
        <permissions></permissions>
        <redirect>ehGeneral.dspLogin</redirect>
    </rule>
    <rule>
        <whitelist>ehGeneral\..*,ehNoMethods\..*,ehProxy\..*,default\..*,ehNoMethods\..*,baseHandler\..*,testing\..*</whitelist>
        <securelist>^abcdef</securelist>
        <roles>User,Administrator</roles>
        <permissions></permissions>
        <redirect>ehGeneral.dspLogin</redirect>
    </rule>
</rules>

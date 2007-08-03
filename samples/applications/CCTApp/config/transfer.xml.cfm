<?xml version="1.0" encoding="UTF-8"?>
<transfer xsi:noNamespaceSchemaLocation="xsd/transfer.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

<objectDefinitions>
	
<package name="AppUser">
	<object name="AppUser" table="AppUser" decorator="coldbox.samples.applications.CCTApp.model.appUser.appUserDecorator" >
		<id name="AppUserId" type="UUID" generate="true"   />
			<property name="Username" type="string" nullable="false" />
			<property name="Password" type="string" nullable="false" />
			<property name="FirstName" type="string" nullable="false" />
			<property name="LastName" type="string" nullable="false" />
			<property name="Email" type="string" nullable="false" />
			<property name="UpdatedOn" type="date" nullable="false" />
			<property name="CreatedOn" type="date" ignore-update="true" />
			<property name="isActive" type="boolean" nullable="false" />
	</object>
</package>

</objectDefinitions>
	
</transfer>
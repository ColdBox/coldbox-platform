<?xml version="1.0" encoding="UTF-8"?>
<transfer xsi:noNamespaceSchemaLocation="transfer.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<objectCache>
		<defaultcache>
			<maxobjects value="100" />
			<maxminutespersisted value="30" />
		</defaultcache>
	</objectCache>
	<objectDefinitions>
		<package name="user">
			<object name="User" table="users" decorator="coldbox.samples.applications.securitysample.model.decorators.User">
				<id name="userId" column="usr_id" type="numeric" generate="false" />
				<property name="password" type="string" nullable="false" column="usr_password" />
				<property name="firstName" type="string" nullable="false" column="usr_firstname"/>
				<property name="lastName" type="string" nullable="false" column="usr_lastname"/>
				<property name="email" type="string" nullable="false" column="usr_email"/>
				<property name="updatedOn" type="date" nullable="false" column="usr_updatedon" />
				<property name="createdOn" type="date" ignore-update="true" column="usr_createdon" />
				<property name="isActive" type="boolean" nullable="false" column="usr_isActive"/>
				<manytoone name="UserType">
					<link column="ust_id" to="user.UserType" />
				</manytoone>
			</object>
			<object name="UserType" table="usertypes">
				<id name="userTypeId" column="ust_id" type="numeric" generate="false" />
				<property name="name" type="string" nullable="false" column="ust_name" />
			</object>
		</package>
	</objectDefinitions>
</transfer>
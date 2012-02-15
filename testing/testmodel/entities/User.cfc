component persistent="true" table="users"{

	property name="id" column="user_id" fieldType="id" generator="uuid";
	/**
	 * @display First Name
	 * @message Please provide firstname
	 * @NotEmpty
	 */
	property name="firstName";
	/**
	 * @display Last Name
	 * @message Please provide lastname
	 * @NotEmpty
	 */
	property name="lastName";
	property name="userName";
	property name="password";
	property name="lastLogin" ormtype="date";
	
	// M20 -> Role
	property name="role" cfc="Role" fieldtype="many-to-one" fkcolumn="FKRoleID" lazy="true" notnull="false";
	
	// DI Test
	property name="testDI" inject="model:testService" persistent="false";
	property name="controller" inject="coldbox" persistent="false";

}
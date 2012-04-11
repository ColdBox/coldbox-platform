component persistent="true" entityname="ActiveUser" table="users" extends="coldbox.system.orm.hibernate.ActiveEntity"{

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
	property name="wirebox" inject="wirebox" persistent="false";
	
	// Constraints
	this.constraints = {
		firstName = {required=true}, lastName = {required=true}, username={required=true,min=5}, password={required=true,min=6}
	};
}
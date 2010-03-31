component persistent="true" table="users"{

	property name="id" column="user_id" fieldType="id" generator="uuid";
	property name="firstName";
	property name="lastName";
	property name="userName";
	property name="password";
	property name="lastLogin" ormtype="date";
}
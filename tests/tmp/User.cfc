component persistent = "true" table = "users"{

	property name="ref1" inject="tests.tmp.Ref1";
	property name="ref2" inject="tests.tmp.Ref2";
	property name="ref3" inject="tests.tmp.Ref2";
	property name="ref4" inject="tests.tmp.Ref2";
	property name="ref5" inject="tests.tmp.Ref2";
	property name="ref6" inject="tests.tmp.Ref2";

	property name="ref7" inject="tests.tmp.Ref1";
	property name="ref8" inject="tests.tmp.Ref1";
	property name="ref9" inject="tests.tmp.Ref1";
	property name="ref10" inject="tests.tmp.Ref1";

	property
		name     ="id"
		column   ="user_id"
		fieldType="id"
		generator="uuid";
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
	property
		name     ="role"
		cfc      ="Role"
		fieldtype="many-to-one"
		fkcolumn ="FKRoleID"
		lazy     ="true"
		notnull  ="false";

	// DI Test
	property
		name      ="testDI"
		inject    ="model:testService"
		persistent="false"
		required  ="false";
	// property name="controller" inject="coldbox" persistent="false" required="false";

	sleep( randRange( 1, 5 ) );

}

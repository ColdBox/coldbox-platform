component displayname="ConcreteService" extends="AbstractService" hint="ConcreteService - Value Object Bean Class" output="false" accessors="true"
{

	property name="someCharlieDAO" type="any";
	property name="someDeltaDAO" type="any";

	/**
	 * @hint constructor method
	 * @output false
	 */
	public ConcreteService function init()
	{
		return this;
	}

	/***************************************************
	 *                public method(s)                 *
	 ***************************************************/

	/***************************************************
	 *                 private method(s)               *
	 ***************************************************/

}
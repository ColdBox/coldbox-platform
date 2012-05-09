component displayname="ConcreteService" extends="AbstractService" hint="ConcreteService - Value Object Bean Class" output="false" accessors="true" autowire="true"
{

	property name="someCharlieDAO" type="ioc" inject;
	property name="someDeltaDAO" type="ioc" inject;

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
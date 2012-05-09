component displayname="AbstractService" hint="AbstractService - Abstract Bean Class" output="false" accessors="true" autowire="true"
{

	property name="someAlphaDAO" type="ioc" inject;
	property name="someBravoDAO" type="ioc" inject;

	/**
	 * @hint constructor method
	 * @output false
	 */
	public AbstractService function init()
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
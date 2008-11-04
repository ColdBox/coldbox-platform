<!---
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
LICENSE
Copyright 2008 Brian Kotek & Luis Majano

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

File Name:

	TDOBeanInjectorObserver.cfc (Transfer Decorator Object Bean Injector Observer)

Version: 1.1 Modified for The ColdBox Framework

Description:

	This observer has been modified to work with ColdBox's beanFactory plugin to provide some basic Transfer Decorator
	Support. All credit goes to Brian Kotek, I have just modified his source for inclusion in the framework.

	This is a Transfer Observer that will autowire your Transfer Decorators with matching beans from
	ColdSpring when the Decorator is created. This makes it much easier to create "rich" Decorators that can handle
	much more business logic than standard Transfer Objects. The dependencies are cached by composed BeanInjector component
	for performance. After the first instance of a Decorator is created, all subsequent Decorators of that type will have their
	dependencies injected using cached information. The component is thread-safe. It relies in the composed BeanInjector
	component to perform the autowiring of the Decorator. For full details on the BeanInjector, please see the comments
	at the top of that component.

Usage:

	Usage of the Observer is fairly straightforward. The ColdSpring XML file might look like this:
		
		<!-- coldbox -->
		<bean id="ColdboxFactory" class="coldbox.system.extras.ColdboxFactory" />
		<bean id="Coldbox" factory-bean="ColdBoxFactory" factory-method="getColdbox" singleton="true" />
	   	<bean id="ColdBoxBeanFactory" factory-bean="ColdBoxFactory" factory-method="getPlugin" singleton="true">
	   		<constructor-arg name="plugin">
		       <value>beanFactory</value>
			</constructor-arg>	
	   	</bean>
	   	<bean id="TDOBeanInjectorObserver" class="coldbox.system.extras.transfer.TDOBeanInjectorObserver" lazy-init="false">
			<constructor-arg name="transfer">
				<ref bean="transfer" />
			</constructor-arg>
			<property name="ColdBoxBeanFactory">
				<ref bean="ColdBoxBeanFactory" />
			</property>
		</bean>

		<!-- Transfer Beans -->
		<bean id="transferFactory" class="transfer.transferFactory">
		   <constructor-arg name="datasourcePath"><value>/project/config/datasource.xml</value></constructor-arg>
		   <constructor-arg name="configPath"><value>/project/config/transfer.xml</value></constructor-arg>
		   <constructor-arg name="definitionPath"><value>/project/transfer/definitions</value></constructor-arg>
		</bean>
		<bean id="transfer" factory-bean="transferFactory" factory-method="getTransfer" />

		<!-- Other Beans -->
		<bean id="validatorFactory" class="components.ValidatorFactory" />
		
	Your ColdSpring configuration must be set to inject the Transfer object into the Observer as a constructor argument.
	It must also be set to inject the ColdBoxBeanFactory as a property. The Observer will register itself with Transfer using the
	transfer.addAfterNewObserver() method. To ensure that this happens at application startup, you have two options:

	1. Use the latest version of ColdSpring that supports lazy-init. What this means is that ColdSpring will automatically
	construct all beans that have lazy-init="false" defined in the ColdSpring XML (as the TDOBeanInjectorObserver bean is in
	the above config snippet). You tell ColdSpring to construct all non-lazy beans when you create the BeanFactory:

		<cfset beanFactory.loadBeans(beanDefinitionFile=configFileLocation, constructNonLazyBeans=true) />

	Using this approach, the TDOBeanInjectorObserver will be registerd with Transfer without you have to do anything else.

	2. On older versions of ColdSpring, or if you do not wish to use the lazy-init capability, the only additional step
	required is to create an instance of the Observer after you initialize ColdSpring, like this:

		<cfset beanFactory.loadBeans(beanDefinitionFile=configFileLocation) />
		<cfset beanFactory.getBean('TDOBeanInjectorObserver') />

	This ensures that the Observer is constructed and registers itself with Transfer.

	Decorators can follow the same rules of cfproperty or setter injection as specified by the coldbox autowire guide.
	
	<!--- PROPERTY ANNOTATIONS --->
	<cfproperty name="ValidatorFactory" type="ioc" scope="instance">
	
	<!--- SETTER INJECTION --->
	<cffunction name="setValidatorFactory" access="public" returntype="void" output="false" hint="I set the ValidatorFactory.">
		<cfargument name="validatorFactory" type="any" required="true" hint="ValidatorFactory" />
		<cfset variables.instance.validatorFactory = arguments.validatorFactory />
	</cffunction>
	
	Once the Observer is registered with Transfer, any time you create a Transfer Decorator, the Observer will
	automatically inject any dependent beans into it at creation time. So in the above example, as soon as the
	Decorator is created, it will automatically have the ValidatorFactory injected into it via the setValidatorFactory()
	method. The end result is that any setters in your Decorators that have matching bean IDs in ColdSpring will have those
	beans injected automatically. As an additional example, a bean with an ID of "productService" would be autowired
	into a Decorator that had a public setter method named setProductService(), and so on.
	
	Thanks to ColdBox, you can also inject your decorators with keys from the ColdBox cache by using the cfproperty approach
	
	<cfproperty name="MyKey" type="ocm" scope="instance">


	Please read the guides in the wiki to see how to use the beanfactory
	

--->
<cfcomponent name="TDOBeanInjectorObserver" hint="A transfer decorator observer injector for the ColdBox Framework">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- Init --->
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<!--- ************************************************************* --->
		<cfargument name="transfer"			  	required="true"		type="any" 		 hint="The transfer.transfer object" />
		<cfargument name="ColdBoxBeanFactory" 	required="true"		type="any" 		 hint="The coldbox bean factory"/>
		<cfargument name="useSetterInjection" 	required="false" 	type="boolean" 	default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<cfargument name="onDICompleteUDF" 		required="false" 	type="string"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="debugMode" 			required="false" 	type="boolean"  default="false" hint="Whether to log debug messages. Default is false">
		<cfargument name="stopRecursion" 		required="false" 	type="string"   default="transfer.com.TransferDecorator" hint="The stop recursion class. Ex: transfer.com.TransferDecorator">
		<!--- ************************************************************* --->
		<cfscript>
			/* Add Observer */
			arguments.transfer.addAfterNewObserver(this);
			
			/* Add Other Dependencies*/
			setColdboxBeanFactory(arguments.ColdBoxBeanFactory);
			setDebugMode(arguments.debugMode);
			setuseSetterInjection(arguments.useSetterInjection);
			setonDICompleteUDF(trim(arguments.onDICompleteUDF));
			setStopRecursion(trim(arguments.stopRecursion));
									
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!---------------------------------------- PUBLIC --------------------------------------------------->

	<!--- Observer --->
	<cffunction name="actionAfterNewTransferEvent" hint="Do something on the new object" access="public" returntype="void" output="false">
	    <!--- ************************************************************* --->
		<cfargument name="event" type="any" required="Yes" hint="The transfer.com.events.TransferEvent">
		<!--- ************************************************************* --->
		<!--- Autowire the decorator --->
		<cfset getColdBoxBeanFactory().autowire(target=arguments.event.getTransferObject(),
												useSetterInjection=getUseSetterInjection(),
												onDICompleteUDF=getonDICompleteUDF(),
												debugMode=getDebugMode(),
												stopRecursion=getStopRecursion() )>
	</cffunction>

<!---------------------------------------- PRIVATE --------------------------------------------------->
	
	<!--- ColdBox Bean Factory --->
	<cffunction name="getColdBoxBeanFactory" access="private" returntype="any" output="false">
		<cfreturn instance.ColdBoxBeanFactory>
	</cffunction>
	<cffunction name="setColdBoxBeanFactory" access="private" returntype="void" output="false">
		<cfargument name="ColdBoxBeanFactory" type="any" required="true">
		<cfset instance.ColdBoxBeanFactory = arguments.ColdBoxBeanFactory>
	</cffunction>
	
	<!--- Use Setter INjection --->
	<cffunction name="getuseSetterInjection" access="private" returntype="boolean" output="false">
		<cfreturn instance.useSetterInjection>
	</cffunction>
	<cffunction name="setuseSetterInjection" access="private" returntype="void" output="false">
		<cfargument name="useSetterInjection" type="boolean" required="true">
		<cfset instance.useSetterInjection = arguments.useSetterInjection>
	</cffunction>
	
	<!--- Debug Mode --->
	<cffunction name="getdebugMode" access="private" returntype="boolean" output="false">
		<cfreturn instance.debugMode>
	</cffunction>
	<cffunction name="setdebugMode" access="private" returntype="void" output="false">
		<cfargument name="debugMode" type="boolean" required="true">
		<cfset instance.debugMode = arguments.debugMode>
	</cffunction>
	<!--- onDICompleteUDF --->
	<cffunction name="getonDICompleteUDF" access="private" returntype="string" output="false">
		<cfreturn instance.onDICompleteUDF>
	</cffunction>
	<cffunction name="setonDICompleteUDF" access="private" returntype="void" output="false">
		<cfargument name="onDICompleteUDF" type="string" required="true">
		<cfset instance.onDICompleteUDF = arguments.onDICompleteUDF>
	</cffunction>
	<!--- Stop Recursion String --->
	<cffunction name="getstopRecursion" access="public" output="false" returntype="string" hint="Get stopRecursion">
		<cfreturn instance.stopRecursion/>
	</cffunction>	
	<cffunction name="setstopRecursion" access="public" output="false" returntype="void" hint="Set stopRecursion">
		<cfargument name="stopRecursion" type="string" required="true"/>
		<cfset instance.stopRecursion = arguments.stopRecursion/>
	</cffunction>

</cfcomponent>
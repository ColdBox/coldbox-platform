<?xml version="1.0" encoding="UTF-8"?>
<beans default-autowire="byName">    
    
    <bean id="ColdboxFactory" class="coldbox.system.ioc.ColdboxFactory" />
    
	<bean id="ConfigBean" factory-bean="ColdboxFactory" factory-method="getConfigBean" />
	
	<bean id="LoggerPlugin" factory-bean="ColdboxFactory" factory-method="getPlugin">
	    <constructor-arg name="plugin">
	        <value>Logger</value>
	    </constructor-arg>
	</bean>
	
	<bean id="myDatasource" factory-bean="ColdboxFactory" factory-method="getDatasource" lazy-init="true">
	    <constructor-arg name="alias">
	        <value>mysite</value>
	    </constructor-arg>
	</bean>
	
	<bean id="myMailSettings" factory-bean="ColdboxFactory" factory-method="getMailSettings" />
	
	<bean id="security" class="coldbox.testing.testmodel.security" />

	
</beans>
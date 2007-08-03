<?xml version="1.0" encoding="UTF-8"?>
<beans default-autowire="byName">    
    
    <bean id="ColdboxFactory" class="coldbox.system.extras.ColdboxFactory" />
    
	<bean id="ConfigBean" factory-bean="ColdboxFactory" factory-method="getConfigBean" />
	
	<bean id="loggerPlugin" factory-bean="ColdboxFactory" factory-method="getPlugin">
	    <constructor-arg name="name">
	        <value>logger</value>
	    </constructor-arg>
	</bean>
	
    <bean id="testModel" class="coldbox.model.testModel" singleton="false">
        <property name="controller">
            <bean id="controller" factory-bean="ColdBoxFactory" factory-method="getColdbox" />
        </property>
        <property name="ConfigBean">
            <ref bean="ConfigBean" />
        </property>
        <property name="logger">
            <ref bean="loggerPlugin" />
        </property>
        <property name="cacheManager">
            <bean id="cacheManager" factory-bean="ColdboxFactory" factory-method="getColdboxOCM" />
        </property>
    </bean>
	
</beans>
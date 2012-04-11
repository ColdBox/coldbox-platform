<?xml version="1.0" encoding="UTF-8"?>
<beans default-autowire="byName" default-lazy-init="true">    
    
    <bean id="ColdboxFactory" class="coldbox.system.ioc.ColdboxFactory" lazy-init="false" />
    
    <bean id="myMailSettings" factory-bean="ColdboxFactory" factory-method="getMailSettings" />
    
    <bean id="ConfigBean" factory-bean="ColdboxFactory" factory-method="getConfigBean" />
    
    <alias name="LoggerPlugin" alias="Logger" />
    <bean id="LoggerPlugin" factory-bean="ColdboxFactory" factory-method="getPlugin">
        <constructor-arg name="plugin">
            <value>Logger</value>
        </constructor-arg>
    </bean>
    
    <alias name="myDatasource" alias="dsn,mydsn" />
    <bean id="myDatasource" factory-bean="ColdboxFactory" factory-method="getDatasource">
        <constructor-arg name="alias">
            <value>mysite</value>
        </constructor-arg>
    </bean>
    
    <bean id="testService" class="coldbox.testharness.model.testService" singleton="true" >
        <property name="testGateway">
            <bean class="coldbox.testharness.model.testGateway" />
        </property>
    </bean>
    
    <bean id="testModel" class="coldbox.testharness.model.testModel" singleton="true">
        <constructor-arg name="UpdateWS"><ref bean="UpdateWS" /></constructor-arg>
        <constructor-arg name="Test"><value>Test</value></constructor-arg>
        
        <property name="controller">
            <bean id="controller" factory-bean="ColdBoxFactory" factory-method="getColdbox" />
        </property>
        <property name="ConfigBean">
            <ref bean="ConfigBean" />
        </property>
        <property name="Logger">
            <ref bean="LoggerPlugin" />
        </property>
        <property name="cacheManager">
            <bean id="cacheManager" factory-bean="ColdboxFactory" factory-method="getColdboxOCM" />
        </property>
		<property name="datasource">
			<ref bean="mydsn" />
        </property>
		<property name="mailsettings">
			<ref bean="myMailSettings" />
        </property>
        <property name="StringBuffer">
            <ref bean="StringBuffer" />
        </property>
        
        <property name="UpdateWS">
            <ref bean="UpdateWS" />
        </property>
    </bean>
	
</beans>
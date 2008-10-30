<?xml version="1.0" encoding="UTF-8"?>
<beans default-autowire="byName" default-lazy-init="true">    
    
    <bean id="ColdboxFactory" class="coldbox.system.extras.ColdboxFactory" lazy-init="false" />
    
	<bean id="ConfigBean" factory-bean="ColdboxFactory" factory-method="getConfigBean" />
	
	<bean id="loggerPlugin" factory-bean="ColdboxFactory" factory-method="getPlugin">
	    <constructor-arg name="plugin">
	        <value>logger</value>
	    </constructor-arg>
	</bean>
	
	<bean id="myDatasource" factory-bean="ColdboxFactory" factory-method="getDatasource">
	    <constructor-arg name="alias">
	        <value>mysite</value>
	    </constructor-arg>
	</bean>
	
	<bean id="myMailSettings" factory-bean="ColdboxFactory" factory-method="getMailSettings" />
	
	<bean id="StringBuffer" class="java.lang.StringBuffer" type="java" singleton="false" />
	
    <bean id="UpdateWS" class="http://www.coldboxframework.com/distribution/updatews.cfc?wsdl" type="webservice" />
	
    <bean id="testModel" class="coldbox.testharness.model.testModel" singleton="true" lazy-init="false">
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
		<property name="datasource">
			<ref bean="myDatasource" />
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
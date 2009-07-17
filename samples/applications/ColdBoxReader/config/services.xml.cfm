<?xml version="1.0" encoding="UTF-8"?>
<beans default-autowire="byName">
    
	<!-- ColdBox Related Beans -->
	<bean id="ColdboxFactory" class="coldbox.system.extras.ColdboxFactory" autowire="no" />
    <bean id="datasourceBean" factory-bean="ColdBoxFactory" factory-method="getDatasource">
		<constructor-arg name="alias">
			<value>coldboxreader</value>
		</constructor-arg>
	</bean>
	<bean id="feedReader" factory-bean="ColdBoxFactory" factory-method="getPlugin">
		<constructor-arg name="plugin">
			<value>feedReader</value>
		</constructor-arg>
	</bean>
	
    <bean id="feedDAO"
        class="coldbox.samples.applications.ColdBoxReader.components.dao.feed" singleton="false">
        <constructor-arg name="dsnBean">
            <ref bean="datasourceBean"/>
        </constructor-arg>
    </bean>
    
    <bean id="feedService"
        class="coldbox.samples.applications.ColdBoxReader.components.services.feedService" singleton="true">
        <constructor-arg name="feedDAO">
            <ref bean="feedDAO"/>
        </constructor-arg>
        <constructor-arg name="ModelBasePath">
            <value>${ModelBasePath}</value>
        </constructor-arg>
		<constructor-arg name="feedReader">
			<ref bean="feedReader" />
		</constructor-arg>
    </bean>
    
    <bean id="tagDAO"
        class="coldbox.samples.applications.ColdBoxReader.components.dao.tags" singleton="false">
        <constructor-arg name="dsnBean">
            <ref bean="datasourceBean"/>
        </constructor-arg>
    </bean>
    
    <bean id="tagService"
        class="coldbox.samples.applications.ColdBoxReader.components.services.tagService" singleton="true">
        <constructor-arg name="tagDAO">
            <ref bean="tagDAO"/>
        </constructor-arg>
        <constructor-arg name="ModelBasePath">
            <value>${ModelBasePath}</value>
        </constructor-arg>
    </bean>
    
    <bean id="usersDAO"
        class="coldbox.samples.applications.ColdBoxReader.components.dao.users" singleton="false">
        <constructor-arg name="dsnBean">
            <ref bean="datasourceBean"/>
        </constructor-arg>
    </bean>
    
    <bean id="userBean"
        class="coldbox.samples.applications.ColdBoxReader.components.beans.userBean" singleton="false">
    </bean>
    
    <bean id="userService"
        class="coldbox.samples.applications.ColdBoxReader.components.services.userService" singleton="true">
        <constructor-arg name="usersDAO">
            <ref bean="usersDAO"/>
        </constructor-arg>
        <constructor-arg name="ModelBasePath">
            <value>${ModelBasePath}</value>
        </constructor-arg>
		<constructor-arg name="OwnerEmail">
             <value>${OwnerEmail}</value>
        </constructor-arg>
    </bean>
    
</beans>
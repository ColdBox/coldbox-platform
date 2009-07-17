<?xml version="1.0" encoding="UTF-8"?>
<beans default-autowire="byName">
	
	<!-- Coldbox Factory -->
	<bean id="ColdboxFactory" class="coldbox.system.extras.ColdboxFactory" singleton="true"/>
	
	
	<!-- coldbox bean factory -->
	<bean id="ColdBoxBeanFactory" factory-bean="ColdBoxFactory" factory-method="getPlugin" singleton="true">
		<constructor-arg name="plugin">
	    	<value>beanFactory</value>
		</constructor-arg>   
	</bean>
	
	
	<!-- Datasource -->
	<bean id="blogDSN" factory-bean="ColdBoxFactory" factory-method="getDatasource">
		<constructor-arg name="alias">
	    	<value>${TransferDSNAlias}</value>
		</constructor-arg>
	</bean>
	
	
	<!-- Coldbox-transfer Config Factory -->
	<bean id="TransferConfigFactory" class="coldbox.system.extras.transfer.TransferConfigFactory" singleton="true" />
	
	
	<!-- Transfer Factory-->
	<bean id="TransferFactory" class="transfer.TransferFactory" singleton="true">
	   <constructor-arg name="configuration">
	      <bean factory-bean="TransferConfigFactory" factory-method="getTransferConfig">
	         <!-- Config Path -->
	         <constructor-arg name="configPath"><value>${TransferConfigPath}</value></constructor-arg>
	         <!-- Definitions Path -->
	         <constructor-arg name="definitionPath"><value>${TransferDefinitionsPath}</value></constructor-arg>
	         <!-- ColdBox Datasource Bean -->
	         <constructor-arg name="dsnBean"><ref bean="blogDSN" /></constructor-arg>
	      </bean>
	   </constructor-arg>
	</bean>
	
	
	<!-- GetTransfer -->
	<bean id="Transfer" factory-bean="TransferFactory" factory-method="getTransfer" />
	
	
	<!-- CommentService -->
	<bean id="CommentService" class="simple_blog_4.model.comments.CommentService" lazy-init="true" singleton="true">
		<constructor-arg name="transfer"><ref bean="Transfer" /></constructor-arg>
	</bean>
	
	
	<!-- EntryService -->
	<bean id="EntryService" class="simple_blog_4.model.entries.EntryService" lazy-init="true" singleton="true">
		<constructor-arg name="transfer"><ref bean="Transfer" /></constructor-arg>
	</bean>
	
	
	<!-- feedGenPlugin -->
	<bean id="feedGenPlugin" factory-bean="ColdboxFactory" factory-method="getPlugin">
		<constructor-arg name="plugin">
			<value>feedGenerator</value>
		</constructor-arg>
	</bean>
	
	
	<!-- RSSService -->
	<bean id="RSSService" class="simple_blog_4.model.rss.RSSService" lazy-init="true" singleton="true">
		<constructor-arg name="transfer"><ref bean="Transfer" /></constructor-arg>
		<constructor-arg name="feedGenPlugin"><ref bean="feedGenPlugin" /></constructor-arg>
		<constructor-arg name="EntryService"><ref bean="EntryService" /></constructor-arg>
		<constructor-arg name="baseUrl"><value>${sesBaseURL}</value></constructor-arg>
	</bean>
	
	
	<!-- DateUtil -->
	<bean id="DateUtil" class="simple_blog_4.model.utilities.DateUtil" lazy-init="true" singleton="true"/>
	
	
	<!-- coldbox-transfer observer -->
	<bean id="TDOBeanInjectorObserver" class="coldbox.system.extras.transfer.TDOBeanInjectorObserver" lazy-init="false">
		<constructor-arg name="Transfer"><ref bean="Transfer"></ref></constructor-arg>
		<constructor-arg name="ColdBoxBeanFactory"><ref bean="ColdBoxBeanFactory"></ref></constructor-arg>
	</bean>


	<!-- UserService -->
	<bean id="UserService" class="simple_blog_4.model.users.UserService" />


	<!-- securityRulesBean -->
	<bean id="securityRulesBean" class="simple_blog_4.config.securityRules.xml.cfm" />

	
	<!-- securityService -->
	<bean id="SecurityService" class="simple_blog_4.model.security.SecurityService" lazy-init="true" singleton="true">
		<constructor-arg name="Transfer"><ref bean="Transfer" /></constructor-arg>
		<constructor-arg name="UserService"><ref bean="UserService" /></constructor-arg>
	</bean>
	
</beans>
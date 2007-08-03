<?xml version="1.0" encoding="UTF-8"?>
<beans>
	<bean id="coldboxFactory" class="coldbox.system.extras.ColdboxFactory" />
	<bean id="coldbox" factory-bean="ColdBoxFactory" factory-method="getColdbox" singleton="true" />

	<!-- transfer integration -->
	<bean id="transferFactory" class="transfer.TransferFactory" singeleton="true">
		<constructor-arg name="datasourcePath">
			<value>${TransferSettings.datasourcePath}</value>
		</constructor-arg>
		<constructor-arg name="configPath">
		   <value>${TransferSettings.configPath}</value>
		</constructor-arg>
		<constructor-arg name="definitionPath">
		   <value>${TransferSettings.definitionPath}</value>
		</constructor-arg>
	</bean>
	
	<bean id="transfer" factory-bean="transferFactory" factory-method="getTransfer" singleton="true" />
	<bean id="datasource" factory-bean="transferFactory" factory-method="getDatasource" singleton="true" />

	<bean id="securityService" class="coldbox.samples.applications.CCTApp.model.securityService" singleton="false">
		<constructor-arg name="oColdbox">
            <ref bean="coldbox" />
      	</constructor-arg>
		<constructor-arg name="oTransfer">
            <ref bean="transfer" />
      	</constructor-arg>
	</bean>	

	<bean id="appUserGateway" class="coldbox.samples.applications.CCTApp.model.appUser.appUserGateway">
		<constructor-arg name="oTransfer">
            <ref bean="transfer" />
      	</constructor-arg>
		<constructor-arg name="oDatasource">
            <ref bean="datasource" />
      	</constructor-arg>
	</bean>

    <bean id="appUserService" class="coldbox.samples.applications.CCTApp.model.appUser.appUserService" singleton="false">
		<constructor-arg name="oAppUserGateway">
            <ref bean="appUserGateway" />
      	</constructor-arg>
		<constructor-arg name="oTransfer">
            <ref bean="transfer" />
      	</constructor-arg>
	</bean>
	
</beans>
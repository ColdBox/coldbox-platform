<?xml version="1.0" encoding="UTF-8"?>
<beans default-lazy-init="false">
	
   	<bean id="CategoryDAO" class="coldbox.testing.tests.LightWireXMLTest.com.model.category.CategoryDAO">
		<constructor-arg name="dsn"><value>${dsn}</value></constructor-arg>
	</bean>
	<bean id="CategoryService" class="coldbox.testing.tests.LightWireXMLTest.com.model.category.CategoryService">
		<constructor-arg name="CategoryDAO">
			<ref bean="CategoryDAO"/>
		</constructor-arg>
		<property name="ProductService">
			<ref bean="ProductService" />
		</property>
	</bean>
	<bean id="ProductService" class="coldbox.testing.tests.LightWireXMLTest.com.model.product.ProductService">
		<constructor-arg name="ProdDAO">
			<ref bean="ProdDAO"/>
		</constructor-arg>
		<constructor-arg name="MyTitle">
			<value>My Title Goes Here</value>
		</constructor-arg>
		<constructor-arg name="MyTitle2">
			<value>My Other Title Goes Here</value>
		</constructor-arg>
		<property name="MySetterTitle">
			<value>My Setter Title Goes Here</value>
		</property>
		<mixin name="MyMixinTitle">
			<value>My Mixin Title Goes Here</value>
		</mixin>
		<mixin name="AnotherMixinProperty">
			<value>My Other Mixin Property is Here</value>
		</mixin>
		<mixin name="CategoryService">
			<ref bean="CategoryService"/>
		</mixin>
	</bean>
	<bean id="ProdDAO" class="coldbox.testing.tests.LightWireXMLTest.com.model.product.ProductDAO">
		<constructor-arg name="dsn"><value>${dsn}</value></constructor-arg>
	</bean>
	<bean id="Product" class="coldbox.testing.tests.LightWireXMLTest.com.model.product.ProductBean" singleton="false">
		<constructor-arg name="ProdDAO">
			<ref bean="ProdDAO"/>
		</constructor-arg>
	</bean>
</beans>
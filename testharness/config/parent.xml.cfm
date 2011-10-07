<?xml version="1.0" encoding="UTF-8"?>
<beans default-autowire="byName" default-lazy-init="true">    
    
	<bean id="StringBuffer" class="java.lang.StringBuffer" type="java" singleton="false" />
    
    <bean id="UpdateWS" class="http://www.coldbox.org/distribution/updatews.cfc?wsdl" type="webservice" />
    
	<bean id="MathUtil" class="java.lang.Math" type="java" singleton="true" />
     		
</beans>
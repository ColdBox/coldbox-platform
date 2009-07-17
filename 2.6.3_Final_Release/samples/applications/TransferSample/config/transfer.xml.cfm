<?xml version="1.0" encoding="UTF-8"?>
<transfer xsi:noNamespaceSchemaLocation="../../../../../../transfer/resources/xsd/transfer.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<!--<objectCache>
		<defaultcache>
			<scope type="none" />          
		</defaultcache>
	</objectCache>
	-->
  <objectDefinitions>
  	
	  <package name="users">
          <object name="users" table="users" >
              <id name="id" type="UUID" generate="true"/>
			  <property name="fname" type="string" nullable="false" />
			  <property name="lname" type="string" nullable="false" />
			  <property name="email" type="string" nullable="false" />
			  <property name="create_date" type="date" ignore-update="true" />
          </object>
      </package>
  
  </objectDefinitions>
	
</transfer>
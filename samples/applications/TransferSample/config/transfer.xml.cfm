<?xml version="1.0" encoding="UTF-8"?>
<transfer xsi:noNamespaceSchemaLocation="../../../../../../transfer/resources/xsd/transfer.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <objectDefinitions>
  
	  <package name="users">
          <object name="users" table="users" >
              <id name="id" type="string" generate="false"/>
			  <property name="fname" type="string" nullable="false" />
			  <property name="lname" type="string" nullable="false" />
			  <property name="email" type="string" nullable="false" />
			  <property name="create_date" type="date" ignore-update="true" />
          </object>
      </package>
  
  </objectDefinitions>
	
</transfer>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		
		transfer = getMockBox().createEmptyMock('transfer.com.Transfer').$("addAfterNewObserver");
		transferObject = getMockBox().createEmptyMock('transfer.com.TransferObject');
		transferEvent = getMockBox().createEmptyMock('transfer.com.events.TransferEvent').$('getTransferObject').$results(transferObject);
		
		BeanFactory = getMockBox().createEmptyMock('coldbox.system.plugins.BeanFactory').$('autowire');
		BeanFactory.autowire(this);
		
		observer = createObject("component","coldbox.system.orm.transfer.TDOBeanInjectorObserver");
		observer.init(transfer=transfer,ColdBoxBeanFactory=BeanFactory,useSetterInjection=true,onDICompleteUDF='onComplete',debugMode=true);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testactionAfterNewTransferEvent" access="public" returntype="void" output="false">
		<cfscript>
			observer.actionAfterNewTransferEvent(transferEvent);			
		</cfscript>
	</cffunction>
	
	
	
</cfcomponent>
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Unit Testing for Event Handlers

The following test cases have been created for testing of event handlers, please
note that the controller created is the ColdBox's testcontroller.

The code speaks for itself. Just make sure you base your tests on the baseTest.cfc

Structure:
AllTests.cfc - Test Suite for all test cases
cases/baseTest.cfc - The base test case that all event handlers need to inherit from
cases/ehGeneralTest.cfc - The test case for the ehGeneral.cfc handler
cases/ehMaintTest.cfc - The test case for the ehMain.cfc handler


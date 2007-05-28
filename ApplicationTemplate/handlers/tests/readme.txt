********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Unit Testing for Event Handlers

The following test cases have been created for testing of event handlers.
One of the caveats you have to be aware about is that if an event handler produces
a RELOCATION via setNextEvent()  Your unit tests will fails.

Therefore, in event handler unit tests, please only tests handlers that do not 
relocate or make sure that they do not relocate when unit testing. If not,
YOU WILL RECEIVE ERRORS.

That is the only issue that I know about know. Enjoy your unit testing.
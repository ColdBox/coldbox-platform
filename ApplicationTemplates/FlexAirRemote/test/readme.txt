********************************************************************************
Copyright since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

ColdBox Unit & Integration Testing

The code speaks for itself. Just make sure you tests inherit from the 
ColdBox Base Test Case so you get more testing goodness.

Structure:
- integration (Where you place all your integration tests for handlers)
- mocks (For any mock testing or mock objects)
- resources (where you can drop testing resources, it includes already an MXUnit
	         RemoteFacade.cfc you can configure from eclipse.)
 -unit (For all your unit test cases)
 Application.cfc (So you can configure it as you like for your own testing)
 
SPECIAL CONSIDERATIONS:
Make sure that if you are using any relative paths in your application, that they become
absolute. This is because the unit testing occurs inside of the unit testing framework
which is outside of this app root. So please remember for unit testing to use absolute
mappings on files or references. I recommend also using a test configuration file.
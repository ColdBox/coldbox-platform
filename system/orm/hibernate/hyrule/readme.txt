HyRule Validation Framwork

Project Details
	Name: Hyrule Validation
	Author: Daniel Vega (danvega@gmail.com) ( Sana Ullah Integrated with ColdBox )
	Blog: www.danvega.org/blog/	
	Download: http://hyrule.riaforge.org
	
About
	- The idea for this project came from a couple different sources. First off I really 
	  liked what the QuickSilver framework was doing and how they were taking advantage of 
	  annotations.
	  
	- I also based the idea off of the hibernate validation framework. The implementation is 
	  obviously different because of the difference in languages but the basic constraints are
	  the same
	
Installation
	- drop into your webroot || create a mapping for /hyrule to this folder
 	- navigate to the /samples folder to check out some examples.
 	  
Validators (not all have been implemented yet)

 - ArrayValidator
 - AssertTrueValidator
 - AssertFalseValidator
 - BinaryValidator
 - BooleanValidator
 - CreditCardNumberValidator
 - DateValidator
 - EmailValidator
 - FutureValidator
 - GUIDValidator
 - InListValidator
 - IsMatchValidator
 - MaxValidator
 - MinValidator
 - NotNullValidator
 - NotEmptyValidator
 - NotInListValidator 
 - NumericValidator
 - PastValidator
 - PatternValidator
 - PhoneValidator
 - QueryValidator
 - RangeValidator
 - StructValidator
 - SizeValidator
 - SSNValidator
 - URLValidator
 - UUIDValidator
 - ZipCodeValidator

/resources
 - This folder contains the DefaultValidatorMessages.properties file. This file contains the default
   messages that each validator will produce. By default this is the file thats loaded when
   the validation framework is loaded but if you want to create a new one and load it you can.
   
   hyrule = new hyrule.validator("yourpropfilehere");
   
/samples
 - This folder contains some examples and tutorials.  
 
 
 TODO: 
 
 Rules to work on still
 -----------------------------
 
 PatternValidator
 NotNullValidator
 
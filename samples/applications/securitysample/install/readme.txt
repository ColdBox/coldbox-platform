Transfer Sample Application with security interceptor: ColdBox, Lightwire and Transfer

What you need
===============================
1. Latest ColdBox

2. Transfer ORM version 0.6.3 or higher http://www.transfer-orm.com/?action=transfer.download

3. Coldfusion 7 OR 8 (not tested on BlueDragon)

4. MySql 5 (not tested on other versions)

5. Of course the transfer sample application 

Install
===============================
1. For simplicity, place all the 'frameworks' and this sample application in your webroot,so you will have something like:
	- wwwroot
		- ColdBox
		- Transfer
		- transfersample

2. Create a mysql database using the sql file in the directory install
3. Create a dsn in CF Administrator named transfersample (remark: incase of using an existing dsn, adjust config/datasource.xml.cfm)

Done: check http://localhost/transfersample or http://{yourhostname}/transfersample


Have fun,

Ernst van der Linden
evdlinden@gmail.com

All credits go to: Mark Mandel (Transfer), Peter Bell (Lightwire) and Luis Majano (ColdBox)! 
 



	

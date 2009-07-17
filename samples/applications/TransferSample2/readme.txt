Transfer Sample Application: ColdBox, ColdSpring and Transfer
by Ernst van der Linden


What you need

===============================

1. ColdBox version 2.5.1 http://luismajano.com/index.cfm/Projects/dspColdBoxDownloads



2. Transfer ORM version 0.6.3 http://www.transfer-orm.com/?action=transfer.download



3. ColdSpring 1.0  http://www.coldspringframework.org/index.cfm?objectid=0E3CDEA5-09A7-95BA-41002F092EEDF855



4. Coldfusion 7 OR 8 (not tested on BlueDragon)



5. MySql 5 (not tested on other versions)



6. Of course the transfer sample application 



Install

===============================

1. For simplicity, place all the 'frameworks' and this sample application in your webroot,so you will have something like:

	- wwwroot

		- ColdBox

		- ColdSpring

		- Transfer

		- transfersample



2. Create a mysql database using the sql file in the directory install

3. Create a dsn in CF Administrator named transfersample (remark: incase of using an existing dsn, adjust config/datasource.xml.cfm)



Done: check http://localhost/transfersample or http://{yourhostname}/transfersample





Cheers,



Ernst van der Linden

evdlinden@gmail.com



PS. Special thanks to: Mark Mandel and of course Luis Majano 

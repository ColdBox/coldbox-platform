component persistent="true" table="categories"{

	property name="id" column="category_id" fieldType="id" generator="uuid";
	property name="category" notnull="true";
	property name="description" notnull="true";
	property name="modifydate" insert="false" update="false" ormtype="timestamp"; 
	
	//DI
	property name="cache" inject="coldbox:cacheManager" persistent="false"; 

}

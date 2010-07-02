component persistent="true" table="categories" cachename="categories" cacheuse="read-write"{

	property name="catid" column="category_id" fieldType="id" generator="uuid";
	property name="category" notnull="true";
	property name="description" notnull="true";
	property name="modifydate" insert="false" update="false" ormtype="timestamp"; 

}

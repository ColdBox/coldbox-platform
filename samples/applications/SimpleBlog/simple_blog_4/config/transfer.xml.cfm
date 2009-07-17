<?xml version="1.0" encoding="UTF-8"?>
<transfer xsi:noNamespaceSchemaLocation="transfer.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<objectDefinitions>

		<package name="posts">

			<!--Entry-->
			<object name="entry" table="entries"  decorator="simple_blog_4.model.entries.Entry" >
				<id name="entry_id" column="entry_id" type="UUID" generate="true" />
				<property name="title" 		type="string" />
				<property name="entryBody" 	type="string" />
				<property name="author" 	type="string" />
				<property name="time"		type="date" />
				
				<!--Relation to post-->
				<onetomany name="comment" lazy="true">
					<link to="posts.comment" column="entry_id"/>		
					<collection type="array">
						<order property="time" order="asc"/>
					</collection>
				</onetomany>
			</object>

			<!--Comment-->
			<object name="comment" table="comments">
				<id name="comment_id" column="comment_id" type="UUID" generate="true" />
				<property name="comment"	type="string" />
				<property name="time"		type="date" />
			</object>
			
		</package>
		
		<package name="users">
		
			<!--admin-->
			<object name="user" table="users">
				<id name="user_id" column="user_id" type="numeric" generate="false"/>
				<property name="firstName" type="string"/>
				<property name="lastName" type="string"/>
				<property name="userName" type="string"/>
				<property name="password" type="string"/>
				<property name="userType" type="string"/>
				<property name="lastLogin" type="date"/>
			</object>
		
		</package>

	</objectDefinitions>

</transfer>
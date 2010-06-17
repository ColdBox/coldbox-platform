[[Dashboard | << Back to Dashboard ]] | <a href="/space/Extras.cfm"><< Extras Viewer</a>

{|align="right"
| __TOC__
|}

= Base ORM Service =

== Overview ==

The ''BaseORMService'' is an amazing service layer tool that can be used in any project.  The idea behind this support class is to provide a very good base service layer that can interact with hibernate and entities inspired by [http://static.springsource.org/spring/docs/3.0.x/spring-framework-reference/html/classic-spring.html#classic-spring-hibernate Spring's Hibernate Template] support.  It provides tons of methods for query executions, paging, transactions, session metadata, caching and much more.  You can either use the class on its own or create more concrete service layers by inheriting from this class.  We also have a virtual service layer that can be mapped to specific entities and create entity driven service layers virtually.  ColdBox also offers several integrations to this class via plugins and the autowire DSL.

Let's explore these possibilities before we get to digest the class.

== ORMService Plugin ==
A new plugin exists called ''ORMService'' that extends this base service class and offers a nice integration to this service layer as a plugin:

<source lang="coldfusion">
// A handler
component{
  property name="ORMService" inject="coldbox:plugin:ORMService";

  function saveUser(event){
      // retrieve and popualte a new user object
      var user = populateModel( ORMService.new("User") );

      // save the entity using hibernate transactions
      ORMService.save( user );
     
      setNextEvent("user.list");
  }

  function list(event){
    var rc = event.getCollection();

    //get a listing of all users with paging
    rc.users = ORMService.list(entityName="User",sortBy="fname",offset=event.getValue("startrow",1),max=20);

    event.setView("user/list");
  }
}
</source>

From the example above I inject the plugin and use it as if it was my service layer.

== Autowire DSL ==

The autowiring DSL has been updated to add a new namespace called ''entityService'' that can be used to wire in the ''BaseORMService'' or any virtual entity service that we will discuss further on.

{|cellpadding="5", class="tablelisting"
! '''Type''' !! '''Description''' 
|-
|| entityService || Inject a ''BaseORMService'' object for usage as a generic service layer
|-
|| entityService:{entity} || Inject a ''VirtualEntityService'' object for usage as a service layer based off the name of the entity passed in.
|}

<source lang="coldfusion">
// Generic ORM service layer
property name="genericService" inject="entityService";
// Virtual service layer based on the User entity
property name="userService" inject="entityService:User";
</source>


== Base Properties ==
There are a few properties you can instantiate the base service with or set them afterward.  Below you can see a nice chart for them:


{|cellpadding="5", class="tablelisting"
! '''Property''' !! '''Type''' !! '''Required''' !! '''Default''' !! '''Description''' 
|-
|| '''queryCacheRegion''' || string || false || ''ORMService.defaultCache'' || The name of the secondary cache region to use when doing queries via this base service
|-
|| '''useQueryCaching''' || boolean || false || false || To enable the caching of queries used by this base service
|-
|| '''eventHandling''' || boolean || false || true || The bit that enables event handling via the ORM Event handler such as interceptions when new entities get created, etc,
|}

So if I was to base off my services on top of this gem, I can do this:

<source lang="coldfusion">
import coldbox.system.orm.hibernate.*
component extends="BaseORMService"{
  
  public UserService function init(){
      super.init(useQueryCaching=true);
      return this;	
  }

}
</source>

Let's start digesting all the beautiful methods this support class can offer.


== evictEntity ==
Evict entity objects from session. The argument can be one persistence entity or an array of entities

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entity || any || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
// evict one entity
ORMService.evictEntity( entity );

// evict an array of entities
entities = [ user1, user2 ];
ORMService.evictEntity( entities );
</source>

== getAll ==
Retrieve all the instances from the passed in entity name using the id argument if specified. The id can be a list of IDs or an array of IDs or none to retrieve all. If the id is not found or returns null the array position will have an empty string in it in the specified order

=== Returns ===
* This function returns ''array'' of entities found.

=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|-
| id || any || No || --- || 
|}

=== Examples ===

<source lang="coldfusion">
// Get all user entities
users = ORMService.getAll("User");
// Get all the following users by id's
users = ORMService.getAll("User","1,2,3");
// Get all the following users by id's as array
users = ORMService.getAll("User",[1,2,3,4,5]);

</source>

== save ==
Save an entity using hibernate transactions. You can optionally flush the session also.

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entity || any || Yes || --- || 
|-
| forceInsert || boolean || No || false || 
|-
| flush || boolean || No || false || 
|}

=== Examples ===

<source lang="coldfusion">
var user = ormService.new("User");
populateModel(user);
ormService.save(user);

// Save with immediate flush
var user = ormService.new(entityName="User", lastName="Majano");
ormService.save(entity=user, flush=true);
</source>


== getQueryCacheRegion ==


=== Returns ===
* This function returns ''string''


=== Examples ===

<source lang="coldfusion">
// Give the name of the cache region used for this service
<cfoutput>#ormservice.getQueryCacheRegion()#</cfoutput>
</source>

== count ==

Return the count of instances in the DB for the given entity name. You can also pass an optional where statement that can filter the count. Ex: count('User','age > 40 AND name="joe"'). You can even use named or positional parameters with this method: Ex: count('User','age > ? AND name = ?',[40,"joe"])

=== Returns ===
* This function returns ''numeric''

=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|-
| where || string || No ||  || 
|-
| params || any || No || structnew() || Named or positional parameters
|}

=== Examples ===

<source lang="coldfusion">
// Get the count of instances for all books
ormService.count("Book");
// Get the count for users with age above 40 and named Bob
ormService.count("User","age > 40 AND name='Bob');
// Get the count for users with passed in positional parameters
ormService.count("User","age > ? AND name=?",[40,'Bob']);
// Get the count for users with passed in named parameters
ormService.count("Post","title like :title and year = :year",{title="coldbox",year="2007"}):
</source>


== sessionContains ==
Checks if the current session contains the passed in entity

=== Returns ===
* This function returns ''boolean''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entity || any || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
function checkSomething( any User ){
  // check if User is already in session
  if( NOT ormService.sessionContains( arguments.User ) ){
     // Not in hibernate session, so merge it in.
     ormService.merge( arguments.User );
  }
}
</source>

== delete ==
Delete an entity using hibernate transactions. The entity argument can be a single entity or an array of entities. You can optionally flush the session also after committing

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entity || any || Yes || --- || 
|-
| flush || boolean || No || false || 
|}

=== Examples ===

<source lang="coldfusion">
var post = ormService.get(1);
ormService.delete( post );

// Delete a flush immediately
ormService.delete( post, true );

</source>


== getTableName ==
Returns the table name of the passed in entity

=== Returns ===
* This function returns ''string''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
var persistedTable = ormService.getTableName( "Category" );
</source>

== setQueryCacheRegion ==
Override the name of the default cache region name used for secondary level caching or coldbox caching.

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| queryCacheRegion || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
ormService.setQueryCacheRegion( 'MyAwesomeUserCache' );
</source>

== findWhere ==
Find one entity or null if not found according to the passed in name value pairs into the function ex: findWhere(entityName="Category", category="Training"), findWhere(entityName="Users", age=40);

=== Returns ===
* This function returns ''any''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
// Find a category according to the named value pairs I pass into this method
var category = ormService.findWhere(entityName="Category", isActive=true, label="Training");
var user = ormService.findWhere(entityName="User", isActive=true, username=rc.username,password=rc.password);
</source>


== getKey ==
Returns the key (id field) of a given entity, either simple or composite keys. If the key is a simple pk then it will return a string, if it is a composite key then it returns an array

=== Returns ===
* This function returns ''any''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
var pkField = ormService.getKey( "User" );
</source>

== merge ==
Merge an entity or array of entities back into the session

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entity || any || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
// merge a single entity back
ormService.merge( userEntity );
// merge an array of entities
collection = [entity1,entity2,entity3];
ormService.merge( collection );
</source>

== evictQueries ==
Evict all queries in the default cache or the cache region that is passed in.

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| cacheName || string || No || --- || 
|}

=== Examples ===

<source lang="coldfusion">
// evict queries that are in the default hibernate cache
ormService.evictQueries();
// evict queries for this service
ormService.evictQueries( ormService.getQueryCacheRegion() );
// evict queries for my artists
ormService.evictQueries( "MyArtits" );
</source>

== findAll ==
Find all the entities for the specified query, named or positional arguments or by an example entity

=== Returns ===
* This function returns ''array''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| query || string || No || --- || 
|-
| params || any || No || [runtime expression] || 
|-
| offset || numeric || No || 0 || 
|-
| max || numeric || No || 0 || 
|-
| example || any || No || --- || 
|}

=== Examples ===

<source lang="coldfusion">
// find all blog posts
ormService.findAll("Post");
// with a positional parameters
ormService.findAll("from Post as p where p.author=?",['Luis Majano']);
// 10 posts from Luis Majano staring from 5th post ordered by release date
ormService.findAll("from Post as p where p.author=? order by p.releaseDate",['Luis majano'],offset=5,max=10);

// Using paging params
var query = "from Post as p where p.author='Luis Majano' order by p.releaseDate" 
// first 20 posts 
ormService.findAll(query=query,max=20) 
// 20 posts starting from my 15th entry
ormService.findAll(query=query,max=20,offset=15);

// examples with named parameters
ormService.findAll("from Post as p where p.author=:author", {author='Luis Majano'})
ormService.findAll("from Post as p where p.author=:author", {author='Luis Majano'}, max=20, offset=5);

// query by example
user = ormService.new(entityName="User",firstName="Luis");
ormService.findAll( example=user );
</source>


== deleteByQuery ==

Delete by using an HQL query and iterating via the results, it is not performing a delete query but it actually is a select query that should retrieve objects to remove

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| query || string || Yes || --- || 
|-
| params || any || No || --- || 
|-
| max || numeric || No || 0 || 
|-
| offset || numeric || No || 0 || 
|-
| flush || boolean || No || false || 
|}

=== Examples ===

<source lang="coldfusion">
// delete all blog posts
ormService.deleteByQuery("from Post");
// delete query with positional parameters
ormService.deleteByQuery("from Post as b where b.author=? and b.isActive = :active",['Luis Majano',false]);

// Use query options
var query = "from User as u where u.isActive=false order by u.creationDate desc"; 
// first 20 stale inactive users 
ormService.deleteByQuery(query=query,max=20); 
// 20 posts starting from my 15th entry
ormService.deleteByQuery(query=query,max=20,offset=15,flush=true);

// examples with named parameters
ormService.deleteByQuery("from Post as p where p.author=:author", {author='Luis Majano'})
</source>

== isSessionDirty ==
Checks if the session contains dirty objects that are awaiting persistence

=== Returns ===
* This function returns ''boolean''


=== Examples ===

<source lang="coldfusion">
// Check if by this point we have a dirty session, then flush it
if( ormService.isSessionDirty() ){
  ORMFlush();
}
</source>


== deleteByID ==
Delete using an entity name and an incoming id, you can also flush the session if needed. The method returns false if the passed in entityName and id is not found in the database.

=== Returns ===
* This function returns ''boolean''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|-
| id || any || Yes || --- || 
|-
| flush || boolean || No || false || 
|}

=== Examples ===

<source lang="coldfusion">
// just delete
results = ormService.deleteByID("User",1);

// delete and flush
results = ormService.deleteByID("User",4,true);

</source>

== setUseQueryCaching ==

Turn on/off the usage of secondary caching level

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| useQueryCaching || boolean || Yes || --- || 
|}

=== Examples ===
<source lang="coldfusion">
ormService.setUseQueryCaching( true );
</source>


== new ==
Get a new entity object by entity name. You can also pass in a structure called properties that will be used to populate
the new entity with or you can use optional named paramters to call setters within the new entity to have shorthand population.

=== Returns ===
* This function returns ''any''

=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || any || true || --- || 
|-
|| properties || struct || false || {} || A structure of name-value pairs to populate the new entity with
|}

=== Examples ===

<source lang="coldfusion">
// return empty post entity
var post = ormService.new("Post");

// create a new user entity with pre-defined params
var user = ormService.new(entityName="User", firstName="Luis", lastName="Majano", age="32", awesome=true);

// Create a new user entity with properties binded
var user = ormService.new("User",{fname="Luis",lname="Majano",cool=false,awesome=true});
</source>


== getSessionStatistics ==
Information about the first-level (session) cache for the current session

=== Returns ===
* This function returns ''struct''


=== Examples ===

<source lang="coldfusion">
// Let's get the session statistics
stats = ormService.getSessionStatistics;

// Lets output it
<cfoutput>
collection count: #stats.collectionCount# <br/>
collection keys: #stats.collectionKeys# <br/>
entity count: #stats.entityCount# <br/>
entity keys: #stats.entityKeys#
</cfoutput>
</source>

== list ==

List all of the instances of the passed in entity class name. You can pass in several optional arguments like a struct of filtering criteria, a sortOrder string, offset, max, ignorecase, and timeout. Caching for the list is based on the useQueryCaching class property and the cachename property is based on the queryCacheRegion class property.

=== Returns ===
* This function returns ''any''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|-
| criteria || struct || No || [runtime expression] || 
|-
| sortOrder || string || No ||  || 
|-
| offset || numeric || No || 0 || 
|-
| max || numeric || No || 0 || 
|-
| timeout || numeric || No || 0 || 
|-
| ignoreCase || boolean || No || false || 
|-
| asQuery || boolean || No || true || 
|}

=== Examples ===


<source lang="coldfusion">
users = ormService.list(entityName="User",max=20,offset=10,asQuery=false);

users = ormService.list(entityName="Art",timeout=10);

users = ormService.list("User",{isActive=false},"lastName, firstName");

users = ormService.list("Comment",{postID=rc.postID},"createdDate desc");
</source>


== createService ==
Create a virtual abstract service for a specfic entity.  Basically a new service layer that inherits from the ''BaseORMService'' object but no need to pass in entity names, they are bound to the entity name passed here.

=== Returns ===
* This function returns ''VirtualEntityService''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|-
| useQueryCaching || boolean || No || Same as BaseService || 
|-
| queryCacheRegion || string || No || Same as BaseService || 
|}

=== Examples ===

<source lang="coldfusion">
userService = ormService.createService("User");
userService = ormService.createService("User",true);
userService = ormService.createService("User",true,"MyFunkyUserCache");

// Remember you can use virtual entity services by autowiring them in via our DSL
component{
  property name="userService" inject="entityService:User";
  property name="postService" inject="entityService:Post";	
}
</source>


== findAllWhere ==
Find one entity or null if not found according to the passed in name value pairs into the function ex: findWhere(entityName="Category", category="Training"), findWhere(entityName="Users", age=40);

=== Returns ===
* This function returns ''array''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
posts = ormService.findAllWhere(entityName="Post", author="Luis Majano");
users = ormService.findAllWhere(entityName="User", isActive=true);
artists = ormService.findAllWhere(entityName="Artist", isActive=true, artist="Monet");
</source>


== countWhere ==
Returns the count by passing name value pairs as arguments to this function.  One mandatory argument is to pass the 'entityName'. The rest of the arguments are used in the where class using AND notation and parameterized. Ex: countWhere(entityName="User",age="20");

=== Returns ===
* This function returns ''numeric''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
found = ormService.countWhere(entityName="Artist", artist="Monet");
found = ormService.countWhere(entityName="Post", author="Luis Majano");
found = ormService.countWhere(entityName="User", isActive=false, married=true);
</source>

== exists ==
Checks if the given entityName and id exists in the database

=== Returns ===
* This function returns ''boolean''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || any || Yes || --- || 
|-
| id || any || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
if( ormService.exists("Account",123) ){
 // do something
}
</source>


== evict ==
Evict an entity from session, the id can be a string or structure for the primary key You can also pass in a collection name to evict from the collection

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|-
| collectionName || string || No || --- || 
|-
| id || any || No || --- || 
|}

=== Examples ===

<source lang="coldfusion">
ormService.evict(entityName="Account",account.getID());
ormService.evict(entityName="Account");
ormService.evict(entityName="Account", collectionName="MyAccounts");
</source>

== find ==
Finds and returns the first result for the given query or null if no entity was found. You can either use the query and params combination or send in an example entity to find.

=== Returns ===
* This function returns ''any''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| query || string || No || --- || 
|-
| params || any || No || [runtime expression] || 
|-
| example || any || No || --- || 
|}

=== Examples ===

<source lang="coldfusion">
// My First Post
ormService.find("from Post as p where p.author='Luis Majano'");
// With positional parameters
ormService.find("from Post as p where p.author=?", ["Luis Majano"]);
// with a named parameter (since 0.5)
ormService.find("from Post as p where p.author=:author and p.isActive=:active", { author="Luis Majano",active=true} );
// By Example
book = ormService.new(entityName="Book", author="Luis Majano");
ormService.find( example=book );
</source>


== deleteWhere ==
Deletes entities by using name value pairs as arguments to this function.  One mandatory argument is to pass the 'entityName'. The rest of the arguments are used in the where class using AND notation and parameterized. Ex: deleteWhere(entityName="User",age="4",isActive=true);

=== Returns ===
* This function returns ''numeric''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
ormService.deleteWhere(entityName="User", isActive=true, age=10);
ormService.deleteWhere(entityName="Account", id="40");
ormService.deleteWhere(entityName="Book", isReleased=true, author="Luis Majano");
</source>

== executeQuery ==

Allows the execution of HQL queries using several nice arguments and returns either an array of entities or a query as specified by the asQuery argument. The params filtering can be using named or positional.

=== Returns ===
* This function returns ''any''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| query || string || Yes || --- || 
|-
| params || any || No || [runtime expression] || 
|-
| offset || numeric || No || 0 || 
|-
| max || numeric || No || 0 || 
|-
| timeout || numeric || No || 0 || 
|-
| asQuery || boolean || No || true || 
|}

=== Examples ===

<source lang="coldfusion">
// simple query
ormService.executeQuery( "select distinct a.accountID from Account a" );
// using with list of parameters
ormService.executeQuery( "select distinct e.employeeID from Employee e where e.department = ? and e.created > ?", ['IS','01/01/2010'] );
// same query but with paging
ormService.executeQuery( "select distinct e.employeeID from Employee e where e.department = ? and e.created > ?", ['IS','01/01/2010'],1,30);

// same query but with named params and paging
ormService.executeQuery( "select distinct e.employeeID from Employee e where e.department = :dep and e.created > :created", {dep='Accounting',created='01/01/2010'],10,20);

// GET FUNKY!!
</source>


== refresh ==
Refresh the state of an entity or array of entities from the database

=== Returns ===
* This function returns ''void''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entity || any || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
var user = storage.getVar("UserSession");
ormService.refresh( user );

var users = [user1,user2,user3];
ormService.refresh( users );
</source>


== getPropertyNames ==
Returns the persisted Property Names of the entity in array format

=== Returns ===
* This function returns ''array''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
var properties = ormService.getPropertyNames("User");
</source>

== get ==
Get an entity using a primary key, if the id is not found this method returns null.  You can also pass an id = 0 and the
service will return to you a new entity.

=== Returns ===
* This function returns ''any''


=== Arguments ===

{| cellpadding="5", class="tablelisting"
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-
| entityName || string || Yes || --- || 
|-
| id || any || Yes || --- || 
|}

=== Examples ===

<source lang="coldfusion">
var account = ormService.get("Account",1);
var account = ormService.get("Account",4);

var newAccount = ormService.get("Account",0);
</source>

== clear ==
Clear the session removes all the entities that are loaded or created in the session. This clears the first level cache and removes the objects that are not yet saved to the database.

=== Returns ===
* This function returns ''void''


=== Examples ===

<source lang="coldfusion">
ormService.clear();
</source>

== getUseQueryCaching ==


=== Returns ===
* This function returns ''boolean''


=== Examples ===

<source lang="coldfusion">
Using Caching: #ormService.getUseQueryCaching()#
</source>
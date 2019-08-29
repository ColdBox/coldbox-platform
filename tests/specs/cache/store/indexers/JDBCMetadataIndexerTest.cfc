<cfcomponent extends="coldbox.system.testing.BaseModelTest">
    <cfscript>
    function setup(){
        config = { dsn: "coolblog", table: "cacheBox" };
        mockProvider = createMock( "coldbox.system.cache.providers.MockProvider" );
        mockProvider.$( "getConfiguration", config );
        store = createMock( className = "coldbox.system.cache.store.JDBCStore" ).init( mockProvider );
        index = store.getIndexer();
    }

    function testGetFields(){
        var list = listToArray( "hits,timeout,lastAccessTimeout,created,lastAccessed,isExpired,isSimple" );
        for( var thisItem in list ){
            assertTrue( findNoCase( thisItem, index.getFields() ) );
        }
    }

    function testgetObjectMetadata(){
        store.set( "test1", now(), 1 );
        store.set( "test2", now(), 1 );
        store.set( "test3", now(), 1 );
        results = index.getObjectMetadata( "test1" );

        assertTrue( not structIsEmpty( results ) );
    }

    function testgetObjectMetadataProperty(){
        store.set( "test1", now(), 1 );
        assertEquals( 1, index.getObjectMetadataProperty( "test1", "hits" ) );
    }

    function getSortedKeys(){
        store.clearAll();
        store.set( "test1", now(), 1 );
        store.set( "test2", now(), 1 );
        store.set( "test3", now(), 1 );

        store.get( "test1" );
        store.get( "test1" );
        store.get( "test3" );

        keys = index.getSortedKeys( "hits", "", "asc" );

        // debug(keys);
        assertEquals( "test2", keys[ 1 ] );
    }
    </cfscript>
</cfcomponent>

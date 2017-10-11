component renderdata="json"{
    
        data = [
            { when = now(), id = createUUID(), name = "luis" },
            { when = now(), id = createUUID(), name = "lucas" },
            { when = now(), id = createUUID(), name = "fernando" },
            { when = now(), id = createUUID(), name = "majano" }
        ];
    
        // Default Action return via JSON, ColdBox does native JSON when returning complex objects
        function index( event, rc, prc ){
            return data;
        }

        function asXML( event, rc, prc ) renderdata="xml"{
            return data;
        }

        function asJSON( event, rc, prc ) renderdata="json"{
            return data;
        }
       
    }
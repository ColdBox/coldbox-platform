component{
    
    // Module Properties
    this.title              = "My Test Module";
    this.aliases            = "routestest";
    this.author             = "Eric Peterson";
    this.webURL             = "http://www.coldbox.org";
    this.description        = "A routing test module";
    this.version            = "1.0.0";
    // If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
    this.viewParentLookup   = true;
    // If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
    this.layoutParentLookup = true;
    this.entryPoint         = "routestest";
    // CFML Mapping for this module, the path will be the module root. If empty, none is registered.
    this.cfmapping          = "routestest";

    function configure(){

        // SES Routes
        routes = [
            "config/routes"
        ];

    }

}
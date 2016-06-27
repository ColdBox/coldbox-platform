component{
    
    // Module Properties
    this.title              = "My Test Module";
    this.aliases            = "routesfile";
    this.author             = "Luis Majano";
    this.webURL             = "http://www.coldbox.org";
    this.description        = "A funky test module";
    this.version            = "1.0";
    // If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
    this.viewParentLookup   = true;
    // If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
    this.layoutParentLookup = true;
    this.entryPoint         = "routesfile";
    // CFML Mapping for this module, the path will be the module root. If empty, none is registered.
    this.cfmapping          = "routesfile";

    function configure(){

        // SES Routes
        routes = [
            "config/routes"
        ];

    }

}
/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* I am an AOP mixer utility method
*/
component{

    /**
    * Constructor
    */
    function init(){
        return this;
    }

    /****************************** AOP UTILITY MIXINS ******************************/

    /**
    * Store JointPoint information
    * @jointpoint The jointpoint to proxy
    * @interceptors The jointpoint interceptors
    * 
    * @return instance
    */
    function $wbAOPStoreJointPoint( required jointpoint, required interceptors ){
        this.$wbAOPTargets[ arguments.jointpoint ] = {
            udfPointer   = variables[ arguments.jointpoint ],
            interceptors = arguments.interceptors
        };
        return this;
    }

    /**
    * Invoke a mixed in proxy method
    * @method The method to proxy execute
    * @args The method args to proxy execute
    */
    function $wbAOPInvokeProxy( required method, required args ){
        return this.$wbAOPTargets[ arguments.method ].udfPointer( argumentCollection=arguments.args );
    }

    /**
    * Mix in a template on an injected target
    * @templatePath The template to mix in
    * 
    * @return Instance
    */
    function $wbAOPInclude( required templatePath ){
        include "#arguments.templatePath#";
        return this;
    }

    /**
    * Remove a method from this target mixin
    * @methodName The method to poof away!
    * 
    * @return Instance
    */
    function $wbAOPRemove( required methodName ){
        structDelete( this, arguments.methodName );
        structDelete( variables, arguments.methodName );
        return this;
    }


    /****************************** UTILITY Methods ******************************/

    /**
    * Write an aspect to disk
    * @genPath The location path
    * @code The code to write
    * 
    * @return Instance
    */
    function writeAspect( required genPath, required code ){
        fileWrite( arguments.genPath, arguments.code );
        return this;
    }

    /**
    * Remove an aspect from disk
    * @filePath The location path
    * 
    * @return Instance
    */
    function removeAspect( required filePath ){
        if( fileExists( arguments.filePath ) ){
        	fileDelete( arguments.filePath );
        }
        return this;
    }

}
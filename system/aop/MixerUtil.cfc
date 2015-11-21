/*-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano, cfscript: Ben Koshy
Description :
	I am an AOP mixer utility method
-----------------------------------------------------------------------*/
component
    hint = "I am an AOP mixer utility method"
    output = false
{
    /*
    * @hint     Constructor
    * @output   false
    */
    public any function init(){
        return this;
    } // init()
    /*------------------------------------------- AOP UTILITY MIXINS ------------------------------------------*/

    /*
    * @hint     Store JointPoint information
    * @output   false
    *
    * @jointpoint.hint      The jointpoint to proxy
    * @interceptors.hint    The jointpoint interceptors
    */
    public any function $wbAOPStoreJointPoint(
        required any jointpoint,
        required any interceptors
    ){
        this.$wbAOPTargets[arguments.jointpoint] = {
            udfPointer   = variables[ arguments.jointpoint ],
            interceptors = arguments.interceptors
        };
    } // $wbAOPStoreJointPoint()

   /*
    * @hint     Invoke a mixed in proxy method
    * @output   false
    *
    * @method.hint  The method to proxy execute
    * @args.hint    The method args to proxy execute
    */
    public any function $wbAOPInvokeProxy(
        required any method,
        required any args
    ){
        return this.$wbAOPTargets[ arguments.method ].udfPointer( argumentCollection = arguments.args )
    } // $wbAOPInvokeProxy()

    /*
    * @hint     Mix in a template on an injected target
    * @output   false
    *
    * @templatePath.hint      The template to mix in
    */
    public any function $wbAOPInclude(
        required any templatePath
    ){
        include template="#arguments.templatePath#";
    } // $wbAOPInclude()

    /*
    * @hint     Remove a method from this target mixin
    * @output   false
    *
    * @methodName.hint      The method to poof away!
    */
    public any function $wbAOPRemove(
        required any methodName
    ){
        structDelete( this, arguments.methodName );
        structDelete( variables, arguments.methodName );
    } // $wbAOPRemove()
    
    /*------------------------------------------- Utility Methods ------------------------------------------*/

    /*
    * @hint     Write an aspect to disk
    * @output   false
    */
    public any function writeAspect(
        required any genPath,
        required any code
    ){
        fileWrite( arguments.genPath, arguments.code );
    } // writeAspect()

    /*
    * @hint     Remove an aspect from disk
    * @output   false
    */
    public any function writeAspect(
        required any filePath
    ){
        if( fileExists( arguments.filePath )){
            fileDelete( arguments.filePath );
        }
    }
}
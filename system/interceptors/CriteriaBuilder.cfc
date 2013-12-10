/*-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :   Luis Majano
Description :   Simple interceptor to process logging of proposed SQL strings from criteria Builder object
    
-----------------------------------------------------------------------*/
component hint="Interceptor for additions to CriteriaBuilder" output="false" extends="coldbox.system.Interceptor" {
/*------------------------------------------- CONSTRUCTOR -------------------------------------------*/

    /**
     * Configuration method for interceptor
     * return void
     */
    public void function configure() {

    }

    public void function onCriteriaBuilderAddition( required Any event, required Struct interceptData ) {
        if( structKeyExists( interceptData, "CriteriaBuilder" ) ) {
            if( interceptData.CriteriaBuilder.canLogSql() ) {
                interceptData.CriteriaBuilder.logSql( label=interceptData.type );
            }
        }
    }
}
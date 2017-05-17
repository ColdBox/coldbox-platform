component name="PRCProvider" implements="coldbox.system.ioc.IProvider" singleton {

    property name="requestService" inject="coldbox:requestService";

    public any function get() output=false {
        return requestService.getContext().getPrivateCollection();
    }

}
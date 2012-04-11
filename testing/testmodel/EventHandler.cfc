component extends="coldbox.system.orm.hibernate.WBEventHandler"{
	
	private function getWireBox(){
		return new coldbox.system.ioc.Injector();
	}
}
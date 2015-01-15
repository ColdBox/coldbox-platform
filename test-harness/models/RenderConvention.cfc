component accessors="true"{

	property name="name";
	property name="age";
	property name="cool";
	
	function init(){ return this; }
	
	function config(name,age,cool){
		setName( arguments.name );
		setAge( arguments.age );
		setCool( arguments.cool );
		return this;
	}
	
	function $renderdata(){
		var d = {
			n = variables.name,
			a = variables.age,
			c = variables.cool,
			today = now()
		};
		
		return d.toString();
	}

}
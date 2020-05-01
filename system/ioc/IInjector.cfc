/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * An interface that enables any CFC to act like a parent injector within WireBox.
 **/
 interface {

	/**
	 * Link a parent Injector with this injector and return itself
	 *
	 * @injector A WireBox Injector to assign as a parent to this Injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return IInjector
	 */
	function setParent( required injector );

	/**
	 * Get a reference to the parent injector instance, else an empty simple string meaning nothing is set
	 *
	 * @return coldbox.system.ioc.Injector
	 */
	function getParent();

	/**
	 * Locates, Creates, Injects and Configures an object model instance
	 *
	 * @name The mapping name or CFC instance path to try to build up
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'
	 * @targetObject The object requesting the dependency, usually only used by DSL lookups
	 */
	function getInstance( name, struct initArguments, dsl, targetObject="" );

	/**
	 * Checks if this injector can locate a model instance or not
	 *
	 * @name The object name or alias to search for if this container can locate it or has knowledge of it
	 */
	boolean function containsInstance( required name );

	/**
	 * Shutdown the injector gracefully by calling the shutdown events internally
	 *
	 * @return IInjector
	 */
	function shutdown();

 }
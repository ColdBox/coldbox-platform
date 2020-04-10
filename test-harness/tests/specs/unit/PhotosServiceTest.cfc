/**
 * The base model test case will use the 'model' annotation as the instantiation path
 * and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
 * responsibility to update the model annotation instantiation path and init your model.
 */
component
	extends="coldbox.system.testing.BaseModelTest"
	model  ="Users.lmajano.Sites.cboxdev.coldbox.test-harness.models.PhotosService"
{

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();

		// setup the model
		super.setup();

		// init the model object
		model.init();
	}

	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "PhotosService Suite", function(){
			it( "should save", function(){
				expect( false ).toBeTrue();
			} );

			it( "should delete", function(){
				expect( false ).toBeTrue();
			} );

			it( "should list", function(){
				expect( false ).toBeTrue();
			} );

			it( "should get", function(){
				expect( false ).toBeTrue();
			} );
		} );
	}

}

// Skipped until ORM is ready
component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here
		setup();
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "HTML Helper", function(){
			beforeEach( function( currentSpec ){
				ormClearSession();
				htmlhelper = prepareMock( getInstance( "HTMLHelper@HTMLHelper" ) ).$( "$htmlhead" );
			} );

			it( "can deliver js via addAsset", function(){
				htmlhelper.addAsset( "test.js,luis.js" );
				assertEquals(
					"<script src=""/includes/js/test.js"" ></script><script src=""/includes/js/luis.js"" ></script>",
					htmlhelper.$callLog().$htmlhead[ 1 ][ 1 ]
				);
				htmlhelper.addAsset( "test.js" );
				assertEquals( 1, arrayLen( htmlhelper.$callLog().$htmlHead ) );
			} );

			it( "can deliver css via addAsset", function(){
				htmlhelper.addAsset( "test.css,luis.css" );
				assertEquals(
					"<link href=""/includes/css/test.css"" type=""text/css"" rel=""stylesheet"" /><link href=""/includes/css/luis.css"" type=""text/css"" rel=""stylesheet"" />",
					htmlhelper.$callLog().$htmlhead[ 1 ][ 1 ]
				);
				htmlhelper.addAsset( "test.css" );
				assertEquals( 1, arrayLen( htmlhelper.$callLog().$htmlHead ) );
			} );

			it( "can create css links via addAsset", function(){
				r = htmlhelper.addAsset( asset: "test1.css,luis1.css", sendToHeader: false );
				assertEquals(
					"<link href=""/includes/css/test1.css"" type=""text/css"" rel=""stylesheet"" /><link href=""/includes/css/luis1.css"" type=""text/css"" rel=""stylesheet"" />",
					r
				);
			} );

			it( "can produce br tags", function(){
				assertEquals( "<br/>", htmlhelper.br() );
				assertEquals( "<br/><br/><br/>", htmlhelper.br( 3 ) );
			} );

			it( "can produce nb spaces", function(){
				assertEquals( "&nbsp;", htmlhelper.nbs() );
				assertEquals( "&nbsp;&nbsp;&nbsp;", htmlhelper.nbs( 3 ) );
			} );

			it( "can produce heading tags", function(){
				assertEquals( "<h1>Hello</h1>", htmlhelper.heading( "Hello" ) );
			} );

			it( "can produce img tags", function(){
				var img = htmlhelper.img( "/includes/images/pio.jpg" );
				expect( img ).toInclude( encodeForHTMLAttribute( "includes/images/pio.jpg" ) );

				var img = htmlhelper.img( "http://hello.com/includes/images/pio.jpg" );
				expect( img ).toInclude( encodeForHTMLAttribute( "http://hello.com/includes/images/pio.jpg" ) );
			} );

			it( "can produce link tags", function(){
				str = htmlhelper.link( href = "luis.css", sendToHeader = false );
				str = htmlhelper.link( href = "http://hello.com/luis.css", sendToHeader = false );

				var xml = xmlParse( str );
				assertEquals( xml.link.XMLAttributes.charset, "UTF-8" );
				assertEquals( xml.link.XMLAttributes.href, "http://hello.com/luis.css" );
			} );

			it( "can produce ol tags", function(){
				str = htmlhelper.ol( "1,2" );
				assertEquals( "<ol><li>1</li><li>2</li></ol>", str );
			} );

			it( "can produce ul tags", function(){
				var data = [ 1, 2, [ 1, 2 ] ];

				str = htmlhelper.ul( "1,2" );
				assertEquals( "<ul><li>1</li><li>2</li></ul>", str );

				str = htmlhelper.ul( values = data, class = "cool" );
				assertEquals( "<ul class=""cool""><li>1</li><li>2</li><ul><li>1</li><li>2</li></ul></ul>", str );
			} );

			it( "can produce ul tags with queries", function(){
				var data = querySim(
					"id,name
					#createUUID()# | luis
					#createUUID()# | joe
					#createUUID()# | fernando
					"
				);
				str = htmlhelper.ul( values = data, column = "name" );
				// debug(str);
				assertEquals( "<ul><li>luis</li><li>joe</li><li>fernando</li></ul>", str );
			} );

			it( "can produce meta tags", function(){
				var data = [
					{ name : "luis", content : "awesome" },
					{ name : "test", content : "2", type : "equiv" }
				];

				str = htmlhelper.meta(
					name         = "luis",
					content      = "awesome",
					sendToHeader = false
				);
				assertEquals( "<meta name=""luis"" content=""awesome"" />", str );

				str = htmlhelper.meta(
					name         = "luis",
					content      = "awesome",
					type         = "equiv",
					sendToHeader = false
				);
				assertEquals( "<meta http-equiv=""luis"" content=""awesome"" />", str );

				str = htmlhelper.meta( data );
				assertEquals(
					"<meta name=""luis"" content=""awesome"" /><meta http-equiv=""test"" content=""2"" />",
					str
				);
			} );

			it( "can produce doctypes", function(){
				str = htmlhelper.docType();
				assertEquals( "<!DOCTYPE html>", str );
			} );


			it( "can produce any tag using the tag method", function(){
				str = htmlhelper.tag( "code", "hello" );
				assertEquals( "<code>hello</code>", str );

				str = htmlhelper.tag(
					tag     = "code",
					content = "hello",
					class   = "cool"
				);
				assertEquals( "<code class=""cool"">hello</code>", str );
			} );


			it( "can produce inline js content", function(){
				str = htmlhelper.addJSContent( "function test(){ alert( ""luis"" ); }" );
				// debug(str);
				assertEquals( "<script>function test(){ alert( ""luis"" ); }</script>", str );
			} );


			it( "can produce inline style content", function(){
				str = htmlhelper.addStyleContent( ".test{color: ##123}" );
				// debug(str);

				assertEquals( "<style type=""text/css"">.test{color: ##123}</style>", str );
			} );


			it( "can produce tables with query inputs", function(){
				data = querySim(
					"id,name
					1 | luis
					2 | peter"
				);

				str = htmlhelper.table( data = data );
				assertEquals(
					xmlParse(
						"<table><thead><tr><th>ID</th><th>NAME</th></tr></thead><tbody><tr><td>1</td><td>luis</td></tr><tr><td>2</td><td>peter</td></tr></tbody></table>"
					),
					xmlParse( str )
				);

				str = htmlhelper.table( data = data, class = "test" );
				assertEquals(
					xmlParse(
						"<table class='test'><thead><tr><th>ID</th><th>NAME</th></tr></thead><tbody><tr><td>1</td><td>luis</td></tr><tr><td>2</td><td>peter</td></tr></tbody></table>"
					),
					xmlParse( str )
				);

				str = htmlhelper.table( data = data, includes = "name", class = "test" );
				assertEquals(
					xmlParse(
						"<table class='test'><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>"
					),
					xmlParse( str )
				);

				str = htmlhelper.table( data = data, excludes = "id", class = "test" );
				assertEquals(
					xmlParse(
						"<table class='test'><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>"
					),
					xmlParse( str )
				);
			} );

			it( "can produce tables with ORM inputs", function(){
				var data = entityLoad( "User", {}, { maxResults : 10 } );
				str      = htmlhelper.table( data = data, includes = "firstName" );
				expect( str ).notToBeEmpty();
			} );

			it( "can produce tables with array of struct inputs", function(){
				data = [
					{ id : 1, name : "luis" },
					{ id : 2, name : "peter" }
				];

				str = htmlhelper.table( data = data );
				expect( str ).toInclude( "<th>NAME</th>" ).toInclude( "<th>ID</th>" );

				str = htmlhelper.table( data = data, class = "test" );
				expect( str ).toInclude( "class=""test" );

				str = htmlhelper.table( data = data, includes = "name", class = "test" );
				expect( str ).NotToInclude( "<th>ID</th>" );

				str = htmlhelper.table( data = data, excludes = "id", class = "test" );
				expect( str ).toInclude( "<th>NAME</th>" );
			} );

			it( "can produce tables with array of object inputs", function(){
				var data = [
					new tests.resources.Test(),
					new tests.resources.Test( name = "test", email = "testing@testing.com" )
				];
				var str = htmlhelper.table( data = data );
				expect( str )
					.toInclude( "<th>NAME</th>" )
					.toInclude( "<th>EMAIL</th>" )
					.toInclude( "testing@testing.com" );
			} );


			it( "can slugify strings", function(){
				data = {
					title1 : "My Awesome Post",
					title2 : "Sept. Is great- for me--and you"
				};

				str = htmlhelper.slugify( data.title1 );
				// debug(str);
				assertEquals( "my-awesome-post", str );

				str = htmlhelper.slugify( data.title2 );
				// debug(str);
				assertEquals( "sept-is-great-for-me-and-you", str );
			} );

			it( "can produce auto discovery links", function(){
				var str = htmlhelper.autoDiscoveryLink( href = "/action/rss", title = "MY RSS Feed" );
				var xml = xmlParse( str );
				assertEquals( xml.link.XMLAttributes.type, "application/rss+xml" );
				assertEquals( xml.link.XMLAttributes.href, "/action/rss" );

				var str = htmlhelper.autoDiscoveryLink(
					type  = "atom",
					href  = "/action/rss",
					title = "MY RSS Feed"
				);
				var xml = xmlParse( str );
				assertEquals( xml.link.XMLAttributes.type, "application/atom+xml" );
				assertEquals( xml.link.XMLAttributes.href, "/action/rss" );
			} );

			it( "can produce video tags", function(){
				var str = htmlhelper.video(
					src      = "includes/movie.ogg",
					autoplay = true,
					width    = "200",
					height   = "200"
				);
				var xml = xmlParse( str );
				assertEquals( xml.video.XMLAttributes.width, "200" );
				assertEquals( xml.video.XMLAttributes.height, "200" );
				expect( xml.video.XMLAttributes.src ).toInclude( "includes/movie.ogg" );
			} );


			it( "can produce audio tags", function(){
				var str = htmlhelper.audio(
					src      = "includes/song.ogg",
					autoplay = true,
					loop     = true
				);
				var xml = xmlParse( str );
				assertEquals( xml.audio.XMLAttributes.autoplay, "autoplay" );
				assertEquals( xml.audio.XMLAttributes.loop, "loop" );
				expect( xml.audio.XMLAttributes.src ).toInclude( "includes/song.ogg" );
			} );

			it( "can produce canvas tags", function(){
				var str = htmlhelper.canvas( "test" );
				var xml = xmlParse( str );
				assertEquals( xml.canvas.XMLAttributes.id, "test" );
			} );

			it( "can produce different form tags", function(){
				str = htmlhelper.endForm();
				assertEquals( "</form>", str );

				str = htmlhelper.startForm( action = "user.save" );
				expect( str ).toInclude( "&##x2f;user&##x2f;save" );

				str = htmlhelper.startForm(
					action = "user.save",
					method = "get",
					name   = "userForm"
				);
				expect( str )
					.toInclude( "id=""userForm""" )
					.toInclude( "method=""get""" )
					.toInclude( "name=""userForm""" );

				str = htmlhelper.startForm();
				expect( str ).toInclude( "method=""post""" );
			} );

			it( "can produce form tags with non-standard HTTP Methods (PUT,PATCH,DELETE)", function(){
				var methods = [ "put", "patch", "delete", "options" ];
				for ( var thisMethod in methods ) {
					str = htmlhelper.startForm( action = "user.#thisMethod#", method = "#thisMethod#" );
					expect( str )
						.toInclude( "method=""post""" )
						.toInclude( "<input type=""hidden"" name=""_method"" value=""#thisMethod#"" />" );
				}
			} );

			it( "can produce labels", function(){
				str = htmlhelper.label( field = "name" );
				assertEquals( "<label for=""name"">Name</label>", str );
				str = htmlhelper.label( field = "name", content = "My Name" );
				assertEquals( "<label for=""name"">My Name</label>", str );
				str = htmlhelper.label(
					field   = "name",
					content = "My Name",
					wrapper = "div"
				);
				assertEquals( "<div><label for=""name"">My Name</label></div>", str );
			} );

			it( "can produce textareas ", function(){
				str = htmlhelper.textarea( name = "message" );
				assertEquals(
					xmlParse( "<textarea name=""message"" id=""message""></textarea>" ),
					xmlParse( str )
				);

				str = htmlhelper.textarea( name = "message", value = "Hello" );
				assertEquals( "<textarea name=""message"" id=""message"">Hello</textarea>", str );

				str = htmlhelper.textarea(
					name  = "message",
					value = "Hello",
					label = "Message"
				);
				assertEquals(
					"<label for=""Message"">Message</label><textarea name=""message"" id=""message"">Hello</textarea>",
					str
				);

				str = htmlhelper.textarea(
					name    = "message",
					value   = "Hello",
					label   = "Message",
					wrapper = "div"
				);
				// debug(str);
				assertEquals(
					"<label for=""Message"">Message</label><div><textarea name=""message"" id=""message"">Hello</textarea></div>",
					str
				);
			} );

			it( "can produce textareas with orm bindings", function(){
				// entity binding
				var entity = entityLoad( "User", {}, { maxResults : 1 } ).first();
				var str    = htmlhelper.textarea( name = "lastName", bind = entity );
				expect( str ).toBe(
					"<textarea name=""lastName"" id=""lastName"">#entity.getLastName()#</textarea>"
				);
			} );

			it( "can produce password fields", function(){
				str = htmlhelper.passwordField( name = "message", value = "test" );
				assertEquals(
					xmlParse( "<input name=""message"" value=""test"" id=""message"" type=""password""/>" ),
					xmlParse( str )
				);

				str = htmlhelper.passwordField(
					name    = "message",
					value   = "test",
					wrapper = "div"
				);
				assertEquals(
					xmlParse(
						"<div><input name=""message"" value=""test"" id=""message"" type=""password""/></div>"
					),
					xmlParse( str )
				);

				str = htmlhelper.passwordField(
					name         = "message",
					value        = "test",
					wrapper      = "div",
					wrapperAttrs = { "class" : "wrapper-class", "id" : "wrapper-id" }
				);
				assertEquals(
					xmlParse(
						"<div class=""wrapper-class"" id=""wrapper-id""><input name=""message"" value=""test"" id=""message"" type=""password""/></div>"
					),
					xmlParse( str )
				);
			} );

			it( "can produce hidden fields", function(){
				str = htmlhelper.hiddenField( name = "message" );
				assertEquals(
					xmlParse( "<input name=""message"" id=""message"" type=""hidden""/>" ),
					xmlParse( str )
				);
			} );

			it( "can produce hidden fields with orm bindings", function(){
				// entity binding
				var entity = entityLoad( "User", {}, { maxResults : 1 } ).first();
				var str    = htmlhelper.hiddenField( name = "lastName", bind = entity );
				expect( str )
					.toInclude( "value=""#entity.getLastName().encodeForHTMLAttribute()#""" )
					.toInclude( "type=""hidden""" );
			} );

			it( "can produce text fields with orm bindings", function(){
				// entity binding
				var entity = entityLoad( "User", {}, { maxResults : 1 } ).first();
				var str    = htmlhelper.textField(
					name = "lastName",
					bind = entity,
					data = { type : "awesome", tooltip : "true", modal : true }
				);
				expect( str ).toInclude( "value=""#entity.getLastName().encodeForHTMLAttribute()#""" );
				expect( str ).toInclude( "data-type=""awesome""" );
				expect( str ).toInclude( "data-tooltip=""true""" );
			} );

			it( "can create buttons", function(){
				str = htmlhelper.button(
					name  = "message",
					value = "hello",
					type  = "submit"
				);
				xml = xmlParse( str );
				expect( xml.button.xmlText ).toBe( "hello" );
				expect( xml.button.XMLAttributes )
					.toHaveKey( "name" )
					.toHaveKey( "type" )
					.toHaveKey( "id" );
			} );

			it( "can produce file fields", function(){
				str = htmlhelper.fileField( name = "message", value = "test" );
				assertEquals(
					xmlParse( "<input name=""message"" value=""test"" id=""message"" type=""file""/>" ),
					xmlParse( str )
				);
			} );

			it( "can produce email fields", function(){
				var entity = entityLoad( "User", {}, { maxResults : 1 } ).first();
				var str    = htmlhelper.emailField( name = "lastName", bind = entity );
				expect( str )
					.toInclude( "value=""#entity.getLastName().encodeForHTMLAttribute()#""" )
					.toInclude( "type=""email""" );
			} );

			it( "can produce URL fields", function(){
				var entity = entityLoad( "User", {}, { maxResults : 1 } ).first();
				var str    = htmlhelper.urlField( name = "lastName", bind = entity );
				expect( str )
					.toInclude( "value=""#entity.getLastName().encodeForHTMLAttribute()#""" )
					.toInclude( "type=""url""" );
			} );

			it( "can produce checkboxes", function(){
				str = htmlhelper.checkbox( name = "message" );
				assertEquals(
					xmlParse( "<input name=""message"" value=""true"" id=""message"" type=""checkbox""/>" ),
					xmlParse( str )
				);

				str = htmlhelper.checkbox(
					name    = "message",
					value   = "test",
					checked = true
				);
				// debug(str);
				assertTrue( findNoCase( "checked=""checked""", str ) );
				assertTrue( findNoCase( "value=""Test""", str ) );
			} );

			it( "can produce checkboxes with orm binding", function(){
				// entity binding
				var entity = entityLoad( "User", {}, { maxResults : 1 } ).first();
				var str    = htmlhelper.checkbox( name = "isActive", bind = entity );
				expect( str )
					.toInclude( "value=""true""" )
					.toInclude( "checked=""true""" )
					.toInclude( "id=""isActive""" );

				entity.setIsActive( false );
				var str = htmlhelper.checkbox( name = "isActive", bind = entity );
				expect( str )
					.toInclude( "value=""true""" )
					.notToInclude( "checked=""true""" )
					.toInclude( "id=""isActive""" );
			} );

			it( "can produce radio buttons", function(){
				str = htmlhelper.radioButton( name = "message" );
				assertEquals(
					xmlParse( "<input name=""message"" value=""true"" id=""message"" type=""radio""/>" ),
					xmlParse( str )
				);

				str = htmlhelper.radioButton(
					name    = "message",
					value   = "test",
					checked = true
				);
				assertEquals( "checked", xmlParse( str ).input.xmlAttributes.checked );
			} );

			it( "can produce radio buttons with orm bindings", function(){
				// entity binding
				var entity = entityLoad( "User", {}, { maxResults : 1 } ).first();
				var str    = htmlhelper.radioButton( name = "isActive", bind = entity );
				expect( str )
					.toInclude( "type=""radio""" )
					.toInclude( "value=""true""" )
					.toInclude( "checked=""true""" )
					.toInclude( "id=""isActive""" );

				entity.setIsActive( false );
				var str = htmlhelper.radioButton( name = "isActive", bind = entity );
				expect( str )
					.toInclude( "type=""radio""" )
					.toInclude( "value=""true""" )
					.notToInclude( "checked=""true""" )
					.toInclude( "id=""isActive""" );
			} );

			it( "can produce submit buttons", function(){
				var str = htmlhelper.submitButton( name = "message" );
				assertEquals(
					xmlParse( "<input name=""message"" value=""Submit"" id=""message"" type=""submit""/>" ),
					xmlParse( str )
				);
			} );

			it( "can produce submit buttons", function(){
				str = htmlhelper.resetButton( name = "message" );
				assertEquals(
					xmlParse( "<input name=""message"" value=""Reset"" id=""message"" type=""reset""/>" ),
					xmlParse( str )
				);
			} );

			it( "can produce image buttons", function(){
				str = htmlhelper.imageButton( name = "message", src = "includes/photo.jpg" );
				assertTrue( findNoCase( "src=""#encodeForHTMLAttribute( "includes/photo.jpg" )#""", str ) );
			} );


			it( "can produce options tags with arrays", function(){
				// array
				str = htmlhelper.options( values = [ 1, 2, 3 ] );
				// debug( str );
				assertEquals(
					"<option value=""1"">1</option><option value=""2"">2</option><option value=""3"">3</option>",
					str
				);
			} );


			it( "can produce option tags with array of structs", function(){
				// array of structs
				str = htmlhelper.options(
					values = [
						{ value : 1, name : "1" },
						{ name : 2, value : 2 },
						{ name : 3, value : 3 }
					]
				);
				// debug( str );
				assertEquals(
					"<option value=""1"">1</option><option value=""2"">2</option><option value=""3"">3</option>",
					str
				);
			} );


			it( "can produce option tags with simple values", function(){
				// simple list
				str = htmlhelper.options( values = "1,2,3" );
				// debug( str );
				assertEquals(
					"<option value=""1"">1</option><option value=""2"">2</option><option value=""3"">3</option>",
					str
				);
			} );


			it( "can produce option tags with queries", function(){
				// query
				var qList = querySim(
					"name
					luis
					joe
					alexia"
				);
				str = htmlhelper.options( values = qList, column = "name" );
				// debug( str );
				assertEquals(
					"<option value=""luis"">luis</option><option value=""joe"">joe</option><option value=""alexia"">alexia</option>",
					str
				);

				str = htmlhelper.options( values = qList );
				// debug( str );
				assertEquals(
					"<option value=""luis"">luis</option><option value=""joe"">joe</option><option value=""alexia"">alexia</option>",
					str
				);

				// query
				qList = querySim(
					"name, id
					luis| 1
					joe| 2
					alexia| 3"
				);
				str = htmlhelper.options(
					values     = qList,
					column     = "id",
					nameColumn = "name"
				);
				// debug( str );
				assertEquals(
					"<option value=""1"">luis</option><option value=""2"">joe</option><option value=""3"">alexia</option>",
					str
				);
			} );


			it( "can produce select tags", function(){
				// array
				str = htmlhelper.select( name = "users", options = [ 1, 2, 3 ] );
				// debug( str );
				assertEquals(
					"<select name=""users"" id=""users""><option value=""1"">1</option><option value=""2"">2</option><option value=""3"">3</option></select>",
					str
				);

				str = htmlhelper.select(
					name    = "users",
					options = [ 1, 2, 3 ],
					label   = "Message"
				);
				// debug( str );
				assertEquals(
					"<label for=""users"">Message</label><select name=""users"" id=""users""><option value=""1"">1</option><option value=""2"">2</option><option value=""3"">3</option></select>",
					str
				);

				str = htmlhelper.select(
					name         = "users",
					options      = [ 1, 2, 3 ],
					label        = "Message",
					labelWrapper = "div"
				);
				// debug( str );
				assertEquals(
					"<div><label for=""users"">Message</label></div><select name=""users"" id=""users""><option value=""1"">1</option><option value=""2"">2</option><option value=""3"">3</option></select>",
					str
				);

				str = htmlhelper.select(
					name    = "users",
					options = [ 1, 2, 3 ],
					label   = "Message",
					wrapper = "div"
				);
				// debug( str );
				assertEquals(
					"<label for=""users"">Message</label><div><select name=""users"" id=""users""><option value=""1"">1</option><option value=""2"">2</option><option value=""3"">3</option></select></div>",
					str
				);
			} );

			it( "can create anchor tags", function(){
				var str = htmlhelper.anchor( name = "lui" );
				expect( xmlParse( "<root>#str#</root>" ) ).toBe(
					xmlParse( "<root><a id=""lui"" name=""lui""></a></root>" )
				);
			} );

			it( "can create href tags", function(){
				str = htmlhelper.href( href = "actions.save" );
				expect( str ).toInclude( encodeForHTMLAttribute( "/actions/save" ) );

				str = htmlhelper.href( href = "actions.save", text = "Edit" );
				expect( str ).toInclude( encodeForHTMLAttribute( "/actions/save" ) ).toInclude( "Edit" );
			} );

			it( "can create fieldsets", function(){
				str = htmlhelper.startFieldset( legend = "Luis" );
				// debug(str);
				assertEquals( "<fieldset><legend>Luis</legend>", str );

				str = htmlhelper.endFieldSet();
				// debug(str);
				assertEquals( "</fieldset>", str );
			} );

			it( "cand do xss escaping", function(){
				var str = htmlhelper.textField(
					name  = "luis",
					value = """><img src=x onerror=prompt(1)> or ""><script>alert(/xss/)</script>"
				);
				// if it parses, then it is escaped, else it fails.
				var xml = xmlParse( str );
			} );


			it( "can do complex wrapper tags", function(){
				var str = htmlhelper.textField(
					name         = "luis",
					value        = "luis",
					wrapper      = "div class='form-control'",
					groupWrapper = "div class='form-group'"
				);
				expect( str )
					.toInclude( "<div class='form-group'><div class='form-control'>" )
					.toInclude( "</div></div>" );
			} );


			it( "can write label attributes ", function(){
				var str = htmlhelper.checkbox(
					name       = "luis",
					value      = 1,
					label      = "luis?",
					labelAttrs = { title : "Check this box for luis" }
				);
				expect( xmlParse( "<root>#str#</root>" ) ).toBe(
					xmlParse(
						"<root><label for=""luis"" title=""Check this box for luis"">luis?</label><input type=""checkbox"" name=""luis"" value=""1"" id=""luis""/></root>"
					)
				);
			} );

			it( "can create inputs inside label tags", function(){
				var str = htmlhelper.checkbox(
					name             = "luis",
					value            = 1,
					label            = "luis?",
					labelAttrs       = { title : "Check this box for luis" },
					inputInsideLabel = 1
				);
				expect( xmlParse( "<root>#str#</root>" ) ).toBe(
					xmlParse(
						"<root><label for=""luis"" title=""Check&##x20;this&##x20;box&##x20;for&##x20;luis""><input value=""1"" name=""luis"" id=""luis"" type=""checkbox""/>luis&##x3f;</label></root>"
					)
				);
			} );
		} );
	}

}

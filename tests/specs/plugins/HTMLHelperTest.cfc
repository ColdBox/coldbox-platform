﻿<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.HTMLHelper">
<cfscript>
	function setup(){
		super.setup();
		application.wirebox = createObject("component","coldbox.system.ioc.Injector").init(binder="coldbox.tests.resources.WireBox");
	}
	function teardown(){
		super.teardown();
		structClear( application );
	}

	function testaddAssetJS(){
		var mockEvent = getMockRequestContext();
		mockRequestService.$("getContext", mockEvent);

		plugin.$("$htmlhead").$("settingExists",false);
		plugin.addAsset('test.js,luis.js');

		debug( plugin.$callLog().$htmlhead);

		// test duplicate call
		assertEquals('<script src="test.js" type="text/javascript"></script><script src="luis.js" type="text/javascript"></script>' , plugin.$callLog().$htmlhead[1][1] );
		plugin.addAsset('test.js');
		assertEquals(1, arrayLen(plugin.$callLog().$htmlHead) );

		// global settings
		plugin.$("settingExists",true).$("getSetting","/includes/js/");
		r = plugin.addAsset('test1.js,luis1.js',false);
		assertEquals('<script src="/includes/js/test1.js" type="text/javascript"></script><script src="/includes/js/luis1.js" type="text/javascript"></script>' , r );

	}

	function testaddAssetCSS(){
		var mockEvent = getMockRequestContext();
		mockRequestService.$("getContext", mockEvent);

		plugin.$("$htmlhead").$("settingExists",false);
		plugin.addAsset('test.css,luis.css');

		// test duplicate call
		assertEquals('<link href="test.css" type="text/css" rel="stylesheet" /><link href="luis.css" type="text/css" rel="stylesheet" />' , plugin.$callLog().$htmlhead[1][1] );
		plugin.addAsset('test.css');
		assertEquals(1, arrayLen(plugin.$callLog().$htmlHead) );

		// global settings
		plugin.$("settingExists",true).$("getSetting","/includes/css/");
		r = plugin.addAsset('test1.css,luis1.css',false);
		debug( r );
		assertEquals('<link href="/includes/css/test1.css" type="text/css" rel="stylesheet" /><link href="/includes/css/luis1.css" type="text/css" rel="stylesheet" />' , r );
	}

	function testbr(){
		assertEquals( "<br/>", plugin.br() );
		assertEquals( "<br/><br/><br/>", plugin.br(3) );
	}
	function testnbs(){
		assertEquals( "&nbsp;", plugin.nbs() );
		assertEquals( "&nbsp;&nbsp;&nbsp;", plugin.nbs(3) );
	}

	function testHeading(){
		assertEquals( "<h1>Hello</h1>", plugin.heading("Hello") );
	}

	function testIMG(){
		// with htmlbaseURL
		var mockEvent = getMockRequestContext()
			.$("getSESBaseURL", "http://www.coldbox.org");
		mockRequestService.$("getContext", mockEvent);

		img = plugin.img("includes/images/pio.jpg");
		assertEquals('<img src="http://www.coldbox.org/includes/images/pio.jpg" />', img);

		img = plugin.img("http://hello.com/includes/images/pio.jpg");
		assertEquals('<img src="http://hello.com/includes/images/pio.jpg" />', img);

		// no base url
		mockEvent.$("getSESBaseURL","");
		img = plugin.img("includes/images/pio.jpg");
		assertEquals('<img src="includes/images/pio.jpg" />', img);
	}

	function testLink(){
		// with htmlbaseURL
		mockController.$("settingExists",true);
		plugin.$("getSetting").$args("htmlBaseURL").$results("http://www.coldbox.org");

		str = plugin.link(href='luis.css', sendToHeader=false);
		str = plugin.link(href='http://hello.com/luis.css', sendToHeader=false);

		var xml = xmlParse( str );
		assertEquals( xml.link.XMLAttributes.charset, "UTF-8" );
		assertEquals( xml.link.XMLAttributes.href, "http://hello.com/luis.css" );
	}

	function testOL(){

		str = plugin.ol("1,2");
		assertEquals( "<ol><li>1</li><li>2</li></ol>", str);
	}

	function testUL(){
		var data = [1,2,[1,2]];

		str = plugin.ul("1,2");
		assertEquals( "<ul><li>1</li><li>2</li></ul>", str);

		str = plugin.ul(values=data,class="cool");
		assertEquals( '<ul class="cool"><li>1</li><li>2</li><ul><li>1</li><li>2</li></ul></ul>', str);
	}

	function testListWithQuery(){
		var data = querySim("id,name
		#createUUID()# | luis
		#createUUID()# | joe
		#createUUID()# | fernando
		");
		mockArray = ["luis","joe","fernando"];
		plugin.$("getColumnArray",mockArray);

		str = plugin.ul(values=data,column="name");
		debug(str);
		assertEquals( '<ul><li>luis</li><li>joe</li><li>fernando</li></ul>', str);
	}

	function testMeta(){
		var data = [
			{name="luis",content="awesome"},
			{name="test",content="2",type="equiv"}
		];


		str = plugin.meta(name="luis",content="awesome",sendToHeader=false);
		assertEquals('<meta name="luis" content="awesome" />', str);

		str = plugin.meta(name="luis",content="awesome",type="equiv",sendToHeader=false);
		assertEquals('<meta http-equiv="luis" content="awesome" />', str);

		str = plugin.meta(data);
		assertEquals('<meta name="luis" content="awesome" /><meta http-equiv="test" content="2" />', str);
	}

	function testDocType(){
		str = plugin.docType();

		assertEquals('<!DOCTYPE html>',str);
	}

	function testtag(){
		str = plugin.tag("code","hello");
		assertEquals('<code>hello</code>', str);

		str = plugin.tag(tag="code",content="hello",class="cool");
		assertEquals('<code class="cool">hello</code>', str);
	}

	function testAddJSContent(){
		str  = plugin.addJSContent('function test(){ alert("luis"); }');
		debug(str);
		assertEquals('<script type="text/javascript">function test(){ alert("luis"); }</script>', str);
	}

	function testAddStyleContent(){
		str  = plugin.addStyleContent('.test{color: ##123}');
		debug(str);

		assertEquals('<style type="text/css">.test{color: ##123}</style>', str);
	}

	function testTable(){
		data = querySim("id,name
		1 | luis
		2 | peter");

		str = plugin.table(data=data);
		assertEquals("<table><thead><tr><th>ID</th><th>NAME</th></tr></thead><tbody><tr><td>1</td><td>luis</td></tr><tr><td>2</td><td>peter</td></tr></tbody></table>",
					 str);

		str = plugin.table(data=data,class="test");
		assertEquals('<table class="test"><thead><tr><th>ID</th><th>NAME</th></tr></thead><tbody><tr><td>1</td><td>luis</td></tr><tr><td>2</td><td>peter</td></tr></tbody></table>',
					 str);

		str = plugin.table(data=data,includes="name",class="test");
		assertEquals('<table class="test"><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>',
					 str);

		str = plugin.table(data=data,excludes="id",class="test");
		assertEquals('<table class="test"><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>',
					 str);
	}

	function testTableORM() skip="true"{
		data = entityLoad("User");

		str = plugin.table(data=data,includes="firstName");
		debug(str);
		assertTrue( isXML(str) );
	}

	function testTableArrayofStructs(){
		data = [
		{id=1, name="luis"},
		{id=2, name="peter"}
		];

		str = plugin.table(data=data);
		assertEquals("<table><thead><tr><th>NAME</th><th>ID</th></tr></thead><tbody><tr><td>luis</td><td>1</td></tr><tr><td>peter</td><td>2</td></tr></tbody></table>",
					 str);

		str = plugin.table(data=data,class="test");
		assertEquals('<table class="test"><thead><tr><th>NAME</th><th>ID</th></tr></thead><tbody><tr><td>luis</td><td>1</td></tr><tr><td>peter</td><td>2</td></tr></tbody></table>',
					 str);

		str = plugin.table(data=data,includes="name",class="test");
		assertEquals('<table class="test"><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>',
					 str);

		str = plugin.table(data=data,excludes="id",class="test");
		assertEquals('<table class="test"><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>',
					 str);
	}

	function testSlugify(){
		data = {
			title1 = "My Awesome Post",
			title2 = "Sept. Is great- for me--and you"
		};

		str = plugin.slugify( data.title1 );
		debug(str);
		assertEquals("my-awesome-post", str);

		str = plugin.slugify( data.title2 );
		debug(str);
		assertEquals("sept-is-great-for-me-and-you", str);
	}

	function testAutoDiscoveryLink(){
		var str = plugin.autoDiscoveryLink(href="/action/rss",title="MY RSS Feed");
		var xml = xmlParse( str );
		assertEquals( xml.link.XMLAttributes.type, "application/rss+xml" );
		assertEquals( xml.link.XMLAttributes.href, "/action/rss" );

		var str = plugin.autoDiscoveryLink(type="atom",href="/action/rss",title="MY RSS Feed");
		var xml = xmlParse( str );
		assertEquals( xml.link.XMLAttributes.type, "application/atom+xml" );
		assertEquals( xml.link.XMLAttributes.href, "/action/rss" );
	}

	function testVideo(){
		var str = plugin.video(src="includes/movie.ogg",autoplay=true,width="200",height="200");
		var xml = xmlParse( str );
		assertEquals( xml.video.XMLAttributes.width, "200" );
		assertEquals( xml.video.XMLAttributes.height, "200" );
		assertEquals( xml.video.XMLAttributes.src, "includes/movie.ogg" );

	}

	function testAudio(){
		var str = plugin.audio(src="includes/song.ogg",autoplay=true,loop=true);
		var xml = xmlParse( str );
		assertEquals( xml.audio.XMLAttributes.autoplay, "autoplay" );
		assertEquals( xml.audio.XMLAttributes.loop, "loop" );
		assertEquals( xml.audio.XMLAttributes.src, "includes/song.ogg" );
	}

	function testCanvas(){
		var str = plugin.canvas("test");
		var xml = xmlParse( str );
		assertEquals( xml.canvas.XMLAttributes.id, "test" );
	}

	function testForm(){
		str = plugin.endForm();
		assertEquals( "</form>",str);

		str = plugin.startForm(action='user.save');
		//debug(str);
		assertTrue( findNoCase( 'action="index.cfm?event=user.save"', str)  );

		var mockEvent = getMockRequestContext()
			.$("buildLink", "http://www.coldbox.org/user/save");
		mockRequestService.$("getContext", mockEvent);
		str = plugin.startForm(action='user.save');
		//debug(str);
		assertTrue( findNoCase( 'action="http://www.coldbox.org/user/save"', str ) );

		var mockEvent = getMockRequestContext()
			.$("buildLink", "https://www.coldbox.org/user/save");
		mockRequestService.$("getContext", mockEvent);
		str = plugin.startForm(action='user.save',ssl=true);
		//debug(str);
		assertTrue( findNoCase( 'action="https://www.coldbox.org/user/save"', str ) );

		str = plugin.startForm(action='user.save',method="get",name="userForm");
		//debug(str);
		assertTrue( findNoCase( 'action="https://www.coldbox.org/user/save"', str) );

		// self-submitting
		mockEvent.$("getCurrentEvent","user.home").$("buildLink", "https://www.coldbox.org/user/home");
		str = plugin.startForm();
		debug(str);
		assertTrue( findNoCase( 'action="https://www.coldbox.org/user/home"', str ) );
	}

	function testLabel(){
		str = plugin.label(field="name");
		assertEquals('<label for="name">Name</label>', str);

		str = plugin.label(field="name",content="My Name");
		assertEquals('<label for="name">My Name</label>', str);

		str = plugin.label(field="name",content="My Name",wrapper="div");
		//debug(str);
		assertEquals('<div><label for="name">My Name</label></div>', str);
	}

	function testTextArea(){
		str = plugin.textarea(name="message");
		assertEquals('<textarea name="message" id="message"></textarea>', str);

		str = plugin.textarea(name="message",value="Hello");
		assertEquals('<textarea name="message" id="message">Hello</textarea>', str);

		str = plugin.textarea(name="message",value="Hello",label="Message");
		assertEquals('<label for="Message">Message</label><textarea name="message" id="message">Hello</textarea>', str);

		str = plugin.textarea(name="message",value="Hello",label="Message",wrapper="div");
		debug(str);
		assertEquals('<label for="Message">Message</label><div><textarea name="message" id="message">Hello</textarea></div>', str);

		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.textarea(name="lastName",bind=majano);
		debug(str);
		assertEquals( xmlParse( '<textarea name="lastName" id="lastName">Majano</textarea>' ), xmlParse( str ) );
	}

	function testPasswordField(){
		str = plugin.passwordField(name="message",value="test");
		assertEquals( xmlParse( '<input name="message" value="test" id="message" type="password"/>' ), xmlParse( str ) );
	}

	function testHiddenField(){
		str = plugin.hiddenField(name="message");
		assertEquals( xmlParse( '<input name="message" id="message" type="hidden"/>' ), xmlParse( str ) );

		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.hiddenField(name="lastName",bind=majano);
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
	}

	function testTextField(){
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.textField(name="lastName",bind=majano, data={ type="awesome", tooltip="true", modal=true });

		//writeDump(str);abort;

		assertTrue( findNocase('value="Majano"', str) );
		assertTrue( findNocase('data-type="awesome"', str) );
		assertTrue( findNocase('data-tooltip="true"', str) );
	}

	function testButton(){
		str = plugin.button(name="message",value="hello",type="submit");
		assertEquals( xmlparse( '<button name="message" id="message" type="submit">hello</button>' ), xmlParse( str ) );
	}

	function testFileField(){
		str = plugin.fileField(name="message",value="test");
		assertEquals( xmlParse( '<input name="message" value="test" id="message" type="file"/>' ), xmlParse( str ));
	}

	function testCheckbox(){
		str = plugin.checkbox(name="message");
		assertEquals( xmlParse( '<input name="message" value="true" id="message" type="checkbox"/>' ), xmlParse( str ) );

		str = plugin.checkbox(name="message",value="test",checked=true);
		//debug(str);
		assertTrue( findnocase('checked="checked"', str));
		assertTrue( findnocase('value="Test"', str));

		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.checkbox(name="lastName", bind=majano, value="majano");
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
		assertTrue( findNocase('checked="true"', str) );
	}

	function testRadioButton(){
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.radioButton(name="lastName", bind=majano, value="majano");

		assertTrue( findNocase('value="majano"', str) );
		assertTrue( findNocase('checked="true"', str) );

		str = plugin.radioButton(name="message");
		assertEquals( xmlParse( '<input name="message" value="true" id="message" type="radio"/>' ), xmlparse( str ));

		str = plugin.radioButton(name="message",value="test",checked=true);
		assertEquals( "checked", xmlParse( str ).input.xmlAttributes.checked );


		majano = entityLoad("User",{lastName="Majano"}, true);
		majano.setuserName( 'yes' );
		str = plugin.radioButton( name="userName", bind=majano, value="yes" );
		assertTrue( findNocase('value="yes"', str) );
		assertTrue( findNocase('checked="true"', str) );
	}

	function testsubmitButton(){
		str = plugin.submitButton(name="message");
		assertEquals( xmlParse( '<input name="message" value="Submit" id="message" type="submit"/>' ), xmlParse( str ) );

	}

	function testresetButton(){
		str = plugin.resetButton(name="message");
		assertEquals( xmlParse( '<input name="message" value="Reset" id="message" type="reset"/>' ),  xmlParse( str ) );

	}

	function testIMageButton(){
		str = plugin.imageButton(name="message",src="includes/photo.jpg");
		assertTrue( findNocase('src="includes/photo.jpg"', str) );
	}

	function testOptions(){
		// array
		str = plugin.options(values=[1,2,3]);
		//debug( str );
		assertEquals('<option value="1">1</option><option value="2">2</option><option value="3">3</option>', str);

		// array of structs
		str = plugin.options(values=[{value=1,name="1"},{name=2,value=2},{name=3,value=3}]);
		//debug( str );
		assertEquals('<option value="1">1</option><option value="2">2</option><option value="3">3</option>', str);

		// simple list
		str = plugin.options(values="1,2,3");
		//debug( str );
		assertEquals('<option value="1">1</option><option value="2">2</option><option value="3">3</option>', str);

		// query
		qList = getMockBox().querySim("name
		luis
		joe
		alexia");
		str = plugin.options(values=qList,column="name");
		//debug( str );
		assertEquals('<option value="luis">luis</option><option value="joe">joe</option><option value="alexia">alexia</option>', str);

		str = plugin.options(values=qList);
		//debug( str );
		assertEquals('<option value="luis">luis</option><option value="joe">joe</option><option value="alexia">alexia</option>', str);

		// query
		qList = getMockBox().querySim("name, id
		luis| 1
		joe| 2
		alexia| 3");
		str = plugin.options(values=qList,column="id",nameColumn="name");
		//debug( str );
		assertEquals('<option value="1">luis</option><option value="2">joe</option><option value="3">alexia</option>', str);
	}

	function testSelect(){
		// array
		str = plugin.select(name="users",options=[1,2,3]);
		debug( str );
		assertEquals('<select name="users" id="users"><option value="1">1</option><option value="2">2</option><option value="3">3</option></select>', str);
	}

	function testAnchor(){
		str = plugin.anchor(name="lui");
		debug( str );
		assertEquals('<a name="lui"></a>', str);

		str = plugin.anchor(name="lui",text="Luis");
		debug( str );
		assertEquals('<a name="lui">Luis</a>', str);
	}

	function testhref(){
		str = plugin.href(href="actions.save");
		debug(str);
		assertEquals('<a href="index.cfm?event=actions.save"></a>', str);

		str = plugin.href(href="actions.save",text="Edit");
		debug(str);
		assertEquals('<a href="index.cfm?event=actions.save">Edit</a>', str);
	}


	function testFieldset(){
		str = plugin.startFieldset(legend="Luis");
		debug(str);
		assertEquals('<fieldset><legend>Luis</legend>', str);

		str = plugin.endFieldSet();
		debug(str);
		assertEquals('</fieldset>', str);
	}

	function testEmailField(){
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.emailField(name="lastName",bind=majano);
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
	}

	function testURLField(){
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.urlField(name="lastName",bind=majano);
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
	}

	function testXSS(){
		var str = plugin.textField( name="luis", value='"><img src=x onerror=prompt(1)> or "><script>alert(/xss/)</script>' );
		// if it parses, then it is escaped, else it fails.
		var xml = xmlParse( str );
	}


</cfscript>

</cfcomponent>

<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.HTMLHelper">
<cfscript>

	function testaddAssetJS(){
		var mockEvent = getMockRequestContext();
		mockRequestService.$("getContext", mockEvent);
		
		plugin.$("$htmlhead");
		plugin.addAsset('test.js,luis.js');
		
		debug( plugin.$callLog().$htmlhead);
		
		// test duplicate call
		assertEquals('<script src="test.js" type="text/javascript"></script><script src="luis.js" type="text/javascript"></script>' , plugin.$callLog().$htmlhead[1][1] );
		plugin.addAsset('test.js');
		assertEquals(1, arrayLen(plugin.$callLog().$htmlHead) );
	}
	
	function testaddAssetCSS(){
		var mockEvent = getMockRequestContext();
		mockRequestService.$("getContext", mockEvent);
		
		plugin.$("$htmlhead");
		plugin.addAsset('test.css,luis.css');
		
		debug( plugin.$callLog().$htmlhead);
		
		// test duplicate call
		assertEquals('<link href="test.css" type="text/css" rel="stylesheet" /><link href="luis.css" type="text/css" rel="stylesheet" />' , plugin.$callLog().$htmlhead[1][1] );
		plugin.addAsset('test.css');
		assertEquals(1, arrayLen(plugin.$callLog().$htmlHead) );
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
		
		str = plugin.link('luis.css');
		
		debug(str);
		
		str = plugin.link('http://hello.com/luis.css');
		
		assertEquals('<link rel="stylesheet" charset="UTF-8" type="text/css" href="http://hello.com/luis.css"/>', str);
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
		queryHelperStub = getMockBox().createStub();
		mockArray = ["luis","joe","fernando"];
		queryHelperStub.$("getColumnArray",mockArray);
		plugin.$("getPlugin",queryHelperStub);
		
		str = plugin.ul(values=data,column="name");
		debug(str);
		assertEquals( '<ul><li>luis</li><li>joe</li><li>fernando</li></ul>', str);
	}
	
	function testMeta(){
		var data = [
			{name="luis",content="awesome"},
			{name="test",content="2",type="equiv"}
		];
		
		
		str = plugin.meta(name="luis",content="awesome");
		assertEquals('<meta name="luis" content="awesome" />', str);
		
		str = plugin.meta(name="luis",content="awesome",type="equiv");
		assertEquals('<meta http-equiv="luis" content="awesome" />', str);
		
		str = plugin.meta(data);
		assertEquals('<meta name="luis" content="awesome" /><meta http-equiv="test" content="2" />', str);
	}
	
	function testDocType(){
		str = plugin.docType();
		
		assertEquals('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',str);
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
		
		assertEquals('<script type="text/javascript"><![CDATA[function test(){ alert("luis"); }//]]></script>', str);
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
	
	function testTableORM(){
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
		str = plugin.autoDiscoveryLink(href="/action/rss",title="MY RSS Feed");
		//debug(str);
		assertEquals('<link rel="alternate" type="application/rss+xml" title="MY RSS Feed" href="/action/rss"/>' , str);
		
		str = plugin.autoDiscoveryLink(type="atom",href="/action/rss",title="MY RSS Feed");
		//debug(str);
		assertEquals('<link rel="alternate" type="application/atom+xml" title="MY RSS Feed" href="/action/rss"/>' , str);
	}
	
	function testVideo(){
		str = plugin.video("includes/movie.ogg");
		//debug(str);
		assertEquals('<video controls="controls" src="includes/movie.ogg" />', str);
		
		str = plugin.video(src="includes/movie.ogg",autoplay=true,width="200",height="200");
		debug(str);
		assertEquals('<video controls="controls" autoplay="autoplay" height="200" width="200" src="includes/movie.ogg" />', str);
		
		str = plugin.video(["includes/movie.ogg","includes/movie2.mp4"]);
		//debug(str);
		assertEquals('<video controls="controls"><source src="includes/movie.ogg"/><source src="includes/movie2.mp4"/></video>', str);
	}
	
	function testAudio(){
		str = plugin.audio("includes/song.ogg");
		//debug(str);
		assertEquals('<audio controls="controls" src="includes/song.ogg" />', str);
		
		str = plugin.audio(src="includes/song.ogg",autoplay=true,loop=true);
		debug(str);
		assertEquals('<audio controls="controls" autoplay="autoplay" loop="loop" src="includes/song.ogg" />', str);
		
		str = plugin.audio(["includes/song.ogg","includes/song.mp4"]);
		//debug(str);
		assertEquals('<audio controls="controls"><source src="includes/song.ogg"/><source src="includes/song.mp4"/></audio>', str);
	}
	
	
	function testCanvas(){
		str = plugin.canvas("test");
		debug(str);
		assertEquals('<canvas id="test"></canvas>', str);		
	}
	
	function testForm(){
		str = plugin.endForm();
		assertEquals( "</form>",str);	
		
		str = plugin.startForm(action='user.save');
		//debug(str);
		assertEquals('<form method="POST" action="index.cfm?event=user.save">', str);	
	
		var mockEvent = getMockRequestContext()
			.$("buildLink", "http://www.coldbox.org/user/save");
		mockRequestService.$("getContext", mockEvent);
		str = plugin.startForm(action='user.save');
		//debug(str);
		assertEquals('<form method="POST" action="http://www.coldbox.org/user/save">', str);	
		
		var mockEvent = getMockRequestContext()
			.$("buildLink", "https://www.coldbox.org/user/save");
		mockRequestService.$("getContext", mockEvent);
		str = plugin.startForm(action='user.save',ssl=true);
		//debug(str);
		assertEquals('<form method="POST" action="https://www.coldbox.org/user/save">', str);
		
		str = plugin.startForm(action='user.save',method="get",name="userForm");
		//debug(str);
		assertEquals('<form name="userForm" id="userForm" method="get" action="https://www.coldbox.org/user/save">', str);	
		
		// self-submitting
		mockEvent.$("getCurrentEvent","user.home").$("buildLink", "https://www.coldbox.org/user/home");
		str = plugin.startForm();
		debug(str);
		assertEquals('<form method="POST" action="https://www.coldbox.org/user/home">', str);	
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
		assertEquals('<textarea name="lastName" id="lastName">Majano</textarea>', str);
	}
	
	function testPasswordField(){
		str = plugin.passwordField(name="message");
		assertEquals('<input name="message" id="message" type="password"/>', str);
		
		str = plugin.passwordField(name="message",value="test");
		assertEquals('<input name="message" value="test" id="message" type="password"/>', str);
	}
	
	function testHiddenField(){
		str = plugin.hiddenField(name="message");
		assertEquals('<input name="message" id="message" type="hidden"/>', str);
		
		str = plugin.hiddenField(name="message",value="test");
		assertEquals('<input name="message" value="test" id="message" type="hidden"/>', str);
		
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.hiddenField(name="lastName",bind=majano);
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
	}
	
	function testTextField(){
		str = plugin.textField(name="message");
		assertEquals('<input name="message" id="message" type="text"/>', str);
		
		str = plugin.textField(name="message",value="test");
		assertEquals('<input name="message" value="test" id="message" type="text"/>', str);
		
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.textField(name="lastName",bind=majano);
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
	}
	
	function testButton(){
		str = plugin.button(name="message");
		assertEquals('<button name="message" id="message" type="button"></button>', str);
		
		str = plugin.button(name="message",value="hello",type="submit");
		assertEquals('<button name="message" id="message" type="submit">hello</button>', str);
		
	}
	
	function testFileField(){
		str = plugin.fileField(name="message");
		assertEquals('<input name="message" id="message" type="file"/>', str);
		
		str = plugin.fileField(name="message",value="test");
		assertEquals('<input name="message" value="test" id="message" type="file"/>', str);
	}
	
	function testCheckbox(){
		str = plugin.checkbox(name="message");
		assertEquals('<input name="message" value="true" id="message" type="checkbox"/>', str);
		
		str = plugin.checkbox(name="message",value="test",checked=true);
		debug(str);
		assertTrue( findnocase('checked="checked"', str));
		assertTrue( findnocase('value="Test"', str));
		
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.checkbox(name="lastName",bind=majano);
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
	}
	
	function testRadioButton(){
		str = plugin.radioButton(name="message");
		assertEquals('<input name="message" value="true" id="message" type="radio"/>', str);
		
		str = plugin.radioButton(name="message",value="test",checked=true);
		debug(str);
		assertEquals('<input name="message" value="test" id="message" checked="checked" type="radio"/>', str);
		
		// entity binding
		majano = entityLoad("User",{lastName="Majano"}, true);
		str = plugin.radioButton(name="lastName",bind=majano);
		debug(str);
		assertTrue( findNocase('value="Majano"', str) );
	}
	
	function testsubmitButton(){
		str = plugin.submitButton(name="message");
		assertEquals('<input name="message" value="Submit" id="message" type="submit"/>', str);
	
	}
	
	function testresetButton(){
		str = plugin.resetButton(name="message");
		assertEquals('<input name="message" value="Reset" id="message" type="reset"/>', str);
	
	}
	
	function testIMageButton(){
		str = plugin.imageButton(name="message",src="includes/photo.jpg");
		assertTrue( findNocase('src="includes/photo.jpg"', str) );
	}
	
	function testOptions(){
		mockQueryHelper = getMockBox().createMock("coldbox.system.plugins.QueryHelper");
		plugin.$("getPlugin", mockQueryHelper);
		
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
	
		// ORM entities
		data = entityLoad("User");
		str = plugin.options(values=data,column="id",nameColumn="firstName");
		debug( str );
		assertTrue( len(str) );
	}
	
	function testSelect(){
		mockQueryHelper = getMockBox().createMock("coldbox.system.plugins.QueryHelper");
		plugin.$("getPlugin", mockQueryHelper);
		
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
</cfscript>

</cfcomponent>

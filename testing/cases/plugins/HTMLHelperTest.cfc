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
		debug(str);
		assertEquals('<form name="userForm" id="userForm" method="get" action="https://www.coldbox.org/user/save">', str);	
	}
	
</cfscript>

</cfcomponent>

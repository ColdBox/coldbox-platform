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
		mockController.$("settingExists",true);
		plugin.$("getSetting").$args("htmlBaseURL").$results("http://www.coldbox.org");
		
		img = plugin.img("includes/images/pio.jpg");
		assertEquals('<img src="http://www.coldbox.org/includes/images/pio.jpg" />', img);
		
		img = plugin.img("http://hello.com/includes/images/pio.jpg");
		assertEquals('<img src="http://hello.com/includes/images/pio.jpg" />', img);
		
		// no base url
		mockController.$("settingExists",false);
		img = plugin.img("includes/images/pio.jpg");
		assertEquals('<img src="includes/images/pio.jpg" />', img);
		
		props = {
			alt="test",
			src="includes/images/pio.jpg",
			title="test",
			width="400"
		};
		
		img = plugin.img(props);
		assertEquals('<img alt="test" src="includes/images/pio.jpg" width="400" title="test" />', img);
	}
	
	function testLink(){
		// with htmlbaseURL
		mockController.$("settingExists",true);
		plugin.$("getSetting").$args("htmlBaseURL").$results("http://www.coldbox.org");
		
		str = plugin.link('luis.css');
		
		debug(str);
		
		str = plugin.link('http://hello.com/luis.css');
		
		assertEquals('<link rel="stylesheet" type="text/css" href="http://hello.com/luis.css" />', str);
	}
	
	
	function testOL(){
		
		str = plugin.ol("1,2");
		assertEquals( "<ol><li>1</li><li>2</li></ol>", str);
	}
	
	function testUL(){
		var data = [1,2,[1,2]];
		var attrs = {
			class="cool"
		};
		
		str = plugin.ul("1,2");
		assertEquals( "<ul><li>1</li><li>2</li></ul>", str);
		
		str = plugin.ul(data,attrs);
		assertEquals( '<ul class="cool"><li>1</li><li>2</li><ul class="cool"><li>1</li><li>2</li></ul></ul>', str);
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
		
		data={class="cool"};
		str = plugin.tag("code","hello",data);
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
		attrs = {class="test"};
		
		str = plugin.table(data=data);
		assertEquals("<table><thead><tr><th>ID</th><th>NAME</th></tr></thead><tbody><tr><td>1</td><td>luis</td></tr><tr><td>2</td><td>peter</td></tr></tbody></table>",
					 str);
					 
		str = plugin.table(data=data,attributes=attrs);
		assertEquals('<table class="test"><thead><tr><th>ID</th><th>NAME</th></tr></thead><tbody><tr><td>1</td><td>luis</td></tr><tr><td>2</td><td>peter</td></tr></tbody></table>',
					 str);
					 
		str = plugin.table(data=data,attributes=attrs,includes="name");
		assertEquals('<table class="test"><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>',
					 str);
					 
		str = plugin.table(data=data,attributes=attrs,excludes="id");
		assertEquals('<table class="test"><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>',
					 str);
	}
	
	function testTableORM(){
		data = entityLoad("User");
		
		str = plugin.table(data=data,includes="firstName");
		debug(str);
		assertEquals('<table><thead><tr><th>firstName</th></tr></thead><tbody><tr><td>Joe</td></tr><tr><td>Luis</td></tr></tbody></table>',
					 str);
	}
	
	function testTableArrayofStructs(){
		data = [
		{id=1, name="luis"},
		{id=2, name="peter"}
		];
		attrs = {class="test"};
		
		str = plugin.table(data=data);
		assertEquals("<table><thead><tr><th>NAME</th><th>ID</th></tr></thead><tbody><tr><td>luis</td><td>1</td></tr><tr><td>peter</td><td>2</td></tr></tbody></table>",
					 str);
					 
		str = plugin.table(data=data,attributes=attrs);
		assertEquals('<table class="test"><thead><tr><th>NAME</th><th>ID</th></tr></thead><tbody><tr><td>luis</td><td>1</td></tr><tr><td>peter</td><td>2</td></tr></tbody></table>',
					 str);
					 
		str = plugin.table(data=data,attributes=attrs,includes="name");
		assertEquals('<table class="test"><thead><tr><th>NAME</th></tr></thead><tbody><tr><td>luis</td></tr><tr><td>peter</td></tr></tbody></table>',
					 str);
					 
		str = plugin.table(data=data,attributes=attrs,excludes="id");
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
	
</cfscript>

</cfcomponent>

-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.24-standard


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema coldboxreader
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ coldboxreader;
USE coldboxreader;

--
-- Table structure for table `coldboxreader`.`feed`
--

DROP TABLE IF EXISTS `coldboxreader_feed`;
CREATE TABLE `coldboxreader_feed` (
  `FeedID` varchar(50) character set latin1 NOT NULL default '',
  `FeedName` varchar(150) character set latin1 NOT NULL default '',
  `FeedURL` varchar(500) character set latin1 NOT NULL default '',
  `FeedAuthor` varchar(100) character set latin1 NOT NULL default '',
  `Description` varchar(1000) character set latin1 NOT NULL default '',
  `ImgURL` varchar(100) character set latin1 default '',
  `SiteURL` varchar(100) character set latin1 NOT NULL default '',
  `CreatedBy` varchar(50) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  `LastRefreshedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  `Views` int(11) NOT NULL default '1',
  PRIMARY KEY  (`FeedID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`coldboxreader_feed`
--

/*!40000 ALTER TABLE `coldboxreader_feed` DISABLE KEYS */;
LOCK TABLES `coldboxreader_feed` WRITE;
INSERT INTO `coldboxreader_feed` VALUES  ('0EE918C0-E944-C2FF-0E2B8D5E9953BA35','In the Trenches','http://cf-bill.blogspot.com/rss.xml','','','','http://cf-bill.blogspot.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-08-14 18:59:19','2006-09-08 14:57:48',61),
 ('0EE94DA3-EDA4-4EAA-31C1910A45790E6B','1 Pixel Out','http://feeds.feedburner.com/1pixelout','','ColdFusion, Mach-II & other web things','','http://www.1pixelout.net','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-08-14 18:59:33','2006-09-08 14:57:48',61),
 ('5DDF2106-C110-4ABF-8CD8D199C593A366','Ben Forta\'s Blog','http://www.forta.com/blog/rss.cfm?mode=full','','ColdFusion, Flex, Java, Web Services, and whatever else tickles my fancy.','','http://www.forta.com/blog/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-11 09:55:39','2006-09-08 14:57:48',181),
 ('69823D73-96BC-4752-4B2704298E0FF3DA','TechCrunch','http://techcrunch.com/rss','','TechCrunch is a weblog dedicated to obsessively profiling and reviewing every newly launched web 2.0 business, product and service. We are part of the  Archimedes Ventures  Network of Companies.','','http://www.techcrunch.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-14 12:01:16','2006-09-08 14:57:48',514),
 ('6A1316DF-96BC-4752-4275D8DC9F2FAA02','del.icio.us/wencho','http://del.icio.us/rss/wencho','','','','http://del.icio.us/wencho','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-14 14:39:29','2006-09-08 14:57:48',506);
INSERT INTO `coldboxreader_feed` VALUES  ('6A146018-96BC-4752-40FCCFF31F2555AE','HomePortal\'s Blog','http://www.cfempire.com/home/modules/blog/blog.cfc?method=getrss&url=/accounts/wencho/blog.xml','','Keep track of the progress and latest updates on HomePortals','','http://www.homeportals.net/home/home.cfm?currentHome=/Accounts/HomePortals/layouts/blog.xml','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-14 14:40:53','2006-09-10 18:34:30',500),
 ('6A812CF0-96BC-4752-446A0D1734EC9095','Raymond Camden\'s ColdFusion Blog','http://ray.camdenfamily.com/rss.cfm?mode=full','','A blog for ColdFusion, Java, and other topics.','','http://ray.camdenfamily.com/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-14 16:39:44','2006-09-10 18:34:39',404),
 ('6AC826BD-96BC-4752-4043684F248FA053','CNN.com','http://rss.cnn.com/rss/cnn_topstories.rss','','CNN.com delivers up-to-the-minute news and information on the latest top stories, weather, entertainment, politics and more.','http://i.cnn.net/cnn/.element/img/1.0/logo/cnn.logo.rss.gif','http://www.cnn.com/rssclick/?section=cnn_topstories','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-14 17:57:15','2006-09-10 17:29:06',366),
 ('6ECA2920-96BC-4752-41B77F7226521AF5','AS Fusion','http://www.asfusion.com/blog/index.rss','','A blog about ColdFusion, Flash, Java, and other topics.','http://www.asfusion.com/blog/assets/images/banner_88_31.jpg','http://www.asfusion.com/blog/','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-15 12:37:56','2006-09-08 14:57:48',329);
INSERT INTO `coldboxreader_feed` VALUES  ('70083E43-96BC-4752-44319D82D1E6ABC4','Adobe Labs','http://weblogs.macromedia.com/labs/index.xml','','News and information on Adobe Labs.','','http://weblogs.macromedia.com/labs/','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-15 18:25:21','2006-09-08 14:57:48',284),
 ('7320815A-96BC-4752-455B76D27FB198B0','Ajaxian','http://ajaxian.com/index.xml','','Cleaning up the web with Ajax','','http://ajaxian.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-02-16 08:50:43','2006-09-08 14:57:48',276),
 ('84E49995-CBCA-49BB-C73538F75FE9A6DD','HomePortal\'s Blog','http://www.homeportals.net/Home/Modules/Blog/blog.cfc?method=getRSS&url=/Accounts/wencho/blog.xml','','Keep track of the progress and latest updates on HomePortals','','http://www.homeportals.net/home/home.cfm?currentHome=/Accounts/HomePortals/layouts/blog.xml','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:46:49','2006-09-08 14:57:48',167),
 ('84E64A5F-C4DA-C67B-41AE94A9F66F1BED','Raymond Camden\'s ColdFusion Blog','http://ray.camdenfamily.com/rss.cfm?mode=full','','A blog for ColdFusion, Java, and other topics.','','http://ray.camdenfamily.com/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:48:40','2006-09-08 14:57:48',167),
 ('84E6CD28-FCC6-A4F7-3A2392B56477EA11','ColdFusion Open-Source Project List - Remote Synthesis','http://www.remotesynthesis.com/cfopensourcelist/rss.cfm','','Currently indexing 133 free and/or open-source projects.','','http://www.remotesynthesis.com/cfopensourcelist','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:49:13','2006-09-08 14:57:48',167);
INSERT INTO `coldboxreader_feed` VALUES  ('84E7216F-BCED-08E7-3F1506F8247A9D0D','Remote Synthesis','http://www.remotesynthesis.com/blog/rss.cfm?mode=full','','Development using ColdFusion, Flash, SQL and more','','http://www.remotesynthesis.com/blog/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:49:35','2006-09-08 14:57:48',167),
 ('84E7D293-F12A-EC18-FFD3E78413672AD7','CompoundTheory','http://www.compoundtheory.com/?action=rss','','Mark Mandel is a software developer in Melbourne Australia that spends most of his working day developing in ColdFusion and Java on Oracle databases.','','http://www.compoundtheory.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:50:20','2006-09-08 14:57:48',167),
 ('84E7E6EE-DB02-8330-678E2AC94C551F83','An Architect\'s View - ColdFusion, Software Design, Frameworks and more...','http://corfield.org/blog/rss.cfm/mode/full','','Thoughts from the Director of Architecture in IT at Macromedia on: ColdFusion MX, Rich Internet Applications, software design... and neat CFMX hacks!','','http://corfield.org','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:50:25','2006-09-08 14:57:48',167),
 ('84EA3E14-9B28-B700-7A648A03D171D737','Simon Horwith\'s Blog','http://www.horwith.com/rss.cfm?mode=full&','','Simon Horwith\'s Web Log','','http://www.horwith.com/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:52:59','2006-09-08 14:57:48',164);
INSERT INTO `coldboxreader_feed` VALUES  ('84EA8E22-0C22-8B0A-09C44D06C5CA3414','Eclipse News','http://www.eclipse.org/home/eclipsenews.rss','','Eclipse News','http://eclipse.org/images/EclipseBannerPic.jpg','http://eclipse.org','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-18 23:53:19','2006-09-08 14:57:48',163),
 ('87F36880-933C-B175-C38B5E6BA6DBB442','The Warp','http://thewarp.org/blog/rss.cfm?mode=short','','My daily finds online and thoughts...','','http://thewarp.org/blog/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-19 14:01:51','2006-09-08 14:57:48',158),
 ('8AA1E183-9C7B-F8C7-D0679DD9398BF1AE','TechCrunch','http://feeds.feedburner.com/Techcrunch','Michael Arrington','TechCrunch profiles the companies, products and events that are defining and transforming the new web. TechCrunch is written by Michael Arrington.','http://www.techcrunch.com/wp-content/techcrunch2_larger.gif','http://www.techcrunch.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-09-07 19:34:27','2006-09-08 14:57:48',17),
 ('8AA5ABC3-BCBF-75BA-5CC22AC3F902D8D4','Dead2.0','http://feeds.feedburner.com/Dead20','skeptic','Anti-hyping Web 2.0 since 2006!','http://www.dead20.com/images/dead20_logo.jpg','http://www.dead20.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-09-07 19:38:35','2006-09-08 14:57:48',14);
INSERT INTO `coldboxreader_feed` VALUES  ('8AA8F12A-E4CF-9A56-F634C3951910547C','Xilya.com','http://www.xilya.com/Home/Modules/Blog/rss?blog=/Accounts/wencho/myBlog.xml','Oscar Arevalo','A test place for the new version of HomePortals','','http://www.xilya.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-09-07 19:42:10','2006-09-08 14:57:48',12),
 ('8AAA60E6-EC11-82D7-32EE2D4D770FCA25','HomePortal\'s Blog','http://www.homeportals.net/Home/Modules/Blog/blog.cfc?method=getRSS&url=/Accounts/wencho/blog.xml','Oscar Arevalo','Keep track of the progress and latest updates on HomePortals','','http://www.homeportals.net/home/home.cfm?currentHome=/Accounts/HomePortals/layouts/blog.xml','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-09-07 19:43:44','2006-09-08 14:57:48',11),
 ('AD845C93-B49A-5CED-4574BDDC340A6B00','Ajax Patterns - Recent changes [en]','http://www.ajaxpatterns.org/Special:Recentchanges?feed=rss','','Track the most recent changes to the Ajax Patterns wiki on this page. \"AjaxPatterns.org began as a collection of design patterns and grew into a publicly editable wiki on anything and everything Ajax.\"','','http://www.ajaxpatterns.org/Special:Recentchanges','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-26 21:06:08','2006-09-08 14:57:48',134),
 ('AD8FDFC3-DDC3-EABD-A7E60D9E460B0102','clearsoftware.net','http://clearsoftware.net/rss.cfm?mode=full','Joe Rinehart','clearsoftware.net - joe rinehart on coldfusion and more, model-glue','','http://clearsoftware.net/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-26 21:18:42','2006-09-08 14:57:48',131);
INSERT INTO `coldboxreader_feed` VALUES  ('AD91F65D-941D-6276-49514DEF998ACC1C','DougHughes.net','http://www.doughughes.net/index.cfm?event=rss','Doug Hughes','Doug\'s blog on ColdFusion and other stuff.','','http://www.doughughes.net/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-07-26 21:20:59','2006-09-08 14:57:48',131),
 ('D0A69823-B7E1-DDD1-E6A2E12B1BDF2BC8','Rob Gonda\'s ColdFusion Blog','http://www.robgonda.com/blog/rss.cfm?mode=full','Rob Gonda','Rob Gonda\'s opinions','http://www.robgonda.com/blog//files/robGonda/UserFiles/Image/header.jpg','http://www.robgonda.com/blog/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-06-13 23:47:26','2006-09-10 18:34:24',193),
 ('D0A8180D-E942-70A9-43BE4EBA16D30B3E','Luis Majano\'s Java, Coldfusion & More Blog','http://www.luismajano.com/blog/index.cfm?event=ehBlog.dspRss&mode=full','Luis Majano','A blog about coldfusion, java, linux, technology, etc.','','http://www.luismajano.com/blog/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-06-13 23:49:05','2006-09-10 17:38:18',1000),
 ('EF0CBC31-9160-4F02-6D44786AAF25F4F5','even a monkey - can have a good Idea!','http://www.evenamonkey.com/rss.xml','','can program OOP!','','http://www.evenamonkey.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-08-08 14:30:24','2006-09-08 14:57:48',88);
INSERT INTO `coldboxreader_feed` VALUES  ('EF0DD25B-D1AC-528A-E4FFDD443901797F','even a monkey - can have a good Idea!','http://www.evenamonkey.com/rss.xml','','can program OOP!','','http://www.evenamonkey.com','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-08-08 14:31:35','2006-09-08 14:57:48',87),
 ('EF0E0F79-95B1-2FC4-F3B20CBD4BF80957','Blog of Fusion','http://www.blogoffusion.com/rss.cfm?mode=full','','ColdFusion Blogs','','http://www.blogoffusion.com/index.cfm','999DFF03-B01D-D747-56E4AF6BCB2E30C5','2006-08-08 14:31:51','2006-09-10 17:31:39',88);
UNLOCK TABLES;
/*!40000 ALTER TABLE `coldboxreader_feed` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`coldboxreader_feed_comments`
--

DROP TABLE IF EXISTS `coldboxreader_feed_comments`;
CREATE TABLE `coldboxreader_feed_comments` (
  `Feed_CommentID` varchar(50) character set latin1 NOT NULL default '',
  `FeedID` varchar(50) character set latin1 NOT NULL default '',
  `CommentText` varchar(500) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  `CreatedBy` varchar(50) character set latin1 NOT NULL default '',
  PRIMARY KEY  (`Feed_CommentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`coldboxreader_feed_comments`
--

/*!40000 ALTER TABLE `coldboxreader_feed_comments` DISABLE KEYS */;
LOCK TABLES `coldboxreader_feed_comments` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `coldboxreader_feed_comments` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`coldboxreader_feed_tags`
--

DROP TABLE IF EXISTS `coldboxreader_feed_tags`;
CREATE TABLE `coldboxreader_feed_tags` (
  `feed_tagID` varchar(50) character set latin1 NOT NULL default '',
  `feedID` varchar(50) character set latin1 NOT NULL default '',
  `tag` varchar(45) character set latin1 NOT NULL default '',
  `CreatedBy` varchar(50) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`feed_tagID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`coldboxreader_feed_tags`
--

/*!40000 ALTER TABLE `coldboxreader_feed_tags` DISABLE KEYS */;
LOCK TABLES `coldboxreader_feed_tags` WRITE;
INSERT INTO `coldboxreader_feed_tags` VALUES  ('0EF5DEC1-C0A5-E283-5A4D1BB2DB8ABC76','0EE94DA3-EDA4-4EAA-31C1910A45790E6B','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-14 19:13:16'),
 ('0EF5FD90-ADEA-B7D5-9645F654F75C68A3','0EE94DA3-EDA4-4EAA-31C1910A45790E6B','javascript','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-14 19:13:24'),
 ('0EF60FF9-07B3-3C62-1A94AD07354A2021','0EE94DA3-EDA4-4EAA-31C1910A45790E6B','mach-ii','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-14 19:13:29'),
 ('0EF63C17-E51B-E17B-F5D0C2309C82C0D4','0EE918C0-E944-C2FF-0E2B8D5E9953BA35','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-14 19:13:40'),
 ('6AB90AB2-96BC-4752-4757A708F4166DEA','6A812CF0-96BC-4752-446A0D1734EC9095','java','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:40:45'),
 ('6AB90AD1-96BC-4752-43A8B83C4D35A7A9','6A812CF0-96BC-4752-446A0D1734EC9095','coldfusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:40:45'),
 ('6ABF41C2-96BC-4752-4FDD2CE64187A8BE','6A146018-96BC-4752-40FCCFF31F2555AE','HomePortals','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:47:32'),
 ('6AC0CBED-96BC-4752-464A79D550FC84C7','69823D73-96BC-4752-4B2704298E0FF3DA','web2.0','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:49:13');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('6ECAC64A-96BC-4752-430FE65567CBDCE8','6ECA2920-96BC-4752-41B77F7226521AF5','coldfusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 12:38:36'),
 ('6FB6F59B-96BC-4752-4F160374C3ABE36F','6AC826BD-96BC-4752-4043684F248FA053','news','','2006-02-15 16:56:34'),
 ('6FB78921-96BC-4752-41454736E87038E1','6ECA2920-96BC-4752-41B77F7226521AF5','FlashForms','','2006-02-15 16:57:12'),
 ('70087810-96BC-4752-43F2360C466DBCA9','70083E43-96BC-4752-44319D82D1E6ABC4','ColdFusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 18:25:36'),
 ('7008782F-96BC-4752-4C7CFAEAE6FFE4CA','70083E43-96BC-4752-44319D82D1E6ABC4','macromedia','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 18:25:36'),
 ('7008784E-96BC-4752-4B0F35EE8187E5CD','70083E43-96BC-4752-44319D82D1E6ABC4','development','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 18:25:36'),
 ('7320C2B9-96BC-4752-4753E908090E4D92','7320815A-96BC-4752-455B76D27FB198B0','web2.0','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-16 08:51:00'),
 ('7320C2D8-96BC-4752-4D2A403C7B3D2D2F','7320815A-96BC-4752-455B76D27FB198B0','ajax','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-16 08:51:00');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('733BBB43-96BC-4752-4D6632A24D6F46E8','733B9397-96BC-4752-4982446D5FFB691C','ColdFusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-16 09:20:27'),
 ('87F57737-033F-C912-4785615781A182BE','87F36880-933C-B175-C38B5E6BA6DBB442','flash','87F2A0C9-9DF0-DE8C-01198A70A62B1AB0','2006-07-19 14:04:06'),
 ('87F59B07-E970-9209-AA2853F5C3FA8E82','87F36880-933C-B175-C38B5E6BA6DBB442','technology','87F2A0C9-9DF0-DE8C-01198A70A62B1AB0','2006-07-19 14:04:15'),
 ('87F6DECE-A71F-FB46-569F4CCFD46B2033','87F36880-933C-B175-C38B5E6BA6DBB442','macromedia','87F2A0C9-9DF0-DE8C-01198A70A62B1AB0','2006-07-19 14:05:38'),
 ('8AA28DA7-A411-0FEB-CCFD11BA6D6C11FA','8AA1E183-9C7B-F8C7-D0679DD9398BF1AE','web2.0','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:35:11'),
 ('8AA2A69D-FD99-DD1E-FE8EC22FF1AE0D11','8AA1E183-9C7B-F8C7-D0679DD9398BF1AE','ajax','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:35:17'),
 ('8AA38FF6-B923-2326-9EACBBEB65C05D81','8AA1E183-9C7B-F8C7-D0679DD9398BF1AE','news','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:36:17'),
 ('8AA5E7FF-EC5E-D344-F8177FDD15E43BFD','8AA5ABC3-BCBF-75BA-5CC22AC3F902D8D4','web2.0','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:38:51');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('8AA5FC67-9453-D8B1-D8D884B51E44AD20','8AA5ABC3-BCBF-75BA-5CC22AC3F902D8D4','news','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:38:56'),
 ('8AA92AE2-F5CC-FD59-F23C47EA9F5CB189','8AA8F12A-E4CF-9A56-F634C3951910547C','HomePortals','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:42:24'),
 ('8AA942B1-0E3D-786D-31834435849FE1DC','8AA8F12A-E4CF-9A56-F634C3951910547C','ajax','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:42:31'),
 ('8AA95170-D57A-2E14-15065D7E2EFE15F0','8AA8F12A-E4CF-9A56-F634C3951910547C','web2.0','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:42:34'),
 ('8AAA8A2B-E2CB-CCE5-7C939F7F94FADAF8','8AAA60E6-EC11-82D7-32EE2D4D770FCA25','HomePortals','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:43:54'),
 ('8AAA95EE-0278-C121-CB4FC32207D300C7','8AAA60E6-EC11-82D7-32EE2D4D770FCA25','ajax','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:43:57'),
 ('8AAAA107-939A-F8F5-C3826CC35B97CFE9','8AAA60E6-EC11-82D7-32EE2D4D770FCA25','web2.0','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:44:00'),
 ('8AAAF06C-AD02-A025-4E4A4959894AB252','8AAA60E6-EC11-82D7-32EE2D4D770FCA25','coldfusion','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:44:21');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('8AAB105C-97FE-F9FE-5479941500F9D477','8AA8F12A-E4CF-9A56-F634C3951910547C','coldfusion','8A9FECBB-9E30-BDEE-593AF4508ADB1AAA','2006-09-07 19:44:29'),
 ('93A534B0-C385-7D60-0D4F5F2C39D6B01E','84E7D293-F12A-EC18-FFD3E78413672AD7','Coldfusion','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-07-21 20:31:53'),
 ('93A5460B-C7F1-6E59-D671D8E2DE8D22C3','84E7D293-F12A-EC18-FFD3E78413672AD7','java','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-07-21 20:31:57'),
 ('9A993507-CD66-B312-145DFB75BDC01339','6A1316DF-96BC-4752-4275D8DC9F2FAA02','Nerd','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 00:47:45'),
 ('9AC8C243-D5C4-1AF1-57B7E4F644895CCF','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','Nerd','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:41'),
 ('9AC8CF50-AD08-28FA-5C823E87347C08BF','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','Coldfusion','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:44'),
 ('9AC8DCA0-E6C0-7D78-5C5B2E489EEFDBAD','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','flash','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:48'),
 ('9AC8DD70-C4A5-D886-96AE54A1CEC83063','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','remoting','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:48');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('9AC8F4D3-FC57-D994-8C4B95890FAA2475','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','textus','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:54'),
 ('9AC9023F-FD69-2FA1-32927564251AEBD9','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','framework','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:58'),
 ('9AC92728-94C4-52BB-6E243B12D22B8D10','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','object','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:40:07'),
 ('9AC9280E-BA2A-900F-30D58F70DEFB58E7','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','oriented','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:40:07'),
 ('9AC9326D-9AB0-B142-3CC65665CF96A059','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','java','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:40:10'),
 ('AD874CBC-0D02-8C00-3EEAD852D08DC546','AD845C93-B49A-5CED-4574BDDC340A6B00','ajax','AD82717F-9079-C9EC-6D33897A56F60085','2006-07-26 21:09:20'),
 ('AD8CC93B-9A2A-41A8-94B5A45173CE495B','84E7E6EE-DB02-8330-678E2AC94C551F83','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-07-26 21:15:20'),
 ('AD922FCD-D0BF-2213-EA5A7DD52AE7D720','AD8FDFC3-DDC3-EABD-A7E60D9E460B0102','model','AD82717F-9079-C9EC-6D33897A56F60085','2006-07-26 21:21:14');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('AD922FD4-9C91-4793-73E0C3622DE26D92','AD8FDFC3-DDC3-EABD-A7E60D9E460B0102','glue','AD82717F-9079-C9EC-6D33897A56F60085','2006-07-26 21:21:14'),
 ('AD9243A0-C297-EB31-BB9B05D88E274D13','AD8FDFC3-DDC3-EABD-A7E60D9E460B0102','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-07-26 21:21:19'),
 ('AFE711E2-F1B1-D813-E4AE3BDCF5F2A03E','AD91F65D-941D-6276-49514DEF998ACC1C','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-07-27 08:13:11'),
 ('D0A6BCC1-DA4C-AD32-A32523BF59F70537','D0A69823-B7E1-DDD1-E6A2E12B1BDF2BC8','Coldfusion','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:47:36'),
 ('D0A6C995-94ED-E04D-8E838AEF4AA89848','D0A69823-B7E1-DDD1-E6A2E12B1BDF2BC8','Ajax','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:47:39'),
 ('D0A84911-D38D-9842-AF0F5716E7C34666','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Coldfusion','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:17'),
 ('D0A855DB-CC0E-8310-A96A3B163F25B184','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Ajax','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:20'),
 ('D0A85ED1-EE48-17C8-446D1CB5F40469E3','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Java','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:23');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('D0A86CD2-95F4-8B68-FE01CE7762BA9A6D','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Nerd','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:26'),
 ('D0A8809D-E25F-81E0-DD7FCE3614491E0B','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Coldbox','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:31'),
 ('D0A88DE0-EBCD-B8BD-0E2FC4E80ABEA17F','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Framework','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:35'),
 ('D0A89FDF-E0E5-5EF7-84E2AE436C7719DC','D0A8180D-E942-70A9-43BE4EBA16D30B3E','OOP','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:39'),
 ('EF0FB047-ED30-79FA-0A7985240EE67D30','EF0CBC31-9160-4F02-6D44786AAF25F4F5','reactor','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-08 14:33:38'),
 ('EF0FD5E8-B240-D7C3-4FE01B1C257E674A','EF0CBC31-9160-4F02-6D44786AAF25F4F5','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-08 14:33:47'),
 ('EF0FF4D8-914E-DB4F-150A922DC91963C1','EF0CBC31-9160-4F02-6D44786AAF25F4F5','modelglue','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-08 14:33:55'),
 ('EF10665F-9A68-77D7-B64A1E8FAB4BD251','EF0DD25B-D1AC-528A-E4FFDD443901797F','reactor','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-08 14:34:24');
INSERT INTO `coldboxreader_feed_tags` VALUES  ('EF1081A7-0FDD-E7AF-9000C25B33C284F4','EF0DD25B-D1AC-528A-E4FFDD443901797F','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-08 14:34:31'),
 ('EF109736-E723-91D8-3C567B7819242C43','EF0DD25B-D1AC-528A-E4FFDD443901797F','modelglue','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-08 14:34:37'),
 ('EF10D97C-0C44-D1BA-F92A6557284DB22F','EF0E0F79-95B1-2FC4-F3B20CBD4BF80957','coldfusion','AD82717F-9079-C9EC-6D33897A56F60085','2006-08-08 14:34:54');
UNLOCK TABLES;
/*!40000 ALTER TABLE `coldboxreader_feed_tags` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`coldboxreader_feed_votes`
--

DROP TABLE IF EXISTS `coldboxreader_feed_votes`;
CREATE TABLE `coldboxreader_feed_votes` (
  `Feed_VoteID` varchar(50) character set latin1 NOT NULL default '',
  `FeedID` varchar(50) character set latin1 NOT NULL default '',
  `CreatedBy` varchar(50) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`Feed_VoteID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`coldboxreader_feed_votes`
--

/*!40000 ALTER TABLE `coldboxreader_feed_votes` DISABLE KEYS */;
LOCK TABLES `coldboxreader_feed_votes` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `coldboxreader_feed_votes` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`coldboxreader_users`
--

DROP TABLE IF EXISTS `coldboxreader_users`;
CREATE TABLE `coldboxreader_users` (
  `UserID` varchar(50) character set latin1 NOT NULL default '',
  `UserName` varchar(20) character set latin1 NOT NULL default '',
  `Password` varchar(45) character set latin1 NOT NULL default '',
  `Email` varchar(45) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  `LastLogin` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`coldboxreader_users`
--

/*!40000 ALTER TABLE `coldboxreader_users` DISABLE KEYS */;
LOCK TABLES `coldboxreader_users` WRITE;
INSERT INTO `coldboxreader_users` VALUES  ('999DFF03-B01D-D747-56E4AF6BCB2E30C5','admin','3186E4493C020FA414DC803F0BD478B7','admin@email.com','2006-09-10 17:24:31','2006-09-10 18:39:45');
UNLOCK TABLES;
/*!40000 ALTER TABLE `coldboxreader_users` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

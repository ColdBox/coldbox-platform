# ************************************************************
# Sequel Pro SQL dump
# Version 4529
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: Localhost (MySQL 5.6.21)
# Database: coolblog
# Generation Time: 2016-02-27 23:03:57 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table blogEntries
# ------------------------------------------------------------
USE `coolblog`;

DROP TABLE IF EXISTS `blogEntries`;

CREATE TABLE `blogEntries` (
  `blogEntriesID` int(11) NOT NULL AUTO_INCREMENT,
  `blogEntriesLink` longtext NOT NULL,
  `blogEntriesTitle` longtext NOT NULL,
  `blogEntriesDescription` longtext NOT NULL,
  `blogEntriesDatePosted` datetime NOT NULL,
  `blogEntriesdateUpdated` datetime NOT NULL,
  `blogEntriesIsActive` bit(1) NOT NULL,
  `blogsID` int(11) DEFAULT NULL,
  PRIMARY KEY (`blogEntriesID`),
  KEY `FK2828728E45296FD` (`blogsID`),
  CONSTRAINT `FK2828728E45296FD` FOREIGN KEY (`blogsID`) REFERENCES `blogs` (`blogsID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `blogEntries` WRITE;
/*!40000 ALTER TABLE `blogEntries` DISABLE KEYS */;

INSERT INTO `blogEntries` (`blogEntriesID`, `blogEntriesLink`, `blogEntriesTitle`, `blogEntriesDescription`, `blogEntriesDatePosted`, `blogEntriesdateUpdated`, `blogEntriesIsActive`, `blogsID`)
VALUES
	(1,'http://blog.coldbox.org/post.cfm/coldbox-wiki-docs-skins-shared','ColdBox Wiki Docs Skins Shared','Since we love collaboration and giving back to the community, we have just opened our Wiki Docs Skins github repository so you can check out how we build out our wiki docs skins for CodexWiki and hopefully you guys can send us your skins and we can use them on the wiki docs site :)','2011-04-06 11:13:52','2011-04-06 11:13:52',b'1',1),
	(2,'http://blog.coldbox.org/post.cfm/new-coldbox-wiki-docs','New ColdBox Wiki Docs','We have been wanting to update all our sites for a long time and the docs where first. Yesterday we updated our codex skins for the coldbox wiki docs and also started our documentation revisions and updates. You will see that it is now much much better organized and our new quick index feature enables you to get to content even faster. Hopefully in the coming weeks we will have all our documentation updated and running. Thank you for your support and feedback.','2011-04-06 10:57:17','2011-04-06 10:57:17',b'1',1),
	(3,'http://blog.coldbox.org/post.cfm/modules-contest-ends-this-friday','Modules Contest Ends This Friday','Just a quick reminder that our Modules Contest ends this Friday! So get to it, build some apps! Modules Contest URL: http://blog.coldbox.org/post.cfm/coldbox-modules-contest-extended','2011-04-04 11:22:19','2011-04-04 11:22:19',b'1',1),
	(4,'http://blog.coldbox.org/post.cfm/coldbox-connection-recording-coldbox-3-0-0','ColdBox Connection Recording: ColdBox 3.0.0','Thanks for attending our 3rd ColdBox Connection webinar today!&nbsp; This  webinar focused on ColdBox 3.0.0 release and goodies.&nbsp; Here is the recording for the show!','2011-03-30 15:42:16','2011-03-30 15:42:16',b'1',1),
	(5,'http://blog.coldbox.org/post.cfm/coldbox-platform-3-0-0-released','ColdBox Platform 3.0.0 Released','\n  \n  \nI am so happy to finally announce ColdBox Platform 3.0.0 today on March 3.0, 2011. It has been over a year of research, testing, development, coding, long long nights, 1 beautiful baby girl, lots of headaches, lots of smiles, inspiration, blessings, new contributors, new team members, new company, new hopes, and ambitions. Overall, what an incredible year for ColdFusion and ColdBox development. I can finally say that this release has been the most ambitious release and project I have tackled in my entire professional life. I am so happy of the results and its incredible community response and involvement. So thank you so much Team ColdBox and all the community for the support and long hours of testing, ideas and development.\nColdBox 3 has been on a journey of 6 defined milestones and 2 release candidates in a spawn of over a year of development. Our vision was revamping the engine into discrete and isolated parts:\n\nCore\nLogBox : Enterprise Logging Library\nWireBox : Enterprise Dependency Injection and AOP framework\nCacheBox : Enterprise Caching Engine &amp; Cache Aggregator\nMockBox : Mocking/Stubbing Framework\n\nAll of these parts are now standalone and can be used with any ColdFusion application or ColdFusion framework. We believe we build great tools and would like everybody to have access to them even though they might not even use ColdBox MVC. Apart from the incredible amount of enhancements, we also ventured into several incredible new features:\n\nWhat\'s New\nColdBox Modules : Bringing Modular Architecture to ANY ColdBox application\nProgrammatic configuration, no more XML\nIncredible caching enhancements and integrations\nExtensible and enterprise dependency injection\nAspect oriented programming\nIntegration testing, mocking, stubbing and incredible amount of tools for testing and verification\nCustomizable Flash RAM and future web flows\nColdFusion ORM and Hibernate Services\nRESTful web services enhancement and easy creations\nTons more\n\n \nThe What\'s New page can say it all! An incredible more than 700 issue tickets closed and ColdBox 3.1 is already in full planning phases. So apart from all this work culminating, we can also say we have transitioned into a complete professional open source software offering an incredible amount of professional services and backup to any enterprise or company running ColdBox or any of our supporting products (Relax, CodexWiki, ForumMan, DataBoss, Messaging, ...):\n\nSupport &amp; Mentoring Plans\nArchitecture &amp; Design\nOver 4 professional training courses\nServer Setup, Tuning and Optimizations\nCustom Consulting and','2011-03-29 23:30:18','2011-03-29 23:30:18',b'1',1),
	(6,'http://blog.coldbox.org/post.cfm/cachebox-1-2-released','CacheBox 1.2 Released','\n  \n  In the spirit of more releases, here is: CacheBox 1.2.0.  CacheBox is an enterprise caching engine, aggregator and API for  ColdFusion applications.  It is part of the ColdBox 3.0.0 Platform but  it can also function on its own as a standalone framework and use it in any ColdFusion application and in any ColdFusion framework. \nThe milestone page for this release can be found in our Assembla Code Tracker. Here is a synopsis of the tickets closed:\n  \n\n \n\n1179	 new cachebox store: BlackholeStore used for optimization and testing\n1180	 cf store does not use createTimeSpan to create minute timespans for puts\n1181	 railo store does not use createTimeSpan to create minute timespans for puts\n1182	 updates to make it coldbox 3.0 compatible\n1192	 store locking mechanisms updated to improve locking and concurrency\n\nSo have fun playing with our new CacheBox release:\n\nDownload\nCheatsheet\nSource Code\nDocumentation\n\n ','2011-03-29 23:26:09','2011-03-29 23:26:09',b'1',1),
	(7,'http://blog.coldbox.org/post.cfm/wirebox-1-1-1-released','WireBox 1.1.1 Released!','I am happy to announce WireBox 1.1.1 to the ColdFusion community. This release sports 3 critical fixes that will make your WireBox injectors run smoother and happier, especially for those doing java integration, this will help you some more.\n\n\nDownload\nCheatsheet\nSource Code\nDocumentation\nOur primer: Getting Jiggy Wit It!\n\n  Issues Fixed\n\n1184 changed way providers accessed scoped injectors via scope registration structure instead of injector references to avoid memory leaks\n    1188 updated the java builder to ignore empty init arguments.\n    1189 updated the java builder to do noInit() as it was ignoring it\n','2011-03-29 23:20:32','2011-03-29 23:20:32',b'1',1),
	(8,'http://blog.coldbox.org/post.cfm/module-lifecycles-explained','Module Lifecycles Explained','In this short entry I just wanted to lay out a few new diagrams that explain the lifecycle of ColdBox modules.  As always, all our documentation reflects these changes as well.  This might help some of you developers getting ready to win that ColdBox Modules contest and get some cash and beer!\n\nModule Service\nThe beauty of ColdBox Modules is that you have an internal module  service that you can tap to in order to dynamically interact with the  ColdBox Modules.  This service is available by talking to the main  ColdBox controller and calling its getModuleService() method: \n// get module service from handlers, plugins, layouts, interceptors or views.\nms = controller.getModuleService();\n\n// You can also inject it via our autowire DSL\nproperty name=\"moduleService\" inject=\"coldbox:moduleService\";\n\n  \nModule Lifecycle\n\n   \n\nHowever, before we start reviewing the module service methods let\'s  review how modules get loaded in a ColdBox application.  Below is a  simple bullet point of what happens in your application when it starts  up and you can also look at the diagram above: \n\nColdBox main application and configuration loads \nColdBox Cache, Logging and WireBox are created \nModule Service calls on registerAllModules() to read all the  modules in the modules locations (with include/excludes) and start  registering their configurations one by one.  If the module had parent  settings, interception points, datasoures or webservices, these are  registered here. \nAll main application interceptors are loaded and configured \nColdBox is marked as initialized \nModule service calls on activateAllModules() so it begins  activating only the registered modules one by one.  This registers the  module\'s SES URL Mappings, model objects, etc \nafterConfigurationLoad interceptors are fired \nColdBox aspects such as i18n, javaloader, ColdSpring/LightWire factories are loaded \nafterAspectsLoad interceptors are fired \n\nThe most common methods that you can use to control the modules in your application are the following: \n\nreloadAll() : Reload all modules in the application. This  clears out all module settings, re-registers from disk, re-configures  them and activates them \nreload(module) : Target a module reload by name \nunloadAll()  : Unload all modules \nunload(module) : Target a module unload by name \nregisterAllModules() : Registers all module configurations \nregisterModule(module) : Target a module configuration registration \nactivateAllModules() : Activate all registered modules \nactivateModule(module) : Target activate a module that has been registered already \ngetLoadedModules() : Get an array of loaded module names \nrebuildModuleRegistry() : Rescan all the module lcoations for newly installed modules and rebuild the registry so these modules can  be registered and activated. \nregisterAndActivateModule(module) : Registe','2011-03-29 11:42:49','2011-03-29 11:42:49',b'1',1),
	(9,'http://blog.coldbox.org/post.cfm/coldbox-connection-show-wednesday','ColdBox Connection Show Wednesday','Just a reminder that this March 3.0.0, 2011 we will be holding a special ColdBox Open Forum Connection at 9 AM PST.&nbsp; You can find more information below:Location:&nbsp; http://experts.adobeconnect.com/coldbox-connection/ColdBox Connection Shows: http://www.coldbox.org/media/connectionWatch out!! Something is coming!!','2011-03-28 20:59:29','2011-03-28 20:59:29',b'1',1),
	(10,'http://blog.coldbox.org/post.cfm/coldbox-modules-contest-extended','ColdBox Modules Contest Extended','We are extending our Modules Contest to allow for more time for entries to trickle in and of course to leverage ColdBox 3 coming this week.\nDeadline: Module entries must be submitted by March 29th EXTENDED: April 8th, 2011 no later than 12PM PST to contests@ortussolutions.com\nWinners Announced on March 30th EXTENDED: April 14th, 2011 The ColdBox Connection show at 9AM PST\nColdBox 3.0 Modules ContestCreate a ColdBox 3.0.0 module that is a fully functional application that can be portable for any ColdBox 3.0 application.  Here are some guidelines the ColdBox team will be evaluating the module on\n\nDownload ColdBox\n\nThe code must reside on either github or a public repository so it is publicly accessible\n\nThe user must create a forgebox entry and submit the module code to it: http://coldbox.org/forgebox\n\nThe more internal libraries it uses the more points it gets: LogBox, MockBox, WireBox, CacheBox\n\nThe module should do something productive, no say hello modules accepted\n\nBest practices on MVC separation of concerns\n\nPortability\n\nDocumentation (You had that one coming!!) as it might need DB setup or DSN setup\n\nBe creative!\n\nMake sure it works!\n\n\n1st Prize\n\nAn Adobe ColdFusion 9 Standard License\n\n$100 Amazon Gift Card\n\nSix pack of \"BrewFather\" beer\n\n\n2nd Prize\n\nA ColdBox Book\n\nA ColdBox T-Shirt\n\n$25 Amazon Gift Card\n\nSix pack of \"BrewFather\" beer\n','2011-03-27 20:29:07','2011-03-27 20:29:07',b'1',1),
	(11,'http://blog.coldbox.org/post.cfm/coldbox-3-release-training-special-discounts','ColdBox 3 Release Training Special Discounts','\n				We are currently holding a special promotion that starts today March 27, 2011 until April 3rd, 2011\n				 at 3:00 PM PST.  Take advantage of this insane $300 off any training of your choice in honor \n				 of our ColdBox 3.0.0 release this week.  Just use our discount code \n				viva3 in our training registration pages or follow our links below and get this discount.  \n				Hurry as the code expires on April 3rd, 2011 at 3PM PST.\n				\n				\nCalifornia Ontario/Los Angeles Training - April 27 to May 1, 2011\n\nDiscount Link: http://coldbox.eventbrite.com/?discount=viva3 \nCBOX-101 ColdBox Core on April 27 - April 29, 2011\nCBOX-203 ColdBox Modules on April 30 - May 1, 2011\n\nPre-CFObjective Minneapolis Training - May 10-11, 2011\n\nDiscount Link: http://coldbox-cfobjective.eventbrite.com/?discount=viva3 \nCBOX-100 ColdBox Core on May 10-11, 2011\nCBOX-202 WireBox Dependency Injection on May 10-11, 2011\n\nHouston, Texas Training - April 27 to May 1, 2011\n\nDiscount Link: http://coldbox-texas.eventbrite.com/?discount=viva3 \nCBOX-101 ColdBox Core on July 6-8, 2011\nCBOX-203 ColdBox Modules on July 7-8, 2011\n','2011-03-27 20:18:44','2011-03-27 20:18:44',b'1',1),
	(12,'http://blog.coldbox.org/post.cfm/coldbox-connection-recordings-page','ColdBox Connection Recordings Page','We just created our new recordings page for the ColdBox Connection today, so you can get in one location all of the recordings.&nbsp; Hopefully in the near future we will expand it with tags and search.','2011-03-25 11:36:08','2011-03-25 11:36:08',b'1',1),
	(13,'http://blog.coldbox.org/post.cfm/coldbox-connection-recording-coldbox-modules','ColdBox Connection Recording: ColdBox Modules','Thanks for attending our 2nd ColdBox Connection webinar today!&nbsp; This webinar focused on ColdBox modules, modularity and architecture.&nbsp; Thanks go to Curt Gratz for presenting such excellent topic.&nbsp; Here is the recording for the show and also please note that we will have another show March 3.0!','2011-03-24 11:41:53','2011-03-24 11:41:53',b'1',1),
	(14,'http://blog.coldbox.org/post.cfm/coldbox-connection-thursday-modules','ColdBox Connection Thursday: Modules','Just a reminder that our ColdBox Connection Show continues this Thursday at 9 AM PST! Curt Gratz will be presenting on ColdBox Modules and of course we will all be there for questions and help. See you there!Location: http://experts.adobeconnect.com/coldbox-connection/Our full calendar of events can be found here: http://coldbox.org/about/eventscalendar','2011-03-22 08:48:10','2011-03-22 08:48:10',b'1',1),
	(15,'http://blog.coldbox.org/post.cfm/coldbox-relax-v1-4-released','ColdBox Relax v1.4 released!','Here is a cool new update for ColdBox Relax - RESTful Tools For Lazy Experts!&nbsp; This update fixes a few issues reported and also enhances the Relaxer console and updates its ability to support definitions for multiple tiers and much more. So download it now!\nHere are the closed issues for this release:\n\n  #14 api_logs direct usage reference removed fixes\n      #15 basic http authentication added to relaxer console so you can easily hit resources that require basic auth\n      #10 entry points can now be a structure of name value pairs for multiple tiers\n   #16 new browser results tab window to show how the results are rendered by a browser\n      #17 addition http proxy as advanced settings to relaxer console so you can proxy your relaxed requests\n      #11 Route Auto Generation - Method security fixes so implicit structures are generated alongside json structures\n\nHere is also a nice screencast showcasing version 1.4 capabilities:\n&nbsp;\n\n\n\n  \nWhat is Relax? ColdBox Relax is a set of RESTful tools for lazy experts.   We pride ourselves in helping developers work smarter and of course  document more in less time by providing them the necessary tools to  automagically document and test.  ColdBox Relax is a way to describe  RESTful web services, test RESTful web services, monitor RESTful web  services and document RESTful web services. The following introductory video will explain it better than words!\n&nbsp;\n\n\n\nSo what are you waiting for? Get Relax Now!\n\n  Source Code\n  Download\n  Documentation\n\n  \n','2011-03-21 16:51:09','2011-03-21 16:51:09',b'1',1);

/*!40000 ALTER TABLE `blogEntries` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table blogs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `blogs`;

CREATE TABLE `blogs` (
  `blogsID` int(11) NOT NULL AUTO_INCREMENT,
  `blogsURL` longtext NOT NULL,
  `blogsWebsiteurl` longtext NOT NULL,
  `blogslanguage` varchar(10) NOT NULL,
  `blogsTitle` longtext NOT NULL,
  `blogsDescription` longtext NOT NULL,
  `blogsdateBuilt` datetime NOT NULL,
  `blogsdateSumitted` datetime NOT NULL,
  `blogsIsActive` bit(1) NOT NULL,
  `blogsAuthorname` varchar(200) DEFAULT NULL,
  `blogsauthorEmail` varchar(200) DEFAULT NULL,
  `blogsauthorURL` longtext,
  PRIMARY KEY (`blogsID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `blogs` WRITE;
/*!40000 ALTER TABLE `blogs` DISABLE KEYS */;

INSERT INTO `blogs` (`blogsID`, `blogsURL`, `blogsWebsiteurl`, `blogslanguage`, `blogsTitle`, `blogsDescription`, `blogsdateBuilt`, `blogsdateSumitted`, `blogsIsActive`, `blogsAuthorname`, `blogsauthorEmail`, `blogsauthorURL`)
VALUES
	(1,'http://blog.coldbox.org/feeds/rss.cfm','http://blog.coldbox.org/','','ColdBox Platform','The official ColdBox Blog','2011-04-08 15:19:13','2011-04-08 15:19:13',b'1',NULL,NULL,NULL);

/*!40000 ALTER TABLE `blogs` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table cacheBox
# ------------------------------------------------------------

DROP TABLE IF EXISTS `cacheBox`;

CREATE TABLE `cacheBox` (
  `id` varchar(100) NOT NULL,
  `objectKey` varchar(255) NOT NULL,
  `objectValue` longtext NOT NULL,
  `hits` int(11) NOT NULL DEFAULT '1',
  `timeout` int(11) NOT NULL,
  `lastAccessTimeout` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `lastAccessed` datetime NOT NULL,
  `isExpired` tinyint(4) NOT NULL DEFAULT '1',
  `isSimple` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `cacheBox` WRITE;
/*!40000 ALTER TABLE `cacheBox` DISABLE KEYS */;

INSERT INTO `cacheBox` (`id`, `objectKey`, `objectValue`, `hits`, `timeout`, `lastAccessTimeout`, `created`, `lastAccessed`, `isExpired`, `isSimple`)
VALUES
	('DF658A103F07DC012AB905014C32D4C7','myKey','hello',1,0,0,'2016-02-25 16:34:00','2016-02-25 16:34:00',1,1);

/*!40000 ALTER TABLE `cacheBox` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table categories
# ------------------------------------------------------------

DROP TABLE IF EXISTS `categories`;

CREATE TABLE `categories` (
  `category_id` varchar(50) NOT NULL,
  `category` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `modifydate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `testValue` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;

INSERT INTO `categories` (`category_id`, `category`, `description`, `modifydate`, `testValue`)
VALUES
	('3A2C516C-41CE-41D3-A9224EA690ED1128','Presentations','<p style=\"margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Lucida Grande; color: #333333\">Presso</p>','2011-02-18 00:00:00',NULL),
	('40288110380cda3301382644c7f90008','LM','LM<br>','2012-06-10 23:00:00',NULL),
	('402881882814615e012826481061000c','Marc','This is marcs category<br>','2010-04-21 22:00:00',NULL),
	('402881882814615e01282bb047fd001e','Cool Wow','A cool wow category<br>','2010-04-22 22:00:00',NULL),
	('402881882b89b49b012b9201bda80002','PascalNews','PascalNews','2010-10-09 00:00:00',NULL),
	('402881a144f57bfd0144fa47bf040007','ads','asdf','2014-01-25 00:00:00',NULL),
	('5898F818-A9B6-4F5D-96FE70A31EBB78AC','Release','<p style=\"margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Lucida Grande; color: #333333\">Releases</p>','2009-04-18 11:48:53',NULL),
	('88B689EA-B1C0-8EEF-143A84813ACADA35','general','A general category','2010-03-31 12:53:21',NULL),
	('88B689EA-B1C0-8EEF-143A84813BCADA35','general','A second test general category','2010-03-31 12:53:21',NULL),
	('88B6C087-F37E-7432-A13A84D45A0F703B','News','A news cateogyr','2009-04-18 11:48:53',NULL),
	('99fc94fd3b98c834013b98c9b2140002','Fancy','Fancy Editor<br>','2012-12-14 00:00:00',NULL),
	('99fc94fd3b9a459d013b9db89c060002','Markus','Hello Markus<br>','2012-12-14 15:00:00',NULL),
	('A13C0DB0-0CBC-4D85-A5261F2E3FCBEF91','Training','unittest','2014-05-07 19:05:21',NULL),
	('ff80808128c9fa8b0128cc3af5d90007','Geeky Stuff','Geeky Stuff','2010-05-25 16:00:00',NULL),
	('ff80808128c9fa8b0128cc3b20bf0008','ColdBox','ColdBox','2010-05-23 16:00:00',NULL),
	('ff80808128c9fa8b0128cc3b7cdd000a','ColdFusion','ColdFusion','2010-05-23 16:00:00',NULL);

/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table comments
# ------------------------------------------------------------

DROP TABLE IF EXISTS `comments`;

CREATE TABLE `comments` (
  `comment_id` varchar(50) NOT NULL,
  `FKentry_id` varchar(50) NOT NULL,
  `comment` text NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `FK_comments_1` (`FKentry_id`),
  KEY `FKentry_id` (`FKentry_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`FKentry_id`) REFERENCES `entries` (`entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;

INSERT INTO `comments` (`comment_id`, `FKentry_id`, `comment`, `time`)
VALUES
	('40288110380cda330138265bf9c4000a','8a64b3712e3a0a5e012e3a11a2cf0004','tt','2012-06-12 23:00:00'),
	('40288110380cda3301382c7fe50d0012','88B82629-B264-B33E-D1A144F97641614E','Test','2012-06-06 23:00:00'),
	('402881882814615e01282b13bbc20013','88B82629-B264-B33E-D1A144F97641614E','This entire blog post really offended me, I hate you','2010-04-22 22:00:00'),
	('402881882814615e01282b13fb290014','88B82629-B264-B33E-D1A144F97641614E','Why are you so hurtful man!','2010-04-22 22:00:00'),
	('402881882814615e01282b142cc60015','88B82629-B264-B33E-D1A144F97641614E','La realidad, que barbaro!','2010-04-22 22:00:00'),
	('88B8C6C7-DFB7-0F34-C2B0EFA4E5D7DA4C','88B82629-B264-B33E-D1A144F97641614E','this blog sucks.','2010-09-02 11:39:04'),
	('8a64b3712e3a0a5e012e3a10321d0002','402881882814615e01282b14964d0016','Vlad is awesome!','2011-02-18 00:00:00'),
	('8a64b3712e3a0a5e012e3a12b1d10005','8a64b3712e3a0a5e012e3a11a2cf0004','Vlad is awesome!','2011-02-18 00:00:00');

/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table contact
# ------------------------------------------------------------

DROP TABLE IF EXISTS `contact`;

CREATE TABLE `contact` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `contact` WRITE;
/*!40000 ALTER TABLE `contact` DISABLE KEYS */;

INSERT INTO `contact` (`id`, `firstName`, `lastName`, `email`)
VALUES
	(1,'Luis','Majano','lmajano@ortussolutions.com'),
	(2,'Jorge','Reyes','lmajano@gmail.com'),
	(3,'','','');

/*!40000 ALTER TABLE `contact` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table entries
# ------------------------------------------------------------

DROP TABLE IF EXISTS `entries`;

CREATE TABLE `entries` (
  `entry_id` varchar(50) NOT NULL,
  `entryBody` text NOT NULL,
  `title` varchar(50) NOT NULL,
  `postedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `FKuser_id` varchar(36) NOT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `FKuser_id` (`FKuser_id`),
  CONSTRAINT `entries_ibfk_1` FOREIGN KEY (`FKuser_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 9216 kB; (`FKuser_id`) REFER `coolblog/users`(`';

LOCK TABLES `entries` WRITE;
/*!40000 ALTER TABLE `entries` DISABLE KEYS */;

INSERT INTO `entries` (`entry_id`, `entryBody`, `title`, `postedDate`, `FKuser_id`)
VALUES
	('402881882814615e01282b14964d0016','Wow, welcome to my new blog, enjoy your stay<br>','My awesome post','2010-04-22 22:00:00','88B73A03-FEFA-935D-AD8036E1B7954B76'),
	('88B82629-B264-B33E-D1A144F97641614E','A first cool blog,hope it does not crash','A cool blog first posting','2009-04-08 00:00:00','88B73A03-FEFA-935D-AD8036E1B7954B76'),
	('8a64b3712e3a0a5e012e3a11a2cf0004','ContentBox is a professional open source modular content management engine that allows you to easily build websites adfsadf adfsadf asfddasfddasfddasfdd','My First Awesome Post My First Awesome Post','2013-04-16 22:00:00','88B73A03-FEFA-935D-AD8036E1B7954B76'),
	('8aee965b3cfff278013d0007d9540002','<span>Mobile browsing popularity is skyrocketing. &nbsp;According to a <a href=\"http://www.nbcnews.com/technology/technolog/25-percent-use-smartphones-not-computers-majority-web-surfing-122259\">new Pew Internet Project report</a>, 25% of Americans use smartphones instead of computers for the majority of their web browsing.</span>\r\n<span>Missing out on <a href=\"http://guavabox.com/3-ways-to-get-started-with-mobile-marketing/\">the mobile marketing trend</a>&nbsp;is\r\n likely to translate into loss of market share and decreased sales. \r\nThat’s not to say that it’s right for every business, but you at least \r\nneed to consider your target market persona before simply dismissing \r\nmobile as a fad.</span>\r\nOne simple step you can take in the mobile direction is to learn how to add Apple icons to your website.\r\n<h2>What Are Apple Icons &amp; Why Use Them?</h2>\r\n<span><a href=\"http://guavabox.com/wp-content/uploads/2013/02/guavabox-apple-icon.png\"><img src=\"http://guavabox.com/wp-content/uploads/2013/02/guavabox-apple-icon.png\" alt=\"GuavaBox Apple Icon Example\" height=\"246\" width=\"307\"></a>Apple\r\n Icons are simply the graphics you’ve chosen to represent your site when\r\n a user saves your page to their home screen in iOS.</span>\r\nIf you don’t have Apple Icons created for your site, iOS grabs a \r\ncompressed thumbnail of your website and displays it as the icon. &nbsp;The \r\nresult is typically indistinguishable and unappealing.\r\nApple Icons are an awesome branding opportunity and give you the chance to g<br>','Test','2013-04-23 00:00:00','402884cc310b1ae901311be89381000a'),
	('99fc94fd3ba7f266013bad4a8a3b0004','This is my first blog post from Bern!<br>','This is my first blog post from Bern!','2012-12-17 15:00:00','99fc94fd3ba7f266013bad49e3c50003');

/*!40000 ALTER TABLE `entries` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table entry_categories
# ------------------------------------------------------------

DROP TABLE IF EXISTS `entry_categories`;

CREATE TABLE `entry_categories` (
  `FKcategory_id` varchar(50) NOT NULL,
  `FKentry_id` varchar(50) NOT NULL,
  KEY `FKcategory_id` (`FKcategory_id`),
  KEY `FKentry_id` (`FKentry_id`),
  CONSTRAINT `entry_categories_ibfk_1` FOREIGN KEY (`FKcategory_id`) REFERENCES `categories` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `entry_categories_ibfk_2` FOREIGN KEY (`FKentry_id`) REFERENCES `entries` (`entry_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `entry_categories` WRITE;
/*!40000 ALTER TABLE `entry_categories` DISABLE KEYS */;

INSERT INTO `entry_categories` (`FKcategory_id`, `FKentry_id`)
VALUES
	('88B689EA-B1C0-8EEF-143A84813ACADA35','88B82629-B264-B33E-D1A144F97641614E'),
	('88B6C087-F37E-7432-A13A84D45A0F703B','88B82629-B264-B33E-D1A144F97641614E'),
	('3A2C516C-41CE-41D3-A9224EA690ED1128','99fc94fd3ba7f266013bad4a8a3b0004'),
	('5898F818-A9B6-4F5D-96FE70A31EBB78AC','99fc94fd3ba7f266013bad4a8a3b0004'),
	('99fc94fd3b98c834013b98c9b2140002','99fc94fd3ba7f266013bad4a8a3b0004'),
	('5898F818-A9B6-4F5D-96FE70A31EBB78AC','402881882814615e01282b14964d0016'),
	('40288110380cda3301382644c7f90008','402881882814615e01282b14964d0016'),
	('3A2C516C-41CE-41D3-A9224EA690ED1128','402881882814615e01282b14964d0016'),
	('402881882b89b49b012b9201bda80002','402881882814615e01282b14964d0016'),
	('99fc94fd3b98c834013b98c9b2140002','402881882814615e01282b14964d0016'),
	('5898F818-A9B6-4F5D-96FE70A31EBB78AC','8a64b3712e3a0a5e012e3a11a2cf0004'),
	('A13C0DB0-0CBC-4D85-A5261F2E3FCBEF91','8a64b3712e3a0a5e012e3a11a2cf0004'),
	('3A2C516C-41CE-41D3-A9224EA690ED1128','8a64b3712e3a0a5e012e3a11a2cf0004');

/*!40000 ALTER TABLE `entry_categories` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `logs`;

CREATE TABLE `logs` (
  `id` varchar(36) NOT NULL,
  `severity` varchar(10) NOT NULL,
  `category` varchar(100) NOT NULL,
  `logdate` datetime NOT NULL,
  `appendername` varchar(100) NOT NULL,
  `message` text,
  `extrainfo` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table relax_logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `relax_logs`;

CREATE TABLE `relax_logs` (
  `id` varchar(36) NOT NULL,
  `severity` varchar(10) NOT NULL,
  `category` varchar(100) NOT NULL,
  `logdate` datetime NOT NULL,
  `appendername` varchar(100) NOT NULL,
  `message` longtext,
  `extrainfo` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table roles
# ------------------------------------------------------------

DROP TABLE IF EXISTS `roles`;

CREATE TABLE `roles` (
  `roleID` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`roleID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;

INSERT INTO `roles` (`roleID`, `role`)
VALUES
	(1,'Administrator'),
	(2,'Moderator'),
	(3,'Anonymous'),
	(4,'Super User'),
	(5,'Editor');

/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table todo
# ------------------------------------------------------------

DROP TABLE IF EXISTS `todo`;

CREATE TABLE `todo` (
  `blogsID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`blogsID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOCK TABLES `todo` WRITE;
/*!40000 ALTER TABLE `todo` DISABLE KEYS */;

INSERT INTO `todo` (`blogsID`, `name`)
VALUES
	(1,'AL-{ts \'2011-04-07 11:15:55\'}'),
	(2,'AL-{ts \'2011-04-07 11:16:22\'}'),
	(3,'AL-{ts \'2011-04-07 11:17:06\'}'),
	(4,'AL-{ts \'2011-04-07 11:21:52\'}'),
	(5,'AL-{ts \'2011-04-07 11:23:06\'}'),
	(6,'AL-{ts \'2011-04-07 11:23:08\'}'),
	(7,'AL-{ts \'2011-04-18 17:23:59\'}'),
	(8,'AL-{ts \'2011-04-18 17:37:15\'}'),
	(9,'AL-{ts \'2011-04-18 17:37:20\'}'),
	(10,'AL-{ts \'2011-04-18 17:38:06\'}'),
	(11,'AL-{ts \'2011-04-18 17:38:08\'}'),
	(12,'AL-{ts \'2011-04-18 17:38:09\'}'),
	(13,'AL-{ts \'2011-04-18 17:38:10\'}'),
	(14,'AL-{ts \'2011-04-18 17:38:11\'}'),
	(15,'AL-{ts \'2011-04-18 17:38:12\'}'),
	(16,'AL-{ts \'2011-04-18 17:38:14\'}'),
	(17,'AL-{ts \'2011-04-18 17:38:15\'}'),
	(18,'AL-{ts \'2011-04-18 17:38:16\'}'),
	(19,'AL-{ts \'2011-04-18 17:38:17\'}'),
	(20,'AL-{ts \'2011-04-18 17:38:18\'}'),
	(21,'AL-{ts \'2011-04-18 17:38:19\'}'),
	(22,'AL-{ts \'2011-04-18 17:38:20\'}'),
	(23,'AL-{ts \'2011-04-18 17:38:21\'}'),
	(24,'AL-{ts \'2011-04-18 17:40:41\'}'),
	(25,'AL-{ts \'2011-04-18 17:40:44\'}'),
	(26,'AL-{ts \'2011-04-18 17:40:47\'}'),
	(27,'AL-{ts \'2011-04-18 17:41:38\'}'),
	(28,'AL-{ts \'2011-04-18 17:44:15\'}'),
	(29,'AL-{ts \'2011-04-18 17:44:25\'}'),
	(30,'AL-{ts \'2011-04-18 17:44:39\'}'),
	(31,'AL-{ts \'2011-04-18 17:49:44\'}'),
	(32,'AL-{ts \'2011-04-18 17:50:10\'}'),
	(33,'AL-{ts \'2011-04-18 17:51:07\'}'),
	(34,'AL-{ts \'2011-04-18 17:57:44\'}'),
	(35,'AL-{ts \'2011-04-18 18:03:33\'}'),
	(36,'AL-{ts \'2011-04-18 19:32:04\'}'),
	(37,'AL-{ts \'2011-04-18 19:32:08\'}'),
	(38,'AL-{ts \'2011-04-18 19:32:31\'}'),
	(39,'AL-{ts \'2011-04-18 19:32:51\'}'),
	(40,'AL-{ts \'2011-04-18 20:02:55\'}'),
	(41,'AL-{ts \'2011-04-18 20:03:52\'}'),
	(42,'AL-{ts \'2011-04-18 20:04:10\'}'),
	(43,'AL-{ts \'2011-04-18 20:12:52\'}'),
	(44,'AL-{ts \'2011-04-19 15:43:36\'}'),
	(45,'AL-{ts \'2011-04-19 15:44:20\'}'),
	(46,'AL-{ts \'2011-04-19 15:48:26\'}'),
	(47,'AL-{ts \'2011-04-19 15:50:59\'}'),
	(48,'AL-{ts \'2011-04-19 15:51:08\'}'),
	(49,'AL-{ts \'2011-04-19 15:51:15\'}'),
	(50,'AL-{ts \'2011-04-23 12:58:04\'}');

/*!40000 ALTER TABLE `todo` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `user_id` varchar(50) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `userName` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `lastLogin` datetime DEFAULT NULL,
  `FKRoleID` int(11) DEFAULT NULL,
  `isActive` bit(1) DEFAULT b'1',
  PRIMARY KEY (`user_id`),
  KEY `FKRoleID` (`FKRoleID`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`FKRoleID`) REFERENCES `roles` (`roleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;

INSERT INTO `users` (`user_id`, `firstName`, `lastName`, `userName`, `password`, `lastLogin`, `FKRoleID`, `isActive`)
VALUES
	('4028818e2fb6c893012fe637c5db00a7','George','Form Injector','george','george',NULL,2,b'1'),
	('402884cc310b1ae901311be89381000a','ken','Advanced Guru','kenneth','smith','2014-03-25 00:00:00',2,b'1'),
	('4A386F4D-DCF4-6587-7B89B3BD57C97155','Joe','Fernando','joe','joe','2009-05-15 00:00:00',1,b'1'),
	('88B73A03-FEFA-935D-AD8036E1B7954B76','Luis','Majano','lui','lmajano','2009-04-08 00:00:00',1,b'1'),
	('8a64b3712e3a0a5e012e3a110fab0003','Vladymir','Ugryumov','vlad','vlad','2011-02-18 00:00:00',1,b'1'),
	('99fc94fd3b98c834013b98c928120001','Juerg','Anderegg','juerg','juerg','2012-12-14 00:00:00',NULL,b'1'),
	('99fc94fd3ba7f266013bad49e3c50003','Tanja','Zogg','tanja','tanja','2012-12-18 00:00:00',NULL,b'1');

/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

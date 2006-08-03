-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.18-standard


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

DROP TABLE IF EXISTS `feed`;
CREATE TABLE `feed` (
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
-- Dumping data for table `coldboxreader`.`feed`
--

/*!40000 ALTER TABLE `feed` DISABLE KEYS */;
INSERT INTO `feed` (`FeedID`,`FeedName`,`FeedURL`,`FeedAuthor`,`Description`,`ImgURL`,`SiteURL`,`CreatedBy`,`CreatedOn`,`LastRefreshedOn`,`Views`) VALUES 
 ('69823D73-96BC-4752-4B2704298E0FF3DA','TechCrunch','http://techcrunch.com/rss','','TechCrunch is a weblog dedicated to obsessively profiling and reviewing every newly launched web 2.0 business, product and service. We are part of the  Archimedes Ventures  Network of Companies.','','http://www.techcrunch.com','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 12:01:16','2006-06-13 23:49:13',328),
 ('6A1316DF-96BC-4752-4275D8DC9F2FAA02','del.icio.us/wencho','http://del.icio.us/rss/wencho','','','','http://del.icio.us/wencho','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 14:39:29','2006-06-13 23:49:13',320),
 ('6A146018-96BC-4752-40FCCFF31F2555AE','HomePortal\'s Blog','http://www.cfempire.com/home/modules/blog/blog.cfc?method=getrss&url=/accounts/wencho/blog.xml','','Keep track of the progress and latest updates on HomePortals','','http://www.homeportals.net/home/home.cfm?currentHome=/Accounts/HomePortals/layouts/blog.xml','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 14:40:53','2006-06-13 23:49:13',313),
 ('6A812CF0-96BC-4752-446A0D1734EC9095','Raymond Camden\'s ColdFusion Blog','http://ray.camdenfamily.com/rss.cfm?mode=full','','A blog for ColdFusion, Java, and other topics.','','http://ray.camdenfamily.com/index.cfm','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 16:39:44','2006-06-13 23:49:13',216);
INSERT INTO `feed` (`FeedID`,`FeedName`,`FeedURL`,`FeedAuthor`,`Description`,`ImgURL`,`SiteURL`,`CreatedBy`,`CreatedOn`,`LastRefreshedOn`,`Views`) VALUES 
 ('6AC826BD-96BC-4752-4043684F248FA053','CNN.com','http://rss.cnn.com/rss/cnn_topstories.rss','','CNN.com delivers up-to-the-minute news and information on the latest top stories, weather, entertainment, politics and more.','http://i.cnn.net/cnn/.element/img/1.0/logo/cnn.logo.rss.gif','http://www.cnn.com/rssclick/?section=cnn_topstories','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:57:15','2006-06-13 23:49:13',179),
 ('6ECA2920-96BC-4752-41B77F7226521AF5','AS Fusion','http://www.asfusion.com/blog/index.rss','','A blog about ColdFusion, Flash, Java, and other topics.','http://www.asfusion.com/blog/assets/images/banner_88_31.jpg','http://www.asfusion.com/blog/','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 12:37:56','2006-06-13 23:49:13',143),
 ('70083E43-96BC-4752-44319D82D1E6ABC4','Adobe Labs','http://weblogs.macromedia.com/labs/index.xml','','News and information on Adobe Labs.','','http://weblogs.macromedia.com/labs/','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 18:25:21','2006-06-13 23:49:13',98),
 ('7320815A-96BC-4752-455B76D27FB198B0','Ajaxian','http://ajaxian.com/index.xml','','Cleaning up the web with Ajax','','http://ajaxian.com','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-16 08:50:43','2006-06-13 23:49:13',90);
INSERT INTO `feed` (`FeedID`,`FeedName`,`FeedURL`,`FeedAuthor`,`Description`,`ImgURL`,`SiteURL`,`CreatedBy`,`CreatedOn`,`LastRefreshedOn`,`Views`) VALUES 
 ('D0A69823-B7E1-DDD1-E6A2E12B1BDF2BC8','Rob Gonda\'s ColdFusion Blog','http://www.robgonda.com/blog/rss.cfm?mode=full','Rob Gonda','Rob Gonda\'s opinions','http://www.robgonda.com/blog//files/robGonda/UserFiles/Image/header.jpg','http://www.robgonda.com/blog/index.cfm','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:47:26','2006-06-13 23:49:13',6),
 ('D0A8180D-E942-70A9-43BE4EBA16D30B3E','Luis Majano\'s Java, Coldfusion & More Blog','http://www.luismajano.com/blog/rss.cfm?mode=full','Luis Majano','A blog about coldfusion, java, linux, technology, etc.','','http://www.luismajano.com/blog/index.cfm','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:05','2006-06-13 23:49:13',5);
/*!40000 ALTER TABLE `feed` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`feed_comments`
--

DROP TABLE IF EXISTS `feed_comments`;
CREATE TABLE `feed_comments` (
  `Feed_CommentID` varchar(50) character set latin1 NOT NULL default '',
  `FeedID` varchar(50) character set latin1 NOT NULL default '',
  `CommentText` varchar(500) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  `CreatedBy` varchar(50) character set latin1 NOT NULL default '',
  PRIMARY KEY  (`Feed_CommentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`feed_comments`
--

/*!40000 ALTER TABLE `feed_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_comments` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`feed_tags`
--

DROP TABLE IF EXISTS `feed_tags`;
CREATE TABLE `feed_tags` (
  `feed_tagID` varchar(50) character set latin1 NOT NULL default '',
  `feedID` varchar(50) character set latin1 NOT NULL default '',
  `tag` varchar(45) character set latin1 NOT NULL default '',
  `CreatedBy` varchar(50) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`feed_tagID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`feed_tags`
--

/*!40000 ALTER TABLE `feed_tags` DISABLE KEYS */;
INSERT INTO `feed_tags` (`feed_tagID`,`feedID`,`tag`,`CreatedBy`,`CreatedOn`) VALUES 
 ('6AB90AB2-96BC-4752-4757A708F4166DEA','6A812CF0-96BC-4752-446A0D1734EC9095','java','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:40:45'),
 ('6AB90AD1-96BC-4752-43A8B83C4D35A7A9','6A812CF0-96BC-4752-446A0D1734EC9095','coldfusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:40:45'),
 ('6ABF41C2-96BC-4752-4FDD2CE64187A8BE','6A146018-96BC-4752-40FCCFF31F2555AE','HomePortals','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:47:32'),
 ('6AC0CBED-96BC-4752-464A79D550FC84C7','69823D73-96BC-4752-4B2704298E0FF3DA','web2.0','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-14 17:49:13'),
 ('6ECAC64A-96BC-4752-430FE65567CBDCE8','6ECA2920-96BC-4752-41B77F7226521AF5','coldfusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 12:38:36'),
 ('6FB6F59B-96BC-4752-4F160374C3ABE36F','6AC826BD-96BC-4752-4043684F248FA053','news','','2006-02-15 16:56:34'),
 ('6FB78921-96BC-4752-41454736E87038E1','6ECA2920-96BC-4752-41B77F7226521AF5','FlashForms','','2006-02-15 16:57:12'),
 ('70087810-96BC-4752-43F2360C466DBCA9','70083E43-96BC-4752-44319D82D1E6ABC4','ColdFusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 18:25:36');
INSERT INTO `feed_tags` (`feed_tagID`,`feedID`,`tag`,`CreatedBy`,`CreatedOn`) VALUES 
 ('7008782F-96BC-4752-4C7CFAEAE6FFE4CA','70083E43-96BC-4752-44319D82D1E6ABC4','macromedia','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 18:25:36'),
 ('7008784E-96BC-4752-4B0F35EE8187E5CD','70083E43-96BC-4752-44319D82D1E6ABC4','development','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-15 18:25:36'),
 ('7320C2B9-96BC-4752-4753E908090E4D92','7320815A-96BC-4752-455B76D27FB198B0','web2.0','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-16 08:51:00'),
 ('7320C2D8-96BC-4752-4D2A403C7B3D2D2F','7320815A-96BC-4752-455B76D27FB198B0','ajax','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-16 08:51:00'),
 ('733BBB43-96BC-4752-4D6632A24D6F46E8','733B9397-96BC-4752-4982446D5FFB691C','ColdFusion','693156E1-96BC-4752-48B5CC5BBBBAA9A8','2006-02-16 09:20:27'),
 ('9A993507-CD66-B312-145DFB75BDC01339','6A1316DF-96BC-4752-4275D8DC9F2FAA02','Nerd','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 00:47:45'),
 ('9AC8C243-D5C4-1AF1-57B7E4F644895CCF','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','Nerd','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:41'),
 ('9AC8CF50-AD08-28FA-5C823E87347C08BF','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','Coldfusion','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:44');
INSERT INTO `feed_tags` (`feed_tagID`,`feedID`,`tag`,`CreatedBy`,`CreatedOn`) VALUES 
 ('9AC8DCA0-E6C0-7D78-5C5B2E489EEFDBAD','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','flash','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:48'),
 ('9AC8DD70-C4A5-D886-96AE54A1CEC83063','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','remoting','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:48'),
 ('9AC8F4D3-FC57-D994-8C4B95890FAA2475','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','textus','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:54'),
 ('9AC9023F-FD69-2FA1-32927564251AEBD9','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','framework','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:39:58'),
 ('9AC92728-94C4-52BB-6E243B12D22B8D10','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','object','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:40:07'),
 ('9AC9280E-BA2A-900F-30D58F70DEFB58E7','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','oriented','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:40:07'),
 ('9AC9326D-9AB0-B142-3CC65665CF96A059','9AC84D34-FBF3-2C11-3BFA8014A6ACAB1C','java','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-02-24 01:40:10'),
 ('D0A6BCC1-DA4C-AD32-A32523BF59F70537','D0A69823-B7E1-DDD1-E6A2E12B1BDF2BC8','Coldfusion','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:47:36');
INSERT INTO `feed_tags` (`feed_tagID`,`feedID`,`tag`,`CreatedBy`,`CreatedOn`) VALUES 
 ('D0A6C995-94ED-E04D-8E838AEF4AA89848','D0A69823-B7E1-DDD1-E6A2E12B1BDF2BC8','Ajax','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:47:39'),
 ('D0A84911-D38D-9842-AF0F5716E7C34666','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Coldfusion','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:17'),
 ('D0A855DB-CC0E-8310-A96A3B163F25B184','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Ajax','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:20'),
 ('D0A85ED1-EE48-17C8-446D1CB5F40469E3','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Java','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:23'),
 ('D0A86CD2-95F4-8B68-FE01CE7762BA9A6D','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Nerd','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:26'),
 ('D0A8809D-E25F-81E0-DD7FCE3614491E0B','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Coldbox','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:31'),
 ('D0A88DE0-EBCD-B8BD-0E2FC4E80ABEA17F','D0A8180D-E942-70A9-43BE4EBA16D30B3E','Framework','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:35'),
 ('D0A89FDF-E0E5-5EF7-84E2AE436C7719DC','D0A8180D-E942-70A9-43BE4EBA16D30B3E','OOP','98FDDCB0-A0E6-CEBA-14C2723C902E9640','2006-06-13 23:49:39');
/*!40000 ALTER TABLE `feed_tags` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`feed_votes`
--

DROP TABLE IF EXISTS `feed_votes`;
CREATE TABLE `feed_votes` (
  `Feed_VoteID` varchar(50) character set latin1 NOT NULL default '',
  `FeedID` varchar(50) character set latin1 NOT NULL default '',
  `CreatedBy` varchar(50) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`Feed_VoteID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`feed_votes`
--

/*!40000 ALTER TABLE `feed_votes` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_votes` ENABLE KEYS */;


--
-- Table structure for table `coldboxreader`.`users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `UserID` varchar(50) character set latin1 NOT NULL default '',
  `UserName` varchar(20) character set latin1 NOT NULL default '',
  `Password` varchar(45) character set latin1 NOT NULL default '',
  `Email` varchar(45) character set latin1 NOT NULL default '',
  `CreatedOn` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coldboxreader`.`users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`UserID`,`UserName`,`Password`,`Email`,`CreatedOn`) VALUES 
 ('693156E1-96BC-4752-48B5CC5BBBBAA9A8','oscar','oscar','info@cfempire.com','2006-02-14 10:32:54'),
 ('98FDDCB0-A0E6-CEBA-14C2723C902E9640','luis','luis','lmajano@gmail.com','2006-02-23 17:18:27');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

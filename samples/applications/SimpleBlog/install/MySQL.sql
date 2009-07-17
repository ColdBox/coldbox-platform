-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.37-community-nt


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema simpleblog
--

CREATE DATABASE IF NOT EXISTS simpleblog;
USE simpleblog;

--
-- Definition of table `comments`
--

DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `comment_id` varchar(50) NOT NULL,
  `entry_id` varchar(50) NOT NULL,
  `comment` text NOT NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`comment_id`),
  KEY `FK_comments_1` (`entry_id`),
  CONSTRAINT `FK_comments_1` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`entry_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `comments`
--

/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` (`comment_id`,`entry_id`,`comment`,`time`) VALUES 
 ('8AAF7985-1EC9-46DA-21581A8BA613645C','4E20F12B-1EC9-46DA-21EBE5CD8D8FA931','test','2008-10-10 11:22:45'),
 ('96453491-1EC9-46DA-21EB22C9A53861EC','4E20F12B-1EC9-46DA-21EBE5CD8D8FA931','test','2008-10-10 11:22:55'),
 ('DD1022ED-1EC9-46DA-214827AD8EBF95A7','4E20F12B-1EC9-46DA-21EBE5CD8D8FA931','test','2008-10-10 11:23:01');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;


--
-- Definition of table `entries`
--

DROP TABLE IF EXISTS `entries`;
CREATE TABLE `entries` (
  `entry_id` varchar(50) NOT NULL,
  `entryBody` text NOT NULL,
  `author` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entries`
--

/*!40000 ALTER TABLE `entries` DISABLE KEYS */;
INSERT INTO `entries` (`entry_id`,`entryBody`,`author`,`title`,`time`) VALUES 
 ('2F94E549-1EC9-46DA-21A75A540728F501','<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>\r\n<p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. &nbsp;</p>','Henrik','Testing Coldspring','2008-10-10 11:22:04'),
 ('2FE9F693-1EC9-46DA-21B30B4E7E1EEF65','<p>I can see the benefit of using it now. It\'s a lot easier to manage all your dependencies in a single spot. It makes it easier to properly encapsulate your variables.</p>\r\n<p>Let\'s add some more text to this post:</p>\r\n<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>\r\n<p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.&nbsp;</p>','Henrik Joreteg','I t ColdSpring Working!','2008-10-10 11:21:49'),
 ('4E0DCC23-1EC9-46DA-21DFC2AE547C4C7A','<p>&nbsp;test</p>','test','test','2008-10-10 11:21:24');
INSERT INTO `entries` (`entry_id`,`entryBody`,`author`,`title`,`time`) VALUES 
 ('4E0F56F5-1EC9-46DA-211AEE733CDA9785','<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>\r\n<p>&nbsp;</p>\r\n<p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. &nbsp;</p>','Henrik','Some Ipsum Text','2008-10-10 11:21:10'),
 ('4E20F12B-1EC9-46DA-21EBE5CD8D8FA931','<p>&nbsp;tests</p>','tsets','test','2008-10-10 11:20:55');
/*!40000 ALTER TABLE `entries` ENABLE KEYS */;


--
-- Definition of table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` varchar(50) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `userName` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `lastLogin` datetime default NULL,
  `userType` varchar(50) NOT NULL,
  PRIMARY KEY  (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`user_id`,`firstName`,`lastName`,`userName`,`password`,`lastLogin`,`userType`) VALUES 
 ('123','Admin','Admin','admin','admin',NULL,'admin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

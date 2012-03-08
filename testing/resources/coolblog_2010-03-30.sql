# Sequel Pro dump
# Version 1630
# http://code.google.com/p/sequel-pro
#
# Host: localhost (MySQL 5.0.45)
# Database: coolblog
# Generation Time: 2010-03-31 13:06:21 -0700
# ************************************************************

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table categories
# ------------------------------------------------------------

DROP TABLE IF EXISTS `categories`;

CREATE TABLE `categories` (
  `category_id` varchar(50) NOT NULL,
  `category` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `modifydate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` (`category_id`,`category`,`description`,`modifydate`)
VALUES
	('3A2C516C-41CE-41D3-A9224EA690ED1128','Presentations.','<p style=\"margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Lucida Grande; color: #333333\">Presso</p>','2009-04-18 11:48:53'),
	('5898F818-A9B6-4F5D-96FE70A31EBB78AC','Release','<p style=\"margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Lucida Grande; color: #333333\">Releases</p>','2009-04-18 11:48:53'),
	('88B689EA-B1C0-8EEF-143A84813ACADA35','general','A general category','2010-03-31 12:53:21'),
	('88B6C087-F37E-7432-A13A84D45A0F703B','News','A news cateogyr','2009-04-18 11:48:53'),
	('A13C0DB0-0CBC-4D85-A5261F2E3FCBEF91','Training','Training','2009-04-18 11:48:53'),
	('A13C0DB0-0CBC-4D85-A5261F2E3FCBEF92','general','A test general','2010-03-31 13:06:03');

/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table comments
# ------------------------------------------------------------

DROP TABLE IF EXISTS `comments`;

CREATE TABLE `comments` (
  `comment_id` varchar(50) NOT NULL,
  `FKentry_id` varchar(50) NOT NULL,
  `comment` text NOT NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`comment_id`),
  KEY `FK_comments_1` (`FKentry_id`),
  KEY `FKentry_id` (`FKentry_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`FKentry_id`) REFERENCES `entries` (`entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` (`comment_id`,`FKentry_id`,`comment`,`time`)
VALUES
	('88B8C6C7-DFB7-0F34-C2B0EFA4E5D7DA4C','88B82629-B264-B33E-D1A144F97641614E','this blog sucks','2009-04-08 00:00:00');

/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table entries
# ------------------------------------------------------------

DROP TABLE IF EXISTS `entries`;

CREATE TABLE `entries` (
  `entry_id` varchar(50) NOT NULL,
  `entryBody` text NOT NULL,
  `title` varchar(50) NOT NULL,
  `postedDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `FKuser_id` varchar(36) NOT NULL,
  PRIMARY KEY  (`entry_id`),
  KEY `FKuser_id` (`FKuser_id`),
  CONSTRAINT `entries_ibfk_1` FOREIGN KEY (`FKuser_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 9216 kB; (`FKuser_id`) REFER `coolblog/users`(`';

LOCK TABLES `entries` WRITE;
/*!40000 ALTER TABLE `entries` DISABLE KEYS */;
INSERT INTO `entries` (`entry_id`,`entryBody`,`title`,`postedDate`,`FKuser_id`)
VALUES
	('88B82629-B264-B33E-D1A144F97641614E','A first cool blog,hope it does not crash','A cool blog first posting','2009-04-08 00:00:00','88B73A03-FEFA-935D-AD8036E1B7954B76');

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
INSERT INTO `entry_categories` (`FKcategory_id`,`FKentry_id`)
VALUES
	('88B689EA-B1C0-8EEF-143A84813ACADA35','88B82629-B264-B33E-D1A144F97641614E'),
	('88B6C087-F37E-7432-A13A84D45A0F703B','88B82629-B264-B33E-D1A144F97641614E');

/*!40000 ALTER TABLE `entry_categories` ENABLE KEYS */;
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
  `lastLogin` datetime default NULL,
  PRIMARY KEY  (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`user_id`,`firstName`,`lastName`,`userName`,`password`,`lastLogin`)
VALUES
	('4A386F4D-DCF4-6587-7B89B3BD57C97155','Joe','Fernando','joe','joe','2009-05-15 00:00:00'),
	('88B73A03-FEFA-935D-AD8036E1B7954B76','Luis','Majano','lmajano','lmajano','2009-04-08 00:00:00');

/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;





/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

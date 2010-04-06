# Sequel Pro dump
# Version 1630
# http://code.google.com/p/sequel-pro
#
# Host: localhost (MySQL 5.0.45)
# Database: coolblog
# Generation Time: 2010-03-31 13:06:35 -0700
# ************************************************************

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table categories
# ------------------------------------------------------------

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

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` (`comment_id`,`FKentry_id`,`comment`,`time`)
VALUES
	('88B8C6C7-DFB7-0F34-C2B0EFA4E5D7DA4C','88B82629-B264-B33E-D1A144F97641614E','this blog sucks','2009-04-08 00:00:00');

/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table entries
# ------------------------------------------------------------

LOCK TABLES `entries` WRITE;
/*!40000 ALTER TABLE `entries` DISABLE KEYS */;
INSERT INTO `entries` (`entry_id`,`entryBody`,`title`,`postedDate`,`FKuser_id`)
VALUES
	('88B82629-B264-B33E-D1A144F97641614E','A first cool blog,hope it does not crash','A cool blog first posting','2009-04-08 00:00:00','88B73A03-FEFA-935D-AD8036E1B7954B76');

/*!40000 ALTER TABLE `entries` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table entry_categories
# ------------------------------------------------------------

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
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

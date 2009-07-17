/*
SQLyog Community Edition- MySQL GUI v6.56
MySQL - 5.0.26-community-nt : Database - transfersample
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/`transfersample` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `transfersample`;

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `usr_id` int(3) NOT NULL auto_increment,
  `usr_password` char(32) NOT NULL,
  `usr_firstname` varchar(50) NOT NULL,
  `usr_lastname` varchar(50) NOT NULL,
  `usr_email` varchar(250) NOT NULL,
  `usr_createdon` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `usr_updatedon` datetime default '0000-00-00 00:00:00',
  `usr_isactive` tinyint(1) NOT NULL default '0',
  `ust_id` int(3) unsigned NOT NULL,
  PRIMARY KEY  (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `users` */

insert  into `users`(`usr_id`,`usr_password`,`usr_firstname`,`usr_lastname`,`usr_email`,`usr_createdon`,`usr_updatedon`,`usr_isactive`,`ust_id`) values (3,'luis','Luis','Majano','info@coldboxframework.com','2008-07-05 00:37:37','2008-07-05 00:37:37',1,2),(4,'ernst','Ernst','van der Linden','evdlinden@gmail.com','2008-07-05 00:46:40','2008-07-05 00:46:40',1,1),(5,'mark','Mark','Mandel','info@transfer-orm.com','2008-07-05 00:48:09','2008-07-05 00:48:09',1,2),(6,'peter','Peter','Bell','info@pbel.com','2008-07-05 00:49:17','2008-07-05 00:49:17',1,2);

/*Table structure for table `usertypes` */

DROP TABLE IF EXISTS `usertypes`;

CREATE TABLE `usertypes` (
  `ust_id` int(3) unsigned NOT NULL auto_increment,
  `ust_name` varchar(50) NOT NULL,
  PRIMARY KEY  (`ust_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `usertypes` */

insert  into `usertypes`(`ust_id`,`ust_name`) values (1,'Administrator'),(2,'User');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

DROP TABLE IF EXISTS `appUser`;
CREATE TABLE `appUser` (
  `AppUserId` char(35) NOT NULL,
  `Username` varchar(50) NOT NULL,
  `Password` char(32) NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Email` varchar(250) NOT NULL,
  `createdOn` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updatedOn` datetime default '0000-00-00 00:00:00',
  `isActive` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`AppUserId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


INSERT INTO `appUser` (`AppUserId`,`Username`,`Password`,`FirstName`,`LastName`,`Email`,`createdOn`,`updatedOn`,`isActive`) VALUES
 ('E0DC3A63-E37C-4BDC-9B8C314C0982E203','admin','21232F297A57A5A743894A0E4A801FC3','Admin','MySQL','admin@admin.com','2007-07-31 15:01:50','1999-01-01 00:00:01',1);
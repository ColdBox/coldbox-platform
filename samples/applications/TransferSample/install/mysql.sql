-- ----------------------------------------------------------------------
-- MySQL Migration Toolkit
-- SQL Create Script
-- ----------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `transfersample`
  CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `transfersample`;
-- -------------------------------------
-- Tables

DROP TABLE IF EXISTS `transfersample`.`users`;
CREATE TABLE `transfersample`.`users` (
  `id` VARCHAR(50) NOT NULL,
  `fname` VARCHAR(100) NOT NULL,
  `lname` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `create_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
)
ENGINE = INNODB;

SET FOREIGN_KEY_CHECKS = 1;

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

INSERT INTO `transfersample`.`users`(`id`, `fname`, `lname`, `email`, `create_date`)
VALUES ('1B6D6442-24D8-41E7-84E3-53ED2E8847C4', 'Admin', 'Majano', 'admin@admin.com', '2007-03-19 18:20:32'),
  ('F2B37E14-1830-41BF-B910-42EBEF03169B', 'Fernando', 'Admin', 'fadmin@admin.com', '2007-03-19 18:20:54');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

-- ----------------------------------------------------------------------
-- EOF


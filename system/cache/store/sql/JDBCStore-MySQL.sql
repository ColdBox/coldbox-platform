CREATE TABLE `cacheBox` (
	`id` VARCHAR(100) NOT NULL,
	`objectKey` VARCHAR(255) NOT NULL,
	`objectValue` LONGTEXT NOT NULL,
	`hits` INT NOT NULL DEFAULT '1',
	`timeout` INT NOT NULL,
	`lastAccessTimeout` INT NOT NULL,
	`created` DATETIME NOT NULL,
	`lastAccessed` DATETIME NOT NULL,
	`isExpired` TINYINT NOT NULL DEFAULT '0',
	`isSimple` TINYINT NOT NULL DEFAULT '1',
	PRIMARY KEY (`id`)
	INDEX `hits` (`hits`),
	INDEX `created` (`created`),
	INDEX `lastAccessed` (`lastAccessed`),
	INDEX `timeout` (`timeout`),
	INDEX `isExpired` (`isExpired`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

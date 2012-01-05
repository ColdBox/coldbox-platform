CREATE TABLE `cacheBox` (
  `id` varchar(100) NOT NULL,
  `objectKey` varchar(255) NOT NULL,
  `objectValue` longtext NOT NULL,
  `hits` int(11) NOT NULL DEFAULT '1',
  `timeout` int(11) NOT NULL,
  `lastAccessTimeout` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `lastAccessed` datetime NOT NULL,
  `isExpired` tinyint(4) NOT NULL DEFAULT '0',
  `isSimple` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `hits` (`hits`),
  KEY `created` (`created`),
  KEY `lastAccessed` (`lastAccessed`),
  KEY `timeout` (`timeout`),
  KEY `isExpired` (`isExpired`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
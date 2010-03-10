--Primary key, can be anything you want.
	
CREATE TABLE securityrules
(
	securityrule_id VARCHAR(36) NOT NULL,
	whitelist VARCHAR(255),
	securelist VARCHAR(255),
	roles VARCHAR(255),
	permissions VARCHAR(255),
	redirect VARCHAR(255),
	useSSL bit NOT NULL DEFAULT 0
	PRIMARY KEY (securityrule_id),
	UNIQUE (securityrule_id)
) 
;
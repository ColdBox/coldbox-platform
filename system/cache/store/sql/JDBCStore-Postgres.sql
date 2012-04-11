CREATE TABLE cachebox (
	id VARCHAR(100) NOT NULL,
	objectKey VARCHAR(255) NOT NULL,
	objectValue text NOT NULL,
	hits integer NOT NULL DEFAULT '1',
	timeout integer NOT NULL,
	lastAccessTimeout integer NOT NULL,
	created timestamp NOT NULL,
	lastAccessed timestamp NOT NULL,
	isExpired boolean NOT NULL DEFAULT true,
	isSimple boolean NOT NULL DEFAULT false,
	PRIMARY KEY (id)
)
CREATE INDEX created
  ON cachebox
  USING btree
  (created);
CREATE INDEX hits
  ON cachebox
  USING btree
  (hits);
CREATE INDEX "isExpired"
  ON cachebox
  USING btree
  (isexpired);
CREATE INDEX "lastAccessed"
  ON cachebox
  USING btree
  (lastaccessed);
CREATE INDEX timeout
  ON cachebox
  USING btree
  (timeout);
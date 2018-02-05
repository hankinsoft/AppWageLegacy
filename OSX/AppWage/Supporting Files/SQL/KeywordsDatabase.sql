CREATE TABLE IF NOT EXISTS applicationKeyword (
  applicationKeywordId integer NOT NULL PRIMARY KEY,
  applicationId integer NOT NULL,
  keyword varchar NOT NULL,
  UNIQUE(applicationId,keyword)
);

CREATE TABLE IF NOT EXISTS applicationKeywordRank (
  applicationKeywordId integer NOT NULL,
  countryId integer NOT NULL,
  position integer NOT NULL,
  positionDate timestamp NOT NULL,
  UNIQUE(applicationKeywordId, countryId, position, positionDate),
  FOREIGN KEY (applicationKeywordId)
  REFERENCES applicationKeyword(applicationKeywordId)
  ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS applicationKeywordRankLookupIndex ON applicationKeywordRank (applicationKeywordId, countryId, position, positionDate);

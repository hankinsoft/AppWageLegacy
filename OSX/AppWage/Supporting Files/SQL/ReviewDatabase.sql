CREATE TABLE IF NOT EXISTS review (
  reviewId integer NOT NULL PRIMARY KEY,
  applicationId integer NOT NULL,
  countryId integer NOT NULL,
  readByUser integer NOT NULL DEFAULT(0),
  translatedByUser integer NOT NULL DEFAULT(0),
  stars float NOT NULL,
  appVersion varchar(128) NOT NULL,
  reviewer varchar(128) NOT NULL,
  title varchar(128) NOT NULL,
  content varchar(1024) NOT NULL,
  translatedTitle varchar(128) DEFAULT NULL,
  translatedContent varchar(1025) DEFAULT NULL,
  translatedLocal varchar(128) DEFAULT NULL,
  collectedDate timestamp NOT NULL,
  lastUpdated timestamp NOT NULL
);
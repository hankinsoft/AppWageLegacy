CREATE TABLE IF NOT EXISTS country (
    countryId            integer PRIMARY KEY,
    shouldCollectRanks   integer NOT NULL DEFAULT(1),
    shouldCollectReviews integer NOT NULL DEFAULT(1),
    countryCode          varchar,
    name                 varchar
);

CREATE INDEX IF NOT EXISTS IDX_COUNTRY_SHOULDCOLLECTRANKS ON country (shouldCollectRanks);
CREATE INDEX IF NOT EXISTS IDX_COUNTRY_SHOULDCOLLECTREVIEWS ON country (shouldCollectReviews);
CREATE INDEX IF NOT EXISTS IDX_COUNTRY_NAME ON country (name);
CREATE INDEX IF NOT EXISTS IDX_COUNTRY_COUNTRYCODE ON country (countryCode);

CREATE TABLE IF NOT EXISTS genre (
    genreId        integer PRIMARY KEY,
    genreType      integer,
    parentGenreId  integer,
    name           varchar
);

CREATE TABLE IF NOT EXISTS genreChart (
    genreChartId    integer PRIMARY KEY,
    genreId         integer,
    baseURL         varchar,
    name            varchar
);

CREATE INDEX IF NOT EXISTS IDX_GENRECHART_GENREID ON genreChart (genreId);

CREATE TABLE IF NOT EXISTS account (
    internalAccountId   varchar PRIMARY KEY,
    accountType         integer
);

CREATE INDEX IF NOT EXISTS IDX_ACCOUNT_ACCOUNTTYPE ON account (accountType);


CREATE TABLE IF NOT EXISTS application (
    applicationId           integer PRIMARY KEY,
    applicationType         integer NOT NULL,
    name                    varchar NOT NULL,
    publisher               varchar NOT NULL,
    hiddenByUser            integer DEFAULT(0),
    shouldCollectRanks      integer DEFAULT(1),
    shouldCollectReviews    integer DEFAULT(1),

    -- Relationships
    internalAccountId       varchar DEFAULT(NULL)
);

CREATE INDEX IF NOT EXISTS IDX_APPLICATION_ACCOUNT ON application (internalAccountId);

CREATE TABLE IF NOT EXISTS product (
    appleIdentifier integer PRIMARY KEY,
    productType     integer,
    title           nvarchar,

    -- Relationships
    applicationId   integer
);

CREATE INDEX IF NOT EXISTS IDX_PRODUCT_APPLICATION ON product (applicationId);

CREATE TABLE IF NOT EXISTS applicationGenre
(
    applicationId integer INTEGER,
    genreId integer,
    PRIMARY KEY(applicationId,genreId)
);

CREATE INDEX IF NOT EXISTS IDX_APPLICATIONGENRE ON applicationGenre (applicationId);

CREATE TABLE IF NOT EXISTS applicationCollection
(
    applicationCollectionId   integer PRIMARY KEY AUTOINCREMENT,
    name                      varchar
);

CREATE TABLE IF NOT EXISTS applicationCollection_application
(
    applicationCollectionId integer,
    applicationId           integer,
    UNIQUE(applicationCollectionId, applicationId)
);
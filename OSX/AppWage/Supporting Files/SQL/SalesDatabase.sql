CREATE TABLE IF NOT EXISTS salesReport (
  internalAccountId varchar(128) NOT NULL,
  salesReportType integer NOT NULL,
  appleIdentifier integer NOT NULL,
  currency varchar(256) NOT NULL,
  productTypeIdentifier varchar(256) NOT NULL,
  profitPerUnit integer NOT NULL,
  promoCode varchar(256),
  units integer NOT NULL,
  countryCode integer NOT NULL,
  beginDate timestamp NOT NULL,
  endDate timestamp NOT NULL,
  cached integer NOT NULL DEFAULT(0),
  UNIQUE(internalAccountId, salesReportType, appleIdentifier, currency, productTypeIdentifier, profitPerUnit, promoCode, units, countryCode, beginDate, endDate)
);

CREATE TABLE IF NOT EXISTS salesReportCache (
  cacheType integer NOT NULL,
  cacheValue double NOT NULL,
  productId integer NOT NULL,
  countryId integer NOT NULL,
  date timestamp NOT NULL,
  UNIQUE(cacheType, productId, countryId, date)
);

CREATE INDEX IF NOT EXISTS IDX_SALESREPORTCACHE ON salesReportCache (cacheType,productId,countryId,date);

CREATE TABLE IF NOT EXISTS salesReportCachePerApp (
    cacheType integer NOT NULL,
    cacheValue double NOT NULL,
    productId integer NOT NULL,
    date timestamp NOT NULL,
    UNIQUE(cacheType, productId, date)
);

CREATE INDEX IF NOT EXISTS IDX_SALESREPORTCACHEPERAPP ON salesReportCachePerApp (cacheType,productId,date);
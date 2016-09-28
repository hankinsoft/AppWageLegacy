CREATE TABLE IF NOT EXISTS rank (
  applicationId integer NOT NULL,
  genreId integer NOT NULL,
  genreChartId integer NOT NULL,
  countryId integer NOT NULL,
  position integer NOT NULL,
  positionDate timestamp NOT NULL,
  UNIQUE(applicationId, genreId, genreChartId, countryId, positionDate)
);

CREATE INDEX IF NOT EXISTS applicationId ON rank (applicationId, genreId, genreChartId, countryId, positionDate);
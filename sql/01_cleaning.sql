SELECT * FROM movies;
SELECT * FROM movies_staging;

-- 1) Staging: copy structure+data
DROP TABLE IF EXISTS movies_staging;
CREATE TABLE movies_staging LIKE movies;

SELECT * FROM movies_staging;

INSERT INTO movies_staging SELECT * FROM movies;

SELECT * FROM movies_staging;

-- 2) Standardize column names (snake_case)
ALTER TABLE movies_staging
  RENAME COLUMN `MOVIES`   TO title,
  RENAME COLUMN `YEAR`     TO year,
  RENAME COLUMN `GENRE`    TO genre,
  RENAME COLUMN `RATING`   TO rating,
  RENAME COLUMN `ONE-LINE` TO description,
  RENAME COLUMN `STARS`    TO stars,
  RENAME COLUMN `VOTES`    TO votes,
  RENAME COLUMN `RunTime`  TO run_time;
  
SELECT * FROM movies_staging;

-- 3) Drop empty column if truly unused
ALTER TABLE movies_staging DROP COLUMN `Gross`;

-- 4) Remove duplicates (keep the first per title)
WITH ranked AS(
	SELECT *,
    ROW_NUMBER() OVER(PARTITION BY title) as row_num
    FROM movies_staging
)
SELECT *
FROM ranked 
WHERE row_num > 1;

-- 5) Clean line breaks and trim across text columns
UPDATE movies_staging
SET
  genre       = TRIM(REPLACE(REPLACE(genre,       CHAR(13), ' '), CHAR(10), ' ')),
  description = TRIM(REPLACE(REPLACE(description, CHAR(13), ' '), CHAR(10), ' ')),
  stars       = TRIM(REPLACE(REPLACE(stars,       CHAR(13), ' '), CHAR(10), ' '));

-- 6) Normalize YEAR if stored like "(2023)"; otherwise skip
-- Only rewrite rows that match "(dddd)"
UPDATE movies_staging
SET year = SUBSTR(year, 2, 4)
WHERE year REGEXP '^\\([0-9]{4}\\)$';

UPDATE movies_staging
SET year = SUBSTR(year, 2, 4)
WHERE LEFT(year, 1) = '(';

SELECT * FROM movies_staging;

-- 7) Extract director and clean stars using robust parsing
-- Add column first
ALTER TABLE movies_staging
ADD COLUMN director TEXT;

-- Director: remove label "Director:" and anything after '|'
SELECT 
director, NULLIF(
SUBSTRING(stars FROM POSITION('Director:' IN stars)+10 FOR POSITION('|' IN stars)-12),
''
)
FROM movies_staging;

UPDATE movies_staging
SET director =  NULLIF(
SUBSTRING(stars FROM POSITION('Director:' IN stars)+10 FOR POSITION('|' IN stars)-12),
''
);
SELECT * FROM movies_staging;

-- Stars: remove everything through "Stars:" label
SELECT stars , SUBSTRING(stars FROM POSITION('Stars:' IN stars)+6 FOR LENGTH(stars) - POSITION('Stars' IN stars)-1) as stars
FROM movies_staging;

UPDATE movies_staging
SET stars = SUBSTRING(stars FROM POSITION('Stars:' IN stars)+6 FOR LENGTH(stars) - POSITION('Stars' IN stars)-1);

SELECT * FROM movies_staging;

-- 8) Clean numeric columns before casting
-- votes like "1,234" -> "1234"; set non-numeric to NULL
UPDATE movies_staging
SET votes = NULLIF(REGEXP_REPLACE(votes, '[^0-9]', ''), '');

-- run_time like "132 min" -> "132"; set non-numeric to NULL
UPDATE movies_staging
SET run_time = NULLIF(REGEXP_REPLACE(run_time, '[^0-9]', ''), '');

-- rating: keep forms like "6", "6.5"; else NULL
-- (also trims spaces)
UPDATE movies_staging
SET rating = NULLIF(TRIM(rating), '');

-- 9) Cast to proper types
ALTER TABLE movies_staging
  MODIFY COLUMN year INT,
  MODIFY COLUMN votes INT,
  MODIFY COLUMN run_time INT,
  MODIFY COLUMN rating DECIMAL(3,1);

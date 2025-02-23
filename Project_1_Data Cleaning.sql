-- SQL Project - Data Cleaning

SELECT 
    *
FROM
    layoffs;



-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT layoffs_staging 
SELECT * 
FROM layoffs;


-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



SELECT 
    *
FROM
    layoffs_staging
;

SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off, percentage_laid_off,`date`) AS row_num
	FROM 
		layoffs_staging;


WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, industry, total_laid_off,percentage_laid_off,`date`
			) AS row_num
	FROM 
		layoffs_staging
) 
SELECT *
FROM duplicate_cte
WHERE 
	row_num > 1;
    
-- let's just look at oda to confirm
SELECT 
    *
FROM
    world_layoffs.layoffs_staging
WHERE
    company = 'Oda'
;
-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate

-- these are our real duplicates 
WITH duplicate_cte AS
(SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
		) AS row_num
	FROM 
		layoffs_staging
) 
DELETE
FROM duplicate_cte
WHERE 
	row_num > 1;
    
CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    row_num > 1;    


INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
		) AS row_num
	FROM 
		layoffs_staging;
    
DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;


SELECT 
    *
FROM
    layoffs_staging2;
    
  
-- Standardizing data 

SELECT 
    company, (TRIM(company))
FROM
    layoffs_staging2;
  
UPDATE layoffs_staging2 
SET 
    company = TRIM(company);
  
  
SELECT DISTINCT
    industry
FROM
    layoffs_staging2;
  
-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto

UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';
  
  
SELECT DISTINCT
    country, TRIM(TRAILING '.' FROM country)
FROM
    layoffs_staging2
ORDER BY 1;

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.
  
UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';
  
  
-- Let's also fix the date columns:
SELECT 
    `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM
    layoffs_staging2;
  
UPDATE layoffs_staging2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
  
SELECT 
    `date`
FROM
    layoffs_staging2;  
  
-- now we can convert the data type properly

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
  

SELECT 
    *
FROM
    layoffs_staging2;


-- 3. Look at Null Values

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = '';

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company = 'Airbnb';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

UPDATE layoffs_staging2 
SET 
    industry = NULL
WHERE
    industry = '';


SELECT 
    t1.industry, t2.industry
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;

 
UPDATE layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company LIKE 'Bally%';
-- nothing wrong here

  
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;


DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;


SELECT 
    *
FROM
    layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;












  

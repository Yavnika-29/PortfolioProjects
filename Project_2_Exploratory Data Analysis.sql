-- Exploratory Data Analysis 

SELECT 
    *
FROM
    layoffs_staging2;


SELECT 
    MAX(total_laid_off), MAX(percentage_laid_off)
FROM
    layoffs_staging;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Companies with the most Total Layoffs
SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT 
    MIN(`date`), MAX(`date`)
FROM
    layoffs_staging2;


SELECT 
    industry, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT 
    *
FROM
    layoffs_staging2;

-- by country
SELECT 
    country, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;



-- this it total in the past 3 years or in the dataset

SELECT 
    YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT 
    stage, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


SELECT 
    company, AVG(percentage_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;



SELECT 
    SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM
    layoffs_staging2
WHERE
    SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;


-- Rolling Total of Layoffs Per Month

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;




SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;



SELECT 
    company, YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY 3 DESC;


-- now use it in a CTE so we can query off of it
WITH company_Year (company, years,total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
) , Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;













SELECT 
    *
FROM
    data_cleaning_project.layoffs;

-- Create a copy of raw data first and add a row number which helps us to findout duplicates if any

-- create a column names row_num using row_number

with rowCTE as (
select *, row_number() over(
partition by 
		company, 
        location,
        industry, 
        total_laid_off, 
        percentage_laid_off, 
        `date`, 
        stage, 
        country, 
        funds_raised_millions) as row_num
 from layoffs)
 select * from rowCTE where row_num >1;
 
 
 -- Create a table as same as layoffs table with on extra column called row_num
 
 
CREATE TABLE `layoffs_copy` (
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


-- Now insert the data into the layoffs_copy table


insert into layoffs_copy
with rowCTE as (
select *, row_number() over(
partition by 
		company, 
        location,
        industry, 
        total_laid_off, 
        percentage_laid_off, 
        `date`, 
        stage, 
        country, 
        funds_raised_millions) as row_num
 from layoffs)
 select * from rowCTE;
 
-- 1. Identify if we have any duplicates and delete them

SELECT 
    *
FROM
    layoffs_copy
WHERE
    row_num > 1;

-- find the count of duplicates

SELECT 
    COUNT(*)
FROM
    layoffs_copy
WHERE
    row_num > 1;


-- Now delete all those duplicates
DELETE FROM layoffs_copy 
WHERE
    row_num > 1;

-- Recheck if we have any duplicates left
SELECT 
    *
FROM
    layoffs_copy
WHERE
    row_num > 1;


-- 2. Standardize the data

SELECT 
    company
FROM
    layoffs_copy;

-- Here i can identify some spaces in the begining of the company name, let us trim them

SELECT 
    company, TRIM(company)
FROM
    layoffs_copy;

-- Looks better. Now update the table
UPDATE layoffs_copy 
SET 
    company = TRIM(company);

SELECT DISTINCT
    industry
FROM
    layoffs_copy
ORDER BY 1;

-- Here i found three industries with different names but same like crypto. 
-- I wanted to make sure all of them comes under same Industry, Because they actually are.

UPDATE layoffs_copy 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';

-- Now let me see if it really worked

SELECT DISTINCT
    industry
FROM
    layoffs_copy
WHERE
    industry LIKE 'Crypto%';
-- Glad! It worked

SELECT DISTINCT
    industry
FROM
    layoffs_copy;

-- Let us also check the same with other columns

SELECT DISTINCT
    country
FROM
    layoffs_copy
ORDER BY 1;

-- Here i found two distinct names of the same country United States in the country column, Lets standardize this

SELECT DISTINCT
    country
FROM
    layoffs_copy
WHERE
    country LIKE '%States%';

UPDATE LAYOFFS_COPY 
SET 
    COUNTRY = 'United States'
WHERE
    country LIKE '%States%';

-- Let us see if it worked

SELECT DISTINCT
    country
FROM
    layoffs_copy
WHERE
    country LIKE '%States%';-- Glad! it worked

SELECT DISTINCT
    `date`
FROM
    layoffs_copy;
-- Now let us standardize the date in YYYY-MM-DD format

SELECT 
    `date`,
    DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'),
            '%Y-%m-%d') AS formatted_date
FROM
    layoffs_copy;
    
-- Update the date column now

UPDATE layoffs_copy 
SET 
    `date` = DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'),
            '%Y-%m-%d');
-- let us see if it worked

-- let us also update the data type of the column

ALTER TABLE layoffs_copy
MODIFY COLUMN `date` DATE;-- COOL!


SELECT 
    company, industry
FROM
    layoffs_copy
WHERE
    industry IS NULL OR industry LIKE '';

-- Now let us try and populate these if we have company names multiple times

SELECT 
    *
FROM
    layoffs_copy
WHERE
    company LIKE 'Airbnb';

-- So there is one Airbnb which is in travel industry. Let's dive deep into it

SELECT 
    a.company, a.industry, b.company, b.industry
FROM
    layoffs_copy a
        JOIN
    layoffs_copy b ON a.company = b.company
        AND a.location = b.location
WHERE
    (a.industry IS NULL OR a.industry = '')
        AND b.industry IS NOT NULL;

-- we can see Airbnb, Carvana, Juul have different branches or locationw=s where we can see the industry, Lets populate using this

UPDATE layoffs_copy 
SET 
    industry = NULL
WHERE
    industry = '';

-- Now update the industry cells
UPDATE layoffs_copy a
        JOIN
    layoffs_copy b ON a.company = b.company
        AND a.location = b.location 
SET 
    a.industry = b.industry
WHERE
    a.industry IS NULL
        AND b.industry IS NOT NULL;
        
SELECT 
    company, industry
FROM
    layoffs_copy
WHERE
    industry LIKE NULL;-- It worked!
    
    
SELECT 
    *
FROM
    layoffs_copy
WHERE
    company LIKE 'Bally%';


-- I found no data to populate total_laid-off and percentage_laid_off columns as i dont have total employees count.

SELECT 
    COUNT(*)
FROM
    layoffs_copy
WHERE
    (total_laid_off IS NULL
        OR total_laid_off = '')
        AND (percentage_laid_off IS NULL
        OR percentage_laid_off = '');

-- There are 361 such rows which is a lot of data. Deleting data could be fun but, 
-- we shall make sure the data is really of no use.

DELETE FROM layoffs_copy 
WHERE
    (total_laid_off IS NULL
    OR total_laid_off = '')
    AND (percentage_laid_off IS NULL
    OR percentage_laid_off = ''); -- BOOM! Gone


-- The last and only remaining step
-- 4. Delete unwanted columns, The only unwanted column is row_num ans=d i will delete it now

ALTER TABLE layoffs_copy
DROP COLUMN row_num;-- And Gone

SELECT 
    *
FROM
    layoffs_copy;







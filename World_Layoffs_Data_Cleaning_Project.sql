-- Data Cleaning

Select * From layoffs;

-- Remove Duplicates
-- Standardize the Data
-- Null Values or Blank values
-- Remove any columns
-- Create a duplicate table for the data cleaning not doing it in raw data

-- Creating a duplicate table

Create Table layoffs_staging
Like layoffs;

Select * From layoffs_staging;

Insert layoffs_staging
Select * From layoffs;

Select * From layoffs_staging;

-- Remove Duplicates

Select *, 
Row_Number() Over(
Partition BY company, industry, total_laid_off, percentage_laid_off, `date`) As row_num 
From layoffs_staging;

-- Creating CTE For Table 

With Duplicate_CTE AS
(Select *,
Row_Number() Over(
Partition BY company, industry, total_laid_off, percentage_laid_off, `date`) As row_num 
From layoffs_staging
)
Select * 
From Duplicate_CTE
Where row_num > 1;     -- to check duplicates

-- Randomly checking any company to see for duplicates

Select * From layoffs_staging
Where company = 'oda'; -- got to know that we have to partition by all columns as funds_raised_millions column may be different

With Duplicate_CTE AS
(Select *,
Row_Number() Over(
Partition BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) As row_num 
From layoffs_staging)

Select * From Duplicate_CTE
Where row_num > 1;

Select * From layoffs_staging
Where company = 'casper';

With Duplicate_CTE AS
(Select *,
Row_Number() Over(
Partition BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) As row_num 
From layoffs_staging)

Delete From 
Duplicate_CTE
Where row_num > 1; -- Delete is not uptable in CTEs so we have create a real but duplicate table of CTE


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select * From layoffs_staging2;

Insert Into layoffs_staging2
Select *,
Row_Number() Over(
Partition BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) As row_num 
From layoffs_staging;

Select * From layoffs_staging2;

Select *
From layoffs_staging2
Where row_num > 1;

Delete 
From layoffs_staging2
Where row_num > 1;

Select *
From layoffs_staging2;

-- Standardizing data
   -- Removing extra spaces

Select company 
From layoffs_staging2;

Select Trim(company)
From layoffs_staging2;

Select company, Trim(company)
From layoffs_staging2;

Update layoffs_staging2
Set company = Trim(company);

Select *
From layoffs_staging2;

-- Making different Crypto% to Crypto

Select Distinct industry
From layoffs_staging2;

Select industry
From layoffs_staging2
Where industry Like 'Crypto%';

Update layoffs_staging2
Set industry = 'Crypto'
Where industry Like 'Crypto%';

Select Distinct industry
From layoffs_staging2;

-- Checking Location column

Select Distinct location
From layoffs_staging2;             -- All good

-- Checking Country column and found trailing . in some United States

Select Distinct country
From layoffs_staging2;

Select Distinct country, Trim(Trailing '.' From country)
From layoffs_staging2
Order By 1;

Update layoffs_staging2
Set country = Trim(Trailing '.' From country)
Where country Like 'United States%';

Select Distinct country
From layoffs_staging2
Order By 1;

-- Changing Date column format and data type from text to Date

Select `date`
From layoffs_staging2;

Select `date`,
str_to_date(`date`, '%m/%d/%Y')
From layoffs_staging2;

Update layoffs_staging2
Set `date` = str_to_date(`date`, '%m/%d/%Y');

Select `date`
From layoffs_staging2;

Alter Table layoffs_staging2
Modify Column `date` Date;

-- Working with Null and Blank Values
   -- We saw that industry column has some null and blanks

Select Distinct industry
From layoffs_staging2;

Select *
From layoffs_staging2
Where industry Is NULL OR industry = '';

Select *
From layoffs_staging2
Where company = 'Airbnb';

Update layoffs_staging2
Set industry = Null
Where industry = '';

Select *
From layoffs_staging2 t1
Join layoffs_staging2 t2
ON t1.company = t2.company
Where (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

Update layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
Where t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Now checking if there is any null values in industry where same company has some not null values

Select *
From layoffs_staging2 t1
Join layoffs_staging2 t2
ON t1.company = t2.company
Where (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- And 

Select *
From layoffs_staging2
Where industry IS NULL;

Select *
From layoffs_staging2
Where company LIKE 'Bally%';

Select *
From layoffs_staging2
Where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
From layoffs_staging2
Where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

Select *
From layoffs_staging2;

ALTER Table layoffs_staging2
DROP Column row_num;

Select *
From layoffs_staging2;

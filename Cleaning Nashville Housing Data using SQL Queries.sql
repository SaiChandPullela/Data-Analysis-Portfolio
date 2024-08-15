
use DATACLEANINGPROJECT;

/*
	Cleaning Data using SQL Queries
*/


/*
	1. Populate addresses
*/

SELECT PropertyAddress
FROM NashvilleHousingData
WHERE propertyaddress IS NULL;


SELECT a.parcelid,
       a.PropertyAddress,
       b.ParcelID,
       b.PropertyAddress,
       isnull(a.PropertyAddress, b.PropertyAddress) AS Propertyaddress
FROM NashvilleHousingData a
JOIN NashvilleHousingData b ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.PropertyAddress IS NULL;


SELECT *
FROM NashvilleHousingData;


/*
	Breaking the property address part into three seperate columns address and city.
	This helps in better querying.
*/

SELECT propertyaddress
FROM NashvilleHousingData;

/* Split the Address into two columns Address and City */
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS PropertySplitAddress,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) AS PropertySplitCity
FROM NashvilleHousingData;


/* Create two new columns and insert the splitdata into those columns*/

ALTER TABLE NashvilleHousingData ADD PropertySplitAddress NVARCHAR(200);


UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE NashvilleHousingData ADD PropertySplitCity NVARCHAR(200);


UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress));


SELECT PropertyAddress,
       PropertySplitAddress,
       PropertySplitCity
FROM NashvilleHousingData;

/*
	2. Break down the Owner address part into three columns Address, city and state
*/
SELECT OwnerAddress
FROM NashvilleHousingData;

/* Split the owner address into three columns Address, City and State*/
SELECT OwnerAddress,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousingData;

/* Add new columns to add the newly created data */
ALTER TABLE NashvilleHousingData ADD OwnerSplitAddress NVARCHAR(200);


ALTER TABLE NashvilleHousingData ADD OwnerSplitCity NVARCHAR(200);


ALTER TABLE NashvilleHousingData ADD OwnerSplitState NVARCHAR(200);

/* Now update the new data into the columns created */
UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

/*
	3. Change 0 and 1 in SoldAsVacant to No and Yes for more readability and easy querying
*/

SELECT DISTINCT soldasvacant,
                count(soldasvacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant;

/* First alter the column properties from bit to varchar and sett he word limit to 3 since wea re only going to use either Yes or No */
ALTER TABLE NashvilleHousingData
ALTER COLUMN soldasvacant VARCHAR(3);

/* Now update the column data using case expression */
UPDATE NashvilleHousingData
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 0 THEN 'NO'
                       WHEN SoldAsVacant = 1 THEN 'YES'
                   END;


/*
	4. Remove all the duplicates from the table
*/

WITH row_numCTE AS
  (SELECT *,
          ROW_NUMBER() OVER(PARTITION BY ParcelId, PropertyAddress, SaleDate, SalePrice, LegalReference
                            ORDER BY UniqueId) row_num
   FROM NashvilleHousingData)
SELECT count(*)
FROM row_numCTE
WHERE row_num > 1;

/* So we can see 104 duplicate rows. Now i am going to delte all those 104  duplicate rows */ WITH row_numCTE AS
  (SELECT *,
          ROW_NUMBER() OVER(PARTITION BY ParcelId, PropertyAddress, SaleDate, SalePrice, LegalReference
                            ORDER BY UniqueId) row_num
   FROM NashvilleHousingData)
DELETE
FROM row_numCTE
WHERE row_num >1;

/* All the duplicated have been deleted now */



/*
	5. Unused columns affect readabilty so delete them for better readability and easy querying
*/ /*
	Since we have split the property address and owner address into several columns for better readability and querying.
	We dont need Property Address and Owner address any more so we will drop those columns
*/
ALTER TABLE NashvilleHousingData
DROP COLUMN PropertyAddress,
            OwnerAddress;


SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousingData';

/*
	Since we dont have the Property Address and owner Address columns.
	I will change the propertysplitaddress, propertysplitcity into propertyaddress and propertycity and likewise with the owneraddress
*/ EXEC sp_rename 'NashvilleHousingData.PropertySplitAddress',
                  'PropertyAddress',
                  'COLUMN';

EXEC sp_rename 'NashvilleHousingData.PropertySplitCity',
               'PropertyCity',
               'COLUMN';

EXEC sp_rename 'NashvilleHousingData.OwnerSplitAddress',
               'OwnerAddress',
               'COLUMN';

EXEC sp_rename 'NashvilleHousingData.OwnerSplitCity',
               'OwnerCity',
               'COLUMN';

EXEC sp_rename 'NashvilleHousingData.OwnerSplitState',
               'OwnerState',
               'COLUMN';


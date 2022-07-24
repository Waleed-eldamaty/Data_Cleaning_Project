SELECT*
FROM nashville_housing_2;

/*
SELECT
COUNT(uniqueID)
FROM nashville_housing_2;
*/

SELECT
SUM(CASE when PropertyAddress='' THEN 1 ELSE 0 END) AS EmptyCount,
SUM(CASE when PropertyAddress IS NULL THEN 1 ELSE 0 END) AS NullCount 
FROM nashville_housing_2;
 
 
 -- Populate Property Address data

SELECT *
FROM nashville_housing_2
Where PropertyAddress is null
order by ParcelID;


SELECT table_a.ParcelID, table_a.PropertyAddress, table_b.ParcelID, table_b.PropertyAddress, ifnull(table_a.PropertyAddress,table_b.PropertyAddress)
FROM nashville_housing_2 table_a
JOIN nashville_housing_2 table_b
	on table_a.ParcelID = table_b.ParcelID
	AND table_a.UniqueID <> table_b.UniqueID
Where table_a.PropertyAddress is null;

/*
Update table_a
SET PropertyAddress = ifnull(table_a.PropertyAddress,table_b.PropertyAddress)
From nashville_housing_2 table_a
JOIN nashville_housing_2 table_b
	on table_a.ParcelID = table_b.ParcelID
	AND table_a.UniqueID <> table_b.UniqueID
Where table_a.PropertyAddress is null;
 */

-- Dividing Property Address into Individual Columns (Address, City)

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) as PropertySplitAddress,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as PropertySplitCity
FROM nashville_housing_2;

ALTER TABLE nashville_housing_2
Add PropertySplitAddress Nvarchar(255);

Update nashville_housing_2
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 );


ALTER TABLE nashville_housing_2
Add PropertySplitCity Nvarchar(255);

Update nashville_housing_2
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress));

-- Dividing Owner Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1 ) as OwnerSplitAddress, -- Inner: Return the location of the comma in the field "OwnerAddress" then -1 to remove the comma from the result, Outer: for the field "OwnerAddress", start as postion 1 & return the Number of characters obtained from Inner
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),",",-1) as OwnerSplitCity, -- Inner: Returns all to the left of the 2nd Comma, Outer: Use this to return all to the right of the 1st comma
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-2),",",-1) as OwnerSplitState -- Inner: Returns all to the Right of the 2nd Comma, Outer: Use this to return all to the right of the 1st comma
From nashville_housing_2;

ALTER TABLE nashville_housing_2
Add OwnerSplitAddress Nvarchar(255);

Update nashville_housing_2
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1 );


ALTER TABLE nashville_housing_2
Add OwnerSplitCity Nvarchar(255);

Update nashville_housing_2
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),",",-1);


ALTER TABLE nashville_housing_2
Add OwnerSplitState Nvarchar(255);

Update nashville_housing_2
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-2),",",-1);


-- Changing Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM nashville_housing_2;

Update nashville_housing_2
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
       
-- Remove Duplicates

WITH Remove_Duplicates AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
	     SalePrice,
	     SaleDate,
	     LegalReference
ORDER BY
UniqueID) row_num
FROM nashville_housing_2);

SELECT * -- Swap with DELETE to remove the duplicated rows
From Remove_Duplicates
Where row_num > 1
Order by PropertyAddress;

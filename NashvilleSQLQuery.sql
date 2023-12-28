
-- Data cleaning

-- Changind datetime format of 'SaleDate' to date

ALTER TABLE 
	NashvilleHousing
ALTER COLUMN
	SaleDate Date


-- Populating Property Address

SELECT
	A.UniqueID, 
	A.ParcelID,
	CASE
		WHEN A.PropertyAddress IS NULL THEN B.PropertyAddress
		ELSE A.PropertyAddress 
	END AS PropertyAddress
FROM
	NashvilleHousing A
	JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID

UPDATE 
	A
SET
	A.PropertyAddress = CASE
		WHEN A.PropertyAddress IS NULL THEN B.PropertyAddress
		ELSE A.PropertyAddress END 
FROM
	NashvilleHousing A
	JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID


-- Checking if the table was updated correctly

SELECT
	ParcelID, 
	PropertyAddress, 
	COUNT(ParcelID) OVER (PARTITION BY ParcelID, PropertyAddress) NumberOfSales
FROM
	NashvilleHousing
ORDER BY
	3 DESC


-- Splitting 'PropertyAddress' to 'PropertyStreetAddress' and 'PropertyCity'

SELECT
	PropertyAddress, 
	LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) PropertyStreet,
	RIGHT(PropertyAddress,(LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress))) PropertyCity
FROM
	NashvilleHousing


ALTER TABLE
	NashvilleHousing
ADD
	PropertyCity nvarchar(255),
	PropertyStreetAddress nvarchar(255)
	

UPDATE 
	NashvilleHousing
SET
	PropertyCity = RIGHT(PropertyAddress,(LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress))),
	PropertyStreetAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) 


-- Splitting 'OwnerAddress' to 'OwnerStreetAddress', 'OwnerCity' and 'OwnerState'

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) OwnerStreetAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) OwnerCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) OwnerState
FROM
	NashvilleHousing


ALTER TABLE
	NashvilleHousing
ADD
	OwnerStreetAddress nvarchar(255),
	OwnerCity nvarchar(255),
	OwnerState nvarchar(255)


UPDATE 
	NashvilleHousing
SET
	OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Searching for inconsistencies with naming of 'LandUse'

SELECT
	LandUse, COUNT(LandUse) NumberOfParcels
FROM
	NashvilleHousing
GROUP BY 
	LandUse
ORDER BY
	1


-- Updating 'LandUse'

UPDATE
	NashvilleHousing
SET 
	LandUse = CASE 
		WHEN LandUse = 'RESTURANT/CAFETERIA' THEN 'RESTAURANT/CAFETERIA'
		WHEN LandUse = 'VACANT RES LAND' 
		OR LandUse = 'VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
	ELSE LandUse
END


-- Searching for inconsistencies with naming of 'SoldAsVacant'

SELECT
	DISTINCT(SoldAsVacant)
FROM
	NashvilleHousing


-- Updating 'SoldAsVacant'

UPDATE
	NashvilleHousing
SET
	SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


-- Searching for dupliacates and deleting them

WITH DupCTE AS
(
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY 
		ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY UniqueID) RowNumber
	FROM
		NashvilleHousing
)
DELETE
FROM
	DupCTE
WHERE 
	RowNumber > 1


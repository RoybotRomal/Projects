Select *
From Datacleaning.dbo.HouseData


--Standardize Date Format
 Select SaleDateConverted, Convert(Date, SaleDate)
 From DataCleaning..HouseData

 Update HouseData
 SET SaleDate= Convert(Date, SaleDate)

 
 -- Fill Property Address data

Select *
From DataCleaning.dbo.HouseData
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.HouseData a
JOIN DataCleaning.dbo.HouseData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.HouseData a
JOIN DataCleaning.dbo.HouseData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Separating Address (Address, City, State)


Select PropertyAddress
From DataCleaning.dbo.HouseData
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From DataCleaning.dbo.HouseData


ALTER TABLE HouseData
Add PropertySplitAddress Nvarchar(255);

Update HouseData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HouseData
Add PropertySplitCity Nvarchar(255);

Update HouseData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From DataCleaning.dbo.HouseData





Select OwnerAddress
From DataCleaning.dbo.HouseData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From DataCleaning.dbo.HouseData



ALTER TABLE HouseData
Add OwnerSplitAddress Nvarchar(255);

Update HouseData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HouseData
Add OwnerSplitCity Nvarchar(255);

Update HouseData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE HouseData
Add OwnerSplitState Nvarchar(255);

Update HouseData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From DataCleaning.dbo.HouseData

-- Changing Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaning.dbo.HouseData
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From DataCleaning.dbo.HouseData


Update HouseData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From DataCleaning.dbo.HouseData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From DataCleaning.dbo.HouseData



-- Delete Unused Columns


Select *
From DataCleaning.dbo.HouseData


ALTER TABLE DataCleaning.dbo.HouseData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

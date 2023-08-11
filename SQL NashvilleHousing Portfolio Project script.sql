                                                        --Cleaning Data in SQL Queries
SELECT *
From PortfoioProject.dbo.NashvilleHousing



                                                          -- Standardize Date Format
SELECT SaleDate
From PortfoioProject.dbo.NashvilleHousing

--Table UPDATE
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Check
SELECT SaleDateConverted
From PortfoioProject.dbo.NashvilleHousing




                                                          --Populate Property Address data
SELECT *
From PortfoioProject.dbo.NashvilleHousing
Where PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfoioProject.dbo.NashvilleHousing a
JOIN PortfoioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfoioProject.dbo.NashvilleHousing a
JOIN PortfoioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



                                               --Breaking out Address into Individual Columns (Address, City)
SELECT PropertyAddress
From PortfoioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfoioProject.dbo.NashvilleHousing

--Table UPDATE
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Check
SELECT *
From PortfoioProject.dbo.NashvilleHousing


                                                            --Split OwnerAddress by Address, City, State
SELECT OwnerAddress
From PortfoioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
From PortfoioProject.dbo.NashvilleHousing

--Table UPDATE
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Check
SELECT *
From PortfoioProject.dbo.NashvilleHousing


                                                              --Change Y and N to Yeas and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfoioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       WHen SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfoioProject.dbo.NashvilleHousing

--UPDATE Table
UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       WHen SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Check
SELECT Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfoioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

                                                                       --Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID, 
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
From PortfoioProject.dbo.NashvilleHousing
)
SELECT *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


--Delete Duplicates
WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID, 
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
From PortfoioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1


                                                                   --Delete Unused Columns

SELECT *
From PortfoioProject.dbo.NashvilleHousing

ALTER TABLE PortfoioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfoioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
use PortfolioProject


-- Cleaning data in SQL queries

select * from TNHouseData
order by 1

------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, CONVERT(Date, SaleDate)
from TNHouseData

ALTER table TNHouseData
add SaleDateCon Date

update TNHouseData
SET SaleDateCon = CONVERT(Date, SaleDate)

Alter table TNHouseData
DROP Column SaleDate

EXEC sp_rename 'TNHouseData.SaleDateCon', 'SaleDate', 'COLUMN';

------------------------------------------------------------------------------------------------------------------------------------------

--Populate property address data

select *--PropertyAddress 
from TNHouseData
--where PropertyAddress is NULL
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from TNHouseData b
join TNHouseData a
	on a.ParcelID=b.ParcelID
	and a.UniqueID!=b.UniqueID
where a.PropertyAddress is NULL

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from TNHouseData b
join TNHouseData a
	on a.ParcelID=b.ParcelID
	and a.UniqueID!=b.UniqueID
where a.PropertyAddress is NULL

------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from TNHouseData

select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

from TNHouseData

ALTER table TNHouseData
add Address Varchar(255);

update TNHouseData
set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

select Address from TNHouseData

ALTER table TNHouseData
add City Varchar(255);

update TNHouseData
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select City from TNHouseData

select OwnerAddress
from TNHouseData

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from TNHouseData

ALTER table TNHouseData
add OSAddress Varchar(255);

update TNHouseData
set OSAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 

select OSAddress from TNHouseData

ALTER table TNHouseData
add OSCity Varchar(255);

update TNHouseData
set OSCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

select OSCity from TNHouseData

ALTER table TNHouseData
add OSState Varchar(255);

update TNHouseData
set OSState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N in Yes and No in "SoldAsVacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from TNHouseData
group by SoldAsVacant
order by 2

select SoldAsVacant
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from TNHouseData

update TNHouseData
set SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

------------------------------------------------------------------------------------------------------------------------------------------
use PortfolioProject
--Remove Duplicates

WITH RowNumCTE AS(
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
from TNHouseData
)
--DELETE
Select *
from RowNumCTE 
where row_num>1

------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Alter table TNHouseData
DROP Column OwnerAddress,
			TaxDistrict,
			PropertyAddress
select *
from PortFolio_Project.dbo.Sheet1

--standardize sale date
select SaleDateConverted, CONVERT(date,SaleDate)
from PortFolio_Project.dbo.Sheet1


alter table Sheet1
add SaleDateConverted Date;

UPDATE Sheet1
SET SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted
from PortFolio_Project.dbo.Sheet1

--populate property address data
select *
from PortFolio_Project.dbo.Sheet1
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortFolio_Project.dbo.Sheet1 a
join PortFolio_Project.dbo.Sheet1 b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortFolio_Project.dbo.Sheet1 a
join PortFolio_Project.dbo.Sheet1 b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns
select PropertyAddress
from PortFolio_Project.dbo.Sheet1
order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address,
CHARINDEX(',',PropertyAddress),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from PortFolio_Project.dbo.Sheet1

alter table dbo.Sheet1
add PropertySplitAddress nvarchar(255);
UPDATE dbo.Sheet1
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table Sheet1
add PropertySplitCity nvarchar(255);
UPDATE Sheet1
SET PropertySplitCity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select OwnerAddress
from PortFolio_Project.dbo.Sheet1

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortFolio_Project.dbo.Sheet1

alter table dbo.Sheet1
add OwnerSplitAddress nvarchar(255);
UPDATE dbo.Sheet1
SET OwnerSplitAddress  = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table Sheet1
add OwnerSplitCity nvarchar(255);
UPDATE Sheet1
SET OwnerSplitCity  = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table Sheet1
add OwnerSplitState nvarchar(255);
UPDATE Sheet1
SET OwnerSplitState  = PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from PortFolio_Project.dbo.Sheet1

--chane no to n and yes to y  
select SoldAsVacant
from PortFolio_Project.dbo.Sheet1

select SoldAsVacant,COUNT(SoldAsVacant)
from PortFolio_Project.dbo.Sheet1
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	when  SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from PortFolio_Project.dbo.Sheet1

update Sheet1
set SoldAsVacant=
case when SoldAsVacant='Y' then 'Yes'
	when  SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from PortFolio_Project.dbo.Sheet1

select SoldAsVacant,COUNT(SoldAsVacant)
from PortFolio_Project.dbo.Sheet1
group by SoldAsVacant
order by 2

--remove duplicate
with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				order by
				UniqueID
				) row_num
from PortFolio_Project.dbo.Sheet1
--order by ParcelID
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress

with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				order by
				UniqueID
				) row_num
from PortFolio_Project.dbo.Sheet1
--order by ParcelID
)
delete 
from RowNumCTE
where row_num>1

--DELETE unused columns
alter table PortFolio_Project.dbo.Sheet1
drop column OwnerAddress,PropertyAddress,SaleDate

select *
from PortFolio_Project.dbo.Sheet1
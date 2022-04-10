/* 
Data cleaning sql
*/

select *
from portfolio_project.dbo.nashville_housing

-- standardize SaleDate

select SaleDate, CONVERT(Date, SaleDate)
from portfolio_project.dbo.nashville_housing

alter table portfolio_project.dbo.nashville_housing
add SaleDateCon Date;

update portfolio_project.dbo.nashville_housing
set SaleDateCon = convert(Date, SaleDate)

-- populate property address data

select *
from portfolio_project.dbo.nashville_housing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio_project.dbo.nashville_housing a
join portfolio_project.dbo.nashville_housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress) 
from portfolio_project.dbo.nashville_housing a
join portfolio_project.dbo.nashville_housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)


-- PropertyAddress 
select PropertyAddress
from portfolio_project.dbo.nashville_housing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress) ) as Address 
from portfolio_project.dbo.nashville_housing

alter table portfolio_project.dbo.nashville_housing
add PropertySplitAddress nvarchar(255);

update portfolio_project.dbo.nashville_housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table portfolio_project.dbo.nashville_housing
add PropertySplitCity nvarchar(255);

update portfolio_project.dbo.nashville_housing
set propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress) )

select * 
from portfolio_project.dbo.nashville_housing


-- OwnerAddress
select *
from portfolio_project.dbo.nashville_housing

select parsename(replace(OwnerAddress,',', '.'), 3),
	parsename(replace(OwnerAddress,',', '.'), 2),
	parsename(replace(OwnerAddress,',', '.'), 1)
from portfolio_project.dbo.nashville_housing

alter table portfolio_project.dbo.nashville_housing
add OwnerSplitAddress nvarchar(255);

update portfolio_project.dbo.nashville_housing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',', '.'), 3)

alter table portfolio_project.dbo.nashville_housing
add OwnerSplitCity nvarchar(255);

update portfolio_project.dbo.nashville_housing
set OwnerSplitCity = parsename(replace(OwnerAddress,',', '.'), 2)

alter table portfolio_project.dbo.nashville_housing
add OwnerSplitState nvarchar(255);

update portfolio_project.dbo.nashville_housing
set OwnerSplitState = parsename(replace(OwnerAddress,',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolio_project.dbo.nashville_housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from portfolio_project.dbo.nashville_housing

update portfolio_project.dbo.nashville_housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
		partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
			order by UniqueID) row_num
from portfolio_project.dbo.nashville_housing

)
-- select *
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress


-- Delete Unused Columns

select *
from portfolio_project.dbo.nashville_housing

alter table portfolio_project.dbo.nashville_housing
drop column OwnerAddress, PropertyAddress, SaleDate
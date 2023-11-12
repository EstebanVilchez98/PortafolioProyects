/* 

Cleaning Data in SQL Queries

*/

Select *
From PortafolioProyect.dbo.NashvilleHousing






------------------------------------------------------------------

--Standarize Data Format


Select SaleDateConverted,CONVERT(date,SaleDate)
From PortafolioProyect.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)
From PortafolioProyect.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted DATE;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)
From PortafolioProyect.dbo.NashvilleHousing





-------------------------------------------------------------------

--Populate Property Address Data


Select *
From PortafolioProyect.dbo.NashvilleHousing
--where PropertyAddress is null
Order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortafolioProyect.dbo.NashvilleHousing a
join PortafolioProyect.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortafolioProyect.dbo.NashvilleHousing a
join PortafolioProyect.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


-------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortafolioProyect.dbo.NashvilleHousing
--where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortafolioProyect.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) 
From PortafolioProyect.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 
From PortafolioProyect.dbo.NashvilleHousing

Select *
From PortafolioProyect.dbo.NashvilleHousing





Select OwnerAddress
From PortafolioProyect.dbo.NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortafolioProyect.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3) 
From PortafolioProyect.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)
From PortafolioProyect.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortafolioProyect.dbo.NashvilleHousing





-------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant),COUNT(SoldAsVacant)
From PortafolioProyect.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From PortafolioProyect.dbo.NashvilleHousing

Update NashvilleHousing 
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From PortafolioProyect.dbo.NashvilleHousing

-------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE  as (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueId
					)  row_num
From PortafolioProyect.dbo.NashvilleHousing
--ORDER BY ParcelID
)
select *
From RowNumCTE
WHERE row_num >1
order by PropertyAddress





-------------------------------------------------------------------

--Delete unused Columns

Select *
From PortafolioProyect.dbo.NashvilleHousing

Alter table PortafolioProyect.dbo.NashvilleHousing
drop column OwnerAddress,PropertyAddress, TaxDistrict

Alter table PortafolioProyect.dbo.NashvilleHousing
drop column SaleDate











-------------------------------------------------------------------
-------------------------------------------------------------------
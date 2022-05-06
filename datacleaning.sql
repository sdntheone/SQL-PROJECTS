/*
data cleaning in SQL
*/

select* 
from [data cleaning]..NashvilleHOusing

--change the date format
select Saledate, 
CONVERT(Date,SaleDate)
from [data cleaning]..NashvilleHOusing

update [data cleaning]..NashvilleHOusing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE [data cleaning]..NashvilleHOusing
ADD SaleDateConverted date;

update [data cleaning]..NashvilleHOusing
SET SaleDateConverted=CONVERT(Date,SaleDate)

--Populate property addresss data

select* 
from [data cleaning]..NashvilleHOusing
--where PropertyAddress is null
order by ParcelID

select* 
from [data cleaning]..NashvilleHOusing a
join [data cleaning]..NashvilleHOusing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [data cleaning]..NashvilleHOusing a
join [data cleaning]..NashvilleHOusing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [data cleaning]..NashvilleHOusing a
join [data cleaning]..NashvilleHOusing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual column (Address,CIty,State)

select PropertyAddress
from [data cleaning]..NashvilleHOusing
 

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 
from [data cleaning]..NashvilleHOusing


ALTER TABLE [data cleaning]..NashvilleHOusing
add PropertySplitAddress Nvarchar(255)


update [data cleaning]..NashvilleHOusing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE[data cleaning]..NashvilleHOusing
add PropertySplitCity Nvarchar(255)

update  [data cleaning]..NashvilleHOusing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

select*
from [data cleaning]..NashvilleHOusing








select OwnerAddress
from [data cleaning]..NashvilleHOusing
 



select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from [data cleaning]..NashvilleHOusing



ALTER TABLE [data cleaning]..NashvilleHOusing
add OwnerSplitAddress Nvarchar(255)

update [data cleaning]..NashvilleHOusing
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3)




ALTER TABLE [data cleaning]..NashvilleHOusing
add OwnerSplitCity Nvarchar(255)

update [data cleaning]..NashvilleHOusing
set OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2)



ALTER TABLE [data cleaning]..NashvilleHOusing
add OwnerSplitState Nvarchar(255)

update [data cleaning]..NashvilleHOusing
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)

select*
from [data cleaning]..NashvilleHOusing




-- change y and N to yes and No in SoldAsVacant

select distinct(SoldAsVacant),count(SoldAsVacant)
from [data cleaning]..NashvilleHOusing
group by SoldAsVacant
 

select SoldAsVacant,
case 
  when SoldAsVacant='Y' then 'YES'
  when SoldAsVacant='N' then 'NO'
  else SoldAsVacant
  end
from [data cleaning]..NashvilleHOusing

update [data cleaning]..NashvilleHOusing
set SoldAsVacant=case 
  when SoldAsVacant='Y' then 'YES'
  when SoldAsVacant='N' then 'NO'
  else SoldAsVacant
  end
from [data cleaning]..NashvilleHOusing


--remove the duplicate value
WITH RowNumCTE as(
select*, 
      ROW_NUMBER() Over(
	  partition by ParcelID,
	  PropertyAddress,
	  SaleDate,
	  SalePrice,
	  LegalReference
	  order by UniqueID
	  )row_num

from  [data cleaning]..NashvilleHOusing
)
select*
from  RowNumCTE
where row_num>1
--order by PropertyAddress

 



--delete unused columns
select*
from [data cleaning]..NashvilleHOusing

alter table [data cleaning]..NashvilleHOusing
drop column PropertyAddress,OwnerAddress, TaxDistrict 

alter table [data cleaning]..NashvilleHOusing
drop column SaleDate

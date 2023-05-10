--cleaning data in sql queries 

select *
from [NashvilleHousing ]

--standardize date format

select SaleDate, convert(date, saledate)
from [NashvilleHousing ]

update [NashvilleHousing ]
set SaleDate=convert(date,saledate)

alter table NashvilleHousing 
add SaleDateConverted Date;

update [NashvilleHousing ]
set SaleDateConverted=convert(date,saledate)

select SaleDateConverted, convert(date, saledate)
from [NashvilleHousing ]

--populate property address data 

Select *
from [NashvilleHousing ]
--where PropertyAddress is null 
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) 
from [NashvilleHousing ] a
join [NashvilleHousing ] b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from [NashvilleHousing ] a
join [NashvilleHousing ] b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

--breaking out address into individual columns 

Select PropertyAddress
from [NashvilleHousing ]

select 
substring(propertyaddress, 1, charindex(',',PropertyAddress)-1) as Address, 
substring(propertyaddress, charindex(',',PropertyAddress)+1, Len(propertyaddress)) as Address 

from [NashvilleHousing ]

alter table NashvilleHousing 
add PropertySplitAddress nvarchar(255);

update [NashvilleHousing ]
set PropertySplitAddress=substring(propertyaddress, 1, charindex(',',PropertyAddress)-1)

alter table NashvilleHousing 
add PropertySplitCity nvarchar(255);

update [NashvilleHousing ]
set PropertySplitCity=substring(propertyaddress, charindex(',',PropertyAddress)+1, Len(propertyaddress))

select *
from [NashvilleHousing ]


select OwnerAddress
from [NashvilleHousing ]

Select 
parsename(replace(owneraddress,',', '.'), 3),
parsename(replace(owneraddress,',', '.'), 2),
parsename(replace(owneraddress,',', '.'), 1)
from [NashvilleHousing ]




alter table NashvilleHousing 
add OwnerSplitAddress nvarchar(255);

update [NashvilleHousing ]
set OwnerSplitAddress=parsename(replace(owneraddress,',', '.'), 3)



alter table NashvilleHousing 
add OwnerSplitCity nvarchar(255);

update [NashvilleHousing ]
set OwnerSplitCity=parsename(replace(owneraddress,',', '.'), 2)


alter table NashvilleHousing 
add OwnerSplitState nvarchar(255);

update [NashvilleHousing ]
set OwnerSplitState=parsename(replace(owneraddress,',', '.'), 1)

select *
from [NashvilleHousing ]



--change y and n to yes and no in "sold as vacant"

select distinct(SoldAsVacant), count(soldasvacant)
from [NashvilleHousing ]
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant='y' then 'Yes'
		when SoldAsVacant='n' then 'No'
		else SoldAsVacant
		end
from [NashvilleHousing ]

Update [NashvilleHousing ]
set SoldAsVacant=
		case when SoldAsVacant='y' then 'Yes'
		when SoldAsVacant='n' then 'No'
		else SoldAsVacant
		end


--remove duplicates

with RowNumCTE as(
select *, 
	ROW_NUMBER() over (
	partition by parcelid, 
				 propertyaddress,
				 saleprice,
				 Saledate,
				 Legalreference
				 order by 
					uniqueid 
					) as row_num

from [NashvilleHousing ]
)


select *
from RowNumCTE
where row_num > 1 
order by PropertyAddress


--Delete unused columns 

select *
from [NashvilleHousing ]

alter table [NashvilleHousing ]
drop column OwnerAddress, PropertyAddress, Saledate   



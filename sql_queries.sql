-- Standardize Date format
update nashville_housing
set "SaleDate"="SaleDate"::date;

-- OR
alter table nashville_housing
add column SaleDateConverted date;

update nashville_housing
set saledateconverted="SaleDate"::date;

-- fill null PropertyAddress with  PropertyAddress that has the same ParcelId.

update nashville_housing
set "PropertyAddress"= tab.new_value
from (select a."PropertyAddress",b."PropertyAddress", b."ParcelID",coalesce(a."PropertyAddress",b."PropertyAddress") as new_value
from nashville_housing a
join nashville_housing b
on(a."ParcelID"=b."ParcelID" and a."UniqueID "<> b."UniqueID ")
where a."PropertyAddress" is null
) as tab
where nashville_housing."ParcelID"=tab."ParcelID" and nashville_housing."PropertyAddress" is null;

-- -- Breaking out Address into Individual Columns (Address, City, State)

ALTER TABLE nashville_housing
add column PropertySplitAddress varchar;

ALTER TABLE nashville_housing
add column PropertySplitCity varchar;

update nashville_housing
set PropertySplitAddress = split_part(a."PropertyAddress",',',1),
    propertysplitcity = split_part(a."PropertyAddress",',',2)
from nashville_housing a;

ALTER TABLE nashville_housing
    add column ownersplitadres varchar;

ALTER TABLE nashville_housing
    add column ownersplitcity varchar;

ALTER TABLE nashville_housing
    add column ownersplitstate varchar;


update nashville_housing
set ownersplitadres=split_part("OwnerAddress", ',', 1),
    ownersplitcity = split_part("OwnerAddress", ',', 2),
    ownersplitstate = split_part("OwnerAddress", ',', 3);

--- Change Y to Yes and N to No

update nashville_housing
set "SoldAsVacant"= case when "SoldAsVacant"='Y' then 'Yes' when "SoldAsVacant"='N' then 'No' else "SoldAsVacant" end;

-- Remove duplicates


delete from nashville_housing where "UniqueID " in
(with template_cte as
(select *, row_number() over
    (partition by "ParcelID","PropertyAddress","SaleDate","SalePrice","LegalReference" order by "UniqueID ") as row_number
from nashville_housing)
select "UniqueID " from template_cte where row_number>1);




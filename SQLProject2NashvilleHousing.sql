-- STEPS FOR PROJECT DATA CLEANING

SELECT *
FROM PortfolioProject..NashVilleHousing
 



------------------------------------------------------------------------------
-- fix date formatting

SELECT SaleDateConverted
FROM PortfolioProject..NashVilleHousing

Update PortfolioProject..NashVilleHousing
SET SaleDate = Convert(date, SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;


Update PortfolioProject..NashVilleHousing
SET SaleDateConverted = Convert(date, SaleDate)
-----------------------------------------------------------------------------------------------
-- Populate property address data

SELECT *
FROM PortfolioProject..NashVilleHousing
WHERE PropertyAddress IS NULL
Order by ParcelID


--a self join

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
-- dont forget alias for tables
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Updating a table, be very careful with update, delete without a backup!!!

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

/*UPDATE a
SET PropertyAddress = NULL 
from PortfolioProject..NashVilleHousing a
WHERE PropertyAddress = ParcelID*/
	
--RAN INTO AN ISSUE HERE WERE BLANKS WERE ACCDIENTALLY REPLACED WITH PARCELID, ABOVE QUERY SOLVED IT



-------------------------------------------------------------------------------- 
---BREAK OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashVilleHousing
WHERE PropertyAddress <> ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, (CharINDEX(',', PropertyAddress)-1)) as Address 
FROM PortfolioProject.dbo.NashVilleHousing


/*--TESTING
SELECT SUBSTRING(ParcelID,CHARINDEX(' ',ParcelID),LEN(ParcelID)) AS Parcel,
ParcelID
FROM PortfolioProject..NashVilleHousing


SELECT LEFT(ParcelID,2) AS Parcel
,ParcelID
FROM PortfolioProject..NashVilleHousing*/

/*

>SELECT --workaround for fixing substring error with negative numbers, was caused by replacing NULL with parcelID
  CASE 
    WHEN CHARINDEX(',', PropertyAddress) > 0 
    THEN SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress) - 1))
    ELSE PropertyAddress
  END as Address
FROM PortfolioProject.dbo.NashVilleHousing; */



--SUBSTRING TAKE 3 arguments, column, startindex and how many characters.
--

SELECT 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress) -1)) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address ----charindex outputs a number, want to start at index
FROM PortfolioProject.dbo.NashVilleHousing


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;


Update PortfolioProject..NashVilleHousing
SET SaleDateConverted = Convert(date, SaleDate)









  




--- Change Y and N to Yes and No in "Sold as Vacant" Field

-- Remove Duplicates


-- Delete unused columns


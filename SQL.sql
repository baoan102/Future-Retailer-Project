--CONSISTANCY
WITH N AS (
SELECT C.[Customer ID]
	-- Check last name
	, IIF(S.[Customer Last Name]=C.[Customer Last Name],0,1) [Last name alert]
	-- Check first name
	, IIF(S.[Customer First Name]=C.[Customer First Name],0,1) [First name alert]
	-- Check profit
	, IIF((S.[Sale Price]-S.[Manufacturer Price]) = [Total Profit (GMROI)],0,1) [Profit alert]
FROM SALES S LEFT JOIN CUSTOMER C 
	ON C.[Customer ID]= S.[CUSTOMER ID])
SELECT SUM([Last name alert]) [Last name alert]
	, SUM([First name alert]) [First name alert]
	, SUM([Profit alert]) [Profit alert]
FROM N;


--CUSTOMER'S PROFILES
WITH N AS(
SELECT	C.[Customer ID]
	, SUM(IIF([ORDER STATUS]='DELIVERED',[Total Profit],NULL)) [Orders AMT]
	, COUNT(IIF([ORDER STATUS]='DELIVERED',[Total Profit],NULL)) [Orders CNT]
	, SUM(IIF([ORDER STATUS]='CANCELLED',[Total Profit],NULL)) [Cancelled AMT]
	, COUNT(IIF([ORDER STATUS]='CANCELLED',[Total Profit],NULL)) [Cancelled CNT]
FROM SALES S LEFT JOIN (SELECT DISTINCT [CUSTOMER ID] FROM CUSTOMER) C 
	ON C.[Customer ID]= S.[CUSTOMER ID] 
GROUP BY C.[CUSTOMER ID]

), GROUP_BY_CATEGORY AS(
	SELECT [CUSTOMER ID], [Product Category], SUM([Quantity Ordered]) [Orders by Category]
		FROM SALES
		WHERE [Order Status] <> 'Cancelled'
		GROUP BY [CUSTOMER ID], [Product Category]
) 
, FAVORITE_CATEGORY AS (
	SELECT DISTINCT  [CUSTOMER ID]
		, [Product Category]
		, ROW_NUMBER() OVER (PARTITION BY [CUSTOMER ID] ORDER BY [Orders by Category] DESC) AAA
	FROM GROUP_BY_CATEGORY
)

-- CREATE FACT_PROFILES TABLE
SELECT N.*,F.[Product Category] [Favotite category]
--INTO FACT_PROFILES
FROM N LEFT JOIN FAVORITE_CATEGORY F ON F.[Customer ID]=N.[Customer ID]
WHERE AAA=1


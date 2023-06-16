/* CASE STUDY QUESTION ON ONLINE FOOD DELIVERY BUISNESS DATA */
USE SWIGGY;

/* CUSTOMER WHO HAVE NEVER ORDERED*/
SELECT NAME FROM S_USER 
WHERE USER_ID NOT IN (SELECT USER_ID  FROM S_ORDERS);

/*AVERAGE PRICE OF DISH*/
SELECT F.F_NAME AS DISH,AVG(M.PRICE) AS AVG_PRICE 
FROM S_MENU M
JOIN S_FOOD F 
ON F.F_ID = M.F_ID
GROUP BY F.F_NAME;

/*TOP RESTAURANT BASED ON ORDER FOR JUNE OR FOR ANY GIVEN MONTH*/
SELECT R.R_NAME AS RESTAURANT,COUNT(O.USER_ID) AS ORDER_RECEIVED 
FROM S_ORDERS O 
JOIN S_RESTAURANT R
ON R.R_ID = O.R_ID
WHERE MONTHNAME(DATE) LIKE "JUNE"
GROUP BY O.R_ID 
ORDER BY COUNT(USER_ID) DESC
LIMIT 1;

/*RESTAURANT WITH SALES IN MONTH OF JUNE OR ANY OTHER MONTH WHICH IS GREATEWR THAN 500*/
SELECT R.R_NAME AS RESTAURANT,SUM(O.AMOUNT) AS REVENUE 
FROM S_ORDERS O 
JOIN S_RESTAURANT R
ON R.R_ID = O.R_ID
WHERE MONTHNAME(DATE) LIKE "JUNE"
GROUP BY R.R_NAME
HAVING SUM(O.AMOUNT) >500;

/*ORDER HISTORY FOR A PARTICULAR CUSTOMER IN A PARTICULAR DATE RANGE */
WITH MASTERTABLE AS(
                  SELECT O.ORDER_ID,O.R_ID,OD.F_ID 
				  FROM S_ORDERS O 
				  JOIN S_ORDER_DETAILS OD 
                  ON O.ORDER_ID = OD.ORDER_ID
				  WHERE (O.USER_ID = 4) AND (O.DATE BETWEEN "2022-06-10" AND "2022-07-10")
                  )
SELECT MT.ORDER_ID,R.R_NAME,F.F_NAME FROM MASTERTABLE MT
JOIN S_RESTAURANT R ON MT.R_ID = R.R_ID
JOIN S_FOOD F ON F.F_ID = MT.F_ID;

/*RESTAURANT WITH MAX REPEATED CUSTOMER*/
SELECT R.R_NAME,COUNT(*) AS LOYAL_CUSTOMER 
FROM (
	   SELECT USER_ID,R_ID,COUNT(*) AS "VISIT" 
       FROM S_ORDERS 
       GROUP BY USER_ID,R_ID 
       HAVING VISIT >1
       ) T
JOIN S_RESTAURANT R 
ON R.R_ID = T.R_ID
GROUP BY T.R_ID
ORDER BY LOYAL_CUSTOMER DESC
LIMIT 1;


/*MOST LOYAL CUSTOMER FOR RESTAURANT*/   
 WITH MTABLE AS(
                 SELECT R_ID,USER_ID,COUNT(*) AS "VISIT" FROM S_ORDERS
                 GROUP BY R_ID,USER_ID 
                 HAVING VISIT >1
                 )
SELECT R.R_NAME AS RESTAURANT, U.NAME AS LOYAL_CUSTOMER 
FROM MtABLE MT JOIN S_RESTAURANT R ON MT.R_ID = R.R_ID JOIN S_USER U ON U.USER_ID = MT.USER_ID
GROUP BY MT.R_ID;

/*MONTH OVER MONTH TOTAL REVENUE GROWTH*/
WITH MTABLE AS (
                 SELECT MONTHNAME(DATE) AS "MONTH",SUM(AMOUNT) AS "REVENUE", 
                 LAG(SUM(AMOUNT),1) OVER(ORDER BY SUM(AMOUNT)) AS "PREVIOUS" 
                 FROM S_ORDERS 
                 GROUP BY MONTHNAME(DATE)
                 )
SELECT MONTH,((REVENUE - PREVIOUS)/PREVIOUS)*100 AS "REVENUE_GROWTH"
FROM MTABLE;
                  
/*MONTH OVER MONTH REVENUE OF A RESTAURANT*/
SELECT T.MONTH,((T.REVENUE-T.PREVIOUS)/T.PREVIOUS)*100 AS REVENUE_GROWTH 
FROM (SELECT MONTHNAME(DATE) AS MONTH,SUM(AMOUNT) AS "REVENUE", 
LAG(SUM(AMOUNT),1) OVER (ORDER BY SUM(AMOUNT)) AS "PREVIOUS"
FROM S_ORDERS 
WHERE R_ID = 1
GROUP BY MONTHNAME(DATE)) T
CREATE Database ToysGroup;
USE ToysGroup;

/*  Task 2 • DDL: creazione delle tabelle
Descrivere la struttura delle tabelle utili a modellare lo scenario ToysGroup tramite sintassi DDL 
e implementarle fisicamente in SQL Server (o DBMS equivalente).
Vincolo: ogni tabella prevede una chiave primaria; 
le chiavi esterne referenziano una chiave primaria esistente nella tabella collegata*/ 

-- T2: creazione tabelle products --
CREATE table dimproduct (
ProductKey INT AUTO_INCREMENT PRIMARY KEY,
Category VARCHAR(50)NOT NULL, 
ProductName VARCHAR(50) NOT NULL,
StandardCost DECIMAL (19,4),
ListPrice DECIMAL (19,4)
);
-- creazione tabelle region --
CREATE table dimregion (
RegionKey INT AUTO_INCREMENT PRIMARY KEY,
StateProvinceCode CHAR(3) NOT NULL,
StateProvinceName VARCHAR(50)NOT NULL,
RegionName VARCHAR(50)NOT NULL,
CountryRegionName VARCHAR(50) NOT NULL
);
-- creazione tabelle sales --

CREATE table factsales (
SalesOrderNumber INT NOT NULL,
SalesOrderLineNumber INT NOT NULL,
ProductKey INT NOT NULL, 
RegionKey INT NOT NULL,   
OrderDate DATE NOT NULL,
OrderQuantity INT,
UnitPrice DECIMAL(9,2),
SalesAmount DECIMAL(9,2),
TotalProductCost DECIMAL(9,2),
PRIMARY KEY(SalesOrderNumber,SalesOrderLineNumber),
FOREIGN KEY(ProductKey)REFERENCES dimproduct(productKey),
FOREIGN KEY(RegionKey) REFERENCES dimregion(RegionKey)
);
DESCRIBE dimproduct;
Show tables;


/* Task 3 • Popolamento dati
popolare le tabelle con dati a scelta: pochi record per tabella sono sufficienti.
Vincolo: ogni INSERT in Sales usa solo ProductID e RegionID già presenti nelle rispettive tabelle.
Criterio di completamento: le query INSERT utilizzate sono riportate insieme al risultato, non solo il dato finale.*/

-- T3.1: Inserire in Product almeno 4 prodotti distribuiti su almeno 2 categorie diverse. --

INSERT INTO dimproduct (Category, ProductName, StandardCost, ListPrice) 
VALUES
('Bikes','Bikes-100', 120.00, 199.99),
('Bikes','Bikes-200', 160.00, 259.99),
('ActionFigures','ActionFigures-100', 3.50, 9.99),
('ActionFigures','ActionFigures-200', 5.00, 12.00); /* non ho inserito ProductKey perchè auto_increment*/
SELECT * FROM dimproduct; 

-- T3.2: Inserire in Region almeno 3 stati distribuiti su almeno 2 region di vendita diverse. --

INSERT INTO dimregion (StateProvinceCode, StateProvinceName, RegionName, CountryRegionName)
VALUES 
('PRO','Provence','WestEurope','France'),
('BAV','Bavaria','WestEurope','Germany'),
('LOM','Lombardy','WestEurope','Italy'),
('CA','California','NorthAmerica','United States'),
('NY','New York','NorthAmerica','United States'),
('BCN','Barcelona','SouthEurope','Spain'); /* non ho inserito PRegionKey perchè auto_increment*/
SELECT * FROM dimregion;

-- T3.3: Inserire in Sales almeno 10 transazioni distribuite su più anni, per poter confrontare periodi diversi.--

INSERT INTO factsales (SalesOrderNumber, SalesOrderLineNumber, ProductKey, RegionKey, OrderDate, OrderQuantity, UnitPrice, SalesAmount, TotalProductCost)
VALUES
(1001,1,1,1,'2023-03-15',2,199.99,399.98,240.00),
(1002, 1, 2, 2, '2023-07-22', 1, 259.99, 259.99, 160.00),
(1003, 1, 3, 3, '2023-11-05', 5, 9.99, 49.95, 17.50),
(1004, 1, 4, 4, '2023-12-19', 3, 12.00, 36.00, 15.00),
(1005, 1, 1, 5, '2024-02-10', 1, 199.99, 199.99, 120.00),
(1006, 1, 2, 6, '2024-05-30', 2, 259.99, 519.98, 320.00),
(1007, 1, 3, 1, '2024-08-14', 4, 9.99, 39.96, 14.00),
(1008, 1, 4, 2, '2024-10-01', 6, 12.00, 72.00, 30.00),
(1009, 1, 1, 3, '2025-01-25', 1, 199.99, 199.99, 120.00),
(1010, 1, 2, 4, '2025-04-12', 3, 259.99, 779.97, 480.00),
(1011, 1, 3, 5, '2025-06-08', 2, 9.99, 19.98, 7.00),
(1012, 1, 4, 6, '2025-09-03', 4, 12.00, 48.00, 20.00);
SELECT *FROM Factsales;

/* Task 4a • Integrità e JOIN
Consegna: verificare l'unicità dele chiavi primarie e costruire l'elenco delle transazioni con INNER JOIN.*/

-- T4a.1: Per ciascuna tabella, scrivere una query che verifichi l'univocità della chiave primaria (una query per tabella).--

-- tabella dimproduct --
SELECT 
      ProductKey, 
      COUNT(ProductKey)
FROM  dimproduct
GROUP BY ProductKey
HAVING COUNT(ProductKey)> 1;

-- tabella dimregion--
SELECT 
      RegionKey,
      COUNT(RegionKey)
FROM dimregion
GROUP BY RegionKey
HAVING  COUNT(RegionKey) > 1;  

-- tabella factSales -- 
SELECT 
      SalesOrderNumber, 
      SalesOrderLineNumber,
      COUNT(*)
FROM factsales
GROUP BY SalesOrderNumber, SalesOrderLineNumber
HAVING COUNT(*) > 1;

-- T4a.2: Con INNER JOIN tra Sales, Product e Region, esporre codice prodotto, categoria, stato, regione di vendita e data per ogni transazione.--

SELECT 
      p.ProductKey,
      p.Category,
      r.StateProvinceName,
      r.RegionName,
      f.OrderDate
FROM dimproduct p
INNER JOIN factsales f
ON p.ProductKey = f.ProductKey
INNER JOIN dimregion r
ON f.regionKey = r.regionkey;
SELECT*FROM factsales;

-- T4a.3: Aggiungere una colonna booleana: True se sono passati più di 180 giorni dalla data vendita, False altrimenti.--
SELECT 
      p.ProductKey,
      p.Category,
      r.StateProvinceName,
      r.RegionName,
      f.OrderDate,
CASE 
           WHEN DATEDIFF(CURDATE(),f.OrderDate) > 180 THEN TRUE
           ELSE FALSE
END AS Over180Days
FROM dimproduct p
INNER JOIN factsales f
ON p.ProductKey = f.ProductKey
INNER JOIN dimregion r
ON f.regionKey = r.regionkey;

/* Task 4b • Aggregazioni e raggruppamenti Consegna: calcolare il fatturato aggregato per diverse chiavi di analisi con GROUP BY e HAVING.*/
-- T4b.1:  Fatturato totale per prodotto e per anno (SUM(SalesAmount) raggruppato per ProductID e anno di SalesDate).--
SELECT 
      ProductKey,
      SUM(SalesAmount) AS TotaleFatturato, 
      YEAR(OrderDate) AS SalesDate
FROM factsales
GROUP BY ProductKey,YEAR(OrderDate); 

-- T4b.2:  Fatturato totale per stato e per anno, ordinato per data e per fatturato decrescente.--
SELECT 
      r.StateProvinceName AS State,
      YEAR(f.OrderDate) AS SalesDate,
      SUM(f.SalesAmount) AS TotaleFatturato
FROM factsales f
INNER JOIN dimregion r
ON f.RegionKey = r.RegionKey
GROUP BY YEAR(f.OrderDate), r.StateProvinceName
ORDER BY TotaleFatturato DESC, YEAR(f.OrderDate) DESC;

-- T4b.3: Categoria di prodotto più richiesta dal mercato, misurata come quantità totale venduta -- 

SELECT 
      p.Category,
	  SUM(f.OrderQuantity)AS TotalQuantity
FROM factsales f
INNER JOIN dimproduct p
ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY TotalQuantity DESC
LIMIT 1; 

/* Task 4c • Subquery e CTE
Consegna: esporre i prodotti venduti con quantità totale superiore alla media di vendita dell'ultimo anno censito, in due modi equivalenti.*/
-- T4c.1: Calcolare, con una subquery, la quantità media venduta per prodotto nell'ultimo anno censito.--

SELECT 
      AVG(TotalQuantity) AS AverageQuantity
FROM  (
     SELECT 
     ProductKey,
     SUM(OrderQuantity) AS TotalQuantity
     FROM factsales
     WHERE YEAR(OrderDate) = ( 
     SELECT MAX(YEAR(OrderDate))
     FROM factsales
  )
GROUP BY ProductKey
)
AS ProductQuantities; 

-- T4c.2: Usare la subquery del punto 1 in una condizione WHERE per filtrare i prodotti sopra la media.--

SELECT  
      ProductKey,
	  SUM(OrderQuantity) AS TotalQuantity
FROM  factsales 
WHERE YEAR(OrderDate) = ( 
          SELECT MAX(YEAR(OrderDate))
           FROM factsales 
     )
GROUP BY ProductKey
HAVING SUM(OrderQuantity) > (
	      SELECT AVG(TotalQuantity)
      FROM   (
            SELECT ProductKey, 
			SUM(OrderQuantity) AS TotalQuantity
			FROM factsales
      WHERE YEAR(OrderDate) = ( 
					SELECT MAX(YEAR(OrderDate)) 
                    FROM factsales 
       )
      GROUP BY ProductKey 
      )
      AS ProductQuantities
);

-- T4c.3: Riscrivere la stessa query con una CTE che isola il calcolo della media, richiamata dalla query principale.--

WITH ProductQuantities AS ( 
	SELECT ProductKey, 
	SUM(OrderQuantity) AS TotalQuantity
	FROM factsales
    WHERE YEAR(OrderDate) = ( 
          SELECT MAX(YEAR(OrderDate))
           FROM factsales )
	GROUP BY ProductKey 
    )
SELECT  
      ProductKey,
	  TotalQuantity
FROM  ProductQuantities
WHERE TotalQuantity > (
SELECT AVG(TotalQuantity) 
FROM ProductQuantities
);

/* Task 4d • Window Functions
Consegna: arricchire il result set delle transazioni con una classifica e un totale progressivo, senza perdere il dettaglio di riga.*/ 

-- T4d.1: Assegnare a ogni prodotto una posizione in classifica per fatturato totale, all'interno della propria categoria.--

WITH ProductSales AS (
SELECT f.ProductKey, p.Category, SUM(f.SalesAmount) OVER(PARTITION BY f.ProductKey) AS ProductTotaleSales
FROM factsales f
JOIN dimproduct p 
ON f.ProductKey = p.ProductKey
)
SELECT ProductKey, Category, ProductTotaleSales, RANK() OVER(PARTITION BY Category ORDER BY ProductTotaleSales DESC) AS CategoryRank
FROM ProductSales;

-- T4d.2: Calcolare, per ogni transazione, il totale progressivo del fatturato della regione fino a quella data.--

SELECT OrderDate, RegionKey, SUM(SalesAmount) OVER (PARTITION BY RegionKey ORDER BY OrderDate) AS RegionTotal
FROM factsales;

-- T4d.3: Confrontare il fatturato di ogni transazione con quello della transazione precedente della stessa regione.--

SELECT OrderDate, RegionKey, SalesAmount, LAG(SalesAmount) OVER(PARTITION BY RegionKey ORDER BY OrderDate) AS PerviuosSalesAmount,
SalesAmount - LAG(SalesAmount) OVER(PARTITION BY RegionKey ORDER BY OrderDate) AS SalesDifference
FROM factsales;

/* Task 4d. Window Functions : 
ho combinato T4d.1 (Classifica per fatturato in categoria) + T4d.2 (Totale porgressivo per regione) 
+ T4d.3 ( Confronto con transazione precedente), in un unico result set con una riga per transazione, 
come richesto dal criterio di completamento : 
'il result set mantiene una riga per transazione, con le colonne aggiuntive di classifica e totale progressivo'*/ 

WITH ProductSales AS (
SELECT f.ProductKey,f.RegionKey, p.Category, f.OrderDate, f.SalesAmount,SUM(f.SalesAmount) 
OVER(PARTITION BY f.ProductKey) AS ProductTotaleSales
FROM factsales f
INNER JOIN dimproduct p 
ON f.ProductKey = p.ProductKey
)
SELECT ProductKey, RegionKey,Category, OrderDate, SalesAmount, ProductTotaleSales,
RANK() OVER(PARTITION BY Category ORDER BY ProductTotaleSales DESC) AS CategoryRank,
SUM(SalesAmount) OVER (PARTITION BY RegionKey ORDER BY OrderDate) AS RegionTotal,
LAG(SalesAmount) OVER(PARTITION BY RegionKey ORDER BY OrderDate) AS PerviuosSalesAmount,
SalesAmount - LAG(SalesAmount) OVER(PARTITION BY RegionKey ORDER BY OrderDate) AS SalesDifference
FROM ProductSales
ORDER BY OrderDate;

/* Task 4e • Prodotti invenduti e VIEW
Consegna: individuare i prodotti mai venduti e creare due viste che espongano informazioni pronte per il reporting*/ 

-- T4e.1:Individuare i prodotti invenduti con un primo approccio a scelta (es. sottrazione o confronto di insiemi).--

/* ho aggiunto a Task 3.1 : nuovo prodotto (Bikes-300) inserito volutamente senza transazione in factsales,
per avere un caso relae di 'prodotto invenduto'da individuare in Task4e.1*/

INSERT INTO dimproduct (Category, ProductName, StandardCost, ListPrice) 
VALUES
('Bikes', 'Bikes-300', 140.00, 229.99);
SELECT * FROM dimproduct; 

SELECT 
      p.ProductKey,
      f.SalesAmount
FROM dimproduct p
LEFT JOIN factsales f
ON p.ProductKey = f.ProductKey
WHERE f.SalesAmount IS NULL;

-- T4e.2: Risolvere la stessa domanda del punto 1 con un secondo approccio diverso dal primo.--
SELECT 
      ProductKey,
      ProductName
FROM dimproduct
WHERE ProductKey NOT IN (
SELECT ProductKey FROM factsales
);

-- T4e.3: Creare una vista sui prodotti che esponga una versione denormalizzata con codice prodotto, nome prodotto e nome categoria.--
CREATE VIEW ProductCategoryView AS 
SELECT 
      ProductKey,
      ProductName,
      Category
FROM dimproduct;

SELECT * FROM ProductCategoryView;

-- T4e.4: Creare una vista per le informazioni geografiche, utile a chi analizza le vendite per area.--
CREATE VIEW RegionGeographyView AS
SELECT 
      RegionKey,
      StateProvinceCode,
      StateProvinceName,
      RegionName,
      CountryRegionName
FROM dimregion;

SELECT * FROM RegionGeographyView;


















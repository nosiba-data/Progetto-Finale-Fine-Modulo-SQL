ToysGroup - Esercitazione SQL

Esercizio per il corso di Data Analysis: modello dati (ERD), creazione tabelle, popolamento dati e query SQL 
(JOIN, aggregazioni, subquery/CTE, window functions, viste) su uno scenario di vendita giocattoli, in MySQL.

Scenario
ToysGroup vende giocattoli in diverse aree geografiche. I prodotti hanno una categoria,
i mercati sono divisi in regioni di vendita. Ogni vendita collega un prodotto a una regione.
-	Product: può essere venduto tante volte o mai. Ha una categoria.
-	Region: può avere molte transazioni o nessuna. Ha uno stato.
-	Sales: ogni transazione è legata a un solo prodotto e una sola regione.

Testo dell'esercizio
Azienda: ToysGroup distribuisce giocatoli in diverse are geografiche del mondo. I prodotti sono classificati in categorie, i mercati in regioni di vendita. 
Ogni vendita collega un prodotto a una regione.
(Product) Un prodotto può essere venduto tante volte, o nessuna. Contiene anche la categoria di appartenenza.
Esempio: 'Bikes-100' e 'Bikes-200' appartengono alla categoria Bikes
(Region) Una regione può avere molte transazioni, o nessuna. Contiene anche lo stato di appartenenza. 
Esempio: 'France' e 'Germany' sono classificati nella region WestEurope.
(Sales) Ogni transazione è riferita a un solo prodotto. Ogni transazione è riferita a una sola regione.
Fatti di vendita: una riga per transazione

Consegna finale: un unico file .sql commentato, con le query numerate nell'ordine degli esercizi e un commento iniziale che dichiara la domanda a cui ciascuna risponde.

Task 1a - Progettazione concettuale Consegna: 
individuare le entità dello scenario ToysGroup e le relazioni tra loro in uno schema Entità/Relazione.
1.	Per ciascuna entità (Product, Region, Sales) indicare l'attributo chiave e i principali attributi descrittivi.
2.	Descrivere la cardinalità delle relazioni Product-Sales e Region-Sales.
3.	Rappresentare le gerarchie: Product include Category, Region include State.

  - Vincolo: lo schema concettuale non indica tipi di dato: solo entità, attributi chiave e relazioni. 
  - Criterio di completamento: ogni entità ha un attributo chiave dichiarato e ogni relazione riporta la cardinalità (1:1, 1:N o N:M).

Task 2 - DDL: creazione delle tabelle Consegna: 
descrivere la struttura delle tabelle utili a modellare lo scenario ToysGroup tramite sintassi DDL e implementarle fisicamente in SQL Server (o DBMS equivalente).
 - Vincolo: ogni tabella prevede una chiave primaria; le chiavi esterne referenziano una chiave primaria esistente nella tabella collegata.
 - Criterio di completamento: le CREATE TABLE eseguono senza errori e Sales referenzia correttamente Product e Region.
  
Task 3 - Popolamento dati Consegna: popolare le tabelle con dati a scelta: pochi record per tabella sono sufficienti.
1.	Inserire in Product almeno 4 prodotti distribuiti su almeno 2 categorie diverse.
2.	Inserire in Region almeno 3 stati distribuiti su almeno 2 region di vendita diverse.
3.	Inserire in Sales almeno 10 transazioni distribuite su più anni, per poter confrontare periodi diversi.
   - Vincolo: ogni INSERT in Sales usa solo ProductID e RegionID già presenti nelle rispettive tabelle.
   - Criterio di completamento: le query INSERT utilizzate sono riportate insieme al risultato, non solo il dato finale.
     
Task 4a - Integrità e JOIN Consegna: 
verificare l'unicità dele chiavi primarie e costruire l'elenco delle transazioni con INNER JOIN.
1.	Per ciascuna tabella, scrivere una query che verifichi l'univocità della chiave primaria (una query per tabella).
2.	Con INNER JOIN tra Sales, Product e Region, esporre codice prodotto, categoria, stato, regione di vendita e data per ogni transazione.
3.	Aggiungere una colonna booleana: True se sono passati più di 180 giorni dalla data vendita, False altrimenti.
 - Criterio di completamento: il numero di righe del punto 2 coincide con il numero di righe di Sales.
  
Task 4b - Aggregazioni e raggruppamenti Consegna: calcolare il fatturato aggregato per diverse chiavi di analisi con GROUP BY e HAVING.
1.	Fatturato totale per prodotto e per anno (SUM(SalesAmount) raggruppato per ProductID e anno di SalesDate).
2.	Fatturato totale per stato e per anno, ordinato per data e per fatturato decrescente.
3.	Categoria di prodotto più richiesta dal mercato, misurata come quantità totale venduta.
4.	- Vincolo: l'anno si estrae dal campo data con una funzione built-in (es. YEAR(SalesDate)), non scritto a mano.
   - Criterio di completamento: ogni query di raggruppamento riporta solo le colonne usate in GROUP BY e gli aggregati richiesti.

Task 4c - Subquery e CTE Consegna: 
esporre i prodotti venduti con quantità totale superiore alla media di vendita dell'ultimo anno censito, in due modi equivalenti.
1.	Calcolare, con una subquery, la quantità media venduta per prodotto nell'ultimo anno censito.
2.	Usare la subquery del punto 1 in una condizione WHERE per filtrare i prodotti sopra la media.
3.	Riscrivere la stessa query con una CTE che isola il calcolo della media, richiamata dalla query principale.
   - Vincolo: il valore soglia (la media) deve risultare da una query, non essere inserito a mano.
   - Criterio di completamento: il result set riporta solo codice prodotto e totale venduto, identico tra la versione con subquery e quella con CTE.
     
Task 4d - Window Functions Consegna: 
arricchire il result set delle transazioni con una classifica e un totale progressivo, senza perdere il dettaglio di riga.
1.	Assegnare a ogni prodotto una posizione in classifica per fatturato totale, all'interno della propria categoria.
2.	Calcolare, per ogni transazione, il totale progressivo del fatturato della regione fino a quella data.
3.	Confrontare il fatturato di ogni transazione con quello della transazione precedente della stessa regione.
  - Vincolo: ogni risultato usa una funzione finestra con PARTITION BY sulla chiave di raggruppamento e ORDER BY sul criterio richiesto, senza GROUP BY che comprima le righe.
  - Criterio di completamento: il result set mantiene una riga per transazione, con le colonne aggiuntive di classifica e totale progressivo.
    
Task 4e - Prodotti invenduti e VIEW Consegna: 
individuare i prodotti mai venduti e creare due viste che espongano informazioni pronte per il reporting.
1.	Individuare i prodotti invenduti con un primo approccio a scelta (es. sottrazione o confronto di insiemi).
2.	Risolvere la stessa domanda del punto 1 con un secondo approccio diverso dal primo.
3.	Creare una vista sui prodotti che esponga una versione denormalizzata con codice prodotto, nome prodotto e nome categoria.
4.	Creare una vista per le informazioni geografiche, utile a chi analizza le vendite per area.
  - Criterio di completamento: le due viste sono interrogabili con una semplice SELECT * e non richiedono JOIN aggiuntivi da parte di chi le usa.
    

Task
1a - Progettazione concettuale
2 - DDL, creazione tabelle
3 - Popolamento dati
4a - Integrità e JOIN
4b - Aggregazioni e raggruppamenti
4c - Subquery e CTE
4d - Window Functions
4e - Prodotti invenduti e viste

Tabelle
dimproduct: ProductKey (PK), Category, ProductName, StandardCost, ListPrice
dimregion: RegionKey (PK), StateProvinceCode, StateProvinceName, RegionName, CountryRegionName
factsales: SalesOrderNumber + SalesOrderLineNumber (PK composta), ProductKey (FK), RegionKey (FK), OrderDate, OrderQuantity, UnitPrice, SalesAmount, TotalProductCost

Governance & Privacy applicata Consegna:
questa parte viene presentata nel file Presentazione, insieme a una breve spiegazione del lavoro fatto e delle scelte fatte lungo il percorso.


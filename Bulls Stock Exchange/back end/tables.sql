------------------
------------------
------------------
------------------
------------------
------------------
------------------
------------------
------------------
------------------
-- DATABASE TABLES --
------------------
------------------
------------------
------------------
------------------
------------------
------------------
------------------
------------------
------------------





 
-- COMPANY GENRES ARE :
-- Energy, Basic Materials, Industrials, Consumer Discretionary, Consumer Staples, Healthcare, Financial, Information Technology, Communications, Utilities, Real Estate








------------------
------------------
-- kse30
------------------
------------------
create table kse30dat
(
indexv int,
dat date
primary key(dat) NOT NULL
)

------------------
------------------
-- notices
------------------
------------------

------------------
-- NOTICE TO PSX
------------------

create table noticecompbankpsx(
regno int NOT NULL,
compname nvarchar(100) NOT NULL,
cnic nvarchar(15) NOT NULL -- C-ANAS: THIS IS CNIC BY COMPANY FOR THE BANK USAGE
primary key(cnic)
foreign key(compname) references psxcompany(compname),
foreign key (regno) references psxcompany(regno),
foreign key(cnic) references bank(cnic)
)
------------------
------------------
create table noticebankpsx(
cnic nvarchar(15) NOT NULL,
bankname nvarchar(50)
primary key(cnic)
foreign key(bankname) references banks(bankname),
foreign key(cnic) references bank(cnic)
)
------------------
-- NOTICE TO BROKER
------------------
create table brokernoticecomp(
regnocompany int,
regnobroker int,
cnicbank nvarchar(15)
primary key(regnocompany,regnobroker)
foreign key(regnobroker) references psxbroker(regnobroker),
foreign key(regnocompany) references psxcompany(regno),
foreign key(cnicbank) references bank(cnic)
)
------------------
------------------
create table brokernotice(
cnicp nvarchar(15),
regnobroker int
primary key(cnicp)
foreign key(regnobroker) references psxbroker(regnobroker),
foreign key(cnicp) references psxperson(cnic)
)
------------------
------------------
------------------
------------------
-- stockbuyer
------------------
------------------

create table stockbuyer(
cnicp nvarchar(15),
nstockstobuy int,
compname nvarchar(100),
maxshareval real
primary key(cnicp,nstockstobuy,compname,maxshareval),
foreign key(cnicp) references psxperson(cnic)
)

------------------
------------------
-- stockseller
------------------
------------------
create table stockseller
(
cnicp nvarchar(15),
nstockstosell int,
compname nvarchar(100),
sharevoffr real
primary key(cnicp,compname) NOT NULL
foreign key(compname) references psxcompany(compname),
foreign key(cnicp) references person(cnic)
)

------------------
------------------
-- stocksellercomp
------------------
------------------
create table stocksellercomp
(
compname nvarchar(100),
nipostosell int, -- C-ANAS: NO. OF IPO'S TO SELL
facevalue real,
dividend real
primary key(compname)
foreign key(compname) references company(compname)
)

---------------
-- PSX DATA START --
---------------


------------------
------------------
-- psx company
------------------
------------------
-- C-ANAS: IF A COMPANY IS NOT REGISTERED IN THE PSX THEN THAT COMPANY CANNOT OFFER SHARES
-- C-ANAS: AND LETS SAY ANY COMPANY COMES THAT NEEDS TO OFFER SHARES THEN WE WILL OPEN THAT COMPANY'S ACCOUNT IN THIS TABLE USING PROC
-- C-ANAS: EACH COMPANY MUST BE REGISTERED HERE IF THE COMPANIES SHARES ARE IN THE MARKET

create table psxcompany(
regno int NOT NULL,
compname nvarchar(100) NOT NULL unique,
compgenre nvarchar(20) NOT NULL,
faceval real,
dividend real,
totalshares int -- C-ANAS: TOTAL NO. OF SHARES(in which each SINGLE SHARE WORTH 5/10 RS.) OF COMPANY SOLD
primary key(regno)
)
alter table psxcompany add constraint uniconstt UNIQUE(compname)
------------------
------------------
-- psx market
------------------
------------------
-- C-ANAS: THIS VALUE WILL BE UPDATED AS PER 'STOCKSELL' TABLE AND DATE WILL ALSO BE UPDATED ACCORDINGLY
create table psxmarket(
regno int NOT NULL,
-- C-ANAS: MEANS WHEN WE SHOW KSE-30 WE WILL SHOW OPEN MARKET KSE-30
msvom real, -- C-ANAS: MaxShareValueOpenMarket means the highest rate of share reached in the OPEN market( the market of psx)
dat date
primary key(regno)
foreign key(regno) references psxcompany(regno)
)
------------------
------------------
-- psx person
------------------
------------------
-- C-ANAS: WE ASSUME THAT THIS IS THE DATABASE CONNECTION TO PSX'S DATABASE WHERE SIMPLY THE USER CNIC AND STOCKS ARE KEPT AS RECORD FOR GOVERNMENT
-- C-ANAS : THINK OF THE SCOPE THAT, THAT USER COULD HAVE BEEN CONNECTED TO MORE THEN ONE STOCKBROKERS LIKE US
create table psxperson(
psxaccno int NOT NULL,
pname nvarchar(50) NOT NULL,
cnic nvarchar(15) NOT NULL
primary key(cnic)
)
alter table psxperson add constraint uniconst UNIQUE(psxaccno)

------------------
------------------
-- psx broker
------------------
------------------
-- C-ANAS: THIS TABLE TELLS THAT WHICH BROKER'S ARE REGISTERED
create table psxbroker(
cnicbroker nvarchar(15) unique,
regnobroker int NOT NULL,
brokername nvarchar(50)
--brokerid int
primary key(regnobroker)
)

------------------
------------------
-- psx record
------------------
------------------
create table psxrecord(
psxaccno int NOT NULL,
noofstocks int NOT NULL,
compname nvarchar(100) NOT NULL,
priceofshare real
primary key(psxaccno,compname)
foreign key(psxaccno) references psxperson(psxaccno),
foreign key(compname) references psxcompany(compname)
)

---------------
-- PSX DATA END --
---------------


---------------
-- BROKER'S DATA INTERCHANGE START --
---------------


------------------
------------------
-- buy broker person
------------------
------------------
-- C-ANAS: AFTER WE HAVE BOUGHT THE STOCK, WE REMOVE THAT STOCK AND DETAIL FROM THE LIST OF 'BUYBROKER'
create table buybrokerperson(
regnobroker int NOT NULL unique,
cnicp nvarchar(15) unique, -- C-ANAS: THIS CNIC NEEDS TO BE VERIFIED FROM PSX, I.E THE PERSON WHO WANTS TO SELL THE STOCK AND AFTER VERIFICATION THE PERSON IS ALSO ADDED IN THE 'PERSONANY' TABLE
bankname nvarchar(50),
compname nvarchar(100), -- C-ANAS: THIS MUST BE A REGISTERED PSX COMPANY REQUIRES TRIGGER & we will get dividend & face value from psx
sharevalue real, -- C-ANAS: HERE WE WILL SEE THE SHAREVALUE OF THE SHARE THAT WE HAVE TO SHOW TO OUR USER, TO LET HIM'HER BUY IT
noofshares int
primary key(regnobroker,cnicp,compname)
foreign key(cnicp) references bank(cnic),
foreign key(compname) references psxcompany(compname),
foreign key(bankname) references banks(bankname),
foreign key(regnobroker) references psxbroker(regnobroker)
-- C-ANAS: AFTER WE GET THE CNIC OF A PERSON AND COMPANY THEN WE ENTER CNIC+COMPANY IN THE 'PERSONANY' TABLE AND THEN WE ENTER THE NO OF SHARES THERE
)

------------------
------------------
-- buy broker company
------------------
------------------
-- C-ANAS: AFTER WE HAVE BOUGHT THE STOCK, WE REMOVE THAT STOCK AND DETAIL FROM THE LIST OF 'BUYBROKERCOMP'
-- C-ANAS:  EQUATION - 11
create table buybrokercomp(
regnobroker int NOT NULL,
compregno int NOT NULL,
compname nvarchar(100) NOT NULL,
cnicbank nvarchar(15) NOT NULL unique,
bankname nvarchar(50),
nipostosell int NOT NULL
primary key(regnobroker,compregno)
foreign key(regnobroker) references psxbroker(regnobroker),
foreign key(compregno) references psxcompany(regno),
foreign key(compname) references psxcompany(compname),
foreign key(bankname) references banks(bankname),
foreign key(cnicbank) references bank(cnic)
)

---------------
-- BROKER'S DATA INTERCHANGE END --
---------------


---------------
-- BANK'S DATA INTERCHANGE START --
---------------


------------------
------------------
-- banks
------------------
------------------
create table banks(
bankname nvarchar(50) NOT NULL
primary key(bankname)
)


------------------
------------------
-- person
------------------
------------------
-- C-ANAS: THIS TABLE IS CREATED FOR US, WE WILL LOGIN WITH THIS PASSWORD ONLY AND NOTHING ELSE AND WILL ADD ANY BROKER IN THE 'OTHERBROKER' AND THE STOCK HE WANTS TO SELL
create table person
(
pname nvarchar (50) NOT NULL,
bdate date NOT NULL,
cnic nvarchar (15) NOT NULL,
country nvarchar (25) NOT NULL,
email nvarchar (75) NOT NULL,
pass nvarchar(8) NOT NULL,
-- C-ANAS: It is necessary to have the bank account
-- C-ANAS: THAT BANK ACCOUNT DETAILS WILL BE MADE TO ENTER HERE BY USER AND BANK TABLE WILL VERIFY THAT IS THERE ANY USER LIKE THAT
bankaccno int NOT NULL,
bankname nvarchar(50) NOT NULL,
psxaccno int DEFAULT NULL,
--  C-ANAS: IF USER IS NEW HE WILL HAVE THIS ACCOUNT CREDITENTIALS EQUAL TO NULL, BUT ON ANY TRANSACTION IT WILL BE OPENED AUTOMATICALLY I.E WE WILL SEND ALL THE CREDITENTIALS TO PSX IN PSX TABLE
-- C-ANAS:  AND IF USER ALREADY HAVE AN ACCOUNT THEN WE WILL NOT BUT INSTEAD WILL VERIFY IF HE HAS AN ACCOUNT IN THE PSX OR NOT, IF NOT THEN ADD NULLS SHOWING THAT HE/SHE DONT HAVE ACCOUNT RE-ENTER INFO ETC INSTEAD OF PUTTING 'STATUSS' 
--statuss BIT --1,0,NULL i.e whether a person is verified or not
primary key(cnic),
foreign key(psxaccno) references psxperson(psxaccno),
foreign key(cnic) references bank(cnic),
foreign key(bankname,bankaccno) references bank(bankname,bankaccno),
foreign key(bankname) references banks(bankname)
)
------------------
------------------
-- company
------------------
------------------
-- C-ANAS:  THE STATUS IS ORIGINALLY DONE WHEN THE PERSON HAVE SENT THE DOCUMENT & HIS EMAIL IS VERIFIED, BUT WE ARE PSX RIGHT NOW -SO, LETS MAP THE CONCEPT THAT
-- C-ANAS: SO THE STATUS WILL BE TRUE AND TRANSACTIONS WILL BE DONE WHEN PERSON'S BANK ACCOUNT NO. AND BANK NAME MATCHES + THIS CAN BE FALSE IF HIS PSX NO. DONOT MATCH
-- C-ANAS: THE COMPANY'S IPO'S CAN ALSO BE OFFERED BY OTHER BROKER'S SO IN THAT CASE
create table company
(
compname nvarchar(100),
compgenre nvarchar(20) NOT NULL,
-- C-ANAS: IF COMPANY IS COMING FIRST TIME TO OFFER SHARES THEN THIS VALUE IS ASSIGNED BY US AND WE ENTER THIS 
-- C-ANAS: statuss because there will be some companies that will be here but not registered IN PSX SO THOSE COMPANIES WILL GIVE EVERY DETAIL ELSE
-- statuss BIT, -- 1,0,NULL (its boolean)
psxregno int DEFAULT NULL, -- FETCHED AS FOREIGN KEY -> MEANS WHEN ASSIGNED THIS VALUE THEN FIRST ENTERED IN THE PSX TABLE AND THEN ENTERED HERE IF STATUS '0' IF STATUS '1' THEN VALUE ONLY FETCHED FROM PSX TABLE USING compname
-- C-ANAS: THE INFO. THAT, IF THE COMPANY IS REG. IN PSX OR NOT TOLD BY COMPANY AND THEN VERIFIED FROM TABLE IF YES THEN STATUSS '1' AND REGNO FETCHED ELSE
-- C-ANAS: (CONT. C) AND IF COMPANY IS FOUND NOT IN PSX OR IS NOT REGISTERED THEN WE FIRST ADD THAT COMPANY AND THERE AND THEN REGNO. FETCHED HERE
-- c-ANAS: BUT YOU SEE THERE I NO NEED OF STATUS BIT, BECAUSE WHETHER COMPANY IS REGISTERED OR NOT HE IS MUST GETTING REGNO. SO JUST A MATTER OF PROC/TRIGGER
iposrem int DEFAULT NULL, --- remaining ipo to sell from our platform
-- C-ANAS: IF THERE ARE IPO'S REMAINING THEN TAKE THE FOLLOWING DETAILS FROM COMPANY ELSE LEAVE THEM AS DEFAULT
cnicbank nvarchar(15) DEFAULT NULL,
bankaccno int DEFAULT NULL,
bankname nvarchar(50) DEFAULT NULL
primary key(compname) NOT NULL,
foreign key(psxregno) references psxcompany(regno),
foreign key(bankname,bankaccno) references bank(bankname,bankaccno),
foreign key(bankname) references banks(bankname),
foreign key(cnicbank) references bank(cnic)
)





------------------
------------------
-- bank
------------------
------------------
-- C-ANAS: BANK TABLE ADDED SINCE WE NEED TO ADD OR SUBTRACT MONEY FROM BANK ACCOUNT AS WELL
-- C-ANAS: WE ARE NOT ALLOWING A USER TO HAVE MORE THAN ONE BANK ACCOUNTS IN A SAME BANK OR DIFFERENT ACCOUNT IN DIFFERENT I.E HE/SHE IS ALLOWED ONLY TO CONNECT HIS/HER SINGLE BANK ACCOUNT FOR STOCK SELL/BUY
-- C-ANAS: THE CUSTOMER FROM THE OTHER BROKER WILL BE ALSO HAVING A BANK ACCOUNT THAT WE WILL SEE FROM THE BANK'S DATABASE BELOW
create table bank
(
cnic nvarchar(15), -- COMPANIES AND PERSON BOTH WILL HAVE BANK ACCOUNTS
bankaccno int,
bankname nvarchar(50),
balance real
primary key (cnic) NOT NULL
foreign key(bankname) references banks(bankname)
)
ALTER TABLE dbo.bank ADD CONSTRAINT unqiueconstraint UNIQUE(bankname,bankaccno);
---------------
-- BANK'S DATA INTERCHANGE END --
---------------

---------------
-- ADMIN DOMAIN START --
---------------

------------------
------------------
-- admine
------------------
------------------
-- C-ANAS: THIS TABLE IS CREATED FOR US, WE WILL LOGIN WITH THIS PASSWORD ONLY AND NOTHING ELSE AND WILL ADD ANY BROKER IN THE 'OTHERBROKER' AND THE STOCK HE WANTS TO SELL
create table admine(
passkey nvarchar(8) DEFAULT '!@#$%^&*'
primary key(passkey)
)


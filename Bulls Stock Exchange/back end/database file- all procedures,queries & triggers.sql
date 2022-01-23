create database stockexchange
-- 1ST EXECUTION BELOW --
use stockexchange
-- NECCESARY TO EXECUTE --


-- DANGER ! --
drop database stockexchange
-- DANGER ! --

----------------------
-- SHARED DATABASES --
--> PSX
--> BANK
--> BROKERS
----------------------


-----------------------------------------------
-----------------------------------------------
-- DONOT EXECUTE THESE BELOW, GO BELOW AND YOU WILL FIND 'EXECUTE THESE BELOW' EXECUTE EVERYTHING BELOW IT 
-----------------------------------------------
-----------------------------------------------


-- .8
-- BROKE A SHARE
-- PRE-ASSUMPTIONS: as you know we at sign-up/login , login verify if the person have provided right psxno or not, so no need to check here
create procedure [f8]
@email nvarchar(75),
@companyname nvarchar(100),
@numberofshares int,
@sharevalueoffered int,
@output int output
AS
BEGIN
	-- cnicperson nvarchar(15)
	declare @cnic nvarchar(15)
	select @cnic=person.cnic from person where person.email=@email
	Declare @tmp int
	Declare @tmp1 nvarchar(5)
	Declare @shr int
	SELECT @tmp=psxaccno FROM psxperson WHERE cnic=@cnic --
	SELECT @tmp1=regno FROM psxcompany WHERE compname=@companyname -- 
	SELECT @shr=msvom FROM psxmarket WHERE regno=@tmp1 --
	if exists( SELECT * FROM psxrecord WHERE (compname=@companyname AND (psxrecord.noofstocks >= @numberofshares) AND psxaccno=@tmp))
	begin
		if(@sharevalueoffered <=@shr)
			begin
				INSERT [dbo].[stockseller] ([cnicp],[nstockstosell],[compname],[sharevoffr])VALUES(@cnic,@numberofshares,@companyname,@sharevalueoffered)
				set @output=1
			end
		else
			begin
				INSERT [dbo].[stockseller] ([cnicp],[nstockstosell],[compname],[sharevoffr])VALUES(@cnic,@numberofshares,@companyname,@sharevalueoffered)
				set @output=2
				--print'Your stock is broked & The chance of your stock to broke is low'
				-- WE ARE IMPLEMENTING LIMITED FUNCTIONALITIES, SO WITHDRAW IS NOT A FUNCTIONALITY GIVEN INTRODUCING 
			end
	end
	else
		begin
			set @output=-1
		end
END
go

-- SELL PRIME TIME

create procedure sellprimetime
as 
begin
print ' High Bulls ' 

	select distinct pr.compname, pr.priceofshare
	from psxrecord as pr join psxcompany as pc on pr.compname= pc.compname join psxmarket as pm on pc.regno=pm.regno
	where pr.priceofshare < pm.msvom adn =
end


-- .10
-- BUY A SHARE



-- -- BEFORE THE USER ENTER WHAT HE WANTS TO BUY WE WILL HAVE TO SHOW ALL THE FOUR PLACES FROM WHERE HE CAN SEE HIMSELF THAT WHAT HE WANTS TO BUY
-- THERE IS TRIGGER REQUIRED FOR STOCKSELLER TABLE THAT KEEPS RUNNING WHENEVER THERE IS INSERTION IN STOCKSELLER TO CHECK IF THE OFFER ENTERED THERE IS USEFUL TO ANYBODY IN THE STOCKBUYER TABLE
-- IF USEFUL TO ANYBODY THIS PROCEDURE GETS EXECUTED BY THAT TRIGGER


-- -- WE ASSUME CNIC IS VERIFIED AS THE PERSON IS OUR CUSTOMER
-- -- STEPS:check person's bank account balance->match the deal->issue noticepsxbank | noticebroker/noticebrokercomp/noticepsxbank/noticepsxcompbank->update the bank accounts of both the parties->remove from table issue notice
-- -- STEPS CONTINUE: ->update parallel psx accounts ->update stockseller/stocksellercomp/buybrokercomp/buybrokerperson
-- -- ->update psxmarket (and it only updates when share price up/down else no change


-- PHANTOM CASE: HANDLING REQUIRED
-- HANDLE: DONT SHOW TO ANYBODY ELSE IN EVERY TRANSACTION CASE THAT, THE TRANSACTION DO BLOCKS IN BANK & PSX BUT HOW DO YOU CHECK IT
-- IF THE PERSON'S THAT COMPANY STOCKS ARE BEING PROCESSED THEN THESE STOCKS ARE NOT SHOWN TO ANYBODY ELSE AND
-- -- 1ST REMOVE THE PERSON FROM STOCK BUYER IF HE ALREADY EXISTS
create procedure [f10]
@cnic nvarchar(15),
@nstockstobuy int,
@compname nvarchar(100),
@mybankname nvarchar(50),
@maxshareval real
AS
BEGIN
	-- seller
		declare @banknames nvarchar(50)
		declare @regnos nvarchar(5)
		declare @cnics nvarchar(15)
		declare @blncseller real
		declare @priceshareoripo real
	-- buyer
		declare @nskbuyer int -- existing stocks in the company
		declare @blncbuyer real
		declare @psxaccbuyer int
		SELECT  @psxaccbuyer=psxaccno FROM psxperson WHERE cnic=@cnic
	if not exists( SELECT [balance] from bank where @cnic=cnic AND [balance]>=(maxshareval*nstockstobuy) AND @mybankname=bankname)
		begin
			print'Your account have insufficient balance for purchasing the required stocks/shares'
		end
	else
		begin
			if exists(SELECT * FROM stockbuyer WHERE cnicp=@cninc AND compname=@compname)
				begin
					DELETE FROM stockbuyer WHERE cnicp=@cnic AND compname=@compname
				end
			if exists(SELECT * FROM stocksellercomp WHERE stocksellercomp.compname=@compname AND @nstocktobuy<=stocksellercomp.nipostosell AND stocksellercomp.facevalue <= maxshareval)
				begin
					SELECT @regnos=[psxregno],@banknames=[bankname],@cnics=cnicbank FROM company WHERE @compname=compname
					SELECT @priceshareoripo=faceval FROM psxcompany WHERE @regno=[regno].[psxcompany]
					-- notice issuance
					INSERT [dbo].[noticebankpsx]([cnic],[bankname])VALUES(@cnic,@mybankname)
					INSERT [dbo].[noticecompbankpsx]([regno],[compname],[cnic])VALUES(@regnos,@compname,@cnics)
					-- balance updation of both parties
					SELECT @blncbuyer=balance FROM bank WHERE @mybankname=bankname AND @cnic=cnic
					SELECT @blncseller=balance FROM bank WHERE @banknames=bankname AND @cnics=cnic
					declare @tmp=(@priceshareoripo*@nstockstobuy)
					SET @blncbuyer=@blncbuyer-(@tmp)
					SET @blncseller=@blncseller+(@tmp)
					UPDATE [bank] SET balance=@blncbuyer WHERE @mybankname=bankname AND @cnic=cnic
					UPDATE [bank] SET balance=@blncseller WHERE @banknames=bankname AND @cnics=cnic
					-- balance updation
					-- psx account update
					-- buyer
					SELECT @psxaccbuyer=psxaccno FROM psxperson WHERE cnic=@cnic
					if exists (SELECT * FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname)
						begin
							SELECT @nskbuyer=noofstocks FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname
							SET @nskbuyer=@nskbuyer+@nstockstobuy
							UPDATE [dbo].[psxrecord] SET noofstocks=@nskbuyer WHERE @psxaccseller=psxaccno AND @compname=compname
						end
					else
						begin
							INSERT [dbo].[psxrecord]([psxaccno],[noofstocks],[compname]) VALUES(@psxaccbuyer,@nstockstobuy,@compname)
						end
					--seller company
					declare @nsksellercomp int
					SELECT @nsksellercomp=nipostosell FROM stocksellercomp WHERE @compname=compname
					SET @nsksellercomp=@nsksellercomp-@nstockstobuy
					UPDATE [psxcompany] SET totalshares=totalshares+@nsksellercomp WHERE @compname=compname AND @regnos=regno
					-- psx account update
					-- update stocksellercomp start
					if(@nskseller=0)
						begin
							DELETE FROM stocksellercomp WHERE @compname=compname
						end
					else
						begin
							UPDATE FROM stocksellercomp SET nipostosell=@nsksellercomp WHERE @compname=compname
						end
					-- update stocksellercomp end
					-- notices clearance
					DELETE FROM [noticecompbankpsx] WHERE regno=@regnos
					DELETE FROM [noticebankpsx] WHERE bankname=@mybankname AND cnic=@cnic
				end
			else if exists(SELECT * FROM buybrokercomp WHERE buybrokercomp.compname=@compname AND @nstocktobuy<=nipostosell.buybrokercomp AND buybrokercomp.facevalue <=maxshareval)
				begin
					declare @regbroker int
					SELECT top 1 @regnos=[compregno],@banknames=[bankname],@cnics=cnicbank,@priceshareoripo=facevalue,@regbroker=regnobroker
					FROM buybrokercomp WHERE @compname=compname
					SELECT @priceshareoripo=faceval FROM psxcompany WHERE @regnos=[regno].[psxcompany]
					-- notice issuance
					INSERT [dbo].[noticebankpsx]([cnic],[bankname])VALUES(@cnic,@mybankname)
					INSERT [dbo].[noticecompbankpsx]([regno],[compname],[cnic])VALUES(@regnos,@compname,@cnics)
					INSERT [dbo].[brokernoticecomp]([regnocompany],[regnobroker],[cnicbank])VALUES(@regnos,@regbroker,@cnics)
					INSERT [dbo].[stockselling]
					-- balance updation of both parties
					SELECT @blncbuyer=balance FROM bank WHERE @mybankname=bankname AND @cnic=cnic
					SELECT @blncseller=balance FROM bank WHERE @banknames=bankname AND @cnics=cnic
					declare @tmp=(@priceshareoripo*@nstockstobuy)
					SET @blncbuyer=@blncbuyer-(@tmp)
					SET @blncseller=@blncseller+(@tmp)
					UPDATE [bank] SET balance=@blncbuyer WHERE @mybankname=bankname AND @cnic=cnic
					UPDATE [bank] SET balance=@blncseller WHERE @banknames=bankname AND @cnics=cnic
					-- balance updation
					-- psx account update
					-- buyer
					SELECT @psxaccbuyer=psxaccno FROM psxperson WHERE cnic=@cnic
					if exists (SELECT * FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname)
						begin
							SELECT @nskbuyer=noofstocks FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname
							SET @nskbuyer=@nskbuyer+@nstockstobuy
							UPDATE [dbo].[psxrecord] SET noofstocks=@nskbuyer WHERE @psxaccseller=psxaccno AND @compname=compname
						end
					else
						begin
							INSERT [dbo].[psxrecord]([psxaccno],[noofstocks],[compname]) VALUES(@psxaccbuyer,@nstockstobuy,@compname)
						end
					--seller company
					declare @nsksellercomp int
					SELECT @nsksellercomp=nipostosell FROM buybrokercomp WHERE @compname=compname AND @regbroker=regnobroker
					SET @nsksellercomp=@nsksellercomp-@nstockstobuy
					UPDATE [psxcompany] SET totalshares=totalshares+@nsksellercomp WHERE @compname=compname AND @regnos=regno
					-- psx account update
					-- update buybrokercomp start
					if(@nsksellercomp=0)
						begin
							DELETE FROM [buybrokercomp] WHERE @compname=compname AND @regbroker=regnobroker
						end
					else
						begin
							UPDATE [buybrokercomp] SET nipostosell=@nsksellercomp WHERE @compname=compname AND @regbroker=regnobroker
						end
					-- update buybrokercomp end
					-- notices clearance
					DELETE FROM [noticecompbankpsx] WHERE regno=@regnos
					DELETE FROM [noticebankpsx] WHERE bankname=@mybankname AND cnic=@cnic	
					DELETE FROM [brokernoticecomp] WHERE regnocompany=@regnos AND regnobroker=@regbroker
				end
			else if exists( SELECT * FROM stockseller WHERE stockseller.compname=@compname AND @nstocktobuy<=stockseller.nstockstosell AND stockseller.sharevoffr <=maxshareval)
				begin
					-- OPTIMIZATION OF LESSEST PRICE REQUIRED HERE -> DONE USING 'ORDER BY'
					declare psxaccseller int
					SELECT top 1 @cnics=cnicp,@priceshareoripo=sharevoffr
					FROM stockseller WHERE @compname=stockseller.compname order by sharevoffr asc
					SELECT @regnos=[psxaccno],@banknames=[bankname] FROM person WHERE @cnics=person.cnic
					-- notice issuance
					INSERT [dbo].[noticebankpsx]([cnic],[bankname])VALUES(@cnic,@mybankname)
					INSERT [dbo].[noticebankpsx]([cnic],[bankname])VALUES(@cnics,@banknames)
					-- balance updation of both parties
					SELECT @blncbuyer=balance FROM bank WHERE @mybankname=bankname AND @cnic=cnic
					SELECT @blncseller=balance FROM bank WHERE @banknames=bankname AND @cnics=cnic
					declare @tmp=(@priceshareoripo*@nstockstobuy)
					SET @blncbuyer=@blncbuyer-(@tmp)
					SET @blncseller=@blncseller+(@tmp)
					UPDATE [bank] SET balance=@blncbuyer WHERE @mybankname=bankname AND @cnic=cnic
					UPDATE [bank] SET balance=@blncseller WHERE @banknames=bankname AND @cnics=cnic
					-- balance updation end
					-- psx account update st
					-- update stockseller st
					declare @nskseller int
					SELECT @psxaccseller=psxaccno FROM psxperson WHERE cnic=@cnics
					SELECT @nskseller=noofstocks FROM psxrecord WHERE @psxaccseller=psxaccno AND @compname=compname
					SET @nskseller=@nskseller-@nstockstobuy
					-- seller
					if(@nskseller=0)
						begin
							DELETE FROM [dbo].[psxrecord] WHERE @psxaccseller=psxaccno AND @compname=compname
							DELETE FROM [dbo].[stockseller] WHERE @cnics=cnicp AND @compname=compname
						end
					else
						begin
							UPDATE [dbo].[psxrecord] SET noofstocks=@nskseller WHERE @psxaccseller=psxaccno AND @compname=compname
							UPDATE [dbo].[stockseller] SET nstockstosell=@nskseller WHERE cnicp=@cnics AND @compname=compname
						end
					-- buyer
					if exists (SELECT * FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname)
						begin
							SELECT @nskbuyer=noofstocks FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname
							SET @nskbuyer=@nskbuyer+@nstockstobuy
							UPDATE [dbo].[psxrecord] SET noofstocks=@nskbuyer WHERE @psxaccseller=psxaccno AND @compname=compname
						end
					else
						begin
							INSERT [dbo].[psxrecord]([psxaccno],[noofstocks],[compname]) VALUES(@psxaccbuyer,@nstockstobuy,@compname)
						end
					declare @datup date
					declare @regnoc nvarchar(5)
					SELECT @regnoc=regno.psxcompany FROM psxcompany WHERE @compname=compname
					if exists(SELECT * FROM psxmarket WHERE @regnoc=regno.psxmarket)
						begin
							SELECT @datup=dat FROM psxmarket WHERE @regnoc=regno.psxmarket
							if(@datup=GETDATE())
								begin
									UPDATE psxmarket SET msvom=@priceshareoripo WHERE @regnoc=regno
								end
							else
								begin
									UPDATE psxmarket SET msvom=@priceshareoripo,dat=GETDATE() WHERE @regnoc=regno									
								end
						end
					else
						begin
							INSERT [dbo].[psxmarket]([regno],[msvom],[dat]) VALUES (@regnoc,@priceshareoripo,GETDATE())
						end
					-- psx account update end
					-- update stockseller end
					-- notices clearance
					DELETE FROM [dbo].[noticebankpsx] WHERE bankname=@mybankname AND cnic=@cnic
					DELETE FROM [dbo].[noticebankpsx] WHERE bankname=@banknames AND cnic=@cnics			
				end
			else if exists(SELECT * FROM buybrokerperson WHERE buybrokerperson.compname=@compname AND @nstocktobuy<=buybrokerperson.noofshares AND buybrokerperson.sharevalue <=maxshareval)
				begin
					declare psxaccseller int
					declare @regbroker int
					-- OPTIMIZATION OF LESSEST PRICE REQUIRED HERE
					SELECT top 1 @banknames=[bankname],@cnics=cnicp,@priceshareoripo=sharevalue,@regbroker=regnobroker FROM buybrokerperson WHERE @compname=compname
					-- notice issuance
					INSERT [dbo].[noticebankpsx]([cnic],[bankname])	   VALUES(@cnic,@mybankname)
					INSERT [dbo].[noticebankpsx]([cnic],[bankname])	   VALUES(@cnics,@banknames)
					INSERT [dbo].[brokernotice] ([cnicp],[regnobroker])VALUES(@cnics,@regbroker)
					-- balance updation of both parties st
					SELECT @blncbuyer=balance  FROM bank WHERE @mybankname=bankname AND @cnic=cnic
					SELECT @blncseller=balance FROM bank WHERE @banknames=bankname  AND @cnics=cnic
					declare @tmp=(@priceshareoripo*@nstockstobuy)
					SET @blncbuyer=@blncbuyer-(@tmp)
					SET @blncseller=@blncseller+(@tmp)
					UPDATE [bank] SET balance=@blncbuyer  WHERE @mybankname=bankname AND @cnic=cnic
					UPDATE [bank] SET balance=@blncseller WHERE @banknames=bankname  AND @cnics=cnic
					-- balance updation end
					-- psx account update
					-- update buybrokerperson
					declare @nskseller int
					SELECT @psxaccseller=psxaccno FROM psxperson WHERE cnic=@cnics
					SELECT @nskseller=noofstocks FROM psxrecord WHERE @psxaccseller=psxaccno AND @compname=compname
					SET @nskseller=@nskseller-@nstockstobuy
					-- seller
					if(@nskseller=0)
						begin
							DELETE FROM [dbo].[psxrecord] WHERE @psxaccseller=psxaccno AND @compname=compname
							DELETE FROM [dbo].[buybrokerperson] WHERE @cnics=cnicp AND @compname=compname AND @regbroker=regnobroker
						end
					else
						begin
							UPDATE [dbo].[psxrecord] SET noofstocks=@nskseller WHERE @psxaccseller=psxaccno AND @compname=compname
							UPDATE [dbo].[buybrokerperson] SET noofstocks=@nskseller WHERE @cnics=cnicp AND @compname=compname AND @regbroker=regnobroker
						end
					-- buyer
					if exists (SELECT * FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname)
						begin
							SELECT @nskbuyer=noofstocks FROM psxrecord WHERE @psxaccbuyer=psxaccno AND @compname=compname
							SET @nskbuyer=@nskbuyer+@nstockstobuy
							UPDATE [dbo].[psxrecord] SET noofstocks=@nskbuyer WHERE @psxaccseller=psxaccno AND @compname=compname
						end
					else
						begin
							INSERT [dbo].[psxrecord]([psxaccno],[noofstocks],[compname]) VALUES(@psxaccbuyer,@nstockstobuy,@compname)
						end
					declare @datup date
					declare @regnoc nvarchar(5)
					SELECT @regnoc=regno.psxcompany FROM psxcompany WHERE @compname=compname
					if exists(SELECT * FROM psxmarket WHERE @regnoc=regno.psxmarket)
						begin
							SELECT @datup=dat FROM psxmarket WHERE @regnoc=regno.psxmarket
							if(@datup=GETDATE())
								begin
									UPDATE psxmarket SET msvom=@priceshareoripo WHERE @regnoc=regno
								end
							else
								begin
									UPDATE psxmarket SET msvom=@priceshareoripo,dat=GETDATE() WHERE @regnoc=regno									
								end
						end
					else
						begin
							INSERT [dbo].[psxmarket]([regno],[msvom],[dat]) VALUES (@regnoc,@priceshareoripo,GETDATE())
						end
					-- psx account update end
					-- update buybrokerperson end
					-- notices clearance
					DELETE FROM [noticebankpsx] 	WHERE bankname=@banknames  AND cnic=@cnics
					DELETE FROM [noticebankpsx] 	WHERE bankname=@mybankname AND cnic=@cnic	
					DELETE FROM [brokernotice]  	WHERE cnicp=@cnics AND regnobroker=@regbroker					
				end
			else
				begin
					INSERT [dbo].[stockbuyer]([cnicp],[nstockstobuy],[compname],[maxshareval]) VALUES (@cnic,@nstockstobuy,@compname,@maxshareval)
				end
		end
END
go

-- .14
-- company's share holders
create procedure [myshareholders]
@companynamein nvarchar(100)
-- OUTPUT TWO THINGS NO. OF SHARE HOLDERS AND EACH SHAREHOLDERS NAME AND NO. OF SHARES THEY HAVE PURCHASED
AS
BEGIN
	if exists( SELECT * FROM psxrecord WHERE @companynamein=psxrecord.compname)
		begin
			SELECT psxrecord.psxaccno,psxrecord.noofstocks FROM psxrecord WHERE @companynamein=psxrecord.compname	
		end
	else
		begin
			print'Currently there are no share holders of your company in the market'
		end
END
go

-- .16
-- person's share holdings

SELECT psxrecord.noofstocks,psxrecord.compname,psxrecord.priceofshare FROM (person inner join psxperson on person.cnic=psxperson.cnic) inner join psxrecord on psxrecord.psxaccno=psxperson.psxaccno  WHERE @email=person.email


-- .17
-- prime time

-- SELLING PRIME TIME
create procedure sellprimetime
as 
begin
print ' Sell Shares of ' 

	select pr.compname, pc.faceval, pc.totalshares
	from psxrecord as pr join psxcompany as pc on pr.compname= pc.compname join psxmarket as pm on pc.regno=pm.regno
	where pr.price < pm.msvom	
end

execute sellprimetime

DROP procedure buyprimetime

-- BUYING PRIME TIME

create procedure buyprimetime
as 
begin
print ' Buy from ' 
	if exists
	begin 
		select bbc.compname, bbc.sharevalue, bbc.dividend
		from buybrokercomp as bbc
		where bbc.facevalue 0
	end
	if exists
	begin 
		select bbc.compname,  bbc.sharevalue, bbc.dividend
		from buybrokercomp as bbc
		where bbc.nipostosell > 0 and bbc.dividend>0
	end
	else if exists
	begin
		select bbc.compname,  bbc.sharevalue, bbc.dividend
		from buybrokercomp as bbc
		where bbc.nipostosell > 0 and bbc.dividend>0
	 select * from stockseller
	 select * from stocksellercomp
	 select * from buybrokercomp
	 select * from buybrokerpersonx
	end
end
go

-- 21,22,23 QUERIES

-- 23
-------MARKET CAPITAL---------

select top 10 pc.totalshares * pm.msvom as marketcapital, pc.compgenre, pc.compname
from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
order by marketcapital desc

-------PERSON CAPITAL---------

select top 10 pr.noofstocks * pr.price as marketcapital, p.pname
from person as p join psxrecord as pr on p.psxaccno= pr.psxaccno
order by marketcapital desc


-- 22
-- kse-30 index

declare @agri1 varchar (30), @agri2 varchar (30), @agri3 varchar (30), @tech1 varchar (30), @tech2 varchar (30), @tech3 varchar (30), @eco1 varchar (30), @eco2 varchar (30), @eco3 varchar (30) 

set @agri1 =
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'agri' 	
	)
)
set @agri2=
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'agri' and pc.compname!= @agri1
	)
)
set @agri3=
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'agri' and pc.compname!= @agri1 and pc.compname!=@agri2
	)
)
set @tech1 =
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'tech' 	
	)
)
set @tech2=
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'tech' and pc.compname!= @tech1
	)
)
set @tech3=
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'tech' and pc.compname!= @tech1 and pc.compname!=@tech2	)
)
set @eco1 =
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'eco' 	
	)
)
set @eco2=
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'eco' and pc.compname!= @eco1
	)
)
set @eco3=
(
	select pc.compname
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.totalshares * pm.msvom =
	(
	select max (pc.totalshares * pm.msvom) as marketcapital
	from psxcompany as pc join psxmarket as pm on pc.regno= pm.regno
	where pc.compgenre= 'eco' and pc.compname!= @eco1 and pc.compname!=@eco2	)
)

select @agri1,@agri2,@agri3,@tech1,@tech2,@tech3,@eco1,@eco2,@eco3
go

-- 21
-------MARKET HAPPENINGS---------

select pc.compname, pc.compgenre, pr.priceofshare
from psxcompany as pc join psxrecord as pr on pc.compname= pr.compname
go

-- .24
-- ipos companies

create procedure checkfirsttime
@compname nvarchar(100),
@output int output
as
begin
	if not exists(select * from psxcompany where psxcompany.compname=@compname)
		begin
			set @output=1
		end
	else
		begin
			set @output=-1
		end
end

go
use stockexchange
create Procedure isfirsttime
@compname nvarchar(100),
@noofipos int,
@priceofipo real,
@dividend real,
@output int output
as
begin
		set @output=-1

		declare @regisNo int
		select @regisNo=max(regno) from psxcompany
		set @regisNo=@regisNo+1

		update company set company.iposrem=@noofipos,company.psxregno=@regisNo where company.compname=@compname

		declare @genre nvarchar(20)

		select @genre=compgenre from company where compname=@compname

		insert into psxcompany values (@regisNo,@compname,@genre,@priceofipo,@dividend,0)

		set @output=1
		select @output=company.iposrem from company where compname=@compname
end
go


declare @ouu int
exec isfirsttime @compname='avein',@noofipos=9,@priceofipo=9,@dividend=8,
@output=@ouu output
go
select @ouu
go




create procedure isnotfirsttime
@compname nvarchar(100),
@noofipos int,
@output int output
as
begin
		update company set iposrem=iposrem+@noofipos where compname=@compname
		if exists( select * from stocksellercomp where stocksellercomp.compname=@compname)
			begin
				update stocksellercomp set stocksellercomp.nipostosell=stocksellercomp.nipostosell+@noofipos where stocksellercomp.compname=@compname
			end
		else
			begin
				declare @faceval real
				select @faceval=faceval from psxcompany where psxcompany.compname=@compname
				declare @dividend real
				select @dividend=dividend from psxcompany where psxcompany.compname=@compname
				insert into stocksellercomp values(@compname,@noofipos,@faceval,@dividend)
			end
		select @output=company.iposrem from company where compname=@compname
end
go




---- DEAD -----
---- DEAD -----
---- DEAD -----
create Procedure companyipos
@inputIpos int,
@compName1 nvarchar(15)
as
begin
			
declare @check1 int
if not exists(select * from psxcompany where @compName1=compname)
	begin

	end
  select @check1=iposrem from company where @compName1=compname
  if @check1<@inputIpos
	begin 
		print 'Error: companys remaining ipos are less than ipos to be sold' 
	end
  else if @check1>=@inputIpos
	begin
		update company set iposrem=iposrem-@inputIpos where compname=@compName1
		insert into stocksellcomp values (@compName1,@inputIpos)
	end
end
go
---- DEAD -----
---- DEAD -----
---- DEAD -----


-- .27
-- MATCH THE DEAL



-- UNDER WORK
SELECT * 
	FROM stocksellercomp 
	WHERE (((stocksellercomp.facevalue >=@shv1) and (stocksellercomp.facevalue <=@shv2)) and ((stocksellercomp.nipostosell >=@n1) and (@n2 <=stocksellercomp.nipostosell)) and ((stocksellercomp.dividend >=@r1) and (stocksellercomp.dividend <=@r2)))
	use stockexchange;
SELECT * 
	FROM buybrokercomp inner join psxcompany on buybrokercomp.compregno=psxcompany.regno 
	WHERE ((psxcompany.faceval >=@shv1) and (psxcompany.faceval <=@shv2)) and ((buybrokercomp.nipostosell >=@n1) and( buybrokercomp.nipostosell <=@n2 )) and ((psxcompany.dividend >=@r1) and (psxcompany.dividend <=@r2) )
	
	SELECT * 
	FROM stockseller inner join psxcompany on stockseller.compname=psxcompany.compname 
	WHERE ((stockseller.sharevoffr >=@shv1 and stockseller.sharevoffr <=@shv2) and (stockseller.nstockstosell >=@n1 and stockseller.nstockstosell <=@n2 ) and (psxcompany.dividend >=@r1 and psxcompany.dividend <=@r2) )
	use stockexchange
	SELECT * 
	FROM buybrokerperson inner join psxcompany on psxcompany.compname=buybrokerperson.compname 
	WHERE ((buybrokerperson.sharevalue >=@shv1 and buybrokerperson.sharevalue <=@shv2) and (buybrokerperson.noofshares >=@n1 and buybrokerperson.noofshares <=@n2 ) and (psxcompany.dividend >=@r1 and psxcompany.dividend <=@r2) )


  
-------------------
-- TABLES
-------------------


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
regno nvarchar(5) NOT NULL,
compname nvarchar(100) NOT NULL,
cnic nvarchar(15) NOT NULL -- C-ANAS: THIS IS CNIC BY COMPANY FOR THE BANK USAGE
primary key(cnic)
)
------------------
------------------
create table noticebankpsx(
cnic nvarchar(15) NOT NULL,
bankname nvarchar(50)
primary key(cnic)
foreign key(bankname) references bank(bankname)
)
------------------
-- NOTICE TO BROKER
------------------
create table brokernoticecomp(
regnocompany nvarchar(5),
regnobroker int,
cnicbank nvarchar(15)primary key(regnocompany,regnobroker)
foreign key(regnobroker) references psxbroker(regnobroker)
)
------------------
------------------
create table brokernotice(
cnicp nvarchar(15),
regnobroker int
primary key(cnicp)
foreign key(regnobroker) references psxbroker(regnobroker)
)
------------------
------------------
------------------
------------------
-- stockbuyer
------------------
------------------

create table stockbuyer(
cnicp int,
nstockstobuy int,
compname nvarchar(100)
maxshareval int
)

------------------
------------------
-- stockseller
------------------
------------------
create table stockseller
(
cnicp int,
nstockstosell int,
compname nvarchar(100),
sharevoffr int
primary key(cnicp,compname) NOT NULL
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


-----------------------------------------------
-----------------------------------------------
-- EXECUTE ALL BELOW
-----------------------------------------------
-----------------------------------------------



------------------
------------------
-- company sign-up
------------------
------------------
create procedure SignUpcompany
@compname nvarchar(100),
@compgenre nvarchar(20),
@psxregno nvarchar(5),
@iposrem int,
@cnicbank nvarchar(15),
@bankaccno int ,
@bankname nvarchar(50),
@output int OUTPUT
as
begin
	if(@psxregno=0)
		begin
			set @psxregno=NULL
		end
	declare @bankVerification BIT,@psxVerification BIT
	set @psxVerification=0
	set @bankVerification=0
	if not exists (select * from [bank] where [bank].bankaccno=@bankaccno AND [bank].bankname=@bankname and [bank].cnic=@cnicbank)
		begin
			set @bankVerification=1
			SET @output=2
			print 'Invalid Bank Details'
		end
	if(@iposrem!=0)
		begin
			if @psxregno is not NULL AND (not exists(select * from psxcompany where @psxregno=regno))
			begin
				set @output=3
				set @psxVerification=1
				print 'Invalid PSX Credentials'
			end
		end
	if (@bankVerification=0 and @psxVerification=0)
		begin
			if not exists(select company.compname from company where company.compname=@compname)
				begin
					set @output=1
					insert into company values (@compname,@compgenre,@psxregno,@iposrem,@cnicbank,@bankaccno,@bankname)
				end
			else
				begin
					SET @output=-2 -- company already exists sign-in
				end
		end
end
go

declare @ot int
execute SignUpcompany
@compname='bulls stock exchange',
@compgenre='Consumer Disc',
@psxregno=NULL,
@iposrem=0,
@cnicbank='09876-9087654-9',
@bankaccno=1,
@bankname='ding dono',
@output=@ot OUTPUT
select @ot
go
-- STRICT NOTICES : VERIFY BANK ACC. & OTHER ACCOUNTS USING CNIC PROVIDED
-- YE NA HOU KE AIK ACCOUNT PE DOU 3EEN BANDAY DANDANTE PHIREN :3

go
INSERT INTO bank values(
'09876-9087654-9',
0909,
'ding dono',
100000)
go
------------------
------------------
-- company sign-in
------------------
------------------
create procedure SignIncompany
@compname nvarchar(100),
@bankaccno int,
@output int OUTPUT
as
begin
	if exists (select * from company where compname=@compname and bankaccno=@bankaccno)
		begin
			SET @output=1
			print 'Login Successful'
		end
	else
		begin
			SET @output=-1
			print 'Sign In Required OR Incorrect Company Details'
		end
end
go
declare @ot int
execute [SignIncompany]
@compname='bulls stock exchange',
@bankaccno=0900,
@output=@ot OUTPUT
select @ot
go
------------------
------------------
-- person sign-up
------------------
------------------
create procedure SignUp
	@lpname nvarchar (50),
	@lbdate date,
	@lcnic nvarchar (15),
	@lcountry nvarchar (25),
	@lemail nvarchar (75),
	@lpass nvarchar(8),
	@lbankaccno int,
	@lbankname nvarchar(50),
	@lpsxaccno int,
	@output int OUTPUT
as
begin
	set @output=9
	declare @bol BIT
	SET @bol=1
	if(@lpsxaccno=0)
		begin
			SET @lpsxaccno=NULL
		end
	
	if exists (select * from person as p where p.cnic= @lcnic)
		begin
			SET @output=2
			SET @bol=0
			print 'Cnic Already Taken - Sign In'
		end
	else
		begin
		
			if exists( select * from person as p where p.email=@lemail )
				begin
					SET @output=3
					SET @bol=0
					print 'Use Another Email or Sign In' 
				end
			if(@bol=1)
				begin
					
					if not exists(select * from [bank] where [bank].bankaccno=@lbankaccno AND [bank].bankname=@lbankname AND [bank].cnic=@lcnic )
						begin
							SET @output=4
							print 'Invalid Bank Credentials'
						end
					if(@lpsxaccno!=NULL and @output!=4)
						begin
							if not exists ( select * from psxperson where [psxperson].psxaccno=@lpsxaccno)
								begin
									SET @output=5
									print'Invalid PSX Credentials'
								end
							else
								begin
									SET @output=1
									insert into person values (@lpname,@lbdate,@lcnic,@lcountry,@lemail,@lpass,@lbankaccno,@lbankname,@lpsxaccno)
								end
						end
					else if(@output!=4)
						begin
							SET @output=1
							insert into person values (@lpname,@lbdate,@lcnic,@lcountry,@lemail,@lpass,@lbankaccno,@lbankname,@lpsxaccno)
						end
				end
		end
end
go

declare @ot int
execute SignUp
	@lpname = 'shakeel zafar',
	@lbdate = '1998-01-29',
	@lcnic = '098765432112345',
	@lcountry = 'Pakistan',
	@lemail = 'shakeel@email.com',
	@lpass = '12345678',
	@lbankaccno = 2,
	@lbankname = 'islamic bank',
	@lpsxaccno = 0,
	@output=@ot OUTPUT
select @ot
go
------------------
------------------
-- person sign-in
------------------
------------------
create procedure SignIn
	@lemail nvarchar (75),
	@lpass nvarchar(8),
	@output int OUTPUT
as
begin
	if exists(select * from [person] where [person].email=@lemail)
		begin
			 if exists(select * from [person] where [person].pass=@lpass AND [person].email=@lemail)
				begin
			SET @output=1					
					print 'Login Successful'
				end
			else
				begin
			SET @output=-1
					print'Incorrect Password'
				end
		end
	else
		begin
			SET @output=2
			print 'Sign Up Required or Incorrect Email'
		end
end
go
execute SignIn
	@lemail = 'as@as',
	@lpass = 'hi'
go

------------------
------------------
------------------
------------------
-- ADMIN PAGE & ITS SUB CATEGORIES
------------------
------------------
------------------
------------------

------------------
------------------
-- admin verify
------------------
------------------
create procedure [adminverify]
@passing nvarchar(8),
@output int OUTPUT
AS
BEGIN
	if exists(SELECT * FROM [dbo].[admine] WHERE @passing=passkey)
		begin
			SET @output=1
		end
	else
		begin
			SET @output=-1
		end
END
go
declare @ot int
execute [adminverify]
@passing='!@#$%^&*',
@output=@ot OUTPUT
select @ot
go
-- INSERT [dbo].[admine]([passkey]) VALUES('!@#$%^&*')


------------------
------------------
-- BROKER OPTION
------------------
------------------

------------------
------------------
-- broker verify
------------------
------------------
create procedure [brokerverify]
@regbroker int,
@ot int OUTPUT
AS
BEGIN
	if exists(SELECT * FROM psxbroker WHERE @regbroker=psxbroker.regnobroker)
		begin
			SET @ot=1
		end
	else
		begin
			SET @ot=-1
		end
END
go

------------------
------------------
-- admin broker - company
------------------
------------------
create procedure [Adminbrokercompany]
@regnobroker int,
@compregno nvarchar(5),
@compname nvarchar(100),
@cnicbank nvarchar(15),
@bankname nvarchar(50),
@nipostosell int,
@output int OUTPUT
AS
BEGIN
-- embedded procedure
declare @otu int
execute [brokerverify]
@regbroker=@regnobroker,
@ot=@otu OUTPUT
-- embedded procedure
	if(@otu=1)
		begin
			if exists ( SELECT * FROM psxcompany WHERE @compname=compname AND @compregno=regno)
				begin
					if exists(SELECT * FROM bank WHERE @cnicbank=cnic AND @bankname=bankname)
						begin
							INSERT [dbo].[buybrokercomp]([regnobroker],[compregno],[compname],[cnicbank],[bankname],[nipostosell]) VALUES(@regnobroker,@compregno,@compname,@cnicbank,@bankname,@nipostosell)
						end
					else
						begin
							SET @output=-3 -- bank issue
						end
				end
			else
				begin
					SET @output=-2 -- psx asc. issue
				end		
		end
	else
		begin
			SET @output=-1 -- broker not registered !
		end
END
go

------------------
------------------
-- admin broker - person
------------------
------------------
create procedure [Adminbrokerperson]
@regnobroker int,
@cnicp nvarchar(15),
@bankname nvarchar(50),
@compname nvarchar(100),
@sharevalue real,
@noofshares int,
@output int OUTPUT
AS
BEGIN
-- embedded procedure
declare @otu int
execute [brokerverify]
@regbroker=@regnobroker,
@ot=@otu OUTPUT
-- embedded procedure
	if(@otu=1)
		begin
			if exists ( SELECT * FROM psxperson WHERE @cnicp=cnic)
				begin
					declare @vr int
					SELECT @vr=psxaccno FROM psxperson WHERE @cnicp=cnic
					if exists ( SELECT * FROM psxrecord WHERE @vr=psxaccno AND @noofshares<=noofstocks AND @compname=compname)
						begin
							if exists( SELECT * FROM bank where bank.bankname=@bankname AND bank.cnic=@cnicp)
								begin
									INSERT [dbo].[buybrokerperson]([regnobroker],[cnicp],[bankname],[compname],[sharvalue],[noofshares]) VALUES(@regnobroker,@cnicp,@bankname,@compname,@sharevalue,@noofshares)
								end
							else
								begin
									SET @output=-4 -- bank credentials issue
								end
						end
					else
						begin
							SET @output=-3 -- stocks doesn't exist
						end
				end
			else
				begin
					SET @output=-2	-- psx reg issue	
				end
		end
	else
		begin
			SET @output=-1 -- broker issue
		end
END
go

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
-- DATABASE --
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
regno nvarchar(5) NOT NULL,
compname nvarchar(100) NOT NULL unique,
compgenre nvarchar(20) NOT NULL,
faceval real,
dividend real,
totalshares int -- C-ANAS: TOTAL NO. OF SHARES(in which each SINGLE SHARE WORTH 5/10 RS.) OF COMPANY SOLD
primary key(regno)
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
primary key(psxaccno)
)


------------------
------------------
-- psx broker
------------------
------------------
-- C-ANAS: THIS TABLE TELLS THAT WHICH BROKER'S ARE REGISTERED
create table psxbroker(
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
noofstocks int DEFAULT NULL,
compname nvarchar(100) DEFAULT NULL,
priceofshare real
primary key(psxaccno,compname)
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
-- C-ANAS: WE NEED 'TRIGGER' HERE THAT VERIFY'S THE INCOMING PERSON FROM THE PSX TABLE
create table buybrokerperson(
regnobroker int NOT NULL unique,
cnicp nvarchar(15) unique, -- C-ANAS: THIS CNIC NEEDS TO BE VERIFIED FROM PSX, I.E THE PERSON WHO WANTS TO SELL THE STOCK AND AFTER VERIFICATION THE PERSON IS ALSO ADDED IN THE 'PERSONANY' TABLE
bankname nvarchar(50),
compname nvarchar(100), -- C-ANAS: THIS MUST BE A REGISTERED PSX COMPANY REQUIRES TRIGGER & we will get dividend & face value from psx
sharevalue real, -- C-ANAS: HERE WE WILL SEE THE SHAREVALUE OF THE SHARE THAT WE HAVE TO SHOW TO OUR USER, TO LET HIM'HER BUY IT
noofshares int
primary key(regnobroker,cnicp,compname)
foreign key(compname) references psxcompany(compname)
-- C-ANAS: AFTER WE GET THE CNIC OF A PERSON AND COMPANY THEN WE ENTER CNIC+COMPANY IN THE 'PERSONANY' TABLE AND THEN WE ENTER THE NO OF SHARES THERE
)

------------------
------------------
-- buy broker company
------------------
------------------
-- C-ANAS: AFTER WE HAVE BOUGHT THE STOCK, WE REMOVE THAT STOCK AND DETAIL FROM THE LIST OF 'BUYBROKERCOMP'
-- C-ANAS:  EQUATION - 11
-- WE NEED 'TRIGGER' HERE WHICH VERIFYS THE INCOMING VALUE IN THE TABLE FROM PSX
create table buybrokercomp( -- C-ANAS: HERE FACE VALUE IS NOT MISSING WE WILL SEE THAT FROM PSX
regnobroker int NOT NULL,
compregno nvarchar(5) NOT NULL,
compname nvarchar(100) NOT NULL,
cnicbank nvarchar(15) NOT NULL unique,
bankname nvarchar(50),
nipostosell int NOT NULL
primary key(regnobroker,compregno)
)

---------------
-- BROKER'S DATA INTERCHANGE END --
---------------


---------------
-- BANK'S DATA INTERCHANGE START --
---------------

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
primary key(bankaccno,bankname) NOT NULL
)

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
foreign key(bankaccno,bankname) references bank(bankaccno,bankname),
foreign key(psxaccno) references psxperson(psxaccno)
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
psxregno nvarchar(5) DEFAULT NULL, -- FETCHED AS FOREIGN KEY -> MEANS WHEN ASSIGNED THIS VALUE THEN FIRST ENTERED IN THE PSX TABLE AND THEN ENTERED HERE IF STATUS '0' IF STATUS '1' THEN VALUE ONLY FETCHED FROM PSX TABLE USING compname
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
foreign key(bankaccno,bankname) references bank(bankaccno,bankname)
)


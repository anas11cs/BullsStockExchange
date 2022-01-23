use stockexchange

-- .8
-- BROKE A SHARE
-- PRE-ASSUMPTIONS: as you know we at sign-up/login , login verify if the person have provided right psxno or not, so no need to check here
create procedure [f8]
@cnicperson nvarchar(15),
@companyname nvarchar(100),
@numberofshares int,
@sharevalueoffered int
AS
BEGIN
	Declare @tmp int
	Declare @tmp1 int
	Declare @shr int
	SELECT @tmp=psxaccno FROM psxperson WHERE cnic=@cnicperson
	SELECT @tmp1=regno FROM psxcompany WHERE compname=@companyname
	SELECT @shr=msvom FROM psxmarket WHERE regno=@tmp1
	if exists( SELECT * FROM psxrecord WHERE (compname=@companyname AND (noofstocks>=@numberofshares) AND psxaccno=@tmp))
	begin
		if(@sharevalueoffered <=msvom)
			begin
				INSERT [dbo].[stockseller] ([cnicp],[nstockstosell],[compname],[sharevoffr])VALUES(@cnicperson,@numberofshares,@companyname,@sharevalueoffered)
				print'Your stock is broked & the chances of your share to be sold is high'
			end
		else
			begin
				INSERT [dbo].[stockseller] ([cnicp],[nstockstosell],[compname],[sharevoffr])VALUES(@cnicperson,@numberofshares,@companyname,@sharevalueoffered)
				print'Your stock is broked & The chance of your stock to broke is low'
				-- WE ARE IMPLEMENTING LIMITED FUNCTIONALITIES, SO WITHDRAW IS NOT A FUNCTIONALITY GIVEN INTRODUCING 
			end
	end
	else
		begin
			print'The credentials to the company name OR no of shares failed to exists against psxaccno '+CAST(@tmp AS VARCHAR)+' stock not broked'
		end
END
go

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
		declare @regnos int
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
					declare @tmp real
					set @tmp=(@priceshareoripo*@nstockstobuy)
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
					declare @regnoc int
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
					declare @regnoc int
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
create procedure [myshares]
@psxaccnoin int NOT NULL
AS
BEGIN
	if exists(SELECT * FROM psxrecord WHERE @psxaccnoin=psxrecord.psxaccno)
		begin
			SELECT psxrecord.compname,psxrecord.noofstocks FROM psxrecord WHERE @psxaccnoin=psxrecord.psxaccno
		end
	else
		begin
			print'Currently there exists no stocks of yours'
		end
END
go


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
		where bbc.nipostosell > 0 and bbc.facevalue>0
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
	 
	end
end
go

-- 21,22,23 QUERIES

-- 21
-------MARKET HAPPENINGS---------

select pc.compname, pc.compgenre, pr.msvom
from psxcompany as pc inner join psxmarket as pr on pc.regno=pr.regno
order by pr.msvom desc


-- 22
-- kse-30 index
select * from psxperson
select * from psxcompany
select * from psxmarket
select * from psxrecord

-----------------------------
-----kse 30 today insert------
-----------------------------


create procedure top3companies
@compgenree nvarchar(20),
@comp1 real output,
@comp2 real output,
@comp3 real output


as
begin

select @comp3=b.forkse30
from
(
select Top 1 a.forkse30
from
(
		select  pc.*, pm.msvom*pc.totalshares as forkse30
		 from psxcompany as pc join psxmarket as pm on pc.regno=pm.regno
		 where pc.compgenre=@compgenree
)
as a
where a.forkse30 not in
(

select Top 2 a.forkse30
from
(
		select  pc.*, pm.msvom*pc.totalshares as forkse30
		 from psxcompany as pc join psxmarket as pm on pc.regno=pm.regno
		 where pc.compgenre=@compgenree
)
as a
)
) as b

select @comp2=b.forkse30
from
(
select Top 1 a.forkse30, a.compname
from
(
		select  pc.*, pm.msvom*pc.totalshares as forkse30
		 from psxcompany as pc join psxmarket as pm on pc.regno=pm.regno
		 where pc.compgenre=@compgenree
)
as a
where a.forkse30 not in
(

select Top 1 a.forkse30
from
(
		select  pc.*, pm.msvom*pc.totalshares as forkse30
		 from psxcompany as pc join psxmarket as pm on pc.regno=pm.regno
		 where pc.compgenre=@compgenree
)
as a
)) as b

select @comp1=b.forkse30
from
(
select Top 1 a.forkse30
from
(
		select  pc.*, pm.msvom*pc.totalshares as forkse30
		 from psxcompany as pc join psxmarket as pm on pc.regno=pm.regno
		 where pc.compgenre=@compgenree
) as a
) as b

if(@comp1 is NULL)
begin
	SET @comp1=0
end
if(@comp2 is NULL)
begin
	SET @comp2=0
end
if(@comp3 is NULL)
begin
	SET @comp3=0
end

end
go

declare @ouu real,@ou1 real,@ou2 real 

exec top3companies
@compgenree='Financial',
@comp1=@ouu output,
@comp2=@ou1 output,
@comp3=@ou2 output


select @ouu as index1, @ou1 as index2, @ou2 as index3
go

-------
-------

create procedure kse30today
@out real output
as	
BEGIN  

		declare @energy1 real ,@energy2 real,@energy3 real
		exec dbo.top3companies 
		@compgenree='Energy',
		@comp1=@energy1 output,
		@comp2=@energy2 output,
		@comp3=@energy3 output

		declare @basic1 real ,@basic2 real,@basic3 real
		exec dbo.top3companies 
		@compgenree='Basic Materials',
		@comp1=@basic1 output,
		@comp2=@basic2 output,
		@comp3=@basic3 output


		declare @indus1 real ,@indus2 real,@indus3 real
		exec dbo.top3companies 
		@compgenree='Industrials',
		@comp1=@indus1 output,
		@comp2=@indus2 output,
		@comp3=@indus3 output

		declare @discretionary1 real ,@discretionary2 real,@discretionary3 real
		exec dbo.top3companies 
		@compgenree='Consumer Disc',
		@comp1=@discretionary1 output,
		@comp2=@discretionary2 output,
		@comp3=@discretionary3 output

		declare @staples1 real ,@staples2 real,@staples3 real
		exec dbo.top3companies 
		@compgenree='Consumer Staples',
		@comp1=@staples1 output,
		@comp2=@staples2 output,
		@comp3=@staples3 output

		declare @health1 real ,@health2 real,@health3 real
		exec dbo.top3companies 
		@compgenree='Healthcare',
		@comp1=@health1 output,
		@comp2=@health2 output,
		@comp3=@health3 output


		declare @fin1 real ,@fin2 real,@fin3 real
		exec dbo.top3companies 
		@compgenree='Financial',
		@comp1=@fin1 output,
		@comp2=@fin2 output,
		@comp3=@fin3 output

		declare @it1 real ,@it2 real,@it3 real
		exec dbo.top3companies 
		@compgenree='Information Tech',
		@comp1=@it1 output,
		@comp2=@it2 output,
		@comp3=@it3 output

		declare @communications1 real ,@communications2 real,@communications3 real
		exec dbo.top3companies 
		@compgenree='Communications',
		@comp1=@communications1 output,
		@comp2=@communications2 output,
		@comp3=@communications3 output


		declare @utilities1 real ,@utilities2 real,@utilities3 real
		exec dbo.top3companies 
		@compgenree='Utilities',
		@comp1=@utilities1 output,
		@comp2=@utilities2 output,
		@comp3=@utilities3 output

		declare @indexv real
		set @indexv=@utilities1+@utilities2+@utilities3+@communications1+@communications2+@communications3+@it1+@it2+@it3+@fin1+@fin2+@fin3
					+@health1+@health2+@health3+@staples1+@staples2+@staples3+@discretionary1+@discretionary2+@discretionary3+@indus1+@indus2
					+@indus3+@basic1+@basic2+@basic3+@energy1+@energy2+@energy3

					set @indexv=(@indexv*1.0)/30.0
					set @out=@indexv                  --if successfully entered out=index of today

	if exists(select * from kse30dat where dat=convert(date,GETDATE()))    --todays index already compuuted
	begin
	    update kse30dat set indexv=@indexv where dat=convert(date,GETDATE())          
	end

	else
	begin
		insert into kse30dat(indexv,dat) values (@indexv,GETDATE())
	end	
	
end
go


declare @ouu real
exec kse30today
@out=@ouu output
select @ouu as indexvalue
-----------------------------
-----kse 30 previous day-------
-----------------------------


create proc kse30prevday
@out real output
as
begin
	SET @out=0
select @out=indexv from kse30dat where dat= convert(date,DATEADD(day,-1,CURRENT_TIMESTAMP)) 
end
go
--execution
declare @ouu real
exec kse30prevday
@out=@ouu output
select @ouu as indexvalue

-----------------------------
-----kse 30 this month-------
-----------------------------

create proc kse30month
@out float output   --out returns avg index of the month
as
begin
declare @days int
select @days=datepart(day,max(dat))  from kse30dat where DATEPART(MONTH, dat)=DATEPART(MONTH,CURRENT_TIMESTAMP) 

set @out=(select sum(indexv) from kse30dat where DATEPART(MONTH, dat)=DATEPART(MONTH,CURRENT_TIMESTAMP)*1.0)/(@days*1.00)

end
go

--execution
declare @ouu float
exec kse30month 
@out=@ouu output
select @ouu as indexvalue

-----------------------------
-----kse 30 compare-------
-----------------------------

create procedure comparekse30
@out real output
as
begin
	set @out=0
	declare @today real,@yesterday real
	set @today=0
	set @yesterday=0
	select @today=indexv from kse30dat where dat=convert(date,GETDATE())
	select @yesterday=indexv from kse30dat where dat=convert(date,dateadd(day,-1,getdate()))

	set @out=@today-@yesterday

end
go
--execution
declare @ouu real
exec comparekse30
@out=@ouu output
select @ouu as indexvalue

-- 23
-------MARKET CAPITAL---------

select top 10 pc.totalshares * pm.msvom as marketcapital, pc.compgenre, pc.compname
from psxcompany as pc inner join psxmarket as pm on pc.regno= pm.regno
order by marketcapital desc

use stockexchange
-------PERSON CAPITAL---------
use stockexchange

select top 5 b.personcapital, b.pname
from (
select a.pname,sum(a.personcapital) as personcapital
from (
select pr.noofstocks * pr.priceofshare as personcapital, p.pname, pr.compname
from psxperson as p inner join psxrecord as pr on p.psxaccno= pr.psxaccno
) as a
group by a.pname) as b
order by b.personcapital desc
-- select * from psxrecord

-- .24
-- ipos companies
create Procedure companyIpos
@inputIpos int,
@compName1 nvarchar(15)
as
begin

declare @check1 int
if not exists(select * from psxcompany where @compName1=compname)
	begin
		declare @regisNo int
		set @regisNo=(select max(regno) from psxcompany)+1
		update company set iposrem=@inputIpos where compname=@compName1
		declare @genre nvarchar(15)
		select @genre=compgenre from company where compname=@compName1
		insert into psxcompany values (@compName1,@genre,@regisNo,0,0,0)
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

-- .27
-- MATCH THE DEAL
create procedure [MatchTheDeal]
@r1 real,
@r2 real,
@n1 int,
@n2 int,
@shv1 int,
@shv2 int
AS
BEGIN
	SELECT * FROM stocksellercomp WHERE ((stocksellercomp.facevalue >=shv1 and stocksellercomp.facevalue <=shv2) and (stocksellercomp.nipostosell >=n1 and stocksellercomp.nipostosell <=n2 ) and (stocksellercomp.dividend >=r1 and stockselleromp.dividend <=r2) )
	SELECT * FROM buybrokercomp inner join psxcompany on buybrokercomp.compregno=psxcompany.regno WHERE ((psxcompany.faceval >=shv1 and psxcompany.faceval <=shv2) and (buybrokercomp.nipostosell >=n1 and buybrokercomp.nipostosell <=n2 ) and (psxcompany.dividend >=r1 and psxcompany.dividend <=r2) )
	SELECT * FROM stockseller inner join psxcompany on stockseller.compname=psxcompany.compname WHERE ((stockseller.sharevoffr >=shv1 and stockseller.sharevoffr <=shv2) and (stockseller.nstockstosell >=n1 and stockseller.nstockstosell <=n2 ) and (psxcompany.dividend >=r1 and psxcompany.dividend <=r2) )
	SELECT * FROM buybrokerperson inner join psxcompany on psxcompany.compname=buybrokerperson.compname WHERE ((buybrokerperson.sharevalue >=shv1 and buybrokerperson.sharevalue <=shv2) and (buybrokerperson.noofshares >=n1 and buybrokerperson.noofshares <=n2 ) and (psxcompany.dividend >=r1 and psxcompany.dividend <=r2) )
END
go

-------------------
-- ADMIN PROCEDURES
-------------------

create procedure checkpsxperson
@pcnic nvarchar(15),
@pername nvarchar(50),
@outputpp int output 
as
begin
	if exists(select * from psxperson where psxperson.cnic=@pcnic)
		begin
			set @outputpp=-1 -- user already exists
		end
	else
		begin
				set @outputpp=1
				declare @ind int
				select @ind=max(psxaccno) from psxperson
				if(@ind is null)
					begin
						set @ind=0
					end 
				else
					begin
						set @ind=@ind+1
					end
			insert into psxperson values (@ind,@pername,@pcnic)
		end
end
go

select * from psxperson
insert into psxperson values(1,'chaudry yameen gujjar','12345-12345-123')
---------
---------

create procedure checkpsxbroker
@brokname nvarchar(50),
@cnicbroker nvarchar(15),
@output int output
as
begin
	if exists(select * from psxbroker where psxbroker.cnicbroker=@cnicbroker)
		begin
			set @output=-1 -- broker already exists
		end
	else
		begin
			set @output=1
			declare @ind int
			select @ind=max(regnobroker) from psxbroker
			if(@ind is null)
				begin
					set @ind=0
				end 
			else
				begin
					set @ind=@ind+1
				end
				insert into psxbroker values (@cnicbroker,@ind,@brokname)
		end
end
go

insert into psxbroker values('0-0-0-0-0-0-0-0',1,'bulls stock exchange')

---------
---------

create procedure checkpsxcompany
@compname nvarchar(100),
@compgenre nvarchar(20),
@faceval real,
@dividend real,
@totalshares int,
@output int output
as
begin
--
if not exists( SELECT * FROM psxcompany where @compname=psxcompany.compname)
begin
	declare @vr int
	if exists ( SELECT * FROM psxcompany) -- check if table isn't empty
		begin
			SELECT @vr=max(regno) from psxcompany
			SET @vr=@vr+1
		end
	else
		begin
			SET @vr=1
		end
		SET @output=1
		insert into psxcompany values (@vr,@compname,@compgenre,@faceval,@dividend,@totalshares)
end
else
begin
	UPDATE psxcompany SET psxcompany.faceval=@faceval, psxcompany.dividend=@dividend,psxcompany.totalshares=@totalshares+psxcompany.totalshares where psxcompany.compname=@compname
	SET @output=1
end
--
end
go

select * from psxcompany

---------
---------

create procedure checkpsxrecord
@psxaccno int,
@noofstocks int,
@compname nvarchar(100),
@priceofshare real,
@output int output
as
begin
 if exists(SELECT * FROM psxperson WHERE psxperson.psxaccno=@psxaccno)
	begin
		declare @used int
		SELECT @used=SUM(psxrecord.noofstocks) FROM psxrecord where psxrecord.compname=@compname
		declare @tot int
		SET @tot=@used+@noofstocks
		if exists(SELECT * FROM psxcompany WHERE psxcompany.compname=@compname and psxcompany.totalshares<=@tot)
			begin
				if exists (SELECT * FROM psxrecord WHERE @psxaccno=psxrecord.psxaccno and @compname=psxrecord.compname and @priceofshare=psxrecord.priceofshare)
					begin
						declare @tmp int
						SELECT @tmp=noofstocks FROM psxrecord WHERE  @psxaccno=psxrecord.psxaccno and @compname=psxrecord.compname and @priceofshare=psxrecord.priceofshare
						SET @tmp=@tmp+@noofstocks
						UPDATE psxrecord SET psxrecord.noofstocks=@tmp WHERE @psxaccno=psxrecord.psxaccno and @compname=psxrecord.compname and @priceofshare=psxrecord.priceofshare
						SET @output=1
					end
				else
					begin
						INSERT INTO psxrecord VALUES (@psxaccno,@noofstocks,@compname,@priceofshare)
						SET @output=1
					end
			end
		else
			begin
				SET @output=-1	-- psxcompany issue
			end
		end
	else
		begin
			SET @output=-2		-- psxacc issue
		end
end
go

select * from psxrecord
insert into psxrecord values(1,20,'bulls stock exchange',50)
---------
---------

create procedure checkpsxmarket
@regno int, -- psx registration no.
@msvom real,
@output int output
as
begin
	if exists ( SELECT * from psxcompany where psxcompany.regno=@regno)
		begin
			SET @output=1
			declare @dt date
			SET @dt=GETDATE()
			INSERT into psxmarket values(@regno,@msvom,@dt)
		end
	else
		begin
			SET @output=-1 -- company donot exist
		end
end
go
go

select * from psxcompany
INSERT INTO psxcompany values('00001','bulls stock exchange','Financial',30,20,10)
---------
---------


create procedure addbankaccount
@cnic nvarchar(15),
@bankname nvarchar(50),
@balance real,
@output int OUTPUT
as
begin
              if exists(select * from bank where cnic=@cnic)
				begin
					if exists( select * from bank where bank.cnic=@cnic and bank.bankname=@bankname)
						begin
							UPDATE bank SET bank.balance=bank.balance+@balance where bank.cnic=@cnic and bank.bankname=@bankname
							set @output=2
						end
					else
						begin
							SET @output=-2
						end
				 end
              else
				 begin
						if exists( select * from banks where @bankname=bankname)
							begin
								declare @tmp int
								if exists ( select * from bank where @bankname=bankname)
									begin
										SELECT @tmp=max(bankaccno) from bank where @bankname=bankname
										set @tmp=@tmp+1
									end
								else
									begin
										set @tmp=1
									end
								insert into bank values (@cnic,@tmp,@bankname,@balance)
								set @output=1
							end
						else
							begin
								set @output=-1 -- bank donot exists
							end
				end
end
go

---------
---------


Create proc addbank
@bankname nvarchar(50),
@output int output
as
begin
	If exists ( select * from banks where banks.bankname=@bankname)
		Begin
              Set @output=-1
		End
	Else
		Begin
              Insert into banks values (@bankname)
              set @output=1

		End
end
go


---------
---------

use KSIEGARNIA
go

drop proc if exists dodajPozycje
go

create procedure dodajPozycje
	@klientId uniqueidentifier,
	@ksiazkaId uniqueidentifier,
	@ilosc int
as

begin tran
begin try

	-- Sprawdz czy klient jest aktywny
	if (select aktywny from Klienci where klientId = @klientId) <> 1
		raiserror('Klient jest nieaktywny', 16, 1)

	-- Sprawdz czy ksi��ka jest dost�pna
	if not exists(select ksiazkaId from Ksiazki where ksiazkaId = @ksiazkaId and dostepnaIlosc >= @ilosc)
		raiserror('Wybrana ksi��ka nie jest obecnie dost�pna w wybranej ilo�ci', 16, 1)

	-- Sprawd� czy istnieje zam�wienie czekaj�ce na op�acenie
	if exists(select z.zamowienieId from 
				Sprzedaz sp join
				Zamowienia z on sp.zamowienieId = z.zamowienieId join
				Statusy st on z.statusId = st.statusId
			  where z.klientId = @klientId and st.statusNazwa = 'Z�o�one' and z.oplacone = 0)
		raiserror('Nie mo�na zlo�y� nowego zam�wienia bez op�acenia poprzedniego zam�wienia', 16, 1)

	-- Wyznacz id zam�wienia i okre�l czy jest to nowe zam�wienie
	declare @noweZamowienie bit = 0
	declare @zamowienieId uniqueidentifier

	select @zamowienieId = z.zamowienieId from 
		Zamowienia z join
		Statusy s on z.statusId = s.statusId
	where z.klientId = @klientId and s.statusNazwa = 'Nowe zam�wienie'

	if @zamowienieId = null
	begin
		set @zamowienieId = newid()
		set @noweZamowienie = 1
	end

	-- sprawdz czy na nowym zam�wieniu istnieje ju� pozycja z dan� ksi��k�
	declare @sprzedazId uniqueidentifier
	declare @nowaPozycja bit = 0

	if @noweZamowienie = 0
	begin
		select @sprzedazId = sp.sprzedazId from
			Sprzedaz sp 
		where sp.ksiazkaId = @ksiazkaId and sp.zamowienieId = @zamowienieId

		if @sprzedazId = null
		begin
			set @sprzedazId = newid()
			set @nowaPozycja = 1
		end
	end
	else
	begin
		set @sprzedazId = newid()
		set @nowaPozycja = 1
	end

	-- zapisz zam�wienie
	if @noweZamowienie = 1
		insert into Zamowienia values(
			@zamowienieId, 
			getdate(), 
			(select statusid from Statusy where statusNazwa = 'Nowe'), 
			@klientId, 
			(select max(nrZamowienia) from Zamowienia), 
			0
		)

	-- zapis pozycja
	declare @cena decimal(12, 2) = (select cena from Ksiazki where ksiazkaId = @ksiazkaId)

	if @nowaPozycja = 1
		insert into Sprzedaz values(
			@sprzedazId,
			@zamowienieId,
			@ksiazkaId,
			@ilosc,
			@cena * @ilosc
		)
	else
	begin
		declare @nowaIlosc int = (select ilosc + @ilosc from Sprzedaz where sprzedazId = @sprzedazId)

		update Sprzedaz set
			ilosc = @nowaIlosc,
			wartosc = @nowaIlosc * @cena
		where sprzedazId = @sprzedazId
	end

end try
begin catch
	select ERROR_MESSAGE() as Error
	if @@TRANCOUNT > 0  
        rollback
end catch

drop table if exists #kategorie

if @@TRANCOUNT > 0
	commit

go
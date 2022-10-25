use KSIEGARNIA
go

drop proc if exists dodajKsiazke
go

create procedure dodajKsiazke
	@tytul varchar(1024),
	@rokWydania int,
	@cena decimal(12,2),
	@dostepnaIlosc int,
	@oprawaTwarda bit,
	@nazwyKategorii varchar(max),
	@imieAutora varchar(128) = null,
	@nazwiskoAutora varchar(256) = null,
	@pseudonimAutora varchar(128) = null
as

begin tran
begin try
	-- pobranie id kategorii
	select * into #kategorie from string_split(@nazwyKategorii, ';')

	-- je�li nie istnieje taka kategoria to j� dodaj
	insert into Kategorie(nazwaKategorii)
		select a.value from #kategorie a where a.value not in(select nazwaKategorii from Kategorie)

	-- pobranie id autora
	declare @autor uniqueidentifier

	-- autor ma albo imie i nazwisko albo pseudonim 
	if @pseudonimAutora is null
	begin
		-- je�li nie istnieje taki autor to go dodaj
		if not exists(select autorId from Autorzy where imie = @imieAutora and nazwisko = @nazwiskoAutora)
			insert into Autorzy(imie, nazwisko) values (@imieAutora, @nazwiskoAutora)

		select @autor = autorId from Autorzy where imie = @imieAutora and nazwisko = @nazwiskoAutora
	end
	else
	begin
		-- je�li nie istnieje taki autor to go dodaj
		if not exists(select autorId from Autorzy where pseudonim = @pseudonimAutora)
			insert into Autorzy(pseudonim) values (@pseudonimAutora)

		select @autor = autorId from Autorzy where pseudonim = @pseudonimAutora
	end

	-- dodanie ksi��ki
	if exists(select ksiazkaId from Ksiazki where tytul = @tytul and autorId = @autor and 
											rokWydania = @rokWydania and oprawaTwarda = @oprawaTwarda)
		raiserror('Ksi��ka ju� istnieje w bazie danych', 16, 1)

	declare @ksiazka uniqueidentifier = newid()

	insert into Ksiazki(ksiazkaId, tytul, rokWydania, autorId, cena, dostepnaIlosc, oprawaTwarda) values
		(@ksiazka, @tytul, @rokWydania, @autor, @cena, @dostepnaIlosc, @oprawaTwarda)

	-- dodanie relacji ksi��ki i kategorii
	insert into KsiazkiKategorie(kategoriaId, ksiazkaId) 
		select k.kategoriaId, @ksiazka from Kategorie k where k.nazwaKategorii in(select t.value from #kategorie t)
	
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
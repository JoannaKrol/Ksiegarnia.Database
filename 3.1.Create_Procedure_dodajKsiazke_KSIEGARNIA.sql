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
	@nazwaKategorii varchar(128),
	@imieAutora varchar(128) = null,
	@nazwiskoAutora varchar(256) = null,
	@pseudonimAutora varchar(128) = null
as

begin tran
	-- pobranie id kategorii
	declare @kategoria uniqueidentifier

	-- jeœli nie istnieje taka kategoria to j¹ dodaj
	if not exists(select kategoriaId from Kategorie where nazwaKategorii = @nazwaKategorii) 
		insert into Kategorie(nazwaKategorii) values (@nazwaKategorii)

	select @kategoria = kategoriaId from Kategorie where nazwaKategorii = @nazwaKategorii

	-- pobranie id autora
	declare @autor uniqueidentifier

	-- autor ma albo imie i nazwisko albo pseudonim 
	if @pseudonimAutora is null
	begin
		-- jeœli nie istnieje taki autor to go dodaj
		if not exists(select autorId from Autorzy where imie = @imieAutora and nazwisko = @nazwiskoAutora)
			insert into Autorzy(imie, nazwisko) values (@imieAutora, @nazwiskoAutora)

		select @autor = autorId from Autorzy where imie = @imieAutora and nazwisko = @nazwiskoAutora
	end
	else
	begin
		-- jeœli nie istnieje taki autor to go dodaj
		if not exists(select autorId from Autorzy where pseudonim = @pseudonimAutora)
			insert into Autorzy(pseudonim) values (@pseudonimAutora)

		select @autor = autorId from Autorzy where pseudonim = @pseudonimAutora
	end

	-- dodanie ksi¹¿ki
	if exists(select ksiazkaId from Ksiazki where tytul = @tytul and autorId = @autor and 
											rokWydania = @rokWydania and oprawaTwarda = @oprawaTwarda)
	begin
		raiserror('Ksi¹¿ka ju¿ istnieje w bazie danych', 16, 1)
		rollback
		return
	end

	declare @ksiazka uniqueidentifier = newid()

	insert into Ksiazki(ksiazkaId, tytul, rokWydania, autorId, cena, dostepnaIlosc, oprawaTwarda) values
		(@ksiazka, @tytul, @rokWydania, @autor, @cena, @dostepnaIlosc, @oprawaTwarda)

	-- dodanie relacji ksi¹¿ki i kategorii
	insert into KsiazkiKategorie(kategoriaId, ksiazkaId) values (@kategoria, @ksiazka)

	commit
go
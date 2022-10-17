use KSIEGARNIA 
go

drop procedure if exists dodajKlienta
go

create procedure dodajKlienta 
	@imie varchar(128),
	@nazwisko varchar(128), 
	@plec char(1),
	@adresEmail varchar(128),
	@kraj varchar(64),
	@miasto varchar (128),
	@kodPocztowy char(6),
	@ulica varchar(256),
	@nrDomu varchar(16),
	@nrLokalu varchar(16) = null
as

begin tran

	-- Sprawdzenie czy podany adres email ju¿ istnieje
	if exists(select emailid from Emaile where adresEmail = @adresEmail)
	begin
		raiserror ('Podany adres email ju¿ istnieje', 16, 1) 
		rollback
		return
	end

	-- Sprawdzenien czy nie podano pustego stringa zamiast adresu
	if trim(@adresEmail) = '' 
	begin
		raiserror ('Nie podamno adresu email', 16, 1) 
		rollback
		return
	end

	-- Dodanie adresu email i statusu aktywnoœci (domyslnie na pocz¹tku zawsze aktywny)
	insert into Emaile( adresEmail, aktywny) values(@adresEmail, 1)

	-- Pobranie i przypisanie wartoœci id adresu email
	declare @Emailid uniqueidentifier
	select @Emailid = emailid from Emaile where adresEmail = @adresEmail

	-- Dodanie adresu
	insert into Adresy ( kraj, miasto, kodPocztowy, ulica, nrDomu, nrLokalu) values
						(@kraj, @miasto, @kodPocztowy,@ulica,@nrDomu,@nrLokalu)

	-- Pobranie i przypisanie id adresu
	declare @Adresid uniqueidentifier 
	select @Adresid = adresid from Adresy where
		kraj = @kraj and
		miasto = @miasto and
		kodPocztowy = @kodPocztowy and
		ulica = @ulica and
		nrDomu = @nrDomu and
		nrLokalu = @nrLokalu

	-- Nadanie numeru klienta dodawanemu klientowi
	declare @nrKlienta int
	select @nrKlienta = MAX(nrKlienta)+1 from Klienci

	-- Dodanie klienta
	insert into Klienci(imie, nazwisko, aktywny, dataAktywacji, plec, emailId, adresId, nrKlienta) values 
					   (@imie, @nazwisko, 0 , null, @plec, @Emailid, @Adresid, iif(@nrKlienta is null, 1, @nrKlienta)) 

	commit
go

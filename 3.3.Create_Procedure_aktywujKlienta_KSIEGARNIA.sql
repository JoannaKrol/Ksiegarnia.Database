use KSIEGARNIA
go

drop procedure if exists aktywujKlienta
go

create procedure aktywujKlienta (
	@klientId uniqueidentifier,
	@adresEmail varchar(128)
)
as
begin tran

	declare @komunikat varchar(128) 
	set @komunikat = dbo.sprawdzEmailKlienta (@klientId, @adresEmail)
	
	if @komunikat <> '' 
	begin
		raiserror (@komunikat, 16,1)
		rollback
		return
	end

	if (select k.aktywny from Klienci k where k.klientId = @klientId) = 1
	begin
		raiserror ('Klient jest ju¿ aktywny', 16, 1)
		rollback
		return
	end

	update dbo.Klienci set aktywny = 1, dataAktywacji = GETDATE() where klientId = @klientId

	if @@ERROR > 0
		rollback

	commit
go
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
begin try
	declare @komunikat varchar(128) 
	set @komunikat = dbo.sprawdzEmailKlienta (@klientId, @adresEmail)
	
	if @komunikat <> ''
		raiserror(@komunikat, 16,1)

	if (select k.aktywny from Klienci k where k.klientId = @klientId) = 1
		raiserror ('Klient jest ju¿ aktywny', 16, 1)

	update dbo.Klienci set aktywny = 1, dataAktywacji = GETDATE() where klientId = @klientId
end try
begin catch
	select ERROR_MESSAGE() as Error
	if @@TRANCOUNT > 0  
        rollback
end catch

if @@TRANCOUNT > 0
	commit

go
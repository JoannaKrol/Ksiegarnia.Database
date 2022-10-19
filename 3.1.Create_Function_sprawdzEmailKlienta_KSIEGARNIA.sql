use KSIEGARNIA
go

drop function if exists sprawdzEmailKlienta
go

create function sprawdzEmailKlienta (
	@klientId uniqueidentifier,
	@adresEmail varchar(128)
)
returns varchar(128)
as
begin
	if not exists(select * from Klienci k join Emaile e on k.emailId = e.emailId 
			where k.klientId = @klientId and adresEmail = @adresEmail)
		return 'B³êdny adres email lub Id u¿ywkownika'

	if (select e.aktywny from Emaile e where e.adresEmail = @adresEmail) = 0 
		return 'Email nieaktywny' 

	return ''
end
go

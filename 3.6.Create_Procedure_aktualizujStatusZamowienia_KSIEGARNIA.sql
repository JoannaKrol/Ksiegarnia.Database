use KSIEGARNIA
go

drop proc if exists aktualizujStatusZamowienia
go

create procedure aktualizujStatusZamowienia
	@zamowienieId uniqueidentifier,
	@nowyStatus varchar(128)
as

begin tran
begin try

	declare @staryStatus varchar(128)
	declare @oplacone bit

	select 
		@staryStatus = s.statusNazwa, 
		@oplacone = z.oplacone 
	from 
		Statusy s join 
		Zamowienia z on s.statusId = z.statusId 
	where 
		z.zamowienieId = @zamowienieId

	-- roboczo poniewa¿ brakuje sprawdzeñ dostêpnoœci ksi¹zek i aktualizacji dla zmiany na "Z³o¿one"
	if @staryStatus = 'Nowe'        and @nowyStatus = 'Anulowane'   or
	   @staryStatus = 'Nowe'        and @nowyStatus = 'Z³o¿one'     or
	   @staryStatus = 'Z³o¿one'     and @nowyStatus = 'Realizowane' and @oplacone = 1 or
	   @staryStatus = 'Realizowane' and @nowyStatus = 'Wys³ane'     or
	   @staryStatus = 'Wys³ane'     and @nowyStatus = 'Zrealizowane'
		update Zamowienia set statusId = (select statusId from Statusy where statusNazwa = @nowyStatus)
	else
		raiserror('Niedopuszczalna konfiguracja', 16, 1)

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
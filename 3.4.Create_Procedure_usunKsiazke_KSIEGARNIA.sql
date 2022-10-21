use KSIEGARNIA
go

drop procedure if exists usunKsiazke
go

create procedure usunKsiazke (
	@ksiazkaId uniqueidentifier
)
as
begin tran
begin try
	if not exists(select * from Ksiazki where ksiazkaId = @ksiazkaId)
		raiserror ('Ksi¹¿ka o podanym id nie istnieje', 16, 1)

	declare @kategoriaId uniqueidentifier
	declare @autorId uniqueidentifier

	-- pobierz autora ksi¹¿ki
	select @autorId = autorId from Ksiazki where ksiazkaId = @ksiazkaId

	-- pobierz kategorie ksi¹¿ki
	select kategoriaId into #kategorie from KsiazkiKategorie where ksiazkaId = @ksiazkaId

	-- usuñ ksi¹¿kê oraz powi¹zania ksi¹¿ki z kategoriami
	delete from KsiazkiKategorie where ksiazkaId = @ksiazkaId
	delete from Ksiazki where ksiazkaId = @ksiazkaId

	-- je¿eli autor nie ma ¿adnej ksi¹¿ki to go usuñ
	if not exists(select * from Ksiazki where autorId = @autorId)
		delete from Autorzy where autorId = @autorId

	-- usuñ kategorie które by³y powi¹zane z usuniêt¹ ksi¹¿k¹ i nie maj¹ powi¹zañ z innymi ksi¹¿kami
	delete from Kategorie where kategoriaId in(
		select kategoriaId from #kategorie
		except
		select kategoriaId from KsiazkiKategorie
	)

	drop table #kategorie
	
end try
begin catch
	select ERROR_MESSAGE() as Error
	drop table if exists #kategorie
	if @@TRANCOUNT > 0  
        rollback
end catch

if @@TRANCOUNT > 0
	commit

go
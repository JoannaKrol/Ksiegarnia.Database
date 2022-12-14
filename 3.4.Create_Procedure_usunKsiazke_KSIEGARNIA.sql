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
		raiserror ('Ksi??ka o podanym id nie istnieje', 16, 1)

	declare @kategoriaId uniqueidentifier
	declare @autorId uniqueidentifier

	-- pobierz autora ksi??ki
	select @autorId = autorId from Ksiazki where ksiazkaId = @ksiazkaId

	-- pobierz kategorie ksi??ki
	select kategoriaId into #kategorie from KsiazkiKategorie where ksiazkaId = @ksiazkaId

	-- usu? ksi??k? oraz powi?zania ksi??ki z kategoriami
	delete from KsiazkiKategorie where ksiazkaId = @ksiazkaId
	delete from Ksiazki where ksiazkaId = @ksiazkaId

	-- je?eli autor nie ma ?adnej ksi??ki to go usu?
	if not exists(select * from Ksiazki where autorId = @autorId)
		delete from Autorzy where autorId = @autorId

	-- usu? kategorie kt?re by?y powi?zane z usuni?t? ksi??k? i nie maj? powi?za? z innymi ksi??kami
	delete from Kategorie where kategoriaId in(
		select kategoriaId from #kategorie
		except
		select kategoriaId from KsiazkiKategorie
	)
	
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
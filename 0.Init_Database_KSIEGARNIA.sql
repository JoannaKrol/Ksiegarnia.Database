use master

declare @execute bit = 0

if @execute = 1
begin
	drop database if exists KSIEGARNIA

	create database KSIEGARNIA
end
else 
begin
	raiserror('Nie utworozno bazy danych. Warto�� zmiennej @Execute = 0. Zmie� warto�� na 1 i uruchom ponownie.', 16, 1)
end
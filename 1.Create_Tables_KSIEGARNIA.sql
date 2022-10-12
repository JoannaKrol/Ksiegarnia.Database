
-- UWAGA! 
-- Przed uruchomieniem skryptu nale¿y przygotowaæ now¹ bazê danych. Domyœlna nazwa KSIEGARNIA

use KSIEGARNIA

-- Tabele
create table Ksiazki (
	ksiazkaId uniqueidentifier primary key default newid(),
	tytul varchar(1024) not null,
	rokWydania int,
	autorId uniqueidentifier not null,
	cena decimal(12, 2)  not null, check(dostepnaIlosc > 0),
	dostepnaIlosc int not null check(dostepnaIlosc >= 0),
	oprawaTwarda bit not null
)

create table Autorzy (
	autorId uniqueidentifier primary key default newid(),
	imie varchar(128),
	nazwisko varchar(256),
	pseudonim varchar(128) --check (pseudonim is not null or (imie is not null and nazwisko is not null))
)

create table Kategorie (
	kategoriaId uniqueidentifier primary key default newid(),
	nazwaKategorii varchar(128) not null
)

create table KsiazkiKategorie (
	ksiazkaKategoriaId uniqueidentifier primary key default newid(), 
	ksiazkaId uniqueidentifier not null,
	kategoriaId uniqueidentifier not null
)

create table Adresy (
	adresId uniqueidentifier primary key default newid(),
	kraj varchar(64) not null,
	miasto varchar(128) not null,
	kodPocztowy char(6) not null,
	ulica varchar(256) not null,
	nrDomu varchar(16) not null,
	nrLokalu varchar(16)
)

create table Emaile (
	emailId uniqueidentifier primary key default newid(),
	adresEmail varchar(128) unique not null,
	aktywny bit not null
)

create table Statusy (
	statusId uniqueidentifier primary key default newid(),
	statusNazwa varchar(128) unique not null
)

create table Klienci(
	klientId uniqueidentifier primary key default newid(),
	imie varchar(128) not null,
	nazwisko varchar(128) not null,
	adresId uniqueidentifier not null,
	nrKlienta int unique not null,
	emailId uniqueidentifier not null,
	aktywny bit not null,
	dataAktywacji datetime2 not null,
	plec char(1) not null 
)

create table Zamowienia(
	zamowienieId uniqueidentifier primary key default newid(),
	dataZamowienia datetime2 not null,
	statusId uniqueidentifier not null,
	klientId uniqueidentifier not null,
	nrZamowienia int unique not null,
	oplacone bit
)

create table Sprzedaz (
	sprzedazId uniqueidentifier primary key default newid(),
	zamowienieId uniqueidentifier not null,
	ksiazkaId uniqueidentifier not null,
	ilosc int not null,
	wartosc decimal(12,2) not null
)

-- Indeksy do tabel
create nonclustered index idx_pseudonim on Autorzy(pseudonim)
create nonclustered index idx_nazwiskoImie on Autorzy(nazwisko, imie)
create nonclustered index idx_tytul on Ksiazki(tytul)
create nonclustered index idx_autorId on Ksiazki(autorId)
create nonclustered index idx_cena on Ksiazki(cena)
create nonclustered index idx_nazwaKategorii on Kategorie(nazwaKategorii) 
create nonclustered index idx_kategoriaIdksiazkaId on KsiazkiKategorie (kategoriaId, ksiazkaId)
create nonclustered index idx_adresId on Klienci(adresId)
create nonclustered index idx_emailId on Klienci(emailId)
create nonclustered index idx_nrKlienta on Klienci(nrKlienta)
create nonclustered index idx_dataZamowienia on Zamowienia(dataZamowienia)
create nonclustered index idx_statusId on Zamowienia(statusId)
create nonclustered index idx_klientid on Zamowienia(klientid)
create nonclustered index idx_nrZamowienia on Zamowienia(nrZamowienia)
create nonclustered index idx_oplacone on Zamowienia(oplacone)
create nonclustered index idx_zamowienieId on Sprzedaz (zamowienieId)
create nonclustered index idx_ksiazkaId on Sprzedaz (ksiazkaId)
create nonclustered index idx_wartosc on Sprzedaz (wartosc)

-- Klucze obce
alter table Ksiazki add foreign key (autorId) references Autorzy(autorId)
alter table KsiazkiKategorie add foreign key (ksiazkaId) references Ksiazki (ksiazkaId)
alter table KsiazkiKategorie add foreign key (kategoriaId) references Kategorie (kategoriaId)
alter table Klienci add foreign key (adresId) references Adresy(adresId) 
alter table Klienci add foreign key (emailId) references Emaile(emailId) 
alter table Zamowienia add foreign key (statusId) references Statusy (statusId)
alter table Zamowienia add foreign key (klientId) references Klienci (klientId) 
alter table Sprzedaz add foreign key (zamowienieId) references Zamowienia (zamowienieId)
alter table Sprzedaz add foreign key (ksiazkaId) references Ksiazki(ksiazkaId) 

-- ograniczenia
alter table Klienci add constraint plecSlownik check(plec in('K', 'M', 'N'))
alter table Autorzy add constraint pseudonimLubImieNazwisko check(pseudonim is not null or (imie is not null and nazwisko is not null))




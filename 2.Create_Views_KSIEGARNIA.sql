use KSIEGARNIA
go

drop view if exists ksiazki_view
go
drop view if exists Zamowienia_view
go
drop view if exists ZamowieniaSzczegoly_view
go
drop view if exists Klienci_view
go

create view ksiazki_view as
select 
	k.ksiazkaId, k.tytul, k.rokWydania, k.cena, k.dostepnaIlosc, 
	case 
		when k.oprawaTwarda=0 then 'Oprawa miêkka'
		else 'Oprawa twarda'
	end as oprawa, 
	a.autorId, 
	a.imie, a.nazwisko, a.pseudonim, 
	case
		when a.imie is null and a.nazwisko is null then a.pseudonim
		else a.imie + ' ' + a.nazwisko
	end as autor,
	ka.nazwaKategorii
from 
  Ksiazki k join 
  Autorzy a on k.autorId = a.autorId join
  KsiazkiKategorie kk on kk.ksiazkaId = k.ksiazkaId join 
  Kategorie ka on ka.kategoriaId = kk.kategoriaId 
go

create view Zamowienia_view as
select z.zamowienieId, z.nrZamowienia, z.dataZamowienia, z.klientId,
	CASE 
		WHEN z.oplacone = 0 THEN 'nieop³acone' 
		ELSE 'op³acone' 
	END as oplacone,
	s.statusNazwa, SUM(sp.wartosc) as wartoscZamowienia
from Zamowienia z JOIN
	Statusy s ON z.statusId = s.statusId JOIN
	Sprzedaz sp ON sp.zamowienieId = z.zamowienieId 
group by z.zamowienieId, z.nrZamowienia, z.dataZamowienia, z.klientId, s.statusNazwa,
	CASE
		WHEN z.oplacone = 0 THEN 'nieop³acone' 
		ELSE 'op³acone' 
	END
go

create view ZamowieniaSzczegoly_view as
select z.zamowienieId, z.nrZamowienia, z.dataZamowienia, z.klientId, 
	CASE
		WHEN z.oplacone = 0 THEN 'nieop³acone' 
		ELSE 'op³acone' 
	END as oplacone,
	s.statusNazwa, k.ksiazkaId, k.tytul, k.cena, sp.ilosc, sp.wartosc
from Zamowienia z JOIN
	Statusy s ON z.statusId = s.statusId JOIN
	Sprzedaz sp ON sp.zamowienieId = z.zamowienieId JOIN
	Ksiazki k ON k.ksiazkaId = sp.ksiazkaId 

go

create view Klienci_view as
select k.klientId, k.nrKlienta, k.imie, k.nazwisko,
	CASE
		when k.plec = 'M' then 'mê¿czyzna' 
		when k.plec = 'K' then 'kobieta'
		else 'nieokreœlona'
	end as klientPlec,
	CASE 
		when k.aktywny = 0 then 'nieaktywny' 
		else 'aktywny'
	end as klientAktywny,
	k.dataAktywacji, e.adresEmail,
	CASE 
		when e.aktywny = 0 then 'nieaktywny' 
		else 'aktywny'
	end as emailAktywny, 
	A.kraj, A.miasto, A.kodPocztowy, A.ulica, A.nrDomu, A.nrLokalu
from Klienci k JOIN 
	Adresy A ON A.adresId = k.adresId JOIN
	Emaile e ON e.emailId = k.emailId 

go
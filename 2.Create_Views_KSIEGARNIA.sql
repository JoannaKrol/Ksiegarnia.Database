use KSIEGARNIA
go

drop view if exists Ksiazki_view
go
drop view if exists Zamowienia_view
go
drop view if exists ZamowieniaSzczegoly_view
go
drop view if exists Klienci_view
go
drop view if exists AktywneZamowienia_view
go
drop view if exists StatystykaSprzedazy_view
go
drop view if exists AktywniKlienci_view
go
drop view if exists StatystykaSprzedazyKsiazek_view
go
drop view if exists StatystykaMiast_view
go


create view Ksiazki_view as
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


create view AktywneZamowienia_view as
select k.klientId, k.nrKlienta, k.imie, k.nazwisko, k.klientPlec, k.klientAktywny,
	k.dataAktywacji, k.adresEmail, k.emailAktywny,
	k.kraj, k.miasto, k.kodPocztowy, k.ulica, k.nrDomu, k.nrLokalu,
	z.zamowienieId, z.nrZamowienia, z.dataZamowienia,
	CASE
		when z.oplacone = 1 then 'op³acone'
		else 'nieop³acone'
	end as czyZamowienieJestOplacone,
	s.statusNazwa [status]
from Klienci_view k JOIN
	Zamowienia z on z.klientId = k.klientId JOIN
	Statusy s on s.statusId = z.statusId
where s.statusNazwa not in('Zrealizowane', 'Anulowane') 
go


create view StatystykaSprzedazy_view as
select 
	MONTH(z.dataZamowienia) + '/' + YEAR(z.dataZamowienia) as okres, 
	SUM(s.ilosc) iloscKsiazek, 
	SUM(s.wartosc) lacznaWartosc
from 
	Zamowienia z JOIN 
	Sprzedaz s on z.zamowienieId = s.zamowienieId
group by 
	MONTH(z.dataZamowienia) + '/' + YEAR(z.dataZamowienia)
go


create view AktywniKlienci_view as
select  
	MONTH(k.dataAktywacji) + '/' + YEAR(k.dataAktywacji) okres, 
	COUNT(k.klientId) liczbaNowychKlientow
from Klienci k 
where k.aktywny = 1
group by 
	MONTH(k.dataAktywacji) + '/' + YEAR(k.dataAktywacji)
go


create view StatystykaSprzedazyKsiazek_view as
select 
	MONTH(z.dataZamowienia) + '/' + YEAR(z.dataZamowienia) as okres,
	k.ksiazkaId, k.tytul, 
	SUM(s.ilosc) as iloscSprzedanychKsiazek, 
	SUM(s.wartosc) as wartoscSprzedanychKsiazek,
	k.rokWydania, kat.nazwaKategorii, a.autorId, a.imie, a.nazwisko, a.pseudonim
from 
	Ksiazki k JOIN
	Sprzedaz s on s.ksiazkaId=k.ksiazkaId JOIN
	Zamowienia z on z.zamowienieId=s.zamowienieId JOIN
	Autorzy a on a.autorId=k.autorId JOIN
	KsiazkiKategorie ksk on k.ksiazkaId= ksk.ksiazkaId JOIN
	Kategorie kat on kat.kategoriaId=ksk.kategoriaId
group by 
	k.ksiazkaId, k.tytul,k.rokWydania, kat.nazwaKategorii, a.autorId, a.imie, a.nazwisko, a.pseudonim, 
	MONTH(z.dataZamowienia) + '/' + YEAR(z.dataZamowienia)
go


create view StatystykaMiast_view as
select a.miasto, 
	COUNT(k.klientId) as liczbaKlientow, 
	SUM(s.wartosc) as wartoscZamowien, 
	SUM(s.ilosc) as iloscZamowionychKsiazek
from Klienci k JOIN
	Adresy a on a.adresId=k.adresId join
	Zamowienia z on z.klientId=k.klientId join
	Sprzedaz s on z.zamowienieId=s.zamowienieId
where k.aktywny = 1
group by a.miasto
go
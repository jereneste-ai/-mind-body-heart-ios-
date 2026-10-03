# Addis — erillinen iPhone-sovellus

Addis on erillinen SwiftUI-sovellus. Suunniteltu tilaus maksaa 9,99 €/kk. Tilausmaksaminen ja StoreKit-ostot eivät vielä ole toteutettu. Oma Xcode-kohde `Adis`, näyttönimi `Addis`, bundle ID `fi.jereneste.adis`. Ei Hyvinn-riippuvuutta. Vanha sisäinen kohteen nimi ja tunniste säilyvät päivitysten jatkuvuuden vuoksi.

## Päivitys 3.10.2026, build 334

- Addis-nimi ja ”Moi, mitä sinulle kuuluu?” aloitusnäkymässä.
- Jokaisella 12 polkutehtävällä oma tallennettava ja poistettava muistiinpano.
- Päiväkirja avautuu kirjakuvakkeesta tai aloitusnäkymästä. Neljä kenttää: tämänhetkinen olo, mikä auttoi, tuen tarve, seuraava askel. Päivättyjen merkintöjen tallennus, avaaminen, muokkaus ja poisto.
- Merkinnät tallennetaan painikkeesta laitteen Application Support -hakemistoon atomisesti ja iOS:n täydellä tiedostosuojauksella. Hakemisto ei kuulu laitevarmuuskopioihin. Ei pilvisynkronointia tai verkkoversion tietojen siirtoa.
- Aiempien viiden välilehden toiminta säilyy. Tukikortti, viikkotekstit ja vapaaehtoinen kirjoitusharjoitus ovat edelleen istuntokohtaisia; vain uudet tehtävämuistiinpanot ja päiväkirja säilyvät tallennuksen jälkeen.

## Kielten ja verkkoversion ero

Tässä natiiviversiossa on FI, EN, SV, NB ja ET. Verkkoversiossa on 21 kieltä ja laajempi harjoituskokoelma. Natiiviversion 16 muun kielen ja sisällön täydellinen vastaavuus ei vielä ole toteutettu. Käännöksiä ei ole ammattimaisesti kielitarkistettu.

## Käännös ja julkaisu

`.github/workflows/adis-ios.yml` kääntää simulaattoriversion. `adis-release.yml` tekee allekirjoittamattoman iPhone-arkiston. Onnistunutkaan arkisto ei ole TestFlight-julkaisu eikä asennettavissa iPhoneen sellaisenaan.

TestFlight vaatii Apple-tiimin allekirjoituksen, sovellustietueen App Store Connectiin ja allekirjoitetun arkiston viennin/lähetyksen. Salaisia avaimia ei tallenneta tähän repositorioon. Nykyinen bundle ID on tarkistettava Apple-tilillä ennen lähettämistä. Testaa fyysisellä iPhonella tallennus ja uudelleenkäynnistys, poisto, kielenvaihto, suuret tekstit, VoiceOver sekä tukilinkit ennen ulkoista testausta.

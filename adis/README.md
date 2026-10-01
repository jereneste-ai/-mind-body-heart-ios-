# Adis iPhone 333 – lähdekoodi

Tämä on yksi SwiftUI-sovellus, jossa on käyttöliittymä suomeksi, englanniksi, ruotsiksi, norjan bokmåliksi ja viroksi. Sen viisi välilehteä ovat **Juuri nyt**, **Oma suunnitelma**, **Keinot**, **Oma polku** ja **Tuki**. Oma polku sisältää kolme käyttäjän valittavaa vaihetta: alkumetrit, uuden arjen rakentaminen ja uusi tavoite. Vaiheet ovat sisältönäkymiä, eivät paranemisaikatauluja tai ihmisarvon tasoja.

Juuri nyt -näkymässä on retkahduksen jälkeinen erillinen tukikortti, helppo siirtyminen ihmisen tuen välilehteen ja vapaaehtoinen seuraava teko. Keinot-välilehdellä on lyhyitä harjoituksia ja ajastin. Oma polku säilyttää valitun vaiheen ja kokeillut askeleet laitteen paikallisissa asetuksissa. Oma viikko antaa tilaa tärkeälle asialle, pienelle teolle, levolle ja ihmiselle, jolta pyytää apua. Lisäksi mukana on vapaaehtoinen 21 päivän arjen kokeilu ilman nollautuvaa putkea.

Sovellus ei vaadi tiliä, sisällä mainoksia tai lähetä tukikortin tekstiä omalle palvelimelle. Tukikortti, Oma viikon tekstit ja kirjoitus pysyvät istunnon muistissa; käyttäjä voi itse avata iOS:n jakoikkunan. Kieli, valittu vaihe, vaihemerkinnät ja 21 päivän kokeilun numerot säilyvät paikallisesti. Merkinnöille ja istunnon teksteille on poistopainike. Ulkoiset tukilinkit ovat palveluntarjoajien omia sivuja.

## Avaaminen ja tarkistaminen

1. Avaa `Adis.xcodeproj` Macin Xcodessa. Projektin käyttöönoton tavoite on iOS 17 tai uudempi.
2. Valitse oma Apple-tiimi kohdassa Signing & Capabilities. Vaihda `fi.jereneste.adis` tarvittaessa tilillesi vapaaseen Bundle Identifieriin.
3. Käännä Debug-versio ja testaa fyysisellä iPhonella suomen ja englannin välilehdet, retkahdusnäkymä, tukipuhelujen avautuminen, ajastin, tukikortin jako ja tyhjennys, Oma viikko sekä polun merkintöjen säilyminen käynnistysten välillä.
4. Testaa VoiceOver, tekstin suurennus, pienet näytöt ja käyttö ilman verkkoyhteyttä. Tarkista kaikkien tukipalvelujen tiedot ennen julkaisua.
5. Hanki päihde- ja riippuvuustyön ammattilaisen sekä kokemusasiantuntijoiden sisältöarvio. Päivitä ja julkaise tietosuojaseloste julkisessa osoitteessa ennen kauppaan lähettämistä.
6. Tee Release-arkisto, testaa TestFlightissa ja täytä App Store Connectin ilmoitukset nykyisen toteutuksen mukaisesti.

Tätä pakettia **ei ole käännetty eikä testattu iPhonella tässä ympäristössä**, koska Xcode ja iOS-simulaattori eivät ole saatavilla. Koodi on lähdepaketti, ei allekirjoitettu julkaisuversio eikä App Store -hyväksyntä. Käyttöliittymän tukitekstit vaativat ammatillisen arvioinnin ennen laajaa jakelua.

## Tukipalvelujen tarkistettavat lähteet

- EHYT Päihdeneuvonta: https://ehyt.fi/selkokieli/mista-saa-apua/
- Peluuri: https://www.peluuri.fi/
- Päivystysapu: https://www.116117.fi/

Suomen ulkopuolella sovellus ohjaa paikallisten palvelujen äärelle. Sovellus ei tarjoa vieroitusohjeita eikä valvo käyttäjän vointia.

Katso ajantasainen lähetyslista tiedostosta JULKAISU-TILANNE.md. Mukana oleva Mac-pilvityönkulku tekee allekirjoittamattoman simulaattorikäännöksen, ei App Store -lähetystä.

Kielilisäys: katso KIELITARKISTUS.md. Uudet kielet on tarkistettava äidinkielisesti ja testattava laitteella ennen kauppajulkaisua.

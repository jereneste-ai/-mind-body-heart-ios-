# Adis 333 — App Store -valmistelu

Päivitetty 1.10.2026. Tämä on lähdekoodipaketti, ei allekirjoitettu IPA eikä Applelle lähetetty sovellus.

## Valmisteltu
- SwiftUI iPhone-sovellus; iOS 17 tai uudempi; suomi, englanti, ruotsi, norjan bokmål ja viro.
- Versio 333.0.0, koontinumero 333; Bundle ID fi.jereneste.adis (vahvistettava Apple-tilillä).
- Mieliteon ja retkahduksen tukinäkymät, tukikortti, harjoitukset, oma polku, oma viikko ja ihmisen tuki.
- Ajastimen uudelleenkäynnistys korjattu; kansainväliset päihde- ja rahapelitukilinkit lisätty.
- App Store -tekstiluonnokset, kuvake ja tietosuojamanifesti mukana.
- GitHub Actions -työnkulku voi kääntää simulaattoriversion Mac-pilvessä. Työnkulkua ei ole ajettu. Se ei allekirjoita eikä lähetä sovellusta Applelle.

## Lähetyksen edellytykset
1. Vahvista aktiivinen Apple Developer -jäsenyys ja App Store Connect -sovellustietue. Säilytä jo rekisteröity Bundle ID, jos tietue on olemassa.
2. Käännä ja testaa Xcodessa tai Mac-pilvessä. Tarkista suomi/englanti, puhelulinkit, VoiceOver, tekstin suurennus, offline-käyttö, ajastin, jakaminen ja merkintöjen poisto.
3. Valitse kehittäjätiimi, tee allekirjoitettu Release-arkisto ja lähetä App Store Connectiin. Käytä turvallista allekirjoitusasetusta; älä lisää avaimia tai salasanoja lähdekoodiin tai chattiin.
4. Julkaise iPhone-version toteutusta vastaava tietosuojasivu ja tukisivu. Verkkoversion tallennus eroaa iPhone-versiosta: iPhone-version kirjoitetut tekstit ovat istuntomuistissa.
5. Lisää aidot laitekuvakaappaukset, tarkista ikäluokitus, tietosuojailmoitus, jakelualueet ja yhteystiedot. Lisää App Review -yhteyshenkilö tilillä.
6. Testaa koonti TestFlightissa ja lähetä App Review -arvioon. Apple päättää hyväksynnästä ja julkaisuajasta.

## Hinta
Sovelluksessa ei ole StoreKit-tilausta tai ostojen palautusta. Älä ilmoita yhden kuukauden kokeilua tai 4,99 €/kk tilausta toimivaksi ennen maksutoiminnon toteutusta ja testausta. Ensimmäinen koonti on nykyisen toteutuksen mukaisesti maksuton.

## Julkaisun nykytila
Linux-ympäristössä ei ole Xcodea tai iOS-simulaattoria. Tätä versiota ei ole käännetty, allekirjoitettu, ajettu iPhonella tai lähetetty Applelle. Sisältöä ei ole vahvistettu ammattilaisen arvioimaksi. Paketti mahdollistaa seuraavan käännös- ja tarkistusvaiheen.

App Store Connect: https://appstoreconnect.apple.com/
Apple Developer: https://developer.apple.com/account/

Kielilisäys: katso KIELITARKISTUS.md. Uudet kielet on tarkistettava äidinkielisesti ja testattava laitteella ennen kauppajulkaisua.

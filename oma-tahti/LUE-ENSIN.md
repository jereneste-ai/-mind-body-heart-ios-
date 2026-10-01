# Oma Tahti 1.0 — mobiililähdekoodi

Tämä on valmisteltu iOS- ja Android-lähdekoodipaketti. Se EI ole allekirjoitettu IPA/AAB, eikä sitä ole lähetetty kauppaan. Natiivikäännöstä tai laitetestausta ei ole vielä tehty.

Pohja: nykyinen Oma Tahti — yhdeksän arjen työkalua, lähdecommit 6eb7d2148d13b82aa3ffc550896606c1a1fda86e. Verkkoversio säilyy osoitteessa https://oma-tahti-yhdeksan.jereneste.chatgpt.site.

## Mukana

- Fysis, Mielis, Ruokis, Adis, 111 %, Oppis, Työlis, Tunnis ja Tukis nykyisine harjoituksineen.
- Paikalliset merkinnät, oma viikko, taukoajastin ja Adiksen turvasuunnitelma.
- Sisältö mukana sovelluksessa: ydintoiminnot eivät tarvitse verkkoa.
- iOS: tietojen vienti järjestelmän jakovalikolla. Android: JSON-tiedoston tallennus tiedostovalitsimella.
- Ulkoiset tuki- ja puhelinlinkit avautuvat laitteen omissa sovelluksissa.
- App-kuvakkeet ja käännöstarkistuksen GitHub Actions -työnkulku.

Ei käyttäjätiliä, maksujärjestelmää, pilvisynkronointia tai seurantaa. Tässä paketissa ei toteuteta aiemmin pohdittua 4,99 €/kk tilausta tai ilmaista kokeilua. Kaupan hinnoittelua ei ole muutettu. Sisältö on suomeksi.

## iPhone / iPad

Macissa tarvitaan Xcode ja XcodeGen. Aja `brew install xcodegen`, sitten `cd ios && xcodegen generate`. Avaa syntyvä OmaTahti.xcodeproj. Valitse kehittäjätilisi Team kohdassa Signing & Capabilities. Tarkista tunniste com.jereneste.omatahti ja vaihda se tarvittaessa tilisi rekisteröityyn tunnisteeseen.

Testaa laitteella, valitse Product → Archive ja Distribute App → App Store Connect. Lisää App Store Connectiin sovellus ja lähetä käsitelty build tarkastukseen metatietojen valmistuttua.

Ilman omaa Macia: vie tämän ZIPin SISÄLTÖ GitHub-repositorion juureen. Mukana oleva työnkulku voi tehdä iOS-simulaattorikäännöksen pilvessä. Se ei tee iPhoneen asennettavaa tai kauppaan lähetettävää IPAa. Allekirjoitettu julkaisu vaatii erikseen Macin, macOS-pilvikäännöksen tai kehittäjän ja Apple-tilin allekirjoitusasetukset. Avaimia tai salasanoja ei pidä tallentaa tähän projektiin.

## Android

Avaa android-kansio Android Studiossa. Käytä JDK 17:ää, Gradle 8.13:a ja SDK 36:ta. Gradle wrapper ei sisälly pakettiin; Android Studio voi luoda sen tai asennetulla Gradlella voi ajaa `gradle wrapper --gradle-version 8.13`.

Debug: `gradle :app:assembleDebug`. Julkaisu: Build → Generate Signed App Bundle / APK → Android App Bundle. Käytä omaa upload-avainta ja pidä se tallessa turvallisesti. Pelkkä `gradle :app:bundleRelease` tuottaa tässä projektissa allekirjoittamattoman AAB:n, jota ei voi lähettää sellaisenaan.

## Ennen tarkastukseen lähettämistä

1. Natiivikäännös ja oikean laitteen testaus molemmilla alustoilla. Testaa kaikki yhdeksän työkalua, lentotila, tallennuksen säilyminen uudelleenkäynnistyksessä, vienti, poistamisen vahvistus, takaisin-navigointi, kääntö, näppäimistö ja suurempi teksti.
2. Tarkista ammattilaisen kanssa terveyteen liittyvät sisällöt. Nykyinen sovellus ilmoittaa ammattilaisarvion olevan tekemättä.
3. Tietosuojaseloste: https://oma-tahti-yhdeksan.jereneste.chatgpt.site/tietosuoja.html. Tukisivu: https://oma-tahti-yhdeksan.jereneste.chatgpt.site/tuki.html. Tarkista vastaavuus lopulliseen mobiiliversioon ennen kauppalähetystä.
4. Lisää oikeasta sovelluksesta otetut kuvakaappaukset sekä kauppojen ikäraja-, terveysisältö- ja tietosuojavastaukset. Vastaa toteutuneen buildin perusteella.
5. Päätä hinnoittelu. Tässä ei ole tilausta. Maksullinen kuukausitilaus vaatii erillisen kauppojen ostojärjestelmään liitetyn toteutuksen ja testit.
6. Tee allekirjoitettu build ja lähetä kehittäjätililtä. Kaupat päättävät hyväksynnästä. Apple edellyttää hyödyllistä sovellustoiminnallisuutta; offline- ja vientitoiminnot eivät takaa hyväksyntää.

Verkkoselaimen vanhoja merkintöjä ei siirretä automaattisesti mobiilisovellukseen. Vienti sisältää mahdollisesti arkaluonteista tietoa; käyttäjä valitsee itse tallennus- tai jakopaikan. Android-varmuuskopio on poistettu käytöstä; iOS:n laitteen varmuuskopio voi sisältää sovelluksen paikallisia tietoja. Poistaminen sovelluksessa ei poista aiemmin vietyjä kopioita.

## Viralliset ohjeet

- https://developer.apple.com/app-store/review/guidelines/
- https://developer.apple.com/help/app-store-connect/
- https://developer.android.com/google/play/requirements/target-sdk
- https://developer.android.com/studio/publish/app-signing

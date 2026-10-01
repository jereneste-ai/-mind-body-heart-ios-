# Tarkistuksen tulos 1.10.2026

Lähdekooditasolla tarkistettu: yhdeksän työkalun renderöinti simuloidulla DOMilla; havaintojen tallennus ja poisto; HTML-erikoismerkkien suojaus; tallennusvirheen ilmoitus; natiiviviennin JavaScript-kutsu; kaikkien paikallisten tietojen poisto; alustojen web-sisällön yhtenäisyys. YAML-, plist-, JSON- ja Android-manifestin rakenne läpäisi jäsennystarkistuksen.

Ei tarkistettu: Swift/Java-käännös, XcodeGen-projektin generointi, Gradle-build, GitHub Actions -ajot, oikean selaimen ulkoasu, iPhone/iPad/Android-laitteiden toiminta, oikea natiivivienti, allekirjoitus tai kauppalähetys. Pilvikäännöstyönkulku on valmisteltu mutta sitä ei ole ajettu.

Paketti on lähdekoodin valmistelutulos. Julkaisuvalmiutta ei voi vahvistaa ennen natiivikäännöstä ja laitetestejä.

Lisätarkistus: tallennetun null-/taulukko-/virheellisen moduulirakenteen normalisointi lisätty. GitHubin kirjoitusyritys hylättiin 403 Resource not accessible by integration -virheellä. Pilvikäännöstä ei käynnistetty. Tukisivujen lähdekoodi ja paikalliset linkit tarkistettu.

Lisäksi ajettu simuloidun DOMin tarkistukset tallennusarvoilla null, [], sekä moduulilla jonka merkinnöissä oli null, viikko oli taulukko ja taso negatiivinen. Kaikki läpäisivät tarkistukset. Natiivilaite-/selainkuvatestejä ei tehty.

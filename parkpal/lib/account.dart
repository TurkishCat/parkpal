import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkpal/login/login_screen.dart';

class AccountPage extends StatelessWidget {
  final User? user;

  AccountPage({this.user});

  void _showPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'Parkpal';

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welkom, $email',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                _showPopup(
                  context,
                  'Veelgestelde vragen',
                  """1. Wat is ParkPal? ParkPal is een handige mobiele app waarmee je gemakkelijk parkeerplaatsen kunt vinden en reserveren. Je kunt de app gebruiken om beschikbare parkeerplekken in de buurt te vinden, parkeertarieven te vergelijken en direct een parkeerplek te reserveren.

                    2. Hoe werkt het reserveren van een parkeerplek?
                      Het reserveren van een parkeerplek is eenvoudig met ParkPal. Nadat je de gewenste locatie hebt geselecteerd, kun je beschikbare parkeerplekken bekijken en de gewenste tijd en datum kiezen. Vervolgens kun je je reservering bevestigen en betalen via de app. Bij aankomst op de parkeerplaats wordt je reservering herkend en kun je gemakkelijk parkeren.

                    3. Zijn mijn betalingsgegevens veilig?
                      Ja, jouw veiligheid en privacy zijn onze hoogste prioriteit. ParkPal maakt gebruik van beveiligde betalingssystemen en versleutelde verbindingen om ervoor te zorgen dat jouw betalingsgegevens veilig worden verwerkt. We slaan geen creditcardgegevens op onze servers op.

                    4. Kan ik mijn reservering annuleren?
                      Ja, je kunt je reservering op elk gewenst moment annuleren via de app. Zolang de annulering binnen de annuleringsvoorwaarden valt, wordt het bedrag terugbetaald op de betaalmethode die je hebt gebruikt bij het maken van de reservering.

                    5. Zijn er extra kosten verbonden aan het gebruik van ParkPal?
                      ParkPal brengt geen extra kosten in rekening voor het gebruik van de app. Je betaalt alleen de geldende parkeertarieven voor de gereserveerde parkeerplaatsen.

                    Als je nog andere vragen hebt, aarzel dan niet om contact met ons op te nemen. We staan altijd klaar om je te helpen!
                    """
                );
              },
              child: Text('Veelgestelde vragen'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                _showPopup(
                  context,
                  'Privacyverklaring',
                  """Bij ParkPal hechten we veel waarde aan de privacy van onze gebruikers. In deze privacyverklaring leggen we uit welke informatie we verzamelen, hoe we deze informatie gebruiken en beschermen, en welke rechten je hebt met betrekking tot je persoonlijke gegevens.

                    Verzamelde informatie:
                    - Persoonlijke gegevens: we kunnen bepaalde persoonlijke gegevens verzamelen, zoals je naam, e-mailadres en contactgegevens. Deze gegevens worden gebruikt om je account te beheren en je de gevraagde services te leveren.
                    - Locatiegegevens: we kunnen je locatiegegevens verzamelen wanneer je de app gebruikt om parkeerplekken te zoeken of te delen. Deze gegevens helpen ons bij het bieden van nauwkeurige parkeerinformatie.

                    Gebruik van informatie:
                    - We gebruiken je persoonlijke gegevens alleen voor het beheer van je account en het leveren van de gevraagde services.
                    - We delen je persoonlijke gegevens niet met derden, tenzij dit nodig is voor het verlenen van de services of wanneer we wettelijk verplicht zijn om dit te doen.
                    - We nemen passende maatregelen om je gegevens te beschermen tegen ongeautoriseerde toegang, verlies, misbruik of openbaarmaking.

                    Jouw rechten:
                    - Je hebt het recht om toegang te vragen tot je persoonlijke gegevens die we bewaren, en om correcties aan te brengen als deze onjuist of onvolledig zijn.
                    - Je kunt op elk moment verzoeken om de verwijdering van je account en persoonlijke gegevens.
                    - Neem contact met ons op via 06-12345678 om je rechten uit te oefenen of als je vragen hebt over deze privacyverklaring.

                    Door het gebruik van de ParkPal-app ga je akkoord met deze privacyverklaring en stem je in met het verzamelen en gebruiken van je persoonlijke gegevens zoals hierin beschreven.

                    """,
                );
              },
              child: Text('Privacyverklaring'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                _showPopup(
                  context,
                  'Algemene voorwaarden',
                  """Welkom bij ParkPal! Voordat je onze app gebruikt, vragen we je om deze algemene voorwaarden zorgvuldig te lezen. Door de ParkPal-app te gebruiken, ga je akkoord met deze voorwaarden.

                    1. Gebruiksvoorwaarden:
                    - Je mag de ParkPal-app alleen gebruiken voor legitieme doeleinden en in overeenstemming met deze voorwaarden.
                    - Je bent verantwoordelijk voor het beschermen van je accountgegevens en het veilig houden van je wachtwoord.
                    - Je mag de app niet gebruiken op een manier die de veiligheid, integriteit of prestaties van de app kan schaden.

                    2. Intellectuele eigendom:
                    - De ParkPal-app en alle bijbehorende inhoud, zoals logo's, ontwerpen en functies, zijn eigendom van ParkPal en zijn beschermd door auteursrecht en andere intellectuele eigendomsrechten.
                    - Je mag de inhoud van de app niet kopiëren, reproduceren, verspreiden of wijzigen zonder de uitdrukkelijke toestemming van ParkPal.

                    3. Gebruikersbijdragen:
                    - Door bijdragen te leveren aan de ParkPal-app, zoals het delen van parkeerplekken of het plaatsen van recensies, verleen je ParkPal het recht om deze bijdragen te gebruiken, kopiëren, aanpassen en verspreiden.
                    - Je bent verantwoordelijk voor je bijdragen en garandeert dat ze accuraat en niet in strijd met de wet zijn.

                    4. Beperking van aansprakelijkheid:
                    - ParkPal is niet aansprakelijk voor enige schade die voortvloeit uit het gebruik van de app of het vertrouwen op de verstrekte informatie.
                    - ParkPal is niet verantwoordelijk voor eventuele verliezen, schade of letsel als gevolg van het parkeren op de aangegeven locaties.

                    5. Wijzigingen en beëindiging:
                    - ParkPal behoudt zich het recht voor om deze algemene voorwaarden op elk moment te wijzigen of de app te beëindigen.
                    - Bij belangrijke wijzigingen zullen we je op de hoogte stellen via de app of het opgegeven e-mailadres.

                    Als je vragen hebt over deze algemene voorwaarden, neem dan contact met ons op via [contactgegevens].

                    Dank je wel voor het lezen en het accepteren van onze algemene voorwaarden. We hopen dat je veel plezier beleeft aan het gebruik van de ParkPal-app!

                    """,
                );
              },
              child: Text('Algemene voorwaarden'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text('Log uit'),
            ),
            Spacer(),
            Image.asset('assets/images/parkpal_red_clean.png'),
          ],
        ),
      ),
    );
  }
}

# TVTower News-Recherche — 15-Teile-Struktur

## Übersicht

| Teil | Thema |
|------|-------|
| 1 | Deutschland (BRD) |
| 2 | Nordamerika |
| 3 | Westeuropa Süd & Mitte |
| 4 | Nordeuropa & Benelux |
| 5 | Nahost & internationale Konflikte |
| 6 | DDR & Ostblock |
| 7 | Asien & Pazifik |
| 8 | Südamerika / Afrika |
| 9 | Sport |
| 10 | Film & Fernsehen |
| 11 | Kultur (Musik, Literatur, Unterhaltung, Kunst, Theater) |
| 12 | Wissenschaft & Technik |
| 13 | Live Events & Verleihungen |
| 14 | Kuriositäten & Gute Nachrichten |
| 15 | Kinder & Jugendliche |

---

## Output-Format pro Kandidat

Für jeden gefundenen Kandidaten wird ein standardisierter Steckbrief geliefert:

**Datum:** So genau wie möglich (Tag.Monat.Jahr; falls nur Monat bekannt: „Monat Jahr") + **Konfidenz-Markierung:**
- ✅ = Datum durch mindestens 2 unabhängige Quellen aus der Websuche bestätigt
- ⚠️ = Datum nur durch 1 Quelle belegt, keine Gegenquelle vorhanden (unverifiziert, aber kein Widerspruch — mit Vorsicht verwendbar)
- ❌ = Quellenkonflikt: 2+ Quellen widersprechen sich aktiv (Widerspruch explizit benennen! — muss vor Verwendung im XML geklärt werden)
- ❓ = Datum aus Kontext abgeleitet, nicht direkt in Suchquellen belegt → „genaues Datum nicht belegt" schreiben

**Ereignis:** Titel + 1–2 Sätze Kontext. Knapp, aber mit dem entscheidenden Detail.

**TV-Relevanz:** ⭐ bis ⭐⭐⭐⭐⭐ — Wie interessant für eine deutsche TV-Nachrichtenredaktion 1980?
- ⭐ Füllmaterial, kaum Spielwert
- ⭐⭐ Nischenthema, aber brauchbar
- ⭐⭐⭐ Solide Nachricht, würde in einer Tageszeitung stehen
- ⭐⭐⭐⭐ Starke Nachricht, Hauptnachrichtensendung
- ⭐⭐⭐⭐⭐ Topnachricht des Monats, jeder redet darüber

**Thread-Potenzial:** Einordnung in eine der folgenden Kategorien:
- *Eigenständig* — Einzelnachricht ohne Bezug
- *Teil einer Kette* — gehört zu einem bestehenden oder neuen Thread
- *Vorbereitung für späteren Monat* — Ereignis wird erst später relevant, vormerken
- *Follow-up* — Abschluss oder Fortsetzung eines früheren Eintrags

**Film/Skript-Potenzial:** Gab es Filme, Serien, Dokumentationen, die dieses Ereignis betreffen? Wenn ja: Titel, Jahr, ggf. IMDb-Link. Relevant für `news-activates-programme`-Mechanik.

**Quelle:** Wikipedia-Link oder andere verifizierbare Quelle für das `comment`-Feld.

### Beispiel

> **Datum:** 31. Oktober 1980 ✅
> **Ereignis:** EG-Kommission erklärt „manifeste Krise" der Stahlindustrie. Erstmals verbindliche Produktionsquoten für alle Stahlwerke der Gemeinschaft. 288.000 Beschäftigte allein in der BRD betroffen.
> **TV-Relevanz:** ⭐⭐⭐⭐⭐ — Direkte Auswirkungen auf Ruhrgebiet, Existenzangst, EG-Bürokratie vs. deutsche Industrie.
> **Thread-Potenzial:** Eigenständig, aber Kettenpotenzial für spätere Werksschließungen (1982–87).
> **Film/Skript-Potenzial:** Keines bekannt.
> **Quelle:** https://de.wikipedia.org/wiki/Stahlkrise

---

## Qualitätskriterien

### Grundsätze

- **Historical accuracy is non-negotiable** — alle Daten, Namen, Zahlen müssen stimmen
- **Entertainment value drives selection** — es ist ein Spiel. Lieber eine mittelwichtige Nachricht mit großem Unterhaltungspotenzial als eine wichtige Nachricht ohne Spielwert
- **Bei Unsicherheit: Quelle prüfen, nicht raten** — Wikipedia ist akzeptabel als Primärquelle
- **Authentische Lücken sind akzeptabel** — nicht krampfhaft Inhalte erzwingen wo natürlicherweise keine existieren
- **Satirischer Ton beibehalten**, aber kein unangemessener Humor bei Todesfällen, Naturkatastrophen mit Opfern oder Terroranschlägen

### Thread-Bewusstsein

- Wenn ein Ereignis Teil einer größeren Story ist: explizit vermerken
- Verweise auf bereits existierende Threads aus früheren Monaten
- Ereignisse vormerken die in späteren Monaten relevant werden
- Bei Kettenpotenzial: Art der Kette vorschlagen (Exklusiv / Hybrid / Themengruppe)

### Anti-Halluzination — Datumsicherheit

LLMs neigen dazu, bei eigenständiger Rekonstruktion von Zeitstrahl-Daten Fehler zu machen: falsche Tage, falsche Monate, Details aus dem Trainings-Wissen statt aus der aktuellen Recherche. Dagegen gelten folgende Regeln:

1. **Quellenabgleich bei Daten:** Wenn ein konkretes Datum+Ereignis genannt wird, muss mindestens eine der aktuellen Websearch-Quellen dieses Datum **explizit** bestätigen. Nicht aus dem Trainings-Wissen des LLM ergänzen.

2. **Konfidenz-Markierung (Pflicht bei jedem Kandidaten):**
   - ✅ = Datum durch mindestens 2 unabhängige Quellen aus der Websuche bestätigt
   - ⚠️ = Datum nur durch 1 Quelle belegt, keine Gegenquelle vorhanden → unverifiziert, aber kein aktiver Widerspruch. Mit Vorsicht verwendbar, ggf. bei der Auswahl nochmals prüfen.
   - ❌ = Quellenkonflikt: 2+ Quellen widersprechen sich aktiv → Widerspruch im Steckbrief **explizit benennen** (z.B. „Quelle A sagt 13. November, Wikipedia-Artikel datiert den Beschluss auf Mai 1978 — möglicherweise unterschiedliche Entscheidungsstufen"). **Darf nicht in den XML-Code übernommen werden, bevor der Konflikt geklärt ist.**
   - ❓ = Datum aus Kontext abgeleitet, nicht direkt in Suchquellen belegt → „genaues Datum nicht belegt" schreiben, **kein Datum erfinden**

3. **Widersprüche offen ansprechen**, nicht stillschweigend eine Version wählen. Im Zweifel: beide Versionen dokumentieren, mit ❌ markieren, und bei der Auswahl klären. Kandidaten mit ❌ dürfen nicht in den XML-Code einfließen, bevor der Konflikt aufgelöst ist.

4. **Keine „Anreicherung":** Wenn die Websuche ein Ereignis findet aber kein exaktes Datum liefert, steht im Steckbrief „Datum: November 1980 (genauer Tag nicht belegt) ❓" — niemals ein Datum aus dem Trainings-Wissen einfügen.

5. **Zahlen und Namen aus Suchquellen übernehmen**, nicht aus dem Gedächtnis ergänzen. Bei Abweichungen zwischen Quellen (z.B. Opferzahlen) die Bandbreite angeben.

### Was NICHT recherchiert werden muss

- Detaillierte Bundesliga-Ergebnisse (es sei denn etwas Außergewöhnliches passiert)
- Tägliche Börsenkurse
- Routinemäßige Parlamentssitzungen ohne besondere Beschlüsse
- Wetter (es sei denn Extremereignisse)
- Routinemäßige Staatsbesuche ohne besonderes Ereignis

---

## Standard-Unterpunkte für geografische Teile (1–8)

Jeder geografische Teil enthält zusätzlich zu seinen regionsspezifischen Unterpunkten folgende Standard-Checks:

- Politik
- Gesellschaft
- Wirtschaft
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

---

## Teil 1: Deutschland (BRD)

- Bundespolitik (Wahlen, Regierung, Gesetze, Parteien)
- Landespolitik (wenn bundesweit relevant)
- Wirtschaft & Arbeitsmarkt
- Gesellschaft & Soziales
- Innere Sicherheit & Terrorismus
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

## Teil 2: Nordamerika

- USA: Innenpolitik & Wahlen
- USA: Außenpolitik & Militär
- USA: Wirtschaft & Gesellschaft
- Kanada
- Mexiko
- Karibik (Kuba, Jamaika, Puerto Rico etc.)
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

## Teil 3: Westeuropa Süd & Mitte

- UK & Nordirland
- Frankreich
- Italien
- Spanien & Portugal
- Schweiz & Österreich
- Griechenland & Türkei
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

## Teil 4: Nordeuropa & Benelux

- Skandinavien (Schweden, Norwegen, Dänemark, Finnland, Island)
- Niederlande, Belgien, Luxemburg
- Irland (Republik)
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

## Teil 5: Nahost & internationale Konflikte

- Nahostkonflikt & Golfregion
- Bewaffnete Konflikte weltweit
- Terrorismus (international)
- Flucht & Migration
- Diplomatie & Friedensprozesse
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

## Teil 6: DDR & Ostblock

- DDR: Innenpolitik, Wirtschaft, Gesellschaft
- Sowjetunion / Russland
- Ostmitteleuropa (Polen, Tschechien, Ungarn, Rumänien, Bulgarien)
- Jugoslawien / Balkan
- Ostblock-Außenpolitik & Bündnisse
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

## Teil 7: Asien & Pazifik

- China
- Japan
- Korea (Nord & Süd)
- Südostasien
- Südasien (Indien, Pakistan, Bangladesh)
- Ozeanien (Australien, Neuseeland, Pazifikinseln)
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

## Teil 8: Südamerika / Afrika

- Südamerika (Politik, Wirtschaft, Gesellschaft)
- Zentralamerika
- Nordafrika
- Sub-Sahara-Afrika
- Religion & Kirche
- Kriminalfälle & Prozesse
- Katastrophen & Unglücke

**Zusätzlicher Check:** Nach der englisch/deutschen Recherche einen kurzen Wikipedia-Check in **Spanisch**, **Portugiesisch** und **Französisch** durchführen (z.B. `es.wikipedia.org/wiki/1980`, `pt.wikipedia.org/wiki/1980_no_Brasil`, `fr.wikipedia.org/wiki/Novembre_1980`). Frankophone afrikanische Ereignisse und südamerikanische Innenpolitik sind in englischsprachigen Quellen häufig unterrepräsentiert.

## Teil 9: Sport

- Fußball (national & international)
- Olympia & Leichtathletik
- Motorsport
- Tennis, Boxen, Radsport
- Wintersport
- Sonstiger Sport

## Teil 10: Film & Fernsehen

- Kinostarts (deutsch & international)
- TV-Serien & Formate
- Quoten, Skandale, Programmentwicklung
- Persönlichkeiten (Todesfälle, Karrieremeilensteine)

## Teil 11: Kultur (Musik, Literatur, Unterhaltung, Kunst, Theater)

- Alben, Singles, Charts
- Bands & Künstler (Gründungen, Auflösungen, Todesfälle)
- Genres & Trends
- Tourneen & Festivals
- Literatur (Romane, Sachbücher, Literaturpreise)
- Kunst & Theater (Ausstellungen, Premieren, Skandale)

## Teil 12: Wissenschaft & Technik

- Raumfahrt
- Medizin & Gesundheit
- Computer & Elektronik
- Naturwissenschaftliche Entdeckungen
- Umwelt & Klima
- Nobelpreise (Forschungsinhalt — Zeremonie in Teil 13)

## Teil 13: Live Events & Verleihungen

- Film- & TV-Preise (Oscars, Emmys, Bambi, Goldene Kamera)
- Musikpreise (Grammys, Echo)
- Eurovision Song Contest
- Nobelpreis-Zeremonie
- TV-Debatten & Elefantenrunden
- Messen & Ausstellungen (CeBIT, IAA, Hannover Messe, Weltausstellungen)
- Staatsbesuche & Zeremonien (Krönungen, Staatsbegräbnisse, Papstbesuche)
- Weltraumübertragungen (Starts, Landungen, Live-Feeds)
- Großveranstaltungen mit TV-Übertragung
- Sonstige TV-Übertragungsevents

## Teil 14: Kuriositäten & Gute Nachrichten

- Absurde & lustige Nachrichten
- Feel-Good-Stories
- Rekorde & Stunts
- Tiergeschichten
- Skurrile Erfindungen & Entdeckungen
- Kurioser Sport (Wettessen, Schneckenrennen etc.)
- Menschliche Wohlfühlmomente (Rettungsaktionen, Wiedervereinigungen, Glückspilze)
- Kuriose Kriminalfälle
- Verrückte Werbung & kuriose Konsumprodukte
- "Das kann man sich nicht ausdenken"-Momente

## Teil 15: Kinder & Jugendliche

- Spielzeug, Spiele & Trends
- Kindersendungen & Jugendprogramme
- Jugendkultur
- Bildung & Schulpolitik

---

## Prozessregeln

### Recherche-Pflicht
- Bei jedem Teil müssen **alle Unterpunkte einzeln geprüft** werden
- Pro Unterpunkt werden **alle** TV-relevanten Kandidaten vorgestellt, nicht nur der stärkste
- Kein künstliches Limit pro Unterpunkt
- Wenn zu einem Unterpunkt nichts gefunden wird, wird das **explizit gemeldet**: „[Unterpunkt] — nichts gefunden"
- Kein Unterpunkt darf stillschweigend übersprungen werden

### Relevanzfilter
- **Teile 1–13, 15:** Nicht alles melden was passiert ist, sondern alles was realistisch als TVTower-News-Eintrag in Frage kommt. Faustregel: *Würde eine Nachrichtenagentur das als eigene Meldung verkaufen?* Pro Unterpunkt realistisch 0–5 Kandidaten. Bei 10+ Kandidaten: vorher fragen ob alle präsentiert oder vorgefiltert werden sollen.
- **Teil 14 (Kuriositäten & Gute Nachrichten): Kein Filter.** Alles was gefunden wird kommt rein. Das Problem bei Kuriositäten ist nicht zu viel, sondern zu wenig.

### Bilanz pro Teil
Am Ende jedes Teils steht eine kurze Bilanz mit Häkchen/nichts-gefunden pro Unterpunkt, z.B.:

> *Teil 3 — Westeuropa Süd & Mitte, Oktober 1980:*
> *UK ✓ (2 Kandidaten), Frankreich ✓ (1 Kandidat), Italien — nichts, Spanien/Portugal — nichts, Schweiz/Österreich — nichts, Griechenland/Türkei — nichts*
> *Religion — nichts, Kriminalfälle — nichts, Katastrophen — nichts*
> *Ergebnis: 3 Kandidaten*

### Duplikate erlaubt
- Die Teile sind **Suchscheinwerfer**, keine Schubladen
- Wenn ein Ereignis in mehreren Teilen auftaucht (z.B. Carter vs. Reagan als Politik in Teil 2 UND als TV-Debatte in Teil 13), wird es in beiden Teilen notiert
- Duplikate werden erst bei der **gemeinsamen Auswahl** nach Abschluss aller 15 Teile aussortiert

### Ton-Priorität
- TVTower lebt von Sarkasmus und Humor
- Aktiv nach absurden, ironischen oder komischen Aspekten suchen — auch bei ernsten Themen
- Wenn ein Ereignis sowohl eine seriöse als auch eine lustige Seite hat, **beide** notieren
- Lieber eine mittelwichtige Nachricht mit großem Unterhaltungspotenzial als eine wichtige Nachricht ohne Spielwert
- **Ernst bleibt ernst** bei: Todesfällen, Naturkatastrophen mit Opfern, Terroranschlägen — dort kein erzwungener Humor
- Bei allem anderen: den sarkastischen Blickwinkel bewusst suchen
- Die endgültige Tonentscheidung fällt bei der gemeinsamen Auswahl

### Workflow
1. Alle 15 Teile werden nacheinander recherchiert
2. Pro Teil wird ein Markdown-Dokument erstellt (sofort, nicht aufgeschoben)
3. Nach Abschluss aller 15 Teile: gemeinsame Kandidatenauswahl
4. XML-Erstellung erst nach Auswahl
5. Stukov trifft alle finalen Entscheidungen

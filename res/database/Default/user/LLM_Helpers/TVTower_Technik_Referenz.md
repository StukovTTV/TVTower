# TVTower Technik-Referenz

Schnellreferenz für die XML-Erstellung. Verweist auf die Projektdokumentation statt sie zu duplizieren — mit Ausnahme der Modifier-Daten, die nur hier dokumentiert sind.

---

## Wo finde ich was?

| Thema | Datei | Abschnitt |
|-------|-------|-----------|
| **News-Genres (0–5)** | `news.md` | Spezifische Werte für news → Genre |
| **News-Flags (1–256)** | `news.md` | Spezifische Werte für news → NewsFlag |
| **News-Typen (0–3)** | `news.md` | Spezifische Werte für news → NewsType |
| **News-Effekte & Trigger** | `news.md` | Effekte (effects) |
| **Kettensysteme & Praxis** | `SKV_News_Guidelines.md` | Nachrichtentypen und Kettensysteme |
| **Programm-Genres (0–401)** | `main.md` | Genre |
| **Programmtypen (0–7)** | `main.md` | Programmtyp |
| **Programmflags** | `main.md` | Programmflags |
| **Ausstrahlungsflags** | `main.md` | Ausstrahlungsflags |
| **Lizenztypen & Lizenzflags** | `main.md` | Lizenztyp / Lizenzflags |
| **Job-Werte (1–4096)** | `main.md` | Job |
| **Länder-Codes** | `main.md` | Länder |
| **Zielgruppen-Flags** | `main.md` | Zielgruppe |
| **Lobbygruppen** | `main.md` | Lobbygruppe |
| **Geschlecht** | `main.md` | Geschlecht |
| **targetgroupattractivity** | `main.md` | targetgroupattractivity |
| **Effekt-Typen (alle)** | `main.md` | effects |
| **Programm-Ratings** | `programmes.md` | Bewertung (ratings) |
| **Programm-Daten** | `programmes.md` | Daten (data) |
| **Programme-Modifier** | `programmes.md` | Modifier → *und diese Datei (Details unten)* |
| **Programm-Release** | `programmes.md` | Veröffentlichung (releaseTime) |
| **Programm-Besetzung** | `programmes.md` | Mitwirkende (staff) |
| **Live-Programme** | `programmes.md` | Live-Programm *(Hinweis: Release-Termin Pflicht!)* |
| **Drehbuch-Struktur** | `scripts.md` | Kindelemente von scripttemplate |
| **Drehbuch-Jobs** | `scripts.md` | Benötigtes Personal (jobs) |
| **Drehbuch min/max/slope** | `scripts.md` | Zufalls-Werte |
| **Drehbuch-Flags** | `scripts.md` | ScriptFlags |
| **Zeittypen (0–8)** | `time.md` | Zeitattribute |
| **Verfügbarkeit (availability)** | `time.md` | Verfügbarkeit |
| **Saison-Zuordnung (Praxis)** | `SKV_News_Guidelines.md` | Verfügbarkeit (availability) |
| **Variablen-Syntax** | `variables.md` | Syntaxgrundlagen |
| **worldtime-Funktionen** | `variables.md` | worldtime |
| **stationmap-Funktionen** | `variables.md` | stationmap |
| **persongenerator** | `variables.md` | persongenerator |
| **person/programme/role-Ref** | `variables.md` | globale Referenz auf Datenbankobjekte |
| **Bedingungen (if/eq/gt...)** | `variables.md` | Bedingungen |
| **csv-Funktion** | `variables.md` | csv |
| **Globale Variablen** | `lang.md` | Globale Variablen |
| **Globale Variablen (Lookup)** | `global_variables_lookup.txt` | — |
| **Personen-Lookup** | `people_lookup.txt` | — |
| **Personen-GUID-Lookup** | `people_guid_lookup.txt` | — |

---

## Modifier-Dokumentation

Die folgenden Modifier-Details sind nicht in den Projektdateien dokumentiert — sie stammen aus der Quellcode-Analyse und sind nur hier festgehalten.

### Topicality-Modifier (für Programme und Drehbuchvorlagen)

```xml
<modifiers>
   <modifier name="topicality::age" value="1.5" />
</modifiers>
```

| Modifier | Default | Beschreibung |
|----------|---------|-------------|
| `topicality::age` | 1.0 | Multiplikator auf den Alterseinfluss. 0.0 = kein Altern, 2.0 = doppelt so schnell. Fließt mit Gewicht 0.8 in MaxTopicality ein. |
| `topicality::refresh` | 1.0 | Multiplikator auf die Erholungsrate nach Ausstrahlung. Programm regeneriert aktuelle Topicality langsamer/schneller bis zur MaxTopicality. Nützlich für Evergreen-Inhalte. |
| `topicality::trailerRefresh` | 1.0 | Wie `refresh`, aber nur für Trailer-Topicality. Betrifft nur Trailer-Erholung, nicht Hauptsendung. |
| `topicality::wearoff` | 1.0 | Multiplikator auf Topicality-Verlust während der Ausstrahlung. Niedrigere Werte = weniger Verlust pro Ausstrahlung. |
| `topicality::trailerWearoff` | 1.0 | Wie `wearoff`, aber für Trailerausstrahlungen. |
| `topicality::firstBroadcastDone` | 0.2 (normal) / 1.0 (LiveOnTape) | Multiplikator auf MaxTopicality-Malus nach erster Ausstrahlung. Basiswert 10 Punkte — bei Default-Normalprogramm: 10 × 0.2 = 2 Punkte MaxTopicality-Verlust. |
| `topicality::notLive` | 1.0 | Multiplikator auf Malus wenn LiveOnTape nicht mehr live ist. Nur relevant für LiveOnTape. Steigt mit jedem Tag: Tag 1 ×1.25, Tag 2 ×1.5, Tag 3 ×1.75, danach ×2.0. |
| `topicality::timesBroadcasted` | 1.0 | Multiplikator auf MaxTopicality-Malus durch Wiederholungen. Basiswerte nichtlinear gestaffelt: 5 Punkte nach 1. Ausstrahlung bis 100 Punkte nach 11+, Gesamtgewicht 0.6. |

### Betty-Modifier (für Programme und Drehbuchvorlagen)

| Modifier | Default | Beschreibung |
|----------|---------|-------------|
| `betty::pointsabsolute` | — | Direkte Vergabe von Bettypunkten unabhängig von Qualität. 100 = +1%, -50 = -0.5%. Für Programme mit festem Reputationseffekt unabhängig von ihrer Qualität. |
| `betty::rawquality` | — | Überschreibt die Programmqualität (0.0–1.0) für die Betty-Berechnung. Nützlich wenn ein Programm objektiv niedrige Qualität hat aber gut fürs Senderimage sein soll — oder umgekehrt. |
| `betty::pointsmod` | 1.0 | Multiplikator auf die automatische Betty-Punkteberechnung. Verstärkt oder schwächt den normalen Qualitäts-zu-Betty-Effekt. |

### Call-In-Modifier

| Modifier | Default | Beschreibung |
|----------|---------|-------------|
| `callin::perViewerRevenue` | 1.0 | Multiplikator auf Einnahmen pro Zuschauer für Call-In-Shows (Programmflag 128). Nur relevant für Programme mit diesem Flag. |

### Preis-Modifier

| Modifier | Default | Beschreibung |
|----------|---------|-------------|
| `price` | 1.0 | Entspricht `price_mod` im `data`-Knoten. Kann als Modifier alternativ gesetzt werden. |

---

## LIVE-Programme: Auktionshaus-Sichtbarkeit

Aus Quellcode-Analyse (game_programme_programmedata.bmx + game_roomhandler_movieagency.bmx).

### Wann erscheint ein LIVE-Programm im Auktionshaus?

Für normale LIVE-Programme (kein `alwaysLive`-Flag) gilt eine dreistufige Logik:

| Zeitpunkt | Verhalten |
|-----------|-----------|
| Mehr als ~10 Spieltage vor `releaseTime` | `IsAvailable()` = `false` → nicht im Auktionshaus, unabhängig von `available`-Flag |
| ~10 Spieltage vor `releaseTime` | `IsAvailable()` = `true` → erscheint im Auktionshaus |
| 1 Spieltag vor `releaseTime` | Auktion endet (`GetMaxAuctionTime()`) |
| `releaseTime` | Live-Ausstrahlung möglich, Auktion vorbei |

**1 Spieltag = 1 Monat.** Das Programm erscheint also ca. 10 Monate vor dem Release-Datum im Auktionshaus.

### Konsequenzen für die Datenbankarbeit

- **`available="0"` in der Programmlizenz** hat keinen Einfluss auf den Erscheinungszeitpunkt im Auktionshaus — die `IsAvailable()`-Logik überschreibt es für LIVE-Programme.
- **Das `available`-Flag auf `0`** ist dennoch korrekt und nötig, damit das Programm erst durch die Unlock-News freigeschaltet wird (andere Prüfebene).
- **Kein Spoiler-Problem** bei früh gesetzten `available="0"`-LIVE-Programmen: Der Spieler sieht das Programm ohnehin erst ~10 Monate vor dem Ereignis.
- **Lead-Time-Regel** (min. 6 Monate zwischen Unlock-News und releaseTime) ist damit gut abgedeckt — das Programm erscheint im Auktionshaus kurz nach der Unlock-News.

---

## News-Generierung im Spiel

### Aufruf-Zyklus

`GetNewsAgency().Update()` wird jede Spielminute aufgerufen. Für jedes Nachrichtengenre wird separat geprüft, ob der Timer abgelaufen ist. Jedes Genre hat seinen eigenen unabhängigen Timer.

### Basis-Intervalle pro Genre (Spielminuten)

| Genre | Min | Max |
|-------|-----|-----|
| Politik/Wirtschaft (0) | 300 | 500 |
| Showbiz (1) | 270 | 450 |
| Sport (2) | 300 | 450 |
| Medien/Technik (3) | 330 | 530 |
| Kultur (5) | 360 | 600 |
| Tagesgeschehen (4) | 270 | 450 |

Grob: alle 4–8 Spielstunden eine neue Nachricht pro Genre.

### Modifikatoren

**Tageszeit:** Nachts (0–4 Uhr) und spätabends (≥ 22 Uhr): +30–70 Minuten (seltener). Arbeitszeit (8–14 Uhr): −20–40 Minuten (häufiger).

**25%-Verdopplung:** Nach jedem Timer-Reset besteht eine 25% Chance, dass die Wartezeit verdoppelt wird.

### Zusätzliche Nachrichtenquellen (außerhalb des Timers)

- **Nachrichtenketten:** Durch andere Nachrichten ausgelöste Events (`triggernews`, `modifyNewsAvailability`) werden verarbeitet sobald ihre geplante Zeit erreicht ist.
- **Sport-Provider:** Externe Quellen wie Fußball- und Eishockey-Events liefern eigene Nachrichten unabhängig vom Genre-Timer.
- **Showbiz-Sonderregel:** Bei Genre 1 besteht eine 25% Chance, statt einer zufälligen Nachricht eine Filmnachricht zu generieren.

### Implikationen für die Datenbankarbeit

- **Pool-Tiefe ist Abwechslung, nicht Häufigkeit.** Mehr Einträge in einem Genre erhöhen nicht die Frequenz — sie verhindern Wiederholungen und sorgen für Varianz.
- **Subscription Level 3** ist echte Nische. Nur Spieler mit Fachagentur-Abo sehen diese Einträge. Sparsam einsetzen.
- **Genre-Balance** beeinflusst, wie abwechslungsreich die Nachrichtenlage für den Spieler wirkt. Unterrepräsentierte Genres (z.B. Kultur) führen nicht zu weniger Nachrichten, aber zu schnellerer Erschöpfung des Pools.

---

## Wichtige Merksätze

- **News-Genres (0–5) ≠ Programm-Genres (0–401)** — nie verwechseln
- **Season-Werte:** 1=Frühling, 2=Sommer, 3=Herbst, 4=Winter — **nicht** 0-basiert
- **Variablen in Ketten** werden von der Startnachricht an Folgenachrichten vererbt (seit 0.8.1)
- **Live-Programme brauchen immer einen Release-Termin** (`releaseTime`)
- **`happen_time="-1"` kann weggelassen werden** — beides gleichwertig
- **`available="0"` bei type="2" Exklusivketten-Einträgen ist Pflicht**, nicht redundant
- **`production_limit="1"` bei Filmen/Dokus weglassen** — ist technisch der Default und verhindert Remakes. Nur setzen wenn bewusst keine Neuverfilmung möglich sein soll (z.B. bei festem Titel, der nicht wiederverwendbar ist)

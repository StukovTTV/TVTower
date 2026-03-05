# TVTower News-Auswahl — Prozessstruktur

## Übersicht

Die Auswahlphase beginnt nach Abschluss aller 15 Recherche-Teile eines Monats. Die Arbeit erfolgt **batchweise** in einem neuen Chat: Stukov liefert jeweils 1–3 Recherche-Artefakte, der Batch wird komplett fertiggestellt (Liste → Auswahl → Ketten → Ton → XML), erst dann kommt der nächste Batch.

---

## Batch-Workflow

### Schritt 1: Kandidatenliste erstellen

Stukov liefert 1–3 Recherche-Artefakte (z.B. Teil 1–3).

Claude liest die Artefakte ein und erstellt eine **nummerierte Liste** aller Kandidaten:

```
1. [Datum] [Konfidenz] [Ereignis] [⭐-Bewertung] [Typ]
2. [Datum] [Konfidenz] [Ereignis] [⭐-Bewertung] [Typ]
...
```

Für jeden Kandidaten:
- **Datum** — so genau wie bekannt
- **Konfidenz** — ✅ / ⚠️ / ❌ / ❓
- **Ereignis** — Kurztitel + 1 Satz
- **Bewertung** — ⭐ bis ⭐⭐⭐⭐⭐
- **Typ** — Einzelnachricht / Kettenstart / Kettenfortsetzung / News-activates-programme
- **Film/Serien-Bezug** — Falls Filme, Serien oder Dokumentationen direkten Bezug zum Ereignis haben: erwähnen (relevant für `news-activates-programme`-Mechanik)

**Duplikate** werden beim Einlesen erkannt. Wenn ein Kandidat bereits in einem früheren Batch verarbeitet wurde oder innerhalb des aktuellen Batches mehrfach auftaucht (z.B. Dallas in Teil 2 und Teil 10), wird er nur einmal aufgeführt mit Vermerk der Herkunfts-Teile.

**Gegencheck gegen bestehende Datenbank:** Beim Einlesen prüft Claude jeden Kandidaten gegen die bereits vorhandenen Einträge in `SKV_News.xml` und `database_news.xml`. Wenn ein Ereignis dort bereits als News-Eintrag existiert, wird es in der Liste mit **[BEREITS VORHANDEN]** markiert. Das verhindert, dass doppelte Einträge entstehen. Bereits vorhandene Einträge können trotzdem auf der Liste stehen — z.B. wenn Stukov eine bestehende Kette erweitern oder einen vorhandenen Eintrag überarbeiten möchte.

**Nächste freie GUID ermitteln:** Beim Einlesen prüft Claude die höchste vergebene GUID in `SKV_News.xml` und meldet die nächste freie GUID. Diese wird als Startpunkt für alle neuen Einträge im Batch verwendet und fortlaufend hochgezählt.

**Methodik (tokeneffizient):** Beide Checks erfolgen per `grep`/`bash`-Befehlen auf dem Container, **nicht** durch Einlesen der gesamten Dateien ins Kontextfenster. Die Dateien sind zusammen ~12.000 Zeilen / ~1 MB — viel zu groß für vollständiges Einlesen. Stattdessen:
- Gegencheck: `grep -i "suchbegriff" SKV_News.xml database_news.xml` pro Kandidat
- GUID: `grep -oP 'guid="\K[^"]+' SKV_News.xml | sort -V | tail -1`

### Schritt 2: Auswahl durch Stukov

Stukov wählt per Nummer:
- ✔ Nehmen
- ✘ Streichen
- ? Noch klären (Konflikt auflösen, mehr Infos nötig)

Claude darf Empfehlungen geben und Bedenken äußern, aber die Entscheidung liegt bei Stukov.

Bei Kandidaten mit ❌ (Quellenkonflikt): Falls Stukov den Kandidaten nehmen will, wird der Konflikt gemeinsam geklärt, bevor der Eintrag geschrieben wird.

### Schritt 3: Ketten fertigstellen

Wenn ein ausgewählter Kandidat ein **Kettenstart** oder eine **Kettenfortsetzung** ist:

1. **Komplette Kette recherchieren** — alle historischen Folgeereignisse identifizieren, egal in welchem Monat oder Jahr sie stattfinden
2. **Alle möglichen Kettenglieder als nummerierte Liste präsentieren** — jedes Glied mit Datum, Kurzbeschreibung und Konfidenz-Markierung
3. **Stukov wählt aus**, welche Glieder geschrieben werden
4. **Nur die ausgewählten Glieder werden als XML geschrieben** — die gesamte Kette auf einmal, mit korrekten `thread_guid`, `triggernews`, `happen_time` etc.
5. **Kette abhaken** — sie ist fertig und muss bei späteren Monatsrecherchen nicht mehr berücksichtigt werden

#### Ketten-Dokumentation
Für jede fertiggestellte Kette wird dokumentiert:
- Ketten-Typ (Exklusivkette / Hybridkette / Themengruppe / Hybridkette mit Deaktivierung)
- `thread_guid` (falls zutreffend)
- Alle Glieder mit GUID, Datum und Kurztitel
- Welche Glieder ausgewählt wurden (✔) und welche gestrichen (✘)
- Mechanik-Details (trigger, effects, availability)

### Schritt 4: Tonkalibrierung

Für jeden ausgewählten Kandidaten wird der Ton festgelegt, **bevor** der XML-Code geschrieben wird:

| Ton | Anwendung |
|-----|-----------|
| **Satirisch/Sarkastisch** | Standard-TVTower-Ton. Für Politik, Wirtschaft, Kuriositäten, Sport, Kultur |
| **Trocken-faktisch mit Augenzwinkern** | Für ernste Themen, die trotzdem eine absurde Seite haben |
| **Ernst** | Für Katastrophen mit vielen Opfern, Terroranschläge, Todesfälle — kein erzwungener Humor |

Stukov kann die Tonzuordnung jederzeit ändern.

### Schritt 5: Werte festlegen

Bevor XML geschrieben wird, präsentiert Claude für jeden ausgewählten Kandidaten die vorgeschlagenen Werte mit kurzer Begründung. Referenz ist die `SKV_News_Guidelines.md` im Projekt.

Für jeden Kandidaten werden folgende Werte präsentiert:

| Wert | Begründung erforderlich |
|------|------------------------|
| **Genre** | Warum diese Kategorie? (gegen Genre-Liste geprüft) |
| **Preis** | Agenturmarkt-Logik: regionale Relevanz für Deutschland, Exklusivität, Nachfrage |
| **Quality (min/max)** | Qualitätsbereich des Nachrichtentexts — beeinflusst wie gut die Nachricht beim Spieler ankommt |
| **Subscription Level** | 1 = Standard/national, 2 = internationale Korrespondenten, 3 = Spezial/Nische |
| **Flags** | In der Regel `flags="2"` (nicht send-to-all), Abweichung begründen |
| **Textlänge (DE/EN)** | Geplante Zeichenzahl für Titel und Beschreibung — Längenvorgaben aus Guidelines beachten |
| **targetgroupattractivity** | Nur wenn vom Durchschnitt abweichend — Werte und Begründung |
| **Effekte** | Welche Effekte löst die Nachricht aus? (z.B. `modifyNewsAvailability`, `modifyProgrammeAvailability`, Terrorangst, Börsenwirkung etc.) — oder keine |
| **Modifier** | Betty-Modifier, Topicality-Modifier etc. — nur wenn zutreffend, mit Begründung warum dieser Charakter/Modifier reagiert |
| **Availability** | Saisonbasiertes Script (Saison 0–3), keine Monatsvergleiche |
| **Ketten-Mechanik** | Falls zutreffend: Typ, thread_guid, triggernews, happen_time, available. **Hinweis:** `happen_time="-1"` ist optional und kann weggelassen werden |

Stukov prüft die Werte, korrigiert oder bestätigt. **Erst nach Freigabe wird der XML-Code geschrieben.**

### Schritt 6: XML-Erstellung

Die ausgewählten und wertmäßig freigegebenen Kandidaten des Batches werden als XML **im Chat** präsentiert. Stukov fügt die Einträge manuell in die XML-Dateien ein. Es werden keine separaten XML-Dateien erstellt.

#### XML-Konventionen
- `happen_time="-1"` ist optional und kann weggelassen werden
- Weitere Konventionen siehe `SKV_News_Guidelines.md`

#### Lookup-Dateien (Übersicht)

Drei kompakte Referenzdateien stehen zur Verfügung — tokeneffizient, per `grep` oder direktem Einlesen nutzbar:

| Datei | Inhalt | Größe | Tokens | Methode |
|-------|--------|-------|--------|---------|
| `people_lookup.txt` | Originalname + Lebensdaten | ~44 KB | ~11k | grep oder einlesen |
| `people_guid_lookup.txt` | Originalname + GUID | ~451 KB | ~120k | nur grep |
| `global_variables_lookup.txt` | Variablenname + Spoofed Value | ~9 KB | ~2,3k | grep oder einlesen |

#### Personen-Referenzen
Wenn eine Nachricht reale Personen namentlich erwähnt, wird geprüft ob die Person in der Datenbank existiert. Falls ja, werden **Variablen** statt hardcodierter Namen verwendet — das Spiel setzt automatisch den Spoofed Name ein.

**Konvention:** Personen werden **immer** über den `<variables>`-Block referenziert — auch bei einmaliger Erwähnung. Das ist konsistent mit der bestehenden `database_news.xml` und vermeidet Mischformen.

**Hinweis:** Technisch funktioniert `${.person:"GUID":"firstname"}` auch direkt im Text (es ist ein GameScriptExpression-Handler). Der `<variables>`-Block ist ein Komfort-Alias. Wir verwenden trotzdem konstant den Variables-Weg für Einheitlichkeit und Lesbarkeit.

**Syntax im XML:**
```xml
<description>
   <de>Kathmandu – ${vorname} ${nachname} hat den Everest bestiegen.</de>
</description>
<variables>
   <vorname>${.person:"GUID-HIER":"firstname"}</vorname>
   <nachname>${.person:"GUID-HIER":"lastname"}</nachname>
</variables>
```

**Workflow:**
1. `grep -i "mcqueen" people_lookup.txt` → Existiert? Lebt die Person?
2. `grep -i "mcqueen" people_guid_lookup.txt` → GUID holen
3. Im XML `<variables>`-Block einsetzen, im Text `${vorname} ${nachname}` verwenden

#### Globale Variablen (Marken, Organisationen, Medientitel)
Für Marken, Organisationen, Sportvereine, Medientitel und Charaktere existieren **globale Variablen** (definiert in `lang/en.xml`). Diese müssen statt der Klarnamen verwendet werden — das Spiel ersetzt sie automatisch durch die Spoofed-Version.

**Beispiele:**
- `${brand_microsoft}` → Macrohard
- `${generalorg_nasa}` → NASE
- `${mediatitle_dallas}` → Texas Clan
- `${mediaorg_ard}` → ADR
- `${sportsclub_fcbayern}` → FU Bavaria
- `${brand_cocacola}` → Cacca Cola

**Workflow:**
1. `grep -i "microsoft" global_variables_lookup.txt` → `${brand_microsoft}|Macrohard`
2. Im XML-Text `${brand_microsoft}` verwenden statt „Microsoft" oder „Macrohard"

**Wichtig:** Globale Variablen brauchen keinen `<variables>`-Block im Eintrag — sie werden automatisch aufgelöst. Im Gegensatz zu Personen-Variablen, die pro Eintrag definiert werden müssen.

#### Reihenfolge
1. **Einzelnachrichten** zuerst — am einfachsten
2. **Ketten** danach — komplexer, profitieren vom Aufwärmen
3. **News-activates-programme** zuletzt — erfordern zusätzliche Programm-/Skript-Einträge

#### Qualitäts-Check pro Eintrag
Vor der Präsentation im Chat:
- [ ] Gegencheck: Eintrag existiert noch nicht in `SKV_News.xml` / `database_news.xml` (oder ist bewusste Erweiterung/Überarbeitung)?
- [ ] Datum korrekt und konfident (✅ oder bewusst akzeptiertes ⚠️/❓)?
- [ ] Deutscher UND englischer Text vorhanden?
- [ ] Textlänge innerhalb der Zeichenvorgaben (Titel + Beschreibung)?
- [ ] Genre korrekt (gegen Genre-Liste geprüft)?
- [ ] Preis plausibel (Agenturmarkt-Logik)?
- [ ] Quality min/max plausibel?
- [ ] Subscription Level korrekt (1/2/3)?
- [ ] Availability-Script saisonbasiert (nicht monatsbasiert)?
- [ ] `flags="2"` gesetzt (außer bei send-to-all)?
- [ ] `targetgroupattractivity` nur wenn nötig (nicht bei breitem Appeal)?
- [ ] Effekte korrekt implementiert (oder bewusst keine)?
- [ ] Modifier korrekt (Betty, Topicality etc. — oder bewusst keine)?
- [ ] Ketten-Mechanik korrekt (thread_guid, triggernews, happen_time, available)?
- [ ] Quelle im `comment`-Feld dokumentiert?
- [ ] GUID-Sequenz konsistent?
- [ ] Personen-Referenzen: Falls reale Personen genannt werden — Variablen statt hardcodierter Namen (wenn Person in Datenbank existiert)?
- [ ] Globale Variablen: Marken, Organisationen, Medientitel als `${variable}` statt Klarname oder hardcodiertem Spoof?
- [ ] Alle Werte stimmen mit der Freigabe aus Schritt 5 überein?

### Schritt 7: Batch abschließen

- Stukov hat die XML-Einträge aus dem Chat übernommen
- Batch ist abgehakt
- Stukov liefert den nächsten Batch

---

## Prozessregeln

### Entscheidungshoheit
- **Stukov entscheidet** über Auswahl, Tonzuordnung, Ketten-Glieder, und alle finalen Fragen
- **Claude empfiehlt**, bewertet, warnt, und gibt ehrliche Einschätzungen — auch wenn sie unbequem sind
- Claude filtert nicht vor und unterdrückt keine Kandidaten

### Batch-Disziplin
- Jeder Batch wird vollständig abgeschlossen, bevor der nächste beginnt
- Kein Vorgriff auf spätere Batches
- Ketten werden innerhalb des Batches komplett fertiggestellt, in dem sie erstmals auftauchen

### Ketten-Prinzip
- Ketten werden immer vollständig recherchiert und präsentiert
- Stukov wählt aus, welche Glieder geschrieben werden
- Fertige Ketten werden abgehakt und bei späteren Monatsrecherchen nicht mehr berücksichtigt

### Reihenfolge innerhalb eines Batches ist verbindlich
- Nicht mit XML-Schreiben beginnen, bevor die Auswahl abgeschlossen ist
- Nicht Ketten teilweise schreiben — immer komplett fertigstellen
- Nicht Ton improvisieren — vorher festlegen

### Dokumentation
Jeder Monat produziert am Ende:
1. Die 15 Recherche-Artefakte (Teile 1–15)
2. XML-Einträge im Chat (von Stukov manuell in die Projektdateien eingefügt)

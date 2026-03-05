# SKV News Authoring Guidelines

Dieses Dokument beschreibt die Konventionen und Entscheidungsregeln für die Erstellung von Nachrichteneinträgen in `SKV_News.xml` für TVTower.

---

## Grundstruktur eines Eintrags

```xml
<news guid="news-stukov[YYYY][Mon]_XXXX" type="0" creator="Stukov" created_by="Stukov" comment="[Quellenlink oder Hinweis]">
    <title>
        <de>Deutscher Titel</de>
        <en>English Title</en>
    </title>
    <description>
        <de>Ort – Beschreibungstext auf Deutsch.</de>
        <en>City – Description text in English.</en>
    </description>
    <data genre="N" price="X.X" quality_min="N" quality_max="N" min_subscription_level="N" available="1" fictional="0" happen_time="-1" flags="2"/>
    <targetgroupattractivity ... />
    <availability year_range_from="YYYY" year_range_to="YYYY" script='${.eq:${.worldtime:"month"}:M}' />
</news>
```

**GUID-Schema:** `news-stukov[Jahr][MonatsKürzel]_[4-stellige Nummer]`
Beispiel: `news-stukov1980Jan_0001`, `news-stukov1980Feb_0001`

**Hinweis:** `happen_time="-1"` kann auch komplett weggelassen werden — beides ist gleichwertig. Der explizite Default dient nur als Erinnerung, dass das Attribut existiert.

---

## Nachrichtengenre (für `<data genre="N">`)

Nachrichten-Genre (nicht Programm-Genre):

| Wert | Bedeutung |
|------|-----------|
| 0 | Politik / Wirtschaft |
| 1 | Showbiz |
| 2 | Sport |
| 3 | Medien / Technik |
| 4 | Tagesgeschehen |
| 5 | Kultur |

**Achtung:** Diese 6 Nachrichtengenres (0–5) sind NICHT identisch mit den Programmgenres (0–401) aus `main.md`. Programmgenres werden nur bei Effekten wie `modifyMovieGenrePopularity` verwendet — nie im `<data genre="N">`-Feld einer Nachricht.

---

## Flags

| Wert | Bedeutung |
|------|-----------|
| 2 | `uniqueEvent` – Nachricht erscheint nur einmalig. Standardwert für historische Einmalereignisse. |
| 8 | `sendToAll` – Unabhängig vom Abolevel an alle. Für wirklich universelle Ereignisse. |
| 10 | 2+8 kombiniert: einmalig + an alle |
| 128 | `specialEvent` – Optische Hervorhebung. Nur für sehr große historische Ereignisse. |

Historische Nachrichten bekommen in der Regel `flags="2"`.

---

## Preis (`price`)

Bereich 0.0–2.0, Standard ist 1.0.

`price` ist was die Agentur dem Sender für den Beitrag **berechnet**. Preis und Qualität müssen nicht konsistent sein — exklusive oder stark nachgefragte Meldungen können teuer sein unabhängig von ihrer Qualität. Umgekehrt kann eine günstige Agentur auch gute Nachrichten liefern.

Die Agenturkosten berechnen sich als: `7500 × price × (quality / 100)`

Der Sender verdient nicht direkt an der Nachricht — höhere Qualität zieht mehr Zuschauer, was indirekt die Werbeeinnahmen steigert.

| Richtwert | Wann |
|-----------|------|
| 0.1–0.2 | Weit entfernt, kein Deutschlandbezug, geringe Nachfrage |
| 0.2–0.4 | Internationales Standardereignis, überall verfügbar |
| 0.4–0.6 | Bedeutendes internationales Ereignis oder leichter Deutschlandbezug |
| 0.6–0.9 | Starker Deutschlandbezug, erhöhte Nachfrage oder regional exklusiv |
| 0.9–1.2 | Deutsches Exklusivereignis oder Sensation mit hoher Nachfrage |
| 1.2–1.6 | Große Sensation, Exklusivmeldung oder nationales Spitzenereignis |
| 1.6–2.0 | Absolute Ausnahme: einzigartiges Ereignis, maximale Nachfrage aller Sender |

---

## Qualität (`quality_min` / `quality_max`)

Bereich 0–100. Immer als Range angeben, nicht als fester Wert.

| Richtwert | Wann |
|-----------|------|
| 5–20 | Triviale, kaum relevante Randnotiz |
| 20–40 | Obskure oder wenig relevante Meldung |
| 40–60 | Normale Nachricht |
| 55–75 | Gut recherchierte, relevante Nachricht |
| 65–85 | Bedeutendes Ereignis |
| 75–90 | Historisch sehr bedeutsames Ereignis |
| 90–100 | Ausnahmsweise: epochales Weltereignis |

Die Range sollte typischerweise 10–20 Punkte breit sein.

---

## Abonnement-Level (`min_subscription_level`)

Das Spielsystem kennt drei Agentur-Stufen. 0, unset und 1 sind funktional identisch — da Nachrichten ohnehin nur bei abonniertem Genre erscheinen, empfiehlt sich immer explizit einen Wert zu setzen.

| Level | Konzept | Wann verwenden |
|-------|---------|----------------|
| **1** | **Mittelklasse-Agentur** | Nationale Nachrichten + internationale Top-Schlagzeilen. Was in jeder guten Tageszeitung steht. Großereignisse, bekannte Konzerne/Personen, Supermacht-Politik, globale Marktbewegungen. |
| **2** | **Korrespondenten-Agentur** | Tiefere Auslandsberichterstattung. Ereignisse die eine Tageszeitung auf Seite 4 bringt aber keine Schlagzeile macht. Ausländische Innenpolitik kleinerer Länder, regionale Konflikte. |
| **3** | **Fachagentur** | Spezialisiertes Fachpublikum. Finanzmarktmechanismen, Militärtechnik, Wissenschafts-/Technikdetails, Brancheninterna. |

**Entscheidungshilfe:**
- Würde die Nachricht in einer deutschen Hauptnachrichtensendung vorkommen? → **1**
- Würde sie in einer deutschen Tageszeitung auf Seite 4–6 erscheinen? → **2**
- Würde sie nur in einem Fachmagazin erscheinen? → **3**

---

## Zielgruppenattraktivität (`targetgroupattractivity`)

Verfügbare Attribute:

```
children, children_male, children_female
teenagers, teenagers_male, teenagers_female
housewives, housewives_male, housewives_female
employees, employees_male, employees_female
unemployed, unemployed_male, unemployed_female
managers, managers_male, managers_female
pensioners, pensioners_male, pensioners_female
```

**Wichtige Regel:** Wenn sowohl `_male` als auch `_female` einer Gruppe definiert werden, entfällt der allgemeine Gruppenname. Dieser wäre redundant.

**Wertebereich:** 0.0–2.0, Standard (nicht gesetzt) = 1.0. Beliebige Floatwerte erlaubt (z.B. `0.9`, `1.1`, `1.135`).

| Wert | Bedeutung |
|------|-----------|
| 0.1–0.4 | Kaum Interesse |
| 0.5–0.7 | Unterdurchschnittliches Interesse |
| 0.8–0.9 | Leicht unterdurchschnittlich |
| 1.0 | Durchschnitt (kann weggelassen werden) |
| 1.1–1.2 | Leicht überdurchschnittlich |
| 1.3–1.6 | Erhöhtes Interesse |
| 1.7–2.0 | Sehr hohes Interesse |

**Faustregel:** Werte nahe 1.0 (z.B. 0.9 oder 1.1) können gesetzt werden wenn eine leichte Tendenz sinnvoll ist. Exakt 1.0 kann weggelassen werden.

**Typische Muster:**

- *Politiknachrichten:* `managers` hoch, `children` niedrig, Gendersplit bei `employees` je nach Thema
- *Streik/Arbeit:* `employees` und `unemployed` hoch, `managers` je nach Perspektive
- *Kultur/Musik:* Altersgruppen je nach Genre, `teenagers` oft hoch bei Popkultur
- *Wirtschaft/Finanzen:* `managers` sehr hoch, `children` sehr niedrig
- *Sport:* je nach Sportart, `men` oft etwas höher

---

## Verfügbarkeit (`availability`)

Für historisch datierte Einträge immer beides setzen: Jahr-Range **und** Monats-Script.

Da 1 Spieltag = 1 Monat ist, wird ein Quartalsfenster verwendet damit Nachrichten nicht zu leicht verpasst werden.

| Ereignismonat | Script | year_range_to |
|---------------|--------|---------------|
| Januar | `${.lte:${.worldtime:"month"}:3}` | Ereignisjahr |
| Februar | `${.lte:${.worldtime:"month"}:3}` | Ereignisjahr |
| März | `${.eq:${.worldtime:"season"}:1}` | Ereignisjahr |
| April | `${.eq:${.worldtime:"season"}:1}` | Ereignisjahr |
| Mai | `${.eq:${.worldtime:"season"}:1}` | Ereignisjahr |
| Juni | `${.eq:${.worldtime:"season"}:2}` | Ereignisjahr |
| Juli | `${.eq:${.worldtime:"season"}:2}` | Ereignisjahr |
| August | `${.eq:${.worldtime:"season"}:2}` | Ereignisjahr |
| September | `${.eq:${.worldtime:"season"}:3}` | Ereignisjahr |
| Oktober | `${.eq:${.worldtime:"season"}:3}` | Ereignisjahr |
| November | `${.eq:${.worldtime:"season"}:3}` | Ereignisjahr |
| Dezember | `${.gte:${.worldtime:"month"}:10}` | Ereignisjahr |

Saison-Werte: 1=Frühling (März–Mai), 2=Sommer (Juni–Aug), 3=Herbst (Sept–Nov), 4=Winter (Dez–Feb).

Winter (`season=4`) **nicht** für datierte historische Nachrichten verwenden — nur für fiktive/wiederkehrende Nachrichten die jahreszeitenabhängig sind (z.B. saisonale Themen ohne Jahresbindung).

- `year_range_from` = `year_range_to` für Einmalereignisse im selben Jahr
- Bei Ereignissen über mehrere Monate `year_range_to` entsprechend anpassen

---

## Effekte (`effects`)

### `modifyMovieGenrePopularity`

**Nur verwenden wenn es realistisch ist**, dass das Sehen der Nachricht den Zuschauer dazu bringt, ein bestimmtes Programm-Genre öfter zu schauen. Beispiel: Eine Nachricht über einen Boxkampf könnte Sport-Events populärer machen. Eine politische Meldung über eine Rüstungsspirale eher nicht.

```xml
<effect trigger="broadcastFirstTime" type="modifyMovieGenrePopularity" genre="N" valueMin="0.05" valueMax="0.15" />
```

- `trigger="broadcastFirstTime"` ist Standard (nicht bei jeder Ausstrahlung, nur beim ersten Mal)
- `valueMin`/`valueMax`: Klein halten (0.05–0.2 für normale Nachrichten, bis 0.5 für sehr starke Kulturereignisse)
- Nur `happen` verwenden wenn der Effekt auch ohne Ausstrahlung eintreten soll (selten sinnvoll)

### Programm-Genre-Nummern (für `modifyMovieGenrePopularity`)

| Nr | Genre | Nr | Genre |
|----|-------|----|-------|
| 1 | Abenteuer | 12 | Horror |
| 2 | Action | 13 | Monumental |
| 3 | Trickfilm | 14 | Mystery |
| 4 | Krimi | 15 | Liebesfilm |
| 5 | Komödie | 16 | SciFi |
| 6 | Dokumentation | 17 | Thriller |
| 7 | Drama | 18 | Western |
| 8 | Erotik | 100 | Show |
| 9 | Familie | 101 | Polittalk |
| 10 | Fantasy | 102 | Musikshow |
| 11 | Historisch | 103 | Talkshow |
| | | 104 | Spielshow |
| | | 200 | Event |
| | | 201 | Politik |
| | | 202 | Musik und Gesang |
| | | 203 | Sport |
| | | 204 | Showbiz |
| | | 300 | Reportage |

---

## Globale Variablen (nutzbar in Titeln und Beschreibungen)

Auswahl der relevantesten für historische Nachrichten:

**Organisationen:**
`${generalorg_nasa}`, `${generalorg_kgb}`, `${generalorg_spd}`, `${generalorg_cpsu}`, `${generalorg_sed}`, `${generalorg_greenpeace}`, `${generalorg_igmetall}`, `${generalorg_adac}`, `${generalorg_unicef}`

**Marken/Unternehmen:**
`${brand_ford}`, `${brand_vw}`, `${brand_apple}`, `${brand_microsoft}`, `${brand_commodore}`, `${brand_atari}`, `${brand_telekom}`, `${brand_tesla}`, `${brand_virgin}`

**Währungs-Konditional (automatisch korrekte Währung je Spieljahr):**
```xml
${.lte:currentyear:2001:"DM":"Euro"}
```

**Personen per GUID:**
```xml
${.person:"GUID":"firstname"}
${.person:"GUID":"lastname"}
```

---

## Nachrichtentypen und Kettensysteme

Es gibt fünf Grundtypen, wie Nachrichten strukturiert werden können — von der einfachen Einzelmeldung bis zu komplexen Ketten mit Deaktivierungslogik.

### Variablen in Ketten

Ab Version 0.8.1 werden Variablen aus der Startnachricht automatisch an alle Folgenachrichten weitergegeben. Das bedeutet:

- **Alle Variablen in der Startnachricht definieren** — auch solche, die erst in Folgenachrichten verwendet werden
- Folgenachrichten brauchen keinen eigenen `<variables>`-Block (dürfen aber auch keinen haben, der mit der Startnachricht kollidiert — das kann zum Programmabbruch führen)
- Gewürfelte Werte (z.B. zufällige Namen, Alternativtexte) bleiben innerhalb einer Ketteninstanz konsistent

### 1. Einzelnachricht (Standard)

Eine alleinstehende Nachricht ohne Bezug zu anderen Nachrichten. Der Normalfall.

- `type="0"`, keine `thread_guid`
- Eigene `<availability>`, `available="1"`

```xml
<news guid="news-stukov1980Jun_0001" type="0" creator="Stukov" created_by="Stukov" comment="...">
    <title>...</title>
    <description>...</description>
    <data genre="2" price="0.8" quality_min="50" quality_max="65" min_subscription_level="2" available="1" fictional="0" happen_time="-1" flags="2"/>
    <targetgroupattractivity ... />
    <availability year_range_from="1980" year_range_to="1980" script='${.eq:${.worldtime:"season"}:2}' />
</news>
```

### 2. Themengruppe (gemeinsame `thread_guid`)

Mehrere eigenständige Nachrichten zum selben Thema, die sich gegenseitig blockieren. Ab Version 0.8.1 blockiert eine gemeinsame `thread_guid` die Wiederverwendung für eine gewisse Zeit — es können also nicht mehrere Nachrichten derselben Gruppe kurz hintereinander im Ticker erscheinen.

**Anwendungsfall:** Mehrere Einzelmeldungen zu einem Großereignis (z.B. Olympia), bei dem nicht alle gleichzeitig den Ticker fluten sollen.

- Alle `type="0"`, gemeinsame `thread_guid`
- Jede Nachricht eigenständig mit eigener `<availability>`, `available="1"`
- Keine gegenseitigen Effekte nötig — die Blockade läuft über die `thread_guid`

```xml
<!-- Olympia-Eröffnung -->
<news guid="news-stukov1980Feb_0009" thread_guid="news-stukov-lakeplacid1980" type="0" ...>
    <title><de>Olympische Winterspiele in Lake Placid eröffnet – Zuschauer warten noch</de></title>
    ...
    <data genre="2" price="1.2" quality_min="65" quality_max="80" ... flags="2"/>
    <availability year_range_from="1980" year_range_to="1980" script='${.lte:${.worldtime:"month"}:3}' />
</news>

<!-- Miracle on Ice -->
<news guid="news-stukov1980Feb_0010" thread_guid="news-stukov-lakeplacid1980" type="0" ...>
    <title><de>Miracle on Ice: USA schlagen die Sowjetunion</de></title>
    ...
    <data genre="2" price="1.8" quality_min="82" quality_max="100" ... flags="2"/>
    <availability year_range_from="1980" year_range_to="1980" script='${.lte:${.worldtime:"month"}:3}' />
</news>
```

**Ergebnis:** Der Spieler bekommt entweder die Eröffnungsfeier oder Miracle on Ice — nicht beides im selben Ticker-Durchlauf.

### 3. Exklusivkette (`modifyNewsAvailability`)

Eine Startnachricht schaltet eine oder mehrere Folgenachrichten frei, die ohne Aktivierung nie erscheinen. Die Folgenachrichten steuern ihr Timing selbst über `happen_time`.

**Anwendungsfall:** Mehrteilige historische Abläufe, bei denen die Folge nur Sinn ergibt, wenn der Anfang existierte (z.B. Silberspekulation → Crash).

**Mechanik:**
| Eigenschaft | Startnachricht | Folgenachricht |
|---|---|---|
| `type` | `0` | `2` |
| `thread_guid` | ✓ gemeinsam | ✓ gemeinsam |
| `available` | `1` | **`0`** (gesperrt) |
| `happen_time` | `-1` | **konkretes Datum** (z.B. `4,1980,3,27`) |
| `<availability>` | ✓ (Jahr + Saison) | **keine** |
| Effekt | `modifyNewsAvailability enable="1"` | — |

```xml
<!-- Startnachricht: Silber-Rekord -->
<news guid="news-stukov1980Jan_0010" thread_guid="news-stukov-huntbrothers" type="0" ...>
    <title><de>Silber-Rekord: Hunt-Brüder treiben Preis auf 52 Dollar</de></title>
    ...
    <data genre="0" price="1.0" quality_min="65" quality_max="81" min_subscription_level="3" available="1" fictional="0" flags="2"/>
    <effects>
        <effect trigger="happen" type="modifyNewsAvailability" enable="1" news="news-stukov1980Mar_0007" />
    </effects>
    <availability year_range_from="1980" year_range_to="1980" script='${.lte:${.worldtime:"month"}:3}' />
</news>

<!-- Folgenachricht: Silver Thursday (gesperrt bis freigeschaltet) -->
<news guid="news-stukov1980Mar_0007" thread_guid="news-stukov-huntbrothers" type="2" ...>
    <title><de>„Silver Thursday": Silberpreis bricht um 50 % ein</de></title>
    ...
    <data genre="0" price="1.4" quality_min="70" quality_max="85" min_subscription_level="1" available="0" fictional="0" happen_time="4,1980,3,27" flags="2"/>
    <!-- keine <availability> — Timing kommt aus happen_time -->
</news>
```

**Ablauf:**
1. Startnachricht erscheint im Pool (Q1 1980)
2. `happen`-Trigger schaltet Folgenachricht frei (`available` 0 → 1)
3. Folgenachricht erscheint selbständig zum `happen_time` am 27. März
4. Ohne Startnachricht bleibt Silver Thursday für immer gesperrt

### 4. Hybridkette (`triggernews`)

Eine Startnachricht triggert eine Folgenachricht, die aber auch eigenständig im Pool existiert. Der Trigger ist ein narrativer Bonus — keine Abhängigkeit.

**Anwendungsfall:** Ereignisse die zusammenhängen, aber auch einzeln Sinn ergeben (z.B. Vulkanwarnung → Eruption).

**Mechanik:**
| Eigenschaft | Startnachricht | Folgenachricht |
|---|---|---|
| `type` | `0` | **`0`** |
| `thread_guid` | **keine** | **keine** |
| `available` | `1` | `1` |
| `happen_time` | `-1` | `-1` |
| `<availability>` | ✓ (Jahr + Saison) | ✓ (Jahr + Saison) |
| Effekt | `triggernews` mit `time="4,YYYY,M,D"` | — |

```xml
<!-- Startnachricht -->
<news guid="news-stukov1980Mar_0005" type="0" ...>
    <title><de>Mount St. Helens: Erdbeben und Dampfexplosionen</de></title>
    ...
    <effects>
        <effect trigger="happen" type="triggernews" time="4,1980,5,18" news="news-stukov1980Mai_0001" />
    </effects>
    <availability year_range_from="1980" year_range_to="1980" script='${.eq:${.worldtime:"season"}:1}' />
</news>

<!-- Folgenachricht: existiert auch eigenständig im Pool -->
<news guid="news-stukov1980Mai_0001" type="0" ...>
    <title><de>Mount St. Helens explodiert</de></title>
    ...
    <data ... available="1" ... flags="2"/>
    <availability year_range_from="1980" year_range_to="1980" script='${.eq:${.worldtime:"season"}:1}' />
</news>
```

**Ablauf:**
- Startnachricht erscheint → Trigger zündet Folgenachricht zum 18. Mai
- Startnachricht erscheint nicht → Folgenachricht kann trotzdem aus dem Pool gezogen werden
- `flags="2"` verhindert Doppelerscheinung: Egal ob Trigger oder Pool zuerst kommt, die Nachricht existiert nur einmal

### 5. Hybridkette mit Deaktivierung

Identisch zur Hybridkette, aber die Folgenachricht deaktiviert vorherige oder alternative Nachrichten per `modifyNewsAvailability enable="0"`, um Geschichtsinkonsistenzen zu verhindern.

**Anwendungsfall:** Alternative Erzählstränge zum selben Thema, bei denen nur einer überleben soll (z.B. mehrere Duplikate derselben Nachricht, Challenger-Verschiebung vs. Unglück).

```xml
<!-- Folgenachricht deaktiviert die alternative Version -->
<news guid="news-stukov1985_challenger_main" type="0" ...>
    <title><de>Challenger-Start verschoben</de></title>
    ...
    <effects>
        <effect trigger="happen" type="triggernews" time="2,1,1,10,11" news="news-stukov1986_challenger_disaster" />
        <effect trigger="happen" type="modifyNewsAvailability" enable="0" news="news-alternative-challenger-version" />
    </effects>
</news>
```

**Wann verwenden:** Wenn zum selben historischen Ereignis mehrere Nachrichtenversionen existieren (z.B. von verschiedenen Autoren) und sichergestellt werden muss, dass nur eine davon im Spiel verbleibt.

---

## Checkliste vor dem Erstellen eines Eintrags

- [ ] Ist das Ereignis historisch korrekt und verifizierbar? (Quelle im `comment`-Attribut)
- [ ] Ist `fictional="0"` gesetzt?
- [ ] Ist `flags="2"` gesetzt (Einmalereignis)?
- [ ] Ist `happen_time="-1"` gesetzt oder weggelassen? (Beides ist gleichwertig; `-1` ist ein optionaler expliziter Default als Erinnerung dass das Attribut existiert)
- [ ] Ist `available="1"` gesetzt? (ebenfalls bewusst gesetzter Default — Attribut bleibt immer vorhanden)
- [ ] Sind `quality_min` und `quality_max` als Range angegeben?
- [ ] Ist `min_subscription_level` bewusst gewählt (1/2/3)?
- [ ] Sind Zielgruppenwerte als sinnvolle Floats gesetzt (nicht mechanisch gerundet)?
- [ ] Sind `_male`/`_female` Splits nur gesetzt wo der Genderunterschied tatsächlich relevant ist?
- [ ] Ist die Verfügbarkeit mit Jahr **und** Monat definiert?
- [ ] Wird `modifyMovieGenrePopularity` nur gesetzt wenn ein direkter kausaler Zusammenhang realistisch ist?
- [ ] Haben Titel und Beschreibung beide `<de>` und `<en>` Tags?
- [ ] Ist der Beschreibungstext im Format „Ort – Text." verfasst?
- [ ] Ist die Beschreibung maximal 200–230 Zeichen pro Sprache?

**Zusätzlich bei Kettensystemen:**

- [ ] Ist der richtige Nachrichtentyp gewählt? (Einzelnachricht / Themengruppe / Exklusiv / Hybrid / Hybrid mit Deaktivierung)
- [ ] Themengruppe: Haben alle Nachrichten der Gruppe dieselbe `thread_guid` und sind alle `type="0"`?
- [ ] Exklusiv: Ist die Folgenachricht `type="2"`, `available="0"`, hat `happen_time` und **keine** `<availability>`?
- [ ] Exklusiv: Nutzt die Startnachricht `modifyNewsAvailability enable="1"` (nicht `triggernews`)?
- [ ] Hybrid: Ist die Folgenachricht `type="0"`, `available="1"`, hat eigene `<availability>` und **kein** `happen_time`?
- [ ] Hybrid: Nutzt die Startnachricht `triggernews` mit festem Datum (`time="4,YYYY,M,D"`)?
- [ ] Hybrid: Haben die Nachrichten **keine** gemeinsame `thread_guid`?
- [ ] Hybrid mit Deaktivierung: Enthält die Folgenachricht `modifyNewsAvailability enable="0"` für alle zu deaktivierenden Alternativen?
- [ ] Ist `flags="2"` gesetzt um Doppelerscheinungen zu verhindern?

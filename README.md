# Pugge-asteroider

Et skrivespill for pugging, i samme ånd som Quizlet Gravity: spørsmål faller mot
jorden, og du skriver svaret for å sprenge asteroiden. To forsøk på hver asteroide
— den skifter fra grå til gul etter første bom, og etter andre bom vises fasiten
(inkludert teksten i parentes) som du må skrive av før spillet fortsetter.

## Filene

| Fil | Hva det er |
| --- | --- |
| `game.html` | Kilden — hele spillet: `<title>`, `<style>`, markup og `<script>`. Rediger denne. |
| `index.html` | Bygget frittstående side (`game.html` pakket i `<!doctype html>` osv.). Det er denne du hoster eller åpner lokalt. |
| `build.sh` | Bygger `index.html` fra `game.html`. Kjør `sh build.sh` etter hver endring. |

Grunnen til todelingen: Claude-artefakter vil ha innholdet uten `<html>`/`<head>`/`<body>`,
mens en vanlig nettside trenger dem. Samme kilde, to innpakninger.

## Spille lokalt

Dobbeltklikk `index.html`. Det er alt — ingen server, ingen internett, ingen avhengigheter.

## Legge det på nett (GitHub Pages, gratis)

1. Lag et nytt repo på [github.com/new](https://github.com/new), f.eks. `asteroider`.
   Sett det til **Public** — Pages krever det på gratiskontoer.
2. Last opp `index.html`, `game.html` og `build.sh` (**Add file → Upload files**).
3. Repo → **Settings** → **Pages** → Source: `Deploy from a branch`, branch `main`,
   mappe `/ (root)` → **Save**.
4. Etter et minutt ligger spillet på `https://<brukernavn>.github.io/asteroider/`.

Vil du ha en kortere adresse, kan du kjøpe et domene (~100 kr/år) og peke det dit
under **Settings → Pages → Custom domain**.

Alternativer som er like enkle: dra mappen inn på [netlify.com/drop](https://app.netlify.com/drop),
eller `vercel deploy`.

## Felles toppliste på tvers av maskiner

Spillet snakker med [Supabase](https://supabase.com) hvis du fyller inn to verdier.
Gratisnivået holder i massevis, og du trenger ikke betalingskort. Uten oppsett
lagres poengene bare i nettleseren — spillet fungerer likevel.

**1. Lag prosjektet.** Logg inn på supabase.com → **New project**. Velg region
`Central EU (Frankfurt)` eller `North EU (Ireland)`. Databasepassordet trenger du
ikke senere, men lagre det et trygt sted.

**2. Lag tabellen.** Åpne **SQL Editor** i menyen til venstre, lim inn og kjør:

```sql
create table public.scores (
  id         uuid primary key default gen_random_uuid(),
  set_id     text        not null,
  name       text        not null,
  score      integer     not null,
  level      integer,
  hits       integer,
  created_at timestamptz not null default now()
);

create index scores_topp on public.scores (set_id, score desc);

alter table public.scores enable row level security;

-- alle kan lese listen
create policy "les toppliste" on public.scores
  for select using (true);

-- alle kan legge til en poengsum, men bare innenfor rimelige grenser
create policy "legg til poengsum" on public.scores
  for insert with check (
    char_length(name)   between 1 and 18
    and char_length(set_id) between 1 and 64
    and score >= 0 and score <= 100000
  );
```

Det finnes med vilje ingen regel for `update` eller `delete`: ingen kan endre
eller slette andres poeng utenfra. Skal du rydde i listen, gjør du det selv under
**Table Editor** i Supabase.

**3. Hent nøklene.** **Project Settings → Data API**: kopier **Project URL** og
nøkkelen som heter **anon public**.

**4. Lim dem inn.** Øverst i `game.html` ligger blokken `const SENTRAL`:

```js
const SENTRAL = {
  url:    "https://abcdefghijkl.supabase.co",
  nokkel: "eyJhbGciOi..."
};
```

Kjør `sh build.sh` etterpå og last opp begge filene på nytt. Hopper du over
byggesteget, blir `index.html` stående med tomme verdier.

`anon public`-nøkkelen er laget for å ligge åpent i nettsider — den gir bare de
rettighetene reglene over tillater. **Service role**-nøkkelen skal derimot aldri
inn i spillet.

Når det virker, står det «Felles toppliste — delt mellom alle som spiller» under
listen. Får spillet ikke kontakt, viser det den lokale listen og sier fra.

Verdt å vite: hvem som helst som besøker siden kan legge inn en poengsum med
hvilket navn de vil. Det holder til en klasseliste, men det er ingen innlogging
bak. Blir det tull, kan du slette rader i **Table Editor**.

## Formatet på spørsmålssett

Én linje per spørsmål:

```
Spørsmål, Svar (tilleggsinfo)
```

- Alt før første komma er spørsmålet, resten er svaret.
- Parentesen trenger du **ikke** skrive — den vises som fasit når du bommer.
  Enkeltord fra parentesen godtas også som svar (`Mestinon (Pyridostigmin)` →
  begge deler godkjennes).
- Har spørsmålet komma i seg, bruk semikolon eller tab som skilletegn i stedet:
  `Spørsmål, med komma; Svar`.
- Skråstrek i svaret gir flere godkjente skrivemåter: `Betablokkere/BB/betablokker`
  godtar alle tre.
- Tomme linjer hoppes over — fint til å skille temaer i filen.

Svarsjekken er tilgivende: store/små bokstaver spiller ingen rolle, æ/ø/å og
tegnsetting ignoreres, og lange ord tåler én til to skrivefeil (`levetirasetam`
godkjennes for `Levetiracetam`).

Egne sett legger du inn under **Egne sett** i menyen — lim inn tekst eller last
opp en `.txt`/`.csv`. De lagres i nettleseren.

## Innebygde sett

- **Nevrologi** (42 spørsmål) — settet fra `MED7/Øving/Asteroids`.
- **Farmakologi** (26 spørsmål) — antiarytmika, antibiotika, angina, hjertesvikt,
  astma og kolesterol. Her er alternative skrivemåter skilt med skråstrek i
  fasiten (`Betablokkere/BB/betablokker`), og alle godkjennes som svar.

Vil du legge til eller bytte ut sett permanent, rediger `BUILTIN_RAW` øverst i
skriptet i `game.html` og kjør `sh build.sh`. Skal et sett bare være ditt eget,
er det enklere å legge det inn under **Egne sett** i menyen.

## Toppliste

Uten oppsett lagres topplisten per spørsmålssett i nettleserens `localStorage`.
Alle som spiller på samme maskin og nettleser deler listen; den følger ikke med
mellom PC-er. Se «Felles toppliste» over for å dele den mellom maskiner.

Poengene lagres alltid lokalt i tillegg, så en runde går ikke tapt om nettet er
nede når du lagrer.

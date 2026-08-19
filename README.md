# Pugge-asteroider

Et skrivespill for pugging. Er en "kopi" av Quizlet sin Gravity: spørsmål faller mot
jorden, og du skriver svaret for å sprenge asteroiden. Du har 3 liv. 

## Filene

| Fil | Hva det er |
| --- | --- |
| `sett/*.txt` | **Spørsmålene.** Vanlige tekstfiler. |
| `game.html` | Kilden til selve spillet: `<title>`, `<style>`, markup og `<script>`. |
| `index.html` | Bygget frittstående side (`game.html` pakket i `<!doctype html>` osv.). |
| `build.sh` | Speiler `sett/*.txt` inn i reservekopiene og bygger `index.html`. |

Grunnen til todelingen av HTML-en: Claude-artefakter vil ha innholdet uten
`<html>`/`<head>`/`<body>`, mens en vanlig nettside trenger dem. Samme kilde, to
innpakninger.

## Endre spørsmål og svar

Rediger tekstfilen for settet:

## Spille lokalt

Dobbeltklikk `index.html`. Kommer ikke opp på topplisten.

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


## Toppliste

Topplisten er felles for alle som spiller, med én liste per spørsmålssett. Den
ligger i Supabase. 
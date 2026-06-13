# H2M Vocabulary Builder

A mobile-first web app for building and managing personal vocabulary, with cloud persistence on Supabase and deployment on Vercel.

## Live App

- Production: [https://h2mvocab.vercel.app](https://h2mvocab.vercel.app)

## Core Features

- **Cloud database storage (Supabase)** for all vocabulary data.
- **Full CRUD** for vocabulary entries.
  - Create new words
  - Read/search words
  - Update existing words
  - Delete words
- **Favorites** with star toggle and a dedicated favorites view.
- **Recency view** to show the latest 10 words added.
- **Sentence Structures tab** for purpose-driven English patterns:
  - Browse purposes, keywords, structures, and example sentences
  - Full CRUD in Supabase (`sentence_purposes`, `sentence_structures`, `sentence_examples`)
  - Purpose-assisted sentence builder with placeholder tokens (`sb`, `sth`, `adj`)
  - Live preview and one-click copy
- **Safari extension scaffold** for quick access from the browser toolbar.
- **Smart search UX**:
  - Real-time filtering
  - Suggestion to add a searched word when no match exists
- **Duplicate prevention**:
  - Blocks adding the same word (case-insensitive)
- **Auto-enrichment** from online APIs:
  - phonetics
  - example
  - synonyms/antonyms/collocations
  - Vietnamese translation (best-effort)
- **Audio pronunciation**:
  - Uses dictionary audio URL when available
  - Falls back to browser speech synthesis
- **Responsive mobile-first UI** with quick action FAB for adding words.
- **Backup export** to a single Excel file (`.xlsx`) with **Vocabulary** and **Structures** sheets.

## Tech Stack

- **Frontend**: HTML, Tailwind CSS (CDN), vanilla JavaScript
- **Icons**: Font Awesome
- **Database / Backend**: Supabase (Postgres + REST)
- **Hosting**: Vercel
- **CI/CD**: GitHub Actions + Vercel CLI deployment workflow
- **Browser extension**: Safari Web Extension (Manifest V3 scaffold)

## Project Structure

```text
vocabApp/
├── index.html                      # Main app UI + client logic
├── image/
│   ├── H2M_logo.png                # Header logo
│   └── favicon.png                 # Browser favicon / OG image reference
├── safari-extension/
│   ├── README.md                   # Safari extension build instructions
│   └── web-extension/
│       ├── manifest.json
│       ├── popup.html
│       ├── popup.css
│       ├── popup.js
│       └── background.js
├── supabase.schema.sql             # DB table + indexes + RLS policies
├── supabase.sentence-structures.schema.sql  # Sentence structures tables + RLS
├── scripts/
│   ├── import-sentence-structures.py        # JSON import for sentence structures
│   └── convert-structure-csv.py             # Convert Structure.csv to import JSON
├── sentence-structures.json                 # Generated import payload from Structure.csv
├── sentence-structures.sample.json          # Small sample import payload
├── DEPLOY_SUPABASE_VERCEL.md       # Step-by-step go-live guide
├── .github/workflows/
│   └── vercel-deploy.yml           # CI/CD workflow for preview + production
├── vercel.json                     # Vercel runtime settings
├── config.example.js               # Optional local runtime config template
├── vocabApp.words.json             # Legacy JSON dataset (reference/import source)
├── vocab_DB - Vocab.cleaned.json   # Cleaned dataset (reference/import source)
└── README.md
```

## Data Model (`vocab_words`)

The app reads/writes to `public.vocab_words` with these main fields:

- `id` (uuid, primary key)
- `word`
- `phonetic`
- `part_of_speech`
- `english_meaning`
- `vietnamese_meaning`
- `synonyms`
- `antonyms`
- `collocations`
- `example_sentence`
- `audio_url`
- `favorite` (boolean)
- `created_at`
- `updated_at`

## Sentence Structures Data Model

Three related tables power the **Structures** tab:

- `sentence_purposes`
  - `title`, `description`, `keywords` (comma-separated phrases)
- `sentence_structures`
  - `purpose_id`, `pattern`, `notes`, `sort_order`
  - Pattern tokens: `sb` (someone), `sth` (something), `adj` (adjective)
- `sentence_examples`
  - `structure_id`, `sentence`

### Import sentence structures JSON

1. Run [`supabase.sentence-structures.schema.sql`](supabase.sentence-structures.schema.sql) in Supabase SQL Editor.
2. Prepare a JSON file like [`sentence-structures.sample.json`](sentence-structures.sample.json), or convert your CSV:

```bash
python3 scripts/convert-structure-csv.py /path/to/Structure.csv -o sentence-structures.json
```

3. Import:

```bash
export SUPABASE_URL="https://YOUR_PROJECT_ID.supabase.co"
export SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
python3 scripts/import-sentence-structures.py sentence-structures.sample.json
```

Use `--force-duplicates` if you want to import purposes even when the title already exists.

## Local Development

1. Clone the repo.
2. Configure Supabase credentials:
   - Option A: hardcoded fallback in `index.html`
   - Option B: create `config.js` from `config.example.js` for local override (localhost), and set:
     - `window.VOCAB_SUPABASE_URL`
     - `window.VOCAB_SUPABASE_ANON_KEY`
     - `window.VOCAB_GEMINI_API_KEY` (optional, for AI Rewrite)
3. Serve the app with any static server.
   - Example: VS Code Live Server
4. Open `index.html` in browser and verify:
   - list loads from DB
   - create/update/delete/favorite works

## Supabase Setup

1. Create a Supabase project.
2. Run `supabase.schema.sql` in SQL Editor.
3. Run `supabase.sentence-structures.schema.sql` for the Structures tab.
4. Import seed data if needed:
   - convert JSON to CSV
   - import into `vocab_words`

## Deployment

### Vercel

1. Connect the GitHub repo to Vercel.
2. Set project/environment variables if needed.
3. Deploy production from `main`.

### CI/CD (GitHub -> Vercel)

Workflow file: `.github/workflows/vercel-deploy.yml`

- On pull request to `main`: preview deploy
- On push to `main`: production deploy

Required GitHub secrets:

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Safari Extension

The repository includes a Safari extension scaffold in `safari-extension/web-extension`.

What it does:

- Opens the app from Safari toolbar
- Quick actions:
  - Open app
  - Open Favorites view (`?view=favorites`)
  - Open Recency view (`?view=recency`)
- Allows saving a custom app URL in extension storage

See detailed instructions in `safari-extension/README.md`.

## Notes

- Current schema/policies are set up for quick launch and testing.
- For stricter production security, tighten RLS policies with authenticated users and ownership-based access.

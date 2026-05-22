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

## Tech Stack

- **Frontend**: HTML, Tailwind CSS (CDN), vanilla JavaScript
- **Icons**: Font Awesome
- **Database / Backend**: Supabase (Postgres + REST)
- **Hosting**: Vercel
- **CI/CD**: GitHub Actions + Vercel CLI deployment workflow

## Project Structure

```text
vocabApp/
├── index.html                      # Main app UI + client logic
├── image/
│   ├── H2M_logo.png                # Header logo
│   └── favicon.png                 # Browser favicon / OG image reference
├── supabase.schema.sql             # DB table + indexes + RLS policies
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

## Local Development

1. Clone the repo.
2. Configure Supabase credentials:
   - Option A: hardcoded fallback in `index.html`
   - Option B: create `config.js` from `config.example.js` and set:
     - `window.VOCAB_SUPABASE_URL`
     - `window.VOCAB_SUPABASE_ANON_KEY`
3. Serve the app with any static server.
   - Example: VS Code Live Server
4. Open `index.html` in browser and verify:
   - list loads from DB
   - create/update/delete/favorite works

## Supabase Setup

1. Create a Supabase project.
2. Run `supabase.schema.sql` in SQL Editor.
3. Import seed data if needed:
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

## Notes

- Current schema/policies are set up for quick launch and testing.
- For stricter production security, tighten RLS policies with authenticated users and ownership-based access.

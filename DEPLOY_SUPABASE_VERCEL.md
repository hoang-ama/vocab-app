# Go-live Guide: Supabase + Vercel + GitHub CI/CD

## 1) Supabase Setup

1. Create a new project in Supabase.
2. Open SQL Editor and run `supabase.schema.sql`.
3. Open `Table Editor` and verify table `vocab_words` exists.

## 2) Import Existing Vocabulary Data

Use Supabase Table Editor import (CSV), or run SQL inserts from your cleaned JSON after converting to CSV.

Recommended columns:

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
- `favorite`

## 3) Local Runtime Config

1. Copy `config.example.js` to `config.js`.
2. Fill your actual values:
   - `VOCAB_SUPABASE_URL`
   - `VOCAB_SUPABASE_ANON_KEY`
3. Open `index.html` with a local server and test create/update/delete/favorite.

## 4) Vercel Project Linking

1. Create/import project on Vercel from GitHub repo.
2. In Vercel project settings, copy:
   - `Project ID`
   - `Org ID` (team/user scope)
3. Create a Vercel token: Account Settings -> Tokens.

## 5) GitHub Secrets for CI/CD

Add these repository secrets in GitHub:

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Workflow file already included: `.github/workflows/vercel-deploy.yml`

- PR to `main` -> preview deploy
- Push to `main` -> production deploy

## 6) Daily Workflow

1. Create feature branch.
2. Commit and push.
3. Open PR -> preview URL generated.
4. Merge PR -> auto deploy production.

## 7) Security Note

Current RLS policies in `supabase.schema.sql` allow anon CRUD for quick launch.
For production with user accounts, tighten policies by owner (`user_id`) and require auth.

create extension if not exists pgcrypto;

create table if not exists public.vocab_words (
  id uuid primary key default gen_random_uuid(),
  word text not null,
  phonetic text default '',
  part_of_speech text default '',
  english_meaning text default '',
  vietnamese_meaning text default '',
  synonyms text default '',
  antonyms text default '',
  collocations text default '',
  example_sentence text default '',
  audio_url text default '',
  favorite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists vocab_words_word_idx on public.vocab_words (word);
create index if not exists vocab_words_updated_at_idx on public.vocab_words (updated_at desc);

alter table public.vocab_words enable row level security;

drop policy if exists "Allow read for anon/auth" on public.vocab_words;
create policy "Allow read for anon/auth"
on public.vocab_words
for select
to anon, authenticated
using (true);

drop policy if exists "Allow insert for anon/auth" on public.vocab_words;
create policy "Allow insert for anon/auth"
on public.vocab_words
for insert
to anon, authenticated
with check (true);

drop policy if exists "Allow update for anon/auth" on public.vocab_words;
create policy "Allow update for anon/auth"
on public.vocab_words
for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "Allow delete for anon/auth" on public.vocab_words;
create policy "Allow delete for anon/auth"
on public.vocab_words
for delete
to anon, authenticated
using (true);

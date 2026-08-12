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

-- Roots & Affixes
create table if not exists public.word_roots (
  id uuid primary key default gen_random_uuid(),
  morpheme text not null,
  type text not null check (type in ('root', 'prefix', 'suffix')),
  meaning text default '',
  origin text default '',
  examples jsonb default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists word_roots_morpheme_idx on public.word_roots (morpheme);

alter table public.word_roots enable row level security;

drop policy if exists "Allow read for anon/auth" on public.word_roots;
create policy "Allow read for anon/auth"
on public.word_roots
for select
to anon, authenticated
using (true);

drop policy if exists "Allow insert for anon/auth" on public.word_roots;
create policy "Allow insert for anon/auth"
on public.word_roots
for insert
to anon, authenticated
with check (true);

drop policy if exists "Allow update for anon/auth" on public.word_roots;
create policy "Allow update for anon/auth"
on public.word_roots
for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "Allow delete for anon/auth" on public.word_roots;
create policy "Allow delete for anon/auth"
on public.word_roots
for delete
to anon, authenticated
using (true);

-- Update vocab_words for Roots & Affixes
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name='vocab_words' and column_name='prefix_id') then
    alter table public.vocab_words add column prefix_id uuid references public.word_roots(id) on delete set null;
  end if;
  if not exists (select 1 from information_schema.columns where table_name='vocab_words' and column_name='root_id') then
    alter table public.vocab_words add column root_id uuid references public.word_roots(id) on delete set null;
  end if;
  if not exists (select 1 from information_schema.columns where table_name='vocab_words' and column_name='suffix_id') then
    alter table public.vocab_words add column suffix_id uuid references public.word_roots(id) on delete set null;
  end if;
  if not exists (select 1 from information_schema.columns where table_name='vocab_words' and column_name='word_family') then
    alter table public.vocab_words add column word_family jsonb default '[]'::jsonb;
  end if;
end
$$;

-- Language Functions schema (replaces sentence_purposes / sentence_structures / sentence_examples)
create extension if not exists pgcrypto;

drop table if exists public.sentence_examples cascade;
drop table if exists public.sentence_structures cascade;
drop table if exists public.sentence_purposes cascade;

create table if not exists public.language_functions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  favorite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.function_structures (
  id uuid primary key default gen_random_uuid(),
  function_id uuid not null references public.language_functions(id) on delete cascade,
  pattern text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.function_phrases (
  id uuid primary key default gen_random_uuid(),
  function_id uuid not null references public.language_functions(id) on delete cascade,
  phrase text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.function_examples (
  id uuid primary key default gen_random_uuid(),
  function_id uuid not null references public.language_functions(id) on delete cascade,
  structure_id uuid references public.function_structures(id) on delete cascade,
  phrase_id uuid references public.function_phrases(id) on delete cascade,
  content text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint function_examples_parent_check check (
    (structure_id is not null and phrase_id is null)
    or (structure_id is null and phrase_id is not null)
  )
);

create index if not exists language_functions_title_idx on public.language_functions (title);
create index if not exists language_functions_favorite_idx on public.language_functions (favorite);
create index if not exists language_functions_updated_at_idx on public.language_functions (updated_at desc);
create index if not exists function_structures_function_id_idx on public.function_structures (function_id);
create index if not exists function_phrases_function_id_idx on public.function_phrases (function_id);
create index if not exists function_examples_function_id_idx on public.function_examples (function_id);
create index if not exists function_examples_structure_id_idx on public.function_examples (structure_id);
create index if not exists function_examples_phrase_id_idx on public.function_examples (phrase_id);

alter table public.language_functions enable row level security;
alter table public.function_structures enable row level security;
alter table public.function_phrases enable row level security;
alter table public.function_examples enable row level security;

drop policy if exists "Allow read language_functions" on public.language_functions;
create policy "Allow read language_functions"
on public.language_functions for select to anon, authenticated using (true);

drop policy if exists "Allow insert language_functions" on public.language_functions;
create policy "Allow insert language_functions"
on public.language_functions for insert to anon, authenticated with check (true);

drop policy if exists "Allow update language_functions" on public.language_functions;
create policy "Allow update language_functions"
on public.language_functions for update to anon, authenticated using (true) with check (true);

drop policy if exists "Allow delete language_functions" on public.language_functions;
create policy "Allow delete language_functions"
on public.language_functions for delete to anon, authenticated using (true);

drop policy if exists "Allow read function_structures" on public.function_structures;
create policy "Allow read function_structures"
on public.function_structures for select to anon, authenticated using (true);

drop policy if exists "Allow insert function_structures" on public.function_structures;
create policy "Allow insert function_structures"
on public.function_structures for insert to anon, authenticated with check (true);

drop policy if exists "Allow update function_structures" on public.function_structures;
create policy "Allow update function_structures"
on public.function_structures for update to anon, authenticated using (true) with check (true);

drop policy if exists "Allow delete function_structures" on public.function_structures;
create policy "Allow delete function_structures"
on public.function_structures for delete to anon, authenticated using (true);

drop policy if exists "Allow read function_phrases" on public.function_phrases;
create policy "Allow read function_phrases"
on public.function_phrases for select to anon, authenticated using (true);

drop policy if exists "Allow insert function_phrases" on public.function_phrases;
create policy "Allow insert function_phrases"
on public.function_phrases for insert to anon, authenticated with check (true);

drop policy if exists "Allow update function_phrases" on public.function_phrases;
create policy "Allow update function_phrases"
on public.function_phrases for update to anon, authenticated using (true) with check (true);

drop policy if exists "Allow delete function_phrases" on public.function_phrases;
create policy "Allow delete function_phrases"
on public.function_phrases for delete to anon, authenticated using (true);

drop policy if exists "Allow read function_examples" on public.function_examples;
create policy "Allow read function_examples"
on public.function_examples for select to anon, authenticated using (true);

drop policy if exists "Allow insert function_examples" on public.function_examples;
create policy "Allow insert function_examples"
on public.function_examples for insert to anon, authenticated with check (true);

drop policy if exists "Allow update function_examples" on public.function_examples;
create policy "Allow update function_examples"
on public.function_examples for update to anon, authenticated using (true) with check (true);

drop policy if exists "Allow delete function_examples" on public.function_examples;
create policy "Allow delete function_examples"
on public.function_examples for delete to anon, authenticated using (true);

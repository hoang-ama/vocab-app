create extension if not exists pgcrypto;

create table if not exists public.sentence_purposes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text default '',
  keywords text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sentence_structures (
  id uuid primary key default gen_random_uuid(),
  purpose_id uuid not null references public.sentence_purposes(id) on delete cascade,
  pattern text not null,
  notes text default '',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sentence_examples (
  id uuid primary key default gen_random_uuid(),
  structure_id uuid not null references public.sentence_structures(id) on delete cascade,
  sentence text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists sentence_purposes_title_idx on public.sentence_purposes (title);
create index if not exists sentence_purposes_updated_at_idx on public.sentence_purposes (updated_at desc);
create index if not exists sentence_structures_purpose_id_idx on public.sentence_structures (purpose_id);
create index if not exists sentence_structures_updated_at_idx on public.sentence_structures (updated_at desc);
create index if not exists sentence_examples_structure_id_idx on public.sentence_examples (structure_id);
create index if not exists sentence_examples_updated_at_idx on public.sentence_examples (updated_at desc);

alter table public.sentence_purposes enable row level security;
alter table public.sentence_structures enable row level security;
alter table public.sentence_examples enable row level security;

drop policy if exists "Allow read sentence_purposes" on public.sentence_purposes;
create policy "Allow read sentence_purposes"
on public.sentence_purposes for select to anon, authenticated using (true);

drop policy if exists "Allow insert sentence_purposes" on public.sentence_purposes;
create policy "Allow insert sentence_purposes"
on public.sentence_purposes for insert to anon, authenticated with check (true);

drop policy if exists "Allow update sentence_purposes" on public.sentence_purposes;
create policy "Allow update sentence_purposes"
on public.sentence_purposes for update to anon, authenticated using (true) with check (true);

drop policy if exists "Allow delete sentence_purposes" on public.sentence_purposes;
create policy "Allow delete sentence_purposes"
on public.sentence_purposes for delete to anon, authenticated using (true);

drop policy if exists "Allow read sentence_structures" on public.sentence_structures;
create policy "Allow read sentence_structures"
on public.sentence_structures for select to anon, authenticated using (true);

drop policy if exists "Allow insert sentence_structures" on public.sentence_structures;
create policy "Allow insert sentence_structures"
on public.sentence_structures for insert to anon, authenticated with check (true);

drop policy if exists "Allow update sentence_structures" on public.sentence_structures;
create policy "Allow update sentence_structures"
on public.sentence_structures for update to anon, authenticated using (true) with check (true);

drop policy if exists "Allow delete sentence_structures" on public.sentence_structures;
create policy "Allow delete sentence_structures"
on public.sentence_structures for delete to anon, authenticated using (true);

drop policy if exists "Allow read sentence_examples" on public.sentence_examples;
create policy "Allow read sentence_examples"
on public.sentence_examples for select to anon, authenticated using (true);

drop policy if exists "Allow insert sentence_examples" on public.sentence_examples;
create policy "Allow insert sentence_examples"
on public.sentence_examples for insert to anon, authenticated with check (true);

drop policy if exists "Allow update sentence_examples" on public.sentence_examples;
create policy "Allow update sentence_examples"
on public.sentence_examples for update to anon, authenticated using (true) with check (true);

drop policy if exists "Allow delete sentence_examples" on public.sentence_examples;
create policy "Allow delete sentence_examples"
on public.sentence_examples for delete to anon, authenticated using (true);

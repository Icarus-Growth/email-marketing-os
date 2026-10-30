-- Interview question: "Do you track A/B tests?"
-- YES: adds an A/B test table. One email can have many tests over time.
-- NO:  skip this file. The "ab_test_result" note on each email is enough.

create table public.ab_tests (
  id             uuid primary key default gen_random_uuid(),
  test_name      text not null,
  client_id      uuid not null references public.clients(id) on delete cascade,
  email_id       uuid references public.emails(id) on delete set null,
  what_tested    text,
  variant_a      text,
  variant_b      text,
  winner         text,
  lift           numeric,
  started_on     date,
  decided_on     date,
  result_notes   text,
  is_example     boolean not null default false,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
comment on table public.ab_tests is 'One A/B test on one email. what_tested is for example: subject line, offer, design.';
create trigger ab_tests_touch_updated_at before update on public.ab_tests
  for each row execute function public.touch_updated_at();
select public.lock_table('ab_tests');

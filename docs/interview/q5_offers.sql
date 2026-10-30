-- Interview question: "Do you keep offers and discount codes for each client?"
-- YES: adds an offers table. Each email can point at one offer.
-- NO:  skip this file. The free-text "offer" column on emails is enough.

create table public.offers (
  id             uuid primary key default gen_random_uuid(),
  offer_name     text not null,
  client_id      uuid not null references public.clients(id) on delete cascade,
  discount_code  text,
  discount       text,
  starts_on      date,
  ends_on        date,
  notes          text,
  is_example     boolean not null default false,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
comment on table public.offers is 'One offer for one client. discount is free text, for example "15% off".';
create trigger offers_touch_updated_at before update on public.offers
  for each row execute function public.touch_updated_at();
select public.lock_table('offers');

alter table public.emails add column offer_id uuid references public.offers(id) on delete set null;

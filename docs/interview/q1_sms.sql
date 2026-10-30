-- Interview question: "Do you also do SMS for clients?"
-- YES: flows and emails get a channel (Email or SMS), and the report numbers get SMS counts.
-- NO:  skip this file.

create type public.message_channel as enum ('Email', 'SMS');

alter table public.clients add column sms_enabled boolean not null default false;
alter table public.flows   add column channel public.message_channel not null default 'Email';
alter table public.emails  add column channel public.message_channel not null default 'Email';
alter table public.daily_metrics
  add column sms_sent    int not null default 0,
  add column sms_revenue numeric(14,2) not null default 0;
alter table public.weekly_metrics
  add column sms_sent    int not null default 0,
  add column sms_revenue numeric(14,2) not null default 0;

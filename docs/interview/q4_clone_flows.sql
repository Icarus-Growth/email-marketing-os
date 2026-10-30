-- Interview question: "Do you copy flows from a master account into each new client?"
-- YES: records where each flow was copied from, and when the copy was done.
-- NO:  skip this file.

alter table public.flows   add column cloned_from text;
alter table public.clients add column master_flows_cloned_at timestamptz;
comment on column public.flows.cloned_from is 'The name of the master flow this one was copied from.';

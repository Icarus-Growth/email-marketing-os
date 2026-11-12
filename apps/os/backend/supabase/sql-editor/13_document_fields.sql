-- SQL editor paste 13 of 19: 0014_document_fields.sql
-- Paste all of this into the Supabase SQL editor and press Run.
-- Wait for "Success" before you paste the next file.

-- =============================================================================
-- 0014  Email marketing: which fields are documents (see 0013)
--
-- The fields below open in the app's editor and in the AI connector's docs.*
-- actions. board = the card table; empty = the client page. The *_url column
-- stays: it is the "paste a link instead".
-- Safe to run twice.
-- =============================================================================

insert into public.document_fields (board, field_key, label, link_column) values
  ('flows', 'brief', 'Brief', 'brief_url'),
  ('flows', 'copy_doc', 'Copy', 'copy_doc_url'),
  ('campaign_calendars', 'copy_doc', 'Copy', 'copy_doc_url'),
  (null, 'research_doc', 'Research doc', 'research_doc_url')
on conflict on constraint document_fields_key do update
  set label = excluded.label, link_column = excluded.link_column;

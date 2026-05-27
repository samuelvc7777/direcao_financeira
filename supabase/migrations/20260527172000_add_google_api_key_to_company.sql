alter table if exists public."Company"
  add column if not exists "googleApiKey" text;

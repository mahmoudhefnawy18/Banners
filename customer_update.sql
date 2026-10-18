-- Run in the SAME Supabase project after the original banner SQL.
-- Replace the email placeholder with your manager sign-in email before running.
-- Does not modify Charge Log tables.
create table if not exists public.banner_requests (
 id uuid primary key default gen_random_uuid(),
 customer_name text not null check(length(customer_name) between 1 and 120),
 customer_email text not null check(length(customer_email) between 3 and 200),
 customer_phone text check(length(customer_phone)<=40),
 banner_size text not null check(banner_size in ('Small — 30 × 60 cm','Medium — 40 × 80 cm','Large — 50 × 90 cm','Custom')),
 custom_dimensions text check(length(custom_dimensions)<=100),
 description text not null check(length(description) between 1 and 3000),
 delivery_address text not null check(length(delivery_address) between 1 and 500),
 postcode text not null check(length(postcode) between 1 and 12),
 due_date date not null,
 image_path text check(length(image_path)<=200),
 reviewed boolean not null default false,
 created_at timestamptz not null default now()
);
alter table public.banner_requests enable row level security;
-- Public may submit only the form columns; no read, update, or delete.
revoke all on public.banner_requests from anon, authenticated;
grant insert (customer_name,customer_email,customer_phone,banner_size,custom_dimensions,description,delivery_address,postcode,due_date,image_path) on public.banner_requests to anon, authenticated;
grant select, update, delete on public.banner_requests to authenticated;
drop policy if exists banner_requests_public_submit on public.banner_requests;
create policy banner_requests_public_submit on public.banner_requests for insert to anon, authenticated with check (reviewed=false);
-- Only the nominated manager can view/change submissions.
drop policy if exists banner_requests_manager_read on public.banner_requests;
create policy banner_requests_manager_read on public.banner_requests for select to authenticated using ((auth.jwt()->>'email') = 'REPLACE_WITH_MANAGER_EMAIL');
drop policy if exists banner_requests_manager_update on public.banner_requests;
create policy banner_requests_manager_update on public.banner_requests for update to authenticated using ((auth.jwt()->>'email') = 'REPLACE_WITH_MANAGER_EMAIL') with check ((auth.jwt()->>'email') = 'REPLACE_WITH_MANAGER_EMAIL');
drop policy if exists banner_requests_manager_delete on public.banner_requests;
create policy banner_requests_manager_delete on public.banner_requests for delete to authenticated using ((auth.jwt()->>'email') = 'REPLACE_WITH_MANAGER_EMAIL');
-- Private image bucket; public visitors can upload images but cannot read them.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values ('banner-designs','banner-designs',false,5242880,array['image/jpeg','image/png','image/webp']) on conflict(id) do update set public=false,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists banner_designs_public_upload on storage.objects;
create policy banner_designs_public_upload on storage.objects for insert to anon, authenticated with check (bucket_id='banner-designs' and (storage.extension(name) in ('jpg','png','webp')));
drop policy if exists banner_designs_manager_read on storage.objects;
create policy banner_designs_manager_read on storage.objects for select to authenticated using (bucket_id='banner-designs' and (auth.jwt()->>'email')='REPLACE_WITH_MANAGER_EMAIL');

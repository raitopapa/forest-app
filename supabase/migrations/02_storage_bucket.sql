-- Create a public bucket for photos
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do nothing;

-- Allow public read access
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'photos' );

-- Allow authenticated users to upload
create policy "Authenticated Upload"
  on storage.objects for insert
  with check ( bucket_id = 'photos' and auth.role() = 'authenticated' );

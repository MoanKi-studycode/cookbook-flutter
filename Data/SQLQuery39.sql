alter table "Favorite" enable row level security;

drop policy if exists "Favorite select own" on "Favorite";
drop policy if exists "Favorite insert own" on "Favorite";
drop policy if exists "Favorite delete own" on "Favorite";
drop policy if exists "Favorite update own" on "Favorite";

create policy "Favorite select own"
on "Favorite"
for select
to authenticated
using ("userId" = auth.uid());

create policy "Favorite insert own"
on "Favorite"
for insert
to authenticated
with check ("userId" = auth.uid());

create policy "Favorite delete own"
on "Favorite"
for delete
to authenticated
using ("userId" = auth.uid());

create policy "Favorite update own"
on "Favorite"
for update
to authenticated
using ("userId" = auth.uid())
with check ("userId" = auth.uid());
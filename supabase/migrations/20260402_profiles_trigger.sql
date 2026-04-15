create or replace function public.update_profile_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists profiles_updated_at_trigger on public.profiles;
create trigger profiles_updated_at_trigger
before update on public.profiles
for each row
execute function public.update_profile_updated_at();

insert into public.teachers (id, name, department)
values
  ('11111111-1111-1111-1111-111111111111', 'Aigerim Saparova', 'Computer Science'),
  ('22222222-2222-2222-2222-222222222222', 'Daniyar Nurgaliyev', 'Mathematics'),
  ('33333333-3333-3333-3333-333333333333', 'Madina Orazbek', 'Physics'),
  ('44444444-4444-4444-4444-444444444444', 'Assel Tursynkyzy', 'English Philology'),
  ('55555555-5555-5555-5555-555555555555', 'Ruslan Bekmuratov', 'Pedagogy')
on conflict (id) do update
set
  name = excluded.name,
  department = excluded.department;

insert into public.subjects (id, name)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Introduction to Programming'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Discrete Mathematics'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Data Structures'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Academic English'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Educational Psychology')
on conflict (id) do update
set
  name = excluded.name;

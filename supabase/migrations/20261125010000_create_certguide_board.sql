-- 자격증 길잡이: 게시판 (프로필, 글, 댓글, 도움돼요)

create table public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 20),
  is_admin     boolean not null default false,
  created_at   timestamptz not null default now()
);

-- 가입하면 프로필을 자동으로 만든다 (구글 이름 또는 이메일 앞부분)
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    left(coalesce(nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
                  nullif(trim(new.raw_user_meta_data->>'name'), ''),
                  split_part(new.email, '@', 1), '사용자'), 20)
  );
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false)
$$;

create table public.posts (
  id         uuid primary key default gen_random_uuid(),
  author_id  uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  cat        text not null check (cat in ('q','tip','pass','free')),
  cert_id    text check (cert_id is null or char_length(cert_id) <= 30),
  title      text not null check (char_length(title) between 1 and 100),
  body       text not null check (char_length(body) between 1 and 5000),
  created_at timestamptz not null default now(),
  edited_at  timestamptz
);
create index posts_created_idx on public.posts (created_at desc);

create table public.comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts(id) on delete cascade,
  author_id  uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  body       text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now()
);
create index comments_post_idx on public.comments (post_id, created_at);

create table public.likes (
  post_id    uuid not null references public.posts(id) on delete cascade,
  user_id    uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

alter table public.profiles enable row level security;
alter table public.posts    enable row level security;
alter table public.comments enable row level security;
alter table public.likes    enable row level security;

-- 읽기: 누구나
create policy "read profiles" on public.profiles for select to anon, authenticated using (true);
create policy "read posts"    on public.posts    for select to anon, authenticated using (true);
create policy "read comments" on public.comments for select to anon, authenticated using (true);
create policy "read likes"    on public.likes    for select to anon, authenticated using (true);

-- 쓰기: 로그인한 사람만, 내 이름으로만
create policy "write own post"    on public.posts    for insert to authenticated with check (author_id = auth.uid());
create policy "write own comment" on public.comments for insert to authenticated with check (author_id = auth.uid());
create policy "write own like"    on public.likes    for insert to authenticated with check (user_id = auth.uid());

create policy "edit own post" on public.posts for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());

-- 삭제: 내 것 또는 관리자
create policy "delete own post"    on public.posts    for delete to authenticated using (author_id = auth.uid() or public.is_admin());
create policy "delete own comment" on public.comments for delete to authenticated using (author_id = auth.uid() or public.is_admin());
create policy "delete own like"    on public.likes    for delete to authenticated using (user_id = auth.uid());

-- 이름 변경은 내 것만 (is_admin 은 바꿀 수 없음)
create policy "update own profile" on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

grant usage on schema public to anon, authenticated;
grant select on public.profiles, public.posts, public.comments, public.likes to anon, authenticated;
grant insert, delete on public.posts, public.comments, public.likes to authenticated;
grant update (display_name) on public.profiles to authenticated;
grant update (cat, cert_id, title, body, edited_at) on public.posts to authenticated;

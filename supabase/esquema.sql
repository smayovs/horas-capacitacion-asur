-- Horas de capacitación · GOLA Cancún
-- Esquema para Supabase: lista de usuarios autorizados con rol, y el reporte vigente.
-- Pégalo completo en SQL Editor y pulsa Run. Se puede volver a ejecutar sin duplicar nada.

-- ---------- tablas ----------
create table if not exists public.perfiles (
  email      text primary key check (email = lower(email) and email like '%@asur.com.mx'),
  nombre     text,
  rol        text not null check (rol in ('admin', 'consulta')),
  creado     timestamptz not null default now(),
  creado_por text
);

-- una sola fila (id = 1) con todos los cursos, en el mismo formato que usa la página
create table if not exists public.reporte (
  id              int primary key default 1 check (id = 1),
  datos           jsonb not null,
  generado        timestamptz not null,
  actualizado     timestamptz not null default now(),
  actualizado_por text
);

alter table public.perfiles enable row level security;
alter table public.reporte  enable row level security;
revoke all on public.perfiles, public.reporte from anon;

-- ---------- rol de quien consulta ----------
-- security definer: lee perfiles sin depender de las políticas de esa misma tabla
create or replace function public.mi_rol() returns text
language sql stable security definer set search_path = public as $$
  select rol from public.perfiles
  where email = lower(coalesce(auth.jwt() ->> 'email', ''))
$$;
revoke all on function public.mi_rol() from public, anon;
grant execute on function public.mi_rol() to authenticated;

-- ---------- permisos del reporte ----------
drop policy if exists "miembros leen el reporte" on public.reporte;
create policy "miembros leen el reporte" on public.reporte
  for select to authenticated using (public.mi_rol() is not null);

drop policy if exists "admins publican el reporte" on public.reporte;
create policy "admins publican el reporte" on public.reporte
  for insert to authenticated with check (public.mi_rol() = 'admin');

drop policy if exists "admins actualizan el reporte" on public.reporte;
create policy "admins actualizan el reporte" on public.reporte
  for update to authenticated using (public.mi_rol() = 'admin') with check (public.mi_rol() = 'admin');

-- ---------- permisos de usuarios ----------
drop policy if exists "ver perfiles" on public.perfiles;
create policy "ver perfiles" on public.perfiles
  for select to authenticated
  using (email = lower(auth.jwt() ->> 'email') or public.mi_rol() = 'admin');

drop policy if exists "admins agregan usuarios" on public.perfiles;
create policy "admins agregan usuarios" on public.perfiles
  for insert to authenticated with check (public.mi_rol() = 'admin');

drop policy if exists "admins cambian roles" on public.perfiles;
create policy "admins cambian roles" on public.perfiles
  for update to authenticated using (public.mi_rol() = 'admin') with check (public.mi_rol() = 'admin');

drop policy if exists "admins quitan usuarios" on public.perfiles;
create policy "admins quitan usuarios" on public.perfiles
  for delete to authenticated using (public.mi_rol() = 'admin');

-- siempre debe quedar al menos un administrador
create or replace function public.proteger_ultimo_admin() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (tg_op = 'DELETE' and old.rol = 'admin')
     or (tg_op = 'UPDATE' and old.rol = 'admin' and new.rol <> 'admin') then
    if (select count(*) from public.perfiles where rol = 'admin' and email <> old.email) = 0 then
      raise exception 'Debe quedar al menos un administrador.';
    end if;
  end if;
  return coalesce(new, old);
end $$;
drop trigger if exists proteger_ultimo_admin on public.perfiles;
create trigger proteger_ultimo_admin before update or delete on public.perfiles
  for each row execute function public.proteger_ultimo_admin();

-- ---------- solo los correos autorizados pueden crear cuenta ----------
-- Se activa en Authentication → Hooks → "Before User Created" → Postgres → public.antes_de_crear_usuario
create or replace function public.antes_de_crear_usuario(event jsonb) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if exists (select 1 from public.perfiles where email = lower(event -> 'user' ->> 'email')) then
    return '{}'::jsonb;
  end if;
  return jsonb_build_object('error', jsonb_build_object(
    'http_code', 403,
    'message', 'Este correo no está autorizado. Pide acceso a un administrador.'));
end $$;
revoke all on function public.antes_de_crear_usuario(jsonb) from public, anon, authenticated;
grant execute on function public.antes_de_crear_usuario(jsonb) to supabase_auth_admin;

-- ---------- primer administrador ----------
insert into public.perfiles (email, nombre, rol, creado_por)
values ('smayorga@asur.com.mx', 'Sergio Samuel Mayorga Valdez', 'admin', 'instalación')
on conflict (email) do update set rol = 'admin';

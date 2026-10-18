create table if not exists public.banner_orders (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 customer_name text not null, order_number text not null, design text, size text not null,
 custom_dimensions text, order_date date not null default current_date, due_date date not null,
 price numeric(12,2) not null default 0 check(price>=0), material_cost numeric(12,2) not null default 0 check(material_cost>=0),
 postage_cost numeric(12,2) not null default 0 check(postage_cost>=0),
 amount_paid numeric(12,2) not null default 0 check(amount_paid>=0 and amount_paid<=price),
 production_status text not null default 'Not started', delivery_status text not null default 'Not sent yet',
 receipt_status text not null default 'Awaiting confirmation', payment_status text not null default 'Not paid',
 tracking_number text, notes text, created_at timestamptz not null default now(),
 unique(user_id,order_number)
);
create table if not exists public.banner_expenses (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 description text not null, category text not null default 'Other', spent_on date not null default current_date,
 amount numeric(12,2) not null check(amount>=0), created_at timestamptz not null default now()
);
alter table public.banner_orders enable row level security;
alter table public.banner_expenses enable row level security;
create policy "Owner only orders" on public.banner_orders for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "Owner only expenses" on public.banner_expenses for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create index if not exists banner_orders_due on public.banner_orders(user_id,due_date,order_date);
create index if not exists banner_expenses_owner on public.banner_expenses(user_id,spent_on);

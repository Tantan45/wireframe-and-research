create extension if not exists "pgcrypto";

create table if not exists public.products (
  id text primary key,
  name text not null,
  category text not null,
  price integer not null,
  image text not null,
  description text,
  highlights text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null,
  quantity integer not null default 1,
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending',
  subtotal integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id text not null,
  product_name text not null,
  unit_price integer not null,
  quantity integer not null default 1,
  image text,
  created_at timestamptz not null default now()
);

create index if not exists cart_items_user_id_idx on public.cart_items (user_id);
create index if not exists orders_user_id_idx on public.orders (user_id);
create index if not exists order_items_order_id_idx on public.order_items (order_id);

alter table public.products enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='products' and policyname='Products are viewable by everyone') then
    create policy "Products are viewable by everyone" on public.products for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='cart_items' and policyname='Users can view their cart') then
    create policy "Users can view their cart" on public.cart_items for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='cart_items' and policyname='Users can insert into their cart') then
    create policy "Users can insert into their cart" on public.cart_items for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='cart_items' and policyname='Users can update their cart') then
    create policy "Users can update their cart" on public.cart_items for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='cart_items' and policyname='Users can delete from their cart') then
    create policy "Users can delete from their cart" on public.cart_items for delete using (auth.uid() = user_id);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='orders' and policyname='Users can view their orders') then
    create policy "Users can view their orders" on public.orders for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='orders' and policyname='Users can insert orders') then
    create policy "Users can insert orders" on public.orders for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='orders' and policyname='Users can update their orders') then
    create policy "Users can update their orders" on public.orders for update using (auth.uid() = user_id);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='order_items' and policyname='Users can view their order items') then
    create policy "Users can view their order items" on public.order_items for select using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='order_items' and policyname='Users can insert order items') then
    create policy "Users can insert order items" on public.order_items for insert with check (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='order_items' and policyname='Users can update order items') then
    create policy "Users can update order items" on public.order_items for update using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='order_items' and policyname='Users can delete order items') then
    create policy "Users can delete order items" on public.order_items for delete using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
  end if;
end $$;

insert into public.products (id, name, category, price, image, description, highlights) values
  ($$cam-fujifilm-x1$$, $$Fujifilm X-T10 Mirrorless$$, $$Cameras$$, 68990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$A compact mirrorless body built for fast autofocus and clean low-light performance.$$, ARRAY[$$24.2MP APS-C sensor$$, $$Dual card slots$$, $$5-axis stabilization$$]),
  ($$cam-fujifilm-7$$, $$Fuji X-T2 Mirrorless$$, $$Cameras$$, 82990, $$https://photographylife.com/wp-content/uploads/2017/03/Fujifilm-X-T2.jpg$$, $$Hybrid stills and cinema-ready 4K for creators who shoot every day.$$, ARRAY[$$Oversampled 4K$$, $$Weather-sealed body$$, $$Dual native ISO$$]),
  ($$cam-fujifilm-8$$, $$Fujifilm X100VI$$, $$Cameras$$, 32990, $$https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMWYaxP3eC6xn3D9KqiW-g7U-M0bdlQRscJw&s$$, $$Lightweight point-and-shoot with crisp color science and fast sharing.$$, ARRAY[$$Flip screen$$, $$Pocket size$$, $$USB-C charging$$]),
  ($$cam-fujifilm-xt5$$, $$Fujifilm X-T5$$, $$Cameras$$, 98990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$High-resolution APS-C body with classic dials and in-body stabilization.$$, ARRAY[$$40.2MP sensor$$, $$7-stop IBIS$$, $$Dual SD slots$$]),
  ($$cam-fujifilm-xs20$$, $$Fujifilm X-S20$$, $$Cameras$$, 74990, $$https://www.fujifilm-x.com/products-cameras-static/x-s20/assets/images/top/dwga_battery_img_01.jpg$$, $$Creator-friendly body with long battery life and fast subject tracking.$$, ARRAY[$$6.2K open-gate$$, $$Vlog modes$$, $$NP-W235 battery$$]),
  ($$cam-fujifilm-xe4$$, $$Fujifilm X-E4$$, $$Cameras$$, 56990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Compact rangefinder-style body for everyday carry and street work.$$, ARRAY[$$26.1MP sensor$$, $$USB-C charging$$, $$Lightweight body$$]),
  ($$cam-fujifilm-xt30-ii$$, $$Fujifilm X-T30 II$$, $$Cameras$$, 52990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Compact, fast hybrid camera with classic dials and quick autofocus.$$, ARRAY[$$4K video$$, $$Film simulations$$, $$Tilting LCD$$]),
  ($$cam-fujifilm-xh2$$, $$Fujifilm X-H2$$, $$Cameras$$, 119990, $$https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4XKmOsbuf7dBpECVSoXEPbYjgPJhLE9N9TA&s$$, $$High-resolution flagship body for studio, landscape, and hybrid creators.$$, ARRAY[$$40.2MP sensor$$, $$8K video$$, $$Pro build$$]),
  ($$cam-fujifilm-xh2s$$, $$Fujifilm X-H2S$$, $$Cameras$$, 129990, $$https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRrfQbPywbUbPQuy30AHYtZ6YkLEW5jhqkLeg&s$$, $$Stacked sensor speed for action, wildlife, and high-frame video.$$, ARRAY[$$26.1MP stacked$$, $$High FPS burst$$, $$Advanced AF$$]),
  ($$cam-fujifilm-gfx50s-ii$$, $$Fujifilm GFX 50S II$$, $$Cameras$$, 199990, $$https://fujifilm-x.b-cdn.net/wp-content/uploads/2021/09/rghs_GFX50SII_thumbnail.jpg?width=480&height=480$$, $$Affordable medium-format body with stunning tonal depth and detail.$$, ARRAY[$$51.4MP medium format$$, $$In-body stabilization$$, $$Weather sealed$$]),
  ($$cam-fujifilm-gfx100s$$, $$Fujifilm GFX 100S$$, $$Cameras$$, 299990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$High-res medium-format camera for commercial and fine-art work.$$, ARRAY[$$102MP sensor$$, $$5-axis IBIS$$, $$Pro color science$$]),
  ($$lens-fujifilm-35$$, $$XF 8mm F3.5 R WR Lens$$, $$Lenses$$, 47990, $$https://camerahaus.com/cdn/shop/files/EHC000835_600x600.jpg?v=1761447693$$, $$A bright prime lens for street and portrait work with creamy bokeh.$$, ARRAY[$$Fast aperture$$, $$Silent focus$$, $$Weather resistant$$]),
  ($$lens-fujifilm-85$$, $$Fujinon XF 30mm f2.8 R LM WR Macro Lens | Henry's$$, $$Lenses$$, 33990, $$https://images-us-prod.cms.commerce.dynamics.com/cms/api/hbzzfqllpg/imageFileData/search?fileName=/Products%2FV568FUJ048%20%5E%20%20%5E%20Fuji%20X%20%5E%20black%20%5E%20New_000_001.png&fallback=/Products/V568FUJ048_000_001.jpg,/Products/V568FUJ048_000_001.png,/Products/V568FUJ048_000_001.webp&w=0&h=772&q=100&m=6$$, $$Portrait lens tuned for sharp eyes and smooth backgrounds.$$, ARRAY[$$11-blade diaphragm$$, $$Nano coating$$, $$Metal mount$$]),
  ($$lens-fujifilm-18-55$$, $$Fujinon XF 18-55mm f/2.8-4 R LM OIS$$, $$Lenses$$, 32990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Versatile everyday zoom with optical stabilization and fast, silent focus.$$, ARRAY[$$OIS stabilization$$, $$Compact zoom$$, $$Quiet AF$$]),
  ($$lens-fujifilm-56$$, $$Fujinon XF 56mm f/1.2 R$$, $$Lenses$$, 47990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Portrait prime built for creamy bokeh and sharp subject separation.$$, ARRAY[$$f/1.2 aperture$$, $$Fast prime$$, $$Metal mount$$]),
  ($$lens-fujifilm-23-14$$, $$Fujinon XF 23mm f/1.4 R LM WR$$, $$Lenses$$, 55990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Wide prime for street, travel, and environmental portraits.$$, ARRAY[$$f/1.4 aperture$$, $$Weather resistant$$, $$Fast linear motor$$]),
  ($$lens-fujifilm-33-14$$, $$Fujinon XF 33mm f/1.4 R LM WR$$, $$Lenses$$, 57990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Standard prime with excellent sharpness and smooth falloff.$$, ARRAY[$$f/1.4 aperture$$, $$Quiet AF$$, $$All-metal body$$]),
  ($$lens-fujifilm-16-55$$, $$Fujinon XF 16-55mm f/2.8 R LM WR$$, $$Lenses$$, 69990, $$https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTliFy_Eqh-munY90uYzHFcbF_JYinzLhmxHw&s$$, $$Workhorse zoom for events and everyday pro coverage.$$, ARRAY[$$Constant f/2.8$$, $$Weather sealed$$, $$Fast zoom$$]),
  ($$lens-fujifilm-50-140$$, $$Fujinon XF 50-140mm f/2.8 R LM OIS WR$$, $$Lenses$$, 89990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Telephoto zoom with stabilization for sports and portraits.$$, ARRAY[$$OIS stabilization$$, $$Constant f/2.8$$, $$Pro build$$]),
  ($$lens-fujifilm-10-24$$, $$Fujinon XF 10-24mm f/4 R OIS WR$$, $$Lenses$$, 61990, $$https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQcD7hFWzbZcVxDwYfsVOKxNscyFLcOvP3nqA&s$$, $$Ultra-wide zoom for architecture, travel, and interiors.$$, ARRAY[$$OIS stabilization$$, $$Ultra-wide$$, $$Weather resistant$$]),
  ($$lens-fujifilm-90-20$$, $$Fujinon XF 90mm f/2 R LM WR$$, $$Lenses$$, 58990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Fast telephoto prime with crisp detail and smooth bokeh.$$, ARRAY[$$f/2 aperture$$, $$Fast linear motor$$, $$Weather sealed$$]),
  ($$acc-tripod-neo$$, $$Neo Carbon Tripod$$, $$Accessories$$, 8990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Travel-ready tripod with quick-lock legs and a compact carry case.$$, ARRAY[$$1.4 kg$$, $$160 cm height$$, $$Arca head$$]),
  ($$acc-light-panel$$, $$Lumen Pro LED Panel$$, $$Accessories$$, 5990, $$https://images.unsplash.com/photo-1519183071298-a2962be96c7c?auto=format&fit=crop&w=1200&q=80$$, $$Soft, adjustable light with bi-color control and battery support.$$, ARRAY[$$3200-5600K$$, $$Battery slot$$, $$Diffuser included$$]),
  ($$acc-lens-filter-set$$, $$Lens Filter Set$$, $$Accessories$$, 7495, $$https://images.squarespace-cdn.com/content/v1/67f5cab6225dcf7a8c5efa83/c892de05-64f5-4f95-818d-3afdf9942902/revolution.jpg$$, $$Compact filter set with over expose cover.$$, ARRAY[$$Directional mic$$, $$Shock mount$$, $$Carry pouch$$]),
  ($$bag-travel-shell$$, $$Eirmai Waterproof Camera Backpack$$, $$Accessories$$, 6990, $$https://jgsuperstore.com/cdn/shop/products/EIRMAIEMB-D2330S-Z.jpg?v=1647402116$$, $$Eirmai Waterproof Camera Backpack Photography Bag with Tripod Compartment for Travel Photographers Videographers.$$, ARRAY[$$Water resistant$$, $$Quick access$$, $$Laptop sleeve$$]),
  ($$acc-battery-pack$$, $$Endurance Battery Pack$$, $$Accessories$$, 8495, $$https://3.img-dpreview.com/files/p/E~C0x107S2048x1152T1200x675~articles/2527438260/C2618145-EFC2-40C3-B9A9-C3A8082C28A7.jpeg$$, $$High-capacity battery with smart charge indicator for long shoots.$$, ARRAY[$$USB-C fast charge$$, $$Overheat protection$$, $$Compact build$$]),
  ($$acc-camera-strap$$, $$Heritage Leather Strap$$, $$Accessories$$, 2490, $$https://m.media-amazon.com/images/I/81vDs7DXfiL._AC_SL1500_.jpg$$, $$Comfortable leather strap with quick-release anchors.$$, ARRAY[$$Genuine leather$$, $$Quick release$$, $$Soft padding$$]),
  ($$acc-sd-card$$, $$SanDisk Extreme Pro 1TB microSDXC UHS-I Card with Adapter [200/140MB/s]$$, $$Accessories$$, 10000, $$https://gameone.ph/media/catalog/product/mpiowebpcache/d378a0f20f83637cdb1392af8dc032a2/s/a/sandisk-1tb-extreme-pro-micro-sdxc-card-_200mbs140mbs_.webp$$, $$High-speed card for burst shooting and 4K capture.$$, ARRAY[$$UHS-II$$, $$Fast write speeds$$, $$256GB$$]),
  ($$acc-cleaning-kit$$, $$Optics Cleaning Kit$$, $$Accessories$$, 1780, $$https://images-cdn.ubuy.co.in/669218c881454949df7ff0e6-hvxrjkn-professional-lens-filter.jpg$$, $$All-in-one kit for lenses, screens, and sensors.$$, ARRAY[$$Microfiber$$, $$Air blower$$, $$Lens-safe solution$$]),
  ($$acc-camera-cage$$, $$Creator Camera Cage$$, $$Accessories$$, 4734, $$https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdVbelckZ5hDoyknmEK_g1DLN8KsKbROZQuA&s$$, $$Rig-friendly cage with multiple mounting points for video setups.$$, ARRAY[$$Arca base$$, $$Cold shoe mounts$$, $$Lightweight alloy$$]),
  ($$acc-flash-speedlite$$, $$Lumen TTL Speedlite$$, $$Accessories$$, 7990, $$https://img.fruugo.com/product/3/16/1920465163_max.jpg$$, $$Portable flash with TTL and high-speed sync.$$, ARRAY[$$TTL metering$$, $$HSS support$$, $$Rechargeable pack$$]),
  ($$acc-wireless-mic$$, $$Wireless Mic Duo$$, $$Accessories$$, 8499, $$https://jgsuperstore.com/cdn/shop/products/HOLLYLANDLARKM1DUO_1.jpg?v=1673663512$$, $$Dual-channel wireless mic set for interviews and vlogging.$$, ARRAY[$$Dual transmitters$$, $$Noise reduction$$, $$USB-C charging$$])
on conflict (id) do update set
  name = excluded.name,
  category = excluded.category,
  price = excluded.price,
  image = excluded.image,
  description = excluded.description,
  highlights = excluded.highlights;

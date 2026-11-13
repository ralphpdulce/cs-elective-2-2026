-- ============================================================
-- Supabase Schema & Seed Script for backend-auth
-- Mobile App Development | CS Elective 2
-- API Courtesy of: Devesh Anand's Genshin Impact API
-- (https://github.com/devesh-anand/genshin-api)
-- ============================================================

-- 1. Create the products table
CREATE TABLE IF NOT EXISTS public.products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  rating NUMERIC(3, 2) DEFAULT 4.5,
  badge TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies for Anonymous (Public) access
DROP POLICY IF EXISTS "Allow public read access" ON public.products;
CREATE POLICY "Allow public read access" 
  ON public.products 
  FOR SELECT 
  USING (true);

DROP POLICY IF EXISTS "Allow public insert access" ON public.products;
CREATE POLICY "Allow public insert access" 
  ON public.products 
  FOR INSERT 
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update access" ON public.products;
CREATE POLICY "Allow public update access" 
  ON public.products 
  FOR UPDATE 
  USING (true);

DROP POLICY IF EXISTS "Allow public delete access" ON public.products;
CREATE POLICY "Allow public delete access" 
  ON public.products 
  FOR DELETE 
  USING (true);

-- 4. Seed initial character catalog
TRUNCATE TABLE public.products;

INSERT INTO public.products (id, name, price, category, image_url, rating, badge, description)
VALUES
  ('zhongli', 'Zhongli', 1499.99, 'Geo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/zhongli/card.png', 5.0, '5★ ARCHON', '"Vago Mundo". Zhongli is a 5★ Geo character from Liyue, wielding a Polearm. A consultant of the Wangsheng Funeral Parlor with profound ancient wisdom.'),
  ('raiden', 'Raiden Shogun', 1449.99, 'Electro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/raiden/card.png', 5.0, '5★ ARCHON', '"Plane of Euthymia". Raiden Shogun is a 5★ Electro character from Inazuma, wielding a Polearm. The supreme ruler of the Inazuma Shogunate who pursues eternity.'),
  ('furina', 'Furina', 1399.99, 'Hydro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/furina/card.png', 4.9, '5★ ARCHON', '"Endless Solo of Solitude". Furina is a 5★ Hydro character from Fontaine, wielding a Sword. The beloved former Hydro Archon and supreme drama queen of Fontaine.'),
  ('nahida', 'Nahida', 1499.99, 'Dendro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/nahida/card.png', 5.0, '5★ ARCHON', '"Physic of Purity". Nahida is a 5★ Dendro character from Sumeru, wielding a Catalyst. Lesser Lord Kusanali, who guides her people with boundless curiosity and empathy.'),
  ('venti', 'Venti', 1349.99, 'Anemo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/venti/card.png', 4.9, '5★ ARCHON', '"Windborne Bard". Venti is a 5★ Anemo character from Mondstadt, wielding a Bow. A carefree bard who loves dandelion wine and wanders the winds of freedom.'),
  ('hu-tao', 'Hu Tao', 1299.99, 'Pyro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/hu-tao/card.png', 4.9, '5★ LEGENDARY', '"Fragrance in Thaw". Hu Tao is a 5★ Pyro character from Liyue, wielding a Polearm. The 77th Director of the Wangsheng Funeral Parlor, playful yet revered.'),
  ('neuvillette', 'Neuvillette', 1299.99, 'Hydro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/neuvillette/card.png', 5.0, '5★ LEGENDARY', '"Ordainer of Inexorable Judgment". Neuvillette is a 5★ Hydro character from Fontaine, wielding a Catalyst. The Iudex of Fontaine whose authority echoes through justice.'),
  ('kazuha', 'Kaedehara Kazuha', 1249.99, 'Anemo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/kazuha/card.png', 4.9, '5★ LEGENDARY', '"Scarlet Leaves Pursue Wild Waves". Kaedehara Kazuha is a 5★ Anemo character from Inazuma, wielding a Sword. A gentle wandering samurai attuned to nature''s melody.'),
  ('ayaka', 'Kamisato Ayaka', 1199.99, 'Cryo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/ayaka/card.png', 4.9, '5★ LEGENDARY', '"Frostflake Heron". Kamisato Ayaka is a 5★ Cryo character from Inazuma, wielding a Sword. The noble and elegant Shirasagi Himegimi of the Yashiro Commission.'),
  ('diluc', 'Diluc', 999.99, 'Pyro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/diluc/card.png', 4.8, '5★ LEGENDARY', '"The Darknight Hero". Diluc is a 5★ Pyro character from Mondstadt, wielding a Claymore. The tycoon of Dawn Winery protecting Mondstadt from the shadows.'),
  ('alhaitham', 'Alhaitham', 1149.99, 'Dendro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/alhaitham/card.png', 4.9, '5★ LEGENDARY', '"Admonishing Instruction". Alhaitham is a 5★ Dendro character from Sumeru, wielding a Sword. The sharp-minded Scribe of the Sumeru Akademiya.'),
  ('navia', 'Navia', 1099.99, 'Geo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/navia/card.png', 4.8, '5★ LEGENDARY', '"Helm of the Radiant Rose". Navia is a 5★ Geo character from Fontaine, wielding a Claymore. The resilient and charismatic President of Spina di Rosula.'),
  ('bennett', 'Bennett', 349.99, 'Pyro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/bennett/card.png', 4.7, '4★ FEATURED', '"Trial by Fire". Bennett is a 4★ Pyro character from Mondstadt, wielding a Sword. The righteous leader of Benny''s Adventure Team whose optimism defies misfortune.'),
  ('xingqiu', 'Xingqiu', 389.99, 'Hydro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/xingqiu/card.png', 4.7, '4★ FEATURED', '"Juvenile Galant". Xingqiu is a 4★ Hydro character from Liyue, wielding a Sword. Second son of the Feiyun Commerce Guild and a master of the Guhua sword arts.'),
  ('xiangling', 'Xiangling', 329.99, 'Pyro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/xiangling/card.png', 4.6, '4★ FEATURED', '"Exquisite Delicacy". Xiangling is a 4★ Pyro character from Liyue, wielding a Polearm. The head chef at Wanmin Restaurant accompanied by the fiery god Guoba.'),
  ('fischl', 'Fischl', 369.99, 'Electro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/fischl/card.png', 4.6, '4★ FEATURED', '"Prinzessin der Verurteilung!". Fischl is a 4★ Electro character from Mondstadt, wielding a Bow. The investigator of the Adventurers'' Guild guided by Oz the night raven.'),
  ('sucrose', 'Sucrose', 299.99, 'Anemo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/sucrose/card.png', 4.5, '4★ FEATURED', '"Harmless Sweetie". Sucrose is a 4★ Anemo character from Mondstadt, wielding a Catalyst. An alchemist specializing in bio-alchemy with insatiable curiosity.'),
  ('ningguang', 'Ningguang', 419.99, 'Geo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/ningguang/card.png', 4.7, '4★ FEATURED', '"Eclipsing Star". Ningguang is a 4★ Geo character from Liyue, wielding a Catalyst. The Tianquan of the Liyue Qixing who commands the floating Jade Chamber.'),
  ('ganyu', 'Ganyu', 1199.99, 'Cryo', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/ganyu/card.png', 4.9, '5★ LEGENDARY', '"Plenilune Gaze". Ganyu is a 5★ Cryo character from Liyue, wielding a Bow. The half-qilin general secretary for the Yuehai Pavilion serving Liyue for millennia.'),
  ('gaming', 'Gaming', 279.99, 'Pyro', 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/gaming/card.png', 4.5, '4★ FEATURED', '"Leonine Vanguard". Gaming is a 4★ Pyro character from Liyue, wielding a Claymore. A transport guard for the Sword and Strongbox Secure Transport Agency and Wushou dance artist.');

-- ============================================================
-- Supabase Schema & Seed Script for backend-filter-pagination
-- Mobile App Development | CS Elective 2
-- ============================================================

-- 1. Create the products table
CREATE TABLE IF NOT EXISTS public.products (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
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
-- (Allows students/graders to test CRUD operations without auth setup)
CREATE POLICY "Allow public read access" 
  ON public.products 
  FOR SELECT 
  USING (true);

CREATE POLICY "Allow public insert access" 
  ON public.products 
  FOR INSERT 
  WITH CHECK (true);

CREATE POLICY "Allow public update access" 
  ON public.products 
  FOR UPDATE 
  USING (true);

CREATE POLICY "Allow public delete access" 
  ON public.products 
  FOR DELETE 
  USING (true);

-- 4. Seed initial products
-- (Clean existing records if any, then re-seed)
TRUNCATE TABLE public.products;

INSERT INTO public.products (id, name, price, category, image_url, rating, badge, description)
VALUES
  (
    '1',
    'Thrilling Tales of Dragon Slayers',
    99.99,
    'Weapons',
    'assets/images/thrilling-tales-of-dragon-slayers-banner.png',
    4.8,
    'BESTSELLER',
    'A fictional story of a band of five heroes who go off on a dragon hunt. It is poorly written and structurally incoherent. Its value lies in the many lessons that can be learned from failure.'
  ),
  (
    '2',
    'Wind-Powered Wind Generator',
    399.99,
    'Gadgets',
    'assets/images/wind-powered-wind-generator-banner.png',
    4.6,
    'NEW',
    'A wind generating device developed by Refait, senior researcher from Fontaine Research Institute of Kinetic Energy Engineering.'
  ),
  (
    '3',
    'Kagura''s Verity',
    899.99,
    'Weapons',
    'assets/images/kaguras-verity-banner.png',
    4.9,
    NULL,
    'Where once there were dances before the throne, the sounds of the bells still linger. The white silhouette, once something to pursue, never returned, yet it remains an unceasing dream.'
  ),
  (
    '4',
    '"The Boon of the Elder Tree"',
    299.99,
    'Gadgets',
    'assets/images/the-boon-of-the-elder-tree.png',
    4.4,
    NULL,
    'Talismans of this kind are often seen in the forests in Sumeru. They possess the ability to gather the power of grass and trees.'
  ),
  (
    '5',
    'Prithiva Topaz Gemstone',
    1499.99,
    'Gemstones',
    'assets/images/prithiva-topaz-gemstone.png',
    5.0,
    'SALE 15%',
    'Character Ascension material. "The currencies that flow through this land are my flesh and blood. For thus did I become the guarantor of the people''s hard work, wisdom, and future."'
  ),
  (
    '6',
    'Windsong Lyre',
    39.99,
    'Gadgets',
    'assets/images/windsong-lyre.png',
    4.3,
    NULL,
    'Use this traditional instrument from Mondstadt to play songs. An instrument of incredible workmanship, it will surely produce moving music when played by able hands.'
  ),
  (
    '7',
    'Philosophies of Justice',
    499.99,
    'Talent Books',
    'assets/images/philosophies-of-justice.png',
    4.7,
    NULL,
    'A comprehensive guide to the principles of justice and fairness in the court of Fontaine.'
  ),
  (
    '8',
    'Vajrada Amethyst Gemstone',
    1499.99,
    'Gemstones',
    'assets/images/vajrada-amethyst-gemstone.png',
    4.2,
    NULL,
    'Character Ascension material. "This body is the noblest and most eminent of all in this world. It should hold absolute control over this world."'
  ),
  (
    '9',
    'The Catch',
    499.99,
    'Weapons',
    'assets/images/the-catch-banner.png',
    4.2,
    'HOT',
    'The favored barbed spear of a famous Inazuman bandit. It was originally a harpoon used to catch fish, but it was also very handy in battle.'
  ),
  (
    '10',
    'Electro Treasure Compass',
    249.99,
    'Gadgets',
    'assets/images/electro-treasure-compass-banner.png',
    4.5,
    NULL,
    'A handy tool used in Inazuma to search for nearby chests. Points toward the closest chest in the vicinity.'
  ),
  (
    '11',
    'Philosophies of Transience',
    549.99,
    'Talent Books',
    'assets/images/philosophies-of-transience.png',
    4.8,
    NULL,
    'Transience is the dream of the nation of thunder. Fleeting youth and fleeting beauty must be treasured.'
  ),
  (
    '12',
    'Ultra-Hot Burner Lamp (Test Model)',
    189.99,
    'Gadgets',
    'assets/images/ultra-hot-burner-lamp-test-model.png',
    4.1,
    NULL,
    'An experimental burner device that accelerates food processing efficiency through high-temperature ore fuel.'
  ),
  (
    '13',
    'A Thousand Floating Dreams',
    1099.99,
    'Weapons',
    'assets/images/kaguras-verity-banner.png',
    4.9,
    'BESTSELLER',
    'A lamp that shines with the light of dreams of a thousand nights, passed down through the ages.'
  ),
  (
    '14',
    'Vayuda Turquoise Gemstone',
    1399.99,
    'Gemstones',
    'assets/images/prithiva-topaz-gemstone.png',
    4.7,
    NULL,
    'Character Ascension material. "Still, the winds change direction. Someday, they will blow towards a brighter future."'
  ),
  (
    '15',
    'Shivada Jade Gemstone',
    1450.00,
    'Gemstones',
    'assets/images/vajrada-amethyst-gemstone.png',
    4.6,
    NULL,
    'Character Ascension material. "Sorry... to also have you shoulder the grievances of the world."'
  ),
  (
    '16',
    'Philosophies of Diligence',
    450.00,
    'Talent Books',
    'assets/images/philosophies-of-justice.png',
    4.5,
    NULL,
    'Diligence is the foundation of the city of rock. Industry and perseverance pave the road to prosperity.'
  );

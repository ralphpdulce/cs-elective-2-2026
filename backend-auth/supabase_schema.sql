-- ============================================================
-- Supabase Schema & Seed Script for backend-auth
-- Mobile App Development | CS Elective 2
-- API Courtesy of: Devesh Anand's Genshin Impact API & Enka Network
-- Includes Characters, Weapons, & Materials with authentic lore
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

-- 4. Seed initial comprehensive catalog (Characters, Weapons, Materials)
TRUNCATE TABLE public.products;

INSERT INTO public.products (id, name, price, category, image_url, rating, badge, description)
VALUES
  ('char-zhongli', 'Zhongli', 1499.99, 'Geo', 'https://enka.network/ui/UI_AvatarIcon_Zhongli_Card.png', 5.0, '5★ ARCHON', 'A mysterious expert contracted by the Wangsheng Funeral Parlor. Extremely knowledgeable in all things.'),
  ('char-raiden-shogun', 'Raiden Shogun', 1499.99, 'Electro', 'https://enka.network/ui/UI_AvatarIcon_Shougun_Card.png', 5.0, '5★ ARCHON', 'Her Excellency, the Almighty Narukami Ogosho, who promised the people of Inazuma an unchanging Eternity.'),
  ('char-furina', 'Furina', 1499.99, 'Hydro', 'https://enka.network/ui/UI_AvatarIcon_Furina_Card.png', 5.0, '5★ ARCHON', 'The absolute focus of the stage of judgment, until the final applause sounds.'),
  ('char-nahida', 'Nahida', 1499.99, 'Dendro', 'https://enka.network/ui/UI_AvatarIcon_Nahida_Card.png', 5.0, '5★ ARCHON', 'A caged bird secluded within the confines of the Sanctuary of Surasthana who can only see the world in her dreams.'),
  ('char-venti', 'Venti', 1499.99, 'Anemo', 'https://enka.network/ui/UI_AvatarIcon_Venti_Card.png', 5.0, '5★ ARCHON', 'One of the many bards of Mondstadt, who freely wanders the city''s streets and alleys.'),
  ('char-hu-tao', 'Hu Tao', 1199.99, 'Pyro', 'https://enka.network/ui/UI_AvatarIcon_Hutao_Card.png', 4.9, '5★ LEGENDARY', 'The 77th Director of the Wangsheng Funeral Parlor. She took over the business at a rather young age.'),
  ('char-neuvillette', 'Neuvillette', 1199.99, 'Hydro', 'https://enka.network/ui/UI_AvatarIcon_Neuvillette_Card.png', 4.9, '5★ LEGENDARY', 'The Chief Justice of Fontaine, known as the Iudex, is renowned for his unassailable impartiality.'),
  ('char-kaedehara-kazuha', 'Kaedehara Kazuha', 1199.99, 'Anemo', 'https://enka.network/ui/UI_AvatarIcon_Kazuha_Card.png', 4.9, '5★ LEGENDARY', 'A wandering samurai from Inazuma who is currently with Liyue''s Crux Fleet. A gentle and carefree soul whose heart hides a great many burdens from the past.'),
  ('char-kamisato-ayaka', 'Kamisato Ayaka', 1199.99, 'Cryo', 'https://enka.network/ui/UI_AvatarIcon_Ayaka_Card.png', 4.9, '5★ LEGENDARY', 'Daughter of the Yashiro Commission''s Kamisato Clan. Dignified and elegant, as well as wise and strong.'),
  ('char-diluc', 'Diluc', 1199.99, 'Pyro', 'https://enka.network/ui/UI_AvatarIcon_Diluc_Card.png', 4.9, '5★ LEGENDARY', 'The tycoon of a winery empire in Mondstadt, unmatched in every possible way.'),
  ('char-alhaitham', 'Alhaitham', 1199.99, 'Dendro', 'https://enka.network/ui/UI_AvatarIcon_Alhatham_Card.png', 4.9, '5★ LEGENDARY', 'The current scribe of the Sumeru Akademiya, a man endowed with extraordinary intelligence and talent. He lives free — free from the searching eyes of ordinary people, anyway.'),
  ('char-navia', 'Navia', 1199.99, 'Geo', 'https://enka.network/ui/UI_AvatarIcon_Navia_Card.png', 4.9, '5★ LEGENDARY', 'The current President of Spina di Rosula, who is lovely, dutiful, and a great boss.'),
  ('char-bennett', 'Bennett', 349.99, 'Pyro', 'https://enka.network/ui/UI_AvatarIcon_Bennett_Card.png', 4.6, '4★ FEATURED', 'A good-natured adventurer from Mondstadt who''s unfortunately extremely unlucky.'),
  ('char-xingqiu', 'Xingqiu', 349.99, 'Hydro', 'https://enka.network/ui/UI_AvatarIcon_Xingqiu_Card.png', 4.6, '4★ FEATURED', 'A young man carrying a longsword who is frequently seen at book booths. He has a chivalrous heart and yearns for justice and fairness for all.'),
  ('char-xiangling', 'Xiangling', 349.99, 'Pyro', 'https://enka.network/ui/UI_AvatarIcon_Xiangling_Card.png', 4.6, '4★ FEATURED', 'A renowned chef from Liyue. She''s extremely passionate about cooking and excels at making her signature hot and spicy dishes.'),
  ('char-fischl', 'Fischl', 349.99, 'Electro', 'https://enka.network/ui/UI_AvatarIcon_Fischl_Card.png', 4.6, '4★ FEATURED', 'A mysterious girl who calls herself "Prinzessin der Verurteilung" and travels with a night raven named Oz.'),
  ('char-gorou', 'Gorou', 349.99, 'Geo', 'https://enka.network/ui/UI_AvatarIcon_Gorou_Card.png', 4.6, '4★ FEATURED', 'The great general of Watatsumi Island''s forces. He is deeply trusted by his subordinates.'),
  ('char-sucrose', 'Sucrose', 349.99, 'Anemo', 'https://enka.network/ui/UI_AvatarIcon_Sucrose_Card.png', 4.6, '4★ FEATURED', 'An alchemist filled with curiosity about all things. She researches bio-alchemy.'),
  ('char-ningguang', 'Ningguang', 349.99, 'Geo', 'https://enka.network/ui/UI_AvatarIcon_Ningguang_Card.png', 4.6, '4★ FEATURED', 'The Tianquan of the Liyue Qixing. Her wealth is unsurpassed in all of Teyvat.'),
  ('char-ganyu', 'Ganyu', 1199.99, 'Cryo', 'https://enka.network/ui/UI_AvatarIcon_Ganyu_Card.png', 4.9, '5★ LEGENDARY', 'The secretary at Yuehai Pavilion. The blood of the qilin, an illuminated beast, flows within her veins.'),
  ('char-gaming', 'Gaming', 349.99, 'Pyro', 'https://enka.network/ui/UI_AvatarIcon_Gaming_Card.png', 4.6, '4★ FEATURED', 'Guard of the Sword and Strongbox Secure Transport Agency, and the head of the "Mighty Mythical Beasts" Wushou troupe.'),
  ('char-xiao', 'Xiao', 1199.99, 'Anemo', 'https://enka.network/ui/UI_AvatarIcon_Xiao_Card.png', 4.9, '5★ LEGENDARY', 'A yaksha adeptus who defends Liyue. Also heralded as the "Conqueror of Demons" and "Vigilant Yaksha."'),
  ('char-yelan', 'Yelan', 1199.99, 'Hydro', 'https://enka.network/ui/UI_AvatarIcon_Yelan_Card.png', 4.9, '5★ LEGENDARY', 'A mysterious person who claims to work for the Ministry of Civil Affairs, but is a "non-entity" on the Ministry of Civil Affairs'' list.'),
  ('char-klee', 'Klee', 1199.99, 'Pyro', 'https://enka.network/ui/UI_AvatarIcon_Klee_Card.png', 4.9, '5★ LEGENDARY', 'An explosives expert and a regular at the Knights of Favonius''s confinement room. Also known as Fleeing Sunlight.'),
  ('char-wriothesley', 'Wriothesley', 1199.99, 'Cryo', 'https://enka.network/ui/UI_AvatarIcon_Wriothesley_Card.png', 4.9, '5★ LEGENDARY', 'Duke of the Fortress of Meropide, Lord Incognito of the murky depths.'),
  ('char-yae-miko', 'Yae Miko', 1199.99, 'Electro', 'https://enka.network/ui/UI_AvatarIcon_Yae_Card.png', 4.9, '5★ LEGENDARY', 'Lady Guuji of the Grand Narukami Shrine. Also serves as the editor-in-chief of Yae Publishing House. Unimaginable intelligence and cunning are hidden under her beautiful appearance.'),
  ('char-kuki-shinobu', 'Kuki Shinobu', 349.99, 'Electro', 'https://enka.network/ui/UI_AvatarIcon_Shinobu_Card.png', 4.6, '4★ FEATURED', 'The capable and reliable Arataki Gang deputy leader - Please note: capable and reliable are not appellations for the "Arataki Gang," but for their deputy leader in specific.'),
  ('char-jean', 'Jean', 1199.99, 'Anemo', 'https://enka.network/ui/UI_AvatarIcon_Qin_Card.png', 4.9, '5★ LEGENDARY', 'The righteous and rigorous Dandelion Knight, and Acting Grand Master of Mondstadt''s Knights of Favonius.'),
  ('char-sangonomiya-kokomi', 'Sangonomiya Kokomi', 1199.99, 'Hydro', 'https://enka.network/ui/UI_AvatarIcon_Kokomi_Card.png', 4.9, '5★ LEGENDARY', 'The Divine Priestess of Watatsumi Island. All of the island''s affairs are at this young lady''s fingertips.'),
  ('char-yaoyao', 'Yaoyao', 349.99, 'Dendro', 'https://enka.network/ui/UI_AvatarIcon_Yaoyao_Card.png', 4.6, '4★ FEATURED', 'Streetward Rambler''s youngest disciple. A gentle and caring "little adult."'),
  ('weap-mistsplitter-reforged', 'Mistsplitter Reforged', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Sword_Narukami.png', 4.9, '5★ WEAPON', 'A sword that blazes with a fierce violet light. The name "Reforged" comes from it having been broken once before.'),
  ('weap-engulfing-lightning', 'Engulfing Lightning', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Pole_Narukami.png', 4.9, '5★ WEAPON', 'A naginata used to "cut grass." Any army that stands before this weapon will probably be likewise cut down...'),
  ('weap-everlasting-moonglow', 'Everlasting Moonglow', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Catalyst_Kaleido.png', 4.9, '5★ WEAPON', 'A string of lovely jasper from the deep sea. It shines with a pure radiance like that of the moon, and just as ever-distant.'),
  ('weap-song-of-broken-pines', 'Song of Broken Pines', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Claymore_Widsith.png', 4.9, '5★ WEAPON', 'A greatsword as light as the sigh of grass in the breeze, yet as merciless to the corrupt as a typhoon.'),
  ('weap-amos-bow', 'Amos'' Bow', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Bow_Amos.png', 4.9, '5★ WEAPON', 'An extremely ancient bow that has retained its power despite its original master being long gone. It draws power from everyone and everything in the world, and the further away you are from that which your heart desires, the more powerful it is.'),
  ('weap-aquila-favonia', 'Aquila Favonia', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Sword_Falcon.png', 4.9, '5★ WEAPON', 'The soul of the Knights of Favonius. Millennia later, it still calls on the winds of swift justice to vanquish all evil — just like the last heroine who wielded it.'),
  ('weap-"the-catch"', '"The Catch"', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Pole_Mori.png', 4.6, '4★ WEAPON', 'In the distant past, this was the beloved spear of a famed Inazuman bandit.'),
  ('weap-thrilling-tales-of-dragon-slayers', 'Thrilling Tales of Dragon Slayers', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Catalyst_Pulpfic.png', 4.6, '3★ WEAPON', 'A fictional story of a band of five heroes who go off on a dragon hunt. It is poorly written and structurally incoherent. Its value lies in the many lessons that can be learned from failure.'),
  ('weap-favonius-sword', 'Favonius Sword', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Sword_Zephyrus.png', 4.6, '4★ WEAPON', 'A standard-issue longsword of the Knights of Favonius. When you''re armed with this agile and sharp weapon, channeling the power of the elements has never been so easy!'),
  ('weap-favonius-warbow', 'Favonius Warbow', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Bow_Zephyrus.png', 4.6, '4★ WEAPON', 'A standard-issue recurve bow of the Knights of Favonius. Only the best archers can unleash its full potential.'),
  ('weap-favonius-greatsword', 'Favonius Greatsword', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Claymore_Zephyrus.png', 4.6, '4★ WEAPON', 'A heavy ceremonial sword of the Knights of Favonius. It channels elemental power easily and is highly destructive.'),
  ('weap-lost-prayer-to-the-sacred-winds', 'Lost Prayer to the Sacred Winds', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Catalyst_Fourwinds.png', 4.9, '5★ WEAPON', 'An educational tome written by anonymous early inhabitants who worshiped the wind. It has been blessed by the wind for its faithfulness and influence over the millennia.'),
  ('weap-skyward-blade', 'Skyward Blade', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Sword_Dvalin.png', 4.9, '5★ WEAPON', 'The sword of a knight that symbolizes the restored honor of Dvalin. The blessings of the Anemo Archon rest on the fuller of the blade, imbuing the sword with the powers of the sky and the wind.'),
  ('weap-calamity-queller', 'Calamity Queller', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Pole_Santika.png', 4.9, '5★ WEAPON', 'A keenly honed weapon forged from some strange crystal. Its faint blue light seems to whisper of countless matters now past.'),
  ('weap-polar-star', 'Polar Star', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Bow_Worldbane.png', 4.9, '5★ WEAPON', 'A pristine bow that is as sharp as the glaciers of the far north.'),
  ('weap-amenoma-kageuchi', 'Amenoma Kageuchi', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Sword_Bakufu.png', 4.6, '4★ WEAPON', 'A blade custom made for a famed samurai who could strike down a tengu warrior, known for their incredible agility, in midair.'),
  ('weap-skyward-pride', 'Skyward Pride', 899.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Claymore_Dvalin.png', 4.9, '5★ WEAPON', 'A claymore that symbolizes the pride of Dvalin soaring through the skies. When swung, it emits a deep hum as the full force of Dvalin''s command of the sky and the wind is unleashed.'),
  ('weap-the-stringless', 'The Stringless', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Bow_Troupe.png', 4.6, '4★ WEAPON', 'A bow that once served as an extraordinary instrument. It is no longer capable of getting people up and dancing.'),
  ('weap-the-widsith', 'The Widsith', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Catalyst_Troupe.png', 4.6, '4★ WEAPON', 'A heavy notebook filled with musical scores. Though suffering from moth damage and heavy wear-and-tear, there is still much power to be found among the hand-written words within.'),
  ('weap-dragons-bane', 'Dragon''s Bane', 199.99, 'Weapons', 'https://enka.network/ui/UI_EquipIcon_Pole_Stardust.png', 4.6, '4★ WEAPON', 'A polearm decorated with an entwining golden dragon. Light and sharp, this weapon may very well kill dragons with ease.'),
  ('mat-prithiva-topaz-gemstone', 'Prithiva Topaz Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104174.png', 4.8, 'GEMSTONE', 'Character Ascension material. "The currencies that flow through this land are my flesh and blood. For thus did I become the guarantor of the people''s hard work, wisdom, and future. This is the trust I have placed in them. Betray it, and you taint my blood."'),
  ('mat-shivada-jade-gemstone', 'Shivada Jade Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104164.png', 4.8, 'GEMSTONE', 'Character Ascension material. "Sorry... to also have you shoulder the grievances of the world. "Since you could endure my bitter cold, you must have the desire to burn? "Then, burn away the old world for me."'),
  ('mat-vayuda-turquoise-gemstone', 'Vayuda Turquoise Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104154.png', 4.8, 'GEMSTONE', 'Character Ascension material. "Still, the winds change direction. "Someday, they will blow towards a brighter future... "Take my blessings and live leisurely from this day onward."'),
  ('mat-vajrada-amethyst-gemstone', 'Vajrada Amethyst Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104144.png', 4.8, 'GEMSTONE', 'Character Ascension material. "This body is the noblest and most eminent of all in this world. "It should hold absolute control over this world. "It once promised its people a dream: the never-changing ''eternity.''"'),
  ('mat-nagadus-emerald-gemstone', 'Nagadus Emerald Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104134.png', 4.8, 'GEMSTONE', 'Character Ascension material. "I had a very, very long dream..." "In it, people were holding hands, dancing in a circle, be they sages or fools, dancers or warriors, puppets or statues of gods..." "That dancing circle embodied everything about the universe. Life has always been the end, while it is wisdom that shall be the means."'),
  ('mat-varunada-lazurite-gemstone', 'Varunada Lazurite Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104124.png', 4.8, 'GEMSTONE', 'Character Ascension material. "My ideals have no stains. I must correct you. People here bear no sins in the eyes of the gods... Only laws and the Tribunal can judge someone. They can judge even me. So praise my magnificence and purity."'),
  ('mat-agnidus-agate-gemstone', 'Agnidus Agate Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104114.png', 4.8, 'GEMSTONE', 'Character Ascension material. "A pilgrimage for a wish; a battle to earn a name... Burnt to cinders for a dream. If the intention yet remains, achieved ██''s truth he has."'),
  ('mat-brilliant-diamond-gemstone', 'Brilliant Diamond Gemstone', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104104.png', 4.8, 'GEMSTONE', 'Character Ascension material. "Welcome to this world."'),
  ('mat-philosophies-of-ingenuity', 'Philosophies of Ingenuity', 69.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104334.png', 4.8, 'TALENT BOOK', 'Talent Level-Up material. Ingenuity is the leaf-veins of the nation of wisdom. Ingenuity is completed by harmonious conduct. What is done completes what is thought. Wisdom blooms where the mind, words, and practice converge.'),
  ('mat-philosophies-of-light', 'Philosophies of Light', 69.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104328.png', 4.8, 'TALENT BOOK', 'Talent Level-Up material. Light is the yearning of the land of thunder. Though they must live forever on the earth, humanity will always reach for the light. Mortals will pursue and surpass, and they will never stop. A sealed eternity may, perhaps, look magnificent, but its essence is death.'),
  ('mat-teachings-of-gold', 'Teachings of Gold', 69.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104316.png', 4.8, 'ASCENSION', 'Talent Level-Up material. Gold is the symbol of the land of Geo. Gold is the blood that flows deep within Liyue''s veins, the muscle that makes up Liyue''s beating heart, and the bones that make Liyue stand proud.'),
  ('mat-teachings-of-diligence', 'Teachings of Diligence', 69.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104313.png', 4.8, 'ASCENSION', 'Talent Level-Up material. Industriousness is the foundation of the land of Geo. Diligence is having the bravery and the strength to conquer mountains and seas and to pursue gold and prosperity through honest, hard work.'),
  ('mat-teachings-of-resistance', 'Teachings of Resistance', 69.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104304.png', 4.8, 'ASCENSION', 'Talent Level-Up material. Resistance is the backbone of the land of the wind. The history of Mondstadt is one of resistances. People rose up to prevent past conflicts from ever being forgotten, like sprouts breaking through the soil, like the eternal wind eroding through stone walls.'),
  ('mat-teachings-of-ballad', 'Teachings of Ballad', 69.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104307.png', 4.8, 'ASCENSION', 'Talent Level-Up material. Poetry is the soul of the land of the wind. Poetry is the manifestations of beautiful feelings. On a beautiful day, the breezes carry with them poetry that touches the heart of people like the wind caressing the leaves.'),
  ('mat-teachings-of-prosperity', 'Teachings of Prosperity', 69.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_104310.png', 4.8, 'ASCENSION', 'Talent Level-Up material. Prosperity is the people''s pursuit in the land of Geo. Prosperity is the blessing of Liyue, it is the foundation of the great city built by the gods and the people of Liyue, and it is the source of the peace and safety of the land.'),
  ('mat-dvalins-plume', 'Dvalin''s Plume', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_113003.png', 4.8, 'ASCENSION', 'A feather from the tail of the Dragon of the East. As a dragon''s feather it has experienced more than a thousand years'' worth of winds. One senses within it a yearning for freedom so strong that it could whip up a light breeze to rescue it from its current confines. Its former owner''s recognition of you is what makes it content to stay in your hands.'),
  ('mat-dvalins-claw', 'Dvalin''s Claw', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_113004.png', 4.8, 'ASCENSION', 'A claw from the Dragon of the East. It once contained the shadow dragon Durin''s vile poison, having torn through the latter''s flesh in battle. Thanks to your purification and healing, it is no longer toxic.'),
  ('mat-dvalins-sigh', 'Dvalin''s Sigh', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_113005.png', 4.8, 'ASCENSION', 'A bit of power taken from the whirlwinds evoked by the Dragon of the East. Beautiful and transparent, both trade winds and tornadoes will work in his name. The winds move as his companion, his voice, and his freedom. His enemies are the thousands who stand against the wind.'),
  ('mat-tail-of-boreas', 'Tail of Boreas', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_113006.png', 4.8, 'ASCENSION', 'A handful of tail scales from the Great Wolf King of the North. Even without his physical body and beyond death, Boreas still possesses extraordinary powers. He took a form comprised of ice and wind to embrace a new challenge, but even such a form could not house all of his power. The ice scales that fell during the battle still retain some of their spiritual energy.'),
  ('mat-ring-of-boreas', 'Ring of Boreas', 149.99, 'Materials', 'https://enka.network/ui/UI_ItemIcon_113007.png', 4.8, 'ASCENSION', 'A bit of crystallized ice from the Great Wolf King of the North. This land was once a realm of freezing-cold blizzards and ice storms filled with razor-sharp ice shards, all at the command of Boreas. Though his power may have diminished, he could still freeze the land in an instant.');

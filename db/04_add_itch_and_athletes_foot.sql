-- =============================================================
-- 04_add_itch_and_athletes_foot.sql
-- 塗り薬に「かゆみ止め」2件と「水虫薬」2件を追加する
--   かゆみ止め: ステロイドなし／ステロイドあり（medium）
--   水虫薬: ブテナフィン／ラノコナゾール（既存のラミシールはテルビナフィン）
-- 実行場所: Supabase の SQL Editor（03 のあとに実行する）
--
-- ⚠️ 学習用のテストデータ。全件 verified = false（未確認）
--   配合量・用法用量・妊娠中の可否は null
-- =============================================================

begin;

-- -------------------------------------------------------------
-- 1. 成分マスタ
--    l-メントール は 03 でも入れているが、03 を飛ばしても動くようにここにも書く
--    （同じ名前があれば入らない）
-- -------------------------------------------------------------
insert into ingredients (name, role, description)
select v.name, v.role, v.description
from (values
  ('l-メントール', '清涼・血行促進', 'ハッカの成分。冷たい感じを与え、痛みをやわらげる'),
  ('dl-カンフル', '清涼・かゆみ止め', '樟脳（しょうのう）。スーッとする感じでかゆみをまぎらわす'),
  ('グリチルレチン酸', '抗炎症', 'カンゾウ由来。炎症をおさえる'),
  ('プレドニゾロン吉草酸エステル酢酸エステル', 'ステロイド（medium）', '中くらいのランク（medium）のステロイド。塗った場所で効いたあと、体の中で弱い形に変わる（アンテドラッグ）'),
  ('ブテナフィン塩酸塩', '抗真菌', '水虫の原因の白癬菌を殺す。1日1回で効く'),
  ('クロタミトン', 'かゆみ止め', '皮膚に軽い温かさを与えて、かゆみをまぎらわす'),
  ('リドカイン', '局所麻酔', '皮膚の感覚をにぶくして、かゆみ・痛みをおさえる'),
  ('ラノコナゾール', '抗真菌', '水虫の原因の白癬菌を殺す。1日1回で効く')
) as v(name, role, description)
where not exists (
  select 1 from ingredients i where i.name = v.name
);

-- -------------------------------------------------------------
-- 2. 薬（新規4件）
-- -------------------------------------------------------------
insert into medicines (name, category, symptoms, precautions, contraindications, dosage_instructions, pregnancy_safe, min_age, risk_class, verified)
select v.name, v.category, v.symptoms, v.precautions, v.contraindications, null, null, null, v.risk_class, false
from (values
  -- かゆみ止め
  ('液体ムヒS2a', '塗り薬', array['かゆみ','虫さされ','湿疹','かぶれ','じんましん'],
   'ステロイドが入っていないので、顔にも使いやすい。目のまわり・粘膜には使わない',
   '傷・ただれのある部分には使わない',
   '第3類'),
  ('ムヒアルファEX', '塗り薬', array['かゆみ','虫さされ','湿疹','かぶれ'],
   '顔や広い範囲には長く使わない。5〜6日使ってよくならなければ受診をすすめる',
   '水虫・たむし、化膿している部分、目のまわりには使わない',
   '指定第2類'),
  -- 水虫薬
  ('ブテナロックVαクリーム', '塗り薬', array['水虫','いんきんたむし','ぜにたむし'],
   '症状がなくなっても、しばらく塗り続ける（菌が残っていることがある）',
   '顔・頭、湿潤やただれがひどい部分には使わない',
   '指定第2類'),
  ('ピロエースZクリーム', '塗り薬', array['水虫','いんきんたむし','ぜにたむし'],
   '症状がなくなっても、しばらく塗り続ける（菌が残っていることがある）',
   '顔・頭、湿潤やただれがひどい部分には使わない',
   '指定第2類')
) as v(name, category, symptoms, precautions, contraindications, risk_class)
where not exists (
  select 1 from medicines m where m.name = v.name
);

-- -------------------------------------------------------------
-- 3. 薬と成分のつながり
-- -------------------------------------------------------------
insert into medicine_ingredients (medicine_id, ingredient_id, amount)
select m.id, i.id, null
from (values
  ('液体ムヒS2a', 'ジフェンヒドラミン塩酸塩'),
  ('液体ムヒS2a', 'l-メントール'),
  ('液体ムヒS2a', 'dl-カンフル'),
  ('液体ムヒS2a', 'グリチルレチン酸'),
  ('ムヒアルファEX', 'プレドニゾロン吉草酸エステル酢酸エステル'),
  ('ムヒアルファEX', 'ジフェンヒドラミン塩酸塩'),
  ('ムヒアルファEX', 'l-メントール'),
  ('ブテナロックVαクリーム', 'ブテナフィン塩酸塩'),
  ('ブテナロックVαクリーム', 'クロタミトン'),
  ('ブテナロックVαクリーム', 'リドカイン'),
  ('ピロエースZクリーム', 'ラノコナゾール')
) as v(medicine_name, ingredient_name)
join medicines m on m.name = v.medicine_name
join ingredients i on i.name = v.ingredient_name
where not exists (
  select 1 from medicine_ingredients mi
  where mi.medicine_id = m.id and mi.ingredient_id = i.id
);

commit;

-- -------------------------------------------------------------
-- 4. 確認用（1行ずつ、先頭の -- を消して実行）
-- -------------------------------------------------------------
-- select count(*) from medicines;   -- 03 のあとなら 35 になるはず
-- select name, risk_class from medicines where category = '塗り薬' order by name;   -- 7件
-- select count(*) from medicine_ingredients;   -- 02（62）＋03（5）＋04（11）＝78 以上

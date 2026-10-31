-- =============================================================
-- 03_add_topical_analgesics.sql
-- カテゴリ「外用鎮痛消炎薬」を追加する（4件）
--   - ボルタレンEXゲル を「塗り薬」から引っ越し
--   - 新規3件（成分パターン: ロキソプロフェン／フェルビナク／サリチル酸メチル）
-- 実行場所: Supabase の SQL Editor（02_seed.sql のあとに実行する）
--
-- ⚠️ 学習用のテストデータ。全件 verified = false（未確認）
--   配合量・用法用量・妊娠中の可否は null
-- =============================================================

begin;

-- -------------------------------------------------------------
-- 1. ボルタレンEXゲル のカテゴリを変える
-- -------------------------------------------------------------
update medicines set category = '外用鎮痛消炎薬' where name = 'ボルタレンEXゲル';

-- -------------------------------------------------------------
-- 2. 成分マスタ
-- -------------------------------------------------------------
insert into ingredients (name, role, description)
select v.name, v.role, v.description
from (values
  ('ロキソプロフェンナトリウム水和物', '鎮痛・抗炎症（外用）', 'NSAIDs。飲み薬は第1類だが、貼り薬・塗り薬は第2類'),
  ('フェルビナク', '鎮痛・抗炎症（外用）', 'NSAIDs。皮膚から吸収されやすく、痛む場所に届きやすい'),
  ('サリチル酸メチル', '鎮痛・抗炎症（外用）', '昔からある成分。スーッとするにおいが特徴'),
  ('l-メントール', '清涼・血行促進', 'ハッカの成分。冷たい感じを与え、痛みをやわらげる')
) as v(name, role, description)
where not exists (
  select 1 from ingredients i where i.name = v.name
);

-- -------------------------------------------------------------
-- 3. 薬（新規3件）
-- -------------------------------------------------------------
insert into medicines (name, category, symptoms, precautions, contraindications, dosage_instructions, pregnancy_safe, min_age, risk_class, verified)
select v.name, v.category, v.symptoms, v.precautions, v.contraindications, null, null, v.min_age, v.risk_class, false
from (values
  ('ロキソニンSテープ', '外用鎮痛消炎薬', array['腰痛','肩こり','筋肉痛','関節痛'],
   '貼ったところに日光を当てない。1日1回の貼り替え',
   '15歳未満、ぜんそくを起こしたことがある人は使わない。傷・湿疹・かぶれのある部分には貼らない',
   15, '第2類'),
  ('フェイタス5.0', '外用鎮痛消炎薬', array['腰痛','肩こり','筋肉痛','関節痛'],
   '貼ったところに日光を当てない',
   '15歳未満、ぜんそくを起こしたことがある人は使わない。傷・湿疹・かぶれのある部分には貼らない',
   null, '第2類'),
  ('サロンパスAe', '外用鎮痛消炎薬', array['腰痛','肩こり','筋肉痛','関節痛'],
   'かぶれやすい人は、長時間貼り続けない',
   '傷・湿疹・かぶれのある部分には貼らない',
   null, '第3類')
) as v(name, category, symptoms, precautions, contraindications, min_age, risk_class)
where not exists (
  select 1 from medicines m where m.name = v.name
);

-- -------------------------------------------------------------
-- 4. 薬と成分のつながり
-- -------------------------------------------------------------
insert into medicine_ingredients (medicine_id, ingredient_id, amount)
select m.id, i.id, null
from (values
  ('ロキソニンSテープ', 'ロキソプロフェンナトリウム水和物'),
  ('フェイタス5.0', 'フェルビナク'),
  ('フェイタス5.0', 'l-メントール'),
  ('サロンパスAe', 'サリチル酸メチル'),
  ('サロンパスAe', 'l-メントール')
) as v(medicine_name, ingredient_name)
join medicines m on m.name = v.medicine_name
join ingredients i on i.name = v.ingredient_name
where not exists (
  select 1 from medicine_ingredients mi
  where mi.medicine_id = m.id and mi.ingredient_id = i.id
);

commit;

-- -------------------------------------------------------------
-- 5. 確認用（1行ずつ、先頭の -- を消して実行）
-- -------------------------------------------------------------
-- select count(*) from medicines;   -- 31 になるはず
-- select name, risk_class from medicines where category = '外用鎮痛消炎薬';   -- 4件
-- select category, count(*) from medicines group by category order by category;

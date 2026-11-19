-- 05: 成分の表（ingredients）と中間テーブル（medicine_ingredients）を、API から読めるようにする
--
-- なぜ必要？
--   Supabase は RLS（行レベルセキュリティ）が有効な表を、「許可（ポリシー）が1つもなければ誰にも見せない」。
--   しかもエラーにはならず、空っぽ（[]）を返すだけなので気づきにくい。
--   GET /medicines/1 で medicine_ingredients が [] になったのはこれが原因。
--   確認（2026-11-19）: Table Editor で Role を Anonymous にすると 0 records（Postgres では 78 records）。
--   このファイルを Run したあと、バファリンA の成分が2つ返るようになった。
--   ※ 途中で「バファリンA の行が消えている」とも疑ったが、medicine_id = 1 の行（id 52, 59、
--     2026-10-29 作成）は最初からあった。表の先頭（id 3〜23）だけを見て見落としていた。
--
-- 何を許可する？
--   「読む（select）」だけ。書き込み・削除は許可しない。
--   成分の名前や役割は、薬の箱にも書いてある公開情報なので、誰が読んでもよい。
--
-- 使い方: Supabase の SQL Editor に貼って Run

create policy "誰でも成分を読める"
  on ingredients
  for select
  to anon
  using (true);

create policy "誰でも薬と成分のつながりを読める"
  on medicine_ingredients
  for select
  to anon
  using (true);

-- 確認用（Run したあと、API で GET /medicines/1 を開いて成分が2つ出ればOK）
-- select * from pg_policies where tablename in ('ingredients', 'medicine_ingredients');

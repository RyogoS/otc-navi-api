-- =============================================================
-- 01_add_columns.sql
-- medicines テーブルに「リスク区分」と「確認済みの印」の列を足す
-- 実行場所: Supabase の SQL Editor
-- 何度実行しても同じ結果になる（if not exists）
-- =============================================================

alter table medicines
  -- リスク区分（薬機法の区分）。第1類は薬剤師しか扱えないので、入れられないようにしている
  add column if not exists risk_class text
    check (risk_class in ('指定第2類', '第2類', '第3類', '指定医薬部外品')),
  -- 添付文書と見比べて確認したら true にする。画面には出さない（作る人向けの印）
  add column if not exists verified boolean not null default false;

comment on column medicines.risk_class is 'リスク区分（指定第2類／第2類／第3類／指定医薬部外品）。第1類は扱わない';
comment on column medicines.verified is '添付文書で確認済みなら true。画面には表示しない';

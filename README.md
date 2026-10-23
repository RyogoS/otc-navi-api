# otc-navi-api

症状から市販薬を探せるWebアプリ「otc-navi」のバックエンドAPI（Nest.js）です。
アプリの説明・使い方・使用技術は [otc-navi-app の README](https://github.com/RyogoS/otc-navi-app) をご覧ください。

> ⚠️ **本アプリはプログラミング学習用のデモです。** 実際に薬を選ぶ・使うときは、医師・薬剤師・登録販売者に相談してください。

## エンドポイント

| メソッド | パス | 内容 |
|---|---|---|
| GET | `/medicines?symptom=頭痛` | 症状に合う薬の一覧を返す（`symptom` を省略すると全件） |

詳しくは [API仕様書](https://github.com/RyogoS/otc-navi-app/blob/main/docs/api-spec.md) を参照してください。

## 動かし方（開発者向け）

1. `.env` に Supabase の接続情報（`SUPABASE_URL`・`SUPABASE_KEY`）を設定する
2. `npm install` → `npm run start:dev` を実行する
3. `http://localhost:3000` で起動する（フロントエンドの `otc-navi-app` も起動すると、画面から使えます）

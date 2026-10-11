// NestJS（ネストジェイエス）の機能を使うための道具を読み込む
// ※「このファイルを他の場所でも使いまわせるようにする（Injectable）」という仕組みで使うよ
import { Injectable } from '@nestjs/common';

// 設定ファイル（.envなど）から合言葉や秘密のキーを取り出すための道具を読み込む
import { ConfigService } from '@nestjs/config';

// Supabase（スーパーベース：データを保存しておく大きな本棚）とやり取りするための道具を読み込む
import { createClient, SupabaseClient } from '@supabase/supabase-js';


// このクラスを他の場所でも使えるようにする設定（NestJSの仕組み）
@Injectable()
export class MedicinesService {
  // データベース（Supabase）と通信するための「専用の電話」を準備する場所
  private supabase: SupabaseClient;

  // このサービスが作られるときに自動で実行される準備処理
  constructor(private configService: ConfigService) {
    // データベースがある「場所（URL）」を金庫（設定ファイル）から取り出す
    const supabaseUrl = this.configService.getOrThrow<string>('SUPABASE_URL');

    // データベースに入るための「鍵（APIキー）」を金庫（設定ファイル）から取り出す
    const supabaseKey = this.configService.getOrThrow<string>('SUPABASE_KEY');

    // 場所と鍵を使って、データベースと通信する「電話（Supabaseクライアント）」をつなぐ
    this.supabase = createClient(supabaseUrl, supabaseKey);
  }

  // 登録されているお薬データをとってくる処理（「symptom」で特定の症状に効く薬だけ絞り込むこともできるよ）
  async findAll(symptom?: string) {
    // まずは「medicines（お薬）」という表から、データをぜんぶ選ぶ「基本の注文書（query）」を作る
    let query = this.supabase.from('medicines').select();

    // もし「頭痛」や「熱」などの症状（symptom）が指定されていたら…
    if (symptom) {
      // 注文書に「symptoms（効く症状リスト）」の中に指定された症状が含まれているお薬だけに絞り込む条件を追加する
      query = query.contains('symptoms', [symptom]);
    }

    // 完成した注文書をSupabase（データベース）に送って、データを受け取る
    const { data, error } = await query;

    // もしデータの取得に失敗してエラーが起きたら、エラーを投げて知らせる
    if (error) {
      throw error;
    }

    // 無事にデータがとれたら、お薬の一覧データを返す
    return data;
  }
}
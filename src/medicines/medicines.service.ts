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
    // まずは「medicines（お薬）」という表から、一覧に必要な4つの列だけを選ぶ「基本の注文書（query）」を作る
    // ・verified（確認済みの印）は作る人向けなので、画面側には渡さない
    // ・用法用量や禁忌などの詳細は、薬を1つ選んだときに詳細API（これから作る）で渡す
    let query = this.supabase
      .from('medicines')
      .select('id, name, category, symptoms');

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

  // 背番号（id）を指定して、お薬1つの詳細と成分をとってくる処理
  async findOne(id: number) {
    const { data, error } = await this.supabase
      .from('medicines')
      // 詳細に必要な列を選ぶ（verified は作る人向けなので、ここでも渡さない）
      // medicine_ingredients(...) の部分は「この薬につながる中間テーブルの行も一緒に持ってきて」という意味
      // さらにその中の ingredients(...) で「その行が指している成分の名前・役割・説明も持ってきて」とたどる
      .select(
        `id, name, category, symptoms,
         precautions, contraindications, dosage_instructions,
         pregnancy_safe, min_age, risk_class,
         medicine_ingredients ( amount, ingredients ( name, role, description ) )`,
      )
      // 背番号が id と同じ薬だけに絞る
      .eq('id', id)
      // 1件だけ受け取る（見つからなければ null。404 にするのは次のステップ）
      .maybeSingle();

    if (error) {
      throw error;
    }

    return data;
  }
}
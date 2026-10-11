// NestJSから「案内係（Controller）」と「お返事のルール（Get）」の道具を読み込む
import { Controller, Get, Query } from '@nestjs/common';

// 前につくった「お薬担当の係員さん（MedicinesService）」を読み込む
import { MedicinesService } from './medicines.service.js';

// 「http://.../medicines」という場所にリクエストが来たら、この案内係が対応するよ！という設定
@Controller('medicines')
export class MedicinesController {
  // お薬担当の係員さん（MedicinesService）を呼び出して、仲間にする準備
  constructor(private medicinesService: MedicinesService) {}

  // アプリや画面から「お薬一覧をちょうだい！（GETリクエスト）」と言われたときに動く場所
  @Get()
  async findAll(@Query('symptom') symptom?: string) {
    // お薬担当の係員さんに「本棚からお薬データぜんぶ取ってきて！」とお願いして、その結果をそのまま返事する
    return await this.medicinesService.findAll(symptom);
  }
}
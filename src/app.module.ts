import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { HelloController } from './hello/hello.controller.js';
import { MedicinesModule } from './medicines/medicines.module.js';

import { ConfigModule } from '@nestjs/config';


@Module({
  imports: [MedicinesModule, ConfigModule.forRoot({
    isGlobal: true,
})],
  controllers: [AppController, HelloController],
  providers: [AppService],
})
export class AppModule {}

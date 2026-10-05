import 'dotenv/config';

import { NestFactory } from '@nestjs/core';
import {
  DocumentBuilder,
  SwaggerModule,
} from '@nestjs/swagger';

import { AppModule } from './app.module.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = new DocumentBuilder()
    .setTitle('Symbol API')
    .setDescription(
      'OpenAPI documentation for MAFJP and NTDS-CWS symbol libraries',
    )
    .setVersion('1.0')
    .addTag(
      'NTDS-CWS',
      'NTDS-CWS symbol library endpoints',
    )
    .addTag(
      'MAFJP',
      'MAFJP symbol library endpoints',
    )
    .build();

  const document = SwaggerModule.createDocument(
    app,
    config,
  );

  SwaggerModule.setup('api', app, document);

  await app.listen(process.env.PORT ?? 3000);
}

bootstrap();
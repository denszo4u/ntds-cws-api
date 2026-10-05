import { Module } from '@nestjs/common';

import { PrismaModule } from './prisma/prisma.module.js';
import { NtdsCwsModule } from './ntds-cws/ntds-cws.module.js';
import { MafjpModule } from './mafjp/mafjp.module.js';

@Module({
  imports: [
    PrismaModule,
    NtdsCwsModule,
    MafjpModule,
  ],
})
export class AppModule {}
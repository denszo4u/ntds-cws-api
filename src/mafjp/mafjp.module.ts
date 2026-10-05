import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module.js';
import { MafjpController } from './mafjp.controller.js';
import { MafjpService } from './mafjp.service.js';

@Module({
  imports: [PrismaModule],
  controllers: [MafjpController],
  providers: [MafjpService],
})
export class MafjpModule {}
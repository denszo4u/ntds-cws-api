import { Module } from '@nestjs/common';
import { NtdsCwsController } from './ntds-cws.controller.js';
import { NtdsCwsService } from './ntds-cws.service.js';
import { PrismaModule } from '../prisma/prisma.module.js';

@Module({
  imports: [PrismaModule],
  controllers: [NtdsCwsController],
  providers: [NtdsCwsService],
})
export class NtdsCwsModule {}
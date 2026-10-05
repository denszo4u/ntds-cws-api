import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma/prisma.service.js';

@Injectable()
export class AppService {
  constructor(private readonly prisma: PrismaService) {}

  getHello(): string {
    return 'Hello World!';
  }

  async getNTDSCWS() {
    return this.prisma.symbolNTDSCWS.findMany({
      take: 10,
      include: {
        SymbolNTDSCWSUnit: true,
        SymbolNTDSCWSType: true,
        SymbolOrientation: true,
      },
    });
  }
}
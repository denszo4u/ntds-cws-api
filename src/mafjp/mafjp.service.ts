import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class MafjpService {
  constructor(private readonly prisma: PrismaService) {}

  // =====================================================
  // UNIT
  // =====================================================

  async getAllUnits() {
    return this.prisma.symbol_mafjp_unit.findMany({
      orderBy: {
        symbol_unit_name_en: 'asc',
      },
    });
  }

  async getUnitById(id: string) {
    return this.prisma.symbol_mafjp_unit.findUnique({
      where: {
        id,
      },
      include: {
        symbol_mafjp: true,
      },
    });
  }

  // =====================================================
  // SYMBOL
  // =====================================================

  async getAllSymbols() {
    return this.prisma.symbol_mafjp.findMany({
      include: {
        symbol_mafjp_unit: true,
      },
      orderBy: {
        symbol_name: 'asc',
      },
    });
  }

  async getSymbolById(id: string) {
    return this.prisma.symbol_mafjp.findUnique({
      where: {
        id,
      },
      include: {
        symbol_mafjp_unit: true,
      },
    });
  }

  // =====================================================
  // SEARCH SYMBOL BY NAME
  // =====================================================

  async searchSymbolsByName(name: string) {
    if (!name) {
      return [];
    }

    return this.prisma.symbol_mafjp.findMany({
      where: {
        symbol_name: {
          contains: name,
          mode: 'insensitive',
        },
      },
      include: {
        symbol_mafjp_unit: true,
      },
      orderBy: {
        symbol_name: 'asc',
      },
    });
  }
}
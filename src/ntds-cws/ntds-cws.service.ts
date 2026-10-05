import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class NtdsCwsService {
  constructor(private readonly prisma: PrismaService) {}

  // =========================
  // CATEGORY
  // =========================
  async getAllCategories(languageId = 2) {
    const categories =
      await this.prisma.symbolNTDSCWSCategory.findMany();

    return categories
      .map((category) => ({
        SymbolCategory:
          languageId === 1
            ? (category.SymbolCategoryNameBM ?? '')
            : (category.SymbolCategoryNameEN ?? ''),

        SymbolCategoryID: category.SymbolCategoryID,
      }))
      .sort((a, b) =>
        a.SymbolCategory.localeCompare(b.SymbolCategory),
      );
  }

  // =========================
  // TYPE
  // =========================
  async getAllTypes(languageId = 2) {
    const types =
      await this.prisma.symbolNTDSCWSType.findMany({
        where: {
          SymbolTypeID: {
            not: 6,
          },
        },
        orderBy: {
          SymbolTypeID: 'asc',
        },
      });

    return types.map((type) => ({
      SymbolType:
        languageId === 1
          ? (type.SymbolTypeNameBM ?? '')
          : (type.SymbolTypeNameEN ?? ''),

      SymbolTypeID: type.SymbolTypeID,
    }));
  }

  // =========================
  // UNIT
  // =========================
  async getAllUnits(
    symbolCategoryId: number | null,
    languageId: number | null,
  ) {
    if (
      symbolCategoryId === null &&
      languageId === null
    ) {
      const units =
        await this.prisma.symbolNTDSCWSUnit.findMany({
          orderBy: [
            {
              SymbolCategoryID: 'asc',
            },
            {
              SymbolUnitID: 'asc',
            },
          ],
        });

      return units.map((unit) => ({
        SymbolUnit: unit.SymbolUnitNameEN ?? '',
        SymbolUnitID: unit.SymbolUnitID,
      }));
    }

    const units =
      await this.prisma.symbolNTDSCWSUnit.findMany({
        where: {
          SymbolCategoryID: symbolCategoryId,
        },
        orderBy: {
          SymbolUnitID: 'asc',
        },
      });

    return units.map((unit) => ({
      SymbolUnit:
        languageId === 1
          ? (unit.SymbolUnitNameBM ?? '')
          : (unit.SymbolUnitNameEN ?? ''),

      SymbolUnitID: unit.SymbolUnitID,
    }));
  }

  // =========================
  // DETAIL
  // =========================
  async getAllDetails(
    symbolUnitId: number,
    languageId = 2,
  ) {
    const symbols =
      await this.prisma.symbolNTDSCWS.findMany({
        where: {
          SymbolUnitID: symbolUnitId,
        },

        include: {
          SymbolNTDSCWSType: true,
          SymbolOrientation: true,
        },

        orderBy: [
          {
            SymbolTypeID: 'asc',
          },
          {
            SequenceNo: 'asc',
          },
        ],
      });

    return symbols
      .filter(
        (symbol) =>
          symbol.SymbolNTDSCWSType !== null &&
          symbol.SymbolOrientation !== null,
      )
      .map((symbol) => ({
        SymbolType:
          languageId === 1
            ? (symbol.SymbolNTDSCWSType
                ?.SymbolTypeNameBM ?? '')
            : (symbol.SymbolNTDSCWSType
                ?.SymbolTypeNameEN ?? ''),

        FontFamily: symbol.FontFamily ?? '',
        FontCharacter: symbol.FontCharacter ?? '',
        ColorCode: symbol.ColorCode ?? '',
        SymbolName: symbol.SymbolName ?? '',

        SymbolOrientation:
          languageId === 1
            ? (symbol.SymbolOrientation
                ?.SymbolOrientationNameBM ?? '')
            : (symbol.SymbolOrientation
                ?.SymbolOrientationNameEN ?? ''),

        SymbolID: symbol.SymbolID,

        SymbolTypeID:
          symbol.SymbolNTDSCWSType?.SymbolTypeID,

        SymbolOrientationID:
          symbol.SymbolOrientation
            ?.SymbolOrientationID,
      }));
  }

  // =========================
  // SEARCH BY NAME
  // =========================
  async searchByName(symbolName: string) {
    // Old stored procedure immediately returns
    // when the search text is empty.
    if (symbolName === '') {
      return [];
    }

    const symbols =
      await this.prisma.symbolNTDSCWS.findMany({
        where: {
          SymbolName: {
            contains: symbolName,
            mode: 'insensitive',
          },

          FontFamily: {
            not: null,
          },

          FontCharacter: {
            not: null,
          },
        },

        orderBy: {
          SymbolName: 'asc',
        },

        select: {
          SymbolID: true,
          SymbolName: true,
          FontFamily: true,
          FontCharacter: true,
          ColorCode: true,
          SymbolOrientationID: true,
        },
      });

    return symbols;
  }
}
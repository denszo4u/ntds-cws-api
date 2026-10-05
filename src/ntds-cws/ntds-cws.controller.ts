import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';

import { NtdsCwsService } from './ntds-cws.service.js';

@ApiTags('NTDS-CWS')
@Controller('ntds-cws')
export class NtdsCwsController {
  constructor(
    private readonly ntdsCwsService: NtdsCwsService,
  ) {}

  // =========================
  // CATEGORY
  // =========================
  @Get('categories')
  @ApiOperation({
    summary: 'Get all NTDS-CWS categories',
  })
  @ApiQuery({
    name: 'LanguageID',
    required: false,
    type: Number,
    description: '1 = Bahasa Melayu, 2 = English',
    example: 2,
  })
  getAllCategories(
    @Query('LanguageID') languageId?: string,
  ) {
    return this.ntdsCwsService.getAllCategories(
      languageId ? Number(languageId) : 2,
    );
  }

  // =========================
  // TYPE
  // =========================
  @Get('types')
  @ApiOperation({
    summary: 'Get all NTDS-CWS symbol types',
  })
  @ApiQuery({
    name: 'LanguageID',
    required: false,
    type: Number,
    description: '1 = Bahasa Melayu, 2 = English',
    example: 2,
  })
  getAllTypes(
    @Query('LanguageID') languageId?: string,
  ) {
    return this.ntdsCwsService.getAllTypes(
      languageId ? Number(languageId) : 2,
    );
  }

  // =========================
  // UNIT
  // =========================
  @Get('units')
  @ApiOperation({
    summary: 'Get NTDS-CWS units by category',
  })
  @ApiQuery({
    name: 'SymbolCategoryID',
    required: false,
    type: Number,
    description: 'Symbol category ID',
    example: 1,
  })
  @ApiQuery({
    name: 'LanguageID',
    required: false,
    type: Number,
    description: '1 = Bahasa Melayu, 2 = English',
    example: 2,
  })
  getAllUnits(
    @Query('SymbolCategoryID')
    symbolCategoryId?: string,

    @Query('LanguageID')
    languageId?: string,
  ) {
    return this.ntdsCwsService.getAllUnits(
      symbolCategoryId !== undefined
        ? Number(symbolCategoryId)
        : null,

      languageId !== undefined
        ? Number(languageId)
        : null,
    );
  }

  // =========================
  // DETAIL
  // =========================
  @Get('details')
  @ApiOperation({
    summary: 'Get NTDS-CWS symbol details by unit',
  })
  @ApiQuery({
    name: 'SymbolUnitID',
    required: true,
    type: Number,
    description: 'Symbol unit ID',
    example: 1,
  })
  @ApiQuery({
    name: 'LanguageID',
    required: false,
    type: Number,
    description: '1 = Bahasa Melayu, 2 = English',
    example: 2,
  })
  getAllDetails(
    @Query('SymbolUnitID')
    symbolUnitId?: string,

    @Query('LanguageID')
    languageId?: string,
  ) {
    return this.ntdsCwsService.getAllDetails(
      symbolUnitId
        ? Number(symbolUnitId)
        : 0,

      languageId
        ? Number(languageId)
        : 2,
    );
  }

  // =========================
  // SEARCH BY NAME
  // =========================
  @Get('search')
  @ApiOperation({
    summary: 'Search NTDS-CWS symbols by name',
  })
  @ApiQuery({
    name: 'SymbolNTDSCWSName',
    required: true,
    type: String,
    description: 'Symbol name to search',
    example: 'Air',
  })
  searchByName(
    @Query('SymbolNTDSCWSName')
    symbolName?: string,
  ) {
    return this.ntdsCwsService.searchByName(
      symbolName ?? '',
    );
  }
}
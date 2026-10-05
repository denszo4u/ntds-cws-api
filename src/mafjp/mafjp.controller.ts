import {
  Controller,
  Get,
  Param,
  Query,
} from '@nestjs/common';

import {
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';

import { MafjpService } from './mafjp.service.js';

@ApiTags('MAFJP')
@Controller('mafjp')
export class MafjpController {
  constructor(
    private readonly mafjpService: MafjpService,
  ) {}

  // =====================================================
  // UNIT
  // =====================================================

  @Get('units')
  @ApiOperation({
    summary: 'Get all MAFJP units',
  })
  getAllUnits() {
    return this.mafjpService.getAllUnits();
  }

  @Get('units/:id')
  @ApiOperation({
    summary: 'Get MAFJP unit by UUID',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'MAFJP unit UUID',
    example: '01a10a17-ebdd-799e-a0ed-0d15b9cad316',
  })
  getUnitById(
    @Param('id') id: string,
  ) {
    return this.mafjpService.getUnitById(id);
  }

  // =====================================================
  // SYMBOL SEARCH
  // Keep search before symbols/:id
  // =====================================================

  @Get('symbols/search')
  @ApiOperation({
    summary: 'Search MAFJP symbols by name',
  })
  @ApiQuery({
    name: 'name',
    required: true,
    type: String,
    description: 'Search symbol by symbol_name',
    example: 'Military',
  })
  searchSymbolsByName(
    @Query('name') name?: string,
  ) {
    return this.mafjpService.searchSymbolsByName(
      name ?? '',
    );
  }

  // =====================================================
  // SYMBOL
  // =====================================================

  @Get('symbols')
  @ApiOperation({
    summary: 'Get all MAFJP symbols',
  })
  getAllSymbols() {
    return this.mafjpService.getAllSymbols();
  }

  @Get('symbols/:id')
  @ApiOperation({
    summary: 'Get MAFJP symbol by UUID',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'MAFJP symbol UUID',
  })
  getSymbolById(
    @Param('id') id: string,
  ) {
    return this.mafjpService.getSymbolById(id);
  }
}
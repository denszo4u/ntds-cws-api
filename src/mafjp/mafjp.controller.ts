import {
  BadRequestException,
  Controller,
  Get,
  Param,
  Query,
} from '@nestjs/common';

import {
  ApiBadRequestResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
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
  // UUIDv7 VALIDATION
  // =====================================================

  private validateUuidV7(id: string) {
    const uuidV7Regex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!uuidV7Regex.test(id)) {
      throw new BadRequestException(
        'Invalid UUIDv7 format',
      );
    }
  }

  // =====================================================
  // UNIT
  // =====================================================

  @Get('units')
  @ApiOperation({
    summary: 'Get all MAFJP units',
  })
  @ApiOkResponse({
    description: 'MAFJP units returned successfully',
  })
  getAllUnits() {
    return this.mafjpService.getAllUnits();
  }

  @Get('units/:id')
  @ApiOperation({
    summary: 'Get MAFJP unit by UUIDv7',
  })
  @ApiParam({
    name: 'id',
    required: true,
    type: String,
    description: 'MAFJP unit UUIDv7',
    example: '01a10a17-ebdd-799e-a0ed-0d15b9cad316',
  })
  @ApiOkResponse({
    description: 'MAFJP unit returned successfully',
  })
  @ApiBadRequestResponse({
    description: 'Invalid UUIDv7 format',
  })
  @ApiNotFoundResponse({
    description: 'MAFJP unit not found',
  })
  getUnitById(
    @Param('id') id: string,
  ) {
    this.validateUuidV7(id);

    return this.mafjpService.getUnitById(id);
  }

  // =====================================================
  // SYMBOL SEARCH
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
  @ApiOkResponse({
    description: 'Search results returned successfully',
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
  @ApiOkResponse({
    description: 'MAFJP symbols returned successfully',
  })
  getAllSymbols() {
    return this.mafjpService.getAllSymbols();
  }

  @Get('symbols/:id')
  @ApiOperation({
    summary: 'Get MAFJP symbol by UUIDv7',
  })
  @ApiParam({
    name: 'id',
    required: true,
    type: String,
    description: 'MAFJP symbol UUIDv7',
    example: '01a10a17-ebf8-732c-bb7e-07af49a34143',
  })
  @ApiOkResponse({
    description: 'MAFJP symbol returned successfully',
  })
  @ApiBadRequestResponse({
    description: 'Invalid UUIDv7 format',
  })
  @ApiNotFoundResponse({
    description: 'MAFJP symbol not found',
  })
  getSymbolById(
    @Param('id') id: string,
  ) {
    this.validateUuidV7(id);

    return this.mafjpService.getSymbolById(id);
  }
}
-- ============================================================
-- MAFJP UUID MIGRATION
-- Source  : public old MAFJP tables
-- Target  : symbology schema
-- Strategy: old integer ID -> temporary UUID mapping -> final
-- ============================================================


-- ============================================================
-- 1. CREATE TARGET SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS symbology;


-- ============================================================
-- 2. TEMPORARY ID MAPPING TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_category_id_map (
    old_id SMALLINT PRIMARY KEY,
    new_id UUID NOT NULL UNIQUE DEFAULT uuidv7()
);

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_type_id_map (
    old_id SMALLINT PRIMARY KEY,
    new_id UUID NOT NULL UNIQUE DEFAULT uuidv7()
);

CREATE TABLE IF NOT EXISTS symbology.symbol_orientation_id_map (
    old_id SMALLINT PRIMARY KEY,
    new_id UUID NOT NULL UNIQUE DEFAULT uuidv7()
);

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_unit_id_map (
    old_id SMALLINT PRIMARY KEY,
    new_id UUID NOT NULL UNIQUE DEFAULT uuidv7()
);

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_id_map (
    old_id INTEGER PRIMARY KEY,
    new_id UUID NOT NULL UNIQUE DEFAULT uuidv7()
);


-- ============================================================
-- 3. POPULATE OLD ID -> UUID MAPPING
-- ============================================================

INSERT INTO symbology.symbol_mafjp_category_id_map (old_id)
SELECT "SymbolCategoryID"
FROM public."SymbolMAFJPCategory"
ON CONFLICT (old_id) DO NOTHING;


INSERT INTO symbology.symbol_mafjp_type_id_map (old_id)
SELECT "SymbolTypeID"
FROM public."SymbolMAFJPType"
ON CONFLICT (old_id) DO NOTHING;


INSERT INTO symbology.symbol_orientation_id_map (old_id)
SELECT "SymbolOrientationID"
FROM public."SymbolOrientation"
ON CONFLICT (old_id) DO NOTHING;


INSERT INTO symbology.symbol_mafjp_unit_id_map (old_id)
SELECT "SymbolUnitID"
FROM public."SymbolMAFJPUnit"
ON CONFLICT (old_id) DO NOTHING;


INSERT INTO symbology.symbol_mafjp_id_map (old_id)
SELECT "SymbolID"
FROM public."SymbolMAFJP"
ON CONFLICT (old_id) DO NOTHING;


-- ============================================================
-- 4. CREATE FINAL TABLE: symbol_mafjp_unit
-- ============================================================

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_unit (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_category_id UUID,
    symbol_unit_name_en VARCHAR(200),
    symbol_unit_name_bm VARCHAR(200),
    symbol_description VARCHAR(200)
);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_unit_category_id
ON symbology.symbol_mafjp_unit (symbol_category_id);


-- ============================================================
-- 5. CREATE FINAL TABLE: symbol_mafjp
-- ============================================================

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_mafjp_unit_id UUID,
    symbol_type_id UUID,
    font_list VARCHAR(8000),
    symbol_orientation_id UUID,
    symbol_name VARCHAR(100),
    sequence_no SMALLINT,

    CONSTRAINT fk_symbol_mafjp_unit
        FOREIGN KEY (symbol_mafjp_unit_id)
        REFERENCES symbology.symbol_mafjp_unit(id)
);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_unit_id
ON symbology.symbol_mafjp (symbol_mafjp_unit_id);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_type_id
ON symbology.symbol_mafjp (symbol_type_id);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_orientation_id
ON symbology.symbol_mafjp (symbol_orientation_id);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_name
ON symbology.symbol_mafjp (symbol_name);


-- ============================================================
-- 6. MIGRATE MAFJP UNIT
-- ============================================================

INSERT INTO symbology.symbol_mafjp_unit (
    id,
    symbol_category_id,
    symbol_unit_name_en,
    symbol_unit_name_bm,
    symbol_description
)
SELECT
    um.new_id,
    cm.new_id,
    u."SymbolUnitNameEN",
    u."SymbolUnitNameBM",
    u."SymbolDescription"
FROM public."SymbolMAFJPUnit" u

JOIN symbology.symbol_mafjp_unit_id_map um
    ON um.old_id = u."SymbolUnitID"

LEFT JOIN symbology.symbol_mafjp_category_id_map cm
    ON cm.old_id = u."SymbolCategoryID"

ON CONFLICT (id) DO NOTHING;


-- ============================================================
-- 7. MIGRATE MAFJP SYMBOL
-- ============================================================

INSERT INTO symbology.symbol_mafjp (
    id,
    symbol_mafjp_unit_id,
    symbol_type_id,
    font_list,
    symbol_orientation_id,
    symbol_name,
    sequence_no
)
SELECT
    sm.new_id,
    um.new_id,
    tm.new_id,
    s."FontList",
    om.new_id,
    s."SymbolName",
    s."SequenceNo"
FROM public."SymbolMAFJP" s

JOIN symbology.symbol_mafjp_id_map sm
    ON sm.old_id = s."SymbolID"

LEFT JOIN symbology.symbol_mafjp_unit_id_map um
    ON um.old_id = s."SymbolUnitID"

LEFT JOIN symbology.symbol_mafjp_type_id_map tm
    ON tm.old_id = s."SymbolTypeID"

LEFT JOIN symbology.symbol_orientation_id_map om
    ON om.old_id = s."SymbolOrientationID"

ON CONFLICT (id) DO NOTHING;


-- ============================================================
-- 8. VERIFICATION
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM public."SymbolMAFJPUnit")
        AS source_unit_count,

    (SELECT COUNT(*) FROM symbology.symbol_mafjp_unit)
        AS target_unit_count,

    (SELECT COUNT(*) FROM public."SymbolMAFJP")
        AS source_symbol_count,

    (SELECT COUNT(*) FROM symbology.symbol_mafjp)
        AS target_symbol_count;


-- Check broken unit relations
SELECT COUNT(*) AS broken_unit_relation
FROM symbology.symbol_mafjp s
LEFT JOIN symbology.symbol_mafjp_unit u
    ON u.id = s.symbol_mafjp_unit_id
WHERE s.symbol_mafjp_unit_id IS NOT NULL
  AND u.id IS NULL;


-- Check indexes
SELECT
    schemaname,
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'symbology'
  AND tablename IN (
      'symbol_mafjp',
      'symbol_mafjp_unit'
  )
ORDER BY tablename, indexname;


-- ============================================================
-- 9. CLEANUP
-- DO NOT RUN until migration has been reviewed/approved.
-- ============================================================

-- DROP TABLE symbology.symbol_mafjp_id_map;
-- DROP TABLE symbology.symbol_mafjp_unit_id_map;
-- DROP TABLE symbology.symbol_mafjp_type_id_map;
-- DROP TABLE symbology.symbol_mafjp_category_id_map;
-- DROP TABLE symbology.symbol_orientation_id_map;
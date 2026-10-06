-- ============================================================
-- MAFJP UUID MIGRATION
-- Source : public schema (legacy integer/smallint IDs)
-- Target : symbology schema (UUIDv7 IDs)
-- ============================================================


-- ============================================================
-- 1. CREATE TARGET SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS symbology;


-- ============================================================
-- 2. TEMPORARY OLD ID -> UUID MAPPING TABLES
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

CREATE TABLE IF NOT EXISTS symbology.symbol_type_library_id_map (
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
-- 3. GENERATE STABLE UUID MAPPINGS
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

INSERT INTO symbology.symbol_type_library_id_map (old_id)
SELECT "SymbolTypeLibID"
FROM public."SymbolTypeLibrary"
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
-- 4. CREATE NEW UUID TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_category (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_category_name_en VARCHAR(200),
    symbol_category_name_bm VARCHAR(200),
    symbol_description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_type (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_type_name_en VARCHAR(100),
    symbol_type_name_bm VARCHAR(100),
    symbol_type_description VARCHAR(100),
    sequence_no SMALLINT
);

CREATE TABLE IF NOT EXISTS symbology.symbol_orientation (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_orientation_name_en VARCHAR(50),
    symbol_orientation_name_bm VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS symbology.symbol_type_library (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_type_lib_name VARCHAR(30),
    description VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp_unit (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_category_id UUID,
    symbol_unit_name_en VARCHAR(200),
    symbol_unit_name_bm VARCHAR(200),
    symbol_description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS symbology.symbol_mafjp (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    symbol_mafjp_unit_id UUID,
    symbol_type_id UUID,
    font_list VARCHAR(8000),
    symbol_orientation_id UUID,
    symbol_name VARCHAR(100),
    sequence_no SMALLINT
);


-- ============================================================
-- 5. MIGRATE PARENT TABLE DATA
-- ============================================================

INSERT INTO symbology.symbol_mafjp_category (
    id,
    symbol_category_name_en,
    symbol_category_name_bm,
    symbol_description
)
SELECT
    m.new_id,
    s."SymbolCategoryNameEN",
    s."SymbolCategoryNameBM",
    s."SymbolDescription"
FROM public."SymbolMAFJPCategory" s
JOIN symbology.symbol_mafjp_category_id_map m
    ON m.old_id = s."SymbolCategoryID"
ON CONFLICT (id) DO UPDATE SET
    symbol_category_name_en = EXCLUDED.symbol_category_name_en,
    symbol_category_name_bm = EXCLUDED.symbol_category_name_bm,
    symbol_description = EXCLUDED.symbol_description;


INSERT INTO symbology.symbol_mafjp_type (
    id,
    symbol_type_name_en,
    symbol_type_name_bm,
    symbol_type_description,
    sequence_no
)
SELECT
    m.new_id,
    s."SymbolTypeNameEN",
    s."SymbolTypeNameBM",
    s."SymbolTypeDescription",
    s."SequenceNo"
FROM public."SymbolMAFJPType" s
JOIN symbology.symbol_mafjp_type_id_map m
    ON m.old_id = s."SymbolTypeID"
ON CONFLICT (id) DO UPDATE SET
    symbol_type_name_en = EXCLUDED.symbol_type_name_en,
    symbol_type_name_bm = EXCLUDED.symbol_type_name_bm,
    symbol_type_description = EXCLUDED.symbol_type_description,
    sequence_no = EXCLUDED.sequence_no;


INSERT INTO symbology.symbol_orientation (
    id,
    symbol_orientation_name_en,
    symbol_orientation_name_bm
)
SELECT
    m.new_id,
    s."SymbolOrientationNameEN",
    s."SymbolOrientationNameBM"
FROM public."SymbolOrientation" s
JOIN symbology.symbol_orientation_id_map m
    ON m.old_id = s."SymbolOrientationID"
ON CONFLICT (id) DO UPDATE SET
    symbol_orientation_name_en = EXCLUDED.symbol_orientation_name_en,
    symbol_orientation_name_bm = EXCLUDED.symbol_orientation_name_bm;


INSERT INTO symbology.symbol_type_library (
    id,
    symbol_type_lib_name,
    description
)
SELECT
    m.new_id,
    s."SymbolTypeLibName",
    s."Description"
FROM public."SymbolTypeLibrary" s
JOIN symbology.symbol_type_library_id_map m
    ON m.old_id = s."SymbolTypeLibID"
ON CONFLICT (id) DO UPDATE SET
    symbol_type_lib_name = EXCLUDED.symbol_type_lib_name,
    description = EXCLUDED.description;


-- ============================================================
-- 6. MIGRATE SYMBOL MAFJP UNIT
-- ============================================================

INSERT INTO symbology.symbol_mafjp_unit (
    id,
    symbol_category_id,
    symbol_unit_name_en,
    symbol_unit_name_bm,
    symbol_description
)
SELECT
    unit_map.new_id,
    category_map.new_id,
    source."SymbolUnitNameEN",
    source."SymbolUnitNameBM",
    source."SymbolDescription"
FROM public."SymbolMAFJPUnit" source
JOIN symbology.symbol_mafjp_unit_id_map unit_map
    ON unit_map.old_id = source."SymbolUnitID"
LEFT JOIN symbology.symbol_mafjp_category_id_map category_map
    ON category_map.old_id = source."SymbolCategoryID"
ON CONFLICT (id) DO UPDATE SET
    symbol_category_id = EXCLUDED.symbol_category_id,
    symbol_unit_name_en = EXCLUDED.symbol_unit_name_en,
    symbol_unit_name_bm = EXCLUDED.symbol_unit_name_bm,
    symbol_description = EXCLUDED.symbol_description;


-- ============================================================
-- 7. MIGRATE SYMBOL MAFJP
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
    symbol_map.new_id,
    unit_map.new_id,
    type_map.new_id,
    source."FontList",
    orientation_map.new_id,
    source."SymbolName",
    source."SequenceNo"
FROM public."SymbolMAFJP" source
JOIN symbology.symbol_mafjp_id_map symbol_map
    ON symbol_map.old_id = source."SymbolID"
LEFT JOIN symbology.symbol_mafjp_unit_id_map unit_map
    ON unit_map.old_id = source."SymbolUnitID"
LEFT JOIN symbology.symbol_mafjp_type_id_map type_map
    ON type_map.old_id = source."SymbolTypeID"
LEFT JOIN symbology.symbol_orientation_id_map orientation_map
    ON orientation_map.old_id = source."SymbolOrientationID"
ON CONFLICT (id) DO UPDATE SET
    symbol_mafjp_unit_id = EXCLUDED.symbol_mafjp_unit_id,
    symbol_type_id = EXCLUDED.symbol_type_id,
    font_list = EXCLUDED.font_list,
    symbol_orientation_id = EXCLUDED.symbol_orientation_id,
    symbol_name = EXCLUDED.symbol_name,
    sequence_no = EXCLUDED.sequence_no;


-- ============================================================
-- 8. ADD FOREIGN KEY RELATIONSHIPS
-- Same relationships as legacy DB
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_symbol_mafjp_unit_category'
    ) THEN
        ALTER TABLE symbology.symbol_mafjp_unit
        ADD CONSTRAINT fk_symbol_mafjp_unit_category
        FOREIGN KEY (symbol_category_id)
        REFERENCES symbology.symbol_mafjp_category(id);
    END IF;
END $$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_symbol_mafjp_unit'
    ) THEN
        ALTER TABLE symbology.symbol_mafjp
        ADD CONSTRAINT fk_symbol_mafjp_unit
        FOREIGN KEY (symbol_mafjp_unit_id)
        REFERENCES symbology.symbol_mafjp_unit(id);
    END IF;
END $$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_symbol_mafjp_type'
    ) THEN
        ALTER TABLE symbology.symbol_mafjp
        ADD CONSTRAINT fk_symbol_mafjp_type
        FOREIGN KEY (symbol_type_id)
        REFERENCES symbology.symbol_mafjp_type(id);
    END IF;
END $$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_symbol_mafjp_orientation'
    ) THEN
        ALTER TABLE symbology.symbol_mafjp
        ADD CONSTRAINT fk_symbol_mafjp_orientation
        FOREIGN KEY (symbol_orientation_id)
        REFERENCES symbology.symbol_orientation(id);
    END IF;
END $$;


-- ============================================================
-- 9. INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_unit_category_id
ON symbology.symbol_mafjp_unit(symbol_category_id);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_unit_id
ON symbology.symbol_mafjp(symbol_mafjp_unit_id);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_type_id
ON symbology.symbol_mafjp(symbol_type_id);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_orientation_id
ON symbology.symbol_mafjp(symbol_orientation_id);

CREATE INDEX IF NOT EXISTS idx_symbol_mafjp_name
ON symbology.symbol_mafjp(symbol_name);


-- ============================================================
-- 10. VERIFY ROW COUNTS
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM symbology.symbol_mafjp_category)
        AS category_count,
    (SELECT COUNT(*) FROM symbology.symbol_mafjp_type)
        AS type_count,
    (SELECT COUNT(*) FROM symbology.symbol_orientation)
        AS orientation_count,
    (SELECT COUNT(*) FROM symbology.symbol_type_library)
        AS type_library_count,
    (SELECT COUNT(*) FROM symbology.symbol_mafjp_unit)
        AS unit_count,
    (SELECT COUNT(*) FROM symbology.symbol_mafjp)
        AS symbol_count;


-- Expected:
-- category_count     = 34
-- type_count         = 7
-- orientation_count  = 4
-- type_library_count = 2
-- unit_count         = 1201
-- symbol_count       = 6204


-- ============================================================
-- 11. VERIFY RELATIONSHIPS
-- ============================================================

SELECT COUNT(*) AS broken_category_relation
FROM symbology.symbol_mafjp_unit u
LEFT JOIN symbology.symbol_mafjp_category c
    ON c.id = u.symbol_category_id
WHERE u.symbol_category_id IS NOT NULL
  AND c.id IS NULL;


SELECT COUNT(*) AS broken_unit_relation
FROM symbology.symbol_mafjp s
LEFT JOIN symbology.symbol_mafjp_unit u
    ON u.id = s.symbol_mafjp_unit_id
WHERE s.symbol_mafjp_unit_id IS NOT NULL
  AND u.id IS NULL;


SELECT COUNT(*) AS broken_type_relation
FROM symbology.symbol_mafjp s
LEFT JOIN symbology.symbol_mafjp_type t
    ON t.id = s.symbol_type_id
WHERE s.symbol_type_id IS NOT NULL
  AND t.id IS NULL;


SELECT COUNT(*) AS broken_orientation_relation
FROM symbology.symbol_mafjp s
LEFT JOIN symbology.symbol_orientation o
    ON o.id = s.symbol_orientation_id
WHERE s.symbol_orientation_id IS NOT NULL
  AND o.id IS NULL;

-- Expected for all broken relationships:
-- 0


-- ============================================================
-- 12. VERIFY FOREIGN KEYS
-- ============================================================

SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
   AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'symbology'
ORDER BY tc.table_name, tc.constraint_name;


-- ============================================================
-- 13. VERIFY INDEXES
-- ============================================================

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'symbology'
ORDER BY tablename, indexname;


-- ============================================================
-- 14. OPTIONAL CLEANUP
-- ONLY AFTER MIGRATION IS REVIEWED / APPROVED
-- ============================================================

-- DROP TABLE symbology.symbol_mafjp_category_id_map;
-- DROP TABLE symbology.symbol_mafjp_type_id_map;
-- DROP TABLE symbology.symbol_orientation_id_map;
-- DROP TABLE symbology.symbol_type_library_id_map;
-- DROP TABLE symbology.symbol_mafjp_unit_id_map;
-- DROP TABLE symbology.symbol_mafjp_id_map;
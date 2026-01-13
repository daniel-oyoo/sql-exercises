-- Complete Schema Overview
USE gamehub;

-- 1. All Tables with Row Counts
SELECT 
    t.TABLE_NAME as 'Table',
    t.TABLE_ROWS as 'Rows',
    t.TABLE_COMMENT as 'Description'
FROM information_schema.TABLES t
WHERE t.TABLE_SCHEMA = 'gamehub'
ORDER BY t.TABLE_NAME;

-- 2. Detailed Column Information
SELECT 
    c.TABLE_NAME as 'Table',
    c.COLUMN_NAME as 'Column',
    c.COLUMN_TYPE as 'Type',
    c.IS_NULLABLE as 'Nullable',
    c.COLUMN_DEFAULT as 'Default',
    c.COLUMN_COMMENT as 'Description'
FROM information_schema.COLUMNS c
WHERE c.TABLE_SCHEMA = 'gamehub'
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

-- 3. Foreign Key Relationships
SELECT 
    rc.TABLE_NAME as 'Child Table',
    rc.COLUMN_NAME as 'Child Column',
    rc.REFERENCED_TABLE_NAME as 'Parent Table',
    rc.REFERENCED_COLUMN_NAME as 'Parent Column'
FROM information_schema.REFERENTIAL_CONSTRAINTS ref
JOIN information_schema.KEY_COLUMN_USAGE rc
    ON rc.CONSTRAINT_NAME = ref.CONSTRAINT_NAME
WHERE rc.TABLE_SCHEMA = 'gamehub'
ORDER BY rc.TABLE_NAME;

-- 4. Indexes
SELECT 
    TABLE_NAME as 'Table',
    INDEX_NAME as 'Index',
    COLUMN_NAME as 'Column',
    INDEX_TYPE as 'Type'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'gamehub'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- 5. Views
SELECT 
    TABLE_NAME as 'View',
    VIEW_DEFINITION as 'Definition'
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'gamehub';
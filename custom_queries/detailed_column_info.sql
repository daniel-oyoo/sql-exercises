-- 2. Detailed Column Information --daily practise go to view_schema ,copy a section of query ,paste it in your session then run meddle with it to see all possible changes and results
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


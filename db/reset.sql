DO $$ 
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') 
    LOOP 
        EXECUTE 'DROP TABLE IF EXISTS public.' || r.tablename || ' CASCADE';
    END LOOP; 
END $$;


DO $$ 
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tgname, tgrelid::regclass FROM pg_trigger 
              WHERE NOT tgisinternal) 
    LOOP 
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.tgname || ' ON ' || r.tgrelid;
    END LOOP; 
END $$;

#!/bin/bash

psql -c "
    LOAD DATABASE $PG1
    INTO $PG2
    WITH DATA ONLY
    EXCLUDING TABLE NAMES MATCHING '__diesel_schema_migrations'
    ALTER SCHEMA 'vaultwarden' RENAME TO 'public';
"
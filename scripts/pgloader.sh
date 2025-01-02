#!/bin/bash

load database
     from "$DATABASE_URL"
     into "$DB2"
     WITH data only
     EXCLUDING TABLE NAMES MATCHING '__diesel_schema_migrations'
     ALTER SCHEMA 'vaultwarden' RENAME TO 'public'
;
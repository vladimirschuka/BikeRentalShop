#!/bin/bash
pg_dump bikerentalshop -U postgres >dump/dump.sql
pg_dump bikerentalshop -U postgres -s  >dump/dump_schema.sql
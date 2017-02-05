# BikeRentalShop
## Overview

For implement this task I use Postgres as database and ruby as language for ORM implementation and some bash scripts.

##Project structure:

1. dbconfig - folder with the database connection configuration file

* config.yml.example - may be used as example (will be rename as config.yml)

2. documentation - folder contain the documentation files

3. dump - database dump, contain folowing files:

* dump_schema.sql - file with schema only

* dump.sql - schema and sample data

4. ruby scripts:

* db_model.rb - ORM by ruby

* db_sample_data.rb - ruby script with sample data	

## How to use it

The application requirement:

* PostgresSql as Database (version 9.5 or above)

* ruby language for scripts

### Step 1. Git clone
For copy files to local folder

    git clone https://github.com/vladimirschuka/BikeRentalShop.git

### Step 2. DataBase configure
Database configuration file:

    dbconfig/config.yml

repository has `config.yml.example` for example, this file contains:

    dbconfiguration:
        adapter: postgresql
        host: localhost
        database: bikerentalshop
        username: postgres
        password: xxxxxx 

You have to change parameters to your DB.


### Step 3. Add schema to DB

After create file config.yml you you need next:

	bundle install

when all gems will be installed, then:

	run.sh

This main script, create db, create schema, and add sample data on request

### Step 4. Sample terminal application

`ruby run_me.rb`

##Documentation

All documentation in documentation folder [link](https://github.com/vladimirschuka/BikeRentalShop/tree/master/documentation)




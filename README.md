# BikeRentalShop
## Overview

For implement this task I use Postgres as database and ruby as language for ORM implementation and some bash scripts.

##Project structure:

1. dbconfig - the folder with the database connection configuration file

	* config.yml.example - the file with example configuration

2. documentation - the folder with documentation

3. dump - the dumps of the database: the full dump and the schema-only dump

4. ruby scripts:

	* db_model.rb - ORM by ruby

	* db_sample_data.rb - ruby script with sample data	

## How to use it

The application requirement:

* PostgresSql as Database (version 9.5 or above)

* ruby language for scripts

Copy files to local folder

    git clone https://github.com/vladimirschuka/BikeRentalShop.git

Changing the database configuration file:

    dbconfig/config.yml

The repository has `config.yml.example` for example.

    dbconfiguration:
        adapter: postgresql
        host: localhost
        database: bikerentalshop
        username: postgres
        password: xxxxxx 

You have to change parameters to your DB.

After creating configuration file `config.yml`, you need install ruby languge:

	apt-get install ruby

Installation the necessary components

	bundle install

Run the main script, that creating database, creating scheme and the sample data

	run.sh


##Sample terminal application

The small terminal application which show clients and the numbers of the bikes.

	ruby run_me.rb

##Documentation

All documentation in documentation folder [link](https://github.com/vladimirschuka/BikeRentalShop/tree/master/documentation)




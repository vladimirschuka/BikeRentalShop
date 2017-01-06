create sequence main_sequence increment by 1 minvalue 10000;

create table dict_bike_brand
(
brand_id int not null default nextval('main_sequence'),
brand_code varchar(100) not null,
brand_name varchar(100) not null,
brand_dscr varchar(4000) not null,
brand_prof_flag boolean default false,
brand_country varchar(100),
created_at timestamp without time zone default timestamp 'now()' not null,
updated_at timestamp without time zone default timestamp 'now()' not null
) ;

insert into dict_bike_brand
(brand_code,brand_name,brand_dscr,brand_prof_flag,brand_country)
values 
('giant',
'Giant',
'Giant Manufacturing Co. Ltd. is a Taiwanese bicycle manufacturer that is recognized as the world''s largest bicycle manufacturer.',
'1',
'Taiwan'),
(
'trek',
'Trek',
'Trek Bicycle Corporation is a major bicycle and cycling product manufacturer and distributor under brand names Trek, 
  Electra Bicycle Company, Gary Fisher, Bontrager, Diamant Bikes, Villiger Bikes and until 2008, LeMond Racing Cycles and Klein.',
'1',
'US'  
),
(
'btwin',
'B''Twin',
'DECATHLON CYCLE WAS REBORN AS B’TWIN.
By changing its name in the same year as it celebrated its 20th birthday, the brand now had the means to reach its ambition: to become THE favourite brand amongst cyclists.',
'0',
'Fr'  
);

create table dict_bike_types
(
bike_type_id int not null default nextval('main_sequence'),
bike_type_code varchar(100),
bike_type_name varchar(100),
created_at timestamp without time zone default timestamp 'now()' not null,
updated_at timestamp without time zone default timestamp 'now()' not null
);

insert into dict_bike_types
(bike_type_code,bike_type_name)
values
(
'mountain',
'Mountain bike'),
('road',
'Road bike'),
('bmx',
'BMX bike'),
('other',
'Other bike');

create table dict_bike_colors
(
bike_color_id int not null default nextval('main_sequence'),
bike_color_code varchar(100),
bike_color_name varchar(100),
created_at timestamp without time zone default timestamp 'now()' not null,
updated_at timestamp without time zone default timestamp 'now()' not null
);

insert into dict_bike_colors
(bike_color_code,bike_color_name)
values
('black','Black'),
('white','White'),
('red','Red'),
('green','Green'),
('blue','Blue');


















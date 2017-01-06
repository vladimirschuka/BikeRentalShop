create sequence main_sequence increment by 1 minvalue 10000;



drop table dict_bike_brand;

create table dict_bike_brand
(
brand_id int not null default nextval('main_sequence'),
brand_code varchar(100) not null,
brand_name varchar(100) not null,
brand_dscr varchar(4000),
brand_prof_flag boolean,
brand_country varchar(100),
created_at timestamp not null default ,
updated_at timestamp,
) ;

insert into dict_bike



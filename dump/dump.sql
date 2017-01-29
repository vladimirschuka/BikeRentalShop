--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: bikestatechange(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION bikestatechange(p_bike_id integer, p_bike_state_code character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
	new_bike_state_id integer;
begin 
	   
	insert into t_bikes_states 
		(bike_id,bike_state_id,bike_state_date)
	select p_bike_id, bike_state_id,current_timestamp
	 from dict_bike_states where bike_state_code = p_bike_state_code and
	 not exists (
		 select 1 
		 from t_bikes bk
			inner join t_bikes_states bs on bk.bike_current_state_id = bs.id
			inner join dict_bike_states dbs on dbs.bike_state_id = bs.bike_state_id 
		 where bk.bike_id = p_bike_id  and dbs.bike_state_code = p_bike_state_code	
		 )
	returning id into new_bike_state_id;

	update t_bikes set bike_current_state_id = new_bike_state_id
	where bike_id = p_bike_id and new_bike_state_id is not null;
	
	

end;
$$;


ALTER FUNCTION public.bikestatechange(p_bike_id integer, p_bike_state_code character varying) OWNER TO postgres;

--
-- Name: createbike(character varying, character varying, date, double precision, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION createbike(p_bike_inventory_number character varying, p_bike_model_code character varying, p_bike_use_beg_date date, p_bike_price double precision, p_bike_state_code character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
	new_bike_id integer = nextval('main_sequence'::regclass);
	new_bike_state_id integer;
begin
	insert into t_bikes_states 
		(bike_id,bike_state_id,bike_state_date)
	select new_bike_id, bike_state_id,current_timestamp
	 from dict_bike_states where bike_state_code = p_bike_state_code
	returning id into new_bike_state_id;
		
	insert into t_bikes
	(
	bike_id,
	bike_inventory_number,
	bike_model_id,
	bike_use_beg_date,
	bike_price,
	bike_current_state_id
	)
	select new_bike_id,
		p_bike_inventory_number,
		t.bike_model_id,
		p_bike_use_beg_date,
		p_bike_price,
		new_bike_state_id
	from dict_bike_models t where t.bike_model_code = p_bike_model_code;

end;
$$;


ALTER FUNCTION public.createbike(p_bike_inventory_number character varying, p_bike_model_code character varying, p_bike_use_beg_date date, p_bike_price double precision, p_bike_state_code character varying) OWNER TO postgres;

--
-- Name: createbooking(character varying, integer, character varying, timestamp without time zone, timestamp without time zone, integer, timestamp without time zone, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION createbooking(p_booking_code character varying, p_customer_id integer, p_bike_model_code character varying, p_period_beg_date timestamp without time zone, p_period_end_date timestamp without time zone, p_bikes_count integer, p_booking_time timestamp without time zone DEFAULT now(), p_booking_state_code character varying DEFAULT 'new'::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	new_booking_id INTEGER;
begin

	if not exists(select 1 from t_booking where booking_code = p_booking_code) THEN
		insert into t_booking
			(booking_time,
			 booking_code,
			 customer_id,
			 booking_state_id)
		select 	p_booking_time,
						p_booking_code,
						p_customer_id,
						t1.booking_state_id
		from  dict_booking_states t1
		WHERE t1.booking_state_code = p_booking_state_code
		RETURNING booking_id into new_booking_id;
	ELSE
		select booking_id into new_booking_id from t_booking where booking_code = p_booking_code;
	END IF;

	insert into t_booking_consist
		(booking_id, bike_model_id, period_beg_date, period_end_date, bikes_count)
	select new_booking_id, t1.bike_model_id, p_period_beg_date,p_period_end_date,p_bikes_count
	from dict_bike_models t1
	where t1.bike_model_code = p_bike_model_code;

end;
$$;


ALTER FUNCTION public.createbooking(p_booking_code character varying, p_customer_id integer, p_bike_model_code character varying, p_period_beg_date timestamp without time zone, p_period_end_date timestamp without time zone, p_bikes_count integer, p_booking_time timestamp without time zone, p_booking_state_code character varying) OWNER TO postgres;

--
-- Name: p_save_bike_model(integer, character varying, character varying, character varying, character varying, character varying, integer, double precision, integer, double precision, boolean, boolean, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION p_save_bike_model(model_id integer, model_code character varying, model_name character varying, model_brand_code character varying, model_type_code character varying, model_color_code character varying, model_speed_count integer, model_wheel_size_inch double precision, model_year integer, model_weight_kg double precision, model_folding_flag boolean, model_prof_flag boolean, model_current_state_code character varying) RETURNS void
    LANGUAGE sql
    AS $$

	with src
	(model_id,model_code,model_name,model_brand_code,model_type_code,
			model_color_code, model_speed_count,model_wheel_size_inch,model_year,
			  model_weight_kg, model_folding_flag, model_prof_flag,model_current_state_code)	
	as (
	values (model_id,model_code,model_name,model_brand_code,model_type_code,
			model_color_code, model_speed_count,model_wheel_size_inch,model_year,
			  model_weight_kg, model_folding_flag, model_prof_flag,model_current_state_code)
	)
	insert into dict_bike_models
	 (bike_model_code, bike_model_name, bike_model_brand_id,bike_model_type_id, bike_model_color_id,
				bike_model_speed_count, bike_model_wheel_size_inch, bike_model_weight_kg, bike_model_year,
					bike_model_folding_flag, bike_model_prof_flag,bike_model_current_state_id)
	select 	t0.model_code,
		 t0.model_name,
		 t1.brand_id,
		 t4.bike_type_id,
		 t2.bike_color_id,
		 t0.model_speed_count,
		 t0.model_wheel_size_inch,
		 t0.model_weight_kg,
		 t0.model_year,
		 t0.model_folding_flag,
		 t0.model_prof_flag,
		 t3.bike_state_id
	
	from src t0
		inner join dict_bike_brands t1 on t0.model_brand_code = t1.brand_code
		inner join dict_bike_colors t2 on t0.model_color_code = t2.bike_color_code
		inner join dict_bike_states t3 on t0.model_current_state_code = t3.bike_state_code
		inner join dict_bike_types t4 on t0.model_type_code = t4.bike_type_code
	on conflict (bike_model_code) 
	do update
	set 
		bike_model_code = EXCLUDED.bike_model_code,
		bike_model_name = EXCLUDED.bike_model_name,
		bike_model_brand_id = EXCLUDED.bike_model_brand_id,
		bike_model_type_id = EXCLUDED.bike_model_type_id,
		bike_model_color_id = EXCLUDED.bike_model_color_id,
		bike_model_speed_count = EXCLUDED.bike_model_speed_count,
		bike_model_wheel_size_inch = EXCLUDED.bike_model_wheel_size_inch,
		bike_model_weight_kg = EXCLUDED.bike_model_weight_kg,
		bike_model_year = EXCLUDED.bike_model_year,
		bike_model_folding_flag = EXCLUDED.bike_model_folding_flag,
		bike_model_prof_flag = EXCLUDED.bike_model_prof_flag,
		bike_model_current_state_id = EXCLUDED.bike_model_current_state_id,
		updated_at = timestamp without time zone 'now()';
	
$$;


ALTER FUNCTION public.p_save_bike_model(model_id integer, model_code character varying, model_name character varying, model_brand_code character varying, model_type_code character varying, model_color_code character varying, model_speed_count integer, model_wheel_size_inch double precision, model_year integer, model_weight_kg double precision, model_folding_flag boolean, model_prof_flag boolean, model_current_state_code character varying) OWNER TO postgres;

--
-- Name: main_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE main_sequence
    START WITH 10000
    INCREMENT BY 1
    MINVALUE 10000
    NO MAXVALUE
    CACHE 1;


ALTER TABLE main_sequence OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: dict_bike_brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_bike_brands (
    brand_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    brand_code character varying(250) NOT NULL,
    brand_name character varying(250) NOT NULL,
    brand_dscr text NOT NULL,
    brand_prof_flag boolean DEFAULT false,
    brand_country character varying(150),
    created_at timestamp without time zone DEFAULT '2017-01-06 21:23:45.33063'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '2017-01-06 21:23:45.33063'::timestamp without time zone NOT NULL
);


ALTER TABLE dict_bike_brands OWNER TO postgres;

--
-- Name: dict_bike_colors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_bike_colors (
    bike_color_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_color_code character varying(100),
    bike_color_name character varying(100),
    created_at timestamp without time zone DEFAULT '2017-01-07 01:39:37.194508'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '2017-01-07 01:39:37.194508'::timestamp without time zone NOT NULL
);


ALTER TABLE dict_bike_colors OWNER TO postgres;

--
-- Name: dict_bike_models; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_bike_models (
    bike_model_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_model_code character varying(250) NOT NULL,
    bike_model_name character varying(250) NOT NULL,
    bike_model_brand_id integer NOT NULL,
    bike_model_type_id integer NOT NULL,
    bike_model_color_id integer NOT NULL,
    bike_model_speed_count integer NOT NULL,
    bike_model_wheel_size_inch double precision NOT NULL,
    bike_model_weight_kg double precision NOT NULL,
    bike_model_year integer NOT NULL,
    bike_model_folding_flag boolean DEFAULT false NOT NULL,
    bike_model_prof_flag boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT '2017-01-08 04:08:27.991938'::timestamp without time zone,
    updated_at timestamp without time zone DEFAULT '2017-01-08 02:13:22.870837'::timestamp without time zone
);


ALTER TABLE dict_bike_models OWNER TO postgres;

--
-- Name: dict_bike_states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_bike_states (
    bike_state_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_state_code character varying(100),
    bike_state_name character varying(100),
    created_at timestamp without time zone DEFAULT '2017-01-07 01:53:27.712546'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '2017-01-07 01:53:27.712546'::timestamp without time zone NOT NULL
);


ALTER TABLE dict_bike_states OWNER TO postgres;

--
-- Name: dict_bike_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_bike_types (
    bike_type_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_type_code character varying(250),
    bike_type_name character varying(250),
    created_at timestamp without time zone DEFAULT '2017-01-07 01:34:25.79555'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '2017-01-07 01:34:25.79555'::timestamp without time zone NOT NULL
);


ALTER TABLE dict_bike_types OWNER TO postgres;

--
-- Name: dict_booking_states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_booking_states (
    booking_state_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    booking_state_code character varying(250),
    booking_state_name character varying(250),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    booking_state_order integer,
    booking_state_last_flag boolean
);


ALTER TABLE dict_booking_states OWNER TO postgres;

--
-- Name: dict_currencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_currencies (
    currency_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    currency_code character varying(100),
    currency_name character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE dict_currencies OWNER TO postgres;

--
-- Name: dict_dates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_dates (
    sys_date date NOT NULL,
    holiday_flag boolean DEFAULT false NOT NULL
);


ALTER TABLE dict_dates OWNER TO postgres;

--
-- Name: dict_prices_discounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_prices_discounts (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    price_code character varying(250),
    price_name character varying(250),
    price_dscr text,
    price_sum_flag boolean,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE dict_prices_discounts OWNER TO postgres;

--
-- Name: t_bikes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_bikes (
    bike_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_inventory_number character varying(250) NOT NULL,
    bike_model_id integer NOT NULL,
    bike_use_beg_date date NOT NULL,
    bike_price double precision NOT NULL,
    bike_current_state_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT '2017-01-07 14:47:02.453574'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '2017-01-07 14:47:26.194499'::timestamp without time zone NOT NULL
);


ALTER TABLE t_bikes OWNER TO postgres;

--
-- Name: t_bikes_states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_bikes_states (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_id integer,
    bike_state_id integer,
    bike_state_date timestamp without time zone
);


ALTER TABLE t_bikes_states OWNER TO postgres;

--
-- Name: t_booking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_booking (
    booking_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    booking_time timestamp without time zone,
    booking_code character varying(250),
    customer_id integer,
    booking_state_id integer,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_booking OWNER TO postgres;

--
-- Name: t_booking_contents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_booking_contents (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    booking_id integer NOT NULL,
    bike_model_id integer,
    period_beg_date timestamp without time zone,
    period_end_date timestamp without time zone,
    bikes_count integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_booking_contents OWNER TO postgres;

--
-- Name: t_booking_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_booking_orders (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    booking_id integer,
    bike_id integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_booking_orders OWNER TO postgres;

--
-- Name: t_booking_prices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_booking_prices (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    t_price_plans_id integer,
    booking_consist_id integer NOT NULL,
    currency_id integer,
    price double precision,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_booking_prices OWNER TO postgres;

--
-- Name: t_customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_customers (
    customer_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    customer_login character varying(250),
    customer_password character varying(1000),
    customer_name character varying(200),
    customer_surname character varying(200),
    customer_last_name character varying(200),
    mobile_phone_main character varying(50),
    mobile_phone_second character varying(50),
    email character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_customers OWNER TO postgres;

--
-- Name: t_customers_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_customers_groups (
    customer_group_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    customer_group_code character varying(100),
    customer_group_name character varying,
    customer_group_dscr text,
    created_at timestamp without time zone DEFAULT now(),
    update_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_customers_groups OWNER TO postgres;

--
-- Name: t_customers_groups_membership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_customers_groups_membership (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    beg_date timestamp without time zone,
    end_date timestamp without time zone,
    customer_id integer,
    customer_group_id integer,
    created_at timestamp without time zone DEFAULT now(),
    update_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_customers_groups_membership OWNER TO postgres;

--
-- Name: t_prices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    beg_date timestamp without time zone,
    end_date timestamp without time zone,
    bike_model_id integer,
    currency_id integer,
    price double precision,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_prices OWNER TO postgres;

--
-- Name: t_prices_specials_conditions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices_specials_conditions (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    price_plan_id integer,
    beg_date_order timestamp without time zone,
    end_date_order timestamp without time zone,
    period_beg_date timestamp without time zone,
    period_end_date timestamp without time zone,
    bike_model_id integer,
    customer_group_id integer,
    bike_count integer,
    period_order_in_hour integer,
    price_specials_value double precision,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    holiday_flag boolean
);


ALTER TABLE t_prices_specials_conditions OWNER TO postgres;

--
-- Name: v_bike_models; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_bike_models AS
 SELECT t1.bike_model_id,
    t1.bike_model_code,
    t1.bike_model_brand_id,
    t2.brand_code,
    t2.brand_name,
    t1.bike_model_type_id,
    t5.bike_type_code,
    t5.bike_type_name,
    t1.bike_model_color_id,
    t3.bike_color_code,
    t3.bike_color_name,
    t1.bike_model_speed_count,
    t1.bike_model_wheel_size_inch,
    t1.bike_model_weight_kg,
    t1.bike_model_year,
    t1.bike_model_folding_flag,
    t1.bike_model_prof_flag,
    t1.created_at,
    t1.updated_at
   FROM dict_bike_models t1,
    dict_bike_brands t2,
    dict_bike_colors t3,
    dict_bike_types t5
  WHERE ((t1.bike_model_brand_id = t2.brand_id) AND (t1.bike_model_type_id = t5.bike_type_id) AND (t1.bike_model_color_id = t3.bike_color_id));


ALTER TABLE v_bike_models OWNER TO postgres;

--
-- Name: v_booking_price_base_by_sysdate; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_booking_price_base_by_sysdate AS
 SELECT t2.booking_id,
    t1.id AS booking_consist_id,
    t0.sys_date,
    t1.bike_model_id,
    t3.customer_id,
    t3.customer_login,
    t1.bikes_count,
    t6.currency_id,
    t6.price
   FROM ((((dict_dates t0
     JOIN t_booking_contents t1 ON (((t0.sys_date >= t1.period_beg_date) AND (t0.sys_date <= t1.period_end_date))))
     JOIN t_booking t2 ON ((t1.booking_id = t2.booking_id)))
     JOIN t_customers t3 ON ((t2.customer_id = t3.customer_id)))
     JOIN t_prices t6 ON ((((t0.sys_date >= t6.beg_date) AND (t0.sys_date <= t6.end_date)) AND (t6.bike_model_id = t1.bike_model_id))));


ALTER TABLE v_booking_price_base_by_sysdate OWNER TO postgres;

--
-- Name: v_booking_prices; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_booking_prices AS
 SELECT t0.sys_date,
    t1.booking_id,
    t1.bike_model_id,
    t1.bikes_count,
    t2.currency_id,
    t2.price
   FROM ((dict_dates t0
     JOIN t_booking_contents t1 ON (((t0.sys_date >= t1.period_beg_date) AND (t0.sys_date <= t1.period_end_date))))
     JOIN t_prices t2 ON ((((t0.sys_date >= t2.beg_date) AND (t0.sys_date <= t2.end_date)) AND (t2.bike_model_id = t1.bike_model_id))));


ALTER TABLE v_booking_prices OWNER TO postgres;

--
-- Name: v_booking_special_prices; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_booking_special_prices AS
 SELECT t0.sys_date,
    t1.id AS booking_consist_id,
    t1.booking_id,
    t1.bike_model_id,
    t1.bikes_count,
    t2.currency_id,
    t2.price,
    t3.id AS discount_id,
    t3.price_code,
    t3.price_sum_flag,
    t4.id,
    t4.price_specials_value
   FROM (((((dict_dates t0
     JOIN t_booking_contents t1 ON (((t0.sys_date >= t1.period_beg_date) AND (t0.sys_date <= t1.period_end_date))))
     JOIN t_booking t10 ON ((t1.booking_id = t10.booking_id)))
     JOIN t_prices t2 ON ((((t0.sys_date >= t2.beg_date) AND (t0.sys_date <= t2.end_date)) AND (t2.bike_model_id = t1.bike_model_id))))
     CROSS JOIN dict_prices_discounts t3)
     JOIN t_prices_specials_conditions t4 ON (((t3.id = t4.price_plan_id) AND ((t10.booking_time >= t4.beg_date_order) AND (t10.booking_time <= t4.end_date_order)) AND ((t0.sys_date >= t4.period_beg_date) AND (t0.sys_date <= t4.period_end_date)) AND ((t1.bike_model_id = t4.bike_model_id) OR (t4.bike_model_id IS NULL)) AND ((EXISTS ( SELECT 1
           FROM t_customers_groups_membership t100
          WHERE (((t0.sys_date >= t100.beg_date) AND (t0.sys_date <= t100.end_date)) AND (t10.customer_id = t100.customer_id) AND (t4.customer_group_id = t100.customer_group_id)))) OR (t4.customer_group_id IS NULL)) AND ((EXISTS ( SELECT 1
           FROM t_booking_contents t110
          WHERE (((t110.bike_model_id = t4.bike_model_id) OR (t4.bike_model_id IS NULL)) AND (t110.booking_id = t1.booking_id))
         HAVING (sum(t110.bikes_count) >= t4.bike_count))) OR (t4.bike_count IS NULL)) AND (((t1.period_beg_date + ((t4.period_order_in_hour || ' hour'::text))::interval) <= t1.period_end_date) OR (t4.period_order_in_hour IS NULL)) AND ((t0.holiday_flag = t4.holiday_flag) OR (t4.holiday_flag IS NULL)))));


ALTER TABLE v_booking_special_prices OWNER TO postgres;

--
-- Name: v_customers_groups_membership; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_customers_groups_membership AS
 SELECT t1.id,
    t1.beg_date,
    t1.end_date,
    t1.customer_id,
    t2.customer_login,
    t2.customer_name,
    t2.customer_surname,
    t2.customer_last_name,
    t1.customer_group_id,
    t3.customer_group_code,
    t3.customer_group_name
   FROM ((t_customers_groups_membership t1
     JOIN t_customers t2 ON ((t1.customer_id = t2.customer_id)))
     JOIN t_customers_groups t3 ON ((t1.customer_group_id = t3.customer_group_id)));


ALTER TABLE v_customers_groups_membership OWNER TO postgres;

--
-- Data for Name: dict_bike_brands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_bike_brands (brand_id, brand_code, brand_name, brand_dscr, brand_prof_flag, brand_country, created_at, updated_at) FROM stdin;
10002	giant	Giant	Giant Manufacturing Co. Ltd. is a Taiwanese bicycle manufacturer that is recognized as the world's largest bicycle manufacturer.	t	Taiwan	2017-01-06 21:23:45.33063	2017-01-06 21:23:45.33063
10003	trek	Trek	Trek Bicycle Corporation is a major bicycle and cycling product manufacturer and distributor under brand names Trek, \n  Electra Bicycle Company, Gary Fisher, Bontrager, Diamant Bikes, Villiger Bikes and until 2008, LeMond Racing Cycles and Klein.	t	US	2017-01-06 21:23:45.33063	2017-01-06 21:23:45.33063
10004	btwin	B'Twin	DECATHLON CYCLE WAS REBORN AS B’TWIN.\nBy changing its name in the same year as it celebrated its 20th birthday, the brand now had the means to reach its ambition: to become THE favourite brand amongst cyclists.	f	Fr	2017-01-06 21:23:45.33063	2017-01-06 21:23:45.33063
10025	forward	Forward	One of most popular bikes in Russia	f	Russia	2017-01-06 21:23:45.33063	2017-01-06 21:23:45.33063
\.


--
-- Data for Name: dict_bike_colors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_bike_colors (bike_color_id, bike_color_code, bike_color_name, created_at, updated_at) FROM stdin;
10009	black	Black	2017-01-07 01:39:37.194508	2017-01-07 01:39:37.194508
10010	white	White	2017-01-07 01:39:37.194508	2017-01-07 01:39:37.194508
10011	red	Red	2017-01-07 01:39:37.194508	2017-01-07 01:39:37.194508
10012	green	Green	2017-01-07 01:39:37.194508	2017-01-07 01:39:37.194508
10013	blue	Blue	2017-01-07 01:39:37.194508	2017-01-07 01:39:37.194508
10024	yellow	Yellow	2017-01-07 01:39:37.194508	2017-01-07 01:39:37.194508
\.


--
-- Data for Name: dict_bike_models; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_bike_models (bike_model_id, bike_model_code, bike_model_name, bike_model_brand_id, bike_model_type_id, bike_model_color_id, bike_model_speed_count, bike_model_wheel_size_inch, bike_model_weight_kg, bike_model_year, bike_model_folding_flag, bike_model_prof_flag, created_at, updated_at) FROM stdin;
10211	giant_black_mountain	Giant Black Mountain bike	10002	10005	10009	1	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10212	giant_black_road	Giant Black Road bike	10002	10006	10009	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10213	giant_black_bmx	Giant Black BMX bike	10002	10007	10009	1	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10214	giant_black_other	Giant Black Other bike	10002	10008	10009	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10215	giant_black_child	Giant Black Childrens	10002	10018	10009	1	24	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10216	giant_white_mountain	Giant White Mountain bike	10002	10005	10010	1	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10217	giant_white_road	Giant White Road bike	10002	10006	10010	1	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10218	giant_white_bmx	Giant White BMX bike	10002	10007	10010	1	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10219	giant_white_other	Giant White Other bike	10002	10008	10010	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10220	giant_white_child	Giant White Childrens	10002	10018	10010	1	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10221	giant_red_mountain	Giant Red Mountain bike	10002	10005	10011	1	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10222	giant_red_road	Giant Red Road bike	10002	10006	10011	1	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10223	giant_red_bmx	Giant Red BMX bike	10002	10007	10011	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10224	giant_red_other	Giant Red Other bike	10002	10008	10011	1	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10225	giant_red_child	Giant Red Childrens	10002	10018	10011	1	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10226	giant_green_mountain	Giant Green Mountain bike	10002	10005	10012	1	24	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10227	giant_green_road	Giant Green Road bike	10002	10006	10012	1	24	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10228	giant_green_bmx	Giant Green BMX bike	10002	10007	10012	1	24	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10229	giant_green_other	Giant Green Other bike	10002	10008	10012	1	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10230	giant_green_child	Giant Green Childrens	10002	10018	10012	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10231	giant_blue_mountain	Giant Blue Mountain bike	10002	10005	10013	1	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10232	giant_blue_road	Giant Blue Road bike	10002	10006	10013	1	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10233	giant_blue_bmx	Giant Blue BMX bike	10002	10007	10013	1	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10234	giant_blue_other	Giant Blue Other bike	10002	10008	10013	1	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10235	giant_blue_child	Giant Blue Childrens	10002	10018	10013	1	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10236	giant_yellow_mountain	Giant Yellow Mountain bike	10002	10005	10024	1	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10237	giant_yellow_road	Giant Yellow Road bike	10002	10006	10024	1	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10238	giant_yellow_bmx	Giant Yellow BMX bike	10002	10007	10024	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10239	giant_yellow_other	Giant Yellow Other bike	10002	10008	10024	1	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10240	giant_yellow_child	Giant Yellow Childrens	10002	10018	10024	1	24	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10241	trek_black_mountain	Trek Black Mountain bike	10003	10005	10009	1	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10242	trek_black_road	Trek Black Road bike	10003	10006	10009	1	24	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10243	trek_black_bmx	Trek Black BMX bike	10003	10007	10009	1	24	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10244	trek_black_other	Trek Black Other bike	10003	10008	10009	1	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10245	trek_black_child	Trek Black Childrens	10003	10018	10009	1	24	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10246	trek_white_mountain	Trek White Mountain bike	10003	10005	10010	1	24	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10247	trek_white_road	Trek White Road bike	10003	10006	10010	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10248	trek_white_bmx	Trek White BMX bike	10003	10007	10010	1	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10249	trek_white_other	Trek White Other bike	10003	10008	10010	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10250	trek_white_child	Trek White Childrens	10003	10018	10010	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10251	trek_red_mountain	Trek Red Mountain bike	10003	10005	10011	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10252	trek_red_road	Trek Red Road bike	10003	10006	10011	1	24	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10253	trek_red_bmx	Trek Red BMX bike	10003	10007	10011	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10254	trek_red_other	Trek Red Other bike	10003	10008	10011	1	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10255	trek_red_child	Trek Red Childrens	10003	10018	10011	1	24	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10256	trek_green_mountain	Trek Green Mountain bike	10003	10005	10012	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10257	trek_green_road	Trek Green Road bike	10003	10006	10012	1	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10258	trek_green_bmx	Trek Green BMX bike	10003	10007	10012	1	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10259	trek_green_other	Trek Green Other bike	10003	10008	10012	1	24	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10260	trek_green_child	Trek Green Childrens	10003	10018	10012	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10261	trek_blue_mountain	Trek Blue Mountain bike	10003	10005	10013	1	24	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10262	trek_blue_road	Trek Blue Road bike	10003	10006	10013	1	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10263	trek_blue_bmx	Trek Blue BMX bike	10003	10007	10013	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10264	trek_blue_other	Trek Blue Other bike	10003	10008	10013	1	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10265	trek_blue_child	Trek Blue Childrens	10003	10018	10013	1	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10266	trek_yellow_mountain	Trek Yellow Mountain bike	10003	10005	10024	1	24	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10267	trek_yellow_road	Trek Yellow Road bike	10003	10006	10024	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10268	trek_yellow_bmx	Trek Yellow BMX bike	10003	10007	10024	1	24	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10269	trek_yellow_other	Trek Yellow Other bike	10003	10008	10024	1	24	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10270	trek_yellow_child	Trek Yellow Childrens	10003	10018	10024	1	24	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10271	btwin_black_mountain	B'Twin Black Mountain bike	10004	10005	10009	1	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10272	btwin_black_road	B'Twin Black Road bike	10004	10006	10009	1	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10273	btwin_black_bmx	B'Twin Black BMX bike	10004	10007	10009	1	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10274	btwin_black_other	B'Twin Black Other bike	10004	10008	10009	1	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10275	btwin_black_child	B'Twin Black Childrens	10004	10018	10009	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10276	btwin_white_mountain	B'Twin White Mountain bike	10004	10005	10010	1	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10277	btwin_white_road	B'Twin White Road bike	10004	10006	10010	1	24	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10278	btwin_white_bmx	B'Twin White BMX bike	10004	10007	10010	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10279	btwin_white_other	B'Twin White Other bike	10004	10008	10010	1	24	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10280	btwin_white_child	B'Twin White Childrens	10004	10018	10010	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10281	btwin_red_mountain	B'Twin Red Mountain bike	10004	10005	10011	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10282	btwin_red_road	B'Twin Red Road bike	10004	10006	10011	1	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10283	btwin_red_bmx	B'Twin Red BMX bike	10004	10007	10011	1	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10284	btwin_red_other	B'Twin Red Other bike	10004	10008	10011	1	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10285	btwin_red_child	B'Twin Red Childrens	10004	10018	10011	1	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10286	btwin_green_mountain	B'Twin Green Mountain bike	10004	10005	10012	1	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10287	btwin_green_road	B'Twin Green Road bike	10004	10006	10012	1	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10288	btwin_green_bmx	B'Twin Green BMX bike	10004	10007	10012	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10289	btwin_green_other	B'Twin Green Other bike	10004	10008	10012	1	24	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10290	btwin_green_child	B'Twin Green Childrens	10004	10018	10012	1	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10291	btwin_blue_mountain	B'Twin Blue Mountain bike	10004	10005	10013	1	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10292	btwin_blue_road	B'Twin Blue Road bike	10004	10006	10013	1	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10293	btwin_blue_bmx	B'Twin Blue BMX bike	10004	10007	10013	1	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10294	btwin_blue_other	B'Twin Blue Other bike	10004	10008	10013	1	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10295	btwin_blue_child	B'Twin Blue Childrens	10004	10018	10013	1	24	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10296	btwin_yellow_mountain	B'Twin Yellow Mountain bike	10004	10005	10024	1	24	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10297	btwin_yellow_road	B'Twin Yellow Road bike	10004	10006	10024	1	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10298	btwin_yellow_bmx	B'Twin Yellow BMX bike	10004	10007	10024	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10299	btwin_yellow_other	B'Twin Yellow Other bike	10004	10008	10024	1	24	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10300	btwin_yellow_child	B'Twin Yellow Childrens	10004	10018	10024	1	24	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10301	forward_black_mountain	Forward Black Mountain bike	10025	10005	10009	1	24	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10302	forward_black_road	Forward Black Road bike	10025	10006	10009	1	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10303	forward_black_bmx	Forward Black BMX bike	10025	10007	10009	1	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10304	forward_black_other	Forward Black Other bike	10025	10008	10009	1	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10305	forward_black_child	Forward Black Childrens	10025	10018	10009	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10306	forward_white_mountain	Forward White Mountain bike	10025	10005	10010	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10307	forward_white_road	Forward White Road bike	10025	10006	10010	1	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10308	forward_white_bmx	Forward White BMX bike	10025	10007	10010	1	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10309	forward_white_other	Forward White Other bike	10025	10008	10010	1	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10310	forward_white_child	Forward White Childrens	10025	10018	10010	1	24	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10311	forward_red_mountain	Forward Red Mountain bike	10025	10005	10011	1	24	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10312	forward_red_road	Forward Red Road bike	10025	10006	10011	1	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10313	forward_red_bmx	Forward Red BMX bike	10025	10007	10011	1	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10314	forward_red_other	Forward Red Other bike	10025	10008	10011	1	24	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10315	forward_red_child	Forward Red Childrens	10025	10018	10011	1	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10316	forward_green_mountain	Forward Green Mountain bike	10025	10005	10012	1	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10317	forward_green_road	Forward Green Road bike	10025	10006	10012	1	24	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10318	forward_green_bmx	Forward Green BMX bike	10025	10007	10012	1	24	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10319	forward_green_other	Forward Green Other bike	10025	10008	10012	1	24	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10320	forward_green_child	Forward Green Childrens	10025	10018	10012	1	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10321	forward_blue_mountain	Forward Blue Mountain bike	10025	10005	10013	1	24	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10322	forward_blue_road	Forward Blue Road bike	10025	10006	10013	1	24	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10323	forward_blue_bmx	Forward Blue BMX bike	10025	10007	10013	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10324	forward_blue_other	Forward Blue Other bike	10025	10008	10013	1	24	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10325	forward_blue_child	Forward Blue Childrens	10025	10018	10013	1	24	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10326	forward_yellow_mountain	Forward Yellow Mountain bike	10025	10005	10024	1	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10327	forward_yellow_road	Forward Yellow Road bike	10025	10006	10024	1	24	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10328	forward_yellow_bmx	Forward Yellow BMX bike	10025	10007	10024	1	24	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10329	forward_yellow_other	Forward Yellow Other bike	10025	10008	10024	1	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10330	forward_yellow_child	Forward Yellow Childrens	10025	10018	10024	1	24	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
\.


--
-- Data for Name: dict_bike_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_bike_states (bike_state_id, bike_state_code, bike_state_name, created_at, updated_at) FROM stdin;
10014	work	Work	2017-01-07 01:53:27.712546	2017-01-07 01:53:27.712546
10015	broken	Broken	2017-01-07 01:53:27.712546	2017-01-07 01:53:27.712546
10016	onservice	On service	2017-01-07 01:53:27.712546	2017-01-07 01:53:27.712546
10017	eol	End of life	2017-01-07 01:53:27.712546	2017-01-07 01:53:27.712546
10026	using	Clients using	2017-01-07 01:53:27.712546	2017-01-07 01:53:27.712546
\.


--
-- Data for Name: dict_bike_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_bike_types (bike_type_id, bike_type_code, bike_type_name, created_at, updated_at) FROM stdin;
10005	mountain	Mountain bike	2017-01-07 01:34:25.79555	2017-01-07 01:34:25.79555
10006	road	Road bike	2017-01-07 01:34:25.79555	2017-01-07 01:34:25.79555
10007	bmx	BMX bike	2017-01-07 01:34:25.79555	2017-01-07 01:34:25.79555
10008	other	Other bike	2017-01-07 01:34:25.79555	2017-01-07 01:34:25.79555
10018	child	Childrens	2017-01-07 01:34:25.79555	2017-01-07 01:34:25.79555
\.


--
-- Data for Name: dict_booking_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_booking_states (booking_state_id, booking_state_code, booking_state_name, created_at, updated_at, booking_state_order, booking_state_last_flag) FROM stdin;
13691	new	New	2017-01-21 16:20:05.552974	2017-01-21 16:20:05.552974	100	f
13693	confirmed	Confirmed	2017-01-21 16:20:05.562033	2017-01-21 16:20:05.562033	200	f
13694	completed	Completed	2017-01-21 16:20:05.566253	2017-01-21 16:20:05.566253	300	t
13692	canceled	Canceled	2017-01-21 16:20:05.557719	2017-01-21 16:20:05.557719	250	t
\.


--
-- Data for Name: dict_currencies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_currencies (currency_id, currency_code, currency_name, created_at, updated_at) FROM stdin;
10030	eur	EUR	2017-01-09 20:22:41.439588	2017-01-09 20:22:41.439588
10031	chf	CHF	2017-01-09 20:22:41.447907	2017-01-09 20:22:41.447907
\.


--
-- Data for Name: dict_dates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_dates (sys_date, holiday_flag) FROM stdin;
2018-05-19	t
2018-05-20	t
2018-05-26	t
2018-05-27	t
2018-06-02	t
2018-06-03	t
2018-06-09	t
2018-06-10	t
2018-06-16	t
2018-06-17	t
2029-04-21	t
2029-04-22	t
2029-04-28	t
2029-04-29	t
2018-09-08	t
2018-09-09	t
2018-09-15	t
2018-09-16	t
2018-09-22	t
2018-09-23	t
2018-09-29	t
2018-09-30	t
2018-10-06	t
2018-10-07	t
2018-10-13	t
2018-10-14	t
2018-10-20	t
2018-10-21	t
2018-10-27	t
2018-10-28	t
2018-11-03	t
2018-11-04	t
2018-11-10	t
2018-11-11	t
2018-11-17	t
2018-11-18	t
2018-11-24	t
2018-11-25	t
2018-12-01	t
2018-12-02	t
2018-12-08	t
2018-12-09	t
2018-12-15	t
2018-12-16	t
2018-12-22	t
2018-12-23	t
2019-11-30	t
2019-12-01	t
2019-12-07	t
2019-12-08	t
2019-12-14	t
2019-12-15	t
2019-12-21	t
2019-12-22	t
2019-12-28	t
2019-12-29	t
2020-01-04	t
2020-01-05	t
2020-01-11	t
2020-01-12	t
2020-01-18	t
2020-01-19	t
2020-01-25	t
2020-01-26	t
2020-02-01	t
2020-02-02	t
2020-02-08	t
2021-11-27	t
2021-11-28	t
2021-12-04	t
2021-12-05	t
2021-12-11	t
2021-12-12	t
2021-12-18	t
2021-12-19	t
2021-12-25	t
2021-12-26	t
2022-01-01	t
2022-01-02	t
2022-01-08	t
2022-01-09	t
2022-01-15	t
2022-01-16	t
2022-01-22	t
2022-01-23	t
2022-01-29	t
2022-01-30	t
2022-02-05	t
2022-02-06	t
2022-02-12	t
2020-12-20	t
2020-12-26	t
2020-12-27	t
2021-01-02	t
2021-01-03	t
2021-01-09	t
2019-06-02	t
2019-06-08	t
2019-06-09	t
2019-06-15	t
2019-06-16	t
2019-06-22	t
2019-06-23	t
2019-06-29	t
2019-06-30	t
2019-07-06	t
2019-07-07	t
2019-07-13	t
2022-02-13	t
2022-02-19	t
2022-02-20	t
2022-02-26	t
2022-02-27	t
2022-03-05	t
2022-03-06	t
2022-03-12	t
2022-03-13	t
2020-03-08	t
2020-03-14	t
2020-03-15	t
2020-03-21	t
2020-03-22	t
2020-03-28	t
2020-03-29	t
2020-04-04	t
2020-04-05	t
2020-04-11	t
2020-04-12	t
2020-04-18	t
2020-04-19	t
2020-04-25	t
2020-04-26	t
2020-05-02	t
2020-05-03	t
2017-10-21	t
2017-10-22	t
2017-10-28	t
2017-10-29	t
2017-11-04	t
2017-11-05	t
2017-11-11	t
2021-01-17	t
2021-01-23	t
2021-01-24	t
2021-01-30	t
2021-01-31	t
2021-02-06	t
2021-02-07	t
2021-02-13	t
2024-03-10	t
2024-03-16	t
2024-03-17	t
2024-03-23	t
2024-03-24	t
2024-03-30	t
2024-03-31	t
2024-04-06	t
2021-03-13	t
2019-03-09	t
2019-03-10	t
2019-03-16	t
2019-03-17	t
2019-03-23	t
2019-03-24	t
2019-03-30	t
2019-03-31	t
2019-04-06	t
2019-04-07	t
2019-04-13	t
2019-04-14	t
2019-04-20	t
2019-04-21	t
2019-04-27	t
2019-04-28	t
2019-05-04	t
2020-05-09	t
2020-05-10	t
2020-05-16	t
2020-05-17	t
2020-05-23	t
2020-05-24	t
2020-05-30	t
2020-05-31	t
2020-06-06	t
2020-06-07	t
2020-06-13	t
2020-06-14	t
2020-06-20	t
2020-06-21	t
2020-06-27	t
2020-06-28	t
2020-07-04	t
2020-07-05	t
2020-07-11	t
2020-07-12	t
2020-07-18	t
2020-07-19	t
2020-07-25	t
2020-07-26	t
2020-08-01	t
2020-08-02	t
2020-08-08	t
2020-08-09	t
2020-08-15	t
2020-08-16	t
2022-03-19	t
2022-03-20	t
2022-03-26	t
2022-03-27	t
2022-04-02	t
2022-04-03	t
2022-04-09	t
2022-04-10	t
2022-04-16	t
2022-04-17	t
2022-04-23	t
2022-04-24	t
2022-04-30	t
2022-05-01	t
2022-05-07	t
2022-05-08	t
2022-05-14	t
2022-05-15	t
2022-05-21	t
2022-05-22	t
2022-05-28	t
2022-05-29	t
2022-06-04	t
2022-06-05	t
2022-06-11	t
2022-06-12	t
2022-06-18	t
2022-06-19	t
2022-06-25	t
2022-06-26	t
2022-07-02	t
2022-07-03	t
2022-07-09	t
2022-07-10	t
2022-07-16	t
2022-07-17	t
2022-07-23	t
2022-07-24	t
2022-07-30	t
2022-07-31	t
2022-08-06	t
2022-08-07	t
2022-08-13	t
2022-08-14	t
2022-08-20	t
2022-08-21	t
2022-08-27	t
2022-10-02	t
2022-10-08	t
2022-10-09	t
2022-10-15	t
2022-10-16	t
2022-10-22	t
2022-10-23	t
2022-10-29	t
2022-10-30	t
2022-11-05	t
2022-11-06	t
2022-11-12	t
2022-11-13	t
2022-11-19	t
2022-11-20	t
2022-11-26	t
2022-11-27	t
2022-12-03	t
2022-12-04	t
2022-12-10	t
2022-12-11	t
2022-12-17	t
2022-12-18	t
2022-12-24	t
2022-12-25	t
2022-12-31	t
2023-01-01	t
2023-01-07	t
2023-01-08	t
2023-01-14	t
2023-01-15	t
2023-01-21	t
2023-01-22	t
2023-01-28	t
2023-01-29	t
2023-02-04	t
2023-02-05	t
2023-02-11	t
2023-02-12	t
2023-02-18	t
2023-02-19	t
2023-02-25	t
2023-02-26	t
2023-03-04	t
2023-03-05	t
2023-03-11	t
2023-03-12	t
2023-03-18	t
2023-03-19	t
2023-03-25	t
2023-03-26	t
2023-04-01	t
2023-04-02	t
2023-04-08	t
2023-04-09	t
2023-04-15	t
2023-04-16	t
2023-04-22	t
2023-04-23	t
2023-04-29	t
2023-04-30	t
2023-05-06	t
2023-05-07	t
2023-05-13	t
2023-05-14	t
2023-05-20	t
2023-05-21	t
2023-05-27	t
2023-05-28	t
2023-06-03	t
2023-06-04	t
2023-06-10	t
2023-06-11	t
2023-06-17	t
2023-06-18	t
2023-06-24	t
2023-06-25	t
2023-07-01	t
2023-07-02	t
2023-07-08	t
2023-07-09	t
2023-07-15	t
2023-07-16	t
2023-07-22	t
2023-07-23	t
2023-07-29	t
2023-07-30	t
2023-08-05	t
2023-08-06	t
2023-08-12	t
2023-08-13	t
2023-08-19	t
2023-08-20	t
2023-08-26	t
2023-08-27	t
2023-09-02	t
2023-09-03	t
2023-09-09	t
2023-09-10	t
2023-09-16	t
2023-09-17	t
2023-09-23	t
2023-09-24	t
2023-09-30	t
2023-10-01	t
2023-10-07	t
2023-10-08	t
2023-10-14	t
2023-10-15	t
2023-10-21	t
2023-10-22	t
2023-10-28	t
2023-10-29	t
2023-11-04	t
2023-11-05	t
2024-04-07	t
2024-04-13	t
2024-04-14	t
2024-04-20	t
2024-04-21	t
2024-04-27	t
2024-04-28	t
2024-05-04	t
2024-05-05	t
2024-05-11	t
2024-05-12	t
2024-05-18	t
2024-05-19	t
2024-05-25	t
2024-05-26	t
2024-06-01	t
2024-06-02	t
2024-06-08	t
2024-06-09	t
2024-06-15	t
2024-06-16	t
2024-06-22	t
2024-06-23	t
2024-06-29	t
2024-06-30	t
2024-07-06	t
2024-07-07	t
2024-07-13	t
2024-07-14	t
2024-07-20	t
2024-07-21	t
2024-07-27	t
2024-07-28	t
2024-08-03	t
2024-08-04	t
2024-08-10	t
2024-08-11	t
2024-08-17	t
2024-08-18	t
2024-08-24	t
2024-08-25	t
2024-08-31	t
2024-09-01	t
2024-09-07	t
2024-09-08	t
2024-09-14	t
2024-09-15	t
2021-10-02	t
2021-10-03	t
2021-10-09	t
2024-12-22	t
2024-12-28	t
2024-12-29	t
2025-01-04	t
2021-10-10	t
2021-10-16	t
2021-10-17	t
2021-10-23	t
2021-10-24	t
2021-10-30	t
2025-09-13	t
2025-09-14	t
2027-01-03	t
2027-01-09	t
2027-01-10	t
2027-01-16	t
2027-01-17	t
2027-01-23	t
2021-10-31	t
2021-11-06	t
2021-11-07	t
2021-11-13	t
2025-09-20	t
2025-09-21	t
2025-09-27	t
2025-09-28	t
2025-10-04	t
2025-10-05	t
2025-10-11	t
2025-10-12	t
2025-10-18	t
2025-10-19	t
2025-10-25	t
2025-10-26	t
2025-11-01	t
2023-11-11	t
2027-06-26	t
2027-06-27	t
2027-07-03	t
2027-07-04	t
2027-07-10	t
2027-07-11	t
2027-07-17	t
2027-07-18	t
2027-07-24	t
2027-07-25	t
2027-07-31	t
2027-08-01	t
2027-08-07	t
2027-08-08	t
2027-08-14	t
2027-08-15	t
2027-08-21	t
2027-08-22	t
2027-08-28	t
2027-08-29	t
2027-09-04	t
2027-09-05	t
2017-11-12	t
2017-11-18	t
2017-11-19	t
2017-11-25	t
2017-11-26	t
2017-12-02	t
2017-12-03	t
2017-12-09	t
2017-12-10	t
2026-07-26	t
2026-08-01	t
2026-08-02	t
2026-08-08	t
2026-08-09	t
2026-08-15	t
2026-08-16	t
2026-08-22	t
2026-08-23	t
2026-08-29	t
2026-08-30	t
2026-09-05	t
2026-09-06	t
2026-09-12	t
2026-09-13	t
2026-09-19	t
2022-08-28	t
2022-09-03	t
2022-09-04	t
2022-09-10	t
2022-09-11	t
2022-09-17	t
2022-09-18	t
2022-09-24	t
2022-09-25	t
2022-10-01	t
2024-09-21	t
2024-09-22	t
2024-09-28	t
2024-09-29	t
2024-10-05	t
2024-10-06	t
2024-10-12	t
2024-10-13	t
2024-10-19	t
2024-10-20	t
2024-10-26	t
2024-10-27	t
2024-11-02	t
2024-11-03	t
2024-11-09	t
2024-11-10	t
2024-11-16	t
2024-11-17	t
2024-11-23	t
2024-11-24	t
2024-11-30	t
2024-12-01	t
2024-12-07	t
2024-12-08	t
2024-12-14	t
2024-12-15	t
2024-12-21	t
2020-02-09	t
2020-02-15	t
2020-02-16	t
2020-02-22	t
2020-02-23	t
2020-02-29	t
2020-03-01	t
2020-03-07	t
2021-11-20	t
2021-11-21	t
2021-03-14	t
2021-03-20	t
2021-03-21	t
2021-03-27	t
2021-03-28	t
2021-04-03	t
2021-04-04	t
2021-04-10	t
2021-04-11	t
2026-09-20	t
2026-09-26	t
2026-09-27	t
2026-10-03	t
2026-10-04	t
2026-10-10	t
2026-10-11	t
2026-10-17	t
2026-10-18	t
2026-10-24	t
2026-10-25	t
2026-10-31	t
2026-11-01	t
2026-11-07	t
2026-11-08	t
2026-11-14	t
2026-11-15	t
2026-11-21	t
2026-11-22	t
2026-11-28	t
2026-11-29	t
2026-12-05	t
2026-12-06	t
2026-12-12	t
2026-12-13	t
2026-12-19	t
2026-12-20	t
2026-12-26	t
2026-12-27	t
2027-01-02	t
2025-01-05	t
2025-01-11	t
2025-01-12	t
2025-01-18	t
2025-01-19	t
2025-01-25	t
2025-01-26	t
2025-02-01	t
2025-02-02	t
2025-02-08	t
2025-02-09	t
2025-02-15	t
2025-02-16	t
2025-02-22	t
2025-02-23	t
2025-03-01	t
2025-03-02	t
2025-03-08	t
2025-03-09	t
2025-03-15	t
2025-03-16	t
2025-03-22	t
2025-03-23	t
2025-03-29	t
2025-03-30	t
2025-04-05	t
2025-04-06	t
2025-04-12	t
2025-04-13	t
2025-04-19	t
2025-04-20	t
2025-04-26	t
2025-04-27	t
2025-05-03	t
2025-05-04	t
2025-05-10	t
2025-05-11	t
2025-05-17	t
2025-05-18	t
2025-05-24	t
2025-05-25	t
2025-05-31	t
2025-06-01	t
2025-06-07	t
2025-06-08	t
2025-06-14	t
2025-06-15	t
2025-06-21	t
2025-06-22	t
2025-06-28	t
2025-06-29	t
2025-07-05	t
2025-07-06	t
2025-07-12	t
2025-07-13	t
2025-07-19	t
2025-07-20	t
2025-07-26	t
2027-01-24	t
2027-01-30	t
2027-01-31	t
2027-02-06	t
2027-02-07	t
2027-02-13	t
2027-02-14	t
2027-02-20	t
2027-02-21	t
2027-02-27	t
2027-02-28	t
2027-03-06	t
2027-03-07	t
2027-03-13	t
2027-03-14	t
2027-03-20	t
2027-03-21	t
2027-03-27	t
2027-03-28	t
2027-04-03	t
2027-04-25	t
2027-05-01	t
2027-05-02	t
2027-05-08	t
2027-05-09	t
2027-05-15	t
2027-05-16	t
2027-05-22	t
2027-05-23	t
2027-05-29	t
2027-05-30	t
2027-06-05	t
2027-06-06	t
2027-06-12	t
2017-01-08	t
2017-01-14	t
2017-01-15	t
2017-01-21	t
2017-01-22	t
2017-01-28	t
2017-01-29	t
2017-02-04	t
2025-11-15	t
2025-11-16	t
2025-11-22	t
2025-11-23	t
2025-11-29	t
2025-11-30	t
2025-12-06	t
2025-12-07	t
2025-12-13	t
2025-12-14	t
2025-12-20	t
2025-12-21	t
2025-12-27	t
2025-12-28	t
2026-01-03	t
2026-01-04	t
2026-01-10	t
2026-01-11	t
2026-01-17	t
2026-01-18	t
2026-01-24	t
2026-01-25	t
2026-01-31	t
2026-06-28	t
2026-07-04	t
2026-07-05	t
2026-07-11	t
2026-07-12	t
2026-07-18	t
2026-07-19	t
2026-07-25	t
2028-11-11	t
2028-11-12	t
2028-11-18	t
2028-11-19	t
2028-11-25	t
2028-11-26	t
2028-12-02	t
2028-12-03	t
2028-12-09	t
2028-12-10	t
2028-12-16	t
2028-12-17	t
2028-12-23	t
2028-12-24	t
2028-12-30	t
2028-12-31	t
2029-01-06	t
2029-01-07	t
2029-01-13	t
2029-01-14	t
2029-01-20	t
2029-01-21	t
2029-01-27	t
2029-01-28	t
2029-02-03	t
2029-02-04	t
2029-02-10	t
2029-02-11	t
2029-02-17	t
2029-02-18	t
2029-02-24	t
2029-02-25	t
2029-03-03	t
2029-03-04	t
2029-03-10	t
2025-07-27	t
2025-08-02	t
2025-08-03	t
2025-08-09	t
2029-04-01	t
2029-04-07	t
2029-04-08	t
2029-04-14	t
2029-04-15	t
2017-05-27	t
2017-05-28	t
2017-06-03	t
2017-06-04	t
2017-06-10	t
2017-06-11	t
2017-06-17	t
2017-06-18	t
2017-06-24	t
2017-06-25	t
2017-07-01	t
2015-07-25	t
2015-07-26	t
2015-08-01	t
2015-08-02	t
2015-08-08	t
2015-08-09	t
2015-08-15	t
2015-08-16	t
2015-08-22	t
2015-08-23	t
2015-08-29	t
2015-08-30	t
2015-09-05	t
2015-09-06	t
2015-09-12	t
2015-09-13	t
2015-09-19	t
2015-09-20	t
2015-09-26	t
2015-09-27	t
2015-10-03	t
2015-10-04	t
2015-10-10	t
2015-10-11	t
2015-10-17	t
2015-10-18	t
2015-10-24	t
2015-10-25	t
2015-10-31	t
2015-11-01	t
2015-11-07	t
2015-11-08	t
2015-11-14	t
2015-11-15	t
2015-11-21	t
2015-11-22	t
2029-08-19	t
2029-08-25	t
2029-08-26	t
2029-09-01	t
2029-09-02	t
2029-09-08	t
2029-09-09	t
2015-11-28	t
2015-11-29	t
2015-12-05	t
2015-12-06	t
2015-12-19	t
2015-12-20	t
2015-12-26	t
2015-12-27	t
2016-01-02	t
2016-01-03	t
2016-01-09	t
2016-01-10	t
2016-01-16	t
2016-01-17	t
2016-01-23	t
2016-01-24	t
2021-03-06	t
2021-03-07	t
2016-01-30	t
2016-01-31	t
2016-02-06	t
2016-02-07	t
2016-02-13	t
2016-02-14	t
2016-02-20	t
2016-02-21	t
2016-02-27	t
2016-02-28	t
2016-03-05	t
2016-03-06	t
2016-03-12	t
2016-03-13	t
2016-03-19	t
2016-03-20	t
2016-03-26	t
2016-03-27	t
2016-04-02	t
2016-04-03	t
2016-04-09	t
2016-04-10	t
2016-04-16	t
2016-04-17	t
2016-04-23	t
2016-04-24	t
2016-04-30	t
2016-05-01	t
2016-05-07	t
2016-05-08	t
2016-05-14	t
2016-07-17	t
2016-07-23	t
2016-07-24	t
2017-02-05	t
2017-02-11	t
2017-02-12	t
2017-02-18	t
2017-02-19	t
2017-02-25	t
2017-02-26	t
2017-03-04	t
2017-03-05	t
2017-03-11	t
2017-03-12	t
2017-03-18	t
2017-03-19	t
2017-03-25	t
2017-03-26	t
2017-04-01	t
2017-04-02	t
2017-04-08	t
2017-04-09	t
2017-04-15	t
2017-04-16	t
2017-04-22	t
2017-04-23	t
2017-04-29	t
2017-04-30	t
2017-05-06	t
2017-05-07	t
2017-05-13	t
2017-05-14	t
2017-05-20	t
2017-05-21	t
2016-05-15	t
2016-05-21	t
2016-05-22	t
2016-05-28	t
2016-05-29	t
2016-06-04	t
2027-04-04	t
2027-04-10	t
2027-04-11	t
2027-04-17	t
2027-04-18	t
2015-12-12	t
2015-12-13	t
2017-08-06	t
2017-08-12	t
2017-08-13	t
2017-08-19	t
2017-08-20	t
2017-08-26	t
2017-08-27	t
2017-09-02	t
2017-09-03	t
2017-09-09	t
2017-09-10	t
2017-09-16	t
2017-09-17	t
2017-09-23	t
2017-09-24	t
2019-07-14	t
2019-07-20	t
2019-07-21	t
2019-07-27	t
2019-07-28	t
2019-08-03	t
2019-08-04	t
2019-08-10	t
2019-08-11	t
2019-08-17	t
2019-08-18	t
2019-08-24	t
2019-08-25	t
2019-08-31	t
2019-09-01	t
2019-09-07	t
2019-09-08	t
2019-09-14	t
2019-09-15	t
2019-09-21	t
2019-09-22	t
2018-01-06	t
2018-01-07	t
2018-01-13	t
2018-01-14	t
2018-01-20	t
2018-01-21	t
2018-01-27	t
2018-01-28	t
2018-02-03	t
2018-02-04	t
2018-02-10	t
2018-02-11	t
2018-02-17	t
2018-02-18	t
2018-02-24	t
2018-02-25	t
2018-03-03	t
2018-03-04	t
2018-03-10	t
2018-03-11	t
2018-03-17	t
2018-03-18	t
2018-03-24	t
2018-03-25	t
2018-03-31	t
2018-04-01	t
2018-04-07	t
2018-04-08	t
2018-04-14	t
2027-04-24	t
2028-04-15	t
2028-04-16	t
2028-04-22	t
2028-04-23	t
2028-04-29	t
2028-04-30	t
2017-07-02	t
2017-07-08	t
2017-07-09	t
2017-07-15	t
2017-07-16	t
2017-07-22	t
2017-07-23	t
2017-07-29	t
2017-07-30	t
2017-08-05	t
2027-10-30	t
2027-10-31	t
2027-11-06	t
2027-12-05	t
2027-12-11	t
2027-12-12	t
2027-12-18	t
2027-12-19	t
2027-12-25	t
2027-12-26	t
2028-01-01	t
2028-01-02	t
2028-01-08	t
2028-01-09	t
2028-01-15	t
2028-01-16	t
2028-01-22	t
2028-01-23	t
2028-01-29	t
2018-04-15	t
2018-04-21	t
2018-04-22	t
2018-04-28	t
2018-04-29	t
2018-05-05	t
2018-05-06	t
2018-05-12	t
2018-05-13	t
2018-12-29	t
2018-12-30	t
2019-01-05	t
2019-01-06	t
2019-01-12	t
2019-01-13	t
2019-01-19	t
2019-01-20	t
2019-01-26	t
2019-01-27	t
2019-02-02	t
2019-02-03	t
2019-02-09	t
2019-02-10	t
2019-02-16	t
2019-02-17	t
2019-02-23	t
2020-09-19	t
2020-09-20	t
2020-09-26	t
2020-09-27	t
2020-10-03	t
2020-10-04	t
2020-10-10	t
2020-10-11	t
2020-10-17	t
2020-10-18	t
2020-10-24	t
2020-10-25	t
2020-10-31	t
2020-11-01	t
2020-11-07	t
2020-11-08	t
2020-11-14	t
2020-11-15	t
2020-11-21	t
2020-11-22	t
2020-11-28	t
2020-11-29	t
2020-12-05	t
2020-12-06	t
2020-12-12	t
2020-12-13	t
2020-12-19	t
2029-05-05	t
2029-05-06	t
2029-05-12	t
2015-06-20	t
2015-06-21	t
2015-06-27	t
2015-06-28	t
2015-07-04	t
2015-07-05	t
2015-07-11	t
2015-07-12	t
2016-09-10	t
2016-09-11	t
2016-09-17	t
2016-09-18	t
2016-09-24	t
2016-09-25	t
2016-10-01	t
2016-10-02	t
2016-10-08	t
2016-10-09	t
2016-10-15	t
2016-10-16	t
2016-10-22	t
2016-10-23	t
2016-10-29	t
2016-10-30	t
2019-09-28	t
2019-09-29	t
2019-10-05	t
2019-10-06	t
2019-10-12	t
2019-10-13	t
2019-10-19	t
2019-10-20	t
2019-10-26	t
2019-10-27	t
2019-11-02	t
2019-11-03	t
2019-11-09	t
2019-11-10	t
2019-11-16	t
2019-11-17	t
2019-11-23	t
2019-11-24	t
2025-08-10	t
2025-08-16	t
2025-08-17	t
2025-08-23	t
2025-08-24	t
2025-08-30	t
2025-08-31	t
2025-09-06	t
2025-09-07	t
2021-02-14	t
2021-02-20	t
2021-02-21	t
2021-02-27	t
2021-02-28	t
2029-03-11	t
2029-03-17	t
2029-03-18	t
2029-03-24	t
2029-03-25	t
2029-03-31	t
2023-11-12	t
2023-11-18	t
2023-11-19	t
2023-11-25	t
2023-11-26	t
2023-12-02	t
2023-12-03	t
2023-12-09	t
2023-12-10	t
2023-12-16	t
2023-12-17	t
2023-12-23	t
2023-12-24	t
2023-12-30	t
2023-12-31	t
2024-01-06	t
2024-01-07	t
2024-01-13	t
2024-01-14	t
2024-01-20	t
2024-01-21	t
2024-01-27	t
2024-01-28	t
2024-02-03	t
2024-02-04	t
2024-02-10	t
2024-02-11	t
2024-02-17	t
2024-02-18	t
2024-02-24	t
2024-02-25	t
2024-03-02	t
2024-03-03	t
2024-03-09	t
2027-11-07	t
2027-11-13	t
2027-11-14	t
2027-11-20	t
2027-11-21	t
2027-11-27	t
2027-11-28	t
2027-12-04	t
2021-01-10	t
2021-01-16	t
2026-02-08	t
2026-02-14	t
2026-02-15	t
2026-02-21	t
2026-02-22	t
2026-02-28	t
2026-03-01	t
2026-03-07	t
2026-03-08	t
2026-03-14	t
2026-03-15	t
2026-03-21	t
2026-03-22	t
2026-03-28	t
2026-03-29	t
2026-04-04	t
2026-04-05	t
2026-04-11	t
2026-04-12	t
2026-04-18	t
2026-04-19	t
2026-04-25	t
2026-04-26	t
2026-05-02	t
2026-05-03	t
2026-05-09	t
2026-05-10	t
2026-05-16	t
2026-05-17	t
2026-05-23	t
2026-05-24	t
2026-05-30	t
2026-05-31	t
2026-06-06	t
2026-06-07	t
2026-06-13	t
2026-06-14	t
2026-06-20	t
2026-06-21	t
2026-06-27	t
2027-06-13	t
2027-06-19	t
2027-06-20	t
2028-01-30	t
2028-02-05	t
2028-02-06	t
2028-02-12	t
2028-02-13	t
2028-02-19	t
2028-02-20	t
2028-02-26	t
2028-02-27	t
2028-03-04	t
2028-03-05	t
2028-03-11	t
2028-03-12	t
2028-03-18	t
2028-03-19	t
2028-03-25	t
2028-03-26	t
2028-04-01	t
2028-04-02	t
2028-04-08	t
2028-04-09	t
2016-06-05	t
2016-06-11	t
2016-06-12	t
2016-06-18	t
2016-06-19	t
2016-06-25	t
2016-06-26	t
2016-07-02	t
2016-07-03	t
2016-07-09	t
2016-07-10	t
2016-07-16	t
2028-05-06	t
2028-05-07	t
2028-05-13	t
2028-05-14	t
2028-05-20	t
2028-05-21	t
2028-05-27	t
2028-05-28	t
2028-06-03	t
2028-06-04	t
2028-06-10	t
2028-06-11	t
2028-06-17	t
2028-06-18	t
2028-06-24	t
2028-06-25	t
2028-07-01	t
2028-07-02	t
2028-07-08	t
2028-07-09	t
2028-07-15	t
2028-07-16	t
2028-07-22	t
2028-07-23	t
2028-07-29	t
2028-07-30	t
2028-08-05	t
2028-08-06	t
2028-08-12	t
2028-08-13	t
2028-08-19	t
2028-08-20	t
2028-08-26	t
2028-08-27	t
2028-09-02	t
2028-09-03	t
2028-09-09	t
2028-09-10	t
2028-09-16	t
2028-09-17	t
2028-09-23	t
2028-09-24	t
2028-09-30	t
2028-10-01	t
2028-10-07	t
2028-10-08	t
2028-10-14	t
2017-12-16	t
2017-12-17	t
2017-12-23	t
2017-12-24	t
2019-02-24	t
2019-03-02	t
2019-03-03	t
2020-08-22	t
2020-08-23	t
2020-08-29	t
2020-08-30	t
2020-09-05	t
2020-09-06	t
2020-09-12	t
2020-09-13	t
2017-09-30	t
2017-10-01	t
2017-10-07	t
2017-10-08	t
2017-10-14	t
2017-10-15	t
2017-12-30	t
2017-12-31	t
2015-07-18	t
2015-07-19	t
2029-05-13	t
2029-05-19	t
2029-05-20	t
2029-05-26	t
2029-05-27	t
2029-06-02	t
2029-06-03	t
2029-06-09	t
2029-06-10	t
2029-06-16	t
2029-06-17	t
2029-06-23	t
2029-06-24	t
2029-06-30	t
2029-07-01	t
2029-07-07	t
2029-07-08	t
2029-07-14	t
2029-07-15	t
2029-07-21	t
2029-07-22	t
2029-07-28	t
2029-07-29	t
2029-08-04	t
2029-08-05	t
2029-08-11	t
2029-08-12	t
2029-08-18	t
2028-10-15	t
2028-10-21	t
2028-10-22	t
2028-10-28	t
2028-10-29	t
2028-11-04	t
2028-11-05	t
2016-07-30	t
2016-07-31	t
2016-08-06	t
2016-08-07	t
2016-08-13	t
2016-08-14	t
2016-08-20	t
2016-08-21	t
2016-08-27	t
2016-08-28	t
2016-09-03	t
2016-09-04	t
2018-06-23	t
2018-06-24	t
2018-06-30	t
2018-07-01	t
2018-07-07	t
2018-07-08	t
2018-07-14	t
2018-07-15	t
2018-07-21	t
2018-07-22	t
2018-07-28	t
2018-07-29	t
2018-08-04	t
2018-08-05	t
2018-08-11	t
2018-08-12	t
2018-08-18	t
2018-08-19	t
2018-08-25	t
2018-08-26	t
2018-09-01	t
2018-09-02	t
2016-11-05	t
2016-11-06	t
2016-11-12	t
2016-11-13	t
2016-11-19	t
2026-02-01	t
2026-02-07	t
2016-11-20	t
2016-11-26	t
2016-11-27	t
2016-12-03	t
2016-12-04	t
2016-12-10	t
2016-12-11	t
2016-12-17	t
2016-12-18	t
2016-12-24	t
2016-12-25	t
2016-12-31	t
2017-01-01	t
2017-01-07	t
2027-09-11	t
2027-09-12	t
2027-09-18	t
2027-09-19	t
2027-09-25	t
2027-09-26	t
2027-10-02	t
2027-10-03	t
2027-10-09	t
2027-10-10	t
2027-10-16	t
2027-10-17	t
2027-10-23	t
2027-10-24	t
2025-11-02	t
2025-11-08	t
2025-11-09	t
2021-11-14	t
2021-04-17	t
2021-04-18	t
2021-04-24	t
2021-04-25	t
2021-05-01	t
2021-05-02	t
2021-05-08	t
2021-05-09	t
2021-05-15	t
2021-05-16	t
2021-05-22	t
2021-05-23	t
2021-05-29	t
2021-05-30	t
2021-06-05	t
2021-06-06	t
2021-06-12	t
2021-06-13	t
2021-06-19	t
2021-06-20	t
2021-06-26	t
2021-06-27	t
2021-07-03	t
2021-07-04	t
2021-07-10	t
2021-07-11	t
2021-07-17	t
2021-07-18	t
2021-07-24	t
2021-07-25	t
2021-07-31	t
2021-08-01	t
2021-08-07	t
2021-08-08	t
2021-08-14	t
2021-08-15	t
2021-08-21	t
2021-08-22	t
2021-08-28	t
2021-08-29	t
2021-09-04	t
2021-09-05	t
2021-09-11	t
2021-09-12	t
2021-09-18	t
2021-09-19	t
2021-09-25	t
2021-09-26	t
2019-05-05	t
2019-05-11	t
2019-05-12	t
2019-05-18	t
2019-05-19	t
2019-05-25	t
2019-05-26	t
2019-06-01	t
2015-01-03	t
2015-01-04	t
2015-01-10	t
2015-01-11	t
2015-01-17	t
2015-01-18	t
2015-01-24	t
2015-01-25	t
2015-01-31	t
2015-02-01	t
2015-02-07	t
2015-02-08	t
2015-02-14	t
2015-02-15	t
2015-02-21	t
2015-02-22	t
2015-02-28	t
2015-03-01	t
2015-03-07	t
2015-03-08	t
2015-03-14	t
2015-03-15	t
2015-03-21	t
2015-03-22	t
2015-03-28	t
2015-03-29	t
2015-04-04	t
2015-04-05	t
2015-04-11	t
2015-04-12	t
2015-04-18	t
2015-04-19	t
2015-04-25	t
2015-04-26	t
2015-05-02	t
2015-05-03	t
2015-05-09	t
2015-05-10	t
2015-05-16	t
2015-05-17	t
2015-05-23	t
2015-05-24	t
2015-05-30	t
2015-05-31	t
2015-06-06	t
2015-06-07	t
2015-06-13	t
2015-06-14	t
2015-01-01	f
2015-01-02	f
2015-01-05	f
2015-01-06	f
2015-01-07	f
2015-01-08	f
2015-01-09	f
2015-01-12	f
2015-01-13	f
2015-01-14	f
2015-01-15	f
2015-01-16	f
2015-01-19	f
2015-01-20	f
2015-01-21	f
2015-01-22	f
2015-01-23	f
2015-01-26	f
2015-01-27	f
2015-01-28	f
2015-01-29	f
2015-01-30	f
2015-02-02	f
2015-02-03	f
2015-02-04	f
2015-02-05	f
2015-02-06	f
2015-02-09	f
2015-02-10	f
2015-02-11	f
2015-02-12	f
2015-02-13	f
2015-02-16	f
2015-02-17	f
2015-02-18	f
2015-02-19	f
2015-02-20	f
2015-02-23	f
2015-02-24	f
2015-02-25	f
2015-02-26	f
2015-02-27	f
2015-03-02	f
2015-03-03	f
2015-03-04	f
2015-03-05	f
2015-03-06	f
2015-03-09	f
2015-03-10	f
2015-03-11	f
2015-03-12	f
2015-03-13	f
2015-03-16	f
2015-03-17	f
2015-03-18	f
2015-03-19	f
2015-03-20	f
2015-03-23	f
2015-03-24	f
2015-03-25	f
2015-03-26	f
2015-03-27	f
2015-03-30	f
2015-03-31	f
2015-04-01	f
2015-04-02	f
2015-04-03	f
2015-04-06	f
2015-04-07	f
2015-04-08	f
2015-04-09	f
2015-04-10	f
2015-04-13	f
2015-04-14	f
2015-04-15	f
2015-04-16	f
2015-04-17	f
2015-04-20	f
2015-04-21	f
2015-04-22	f
2015-04-23	f
2015-04-24	f
2015-04-27	f
2015-04-28	f
2015-04-29	f
2015-04-30	f
2015-05-01	f
2015-05-04	f
2015-05-05	f
2015-05-06	f
2015-05-07	f
2015-05-08	f
2015-05-11	f
2015-05-12	f
2015-05-13	f
2015-05-14	f
2015-05-15	f
2015-05-18	f
2015-05-19	f
2015-05-20	f
2015-05-21	f
2015-05-22	f
2015-05-25	f
2015-05-26	f
2015-05-27	f
2015-05-28	f
2015-05-29	f
2015-06-01	f
2015-06-02	f
2015-06-03	f
2015-06-04	f
2015-06-05	f
2015-06-08	f
2015-06-09	f
2015-06-10	f
2015-06-11	f
2015-06-12	f
2015-06-15	f
2015-06-16	f
2015-06-17	f
2015-06-18	f
2015-06-19	f
2015-06-22	f
2015-06-23	f
2015-06-24	f
2015-06-25	f
2015-06-26	f
2015-06-29	f
2015-06-30	f
2015-07-01	f
2015-07-02	f
2015-07-03	f
2015-07-06	f
2015-07-07	f
2015-07-08	f
2015-07-09	f
2015-07-10	f
2015-07-13	f
2015-07-14	f
2015-07-15	f
2015-07-16	f
2015-07-17	f
2015-07-20	f
2015-07-21	f
2015-07-22	f
2015-07-23	f
2015-07-24	f
2015-07-27	f
2015-07-28	f
2015-07-29	f
2015-07-30	f
2015-07-31	f
2015-08-03	f
2015-08-04	f
2015-08-05	f
2015-08-06	f
2015-08-07	f
2015-08-10	f
2015-08-11	f
2015-08-12	f
2015-08-13	f
2015-08-14	f
2015-08-17	f
2015-08-18	f
2015-08-19	f
2015-08-20	f
2015-08-21	f
2015-08-24	f
2015-08-25	f
2015-08-26	f
2015-08-27	f
2015-08-28	f
2015-08-31	f
2015-09-01	f
2015-09-02	f
2015-09-03	f
2015-09-04	f
2015-09-07	f
2015-09-08	f
2015-09-09	f
2015-09-10	f
2015-09-11	f
2015-09-14	f
2015-09-15	f
2015-09-16	f
2015-09-17	f
2015-09-18	f
2015-09-21	f
2015-09-22	f
2015-09-23	f
2015-09-24	f
2015-09-25	f
2015-09-28	f
2015-09-29	f
2015-09-30	f
2015-10-01	f
2015-10-02	f
2015-10-05	f
2015-10-06	f
2015-10-07	f
2015-10-08	f
2015-10-09	f
2015-10-12	f
2015-10-13	f
2015-10-14	f
2015-10-15	f
2015-10-16	f
2015-10-19	f
2015-10-20	f
2015-10-21	f
2015-10-22	f
2015-10-23	f
2015-10-26	f
2015-10-27	f
2015-10-28	f
2015-10-29	f
2015-10-30	f
2015-11-02	f
2015-11-03	f
2015-11-04	f
2015-11-05	f
2015-11-06	f
2015-11-09	f
2015-11-10	f
2015-11-11	f
2015-11-12	f
2015-11-13	f
2015-11-16	f
2015-11-17	f
2015-11-18	f
2015-11-19	f
2015-11-20	f
2015-11-23	f
2015-11-24	f
2015-11-25	f
2015-11-26	f
2015-11-27	f
2015-11-30	f
2015-12-01	f
2015-12-02	f
2015-12-03	f
2015-12-04	f
2015-12-07	f
2015-12-08	f
2015-12-09	f
2015-12-10	f
2015-12-11	f
2015-12-14	f
2015-12-15	f
2015-12-16	f
2015-12-17	f
2015-12-18	f
2015-12-21	f
2015-12-22	f
2015-12-23	f
2015-12-24	f
2015-12-25	f
2015-12-28	f
2015-12-29	f
2015-12-30	f
2015-12-31	f
2016-01-01	f
2016-01-04	f
2016-01-05	f
2016-01-06	f
2016-01-07	f
2016-01-08	f
2016-01-11	f
2016-01-12	f
2016-01-13	f
2016-01-14	f
2016-01-15	f
2016-01-18	f
2016-01-19	f
2016-01-20	f
2016-01-21	f
2016-01-22	f
2016-01-25	f
2016-01-26	f
2016-01-27	f
2016-01-28	f
2016-01-29	f
2016-02-01	f
2016-02-02	f
2016-02-03	f
2016-02-04	f
2016-02-05	f
2016-02-08	f
2016-02-09	f
2016-02-10	f
2016-02-11	f
2016-02-12	f
2016-02-15	f
2016-02-16	f
2016-02-17	f
2016-02-18	f
2016-02-19	f
2016-02-22	f
2016-02-23	f
2016-02-24	f
2016-02-25	f
2016-02-26	f
2016-02-29	f
2016-03-01	f
2016-03-02	f
2016-03-03	f
2016-03-04	f
2016-03-07	f
2016-03-08	f
2016-03-09	f
2016-03-10	f
2016-03-11	f
2016-03-14	f
2016-03-15	f
2016-03-16	f
2016-03-17	f
2016-03-18	f
2016-03-21	f
2016-03-22	f
2016-03-23	f
2016-03-24	f
2016-03-25	f
2016-03-28	f
2016-03-29	f
2016-03-30	f
2016-03-31	f
2016-04-01	f
2016-04-04	f
2016-04-05	f
2016-04-06	f
2016-04-07	f
2016-04-08	f
2016-04-11	f
2016-04-12	f
2016-04-13	f
2016-04-14	f
2016-04-15	f
2016-04-18	f
2016-04-19	f
2016-04-20	f
2016-04-21	f
2016-04-22	f
2016-04-25	f
2016-04-26	f
2016-04-27	f
2016-04-28	f
2016-04-29	f
2016-05-02	f
2016-05-03	f
2016-05-04	f
2016-05-05	f
2016-05-06	f
2016-05-09	f
2016-05-10	f
2016-05-11	f
2016-05-12	f
2016-05-13	f
2016-05-16	f
2016-05-17	f
2016-05-18	f
2016-05-19	f
2016-05-20	f
2016-05-23	f
2016-05-24	f
2016-05-25	f
2016-05-26	f
2016-05-27	f
2016-05-30	f
2016-05-31	f
2016-06-01	f
2016-06-02	f
2016-06-03	f
2016-06-06	f
2016-06-07	f
2016-06-08	f
2016-06-09	f
2016-06-10	f
2016-06-13	f
2016-06-14	f
2016-06-15	f
2016-06-16	f
2016-06-17	f
2016-06-20	f
2016-06-21	f
2016-06-22	f
2016-06-23	f
2016-06-24	f
2016-06-27	f
2016-06-28	f
2016-06-29	f
2016-06-30	f
2016-07-01	f
2016-07-04	f
2016-07-05	f
2016-07-06	f
2016-07-07	f
2016-07-08	f
2016-07-11	f
2016-07-12	f
2016-07-13	f
2016-07-14	f
2016-07-15	f
2016-07-18	f
2016-07-19	f
2016-07-20	f
2016-07-21	f
2016-07-22	f
2016-07-25	f
2016-07-26	f
2016-07-27	f
2016-07-28	f
2016-07-29	f
2016-08-01	f
2016-08-02	f
2016-08-03	f
2016-08-04	f
2016-08-05	f
2016-08-08	f
2016-08-09	f
2016-08-10	f
2016-08-11	f
2016-08-12	f
2016-08-15	f
2016-08-16	f
2016-08-17	f
2016-08-18	f
2016-08-19	f
2016-08-22	f
2016-08-23	f
2016-08-24	f
2016-08-25	f
2016-08-26	f
2016-08-29	f
2016-08-30	f
2016-08-31	f
2016-09-01	f
2016-09-02	f
2016-09-05	f
2016-09-06	f
2016-09-07	f
2016-09-08	f
2016-09-09	f
2016-09-12	f
2016-09-13	f
2016-09-14	f
2016-09-15	f
2016-09-16	f
2016-09-19	f
2016-09-20	f
2016-09-21	f
2016-09-22	f
2016-09-23	f
2016-09-26	f
2016-09-27	f
2016-09-28	f
2016-09-29	f
2016-09-30	f
2016-10-03	f
2016-10-04	f
2016-10-05	f
2016-10-06	f
2016-10-07	f
2016-10-10	f
2016-10-11	f
2016-10-12	f
2016-10-13	f
2016-10-14	f
2016-10-17	f
2016-10-18	f
2016-10-19	f
2016-10-20	f
2016-10-21	f
2016-10-24	f
2016-10-25	f
2016-10-26	f
2016-10-27	f
2016-10-28	f
2016-10-31	f
2016-11-01	f
2016-11-02	f
2016-11-03	f
2016-11-04	f
2016-11-07	f
2016-11-08	f
2016-11-09	f
2016-11-10	f
2016-11-11	f
2016-11-14	f
2016-11-15	f
2016-11-16	f
2016-11-17	f
2016-11-18	f
2016-11-21	f
2016-11-22	f
2016-11-23	f
2016-11-24	f
2016-11-25	f
2016-11-28	f
2016-11-29	f
2016-11-30	f
2016-12-01	f
2016-12-02	f
2016-12-05	f
2016-12-06	f
2016-12-07	f
2016-12-08	f
2016-12-09	f
2016-12-12	f
2016-12-13	f
2016-12-14	f
2016-12-15	f
2016-12-16	f
2016-12-19	f
2016-12-20	f
2016-12-21	f
2016-12-22	f
2016-12-23	f
2016-12-26	f
2016-12-27	f
2016-12-28	f
2016-12-29	f
2016-12-30	f
2017-01-02	f
2017-01-03	f
2017-01-04	f
2017-01-05	f
2017-01-06	f
2017-01-09	f
2017-01-10	f
2017-01-11	f
2017-01-12	f
2017-01-13	f
2017-01-16	f
2017-01-17	f
2017-01-18	f
2017-01-19	f
2017-01-20	f
2017-01-23	f
2017-01-24	f
2017-01-25	f
2017-01-26	f
2017-01-27	f
2017-01-30	f
2017-01-31	f
2017-02-01	f
2017-02-02	f
2017-02-03	f
2017-02-06	f
2017-02-07	f
2017-02-08	f
2017-02-09	f
2017-02-10	f
2017-02-13	f
2017-02-14	f
2017-02-15	f
2017-02-16	f
2017-02-17	f
2017-02-20	f
2017-02-21	f
2017-02-22	f
2017-02-23	f
2017-02-24	f
2017-02-27	f
2017-02-28	f
2017-03-01	f
2017-03-02	f
2017-03-03	f
2017-03-06	f
2017-03-07	f
2017-03-08	f
2017-03-09	f
2017-03-10	f
2017-03-13	f
2017-03-14	f
2017-03-15	f
2017-03-16	f
2017-03-17	f
2017-03-20	f
2017-03-21	f
2017-03-22	f
2017-03-23	f
2017-03-24	f
2017-03-27	f
2017-03-28	f
2017-03-29	f
2017-03-30	f
2017-03-31	f
2017-04-03	f
2017-04-04	f
2017-04-05	f
2017-04-06	f
2017-04-07	f
2017-04-10	f
2017-04-11	f
2017-04-12	f
2017-04-13	f
2017-04-14	f
2017-04-17	f
2017-04-18	f
2017-04-19	f
2017-04-20	f
2017-04-21	f
2017-04-24	f
2017-04-25	f
2017-04-26	f
2017-04-27	f
2017-04-28	f
2017-05-01	f
2017-05-02	f
2017-05-03	f
2017-05-04	f
2017-05-05	f
2017-05-08	f
2017-05-09	f
2017-05-10	f
2017-05-11	f
2017-05-12	f
2017-05-15	f
2017-05-16	f
2017-05-17	f
2017-05-18	f
2017-05-19	f
2017-05-22	f
2017-05-23	f
2017-05-24	f
2017-05-25	f
2017-05-26	f
2017-05-29	f
2017-05-30	f
2017-05-31	f
2017-06-01	f
2017-06-02	f
2017-06-05	f
2017-06-06	f
2017-06-07	f
2017-06-08	f
2017-06-09	f
2017-06-12	f
2017-06-13	f
2017-06-14	f
2017-06-15	f
2017-06-16	f
2017-06-19	f
2017-06-20	f
2017-06-21	f
2017-06-22	f
2017-06-23	f
2017-06-26	f
2017-06-27	f
2017-06-28	f
2017-06-29	f
2017-06-30	f
2017-07-03	f
2017-07-04	f
2017-07-05	f
2017-07-06	f
2017-07-07	f
2017-07-10	f
2017-07-11	f
2017-07-12	f
2017-07-13	f
2017-07-14	f
2017-07-17	f
2017-07-18	f
2017-07-19	f
2017-07-20	f
2017-07-21	f
2017-07-24	f
2017-07-25	f
2017-07-26	f
2017-07-27	f
2017-07-28	f
2017-07-31	f
2017-08-01	f
2017-08-02	f
2017-08-03	f
2017-08-04	f
2017-08-07	f
2017-08-08	f
2017-08-09	f
2017-08-10	f
2017-08-11	f
2017-08-14	f
2017-08-15	f
2017-08-16	f
2017-08-17	f
2017-08-18	f
2017-08-21	f
2017-08-22	f
2017-08-23	f
2017-08-24	f
2017-08-25	f
2017-08-28	f
2017-08-29	f
2017-08-30	f
2017-08-31	f
2017-09-01	f
2017-09-04	f
2017-09-05	f
2017-09-06	f
2017-09-07	f
2017-09-08	f
2017-09-11	f
2017-09-12	f
2017-09-13	f
2017-09-14	f
2017-09-15	f
2017-09-18	f
2017-09-19	f
2017-09-20	f
2017-09-21	f
2017-09-22	f
2017-09-25	f
2017-09-26	f
2017-09-27	f
2017-09-28	f
2017-09-29	f
2017-10-02	f
2017-10-03	f
2017-10-04	f
2017-10-05	f
2017-10-06	f
2017-10-09	f
2017-10-10	f
2017-10-11	f
2017-10-12	f
2017-10-13	f
2017-10-16	f
2017-10-17	f
2017-10-18	f
2017-10-19	f
2017-10-20	f
2017-10-23	f
2017-10-24	f
2017-10-25	f
2017-10-26	f
2017-10-27	f
2017-10-30	f
2017-10-31	f
2017-11-01	f
2017-11-02	f
2017-11-03	f
2017-11-06	f
2017-11-07	f
2017-11-08	f
2017-11-09	f
2017-11-10	f
2017-11-13	f
2017-11-14	f
2017-11-15	f
2017-11-16	f
2017-11-17	f
2017-11-20	f
2017-11-21	f
2017-11-22	f
2017-11-23	f
2017-11-24	f
2017-11-27	f
2017-11-28	f
2017-11-29	f
2017-11-30	f
2017-12-01	f
2017-12-04	f
2017-12-05	f
2017-12-06	f
2017-12-07	f
2017-12-08	f
2017-12-11	f
2017-12-12	f
2017-12-13	f
2017-12-14	f
2017-12-15	f
2017-12-18	f
2017-12-19	f
2017-12-20	f
2017-12-21	f
2017-12-22	f
2017-12-25	f
2017-12-26	f
2017-12-27	f
2017-12-28	f
2017-12-29	f
2018-01-01	f
2018-01-02	f
2018-01-03	f
2018-01-04	f
2018-01-05	f
2018-01-08	f
2018-01-09	f
2018-01-10	f
2018-01-11	f
2018-01-12	f
2018-01-15	f
2018-01-16	f
2018-01-17	f
2018-01-18	f
2018-01-19	f
2018-01-22	f
2018-01-23	f
2018-01-24	f
2018-01-25	f
2018-01-26	f
2018-01-29	f
2018-01-30	f
2018-01-31	f
2018-02-01	f
2018-02-02	f
2018-02-05	f
2018-02-06	f
2018-02-07	f
2018-02-08	f
2018-02-09	f
2018-02-12	f
2018-02-13	f
2018-02-14	f
2018-02-15	f
2018-02-16	f
2018-02-19	f
2018-02-20	f
2018-02-21	f
2018-02-22	f
2018-02-23	f
2018-02-26	f
2018-02-27	f
2018-02-28	f
2018-03-01	f
2018-03-02	f
2018-03-05	f
2018-03-06	f
2018-03-07	f
2018-03-08	f
2018-03-09	f
2018-03-12	f
2018-03-13	f
2018-03-14	f
2018-03-15	f
2018-03-16	f
2018-03-19	f
2018-03-20	f
2018-03-21	f
2018-03-22	f
2018-03-23	f
2018-03-26	f
2018-03-27	f
2018-03-28	f
2018-03-29	f
2018-03-30	f
2018-04-02	f
2018-04-03	f
2018-04-04	f
2018-04-05	f
2018-04-06	f
2018-04-09	f
2018-04-10	f
2018-04-11	f
2018-04-12	f
2018-04-13	f
2018-04-16	f
2018-04-17	f
2018-04-18	f
2018-04-19	f
2018-04-20	f
2018-04-23	f
2018-04-24	f
2018-04-25	f
2018-04-26	f
2018-04-27	f
2018-04-30	f
2018-05-01	f
2018-05-02	f
2018-05-03	f
2018-05-04	f
2018-05-07	f
2018-05-08	f
2018-05-09	f
2018-05-10	f
2018-05-11	f
2018-05-14	f
2018-05-15	f
2018-05-16	f
2018-05-17	f
2018-05-18	f
2018-05-21	f
2018-05-22	f
2018-05-23	f
2018-05-24	f
2018-05-25	f
2018-05-28	f
2018-05-29	f
2018-05-30	f
2018-05-31	f
2018-06-01	f
2018-06-04	f
2018-06-05	f
2018-06-06	f
2018-06-07	f
2018-06-08	f
2018-06-11	f
2018-06-12	f
2018-06-13	f
2018-06-14	f
2018-06-15	f
2018-06-18	f
2018-06-19	f
2018-06-20	f
2018-06-21	f
2018-06-22	f
2018-06-25	f
2018-06-26	f
2018-06-27	f
2018-06-28	f
2018-06-29	f
2018-07-02	f
2018-07-03	f
2018-07-04	f
2018-07-05	f
2018-07-06	f
2018-07-09	f
2018-07-10	f
2018-07-11	f
2018-07-12	f
2018-07-13	f
2018-07-16	f
2018-07-17	f
2018-07-18	f
2018-07-19	f
2018-07-20	f
2018-07-23	f
2018-07-24	f
2018-07-25	f
2018-07-26	f
2018-07-27	f
2018-07-30	f
2018-07-31	f
2018-08-01	f
2018-08-02	f
2018-08-03	f
2018-08-06	f
2018-08-07	f
2018-08-08	f
2018-08-09	f
2018-08-10	f
2018-08-13	f
2018-08-14	f
2018-08-15	f
2018-08-16	f
2018-08-17	f
2018-08-20	f
2018-08-21	f
2018-08-22	f
2018-08-23	f
2018-08-24	f
2018-08-27	f
2018-08-28	f
2018-08-29	f
2018-08-30	f
2018-08-31	f
2018-09-03	f
2018-09-04	f
2018-09-05	f
2018-09-06	f
2018-09-07	f
2018-09-10	f
2018-09-11	f
2018-09-12	f
2018-09-13	f
2018-09-14	f
2018-09-17	f
2018-09-18	f
2018-09-19	f
2018-09-20	f
2018-09-21	f
2018-09-24	f
2018-09-25	f
2018-09-26	f
2018-09-27	f
2018-09-28	f
2018-10-01	f
2018-10-02	f
2018-10-03	f
2018-10-04	f
2018-10-05	f
2018-10-08	f
2018-10-09	f
2018-10-10	f
2018-10-11	f
2018-10-12	f
2018-10-15	f
2018-10-16	f
2018-10-17	f
2018-10-18	f
2018-10-19	f
2018-10-22	f
2018-10-23	f
2018-10-24	f
2018-10-25	f
2018-10-26	f
2018-10-29	f
2018-10-30	f
2018-10-31	f
2018-11-01	f
2018-11-02	f
2018-11-05	f
2018-11-06	f
2018-11-07	f
2018-11-08	f
2018-11-09	f
2018-11-12	f
2018-11-13	f
2018-11-14	f
2018-11-15	f
2018-11-16	f
2018-11-19	f
2018-11-20	f
2018-11-21	f
2018-11-22	f
2018-11-23	f
2018-11-26	f
2018-11-27	f
2018-11-28	f
2018-11-29	f
2018-11-30	f
2018-12-03	f
2018-12-04	f
2018-12-05	f
2018-12-06	f
2018-12-07	f
2018-12-10	f
2018-12-11	f
2018-12-12	f
2018-12-13	f
2018-12-14	f
2018-12-17	f
2018-12-18	f
2018-12-19	f
2018-12-20	f
2018-12-21	f
2018-12-24	f
2018-12-25	f
2018-12-26	f
2018-12-27	f
2018-12-28	f
2018-12-31	f
2019-01-01	f
2019-01-02	f
2019-01-03	f
2019-01-04	f
2019-01-07	f
2019-01-08	f
2019-01-09	f
2019-01-10	f
2019-01-11	f
2019-01-14	f
2019-01-15	f
2019-01-16	f
2019-01-17	f
2019-01-18	f
2019-01-21	f
2019-01-22	f
2019-01-23	f
2019-01-24	f
2019-01-25	f
2019-01-28	f
2019-01-29	f
2019-01-30	f
2019-01-31	f
2019-02-01	f
2019-02-04	f
2019-02-05	f
2019-02-06	f
2019-02-07	f
2019-02-08	f
2019-02-11	f
2019-02-12	f
2019-02-13	f
2019-02-14	f
2019-02-15	f
2019-02-18	f
2019-02-19	f
2019-02-20	f
2019-02-21	f
2019-02-22	f
2019-02-25	f
2019-02-26	f
2019-02-27	f
2019-02-28	f
2019-03-01	f
2019-03-04	f
2019-03-05	f
2019-03-06	f
2019-03-07	f
2019-03-08	f
2019-03-11	f
2019-03-12	f
2019-03-13	f
2019-03-14	f
2019-03-15	f
2019-03-18	f
2019-03-19	f
2019-03-20	f
2019-03-21	f
2019-03-22	f
2019-03-25	f
2019-03-26	f
2019-03-27	f
2019-03-28	f
2019-03-29	f
2019-04-01	f
2019-04-02	f
2019-04-03	f
2019-04-04	f
2019-04-05	f
2019-04-08	f
2019-04-09	f
2019-04-10	f
2019-04-11	f
2019-04-12	f
2019-04-15	f
2019-04-16	f
2019-04-17	f
2019-04-18	f
2019-04-19	f
2019-04-22	f
2019-04-23	f
2019-04-24	f
2019-04-25	f
2019-04-26	f
2019-04-29	f
2019-04-30	f
2019-05-01	f
2019-05-02	f
2019-05-03	f
2019-05-06	f
2019-05-07	f
2019-05-08	f
2019-05-09	f
2019-05-10	f
2019-05-13	f
2019-05-14	f
2019-05-15	f
2019-05-16	f
2019-05-17	f
2019-05-20	f
2019-05-21	f
2019-05-22	f
2019-05-23	f
2019-05-24	f
2019-05-27	f
2019-05-28	f
2019-05-29	f
2019-05-30	f
2019-05-31	f
2019-06-03	f
2019-06-04	f
2019-06-05	f
2019-06-06	f
2019-06-07	f
2019-06-10	f
2019-06-11	f
2019-06-12	f
2019-06-13	f
2019-06-14	f
2019-06-17	f
2019-06-18	f
2019-06-19	f
2019-06-20	f
2019-06-21	f
2019-06-24	f
2019-06-25	f
2019-06-26	f
2019-06-27	f
2019-06-28	f
2019-07-01	f
2019-07-02	f
2019-07-03	f
2019-07-04	f
2019-07-05	f
2019-07-08	f
2019-07-09	f
2019-07-10	f
2019-07-11	f
2019-07-12	f
2019-07-15	f
2019-07-16	f
2019-07-17	f
2019-07-18	f
2019-07-19	f
2019-07-22	f
2019-07-23	f
2019-07-24	f
2019-07-25	f
2019-07-26	f
2019-07-29	f
2019-07-30	f
2019-07-31	f
2019-08-01	f
2019-08-02	f
2019-08-05	f
2019-08-06	f
2019-08-07	f
2019-08-08	f
2019-08-09	f
2019-08-12	f
2019-08-13	f
2019-08-14	f
2019-08-15	f
2019-08-16	f
2019-08-19	f
2019-08-20	f
2019-08-21	f
2019-08-22	f
2019-08-23	f
2019-08-26	f
2019-08-27	f
2019-08-28	f
2019-08-29	f
2019-08-30	f
2019-09-02	f
2019-09-03	f
2019-09-04	f
2019-09-05	f
2019-09-06	f
2019-09-09	f
2019-09-10	f
2019-09-11	f
2019-09-12	f
2019-09-13	f
2019-09-16	f
2019-09-17	f
2019-09-18	f
2019-09-19	f
2019-09-20	f
2019-09-23	f
2019-09-24	f
2019-09-25	f
2019-09-26	f
2019-09-27	f
2019-09-30	f
2019-10-01	f
2019-10-02	f
2019-10-03	f
2019-10-04	f
2019-10-07	f
2019-10-08	f
2019-10-09	f
2019-10-10	f
2019-10-11	f
2019-10-14	f
2019-10-15	f
2019-10-16	f
2019-10-17	f
2019-10-18	f
2019-10-21	f
2019-10-22	f
2019-10-23	f
2019-10-24	f
2019-10-25	f
2019-10-28	f
2019-10-29	f
2019-10-30	f
2019-10-31	f
2019-11-01	f
2019-11-04	f
2019-11-05	f
2019-11-06	f
2019-11-07	f
2019-11-08	f
2019-11-11	f
2019-11-12	f
2019-11-13	f
2019-11-14	f
2019-11-15	f
2019-11-18	f
2019-11-19	f
2019-11-20	f
2019-11-21	f
2019-11-22	f
2019-11-25	f
2019-11-26	f
2019-11-27	f
2019-11-28	f
2019-11-29	f
2019-12-02	f
2019-12-03	f
2019-12-04	f
2019-12-05	f
2019-12-06	f
2019-12-09	f
2019-12-10	f
2019-12-11	f
2019-12-12	f
2019-12-13	f
2019-12-16	f
2019-12-17	f
2019-12-18	f
2019-12-19	f
2019-12-20	f
2019-12-23	f
2019-12-24	f
2019-12-25	f
2019-12-26	f
2019-12-27	f
2019-12-30	f
2019-12-31	f
2020-01-01	f
2020-01-02	f
2020-01-03	f
2020-01-06	f
2020-01-07	f
2020-01-08	f
2020-01-09	f
2020-01-10	f
2020-01-13	f
2020-01-14	f
2020-01-15	f
2020-01-16	f
2020-01-17	f
2020-01-20	f
2020-01-21	f
2020-01-22	f
2020-01-23	f
2020-01-24	f
2020-01-27	f
2020-01-28	f
2020-01-29	f
2020-01-30	f
2020-01-31	f
2020-02-03	f
2020-02-04	f
2020-02-05	f
2020-02-06	f
2020-02-07	f
2020-02-10	f
2020-02-11	f
2020-02-12	f
2020-02-13	f
2020-02-14	f
2020-02-17	f
2020-02-18	f
2020-02-19	f
2020-02-20	f
2020-02-21	f
2020-02-24	f
2020-02-25	f
2020-02-26	f
2020-02-27	f
2020-02-28	f
2020-03-02	f
2020-03-03	f
2020-03-04	f
2020-03-05	f
2020-03-06	f
2020-03-09	f
2020-03-10	f
2020-03-11	f
2020-03-12	f
2020-03-13	f
2020-03-16	f
2020-03-17	f
2020-03-18	f
2020-03-19	f
2020-03-20	f
2020-03-23	f
2020-03-24	f
2020-03-25	f
2020-03-26	f
2020-03-27	f
2020-03-30	f
2020-03-31	f
2020-04-01	f
2020-04-02	f
2020-04-03	f
2020-04-06	f
2020-04-07	f
2020-04-08	f
2020-04-09	f
2020-04-10	f
2020-04-13	f
2020-04-14	f
2020-04-15	f
2020-04-16	f
2020-04-17	f
2020-04-20	f
2020-04-21	f
2020-04-22	f
2020-04-23	f
2020-04-24	f
2020-04-27	f
2020-04-28	f
2020-04-29	f
2020-04-30	f
2020-05-01	f
2020-05-04	f
2020-05-05	f
2020-05-06	f
2020-05-07	f
2020-05-08	f
2020-05-11	f
2020-05-12	f
2020-05-13	f
2020-05-14	f
2020-05-15	f
2020-05-18	f
2020-05-19	f
2020-05-20	f
2020-05-21	f
2020-05-22	f
2020-05-25	f
2020-05-26	f
2020-05-27	f
2020-05-28	f
2020-05-29	f
2020-06-01	f
2020-06-02	f
2020-06-03	f
2020-06-04	f
2020-06-05	f
2020-06-08	f
2020-06-09	f
2020-06-10	f
2020-06-11	f
2020-06-12	f
2020-06-15	f
2020-06-16	f
2020-06-17	f
2020-06-18	f
2020-06-19	f
2020-06-22	f
2020-06-23	f
2020-06-24	f
2020-06-25	f
2020-06-26	f
2020-06-29	f
2020-06-30	f
2020-07-01	f
2020-07-02	f
2020-07-03	f
2020-07-06	f
2020-07-07	f
2020-07-08	f
2020-07-09	f
2020-07-10	f
2020-07-13	f
2020-07-14	f
2020-07-15	f
2020-07-16	f
2020-07-17	f
2020-07-20	f
2020-07-21	f
2020-07-22	f
2020-07-23	f
2020-07-24	f
2020-07-27	f
2020-07-28	f
2020-07-29	f
2020-07-30	f
2020-07-31	f
2020-08-03	f
2020-08-04	f
2020-08-05	f
2020-08-06	f
2020-08-07	f
2020-08-10	f
2020-08-11	f
2020-08-12	f
2020-08-13	f
2020-08-14	f
2020-08-17	f
2020-08-18	f
2020-08-19	f
2020-08-20	f
2020-08-21	f
2020-08-24	f
2020-08-25	f
2020-08-26	f
2020-08-27	f
2020-08-28	f
2020-08-31	f
2020-09-01	f
2020-09-02	f
2020-09-03	f
2020-09-04	f
2020-09-07	f
2020-09-08	f
2020-09-09	f
2020-09-10	f
2020-09-11	f
2020-09-14	f
2020-09-15	f
2020-09-16	f
2020-09-17	f
2020-09-18	f
2020-09-21	f
2020-09-22	f
2020-09-23	f
2020-09-24	f
2020-09-25	f
2020-09-28	f
2020-09-29	f
2020-09-30	f
2020-10-01	f
2020-10-02	f
2020-10-05	f
2020-10-06	f
2020-10-07	f
2020-10-08	f
2020-10-09	f
2020-10-12	f
2020-10-13	f
2020-10-14	f
2020-10-15	f
2020-10-16	f
2020-10-19	f
2020-10-20	f
2020-10-21	f
2020-10-22	f
2020-10-23	f
2020-10-26	f
2020-10-27	f
2020-10-28	f
2020-10-29	f
2020-10-30	f
2020-11-02	f
2020-11-03	f
2020-11-04	f
2020-11-05	f
2020-11-06	f
2020-11-09	f
2020-11-10	f
2020-11-11	f
2020-11-12	f
2020-11-13	f
2020-11-16	f
2020-11-17	f
2020-11-18	f
2020-11-19	f
2020-11-20	f
2020-11-23	f
2020-11-24	f
2020-11-25	f
2020-11-26	f
2020-11-27	f
2020-11-30	f
2020-12-01	f
2020-12-02	f
2020-12-03	f
2020-12-04	f
2020-12-07	f
2020-12-08	f
2020-12-09	f
2020-12-10	f
2020-12-11	f
2020-12-14	f
2020-12-15	f
2020-12-16	f
2020-12-17	f
2020-12-18	f
2020-12-21	f
2020-12-22	f
2020-12-23	f
2020-12-24	f
2020-12-25	f
2020-12-28	f
2020-12-29	f
2020-12-30	f
2020-12-31	f
2021-01-01	f
2021-01-04	f
2021-01-05	f
2021-01-06	f
2021-01-07	f
2021-01-08	f
2021-01-11	f
2021-01-12	f
2021-01-13	f
2021-01-14	f
2021-01-15	f
2021-01-18	f
2021-01-19	f
2021-01-20	f
2021-01-21	f
2021-01-22	f
2021-01-25	f
2021-01-26	f
2021-01-27	f
2021-01-28	f
2021-01-29	f
2021-02-01	f
2021-02-02	f
2021-02-03	f
2021-02-04	f
2021-02-05	f
2021-02-08	f
2021-02-09	f
2021-02-10	f
2021-02-11	f
2021-02-12	f
2021-02-15	f
2021-02-16	f
2021-02-17	f
2021-02-18	f
2021-02-19	f
2021-02-22	f
2021-02-23	f
2021-02-24	f
2021-02-25	f
2021-02-26	f
2021-03-01	f
2021-03-02	f
2021-03-03	f
2021-03-04	f
2021-03-05	f
2021-03-08	f
2021-03-09	f
2021-03-10	f
2021-03-11	f
2021-03-12	f
2021-03-15	f
2021-03-16	f
2021-03-17	f
2021-03-18	f
2021-03-19	f
2021-03-22	f
2021-03-23	f
2021-03-24	f
2021-03-25	f
2021-03-26	f
2021-03-29	f
2021-03-30	f
2021-03-31	f
2021-04-01	f
2021-04-02	f
2021-04-05	f
2021-04-06	f
2021-04-07	f
2021-04-08	f
2021-04-09	f
2021-04-12	f
2021-04-13	f
2021-04-14	f
2021-04-15	f
2021-04-16	f
2021-04-19	f
2021-04-20	f
2021-04-21	f
2021-04-22	f
2021-04-23	f
2021-04-26	f
2021-04-27	f
2021-04-28	f
2021-04-29	f
2021-04-30	f
2021-05-03	f
2021-05-04	f
2021-05-05	f
2021-05-06	f
2021-05-07	f
2021-05-10	f
2021-05-11	f
2021-05-12	f
2021-05-13	f
2021-05-14	f
2021-05-17	f
2021-05-18	f
2021-05-19	f
2021-05-20	f
2021-05-21	f
2021-05-24	f
2021-05-25	f
2021-05-26	f
2021-05-27	f
2021-05-28	f
2021-05-31	f
2021-06-01	f
2021-06-02	f
2021-06-03	f
2021-06-04	f
2021-06-07	f
2021-06-08	f
2021-06-09	f
2021-06-10	f
2021-06-11	f
2021-06-14	f
2021-06-15	f
2021-06-16	f
2021-06-17	f
2021-06-18	f
2021-06-21	f
2021-06-22	f
2021-06-23	f
2021-06-24	f
2021-06-25	f
2021-06-28	f
2021-06-29	f
2021-06-30	f
2021-07-01	f
2021-07-02	f
2021-07-05	f
2021-07-06	f
2021-07-07	f
2021-07-08	f
2021-07-09	f
2021-07-12	f
2021-07-13	f
2021-07-14	f
2021-07-15	f
2021-07-16	f
2021-07-19	f
2021-07-20	f
2021-07-21	f
2021-07-22	f
2021-07-23	f
2021-07-26	f
2021-07-27	f
2021-07-28	f
2021-07-29	f
2021-07-30	f
2021-08-02	f
2021-08-03	f
2021-08-04	f
2021-08-05	f
2021-08-06	f
2021-08-09	f
2021-08-10	f
2021-08-11	f
2021-08-12	f
2021-08-13	f
2021-08-16	f
2021-08-17	f
2021-08-18	f
2021-08-19	f
2021-08-20	f
2021-08-23	f
2021-08-24	f
2021-08-25	f
2021-08-26	f
2021-08-27	f
2021-08-30	f
2021-08-31	f
2021-09-01	f
2021-09-02	f
2021-09-03	f
2021-09-06	f
2021-09-07	f
2021-09-08	f
2021-09-09	f
2021-09-10	f
2021-09-13	f
2021-09-14	f
2021-09-15	f
2021-09-16	f
2021-09-17	f
2021-09-20	f
2021-09-21	f
2021-09-22	f
2021-09-23	f
2021-09-24	f
2021-09-27	f
2021-09-28	f
2021-09-29	f
2021-09-30	f
2021-10-01	f
2021-10-04	f
2021-10-05	f
2021-10-06	f
2021-10-07	f
2021-10-08	f
2021-10-11	f
2021-10-12	f
2021-10-13	f
2021-10-14	f
2021-10-15	f
2021-10-18	f
2021-10-19	f
2021-10-20	f
2021-10-21	f
2021-10-22	f
2021-10-25	f
2021-10-26	f
2021-10-27	f
2021-10-28	f
2021-10-29	f
2021-11-01	f
2021-11-02	f
2021-11-03	f
2021-11-04	f
2021-11-05	f
2021-11-08	f
2021-11-09	f
2021-11-10	f
2021-11-11	f
2021-11-12	f
2021-11-15	f
2021-11-16	f
2021-11-17	f
2021-11-18	f
2021-11-19	f
2021-11-22	f
2021-11-23	f
2021-11-24	f
2021-11-25	f
2021-11-26	f
2021-11-29	f
2021-11-30	f
2021-12-01	f
2021-12-02	f
2021-12-03	f
2021-12-06	f
2021-12-07	f
2021-12-08	f
2021-12-09	f
2021-12-10	f
2021-12-13	f
2021-12-14	f
2021-12-15	f
2021-12-16	f
2021-12-17	f
2021-12-20	f
2021-12-21	f
2021-12-22	f
2021-12-23	f
2021-12-24	f
2021-12-27	f
2021-12-28	f
2021-12-29	f
2021-12-30	f
2021-12-31	f
2022-01-03	f
2022-01-04	f
2022-01-05	f
2022-01-06	f
2022-01-07	f
2022-01-10	f
2022-01-11	f
2022-01-12	f
2022-01-13	f
2022-01-14	f
2022-01-17	f
2022-01-18	f
2022-01-19	f
2022-01-20	f
2022-01-21	f
2022-01-24	f
2022-01-25	f
2022-01-26	f
2022-01-27	f
2022-01-28	f
2022-01-31	f
2022-02-01	f
2022-02-02	f
2022-02-03	f
2022-02-04	f
2022-02-07	f
2022-02-08	f
2022-02-09	f
2022-02-10	f
2022-02-11	f
2022-02-14	f
2022-02-15	f
2022-02-16	f
2022-02-17	f
2022-02-18	f
2022-02-21	f
2022-02-22	f
2022-02-23	f
2022-02-24	f
2022-02-25	f
2022-02-28	f
2022-03-01	f
2022-03-02	f
2022-03-03	f
2022-03-04	f
2022-03-07	f
2022-03-08	f
2022-03-09	f
2022-03-10	f
2022-03-11	f
2022-03-14	f
2022-03-15	f
2022-03-16	f
2022-03-17	f
2022-03-18	f
2022-03-21	f
2022-03-22	f
2022-03-23	f
2022-03-24	f
2022-03-25	f
2022-03-28	f
2022-03-29	f
2022-03-30	f
2022-03-31	f
2022-04-01	f
2022-04-04	f
2022-04-05	f
2022-04-06	f
2022-04-07	f
2022-04-08	f
2022-04-11	f
2022-04-12	f
2022-04-13	f
2022-04-14	f
2022-04-15	f
2022-04-18	f
2022-04-19	f
2022-04-20	f
2022-04-21	f
2022-04-22	f
2022-04-25	f
2022-04-26	f
2022-04-27	f
2022-04-28	f
2022-04-29	f
2022-05-02	f
2022-05-03	f
2022-05-04	f
2022-05-05	f
2022-05-06	f
2022-05-09	f
2022-05-10	f
2022-05-11	f
2022-05-12	f
2022-05-13	f
2022-05-16	f
2022-05-17	f
2022-05-18	f
2022-05-19	f
2022-05-20	f
2022-05-23	f
2022-05-24	f
2022-05-25	f
2022-05-26	f
2022-05-27	f
2022-05-30	f
2022-05-31	f
2022-06-01	f
2022-06-02	f
2022-06-03	f
2022-06-06	f
2022-06-07	f
2022-06-08	f
2022-06-09	f
2022-06-10	f
2022-06-13	f
2022-06-14	f
2022-06-15	f
2022-06-16	f
2022-06-17	f
2022-06-20	f
2022-06-21	f
2022-06-22	f
2022-06-23	f
2022-06-24	f
2022-06-27	f
2022-06-28	f
2022-06-29	f
2022-06-30	f
2022-07-01	f
2022-07-04	f
2022-07-05	f
2022-07-06	f
2022-07-07	f
2022-07-08	f
2022-07-11	f
2022-07-12	f
2022-07-13	f
2022-07-14	f
2022-07-15	f
2022-07-18	f
2022-07-19	f
2022-07-20	f
2022-07-21	f
2022-07-22	f
2022-07-25	f
2022-07-26	f
2022-07-27	f
2022-07-28	f
2022-07-29	f
2022-08-01	f
2022-08-02	f
2022-08-03	f
2022-08-04	f
2022-08-05	f
2022-08-08	f
2022-08-09	f
2022-08-10	f
2022-08-11	f
2022-08-12	f
2022-08-15	f
2022-08-16	f
2022-08-17	f
2022-08-18	f
2022-08-19	f
2022-08-22	f
2022-08-23	f
2022-08-24	f
2022-08-25	f
2022-08-26	f
2022-08-29	f
2022-08-30	f
2022-08-31	f
2022-09-01	f
2022-09-02	f
2022-09-05	f
2022-09-06	f
2022-09-07	f
2022-09-08	f
2022-09-09	f
2022-09-12	f
2022-09-13	f
2022-09-14	f
2022-09-15	f
2022-09-16	f
2022-09-19	f
2022-09-20	f
2022-09-21	f
2022-09-22	f
2022-09-23	f
2022-09-26	f
2022-09-27	f
2022-09-28	f
2022-09-29	f
2022-09-30	f
2022-10-03	f
2022-10-04	f
2022-10-05	f
2022-10-06	f
2022-10-07	f
2022-10-10	f
2022-10-11	f
2022-10-12	f
2022-10-13	f
2022-10-14	f
2022-10-17	f
2022-10-18	f
2022-10-19	f
2022-10-20	f
2022-10-21	f
2022-10-24	f
2022-10-25	f
2022-10-26	f
2022-10-27	f
2022-10-28	f
2022-10-31	f
2022-11-01	f
2022-11-02	f
2022-11-03	f
2022-11-04	f
2022-11-07	f
2022-11-08	f
2022-11-09	f
2022-11-10	f
2022-11-11	f
2022-11-14	f
2022-11-15	f
2022-11-16	f
2022-11-17	f
2022-11-18	f
2022-11-21	f
2022-11-22	f
2022-11-23	f
2022-11-24	f
2022-11-25	f
2022-11-28	f
2022-11-29	f
2022-11-30	f
2022-12-01	f
2022-12-02	f
2022-12-05	f
2022-12-06	f
2022-12-07	f
2022-12-08	f
2022-12-09	f
2022-12-12	f
2022-12-13	f
2022-12-14	f
2022-12-15	f
2022-12-16	f
2022-12-19	f
2022-12-20	f
2022-12-21	f
2022-12-22	f
2022-12-23	f
2022-12-26	f
2022-12-27	f
2022-12-28	f
2022-12-29	f
2022-12-30	f
2023-01-02	f
2023-01-03	f
2023-01-04	f
2023-01-05	f
2023-01-06	f
2023-01-09	f
2023-01-10	f
2023-01-11	f
2023-01-12	f
2023-01-13	f
2023-01-16	f
2023-01-17	f
2023-01-18	f
2023-01-19	f
2023-01-20	f
2023-01-23	f
2023-01-24	f
2023-01-25	f
2023-01-26	f
2023-01-27	f
2023-01-30	f
2023-01-31	f
2023-02-01	f
2023-02-02	f
2023-02-03	f
2023-02-06	f
2023-02-07	f
2023-02-08	f
2023-02-09	f
2023-02-10	f
2023-02-13	f
2023-02-14	f
2023-02-15	f
2023-02-16	f
2023-02-17	f
2023-02-20	f
2023-02-21	f
2023-02-22	f
2023-02-23	f
2023-02-24	f
2023-02-27	f
2023-02-28	f
2023-03-01	f
2023-03-02	f
2023-03-03	f
2023-03-06	f
2023-03-07	f
2023-03-08	f
2023-03-09	f
2023-03-10	f
2023-03-13	f
2023-03-14	f
2023-03-15	f
2023-03-16	f
2023-03-17	f
2023-03-20	f
2023-03-21	f
2023-03-22	f
2023-03-23	f
2023-03-24	f
2023-03-27	f
2023-03-28	f
2023-03-29	f
2023-03-30	f
2023-03-31	f
2023-04-03	f
2023-04-04	f
2023-04-05	f
2023-04-06	f
2023-04-07	f
2023-04-10	f
2023-04-11	f
2023-04-12	f
2023-04-13	f
2023-04-14	f
2023-04-17	f
2023-04-18	f
2023-04-19	f
2023-04-20	f
2023-04-21	f
2023-04-24	f
2023-04-25	f
2023-04-26	f
2023-04-27	f
2023-04-28	f
2023-05-01	f
2023-05-02	f
2023-05-03	f
2023-05-04	f
2023-05-05	f
2023-05-08	f
2023-05-09	f
2023-05-10	f
2023-05-11	f
2023-05-12	f
2023-05-15	f
2023-05-16	f
2023-05-17	f
2023-05-18	f
2023-05-19	f
2023-05-22	f
2023-05-23	f
2023-05-24	f
2023-05-25	f
2023-05-26	f
2023-05-29	f
2023-05-30	f
2023-05-31	f
2023-06-01	f
2023-06-02	f
2023-06-05	f
2023-06-06	f
2023-06-07	f
2023-06-08	f
2023-06-09	f
2023-06-12	f
2023-06-13	f
2023-06-14	f
2023-06-15	f
2023-06-16	f
2023-06-19	f
2023-06-20	f
2023-06-21	f
2023-06-22	f
2023-06-23	f
2023-06-26	f
2023-06-27	f
2023-06-28	f
2023-06-29	f
2023-06-30	f
2023-07-03	f
2023-07-04	f
2023-07-05	f
2023-07-06	f
2023-07-07	f
2023-07-10	f
2023-07-11	f
2023-07-12	f
2023-07-13	f
2023-07-14	f
2023-07-17	f
2023-07-18	f
2023-07-19	f
2023-07-20	f
2023-07-21	f
2023-07-24	f
2023-07-25	f
2023-07-26	f
2023-07-27	f
2023-07-28	f
2023-07-31	f
2023-08-01	f
2023-08-02	f
2023-08-03	f
2023-08-04	f
2023-08-07	f
2023-08-08	f
2023-08-09	f
2023-08-10	f
2023-08-11	f
2023-08-14	f
2023-08-15	f
2023-08-16	f
2023-08-17	f
2023-08-18	f
2023-08-21	f
2023-08-22	f
2023-08-23	f
2023-08-24	f
2023-08-25	f
2023-08-28	f
2023-08-29	f
2023-08-30	f
2023-08-31	f
2023-09-01	f
2023-09-04	f
2023-09-05	f
2023-09-06	f
2023-09-07	f
2023-09-08	f
2023-09-11	f
2023-09-12	f
2023-09-13	f
2023-09-14	f
2023-09-15	f
2023-09-18	f
2023-09-19	f
2023-09-20	f
2023-09-21	f
2023-09-22	f
2023-09-25	f
2023-09-26	f
2023-09-27	f
2023-09-28	f
2023-09-29	f
2023-10-02	f
2023-10-03	f
2023-10-04	f
2023-10-05	f
2023-10-06	f
2023-10-09	f
2023-10-10	f
2023-10-11	f
2023-10-12	f
2023-10-13	f
2023-10-16	f
2023-10-17	f
2023-10-18	f
2023-10-19	f
2023-10-20	f
2023-10-23	f
2023-10-24	f
2023-10-25	f
2023-10-26	f
2023-10-27	f
2023-10-30	f
2023-10-31	f
2023-11-01	f
2023-11-02	f
2023-11-03	f
2023-11-06	f
2023-11-07	f
2023-11-08	f
2023-11-09	f
2023-11-10	f
2023-11-13	f
2023-11-14	f
2023-11-15	f
2023-11-16	f
2023-11-17	f
2023-11-20	f
2023-11-21	f
2023-11-22	f
2023-11-23	f
2023-11-24	f
2023-11-27	f
2023-11-28	f
2023-11-29	f
2023-11-30	f
2023-12-01	f
2023-12-04	f
2023-12-05	f
2023-12-06	f
2023-12-07	f
2023-12-08	f
2023-12-11	f
2023-12-12	f
2023-12-13	f
2023-12-14	f
2023-12-15	f
2023-12-18	f
2023-12-19	f
2023-12-20	f
2023-12-21	f
2023-12-22	f
2023-12-25	f
2023-12-26	f
2023-12-27	f
2023-12-28	f
2023-12-29	f
2024-01-01	f
2024-01-02	f
2024-01-03	f
2024-01-04	f
2024-01-05	f
2024-01-08	f
2024-01-09	f
2024-01-10	f
2024-01-11	f
2024-01-12	f
2024-01-15	f
2024-01-16	f
2024-01-17	f
2024-01-18	f
2024-01-19	f
2024-01-22	f
2024-01-23	f
2024-01-24	f
2024-01-25	f
2024-01-26	f
2024-01-29	f
2024-01-30	f
2024-01-31	f
2024-02-01	f
2024-02-02	f
2024-02-05	f
2024-02-06	f
2024-02-07	f
2024-02-08	f
2024-02-09	f
2024-02-12	f
2024-02-13	f
2024-02-14	f
2024-02-15	f
2024-02-16	f
2024-02-19	f
2024-02-20	f
2024-02-21	f
2024-02-22	f
2024-02-23	f
2024-02-26	f
2024-02-27	f
2024-02-28	f
2024-02-29	f
2024-03-01	f
2024-03-04	f
2024-03-05	f
2024-03-06	f
2024-03-07	f
2024-03-08	f
2024-03-11	f
2024-03-12	f
2024-03-13	f
2024-03-14	f
2024-03-15	f
2024-03-18	f
2024-03-19	f
2024-03-20	f
2024-03-21	f
2024-03-22	f
2024-03-25	f
2024-03-26	f
2024-03-27	f
2024-03-28	f
2024-03-29	f
2024-04-01	f
2024-04-02	f
2024-04-03	f
2024-04-04	f
2024-04-05	f
2024-04-08	f
2024-04-09	f
2024-04-10	f
2024-04-11	f
2024-04-12	f
2024-04-15	f
2024-04-16	f
2024-04-17	f
2024-04-18	f
2024-04-19	f
2024-04-22	f
2024-04-23	f
2024-04-24	f
2024-04-25	f
2024-04-26	f
2024-04-29	f
2024-04-30	f
2024-05-01	f
2024-05-02	f
2024-05-03	f
2024-05-06	f
2024-05-07	f
2024-05-08	f
2024-05-09	f
2024-05-10	f
2024-05-13	f
2024-05-14	f
2024-05-15	f
2024-05-16	f
2024-05-17	f
2024-05-20	f
2024-05-21	f
2024-05-22	f
2024-05-23	f
2024-05-24	f
2024-05-27	f
2024-05-28	f
2024-05-29	f
2024-05-30	f
2024-05-31	f
2024-06-03	f
2024-06-04	f
2024-06-05	f
2024-06-06	f
2024-06-07	f
2024-06-10	f
2024-06-11	f
2024-06-12	f
2024-06-13	f
2024-06-14	f
2024-06-17	f
2024-06-18	f
2024-06-19	f
2024-06-20	f
2024-06-21	f
2024-06-24	f
2024-06-25	f
2024-06-26	f
2024-06-27	f
2024-06-28	f
2024-07-01	f
2024-07-02	f
2024-07-03	f
2024-07-04	f
2024-07-05	f
2024-07-08	f
2024-07-09	f
2024-07-10	f
2024-07-11	f
2024-07-12	f
2024-07-15	f
2024-07-16	f
2024-07-17	f
2024-07-18	f
2024-07-19	f
2024-07-22	f
2024-07-23	f
2024-07-24	f
2024-07-25	f
2024-07-26	f
2024-07-29	f
2024-07-30	f
2024-07-31	f
2024-08-01	f
2024-08-02	f
2024-08-05	f
2024-08-06	f
2024-08-07	f
2024-08-08	f
2024-08-09	f
2024-08-12	f
2024-08-13	f
2024-08-14	f
2024-08-15	f
2024-08-16	f
2024-08-19	f
2024-08-20	f
2024-08-21	f
2024-08-22	f
2024-08-23	f
2024-08-26	f
2024-08-27	f
2024-08-28	f
2024-08-29	f
2024-08-30	f
2024-09-02	f
2024-09-03	f
2024-09-04	f
2024-09-05	f
2024-09-06	f
2024-09-09	f
2024-09-10	f
2024-09-11	f
2024-09-12	f
2024-09-13	f
2024-09-16	f
2024-09-17	f
2024-09-18	f
2024-09-19	f
2024-09-20	f
2024-09-23	f
2024-09-24	f
2024-09-25	f
2024-09-26	f
2024-09-27	f
2024-09-30	f
2024-10-01	f
2024-10-02	f
2024-10-03	f
2024-10-04	f
2024-10-07	f
2024-10-08	f
2024-10-09	f
2024-10-10	f
2024-10-11	f
2024-10-14	f
2024-10-15	f
2024-10-16	f
2024-10-17	f
2024-10-18	f
2024-10-21	f
2024-10-22	f
2024-10-23	f
2024-10-24	f
2024-10-25	f
2024-10-28	f
2024-10-29	f
2024-10-30	f
2024-10-31	f
2024-11-01	f
2024-11-04	f
2024-11-05	f
2024-11-06	f
2024-11-07	f
2024-11-08	f
2024-11-11	f
2024-11-12	f
2024-11-13	f
2024-11-14	f
2024-11-15	f
2024-11-18	f
2024-11-19	f
2024-11-20	f
2024-11-21	f
2024-11-22	f
2024-11-25	f
2024-11-26	f
2024-11-27	f
2024-11-28	f
2024-11-29	f
2024-12-02	f
2024-12-03	f
2024-12-04	f
2024-12-05	f
2024-12-06	f
2024-12-09	f
2024-12-10	f
2024-12-11	f
2024-12-12	f
2024-12-13	f
2024-12-16	f
2024-12-17	f
2024-12-18	f
2024-12-19	f
2024-12-20	f
2024-12-23	f
2024-12-24	f
2024-12-25	f
2024-12-26	f
2024-12-27	f
2024-12-30	f
2024-12-31	f
2025-01-01	f
2025-01-02	f
2025-01-03	f
2025-01-06	f
2025-01-07	f
2025-01-08	f
2025-01-09	f
2025-01-10	f
2025-01-13	f
2025-01-14	f
2025-01-15	f
2025-01-16	f
2025-01-17	f
2025-01-20	f
2025-01-21	f
2025-01-22	f
2025-01-23	f
2025-01-24	f
2025-01-27	f
2025-01-28	f
2025-01-29	f
2025-01-30	f
2025-01-31	f
2025-02-03	f
2025-02-04	f
2025-02-05	f
2025-02-06	f
2025-02-07	f
2025-02-10	f
2025-02-11	f
2025-02-12	f
2025-02-13	f
2025-02-14	f
2025-02-17	f
2025-02-18	f
2025-02-19	f
2025-02-20	f
2025-02-21	f
2025-02-24	f
2025-02-25	f
2025-02-26	f
2025-02-27	f
2025-02-28	f
2025-03-03	f
2025-03-04	f
2025-03-05	f
2025-03-06	f
2025-03-07	f
2025-03-10	f
2025-03-11	f
2025-03-12	f
2025-03-13	f
2025-03-14	f
2025-03-17	f
2025-03-18	f
2025-03-19	f
2025-03-20	f
2025-03-21	f
2025-03-24	f
2025-03-25	f
2025-03-26	f
2025-03-27	f
2025-03-28	f
2025-03-31	f
2025-04-01	f
2025-04-02	f
2025-04-03	f
2025-04-04	f
2025-04-07	f
2025-04-08	f
2025-04-09	f
2025-04-10	f
2025-04-11	f
2025-04-14	f
2025-04-15	f
2025-04-16	f
2025-04-17	f
2025-04-18	f
2025-04-21	f
2025-04-22	f
2025-04-23	f
2025-04-24	f
2025-04-25	f
2025-04-28	f
2025-04-29	f
2025-04-30	f
2025-05-01	f
2025-05-02	f
2025-05-05	f
2025-05-06	f
2025-05-07	f
2025-05-08	f
2025-05-09	f
2025-05-12	f
2025-05-13	f
2025-05-14	f
2025-05-15	f
2025-05-16	f
2025-05-19	f
2025-05-20	f
2025-05-21	f
2025-05-22	f
2025-05-23	f
2025-05-26	f
2025-05-27	f
2025-05-28	f
2025-05-29	f
2025-05-30	f
2025-06-02	f
2025-06-03	f
2025-06-04	f
2025-06-05	f
2025-06-06	f
2025-06-09	f
2025-06-10	f
2025-06-11	f
2025-06-12	f
2025-06-13	f
2025-06-16	f
2025-06-17	f
2025-06-18	f
2025-06-19	f
2025-06-20	f
2025-06-23	f
2025-06-24	f
2025-06-25	f
2025-06-26	f
2025-06-27	f
2025-06-30	f
2025-07-01	f
2025-07-02	f
2025-07-03	f
2025-07-04	f
2025-07-07	f
2025-07-08	f
2025-07-09	f
2025-07-10	f
2025-07-11	f
2025-07-14	f
2025-07-15	f
2025-07-16	f
2025-07-17	f
2025-07-18	f
2025-07-21	f
2025-07-22	f
2025-07-23	f
2025-07-24	f
2025-07-25	f
2025-07-28	f
2025-07-29	f
2025-07-30	f
2025-07-31	f
2025-08-01	f
2025-08-04	f
2025-08-05	f
2025-08-06	f
2025-08-07	f
2025-08-08	f
2025-08-11	f
2025-08-12	f
2025-08-13	f
2025-08-14	f
2025-08-15	f
2025-08-18	f
2025-08-19	f
2025-08-20	f
2025-08-21	f
2025-08-22	f
2025-08-25	f
2025-08-26	f
2025-08-27	f
2025-08-28	f
2025-08-29	f
2025-09-01	f
2025-09-02	f
2025-09-03	f
2025-09-04	f
2025-09-05	f
2025-09-08	f
2025-09-09	f
2025-09-10	f
2025-09-11	f
2025-09-12	f
2025-09-15	f
2025-09-16	f
2025-09-17	f
2025-09-18	f
2025-09-19	f
2025-09-22	f
2025-09-23	f
2025-09-24	f
2025-09-25	f
2025-09-26	f
2025-09-29	f
2025-09-30	f
2025-10-01	f
2025-10-02	f
2025-10-03	f
2025-10-06	f
2025-10-07	f
2025-10-08	f
2025-10-09	f
2025-10-10	f
2025-10-13	f
2025-10-14	f
2025-10-15	f
2025-10-16	f
2025-10-17	f
2025-10-20	f
2025-10-21	f
2025-10-22	f
2025-10-23	f
2025-10-24	f
2025-10-27	f
2025-10-28	f
2025-10-29	f
2025-10-30	f
2025-10-31	f
2025-11-03	f
2025-11-04	f
2025-11-05	f
2025-11-06	f
2025-11-07	f
2025-11-10	f
2025-11-11	f
2025-11-12	f
2025-11-13	f
2025-11-14	f
2025-11-17	f
2025-11-18	f
2025-11-19	f
2025-11-20	f
2025-11-21	f
2025-11-24	f
2025-11-25	f
2025-11-26	f
2025-11-27	f
2025-11-28	f
2025-12-01	f
2025-12-02	f
2025-12-03	f
2025-12-04	f
2025-12-05	f
2025-12-08	f
2025-12-09	f
2025-12-10	f
2025-12-11	f
2025-12-12	f
2025-12-15	f
2025-12-16	f
2025-12-17	f
2025-12-18	f
2025-12-19	f
2025-12-22	f
2025-12-23	f
2025-12-24	f
2025-12-25	f
2025-12-26	f
2025-12-29	f
2025-12-30	f
2025-12-31	f
2026-01-01	f
2026-01-02	f
2026-01-05	f
2026-01-06	f
2026-01-07	f
2026-01-08	f
2026-01-09	f
2026-01-12	f
2026-01-13	f
2026-01-14	f
2026-01-15	f
2026-01-16	f
2026-01-19	f
2026-01-20	f
2026-01-21	f
2026-01-22	f
2026-01-23	f
2026-01-26	f
2026-01-27	f
2026-01-28	f
2026-01-29	f
2026-01-30	f
2026-02-02	f
2026-02-03	f
2026-02-04	f
2026-02-05	f
2026-02-06	f
2026-02-09	f
2026-02-10	f
2026-02-11	f
2026-02-12	f
2026-02-13	f
2026-02-16	f
2026-02-17	f
2026-02-18	f
2026-02-19	f
2026-02-20	f
2026-02-23	f
2026-02-24	f
2026-02-25	f
2026-02-26	f
2026-02-27	f
2026-03-02	f
2026-03-03	f
2026-03-04	f
2026-03-05	f
2026-03-06	f
2026-03-09	f
2026-03-10	f
2026-03-11	f
2026-03-12	f
2026-03-13	f
2026-03-16	f
2026-03-17	f
2026-03-18	f
2026-03-19	f
2026-03-20	f
2026-03-23	f
2026-03-24	f
2026-03-25	f
2026-03-26	f
2026-03-27	f
2026-03-30	f
2026-03-31	f
2026-04-01	f
2026-04-02	f
2026-04-03	f
2026-04-06	f
2026-04-07	f
2026-04-08	f
2026-04-09	f
2026-04-10	f
2026-04-13	f
2026-04-14	f
2026-04-15	f
2026-04-16	f
2026-04-17	f
2026-04-20	f
2026-04-21	f
2026-04-22	f
2026-04-23	f
2026-04-24	f
2026-04-27	f
2026-04-28	f
2026-04-29	f
2026-04-30	f
2026-05-01	f
2026-05-04	f
2026-05-05	f
2026-05-06	f
2026-05-07	f
2026-05-08	f
2026-05-11	f
2026-05-12	f
2026-05-13	f
2026-05-14	f
2026-05-15	f
2026-05-18	f
2026-05-19	f
2026-05-20	f
2026-05-21	f
2026-05-22	f
2026-05-25	f
2026-05-26	f
2026-05-27	f
2026-05-28	f
2026-05-29	f
2026-06-01	f
2026-06-02	f
2026-06-03	f
2026-06-04	f
2026-06-05	f
2026-06-08	f
2026-06-09	f
2026-06-10	f
2026-06-11	f
2026-06-12	f
2026-06-15	f
2026-06-16	f
2026-06-17	f
2026-06-18	f
2026-06-19	f
2026-06-22	f
2026-06-23	f
2026-06-24	f
2026-06-25	f
2026-06-26	f
2026-06-29	f
2026-06-30	f
2026-07-01	f
2026-07-02	f
2026-07-03	f
2026-07-06	f
2026-07-07	f
2026-07-08	f
2026-07-09	f
2026-07-10	f
2026-07-13	f
2026-07-14	f
2026-07-15	f
2026-07-16	f
2026-07-17	f
2026-07-20	f
2026-07-21	f
2026-07-22	f
2026-07-23	f
2026-07-24	f
2026-07-27	f
2026-07-28	f
2026-07-29	f
2026-07-30	f
2026-07-31	f
2026-08-03	f
2026-08-04	f
2026-08-05	f
2026-08-06	f
2026-08-07	f
2026-08-10	f
2026-08-11	f
2026-08-12	f
2026-08-13	f
2026-08-14	f
2026-08-17	f
2026-08-18	f
2026-08-19	f
2026-08-20	f
2026-08-21	f
2026-08-24	f
2026-08-25	f
2026-08-26	f
2026-08-27	f
2026-08-28	f
2026-08-31	f
2026-09-01	f
2026-09-02	f
2026-09-03	f
2026-09-04	f
2026-09-07	f
2026-09-08	f
2026-09-09	f
2026-09-10	f
2026-09-11	f
2026-09-14	f
2026-09-15	f
2026-09-16	f
2026-09-17	f
2026-09-18	f
2026-09-21	f
2026-09-22	f
2026-09-23	f
2026-09-24	f
2026-09-25	f
2026-09-28	f
2026-09-29	f
2026-09-30	f
2026-10-01	f
2026-10-02	f
2026-10-05	f
2026-10-06	f
2026-10-07	f
2026-10-08	f
2026-10-09	f
2026-10-12	f
2026-10-13	f
2026-10-14	f
2026-10-15	f
2026-10-16	f
2026-10-19	f
2026-10-20	f
2026-10-21	f
2026-10-22	f
2026-10-23	f
2026-10-26	f
2026-10-27	f
2026-10-28	f
2026-10-29	f
2026-10-30	f
2026-11-02	f
2026-11-03	f
2026-11-04	f
2026-11-05	f
2026-11-06	f
2026-11-09	f
2026-11-10	f
2026-11-11	f
2026-11-12	f
2026-11-13	f
2026-11-16	f
2026-11-17	f
2026-11-18	f
2026-11-19	f
2026-11-20	f
2026-11-23	f
2026-11-24	f
2026-11-25	f
2026-11-26	f
2026-11-27	f
2026-11-30	f
2026-12-01	f
2026-12-02	f
2026-12-03	f
2026-12-04	f
2026-12-07	f
2026-12-08	f
2026-12-09	f
2026-12-10	f
2026-12-11	f
2026-12-14	f
2026-12-15	f
2026-12-16	f
2026-12-17	f
2026-12-18	f
2026-12-21	f
2026-12-22	f
2026-12-23	f
2026-12-24	f
2026-12-25	f
2026-12-28	f
2026-12-29	f
2026-12-30	f
2026-12-31	f
2027-01-01	f
2027-01-04	f
2027-01-05	f
2027-01-06	f
2027-01-07	f
2027-01-08	f
2027-01-11	f
2027-01-12	f
2027-01-13	f
2027-01-14	f
2027-01-15	f
2027-01-18	f
2027-01-19	f
2027-01-20	f
2027-01-21	f
2027-01-22	f
2027-01-25	f
2027-01-26	f
2027-01-27	f
2027-01-28	f
2027-01-29	f
2027-02-01	f
2027-02-02	f
2027-02-03	f
2027-02-04	f
2027-02-05	f
2027-02-08	f
2027-02-09	f
2027-02-10	f
2027-02-11	f
2027-02-12	f
2027-02-15	f
2027-02-16	f
2027-02-17	f
2027-02-18	f
2027-02-19	f
2027-02-22	f
2027-02-23	f
2027-02-24	f
2027-02-25	f
2027-02-26	f
2027-03-01	f
2027-03-02	f
2027-03-03	f
2027-03-04	f
2027-03-05	f
2027-03-08	f
2027-03-09	f
2027-03-10	f
2027-03-11	f
2027-03-12	f
2027-03-15	f
2027-03-16	f
2027-03-17	f
2027-03-18	f
2027-03-19	f
2027-03-22	f
2027-03-23	f
2027-03-24	f
2027-03-25	f
2027-03-26	f
2027-03-29	f
2027-03-30	f
2027-03-31	f
2027-04-01	f
2027-04-02	f
2027-04-05	f
2027-04-06	f
2027-04-07	f
2027-04-08	f
2027-04-09	f
2027-04-12	f
2027-04-13	f
2027-04-14	f
2027-04-15	f
2027-04-16	f
2027-04-19	f
2027-04-20	f
2027-04-21	f
2027-04-22	f
2027-04-23	f
2027-04-26	f
2027-04-27	f
2027-04-28	f
2027-04-29	f
2027-04-30	f
2027-05-03	f
2027-05-04	f
2027-05-05	f
2027-05-06	f
2027-05-07	f
2027-05-10	f
2027-05-11	f
2027-05-12	f
2027-05-13	f
2027-05-14	f
2027-05-17	f
2027-05-18	f
2027-05-19	f
2027-05-20	f
2027-05-21	f
2027-05-24	f
2027-05-25	f
2027-05-26	f
2027-05-27	f
2027-05-28	f
2027-05-31	f
2027-06-01	f
2027-06-02	f
2027-06-03	f
2027-06-04	f
2027-06-07	f
2027-06-08	f
2027-06-09	f
2027-06-10	f
2027-06-11	f
2027-06-14	f
2027-06-15	f
2027-06-16	f
2027-06-17	f
2027-06-18	f
2027-06-21	f
2027-06-22	f
2027-06-23	f
2027-06-24	f
2027-06-25	f
2027-06-28	f
2027-06-29	f
2027-06-30	f
2027-07-01	f
2027-07-02	f
2027-07-05	f
2027-07-06	f
2027-07-07	f
2027-07-08	f
2027-07-09	f
2027-07-12	f
2027-07-13	f
2027-07-14	f
2027-07-15	f
2027-07-16	f
2027-07-19	f
2027-07-20	f
2027-07-21	f
2027-07-22	f
2027-07-23	f
2027-07-26	f
2027-07-27	f
2027-07-28	f
2027-07-29	f
2027-07-30	f
2027-08-02	f
2027-08-03	f
2027-08-04	f
2027-08-05	f
2027-08-06	f
2027-08-09	f
2027-08-10	f
2027-08-11	f
2027-08-12	f
2027-08-13	f
2027-08-16	f
2027-08-17	f
2027-08-18	f
2027-08-19	f
2027-08-20	f
2027-08-23	f
2027-08-24	f
2027-08-25	f
2027-08-26	f
2027-08-27	f
2027-08-30	f
2027-08-31	f
2027-09-01	f
2027-09-02	f
2027-09-03	f
2027-09-06	f
2027-09-07	f
2027-09-08	f
2027-09-09	f
2027-09-10	f
2027-09-13	f
2027-09-14	f
2027-09-15	f
2027-09-16	f
2027-09-17	f
2027-09-20	f
2027-09-21	f
2027-09-22	f
2027-09-23	f
2027-09-24	f
2027-09-27	f
2027-09-28	f
2027-09-29	f
2027-09-30	f
2027-10-01	f
2027-10-04	f
2027-10-05	f
2027-10-06	f
2027-10-07	f
2027-10-08	f
2027-10-11	f
2027-10-12	f
2027-10-13	f
2027-10-14	f
2027-10-15	f
2027-10-18	f
2027-10-19	f
2027-10-20	f
2027-10-21	f
2027-10-22	f
2027-10-25	f
2027-10-26	f
2027-10-27	f
2027-10-28	f
2027-10-29	f
2027-11-01	f
2027-11-02	f
2027-11-03	f
2027-11-04	f
2027-11-05	f
2027-11-08	f
2027-11-09	f
2027-11-10	f
2027-11-11	f
2027-11-12	f
2027-11-15	f
2027-11-16	f
2027-11-17	f
2027-11-18	f
2027-11-19	f
2027-11-22	f
2027-11-23	f
2027-11-24	f
2027-11-25	f
2027-11-26	f
2027-11-29	f
2027-11-30	f
2027-12-01	f
2027-12-02	f
2027-12-03	f
2027-12-06	f
2027-12-07	f
2027-12-08	f
2027-12-09	f
2027-12-10	f
2027-12-13	f
2027-12-14	f
2027-12-15	f
2027-12-16	f
2027-12-17	f
2027-12-20	f
2027-12-21	f
2027-12-22	f
2027-12-23	f
2027-12-24	f
2027-12-27	f
2027-12-28	f
2027-12-29	f
2027-12-30	f
2027-12-31	f
2028-01-03	f
2028-01-04	f
2028-01-05	f
2028-01-06	f
2028-01-07	f
2028-01-10	f
2028-01-11	f
2028-01-12	f
2028-01-13	f
2028-01-14	f
2028-01-17	f
2028-01-18	f
2028-01-19	f
2028-01-20	f
2028-01-21	f
2028-01-24	f
2028-01-25	f
2028-01-26	f
2028-01-27	f
2028-01-28	f
2028-01-31	f
2028-02-01	f
2028-02-02	f
2028-02-03	f
2028-02-04	f
2028-02-07	f
2028-02-08	f
2028-02-09	f
2028-02-10	f
2028-02-11	f
2028-02-14	f
2028-02-15	f
2028-02-16	f
2028-02-17	f
2028-02-18	f
2028-02-21	f
2028-02-22	f
2028-02-23	f
2028-02-24	f
2028-02-25	f
2028-02-28	f
2028-02-29	f
2028-03-01	f
2028-03-02	f
2028-03-03	f
2028-03-06	f
2028-03-07	f
2028-03-08	f
2028-03-09	f
2028-03-10	f
2028-03-13	f
2028-03-14	f
2028-03-15	f
2028-03-16	f
2028-03-17	f
2028-03-20	f
2028-03-21	f
2028-03-22	f
2028-03-23	f
2028-03-24	f
2028-03-27	f
2028-03-28	f
2028-03-29	f
2028-03-30	f
2028-03-31	f
2028-04-03	f
2028-04-04	f
2028-04-05	f
2028-04-06	f
2028-04-07	f
2028-04-10	f
2028-04-11	f
2028-04-12	f
2028-04-13	f
2028-04-14	f
2028-04-17	f
2028-04-18	f
2028-04-19	f
2028-04-20	f
2028-04-21	f
2028-04-24	f
2028-04-25	f
2028-04-26	f
2028-04-27	f
2028-04-28	f
2028-05-01	f
2028-05-02	f
2028-05-03	f
2028-05-04	f
2028-05-05	f
2028-05-08	f
2028-05-09	f
2028-05-10	f
2028-05-11	f
2028-05-12	f
2028-05-15	f
2028-05-16	f
2028-05-17	f
2028-05-18	f
2028-05-19	f
2028-05-22	f
2028-05-23	f
2028-05-24	f
2028-05-25	f
2028-05-26	f
2028-05-29	f
2028-05-30	f
2028-05-31	f
2028-06-01	f
2028-06-02	f
2028-06-05	f
2028-06-06	f
2028-06-07	f
2028-06-08	f
2028-06-09	f
2028-06-12	f
2028-06-13	f
2028-06-14	f
2028-06-15	f
2028-06-16	f
2028-06-19	f
2028-06-20	f
2028-06-21	f
2028-06-22	f
2028-06-23	f
2028-06-26	f
2028-06-27	f
2028-06-28	f
2028-06-29	f
2028-06-30	f
2028-07-03	f
2028-07-04	f
2028-07-05	f
2028-07-06	f
2028-07-07	f
2028-07-10	f
2028-07-11	f
2028-07-12	f
2028-07-13	f
2028-07-14	f
2028-07-17	f
2028-07-18	f
2028-07-19	f
2028-07-20	f
2028-07-21	f
2028-07-24	f
2028-07-25	f
2028-07-26	f
2028-07-27	f
2028-07-28	f
2028-07-31	f
2028-08-01	f
2028-08-02	f
2028-08-03	f
2028-08-04	f
2028-08-07	f
2028-08-08	f
2028-08-09	f
2028-08-10	f
2028-08-11	f
2028-08-14	f
2028-08-15	f
2028-08-16	f
2028-08-17	f
2028-08-18	f
2028-08-21	f
2028-08-22	f
2028-08-23	f
2028-08-24	f
2028-08-25	f
2028-08-28	f
2028-08-29	f
2028-08-30	f
2028-08-31	f
2028-09-01	f
2028-09-04	f
2028-09-05	f
2028-09-06	f
2028-09-07	f
2028-09-08	f
2028-09-11	f
2028-09-12	f
2028-09-13	f
2028-09-14	f
2028-09-15	f
2028-09-18	f
2028-09-19	f
2028-09-20	f
2028-09-21	f
2028-09-22	f
2028-09-25	f
2028-09-26	f
2028-09-27	f
2028-09-28	f
2028-09-29	f
2028-10-02	f
2028-10-03	f
2028-10-04	f
2028-10-05	f
2028-10-06	f
2028-10-09	f
2028-10-10	f
2028-10-11	f
2028-10-12	f
2028-10-13	f
2028-10-16	f
2028-10-17	f
2028-10-18	f
2028-10-19	f
2028-10-20	f
2028-10-23	f
2028-10-24	f
2028-10-25	f
2028-10-26	f
2028-10-27	f
2028-10-30	f
2028-10-31	f
2028-11-01	f
2028-11-02	f
2028-11-03	f
2028-11-06	f
2028-11-07	f
2028-11-08	f
2028-11-09	f
2028-11-10	f
2028-11-13	f
2028-11-14	f
2028-11-15	f
2028-11-16	f
2028-11-17	f
2028-11-20	f
2028-11-21	f
2028-11-22	f
2028-11-23	f
2028-11-24	f
2028-11-27	f
2028-11-28	f
2028-11-29	f
2028-11-30	f
2028-12-01	f
2028-12-04	f
2028-12-05	f
2028-12-06	f
2028-12-07	f
2028-12-08	f
2028-12-11	f
2028-12-12	f
2028-12-13	f
2028-12-14	f
2028-12-15	f
2028-12-18	f
2028-12-19	f
2028-12-20	f
2028-12-21	f
2028-12-22	f
2028-12-25	f
2028-12-26	f
2028-12-27	f
2028-12-28	f
2028-12-29	f
2029-01-01	f
2029-01-02	f
2029-01-03	f
2029-01-04	f
2029-01-05	f
2029-01-08	f
2029-01-09	f
2029-01-10	f
2029-01-11	f
2029-01-12	f
2029-01-15	f
2029-01-16	f
2029-01-17	f
2029-01-18	f
2029-01-19	f
2029-01-22	f
2029-01-23	f
2029-01-24	f
2029-01-25	f
2029-01-26	f
2029-01-29	f
2029-01-30	f
2029-01-31	f
2029-02-01	f
2029-02-02	f
2029-02-05	f
2029-02-06	f
2029-02-07	f
2029-02-08	f
2029-02-09	f
2029-02-12	f
2029-02-13	f
2029-02-14	f
2029-02-15	f
2029-02-16	f
2029-02-19	f
2029-02-20	f
2029-02-21	f
2029-02-22	f
2029-02-23	f
2029-02-26	f
2029-02-27	f
2029-02-28	f
2029-03-01	f
2029-03-02	f
2029-03-05	f
2029-03-06	f
2029-03-07	f
2029-03-08	f
2029-03-09	f
2029-03-12	f
2029-03-13	f
2029-03-14	f
2029-03-15	f
2029-03-16	f
2029-03-19	f
2029-03-20	f
2029-03-21	f
2029-03-22	f
2029-03-23	f
2029-03-26	f
2029-03-27	f
2029-03-28	f
2029-03-29	f
2029-03-30	f
2029-04-02	f
2029-04-03	f
2029-04-04	f
2029-04-05	f
2029-04-06	f
2029-04-09	f
2029-04-10	f
2029-04-11	f
2029-04-12	f
2029-04-13	f
2029-04-16	f
2029-04-17	f
2029-04-18	f
2029-04-19	f
2029-04-20	f
2029-04-23	f
2029-04-24	f
2029-04-25	f
2029-04-26	f
2029-04-27	f
2029-04-30	f
2029-05-01	f
2029-05-02	f
2029-05-03	f
2029-05-04	f
2029-05-07	f
2029-05-08	f
2029-05-09	f
2029-05-10	f
2029-05-11	f
2029-05-14	f
2029-05-15	f
2029-05-16	f
2029-05-17	f
2029-05-18	f
2029-05-21	f
2029-05-22	f
2029-05-23	f
2029-05-24	f
2029-05-25	f
2029-05-28	f
2029-05-29	f
2029-05-30	f
2029-05-31	f
2029-06-01	f
2029-06-04	f
2029-06-05	f
2029-06-06	f
2029-06-07	f
2029-06-08	f
2029-06-11	f
2029-06-12	f
2029-06-13	f
2029-06-14	f
2029-06-15	f
2029-06-18	f
2029-06-19	f
2029-06-20	f
2029-06-21	f
2029-06-22	f
2029-06-25	f
2029-06-26	f
2029-06-27	f
2029-06-28	f
2029-06-29	f
2029-07-02	f
2029-07-03	f
2029-07-04	f
2029-07-05	f
2029-07-06	f
2029-07-09	f
2029-07-10	f
2029-07-11	f
2029-07-12	f
2029-07-13	f
2029-07-16	f
2029-07-17	f
2029-07-18	f
2029-07-19	f
2029-07-20	f
2029-07-23	f
2029-07-24	f
2029-07-25	f
2029-07-26	f
2029-07-27	f
2029-07-30	f
2029-07-31	f
2029-08-01	f
2029-08-02	f
2029-08-03	f
2029-08-06	f
2029-08-07	f
2029-08-08	f
2029-08-09	f
2029-08-10	f
2029-08-13	f
2029-08-14	f
2029-08-15	f
2029-08-16	f
2029-08-17	f
2029-08-20	f
2029-08-21	f
2029-08-22	f
2029-08-23	f
2029-08-24	f
2029-08-27	f
2029-08-28	f
2029-08-29	f
2029-08-30	f
2029-08-31	f
2029-09-03	f
2029-09-04	f
2029-09-05	f
2029-09-06	f
2029-09-07	f
2029-09-10	f
2029-09-11	f
2029-09-12	f
2029-09-13	f
2029-09-14	f
2029-09-17	f
2029-09-18	f
2029-09-19	f
2029-09-20	f
2029-09-21	f
2029-09-24	f
2029-09-25	f
2029-09-26	f
2029-09-27	f
2029-09-28	f
2029-10-01	f
2029-10-02	f
2029-10-03	f
2029-10-04	f
2029-10-05	f
2029-10-08	f
2029-10-09	f
2029-10-10	f
2029-10-11	f
2029-10-12	f
2029-10-15	f
2029-10-16	f
2029-10-17	f
2029-10-18	f
2029-10-19	f
2029-10-22	f
2029-10-23	f
2029-10-24	f
2029-10-25	f
2029-10-26	f
2029-10-29	f
2029-10-30	f
2029-10-31	f
2029-11-01	f
2029-11-02	f
2029-11-05	f
2029-11-06	f
2029-11-07	f
2029-11-08	f
2029-11-09	f
2029-11-12	f
2029-11-13	f
2029-11-14	f
2029-11-15	f
2029-11-16	f
2029-11-19	f
2029-11-20	f
2029-11-21	f
2029-11-22	f
2029-11-23	f
2029-11-26	f
2029-11-27	f
2029-11-28	f
2029-11-29	f
2029-11-30	f
2029-12-03	f
2029-12-04	f
2029-12-05	f
2029-12-06	f
2029-12-07	f
2029-12-10	f
2029-12-11	f
2029-12-12	f
2029-12-13	f
2029-12-14	f
2029-12-17	f
2029-12-18	f
2029-12-19	f
2029-12-20	f
2029-12-21	f
2029-12-24	f
2029-12-25	f
2029-12-26	f
2029-12-27	f
2029-12-28	f
2029-12-31	f
2030-01-01	f
2030-01-02	f
2029-09-15	t
2029-09-16	t
2029-09-22	t
2029-09-23	t
2029-09-29	t
2029-09-30	t
2029-10-06	t
2029-10-07	t
2029-10-13	t
2029-10-14	t
2029-10-20	t
2029-10-21	t
2029-10-27	t
2029-10-28	t
2029-11-03	t
2029-11-04	t
2029-11-10	t
2029-11-11	t
2029-11-17	t
2029-11-18	t
2029-11-24	t
2029-11-25	t
2029-12-01	t
2029-12-02	t
2029-12-08	t
2029-12-09	t
2029-12-15	t
2029-12-16	t
2029-12-22	t
2029-12-23	t
2029-12-29	t
2029-12-30	t
\.


--
-- Data for Name: dict_prices_discounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_prices_discounts (id, price_code, price_name, price_dscr, price_sum_flag, created_at, updated_at) FROM stdin;
16576	vip	Discount for VIP	 This is discount for VIP costomers	t	2017-01-22 17:55:27.54773	2017-01-22 17:55:27.54773
16577	holiday	Discount for Holiday	Discount for holidays.	f	2017-01-22 17:55:27.556538	2017-01-22 17:55:27.556538
16578	count5	Discount for 5 bike	If customer booking 5 bikes.	f	2017-01-22 17:55:27.56239	2017-01-22 17:55:27.56239
16579	period10	Discount for 10 days	If customer have booking for 10 days 	f	2017-01-22 17:55:27.568419	2017-01-22 17:55:27.568419
\.


--
-- Name: main_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('main_sequence', 17762, true);


--
-- Data for Name: t_bikes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_bikes (bike_id, bike_inventory_number, bike_model_id, bike_use_beg_date, bike_price, bike_current_state_id, created_at, updated_at) FROM stdin;
17616	8FC81AAFC39	10211	2016-01-01	120	17743	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17624	4238FCB3A15	10277	2016-02-23	100	17746	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17604	8DA75DF8F27	10211	2016-01-01	120	17605	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17606	8CD795AAAFB	10211	2016-01-01	120	17607	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17630	6C6EEF5CFA3	10277	2016-02-23	100	17631	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17632	39878E0688E	10277	2016-02-23	100	17633	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17638	94A01D05B6	10285	2016-03-02	70	17639	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17654	DAAF3548B3	10262	2015-07-12	50	17655	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17660	48E04645495	10211	2016-01-01	120	17661	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17662	797771BC2AA	10211	2016-01-01	120	17663	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17668	8834CC22B97	10211	2016-01-01	120	17669	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17670	66EDD07C218	10277	2016-02-23	100	17671	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17598	8635DE37659	10211	2016-01-01	120	17690	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17640	1A065CEFD6D	10262	2015-07-12	50	17691	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17676	2F6DEDD0EF1	10285	2016-03-02	70	17692	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17590	1FCF85154F	10211	2016-01-01	120	17693	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17608	6C29B9DF40E	10211	2016-01-01	120	17694	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17644	63A6407A7B1	10262	2015-07-12	50	17695	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17666	85945336BBF	10211	2016-01-01	120	17696	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17678	505C1C8375E	10262	2015-07-12	50	17697	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17576	7B9704C1960	10211	2016-01-01	120	17698	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17586	858C7A03E28	10211	2016-01-01	120	17699	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17656	78564024460	10211	2016-01-01	120	17700	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17588	CE35602330	10211	2016-01-01	120	17701	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17628	7FCD5A9DE17	10277	2016-02-23	100	17702	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17664	864354A6796	10211	2016-01-01	120	17703	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17674	DFE67DB230	10285	2016-03-02	70	17704	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17582	2E3C948421B	10211	2016-01-01	120	17705	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17594	327C9297DE5	10211	2016-01-01	120	17706	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17634	2D74DA2B2DF	10277	2016-02-23	100	17707	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17636	8B590BA79E3	10285	2016-03-02	70	17708	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17596	CADE53E66F	10211	2016-01-01	120	17709	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17600	3FF5DBF6A5E	10211	2016-01-01	120	17710	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17614	73D4617A450	10211	2016-01-01	120	17711	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17626	4587EAC8619	10277	2016-02-23	100	17712	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17650	21BAF716E26	10262	2015-07-12	50	17713	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17652	5FDE87E4F3A	10262	2015-07-12	50	17714	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17680	435926D4AC9	10262	2015-07-12	50	17715	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17580	6C5E7608D2	10211	2016-01-01	120	17716	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17642	1DBE42AC1F9	10262	2015-07-12	50	17717	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17682	5CFC29A76FD	10262	2015-07-12	50	17718	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17684	769197D7AF9	10262	2015-07-12	50	17719	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17592	8942A82A2F6	10211	2016-01-01	120	17720	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17602	569CC3731FB	10211	2016-01-01	120	17721	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17618	3F03C404B72	10277	2016-02-23	100	17722	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17578	1FDBABE6854	10211	2016-01-01	120	17723	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17612	58E5DBB354B	10211	2016-01-01	120	17724	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17584	84C5EE05498	10211	2016-01-01	120	17725	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17622	6772E5051A7	10277	2016-02-23	100	17731	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17646	515DAD36267	10262	2015-07-12	50	17732	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17658	653B7C94488	10211	2016-01-01	120	17733	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17672	E3497E2270	10277	2016-02-23	100	17738	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17610	5F569AC63F7	10211	2016-01-01	120	17740	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17620	69F1ED0E763	10277	2016-02-23	100	17741	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
17648	4D9B0538DBB	10262	2015-07-12	50	17742	2017-01-07 14:47:02.453574	2017-01-07 14:47:26.194499
\.


--
-- Data for Name: t_bikes_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_bikes_states (id, bike_id, bike_state_id, bike_state_date) FROM stdin;
17577	17576	10014	2017-01-24 18:29:43.489084
17579	17578	10014	2017-01-24 18:29:43.49297
17581	17580	10014	2017-01-24 18:29:43.494857
17583	17582	10014	2017-01-24 18:29:43.496575
17585	17584	10014	2017-01-24 18:29:43.498524
17587	17586	10014	2017-01-24 18:29:43.500995
17589	17588	10014	2017-01-24 18:29:43.502944
17591	17590	10014	2017-01-24 18:29:43.50459
17593	17592	10014	2017-01-24 18:29:43.506501
17595	17594	10014	2017-01-24 18:29:43.509167
17597	17596	10014	2017-01-24 18:29:43.510942
17599	17598	10014	2017-01-24 18:29:43.512667
17601	17600	10014	2017-01-24 18:29:43.514658
17603	17602	10014	2017-01-24 18:29:43.516652
17605	17604	10014	2017-01-24 18:29:43.518725
17607	17606	10014	2017-01-24 18:29:43.520828
17609	17608	10014	2017-01-24 18:29:43.522853
17611	17610	10014	2017-01-24 18:31:02.402175
17613	17612	10014	2017-01-24 18:31:02.406041
17615	17614	10014	2017-01-24 18:31:02.40756
17617	17616	10014	2017-01-24 18:31:02.409396
17619	17618	10014	2017-01-24 18:31:02.411744
17621	17620	10014	2017-01-24 18:31:02.413792
17623	17622	10014	2017-01-24 18:31:02.415803
17625	17624	10014	2017-01-24 18:31:02.417709
17627	17626	10014	2017-01-24 18:31:02.41961
17629	17628	10014	2017-01-24 18:31:02.420996
17631	17630	10014	2017-01-24 18:31:02.422427
17633	17632	10014	2017-01-24 18:31:02.423992
17635	17634	10014	2017-01-24 18:31:02.425461
17637	17636	10014	2017-01-24 18:31:02.427677
17639	17638	10014	2017-01-24 18:31:02.429539
17641	17640	10014	2017-01-24 18:31:02.431969
17643	17642	10014	2017-01-24 18:31:02.434033
17645	17644	10014	2017-01-24 18:31:02.43673
17647	17646	10014	2017-01-24 18:31:02.438519
17649	17648	10014	2017-01-24 18:31:02.440512
17651	17650	10014	2017-01-24 18:31:02.442448
17653	17652	10014	2017-01-24 18:31:02.444183
17655	17654	10014	2017-01-24 18:31:02.44614
17657	17656	10014	2017-01-24 18:31:28.605756
17659	17658	10014	2017-01-24 18:31:28.609945
17661	17660	10014	2017-01-24 18:31:28.61191
17663	17662	10014	2017-01-24 18:31:28.614413
17665	17664	10014	2017-01-24 18:31:28.616459
17667	17666	10014	2017-01-24 18:31:28.619487
17669	17668	10014	2017-01-24 18:31:28.621282
17671	17670	10014	2017-01-24 18:31:28.623682
17673	17672	10014	2017-01-24 18:31:28.625299
17675	17674	10014	2017-01-24 18:31:28.627855
17677	17676	10014	2017-01-24 18:31:28.629762
17679	17678	10014	2017-01-24 18:31:28.631933
17681	17680	10014	2017-01-24 18:31:28.633683
17683	17682	10014	2017-01-24 18:31:28.634958
17685	17684	10014	2017-01-24 18:31:28.636377
17688	17576	10015	2017-01-24 23:44:47.562112
17689	17576	10014	2017-01-24 23:46:47.707338
17690	17598	10015	2017-01-24 20:31:23.602092
17691	17640	10015	2017-01-24 20:31:23.609439
17692	17676	10015	2017-01-24 20:31:23.61225
17693	17590	10015	2017-01-24 20:33:09.141217
17694	17608	10015	2017-01-24 20:33:09.146077
17695	17644	10015	2017-01-24 20:33:09.149743
17696	17666	10015	2017-01-24 20:33:09.152145
17697	17678	10015	2017-01-24 20:33:09.154841
17698	17576	10015	2017-01-25 20:08:54.255731
17699	17586	10015	2017-01-28 17:52:54.499312
17700	17656	10015	2017-01-28 17:52:54.515222
17701	17588	10015	2017-01-28 17:53:37.136599
17702	17628	10015	2017-01-28 17:53:37.140915
17703	17664	10015	2017-01-28 17:53:37.143406
17704	17674	10015	2017-01-28 17:53:37.145723
17705	17582	10015	2017-01-28 17:54:13.994372
17706	17594	10015	2017-01-28 17:54:13.999275
17707	17634	10015	2017-01-28 17:54:14.001725
17708	17636	10015	2017-01-28 17:54:14.004064
17709	17596	10015	2017-01-28 17:56:45.135086
17710	17600	10015	2017-01-28 17:56:45.139392
17711	17614	10015	2017-01-28 17:56:45.141905
17712	17626	10015	2017-01-28 17:56:45.144304
17713	17650	10015	2017-01-28 17:56:45.147115
17714	17652	10015	2017-01-28 17:56:45.149888
17715	17680	10015	2017-01-28 17:56:45.15245
17716	17580	10015	2017-01-28 17:58:47.068357
17717	17642	10015	2017-01-28 17:58:47.070138
17718	17682	10015	2017-01-28 17:58:47.071806
17719	17684	10015	2017-01-28 17:58:47.073378
17720	17592	10015	2017-01-28 17:59:31.261232
17721	17602	10015	2017-01-28 17:59:31.265691
17722	17618	10015	2017-01-28 17:59:31.26807
17723	17578	10015	2017-01-28 18:04:26.511978
17724	17612	10015	2017-01-28 18:04:26.516872
17725	17584	10015	2017-01-28 18:05:18.814069
17731	17622	10015	2017-01-28 18:37:12.445465
17732	17646	10015	2017-01-28 18:37:12.44817
17733	17658	10015	2017-01-28 18:37:12.450524
17738	17672	10015	2017-01-28 22:55:04.836875
17740	17610	10015	2017-01-28 22:56:30.154442
17741	17620	10015	2017-01-28 22:56:30.159228
17742	17648	10015	2017-01-28 22:56:30.161823
17743	17616	10015	2017-01-28 22:58:36.013959
17746	17624	10015	2017-01-28 23:07:38.688942
\.


--
-- Data for Name: t_booking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking (booking_id, booking_time, booking_code, customer_id, booking_state_id, updated_at) FROM stdin;
17747	2017-01-28 23:07:38.727603	first	10032	13691	2017-01-28 23:07:38.727603
17749	2017-01-28 23:07:38.740709	second	10032	13691	2017-01-28 23:07:38.740709
17751	2017-01-28 23:07:38.745838	third	10034	13691	2017-01-28 23:07:38.745838
17754	2017-01-28 23:07:38.760266	H1H23	10049	13691	2017-01-28 23:07:38.760266
17756	2017-01-28 23:07:38.765312	E2E4	10049	13691	2017-01-28 23:07:38.765312
17758	2017-01-28 23:07:38.770316	D2D4	10050	13691	2017-01-28 23:07:38.770316
17760	2017-01-28 23:07:38.778464	F2F4	10051	13691	2017-01-28 23:07:38.778464
\.


--
-- Data for Name: t_booking_contents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking_contents (id, booking_id, bike_model_id, period_beg_date, period_end_date, bikes_count, created_at, updated_at) FROM stdin;
17748	17747	10262	2016-01-01 00:00:00	2016-01-07 00:00:00	1	2017-01-28 23:07:38.727603	2017-01-28 23:07:38.727603
17750	17749	10262	2016-07-01 00:00:00	2016-07-14 00:00:00	1	2017-01-28 23:07:38.740709	2017-01-28 23:07:38.740709
17752	17751	10211	2016-01-01 00:00:00	2016-01-14 00:00:00	2	2017-01-28 23:07:38.745838	2017-01-28 23:07:38.745838
17753	17751	10262	2016-01-01 00:00:00	2016-01-14 00:00:00	3	2017-01-28 23:07:38.755316	2017-01-28 23:07:38.755316
17755	17754	10277	2016-09-10 00:00:00	2016-09-16 00:00:00	1	2017-01-28 23:07:38.760266	2017-01-28 23:07:38.760266
17757	17756	10277	2016-10-15 00:00:00	2016-10-18 00:00:00	2	2017-01-28 23:07:38.765312	2017-01-28 23:07:38.765312
17759	17758	10277	2016-09-10 00:00:00	2016-09-16 00:00:00	1	2017-01-28 23:07:38.770316	2017-01-28 23:07:38.770316
17761	17760	10211	2016-11-05 00:00:00	2016-11-07 00:00:00	2	2017-01-28 23:07:38.778464	2017-01-28 23:07:38.778464
17762	17758	10285	2016-11-23 00:00:00	2016-12-16 00:00:00	1	2017-01-28 23:12:24.302846	2017-01-28 23:12:24.302846
\.


--
-- Data for Name: t_booking_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking_orders (id, booking_id, bike_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_booking_prices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking_prices (id, t_price_plans_id, booking_consist_id, currency_id, price, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_customers (customer_id, customer_login, customer_password, customer_name, customer_surname, customer_last_name, mobile_phone_main, mobile_phone_second, email, created_at, updated_at) FROM stdin;
10032	piterparker	password1	Piter		Parker	+4123456789		spider_man@gmail.com	2017-01-09 20:41:49.735871	2017-01-09 20:41:49.735871
10033	N/A	N/A	Clark		Kent	+4123456780		superman@gmail.com	2017-01-09 20:41:49.743106	2017-01-09 20:41:49.743106
10034	vladimirschuka	pass1234	Vladimir	Alexandrovich	Schuka	+79022535754		vladimirschuka@gmail.com	2017-01-09 20:41:49.748355	2017-01-09 20:41:49.748355
10036	N/A	N/A	Clark		Kent	+4123456780		superman@gmail.com	2017-01-09 20:41:55.139819	2017-01-09 20:41:55.139819
10035	N/A	N/A	Piter		Parker	+4123456789		spider_man@gmail.com	2017-01-09 20:41:55.134765	2017-01-09 20:41:55.134765
10039	N/A	N/A	Clark		Kent	+4123456780		superman@gmail.com	2017-01-16 17:09:19.244606	2017-01-16 17:09:19.244606
10040	N/A	N/A	Clark		Kent	+4123456780		superman@gmail.com	2017-01-16 17:10:34.163328	2017-01-16 17:10:34.163328
10041	N/A	N/A	Clark		Kent	+4123456780		superman@gmail.com	2017-01-16 17:11:13.560411	2017-01-16 17:11:13.560411
10045	N/A	N/A	Clark		Kent	+4123456780		superman@gmail.com	2017-01-16 17:14:39.385875	2017-01-16 17:14:39.385875
10049	dmitrii	pass1234	Dmitry		Schuka	+798878998796		mnbm@gmail.com	2017-01-16 18:44:45.556342	2017-01-16 18:44:45.556342
10050	scvbnm	pass1234	SomeOne		LastName	+79022538987		someone@gmail.com	2017-01-16 18:44:45.561187	2017-01-16 18:44:45.561187
10051	oneclient	pass1234	Clients		Clients2	+79992535754		clients@gmail.com	2017-01-16 18:44:45.56564	2017-01-16 18:44:45.56564
\.


--
-- Data for Name: t_customers_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_customers_groups (customer_group_id, customer_group_code, customer_group_name, customer_group_dscr, created_at, update_at) FROM stdin;
10046	vip	VIP clients	VIP clients	2017-01-16 17:14:39.40712	2017-01-16 17:14:39.406861
10047	oneyear	One year	Clients that have more then one year expirience work with our company	2017-01-16 17:14:39.411593	2017-01-16 17:14:39.411389
10048	good	Good clients	Clients those using often the our bikes (more then one times month (average from half year)) 	2017-01-16 17:14:39.41527	2017-01-16 17:14:39.415129
\.


--
-- Data for Name: t_customers_groups_membership; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_customers_groups_membership (id, beg_date, end_date, customer_id, customer_group_id, created_at, update_at) FROM stdin;
10061	2000-01-01 00:00:00	2100-01-01 00:00:00	10032	10046	2017-01-16 19:10:19.41332	2017-01-16 19:10:19.412998
10062	2000-01-01 00:00:00	2100-01-01 00:00:00	10032	10047	2017-01-16 19:10:19.424442	2017-01-16 19:10:19.424299
10063	2000-01-01 00:00:00	2100-01-01 00:00:00	10034	10048	2017-01-16 19:10:19.434214	2017-01-16 19:10:19.434069
10064	2000-01-01 00:00:00	2100-01-01 00:00:00	10050	10047	2017-01-16 19:10:19.443106	2017-01-16 19:10:19.442964
10065	2000-01-01 00:00:00	2100-01-01 00:00:00	10051	10048	2017-01-16 19:10:19.450158	2017-01-16 19:10:19.449973
10066	2000-01-01 00:00:00	2100-01-01 00:00:00	10051	10046	2017-01-16 19:10:19.457666	2017-01-16 19:10:19.457514
\.


--
-- Data for Name: t_prices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices (id, beg_date, end_date, bike_model_id, currency_id, price, created_at, updated_at) FROM stdin;
16582	2000-01-01 00:00:00	2016-05-31 18:59:59	10211	10030	12	2017-01-23 18:14:11.784798	2017-01-23 18:14:11.784798
16583	2000-01-01 00:00:00	2016-05-31 18:59:59	10211	10031	10	2017-01-23 18:14:11.79384	2017-01-23 18:14:11.79384
16584	2016-06-01 00:00:00	2016-08-31 18:59:59	10211	10030	10	2017-01-23 18:14:11.799712	2017-01-23 18:14:11.799712
16585	2016-06-01 00:00:00	2016-08-31 18:59:59	10211	10031	11	2017-01-23 18:14:11.80523	2017-01-23 18:14:11.80523
16586	2016-09-01 00:00:00	2016-12-31 18:59:59	10211	10030	13	2017-01-23 18:14:11.811319	2017-01-23 18:14:11.811319
16587	2016-09-01 00:00:00	2016-12-31 18:59:59	10211	10031	12	2017-01-23 18:14:11.816714	2017-01-23 18:14:11.816714
16588	2017-01-01 00:00:00	2099-12-31 18:59:59	10211	10030	10	2017-01-23 18:14:11.822794	2017-01-23 18:14:11.822794
16589	2017-01-01 00:00:00	2099-12-31 18:59:59	10211	10031	10	2017-01-23 18:14:11.827439	2017-01-23 18:14:11.827439
16590	2000-01-01 00:00:00	2016-05-31 18:59:59	10212	10030	12	2017-01-23 18:14:11.83315	2017-01-23 18:14:11.83315
16591	2000-01-01 00:00:00	2016-05-31 18:59:59	10212	10031	11	2017-01-23 18:14:11.839956	2017-01-23 18:14:11.839956
16592	2016-06-01 00:00:00	2016-08-31 18:59:59	10212	10030	10	2017-01-23 18:14:11.845738	2017-01-23 18:14:11.845738
16593	2016-06-01 00:00:00	2016-08-31 18:59:59	10212	10031	13	2017-01-23 18:14:11.851591	2017-01-23 18:14:11.851591
16594	2016-09-01 00:00:00	2016-12-31 18:59:59	10212	10030	12	2017-01-23 18:14:11.857745	2017-01-23 18:14:11.857745
16595	2016-09-01 00:00:00	2016-12-31 18:59:59	10212	10031	14	2017-01-23 18:14:11.862688	2017-01-23 18:14:11.862688
16596	2017-01-01 00:00:00	2099-12-31 18:59:59	10212	10030	13	2017-01-23 18:14:11.86871	2017-01-23 18:14:11.86871
16597	2017-01-01 00:00:00	2099-12-31 18:59:59	10212	10031	13	2017-01-23 18:14:11.874731	2017-01-23 18:14:11.874731
16598	2000-01-01 00:00:00	2016-05-31 18:59:59	10213	10030	14	2017-01-23 18:14:11.880709	2017-01-23 18:14:11.880709
16599	2000-01-01 00:00:00	2016-05-31 18:59:59	10213	10031	14	2017-01-23 18:14:11.88559	2017-01-23 18:14:11.88559
16600	2016-06-01 00:00:00	2016-08-31 18:59:59	10213	10030	12	2017-01-23 18:14:11.891602	2017-01-23 18:14:11.891602
16601	2016-06-01 00:00:00	2016-08-31 18:59:59	10213	10031	12	2017-01-23 18:14:11.89665	2017-01-23 18:14:11.89665
16602	2016-09-01 00:00:00	2016-12-31 18:59:59	10213	10030	14	2017-01-23 18:14:11.902933	2017-01-23 18:14:11.902933
16603	2016-09-01 00:00:00	2016-12-31 18:59:59	10213	10031	10	2017-01-23 18:14:11.909474	2017-01-23 18:14:11.909474
16604	2017-01-01 00:00:00	2099-12-31 18:59:59	10213	10030	11	2017-01-23 18:14:11.915212	2017-01-23 18:14:11.915212
16605	2017-01-01 00:00:00	2099-12-31 18:59:59	10213	10031	12	2017-01-23 18:14:11.920387	2017-01-23 18:14:11.920387
16606	2000-01-01 00:00:00	2016-05-31 18:59:59	10214	10030	14	2017-01-23 18:14:11.926284	2017-01-23 18:14:11.926284
16607	2000-01-01 00:00:00	2016-05-31 18:59:59	10214	10031	13	2017-01-23 18:14:11.931118	2017-01-23 18:14:11.931118
16608	2016-06-01 00:00:00	2016-08-31 18:59:59	10214	10030	11	2017-01-23 18:14:11.936714	2017-01-23 18:14:11.936714
16609	2016-06-01 00:00:00	2016-08-31 18:59:59	10214	10031	12	2017-01-23 18:14:11.941738	2017-01-23 18:14:11.941738
16610	2016-09-01 00:00:00	2016-12-31 18:59:59	10214	10030	12	2017-01-23 18:14:11.947105	2017-01-23 18:14:11.947105
16611	2016-09-01 00:00:00	2016-12-31 18:59:59	10214	10031	10	2017-01-23 18:14:11.951899	2017-01-23 18:14:11.951899
16612	2017-01-01 00:00:00	2099-12-31 18:59:59	10214	10030	13	2017-01-23 18:14:11.957524	2017-01-23 18:14:11.957524
16613	2017-01-01 00:00:00	2099-12-31 18:59:59	10214	10031	13	2017-01-23 18:14:11.962349	2017-01-23 18:14:11.962349
16614	2000-01-01 00:00:00	2016-05-31 18:59:59	10215	10030	13	2017-01-23 18:14:11.96815	2017-01-23 18:14:11.96815
16615	2000-01-01 00:00:00	2016-05-31 18:59:59	10215	10031	14	2017-01-23 18:14:11.973166	2017-01-23 18:14:11.973166
16616	2016-06-01 00:00:00	2016-08-31 18:59:59	10215	10030	10	2017-01-23 18:14:11.9788	2017-01-23 18:14:11.9788
16617	2016-06-01 00:00:00	2016-08-31 18:59:59	10215	10031	11	2017-01-23 18:14:11.983761	2017-01-23 18:14:11.983761
16618	2016-09-01 00:00:00	2016-12-31 18:59:59	10215	10030	13	2017-01-23 18:14:11.990943	2017-01-23 18:14:11.990943
16619	2016-09-01 00:00:00	2016-12-31 18:59:59	10215	10031	11	2017-01-23 18:14:11.995647	2017-01-23 18:14:11.995647
16620	2017-01-01 00:00:00	2099-12-31 18:59:59	10215	10030	13	2017-01-23 18:14:12.001427	2017-01-23 18:14:12.001427
16621	2017-01-01 00:00:00	2099-12-31 18:59:59	10215	10031	10	2017-01-23 18:14:12.00681	2017-01-23 18:14:12.00681
16622	2000-01-01 00:00:00	2016-05-31 18:59:59	10216	10030	10	2017-01-23 18:14:12.012475	2017-01-23 18:14:12.012475
16623	2000-01-01 00:00:00	2016-05-31 18:59:59	10216	10031	13	2017-01-23 18:14:12.017443	2017-01-23 18:14:12.017443
16624	2016-06-01 00:00:00	2016-08-31 18:59:59	10216	10030	14	2017-01-23 18:14:12.023212	2017-01-23 18:14:12.023212
16625	2016-06-01 00:00:00	2016-08-31 18:59:59	10216	10031	12	2017-01-23 18:14:12.028257	2017-01-23 18:14:12.028257
16626	2016-09-01 00:00:00	2016-12-31 18:59:59	10216	10030	13	2017-01-23 18:14:12.033982	2017-01-23 18:14:12.033982
16627	2016-09-01 00:00:00	2016-12-31 18:59:59	10216	10031	11	2017-01-23 18:14:12.039238	2017-01-23 18:14:12.039238
16628	2017-01-01 00:00:00	2099-12-31 18:59:59	10216	10030	12	2017-01-23 18:14:12.044826	2017-01-23 18:14:12.044826
16629	2017-01-01 00:00:00	2099-12-31 18:59:59	10216	10031	14	2017-01-23 18:14:12.049691	2017-01-23 18:14:12.049691
16630	2000-01-01 00:00:00	2016-05-31 18:59:59	10217	10030	14	2017-01-23 18:14:12.055644	2017-01-23 18:14:12.055644
16631	2000-01-01 00:00:00	2016-05-31 18:59:59	10217	10031	12	2017-01-23 18:14:12.0607	2017-01-23 18:14:12.0607
16632	2016-06-01 00:00:00	2016-08-31 18:59:59	10217	10030	10	2017-01-23 18:14:12.066607	2017-01-23 18:14:12.066607
16633	2016-06-01 00:00:00	2016-08-31 18:59:59	10217	10031	14	2017-01-23 18:14:12.071563	2017-01-23 18:14:12.071563
16634	2016-09-01 00:00:00	2016-12-31 18:59:59	10217	10030	10	2017-01-23 18:14:12.077636	2017-01-23 18:14:12.077636
16635	2016-09-01 00:00:00	2016-12-31 18:59:59	10217	10031	11	2017-01-23 18:14:12.083482	2017-01-23 18:14:12.083482
16636	2017-01-01 00:00:00	2099-12-31 18:59:59	10217	10030	13	2017-01-23 18:14:12.089539	2017-01-23 18:14:12.089539
16637	2017-01-01 00:00:00	2099-12-31 18:59:59	10217	10031	12	2017-01-23 18:14:12.094811	2017-01-23 18:14:12.094811
16638	2000-01-01 00:00:00	2016-05-31 18:59:59	10218	10030	10	2017-01-23 18:14:12.100787	2017-01-23 18:14:12.100787
16639	2000-01-01 00:00:00	2016-05-31 18:59:59	10218	10031	10	2017-01-23 18:14:12.106596	2017-01-23 18:14:12.106596
16640	2016-06-01 00:00:00	2016-08-31 18:59:59	10218	10030	12	2017-01-23 18:14:12.112584	2017-01-23 18:14:12.112584
16641	2016-06-01 00:00:00	2016-08-31 18:59:59	10218	10031	12	2017-01-23 18:14:12.117643	2017-01-23 18:14:12.117643
16642	2016-09-01 00:00:00	2016-12-31 18:59:59	10218	10030	11	2017-01-23 18:14:12.123455	2017-01-23 18:14:12.123455
16643	2016-09-01 00:00:00	2016-12-31 18:59:59	10218	10031	14	2017-01-23 18:14:12.128391	2017-01-23 18:14:12.128391
16644	2017-01-01 00:00:00	2099-12-31 18:59:59	10218	10030	11	2017-01-23 18:14:12.134249	2017-01-23 18:14:12.134249
16645	2017-01-01 00:00:00	2099-12-31 18:59:59	10218	10031	14	2017-01-23 18:14:12.139754	2017-01-23 18:14:12.139754
16646	2000-01-01 00:00:00	2016-05-31 18:59:59	10219	10030	11	2017-01-23 18:14:12.145487	2017-01-23 18:14:12.145487
16647	2000-01-01 00:00:00	2016-05-31 18:59:59	10219	10031	13	2017-01-23 18:14:12.151347	2017-01-23 18:14:12.151347
16648	2016-06-01 00:00:00	2016-08-31 18:59:59	10219	10030	13	2017-01-23 18:14:12.157359	2017-01-23 18:14:12.157359
16649	2016-06-01 00:00:00	2016-08-31 18:59:59	10219	10031	13	2017-01-23 18:14:12.162801	2017-01-23 18:14:12.162801
16650	2016-09-01 00:00:00	2016-12-31 18:59:59	10219	10030	13	2017-01-23 18:14:12.168332	2017-01-23 18:14:12.168332
16651	2016-09-01 00:00:00	2016-12-31 18:59:59	10219	10031	11	2017-01-23 18:14:12.17401	2017-01-23 18:14:12.17401
16652	2017-01-01 00:00:00	2099-12-31 18:59:59	10219	10030	10	2017-01-23 18:14:12.179681	2017-01-23 18:14:12.179681
16653	2017-01-01 00:00:00	2099-12-31 18:59:59	10219	10031	11	2017-01-23 18:14:12.185001	2017-01-23 18:14:12.185001
16654	2000-01-01 00:00:00	2016-05-31 18:59:59	10220	10030	14	2017-01-23 18:14:12.190921	2017-01-23 18:14:12.190921
16655	2000-01-01 00:00:00	2016-05-31 18:59:59	10220	10031	14	2017-01-23 18:14:12.196018	2017-01-23 18:14:12.196018
16656	2016-06-01 00:00:00	2016-08-31 18:59:59	10220	10030	10	2017-01-23 18:14:12.201615	2017-01-23 18:14:12.201615
16657	2016-06-01 00:00:00	2016-08-31 18:59:59	10220	10031	10	2017-01-23 18:14:12.207011	2017-01-23 18:14:12.207011
16658	2016-09-01 00:00:00	2016-12-31 18:59:59	10220	10030	10	2017-01-23 18:14:12.21274	2017-01-23 18:14:12.21274
16659	2016-09-01 00:00:00	2016-12-31 18:59:59	10220	10031	12	2017-01-23 18:14:12.218599	2017-01-23 18:14:12.218599
16660	2017-01-01 00:00:00	2099-12-31 18:59:59	10220	10030	10	2017-01-23 18:14:12.22446	2017-01-23 18:14:12.22446
16661	2017-01-01 00:00:00	2099-12-31 18:59:59	10220	10031	12	2017-01-23 18:14:12.229337	2017-01-23 18:14:12.229337
16662	2000-01-01 00:00:00	2016-05-31 18:59:59	10221	10030	10	2017-01-23 18:14:12.235341	2017-01-23 18:14:12.235341
16663	2000-01-01 00:00:00	2016-05-31 18:59:59	10221	10031	14	2017-01-23 18:14:12.240444	2017-01-23 18:14:12.240444
16664	2016-06-01 00:00:00	2016-08-31 18:59:59	10221	10030	12	2017-01-23 18:14:12.24596	2017-01-23 18:14:12.24596
16665	2016-06-01 00:00:00	2016-08-31 18:59:59	10221	10031	13	2017-01-23 18:14:12.251369	2017-01-23 18:14:12.251369
16666	2016-09-01 00:00:00	2016-12-31 18:59:59	10221	10030	14	2017-01-23 18:14:12.257164	2017-01-23 18:14:12.257164
16667	2016-09-01 00:00:00	2016-12-31 18:59:59	10221	10031	12	2017-01-23 18:14:12.262243	2017-01-23 18:14:12.262243
16668	2017-01-01 00:00:00	2099-12-31 18:59:59	10221	10030	11	2017-01-23 18:14:12.268102	2017-01-23 18:14:12.268102
16669	2017-01-01 00:00:00	2099-12-31 18:59:59	10221	10031	14	2017-01-23 18:14:12.27333	2017-01-23 18:14:12.27333
16670	2000-01-01 00:00:00	2016-05-31 18:59:59	10222	10030	10	2017-01-23 18:14:12.279264	2017-01-23 18:14:12.279264
16671	2000-01-01 00:00:00	2016-05-31 18:59:59	10222	10031	14	2017-01-23 18:14:12.284682	2017-01-23 18:14:12.284682
16672	2016-06-01 00:00:00	2016-08-31 18:59:59	10222	10030	12	2017-01-23 18:14:12.290471	2017-01-23 18:14:12.290471
16673	2016-06-01 00:00:00	2016-08-31 18:59:59	10222	10031	14	2017-01-23 18:14:12.295949	2017-01-23 18:14:12.295949
16674	2016-09-01 00:00:00	2016-12-31 18:59:59	10222	10030	12	2017-01-23 18:14:12.301696	2017-01-23 18:14:12.301696
16675	2016-09-01 00:00:00	2016-12-31 18:59:59	10222	10031	13	2017-01-23 18:14:12.306669	2017-01-23 18:14:12.306669
16676	2017-01-01 00:00:00	2099-12-31 18:59:59	10222	10030	10	2017-01-23 18:14:12.312784	2017-01-23 18:14:12.312784
16677	2017-01-01 00:00:00	2099-12-31 18:59:59	10222	10031	12	2017-01-23 18:14:12.317945	2017-01-23 18:14:12.317945
16678	2000-01-01 00:00:00	2016-05-31 18:59:59	10223	10030	13	2017-01-23 18:14:12.32358	2017-01-23 18:14:12.32358
16679	2000-01-01 00:00:00	2016-05-31 18:59:59	10223	10031	13	2017-01-23 18:14:12.328976	2017-01-23 18:14:12.328976
16680	2016-06-01 00:00:00	2016-08-31 18:59:59	10223	10030	13	2017-01-23 18:14:12.335431	2017-01-23 18:14:12.335431
16681	2016-06-01 00:00:00	2016-08-31 18:59:59	10223	10031	14	2017-01-23 18:14:12.341476	2017-01-23 18:14:12.341476
16682	2016-09-01 00:00:00	2016-12-31 18:59:59	10223	10030	12	2017-01-23 18:14:12.347763	2017-01-23 18:14:12.347763
16683	2016-09-01 00:00:00	2016-12-31 18:59:59	10223	10031	13	2017-01-23 18:14:12.352811	2017-01-23 18:14:12.352811
16684	2017-01-01 00:00:00	2099-12-31 18:59:59	10223	10030	13	2017-01-23 18:14:12.358354	2017-01-23 18:14:12.358354
16685	2017-01-01 00:00:00	2099-12-31 18:59:59	10223	10031	12	2017-01-23 18:14:12.363918	2017-01-23 18:14:12.363918
16686	2000-01-01 00:00:00	2016-05-31 18:59:59	10224	10030	10	2017-01-23 18:14:12.369813	2017-01-23 18:14:12.369813
16687	2000-01-01 00:00:00	2016-05-31 18:59:59	10224	10031	12	2017-01-23 18:14:12.374721	2017-01-23 18:14:12.374721
16688	2016-06-01 00:00:00	2016-08-31 18:59:59	10224	10030	14	2017-01-23 18:14:12.380428	2017-01-23 18:14:12.380428
16689	2016-06-01 00:00:00	2016-08-31 18:59:59	10224	10031	12	2017-01-23 18:14:12.385533	2017-01-23 18:14:12.385533
16690	2016-09-01 00:00:00	2016-12-31 18:59:59	10224	10030	12	2017-01-23 18:14:12.391548	2017-01-23 18:14:12.391548
16691	2016-09-01 00:00:00	2016-12-31 18:59:59	10224	10031	12	2017-01-23 18:14:12.397102	2017-01-23 18:14:12.397102
16692	2017-01-01 00:00:00	2099-12-31 18:59:59	10224	10030	12	2017-01-23 18:14:12.403177	2017-01-23 18:14:12.403177
16693	2017-01-01 00:00:00	2099-12-31 18:59:59	10224	10031	13	2017-01-23 18:14:12.408616	2017-01-23 18:14:12.408616
16694	2000-01-01 00:00:00	2016-05-31 18:59:59	10225	10030	10	2017-01-23 18:14:12.414246	2017-01-23 18:14:12.414246
16695	2000-01-01 00:00:00	2016-05-31 18:59:59	10225	10031	14	2017-01-23 18:14:12.419658	2017-01-23 18:14:12.419658
16696	2016-06-01 00:00:00	2016-08-31 18:59:59	10225	10030	14	2017-01-23 18:14:12.425813	2017-01-23 18:14:12.425813
16697	2016-06-01 00:00:00	2016-08-31 18:59:59	10225	10031	12	2017-01-23 18:14:12.430734	2017-01-23 18:14:12.430734
16698	2016-09-01 00:00:00	2016-12-31 18:59:59	10225	10030	12	2017-01-23 18:14:12.436546	2017-01-23 18:14:12.436546
16699	2016-09-01 00:00:00	2016-12-31 18:59:59	10225	10031	10	2017-01-23 18:14:12.441751	2017-01-23 18:14:12.441751
16700	2017-01-01 00:00:00	2099-12-31 18:59:59	10225	10030	10	2017-01-23 18:14:12.44836	2017-01-23 18:14:12.44836
16701	2017-01-01 00:00:00	2099-12-31 18:59:59	10225	10031	11	2017-01-23 18:14:12.453205	2017-01-23 18:14:12.453205
16702	2000-01-01 00:00:00	2016-05-31 18:59:59	10226	10030	10	2017-01-23 18:14:12.459043	2017-01-23 18:14:12.459043
16703	2000-01-01 00:00:00	2016-05-31 18:59:59	10226	10031	12	2017-01-23 18:14:12.464309	2017-01-23 18:14:12.464309
16704	2016-06-01 00:00:00	2016-08-31 18:59:59	10226	10030	12	2017-01-23 18:14:12.469837	2017-01-23 18:14:12.469837
16705	2016-06-01 00:00:00	2016-08-31 18:59:59	10226	10031	13	2017-01-23 18:14:12.475196	2017-01-23 18:14:12.475196
16706	2016-09-01 00:00:00	2016-12-31 18:59:59	10226	10030	10	2017-01-23 18:14:12.48101	2017-01-23 18:14:12.48101
16707	2016-09-01 00:00:00	2016-12-31 18:59:59	10226	10031	13	2017-01-23 18:14:12.486131	2017-01-23 18:14:12.486131
16708	2017-01-01 00:00:00	2099-12-31 18:59:59	10226	10030	11	2017-01-23 18:14:12.491676	2017-01-23 18:14:12.491676
16709	2017-01-01 00:00:00	2099-12-31 18:59:59	10226	10031	11	2017-01-23 18:14:12.496494	2017-01-23 18:14:12.496494
16710	2000-01-01 00:00:00	2016-05-31 18:59:59	10227	10030	10	2017-01-23 18:14:12.502303	2017-01-23 18:14:12.502303
16711	2000-01-01 00:00:00	2016-05-31 18:59:59	10227	10031	12	2017-01-23 18:14:12.507496	2017-01-23 18:14:12.507496
16712	2016-06-01 00:00:00	2016-08-31 18:59:59	10227	10030	13	2017-01-23 18:14:12.512975	2017-01-23 18:14:12.512975
16713	2016-06-01 00:00:00	2016-08-31 18:59:59	10227	10031	11	2017-01-23 18:14:12.518379	2017-01-23 18:14:12.518379
16714	2016-09-01 00:00:00	2016-12-31 18:59:59	10227	10030	14	2017-01-23 18:14:12.524406	2017-01-23 18:14:12.524406
16715	2016-09-01 00:00:00	2016-12-31 18:59:59	10227	10031	11	2017-01-23 18:14:12.529137	2017-01-23 18:14:12.529137
16716	2017-01-01 00:00:00	2099-12-31 18:59:59	10227	10030	11	2017-01-23 18:14:12.534845	2017-01-23 18:14:12.534845
16717	2017-01-01 00:00:00	2099-12-31 18:59:59	10227	10031	14	2017-01-23 18:14:12.540121	2017-01-23 18:14:12.540121
16718	2000-01-01 00:00:00	2016-05-31 18:59:59	10228	10030	11	2017-01-23 18:14:12.545758	2017-01-23 18:14:12.545758
16719	2000-01-01 00:00:00	2016-05-31 18:59:59	10228	10031	10	2017-01-23 18:14:12.551239	2017-01-23 18:14:12.551239
16720	2016-06-01 00:00:00	2016-08-31 18:59:59	10228	10030	11	2017-01-23 18:14:12.557825	2017-01-23 18:14:12.557825
16721	2016-06-01 00:00:00	2016-08-31 18:59:59	10228	10031	11	2017-01-23 18:14:12.562971	2017-01-23 18:14:12.562971
16722	2016-09-01 00:00:00	2016-12-31 18:59:59	10228	10030	13	2017-01-23 18:14:12.569626	2017-01-23 18:14:12.569626
16723	2016-09-01 00:00:00	2016-12-31 18:59:59	10228	10031	14	2017-01-23 18:14:12.574711	2017-01-23 18:14:12.574711
16724	2017-01-01 00:00:00	2099-12-31 18:59:59	10228	10030	10	2017-01-23 18:14:12.58058	2017-01-23 18:14:12.58058
16725	2017-01-01 00:00:00	2099-12-31 18:59:59	10228	10031	12	2017-01-23 18:14:12.585691	2017-01-23 18:14:12.585691
16726	2000-01-01 00:00:00	2016-05-31 18:59:59	10229	10030	11	2017-01-23 18:14:12.5917	2017-01-23 18:14:12.5917
16727	2000-01-01 00:00:00	2016-05-31 18:59:59	10229	10031	13	2017-01-23 18:14:12.596684	2017-01-23 18:14:12.596684
16728	2016-06-01 00:00:00	2016-08-31 18:59:59	10229	10030	14	2017-01-23 18:14:12.602939	2017-01-23 18:14:12.602939
16729	2016-06-01 00:00:00	2016-08-31 18:59:59	10229	10031	13	2017-01-23 18:14:12.608458	2017-01-23 18:14:12.608458
16730	2016-09-01 00:00:00	2016-12-31 18:59:59	10229	10030	12	2017-01-23 18:14:12.61481	2017-01-23 18:14:12.61481
16731	2016-09-01 00:00:00	2016-12-31 18:59:59	10229	10031	10	2017-01-23 18:14:12.620622	2017-01-23 18:14:12.620622
16732	2017-01-01 00:00:00	2099-12-31 18:59:59	10229	10030	14	2017-01-23 18:14:12.627751	2017-01-23 18:14:12.627751
16733	2017-01-01 00:00:00	2099-12-31 18:59:59	10229	10031	13	2017-01-23 18:14:12.633744	2017-01-23 18:14:12.633744
16734	2000-01-01 00:00:00	2016-05-31 18:59:59	10230	10030	14	2017-01-23 18:14:12.640401	2017-01-23 18:14:12.640401
16735	2000-01-01 00:00:00	2016-05-31 18:59:59	10230	10031	13	2017-01-23 18:14:12.64608	2017-01-23 18:14:12.64608
16736	2016-06-01 00:00:00	2016-08-31 18:59:59	10230	10030	11	2017-01-23 18:14:12.653593	2017-01-23 18:14:12.653593
16737	2016-06-01 00:00:00	2016-08-31 18:59:59	10230	10031	14	2017-01-23 18:14:12.660022	2017-01-23 18:14:12.660022
16738	2016-09-01 00:00:00	2016-12-31 18:59:59	10230	10030	11	2017-01-23 18:14:12.666801	2017-01-23 18:14:12.666801
16739	2016-09-01 00:00:00	2016-12-31 18:59:59	10230	10031	11	2017-01-23 18:14:12.672973	2017-01-23 18:14:12.672973
16740	2017-01-01 00:00:00	2099-12-31 18:59:59	10230	10030	12	2017-01-23 18:14:12.679243	2017-01-23 18:14:12.679243
16741	2017-01-01 00:00:00	2099-12-31 18:59:59	10230	10031	10	2017-01-23 18:14:12.685662	2017-01-23 18:14:12.685662
16742	2000-01-01 00:00:00	2016-05-31 18:59:59	10231	10030	14	2017-01-23 18:14:12.69167	2017-01-23 18:14:12.69167
16743	2000-01-01 00:00:00	2016-05-31 18:59:59	10231	10031	10	2017-01-23 18:14:12.697068	2017-01-23 18:14:12.697068
16744	2016-06-01 00:00:00	2016-08-31 18:59:59	10231	10030	12	2017-01-23 18:14:12.702715	2017-01-23 18:14:12.702715
16745	2016-06-01 00:00:00	2016-08-31 18:59:59	10231	10031	11	2017-01-23 18:14:12.708086	2017-01-23 18:14:12.708086
16746	2016-09-01 00:00:00	2016-12-31 18:59:59	10231	10030	11	2017-01-23 18:14:12.713824	2017-01-23 18:14:12.713824
16747	2016-09-01 00:00:00	2016-12-31 18:59:59	10231	10031	11	2017-01-23 18:14:12.718951	2017-01-23 18:14:12.718951
16748	2017-01-01 00:00:00	2099-12-31 18:59:59	10231	10030	10	2017-01-23 18:14:12.724826	2017-01-23 18:14:12.724826
16749	2017-01-01 00:00:00	2099-12-31 18:59:59	10231	10031	12	2017-01-23 18:14:12.730209	2017-01-23 18:14:12.730209
16750	2000-01-01 00:00:00	2016-05-31 18:59:59	10232	10030	13	2017-01-23 18:14:12.735777	2017-01-23 18:14:12.735777
16751	2000-01-01 00:00:00	2016-05-31 18:59:59	10232	10031	10	2017-01-23 18:14:12.740703	2017-01-23 18:14:12.740703
16752	2016-06-01 00:00:00	2016-08-31 18:59:59	10232	10030	14	2017-01-23 18:14:12.746469	2017-01-23 18:14:12.746469
16753	2016-06-01 00:00:00	2016-08-31 18:59:59	10232	10031	12	2017-01-23 18:14:12.751734	2017-01-23 18:14:12.751734
16754	2016-09-01 00:00:00	2016-12-31 18:59:59	10232	10030	14	2017-01-23 18:14:12.757726	2017-01-23 18:14:12.757726
16755	2016-09-01 00:00:00	2016-12-31 18:59:59	10232	10031	11	2017-01-23 18:14:12.763109	2017-01-23 18:14:12.763109
16756	2017-01-01 00:00:00	2099-12-31 18:59:59	10232	10030	14	2017-01-23 18:14:12.768915	2017-01-23 18:14:12.768915
16757	2017-01-01 00:00:00	2099-12-31 18:59:59	10232	10031	11	2017-01-23 18:14:12.774247	2017-01-23 18:14:12.774247
16758	2000-01-01 00:00:00	2016-05-31 18:59:59	10233	10030	12	2017-01-23 18:14:12.780029	2017-01-23 18:14:12.780029
16759	2000-01-01 00:00:00	2016-05-31 18:59:59	10233	10031	12	2017-01-23 18:14:12.785465	2017-01-23 18:14:12.785465
16760	2016-06-01 00:00:00	2016-08-31 18:59:59	10233	10030	12	2017-01-23 18:14:12.791072	2017-01-23 18:14:12.791072
16761	2016-06-01 00:00:00	2016-08-31 18:59:59	10233	10031	12	2017-01-23 18:14:12.796285	2017-01-23 18:14:12.796285
16762	2016-09-01 00:00:00	2016-12-31 18:59:59	10233	10030	13	2017-01-23 18:14:12.801912	2017-01-23 18:14:12.801912
16763	2016-09-01 00:00:00	2016-12-31 18:59:59	10233	10031	13	2017-01-23 18:14:12.80702	2017-01-23 18:14:12.80702
16764	2017-01-01 00:00:00	2099-12-31 18:59:59	10233	10030	13	2017-01-23 18:14:12.812715	2017-01-23 18:14:12.812715
16765	2017-01-01 00:00:00	2099-12-31 18:59:59	10233	10031	10	2017-01-23 18:14:12.81791	2017-01-23 18:14:12.81791
16766	2000-01-01 00:00:00	2016-05-31 18:59:59	10234	10030	10	2017-01-23 18:14:12.823957	2017-01-23 18:14:12.823957
16767	2000-01-01 00:00:00	2016-05-31 18:59:59	10234	10031	14	2017-01-23 18:14:12.829703	2017-01-23 18:14:12.829703
16768	2016-06-01 00:00:00	2016-08-31 18:59:59	10234	10030	10	2017-01-23 18:14:12.835381	2017-01-23 18:14:12.835381
16769	2016-06-01 00:00:00	2016-08-31 18:59:59	10234	10031	13	2017-01-23 18:14:12.840857	2017-01-23 18:14:12.840857
16770	2016-09-01 00:00:00	2016-12-31 18:59:59	10234	10030	12	2017-01-23 18:14:12.846778	2017-01-23 18:14:12.846778
16771	2016-09-01 00:00:00	2016-12-31 18:59:59	10234	10031	11	2017-01-23 18:14:12.852125	2017-01-23 18:14:12.852125
16772	2017-01-01 00:00:00	2099-12-31 18:59:59	10234	10030	10	2017-01-23 18:14:12.857996	2017-01-23 18:14:12.857996
16773	2017-01-01 00:00:00	2099-12-31 18:59:59	10234	10031	11	2017-01-23 18:14:12.86291	2017-01-23 18:14:12.86291
16774	2000-01-01 00:00:00	2016-05-31 18:59:59	10235	10030	11	2017-01-23 18:14:12.868479	2017-01-23 18:14:12.868479
16775	2000-01-01 00:00:00	2016-05-31 18:59:59	10235	10031	11	2017-01-23 18:14:12.873734	2017-01-23 18:14:12.873734
16776	2016-06-01 00:00:00	2016-08-31 18:59:59	10235	10030	14	2017-01-23 18:14:12.879504	2017-01-23 18:14:12.879504
16777	2016-06-01 00:00:00	2016-08-31 18:59:59	10235	10031	14	2017-01-23 18:14:12.885129	2017-01-23 18:14:12.885129
16778	2016-09-01 00:00:00	2016-12-31 18:59:59	10235	10030	10	2017-01-23 18:14:12.890867	2017-01-23 18:14:12.890867
16779	2016-09-01 00:00:00	2016-12-31 18:59:59	10235	10031	11	2017-01-23 18:14:12.895988	2017-01-23 18:14:12.895988
16780	2017-01-01 00:00:00	2099-12-31 18:59:59	10235	10030	14	2017-01-23 18:14:12.90157	2017-01-23 18:14:12.90157
16781	2017-01-01 00:00:00	2099-12-31 18:59:59	10235	10031	12	2017-01-23 18:14:12.90677	2017-01-23 18:14:12.90677
16782	2000-01-01 00:00:00	2016-05-31 18:59:59	10236	10030	10	2017-01-23 18:14:12.912575	2017-01-23 18:14:12.912575
16783	2000-01-01 00:00:00	2016-05-31 18:59:59	10236	10031	12	2017-01-23 18:14:12.917595	2017-01-23 18:14:12.917595
16784	2016-06-01 00:00:00	2016-08-31 18:59:59	10236	10030	12	2017-01-23 18:14:12.923437	2017-01-23 18:14:12.923437
16785	2016-06-01 00:00:00	2016-08-31 18:59:59	10236	10031	14	2017-01-23 18:14:12.928446	2017-01-23 18:14:12.928446
16786	2016-09-01 00:00:00	2016-12-31 18:59:59	10236	10030	13	2017-01-23 18:14:12.933925	2017-01-23 18:14:12.933925
16787	2016-09-01 00:00:00	2016-12-31 18:59:59	10236	10031	14	2017-01-23 18:14:12.938802	2017-01-23 18:14:12.938802
16788	2017-01-01 00:00:00	2099-12-31 18:59:59	10236	10030	13	2017-01-23 18:14:12.944473	2017-01-23 18:14:12.944473
16789	2017-01-01 00:00:00	2099-12-31 18:59:59	10236	10031	12	2017-01-23 18:14:12.949709	2017-01-23 18:14:12.949709
16790	2000-01-01 00:00:00	2016-05-31 18:59:59	10237	10030	14	2017-01-23 18:14:12.955683	2017-01-23 18:14:12.955683
16791	2000-01-01 00:00:00	2016-05-31 18:59:59	10237	10031	13	2017-01-23 18:14:12.961028	2017-01-23 18:14:12.961028
16792	2016-06-01 00:00:00	2016-08-31 18:59:59	10237	10030	14	2017-01-23 18:14:12.966754	2017-01-23 18:14:12.966754
16793	2016-06-01 00:00:00	2016-08-31 18:59:59	10237	10031	11	2017-01-23 18:14:12.972029	2017-01-23 18:14:12.972029
16794	2016-09-01 00:00:00	2016-12-31 18:59:59	10237	10030	14	2017-01-23 18:14:12.978667	2017-01-23 18:14:12.978667
16795	2016-09-01 00:00:00	2016-12-31 18:59:59	10237	10031	10	2017-01-23 18:14:12.983928	2017-01-23 18:14:12.983928
16796	2017-01-01 00:00:00	2099-12-31 18:59:59	10237	10030	11	2017-01-23 18:14:12.989603	2017-01-23 18:14:12.989603
16797	2017-01-01 00:00:00	2099-12-31 18:59:59	10237	10031	11	2017-01-23 18:14:12.994809	2017-01-23 18:14:12.994809
16798	2000-01-01 00:00:00	2016-05-31 18:59:59	10238	10030	14	2017-01-23 18:14:13.000693	2017-01-23 18:14:13.000693
16799	2000-01-01 00:00:00	2016-05-31 18:59:59	10238	10031	13	2017-01-23 18:14:13.006113	2017-01-23 18:14:13.006113
16800	2016-06-01 00:00:00	2016-08-31 18:59:59	10238	10030	13	2017-01-23 18:14:13.011736	2017-01-23 18:14:13.011736
16801	2016-06-01 00:00:00	2016-08-31 18:59:59	10238	10031	14	2017-01-23 18:14:13.016571	2017-01-23 18:14:13.016571
16802	2016-09-01 00:00:00	2016-12-31 18:59:59	10238	10030	10	2017-01-23 18:14:13.022245	2017-01-23 18:14:13.022245
16803	2016-09-01 00:00:00	2016-12-31 18:59:59	10238	10031	10	2017-01-23 18:14:13.027388	2017-01-23 18:14:13.027388
16804	2017-01-01 00:00:00	2099-12-31 18:59:59	10238	10030	11	2017-01-23 18:14:13.033787	2017-01-23 18:14:13.033787
16805	2017-01-01 00:00:00	2099-12-31 18:59:59	10238	10031	12	2017-01-23 18:14:13.03887	2017-01-23 18:14:13.03887
16806	2000-01-01 00:00:00	2016-05-31 18:59:59	10239	10030	13	2017-01-23 18:14:13.044308	2017-01-23 18:14:13.044308
16807	2000-01-01 00:00:00	2016-05-31 18:59:59	10239	10031	14	2017-01-23 18:14:13.049551	2017-01-23 18:14:13.049551
16808	2016-06-01 00:00:00	2016-08-31 18:59:59	10239	10030	11	2017-01-23 18:14:13.055335	2017-01-23 18:14:13.055335
16809	2016-06-01 00:00:00	2016-08-31 18:59:59	10239	10031	12	2017-01-23 18:14:13.060189	2017-01-23 18:14:13.060189
16810	2016-09-01 00:00:00	2016-12-31 18:59:59	10239	10030	12	2017-01-23 18:14:13.065683	2017-01-23 18:14:13.065683
16811	2016-09-01 00:00:00	2016-12-31 18:59:59	10239	10031	12	2017-01-23 18:14:13.070862	2017-01-23 18:14:13.070862
16812	2017-01-01 00:00:00	2099-12-31 18:59:59	10239	10030	13	2017-01-23 18:14:13.076856	2017-01-23 18:14:13.076856
16813	2017-01-01 00:00:00	2099-12-31 18:59:59	10239	10031	10	2017-01-23 18:14:13.082011	2017-01-23 18:14:13.082011
16814	2000-01-01 00:00:00	2016-05-31 18:59:59	10240	10030	11	2017-01-23 18:14:13.087791	2017-01-23 18:14:13.087791
16815	2000-01-01 00:00:00	2016-05-31 18:59:59	10240	10031	13	2017-01-23 18:14:13.093062	2017-01-23 18:14:13.093062
16816	2016-06-01 00:00:00	2016-08-31 18:59:59	10240	10030	14	2017-01-23 18:14:13.098995	2017-01-23 18:14:13.098995
16817	2016-06-01 00:00:00	2016-08-31 18:59:59	10240	10031	11	2017-01-23 18:14:13.104055	2017-01-23 18:14:13.104055
16818	2016-09-01 00:00:00	2016-12-31 18:59:59	10240	10030	10	2017-01-23 18:14:13.110034	2017-01-23 18:14:13.110034
16819	2016-09-01 00:00:00	2016-12-31 18:59:59	10240	10031	14	2017-01-23 18:14:13.115085	2017-01-23 18:14:13.115085
16820	2017-01-01 00:00:00	2099-12-31 18:59:59	10240	10030	14	2017-01-23 18:14:13.121631	2017-01-23 18:14:13.121631
16821	2017-01-01 00:00:00	2099-12-31 18:59:59	10240	10031	12	2017-01-23 18:14:13.126923	2017-01-23 18:14:13.126923
16822	2000-01-01 00:00:00	2016-05-31 18:59:59	10241	10030	14	2017-01-23 18:14:13.132427	2017-01-23 18:14:13.132427
16823	2000-01-01 00:00:00	2016-05-31 18:59:59	10241	10031	10	2017-01-23 18:14:13.137508	2017-01-23 18:14:13.137508
16824	2016-06-01 00:00:00	2016-08-31 18:59:59	10241	10030	13	2017-01-23 18:14:13.143476	2017-01-23 18:14:13.143476
16825	2016-06-01 00:00:00	2016-08-31 18:59:59	10241	10031	10	2017-01-23 18:14:13.148828	2017-01-23 18:14:13.148828
16826	2016-09-01 00:00:00	2016-12-31 18:59:59	10241	10030	10	2017-01-23 18:14:13.155105	2017-01-23 18:14:13.155105
16827	2016-09-01 00:00:00	2016-12-31 18:59:59	10241	10031	13	2017-01-23 18:14:13.160162	2017-01-23 18:14:13.160162
16828	2017-01-01 00:00:00	2099-12-31 18:59:59	10241	10030	11	2017-01-23 18:14:13.165435	2017-01-23 18:14:13.165435
16829	2017-01-01 00:00:00	2099-12-31 18:59:59	10241	10031	10	2017-01-23 18:14:13.170792	2017-01-23 18:14:13.170792
16830	2000-01-01 00:00:00	2016-05-31 18:59:59	10242	10030	12	2017-01-23 18:14:13.176678	2017-01-23 18:14:13.176678
16831	2000-01-01 00:00:00	2016-05-31 18:59:59	10242	10031	13	2017-01-23 18:14:13.181849	2017-01-23 18:14:13.181849
16832	2016-06-01 00:00:00	2016-08-31 18:59:59	10242	10030	12	2017-01-23 18:14:13.187423	2017-01-23 18:14:13.187423
16833	2016-06-01 00:00:00	2016-08-31 18:59:59	10242	10031	12	2017-01-23 18:14:13.192719	2017-01-23 18:14:13.192719
16834	2016-09-01 00:00:00	2016-12-31 18:59:59	10242	10030	14	2017-01-23 18:14:13.198564	2017-01-23 18:14:13.198564
16835	2016-09-01 00:00:00	2016-12-31 18:59:59	10242	10031	12	2017-01-23 18:14:13.203752	2017-01-23 18:14:13.203752
16836	2017-01-01 00:00:00	2099-12-31 18:59:59	10242	10030	13	2017-01-23 18:14:13.209607	2017-01-23 18:14:13.209607
16837	2017-01-01 00:00:00	2099-12-31 18:59:59	10242	10031	13	2017-01-23 18:14:13.214923	2017-01-23 18:14:13.214923
16838	2000-01-01 00:00:00	2016-05-31 18:59:59	10243	10030	11	2017-01-23 18:14:13.220718	2017-01-23 18:14:13.220718
16839	2000-01-01 00:00:00	2016-05-31 18:59:59	10243	10031	13	2017-01-23 18:14:13.225709	2017-01-23 18:14:13.225709
16840	2016-06-01 00:00:00	2016-08-31 18:59:59	10243	10030	12	2017-01-23 18:14:13.231702	2017-01-23 18:14:13.231702
16841	2016-06-01 00:00:00	2016-08-31 18:59:59	10243	10031	10	2017-01-23 18:14:13.237278	2017-01-23 18:14:13.237278
16842	2016-09-01 00:00:00	2016-12-31 18:59:59	10243	10030	11	2017-01-23 18:14:13.243086	2017-01-23 18:14:13.243086
16843	2016-09-01 00:00:00	2016-12-31 18:59:59	10243	10031	12	2017-01-23 18:14:13.248093	2017-01-23 18:14:13.248093
16844	2017-01-01 00:00:00	2099-12-31 18:59:59	10243	10030	11	2017-01-23 18:14:13.253775	2017-01-23 18:14:13.253775
16845	2017-01-01 00:00:00	2099-12-31 18:59:59	10243	10031	12	2017-01-23 18:14:13.259248	2017-01-23 18:14:13.259248
16846	2000-01-01 00:00:00	2016-05-31 18:59:59	10244	10030	14	2017-01-23 18:14:13.265793	2017-01-23 18:14:13.265793
16847	2000-01-01 00:00:00	2016-05-31 18:59:59	10244	10031	13	2017-01-23 18:14:13.270965	2017-01-23 18:14:13.270965
16848	2016-06-01 00:00:00	2016-08-31 18:59:59	10244	10030	10	2017-01-23 18:14:13.276625	2017-01-23 18:14:13.276625
16849	2016-06-01 00:00:00	2016-08-31 18:59:59	10244	10031	11	2017-01-23 18:14:13.281732	2017-01-23 18:14:13.281732
16850	2016-09-01 00:00:00	2016-12-31 18:59:59	10244	10030	10	2017-01-23 18:14:13.28712	2017-01-23 18:14:13.28712
16851	2016-09-01 00:00:00	2016-12-31 18:59:59	10244	10031	11	2017-01-23 18:14:13.292413	2017-01-23 18:14:13.292413
16852	2017-01-01 00:00:00	2099-12-31 18:59:59	10244	10030	13	2017-01-23 18:14:13.298067	2017-01-23 18:14:13.298067
16853	2017-01-01 00:00:00	2099-12-31 18:59:59	10244	10031	12	2017-01-23 18:14:13.302885	2017-01-23 18:14:13.302885
16854	2000-01-01 00:00:00	2016-05-31 18:59:59	10245	10030	11	2017-01-23 18:14:13.308767	2017-01-23 18:14:13.308767
16855	2000-01-01 00:00:00	2016-05-31 18:59:59	10245	10031	14	2017-01-23 18:14:13.314593	2017-01-23 18:14:13.314593
16856	2016-06-01 00:00:00	2016-08-31 18:59:59	10245	10030	13	2017-01-23 18:14:13.320256	2017-01-23 18:14:13.320256
16857	2016-06-01 00:00:00	2016-08-31 18:59:59	10245	10031	10	2017-01-23 18:14:13.325237	2017-01-23 18:14:13.325237
16858	2016-09-01 00:00:00	2016-12-31 18:59:59	10245	10030	11	2017-01-23 18:14:13.331185	2017-01-23 18:14:13.331185
16859	2016-09-01 00:00:00	2016-12-31 18:59:59	10245	10031	10	2017-01-23 18:14:13.33655	2017-01-23 18:14:13.33655
16860	2017-01-01 00:00:00	2099-12-31 18:59:59	10245	10030	11	2017-01-23 18:14:13.34243	2017-01-23 18:14:13.34243
16861	2017-01-01 00:00:00	2099-12-31 18:59:59	10245	10031	12	2017-01-23 18:14:13.347298	2017-01-23 18:14:13.347298
16862	2000-01-01 00:00:00	2016-05-31 18:59:59	10246	10030	12	2017-01-23 18:14:13.353353	2017-01-23 18:14:13.353353
16863	2000-01-01 00:00:00	2016-05-31 18:59:59	10246	10031	13	2017-01-23 18:14:13.358428	2017-01-23 18:14:13.358428
16864	2016-06-01 00:00:00	2016-08-31 18:59:59	10246	10030	11	2017-01-23 18:14:13.364196	2017-01-23 18:14:13.364196
16865	2016-06-01 00:00:00	2016-08-31 18:59:59	10246	10031	13	2017-01-23 18:14:13.369446	2017-01-23 18:14:13.369446
16866	2016-09-01 00:00:00	2016-12-31 18:59:59	10246	10030	13	2017-01-23 18:14:13.375025	2017-01-23 18:14:13.375025
16867	2016-09-01 00:00:00	2016-12-31 18:59:59	10246	10031	11	2017-01-23 18:14:13.380191	2017-01-23 18:14:13.380191
16868	2017-01-01 00:00:00	2099-12-31 18:59:59	10246	10030	14	2017-01-23 18:14:13.385726	2017-01-23 18:14:13.385726
16869	2017-01-01 00:00:00	2099-12-31 18:59:59	10246	10031	13	2017-01-23 18:14:13.390793	2017-01-23 18:14:13.390793
16870	2000-01-01 00:00:00	2016-05-31 18:59:59	10247	10030	11	2017-01-23 18:14:13.396354	2017-01-23 18:14:13.396354
16871	2000-01-01 00:00:00	2016-05-31 18:59:59	10247	10031	11	2017-01-23 18:14:13.401581	2017-01-23 18:14:13.401581
16872	2016-06-01 00:00:00	2016-08-31 18:59:59	10247	10030	12	2017-01-23 18:14:13.407337	2017-01-23 18:14:13.407337
16873	2016-06-01 00:00:00	2016-08-31 18:59:59	10247	10031	13	2017-01-23 18:14:13.412932	2017-01-23 18:14:13.412932
16874	2016-09-01 00:00:00	2016-12-31 18:59:59	10247	10030	14	2017-01-23 18:14:13.41876	2017-01-23 18:14:13.41876
16875	2016-09-01 00:00:00	2016-12-31 18:59:59	10247	10031	10	2017-01-23 18:14:13.424038	2017-01-23 18:14:13.424038
16876	2017-01-01 00:00:00	2099-12-31 18:59:59	10247	10030	14	2017-01-23 18:14:13.429588	2017-01-23 18:14:13.429588
16877	2017-01-01 00:00:00	2099-12-31 18:59:59	10247	10031	13	2017-01-23 18:14:13.434715	2017-01-23 18:14:13.434715
16878	2000-01-01 00:00:00	2016-05-31 18:59:59	10248	10030	12	2017-01-23 18:14:13.44062	2017-01-23 18:14:13.44062
16879	2000-01-01 00:00:00	2016-05-31 18:59:59	10248	10031	12	2017-01-23 18:14:13.445743	2017-01-23 18:14:13.445743
16880	2016-06-01 00:00:00	2016-08-31 18:59:59	10248	10030	14	2017-01-23 18:14:13.451693	2017-01-23 18:14:13.451693
16881	2016-06-01 00:00:00	2016-08-31 18:59:59	10248	10031	10	2017-01-23 18:14:13.457158	2017-01-23 18:14:13.457158
16882	2016-09-01 00:00:00	2016-12-31 18:59:59	10248	10030	13	2017-01-23 18:14:13.462944	2017-01-23 18:14:13.462944
16883	2016-09-01 00:00:00	2016-12-31 18:59:59	10248	10031	13	2017-01-23 18:14:13.467774	2017-01-23 18:14:13.467774
16884	2017-01-01 00:00:00	2099-12-31 18:59:59	10248	10030	12	2017-01-23 18:14:13.473326	2017-01-23 18:14:13.473326
16885	2017-01-01 00:00:00	2099-12-31 18:59:59	10248	10031	13	2017-01-23 18:14:13.478739	2017-01-23 18:14:13.478739
16886	2000-01-01 00:00:00	2016-05-31 18:59:59	10249	10030	13	2017-01-23 18:14:13.48472	2017-01-23 18:14:13.48472
16887	2000-01-01 00:00:00	2016-05-31 18:59:59	10249	10031	10	2017-01-23 18:14:13.489863	2017-01-23 18:14:13.489863
16888	2016-06-01 00:00:00	2016-08-31 18:59:59	10249	10030	13	2017-01-23 18:14:13.495718	2017-01-23 18:14:13.495718
16889	2016-06-01 00:00:00	2016-08-31 18:59:59	10249	10031	11	2017-01-23 18:14:13.500858	2017-01-23 18:14:13.500858
16890	2016-09-01 00:00:00	2016-12-31 18:59:59	10249	10030	12	2017-01-23 18:14:13.506436	2017-01-23 18:14:13.506436
16891	2016-09-01 00:00:00	2016-12-31 18:59:59	10249	10031	11	2017-01-23 18:14:13.511751	2017-01-23 18:14:13.511751
16892	2017-01-01 00:00:00	2099-12-31 18:59:59	10249	10030	14	2017-01-23 18:14:13.517922	2017-01-23 18:14:13.517922
16893	2017-01-01 00:00:00	2099-12-31 18:59:59	10249	10031	13	2017-01-23 18:14:13.523034	2017-01-23 18:14:13.523034
16894	2000-01-01 00:00:00	2016-05-31 18:59:59	10250	10030	13	2017-01-23 18:14:13.528732	2017-01-23 18:14:13.528732
16895	2000-01-01 00:00:00	2016-05-31 18:59:59	10250	10031	11	2017-01-23 18:14:13.53409	2017-01-23 18:14:13.53409
16896	2016-06-01 00:00:00	2016-08-31 18:59:59	10250	10030	10	2017-01-23 18:14:13.540167	2017-01-23 18:14:13.540167
16897	2016-06-01 00:00:00	2016-08-31 18:59:59	10250	10031	12	2017-01-23 18:14:13.545692	2017-01-23 18:14:13.545692
16898	2016-09-01 00:00:00	2016-12-31 18:59:59	10250	10030	12	2017-01-23 18:14:13.551726	2017-01-23 18:14:13.551726
16899	2016-09-01 00:00:00	2016-12-31 18:59:59	10250	10031	11	2017-01-23 18:14:13.557565	2017-01-23 18:14:13.557565
16900	2017-01-01 00:00:00	2099-12-31 18:59:59	10250	10030	11	2017-01-23 18:14:13.563753	2017-01-23 18:14:13.563753
16901	2017-01-01 00:00:00	2099-12-31 18:59:59	10250	10031	10	2017-01-23 18:14:13.568838	2017-01-23 18:14:13.568838
16902	2000-01-01 00:00:00	2016-05-31 18:59:59	10251	10030	10	2017-01-23 18:14:13.574188	2017-01-23 18:14:13.574188
16903	2000-01-01 00:00:00	2016-05-31 18:59:59	10251	10031	14	2017-01-23 18:14:13.579249	2017-01-23 18:14:13.579249
16904	2016-06-01 00:00:00	2016-08-31 18:59:59	10251	10030	13	2017-01-23 18:14:13.585178	2017-01-23 18:14:13.585178
16905	2016-06-01 00:00:00	2016-08-31 18:59:59	10251	10031	11	2017-01-23 18:14:13.590539	2017-01-23 18:14:13.590539
16906	2016-09-01 00:00:00	2016-12-31 18:59:59	10251	10030	10	2017-01-23 18:14:13.596673	2017-01-23 18:14:13.596673
16907	2016-09-01 00:00:00	2016-12-31 18:59:59	10251	10031	14	2017-01-23 18:14:13.601912	2017-01-23 18:14:13.601912
16908	2017-01-01 00:00:00	2099-12-31 18:59:59	10251	10030	11	2017-01-23 18:14:13.60815	2017-01-23 18:14:13.60815
16909	2017-01-01 00:00:00	2099-12-31 18:59:59	10251	10031	11	2017-01-23 18:14:13.613198	2017-01-23 18:14:13.613198
16910	2000-01-01 00:00:00	2016-05-31 18:59:59	10252	10030	10	2017-01-23 18:14:13.618852	2017-01-23 18:14:13.618852
16911	2000-01-01 00:00:00	2016-05-31 18:59:59	10252	10031	12	2017-01-23 18:14:13.623981	2017-01-23 18:14:13.623981
16912	2016-06-01 00:00:00	2016-08-31 18:59:59	10252	10030	10	2017-01-23 18:14:13.629465	2017-01-23 18:14:13.629465
16913	2016-06-01 00:00:00	2016-08-31 18:59:59	10252	10031	11	2017-01-23 18:14:13.634339	2017-01-23 18:14:13.634339
16914	2016-09-01 00:00:00	2016-12-31 18:59:59	10252	10030	10	2017-01-23 18:14:13.640303	2017-01-23 18:14:13.640303
16915	2016-09-01 00:00:00	2016-12-31 18:59:59	10252	10031	14	2017-01-23 18:14:13.645761	2017-01-23 18:14:13.645761
16916	2017-01-01 00:00:00	2099-12-31 18:59:59	10252	10030	12	2017-01-23 18:14:13.651645	2017-01-23 18:14:13.651645
16917	2017-01-01 00:00:00	2099-12-31 18:59:59	10252	10031	11	2017-01-23 18:14:13.6569	2017-01-23 18:14:13.6569
16918	2000-01-01 00:00:00	2016-05-31 18:59:59	10253	10030	14	2017-01-23 18:14:13.66226	2017-01-23 18:14:13.66226
16919	2000-01-01 00:00:00	2016-05-31 18:59:59	10253	10031	12	2017-01-23 18:14:13.666813	2017-01-23 18:14:13.666813
16920	2016-06-01 00:00:00	2016-08-31 18:59:59	10253	10030	14	2017-01-23 18:14:13.672786	2017-01-23 18:14:13.672786
16921	2016-06-01 00:00:00	2016-08-31 18:59:59	10253	10031	13	2017-01-23 18:14:13.678256	2017-01-23 18:14:13.678256
16922	2016-09-01 00:00:00	2016-12-31 18:59:59	10253	10030	11	2017-01-23 18:14:13.683873	2017-01-23 18:14:13.683873
16923	2016-09-01 00:00:00	2016-12-31 18:59:59	10253	10031	13	2017-01-23 18:14:13.689089	2017-01-23 18:14:13.689089
16924	2017-01-01 00:00:00	2099-12-31 18:59:59	10253	10030	11	2017-01-23 18:14:13.694805	2017-01-23 18:14:13.694805
16925	2017-01-01 00:00:00	2099-12-31 18:59:59	10253	10031	12	2017-01-23 18:14:13.700555	2017-01-23 18:14:13.700555
16926	2000-01-01 00:00:00	2016-05-31 18:59:59	10254	10030	10	2017-01-23 18:14:13.706789	2017-01-23 18:14:13.706789
16927	2000-01-01 00:00:00	2016-05-31 18:59:59	10254	10031	14	2017-01-23 18:14:13.711648	2017-01-23 18:14:13.711648
16928	2016-06-01 00:00:00	2016-08-31 18:59:59	10254	10030	14	2017-01-23 18:14:13.717558	2017-01-23 18:14:13.717558
16929	2016-06-01 00:00:00	2016-08-31 18:59:59	10254	10031	14	2017-01-23 18:14:13.723041	2017-01-23 18:14:13.723041
16930	2016-09-01 00:00:00	2016-12-31 18:59:59	10254	10030	11	2017-01-23 18:14:13.728545	2017-01-23 18:14:13.728545
16931	2016-09-01 00:00:00	2016-12-31 18:59:59	10254	10031	11	2017-01-23 18:14:13.733799	2017-01-23 18:14:13.733799
16932	2017-01-01 00:00:00	2099-12-31 18:59:59	10254	10030	12	2017-01-23 18:14:13.739723	2017-01-23 18:14:13.739723
16933	2017-01-01 00:00:00	2099-12-31 18:59:59	10254	10031	14	2017-01-23 18:14:13.745014	2017-01-23 18:14:13.745014
16934	2000-01-01 00:00:00	2016-05-31 18:59:59	10255	10030	10	2017-01-23 18:14:13.750621	2017-01-23 18:14:13.750621
16935	2000-01-01 00:00:00	2016-05-31 18:59:59	10255	10031	11	2017-01-23 18:14:13.755702	2017-01-23 18:14:13.755702
16936	2016-06-01 00:00:00	2016-08-31 18:59:59	10255	10030	12	2017-01-23 18:14:13.76159	2017-01-23 18:14:13.76159
16937	2016-06-01 00:00:00	2016-08-31 18:59:59	10255	10031	10	2017-01-23 18:14:13.767036	2017-01-23 18:14:13.767036
16938	2016-09-01 00:00:00	2016-12-31 18:59:59	10255	10030	12	2017-01-23 18:14:13.772913	2017-01-23 18:14:13.772913
16939	2016-09-01 00:00:00	2016-12-31 18:59:59	10255	10031	14	2017-01-23 18:14:13.777977	2017-01-23 18:14:13.777977
16940	2017-01-01 00:00:00	2099-12-31 18:59:59	10255	10030	11	2017-01-23 18:14:13.783515	2017-01-23 18:14:13.783515
16941	2017-01-01 00:00:00	2099-12-31 18:59:59	10255	10031	10	2017-01-23 18:14:13.788824	2017-01-23 18:14:13.788824
16942	2000-01-01 00:00:00	2016-05-31 18:59:59	10256	10030	13	2017-01-23 18:14:13.794794	2017-01-23 18:14:13.794794
16943	2000-01-01 00:00:00	2016-05-31 18:59:59	10256	10031	10	2017-01-23 18:14:13.799935	2017-01-23 18:14:13.799935
16944	2016-06-01 00:00:00	2016-08-31 18:59:59	10256	10030	12	2017-01-23 18:14:13.805654	2017-01-23 18:14:13.805654
16945	2016-06-01 00:00:00	2016-08-31 18:59:59	10256	10031	10	2017-01-23 18:14:13.810799	2017-01-23 18:14:13.810799
16946	2016-09-01 00:00:00	2016-12-31 18:59:59	10256	10030	14	2017-01-23 18:14:13.816434	2017-01-23 18:14:13.816434
16947	2016-09-01 00:00:00	2016-12-31 18:59:59	10256	10031	10	2017-01-23 18:14:13.821776	2017-01-23 18:14:13.821776
16948	2017-01-01 00:00:00	2099-12-31 18:59:59	10256	10030	10	2017-01-23 18:14:13.82754	2017-01-23 18:14:13.82754
16949	2017-01-01 00:00:00	2099-12-31 18:59:59	10256	10031	11	2017-01-23 18:14:13.832562	2017-01-23 18:14:13.832562
16950	2000-01-01 00:00:00	2016-05-31 18:59:59	10257	10030	13	2017-01-23 18:14:13.838863	2017-01-23 18:14:13.838863
16951	2000-01-01 00:00:00	2016-05-31 18:59:59	10257	10031	12	2017-01-23 18:14:13.844545	2017-01-23 18:14:13.844545
16952	2016-06-01 00:00:00	2016-08-31 18:59:59	10257	10030	11	2017-01-23 18:14:13.85002	2017-01-23 18:14:13.85002
16953	2016-06-01 00:00:00	2016-08-31 18:59:59	10257	10031	11	2017-01-23 18:14:13.854895	2017-01-23 18:14:13.854895
16954	2016-09-01 00:00:00	2016-12-31 18:59:59	10257	10030	14	2017-01-23 18:14:13.860637	2017-01-23 18:14:13.860637
16955	2016-09-01 00:00:00	2016-12-31 18:59:59	10257	10031	11	2017-01-23 18:14:13.866012	2017-01-23 18:14:13.866012
16956	2017-01-01 00:00:00	2099-12-31 18:59:59	10257	10030	12	2017-01-23 18:14:13.871846	2017-01-23 18:14:13.871846
16957	2017-01-01 00:00:00	2099-12-31 18:59:59	10257	10031	12	2017-01-23 18:14:13.876793	2017-01-23 18:14:13.876793
16958	2000-01-01 00:00:00	2016-05-31 18:59:59	10258	10030	12	2017-01-23 18:14:13.882516	2017-01-23 18:14:13.882516
16959	2000-01-01 00:00:00	2016-05-31 18:59:59	10258	10031	14	2017-01-23 18:14:13.887946	2017-01-23 18:14:13.887946
16960	2016-06-01 00:00:00	2016-08-31 18:59:59	10258	10030	13	2017-01-23 18:14:13.893602	2017-01-23 18:14:13.893602
16961	2016-06-01 00:00:00	2016-08-31 18:59:59	10258	10031	11	2017-01-23 18:14:13.898916	2017-01-23 18:14:13.898916
16962	2016-09-01 00:00:00	2016-12-31 18:59:59	10258	10030	14	2017-01-23 18:14:13.905048	2017-01-23 18:14:13.905048
16963	2016-09-01 00:00:00	2016-12-31 18:59:59	10258	10031	11	2017-01-23 18:14:13.910018	2017-01-23 18:14:13.910018
16964	2017-01-01 00:00:00	2099-12-31 18:59:59	10258	10030	11	2017-01-23 18:14:13.916704	2017-01-23 18:14:13.916704
16965	2017-01-01 00:00:00	2099-12-31 18:59:59	10258	10031	12	2017-01-23 18:14:13.922229	2017-01-23 18:14:13.922229
16966	2000-01-01 00:00:00	2016-05-31 18:59:59	10259	10030	11	2017-01-23 18:14:13.928845	2017-01-23 18:14:13.928845
16967	2000-01-01 00:00:00	2016-05-31 18:59:59	10259	10031	11	2017-01-23 18:14:13.934013	2017-01-23 18:14:13.934013
16968	2016-06-01 00:00:00	2016-08-31 18:59:59	10259	10030	11	2017-01-23 18:14:13.939607	2017-01-23 18:14:13.939607
16969	2016-06-01 00:00:00	2016-08-31 18:59:59	10259	10031	14	2017-01-23 18:14:13.945081	2017-01-23 18:14:13.945081
16970	2016-09-01 00:00:00	2016-12-31 18:59:59	10259	10030	10	2017-01-23 18:14:13.950797	2017-01-23 18:14:13.950797
16971	2016-09-01 00:00:00	2016-12-31 18:59:59	10259	10031	12	2017-01-23 18:14:13.95583	2017-01-23 18:14:13.95583
16972	2017-01-01 00:00:00	2099-12-31 18:59:59	10259	10030	14	2017-01-23 18:14:13.961736	2017-01-23 18:14:13.961736
16973	2017-01-01 00:00:00	2099-12-31 18:59:59	10259	10031	10	2017-01-23 18:14:13.966761	2017-01-23 18:14:13.966761
16974	2000-01-01 00:00:00	2016-05-31 18:59:59	10260	10030	11	2017-01-23 18:14:13.97237	2017-01-23 18:14:13.97237
16975	2000-01-01 00:00:00	2016-05-31 18:59:59	10260	10031	13	2017-01-23 18:14:13.97767	2017-01-23 18:14:13.97767
16976	2016-06-01 00:00:00	2016-08-31 18:59:59	10260	10030	11	2017-01-23 18:14:13.983403	2017-01-23 18:14:13.983403
16977	2016-06-01 00:00:00	2016-08-31 18:59:59	10260	10031	14	2017-01-23 18:14:13.989443	2017-01-23 18:14:13.989443
16978	2016-09-01 00:00:00	2016-12-31 18:59:59	10260	10030	12	2017-01-23 18:14:13.995269	2017-01-23 18:14:13.995269
16979	2016-09-01 00:00:00	2016-12-31 18:59:59	10260	10031	14	2017-01-23 18:14:14.000152	2017-01-23 18:14:14.000152
16980	2017-01-01 00:00:00	2099-12-31 18:59:59	10260	10030	14	2017-01-23 18:14:14.005831	2017-01-23 18:14:14.005831
16981	2017-01-01 00:00:00	2099-12-31 18:59:59	10260	10031	11	2017-01-23 18:14:14.010865	2017-01-23 18:14:14.010865
16982	2000-01-01 00:00:00	2016-05-31 18:59:59	10261	10030	12	2017-01-23 18:14:14.016601	2017-01-23 18:14:14.016601
16983	2000-01-01 00:00:00	2016-05-31 18:59:59	10261	10031	14	2017-01-23 18:14:14.021888	2017-01-23 18:14:14.021888
16984	2016-06-01 00:00:00	2016-08-31 18:59:59	10261	10030	14	2017-01-23 18:14:14.027677	2017-01-23 18:14:14.027677
16985	2016-06-01 00:00:00	2016-08-31 18:59:59	10261	10031	11	2017-01-23 18:14:14.033007	2017-01-23 18:14:14.033007
16986	2016-09-01 00:00:00	2016-12-31 18:59:59	10261	10030	14	2017-01-23 18:14:14.038895	2017-01-23 18:14:14.038895
16987	2016-09-01 00:00:00	2016-12-31 18:59:59	10261	10031	13	2017-01-23 18:14:14.043992	2017-01-23 18:14:14.043992
16988	2017-01-01 00:00:00	2099-12-31 18:59:59	10261	10030	10	2017-01-23 18:14:14.050148	2017-01-23 18:14:14.050148
16989	2017-01-01 00:00:00	2099-12-31 18:59:59	10261	10031	14	2017-01-23 18:14:14.055077	2017-01-23 18:14:14.055077
16990	2000-01-01 00:00:00	2016-05-31 18:59:59	10262	10030	11	2017-01-23 18:14:14.060907	2017-01-23 18:14:14.060907
16991	2000-01-01 00:00:00	2016-05-31 18:59:59	10262	10031	14	2017-01-23 18:14:14.065853	2017-01-23 18:14:14.065853
16992	2016-06-01 00:00:00	2016-08-31 18:59:59	10262	10030	13	2017-01-23 18:14:14.071869	2017-01-23 18:14:14.071869
16993	2016-06-01 00:00:00	2016-08-31 18:59:59	10262	10031	10	2017-01-23 18:14:14.077099	2017-01-23 18:14:14.077099
16994	2016-09-01 00:00:00	2016-12-31 18:59:59	10262	10030	13	2017-01-23 18:14:14.082693	2017-01-23 18:14:14.082693
16995	2016-09-01 00:00:00	2016-12-31 18:59:59	10262	10031	14	2017-01-23 18:14:14.087725	2017-01-23 18:14:14.087725
16996	2017-01-01 00:00:00	2099-12-31 18:59:59	10262	10030	10	2017-01-23 18:14:14.093179	2017-01-23 18:14:14.093179
16997	2017-01-01 00:00:00	2099-12-31 18:59:59	10262	10031	11	2017-01-23 18:14:14.098236	2017-01-23 18:14:14.098236
16998	2000-01-01 00:00:00	2016-05-31 18:59:59	10263	10030	12	2017-01-23 18:14:14.10401	2017-01-23 18:14:14.10401
16999	2000-01-01 00:00:00	2016-05-31 18:59:59	10263	10031	10	2017-01-23 18:14:14.109019	2017-01-23 18:14:14.109019
17000	2016-06-01 00:00:00	2016-08-31 18:59:59	10263	10030	14	2017-01-23 18:14:14.114759	2017-01-23 18:14:14.114759
17001	2016-06-01 00:00:00	2016-08-31 18:59:59	10263	10031	12	2017-01-23 18:14:14.119795	2017-01-23 18:14:14.119795
17002	2016-09-01 00:00:00	2016-12-31 18:59:59	10263	10030	11	2017-01-23 18:14:14.125751	2017-01-23 18:14:14.125751
17003	2016-09-01 00:00:00	2016-12-31 18:59:59	10263	10031	11	2017-01-23 18:14:14.131836	2017-01-23 18:14:14.131836
17004	2017-01-01 00:00:00	2099-12-31 18:59:59	10263	10030	12	2017-01-23 18:14:14.137437	2017-01-23 18:14:14.137437
17005	2017-01-01 00:00:00	2099-12-31 18:59:59	10263	10031	12	2017-01-23 18:14:14.142917	2017-01-23 18:14:14.142917
17006	2000-01-01 00:00:00	2016-05-31 18:59:59	10264	10030	13	2017-01-23 18:14:14.148564	2017-01-23 18:14:14.148564
17007	2000-01-01 00:00:00	2016-05-31 18:59:59	10264	10031	12	2017-01-23 18:14:14.154091	2017-01-23 18:14:14.154091
17008	2016-06-01 00:00:00	2016-08-31 18:59:59	10264	10030	10	2017-01-23 18:14:14.160836	2017-01-23 18:14:14.160836
17009	2016-06-01 00:00:00	2016-08-31 18:59:59	10264	10031	11	2017-01-23 18:14:14.166363	2017-01-23 18:14:14.166363
17010	2016-09-01 00:00:00	2016-12-31 18:59:59	10264	10030	12	2017-01-23 18:14:14.17266	2017-01-23 18:14:14.17266
17011	2016-09-01 00:00:00	2016-12-31 18:59:59	10264	10031	10	2017-01-23 18:14:14.178004	2017-01-23 18:14:14.178004
17012	2017-01-01 00:00:00	2099-12-31 18:59:59	10264	10030	11	2017-01-23 18:14:14.183748	2017-01-23 18:14:14.183748
17013	2017-01-01 00:00:00	2099-12-31 18:59:59	10264	10031	14	2017-01-23 18:14:14.189118	2017-01-23 18:14:14.189118
17014	2000-01-01 00:00:00	2016-05-31 18:59:59	10265	10030	12	2017-01-23 18:14:14.194907	2017-01-23 18:14:14.194907
17015	2000-01-01 00:00:00	2016-05-31 18:59:59	10265	10031	11	2017-01-23 18:14:14.20006	2017-01-23 18:14:14.20006
17016	2016-06-01 00:00:00	2016-08-31 18:59:59	10265	10030	11	2017-01-23 18:14:14.205793	2017-01-23 18:14:14.205793
17017	2016-06-01 00:00:00	2016-08-31 18:59:59	10265	10031	10	2017-01-23 18:14:14.210873	2017-01-23 18:14:14.210873
17018	2016-09-01 00:00:00	2016-12-31 18:59:59	10265	10030	14	2017-01-23 18:14:14.21636	2017-01-23 18:14:14.21636
17019	2016-09-01 00:00:00	2016-12-31 18:59:59	10265	10031	11	2017-01-23 18:14:14.221231	2017-01-23 18:14:14.221231
17020	2017-01-01 00:00:00	2099-12-31 18:59:59	10265	10030	14	2017-01-23 18:14:14.227139	2017-01-23 18:14:14.227139
17021	2017-01-01 00:00:00	2099-12-31 18:59:59	10265	10031	13	2017-01-23 18:14:14.231949	2017-01-23 18:14:14.231949
17022	2000-01-01 00:00:00	2016-05-31 18:59:59	10266	10030	13	2017-01-23 18:14:14.237764	2017-01-23 18:14:14.237764
17023	2000-01-01 00:00:00	2016-05-31 18:59:59	10266	10031	11	2017-01-23 18:14:14.242938	2017-01-23 18:14:14.242938
17024	2016-06-01 00:00:00	2016-08-31 18:59:59	10266	10030	14	2017-01-23 18:14:14.248671	2017-01-23 18:14:14.248671
17025	2016-06-01 00:00:00	2016-08-31 18:59:59	10266	10031	13	2017-01-23 18:14:14.253905	2017-01-23 18:14:14.253905
17026	2016-09-01 00:00:00	2016-12-31 18:59:59	10266	10030	10	2017-01-23 18:14:14.259958	2017-01-23 18:14:14.259958
17027	2016-09-01 00:00:00	2016-12-31 18:59:59	10266	10031	13	2017-01-23 18:14:14.264958	2017-01-23 18:14:14.264958
17028	2017-01-01 00:00:00	2099-12-31 18:59:59	10266	10030	12	2017-01-23 18:14:14.270687	2017-01-23 18:14:14.270687
17029	2017-01-01 00:00:00	2099-12-31 18:59:59	10266	10031	11	2017-01-23 18:14:14.276476	2017-01-23 18:14:14.276476
17030	2000-01-01 00:00:00	2016-05-31 18:59:59	10267	10030	10	2017-01-23 18:14:14.282535	2017-01-23 18:14:14.282535
17031	2000-01-01 00:00:00	2016-05-31 18:59:59	10267	10031	13	2017-01-23 18:14:14.288232	2017-01-23 18:14:14.288232
17032	2016-06-01 00:00:00	2016-08-31 18:59:59	10267	10030	11	2017-01-23 18:14:14.293943	2017-01-23 18:14:14.293943
17033	2016-06-01 00:00:00	2016-08-31 18:59:59	10267	10031	10	2017-01-23 18:14:14.299089	2017-01-23 18:14:14.299089
17034	2016-09-01 00:00:00	2016-12-31 18:59:59	10267	10030	10	2017-01-23 18:14:14.30468	2017-01-23 18:14:14.30468
17035	2016-09-01 00:00:00	2016-12-31 18:59:59	10267	10031	13	2017-01-23 18:14:14.30996	2017-01-23 18:14:14.30996
17036	2017-01-01 00:00:00	2099-12-31 18:59:59	10267	10030	12	2017-01-23 18:14:14.31566	2017-01-23 18:14:14.31566
17037	2017-01-01 00:00:00	2099-12-31 18:59:59	10267	10031	10	2017-01-23 18:14:14.320893	2017-01-23 18:14:14.320893
17038	2000-01-01 00:00:00	2016-05-31 18:59:59	10268	10030	12	2017-01-23 18:14:14.326587	2017-01-23 18:14:14.326587
17039	2000-01-01 00:00:00	2016-05-31 18:59:59	10268	10031	10	2017-01-23 18:14:14.331475	2017-01-23 18:14:14.331475
17040	2016-06-01 00:00:00	2016-08-31 18:59:59	10268	10030	11	2017-01-23 18:14:14.337276	2017-01-23 18:14:14.337276
17041	2016-06-01 00:00:00	2016-08-31 18:59:59	10268	10031	11	2017-01-23 18:14:14.342613	2017-01-23 18:14:14.342613
17042	2016-09-01 00:00:00	2016-12-31 18:59:59	10268	10030	13	2017-01-23 18:14:14.348444	2017-01-23 18:14:14.348444
17043	2016-09-01 00:00:00	2016-12-31 18:59:59	10268	10031	12	2017-01-23 18:14:14.353811	2017-01-23 18:14:14.353811
17044	2017-01-01 00:00:00	2099-12-31 18:59:59	10268	10030	14	2017-01-23 18:14:14.359547	2017-01-23 18:14:14.359547
17045	2017-01-01 00:00:00	2099-12-31 18:59:59	10268	10031	13	2017-01-23 18:14:14.364534	2017-01-23 18:14:14.364534
17046	2000-01-01 00:00:00	2016-05-31 18:59:59	10269	10030	13	2017-01-23 18:14:14.370603	2017-01-23 18:14:14.370603
17047	2000-01-01 00:00:00	2016-05-31 18:59:59	10269	10031	13	2017-01-23 18:14:14.375846	2017-01-23 18:14:14.375846
17048	2016-06-01 00:00:00	2016-08-31 18:59:59	10269	10030	11	2017-01-23 18:14:14.381553	2017-01-23 18:14:14.381553
17049	2016-06-01 00:00:00	2016-08-31 18:59:59	10269	10031	14	2017-01-23 18:14:14.387062	2017-01-23 18:14:14.387062
17050	2016-09-01 00:00:00	2016-12-31 18:59:59	10269	10030	13	2017-01-23 18:14:14.392801	2017-01-23 18:14:14.392801
17051	2016-09-01 00:00:00	2016-12-31 18:59:59	10269	10031	11	2017-01-23 18:14:14.397544	2017-01-23 18:14:14.397544
17052	2017-01-01 00:00:00	2099-12-31 18:59:59	10269	10030	12	2017-01-23 18:14:14.403501	2017-01-23 18:14:14.403501
17053	2017-01-01 00:00:00	2099-12-31 18:59:59	10269	10031	13	2017-01-23 18:14:14.409073	2017-01-23 18:14:14.409073
17054	2000-01-01 00:00:00	2016-05-31 18:59:59	10270	10030	13	2017-01-23 18:14:14.414865	2017-01-23 18:14:14.414865
17055	2000-01-01 00:00:00	2016-05-31 18:59:59	10270	10031	12	2017-01-23 18:14:14.420503	2017-01-23 18:14:14.420503
17056	2016-06-01 00:00:00	2016-08-31 18:59:59	10270	10030	12	2017-01-23 18:14:14.426247	2017-01-23 18:14:14.426247
17057	2016-06-01 00:00:00	2016-08-31 18:59:59	10270	10031	13	2017-01-23 18:14:14.431172	2017-01-23 18:14:14.431172
17058	2016-09-01 00:00:00	2016-12-31 18:59:59	10270	10030	13	2017-01-23 18:14:14.436854	2017-01-23 18:14:14.436854
17059	2016-09-01 00:00:00	2016-12-31 18:59:59	10270	10031	11	2017-01-23 18:14:14.441892	2017-01-23 18:14:14.441892
17060	2017-01-01 00:00:00	2099-12-31 18:59:59	10270	10030	13	2017-01-23 18:14:14.447585	2017-01-23 18:14:14.447585
17061	2017-01-01 00:00:00	2099-12-31 18:59:59	10270	10031	11	2017-01-23 18:14:14.452917	2017-01-23 18:14:14.452917
17062	2000-01-01 00:00:00	2016-05-31 18:59:59	10271	10030	11	2017-01-23 18:14:14.458606	2017-01-23 18:14:14.458606
17063	2000-01-01 00:00:00	2016-05-31 18:59:59	10271	10031	13	2017-01-23 18:14:14.463871	2017-01-23 18:14:14.463871
17064	2016-06-01 00:00:00	2016-08-31 18:59:59	10271	10030	12	2017-01-23 18:14:14.469974	2017-01-23 18:14:14.469974
17065	2016-06-01 00:00:00	2016-08-31 18:59:59	10271	10031	10	2017-01-23 18:14:14.474882	2017-01-23 18:14:14.474882
17066	2016-09-01 00:00:00	2016-12-31 18:59:59	10271	10030	14	2017-01-23 18:14:14.480499	2017-01-23 18:14:14.480499
17067	2016-09-01 00:00:00	2016-12-31 18:59:59	10271	10031	10	2017-01-23 18:14:14.485419	2017-01-23 18:14:14.485419
17068	2017-01-01 00:00:00	2099-12-31 18:59:59	10271	10030	11	2017-01-23 18:14:14.491773	2017-01-23 18:14:14.491773
17069	2017-01-01 00:00:00	2099-12-31 18:59:59	10271	10031	14	2017-01-23 18:14:14.496666	2017-01-23 18:14:14.496666
17070	2000-01-01 00:00:00	2016-05-31 18:59:59	10272	10030	11	2017-01-23 18:14:14.502511	2017-01-23 18:14:14.502511
17071	2000-01-01 00:00:00	2016-05-31 18:59:59	10272	10031	14	2017-01-23 18:14:14.507737	2017-01-23 18:14:14.507737
17072	2016-06-01 00:00:00	2016-08-31 18:59:59	10272	10030	12	2017-01-23 18:14:14.513347	2017-01-23 18:14:14.513347
17073	2016-06-01 00:00:00	2016-08-31 18:59:59	10272	10031	14	2017-01-23 18:14:14.518887	2017-01-23 18:14:14.518887
17074	2016-09-01 00:00:00	2016-12-31 18:59:59	10272	10030	14	2017-01-23 18:14:14.524574	2017-01-23 18:14:14.524574
17075	2016-09-01 00:00:00	2016-12-31 18:59:59	10272	10031	13	2017-01-23 18:14:14.529811	2017-01-23 18:14:14.529811
17076	2017-01-01 00:00:00	2099-12-31 18:59:59	10272	10030	12	2017-01-23 18:14:14.535721	2017-01-23 18:14:14.535721
17077	2017-01-01 00:00:00	2099-12-31 18:59:59	10272	10031	10	2017-01-23 18:14:14.540776	2017-01-23 18:14:14.540776
17078	2000-01-01 00:00:00	2016-05-31 18:59:59	10273	10030	12	2017-01-23 18:14:14.546314	2017-01-23 18:14:14.546314
17079	2000-01-01 00:00:00	2016-05-31 18:59:59	10273	10031	10	2017-01-23 18:14:14.551324	2017-01-23 18:14:14.551324
17080	2016-06-01 00:00:00	2016-08-31 18:59:59	10273	10030	14	2017-01-23 18:14:14.55712	2017-01-23 18:14:14.55712
17081	2016-06-01 00:00:00	2016-08-31 18:59:59	10273	10031	14	2017-01-23 18:14:14.562984	2017-01-23 18:14:14.562984
17082	2016-09-01 00:00:00	2016-12-31 18:59:59	10273	10030	13	2017-01-23 18:14:14.56879	2017-01-23 18:14:14.56879
17083	2016-09-01 00:00:00	2016-12-31 18:59:59	10273	10031	10	2017-01-23 18:14:14.574028	2017-01-23 18:14:14.574028
17084	2017-01-01 00:00:00	2099-12-31 18:59:59	10273	10030	12	2017-01-23 18:14:14.579969	2017-01-23 18:14:14.579969
17085	2017-01-01 00:00:00	2099-12-31 18:59:59	10273	10031	10	2017-01-23 18:14:14.585061	2017-01-23 18:14:14.585061
17086	2000-01-01 00:00:00	2016-05-31 18:59:59	10274	10030	12	2017-01-23 18:14:14.590818	2017-01-23 18:14:14.590818
17087	2000-01-01 00:00:00	2016-05-31 18:59:59	10274	10031	13	2017-01-23 18:14:14.595827	2017-01-23 18:14:14.595827
17088	2016-06-01 00:00:00	2016-08-31 18:59:59	10274	10030	14	2017-01-23 18:14:14.602014	2017-01-23 18:14:14.602014
17089	2016-06-01 00:00:00	2016-08-31 18:59:59	10274	10031	11	2017-01-23 18:14:14.607131	2017-01-23 18:14:14.607131
17090	2016-09-01 00:00:00	2016-12-31 18:59:59	10274	10030	13	2017-01-23 18:14:14.612956	2017-01-23 18:14:14.612956
17091	2016-09-01 00:00:00	2016-12-31 18:59:59	10274	10031	11	2017-01-23 18:14:14.618447	2017-01-23 18:14:14.618447
17092	2017-01-01 00:00:00	2099-12-31 18:59:59	10274	10030	12	2017-01-23 18:14:14.624309	2017-01-23 18:14:14.624309
17093	2017-01-01 00:00:00	2099-12-31 18:59:59	10274	10031	13	2017-01-23 18:14:14.629608	2017-01-23 18:14:14.629608
17094	2000-01-01 00:00:00	2016-05-31 18:59:59	10275	10030	14	2017-01-23 18:14:14.63542	2017-01-23 18:14:14.63542
17095	2000-01-01 00:00:00	2016-05-31 18:59:59	10275	10031	13	2017-01-23 18:14:14.640525	2017-01-23 18:14:14.640525
17096	2016-06-01 00:00:00	2016-08-31 18:59:59	10275	10030	10	2017-01-23 18:14:14.646281	2017-01-23 18:14:14.646281
17097	2016-06-01 00:00:00	2016-08-31 18:59:59	10275	10031	11	2017-01-23 18:14:14.651466	2017-01-23 18:14:14.651466
17098	2016-09-01 00:00:00	2016-12-31 18:59:59	10275	10030	12	2017-01-23 18:14:14.657599	2017-01-23 18:14:14.657599
17099	2016-09-01 00:00:00	2016-12-31 18:59:59	10275	10031	14	2017-01-23 18:14:14.662978	2017-01-23 18:14:14.662978
17100	2017-01-01 00:00:00	2099-12-31 18:59:59	10275	10030	11	2017-01-23 18:14:14.668821	2017-01-23 18:14:14.668821
17101	2017-01-01 00:00:00	2099-12-31 18:59:59	10275	10031	13	2017-01-23 18:14:14.673937	2017-01-23 18:14:14.673937
17102	2000-01-01 00:00:00	2016-05-31 18:59:59	10276	10030	13	2017-01-23 18:14:14.679696	2017-01-23 18:14:14.679696
17103	2000-01-01 00:00:00	2016-05-31 18:59:59	10276	10031	10	2017-01-23 18:14:14.684864	2017-01-23 18:14:14.684864
17104	2016-06-01 00:00:00	2016-08-31 18:59:59	10276	10030	11	2017-01-23 18:14:14.690641	2017-01-23 18:14:14.690641
17105	2016-06-01 00:00:00	2016-08-31 18:59:59	10276	10031	12	2017-01-23 18:14:14.69576	2017-01-23 18:14:14.69576
17106	2016-09-01 00:00:00	2016-12-31 18:59:59	10276	10030	11	2017-01-23 18:14:14.701661	2017-01-23 18:14:14.701661
17107	2016-09-01 00:00:00	2016-12-31 18:59:59	10276	10031	13	2017-01-23 18:14:14.707727	2017-01-23 18:14:14.707727
17108	2017-01-01 00:00:00	2099-12-31 18:59:59	10276	10030	10	2017-01-23 18:14:14.71378	2017-01-23 18:14:14.71378
17109	2017-01-01 00:00:00	2099-12-31 18:59:59	10276	10031	13	2017-01-23 18:14:14.718719	2017-01-23 18:14:14.718719
17110	2000-01-01 00:00:00	2016-05-31 18:59:59	10277	10030	11	2017-01-23 18:14:14.724648	2017-01-23 18:14:14.724648
17111	2000-01-01 00:00:00	2016-05-31 18:59:59	10277	10031	14	2017-01-23 18:14:14.729642	2017-01-23 18:14:14.729642
17112	2016-06-01 00:00:00	2016-08-31 18:59:59	10277	10030	12	2017-01-23 18:14:14.735868	2017-01-23 18:14:14.735868
17113	2016-06-01 00:00:00	2016-08-31 18:59:59	10277	10031	12	2017-01-23 18:14:14.741158	2017-01-23 18:14:14.741158
17114	2016-09-01 00:00:00	2016-12-31 18:59:59	10277	10030	11	2017-01-23 18:14:14.746814	2017-01-23 18:14:14.746814
17115	2016-09-01 00:00:00	2016-12-31 18:59:59	10277	10031	11	2017-01-23 18:14:14.751949	2017-01-23 18:14:14.751949
17116	2017-01-01 00:00:00	2099-12-31 18:59:59	10277	10030	11	2017-01-23 18:14:14.757691	2017-01-23 18:14:14.757691
17117	2017-01-01 00:00:00	2099-12-31 18:59:59	10277	10031	12	2017-01-23 18:14:14.762575	2017-01-23 18:14:14.762575
17118	2000-01-01 00:00:00	2016-05-31 18:59:59	10278	10030	12	2017-01-23 18:14:14.768558	2017-01-23 18:14:14.768558
17119	2000-01-01 00:00:00	2016-05-31 18:59:59	10278	10031	14	2017-01-23 18:14:14.773983	2017-01-23 18:14:14.773983
17120	2016-06-01 00:00:00	2016-08-31 18:59:59	10278	10030	14	2017-01-23 18:14:14.779931	2017-01-23 18:14:14.779931
17121	2016-06-01 00:00:00	2016-08-31 18:59:59	10278	10031	14	2017-01-23 18:14:14.784808	2017-01-23 18:14:14.784808
17122	2016-09-01 00:00:00	2016-12-31 18:59:59	10278	10030	14	2017-01-23 18:14:14.79055	2017-01-23 18:14:14.79055
17123	2016-09-01 00:00:00	2016-12-31 18:59:59	10278	10031	10	2017-01-23 18:14:14.79558	2017-01-23 18:14:14.79558
17124	2017-01-01 00:00:00	2099-12-31 18:59:59	10278	10030	14	2017-01-23 18:14:14.801344	2017-01-23 18:14:14.801344
17125	2017-01-01 00:00:00	2099-12-31 18:59:59	10278	10031	13	2017-01-23 18:14:14.806551	2017-01-23 18:14:14.806551
17126	2000-01-01 00:00:00	2016-05-31 18:59:59	10279	10030	10	2017-01-23 18:14:14.812473	2017-01-23 18:14:14.812473
17127	2000-01-01 00:00:00	2016-05-31 18:59:59	10279	10031	14	2017-01-23 18:14:14.817741	2017-01-23 18:14:14.817741
17128	2016-06-01 00:00:00	2016-08-31 18:59:59	10279	10030	11	2017-01-23 18:14:14.823692	2017-01-23 18:14:14.823692
17129	2016-06-01 00:00:00	2016-08-31 18:59:59	10279	10031	11	2017-01-23 18:14:14.82883	2017-01-23 18:14:14.82883
17130	2016-09-01 00:00:00	2016-12-31 18:59:59	10279	10030	12	2017-01-23 18:14:14.83455	2017-01-23 18:14:14.83455
17131	2016-09-01 00:00:00	2016-12-31 18:59:59	10279	10031	11	2017-01-23 18:14:14.840244	2017-01-23 18:14:14.840244
17132	2017-01-01 00:00:00	2099-12-31 18:59:59	10279	10030	13	2017-01-23 18:14:14.845715	2017-01-23 18:14:14.845715
17133	2017-01-01 00:00:00	2099-12-31 18:59:59	10279	10031	14	2017-01-23 18:14:14.851435	2017-01-23 18:14:14.851435
17134	2000-01-01 00:00:00	2016-05-31 18:59:59	10280	10030	10	2017-01-23 18:14:14.857809	2017-01-23 18:14:14.857809
17135	2000-01-01 00:00:00	2016-05-31 18:59:59	10280	10031	10	2017-01-23 18:14:14.863168	2017-01-23 18:14:14.863168
17136	2016-06-01 00:00:00	2016-08-31 18:59:59	10280	10030	12	2017-01-23 18:14:14.868709	2017-01-23 18:14:14.868709
17137	2016-06-01 00:00:00	2016-08-31 18:59:59	10280	10031	10	2017-01-23 18:14:14.873889	2017-01-23 18:14:14.873889
17138	2016-09-01 00:00:00	2016-12-31 18:59:59	10280	10030	13	2017-01-23 18:14:14.879743	2017-01-23 18:14:14.879743
17139	2016-09-01 00:00:00	2016-12-31 18:59:59	10280	10031	14	2017-01-23 18:14:14.884804	2017-01-23 18:14:14.884804
17140	2017-01-01 00:00:00	2099-12-31 18:59:59	10280	10030	11	2017-01-23 18:14:14.890742	2017-01-23 18:14:14.890742
17141	2017-01-01 00:00:00	2099-12-31 18:59:59	10280	10031	12	2017-01-23 18:14:14.895944	2017-01-23 18:14:14.895944
17142	2000-01-01 00:00:00	2016-05-31 18:59:59	10281	10030	14	2017-01-23 18:14:14.901732	2017-01-23 18:14:14.901732
17143	2000-01-01 00:00:00	2016-05-31 18:59:59	10281	10031	10	2017-01-23 18:14:14.907253	2017-01-23 18:14:14.907253
17144	2016-06-01 00:00:00	2016-08-31 18:59:59	10281	10030	12	2017-01-23 18:14:14.913061	2017-01-23 18:14:14.913061
17145	2016-06-01 00:00:00	2016-08-31 18:59:59	10281	10031	11	2017-01-23 18:14:14.918736	2017-01-23 18:14:14.918736
17146	2016-09-01 00:00:00	2016-12-31 18:59:59	10281	10030	10	2017-01-23 18:14:14.924623	2017-01-23 18:14:14.924623
17147	2016-09-01 00:00:00	2016-12-31 18:59:59	10281	10031	12	2017-01-23 18:14:14.929924	2017-01-23 18:14:14.929924
17148	2017-01-01 00:00:00	2099-12-31 18:59:59	10281	10030	14	2017-01-23 18:14:14.93538	2017-01-23 18:14:14.93538
17149	2017-01-01 00:00:00	2099-12-31 18:59:59	10281	10031	10	2017-01-23 18:14:14.942191	2017-01-23 18:14:14.942191
17150	2000-01-01 00:00:00	2016-05-31 18:59:59	10282	10030	10	2017-01-23 18:14:14.955118	2017-01-23 18:14:14.955118
17151	2000-01-01 00:00:00	2016-05-31 18:59:59	10282	10031	13	2017-01-23 18:14:14.967156	2017-01-23 18:14:14.967156
17152	2016-06-01 00:00:00	2016-08-31 18:59:59	10282	10030	10	2017-01-23 18:14:14.975628	2017-01-23 18:14:14.975628
17153	2016-06-01 00:00:00	2016-08-31 18:59:59	10282	10031	10	2017-01-23 18:14:14.982201	2017-01-23 18:14:14.982201
17154	2016-09-01 00:00:00	2016-12-31 18:59:59	10282	10030	13	2017-01-23 18:14:14.98834	2017-01-23 18:14:14.98834
17155	2016-09-01 00:00:00	2016-12-31 18:59:59	10282	10031	12	2017-01-23 18:14:14.993635	2017-01-23 18:14:14.993635
17156	2017-01-01 00:00:00	2099-12-31 18:59:59	10282	10030	13	2017-01-23 18:14:14.99999	2017-01-23 18:14:14.99999
17157	2017-01-01 00:00:00	2099-12-31 18:59:59	10282	10031	12	2017-01-23 18:14:15.005167	2017-01-23 18:14:15.005167
17158	2000-01-01 00:00:00	2016-05-31 18:59:59	10283	10030	11	2017-01-23 18:14:15.010846	2017-01-23 18:14:15.010846
17159	2000-01-01 00:00:00	2016-05-31 18:59:59	10283	10031	14	2017-01-23 18:14:15.016787	2017-01-23 18:14:15.016787
17160	2016-06-01 00:00:00	2016-08-31 18:59:59	10283	10030	12	2017-01-23 18:14:15.022649	2017-01-23 18:14:15.022649
17161	2016-06-01 00:00:00	2016-08-31 18:59:59	10283	10031	10	2017-01-23 18:14:15.027534	2017-01-23 18:14:15.027534
17162	2016-09-01 00:00:00	2016-12-31 18:59:59	10283	10030	13	2017-01-23 18:14:15.033341	2017-01-23 18:14:15.033341
17163	2016-09-01 00:00:00	2016-12-31 18:59:59	10283	10031	14	2017-01-23 18:14:15.038544	2017-01-23 18:14:15.038544
17164	2017-01-01 00:00:00	2099-12-31 18:59:59	10283	10030	14	2017-01-23 18:14:15.044054	2017-01-23 18:14:15.044054
17165	2017-01-01 00:00:00	2099-12-31 18:59:59	10283	10031	10	2017-01-23 18:14:15.049446	2017-01-23 18:14:15.049446
17166	2000-01-01 00:00:00	2016-05-31 18:59:59	10284	10030	11	2017-01-23 18:14:15.055307	2017-01-23 18:14:15.055307
17167	2000-01-01 00:00:00	2016-05-31 18:59:59	10284	10031	12	2017-01-23 18:14:15.06039	2017-01-23 18:14:15.06039
17168	2016-06-01 00:00:00	2016-08-31 18:59:59	10284	10030	12	2017-01-23 18:14:15.065899	2017-01-23 18:14:15.065899
17169	2016-06-01 00:00:00	2016-08-31 18:59:59	10284	10031	11	2017-01-23 18:14:15.071212	2017-01-23 18:14:15.071212
17170	2016-09-01 00:00:00	2016-12-31 18:59:59	10284	10030	11	2017-01-23 18:14:15.076869	2017-01-23 18:14:15.076869
17171	2016-09-01 00:00:00	2016-12-31 18:59:59	10284	10031	10	2017-01-23 18:14:15.081807	2017-01-23 18:14:15.081807
17172	2017-01-01 00:00:00	2099-12-31 18:59:59	10284	10030	11	2017-01-23 18:14:15.087514	2017-01-23 18:14:15.087514
17173	2017-01-01 00:00:00	2099-12-31 18:59:59	10284	10031	10	2017-01-23 18:14:15.092951	2017-01-23 18:14:15.092951
17174	2000-01-01 00:00:00	2016-05-31 18:59:59	10285	10030	13	2017-01-23 18:14:15.098461	2017-01-23 18:14:15.098461
17175	2000-01-01 00:00:00	2016-05-31 18:59:59	10285	10031	13	2017-01-23 18:14:15.103941	2017-01-23 18:14:15.103941
17176	2016-06-01 00:00:00	2016-08-31 18:59:59	10285	10030	12	2017-01-23 18:14:15.109591	2017-01-23 18:14:15.109591
17177	2016-06-01 00:00:00	2016-08-31 18:59:59	10285	10031	14	2017-01-23 18:14:15.11482	2017-01-23 18:14:15.11482
17178	2016-09-01 00:00:00	2016-12-31 18:59:59	10285	10030	10	2017-01-23 18:14:15.120747	2017-01-23 18:14:15.120747
17179	2016-09-01 00:00:00	2016-12-31 18:59:59	10285	10031	13	2017-01-23 18:14:15.125974	2017-01-23 18:14:15.125974
17180	2017-01-01 00:00:00	2099-12-31 18:59:59	10285	10030	12	2017-01-23 18:14:15.131951	2017-01-23 18:14:15.131951
17181	2017-01-01 00:00:00	2099-12-31 18:59:59	10285	10031	12	2017-01-23 18:14:15.136886	2017-01-23 18:14:15.136886
17182	2000-01-01 00:00:00	2016-05-31 18:59:59	10286	10030	10	2017-01-23 18:14:15.14276	2017-01-23 18:14:15.14276
17183	2000-01-01 00:00:00	2016-05-31 18:59:59	10286	10031	11	2017-01-23 18:14:15.148038	2017-01-23 18:14:15.148038
17184	2016-06-01 00:00:00	2016-08-31 18:59:59	10286	10030	14	2017-01-23 18:14:15.154148	2017-01-23 18:14:15.154148
17185	2016-06-01 00:00:00	2016-08-31 18:59:59	10286	10031	14	2017-01-23 18:14:15.159781	2017-01-23 18:14:15.159781
17186	2016-09-01 00:00:00	2016-12-31 18:59:59	10286	10030	14	2017-01-23 18:14:15.16514	2017-01-23 18:14:15.16514
17187	2016-09-01 00:00:00	2016-12-31 18:59:59	10286	10031	12	2017-01-23 18:14:15.170122	2017-01-23 18:14:15.170122
17188	2017-01-01 00:00:00	2099-12-31 18:59:59	10286	10030	10	2017-01-23 18:14:15.17587	2017-01-23 18:14:15.17587
17189	2017-01-01 00:00:00	2099-12-31 18:59:59	10286	10031	10	2017-01-23 18:14:15.181212	2017-01-23 18:14:15.181212
17190	2000-01-01 00:00:00	2016-05-31 18:59:59	10287	10030	11	2017-01-23 18:14:15.186727	2017-01-23 18:14:15.186727
17191	2000-01-01 00:00:00	2016-05-31 18:59:59	10287	10031	14	2017-01-23 18:14:15.192231	2017-01-23 18:14:15.192231
17192	2016-06-01 00:00:00	2016-08-31 18:59:59	10287	10030	12	2017-01-23 18:14:15.197783	2017-01-23 18:14:15.197783
17193	2016-06-01 00:00:00	2016-08-31 18:59:59	10287	10031	13	2017-01-23 18:14:15.203066	2017-01-23 18:14:15.203066
17194	2016-09-01 00:00:00	2016-12-31 18:59:59	10287	10030	10	2017-01-23 18:14:15.208758	2017-01-23 18:14:15.208758
17195	2016-09-01 00:00:00	2016-12-31 18:59:59	10287	10031	11	2017-01-23 18:14:15.213655	2017-01-23 18:14:15.213655
17196	2017-01-01 00:00:00	2099-12-31 18:59:59	10287	10030	11	2017-01-23 18:14:15.219531	2017-01-23 18:14:15.219531
17197	2017-01-01 00:00:00	2099-12-31 18:59:59	10287	10031	11	2017-01-23 18:14:15.224888	2017-01-23 18:14:15.224888
17198	2000-01-01 00:00:00	2016-05-31 18:59:59	10288	10030	12	2017-01-23 18:14:15.23068	2017-01-23 18:14:15.23068
17199	2000-01-01 00:00:00	2016-05-31 18:59:59	10288	10031	10	2017-01-23 18:14:15.23588	2017-01-23 18:14:15.23588
17200	2016-06-01 00:00:00	2016-08-31 18:59:59	10288	10030	10	2017-01-23 18:14:15.241582	2017-01-23 18:14:15.241582
17201	2016-06-01 00:00:00	2016-08-31 18:59:59	10288	10031	12	2017-01-23 18:14:15.246566	2017-01-23 18:14:15.246566
17202	2016-09-01 00:00:00	2016-12-31 18:59:59	10288	10030	13	2017-01-23 18:14:15.252213	2017-01-23 18:14:15.252213
17203	2016-09-01 00:00:00	2016-12-31 18:59:59	10288	10031	13	2017-01-23 18:14:15.257166	2017-01-23 18:14:15.257166
17204	2017-01-01 00:00:00	2099-12-31 18:59:59	10288	10030	14	2017-01-23 18:14:15.263014	2017-01-23 18:14:15.263014
17205	2017-01-01 00:00:00	2099-12-31 18:59:59	10288	10031	13	2017-01-23 18:14:15.267924	2017-01-23 18:14:15.267924
17206	2000-01-01 00:00:00	2016-05-31 18:59:59	10289	10030	11	2017-01-23 18:14:15.273667	2017-01-23 18:14:15.273667
17207	2000-01-01 00:00:00	2016-05-31 18:59:59	10289	10031	11	2017-01-23 18:14:15.279018	2017-01-23 18:14:15.279018
17208	2016-06-01 00:00:00	2016-08-31 18:59:59	10289	10030	13	2017-01-23 18:14:15.285219	2017-01-23 18:14:15.285219
17209	2016-06-01 00:00:00	2016-08-31 18:59:59	10289	10031	13	2017-01-23 18:14:15.290324	2017-01-23 18:14:15.290324
17210	2016-09-01 00:00:00	2016-12-31 18:59:59	10289	10030	13	2017-01-23 18:14:15.29683	2017-01-23 18:14:15.29683
17211	2016-09-01 00:00:00	2016-12-31 18:59:59	10289	10031	12	2017-01-23 18:14:15.302014	2017-01-23 18:14:15.302014
17212	2017-01-01 00:00:00	2099-12-31 18:59:59	10289	10030	13	2017-01-23 18:14:15.307774	2017-01-23 18:14:15.307774
17213	2017-01-01 00:00:00	2099-12-31 18:59:59	10289	10031	14	2017-01-23 18:14:15.312789	2017-01-23 18:14:15.312789
17214	2000-01-01 00:00:00	2016-05-31 18:59:59	10290	10030	13	2017-01-23 18:14:15.318436	2017-01-23 18:14:15.318436
17215	2000-01-01 00:00:00	2016-05-31 18:59:59	10290	10031	12	2017-01-23 18:14:15.32403	2017-01-23 18:14:15.32403
17216	2016-06-01 00:00:00	2016-08-31 18:59:59	10290	10030	13	2017-01-23 18:14:15.329865	2017-01-23 18:14:15.329865
17217	2016-06-01 00:00:00	2016-08-31 18:59:59	10290	10031	14	2017-01-23 18:14:15.33507	2017-01-23 18:14:15.33507
17218	2016-09-01 00:00:00	2016-12-31 18:59:59	10290	10030	13	2017-01-23 18:14:15.340843	2017-01-23 18:14:15.340843
17219	2016-09-01 00:00:00	2016-12-31 18:59:59	10290	10031	12	2017-01-23 18:14:15.345797	2017-01-23 18:14:15.345797
17220	2017-01-01 00:00:00	2099-12-31 18:59:59	10290	10030	10	2017-01-23 18:14:15.352013	2017-01-23 18:14:15.352013
17221	2017-01-01 00:00:00	2099-12-31 18:59:59	10290	10031	10	2017-01-23 18:14:15.357115	2017-01-23 18:14:15.357115
17222	2000-01-01 00:00:00	2016-05-31 18:59:59	10291	10030	11	2017-01-23 18:14:15.362706	2017-01-23 18:14:15.362706
17223	2000-01-01 00:00:00	2016-05-31 18:59:59	10291	10031	13	2017-01-23 18:14:15.367731	2017-01-23 18:14:15.367731
17224	2016-06-01 00:00:00	2016-08-31 18:59:59	10291	10030	11	2017-01-23 18:14:15.373271	2017-01-23 18:14:15.373271
17225	2016-06-01 00:00:00	2016-08-31 18:59:59	10291	10031	13	2017-01-23 18:14:15.378665	2017-01-23 18:14:15.378665
17226	2016-09-01 00:00:00	2016-12-31 18:59:59	10291	10030	11	2017-01-23 18:14:15.384706	2017-01-23 18:14:15.384706
17227	2016-09-01 00:00:00	2016-12-31 18:59:59	10291	10031	12	2017-01-23 18:14:15.389838	2017-01-23 18:14:15.389838
17228	2017-01-01 00:00:00	2099-12-31 18:59:59	10291	10030	10	2017-01-23 18:14:15.39568	2017-01-23 18:14:15.39568
17229	2017-01-01 00:00:00	2099-12-31 18:59:59	10291	10031	11	2017-01-23 18:14:15.401071	2017-01-23 18:14:15.401071
17230	2000-01-01 00:00:00	2016-05-31 18:59:59	10292	10030	13	2017-01-23 18:14:15.40701	2017-01-23 18:14:15.40701
17231	2000-01-01 00:00:00	2016-05-31 18:59:59	10292	10031	14	2017-01-23 18:14:15.412172	2017-01-23 18:14:15.412172
17232	2016-06-01 00:00:00	2016-08-31 18:59:59	10292	10030	14	2017-01-23 18:14:15.4178	2017-01-23 18:14:15.4178
17233	2016-06-01 00:00:00	2016-08-31 18:59:59	10292	10031	11	2017-01-23 18:14:15.422464	2017-01-23 18:14:15.422464
17234	2016-09-01 00:00:00	2016-12-31 18:59:59	10292	10030	13	2017-01-23 18:14:15.428184	2017-01-23 18:14:15.428184
17235	2016-09-01 00:00:00	2016-12-31 18:59:59	10292	10031	13	2017-01-23 18:14:15.433285	2017-01-23 18:14:15.433285
17236	2017-01-01 00:00:00	2099-12-31 18:59:59	10292	10030	10	2017-01-23 18:14:15.439579	2017-01-23 18:14:15.439579
17237	2017-01-01 00:00:00	2099-12-31 18:59:59	10292	10031	11	2017-01-23 18:14:15.445039	2017-01-23 18:14:15.445039
17238	2000-01-01 00:00:00	2016-05-31 18:59:59	10293	10030	10	2017-01-23 18:14:15.4506	2017-01-23 18:14:15.4506
17239	2000-01-01 00:00:00	2016-05-31 18:59:59	10293	10031	13	2017-01-23 18:14:15.455702	2017-01-23 18:14:15.455702
17240	2016-06-01 00:00:00	2016-08-31 18:59:59	10293	10030	13	2017-01-23 18:14:15.46159	2017-01-23 18:14:15.46159
17241	2016-06-01 00:00:00	2016-08-31 18:59:59	10293	10031	12	2017-01-23 18:14:15.467232	2017-01-23 18:14:15.467232
17242	2016-09-01 00:00:00	2016-12-31 18:59:59	10293	10030	13	2017-01-23 18:14:15.473312	2017-01-23 18:14:15.473312
17243	2016-09-01 00:00:00	2016-12-31 18:59:59	10293	10031	10	2017-01-23 18:14:15.478168	2017-01-23 18:14:15.478168
17244	2017-01-01 00:00:00	2099-12-31 18:59:59	10293	10030	14	2017-01-23 18:14:15.483664	2017-01-23 18:14:15.483664
17245	2017-01-01 00:00:00	2099-12-31 18:59:59	10293	10031	11	2017-01-23 18:14:15.488741	2017-01-23 18:14:15.488741
17246	2000-01-01 00:00:00	2016-05-31 18:59:59	10294	10030	13	2017-01-23 18:14:15.494582	2017-01-23 18:14:15.494582
17247	2000-01-01 00:00:00	2016-05-31 18:59:59	10294	10031	13	2017-01-23 18:14:15.499882	2017-01-23 18:14:15.499882
17248	2016-06-01 00:00:00	2016-08-31 18:59:59	10294	10030	12	2017-01-23 18:14:15.50591	2017-01-23 18:14:15.50591
17249	2016-06-01 00:00:00	2016-08-31 18:59:59	10294	10031	11	2017-01-23 18:14:15.510845	2017-01-23 18:14:15.510845
17250	2016-09-01 00:00:00	2016-12-31 18:59:59	10294	10030	10	2017-01-23 18:14:15.5162	2017-01-23 18:14:15.5162
17251	2016-09-01 00:00:00	2016-12-31 18:59:59	10294	10031	11	2017-01-23 18:14:15.521113	2017-01-23 18:14:15.521113
17252	2017-01-01 00:00:00	2099-12-31 18:59:59	10294	10030	10	2017-01-23 18:14:15.527066	2017-01-23 18:14:15.527066
17253	2017-01-01 00:00:00	2099-12-31 18:59:59	10294	10031	12	2017-01-23 18:14:15.532065	2017-01-23 18:14:15.532065
17254	2000-01-01 00:00:00	2016-05-31 18:59:59	10295	10030	11	2017-01-23 18:14:15.537802	2017-01-23 18:14:15.537802
17255	2000-01-01 00:00:00	2016-05-31 18:59:59	10295	10031	14	2017-01-23 18:14:15.54295	2017-01-23 18:14:15.54295
17256	2016-06-01 00:00:00	2016-08-31 18:59:59	10295	10030	14	2017-01-23 18:14:15.548733	2017-01-23 18:14:15.548733
17257	2016-06-01 00:00:00	2016-08-31 18:59:59	10295	10031	10	2017-01-23 18:14:15.554029	2017-01-23 18:14:15.554029
17258	2016-09-01 00:00:00	2016-12-31 18:59:59	10295	10030	10	2017-01-23 18:14:15.559952	2017-01-23 18:14:15.559952
17259	2016-09-01 00:00:00	2016-12-31 18:59:59	10295	10031	12	2017-01-23 18:14:15.564996	2017-01-23 18:14:15.564996
17260	2017-01-01 00:00:00	2099-12-31 18:59:59	10295	10030	13	2017-01-23 18:14:15.570607	2017-01-23 18:14:15.570607
17261	2017-01-01 00:00:00	2099-12-31 18:59:59	10295	10031	14	2017-01-23 18:14:15.576218	2017-01-23 18:14:15.576218
17262	2000-01-01 00:00:00	2016-05-31 18:59:59	10296	10030	12	2017-01-23 18:14:15.582373	2017-01-23 18:14:15.582373
17263	2000-01-01 00:00:00	2016-05-31 18:59:59	10296	10031	14	2017-01-23 18:14:15.587972	2017-01-23 18:14:15.587972
17264	2016-06-01 00:00:00	2016-08-31 18:59:59	10296	10030	14	2017-01-23 18:14:15.593811	2017-01-23 18:14:15.593811
17265	2016-06-01 00:00:00	2016-08-31 18:59:59	10296	10031	10	2017-01-23 18:14:15.598891	2017-01-23 18:14:15.598891
17266	2016-09-01 00:00:00	2016-12-31 18:59:59	10296	10030	13	2017-01-23 18:14:15.605244	2017-01-23 18:14:15.605244
17267	2016-09-01 00:00:00	2016-12-31 18:59:59	10296	10031	12	2017-01-23 18:14:15.610378	2017-01-23 18:14:15.610378
17268	2017-01-01 00:00:00	2099-12-31 18:59:59	10296	10030	14	2017-01-23 18:14:15.616379	2017-01-23 18:14:15.616379
17269	2017-01-01 00:00:00	2099-12-31 18:59:59	10296	10031	11	2017-01-23 18:14:15.621095	2017-01-23 18:14:15.621095
17270	2000-01-01 00:00:00	2016-05-31 18:59:59	10297	10030	10	2017-01-23 18:14:15.627362	2017-01-23 18:14:15.627362
17271	2000-01-01 00:00:00	2016-05-31 18:59:59	10297	10031	10	2017-01-23 18:14:15.632872	2017-01-23 18:14:15.632872
17272	2016-06-01 00:00:00	2016-08-31 18:59:59	10297	10030	14	2017-01-23 18:14:15.638685	2017-01-23 18:14:15.638685
17273	2016-06-01 00:00:00	2016-08-31 18:59:59	10297	10031	12	2017-01-23 18:14:15.644057	2017-01-23 18:14:15.644057
17274	2016-09-01 00:00:00	2016-12-31 18:59:59	10297	10030	13	2017-01-23 18:14:15.649975	2017-01-23 18:14:15.649975
17275	2016-09-01 00:00:00	2016-12-31 18:59:59	10297	10031	12	2017-01-23 18:14:15.654775	2017-01-23 18:14:15.654775
17276	2017-01-01 00:00:00	2099-12-31 18:59:59	10297	10030	14	2017-01-23 18:14:15.661049	2017-01-23 18:14:15.661049
17277	2017-01-01 00:00:00	2099-12-31 18:59:59	10297	10031	13	2017-01-23 18:14:15.666671	2017-01-23 18:14:15.666671
17278	2000-01-01 00:00:00	2016-05-31 18:59:59	10298	10030	14	2017-01-23 18:14:15.672443	2017-01-23 18:14:15.672443
17279	2000-01-01 00:00:00	2016-05-31 18:59:59	10298	10031	10	2017-01-23 18:14:15.677628	2017-01-23 18:14:15.677628
17280	2016-06-01 00:00:00	2016-08-31 18:59:59	10298	10030	14	2017-01-23 18:14:15.683593	2017-01-23 18:14:15.683593
17281	2016-06-01 00:00:00	2016-08-31 18:59:59	10298	10031	11	2017-01-23 18:14:15.688821	2017-01-23 18:14:15.688821
17282	2016-09-01 00:00:00	2016-12-31 18:59:59	10298	10030	11	2017-01-23 18:14:15.694733	2017-01-23 18:14:15.694733
17283	2016-09-01 00:00:00	2016-12-31 18:59:59	10298	10031	13	2017-01-23 18:14:15.700086	2017-01-23 18:14:15.700086
17284	2017-01-01 00:00:00	2099-12-31 18:59:59	10298	10030	14	2017-01-23 18:14:15.705995	2017-01-23 18:14:15.705995
17285	2017-01-01 00:00:00	2099-12-31 18:59:59	10298	10031	14	2017-01-23 18:14:15.711268	2017-01-23 18:14:15.711268
17286	2000-01-01 00:00:00	2016-05-31 18:59:59	10299	10030	12	2017-01-23 18:14:15.716981	2017-01-23 18:14:15.716981
17287	2000-01-01 00:00:00	2016-05-31 18:59:59	10299	10031	12	2017-01-23 18:14:15.722892	2017-01-23 18:14:15.722892
17288	2016-06-01 00:00:00	2016-08-31 18:59:59	10299	10030	10	2017-01-23 18:14:15.728739	2017-01-23 18:14:15.728739
17289	2016-06-01 00:00:00	2016-08-31 18:59:59	10299	10031	12	2017-01-23 18:14:15.73392	2017-01-23 18:14:15.73392
17290	2016-09-01 00:00:00	2016-12-31 18:59:59	10299	10030	12	2017-01-23 18:14:15.739597	2017-01-23 18:14:15.739597
17291	2016-09-01 00:00:00	2016-12-31 18:59:59	10299	10031	14	2017-01-23 18:14:15.744848	2017-01-23 18:14:15.744848
17292	2017-01-01 00:00:00	2099-12-31 18:59:59	10299	10030	11	2017-01-23 18:14:15.75063	2017-01-23 18:14:15.75063
17293	2017-01-01 00:00:00	2099-12-31 18:59:59	10299	10031	10	2017-01-23 18:14:15.755922	2017-01-23 18:14:15.755922
17294	2000-01-01 00:00:00	2016-05-31 18:59:59	10300	10030	10	2017-01-23 18:14:15.761651	2017-01-23 18:14:15.761651
17295	2000-01-01 00:00:00	2016-05-31 18:59:59	10300	10031	10	2017-01-23 18:14:15.766592	2017-01-23 18:14:15.766592
17296	2016-06-01 00:00:00	2016-08-31 18:59:59	10300	10030	14	2017-01-23 18:14:15.772586	2017-01-23 18:14:15.772586
17297	2016-06-01 00:00:00	2016-08-31 18:59:59	10300	10031	11	2017-01-23 18:14:15.778037	2017-01-23 18:14:15.778037
17298	2016-09-01 00:00:00	2016-12-31 18:59:59	10300	10030	14	2017-01-23 18:14:15.783538	2017-01-23 18:14:15.783538
17299	2016-09-01 00:00:00	2016-12-31 18:59:59	10300	10031	14	2017-01-23 18:14:15.788545	2017-01-23 18:14:15.788545
17300	2017-01-01 00:00:00	2099-12-31 18:59:59	10300	10030	11	2017-01-23 18:14:15.794261	2017-01-23 18:14:15.794261
17301	2017-01-01 00:00:00	2099-12-31 18:59:59	10300	10031	10	2017-01-23 18:14:15.799334	2017-01-23 18:14:15.799334
17302	2000-01-01 00:00:00	2016-05-31 18:59:59	10301	10030	13	2017-01-23 18:14:15.804969	2017-01-23 18:14:15.804969
17303	2000-01-01 00:00:00	2016-05-31 18:59:59	10301	10031	14	2017-01-23 18:14:15.810061	2017-01-23 18:14:15.810061
17304	2016-06-01 00:00:00	2016-08-31 18:59:59	10301	10030	14	2017-01-23 18:14:15.815911	2017-01-23 18:14:15.815911
17305	2016-06-01 00:00:00	2016-08-31 18:59:59	10301	10031	11	2017-01-23 18:14:15.820962	2017-01-23 18:14:15.820962
17306	2016-09-01 00:00:00	2016-12-31 18:59:59	10301	10030	11	2017-01-23 18:14:15.826599	2017-01-23 18:14:15.826599
17307	2016-09-01 00:00:00	2016-12-31 18:59:59	10301	10031	11	2017-01-23 18:14:15.832173	2017-01-23 18:14:15.832173
17308	2017-01-01 00:00:00	2099-12-31 18:59:59	10301	10030	11	2017-01-23 18:14:15.838103	2017-01-23 18:14:15.838103
17309	2017-01-01 00:00:00	2099-12-31 18:59:59	10301	10031	14	2017-01-23 18:14:15.843163	2017-01-23 18:14:15.843163
17310	2000-01-01 00:00:00	2016-05-31 18:59:59	10302	10030	13	2017-01-23 18:14:15.848706	2017-01-23 18:14:15.848706
17311	2000-01-01 00:00:00	2016-05-31 18:59:59	10302	10031	12	2017-01-23 18:14:15.853648	2017-01-23 18:14:15.853648
17312	2016-06-01 00:00:00	2016-08-31 18:59:59	10302	10030	12	2017-01-23 18:14:15.859846	2017-01-23 18:14:15.859846
17313	2016-06-01 00:00:00	2016-08-31 18:59:59	10302	10031	11	2017-01-23 18:14:15.865942	2017-01-23 18:14:15.865942
17314	2016-09-01 00:00:00	2016-12-31 18:59:59	10302	10030	10	2017-01-23 18:14:15.871879	2017-01-23 18:14:15.871879
17315	2016-09-01 00:00:00	2016-12-31 18:59:59	10302	10031	11	2017-01-23 18:14:15.876918	2017-01-23 18:14:15.876918
17316	2017-01-01 00:00:00	2099-12-31 18:59:59	10302	10030	14	2017-01-23 18:14:15.882546	2017-01-23 18:14:15.882546
17317	2017-01-01 00:00:00	2099-12-31 18:59:59	10302	10031	14	2017-01-23 18:14:15.887364	2017-01-23 18:14:15.887364
17318	2000-01-01 00:00:00	2016-05-31 18:59:59	10303	10030	10	2017-01-23 18:14:15.893502	2017-01-23 18:14:15.893502
17319	2000-01-01 00:00:00	2016-05-31 18:59:59	10303	10031	13	2017-01-23 18:14:15.898643	2017-01-23 18:14:15.898643
17320	2016-06-01 00:00:00	2016-08-31 18:59:59	10303	10030	14	2017-01-23 18:14:15.904448	2017-01-23 18:14:15.904448
17321	2016-06-01 00:00:00	2016-08-31 18:59:59	10303	10031	12	2017-01-23 18:14:15.909877	2017-01-23 18:14:15.909877
17322	2016-09-01 00:00:00	2016-12-31 18:59:59	10303	10030	14	2017-01-23 18:14:15.915633	2017-01-23 18:14:15.915633
17323	2016-09-01 00:00:00	2016-12-31 18:59:59	10303	10031	13	2017-01-23 18:14:15.920518	2017-01-23 18:14:15.920518
17324	2017-01-01 00:00:00	2099-12-31 18:59:59	10303	10030	14	2017-01-23 18:14:15.926215	2017-01-23 18:14:15.926215
17325	2017-01-01 00:00:00	2099-12-31 18:59:59	10303	10031	11	2017-01-23 18:14:15.932038	2017-01-23 18:14:15.932038
17326	2000-01-01 00:00:00	2016-05-31 18:59:59	10304	10030	13	2017-01-23 18:14:15.937886	2017-01-23 18:14:15.937886
17327	2000-01-01 00:00:00	2016-05-31 18:59:59	10304	10031	10	2017-01-23 18:14:15.943076	2017-01-23 18:14:15.943076
17328	2016-06-01 00:00:00	2016-08-31 18:59:59	10304	10030	10	2017-01-23 18:14:15.948567	2017-01-23 18:14:15.948567
17329	2016-06-01 00:00:00	2016-08-31 18:59:59	10304	10031	13	2017-01-23 18:14:15.953956	2017-01-23 18:14:15.953956
17330	2016-09-01 00:00:00	2016-12-31 18:59:59	10304	10030	13	2017-01-23 18:14:15.959701	2017-01-23 18:14:15.959701
17331	2016-09-01 00:00:00	2016-12-31 18:59:59	10304	10031	14	2017-01-23 18:14:15.964657	2017-01-23 18:14:15.964657
17332	2017-01-01 00:00:00	2099-12-31 18:59:59	10304	10030	12	2017-01-23 18:14:15.970582	2017-01-23 18:14:15.970582
17333	2017-01-01 00:00:00	2099-12-31 18:59:59	10304	10031	11	2017-01-23 18:14:15.975996	2017-01-23 18:14:15.975996
17334	2000-01-01 00:00:00	2016-05-31 18:59:59	10305	10030	13	2017-01-23 18:14:15.981827	2017-01-23 18:14:15.981827
17335	2000-01-01 00:00:00	2016-05-31 18:59:59	10305	10031	10	2017-01-23 18:14:15.987047	2017-01-23 18:14:15.987047
17336	2016-06-01 00:00:00	2016-08-31 18:59:59	10305	10030	12	2017-01-23 18:14:15.992787	2017-01-23 18:14:15.992787
17337	2016-06-01 00:00:00	2016-08-31 18:59:59	10305	10031	14	2017-01-23 18:14:15.998009	2017-01-23 18:14:15.998009
17338	2016-09-01 00:00:00	2016-12-31 18:59:59	10305	10030	10	2017-01-23 18:14:16.004096	2017-01-23 18:14:16.004096
17339	2016-09-01 00:00:00	2016-12-31 18:59:59	10305	10031	13	2017-01-23 18:14:16.009428	2017-01-23 18:14:16.009428
17340	2017-01-01 00:00:00	2099-12-31 18:59:59	10305	10030	12	2017-01-23 18:14:16.015307	2017-01-23 18:14:16.015307
17341	2017-01-01 00:00:00	2099-12-31 18:59:59	10305	10031	10	2017-01-23 18:14:16.020259	2017-01-23 18:14:16.020259
17342	2000-01-01 00:00:00	2016-05-31 18:59:59	10306	10030	12	2017-01-23 18:14:16.026025	2017-01-23 18:14:16.026025
17343	2000-01-01 00:00:00	2016-05-31 18:59:59	10306	10031	11	2017-01-23 18:14:16.03104	2017-01-23 18:14:16.03104
17344	2016-06-01 00:00:00	2016-08-31 18:59:59	10306	10030	10	2017-01-23 18:14:16.036942	2017-01-23 18:14:16.036942
17345	2016-06-01 00:00:00	2016-08-31 18:59:59	10306	10031	12	2017-01-23 18:14:16.041873	2017-01-23 18:14:16.041873
17346	2016-09-01 00:00:00	2016-12-31 18:59:59	10306	10030	10	2017-01-23 18:14:16.047635	2017-01-23 18:14:16.047635
17347	2016-09-01 00:00:00	2016-12-31 18:59:59	10306	10031	14	2017-01-23 18:14:16.052919	2017-01-23 18:14:16.052919
17348	2017-01-01 00:00:00	2099-12-31 18:59:59	10306	10030	11	2017-01-23 18:14:16.058766	2017-01-23 18:14:16.058766
17349	2017-01-01 00:00:00	2099-12-31 18:59:59	10306	10031	11	2017-01-23 18:14:16.064111	2017-01-23 18:14:16.064111
17350	2000-01-01 00:00:00	2016-05-31 18:59:59	10307	10030	14	2017-01-23 18:14:16.06969	2017-01-23 18:14:16.06969
17351	2000-01-01 00:00:00	2016-05-31 18:59:59	10307	10031	10	2017-01-23 18:14:16.075205	2017-01-23 18:14:16.075205
17352	2016-06-01 00:00:00	2016-08-31 18:59:59	10307	10030	12	2017-01-23 18:14:16.080789	2017-01-23 18:14:16.080789
17353	2016-06-01 00:00:00	2016-08-31 18:59:59	10307	10031	14	2017-01-23 18:14:16.085572	2017-01-23 18:14:16.085572
17354	2016-09-01 00:00:00	2016-12-31 18:59:59	10307	10030	10	2017-01-23 18:14:16.091375	2017-01-23 18:14:16.091375
17355	2016-09-01 00:00:00	2016-12-31 18:59:59	10307	10031	14	2017-01-23 18:14:16.096221	2017-01-23 18:14:16.096221
17356	2017-01-01 00:00:00	2099-12-31 18:59:59	10307	10030	14	2017-01-23 18:14:16.102319	2017-01-23 18:14:16.102319
17357	2017-01-01 00:00:00	2099-12-31 18:59:59	10307	10031	13	2017-01-23 18:14:16.107742	2017-01-23 18:14:16.107742
17358	2000-01-01 00:00:00	2016-05-31 18:59:59	10308	10030	13	2017-01-23 18:14:16.113304	2017-01-23 18:14:16.113304
17359	2000-01-01 00:00:00	2016-05-31 18:59:59	10308	10031	13	2017-01-23 18:14:16.118476	2017-01-23 18:14:16.118476
17360	2016-06-01 00:00:00	2016-08-31 18:59:59	10308	10030	14	2017-01-23 18:14:16.12439	2017-01-23 18:14:16.12439
17361	2016-06-01 00:00:00	2016-08-31 18:59:59	10308	10031	12	2017-01-23 18:14:16.129307	2017-01-23 18:14:16.129307
17362	2016-09-01 00:00:00	2016-12-31 18:59:59	10308	10030	11	2017-01-23 18:14:16.135521	2017-01-23 18:14:16.135521
17363	2016-09-01 00:00:00	2016-12-31 18:59:59	10308	10031	12	2017-01-23 18:14:16.141653	2017-01-23 18:14:16.141653
17364	2017-01-01 00:00:00	2099-12-31 18:59:59	10308	10030	14	2017-01-23 18:14:16.148004	2017-01-23 18:14:16.148004
17365	2017-01-01 00:00:00	2099-12-31 18:59:59	10308	10031	12	2017-01-23 18:14:16.152964	2017-01-23 18:14:16.152964
17366	2000-01-01 00:00:00	2016-05-31 18:59:59	10309	10030	14	2017-01-23 18:14:16.158754	2017-01-23 18:14:16.158754
17367	2000-01-01 00:00:00	2016-05-31 18:59:59	10309	10031	11	2017-01-23 18:14:16.163838	2017-01-23 18:14:16.163838
17368	2016-06-01 00:00:00	2016-08-31 18:59:59	10309	10030	10	2017-01-23 18:14:16.169612	2017-01-23 18:14:16.169612
17369	2016-06-01 00:00:00	2016-08-31 18:59:59	10309	10031	12	2017-01-23 18:14:16.174891	2017-01-23 18:14:16.174891
17370	2016-09-01 00:00:00	2016-12-31 18:59:59	10309	10030	10	2017-01-23 18:14:16.18058	2017-01-23 18:14:16.18058
17371	2016-09-01 00:00:00	2016-12-31 18:59:59	10309	10031	11	2017-01-23 18:14:16.185903	2017-01-23 18:14:16.185903
17372	2017-01-01 00:00:00	2099-12-31 18:59:59	10309	10030	12	2017-01-23 18:14:16.192061	2017-01-23 18:14:16.192061
17373	2017-01-01 00:00:00	2099-12-31 18:59:59	10309	10031	12	2017-01-23 18:14:16.197161	2017-01-23 18:14:16.197161
17374	2000-01-01 00:00:00	2016-05-31 18:59:59	10310	10030	10	2017-01-23 18:14:16.203095	2017-01-23 18:14:16.203095
17375	2000-01-01 00:00:00	2016-05-31 18:59:59	10310	10031	11	2017-01-23 18:14:16.208261	2017-01-23 18:14:16.208261
17376	2016-06-01 00:00:00	2016-08-31 18:59:59	10310	10030	12	2017-01-23 18:14:16.213933	2017-01-23 18:14:16.213933
17377	2016-06-01 00:00:00	2016-08-31 18:59:59	10310	10031	12	2017-01-23 18:14:16.21905	2017-01-23 18:14:16.21905
17378	2016-09-01 00:00:00	2016-12-31 18:59:59	10310	10030	10	2017-01-23 18:14:16.224902	2017-01-23 18:14:16.224902
17379	2016-09-01 00:00:00	2016-12-31 18:59:59	10310	10031	13	2017-01-23 18:14:16.229828	2017-01-23 18:14:16.229828
17380	2017-01-01 00:00:00	2099-12-31 18:59:59	10310	10030	13	2017-01-23 18:14:16.235529	2017-01-23 18:14:16.235529
17381	2017-01-01 00:00:00	2099-12-31 18:59:59	10310	10031	14	2017-01-23 18:14:16.240751	2017-01-23 18:14:16.240751
17382	2000-01-01 00:00:00	2016-05-31 18:59:59	10311	10030	10	2017-01-23 18:14:16.246396	2017-01-23 18:14:16.246396
17383	2000-01-01 00:00:00	2016-05-31 18:59:59	10311	10031	11	2017-01-23 18:14:16.251733	2017-01-23 18:14:16.251733
17384	2016-06-01 00:00:00	2016-08-31 18:59:59	10311	10030	11	2017-01-23 18:14:16.257827	2017-01-23 18:14:16.257827
17385	2016-06-01 00:00:00	2016-08-31 18:59:59	10311	10031	12	2017-01-23 18:14:16.262743	2017-01-23 18:14:16.262743
17386	2016-09-01 00:00:00	2016-12-31 18:59:59	10311	10030	14	2017-01-23 18:14:16.268685	2017-01-23 18:14:16.268685
17387	2016-09-01 00:00:00	2016-12-31 18:59:59	10311	10031	13	2017-01-23 18:14:16.273889	2017-01-23 18:14:16.273889
17388	2017-01-01 00:00:00	2099-12-31 18:59:59	10311	10030	14	2017-01-23 18:14:16.280295	2017-01-23 18:14:16.280295
17389	2017-01-01 00:00:00	2099-12-31 18:59:59	10311	10031	12	2017-01-23 18:14:16.286046	2017-01-23 18:14:16.286046
17390	2000-01-01 00:00:00	2016-05-31 18:59:59	10312	10030	13	2017-01-23 18:14:16.291972	2017-01-23 18:14:16.291972
17391	2000-01-01 00:00:00	2016-05-31 18:59:59	10312	10031	10	2017-01-23 18:14:16.296891	2017-01-23 18:14:16.296891
17392	2016-06-01 00:00:00	2016-08-31 18:59:59	10312	10030	14	2017-01-23 18:14:16.3026	2017-01-23 18:14:16.3026
17393	2016-06-01 00:00:00	2016-08-31 18:59:59	10312	10031	11	2017-01-23 18:14:16.307674	2017-01-23 18:14:16.307674
17394	2016-09-01 00:00:00	2016-12-31 18:59:59	10312	10030	12	2017-01-23 18:14:16.313469	2017-01-23 18:14:16.313469
17395	2016-09-01 00:00:00	2016-12-31 18:59:59	10312	10031	11	2017-01-23 18:14:16.318703	2017-01-23 18:14:16.318703
17396	2017-01-01 00:00:00	2099-12-31 18:59:59	10312	10030	12	2017-01-23 18:14:16.324667	2017-01-23 18:14:16.324667
17397	2017-01-01 00:00:00	2099-12-31 18:59:59	10312	10031	14	2017-01-23 18:14:16.329654	2017-01-23 18:14:16.329654
17398	2000-01-01 00:00:00	2016-05-31 18:59:59	10313	10030	11	2017-01-23 18:14:16.335323	2017-01-23 18:14:16.335323
17399	2000-01-01 00:00:00	2016-05-31 18:59:59	10313	10031	11	2017-01-23 18:14:16.340876	2017-01-23 18:14:16.340876
17400	2016-06-01 00:00:00	2016-08-31 18:59:59	10313	10030	11	2017-01-23 18:14:16.346584	2017-01-23 18:14:16.346584
17401	2016-06-01 00:00:00	2016-08-31 18:59:59	10313	10031	11	2017-01-23 18:14:16.35166	2017-01-23 18:14:16.35166
17402	2016-09-01 00:00:00	2016-12-31 18:59:59	10313	10030	11	2017-01-23 18:14:16.357295	2017-01-23 18:14:16.357295
17403	2016-09-01 00:00:00	2016-12-31 18:59:59	10313	10031	14	2017-01-23 18:14:16.362608	2017-01-23 18:14:16.362608
17404	2017-01-01 00:00:00	2099-12-31 18:59:59	10313	10030	14	2017-01-23 18:14:16.368488	2017-01-23 18:14:16.368488
17405	2017-01-01 00:00:00	2099-12-31 18:59:59	10313	10031	11	2017-01-23 18:14:16.373894	2017-01-23 18:14:16.373894
17406	2000-01-01 00:00:00	2016-05-31 18:59:59	10314	10030	14	2017-01-23 18:14:16.379593	2017-01-23 18:14:16.379593
17407	2000-01-01 00:00:00	2016-05-31 18:59:59	10314	10031	12	2017-01-23 18:14:16.384599	2017-01-23 18:14:16.384599
17408	2016-06-01 00:00:00	2016-08-31 18:59:59	10314	10030	11	2017-01-23 18:14:16.390783	2017-01-23 18:14:16.390783
17409	2016-06-01 00:00:00	2016-08-31 18:59:59	10314	10031	14	2017-01-23 18:14:16.395741	2017-01-23 18:14:16.395741
17410	2016-09-01 00:00:00	2016-12-31 18:59:59	10314	10030	13	2017-01-23 18:14:16.401556	2017-01-23 18:14:16.401556
17411	2016-09-01 00:00:00	2016-12-31 18:59:59	10314	10031	10	2017-01-23 18:14:16.406975	2017-01-23 18:14:16.406975
17412	2017-01-01 00:00:00	2099-12-31 18:59:59	10314	10030	13	2017-01-23 18:14:16.4125	2017-01-23 18:14:16.4125
17413	2017-01-01 00:00:00	2099-12-31 18:59:59	10314	10031	10	2017-01-23 18:14:16.417455	2017-01-23 18:14:16.417455
17414	2000-01-01 00:00:00	2016-05-31 18:59:59	10315	10030	12	2017-01-23 18:14:16.424103	2017-01-23 18:14:16.424103
17415	2000-01-01 00:00:00	2016-05-31 18:59:59	10315	10031	10	2017-01-23 18:14:16.42924	2017-01-23 18:14:16.42924
17416	2016-06-01 00:00:00	2016-08-31 18:59:59	10315	10030	10	2017-01-23 18:14:16.435166	2017-01-23 18:14:16.435166
17417	2016-06-01 00:00:00	2016-08-31 18:59:59	10315	10031	14	2017-01-23 18:14:16.440681	2017-01-23 18:14:16.440681
17418	2016-09-01 00:00:00	2016-12-31 18:59:59	10315	10030	14	2017-01-23 18:14:16.446613	2017-01-23 18:14:16.446613
17419	2016-09-01 00:00:00	2016-12-31 18:59:59	10315	10031	11	2017-01-23 18:14:16.4517	2017-01-23 18:14:16.4517
17420	2017-01-01 00:00:00	2099-12-31 18:59:59	10315	10030	11	2017-01-23 18:14:16.457669	2017-01-23 18:14:16.457669
17421	2017-01-01 00:00:00	2099-12-31 18:59:59	10315	10031	10	2017-01-23 18:14:16.462863	2017-01-23 18:14:16.462863
17422	2000-01-01 00:00:00	2016-05-31 18:59:59	10316	10030	10	2017-01-23 18:14:16.468608	2017-01-23 18:14:16.468608
17423	2000-01-01 00:00:00	2016-05-31 18:59:59	10316	10031	11	2017-01-23 18:14:16.473835	2017-01-23 18:14:16.473835
17424	2016-06-01 00:00:00	2016-08-31 18:59:59	10316	10030	13	2017-01-23 18:14:16.479448	2017-01-23 18:14:16.479448
17425	2016-06-01 00:00:00	2016-08-31 18:59:59	10316	10031	10	2017-01-23 18:14:16.484531	2017-01-23 18:14:16.484531
17426	2016-09-01 00:00:00	2016-12-31 18:59:59	10316	10030	12	2017-01-23 18:14:16.490412	2017-01-23 18:14:16.490412
17427	2016-09-01 00:00:00	2016-12-31 18:59:59	10316	10031	13	2017-01-23 18:14:16.495292	2017-01-23 18:14:16.495292
17428	2017-01-01 00:00:00	2099-12-31 18:59:59	10316	10030	14	2017-01-23 18:14:16.501248	2017-01-23 18:14:16.501248
17429	2017-01-01 00:00:00	2099-12-31 18:59:59	10316	10031	14	2017-01-23 18:14:16.506296	2017-01-23 18:14:16.506296
17430	2000-01-01 00:00:00	2016-05-31 18:59:59	10317	10030	11	2017-01-23 18:14:16.512116	2017-01-23 18:14:16.512116
17431	2000-01-01 00:00:00	2016-05-31 18:59:59	10317	10031	13	2017-01-23 18:14:16.517327	2017-01-23 18:14:16.517327
17432	2016-06-01 00:00:00	2016-08-31 18:59:59	10317	10030	11	2017-01-23 18:14:16.523558	2017-01-23 18:14:16.523558
17433	2016-06-01 00:00:00	2016-08-31 18:59:59	10317	10031	10	2017-01-23 18:14:16.52909	2017-01-23 18:14:16.52909
17434	2016-09-01 00:00:00	2016-12-31 18:59:59	10317	10030	13	2017-01-23 18:14:16.53494	2017-01-23 18:14:16.53494
17435	2016-09-01 00:00:00	2016-12-31 18:59:59	10317	10031	10	2017-01-23 18:14:16.539925	2017-01-23 18:14:16.539925
17436	2017-01-01 00:00:00	2099-12-31 18:59:59	10317	10030	14	2017-01-23 18:14:16.545696	2017-01-23 18:14:16.545696
17437	2017-01-01 00:00:00	2099-12-31 18:59:59	10317	10031	13	2017-01-23 18:14:16.55094	2017-01-23 18:14:16.55094
17438	2000-01-01 00:00:00	2016-05-31 18:59:59	10318	10030	10	2017-01-23 18:14:16.556661	2017-01-23 18:14:16.556661
17439	2000-01-01 00:00:00	2016-05-31 18:59:59	10318	10031	14	2017-01-23 18:14:16.562731	2017-01-23 18:14:16.562731
17440	2016-06-01 00:00:00	2016-08-31 18:59:59	10318	10030	12	2017-01-23 18:14:16.568731	2017-01-23 18:14:16.568731
17441	2016-06-01 00:00:00	2016-08-31 18:59:59	10318	10031	13	2017-01-23 18:14:16.573957	2017-01-23 18:14:16.573957
17442	2016-09-01 00:00:00	2016-12-31 18:59:59	10318	10030	10	2017-01-23 18:14:16.579654	2017-01-23 18:14:16.579654
17443	2016-09-01 00:00:00	2016-12-31 18:59:59	10318	10031	14	2017-01-23 18:14:16.584721	2017-01-23 18:14:16.584721
17444	2017-01-01 00:00:00	2099-12-31 18:59:59	10318	10030	12	2017-01-23 18:14:16.590716	2017-01-23 18:14:16.590716
17445	2017-01-01 00:00:00	2099-12-31 18:59:59	10318	10031	14	2017-01-23 18:14:16.595597	2017-01-23 18:14:16.595597
17446	2000-01-01 00:00:00	2016-05-31 18:59:59	10319	10030	14	2017-01-23 18:14:16.60131	2017-01-23 18:14:16.60131
17447	2000-01-01 00:00:00	2016-05-31 18:59:59	10319	10031	12	2017-01-23 18:14:16.606646	2017-01-23 18:14:16.606646
17448	2016-06-01 00:00:00	2016-08-31 18:59:59	10319	10030	10	2017-01-23 18:14:16.612736	2017-01-23 18:14:16.612736
17449	2016-06-01 00:00:00	2016-08-31 18:59:59	10319	10031	10	2017-01-23 18:14:16.61766	2017-01-23 18:14:16.61766
17450	2016-09-01 00:00:00	2016-12-31 18:59:59	10319	10030	11	2017-01-23 18:14:16.623643	2017-01-23 18:14:16.623643
17451	2016-09-01 00:00:00	2016-12-31 18:59:59	10319	10031	14	2017-01-23 18:14:16.628999	2017-01-23 18:14:16.628999
17452	2017-01-01 00:00:00	2099-12-31 18:59:59	10319	10030	13	2017-01-23 18:14:16.634723	2017-01-23 18:14:16.634723
17453	2017-01-01 00:00:00	2099-12-31 18:59:59	10319	10031	10	2017-01-23 18:14:16.639663	2017-01-23 18:14:16.639663
17454	2000-01-01 00:00:00	2016-05-31 18:59:59	10320	10030	14	2017-01-23 18:14:16.645427	2017-01-23 18:14:16.645427
17455	2000-01-01 00:00:00	2016-05-31 18:59:59	10320	10031	13	2017-01-23 18:14:16.650798	2017-01-23 18:14:16.650798
17456	2016-06-01 00:00:00	2016-08-31 18:59:59	10320	10030	12	2017-01-23 18:14:16.656322	2017-01-23 18:14:16.656322
17457	2016-06-01 00:00:00	2016-08-31 18:59:59	10320	10031	13	2017-01-23 18:14:16.662328	2017-01-23 18:14:16.662328
17458	2016-09-01 00:00:00	2016-12-31 18:59:59	10320	10030	12	2017-01-23 18:14:16.668214	2017-01-23 18:14:16.668214
17459	2016-09-01 00:00:00	2016-12-31 18:59:59	10320	10031	10	2017-01-23 18:14:16.673771	2017-01-23 18:14:16.673771
17460	2017-01-01 00:00:00	2099-12-31 18:59:59	10320	10030	11	2017-01-23 18:14:16.679744	2017-01-23 18:14:16.679744
17461	2017-01-01 00:00:00	2099-12-31 18:59:59	10320	10031	11	2017-01-23 18:14:16.685151	2017-01-23 18:14:16.685151
17462	2000-01-01 00:00:00	2016-05-31 18:59:59	10321	10030	12	2017-01-23 18:14:16.691186	2017-01-23 18:14:16.691186
17463	2000-01-01 00:00:00	2016-05-31 18:59:59	10321	10031	14	2017-01-23 18:14:16.696753	2017-01-23 18:14:16.696753
17464	2016-06-01 00:00:00	2016-08-31 18:59:59	10321	10030	10	2017-01-23 18:14:16.702783	2017-01-23 18:14:16.702783
17465	2016-06-01 00:00:00	2016-08-31 18:59:59	10321	10031	13	2017-01-23 18:14:16.708366	2017-01-23 18:14:16.708366
17466	2016-09-01 00:00:00	2016-12-31 18:59:59	10321	10030	10	2017-01-23 18:14:16.714389	2017-01-23 18:14:16.714389
17467	2016-09-01 00:00:00	2016-12-31 18:59:59	10321	10031	13	2017-01-23 18:14:16.719423	2017-01-23 18:14:16.719423
17468	2017-01-01 00:00:00	2099-12-31 18:59:59	10321	10030	12	2017-01-23 18:14:16.725593	2017-01-23 18:14:16.725593
17469	2017-01-01 00:00:00	2099-12-31 18:59:59	10321	10031	14	2017-01-23 18:14:16.730761	2017-01-23 18:14:16.730761
17470	2000-01-01 00:00:00	2016-05-31 18:59:59	10322	10030	11	2017-01-23 18:14:16.736219	2017-01-23 18:14:16.736219
17471	2000-01-01 00:00:00	2016-05-31 18:59:59	10322	10031	10	2017-01-23 18:14:16.741234	2017-01-23 18:14:16.741234
17472	2016-06-01 00:00:00	2016-08-31 18:59:59	10322	10030	11	2017-01-23 18:14:16.746737	2017-01-23 18:14:16.746737
17473	2016-06-01 00:00:00	2016-08-31 18:59:59	10322	10031	14	2017-01-23 18:14:16.751914	2017-01-23 18:14:16.751914
17474	2016-09-01 00:00:00	2016-12-31 18:59:59	10322	10030	14	2017-01-23 18:14:16.757705	2017-01-23 18:14:16.757705
17475	2016-09-01 00:00:00	2016-12-31 18:59:59	10322	10031	14	2017-01-23 18:14:16.762916	2017-01-23 18:14:16.762916
17476	2017-01-01 00:00:00	2099-12-31 18:59:59	10322	10030	14	2017-01-23 18:14:16.768971	2017-01-23 18:14:16.768971
17477	2017-01-01 00:00:00	2099-12-31 18:59:59	10322	10031	14	2017-01-23 18:14:16.774382	2017-01-23 18:14:16.774382
17478	2000-01-01 00:00:00	2016-05-31 18:59:59	10323	10030	11	2017-01-23 18:14:16.780255	2017-01-23 18:14:16.780255
17479	2000-01-01 00:00:00	2016-05-31 18:59:59	10323	10031	11	2017-01-23 18:14:16.785396	2017-01-23 18:14:16.785396
17480	2016-06-01 00:00:00	2016-08-31 18:59:59	10323	10030	11	2017-01-23 18:14:16.791441	2017-01-23 18:14:16.791441
17481	2016-06-01 00:00:00	2016-08-31 18:59:59	10323	10031	10	2017-01-23 18:14:16.796699	2017-01-23 18:14:16.796699
17482	2016-09-01 00:00:00	2016-12-31 18:59:59	10323	10030	13	2017-01-23 18:14:16.80233	2017-01-23 18:14:16.80233
17483	2016-09-01 00:00:00	2016-12-31 18:59:59	10323	10031	14	2017-01-23 18:14:16.807524	2017-01-23 18:14:16.807524
17484	2017-01-01 00:00:00	2099-12-31 18:59:59	10323	10030	10	2017-01-23 18:14:16.813848	2017-01-23 18:14:16.813848
17485	2017-01-01 00:00:00	2099-12-31 18:59:59	10323	10031	14	2017-01-23 18:14:16.818792	2017-01-23 18:14:16.818792
17486	2000-01-01 00:00:00	2016-05-31 18:59:59	10324	10030	11	2017-01-23 18:14:16.824592	2017-01-23 18:14:16.824592
17487	2000-01-01 00:00:00	2016-05-31 18:59:59	10324	10031	11	2017-01-23 18:14:16.82959	2017-01-23 18:14:16.82959
17488	2016-06-01 00:00:00	2016-08-31 18:59:59	10324	10030	14	2017-01-23 18:14:16.835549	2017-01-23 18:14:16.835549
17489	2016-06-01 00:00:00	2016-08-31 18:59:59	10324	10031	13	2017-01-23 18:14:16.840683	2017-01-23 18:14:16.840683
17490	2016-09-01 00:00:00	2016-12-31 18:59:59	10324	10030	10	2017-01-23 18:14:16.847043	2017-01-23 18:14:16.847043
17491	2016-09-01 00:00:00	2016-12-31 18:59:59	10324	10031	10	2017-01-23 18:14:16.851969	2017-01-23 18:14:16.851969
17492	2017-01-01 00:00:00	2099-12-31 18:59:59	10324	10030	13	2017-01-23 18:14:16.85762	2017-01-23 18:14:16.85762
17493	2017-01-01 00:00:00	2099-12-31 18:59:59	10324	10031	11	2017-01-23 18:14:16.862599	2017-01-23 18:14:16.862599
17494	2000-01-01 00:00:00	2016-05-31 18:59:59	10325	10030	10	2017-01-23 18:14:16.868578	2017-01-23 18:14:16.868578
17495	2000-01-01 00:00:00	2016-05-31 18:59:59	10325	10031	14	2017-01-23 18:14:16.87416	2017-01-23 18:14:16.87416
17496	2016-06-01 00:00:00	2016-08-31 18:59:59	10325	10030	12	2017-01-23 18:14:16.879721	2017-01-23 18:14:16.879721
17497	2016-06-01 00:00:00	2016-08-31 18:59:59	10325	10031	13	2017-01-23 18:14:16.884863	2017-01-23 18:14:16.884863
17498	2016-09-01 00:00:00	2016-12-31 18:59:59	10325	10030	11	2017-01-23 18:14:16.890922	2017-01-23 18:14:16.890922
17499	2016-09-01 00:00:00	2016-12-31 18:59:59	10325	10031	13	2017-01-23 18:14:16.895949	2017-01-23 18:14:16.895949
17500	2017-01-01 00:00:00	2099-12-31 18:59:59	10325	10030	10	2017-01-23 18:14:16.901549	2017-01-23 18:14:16.901549
17501	2017-01-01 00:00:00	2099-12-31 18:59:59	10325	10031	10	2017-01-23 18:14:16.906921	2017-01-23 18:14:16.906921
17502	2000-01-01 00:00:00	2016-05-31 18:59:59	10326	10030	13	2017-01-23 18:14:16.912738	2017-01-23 18:14:16.912738
17503	2000-01-01 00:00:00	2016-05-31 18:59:59	10326	10031	11	2017-01-23 18:14:16.917639	2017-01-23 18:14:16.917639
17504	2016-06-01 00:00:00	2016-08-31 18:59:59	10326	10030	11	2017-01-23 18:14:16.923518	2017-01-23 18:14:16.923518
17505	2016-06-01 00:00:00	2016-08-31 18:59:59	10326	10031	13	2017-01-23 18:14:16.929136	2017-01-23 18:14:16.929136
17506	2016-09-01 00:00:00	2016-12-31 18:59:59	10326	10030	13	2017-01-23 18:14:16.93489	2017-01-23 18:14:16.93489
17507	2016-09-01 00:00:00	2016-12-31 18:59:59	10326	10031	10	2017-01-23 18:14:16.941732	2017-01-23 18:14:16.941732
17508	2017-01-01 00:00:00	2099-12-31 18:59:59	10326	10030	11	2017-01-23 18:14:16.947479	2017-01-23 18:14:16.947479
17509	2017-01-01 00:00:00	2099-12-31 18:59:59	10326	10031	11	2017-01-23 18:14:16.953109	2017-01-23 18:14:16.953109
17510	2000-01-01 00:00:00	2016-05-31 18:59:59	10327	10030	11	2017-01-23 18:14:16.959244	2017-01-23 18:14:16.959244
17511	2000-01-01 00:00:00	2016-05-31 18:59:59	10327	10031	13	2017-01-23 18:14:16.964043	2017-01-23 18:14:16.964043
17512	2016-06-01 00:00:00	2016-08-31 18:59:59	10327	10030	11	2017-01-23 18:14:16.970029	2017-01-23 18:14:16.970029
17513	2016-06-01 00:00:00	2016-08-31 18:59:59	10327	10031	12	2017-01-23 18:14:16.975049	2017-01-23 18:14:16.975049
17514	2016-09-01 00:00:00	2016-12-31 18:59:59	10327	10030	10	2017-01-23 18:14:16.980972	2017-01-23 18:14:16.980972
17515	2016-09-01 00:00:00	2016-12-31 18:59:59	10327	10031	11	2017-01-23 18:14:16.986873	2017-01-23 18:14:16.986873
17516	2017-01-01 00:00:00	2099-12-31 18:59:59	10327	10030	10	2017-01-23 18:14:16.999189	2017-01-23 18:14:16.999189
17517	2017-01-01 00:00:00	2099-12-31 18:59:59	10327	10031	11	2017-01-23 18:14:17.011277	2017-01-23 18:14:17.011277
17518	2000-01-01 00:00:00	2016-05-31 18:59:59	10328	10030	11	2017-01-23 18:14:17.020114	2017-01-23 18:14:17.020114
17519	2000-01-01 00:00:00	2016-05-31 18:59:59	10328	10031	14	2017-01-23 18:14:17.02657	2017-01-23 18:14:17.02657
17520	2016-06-01 00:00:00	2016-08-31 18:59:59	10328	10030	10	2017-01-23 18:14:17.03264	2017-01-23 18:14:17.03264
17521	2016-06-01 00:00:00	2016-08-31 18:59:59	10328	10031	10	2017-01-23 18:14:17.037971	2017-01-23 18:14:17.037971
17522	2016-09-01 00:00:00	2016-12-31 18:59:59	10328	10030	10	2017-01-23 18:14:17.043887	2017-01-23 18:14:17.043887
17523	2016-09-01 00:00:00	2016-12-31 18:59:59	10328	10031	10	2017-01-23 18:14:17.048941	2017-01-23 18:14:17.048941
17524	2017-01-01 00:00:00	2099-12-31 18:59:59	10328	10030	13	2017-01-23 18:14:17.054906	2017-01-23 18:14:17.054906
17525	2017-01-01 00:00:00	2099-12-31 18:59:59	10328	10031	12	2017-01-23 18:14:17.059789	2017-01-23 18:14:17.059789
17526	2000-01-01 00:00:00	2016-05-31 18:59:59	10329	10030	13	2017-01-23 18:14:17.065259	2017-01-23 18:14:17.065259
17527	2000-01-01 00:00:00	2016-05-31 18:59:59	10329	10031	14	2017-01-23 18:14:17.070889	2017-01-23 18:14:17.070889
17528	2016-06-01 00:00:00	2016-08-31 18:59:59	10329	10030	13	2017-01-23 18:14:17.076792	2017-01-23 18:14:17.076792
17529	2016-06-01 00:00:00	2016-08-31 18:59:59	10329	10031	10	2017-01-23 18:14:17.082071	2017-01-23 18:14:17.082071
17530	2016-09-01 00:00:00	2016-12-31 18:59:59	10329	10030	10	2017-01-23 18:14:17.087612	2017-01-23 18:14:17.087612
17531	2016-09-01 00:00:00	2016-12-31 18:59:59	10329	10031	14	2017-01-23 18:14:17.093217	2017-01-23 18:14:17.093217
17532	2017-01-01 00:00:00	2099-12-31 18:59:59	10329	10030	13	2017-01-23 18:14:17.099006	2017-01-23 18:14:17.099006
17533	2017-01-01 00:00:00	2099-12-31 18:59:59	10329	10031	10	2017-01-23 18:14:17.103943	2017-01-23 18:14:17.103943
17534	2000-01-01 00:00:00	2016-05-31 18:59:59	10330	10030	14	2017-01-23 18:14:17.10955	2017-01-23 18:14:17.10955
17535	2000-01-01 00:00:00	2016-05-31 18:59:59	10330	10031	13	2017-01-23 18:14:17.115286	2017-01-23 18:14:17.115286
17536	2016-06-01 00:00:00	2016-08-31 18:59:59	10330	10030	11	2017-01-23 18:14:17.120853	2017-01-23 18:14:17.120853
17537	2016-06-01 00:00:00	2016-08-31 18:59:59	10330	10031	11	2017-01-23 18:14:17.12578	2017-01-23 18:14:17.12578
17538	2016-09-01 00:00:00	2016-12-31 18:59:59	10330	10030	13	2017-01-23 18:14:17.131517	2017-01-23 18:14:17.131517
17539	2016-09-01 00:00:00	2016-12-31 18:59:59	10330	10031	14	2017-01-23 18:14:17.136797	2017-01-23 18:14:17.136797
17540	2017-01-01 00:00:00	2099-12-31 18:59:59	10330	10030	10	2017-01-23 18:14:17.143559	2017-01-23 18:14:17.143559
17541	2017-01-01 00:00:00	2099-12-31 18:59:59	10330	10031	12	2017-01-23 18:14:17.148636	2017-01-23 18:14:17.148636
\.


--
-- Data for Name: t_prices_specials_conditions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices_specials_conditions (id, price_plan_id, beg_date_order, end_date_order, period_beg_date, period_end_date, bike_model_id, customer_group_id, bike_count, period_order_in_hour, price_specials_value, created_at, updated_at, holiday_flag) FROM stdin;
17735	16577	2000-01-01 00:00:00	2100-01-01 00:00:00	2000-01-01 00:00:00	2100-01-01 00:00:00	\N	\N	\N	\N	5	2017-01-28 18:37:12.462935	2017-01-28 18:37:12.462935	t
17737	16579	2000-01-01 00:00:00	2100-01-01 00:00:00	2000-01-01 00:00:00	2100-01-01 00:00:00	\N	\N	\N	240	7	2017-01-28 18:37:12.47217	2017-01-28 18:37:12.47217	\N
17736	16578	2000-01-01 00:00:00	2100-01-01 00:00:00	2000-01-01 00:00:00	2100-01-01 00:00:00	\N	\N	5	\N	5	2017-01-28 18:37:12.467523	2017-01-28 18:37:12.467523	\N
17734	16576	2001-01-01 00:00:00	2100-01-01 00:00:00	2000-01-01 00:00:00	2100-01-01 00:00:00	\N	10046	\N	\N	10	2017-01-28 18:37:12.458047	2017-01-28 18:37:12.458047	\N
\.


--
-- Name: t_bikes_states PK_bike_states_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes_states
    ADD CONSTRAINT "PK_bike_states_id" PRIMARY KEY (id);


--
-- Name: t_booking_contents PK_booking_consist; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_contents
    ADD CONSTRAINT "PK_booking_consist" PRIMARY KEY (id);


--
-- Name: t_booking PK_booking_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking
    ADD CONSTRAINT "PK_booking_id" PRIMARY KEY (booking_id);


--
-- Name: t_booking_orders PK_booking_orders; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_orders
    ADD CONSTRAINT "PK_booking_orders" PRIMARY KEY (id);


--
-- Name: t_booking_prices PK_booking_price; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_prices
    ADD CONSTRAINT "PK_booking_price" PRIMARY KEY (id);


--
-- Name: dict_booking_states PK_booking_state_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_booking_states
    ADD CONSTRAINT "PK_booking_state_id" PRIMARY KEY (booking_state_id);


--
-- Name: dict_currencies PK_currencies_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_currencies
    ADD CONSTRAINT "PK_currencies_id" PRIMARY KEY (currency_id);


--
-- Name: t_customers_groups PK_customer_group; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_customers_groups
    ADD CONSTRAINT "PK_customer_group" PRIMARY KEY (customer_group_id);


--
-- Name: t_customers PK_customer_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_customers
    ADD CONSTRAINT "PK_customer_id" PRIMARY KEY (customer_id);


--
-- Name: dict_dates PK_dates; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_dates
    ADD CONSTRAINT "PK_dates" PRIMARY KEY (sys_date);


--
-- Name: dict_bike_brands PK_dict_bike_brands_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_brands
    ADD CONSTRAINT "PK_dict_bike_brands_id" PRIMARY KEY (brand_id);


--
-- Name: dict_bike_colors PK_dict_bike_colors_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_colors
    ADD CONSTRAINT "PK_dict_bike_colors_id" PRIMARY KEY (bike_color_id);


--
-- Name: dict_bike_models PK_dict_bike_models_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_models
    ADD CONSTRAINT "PK_dict_bike_models_id" PRIMARY KEY (bike_model_id);


--
-- Name: dict_bike_states PK_dict_bike_states_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_states
    ADD CONSTRAINT "PK_dict_bike_states_id" PRIMARY KEY (bike_state_id);


--
-- Name: dict_bike_types PK_dict_bike_types; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_types
    ADD CONSTRAINT "PK_dict_bike_types" PRIMARY KEY (bike_type_id);


--
-- Name: t_customers_groups_membership PK_membership_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_customers_groups_membership
    ADD CONSTRAINT "PK_membership_id" PRIMARY KEY (id);


--
-- Name: dict_prices_discounts PK_prices_plans; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_prices_discounts
    ADD CONSTRAINT "PK_prices_plans" PRIMARY KEY (id);


--
-- Name: t_bikes PK_t_bikes_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes
    ADD CONSTRAINT "PK_t_bikes_id" PRIMARY KEY (bike_id);


--
-- Name: t_prices PK_t_prices_base_plans; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices
    ADD CONSTRAINT "PK_t_prices_base_plans" PRIMARY KEY (id);


--
-- Name: t_prices_specials_conditions PK_t_prices_specials_conditions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_specials_conditions
    ADD CONSTRAINT "PK_t_prices_specials_conditions" PRIMARY KEY (id);


--
-- Name: dict_currencies UNIQ_val_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_currencies
    ADD CONSTRAINT "UNIQ_val_code" UNIQUE (currency_code);


--
-- Name: FKI_bike_model_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_bike_model_id" ON t_bikes USING btree (bike_model_id);


--
-- Name: FKI_bike_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_bike_state" ON t_bikes_states USING btree (bike_state_id);


--
-- Name: FKI_bikes_states_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_bikes_states_id" ON t_bikes USING btree (bike_current_state_id);


--
-- Name: FKI_booking_bike_model_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_booking_bike_model_id" ON t_booking_contents USING btree (bike_model_id);


--
-- Name: FKI_booking_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_booking_customer_id" ON t_booking USING btree (customer_id);


--
-- Name: FKI_booking_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_booking_id" ON t_booking_contents USING btree (booking_id);


--
-- Name: FKI_booking_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_booking_state" ON t_booking USING btree (booking_state_id);


--
-- Name: FKI_customer_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_customer_group_id" ON t_customers_groups_membership USING btree (customer_group_id);


--
-- Name: FKI_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_customer_id" ON t_customers_groups_membership USING btree (customer_id);


--
-- Name: FKI_from_bike_to_booking_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_from_bike_to_booking_order" ON t_booking_orders USING btree (bike_id);


--
-- Name: FKI_from_booking_order_to_booking_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_from_booking_order_to_booking_id" ON t_booking_orders USING btree (booking_id);


--
-- Name: FKI_model_brand_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_model_brand_id" ON dict_bike_models USING btree (bike_model_brand_id);


--
-- Name: FKI_model_color_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_model_color_id" ON dict_bike_models USING btree (bike_model_color_id);


--
-- Name: FKI_model_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_model_type_id" ON dict_bike_models USING btree (bike_model_type_id);


--
-- Name: FKI_prices_plans; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_prices_plans" ON t_prices_specials_conditions USING btree (price_plan_id);


--
-- Name: FKI_to_bike_model_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_bike_model_id" ON t_prices USING btree (bike_model_id);


--
-- Name: FKI_to_booking_consist; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_booking_consist" ON t_booking_prices USING btree (booking_consist_id);


--
-- Name: FKI_to_currency_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_currency_id" ON t_prices USING btree (currency_id);


--
-- Name: FKI_to_price_plans_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_price_plans_id" ON t_booking_prices USING btree (t_price_plans_id);


--
-- Name: PK_idx_bikes_states; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_bikes_states" ON t_bikes_states USING btree (id);


--
-- Name: PK_idx_booking_consist; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PK_idx_booking_consist" ON t_booking_contents USING btree (id);


--
-- Name: PK_idx_booking_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_booking_id" ON t_booking USING btree (booking_id);


--
-- Name: PK_idx_booking_orders; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_booking_orders" ON t_booking_orders USING btree (id);


--
-- Name: PK_idx_booking_prices; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_booking_prices" ON t_booking_prices USING btree (id);


--
-- Name: PK_idx_booking_state_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_booking_state_id" ON dict_booking_states USING btree (booking_state_id);


--
-- Name: PK_idx_currencies_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_currencies_id" ON dict_currencies USING btree (currency_id);


--
-- Name: PK_idx_customer_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_customer_group" ON t_customers_groups USING btree (customer_group_id);


--
-- Name: PK_idx_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_customer_id" ON t_customers USING btree (customer_id);


--
-- Name: PK_idx_dict_bike_brands_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_dict_bike_brands_id" ON dict_bike_brands USING btree (brand_id);


--
-- Name: PK_idx_dict_bike_colors_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_dict_bike_colors_id" ON dict_bike_colors USING btree (bike_color_id);


--
-- Name: PK_idx_dict_bike_models_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_dict_bike_models_id" ON dict_bike_models USING btree (bike_model_id);


--
-- Name: PK_idx_dict_bike_states_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_dict_bike_states_id" ON dict_bike_states USING btree (bike_state_id);


--
-- Name: PK_idx_dict_bike_types_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_dict_bike_types_id" ON dict_bike_types USING btree (bike_type_id);


--
-- Name: PK_idx_membership_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PK_idx_membership_id" ON t_customers_groups_membership USING btree (id);


--
-- Name: PK_idx_prices_plans; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_prices_plans" ON dict_prices_discounts USING btree (id);


--
-- Name: PK_idx_prices_specials_conditions; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_prices_specials_conditions" ON t_prices_specials_conditions USING btree (id);


--
-- Name: PK_idx_sys_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_sys_date" ON dict_dates USING btree (sys_date);


--
-- Name: PK_idx_t_bikes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_t_bikes_id" ON t_bikes USING btree (bike_id);


--
-- Name: UNIQ_booking_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UNIQ_booking_code" ON t_booking USING btree (booking_code);


--
-- Name: UNIQ_booking_state_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UNIQ_booking_state_code" ON dict_booking_states USING btree (booking_state_code);


--
-- Name: UNIQ_idx_beg_date_bike_model_id_val_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "UNIQ_idx_beg_date_bike_model_id_val_id" ON t_prices USING btree (beg_date, bike_model_id, currency_id);


--
-- Name: UNIQ_price_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UNIQ_price_code" ON dict_prices_discounts USING btree (price_code);


--
-- Name: idx_bike_inventory_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_bike_inventory_number ON t_bikes USING btree (bike_inventory_number);


--
-- Name: idx_dict_bike_models_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_dict_bike_models_code ON dict_bike_models USING btree (bike_model_code);


--
-- Name: idx_dict_bike_states_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_dict_bike_states_code ON dict_bike_states USING btree (bike_state_code);


--
-- Name: idx_dict_bike_types_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_dict_bike_types_code ON dict_bike_types USING btree (bike_type_code);


--
-- Name: idx_uniq_dict_bike_brands_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_uniq_dict_bike_brands_code ON dict_bike_brands USING btree (brand_code);


--
-- Name: idx_uniq_dict_bike_colors_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_uniq_dict_bike_colors_code ON dict_bike_colors USING btree (bike_color_code);


--
-- Name: t_bikes FK_bike_current_state; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes
    ADD CONSTRAINT "FK_bike_current_state" FOREIGN KEY (bike_current_state_id) REFERENCES t_bikes_states(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_bikes FK_bike_model_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes
    ADD CONSTRAINT "FK_bike_model_id" FOREIGN KEY (bike_model_id) REFERENCES dict_bike_models(bike_model_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_bikes_states FK_bike_state; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes_states
    ADD CONSTRAINT "FK_bike_state" FOREIGN KEY (bike_state_id) REFERENCES dict_bike_states(bike_state_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_contents FK_booking_bike_model_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_contents
    ADD CONSTRAINT "FK_booking_bike_model_id" FOREIGN KEY (bike_model_id) REFERENCES dict_bike_models(bike_model_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking FK_booking_customer_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking
    ADD CONSTRAINT "FK_booking_customer_id" FOREIGN KEY (customer_id) REFERENCES t_customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_contents FK_booking_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_contents
    ADD CONSTRAINT "FK_booking_id" FOREIGN KEY (booking_id) REFERENCES t_booking(booking_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking FK_booking_state; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking
    ADD CONSTRAINT "FK_booking_state" FOREIGN KEY (booking_state_id) REFERENCES dict_booking_states(booking_state_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_customers_groups_membership FK_customer_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_customers_groups_membership
    ADD CONSTRAINT "FK_customer_group_id" FOREIGN KEY (customer_group_id) REFERENCES t_customers_groups(customer_group_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_customers_groups_membership FK_customer_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_customers_groups_membership
    ADD CONSTRAINT "FK_customer_id" FOREIGN KEY (customer_id) REFERENCES t_customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_orders FK_from_bike_to_booking_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_orders
    ADD CONSTRAINT "FK_from_bike_to_booking_order" FOREIGN KEY (bike_id) REFERENCES t_bikes(bike_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_orders FK_from_booking_order_to_booking_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_orders
    ADD CONSTRAINT "FK_from_booking_order_to_booking_id" FOREIGN KEY (booking_id) REFERENCES t_booking(booking_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: dict_bike_models FK_model_brand_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_models
    ADD CONSTRAINT "FK_model_brand_id" FOREIGN KEY (bike_model_brand_id) REFERENCES dict_bike_brands(brand_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: dict_bike_models FK_model_color_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_models
    ADD CONSTRAINT "FK_model_color_id" FOREIGN KEY (bike_model_color_id) REFERENCES dict_bike_colors(bike_color_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: dict_bike_models FK_model_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_models
    ADD CONSTRAINT "FK_model_type_id" FOREIGN KEY (bike_model_type_id) REFERENCES dict_bike_types(bike_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_prices_specials_conditions FK_prices_plans; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_specials_conditions
    ADD CONSTRAINT "FK_prices_plans" FOREIGN KEY (price_plan_id) REFERENCES dict_prices_discounts(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_prices FK_to_bike_model_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices
    ADD CONSTRAINT "FK_to_bike_model_id" FOREIGN KEY (bike_model_id) REFERENCES dict_bike_models(bike_model_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_prices FK_to_booking_consist; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_prices
    ADD CONSTRAINT "FK_to_booking_consist" FOREIGN KEY (booking_consist_id) REFERENCES t_booking_contents(id);


--
-- Name: t_prices FK_to_currency_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices
    ADD CONSTRAINT "FK_to_currency_id" FOREIGN KEY (currency_id) REFERENCES dict_currencies(currency_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_prices FK_to_price_plans_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_prices
    ADD CONSTRAINT "FK_to_price_plans_id" FOREIGN KEY (t_price_plans_id) REFERENCES dict_prices_discounts(id);


--
-- Name: t_prices_specials_conditions fk_t_prices_specials_conditions_dict_bike_models; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_specials_conditions
    ADD CONSTRAINT fk_t_prices_specials_conditions_dict_bike_models FOREIGN KEY (bike_model_id) REFERENCES dict_bike_models(bike_model_id) ON UPDATE CASCADE;


--
-- Name: t_prices_specials_conditions fk_to_customer_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_specials_conditions
    ADD CONSTRAINT fk_to_customer_group_id FOREIGN KEY (customer_group_id) REFERENCES t_customers_groups(customer_group_id) ON UPDATE CASCADE;


--
-- PostgreSQL database dump complete
--


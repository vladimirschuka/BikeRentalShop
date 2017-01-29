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


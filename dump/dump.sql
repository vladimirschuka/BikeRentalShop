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
	returning bike_state_id into new_bike_state_id;
		
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
-- Name: dict_booking_order_states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_booking_order_states (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    state_code character varying(250),
    state_name character varying(250),
    order_state integer,
    finish_state_flag boolean
);


ALTER TABLE dict_booking_order_states OWNER TO postgres;

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
-- Name: t_booking_consist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_booking_consist (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    booking_id integer NOT NULL,
    bike_model_id integer,
    period_beg_date timestamp without time zone,
    period_end_date timestamp without time zone,
    bikes_count integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_booking_consist OWNER TO postgres;

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
    price_per_one double precision,
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
-- Name: t_prices_base_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices_base_plans (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    beg_date timestamp without time zone,
    end_date timestamp without time zone,
    bike_model_id integer,
    currency_id integer,
    price double precision,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    price_plan_id integer
);


ALTER TABLE t_prices_base_plans OWNER TO postgres;

--
-- Name: t_prices_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices_plans (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    price_code character varying(250),
    price_name character varying(250),
    price_dscr text,
    price_sum_flag boolean,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_prices_plans OWNER TO postgres;

--
-- Name: t_prices_specials_conditions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices_specials_conditions (
    id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    price_plan_id integer,
    beg_date_order timestamp without time zone,
    end_date_order timestamp without time zone,
    pediod_beg_date timestamp without time zone,
    pediod_end_date timestamp without time zone,
    bike_model_id integer,
    customer_group_id integer,
    bike_count integer,
    period_order_in_hour integer,
    val_id integer,
    prct_flag boolean,
    price_specials_value double precision,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
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
10211	giant_black_mountain	Giant Black Mountain bike	10002	10005	10009	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10212	giant_black_road	Giant Black Road bike	10002	10006	10009	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10213	giant_black_bmx	Giant Black BMX bike	10002	10007	10009	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10214	giant_black_other	Giant Black Other bike	10002	10008	10009	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10215	giant_black_child	Giant Black Childrens	10002	10018	10009	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10216	giant_white_mountain	Giant White Mountain bike	10002	10005	10010	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10217	giant_white_road	Giant White Road bike	10002	10006	10010	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10218	giant_white_bmx	Giant White BMX bike	10002	10007	10010	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10219	giant_white_other	Giant White Other bike	10002	10008	10010	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10220	giant_white_child	Giant White Childrens	10002	10018	10010	18	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10221	giant_red_mountain	Giant Red Mountain bike	10002	10005	10011	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10222	giant_red_road	Giant Red Road bike	10002	10006	10011	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10223	giant_red_bmx	Giant Red BMX bike	10002	10007	10011	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10224	giant_red_other	Giant Red Other bike	10002	10008	10011	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10225	giant_red_child	Giant Red Childrens	10002	10018	10011	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10226	giant_green_mountain	Giant Green Mountain bike	10002	10005	10012	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10227	giant_green_road	Giant Green Road bike	10002	10006	10012	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10228	giant_green_bmx	Giant Green BMX bike	10002	10007	10012	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10229	giant_green_other	Giant Green Other bike	10002	10008	10012	18	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10230	giant_green_child	Giant Green Childrens	10002	10018	10012	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10231	giant_blue_mountain	Giant Blue Mountain bike	10002	10005	10013	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10232	giant_blue_road	Giant Blue Road bike	10002	10006	10013	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10233	giant_blue_bmx	Giant Blue BMX bike	10002	10007	10013	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10234	giant_blue_other	Giant Blue Other bike	10002	10008	10013	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10235	giant_blue_child	Giant Blue Childrens	10002	10018	10013	18	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10236	giant_yellow_mountain	Giant Yellow Mountain bike	10002	10005	10024	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10237	giant_yellow_road	Giant Yellow Road bike	10002	10006	10024	18	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10238	giant_yellow_bmx	Giant Yellow BMX bike	10002	10007	10024	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10239	giant_yellow_other	Giant Yellow Other bike	10002	10008	10024	18	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10240	giant_yellow_child	Giant Yellow Childrens	10002	10018	10024	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10241	trek_black_mountain	Trek Black Mountain bike	10003	10005	10009	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10242	trek_black_road	Trek Black Road bike	10003	10006	10009	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10243	trek_black_bmx	Trek Black BMX bike	10003	10007	10009	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10244	trek_black_other	Trek Black Other bike	10003	10008	10009	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10245	trek_black_child	Trek Black Childrens	10003	10018	10009	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10246	trek_white_mountain	Trek White Mountain bike	10003	10005	10010	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10247	trek_white_road	Trek White Road bike	10003	10006	10010	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10248	trek_white_bmx	Trek White BMX bike	10003	10007	10010	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10249	trek_white_other	Trek White Other bike	10003	10008	10010	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10250	trek_white_child	Trek White Childrens	10003	10018	10010	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10251	trek_red_mountain	Trek Red Mountain bike	10003	10005	10011	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10252	trek_red_road	Trek Red Road bike	10003	10006	10011	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10253	trek_red_bmx	Trek Red BMX bike	10003	10007	10011	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10254	trek_red_other	Trek Red Other bike	10003	10008	10011	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10255	trek_red_child	Trek Red Childrens	10003	10018	10011	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10256	trek_green_mountain	Trek Green Mountain bike	10003	10005	10012	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10257	trek_green_road	Trek Green Road bike	10003	10006	10012	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10258	trek_green_bmx	Trek Green BMX bike	10003	10007	10012	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10259	trek_green_other	Trek Green Other bike	10003	10008	10012	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10260	trek_green_child	Trek Green Childrens	10003	10018	10012	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10261	trek_blue_mountain	Trek Blue Mountain bike	10003	10005	10013	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10262	trek_blue_road	Trek Blue Road bike	10003	10006	10013	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10263	trek_blue_bmx	Trek Blue BMX bike	10003	10007	10013	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10264	trek_blue_other	Trek Blue Other bike	10003	10008	10013	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10265	trek_blue_child	Trek Blue Childrens	10003	10018	10013	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10266	trek_yellow_mountain	Trek Yellow Mountain bike	10003	10005	10024	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10267	trek_yellow_road	Trek Yellow Road bike	10003	10006	10024	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10268	trek_yellow_bmx	Trek Yellow BMX bike	10003	10007	10024	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10269	trek_yellow_other	Trek Yellow Other bike	10003	10008	10024	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10270	trek_yellow_child	Trek Yellow Childrens	10003	10018	10024	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10271	btwin_black_mountain	B'Twin Black Mountain bike	10004	10005	10009	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10272	btwin_black_road	B'Twin Black Road bike	10004	10006	10009	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10273	btwin_black_bmx	B'Twin Black BMX bike	10004	10007	10009	18	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10274	btwin_black_other	B'Twin Black Other bike	10004	10008	10009	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10275	btwin_black_child	B'Twin Black Childrens	10004	10018	10009	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10276	btwin_white_mountain	B'Twin White Mountain bike	10004	10005	10010	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10277	btwin_white_road	B'Twin White Road bike	10004	10006	10010	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10278	btwin_white_bmx	B'Twin White BMX bike	10004	10007	10010	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10279	btwin_white_other	B'Twin White Other bike	10004	10008	10010	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10280	btwin_white_child	B'Twin White Childrens	10004	10018	10010	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10281	btwin_red_mountain	B'Twin Red Mountain bike	10004	10005	10011	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10282	btwin_red_road	B'Twin Red Road bike	10004	10006	10011	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10283	btwin_red_bmx	B'Twin Red BMX bike	10004	10007	10011	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10284	btwin_red_other	B'Twin Red Other bike	10004	10008	10011	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10285	btwin_red_child	B'Twin Red Childrens	10004	10018	10011	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10286	btwin_green_mountain	B'Twin Green Mountain bike	10004	10005	10012	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10287	btwin_green_road	B'Twin Green Road bike	10004	10006	10012	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10288	btwin_green_bmx	B'Twin Green BMX bike	10004	10007	10012	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10289	btwin_green_other	B'Twin Green Other bike	10004	10008	10012	18	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10290	btwin_green_child	B'Twin Green Childrens	10004	10018	10012	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10291	btwin_blue_mountain	B'Twin Blue Mountain bike	10004	10005	10013	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10292	btwin_blue_road	B'Twin Blue Road bike	10004	10006	10013	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10293	btwin_blue_bmx	B'Twin Blue BMX bike	10004	10007	10013	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10294	btwin_blue_other	B'Twin Blue Other bike	10004	10008	10013	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10295	btwin_blue_child	B'Twin Blue Childrens	10004	10018	10013	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10296	btwin_yellow_mountain	B'Twin Yellow Mountain bike	10004	10005	10024	18	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10297	btwin_yellow_road	B'Twin Yellow Road bike	10004	10006	10024	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10298	btwin_yellow_bmx	B'Twin Yellow BMX bike	10004	10007	10024	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10299	btwin_yellow_other	B'Twin Yellow Other bike	10004	10008	10024	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10300	btwin_yellow_child	B'Twin Yellow Childrens	10004	10018	10024	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10301	forward_black_mountain	Forward Black Mountain bike	10025	10005	10009	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10302	forward_black_road	Forward Black Road bike	10025	10006	10009	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10303	forward_black_bmx	Forward Black BMX bike	10025	10007	10009	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10304	forward_black_other	Forward Black Other bike	10025	10008	10009	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10305	forward_black_child	Forward Black Childrens	10025	10018	10009	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10306	forward_white_mountain	Forward White Mountain bike	10025	10005	10010	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10307	forward_white_road	Forward White Road bike	10025	10006	10010	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10308	forward_white_bmx	Forward White BMX bike	10025	10007	10010	18	26	10	2016	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10309	forward_white_other	Forward White Other bike	10025	10008	10010	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10310	forward_white_child	Forward White Childrens	10025	10018	10010	18	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10311	forward_red_mountain	Forward Red Mountain bike	10025	10005	10011	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10312	forward_red_road	Forward Red Road bike	10025	10006	10011	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10313	forward_red_bmx	Forward Red BMX bike	10025	10007	10011	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10314	forward_red_other	Forward Red Other bike	10025	10008	10011	18	26	10	2016	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10315	forward_red_child	Forward Red Childrens	10025	10018	10011	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10316	forward_green_mountain	Forward Green Mountain bike	10025	10005	10012	18	26	10	2015	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10317	forward_green_road	Forward Green Road bike	10025	10006	10012	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10318	forward_green_bmx	Forward Green BMX bike	10025	10007	10012	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10319	forward_green_other	Forward Green Other bike	10025	10008	10012	18	26	10	2016	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10320	forward_green_child	Forward Green Childrens	10025	10018	10012	18	26	10	2014	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10321	forward_blue_mountain	Forward Blue Mountain bike	10025	10005	10013	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10322	forward_blue_road	Forward Blue Road bike	10025	10006	10013	18	26	10	2015	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10323	forward_blue_bmx	Forward Blue BMX bike	10025	10007	10013	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10324	forward_blue_other	Forward Blue Other bike	10025	10008	10013	18	26	10	2015	t	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10325	forward_blue_child	Forward Blue Childrens	10025	10018	10013	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10326	forward_yellow_mountain	Forward Yellow Mountain bike	10025	10005	10024	18	26	10	2014	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10327	forward_yellow_road	Forward Yellow Road bike	10025	10006	10024	18	26	10	2014	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10328	forward_yellow_bmx	Forward Yellow BMX bike	10025	10007	10024	18	26	10	2014	f	f	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10329	forward_yellow_other	Forward Yellow Other bike	10025	10008	10024	18	26	10	2016	t	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
10330	forward_yellow_child	Forward Yellow Childrens	10025	10018	10024	18	26	10	2015	f	t	2017-01-08 04:08:27.991938	2017-01-08 02:13:22.870837
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
-- Data for Name: dict_booking_order_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_booking_order_states (id, state_code, state_name, order_state, finish_state_flag) FROM stdin;
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
-- Name: main_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('main_sequence', 17541, true);


--
-- Data for Name: t_bikes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_bikes (bike_id, bike_inventory_number, bike_model_id, bike_use_beg_date, bike_price, bike_current_state_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_bikes_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_bikes_states (id, bike_id, bike_state_id, bike_state_date) FROM stdin;
\.


--
-- Data for Name: t_booking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking (booking_id, booking_time, booking_code, customer_id, booking_state_id, updated_at) FROM stdin;
\.


--
-- Data for Name: t_booking_consist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking_consist (id, booking_id, bike_model_id, period_beg_date, period_end_date, bikes_count, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_booking_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking_orders (id, booking_id, bike_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_booking_prices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_booking_prices (id, t_price_plans_id, booking_consist_id, currency_id, price_per_one, price, created_at, updated_at) FROM stdin;
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
-- Data for Name: t_prices_base_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices_base_plans (id, beg_date, end_date, bike_model_id, currency_id, price, created_at, updated_at, price_plan_id) FROM stdin;
16582	2000-01-01 00:00:00	2016-05-31 18:59:59	10211	10030	12	2017-01-23 18:14:11.784798	2017-01-23 18:14:11.784798	16575
16583	2000-01-01 00:00:00	2016-05-31 18:59:59	10211	10031	10	2017-01-23 18:14:11.79384	2017-01-23 18:14:11.79384	16575
16584	2016-06-01 00:00:00	2016-08-31 18:59:59	10211	10030	10	2017-01-23 18:14:11.799712	2017-01-23 18:14:11.799712	16575
16585	2016-06-01 00:00:00	2016-08-31 18:59:59	10211	10031	11	2017-01-23 18:14:11.80523	2017-01-23 18:14:11.80523	16575
16586	2016-09-01 00:00:00	2016-12-31 18:59:59	10211	10030	13	2017-01-23 18:14:11.811319	2017-01-23 18:14:11.811319	16575
16587	2016-09-01 00:00:00	2016-12-31 18:59:59	10211	10031	12	2017-01-23 18:14:11.816714	2017-01-23 18:14:11.816714	16575
16588	2017-01-01 00:00:00	2099-12-31 18:59:59	10211	10030	10	2017-01-23 18:14:11.822794	2017-01-23 18:14:11.822794	16575
16589	2017-01-01 00:00:00	2099-12-31 18:59:59	10211	10031	10	2017-01-23 18:14:11.827439	2017-01-23 18:14:11.827439	16575
16590	2000-01-01 00:00:00	2016-05-31 18:59:59	10212	10030	12	2017-01-23 18:14:11.83315	2017-01-23 18:14:11.83315	16575
16591	2000-01-01 00:00:00	2016-05-31 18:59:59	10212	10031	11	2017-01-23 18:14:11.839956	2017-01-23 18:14:11.839956	16575
16592	2016-06-01 00:00:00	2016-08-31 18:59:59	10212	10030	10	2017-01-23 18:14:11.845738	2017-01-23 18:14:11.845738	16575
16593	2016-06-01 00:00:00	2016-08-31 18:59:59	10212	10031	13	2017-01-23 18:14:11.851591	2017-01-23 18:14:11.851591	16575
16594	2016-09-01 00:00:00	2016-12-31 18:59:59	10212	10030	12	2017-01-23 18:14:11.857745	2017-01-23 18:14:11.857745	16575
16595	2016-09-01 00:00:00	2016-12-31 18:59:59	10212	10031	14	2017-01-23 18:14:11.862688	2017-01-23 18:14:11.862688	16575
16596	2017-01-01 00:00:00	2099-12-31 18:59:59	10212	10030	13	2017-01-23 18:14:11.86871	2017-01-23 18:14:11.86871	16575
16597	2017-01-01 00:00:00	2099-12-31 18:59:59	10212	10031	13	2017-01-23 18:14:11.874731	2017-01-23 18:14:11.874731	16575
16598	2000-01-01 00:00:00	2016-05-31 18:59:59	10213	10030	14	2017-01-23 18:14:11.880709	2017-01-23 18:14:11.880709	16575
16599	2000-01-01 00:00:00	2016-05-31 18:59:59	10213	10031	14	2017-01-23 18:14:11.88559	2017-01-23 18:14:11.88559	16575
16600	2016-06-01 00:00:00	2016-08-31 18:59:59	10213	10030	12	2017-01-23 18:14:11.891602	2017-01-23 18:14:11.891602	16575
16601	2016-06-01 00:00:00	2016-08-31 18:59:59	10213	10031	12	2017-01-23 18:14:11.89665	2017-01-23 18:14:11.89665	16575
16602	2016-09-01 00:00:00	2016-12-31 18:59:59	10213	10030	14	2017-01-23 18:14:11.902933	2017-01-23 18:14:11.902933	16575
16603	2016-09-01 00:00:00	2016-12-31 18:59:59	10213	10031	10	2017-01-23 18:14:11.909474	2017-01-23 18:14:11.909474	16575
16604	2017-01-01 00:00:00	2099-12-31 18:59:59	10213	10030	11	2017-01-23 18:14:11.915212	2017-01-23 18:14:11.915212	16575
16605	2017-01-01 00:00:00	2099-12-31 18:59:59	10213	10031	12	2017-01-23 18:14:11.920387	2017-01-23 18:14:11.920387	16575
16606	2000-01-01 00:00:00	2016-05-31 18:59:59	10214	10030	14	2017-01-23 18:14:11.926284	2017-01-23 18:14:11.926284	16575
16607	2000-01-01 00:00:00	2016-05-31 18:59:59	10214	10031	13	2017-01-23 18:14:11.931118	2017-01-23 18:14:11.931118	16575
16608	2016-06-01 00:00:00	2016-08-31 18:59:59	10214	10030	11	2017-01-23 18:14:11.936714	2017-01-23 18:14:11.936714	16575
16609	2016-06-01 00:00:00	2016-08-31 18:59:59	10214	10031	12	2017-01-23 18:14:11.941738	2017-01-23 18:14:11.941738	16575
16610	2016-09-01 00:00:00	2016-12-31 18:59:59	10214	10030	12	2017-01-23 18:14:11.947105	2017-01-23 18:14:11.947105	16575
16611	2016-09-01 00:00:00	2016-12-31 18:59:59	10214	10031	10	2017-01-23 18:14:11.951899	2017-01-23 18:14:11.951899	16575
16612	2017-01-01 00:00:00	2099-12-31 18:59:59	10214	10030	13	2017-01-23 18:14:11.957524	2017-01-23 18:14:11.957524	16575
16613	2017-01-01 00:00:00	2099-12-31 18:59:59	10214	10031	13	2017-01-23 18:14:11.962349	2017-01-23 18:14:11.962349	16575
16614	2000-01-01 00:00:00	2016-05-31 18:59:59	10215	10030	13	2017-01-23 18:14:11.96815	2017-01-23 18:14:11.96815	16575
16615	2000-01-01 00:00:00	2016-05-31 18:59:59	10215	10031	14	2017-01-23 18:14:11.973166	2017-01-23 18:14:11.973166	16575
16616	2016-06-01 00:00:00	2016-08-31 18:59:59	10215	10030	10	2017-01-23 18:14:11.9788	2017-01-23 18:14:11.9788	16575
16617	2016-06-01 00:00:00	2016-08-31 18:59:59	10215	10031	11	2017-01-23 18:14:11.983761	2017-01-23 18:14:11.983761	16575
16618	2016-09-01 00:00:00	2016-12-31 18:59:59	10215	10030	13	2017-01-23 18:14:11.990943	2017-01-23 18:14:11.990943	16575
16619	2016-09-01 00:00:00	2016-12-31 18:59:59	10215	10031	11	2017-01-23 18:14:11.995647	2017-01-23 18:14:11.995647	16575
16620	2017-01-01 00:00:00	2099-12-31 18:59:59	10215	10030	13	2017-01-23 18:14:12.001427	2017-01-23 18:14:12.001427	16575
16621	2017-01-01 00:00:00	2099-12-31 18:59:59	10215	10031	10	2017-01-23 18:14:12.00681	2017-01-23 18:14:12.00681	16575
16622	2000-01-01 00:00:00	2016-05-31 18:59:59	10216	10030	10	2017-01-23 18:14:12.012475	2017-01-23 18:14:12.012475	16575
16623	2000-01-01 00:00:00	2016-05-31 18:59:59	10216	10031	13	2017-01-23 18:14:12.017443	2017-01-23 18:14:12.017443	16575
16624	2016-06-01 00:00:00	2016-08-31 18:59:59	10216	10030	14	2017-01-23 18:14:12.023212	2017-01-23 18:14:12.023212	16575
16625	2016-06-01 00:00:00	2016-08-31 18:59:59	10216	10031	12	2017-01-23 18:14:12.028257	2017-01-23 18:14:12.028257	16575
16626	2016-09-01 00:00:00	2016-12-31 18:59:59	10216	10030	13	2017-01-23 18:14:12.033982	2017-01-23 18:14:12.033982	16575
16627	2016-09-01 00:00:00	2016-12-31 18:59:59	10216	10031	11	2017-01-23 18:14:12.039238	2017-01-23 18:14:12.039238	16575
16628	2017-01-01 00:00:00	2099-12-31 18:59:59	10216	10030	12	2017-01-23 18:14:12.044826	2017-01-23 18:14:12.044826	16575
16629	2017-01-01 00:00:00	2099-12-31 18:59:59	10216	10031	14	2017-01-23 18:14:12.049691	2017-01-23 18:14:12.049691	16575
16630	2000-01-01 00:00:00	2016-05-31 18:59:59	10217	10030	14	2017-01-23 18:14:12.055644	2017-01-23 18:14:12.055644	16575
16631	2000-01-01 00:00:00	2016-05-31 18:59:59	10217	10031	12	2017-01-23 18:14:12.0607	2017-01-23 18:14:12.0607	16575
16632	2016-06-01 00:00:00	2016-08-31 18:59:59	10217	10030	10	2017-01-23 18:14:12.066607	2017-01-23 18:14:12.066607	16575
16633	2016-06-01 00:00:00	2016-08-31 18:59:59	10217	10031	14	2017-01-23 18:14:12.071563	2017-01-23 18:14:12.071563	16575
16634	2016-09-01 00:00:00	2016-12-31 18:59:59	10217	10030	10	2017-01-23 18:14:12.077636	2017-01-23 18:14:12.077636	16575
16635	2016-09-01 00:00:00	2016-12-31 18:59:59	10217	10031	11	2017-01-23 18:14:12.083482	2017-01-23 18:14:12.083482	16575
16636	2017-01-01 00:00:00	2099-12-31 18:59:59	10217	10030	13	2017-01-23 18:14:12.089539	2017-01-23 18:14:12.089539	16575
16637	2017-01-01 00:00:00	2099-12-31 18:59:59	10217	10031	12	2017-01-23 18:14:12.094811	2017-01-23 18:14:12.094811	16575
16638	2000-01-01 00:00:00	2016-05-31 18:59:59	10218	10030	10	2017-01-23 18:14:12.100787	2017-01-23 18:14:12.100787	16575
16639	2000-01-01 00:00:00	2016-05-31 18:59:59	10218	10031	10	2017-01-23 18:14:12.106596	2017-01-23 18:14:12.106596	16575
16640	2016-06-01 00:00:00	2016-08-31 18:59:59	10218	10030	12	2017-01-23 18:14:12.112584	2017-01-23 18:14:12.112584	16575
16641	2016-06-01 00:00:00	2016-08-31 18:59:59	10218	10031	12	2017-01-23 18:14:12.117643	2017-01-23 18:14:12.117643	16575
16642	2016-09-01 00:00:00	2016-12-31 18:59:59	10218	10030	11	2017-01-23 18:14:12.123455	2017-01-23 18:14:12.123455	16575
16643	2016-09-01 00:00:00	2016-12-31 18:59:59	10218	10031	14	2017-01-23 18:14:12.128391	2017-01-23 18:14:12.128391	16575
16644	2017-01-01 00:00:00	2099-12-31 18:59:59	10218	10030	11	2017-01-23 18:14:12.134249	2017-01-23 18:14:12.134249	16575
16645	2017-01-01 00:00:00	2099-12-31 18:59:59	10218	10031	14	2017-01-23 18:14:12.139754	2017-01-23 18:14:12.139754	16575
16646	2000-01-01 00:00:00	2016-05-31 18:59:59	10219	10030	11	2017-01-23 18:14:12.145487	2017-01-23 18:14:12.145487	16575
16647	2000-01-01 00:00:00	2016-05-31 18:59:59	10219	10031	13	2017-01-23 18:14:12.151347	2017-01-23 18:14:12.151347	16575
16648	2016-06-01 00:00:00	2016-08-31 18:59:59	10219	10030	13	2017-01-23 18:14:12.157359	2017-01-23 18:14:12.157359	16575
16649	2016-06-01 00:00:00	2016-08-31 18:59:59	10219	10031	13	2017-01-23 18:14:12.162801	2017-01-23 18:14:12.162801	16575
16650	2016-09-01 00:00:00	2016-12-31 18:59:59	10219	10030	13	2017-01-23 18:14:12.168332	2017-01-23 18:14:12.168332	16575
16651	2016-09-01 00:00:00	2016-12-31 18:59:59	10219	10031	11	2017-01-23 18:14:12.17401	2017-01-23 18:14:12.17401	16575
16652	2017-01-01 00:00:00	2099-12-31 18:59:59	10219	10030	10	2017-01-23 18:14:12.179681	2017-01-23 18:14:12.179681	16575
16653	2017-01-01 00:00:00	2099-12-31 18:59:59	10219	10031	11	2017-01-23 18:14:12.185001	2017-01-23 18:14:12.185001	16575
16654	2000-01-01 00:00:00	2016-05-31 18:59:59	10220	10030	14	2017-01-23 18:14:12.190921	2017-01-23 18:14:12.190921	16575
16655	2000-01-01 00:00:00	2016-05-31 18:59:59	10220	10031	14	2017-01-23 18:14:12.196018	2017-01-23 18:14:12.196018	16575
16656	2016-06-01 00:00:00	2016-08-31 18:59:59	10220	10030	10	2017-01-23 18:14:12.201615	2017-01-23 18:14:12.201615	16575
16657	2016-06-01 00:00:00	2016-08-31 18:59:59	10220	10031	10	2017-01-23 18:14:12.207011	2017-01-23 18:14:12.207011	16575
16658	2016-09-01 00:00:00	2016-12-31 18:59:59	10220	10030	10	2017-01-23 18:14:12.21274	2017-01-23 18:14:12.21274	16575
16659	2016-09-01 00:00:00	2016-12-31 18:59:59	10220	10031	12	2017-01-23 18:14:12.218599	2017-01-23 18:14:12.218599	16575
16660	2017-01-01 00:00:00	2099-12-31 18:59:59	10220	10030	10	2017-01-23 18:14:12.22446	2017-01-23 18:14:12.22446	16575
16661	2017-01-01 00:00:00	2099-12-31 18:59:59	10220	10031	12	2017-01-23 18:14:12.229337	2017-01-23 18:14:12.229337	16575
16662	2000-01-01 00:00:00	2016-05-31 18:59:59	10221	10030	10	2017-01-23 18:14:12.235341	2017-01-23 18:14:12.235341	16575
16663	2000-01-01 00:00:00	2016-05-31 18:59:59	10221	10031	14	2017-01-23 18:14:12.240444	2017-01-23 18:14:12.240444	16575
16664	2016-06-01 00:00:00	2016-08-31 18:59:59	10221	10030	12	2017-01-23 18:14:12.24596	2017-01-23 18:14:12.24596	16575
16665	2016-06-01 00:00:00	2016-08-31 18:59:59	10221	10031	13	2017-01-23 18:14:12.251369	2017-01-23 18:14:12.251369	16575
16666	2016-09-01 00:00:00	2016-12-31 18:59:59	10221	10030	14	2017-01-23 18:14:12.257164	2017-01-23 18:14:12.257164	16575
16667	2016-09-01 00:00:00	2016-12-31 18:59:59	10221	10031	12	2017-01-23 18:14:12.262243	2017-01-23 18:14:12.262243	16575
16668	2017-01-01 00:00:00	2099-12-31 18:59:59	10221	10030	11	2017-01-23 18:14:12.268102	2017-01-23 18:14:12.268102	16575
16669	2017-01-01 00:00:00	2099-12-31 18:59:59	10221	10031	14	2017-01-23 18:14:12.27333	2017-01-23 18:14:12.27333	16575
16670	2000-01-01 00:00:00	2016-05-31 18:59:59	10222	10030	10	2017-01-23 18:14:12.279264	2017-01-23 18:14:12.279264	16575
16671	2000-01-01 00:00:00	2016-05-31 18:59:59	10222	10031	14	2017-01-23 18:14:12.284682	2017-01-23 18:14:12.284682	16575
16672	2016-06-01 00:00:00	2016-08-31 18:59:59	10222	10030	12	2017-01-23 18:14:12.290471	2017-01-23 18:14:12.290471	16575
16673	2016-06-01 00:00:00	2016-08-31 18:59:59	10222	10031	14	2017-01-23 18:14:12.295949	2017-01-23 18:14:12.295949	16575
16674	2016-09-01 00:00:00	2016-12-31 18:59:59	10222	10030	12	2017-01-23 18:14:12.301696	2017-01-23 18:14:12.301696	16575
16675	2016-09-01 00:00:00	2016-12-31 18:59:59	10222	10031	13	2017-01-23 18:14:12.306669	2017-01-23 18:14:12.306669	16575
16676	2017-01-01 00:00:00	2099-12-31 18:59:59	10222	10030	10	2017-01-23 18:14:12.312784	2017-01-23 18:14:12.312784	16575
16677	2017-01-01 00:00:00	2099-12-31 18:59:59	10222	10031	12	2017-01-23 18:14:12.317945	2017-01-23 18:14:12.317945	16575
16678	2000-01-01 00:00:00	2016-05-31 18:59:59	10223	10030	13	2017-01-23 18:14:12.32358	2017-01-23 18:14:12.32358	16575
16679	2000-01-01 00:00:00	2016-05-31 18:59:59	10223	10031	13	2017-01-23 18:14:12.328976	2017-01-23 18:14:12.328976	16575
16680	2016-06-01 00:00:00	2016-08-31 18:59:59	10223	10030	13	2017-01-23 18:14:12.335431	2017-01-23 18:14:12.335431	16575
16681	2016-06-01 00:00:00	2016-08-31 18:59:59	10223	10031	14	2017-01-23 18:14:12.341476	2017-01-23 18:14:12.341476	16575
16682	2016-09-01 00:00:00	2016-12-31 18:59:59	10223	10030	12	2017-01-23 18:14:12.347763	2017-01-23 18:14:12.347763	16575
16683	2016-09-01 00:00:00	2016-12-31 18:59:59	10223	10031	13	2017-01-23 18:14:12.352811	2017-01-23 18:14:12.352811	16575
16684	2017-01-01 00:00:00	2099-12-31 18:59:59	10223	10030	13	2017-01-23 18:14:12.358354	2017-01-23 18:14:12.358354	16575
16685	2017-01-01 00:00:00	2099-12-31 18:59:59	10223	10031	12	2017-01-23 18:14:12.363918	2017-01-23 18:14:12.363918	16575
16686	2000-01-01 00:00:00	2016-05-31 18:59:59	10224	10030	10	2017-01-23 18:14:12.369813	2017-01-23 18:14:12.369813	16575
16687	2000-01-01 00:00:00	2016-05-31 18:59:59	10224	10031	12	2017-01-23 18:14:12.374721	2017-01-23 18:14:12.374721	16575
16688	2016-06-01 00:00:00	2016-08-31 18:59:59	10224	10030	14	2017-01-23 18:14:12.380428	2017-01-23 18:14:12.380428	16575
16689	2016-06-01 00:00:00	2016-08-31 18:59:59	10224	10031	12	2017-01-23 18:14:12.385533	2017-01-23 18:14:12.385533	16575
16690	2016-09-01 00:00:00	2016-12-31 18:59:59	10224	10030	12	2017-01-23 18:14:12.391548	2017-01-23 18:14:12.391548	16575
16691	2016-09-01 00:00:00	2016-12-31 18:59:59	10224	10031	12	2017-01-23 18:14:12.397102	2017-01-23 18:14:12.397102	16575
16692	2017-01-01 00:00:00	2099-12-31 18:59:59	10224	10030	12	2017-01-23 18:14:12.403177	2017-01-23 18:14:12.403177	16575
16693	2017-01-01 00:00:00	2099-12-31 18:59:59	10224	10031	13	2017-01-23 18:14:12.408616	2017-01-23 18:14:12.408616	16575
16694	2000-01-01 00:00:00	2016-05-31 18:59:59	10225	10030	10	2017-01-23 18:14:12.414246	2017-01-23 18:14:12.414246	16575
16695	2000-01-01 00:00:00	2016-05-31 18:59:59	10225	10031	14	2017-01-23 18:14:12.419658	2017-01-23 18:14:12.419658	16575
16696	2016-06-01 00:00:00	2016-08-31 18:59:59	10225	10030	14	2017-01-23 18:14:12.425813	2017-01-23 18:14:12.425813	16575
16697	2016-06-01 00:00:00	2016-08-31 18:59:59	10225	10031	12	2017-01-23 18:14:12.430734	2017-01-23 18:14:12.430734	16575
16698	2016-09-01 00:00:00	2016-12-31 18:59:59	10225	10030	12	2017-01-23 18:14:12.436546	2017-01-23 18:14:12.436546	16575
16699	2016-09-01 00:00:00	2016-12-31 18:59:59	10225	10031	10	2017-01-23 18:14:12.441751	2017-01-23 18:14:12.441751	16575
16700	2017-01-01 00:00:00	2099-12-31 18:59:59	10225	10030	10	2017-01-23 18:14:12.44836	2017-01-23 18:14:12.44836	16575
16701	2017-01-01 00:00:00	2099-12-31 18:59:59	10225	10031	11	2017-01-23 18:14:12.453205	2017-01-23 18:14:12.453205	16575
16702	2000-01-01 00:00:00	2016-05-31 18:59:59	10226	10030	10	2017-01-23 18:14:12.459043	2017-01-23 18:14:12.459043	16575
16703	2000-01-01 00:00:00	2016-05-31 18:59:59	10226	10031	12	2017-01-23 18:14:12.464309	2017-01-23 18:14:12.464309	16575
16704	2016-06-01 00:00:00	2016-08-31 18:59:59	10226	10030	12	2017-01-23 18:14:12.469837	2017-01-23 18:14:12.469837	16575
16705	2016-06-01 00:00:00	2016-08-31 18:59:59	10226	10031	13	2017-01-23 18:14:12.475196	2017-01-23 18:14:12.475196	16575
16706	2016-09-01 00:00:00	2016-12-31 18:59:59	10226	10030	10	2017-01-23 18:14:12.48101	2017-01-23 18:14:12.48101	16575
16707	2016-09-01 00:00:00	2016-12-31 18:59:59	10226	10031	13	2017-01-23 18:14:12.486131	2017-01-23 18:14:12.486131	16575
16708	2017-01-01 00:00:00	2099-12-31 18:59:59	10226	10030	11	2017-01-23 18:14:12.491676	2017-01-23 18:14:12.491676	16575
16709	2017-01-01 00:00:00	2099-12-31 18:59:59	10226	10031	11	2017-01-23 18:14:12.496494	2017-01-23 18:14:12.496494	16575
16710	2000-01-01 00:00:00	2016-05-31 18:59:59	10227	10030	10	2017-01-23 18:14:12.502303	2017-01-23 18:14:12.502303	16575
16711	2000-01-01 00:00:00	2016-05-31 18:59:59	10227	10031	12	2017-01-23 18:14:12.507496	2017-01-23 18:14:12.507496	16575
16712	2016-06-01 00:00:00	2016-08-31 18:59:59	10227	10030	13	2017-01-23 18:14:12.512975	2017-01-23 18:14:12.512975	16575
16713	2016-06-01 00:00:00	2016-08-31 18:59:59	10227	10031	11	2017-01-23 18:14:12.518379	2017-01-23 18:14:12.518379	16575
16714	2016-09-01 00:00:00	2016-12-31 18:59:59	10227	10030	14	2017-01-23 18:14:12.524406	2017-01-23 18:14:12.524406	16575
16715	2016-09-01 00:00:00	2016-12-31 18:59:59	10227	10031	11	2017-01-23 18:14:12.529137	2017-01-23 18:14:12.529137	16575
16716	2017-01-01 00:00:00	2099-12-31 18:59:59	10227	10030	11	2017-01-23 18:14:12.534845	2017-01-23 18:14:12.534845	16575
16717	2017-01-01 00:00:00	2099-12-31 18:59:59	10227	10031	14	2017-01-23 18:14:12.540121	2017-01-23 18:14:12.540121	16575
16718	2000-01-01 00:00:00	2016-05-31 18:59:59	10228	10030	11	2017-01-23 18:14:12.545758	2017-01-23 18:14:12.545758	16575
16719	2000-01-01 00:00:00	2016-05-31 18:59:59	10228	10031	10	2017-01-23 18:14:12.551239	2017-01-23 18:14:12.551239	16575
16720	2016-06-01 00:00:00	2016-08-31 18:59:59	10228	10030	11	2017-01-23 18:14:12.557825	2017-01-23 18:14:12.557825	16575
16721	2016-06-01 00:00:00	2016-08-31 18:59:59	10228	10031	11	2017-01-23 18:14:12.562971	2017-01-23 18:14:12.562971	16575
16722	2016-09-01 00:00:00	2016-12-31 18:59:59	10228	10030	13	2017-01-23 18:14:12.569626	2017-01-23 18:14:12.569626	16575
16723	2016-09-01 00:00:00	2016-12-31 18:59:59	10228	10031	14	2017-01-23 18:14:12.574711	2017-01-23 18:14:12.574711	16575
16724	2017-01-01 00:00:00	2099-12-31 18:59:59	10228	10030	10	2017-01-23 18:14:12.58058	2017-01-23 18:14:12.58058	16575
16725	2017-01-01 00:00:00	2099-12-31 18:59:59	10228	10031	12	2017-01-23 18:14:12.585691	2017-01-23 18:14:12.585691	16575
16726	2000-01-01 00:00:00	2016-05-31 18:59:59	10229	10030	11	2017-01-23 18:14:12.5917	2017-01-23 18:14:12.5917	16575
16727	2000-01-01 00:00:00	2016-05-31 18:59:59	10229	10031	13	2017-01-23 18:14:12.596684	2017-01-23 18:14:12.596684	16575
16728	2016-06-01 00:00:00	2016-08-31 18:59:59	10229	10030	14	2017-01-23 18:14:12.602939	2017-01-23 18:14:12.602939	16575
16729	2016-06-01 00:00:00	2016-08-31 18:59:59	10229	10031	13	2017-01-23 18:14:12.608458	2017-01-23 18:14:12.608458	16575
16730	2016-09-01 00:00:00	2016-12-31 18:59:59	10229	10030	12	2017-01-23 18:14:12.61481	2017-01-23 18:14:12.61481	16575
16731	2016-09-01 00:00:00	2016-12-31 18:59:59	10229	10031	10	2017-01-23 18:14:12.620622	2017-01-23 18:14:12.620622	16575
16732	2017-01-01 00:00:00	2099-12-31 18:59:59	10229	10030	14	2017-01-23 18:14:12.627751	2017-01-23 18:14:12.627751	16575
16733	2017-01-01 00:00:00	2099-12-31 18:59:59	10229	10031	13	2017-01-23 18:14:12.633744	2017-01-23 18:14:12.633744	16575
16734	2000-01-01 00:00:00	2016-05-31 18:59:59	10230	10030	14	2017-01-23 18:14:12.640401	2017-01-23 18:14:12.640401	16575
16735	2000-01-01 00:00:00	2016-05-31 18:59:59	10230	10031	13	2017-01-23 18:14:12.64608	2017-01-23 18:14:12.64608	16575
16736	2016-06-01 00:00:00	2016-08-31 18:59:59	10230	10030	11	2017-01-23 18:14:12.653593	2017-01-23 18:14:12.653593	16575
16737	2016-06-01 00:00:00	2016-08-31 18:59:59	10230	10031	14	2017-01-23 18:14:12.660022	2017-01-23 18:14:12.660022	16575
16738	2016-09-01 00:00:00	2016-12-31 18:59:59	10230	10030	11	2017-01-23 18:14:12.666801	2017-01-23 18:14:12.666801	16575
16739	2016-09-01 00:00:00	2016-12-31 18:59:59	10230	10031	11	2017-01-23 18:14:12.672973	2017-01-23 18:14:12.672973	16575
16740	2017-01-01 00:00:00	2099-12-31 18:59:59	10230	10030	12	2017-01-23 18:14:12.679243	2017-01-23 18:14:12.679243	16575
16741	2017-01-01 00:00:00	2099-12-31 18:59:59	10230	10031	10	2017-01-23 18:14:12.685662	2017-01-23 18:14:12.685662	16575
16742	2000-01-01 00:00:00	2016-05-31 18:59:59	10231	10030	14	2017-01-23 18:14:12.69167	2017-01-23 18:14:12.69167	16575
16743	2000-01-01 00:00:00	2016-05-31 18:59:59	10231	10031	10	2017-01-23 18:14:12.697068	2017-01-23 18:14:12.697068	16575
16744	2016-06-01 00:00:00	2016-08-31 18:59:59	10231	10030	12	2017-01-23 18:14:12.702715	2017-01-23 18:14:12.702715	16575
16745	2016-06-01 00:00:00	2016-08-31 18:59:59	10231	10031	11	2017-01-23 18:14:12.708086	2017-01-23 18:14:12.708086	16575
16746	2016-09-01 00:00:00	2016-12-31 18:59:59	10231	10030	11	2017-01-23 18:14:12.713824	2017-01-23 18:14:12.713824	16575
16747	2016-09-01 00:00:00	2016-12-31 18:59:59	10231	10031	11	2017-01-23 18:14:12.718951	2017-01-23 18:14:12.718951	16575
16748	2017-01-01 00:00:00	2099-12-31 18:59:59	10231	10030	10	2017-01-23 18:14:12.724826	2017-01-23 18:14:12.724826	16575
16749	2017-01-01 00:00:00	2099-12-31 18:59:59	10231	10031	12	2017-01-23 18:14:12.730209	2017-01-23 18:14:12.730209	16575
16750	2000-01-01 00:00:00	2016-05-31 18:59:59	10232	10030	13	2017-01-23 18:14:12.735777	2017-01-23 18:14:12.735777	16575
16751	2000-01-01 00:00:00	2016-05-31 18:59:59	10232	10031	10	2017-01-23 18:14:12.740703	2017-01-23 18:14:12.740703	16575
16752	2016-06-01 00:00:00	2016-08-31 18:59:59	10232	10030	14	2017-01-23 18:14:12.746469	2017-01-23 18:14:12.746469	16575
16753	2016-06-01 00:00:00	2016-08-31 18:59:59	10232	10031	12	2017-01-23 18:14:12.751734	2017-01-23 18:14:12.751734	16575
16754	2016-09-01 00:00:00	2016-12-31 18:59:59	10232	10030	14	2017-01-23 18:14:12.757726	2017-01-23 18:14:12.757726	16575
16755	2016-09-01 00:00:00	2016-12-31 18:59:59	10232	10031	11	2017-01-23 18:14:12.763109	2017-01-23 18:14:12.763109	16575
16756	2017-01-01 00:00:00	2099-12-31 18:59:59	10232	10030	14	2017-01-23 18:14:12.768915	2017-01-23 18:14:12.768915	16575
16757	2017-01-01 00:00:00	2099-12-31 18:59:59	10232	10031	11	2017-01-23 18:14:12.774247	2017-01-23 18:14:12.774247	16575
16758	2000-01-01 00:00:00	2016-05-31 18:59:59	10233	10030	12	2017-01-23 18:14:12.780029	2017-01-23 18:14:12.780029	16575
16759	2000-01-01 00:00:00	2016-05-31 18:59:59	10233	10031	12	2017-01-23 18:14:12.785465	2017-01-23 18:14:12.785465	16575
16760	2016-06-01 00:00:00	2016-08-31 18:59:59	10233	10030	12	2017-01-23 18:14:12.791072	2017-01-23 18:14:12.791072	16575
16761	2016-06-01 00:00:00	2016-08-31 18:59:59	10233	10031	12	2017-01-23 18:14:12.796285	2017-01-23 18:14:12.796285	16575
16762	2016-09-01 00:00:00	2016-12-31 18:59:59	10233	10030	13	2017-01-23 18:14:12.801912	2017-01-23 18:14:12.801912	16575
16763	2016-09-01 00:00:00	2016-12-31 18:59:59	10233	10031	13	2017-01-23 18:14:12.80702	2017-01-23 18:14:12.80702	16575
16764	2017-01-01 00:00:00	2099-12-31 18:59:59	10233	10030	13	2017-01-23 18:14:12.812715	2017-01-23 18:14:12.812715	16575
16765	2017-01-01 00:00:00	2099-12-31 18:59:59	10233	10031	10	2017-01-23 18:14:12.81791	2017-01-23 18:14:12.81791	16575
16766	2000-01-01 00:00:00	2016-05-31 18:59:59	10234	10030	10	2017-01-23 18:14:12.823957	2017-01-23 18:14:12.823957	16575
16767	2000-01-01 00:00:00	2016-05-31 18:59:59	10234	10031	14	2017-01-23 18:14:12.829703	2017-01-23 18:14:12.829703	16575
16768	2016-06-01 00:00:00	2016-08-31 18:59:59	10234	10030	10	2017-01-23 18:14:12.835381	2017-01-23 18:14:12.835381	16575
16769	2016-06-01 00:00:00	2016-08-31 18:59:59	10234	10031	13	2017-01-23 18:14:12.840857	2017-01-23 18:14:12.840857	16575
16770	2016-09-01 00:00:00	2016-12-31 18:59:59	10234	10030	12	2017-01-23 18:14:12.846778	2017-01-23 18:14:12.846778	16575
16771	2016-09-01 00:00:00	2016-12-31 18:59:59	10234	10031	11	2017-01-23 18:14:12.852125	2017-01-23 18:14:12.852125	16575
16772	2017-01-01 00:00:00	2099-12-31 18:59:59	10234	10030	10	2017-01-23 18:14:12.857996	2017-01-23 18:14:12.857996	16575
16773	2017-01-01 00:00:00	2099-12-31 18:59:59	10234	10031	11	2017-01-23 18:14:12.86291	2017-01-23 18:14:12.86291	16575
16774	2000-01-01 00:00:00	2016-05-31 18:59:59	10235	10030	11	2017-01-23 18:14:12.868479	2017-01-23 18:14:12.868479	16575
16775	2000-01-01 00:00:00	2016-05-31 18:59:59	10235	10031	11	2017-01-23 18:14:12.873734	2017-01-23 18:14:12.873734	16575
16776	2016-06-01 00:00:00	2016-08-31 18:59:59	10235	10030	14	2017-01-23 18:14:12.879504	2017-01-23 18:14:12.879504	16575
16777	2016-06-01 00:00:00	2016-08-31 18:59:59	10235	10031	14	2017-01-23 18:14:12.885129	2017-01-23 18:14:12.885129	16575
16778	2016-09-01 00:00:00	2016-12-31 18:59:59	10235	10030	10	2017-01-23 18:14:12.890867	2017-01-23 18:14:12.890867	16575
16779	2016-09-01 00:00:00	2016-12-31 18:59:59	10235	10031	11	2017-01-23 18:14:12.895988	2017-01-23 18:14:12.895988	16575
16780	2017-01-01 00:00:00	2099-12-31 18:59:59	10235	10030	14	2017-01-23 18:14:12.90157	2017-01-23 18:14:12.90157	16575
16781	2017-01-01 00:00:00	2099-12-31 18:59:59	10235	10031	12	2017-01-23 18:14:12.90677	2017-01-23 18:14:12.90677	16575
16782	2000-01-01 00:00:00	2016-05-31 18:59:59	10236	10030	10	2017-01-23 18:14:12.912575	2017-01-23 18:14:12.912575	16575
16783	2000-01-01 00:00:00	2016-05-31 18:59:59	10236	10031	12	2017-01-23 18:14:12.917595	2017-01-23 18:14:12.917595	16575
16784	2016-06-01 00:00:00	2016-08-31 18:59:59	10236	10030	12	2017-01-23 18:14:12.923437	2017-01-23 18:14:12.923437	16575
16785	2016-06-01 00:00:00	2016-08-31 18:59:59	10236	10031	14	2017-01-23 18:14:12.928446	2017-01-23 18:14:12.928446	16575
16786	2016-09-01 00:00:00	2016-12-31 18:59:59	10236	10030	13	2017-01-23 18:14:12.933925	2017-01-23 18:14:12.933925	16575
16787	2016-09-01 00:00:00	2016-12-31 18:59:59	10236	10031	14	2017-01-23 18:14:12.938802	2017-01-23 18:14:12.938802	16575
16788	2017-01-01 00:00:00	2099-12-31 18:59:59	10236	10030	13	2017-01-23 18:14:12.944473	2017-01-23 18:14:12.944473	16575
16789	2017-01-01 00:00:00	2099-12-31 18:59:59	10236	10031	12	2017-01-23 18:14:12.949709	2017-01-23 18:14:12.949709	16575
16790	2000-01-01 00:00:00	2016-05-31 18:59:59	10237	10030	14	2017-01-23 18:14:12.955683	2017-01-23 18:14:12.955683	16575
16791	2000-01-01 00:00:00	2016-05-31 18:59:59	10237	10031	13	2017-01-23 18:14:12.961028	2017-01-23 18:14:12.961028	16575
16792	2016-06-01 00:00:00	2016-08-31 18:59:59	10237	10030	14	2017-01-23 18:14:12.966754	2017-01-23 18:14:12.966754	16575
16793	2016-06-01 00:00:00	2016-08-31 18:59:59	10237	10031	11	2017-01-23 18:14:12.972029	2017-01-23 18:14:12.972029	16575
16794	2016-09-01 00:00:00	2016-12-31 18:59:59	10237	10030	14	2017-01-23 18:14:12.978667	2017-01-23 18:14:12.978667	16575
16795	2016-09-01 00:00:00	2016-12-31 18:59:59	10237	10031	10	2017-01-23 18:14:12.983928	2017-01-23 18:14:12.983928	16575
16796	2017-01-01 00:00:00	2099-12-31 18:59:59	10237	10030	11	2017-01-23 18:14:12.989603	2017-01-23 18:14:12.989603	16575
16797	2017-01-01 00:00:00	2099-12-31 18:59:59	10237	10031	11	2017-01-23 18:14:12.994809	2017-01-23 18:14:12.994809	16575
16798	2000-01-01 00:00:00	2016-05-31 18:59:59	10238	10030	14	2017-01-23 18:14:13.000693	2017-01-23 18:14:13.000693	16575
16799	2000-01-01 00:00:00	2016-05-31 18:59:59	10238	10031	13	2017-01-23 18:14:13.006113	2017-01-23 18:14:13.006113	16575
16800	2016-06-01 00:00:00	2016-08-31 18:59:59	10238	10030	13	2017-01-23 18:14:13.011736	2017-01-23 18:14:13.011736	16575
16801	2016-06-01 00:00:00	2016-08-31 18:59:59	10238	10031	14	2017-01-23 18:14:13.016571	2017-01-23 18:14:13.016571	16575
16802	2016-09-01 00:00:00	2016-12-31 18:59:59	10238	10030	10	2017-01-23 18:14:13.022245	2017-01-23 18:14:13.022245	16575
16803	2016-09-01 00:00:00	2016-12-31 18:59:59	10238	10031	10	2017-01-23 18:14:13.027388	2017-01-23 18:14:13.027388	16575
16804	2017-01-01 00:00:00	2099-12-31 18:59:59	10238	10030	11	2017-01-23 18:14:13.033787	2017-01-23 18:14:13.033787	16575
16805	2017-01-01 00:00:00	2099-12-31 18:59:59	10238	10031	12	2017-01-23 18:14:13.03887	2017-01-23 18:14:13.03887	16575
16806	2000-01-01 00:00:00	2016-05-31 18:59:59	10239	10030	13	2017-01-23 18:14:13.044308	2017-01-23 18:14:13.044308	16575
16807	2000-01-01 00:00:00	2016-05-31 18:59:59	10239	10031	14	2017-01-23 18:14:13.049551	2017-01-23 18:14:13.049551	16575
16808	2016-06-01 00:00:00	2016-08-31 18:59:59	10239	10030	11	2017-01-23 18:14:13.055335	2017-01-23 18:14:13.055335	16575
16809	2016-06-01 00:00:00	2016-08-31 18:59:59	10239	10031	12	2017-01-23 18:14:13.060189	2017-01-23 18:14:13.060189	16575
16810	2016-09-01 00:00:00	2016-12-31 18:59:59	10239	10030	12	2017-01-23 18:14:13.065683	2017-01-23 18:14:13.065683	16575
16811	2016-09-01 00:00:00	2016-12-31 18:59:59	10239	10031	12	2017-01-23 18:14:13.070862	2017-01-23 18:14:13.070862	16575
16812	2017-01-01 00:00:00	2099-12-31 18:59:59	10239	10030	13	2017-01-23 18:14:13.076856	2017-01-23 18:14:13.076856	16575
16813	2017-01-01 00:00:00	2099-12-31 18:59:59	10239	10031	10	2017-01-23 18:14:13.082011	2017-01-23 18:14:13.082011	16575
16814	2000-01-01 00:00:00	2016-05-31 18:59:59	10240	10030	11	2017-01-23 18:14:13.087791	2017-01-23 18:14:13.087791	16575
16815	2000-01-01 00:00:00	2016-05-31 18:59:59	10240	10031	13	2017-01-23 18:14:13.093062	2017-01-23 18:14:13.093062	16575
16816	2016-06-01 00:00:00	2016-08-31 18:59:59	10240	10030	14	2017-01-23 18:14:13.098995	2017-01-23 18:14:13.098995	16575
16817	2016-06-01 00:00:00	2016-08-31 18:59:59	10240	10031	11	2017-01-23 18:14:13.104055	2017-01-23 18:14:13.104055	16575
16818	2016-09-01 00:00:00	2016-12-31 18:59:59	10240	10030	10	2017-01-23 18:14:13.110034	2017-01-23 18:14:13.110034	16575
16819	2016-09-01 00:00:00	2016-12-31 18:59:59	10240	10031	14	2017-01-23 18:14:13.115085	2017-01-23 18:14:13.115085	16575
16820	2017-01-01 00:00:00	2099-12-31 18:59:59	10240	10030	14	2017-01-23 18:14:13.121631	2017-01-23 18:14:13.121631	16575
16821	2017-01-01 00:00:00	2099-12-31 18:59:59	10240	10031	12	2017-01-23 18:14:13.126923	2017-01-23 18:14:13.126923	16575
16822	2000-01-01 00:00:00	2016-05-31 18:59:59	10241	10030	14	2017-01-23 18:14:13.132427	2017-01-23 18:14:13.132427	16575
16823	2000-01-01 00:00:00	2016-05-31 18:59:59	10241	10031	10	2017-01-23 18:14:13.137508	2017-01-23 18:14:13.137508	16575
16824	2016-06-01 00:00:00	2016-08-31 18:59:59	10241	10030	13	2017-01-23 18:14:13.143476	2017-01-23 18:14:13.143476	16575
16825	2016-06-01 00:00:00	2016-08-31 18:59:59	10241	10031	10	2017-01-23 18:14:13.148828	2017-01-23 18:14:13.148828	16575
16826	2016-09-01 00:00:00	2016-12-31 18:59:59	10241	10030	10	2017-01-23 18:14:13.155105	2017-01-23 18:14:13.155105	16575
16827	2016-09-01 00:00:00	2016-12-31 18:59:59	10241	10031	13	2017-01-23 18:14:13.160162	2017-01-23 18:14:13.160162	16575
16828	2017-01-01 00:00:00	2099-12-31 18:59:59	10241	10030	11	2017-01-23 18:14:13.165435	2017-01-23 18:14:13.165435	16575
16829	2017-01-01 00:00:00	2099-12-31 18:59:59	10241	10031	10	2017-01-23 18:14:13.170792	2017-01-23 18:14:13.170792	16575
16830	2000-01-01 00:00:00	2016-05-31 18:59:59	10242	10030	12	2017-01-23 18:14:13.176678	2017-01-23 18:14:13.176678	16575
16831	2000-01-01 00:00:00	2016-05-31 18:59:59	10242	10031	13	2017-01-23 18:14:13.181849	2017-01-23 18:14:13.181849	16575
16832	2016-06-01 00:00:00	2016-08-31 18:59:59	10242	10030	12	2017-01-23 18:14:13.187423	2017-01-23 18:14:13.187423	16575
16833	2016-06-01 00:00:00	2016-08-31 18:59:59	10242	10031	12	2017-01-23 18:14:13.192719	2017-01-23 18:14:13.192719	16575
16834	2016-09-01 00:00:00	2016-12-31 18:59:59	10242	10030	14	2017-01-23 18:14:13.198564	2017-01-23 18:14:13.198564	16575
16835	2016-09-01 00:00:00	2016-12-31 18:59:59	10242	10031	12	2017-01-23 18:14:13.203752	2017-01-23 18:14:13.203752	16575
16836	2017-01-01 00:00:00	2099-12-31 18:59:59	10242	10030	13	2017-01-23 18:14:13.209607	2017-01-23 18:14:13.209607	16575
16837	2017-01-01 00:00:00	2099-12-31 18:59:59	10242	10031	13	2017-01-23 18:14:13.214923	2017-01-23 18:14:13.214923	16575
16838	2000-01-01 00:00:00	2016-05-31 18:59:59	10243	10030	11	2017-01-23 18:14:13.220718	2017-01-23 18:14:13.220718	16575
16839	2000-01-01 00:00:00	2016-05-31 18:59:59	10243	10031	13	2017-01-23 18:14:13.225709	2017-01-23 18:14:13.225709	16575
16840	2016-06-01 00:00:00	2016-08-31 18:59:59	10243	10030	12	2017-01-23 18:14:13.231702	2017-01-23 18:14:13.231702	16575
16841	2016-06-01 00:00:00	2016-08-31 18:59:59	10243	10031	10	2017-01-23 18:14:13.237278	2017-01-23 18:14:13.237278	16575
16842	2016-09-01 00:00:00	2016-12-31 18:59:59	10243	10030	11	2017-01-23 18:14:13.243086	2017-01-23 18:14:13.243086	16575
16843	2016-09-01 00:00:00	2016-12-31 18:59:59	10243	10031	12	2017-01-23 18:14:13.248093	2017-01-23 18:14:13.248093	16575
16844	2017-01-01 00:00:00	2099-12-31 18:59:59	10243	10030	11	2017-01-23 18:14:13.253775	2017-01-23 18:14:13.253775	16575
16845	2017-01-01 00:00:00	2099-12-31 18:59:59	10243	10031	12	2017-01-23 18:14:13.259248	2017-01-23 18:14:13.259248	16575
16846	2000-01-01 00:00:00	2016-05-31 18:59:59	10244	10030	14	2017-01-23 18:14:13.265793	2017-01-23 18:14:13.265793	16575
16847	2000-01-01 00:00:00	2016-05-31 18:59:59	10244	10031	13	2017-01-23 18:14:13.270965	2017-01-23 18:14:13.270965	16575
16848	2016-06-01 00:00:00	2016-08-31 18:59:59	10244	10030	10	2017-01-23 18:14:13.276625	2017-01-23 18:14:13.276625	16575
16849	2016-06-01 00:00:00	2016-08-31 18:59:59	10244	10031	11	2017-01-23 18:14:13.281732	2017-01-23 18:14:13.281732	16575
16850	2016-09-01 00:00:00	2016-12-31 18:59:59	10244	10030	10	2017-01-23 18:14:13.28712	2017-01-23 18:14:13.28712	16575
16851	2016-09-01 00:00:00	2016-12-31 18:59:59	10244	10031	11	2017-01-23 18:14:13.292413	2017-01-23 18:14:13.292413	16575
16852	2017-01-01 00:00:00	2099-12-31 18:59:59	10244	10030	13	2017-01-23 18:14:13.298067	2017-01-23 18:14:13.298067	16575
16853	2017-01-01 00:00:00	2099-12-31 18:59:59	10244	10031	12	2017-01-23 18:14:13.302885	2017-01-23 18:14:13.302885	16575
16854	2000-01-01 00:00:00	2016-05-31 18:59:59	10245	10030	11	2017-01-23 18:14:13.308767	2017-01-23 18:14:13.308767	16575
16855	2000-01-01 00:00:00	2016-05-31 18:59:59	10245	10031	14	2017-01-23 18:14:13.314593	2017-01-23 18:14:13.314593	16575
16856	2016-06-01 00:00:00	2016-08-31 18:59:59	10245	10030	13	2017-01-23 18:14:13.320256	2017-01-23 18:14:13.320256	16575
16857	2016-06-01 00:00:00	2016-08-31 18:59:59	10245	10031	10	2017-01-23 18:14:13.325237	2017-01-23 18:14:13.325237	16575
16858	2016-09-01 00:00:00	2016-12-31 18:59:59	10245	10030	11	2017-01-23 18:14:13.331185	2017-01-23 18:14:13.331185	16575
16859	2016-09-01 00:00:00	2016-12-31 18:59:59	10245	10031	10	2017-01-23 18:14:13.33655	2017-01-23 18:14:13.33655	16575
16860	2017-01-01 00:00:00	2099-12-31 18:59:59	10245	10030	11	2017-01-23 18:14:13.34243	2017-01-23 18:14:13.34243	16575
16861	2017-01-01 00:00:00	2099-12-31 18:59:59	10245	10031	12	2017-01-23 18:14:13.347298	2017-01-23 18:14:13.347298	16575
16862	2000-01-01 00:00:00	2016-05-31 18:59:59	10246	10030	12	2017-01-23 18:14:13.353353	2017-01-23 18:14:13.353353	16575
16863	2000-01-01 00:00:00	2016-05-31 18:59:59	10246	10031	13	2017-01-23 18:14:13.358428	2017-01-23 18:14:13.358428	16575
16864	2016-06-01 00:00:00	2016-08-31 18:59:59	10246	10030	11	2017-01-23 18:14:13.364196	2017-01-23 18:14:13.364196	16575
16865	2016-06-01 00:00:00	2016-08-31 18:59:59	10246	10031	13	2017-01-23 18:14:13.369446	2017-01-23 18:14:13.369446	16575
16866	2016-09-01 00:00:00	2016-12-31 18:59:59	10246	10030	13	2017-01-23 18:14:13.375025	2017-01-23 18:14:13.375025	16575
16867	2016-09-01 00:00:00	2016-12-31 18:59:59	10246	10031	11	2017-01-23 18:14:13.380191	2017-01-23 18:14:13.380191	16575
16868	2017-01-01 00:00:00	2099-12-31 18:59:59	10246	10030	14	2017-01-23 18:14:13.385726	2017-01-23 18:14:13.385726	16575
16869	2017-01-01 00:00:00	2099-12-31 18:59:59	10246	10031	13	2017-01-23 18:14:13.390793	2017-01-23 18:14:13.390793	16575
16870	2000-01-01 00:00:00	2016-05-31 18:59:59	10247	10030	11	2017-01-23 18:14:13.396354	2017-01-23 18:14:13.396354	16575
16871	2000-01-01 00:00:00	2016-05-31 18:59:59	10247	10031	11	2017-01-23 18:14:13.401581	2017-01-23 18:14:13.401581	16575
16872	2016-06-01 00:00:00	2016-08-31 18:59:59	10247	10030	12	2017-01-23 18:14:13.407337	2017-01-23 18:14:13.407337	16575
16873	2016-06-01 00:00:00	2016-08-31 18:59:59	10247	10031	13	2017-01-23 18:14:13.412932	2017-01-23 18:14:13.412932	16575
16874	2016-09-01 00:00:00	2016-12-31 18:59:59	10247	10030	14	2017-01-23 18:14:13.41876	2017-01-23 18:14:13.41876	16575
16875	2016-09-01 00:00:00	2016-12-31 18:59:59	10247	10031	10	2017-01-23 18:14:13.424038	2017-01-23 18:14:13.424038	16575
16876	2017-01-01 00:00:00	2099-12-31 18:59:59	10247	10030	14	2017-01-23 18:14:13.429588	2017-01-23 18:14:13.429588	16575
16877	2017-01-01 00:00:00	2099-12-31 18:59:59	10247	10031	13	2017-01-23 18:14:13.434715	2017-01-23 18:14:13.434715	16575
16878	2000-01-01 00:00:00	2016-05-31 18:59:59	10248	10030	12	2017-01-23 18:14:13.44062	2017-01-23 18:14:13.44062	16575
16879	2000-01-01 00:00:00	2016-05-31 18:59:59	10248	10031	12	2017-01-23 18:14:13.445743	2017-01-23 18:14:13.445743	16575
16880	2016-06-01 00:00:00	2016-08-31 18:59:59	10248	10030	14	2017-01-23 18:14:13.451693	2017-01-23 18:14:13.451693	16575
16881	2016-06-01 00:00:00	2016-08-31 18:59:59	10248	10031	10	2017-01-23 18:14:13.457158	2017-01-23 18:14:13.457158	16575
16882	2016-09-01 00:00:00	2016-12-31 18:59:59	10248	10030	13	2017-01-23 18:14:13.462944	2017-01-23 18:14:13.462944	16575
16883	2016-09-01 00:00:00	2016-12-31 18:59:59	10248	10031	13	2017-01-23 18:14:13.467774	2017-01-23 18:14:13.467774	16575
16884	2017-01-01 00:00:00	2099-12-31 18:59:59	10248	10030	12	2017-01-23 18:14:13.473326	2017-01-23 18:14:13.473326	16575
16885	2017-01-01 00:00:00	2099-12-31 18:59:59	10248	10031	13	2017-01-23 18:14:13.478739	2017-01-23 18:14:13.478739	16575
16886	2000-01-01 00:00:00	2016-05-31 18:59:59	10249	10030	13	2017-01-23 18:14:13.48472	2017-01-23 18:14:13.48472	16575
16887	2000-01-01 00:00:00	2016-05-31 18:59:59	10249	10031	10	2017-01-23 18:14:13.489863	2017-01-23 18:14:13.489863	16575
16888	2016-06-01 00:00:00	2016-08-31 18:59:59	10249	10030	13	2017-01-23 18:14:13.495718	2017-01-23 18:14:13.495718	16575
16889	2016-06-01 00:00:00	2016-08-31 18:59:59	10249	10031	11	2017-01-23 18:14:13.500858	2017-01-23 18:14:13.500858	16575
16890	2016-09-01 00:00:00	2016-12-31 18:59:59	10249	10030	12	2017-01-23 18:14:13.506436	2017-01-23 18:14:13.506436	16575
16891	2016-09-01 00:00:00	2016-12-31 18:59:59	10249	10031	11	2017-01-23 18:14:13.511751	2017-01-23 18:14:13.511751	16575
16892	2017-01-01 00:00:00	2099-12-31 18:59:59	10249	10030	14	2017-01-23 18:14:13.517922	2017-01-23 18:14:13.517922	16575
16893	2017-01-01 00:00:00	2099-12-31 18:59:59	10249	10031	13	2017-01-23 18:14:13.523034	2017-01-23 18:14:13.523034	16575
16894	2000-01-01 00:00:00	2016-05-31 18:59:59	10250	10030	13	2017-01-23 18:14:13.528732	2017-01-23 18:14:13.528732	16575
16895	2000-01-01 00:00:00	2016-05-31 18:59:59	10250	10031	11	2017-01-23 18:14:13.53409	2017-01-23 18:14:13.53409	16575
16896	2016-06-01 00:00:00	2016-08-31 18:59:59	10250	10030	10	2017-01-23 18:14:13.540167	2017-01-23 18:14:13.540167	16575
16897	2016-06-01 00:00:00	2016-08-31 18:59:59	10250	10031	12	2017-01-23 18:14:13.545692	2017-01-23 18:14:13.545692	16575
16898	2016-09-01 00:00:00	2016-12-31 18:59:59	10250	10030	12	2017-01-23 18:14:13.551726	2017-01-23 18:14:13.551726	16575
16899	2016-09-01 00:00:00	2016-12-31 18:59:59	10250	10031	11	2017-01-23 18:14:13.557565	2017-01-23 18:14:13.557565	16575
16900	2017-01-01 00:00:00	2099-12-31 18:59:59	10250	10030	11	2017-01-23 18:14:13.563753	2017-01-23 18:14:13.563753	16575
16901	2017-01-01 00:00:00	2099-12-31 18:59:59	10250	10031	10	2017-01-23 18:14:13.568838	2017-01-23 18:14:13.568838	16575
16902	2000-01-01 00:00:00	2016-05-31 18:59:59	10251	10030	10	2017-01-23 18:14:13.574188	2017-01-23 18:14:13.574188	16575
16903	2000-01-01 00:00:00	2016-05-31 18:59:59	10251	10031	14	2017-01-23 18:14:13.579249	2017-01-23 18:14:13.579249	16575
16904	2016-06-01 00:00:00	2016-08-31 18:59:59	10251	10030	13	2017-01-23 18:14:13.585178	2017-01-23 18:14:13.585178	16575
16905	2016-06-01 00:00:00	2016-08-31 18:59:59	10251	10031	11	2017-01-23 18:14:13.590539	2017-01-23 18:14:13.590539	16575
16906	2016-09-01 00:00:00	2016-12-31 18:59:59	10251	10030	10	2017-01-23 18:14:13.596673	2017-01-23 18:14:13.596673	16575
16907	2016-09-01 00:00:00	2016-12-31 18:59:59	10251	10031	14	2017-01-23 18:14:13.601912	2017-01-23 18:14:13.601912	16575
16908	2017-01-01 00:00:00	2099-12-31 18:59:59	10251	10030	11	2017-01-23 18:14:13.60815	2017-01-23 18:14:13.60815	16575
16909	2017-01-01 00:00:00	2099-12-31 18:59:59	10251	10031	11	2017-01-23 18:14:13.613198	2017-01-23 18:14:13.613198	16575
16910	2000-01-01 00:00:00	2016-05-31 18:59:59	10252	10030	10	2017-01-23 18:14:13.618852	2017-01-23 18:14:13.618852	16575
16911	2000-01-01 00:00:00	2016-05-31 18:59:59	10252	10031	12	2017-01-23 18:14:13.623981	2017-01-23 18:14:13.623981	16575
16912	2016-06-01 00:00:00	2016-08-31 18:59:59	10252	10030	10	2017-01-23 18:14:13.629465	2017-01-23 18:14:13.629465	16575
16913	2016-06-01 00:00:00	2016-08-31 18:59:59	10252	10031	11	2017-01-23 18:14:13.634339	2017-01-23 18:14:13.634339	16575
16914	2016-09-01 00:00:00	2016-12-31 18:59:59	10252	10030	10	2017-01-23 18:14:13.640303	2017-01-23 18:14:13.640303	16575
16915	2016-09-01 00:00:00	2016-12-31 18:59:59	10252	10031	14	2017-01-23 18:14:13.645761	2017-01-23 18:14:13.645761	16575
16916	2017-01-01 00:00:00	2099-12-31 18:59:59	10252	10030	12	2017-01-23 18:14:13.651645	2017-01-23 18:14:13.651645	16575
16917	2017-01-01 00:00:00	2099-12-31 18:59:59	10252	10031	11	2017-01-23 18:14:13.6569	2017-01-23 18:14:13.6569	16575
16918	2000-01-01 00:00:00	2016-05-31 18:59:59	10253	10030	14	2017-01-23 18:14:13.66226	2017-01-23 18:14:13.66226	16575
16919	2000-01-01 00:00:00	2016-05-31 18:59:59	10253	10031	12	2017-01-23 18:14:13.666813	2017-01-23 18:14:13.666813	16575
16920	2016-06-01 00:00:00	2016-08-31 18:59:59	10253	10030	14	2017-01-23 18:14:13.672786	2017-01-23 18:14:13.672786	16575
16921	2016-06-01 00:00:00	2016-08-31 18:59:59	10253	10031	13	2017-01-23 18:14:13.678256	2017-01-23 18:14:13.678256	16575
16922	2016-09-01 00:00:00	2016-12-31 18:59:59	10253	10030	11	2017-01-23 18:14:13.683873	2017-01-23 18:14:13.683873	16575
16923	2016-09-01 00:00:00	2016-12-31 18:59:59	10253	10031	13	2017-01-23 18:14:13.689089	2017-01-23 18:14:13.689089	16575
16924	2017-01-01 00:00:00	2099-12-31 18:59:59	10253	10030	11	2017-01-23 18:14:13.694805	2017-01-23 18:14:13.694805	16575
16925	2017-01-01 00:00:00	2099-12-31 18:59:59	10253	10031	12	2017-01-23 18:14:13.700555	2017-01-23 18:14:13.700555	16575
16926	2000-01-01 00:00:00	2016-05-31 18:59:59	10254	10030	10	2017-01-23 18:14:13.706789	2017-01-23 18:14:13.706789	16575
16927	2000-01-01 00:00:00	2016-05-31 18:59:59	10254	10031	14	2017-01-23 18:14:13.711648	2017-01-23 18:14:13.711648	16575
16928	2016-06-01 00:00:00	2016-08-31 18:59:59	10254	10030	14	2017-01-23 18:14:13.717558	2017-01-23 18:14:13.717558	16575
16929	2016-06-01 00:00:00	2016-08-31 18:59:59	10254	10031	14	2017-01-23 18:14:13.723041	2017-01-23 18:14:13.723041	16575
16930	2016-09-01 00:00:00	2016-12-31 18:59:59	10254	10030	11	2017-01-23 18:14:13.728545	2017-01-23 18:14:13.728545	16575
16931	2016-09-01 00:00:00	2016-12-31 18:59:59	10254	10031	11	2017-01-23 18:14:13.733799	2017-01-23 18:14:13.733799	16575
16932	2017-01-01 00:00:00	2099-12-31 18:59:59	10254	10030	12	2017-01-23 18:14:13.739723	2017-01-23 18:14:13.739723	16575
16933	2017-01-01 00:00:00	2099-12-31 18:59:59	10254	10031	14	2017-01-23 18:14:13.745014	2017-01-23 18:14:13.745014	16575
16934	2000-01-01 00:00:00	2016-05-31 18:59:59	10255	10030	10	2017-01-23 18:14:13.750621	2017-01-23 18:14:13.750621	16575
16935	2000-01-01 00:00:00	2016-05-31 18:59:59	10255	10031	11	2017-01-23 18:14:13.755702	2017-01-23 18:14:13.755702	16575
16936	2016-06-01 00:00:00	2016-08-31 18:59:59	10255	10030	12	2017-01-23 18:14:13.76159	2017-01-23 18:14:13.76159	16575
16937	2016-06-01 00:00:00	2016-08-31 18:59:59	10255	10031	10	2017-01-23 18:14:13.767036	2017-01-23 18:14:13.767036	16575
16938	2016-09-01 00:00:00	2016-12-31 18:59:59	10255	10030	12	2017-01-23 18:14:13.772913	2017-01-23 18:14:13.772913	16575
16939	2016-09-01 00:00:00	2016-12-31 18:59:59	10255	10031	14	2017-01-23 18:14:13.777977	2017-01-23 18:14:13.777977	16575
16940	2017-01-01 00:00:00	2099-12-31 18:59:59	10255	10030	11	2017-01-23 18:14:13.783515	2017-01-23 18:14:13.783515	16575
16941	2017-01-01 00:00:00	2099-12-31 18:59:59	10255	10031	10	2017-01-23 18:14:13.788824	2017-01-23 18:14:13.788824	16575
16942	2000-01-01 00:00:00	2016-05-31 18:59:59	10256	10030	13	2017-01-23 18:14:13.794794	2017-01-23 18:14:13.794794	16575
16943	2000-01-01 00:00:00	2016-05-31 18:59:59	10256	10031	10	2017-01-23 18:14:13.799935	2017-01-23 18:14:13.799935	16575
16944	2016-06-01 00:00:00	2016-08-31 18:59:59	10256	10030	12	2017-01-23 18:14:13.805654	2017-01-23 18:14:13.805654	16575
16945	2016-06-01 00:00:00	2016-08-31 18:59:59	10256	10031	10	2017-01-23 18:14:13.810799	2017-01-23 18:14:13.810799	16575
16946	2016-09-01 00:00:00	2016-12-31 18:59:59	10256	10030	14	2017-01-23 18:14:13.816434	2017-01-23 18:14:13.816434	16575
16947	2016-09-01 00:00:00	2016-12-31 18:59:59	10256	10031	10	2017-01-23 18:14:13.821776	2017-01-23 18:14:13.821776	16575
16948	2017-01-01 00:00:00	2099-12-31 18:59:59	10256	10030	10	2017-01-23 18:14:13.82754	2017-01-23 18:14:13.82754	16575
16949	2017-01-01 00:00:00	2099-12-31 18:59:59	10256	10031	11	2017-01-23 18:14:13.832562	2017-01-23 18:14:13.832562	16575
16950	2000-01-01 00:00:00	2016-05-31 18:59:59	10257	10030	13	2017-01-23 18:14:13.838863	2017-01-23 18:14:13.838863	16575
16951	2000-01-01 00:00:00	2016-05-31 18:59:59	10257	10031	12	2017-01-23 18:14:13.844545	2017-01-23 18:14:13.844545	16575
16952	2016-06-01 00:00:00	2016-08-31 18:59:59	10257	10030	11	2017-01-23 18:14:13.85002	2017-01-23 18:14:13.85002	16575
16953	2016-06-01 00:00:00	2016-08-31 18:59:59	10257	10031	11	2017-01-23 18:14:13.854895	2017-01-23 18:14:13.854895	16575
16954	2016-09-01 00:00:00	2016-12-31 18:59:59	10257	10030	14	2017-01-23 18:14:13.860637	2017-01-23 18:14:13.860637	16575
16955	2016-09-01 00:00:00	2016-12-31 18:59:59	10257	10031	11	2017-01-23 18:14:13.866012	2017-01-23 18:14:13.866012	16575
16956	2017-01-01 00:00:00	2099-12-31 18:59:59	10257	10030	12	2017-01-23 18:14:13.871846	2017-01-23 18:14:13.871846	16575
16957	2017-01-01 00:00:00	2099-12-31 18:59:59	10257	10031	12	2017-01-23 18:14:13.876793	2017-01-23 18:14:13.876793	16575
16958	2000-01-01 00:00:00	2016-05-31 18:59:59	10258	10030	12	2017-01-23 18:14:13.882516	2017-01-23 18:14:13.882516	16575
16959	2000-01-01 00:00:00	2016-05-31 18:59:59	10258	10031	14	2017-01-23 18:14:13.887946	2017-01-23 18:14:13.887946	16575
16960	2016-06-01 00:00:00	2016-08-31 18:59:59	10258	10030	13	2017-01-23 18:14:13.893602	2017-01-23 18:14:13.893602	16575
16961	2016-06-01 00:00:00	2016-08-31 18:59:59	10258	10031	11	2017-01-23 18:14:13.898916	2017-01-23 18:14:13.898916	16575
16962	2016-09-01 00:00:00	2016-12-31 18:59:59	10258	10030	14	2017-01-23 18:14:13.905048	2017-01-23 18:14:13.905048	16575
16963	2016-09-01 00:00:00	2016-12-31 18:59:59	10258	10031	11	2017-01-23 18:14:13.910018	2017-01-23 18:14:13.910018	16575
16964	2017-01-01 00:00:00	2099-12-31 18:59:59	10258	10030	11	2017-01-23 18:14:13.916704	2017-01-23 18:14:13.916704	16575
16965	2017-01-01 00:00:00	2099-12-31 18:59:59	10258	10031	12	2017-01-23 18:14:13.922229	2017-01-23 18:14:13.922229	16575
16966	2000-01-01 00:00:00	2016-05-31 18:59:59	10259	10030	11	2017-01-23 18:14:13.928845	2017-01-23 18:14:13.928845	16575
16967	2000-01-01 00:00:00	2016-05-31 18:59:59	10259	10031	11	2017-01-23 18:14:13.934013	2017-01-23 18:14:13.934013	16575
16968	2016-06-01 00:00:00	2016-08-31 18:59:59	10259	10030	11	2017-01-23 18:14:13.939607	2017-01-23 18:14:13.939607	16575
16969	2016-06-01 00:00:00	2016-08-31 18:59:59	10259	10031	14	2017-01-23 18:14:13.945081	2017-01-23 18:14:13.945081	16575
16970	2016-09-01 00:00:00	2016-12-31 18:59:59	10259	10030	10	2017-01-23 18:14:13.950797	2017-01-23 18:14:13.950797	16575
16971	2016-09-01 00:00:00	2016-12-31 18:59:59	10259	10031	12	2017-01-23 18:14:13.95583	2017-01-23 18:14:13.95583	16575
16972	2017-01-01 00:00:00	2099-12-31 18:59:59	10259	10030	14	2017-01-23 18:14:13.961736	2017-01-23 18:14:13.961736	16575
16973	2017-01-01 00:00:00	2099-12-31 18:59:59	10259	10031	10	2017-01-23 18:14:13.966761	2017-01-23 18:14:13.966761	16575
16974	2000-01-01 00:00:00	2016-05-31 18:59:59	10260	10030	11	2017-01-23 18:14:13.97237	2017-01-23 18:14:13.97237	16575
16975	2000-01-01 00:00:00	2016-05-31 18:59:59	10260	10031	13	2017-01-23 18:14:13.97767	2017-01-23 18:14:13.97767	16575
16976	2016-06-01 00:00:00	2016-08-31 18:59:59	10260	10030	11	2017-01-23 18:14:13.983403	2017-01-23 18:14:13.983403	16575
16977	2016-06-01 00:00:00	2016-08-31 18:59:59	10260	10031	14	2017-01-23 18:14:13.989443	2017-01-23 18:14:13.989443	16575
16978	2016-09-01 00:00:00	2016-12-31 18:59:59	10260	10030	12	2017-01-23 18:14:13.995269	2017-01-23 18:14:13.995269	16575
16979	2016-09-01 00:00:00	2016-12-31 18:59:59	10260	10031	14	2017-01-23 18:14:14.000152	2017-01-23 18:14:14.000152	16575
16980	2017-01-01 00:00:00	2099-12-31 18:59:59	10260	10030	14	2017-01-23 18:14:14.005831	2017-01-23 18:14:14.005831	16575
16981	2017-01-01 00:00:00	2099-12-31 18:59:59	10260	10031	11	2017-01-23 18:14:14.010865	2017-01-23 18:14:14.010865	16575
16982	2000-01-01 00:00:00	2016-05-31 18:59:59	10261	10030	12	2017-01-23 18:14:14.016601	2017-01-23 18:14:14.016601	16575
16983	2000-01-01 00:00:00	2016-05-31 18:59:59	10261	10031	14	2017-01-23 18:14:14.021888	2017-01-23 18:14:14.021888	16575
16984	2016-06-01 00:00:00	2016-08-31 18:59:59	10261	10030	14	2017-01-23 18:14:14.027677	2017-01-23 18:14:14.027677	16575
16985	2016-06-01 00:00:00	2016-08-31 18:59:59	10261	10031	11	2017-01-23 18:14:14.033007	2017-01-23 18:14:14.033007	16575
16986	2016-09-01 00:00:00	2016-12-31 18:59:59	10261	10030	14	2017-01-23 18:14:14.038895	2017-01-23 18:14:14.038895	16575
16987	2016-09-01 00:00:00	2016-12-31 18:59:59	10261	10031	13	2017-01-23 18:14:14.043992	2017-01-23 18:14:14.043992	16575
16988	2017-01-01 00:00:00	2099-12-31 18:59:59	10261	10030	10	2017-01-23 18:14:14.050148	2017-01-23 18:14:14.050148	16575
16989	2017-01-01 00:00:00	2099-12-31 18:59:59	10261	10031	14	2017-01-23 18:14:14.055077	2017-01-23 18:14:14.055077	16575
16990	2000-01-01 00:00:00	2016-05-31 18:59:59	10262	10030	11	2017-01-23 18:14:14.060907	2017-01-23 18:14:14.060907	16575
16991	2000-01-01 00:00:00	2016-05-31 18:59:59	10262	10031	14	2017-01-23 18:14:14.065853	2017-01-23 18:14:14.065853	16575
16992	2016-06-01 00:00:00	2016-08-31 18:59:59	10262	10030	13	2017-01-23 18:14:14.071869	2017-01-23 18:14:14.071869	16575
16993	2016-06-01 00:00:00	2016-08-31 18:59:59	10262	10031	10	2017-01-23 18:14:14.077099	2017-01-23 18:14:14.077099	16575
16994	2016-09-01 00:00:00	2016-12-31 18:59:59	10262	10030	13	2017-01-23 18:14:14.082693	2017-01-23 18:14:14.082693	16575
16995	2016-09-01 00:00:00	2016-12-31 18:59:59	10262	10031	14	2017-01-23 18:14:14.087725	2017-01-23 18:14:14.087725	16575
16996	2017-01-01 00:00:00	2099-12-31 18:59:59	10262	10030	10	2017-01-23 18:14:14.093179	2017-01-23 18:14:14.093179	16575
16997	2017-01-01 00:00:00	2099-12-31 18:59:59	10262	10031	11	2017-01-23 18:14:14.098236	2017-01-23 18:14:14.098236	16575
16998	2000-01-01 00:00:00	2016-05-31 18:59:59	10263	10030	12	2017-01-23 18:14:14.10401	2017-01-23 18:14:14.10401	16575
16999	2000-01-01 00:00:00	2016-05-31 18:59:59	10263	10031	10	2017-01-23 18:14:14.109019	2017-01-23 18:14:14.109019	16575
17000	2016-06-01 00:00:00	2016-08-31 18:59:59	10263	10030	14	2017-01-23 18:14:14.114759	2017-01-23 18:14:14.114759	16575
17001	2016-06-01 00:00:00	2016-08-31 18:59:59	10263	10031	12	2017-01-23 18:14:14.119795	2017-01-23 18:14:14.119795	16575
17002	2016-09-01 00:00:00	2016-12-31 18:59:59	10263	10030	11	2017-01-23 18:14:14.125751	2017-01-23 18:14:14.125751	16575
17003	2016-09-01 00:00:00	2016-12-31 18:59:59	10263	10031	11	2017-01-23 18:14:14.131836	2017-01-23 18:14:14.131836	16575
17004	2017-01-01 00:00:00	2099-12-31 18:59:59	10263	10030	12	2017-01-23 18:14:14.137437	2017-01-23 18:14:14.137437	16575
17005	2017-01-01 00:00:00	2099-12-31 18:59:59	10263	10031	12	2017-01-23 18:14:14.142917	2017-01-23 18:14:14.142917	16575
17006	2000-01-01 00:00:00	2016-05-31 18:59:59	10264	10030	13	2017-01-23 18:14:14.148564	2017-01-23 18:14:14.148564	16575
17007	2000-01-01 00:00:00	2016-05-31 18:59:59	10264	10031	12	2017-01-23 18:14:14.154091	2017-01-23 18:14:14.154091	16575
17008	2016-06-01 00:00:00	2016-08-31 18:59:59	10264	10030	10	2017-01-23 18:14:14.160836	2017-01-23 18:14:14.160836	16575
17009	2016-06-01 00:00:00	2016-08-31 18:59:59	10264	10031	11	2017-01-23 18:14:14.166363	2017-01-23 18:14:14.166363	16575
17010	2016-09-01 00:00:00	2016-12-31 18:59:59	10264	10030	12	2017-01-23 18:14:14.17266	2017-01-23 18:14:14.17266	16575
17011	2016-09-01 00:00:00	2016-12-31 18:59:59	10264	10031	10	2017-01-23 18:14:14.178004	2017-01-23 18:14:14.178004	16575
17012	2017-01-01 00:00:00	2099-12-31 18:59:59	10264	10030	11	2017-01-23 18:14:14.183748	2017-01-23 18:14:14.183748	16575
17013	2017-01-01 00:00:00	2099-12-31 18:59:59	10264	10031	14	2017-01-23 18:14:14.189118	2017-01-23 18:14:14.189118	16575
17014	2000-01-01 00:00:00	2016-05-31 18:59:59	10265	10030	12	2017-01-23 18:14:14.194907	2017-01-23 18:14:14.194907	16575
17015	2000-01-01 00:00:00	2016-05-31 18:59:59	10265	10031	11	2017-01-23 18:14:14.20006	2017-01-23 18:14:14.20006	16575
17016	2016-06-01 00:00:00	2016-08-31 18:59:59	10265	10030	11	2017-01-23 18:14:14.205793	2017-01-23 18:14:14.205793	16575
17017	2016-06-01 00:00:00	2016-08-31 18:59:59	10265	10031	10	2017-01-23 18:14:14.210873	2017-01-23 18:14:14.210873	16575
17018	2016-09-01 00:00:00	2016-12-31 18:59:59	10265	10030	14	2017-01-23 18:14:14.21636	2017-01-23 18:14:14.21636	16575
17019	2016-09-01 00:00:00	2016-12-31 18:59:59	10265	10031	11	2017-01-23 18:14:14.221231	2017-01-23 18:14:14.221231	16575
17020	2017-01-01 00:00:00	2099-12-31 18:59:59	10265	10030	14	2017-01-23 18:14:14.227139	2017-01-23 18:14:14.227139	16575
17021	2017-01-01 00:00:00	2099-12-31 18:59:59	10265	10031	13	2017-01-23 18:14:14.231949	2017-01-23 18:14:14.231949	16575
17022	2000-01-01 00:00:00	2016-05-31 18:59:59	10266	10030	13	2017-01-23 18:14:14.237764	2017-01-23 18:14:14.237764	16575
17023	2000-01-01 00:00:00	2016-05-31 18:59:59	10266	10031	11	2017-01-23 18:14:14.242938	2017-01-23 18:14:14.242938	16575
17024	2016-06-01 00:00:00	2016-08-31 18:59:59	10266	10030	14	2017-01-23 18:14:14.248671	2017-01-23 18:14:14.248671	16575
17025	2016-06-01 00:00:00	2016-08-31 18:59:59	10266	10031	13	2017-01-23 18:14:14.253905	2017-01-23 18:14:14.253905	16575
17026	2016-09-01 00:00:00	2016-12-31 18:59:59	10266	10030	10	2017-01-23 18:14:14.259958	2017-01-23 18:14:14.259958	16575
17027	2016-09-01 00:00:00	2016-12-31 18:59:59	10266	10031	13	2017-01-23 18:14:14.264958	2017-01-23 18:14:14.264958	16575
17028	2017-01-01 00:00:00	2099-12-31 18:59:59	10266	10030	12	2017-01-23 18:14:14.270687	2017-01-23 18:14:14.270687	16575
17029	2017-01-01 00:00:00	2099-12-31 18:59:59	10266	10031	11	2017-01-23 18:14:14.276476	2017-01-23 18:14:14.276476	16575
17030	2000-01-01 00:00:00	2016-05-31 18:59:59	10267	10030	10	2017-01-23 18:14:14.282535	2017-01-23 18:14:14.282535	16575
17031	2000-01-01 00:00:00	2016-05-31 18:59:59	10267	10031	13	2017-01-23 18:14:14.288232	2017-01-23 18:14:14.288232	16575
17032	2016-06-01 00:00:00	2016-08-31 18:59:59	10267	10030	11	2017-01-23 18:14:14.293943	2017-01-23 18:14:14.293943	16575
17033	2016-06-01 00:00:00	2016-08-31 18:59:59	10267	10031	10	2017-01-23 18:14:14.299089	2017-01-23 18:14:14.299089	16575
17034	2016-09-01 00:00:00	2016-12-31 18:59:59	10267	10030	10	2017-01-23 18:14:14.30468	2017-01-23 18:14:14.30468	16575
17035	2016-09-01 00:00:00	2016-12-31 18:59:59	10267	10031	13	2017-01-23 18:14:14.30996	2017-01-23 18:14:14.30996	16575
17036	2017-01-01 00:00:00	2099-12-31 18:59:59	10267	10030	12	2017-01-23 18:14:14.31566	2017-01-23 18:14:14.31566	16575
17037	2017-01-01 00:00:00	2099-12-31 18:59:59	10267	10031	10	2017-01-23 18:14:14.320893	2017-01-23 18:14:14.320893	16575
17038	2000-01-01 00:00:00	2016-05-31 18:59:59	10268	10030	12	2017-01-23 18:14:14.326587	2017-01-23 18:14:14.326587	16575
17039	2000-01-01 00:00:00	2016-05-31 18:59:59	10268	10031	10	2017-01-23 18:14:14.331475	2017-01-23 18:14:14.331475	16575
17040	2016-06-01 00:00:00	2016-08-31 18:59:59	10268	10030	11	2017-01-23 18:14:14.337276	2017-01-23 18:14:14.337276	16575
17041	2016-06-01 00:00:00	2016-08-31 18:59:59	10268	10031	11	2017-01-23 18:14:14.342613	2017-01-23 18:14:14.342613	16575
17042	2016-09-01 00:00:00	2016-12-31 18:59:59	10268	10030	13	2017-01-23 18:14:14.348444	2017-01-23 18:14:14.348444	16575
17043	2016-09-01 00:00:00	2016-12-31 18:59:59	10268	10031	12	2017-01-23 18:14:14.353811	2017-01-23 18:14:14.353811	16575
17044	2017-01-01 00:00:00	2099-12-31 18:59:59	10268	10030	14	2017-01-23 18:14:14.359547	2017-01-23 18:14:14.359547	16575
17045	2017-01-01 00:00:00	2099-12-31 18:59:59	10268	10031	13	2017-01-23 18:14:14.364534	2017-01-23 18:14:14.364534	16575
17046	2000-01-01 00:00:00	2016-05-31 18:59:59	10269	10030	13	2017-01-23 18:14:14.370603	2017-01-23 18:14:14.370603	16575
17047	2000-01-01 00:00:00	2016-05-31 18:59:59	10269	10031	13	2017-01-23 18:14:14.375846	2017-01-23 18:14:14.375846	16575
17048	2016-06-01 00:00:00	2016-08-31 18:59:59	10269	10030	11	2017-01-23 18:14:14.381553	2017-01-23 18:14:14.381553	16575
17049	2016-06-01 00:00:00	2016-08-31 18:59:59	10269	10031	14	2017-01-23 18:14:14.387062	2017-01-23 18:14:14.387062	16575
17050	2016-09-01 00:00:00	2016-12-31 18:59:59	10269	10030	13	2017-01-23 18:14:14.392801	2017-01-23 18:14:14.392801	16575
17051	2016-09-01 00:00:00	2016-12-31 18:59:59	10269	10031	11	2017-01-23 18:14:14.397544	2017-01-23 18:14:14.397544	16575
17052	2017-01-01 00:00:00	2099-12-31 18:59:59	10269	10030	12	2017-01-23 18:14:14.403501	2017-01-23 18:14:14.403501	16575
17053	2017-01-01 00:00:00	2099-12-31 18:59:59	10269	10031	13	2017-01-23 18:14:14.409073	2017-01-23 18:14:14.409073	16575
17054	2000-01-01 00:00:00	2016-05-31 18:59:59	10270	10030	13	2017-01-23 18:14:14.414865	2017-01-23 18:14:14.414865	16575
17055	2000-01-01 00:00:00	2016-05-31 18:59:59	10270	10031	12	2017-01-23 18:14:14.420503	2017-01-23 18:14:14.420503	16575
17056	2016-06-01 00:00:00	2016-08-31 18:59:59	10270	10030	12	2017-01-23 18:14:14.426247	2017-01-23 18:14:14.426247	16575
17057	2016-06-01 00:00:00	2016-08-31 18:59:59	10270	10031	13	2017-01-23 18:14:14.431172	2017-01-23 18:14:14.431172	16575
17058	2016-09-01 00:00:00	2016-12-31 18:59:59	10270	10030	13	2017-01-23 18:14:14.436854	2017-01-23 18:14:14.436854	16575
17059	2016-09-01 00:00:00	2016-12-31 18:59:59	10270	10031	11	2017-01-23 18:14:14.441892	2017-01-23 18:14:14.441892	16575
17060	2017-01-01 00:00:00	2099-12-31 18:59:59	10270	10030	13	2017-01-23 18:14:14.447585	2017-01-23 18:14:14.447585	16575
17061	2017-01-01 00:00:00	2099-12-31 18:59:59	10270	10031	11	2017-01-23 18:14:14.452917	2017-01-23 18:14:14.452917	16575
17062	2000-01-01 00:00:00	2016-05-31 18:59:59	10271	10030	11	2017-01-23 18:14:14.458606	2017-01-23 18:14:14.458606	16575
17063	2000-01-01 00:00:00	2016-05-31 18:59:59	10271	10031	13	2017-01-23 18:14:14.463871	2017-01-23 18:14:14.463871	16575
17064	2016-06-01 00:00:00	2016-08-31 18:59:59	10271	10030	12	2017-01-23 18:14:14.469974	2017-01-23 18:14:14.469974	16575
17065	2016-06-01 00:00:00	2016-08-31 18:59:59	10271	10031	10	2017-01-23 18:14:14.474882	2017-01-23 18:14:14.474882	16575
17066	2016-09-01 00:00:00	2016-12-31 18:59:59	10271	10030	14	2017-01-23 18:14:14.480499	2017-01-23 18:14:14.480499	16575
17067	2016-09-01 00:00:00	2016-12-31 18:59:59	10271	10031	10	2017-01-23 18:14:14.485419	2017-01-23 18:14:14.485419	16575
17068	2017-01-01 00:00:00	2099-12-31 18:59:59	10271	10030	11	2017-01-23 18:14:14.491773	2017-01-23 18:14:14.491773	16575
17069	2017-01-01 00:00:00	2099-12-31 18:59:59	10271	10031	14	2017-01-23 18:14:14.496666	2017-01-23 18:14:14.496666	16575
17070	2000-01-01 00:00:00	2016-05-31 18:59:59	10272	10030	11	2017-01-23 18:14:14.502511	2017-01-23 18:14:14.502511	16575
17071	2000-01-01 00:00:00	2016-05-31 18:59:59	10272	10031	14	2017-01-23 18:14:14.507737	2017-01-23 18:14:14.507737	16575
17072	2016-06-01 00:00:00	2016-08-31 18:59:59	10272	10030	12	2017-01-23 18:14:14.513347	2017-01-23 18:14:14.513347	16575
17073	2016-06-01 00:00:00	2016-08-31 18:59:59	10272	10031	14	2017-01-23 18:14:14.518887	2017-01-23 18:14:14.518887	16575
17074	2016-09-01 00:00:00	2016-12-31 18:59:59	10272	10030	14	2017-01-23 18:14:14.524574	2017-01-23 18:14:14.524574	16575
17075	2016-09-01 00:00:00	2016-12-31 18:59:59	10272	10031	13	2017-01-23 18:14:14.529811	2017-01-23 18:14:14.529811	16575
17076	2017-01-01 00:00:00	2099-12-31 18:59:59	10272	10030	12	2017-01-23 18:14:14.535721	2017-01-23 18:14:14.535721	16575
17077	2017-01-01 00:00:00	2099-12-31 18:59:59	10272	10031	10	2017-01-23 18:14:14.540776	2017-01-23 18:14:14.540776	16575
17078	2000-01-01 00:00:00	2016-05-31 18:59:59	10273	10030	12	2017-01-23 18:14:14.546314	2017-01-23 18:14:14.546314	16575
17079	2000-01-01 00:00:00	2016-05-31 18:59:59	10273	10031	10	2017-01-23 18:14:14.551324	2017-01-23 18:14:14.551324	16575
17080	2016-06-01 00:00:00	2016-08-31 18:59:59	10273	10030	14	2017-01-23 18:14:14.55712	2017-01-23 18:14:14.55712	16575
17081	2016-06-01 00:00:00	2016-08-31 18:59:59	10273	10031	14	2017-01-23 18:14:14.562984	2017-01-23 18:14:14.562984	16575
17082	2016-09-01 00:00:00	2016-12-31 18:59:59	10273	10030	13	2017-01-23 18:14:14.56879	2017-01-23 18:14:14.56879	16575
17083	2016-09-01 00:00:00	2016-12-31 18:59:59	10273	10031	10	2017-01-23 18:14:14.574028	2017-01-23 18:14:14.574028	16575
17084	2017-01-01 00:00:00	2099-12-31 18:59:59	10273	10030	12	2017-01-23 18:14:14.579969	2017-01-23 18:14:14.579969	16575
17085	2017-01-01 00:00:00	2099-12-31 18:59:59	10273	10031	10	2017-01-23 18:14:14.585061	2017-01-23 18:14:14.585061	16575
17086	2000-01-01 00:00:00	2016-05-31 18:59:59	10274	10030	12	2017-01-23 18:14:14.590818	2017-01-23 18:14:14.590818	16575
17087	2000-01-01 00:00:00	2016-05-31 18:59:59	10274	10031	13	2017-01-23 18:14:14.595827	2017-01-23 18:14:14.595827	16575
17088	2016-06-01 00:00:00	2016-08-31 18:59:59	10274	10030	14	2017-01-23 18:14:14.602014	2017-01-23 18:14:14.602014	16575
17089	2016-06-01 00:00:00	2016-08-31 18:59:59	10274	10031	11	2017-01-23 18:14:14.607131	2017-01-23 18:14:14.607131	16575
17090	2016-09-01 00:00:00	2016-12-31 18:59:59	10274	10030	13	2017-01-23 18:14:14.612956	2017-01-23 18:14:14.612956	16575
17091	2016-09-01 00:00:00	2016-12-31 18:59:59	10274	10031	11	2017-01-23 18:14:14.618447	2017-01-23 18:14:14.618447	16575
17092	2017-01-01 00:00:00	2099-12-31 18:59:59	10274	10030	12	2017-01-23 18:14:14.624309	2017-01-23 18:14:14.624309	16575
17093	2017-01-01 00:00:00	2099-12-31 18:59:59	10274	10031	13	2017-01-23 18:14:14.629608	2017-01-23 18:14:14.629608	16575
17094	2000-01-01 00:00:00	2016-05-31 18:59:59	10275	10030	14	2017-01-23 18:14:14.63542	2017-01-23 18:14:14.63542	16575
17095	2000-01-01 00:00:00	2016-05-31 18:59:59	10275	10031	13	2017-01-23 18:14:14.640525	2017-01-23 18:14:14.640525	16575
17096	2016-06-01 00:00:00	2016-08-31 18:59:59	10275	10030	10	2017-01-23 18:14:14.646281	2017-01-23 18:14:14.646281	16575
17097	2016-06-01 00:00:00	2016-08-31 18:59:59	10275	10031	11	2017-01-23 18:14:14.651466	2017-01-23 18:14:14.651466	16575
17098	2016-09-01 00:00:00	2016-12-31 18:59:59	10275	10030	12	2017-01-23 18:14:14.657599	2017-01-23 18:14:14.657599	16575
17099	2016-09-01 00:00:00	2016-12-31 18:59:59	10275	10031	14	2017-01-23 18:14:14.662978	2017-01-23 18:14:14.662978	16575
17100	2017-01-01 00:00:00	2099-12-31 18:59:59	10275	10030	11	2017-01-23 18:14:14.668821	2017-01-23 18:14:14.668821	16575
17101	2017-01-01 00:00:00	2099-12-31 18:59:59	10275	10031	13	2017-01-23 18:14:14.673937	2017-01-23 18:14:14.673937	16575
17102	2000-01-01 00:00:00	2016-05-31 18:59:59	10276	10030	13	2017-01-23 18:14:14.679696	2017-01-23 18:14:14.679696	16575
17103	2000-01-01 00:00:00	2016-05-31 18:59:59	10276	10031	10	2017-01-23 18:14:14.684864	2017-01-23 18:14:14.684864	16575
17104	2016-06-01 00:00:00	2016-08-31 18:59:59	10276	10030	11	2017-01-23 18:14:14.690641	2017-01-23 18:14:14.690641	16575
17105	2016-06-01 00:00:00	2016-08-31 18:59:59	10276	10031	12	2017-01-23 18:14:14.69576	2017-01-23 18:14:14.69576	16575
17106	2016-09-01 00:00:00	2016-12-31 18:59:59	10276	10030	11	2017-01-23 18:14:14.701661	2017-01-23 18:14:14.701661	16575
17107	2016-09-01 00:00:00	2016-12-31 18:59:59	10276	10031	13	2017-01-23 18:14:14.707727	2017-01-23 18:14:14.707727	16575
17108	2017-01-01 00:00:00	2099-12-31 18:59:59	10276	10030	10	2017-01-23 18:14:14.71378	2017-01-23 18:14:14.71378	16575
17109	2017-01-01 00:00:00	2099-12-31 18:59:59	10276	10031	13	2017-01-23 18:14:14.718719	2017-01-23 18:14:14.718719	16575
17110	2000-01-01 00:00:00	2016-05-31 18:59:59	10277	10030	11	2017-01-23 18:14:14.724648	2017-01-23 18:14:14.724648	16575
17111	2000-01-01 00:00:00	2016-05-31 18:59:59	10277	10031	14	2017-01-23 18:14:14.729642	2017-01-23 18:14:14.729642	16575
17112	2016-06-01 00:00:00	2016-08-31 18:59:59	10277	10030	12	2017-01-23 18:14:14.735868	2017-01-23 18:14:14.735868	16575
17113	2016-06-01 00:00:00	2016-08-31 18:59:59	10277	10031	12	2017-01-23 18:14:14.741158	2017-01-23 18:14:14.741158	16575
17114	2016-09-01 00:00:00	2016-12-31 18:59:59	10277	10030	11	2017-01-23 18:14:14.746814	2017-01-23 18:14:14.746814	16575
17115	2016-09-01 00:00:00	2016-12-31 18:59:59	10277	10031	11	2017-01-23 18:14:14.751949	2017-01-23 18:14:14.751949	16575
17116	2017-01-01 00:00:00	2099-12-31 18:59:59	10277	10030	11	2017-01-23 18:14:14.757691	2017-01-23 18:14:14.757691	16575
17117	2017-01-01 00:00:00	2099-12-31 18:59:59	10277	10031	12	2017-01-23 18:14:14.762575	2017-01-23 18:14:14.762575	16575
17118	2000-01-01 00:00:00	2016-05-31 18:59:59	10278	10030	12	2017-01-23 18:14:14.768558	2017-01-23 18:14:14.768558	16575
17119	2000-01-01 00:00:00	2016-05-31 18:59:59	10278	10031	14	2017-01-23 18:14:14.773983	2017-01-23 18:14:14.773983	16575
17120	2016-06-01 00:00:00	2016-08-31 18:59:59	10278	10030	14	2017-01-23 18:14:14.779931	2017-01-23 18:14:14.779931	16575
17121	2016-06-01 00:00:00	2016-08-31 18:59:59	10278	10031	14	2017-01-23 18:14:14.784808	2017-01-23 18:14:14.784808	16575
17122	2016-09-01 00:00:00	2016-12-31 18:59:59	10278	10030	14	2017-01-23 18:14:14.79055	2017-01-23 18:14:14.79055	16575
17123	2016-09-01 00:00:00	2016-12-31 18:59:59	10278	10031	10	2017-01-23 18:14:14.79558	2017-01-23 18:14:14.79558	16575
17124	2017-01-01 00:00:00	2099-12-31 18:59:59	10278	10030	14	2017-01-23 18:14:14.801344	2017-01-23 18:14:14.801344	16575
17125	2017-01-01 00:00:00	2099-12-31 18:59:59	10278	10031	13	2017-01-23 18:14:14.806551	2017-01-23 18:14:14.806551	16575
17126	2000-01-01 00:00:00	2016-05-31 18:59:59	10279	10030	10	2017-01-23 18:14:14.812473	2017-01-23 18:14:14.812473	16575
17127	2000-01-01 00:00:00	2016-05-31 18:59:59	10279	10031	14	2017-01-23 18:14:14.817741	2017-01-23 18:14:14.817741	16575
17128	2016-06-01 00:00:00	2016-08-31 18:59:59	10279	10030	11	2017-01-23 18:14:14.823692	2017-01-23 18:14:14.823692	16575
17129	2016-06-01 00:00:00	2016-08-31 18:59:59	10279	10031	11	2017-01-23 18:14:14.82883	2017-01-23 18:14:14.82883	16575
17130	2016-09-01 00:00:00	2016-12-31 18:59:59	10279	10030	12	2017-01-23 18:14:14.83455	2017-01-23 18:14:14.83455	16575
17131	2016-09-01 00:00:00	2016-12-31 18:59:59	10279	10031	11	2017-01-23 18:14:14.840244	2017-01-23 18:14:14.840244	16575
17132	2017-01-01 00:00:00	2099-12-31 18:59:59	10279	10030	13	2017-01-23 18:14:14.845715	2017-01-23 18:14:14.845715	16575
17133	2017-01-01 00:00:00	2099-12-31 18:59:59	10279	10031	14	2017-01-23 18:14:14.851435	2017-01-23 18:14:14.851435	16575
17134	2000-01-01 00:00:00	2016-05-31 18:59:59	10280	10030	10	2017-01-23 18:14:14.857809	2017-01-23 18:14:14.857809	16575
17135	2000-01-01 00:00:00	2016-05-31 18:59:59	10280	10031	10	2017-01-23 18:14:14.863168	2017-01-23 18:14:14.863168	16575
17136	2016-06-01 00:00:00	2016-08-31 18:59:59	10280	10030	12	2017-01-23 18:14:14.868709	2017-01-23 18:14:14.868709	16575
17137	2016-06-01 00:00:00	2016-08-31 18:59:59	10280	10031	10	2017-01-23 18:14:14.873889	2017-01-23 18:14:14.873889	16575
17138	2016-09-01 00:00:00	2016-12-31 18:59:59	10280	10030	13	2017-01-23 18:14:14.879743	2017-01-23 18:14:14.879743	16575
17139	2016-09-01 00:00:00	2016-12-31 18:59:59	10280	10031	14	2017-01-23 18:14:14.884804	2017-01-23 18:14:14.884804	16575
17140	2017-01-01 00:00:00	2099-12-31 18:59:59	10280	10030	11	2017-01-23 18:14:14.890742	2017-01-23 18:14:14.890742	16575
17141	2017-01-01 00:00:00	2099-12-31 18:59:59	10280	10031	12	2017-01-23 18:14:14.895944	2017-01-23 18:14:14.895944	16575
17142	2000-01-01 00:00:00	2016-05-31 18:59:59	10281	10030	14	2017-01-23 18:14:14.901732	2017-01-23 18:14:14.901732	16575
17143	2000-01-01 00:00:00	2016-05-31 18:59:59	10281	10031	10	2017-01-23 18:14:14.907253	2017-01-23 18:14:14.907253	16575
17144	2016-06-01 00:00:00	2016-08-31 18:59:59	10281	10030	12	2017-01-23 18:14:14.913061	2017-01-23 18:14:14.913061	16575
17145	2016-06-01 00:00:00	2016-08-31 18:59:59	10281	10031	11	2017-01-23 18:14:14.918736	2017-01-23 18:14:14.918736	16575
17146	2016-09-01 00:00:00	2016-12-31 18:59:59	10281	10030	10	2017-01-23 18:14:14.924623	2017-01-23 18:14:14.924623	16575
17147	2016-09-01 00:00:00	2016-12-31 18:59:59	10281	10031	12	2017-01-23 18:14:14.929924	2017-01-23 18:14:14.929924	16575
17148	2017-01-01 00:00:00	2099-12-31 18:59:59	10281	10030	14	2017-01-23 18:14:14.93538	2017-01-23 18:14:14.93538	16575
17149	2017-01-01 00:00:00	2099-12-31 18:59:59	10281	10031	10	2017-01-23 18:14:14.942191	2017-01-23 18:14:14.942191	16575
17150	2000-01-01 00:00:00	2016-05-31 18:59:59	10282	10030	10	2017-01-23 18:14:14.955118	2017-01-23 18:14:14.955118	16575
17151	2000-01-01 00:00:00	2016-05-31 18:59:59	10282	10031	13	2017-01-23 18:14:14.967156	2017-01-23 18:14:14.967156	16575
17152	2016-06-01 00:00:00	2016-08-31 18:59:59	10282	10030	10	2017-01-23 18:14:14.975628	2017-01-23 18:14:14.975628	16575
17153	2016-06-01 00:00:00	2016-08-31 18:59:59	10282	10031	10	2017-01-23 18:14:14.982201	2017-01-23 18:14:14.982201	16575
17154	2016-09-01 00:00:00	2016-12-31 18:59:59	10282	10030	13	2017-01-23 18:14:14.98834	2017-01-23 18:14:14.98834	16575
17155	2016-09-01 00:00:00	2016-12-31 18:59:59	10282	10031	12	2017-01-23 18:14:14.993635	2017-01-23 18:14:14.993635	16575
17156	2017-01-01 00:00:00	2099-12-31 18:59:59	10282	10030	13	2017-01-23 18:14:14.99999	2017-01-23 18:14:14.99999	16575
17157	2017-01-01 00:00:00	2099-12-31 18:59:59	10282	10031	12	2017-01-23 18:14:15.005167	2017-01-23 18:14:15.005167	16575
17158	2000-01-01 00:00:00	2016-05-31 18:59:59	10283	10030	11	2017-01-23 18:14:15.010846	2017-01-23 18:14:15.010846	16575
17159	2000-01-01 00:00:00	2016-05-31 18:59:59	10283	10031	14	2017-01-23 18:14:15.016787	2017-01-23 18:14:15.016787	16575
17160	2016-06-01 00:00:00	2016-08-31 18:59:59	10283	10030	12	2017-01-23 18:14:15.022649	2017-01-23 18:14:15.022649	16575
17161	2016-06-01 00:00:00	2016-08-31 18:59:59	10283	10031	10	2017-01-23 18:14:15.027534	2017-01-23 18:14:15.027534	16575
17162	2016-09-01 00:00:00	2016-12-31 18:59:59	10283	10030	13	2017-01-23 18:14:15.033341	2017-01-23 18:14:15.033341	16575
17163	2016-09-01 00:00:00	2016-12-31 18:59:59	10283	10031	14	2017-01-23 18:14:15.038544	2017-01-23 18:14:15.038544	16575
17164	2017-01-01 00:00:00	2099-12-31 18:59:59	10283	10030	14	2017-01-23 18:14:15.044054	2017-01-23 18:14:15.044054	16575
17165	2017-01-01 00:00:00	2099-12-31 18:59:59	10283	10031	10	2017-01-23 18:14:15.049446	2017-01-23 18:14:15.049446	16575
17166	2000-01-01 00:00:00	2016-05-31 18:59:59	10284	10030	11	2017-01-23 18:14:15.055307	2017-01-23 18:14:15.055307	16575
17167	2000-01-01 00:00:00	2016-05-31 18:59:59	10284	10031	12	2017-01-23 18:14:15.06039	2017-01-23 18:14:15.06039	16575
17168	2016-06-01 00:00:00	2016-08-31 18:59:59	10284	10030	12	2017-01-23 18:14:15.065899	2017-01-23 18:14:15.065899	16575
17169	2016-06-01 00:00:00	2016-08-31 18:59:59	10284	10031	11	2017-01-23 18:14:15.071212	2017-01-23 18:14:15.071212	16575
17170	2016-09-01 00:00:00	2016-12-31 18:59:59	10284	10030	11	2017-01-23 18:14:15.076869	2017-01-23 18:14:15.076869	16575
17171	2016-09-01 00:00:00	2016-12-31 18:59:59	10284	10031	10	2017-01-23 18:14:15.081807	2017-01-23 18:14:15.081807	16575
17172	2017-01-01 00:00:00	2099-12-31 18:59:59	10284	10030	11	2017-01-23 18:14:15.087514	2017-01-23 18:14:15.087514	16575
17173	2017-01-01 00:00:00	2099-12-31 18:59:59	10284	10031	10	2017-01-23 18:14:15.092951	2017-01-23 18:14:15.092951	16575
17174	2000-01-01 00:00:00	2016-05-31 18:59:59	10285	10030	13	2017-01-23 18:14:15.098461	2017-01-23 18:14:15.098461	16575
17175	2000-01-01 00:00:00	2016-05-31 18:59:59	10285	10031	13	2017-01-23 18:14:15.103941	2017-01-23 18:14:15.103941	16575
17176	2016-06-01 00:00:00	2016-08-31 18:59:59	10285	10030	12	2017-01-23 18:14:15.109591	2017-01-23 18:14:15.109591	16575
17177	2016-06-01 00:00:00	2016-08-31 18:59:59	10285	10031	14	2017-01-23 18:14:15.11482	2017-01-23 18:14:15.11482	16575
17178	2016-09-01 00:00:00	2016-12-31 18:59:59	10285	10030	10	2017-01-23 18:14:15.120747	2017-01-23 18:14:15.120747	16575
17179	2016-09-01 00:00:00	2016-12-31 18:59:59	10285	10031	13	2017-01-23 18:14:15.125974	2017-01-23 18:14:15.125974	16575
17180	2017-01-01 00:00:00	2099-12-31 18:59:59	10285	10030	12	2017-01-23 18:14:15.131951	2017-01-23 18:14:15.131951	16575
17181	2017-01-01 00:00:00	2099-12-31 18:59:59	10285	10031	12	2017-01-23 18:14:15.136886	2017-01-23 18:14:15.136886	16575
17182	2000-01-01 00:00:00	2016-05-31 18:59:59	10286	10030	10	2017-01-23 18:14:15.14276	2017-01-23 18:14:15.14276	16575
17183	2000-01-01 00:00:00	2016-05-31 18:59:59	10286	10031	11	2017-01-23 18:14:15.148038	2017-01-23 18:14:15.148038	16575
17184	2016-06-01 00:00:00	2016-08-31 18:59:59	10286	10030	14	2017-01-23 18:14:15.154148	2017-01-23 18:14:15.154148	16575
17185	2016-06-01 00:00:00	2016-08-31 18:59:59	10286	10031	14	2017-01-23 18:14:15.159781	2017-01-23 18:14:15.159781	16575
17186	2016-09-01 00:00:00	2016-12-31 18:59:59	10286	10030	14	2017-01-23 18:14:15.16514	2017-01-23 18:14:15.16514	16575
17187	2016-09-01 00:00:00	2016-12-31 18:59:59	10286	10031	12	2017-01-23 18:14:15.170122	2017-01-23 18:14:15.170122	16575
17188	2017-01-01 00:00:00	2099-12-31 18:59:59	10286	10030	10	2017-01-23 18:14:15.17587	2017-01-23 18:14:15.17587	16575
17189	2017-01-01 00:00:00	2099-12-31 18:59:59	10286	10031	10	2017-01-23 18:14:15.181212	2017-01-23 18:14:15.181212	16575
17190	2000-01-01 00:00:00	2016-05-31 18:59:59	10287	10030	11	2017-01-23 18:14:15.186727	2017-01-23 18:14:15.186727	16575
17191	2000-01-01 00:00:00	2016-05-31 18:59:59	10287	10031	14	2017-01-23 18:14:15.192231	2017-01-23 18:14:15.192231	16575
17192	2016-06-01 00:00:00	2016-08-31 18:59:59	10287	10030	12	2017-01-23 18:14:15.197783	2017-01-23 18:14:15.197783	16575
17193	2016-06-01 00:00:00	2016-08-31 18:59:59	10287	10031	13	2017-01-23 18:14:15.203066	2017-01-23 18:14:15.203066	16575
17194	2016-09-01 00:00:00	2016-12-31 18:59:59	10287	10030	10	2017-01-23 18:14:15.208758	2017-01-23 18:14:15.208758	16575
17195	2016-09-01 00:00:00	2016-12-31 18:59:59	10287	10031	11	2017-01-23 18:14:15.213655	2017-01-23 18:14:15.213655	16575
17196	2017-01-01 00:00:00	2099-12-31 18:59:59	10287	10030	11	2017-01-23 18:14:15.219531	2017-01-23 18:14:15.219531	16575
17197	2017-01-01 00:00:00	2099-12-31 18:59:59	10287	10031	11	2017-01-23 18:14:15.224888	2017-01-23 18:14:15.224888	16575
17198	2000-01-01 00:00:00	2016-05-31 18:59:59	10288	10030	12	2017-01-23 18:14:15.23068	2017-01-23 18:14:15.23068	16575
17199	2000-01-01 00:00:00	2016-05-31 18:59:59	10288	10031	10	2017-01-23 18:14:15.23588	2017-01-23 18:14:15.23588	16575
17200	2016-06-01 00:00:00	2016-08-31 18:59:59	10288	10030	10	2017-01-23 18:14:15.241582	2017-01-23 18:14:15.241582	16575
17201	2016-06-01 00:00:00	2016-08-31 18:59:59	10288	10031	12	2017-01-23 18:14:15.246566	2017-01-23 18:14:15.246566	16575
17202	2016-09-01 00:00:00	2016-12-31 18:59:59	10288	10030	13	2017-01-23 18:14:15.252213	2017-01-23 18:14:15.252213	16575
17203	2016-09-01 00:00:00	2016-12-31 18:59:59	10288	10031	13	2017-01-23 18:14:15.257166	2017-01-23 18:14:15.257166	16575
17204	2017-01-01 00:00:00	2099-12-31 18:59:59	10288	10030	14	2017-01-23 18:14:15.263014	2017-01-23 18:14:15.263014	16575
17205	2017-01-01 00:00:00	2099-12-31 18:59:59	10288	10031	13	2017-01-23 18:14:15.267924	2017-01-23 18:14:15.267924	16575
17206	2000-01-01 00:00:00	2016-05-31 18:59:59	10289	10030	11	2017-01-23 18:14:15.273667	2017-01-23 18:14:15.273667	16575
17207	2000-01-01 00:00:00	2016-05-31 18:59:59	10289	10031	11	2017-01-23 18:14:15.279018	2017-01-23 18:14:15.279018	16575
17208	2016-06-01 00:00:00	2016-08-31 18:59:59	10289	10030	13	2017-01-23 18:14:15.285219	2017-01-23 18:14:15.285219	16575
17209	2016-06-01 00:00:00	2016-08-31 18:59:59	10289	10031	13	2017-01-23 18:14:15.290324	2017-01-23 18:14:15.290324	16575
17210	2016-09-01 00:00:00	2016-12-31 18:59:59	10289	10030	13	2017-01-23 18:14:15.29683	2017-01-23 18:14:15.29683	16575
17211	2016-09-01 00:00:00	2016-12-31 18:59:59	10289	10031	12	2017-01-23 18:14:15.302014	2017-01-23 18:14:15.302014	16575
17212	2017-01-01 00:00:00	2099-12-31 18:59:59	10289	10030	13	2017-01-23 18:14:15.307774	2017-01-23 18:14:15.307774	16575
17213	2017-01-01 00:00:00	2099-12-31 18:59:59	10289	10031	14	2017-01-23 18:14:15.312789	2017-01-23 18:14:15.312789	16575
17214	2000-01-01 00:00:00	2016-05-31 18:59:59	10290	10030	13	2017-01-23 18:14:15.318436	2017-01-23 18:14:15.318436	16575
17215	2000-01-01 00:00:00	2016-05-31 18:59:59	10290	10031	12	2017-01-23 18:14:15.32403	2017-01-23 18:14:15.32403	16575
17216	2016-06-01 00:00:00	2016-08-31 18:59:59	10290	10030	13	2017-01-23 18:14:15.329865	2017-01-23 18:14:15.329865	16575
17217	2016-06-01 00:00:00	2016-08-31 18:59:59	10290	10031	14	2017-01-23 18:14:15.33507	2017-01-23 18:14:15.33507	16575
17218	2016-09-01 00:00:00	2016-12-31 18:59:59	10290	10030	13	2017-01-23 18:14:15.340843	2017-01-23 18:14:15.340843	16575
17219	2016-09-01 00:00:00	2016-12-31 18:59:59	10290	10031	12	2017-01-23 18:14:15.345797	2017-01-23 18:14:15.345797	16575
17220	2017-01-01 00:00:00	2099-12-31 18:59:59	10290	10030	10	2017-01-23 18:14:15.352013	2017-01-23 18:14:15.352013	16575
17221	2017-01-01 00:00:00	2099-12-31 18:59:59	10290	10031	10	2017-01-23 18:14:15.357115	2017-01-23 18:14:15.357115	16575
17222	2000-01-01 00:00:00	2016-05-31 18:59:59	10291	10030	11	2017-01-23 18:14:15.362706	2017-01-23 18:14:15.362706	16575
17223	2000-01-01 00:00:00	2016-05-31 18:59:59	10291	10031	13	2017-01-23 18:14:15.367731	2017-01-23 18:14:15.367731	16575
17224	2016-06-01 00:00:00	2016-08-31 18:59:59	10291	10030	11	2017-01-23 18:14:15.373271	2017-01-23 18:14:15.373271	16575
17225	2016-06-01 00:00:00	2016-08-31 18:59:59	10291	10031	13	2017-01-23 18:14:15.378665	2017-01-23 18:14:15.378665	16575
17226	2016-09-01 00:00:00	2016-12-31 18:59:59	10291	10030	11	2017-01-23 18:14:15.384706	2017-01-23 18:14:15.384706	16575
17227	2016-09-01 00:00:00	2016-12-31 18:59:59	10291	10031	12	2017-01-23 18:14:15.389838	2017-01-23 18:14:15.389838	16575
17228	2017-01-01 00:00:00	2099-12-31 18:59:59	10291	10030	10	2017-01-23 18:14:15.39568	2017-01-23 18:14:15.39568	16575
17229	2017-01-01 00:00:00	2099-12-31 18:59:59	10291	10031	11	2017-01-23 18:14:15.401071	2017-01-23 18:14:15.401071	16575
17230	2000-01-01 00:00:00	2016-05-31 18:59:59	10292	10030	13	2017-01-23 18:14:15.40701	2017-01-23 18:14:15.40701	16575
17231	2000-01-01 00:00:00	2016-05-31 18:59:59	10292	10031	14	2017-01-23 18:14:15.412172	2017-01-23 18:14:15.412172	16575
17232	2016-06-01 00:00:00	2016-08-31 18:59:59	10292	10030	14	2017-01-23 18:14:15.4178	2017-01-23 18:14:15.4178	16575
17233	2016-06-01 00:00:00	2016-08-31 18:59:59	10292	10031	11	2017-01-23 18:14:15.422464	2017-01-23 18:14:15.422464	16575
17234	2016-09-01 00:00:00	2016-12-31 18:59:59	10292	10030	13	2017-01-23 18:14:15.428184	2017-01-23 18:14:15.428184	16575
17235	2016-09-01 00:00:00	2016-12-31 18:59:59	10292	10031	13	2017-01-23 18:14:15.433285	2017-01-23 18:14:15.433285	16575
17236	2017-01-01 00:00:00	2099-12-31 18:59:59	10292	10030	10	2017-01-23 18:14:15.439579	2017-01-23 18:14:15.439579	16575
17237	2017-01-01 00:00:00	2099-12-31 18:59:59	10292	10031	11	2017-01-23 18:14:15.445039	2017-01-23 18:14:15.445039	16575
17238	2000-01-01 00:00:00	2016-05-31 18:59:59	10293	10030	10	2017-01-23 18:14:15.4506	2017-01-23 18:14:15.4506	16575
17239	2000-01-01 00:00:00	2016-05-31 18:59:59	10293	10031	13	2017-01-23 18:14:15.455702	2017-01-23 18:14:15.455702	16575
17240	2016-06-01 00:00:00	2016-08-31 18:59:59	10293	10030	13	2017-01-23 18:14:15.46159	2017-01-23 18:14:15.46159	16575
17241	2016-06-01 00:00:00	2016-08-31 18:59:59	10293	10031	12	2017-01-23 18:14:15.467232	2017-01-23 18:14:15.467232	16575
17242	2016-09-01 00:00:00	2016-12-31 18:59:59	10293	10030	13	2017-01-23 18:14:15.473312	2017-01-23 18:14:15.473312	16575
17243	2016-09-01 00:00:00	2016-12-31 18:59:59	10293	10031	10	2017-01-23 18:14:15.478168	2017-01-23 18:14:15.478168	16575
17244	2017-01-01 00:00:00	2099-12-31 18:59:59	10293	10030	14	2017-01-23 18:14:15.483664	2017-01-23 18:14:15.483664	16575
17245	2017-01-01 00:00:00	2099-12-31 18:59:59	10293	10031	11	2017-01-23 18:14:15.488741	2017-01-23 18:14:15.488741	16575
17246	2000-01-01 00:00:00	2016-05-31 18:59:59	10294	10030	13	2017-01-23 18:14:15.494582	2017-01-23 18:14:15.494582	16575
17247	2000-01-01 00:00:00	2016-05-31 18:59:59	10294	10031	13	2017-01-23 18:14:15.499882	2017-01-23 18:14:15.499882	16575
17248	2016-06-01 00:00:00	2016-08-31 18:59:59	10294	10030	12	2017-01-23 18:14:15.50591	2017-01-23 18:14:15.50591	16575
17249	2016-06-01 00:00:00	2016-08-31 18:59:59	10294	10031	11	2017-01-23 18:14:15.510845	2017-01-23 18:14:15.510845	16575
17250	2016-09-01 00:00:00	2016-12-31 18:59:59	10294	10030	10	2017-01-23 18:14:15.5162	2017-01-23 18:14:15.5162	16575
17251	2016-09-01 00:00:00	2016-12-31 18:59:59	10294	10031	11	2017-01-23 18:14:15.521113	2017-01-23 18:14:15.521113	16575
17252	2017-01-01 00:00:00	2099-12-31 18:59:59	10294	10030	10	2017-01-23 18:14:15.527066	2017-01-23 18:14:15.527066	16575
17253	2017-01-01 00:00:00	2099-12-31 18:59:59	10294	10031	12	2017-01-23 18:14:15.532065	2017-01-23 18:14:15.532065	16575
17254	2000-01-01 00:00:00	2016-05-31 18:59:59	10295	10030	11	2017-01-23 18:14:15.537802	2017-01-23 18:14:15.537802	16575
17255	2000-01-01 00:00:00	2016-05-31 18:59:59	10295	10031	14	2017-01-23 18:14:15.54295	2017-01-23 18:14:15.54295	16575
17256	2016-06-01 00:00:00	2016-08-31 18:59:59	10295	10030	14	2017-01-23 18:14:15.548733	2017-01-23 18:14:15.548733	16575
17257	2016-06-01 00:00:00	2016-08-31 18:59:59	10295	10031	10	2017-01-23 18:14:15.554029	2017-01-23 18:14:15.554029	16575
17258	2016-09-01 00:00:00	2016-12-31 18:59:59	10295	10030	10	2017-01-23 18:14:15.559952	2017-01-23 18:14:15.559952	16575
17259	2016-09-01 00:00:00	2016-12-31 18:59:59	10295	10031	12	2017-01-23 18:14:15.564996	2017-01-23 18:14:15.564996	16575
17260	2017-01-01 00:00:00	2099-12-31 18:59:59	10295	10030	13	2017-01-23 18:14:15.570607	2017-01-23 18:14:15.570607	16575
17261	2017-01-01 00:00:00	2099-12-31 18:59:59	10295	10031	14	2017-01-23 18:14:15.576218	2017-01-23 18:14:15.576218	16575
17262	2000-01-01 00:00:00	2016-05-31 18:59:59	10296	10030	12	2017-01-23 18:14:15.582373	2017-01-23 18:14:15.582373	16575
17263	2000-01-01 00:00:00	2016-05-31 18:59:59	10296	10031	14	2017-01-23 18:14:15.587972	2017-01-23 18:14:15.587972	16575
17264	2016-06-01 00:00:00	2016-08-31 18:59:59	10296	10030	14	2017-01-23 18:14:15.593811	2017-01-23 18:14:15.593811	16575
17265	2016-06-01 00:00:00	2016-08-31 18:59:59	10296	10031	10	2017-01-23 18:14:15.598891	2017-01-23 18:14:15.598891	16575
17266	2016-09-01 00:00:00	2016-12-31 18:59:59	10296	10030	13	2017-01-23 18:14:15.605244	2017-01-23 18:14:15.605244	16575
17267	2016-09-01 00:00:00	2016-12-31 18:59:59	10296	10031	12	2017-01-23 18:14:15.610378	2017-01-23 18:14:15.610378	16575
17268	2017-01-01 00:00:00	2099-12-31 18:59:59	10296	10030	14	2017-01-23 18:14:15.616379	2017-01-23 18:14:15.616379	16575
17269	2017-01-01 00:00:00	2099-12-31 18:59:59	10296	10031	11	2017-01-23 18:14:15.621095	2017-01-23 18:14:15.621095	16575
17270	2000-01-01 00:00:00	2016-05-31 18:59:59	10297	10030	10	2017-01-23 18:14:15.627362	2017-01-23 18:14:15.627362	16575
17271	2000-01-01 00:00:00	2016-05-31 18:59:59	10297	10031	10	2017-01-23 18:14:15.632872	2017-01-23 18:14:15.632872	16575
17272	2016-06-01 00:00:00	2016-08-31 18:59:59	10297	10030	14	2017-01-23 18:14:15.638685	2017-01-23 18:14:15.638685	16575
17273	2016-06-01 00:00:00	2016-08-31 18:59:59	10297	10031	12	2017-01-23 18:14:15.644057	2017-01-23 18:14:15.644057	16575
17274	2016-09-01 00:00:00	2016-12-31 18:59:59	10297	10030	13	2017-01-23 18:14:15.649975	2017-01-23 18:14:15.649975	16575
17275	2016-09-01 00:00:00	2016-12-31 18:59:59	10297	10031	12	2017-01-23 18:14:15.654775	2017-01-23 18:14:15.654775	16575
17276	2017-01-01 00:00:00	2099-12-31 18:59:59	10297	10030	14	2017-01-23 18:14:15.661049	2017-01-23 18:14:15.661049	16575
17277	2017-01-01 00:00:00	2099-12-31 18:59:59	10297	10031	13	2017-01-23 18:14:15.666671	2017-01-23 18:14:15.666671	16575
17278	2000-01-01 00:00:00	2016-05-31 18:59:59	10298	10030	14	2017-01-23 18:14:15.672443	2017-01-23 18:14:15.672443	16575
17279	2000-01-01 00:00:00	2016-05-31 18:59:59	10298	10031	10	2017-01-23 18:14:15.677628	2017-01-23 18:14:15.677628	16575
17280	2016-06-01 00:00:00	2016-08-31 18:59:59	10298	10030	14	2017-01-23 18:14:15.683593	2017-01-23 18:14:15.683593	16575
17281	2016-06-01 00:00:00	2016-08-31 18:59:59	10298	10031	11	2017-01-23 18:14:15.688821	2017-01-23 18:14:15.688821	16575
17282	2016-09-01 00:00:00	2016-12-31 18:59:59	10298	10030	11	2017-01-23 18:14:15.694733	2017-01-23 18:14:15.694733	16575
17283	2016-09-01 00:00:00	2016-12-31 18:59:59	10298	10031	13	2017-01-23 18:14:15.700086	2017-01-23 18:14:15.700086	16575
17284	2017-01-01 00:00:00	2099-12-31 18:59:59	10298	10030	14	2017-01-23 18:14:15.705995	2017-01-23 18:14:15.705995	16575
17285	2017-01-01 00:00:00	2099-12-31 18:59:59	10298	10031	14	2017-01-23 18:14:15.711268	2017-01-23 18:14:15.711268	16575
17286	2000-01-01 00:00:00	2016-05-31 18:59:59	10299	10030	12	2017-01-23 18:14:15.716981	2017-01-23 18:14:15.716981	16575
17287	2000-01-01 00:00:00	2016-05-31 18:59:59	10299	10031	12	2017-01-23 18:14:15.722892	2017-01-23 18:14:15.722892	16575
17288	2016-06-01 00:00:00	2016-08-31 18:59:59	10299	10030	10	2017-01-23 18:14:15.728739	2017-01-23 18:14:15.728739	16575
17289	2016-06-01 00:00:00	2016-08-31 18:59:59	10299	10031	12	2017-01-23 18:14:15.73392	2017-01-23 18:14:15.73392	16575
17290	2016-09-01 00:00:00	2016-12-31 18:59:59	10299	10030	12	2017-01-23 18:14:15.739597	2017-01-23 18:14:15.739597	16575
17291	2016-09-01 00:00:00	2016-12-31 18:59:59	10299	10031	14	2017-01-23 18:14:15.744848	2017-01-23 18:14:15.744848	16575
17292	2017-01-01 00:00:00	2099-12-31 18:59:59	10299	10030	11	2017-01-23 18:14:15.75063	2017-01-23 18:14:15.75063	16575
17293	2017-01-01 00:00:00	2099-12-31 18:59:59	10299	10031	10	2017-01-23 18:14:15.755922	2017-01-23 18:14:15.755922	16575
17294	2000-01-01 00:00:00	2016-05-31 18:59:59	10300	10030	10	2017-01-23 18:14:15.761651	2017-01-23 18:14:15.761651	16575
17295	2000-01-01 00:00:00	2016-05-31 18:59:59	10300	10031	10	2017-01-23 18:14:15.766592	2017-01-23 18:14:15.766592	16575
17296	2016-06-01 00:00:00	2016-08-31 18:59:59	10300	10030	14	2017-01-23 18:14:15.772586	2017-01-23 18:14:15.772586	16575
17297	2016-06-01 00:00:00	2016-08-31 18:59:59	10300	10031	11	2017-01-23 18:14:15.778037	2017-01-23 18:14:15.778037	16575
17298	2016-09-01 00:00:00	2016-12-31 18:59:59	10300	10030	14	2017-01-23 18:14:15.783538	2017-01-23 18:14:15.783538	16575
17299	2016-09-01 00:00:00	2016-12-31 18:59:59	10300	10031	14	2017-01-23 18:14:15.788545	2017-01-23 18:14:15.788545	16575
17300	2017-01-01 00:00:00	2099-12-31 18:59:59	10300	10030	11	2017-01-23 18:14:15.794261	2017-01-23 18:14:15.794261	16575
17301	2017-01-01 00:00:00	2099-12-31 18:59:59	10300	10031	10	2017-01-23 18:14:15.799334	2017-01-23 18:14:15.799334	16575
17302	2000-01-01 00:00:00	2016-05-31 18:59:59	10301	10030	13	2017-01-23 18:14:15.804969	2017-01-23 18:14:15.804969	16575
17303	2000-01-01 00:00:00	2016-05-31 18:59:59	10301	10031	14	2017-01-23 18:14:15.810061	2017-01-23 18:14:15.810061	16575
17304	2016-06-01 00:00:00	2016-08-31 18:59:59	10301	10030	14	2017-01-23 18:14:15.815911	2017-01-23 18:14:15.815911	16575
17305	2016-06-01 00:00:00	2016-08-31 18:59:59	10301	10031	11	2017-01-23 18:14:15.820962	2017-01-23 18:14:15.820962	16575
17306	2016-09-01 00:00:00	2016-12-31 18:59:59	10301	10030	11	2017-01-23 18:14:15.826599	2017-01-23 18:14:15.826599	16575
17307	2016-09-01 00:00:00	2016-12-31 18:59:59	10301	10031	11	2017-01-23 18:14:15.832173	2017-01-23 18:14:15.832173	16575
17308	2017-01-01 00:00:00	2099-12-31 18:59:59	10301	10030	11	2017-01-23 18:14:15.838103	2017-01-23 18:14:15.838103	16575
17309	2017-01-01 00:00:00	2099-12-31 18:59:59	10301	10031	14	2017-01-23 18:14:15.843163	2017-01-23 18:14:15.843163	16575
17310	2000-01-01 00:00:00	2016-05-31 18:59:59	10302	10030	13	2017-01-23 18:14:15.848706	2017-01-23 18:14:15.848706	16575
17311	2000-01-01 00:00:00	2016-05-31 18:59:59	10302	10031	12	2017-01-23 18:14:15.853648	2017-01-23 18:14:15.853648	16575
17312	2016-06-01 00:00:00	2016-08-31 18:59:59	10302	10030	12	2017-01-23 18:14:15.859846	2017-01-23 18:14:15.859846	16575
17313	2016-06-01 00:00:00	2016-08-31 18:59:59	10302	10031	11	2017-01-23 18:14:15.865942	2017-01-23 18:14:15.865942	16575
17314	2016-09-01 00:00:00	2016-12-31 18:59:59	10302	10030	10	2017-01-23 18:14:15.871879	2017-01-23 18:14:15.871879	16575
17315	2016-09-01 00:00:00	2016-12-31 18:59:59	10302	10031	11	2017-01-23 18:14:15.876918	2017-01-23 18:14:15.876918	16575
17316	2017-01-01 00:00:00	2099-12-31 18:59:59	10302	10030	14	2017-01-23 18:14:15.882546	2017-01-23 18:14:15.882546	16575
17317	2017-01-01 00:00:00	2099-12-31 18:59:59	10302	10031	14	2017-01-23 18:14:15.887364	2017-01-23 18:14:15.887364	16575
17318	2000-01-01 00:00:00	2016-05-31 18:59:59	10303	10030	10	2017-01-23 18:14:15.893502	2017-01-23 18:14:15.893502	16575
17319	2000-01-01 00:00:00	2016-05-31 18:59:59	10303	10031	13	2017-01-23 18:14:15.898643	2017-01-23 18:14:15.898643	16575
17320	2016-06-01 00:00:00	2016-08-31 18:59:59	10303	10030	14	2017-01-23 18:14:15.904448	2017-01-23 18:14:15.904448	16575
17321	2016-06-01 00:00:00	2016-08-31 18:59:59	10303	10031	12	2017-01-23 18:14:15.909877	2017-01-23 18:14:15.909877	16575
17322	2016-09-01 00:00:00	2016-12-31 18:59:59	10303	10030	14	2017-01-23 18:14:15.915633	2017-01-23 18:14:15.915633	16575
17323	2016-09-01 00:00:00	2016-12-31 18:59:59	10303	10031	13	2017-01-23 18:14:15.920518	2017-01-23 18:14:15.920518	16575
17324	2017-01-01 00:00:00	2099-12-31 18:59:59	10303	10030	14	2017-01-23 18:14:15.926215	2017-01-23 18:14:15.926215	16575
17325	2017-01-01 00:00:00	2099-12-31 18:59:59	10303	10031	11	2017-01-23 18:14:15.932038	2017-01-23 18:14:15.932038	16575
17326	2000-01-01 00:00:00	2016-05-31 18:59:59	10304	10030	13	2017-01-23 18:14:15.937886	2017-01-23 18:14:15.937886	16575
17327	2000-01-01 00:00:00	2016-05-31 18:59:59	10304	10031	10	2017-01-23 18:14:15.943076	2017-01-23 18:14:15.943076	16575
17328	2016-06-01 00:00:00	2016-08-31 18:59:59	10304	10030	10	2017-01-23 18:14:15.948567	2017-01-23 18:14:15.948567	16575
17329	2016-06-01 00:00:00	2016-08-31 18:59:59	10304	10031	13	2017-01-23 18:14:15.953956	2017-01-23 18:14:15.953956	16575
17330	2016-09-01 00:00:00	2016-12-31 18:59:59	10304	10030	13	2017-01-23 18:14:15.959701	2017-01-23 18:14:15.959701	16575
17331	2016-09-01 00:00:00	2016-12-31 18:59:59	10304	10031	14	2017-01-23 18:14:15.964657	2017-01-23 18:14:15.964657	16575
17332	2017-01-01 00:00:00	2099-12-31 18:59:59	10304	10030	12	2017-01-23 18:14:15.970582	2017-01-23 18:14:15.970582	16575
17333	2017-01-01 00:00:00	2099-12-31 18:59:59	10304	10031	11	2017-01-23 18:14:15.975996	2017-01-23 18:14:15.975996	16575
17334	2000-01-01 00:00:00	2016-05-31 18:59:59	10305	10030	13	2017-01-23 18:14:15.981827	2017-01-23 18:14:15.981827	16575
17335	2000-01-01 00:00:00	2016-05-31 18:59:59	10305	10031	10	2017-01-23 18:14:15.987047	2017-01-23 18:14:15.987047	16575
17336	2016-06-01 00:00:00	2016-08-31 18:59:59	10305	10030	12	2017-01-23 18:14:15.992787	2017-01-23 18:14:15.992787	16575
17337	2016-06-01 00:00:00	2016-08-31 18:59:59	10305	10031	14	2017-01-23 18:14:15.998009	2017-01-23 18:14:15.998009	16575
17338	2016-09-01 00:00:00	2016-12-31 18:59:59	10305	10030	10	2017-01-23 18:14:16.004096	2017-01-23 18:14:16.004096	16575
17339	2016-09-01 00:00:00	2016-12-31 18:59:59	10305	10031	13	2017-01-23 18:14:16.009428	2017-01-23 18:14:16.009428	16575
17340	2017-01-01 00:00:00	2099-12-31 18:59:59	10305	10030	12	2017-01-23 18:14:16.015307	2017-01-23 18:14:16.015307	16575
17341	2017-01-01 00:00:00	2099-12-31 18:59:59	10305	10031	10	2017-01-23 18:14:16.020259	2017-01-23 18:14:16.020259	16575
17342	2000-01-01 00:00:00	2016-05-31 18:59:59	10306	10030	12	2017-01-23 18:14:16.026025	2017-01-23 18:14:16.026025	16575
17343	2000-01-01 00:00:00	2016-05-31 18:59:59	10306	10031	11	2017-01-23 18:14:16.03104	2017-01-23 18:14:16.03104	16575
17344	2016-06-01 00:00:00	2016-08-31 18:59:59	10306	10030	10	2017-01-23 18:14:16.036942	2017-01-23 18:14:16.036942	16575
17345	2016-06-01 00:00:00	2016-08-31 18:59:59	10306	10031	12	2017-01-23 18:14:16.041873	2017-01-23 18:14:16.041873	16575
17346	2016-09-01 00:00:00	2016-12-31 18:59:59	10306	10030	10	2017-01-23 18:14:16.047635	2017-01-23 18:14:16.047635	16575
17347	2016-09-01 00:00:00	2016-12-31 18:59:59	10306	10031	14	2017-01-23 18:14:16.052919	2017-01-23 18:14:16.052919	16575
17348	2017-01-01 00:00:00	2099-12-31 18:59:59	10306	10030	11	2017-01-23 18:14:16.058766	2017-01-23 18:14:16.058766	16575
17349	2017-01-01 00:00:00	2099-12-31 18:59:59	10306	10031	11	2017-01-23 18:14:16.064111	2017-01-23 18:14:16.064111	16575
17350	2000-01-01 00:00:00	2016-05-31 18:59:59	10307	10030	14	2017-01-23 18:14:16.06969	2017-01-23 18:14:16.06969	16575
17351	2000-01-01 00:00:00	2016-05-31 18:59:59	10307	10031	10	2017-01-23 18:14:16.075205	2017-01-23 18:14:16.075205	16575
17352	2016-06-01 00:00:00	2016-08-31 18:59:59	10307	10030	12	2017-01-23 18:14:16.080789	2017-01-23 18:14:16.080789	16575
17353	2016-06-01 00:00:00	2016-08-31 18:59:59	10307	10031	14	2017-01-23 18:14:16.085572	2017-01-23 18:14:16.085572	16575
17354	2016-09-01 00:00:00	2016-12-31 18:59:59	10307	10030	10	2017-01-23 18:14:16.091375	2017-01-23 18:14:16.091375	16575
17355	2016-09-01 00:00:00	2016-12-31 18:59:59	10307	10031	14	2017-01-23 18:14:16.096221	2017-01-23 18:14:16.096221	16575
17356	2017-01-01 00:00:00	2099-12-31 18:59:59	10307	10030	14	2017-01-23 18:14:16.102319	2017-01-23 18:14:16.102319	16575
17357	2017-01-01 00:00:00	2099-12-31 18:59:59	10307	10031	13	2017-01-23 18:14:16.107742	2017-01-23 18:14:16.107742	16575
17358	2000-01-01 00:00:00	2016-05-31 18:59:59	10308	10030	13	2017-01-23 18:14:16.113304	2017-01-23 18:14:16.113304	16575
17359	2000-01-01 00:00:00	2016-05-31 18:59:59	10308	10031	13	2017-01-23 18:14:16.118476	2017-01-23 18:14:16.118476	16575
17360	2016-06-01 00:00:00	2016-08-31 18:59:59	10308	10030	14	2017-01-23 18:14:16.12439	2017-01-23 18:14:16.12439	16575
17361	2016-06-01 00:00:00	2016-08-31 18:59:59	10308	10031	12	2017-01-23 18:14:16.129307	2017-01-23 18:14:16.129307	16575
17362	2016-09-01 00:00:00	2016-12-31 18:59:59	10308	10030	11	2017-01-23 18:14:16.135521	2017-01-23 18:14:16.135521	16575
17363	2016-09-01 00:00:00	2016-12-31 18:59:59	10308	10031	12	2017-01-23 18:14:16.141653	2017-01-23 18:14:16.141653	16575
17364	2017-01-01 00:00:00	2099-12-31 18:59:59	10308	10030	14	2017-01-23 18:14:16.148004	2017-01-23 18:14:16.148004	16575
17365	2017-01-01 00:00:00	2099-12-31 18:59:59	10308	10031	12	2017-01-23 18:14:16.152964	2017-01-23 18:14:16.152964	16575
17366	2000-01-01 00:00:00	2016-05-31 18:59:59	10309	10030	14	2017-01-23 18:14:16.158754	2017-01-23 18:14:16.158754	16575
17367	2000-01-01 00:00:00	2016-05-31 18:59:59	10309	10031	11	2017-01-23 18:14:16.163838	2017-01-23 18:14:16.163838	16575
17368	2016-06-01 00:00:00	2016-08-31 18:59:59	10309	10030	10	2017-01-23 18:14:16.169612	2017-01-23 18:14:16.169612	16575
17369	2016-06-01 00:00:00	2016-08-31 18:59:59	10309	10031	12	2017-01-23 18:14:16.174891	2017-01-23 18:14:16.174891	16575
17370	2016-09-01 00:00:00	2016-12-31 18:59:59	10309	10030	10	2017-01-23 18:14:16.18058	2017-01-23 18:14:16.18058	16575
17371	2016-09-01 00:00:00	2016-12-31 18:59:59	10309	10031	11	2017-01-23 18:14:16.185903	2017-01-23 18:14:16.185903	16575
17372	2017-01-01 00:00:00	2099-12-31 18:59:59	10309	10030	12	2017-01-23 18:14:16.192061	2017-01-23 18:14:16.192061	16575
17373	2017-01-01 00:00:00	2099-12-31 18:59:59	10309	10031	12	2017-01-23 18:14:16.197161	2017-01-23 18:14:16.197161	16575
17374	2000-01-01 00:00:00	2016-05-31 18:59:59	10310	10030	10	2017-01-23 18:14:16.203095	2017-01-23 18:14:16.203095	16575
17375	2000-01-01 00:00:00	2016-05-31 18:59:59	10310	10031	11	2017-01-23 18:14:16.208261	2017-01-23 18:14:16.208261	16575
17376	2016-06-01 00:00:00	2016-08-31 18:59:59	10310	10030	12	2017-01-23 18:14:16.213933	2017-01-23 18:14:16.213933	16575
17377	2016-06-01 00:00:00	2016-08-31 18:59:59	10310	10031	12	2017-01-23 18:14:16.21905	2017-01-23 18:14:16.21905	16575
17378	2016-09-01 00:00:00	2016-12-31 18:59:59	10310	10030	10	2017-01-23 18:14:16.224902	2017-01-23 18:14:16.224902	16575
17379	2016-09-01 00:00:00	2016-12-31 18:59:59	10310	10031	13	2017-01-23 18:14:16.229828	2017-01-23 18:14:16.229828	16575
17380	2017-01-01 00:00:00	2099-12-31 18:59:59	10310	10030	13	2017-01-23 18:14:16.235529	2017-01-23 18:14:16.235529	16575
17381	2017-01-01 00:00:00	2099-12-31 18:59:59	10310	10031	14	2017-01-23 18:14:16.240751	2017-01-23 18:14:16.240751	16575
17382	2000-01-01 00:00:00	2016-05-31 18:59:59	10311	10030	10	2017-01-23 18:14:16.246396	2017-01-23 18:14:16.246396	16575
17383	2000-01-01 00:00:00	2016-05-31 18:59:59	10311	10031	11	2017-01-23 18:14:16.251733	2017-01-23 18:14:16.251733	16575
17384	2016-06-01 00:00:00	2016-08-31 18:59:59	10311	10030	11	2017-01-23 18:14:16.257827	2017-01-23 18:14:16.257827	16575
17385	2016-06-01 00:00:00	2016-08-31 18:59:59	10311	10031	12	2017-01-23 18:14:16.262743	2017-01-23 18:14:16.262743	16575
17386	2016-09-01 00:00:00	2016-12-31 18:59:59	10311	10030	14	2017-01-23 18:14:16.268685	2017-01-23 18:14:16.268685	16575
17387	2016-09-01 00:00:00	2016-12-31 18:59:59	10311	10031	13	2017-01-23 18:14:16.273889	2017-01-23 18:14:16.273889	16575
17388	2017-01-01 00:00:00	2099-12-31 18:59:59	10311	10030	14	2017-01-23 18:14:16.280295	2017-01-23 18:14:16.280295	16575
17389	2017-01-01 00:00:00	2099-12-31 18:59:59	10311	10031	12	2017-01-23 18:14:16.286046	2017-01-23 18:14:16.286046	16575
17390	2000-01-01 00:00:00	2016-05-31 18:59:59	10312	10030	13	2017-01-23 18:14:16.291972	2017-01-23 18:14:16.291972	16575
17391	2000-01-01 00:00:00	2016-05-31 18:59:59	10312	10031	10	2017-01-23 18:14:16.296891	2017-01-23 18:14:16.296891	16575
17392	2016-06-01 00:00:00	2016-08-31 18:59:59	10312	10030	14	2017-01-23 18:14:16.3026	2017-01-23 18:14:16.3026	16575
17393	2016-06-01 00:00:00	2016-08-31 18:59:59	10312	10031	11	2017-01-23 18:14:16.307674	2017-01-23 18:14:16.307674	16575
17394	2016-09-01 00:00:00	2016-12-31 18:59:59	10312	10030	12	2017-01-23 18:14:16.313469	2017-01-23 18:14:16.313469	16575
17395	2016-09-01 00:00:00	2016-12-31 18:59:59	10312	10031	11	2017-01-23 18:14:16.318703	2017-01-23 18:14:16.318703	16575
17396	2017-01-01 00:00:00	2099-12-31 18:59:59	10312	10030	12	2017-01-23 18:14:16.324667	2017-01-23 18:14:16.324667	16575
17397	2017-01-01 00:00:00	2099-12-31 18:59:59	10312	10031	14	2017-01-23 18:14:16.329654	2017-01-23 18:14:16.329654	16575
17398	2000-01-01 00:00:00	2016-05-31 18:59:59	10313	10030	11	2017-01-23 18:14:16.335323	2017-01-23 18:14:16.335323	16575
17399	2000-01-01 00:00:00	2016-05-31 18:59:59	10313	10031	11	2017-01-23 18:14:16.340876	2017-01-23 18:14:16.340876	16575
17400	2016-06-01 00:00:00	2016-08-31 18:59:59	10313	10030	11	2017-01-23 18:14:16.346584	2017-01-23 18:14:16.346584	16575
17401	2016-06-01 00:00:00	2016-08-31 18:59:59	10313	10031	11	2017-01-23 18:14:16.35166	2017-01-23 18:14:16.35166	16575
17402	2016-09-01 00:00:00	2016-12-31 18:59:59	10313	10030	11	2017-01-23 18:14:16.357295	2017-01-23 18:14:16.357295	16575
17403	2016-09-01 00:00:00	2016-12-31 18:59:59	10313	10031	14	2017-01-23 18:14:16.362608	2017-01-23 18:14:16.362608	16575
17404	2017-01-01 00:00:00	2099-12-31 18:59:59	10313	10030	14	2017-01-23 18:14:16.368488	2017-01-23 18:14:16.368488	16575
17405	2017-01-01 00:00:00	2099-12-31 18:59:59	10313	10031	11	2017-01-23 18:14:16.373894	2017-01-23 18:14:16.373894	16575
17406	2000-01-01 00:00:00	2016-05-31 18:59:59	10314	10030	14	2017-01-23 18:14:16.379593	2017-01-23 18:14:16.379593	16575
17407	2000-01-01 00:00:00	2016-05-31 18:59:59	10314	10031	12	2017-01-23 18:14:16.384599	2017-01-23 18:14:16.384599	16575
17408	2016-06-01 00:00:00	2016-08-31 18:59:59	10314	10030	11	2017-01-23 18:14:16.390783	2017-01-23 18:14:16.390783	16575
17409	2016-06-01 00:00:00	2016-08-31 18:59:59	10314	10031	14	2017-01-23 18:14:16.395741	2017-01-23 18:14:16.395741	16575
17410	2016-09-01 00:00:00	2016-12-31 18:59:59	10314	10030	13	2017-01-23 18:14:16.401556	2017-01-23 18:14:16.401556	16575
17411	2016-09-01 00:00:00	2016-12-31 18:59:59	10314	10031	10	2017-01-23 18:14:16.406975	2017-01-23 18:14:16.406975	16575
17412	2017-01-01 00:00:00	2099-12-31 18:59:59	10314	10030	13	2017-01-23 18:14:16.4125	2017-01-23 18:14:16.4125	16575
17413	2017-01-01 00:00:00	2099-12-31 18:59:59	10314	10031	10	2017-01-23 18:14:16.417455	2017-01-23 18:14:16.417455	16575
17414	2000-01-01 00:00:00	2016-05-31 18:59:59	10315	10030	12	2017-01-23 18:14:16.424103	2017-01-23 18:14:16.424103	16575
17415	2000-01-01 00:00:00	2016-05-31 18:59:59	10315	10031	10	2017-01-23 18:14:16.42924	2017-01-23 18:14:16.42924	16575
17416	2016-06-01 00:00:00	2016-08-31 18:59:59	10315	10030	10	2017-01-23 18:14:16.435166	2017-01-23 18:14:16.435166	16575
17417	2016-06-01 00:00:00	2016-08-31 18:59:59	10315	10031	14	2017-01-23 18:14:16.440681	2017-01-23 18:14:16.440681	16575
17418	2016-09-01 00:00:00	2016-12-31 18:59:59	10315	10030	14	2017-01-23 18:14:16.446613	2017-01-23 18:14:16.446613	16575
17419	2016-09-01 00:00:00	2016-12-31 18:59:59	10315	10031	11	2017-01-23 18:14:16.4517	2017-01-23 18:14:16.4517	16575
17420	2017-01-01 00:00:00	2099-12-31 18:59:59	10315	10030	11	2017-01-23 18:14:16.457669	2017-01-23 18:14:16.457669	16575
17421	2017-01-01 00:00:00	2099-12-31 18:59:59	10315	10031	10	2017-01-23 18:14:16.462863	2017-01-23 18:14:16.462863	16575
17422	2000-01-01 00:00:00	2016-05-31 18:59:59	10316	10030	10	2017-01-23 18:14:16.468608	2017-01-23 18:14:16.468608	16575
17423	2000-01-01 00:00:00	2016-05-31 18:59:59	10316	10031	11	2017-01-23 18:14:16.473835	2017-01-23 18:14:16.473835	16575
17424	2016-06-01 00:00:00	2016-08-31 18:59:59	10316	10030	13	2017-01-23 18:14:16.479448	2017-01-23 18:14:16.479448	16575
17425	2016-06-01 00:00:00	2016-08-31 18:59:59	10316	10031	10	2017-01-23 18:14:16.484531	2017-01-23 18:14:16.484531	16575
17426	2016-09-01 00:00:00	2016-12-31 18:59:59	10316	10030	12	2017-01-23 18:14:16.490412	2017-01-23 18:14:16.490412	16575
17427	2016-09-01 00:00:00	2016-12-31 18:59:59	10316	10031	13	2017-01-23 18:14:16.495292	2017-01-23 18:14:16.495292	16575
17428	2017-01-01 00:00:00	2099-12-31 18:59:59	10316	10030	14	2017-01-23 18:14:16.501248	2017-01-23 18:14:16.501248	16575
17429	2017-01-01 00:00:00	2099-12-31 18:59:59	10316	10031	14	2017-01-23 18:14:16.506296	2017-01-23 18:14:16.506296	16575
17430	2000-01-01 00:00:00	2016-05-31 18:59:59	10317	10030	11	2017-01-23 18:14:16.512116	2017-01-23 18:14:16.512116	16575
17431	2000-01-01 00:00:00	2016-05-31 18:59:59	10317	10031	13	2017-01-23 18:14:16.517327	2017-01-23 18:14:16.517327	16575
17432	2016-06-01 00:00:00	2016-08-31 18:59:59	10317	10030	11	2017-01-23 18:14:16.523558	2017-01-23 18:14:16.523558	16575
17433	2016-06-01 00:00:00	2016-08-31 18:59:59	10317	10031	10	2017-01-23 18:14:16.52909	2017-01-23 18:14:16.52909	16575
17434	2016-09-01 00:00:00	2016-12-31 18:59:59	10317	10030	13	2017-01-23 18:14:16.53494	2017-01-23 18:14:16.53494	16575
17435	2016-09-01 00:00:00	2016-12-31 18:59:59	10317	10031	10	2017-01-23 18:14:16.539925	2017-01-23 18:14:16.539925	16575
17436	2017-01-01 00:00:00	2099-12-31 18:59:59	10317	10030	14	2017-01-23 18:14:16.545696	2017-01-23 18:14:16.545696	16575
17437	2017-01-01 00:00:00	2099-12-31 18:59:59	10317	10031	13	2017-01-23 18:14:16.55094	2017-01-23 18:14:16.55094	16575
17438	2000-01-01 00:00:00	2016-05-31 18:59:59	10318	10030	10	2017-01-23 18:14:16.556661	2017-01-23 18:14:16.556661	16575
17439	2000-01-01 00:00:00	2016-05-31 18:59:59	10318	10031	14	2017-01-23 18:14:16.562731	2017-01-23 18:14:16.562731	16575
17440	2016-06-01 00:00:00	2016-08-31 18:59:59	10318	10030	12	2017-01-23 18:14:16.568731	2017-01-23 18:14:16.568731	16575
17441	2016-06-01 00:00:00	2016-08-31 18:59:59	10318	10031	13	2017-01-23 18:14:16.573957	2017-01-23 18:14:16.573957	16575
17442	2016-09-01 00:00:00	2016-12-31 18:59:59	10318	10030	10	2017-01-23 18:14:16.579654	2017-01-23 18:14:16.579654	16575
17443	2016-09-01 00:00:00	2016-12-31 18:59:59	10318	10031	14	2017-01-23 18:14:16.584721	2017-01-23 18:14:16.584721	16575
17444	2017-01-01 00:00:00	2099-12-31 18:59:59	10318	10030	12	2017-01-23 18:14:16.590716	2017-01-23 18:14:16.590716	16575
17445	2017-01-01 00:00:00	2099-12-31 18:59:59	10318	10031	14	2017-01-23 18:14:16.595597	2017-01-23 18:14:16.595597	16575
17446	2000-01-01 00:00:00	2016-05-31 18:59:59	10319	10030	14	2017-01-23 18:14:16.60131	2017-01-23 18:14:16.60131	16575
17447	2000-01-01 00:00:00	2016-05-31 18:59:59	10319	10031	12	2017-01-23 18:14:16.606646	2017-01-23 18:14:16.606646	16575
17448	2016-06-01 00:00:00	2016-08-31 18:59:59	10319	10030	10	2017-01-23 18:14:16.612736	2017-01-23 18:14:16.612736	16575
17449	2016-06-01 00:00:00	2016-08-31 18:59:59	10319	10031	10	2017-01-23 18:14:16.61766	2017-01-23 18:14:16.61766	16575
17450	2016-09-01 00:00:00	2016-12-31 18:59:59	10319	10030	11	2017-01-23 18:14:16.623643	2017-01-23 18:14:16.623643	16575
17451	2016-09-01 00:00:00	2016-12-31 18:59:59	10319	10031	14	2017-01-23 18:14:16.628999	2017-01-23 18:14:16.628999	16575
17452	2017-01-01 00:00:00	2099-12-31 18:59:59	10319	10030	13	2017-01-23 18:14:16.634723	2017-01-23 18:14:16.634723	16575
17453	2017-01-01 00:00:00	2099-12-31 18:59:59	10319	10031	10	2017-01-23 18:14:16.639663	2017-01-23 18:14:16.639663	16575
17454	2000-01-01 00:00:00	2016-05-31 18:59:59	10320	10030	14	2017-01-23 18:14:16.645427	2017-01-23 18:14:16.645427	16575
17455	2000-01-01 00:00:00	2016-05-31 18:59:59	10320	10031	13	2017-01-23 18:14:16.650798	2017-01-23 18:14:16.650798	16575
17456	2016-06-01 00:00:00	2016-08-31 18:59:59	10320	10030	12	2017-01-23 18:14:16.656322	2017-01-23 18:14:16.656322	16575
17457	2016-06-01 00:00:00	2016-08-31 18:59:59	10320	10031	13	2017-01-23 18:14:16.662328	2017-01-23 18:14:16.662328	16575
17458	2016-09-01 00:00:00	2016-12-31 18:59:59	10320	10030	12	2017-01-23 18:14:16.668214	2017-01-23 18:14:16.668214	16575
17459	2016-09-01 00:00:00	2016-12-31 18:59:59	10320	10031	10	2017-01-23 18:14:16.673771	2017-01-23 18:14:16.673771	16575
17460	2017-01-01 00:00:00	2099-12-31 18:59:59	10320	10030	11	2017-01-23 18:14:16.679744	2017-01-23 18:14:16.679744	16575
17461	2017-01-01 00:00:00	2099-12-31 18:59:59	10320	10031	11	2017-01-23 18:14:16.685151	2017-01-23 18:14:16.685151	16575
17462	2000-01-01 00:00:00	2016-05-31 18:59:59	10321	10030	12	2017-01-23 18:14:16.691186	2017-01-23 18:14:16.691186	16575
17463	2000-01-01 00:00:00	2016-05-31 18:59:59	10321	10031	14	2017-01-23 18:14:16.696753	2017-01-23 18:14:16.696753	16575
17464	2016-06-01 00:00:00	2016-08-31 18:59:59	10321	10030	10	2017-01-23 18:14:16.702783	2017-01-23 18:14:16.702783	16575
17465	2016-06-01 00:00:00	2016-08-31 18:59:59	10321	10031	13	2017-01-23 18:14:16.708366	2017-01-23 18:14:16.708366	16575
17466	2016-09-01 00:00:00	2016-12-31 18:59:59	10321	10030	10	2017-01-23 18:14:16.714389	2017-01-23 18:14:16.714389	16575
17467	2016-09-01 00:00:00	2016-12-31 18:59:59	10321	10031	13	2017-01-23 18:14:16.719423	2017-01-23 18:14:16.719423	16575
17468	2017-01-01 00:00:00	2099-12-31 18:59:59	10321	10030	12	2017-01-23 18:14:16.725593	2017-01-23 18:14:16.725593	16575
17469	2017-01-01 00:00:00	2099-12-31 18:59:59	10321	10031	14	2017-01-23 18:14:16.730761	2017-01-23 18:14:16.730761	16575
17470	2000-01-01 00:00:00	2016-05-31 18:59:59	10322	10030	11	2017-01-23 18:14:16.736219	2017-01-23 18:14:16.736219	16575
17471	2000-01-01 00:00:00	2016-05-31 18:59:59	10322	10031	10	2017-01-23 18:14:16.741234	2017-01-23 18:14:16.741234	16575
17472	2016-06-01 00:00:00	2016-08-31 18:59:59	10322	10030	11	2017-01-23 18:14:16.746737	2017-01-23 18:14:16.746737	16575
17473	2016-06-01 00:00:00	2016-08-31 18:59:59	10322	10031	14	2017-01-23 18:14:16.751914	2017-01-23 18:14:16.751914	16575
17474	2016-09-01 00:00:00	2016-12-31 18:59:59	10322	10030	14	2017-01-23 18:14:16.757705	2017-01-23 18:14:16.757705	16575
17475	2016-09-01 00:00:00	2016-12-31 18:59:59	10322	10031	14	2017-01-23 18:14:16.762916	2017-01-23 18:14:16.762916	16575
17476	2017-01-01 00:00:00	2099-12-31 18:59:59	10322	10030	14	2017-01-23 18:14:16.768971	2017-01-23 18:14:16.768971	16575
17477	2017-01-01 00:00:00	2099-12-31 18:59:59	10322	10031	14	2017-01-23 18:14:16.774382	2017-01-23 18:14:16.774382	16575
17478	2000-01-01 00:00:00	2016-05-31 18:59:59	10323	10030	11	2017-01-23 18:14:16.780255	2017-01-23 18:14:16.780255	16575
17479	2000-01-01 00:00:00	2016-05-31 18:59:59	10323	10031	11	2017-01-23 18:14:16.785396	2017-01-23 18:14:16.785396	16575
17480	2016-06-01 00:00:00	2016-08-31 18:59:59	10323	10030	11	2017-01-23 18:14:16.791441	2017-01-23 18:14:16.791441	16575
17481	2016-06-01 00:00:00	2016-08-31 18:59:59	10323	10031	10	2017-01-23 18:14:16.796699	2017-01-23 18:14:16.796699	16575
17482	2016-09-01 00:00:00	2016-12-31 18:59:59	10323	10030	13	2017-01-23 18:14:16.80233	2017-01-23 18:14:16.80233	16575
17483	2016-09-01 00:00:00	2016-12-31 18:59:59	10323	10031	14	2017-01-23 18:14:16.807524	2017-01-23 18:14:16.807524	16575
17484	2017-01-01 00:00:00	2099-12-31 18:59:59	10323	10030	10	2017-01-23 18:14:16.813848	2017-01-23 18:14:16.813848	16575
17485	2017-01-01 00:00:00	2099-12-31 18:59:59	10323	10031	14	2017-01-23 18:14:16.818792	2017-01-23 18:14:16.818792	16575
17486	2000-01-01 00:00:00	2016-05-31 18:59:59	10324	10030	11	2017-01-23 18:14:16.824592	2017-01-23 18:14:16.824592	16575
17487	2000-01-01 00:00:00	2016-05-31 18:59:59	10324	10031	11	2017-01-23 18:14:16.82959	2017-01-23 18:14:16.82959	16575
17488	2016-06-01 00:00:00	2016-08-31 18:59:59	10324	10030	14	2017-01-23 18:14:16.835549	2017-01-23 18:14:16.835549	16575
17489	2016-06-01 00:00:00	2016-08-31 18:59:59	10324	10031	13	2017-01-23 18:14:16.840683	2017-01-23 18:14:16.840683	16575
17490	2016-09-01 00:00:00	2016-12-31 18:59:59	10324	10030	10	2017-01-23 18:14:16.847043	2017-01-23 18:14:16.847043	16575
17491	2016-09-01 00:00:00	2016-12-31 18:59:59	10324	10031	10	2017-01-23 18:14:16.851969	2017-01-23 18:14:16.851969	16575
17492	2017-01-01 00:00:00	2099-12-31 18:59:59	10324	10030	13	2017-01-23 18:14:16.85762	2017-01-23 18:14:16.85762	16575
17493	2017-01-01 00:00:00	2099-12-31 18:59:59	10324	10031	11	2017-01-23 18:14:16.862599	2017-01-23 18:14:16.862599	16575
17494	2000-01-01 00:00:00	2016-05-31 18:59:59	10325	10030	10	2017-01-23 18:14:16.868578	2017-01-23 18:14:16.868578	16575
17495	2000-01-01 00:00:00	2016-05-31 18:59:59	10325	10031	14	2017-01-23 18:14:16.87416	2017-01-23 18:14:16.87416	16575
17496	2016-06-01 00:00:00	2016-08-31 18:59:59	10325	10030	12	2017-01-23 18:14:16.879721	2017-01-23 18:14:16.879721	16575
17497	2016-06-01 00:00:00	2016-08-31 18:59:59	10325	10031	13	2017-01-23 18:14:16.884863	2017-01-23 18:14:16.884863	16575
17498	2016-09-01 00:00:00	2016-12-31 18:59:59	10325	10030	11	2017-01-23 18:14:16.890922	2017-01-23 18:14:16.890922	16575
17499	2016-09-01 00:00:00	2016-12-31 18:59:59	10325	10031	13	2017-01-23 18:14:16.895949	2017-01-23 18:14:16.895949	16575
17500	2017-01-01 00:00:00	2099-12-31 18:59:59	10325	10030	10	2017-01-23 18:14:16.901549	2017-01-23 18:14:16.901549	16575
17501	2017-01-01 00:00:00	2099-12-31 18:59:59	10325	10031	10	2017-01-23 18:14:16.906921	2017-01-23 18:14:16.906921	16575
17502	2000-01-01 00:00:00	2016-05-31 18:59:59	10326	10030	13	2017-01-23 18:14:16.912738	2017-01-23 18:14:16.912738	16575
17503	2000-01-01 00:00:00	2016-05-31 18:59:59	10326	10031	11	2017-01-23 18:14:16.917639	2017-01-23 18:14:16.917639	16575
17504	2016-06-01 00:00:00	2016-08-31 18:59:59	10326	10030	11	2017-01-23 18:14:16.923518	2017-01-23 18:14:16.923518	16575
17505	2016-06-01 00:00:00	2016-08-31 18:59:59	10326	10031	13	2017-01-23 18:14:16.929136	2017-01-23 18:14:16.929136	16575
17506	2016-09-01 00:00:00	2016-12-31 18:59:59	10326	10030	13	2017-01-23 18:14:16.93489	2017-01-23 18:14:16.93489	16575
17507	2016-09-01 00:00:00	2016-12-31 18:59:59	10326	10031	10	2017-01-23 18:14:16.941732	2017-01-23 18:14:16.941732	16575
17508	2017-01-01 00:00:00	2099-12-31 18:59:59	10326	10030	11	2017-01-23 18:14:16.947479	2017-01-23 18:14:16.947479	16575
17509	2017-01-01 00:00:00	2099-12-31 18:59:59	10326	10031	11	2017-01-23 18:14:16.953109	2017-01-23 18:14:16.953109	16575
17510	2000-01-01 00:00:00	2016-05-31 18:59:59	10327	10030	11	2017-01-23 18:14:16.959244	2017-01-23 18:14:16.959244	16575
17511	2000-01-01 00:00:00	2016-05-31 18:59:59	10327	10031	13	2017-01-23 18:14:16.964043	2017-01-23 18:14:16.964043	16575
17512	2016-06-01 00:00:00	2016-08-31 18:59:59	10327	10030	11	2017-01-23 18:14:16.970029	2017-01-23 18:14:16.970029	16575
17513	2016-06-01 00:00:00	2016-08-31 18:59:59	10327	10031	12	2017-01-23 18:14:16.975049	2017-01-23 18:14:16.975049	16575
17514	2016-09-01 00:00:00	2016-12-31 18:59:59	10327	10030	10	2017-01-23 18:14:16.980972	2017-01-23 18:14:16.980972	16575
17515	2016-09-01 00:00:00	2016-12-31 18:59:59	10327	10031	11	2017-01-23 18:14:16.986873	2017-01-23 18:14:16.986873	16575
17516	2017-01-01 00:00:00	2099-12-31 18:59:59	10327	10030	10	2017-01-23 18:14:16.999189	2017-01-23 18:14:16.999189	16575
17517	2017-01-01 00:00:00	2099-12-31 18:59:59	10327	10031	11	2017-01-23 18:14:17.011277	2017-01-23 18:14:17.011277	16575
17518	2000-01-01 00:00:00	2016-05-31 18:59:59	10328	10030	11	2017-01-23 18:14:17.020114	2017-01-23 18:14:17.020114	16575
17519	2000-01-01 00:00:00	2016-05-31 18:59:59	10328	10031	14	2017-01-23 18:14:17.02657	2017-01-23 18:14:17.02657	16575
17520	2016-06-01 00:00:00	2016-08-31 18:59:59	10328	10030	10	2017-01-23 18:14:17.03264	2017-01-23 18:14:17.03264	16575
17521	2016-06-01 00:00:00	2016-08-31 18:59:59	10328	10031	10	2017-01-23 18:14:17.037971	2017-01-23 18:14:17.037971	16575
17522	2016-09-01 00:00:00	2016-12-31 18:59:59	10328	10030	10	2017-01-23 18:14:17.043887	2017-01-23 18:14:17.043887	16575
17523	2016-09-01 00:00:00	2016-12-31 18:59:59	10328	10031	10	2017-01-23 18:14:17.048941	2017-01-23 18:14:17.048941	16575
17524	2017-01-01 00:00:00	2099-12-31 18:59:59	10328	10030	13	2017-01-23 18:14:17.054906	2017-01-23 18:14:17.054906	16575
17525	2017-01-01 00:00:00	2099-12-31 18:59:59	10328	10031	12	2017-01-23 18:14:17.059789	2017-01-23 18:14:17.059789	16575
17526	2000-01-01 00:00:00	2016-05-31 18:59:59	10329	10030	13	2017-01-23 18:14:17.065259	2017-01-23 18:14:17.065259	16575
17527	2000-01-01 00:00:00	2016-05-31 18:59:59	10329	10031	14	2017-01-23 18:14:17.070889	2017-01-23 18:14:17.070889	16575
17528	2016-06-01 00:00:00	2016-08-31 18:59:59	10329	10030	13	2017-01-23 18:14:17.076792	2017-01-23 18:14:17.076792	16575
17529	2016-06-01 00:00:00	2016-08-31 18:59:59	10329	10031	10	2017-01-23 18:14:17.082071	2017-01-23 18:14:17.082071	16575
17530	2016-09-01 00:00:00	2016-12-31 18:59:59	10329	10030	10	2017-01-23 18:14:17.087612	2017-01-23 18:14:17.087612	16575
17531	2016-09-01 00:00:00	2016-12-31 18:59:59	10329	10031	14	2017-01-23 18:14:17.093217	2017-01-23 18:14:17.093217	16575
17532	2017-01-01 00:00:00	2099-12-31 18:59:59	10329	10030	13	2017-01-23 18:14:17.099006	2017-01-23 18:14:17.099006	16575
17533	2017-01-01 00:00:00	2099-12-31 18:59:59	10329	10031	10	2017-01-23 18:14:17.103943	2017-01-23 18:14:17.103943	16575
17534	2000-01-01 00:00:00	2016-05-31 18:59:59	10330	10030	14	2017-01-23 18:14:17.10955	2017-01-23 18:14:17.10955	16575
17535	2000-01-01 00:00:00	2016-05-31 18:59:59	10330	10031	13	2017-01-23 18:14:17.115286	2017-01-23 18:14:17.115286	16575
17536	2016-06-01 00:00:00	2016-08-31 18:59:59	10330	10030	11	2017-01-23 18:14:17.120853	2017-01-23 18:14:17.120853	16575
17537	2016-06-01 00:00:00	2016-08-31 18:59:59	10330	10031	11	2017-01-23 18:14:17.12578	2017-01-23 18:14:17.12578	16575
17538	2016-09-01 00:00:00	2016-12-31 18:59:59	10330	10030	13	2017-01-23 18:14:17.131517	2017-01-23 18:14:17.131517	16575
17539	2016-09-01 00:00:00	2016-12-31 18:59:59	10330	10031	14	2017-01-23 18:14:17.136797	2017-01-23 18:14:17.136797	16575
17540	2017-01-01 00:00:00	2099-12-31 18:59:59	10330	10030	10	2017-01-23 18:14:17.143559	2017-01-23 18:14:17.143559	16575
17541	2017-01-01 00:00:00	2099-12-31 18:59:59	10330	10031	12	2017-01-23 18:14:17.148636	2017-01-23 18:14:17.148636	16575
\.


--
-- Data for Name: t_prices_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices_plans (id, price_code, price_name, price_dscr, price_sum_flag, created_at, updated_at) FROM stdin;
16575	base	Base price plan	This is main price for bike.	t	2017-01-22 17:55:27.538181	2017-01-22 17:55:27.538181
16576	vip	Discount for VIP	 This is discount for VIP costomers	t	2017-01-22 17:55:27.54773	2017-01-22 17:55:27.54773
16577	holiday	Discount for Holiday	Discount for holidays.	f	2017-01-22 17:55:27.556538	2017-01-22 17:55:27.556538
16578	count5	Discount for 5 bike	If customer booking 5 bikes.	f	2017-01-22 17:55:27.56239	2017-01-22 17:55:27.56239
16579	period10	Discount for 10 days	If customer have booking for 10 days 	f	2017-01-22 17:55:27.568419	2017-01-22 17:55:27.568419
\.


--
-- Data for Name: t_prices_specials_conditions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices_specials_conditions (id, price_plan_id, beg_date_order, end_date_order, pediod_beg_date, pediod_end_date, bike_model_id, customer_group_id, bike_count, period_order_in_hour, val_id, prct_flag, price_specials_value, created_at, updated_at) FROM stdin;
\.


--
-- Name: t_bikes_states PK_bike_states_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes_states
    ADD CONSTRAINT "PK_bike_states_id" PRIMARY KEY (id);


--
-- Name: t_booking_consist PK_booking_consist; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_consist
    ADD CONSTRAINT "PK_booking_consist" PRIMARY KEY (id);


--
-- Name: t_booking PK_booking_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking
    ADD CONSTRAINT "PK_booking_id" PRIMARY KEY (booking_id);


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
-- Name: t_prices_plans PK_prices_plans; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_plans
    ADD CONSTRAINT "PK_prices_plans" PRIMARY KEY (id);


--
-- Name: t_bikes PK_t_bikes_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes
    ADD CONSTRAINT "PK_t_bikes_id" PRIMARY KEY (bike_id);


--
-- Name: t_prices_base_plans PK_t_prices_base_plans; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_base_plans
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

CREATE INDEX "FKI_booking_bike_model_id" ON t_booking_consist USING btree (bike_model_id);


--
-- Name: FKI_booking_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_booking_customer_id" ON t_booking USING btree (customer_id);


--
-- Name: FKI_booking_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_booking_id" ON t_booking_consist USING btree (booking_id);


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

CREATE INDEX "FKI_to_bike_model_id" ON t_prices_base_plans USING btree (bike_model_id);


--
-- Name: FKI_to_booking_consist; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_booking_consist" ON t_booking_prices USING btree (booking_consist_id);


--
-- Name: FKI_to_currency_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_currency_id" ON t_prices_base_plans USING btree (currency_id);


--
-- Name: FKI_to_price_plans_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_price_plans_id" ON t_booking_prices USING btree (t_price_plans_id);


--
-- Name: FKI_to_prices_plans; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_to_prices_plans" ON t_prices_base_plans USING btree (price_plan_id);


--
-- Name: PK_idx_bikes_states; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_bikes_states" ON t_bikes_states USING btree (id);


--
-- Name: PK_idx_booking_consist; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PK_idx_booking_consist" ON t_booking_consist USING btree (id);


--
-- Name: PK_idx_booking_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_booking_id" ON t_booking USING btree (booking_id);


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

CREATE UNIQUE INDEX "PK_idx_prices_plans" ON t_prices_plans USING btree (id);


--
-- Name: PK_idx_prices_specials_conditions; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_prices_specials_conditions" ON t_prices_specials_conditions USING btree (id);


--
-- Name: PK_idx_t_bikes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_t_bikes_id" ON t_bikes USING btree (bike_id);


--
-- Name: UNIQ_booking_state_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UNIQ_booking_state_code" ON dict_booking_states USING btree (booking_state_code);


--
-- Name: UNIQ_idx_beg_date_bike_model_id_val_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "UNIQ_idx_beg_date_bike_model_id_val_id" ON t_prices_base_plans USING btree (beg_date, bike_model_id, currency_id);


--
-- Name: UNIQ_price_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UNIQ_price_code" ON t_prices_plans USING btree (price_code);


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
-- Name: t_booking_consist FK_booking_bike_model_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_consist
    ADD CONSTRAINT "FK_booking_bike_model_id" FOREIGN KEY (bike_model_id) REFERENCES dict_bike_models(bike_model_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking FK_booking_customer_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking
    ADD CONSTRAINT "FK_booking_customer_id" FOREIGN KEY (customer_id) REFERENCES t_customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_consist FK_booking_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_consist
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
    ADD CONSTRAINT "FK_prices_plans" FOREIGN KEY (price_plan_id) REFERENCES t_prices_plans(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_prices_base_plans FK_to_bike_model_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_base_plans
    ADD CONSTRAINT "FK_to_bike_model_id" FOREIGN KEY (bike_model_id) REFERENCES dict_bike_models(bike_model_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_prices FK_to_booking_consist; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_prices
    ADD CONSTRAINT "FK_to_booking_consist" FOREIGN KEY (booking_consist_id) REFERENCES t_booking_consist(id);


--
-- Name: t_prices_base_plans FK_to_currency_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_base_plans
    ADD CONSTRAINT "FK_to_currency_id" FOREIGN KEY (currency_id) REFERENCES dict_currencies(currency_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: t_booking_prices FK_to_price_plans_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_booking_prices
    ADD CONSTRAINT "FK_to_price_plans_id" FOREIGN KEY (t_price_plans_id) REFERENCES t_prices_plans(id);


--
-- Name: t_prices_base_plans FK_to_prices_plans; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_prices_base_plans
    ADD CONSTRAINT "FK_to_prices_plans" FOREIGN KEY (price_plan_id) REFERENCES t_prices_plans(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


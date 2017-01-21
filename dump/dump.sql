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
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE dict_booking_states OWNER TO postgres;

--
-- Name: dict_currencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_currencies (
    val_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    val_code character varying(100),
    val_name character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE dict_currencies OWNER TO postgres;

--
-- Name: t_bikes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_bikes (
    bike_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_inventory_number character varying(100) NOT NULL,
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
    id integer NOT NULL,
    booking_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_model_id integer,
    period_beg_date timestamp without time zone,
    period_end_date timestamp without time zone,
    bikes_count integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_booking_consist OWNER TO postgres;

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
-- Name: t_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_orders (
    order_id integer DEFAULT nextval('main_sequence'::regclass),
    order_code character varying(250),
    customer_id integer,
    canceled_flag boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_orders OWNER TO postgres;

--
-- Name: t_orders_lists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_orders_lists (
    id integer DEFAULT nextval('main_sequence'::regclass),
    order_id integer,
    bike_id integer,
    beg_date timestamp without time zone,
    end_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_orders_lists OWNER TO postgres;

--
-- Name: t_prices_base_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices_base_plans (
    id integer DEFAULT nextval('main_sequence'::regclass),
    beg_date timestamp without time zone,
    end_date timestamp without time zone,
    bike_model_id integer,
    val_id integer,
    price double precision,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_prices_base_plans OWNER TO postgres;

--
-- Name: t_prices_specials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices_specials (
    id integer DEFAULT nextval('main_sequence'::regclass),
    price_spec_code character varying(100),
    price_spec_dscr character varying(1000),
    price_spec_sum_flag boolean,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE t_prices_specials OWNER TO postgres;

--
-- Name: t_prices_specials_conditions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_prices_specials_conditions (
    id integer DEFAULT nextval('main_sequence'::regclass),
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
-- Data for Name: dict_booking_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_booking_states (booking_state_id, booking_state_code, booking_state_name, created_at, updated_at) FROM stdin;
13691	new	New	2017-01-21 16:20:05.552974	2017-01-21 16:20:05.552974
13692	canceled	Canceled	2017-01-21 16:20:05.557719	2017-01-21 16:20:05.557719
13693	confirmed	Confirmed	2017-01-21 16:20:05.562033	2017-01-21 16:20:05.562033
13694	completed	Completed	2017-01-21 16:20:05.566253	2017-01-21 16:20:05.566253
\.


--
-- Data for Name: dict_currencies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_currencies (val_id, val_code, val_name, created_at, updated_at) FROM stdin;
10030	eur	EUR	2017-01-09 20:22:41.439588	2017-01-09 20:22:41.439588
10031	chf	CHF	2017-01-09 20:22:41.447907	2017-01-09 20:22:41.447907
\.


--
-- Name: main_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('main_sequence', 16574, true);


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
-- Data for Name: t_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_orders (order_id, order_code, customer_id, canceled_flag, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_orders_lists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_orders_lists (id, order_id, bike_id, beg_date, end_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_prices_base_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices_base_plans (id, beg_date, end_date, bike_model_id, val_id, price, created_at, updated_at) FROM stdin;
15615	2000-01-01 00:00:00	2016-05-31 18:59:59	10211	10030	12	2017-01-21 17:35:54.417633	2017-01-21 17:35:54.417633
15616	2000-01-01 00:00:00	2016-05-31 18:59:59	10211	10031	28	2017-01-21 17:35:54.422766	2017-01-21 17:35:54.422766
15617	2016-06-01 00:00:00	2016-08-31 18:59:59	10211	10030	12	2017-01-21 17:35:54.427929	2017-01-21 17:35:54.427929
15618	2016-06-01 00:00:00	2016-08-31 18:59:59	10211	10031	25	2017-01-21 17:35:54.432598	2017-01-21 17:35:54.432598
15619	2016-09-01 00:00:00	2016-12-31 18:59:59	10211	10030	10	2017-01-21 17:35:54.437509	2017-01-21 17:35:54.437509
15620	2016-09-01 00:00:00	2016-12-31 18:59:59	10211	10031	21	2017-01-21 17:35:54.442331	2017-01-21 17:35:54.442331
15621	2017-01-01 00:00:00	2099-12-31 18:59:59	10211	10030	16	2017-01-21 17:35:54.447179	2017-01-21 17:35:54.447179
15622	2017-01-01 00:00:00	2099-12-31 18:59:59	10211	10031	25	2017-01-21 17:35:54.453531	2017-01-21 17:35:54.453531
15623	2000-01-01 00:00:00	2016-05-31 18:59:59	10212	10030	16	2017-01-21 17:35:54.457968	2017-01-21 17:35:54.457968
15624	2000-01-01 00:00:00	2016-05-31 18:59:59	10212	10031	25	2017-01-21 17:35:54.462613	2017-01-21 17:35:54.462613
15625	2016-06-01 00:00:00	2016-08-31 18:59:59	10212	10030	14	2017-01-21 17:35:54.468128	2017-01-21 17:35:54.468128
15626	2016-06-01 00:00:00	2016-08-31 18:59:59	10212	10031	19	2017-01-21 17:35:54.47278	2017-01-21 17:35:54.47278
15627	2016-09-01 00:00:00	2016-12-31 18:59:59	10212	10030	14	2017-01-21 17:35:54.478017	2017-01-21 17:35:54.478017
15628	2016-09-01 00:00:00	2016-12-31 18:59:59	10212	10031	10	2017-01-21 17:35:54.482804	2017-01-21 17:35:54.482804
15629	2017-01-01 00:00:00	2099-12-31 18:59:59	10212	10030	10	2017-01-21 17:35:54.488175	2017-01-21 17:35:54.488175
15630	2017-01-01 00:00:00	2099-12-31 18:59:59	10212	10031	26	2017-01-21 17:35:54.492669	2017-01-21 17:35:54.492669
15631	2000-01-01 00:00:00	2016-05-31 18:59:59	10213	10030	22	2017-01-21 17:35:54.497805	2017-01-21 17:35:54.497805
15632	2000-01-01 00:00:00	2016-05-31 18:59:59	10213	10031	29	2017-01-21 17:35:54.50254	2017-01-21 17:35:54.50254
15633	2016-06-01 00:00:00	2016-08-31 18:59:59	10213	10030	16	2017-01-21 17:35:54.507927	2017-01-21 17:35:54.507927
15634	2016-06-01 00:00:00	2016-08-31 18:59:59	10213	10031	12	2017-01-21 17:35:54.512702	2017-01-21 17:35:54.512702
15635	2016-09-01 00:00:00	2016-12-31 18:59:59	10213	10030	23	2017-01-21 17:35:54.518196	2017-01-21 17:35:54.518196
15636	2016-09-01 00:00:00	2016-12-31 18:59:59	10213	10031	28	2017-01-21 17:35:54.522631	2017-01-21 17:35:54.522631
15637	2017-01-01 00:00:00	2099-12-31 18:59:59	10213	10030	21	2017-01-21 17:35:54.527782	2017-01-21 17:35:54.527782
15638	2017-01-01 00:00:00	2099-12-31 18:59:59	10213	10031	14	2017-01-21 17:35:54.532142	2017-01-21 17:35:54.532142
15639	2000-01-01 00:00:00	2016-05-31 18:59:59	10214	10030	17	2017-01-21 17:35:54.538232	2017-01-21 17:35:54.538232
15640	2000-01-01 00:00:00	2016-05-31 18:59:59	10214	10031	25	2017-01-21 17:35:54.542682	2017-01-21 17:35:54.542682
15641	2016-06-01 00:00:00	2016-08-31 18:59:59	10214	10030	28	2017-01-21 17:35:54.549417	2017-01-21 17:35:54.549417
15642	2016-06-01 00:00:00	2016-08-31 18:59:59	10214	10031	15	2017-01-21 17:35:54.553984	2017-01-21 17:35:54.553984
15643	2016-09-01 00:00:00	2016-12-31 18:59:59	10214	10030	17	2017-01-21 17:35:54.559139	2017-01-21 17:35:54.559139
15644	2016-09-01 00:00:00	2016-12-31 18:59:59	10214	10031	13	2017-01-21 17:35:54.563919	2017-01-21 17:35:54.563919
15645	2017-01-01 00:00:00	2099-12-31 18:59:59	10214	10030	10	2017-01-21 17:35:54.569518	2017-01-21 17:35:54.569518
15646	2017-01-01 00:00:00	2099-12-31 18:59:59	10214	10031	18	2017-01-21 17:35:54.574005	2017-01-21 17:35:54.574005
15647	2000-01-01 00:00:00	2016-05-31 18:59:59	10215	10030	26	2017-01-21 17:35:54.579165	2017-01-21 17:35:54.579165
15648	2000-01-01 00:00:00	2016-05-31 18:59:59	10215	10031	25	2017-01-21 17:35:54.583802	2017-01-21 17:35:54.583802
15649	2016-06-01 00:00:00	2016-08-31 18:59:59	10215	10030	28	2017-01-21 17:35:54.589293	2017-01-21 17:35:54.589293
15650	2016-06-01 00:00:00	2016-08-31 18:59:59	10215	10031	18	2017-01-21 17:35:54.593693	2017-01-21 17:35:54.593693
15651	2016-09-01 00:00:00	2016-12-31 18:59:59	10215	10030	19	2017-01-21 17:35:54.598807	2017-01-21 17:35:54.598807
15652	2016-09-01 00:00:00	2016-12-31 18:59:59	10215	10031	10	2017-01-21 17:35:54.603608	2017-01-21 17:35:54.603608
15653	2017-01-01 00:00:00	2099-12-31 18:59:59	10215	10030	23	2017-01-21 17:35:54.608974	2017-01-21 17:35:54.608974
15654	2017-01-01 00:00:00	2099-12-31 18:59:59	10215	10031	10	2017-01-21 17:35:54.613779	2017-01-21 17:35:54.613779
15655	2000-01-01 00:00:00	2016-05-31 18:59:59	10216	10030	18	2017-01-21 17:35:54.619348	2017-01-21 17:35:54.619348
15656	2000-01-01 00:00:00	2016-05-31 18:59:59	10216	10031	27	2017-01-21 17:35:54.623873	2017-01-21 17:35:54.623873
15657	2016-06-01 00:00:00	2016-08-31 18:59:59	10216	10030	26	2017-01-21 17:35:54.629601	2017-01-21 17:35:54.629601
15658	2016-06-01 00:00:00	2016-08-31 18:59:59	10216	10031	16	2017-01-21 17:35:54.633471	2017-01-21 17:35:54.633471
15659	2016-09-01 00:00:00	2016-12-31 18:59:59	10216	10030	18	2017-01-21 17:35:54.638012	2017-01-21 17:35:54.638012
15660	2016-09-01 00:00:00	2016-12-31 18:59:59	10216	10031	27	2017-01-21 17:35:54.641965	2017-01-21 17:35:54.641965
15661	2017-01-01 00:00:00	2099-12-31 18:59:59	10216	10030	27	2017-01-21 17:35:54.646186	2017-01-21 17:35:54.646186
15662	2017-01-01 00:00:00	2099-12-31 18:59:59	10216	10031	11	2017-01-21 17:35:54.650599	2017-01-21 17:35:54.650599
15663	2000-01-01 00:00:00	2016-05-31 18:59:59	10217	10030	25	2017-01-21 17:35:54.655834	2017-01-21 17:35:54.655834
15664	2000-01-01 00:00:00	2016-05-31 18:59:59	10217	10031	28	2017-01-21 17:35:54.660638	2017-01-21 17:35:54.660638
15665	2016-06-01 00:00:00	2016-08-31 18:59:59	10217	10030	29	2017-01-21 17:35:54.666078	2017-01-21 17:35:54.666078
15666	2016-06-01 00:00:00	2016-08-31 18:59:59	10217	10031	21	2017-01-21 17:35:54.670761	2017-01-21 17:35:54.670761
15667	2016-09-01 00:00:00	2016-12-31 18:59:59	10217	10030	16	2017-01-21 17:35:54.676378	2017-01-21 17:35:54.676378
15668	2016-09-01 00:00:00	2016-12-31 18:59:59	10217	10031	24	2017-01-21 17:35:54.681032	2017-01-21 17:35:54.681032
15669	2017-01-01 00:00:00	2099-12-31 18:59:59	10217	10030	27	2017-01-21 17:35:54.686584	2017-01-21 17:35:54.686584
15670	2017-01-01 00:00:00	2099-12-31 18:59:59	10217	10031	23	2017-01-21 17:35:54.69106	2017-01-21 17:35:54.69106
15671	2000-01-01 00:00:00	2016-05-31 18:59:59	10218	10030	26	2017-01-21 17:35:54.6963	2017-01-21 17:35:54.6963
15672	2000-01-01 00:00:00	2016-05-31 18:59:59	10218	10031	13	2017-01-21 17:35:54.701003	2017-01-21 17:35:54.701003
15673	2016-06-01 00:00:00	2016-08-31 18:59:59	10218	10030	28	2017-01-21 17:35:54.706237	2017-01-21 17:35:54.706237
15674	2016-06-01 00:00:00	2016-08-31 18:59:59	10218	10031	14	2017-01-21 17:35:54.710896	2017-01-21 17:35:54.710896
15675	2016-09-01 00:00:00	2016-12-31 18:59:59	10218	10030	29	2017-01-21 17:35:54.716137	2017-01-21 17:35:54.716137
15676	2016-09-01 00:00:00	2016-12-31 18:59:59	10218	10031	28	2017-01-21 17:35:54.72052	2017-01-21 17:35:54.72052
15677	2017-01-01 00:00:00	2099-12-31 18:59:59	10218	10030	14	2017-01-21 17:35:54.725368	2017-01-21 17:35:54.725368
15678	2017-01-01 00:00:00	2099-12-31 18:59:59	10218	10031	17	2017-01-21 17:35:54.729656	2017-01-21 17:35:54.729656
15679	2000-01-01 00:00:00	2016-05-31 18:59:59	10219	10030	17	2017-01-21 17:35:54.734913	2017-01-21 17:35:54.734913
15680	2000-01-01 00:00:00	2016-05-31 18:59:59	10219	10031	27	2017-01-21 17:35:54.739342	2017-01-21 17:35:54.739342
15681	2016-06-01 00:00:00	2016-08-31 18:59:59	10219	10030	27	2017-01-21 17:35:54.744865	2017-01-21 17:35:54.744865
15682	2016-06-01 00:00:00	2016-08-31 18:59:59	10219	10031	19	2017-01-21 17:35:54.749547	2017-01-21 17:35:54.749547
15683	2016-09-01 00:00:00	2016-12-31 18:59:59	10219	10030	20	2017-01-21 17:35:54.754851	2017-01-21 17:35:54.754851
15684	2016-09-01 00:00:00	2016-12-31 18:59:59	10219	10031	24	2017-01-21 17:35:54.760201	2017-01-21 17:35:54.760201
15685	2017-01-01 00:00:00	2099-12-31 18:59:59	10219	10030	25	2017-01-21 17:35:54.765368	2017-01-21 17:35:54.765368
15686	2017-01-01 00:00:00	2099-12-31 18:59:59	10219	10031	21	2017-01-21 17:35:54.769927	2017-01-21 17:35:54.769927
15687	2000-01-01 00:00:00	2016-05-31 18:59:59	10220	10030	27	2017-01-21 17:35:54.775116	2017-01-21 17:35:54.775116
15688	2000-01-01 00:00:00	2016-05-31 18:59:59	10220	10031	11	2017-01-21 17:35:54.779513	2017-01-21 17:35:54.779513
15689	2016-06-01 00:00:00	2016-08-31 18:59:59	10220	10030	16	2017-01-21 17:35:54.784785	2017-01-21 17:35:54.784785
15690	2016-06-01 00:00:00	2016-08-31 18:59:59	10220	10031	13	2017-01-21 17:35:54.789249	2017-01-21 17:35:54.789249
15691	2016-09-01 00:00:00	2016-12-31 18:59:59	10220	10030	25	2017-01-21 17:35:54.79438	2017-01-21 17:35:54.79438
15692	2016-09-01 00:00:00	2016-12-31 18:59:59	10220	10031	10	2017-01-21 17:35:54.798798	2017-01-21 17:35:54.798798
15693	2017-01-01 00:00:00	2099-12-31 18:59:59	10220	10030	20	2017-01-21 17:35:54.803893	2017-01-21 17:35:54.803893
15694	2017-01-01 00:00:00	2099-12-31 18:59:59	10220	10031	10	2017-01-21 17:35:54.808009	2017-01-21 17:35:54.808009
15695	2000-01-01 00:00:00	2016-05-31 18:59:59	10221	10030	23	2017-01-21 17:35:54.812632	2017-01-21 17:35:54.812632
15696	2000-01-01 00:00:00	2016-05-31 18:59:59	10221	10031	25	2017-01-21 17:35:54.817751	2017-01-21 17:35:54.817751
15697	2016-06-01 00:00:00	2016-08-31 18:59:59	10221	10030	21	2017-01-21 17:35:54.823544	2017-01-21 17:35:54.823544
15698	2016-06-01 00:00:00	2016-08-31 18:59:59	10221	10031	17	2017-01-21 17:35:54.828197	2017-01-21 17:35:54.828197
15699	2016-09-01 00:00:00	2016-12-31 18:59:59	10221	10030	28	2017-01-21 17:35:54.833549	2017-01-21 17:35:54.833549
15700	2016-09-01 00:00:00	2016-12-31 18:59:59	10221	10031	28	2017-01-21 17:35:54.838163	2017-01-21 17:35:54.838163
15701	2017-01-01 00:00:00	2099-12-31 18:59:59	10221	10030	13	2017-01-21 17:35:54.843418	2017-01-21 17:35:54.843418
15702	2017-01-01 00:00:00	2099-12-31 18:59:59	10221	10031	18	2017-01-21 17:35:54.848117	2017-01-21 17:35:54.848117
15703	2000-01-01 00:00:00	2016-05-31 18:59:59	10222	10030	21	2017-01-21 17:35:54.853574	2017-01-21 17:35:54.853574
15704	2000-01-01 00:00:00	2016-05-31 18:59:59	10222	10031	26	2017-01-21 17:35:54.858258	2017-01-21 17:35:54.858258
15705	2016-06-01 00:00:00	2016-08-31 18:59:59	10222	10030	26	2017-01-21 17:35:54.863571	2017-01-21 17:35:54.863571
15706	2016-06-01 00:00:00	2016-08-31 18:59:59	10222	10031	14	2017-01-21 17:35:54.868084	2017-01-21 17:35:54.868084
15707	2016-09-01 00:00:00	2016-12-31 18:59:59	10222	10030	22	2017-01-21 17:35:54.873363	2017-01-21 17:35:54.873363
15708	2016-09-01 00:00:00	2016-12-31 18:59:59	10222	10031	13	2017-01-21 17:35:54.87804	2017-01-21 17:35:54.87804
15709	2017-01-01 00:00:00	2099-12-31 18:59:59	10222	10030	24	2017-01-21 17:35:54.88378	2017-01-21 17:35:54.88378
15710	2017-01-01 00:00:00	2099-12-31 18:59:59	10222	10031	11	2017-01-21 17:35:54.888845	2017-01-21 17:35:54.888845
15711	2000-01-01 00:00:00	2016-05-31 18:59:59	10223	10030	27	2017-01-21 17:35:54.894414	2017-01-21 17:35:54.894414
15712	2000-01-01 00:00:00	2016-05-31 18:59:59	10223	10031	14	2017-01-21 17:35:54.898891	2017-01-21 17:35:54.898891
15713	2016-06-01 00:00:00	2016-08-31 18:59:59	10223	10030	23	2017-01-21 17:35:54.904555	2017-01-21 17:35:54.904555
15714	2016-06-01 00:00:00	2016-08-31 18:59:59	10223	10031	16	2017-01-21 17:35:54.909064	2017-01-21 17:35:54.909064
15715	2016-09-01 00:00:00	2016-12-31 18:59:59	10223	10030	20	2017-01-21 17:35:54.9147	2017-01-21 17:35:54.9147
15716	2016-09-01 00:00:00	2016-12-31 18:59:59	10223	10031	16	2017-01-21 17:35:54.919389	2017-01-21 17:35:54.919389
15717	2017-01-01 00:00:00	2099-12-31 18:59:59	10223	10030	13	2017-01-21 17:35:54.924533	2017-01-21 17:35:54.924533
15718	2017-01-01 00:00:00	2099-12-31 18:59:59	10223	10031	29	2017-01-21 17:35:54.929171	2017-01-21 17:35:54.929171
15719	2000-01-01 00:00:00	2016-05-31 18:59:59	10224	10030	17	2017-01-21 17:35:54.934555	2017-01-21 17:35:54.934555
15720	2000-01-01 00:00:00	2016-05-31 18:59:59	10224	10031	13	2017-01-21 17:35:54.939036	2017-01-21 17:35:54.939036
15721	2016-06-01 00:00:00	2016-08-31 18:59:59	10224	10030	27	2017-01-21 17:35:54.944087	2017-01-21 17:35:54.944087
15722	2016-06-01 00:00:00	2016-08-31 18:59:59	10224	10031	10	2017-01-21 17:35:54.948467	2017-01-21 17:35:54.948467
15723	2016-09-01 00:00:00	2016-12-31 18:59:59	10224	10030	26	2017-01-21 17:35:54.953665	2017-01-21 17:35:54.953665
15724	2016-09-01 00:00:00	2016-12-31 18:59:59	10224	10031	16	2017-01-21 17:35:54.958019	2017-01-21 17:35:54.958019
15725	2017-01-01 00:00:00	2099-12-31 18:59:59	10224	10030	13	2017-01-21 17:35:54.963402	2017-01-21 17:35:54.963402
15726	2017-01-01 00:00:00	2099-12-31 18:59:59	10224	10031	28	2017-01-21 17:35:54.968089	2017-01-21 17:35:54.968089
15727	2000-01-01 00:00:00	2016-05-31 18:59:59	10225	10030	17	2017-01-21 17:35:54.973586	2017-01-21 17:35:54.973586
15728	2000-01-01 00:00:00	2016-05-31 18:59:59	10225	10031	25	2017-01-21 17:35:54.979052	2017-01-21 17:35:54.979052
15729	2016-06-01 00:00:00	2016-08-31 18:59:59	10225	10030	28	2017-01-21 17:35:54.984451	2017-01-21 17:35:54.984451
15730	2016-06-01 00:00:00	2016-08-31 18:59:59	10225	10031	24	2017-01-21 17:35:54.989065	2017-01-21 17:35:54.989065
15731	2016-09-01 00:00:00	2016-12-31 18:59:59	10225	10030	11	2017-01-21 17:35:54.994933	2017-01-21 17:35:54.994933
15732	2016-09-01 00:00:00	2016-12-31 18:59:59	10225	10031	17	2017-01-21 17:35:54.999873	2017-01-21 17:35:54.999873
15733	2017-01-01 00:00:00	2099-12-31 18:59:59	10225	10030	29	2017-01-21 17:35:55.005425	2017-01-21 17:35:55.005425
15734	2017-01-01 00:00:00	2099-12-31 18:59:59	10225	10031	18	2017-01-21 17:35:55.009905	2017-01-21 17:35:55.009905
15735	2000-01-01 00:00:00	2016-05-31 18:59:59	10226	10030	18	2017-01-21 17:35:55.015294	2017-01-21 17:35:55.015294
15736	2000-01-01 00:00:00	2016-05-31 18:59:59	10226	10031	24	2017-01-21 17:35:55.019884	2017-01-21 17:35:55.019884
15737	2016-06-01 00:00:00	2016-08-31 18:59:59	10226	10030	11	2017-01-21 17:35:55.025392	2017-01-21 17:35:55.025392
15738	2016-06-01 00:00:00	2016-08-31 18:59:59	10226	10031	10	2017-01-21 17:35:55.030066	2017-01-21 17:35:55.030066
15739	2016-09-01 00:00:00	2016-12-31 18:59:59	10226	10030	17	2017-01-21 17:35:55.035657	2017-01-21 17:35:55.035657
15740	2016-09-01 00:00:00	2016-12-31 18:59:59	10226	10031	22	2017-01-21 17:35:55.040132	2017-01-21 17:35:55.040132
15741	2017-01-01 00:00:00	2099-12-31 18:59:59	10226	10030	10	2017-01-21 17:35:55.045381	2017-01-21 17:35:55.045381
15742	2017-01-01 00:00:00	2099-12-31 18:59:59	10226	10031	20	2017-01-21 17:35:55.049902	2017-01-21 17:35:55.049902
15743	2000-01-01 00:00:00	2016-05-31 18:59:59	10227	10030	15	2017-01-21 17:35:55.055277	2017-01-21 17:35:55.055277
15744	2000-01-01 00:00:00	2016-05-31 18:59:59	10227	10031	24	2017-01-21 17:35:55.059829	2017-01-21 17:35:55.059829
15745	2016-06-01 00:00:00	2016-08-31 18:59:59	10227	10030	18	2017-01-21 17:35:55.065423	2017-01-21 17:35:55.065423
15746	2016-06-01 00:00:00	2016-08-31 18:59:59	10227	10031	26	2017-01-21 17:35:55.070066	2017-01-21 17:35:55.070066
15747	2016-09-01 00:00:00	2016-12-31 18:59:59	10227	10030	22	2017-01-21 17:35:55.075389	2017-01-21 17:35:55.075389
15748	2016-09-01 00:00:00	2016-12-31 18:59:59	10227	10031	20	2017-01-21 17:35:55.081849	2017-01-21 17:35:55.081849
15749	2017-01-01 00:00:00	2099-12-31 18:59:59	10227	10030	21	2017-01-21 17:35:55.087484	2017-01-21 17:35:55.087484
15750	2017-01-01 00:00:00	2099-12-31 18:59:59	10227	10031	26	2017-01-21 17:35:55.091914	2017-01-21 17:35:55.091914
15751	2000-01-01 00:00:00	2016-05-31 18:59:59	10228	10030	16	2017-01-21 17:35:55.097312	2017-01-21 17:35:55.097312
15752	2000-01-01 00:00:00	2016-05-31 18:59:59	10228	10031	20	2017-01-21 17:35:55.101958	2017-01-21 17:35:55.101958
15753	2016-06-01 00:00:00	2016-08-31 18:59:59	10228	10030	14	2017-01-21 17:35:55.1073	2017-01-21 17:35:55.1073
15754	2016-06-01 00:00:00	2016-08-31 18:59:59	10228	10031	17	2017-01-21 17:35:55.111878	2017-01-21 17:35:55.111878
15755	2016-09-01 00:00:00	2016-12-31 18:59:59	10228	10030	12	2017-01-21 17:35:55.117436	2017-01-21 17:35:55.117436
15756	2016-09-01 00:00:00	2016-12-31 18:59:59	10228	10031	27	2017-01-21 17:35:55.122074	2017-01-21 17:35:55.122074
15757	2017-01-01 00:00:00	2099-12-31 18:59:59	10228	10030	25	2017-01-21 17:35:55.127398	2017-01-21 17:35:55.127398
15758	2017-01-01 00:00:00	2099-12-31 18:59:59	10228	10031	29	2017-01-21 17:35:55.13207	2017-01-21 17:35:55.13207
15759	2000-01-01 00:00:00	2016-05-31 18:59:59	10229	10030	24	2017-01-21 17:35:55.137554	2017-01-21 17:35:55.137554
15760	2000-01-01 00:00:00	2016-05-31 18:59:59	10229	10031	10	2017-01-21 17:35:55.142147	2017-01-21 17:35:55.142147
15761	2016-06-01 00:00:00	2016-08-31 18:59:59	10229	10030	10	2017-01-21 17:35:55.147479	2017-01-21 17:35:55.147479
15762	2016-06-01 00:00:00	2016-08-31 18:59:59	10229	10031	27	2017-01-21 17:35:55.152019	2017-01-21 17:35:55.152019
15763	2016-09-01 00:00:00	2016-12-31 18:59:59	10229	10030	15	2017-01-21 17:35:55.157201	2017-01-21 17:35:55.157201
15764	2016-09-01 00:00:00	2016-12-31 18:59:59	10229	10031	18	2017-01-21 17:35:55.161737	2017-01-21 17:35:55.161737
15765	2017-01-01 00:00:00	2099-12-31 18:59:59	10229	10030	15	2017-01-21 17:35:55.166694	2017-01-21 17:35:55.166694
15766	2017-01-01 00:00:00	2099-12-31 18:59:59	10229	10031	11	2017-01-21 17:35:55.171017	2017-01-21 17:35:55.171017
15767	2000-01-01 00:00:00	2016-05-31 18:59:59	10230	10030	13	2017-01-21 17:35:55.17636	2017-01-21 17:35:55.17636
15768	2000-01-01 00:00:00	2016-05-31 18:59:59	10230	10031	21	2017-01-21 17:35:55.180292	2017-01-21 17:35:55.180292
15769	2016-06-01 00:00:00	2016-08-31 18:59:59	10230	10030	21	2017-01-21 17:35:55.185439	2017-01-21 17:35:55.185439
15770	2016-06-01 00:00:00	2016-08-31 18:59:59	10230	10031	24	2017-01-21 17:35:55.189956	2017-01-21 17:35:55.189956
15771	2016-09-01 00:00:00	2016-12-31 18:59:59	10230	10030	29	2017-01-21 17:35:55.195468	2017-01-21 17:35:55.195468
15772	2016-09-01 00:00:00	2016-12-31 18:59:59	10230	10031	18	2017-01-21 17:35:55.200243	2017-01-21 17:35:55.200243
15773	2017-01-01 00:00:00	2099-12-31 18:59:59	10230	10030	16	2017-01-21 17:35:55.206339	2017-01-21 17:35:55.206339
15774	2017-01-01 00:00:00	2099-12-31 18:59:59	10230	10031	21	2017-01-21 17:35:55.210897	2017-01-21 17:35:55.210897
15775	2000-01-01 00:00:00	2016-05-31 18:59:59	10231	10030	27	2017-01-21 17:35:55.216041	2017-01-21 17:35:55.216041
15776	2000-01-01 00:00:00	2016-05-31 18:59:59	10231	10031	26	2017-01-21 17:35:55.220638	2017-01-21 17:35:55.220638
15777	2016-06-01 00:00:00	2016-08-31 18:59:59	10231	10030	25	2017-01-21 17:35:55.225855	2017-01-21 17:35:55.225855
15778	2016-06-01 00:00:00	2016-08-31 18:59:59	10231	10031	15	2017-01-21 17:35:55.230232	2017-01-21 17:35:55.230232
15779	2016-09-01 00:00:00	2016-12-31 18:59:59	10231	10030	15	2017-01-21 17:35:55.235544	2017-01-21 17:35:55.235544
15780	2016-09-01 00:00:00	2016-12-31 18:59:59	10231	10031	14	2017-01-21 17:35:55.240131	2017-01-21 17:35:55.240131
15781	2017-01-01 00:00:00	2099-12-31 18:59:59	10231	10030	28	2017-01-21 17:35:55.245239	2017-01-21 17:35:55.245239
15782	2017-01-01 00:00:00	2099-12-31 18:59:59	10231	10031	16	2017-01-21 17:35:55.250325	2017-01-21 17:35:55.250325
15783	2000-01-01 00:00:00	2016-05-31 18:59:59	10232	10030	24	2017-01-21 17:35:55.255672	2017-01-21 17:35:55.255672
15784	2000-01-01 00:00:00	2016-05-31 18:59:59	10232	10031	15	2017-01-21 17:35:55.260151	2017-01-21 17:35:55.260151
15785	2016-06-01 00:00:00	2016-08-31 18:59:59	10232	10030	26	2017-01-21 17:35:55.26551	2017-01-21 17:35:55.26551
15786	2016-06-01 00:00:00	2016-08-31 18:59:59	10232	10031	16	2017-01-21 17:35:55.269973	2017-01-21 17:35:55.269973
15787	2016-09-01 00:00:00	2016-12-31 18:59:59	10232	10030	26	2017-01-21 17:35:55.275294	2017-01-21 17:35:55.275294
15788	2016-09-01 00:00:00	2016-12-31 18:59:59	10232	10031	24	2017-01-21 17:35:55.280081	2017-01-21 17:35:55.280081
15789	2017-01-01 00:00:00	2099-12-31 18:59:59	10232	10030	20	2017-01-21 17:35:55.285382	2017-01-21 17:35:55.285382
15790	2017-01-01 00:00:00	2099-12-31 18:59:59	10232	10031	28	2017-01-21 17:35:55.289905	2017-01-21 17:35:55.289905
15791	2000-01-01 00:00:00	2016-05-31 18:59:59	10233	10030	12	2017-01-21 17:35:55.295073	2017-01-21 17:35:55.295073
15792	2000-01-01 00:00:00	2016-05-31 18:59:59	10233	10031	12	2017-01-21 17:35:55.299752	2017-01-21 17:35:55.299752
15793	2016-06-01 00:00:00	2016-08-31 18:59:59	10233	10030	26	2017-01-21 17:35:55.304851	2017-01-21 17:35:55.304851
15794	2016-06-01 00:00:00	2016-08-31 18:59:59	10233	10031	29	2017-01-21 17:35:55.308903	2017-01-21 17:35:55.308903
15795	2016-09-01 00:00:00	2016-12-31 18:59:59	10233	10030	19	2017-01-21 17:35:55.313785	2017-01-21 17:35:55.313785
15796	2016-09-01 00:00:00	2016-12-31 18:59:59	10233	10031	15	2017-01-21 17:35:55.318368	2017-01-21 17:35:55.318368
15797	2017-01-01 00:00:00	2099-12-31 18:59:59	10233	10030	16	2017-01-21 17:35:55.323314	2017-01-21 17:35:55.323314
15798	2017-01-01 00:00:00	2099-12-31 18:59:59	10233	10031	19	2017-01-21 17:35:55.327807	2017-01-21 17:35:55.327807
15799	2000-01-01 00:00:00	2016-05-31 18:59:59	10234	10030	21	2017-01-21 17:35:55.334175	2017-01-21 17:35:55.334175
15800	2000-01-01 00:00:00	2016-05-31 18:59:59	10234	10031	28	2017-01-21 17:35:55.340261	2017-01-21 17:35:55.340261
15801	2016-06-01 00:00:00	2016-08-31 18:59:59	10234	10030	10	2017-01-21 17:35:55.345201	2017-01-21 17:35:55.345201
15802	2016-06-01 00:00:00	2016-08-31 18:59:59	10234	10031	27	2017-01-21 17:35:55.349774	2017-01-21 17:35:55.349774
15803	2016-09-01 00:00:00	2016-12-31 18:59:59	10234	10030	25	2017-01-21 17:35:55.354908	2017-01-21 17:35:55.354908
15804	2016-09-01 00:00:00	2016-12-31 18:59:59	10234	10031	27	2017-01-21 17:35:55.359785	2017-01-21 17:35:55.359785
15805	2017-01-01 00:00:00	2099-12-31 18:59:59	10234	10030	25	2017-01-21 17:35:55.365174	2017-01-21 17:35:55.365174
15806	2017-01-01 00:00:00	2099-12-31 18:59:59	10234	10031	17	2017-01-21 17:35:55.369913	2017-01-21 17:35:55.369913
15807	2000-01-01 00:00:00	2016-05-31 18:59:59	10235	10030	10	2017-01-21 17:35:55.375335	2017-01-21 17:35:55.375335
15808	2000-01-01 00:00:00	2016-05-31 18:59:59	10235	10031	25	2017-01-21 17:35:55.379833	2017-01-21 17:35:55.379833
15809	2016-06-01 00:00:00	2016-08-31 18:59:59	10235	10030	27	2017-01-21 17:35:55.385436	2017-01-21 17:35:55.385436
15810	2016-06-01 00:00:00	2016-08-31 18:59:59	10235	10031	19	2017-01-21 17:35:55.389992	2017-01-21 17:35:55.389992
15811	2016-09-01 00:00:00	2016-12-31 18:59:59	10235	10030	11	2017-01-21 17:35:55.395439	2017-01-21 17:35:55.395439
15812	2016-09-01 00:00:00	2016-12-31 18:59:59	10235	10031	14	2017-01-21 17:35:55.400116	2017-01-21 17:35:55.400116
15813	2017-01-01 00:00:00	2099-12-31 18:59:59	10235	10030	24	2017-01-21 17:35:55.405644	2017-01-21 17:35:55.405644
15814	2017-01-01 00:00:00	2099-12-31 18:59:59	10235	10031	17	2017-01-21 17:35:55.410315	2017-01-21 17:35:55.410315
15815	2000-01-01 00:00:00	2016-05-31 18:59:59	10236	10030	12	2017-01-21 17:35:55.415921	2017-01-21 17:35:55.415921
15816	2000-01-01 00:00:00	2016-05-31 18:59:59	10236	10031	18	2017-01-21 17:35:55.420777	2017-01-21 17:35:55.420777
15817	2016-06-01 00:00:00	2016-08-31 18:59:59	10236	10030	18	2017-01-21 17:35:55.427145	2017-01-21 17:35:55.427145
15818	2016-06-01 00:00:00	2016-08-31 18:59:59	10236	10031	16	2017-01-21 17:35:55.43181	2017-01-21 17:35:55.43181
15819	2016-09-01 00:00:00	2016-12-31 18:59:59	10236	10030	10	2017-01-21 17:35:55.437282	2017-01-21 17:35:55.437282
15820	2016-09-01 00:00:00	2016-12-31 18:59:59	10236	10031	25	2017-01-21 17:35:55.441983	2017-01-21 17:35:55.441983
15821	2017-01-01 00:00:00	2099-12-31 18:59:59	10236	10030	12	2017-01-21 17:35:55.447545	2017-01-21 17:35:55.447545
15822	2017-01-01 00:00:00	2099-12-31 18:59:59	10236	10031	17	2017-01-21 17:35:55.451963	2017-01-21 17:35:55.451963
15823	2000-01-01 00:00:00	2016-05-31 18:59:59	10237	10030	15	2017-01-21 17:35:55.457176	2017-01-21 17:35:55.457176
15824	2000-01-01 00:00:00	2016-05-31 18:59:59	10237	10031	28	2017-01-21 17:35:55.461701	2017-01-21 17:35:55.461701
15825	2016-06-01 00:00:00	2016-08-31 18:59:59	10237	10030	14	2017-01-21 17:35:55.466852	2017-01-21 17:35:55.466852
15826	2016-06-01 00:00:00	2016-08-31 18:59:59	10237	10031	28	2017-01-21 17:35:55.471418	2017-01-21 17:35:55.471418
15827	2016-09-01 00:00:00	2016-12-31 18:59:59	10237	10030	12	2017-01-21 17:35:55.476468	2017-01-21 17:35:55.476468
15828	2016-09-01 00:00:00	2016-12-31 18:59:59	10237	10031	17	2017-01-21 17:35:55.480947	2017-01-21 17:35:55.480947
15829	2017-01-01 00:00:00	2099-12-31 18:59:59	10237	10030	16	2017-01-21 17:35:55.486084	2017-01-21 17:35:55.486084
15830	2017-01-01 00:00:00	2099-12-31 18:59:59	10237	10031	24	2017-01-21 17:35:55.490167	2017-01-21 17:35:55.490167
15831	2000-01-01 00:00:00	2016-05-31 18:59:59	10238	10030	13	2017-01-21 17:35:55.495134	2017-01-21 17:35:55.495134
15832	2000-01-01 00:00:00	2016-05-31 18:59:59	10238	10031	12	2017-01-21 17:35:55.49937	2017-01-21 17:35:55.49937
15833	2016-06-01 00:00:00	2016-08-31 18:59:59	10238	10030	10	2017-01-21 17:35:55.504483	2017-01-21 17:35:55.504483
15834	2016-06-01 00:00:00	2016-08-31 18:59:59	10238	10031	10	2017-01-21 17:35:55.508968	2017-01-21 17:35:55.508968
15835	2016-09-01 00:00:00	2016-12-31 18:59:59	10238	10030	29	2017-01-21 17:35:55.514315	2017-01-21 17:35:55.514315
15836	2016-09-01 00:00:00	2016-12-31 18:59:59	10238	10031	23	2017-01-21 17:35:55.518884	2017-01-21 17:35:55.518884
15837	2017-01-01 00:00:00	2099-12-31 18:59:59	10238	10030	20	2017-01-21 17:35:55.524311	2017-01-21 17:35:55.524311
15838	2017-01-01 00:00:00	2099-12-31 18:59:59	10238	10031	29	2017-01-21 17:35:55.529337	2017-01-21 17:35:55.529337
15839	2000-01-01 00:00:00	2016-05-31 18:59:59	10239	10030	14	2017-01-21 17:35:55.534419	2017-01-21 17:35:55.534419
15840	2000-01-01 00:00:00	2016-05-31 18:59:59	10239	10031	13	2017-01-21 17:35:55.538999	2017-01-21 17:35:55.538999
15841	2016-06-01 00:00:00	2016-08-31 18:59:59	10239	10030	11	2017-01-21 17:35:55.544315	2017-01-21 17:35:55.544315
15842	2016-06-01 00:00:00	2016-08-31 18:59:59	10239	10031	24	2017-01-21 17:35:55.549034	2017-01-21 17:35:55.549034
15843	2016-09-01 00:00:00	2016-12-31 18:59:59	10239	10030	20	2017-01-21 17:35:55.554534	2017-01-21 17:35:55.554534
15844	2016-09-01 00:00:00	2016-12-31 18:59:59	10239	10031	12	2017-01-21 17:35:55.559218	2017-01-21 17:35:55.559218
15845	2017-01-01 00:00:00	2099-12-31 18:59:59	10239	10030	18	2017-01-21 17:35:55.564815	2017-01-21 17:35:55.564815
15846	2017-01-01 00:00:00	2099-12-31 18:59:59	10239	10031	22	2017-01-21 17:35:55.569639	2017-01-21 17:35:55.569639
15847	2000-01-01 00:00:00	2016-05-31 18:59:59	10240	10030	15	2017-01-21 17:35:55.57525	2017-01-21 17:35:55.57525
15848	2000-01-01 00:00:00	2016-05-31 18:59:59	10240	10031	19	2017-01-21 17:35:55.579969	2017-01-21 17:35:55.579969
15849	2016-06-01 00:00:00	2016-08-31 18:59:59	10240	10030	17	2017-01-21 17:35:55.585286	2017-01-21 17:35:55.585286
15850	2016-06-01 00:00:00	2016-08-31 18:59:59	10240	10031	21	2017-01-21 17:35:55.589937	2017-01-21 17:35:55.589937
15851	2016-09-01 00:00:00	2016-12-31 18:59:59	10240	10030	28	2017-01-21 17:35:55.595232	2017-01-21 17:35:55.595232
15852	2016-09-01 00:00:00	2016-12-31 18:59:59	10240	10031	14	2017-01-21 17:35:55.599893	2017-01-21 17:35:55.599893
15853	2017-01-01 00:00:00	2099-12-31 18:59:59	10240	10030	28	2017-01-21 17:35:55.605431	2017-01-21 17:35:55.605431
15854	2017-01-01 00:00:00	2099-12-31 18:59:59	10240	10031	21	2017-01-21 17:35:55.61004	2017-01-21 17:35:55.61004
15855	2000-01-01 00:00:00	2016-05-31 18:59:59	10241	10030	27	2017-01-21 17:35:55.615676	2017-01-21 17:35:55.615676
15856	2000-01-01 00:00:00	2016-05-31 18:59:59	10241	10031	25	2017-01-21 17:35:55.620232	2017-01-21 17:35:55.620232
15857	2016-06-01 00:00:00	2016-08-31 18:59:59	10241	10030	10	2017-01-21 17:35:55.625422	2017-01-21 17:35:55.625422
15858	2016-06-01 00:00:00	2016-08-31 18:59:59	10241	10031	19	2017-01-21 17:35:55.630029	2017-01-21 17:35:55.630029
15859	2016-09-01 00:00:00	2016-12-31 18:59:59	10241	10030	22	2017-01-21 17:35:55.635631	2017-01-21 17:35:55.635631
15860	2016-09-01 00:00:00	2016-12-31 18:59:59	10241	10031	28	2017-01-21 17:35:55.640252	2017-01-21 17:35:55.640252
15861	2017-01-01 00:00:00	2099-12-31 18:59:59	10241	10030	28	2017-01-21 17:35:55.646071	2017-01-21 17:35:55.646071
15862	2017-01-01 00:00:00	2099-12-31 18:59:59	10241	10031	26	2017-01-21 17:35:55.650702	2017-01-21 17:35:55.650702
15863	2000-01-01 00:00:00	2016-05-31 18:59:59	10242	10030	29	2017-01-21 17:35:55.656025	2017-01-21 17:35:55.656025
15864	2000-01-01 00:00:00	2016-05-31 18:59:59	10242	10031	13	2017-01-21 17:35:55.660617	2017-01-21 17:35:55.660617
15865	2016-06-01 00:00:00	2016-08-31 18:59:59	10242	10030	28	2017-01-21 17:35:55.665852	2017-01-21 17:35:55.665852
15866	2016-06-01 00:00:00	2016-08-31 18:59:59	10242	10031	20	2017-01-21 17:35:55.670138	2017-01-21 17:35:55.670138
15867	2016-09-01 00:00:00	2016-12-31 18:59:59	10242	10030	23	2017-01-21 17:35:55.675389	2017-01-21 17:35:55.675389
15868	2016-09-01 00:00:00	2016-12-31 18:59:59	10242	10031	14	2017-01-21 17:35:55.680301	2017-01-21 17:35:55.680301
15869	2017-01-01 00:00:00	2099-12-31 18:59:59	10242	10030	15	2017-01-21 17:35:55.68583	2017-01-21 17:35:55.68583
15870	2017-01-01 00:00:00	2099-12-31 18:59:59	10242	10031	13	2017-01-21 17:35:55.690686	2017-01-21 17:35:55.690686
15871	2000-01-01 00:00:00	2016-05-31 18:59:59	10243	10030	19	2017-01-21 17:35:55.695936	2017-01-21 17:35:55.695936
15872	2000-01-01 00:00:00	2016-05-31 18:59:59	10243	10031	11	2017-01-21 17:35:55.700848	2017-01-21 17:35:55.700848
15873	2016-06-01 00:00:00	2016-08-31 18:59:59	10243	10030	27	2017-01-21 17:35:55.706504	2017-01-21 17:35:55.706504
15874	2016-06-01 00:00:00	2016-08-31 18:59:59	10243	10031	18	2017-01-21 17:35:55.711234	2017-01-21 17:35:55.711234
15875	2016-09-01 00:00:00	2016-12-31 18:59:59	10243	10030	13	2017-01-21 17:35:55.716394	2017-01-21 17:35:55.716394
15876	2016-09-01 00:00:00	2016-12-31 18:59:59	10243	10031	13	2017-01-21 17:35:55.721081	2017-01-21 17:35:55.721081
15877	2017-01-01 00:00:00	2099-12-31 18:59:59	10243	10030	13	2017-01-21 17:35:55.72638	2017-01-21 17:35:55.72638
15878	2017-01-01 00:00:00	2099-12-31 18:59:59	10243	10031	27	2017-01-21 17:35:55.730953	2017-01-21 17:35:55.730953
15879	2000-01-01 00:00:00	2016-05-31 18:59:59	10244	10030	27	2017-01-21 17:35:55.736169	2017-01-21 17:35:55.736169
15880	2000-01-01 00:00:00	2016-05-31 18:59:59	10244	10031	27	2017-01-21 17:35:55.74067	2017-01-21 17:35:55.74067
15881	2016-06-01 00:00:00	2016-08-31 18:59:59	10244	10030	11	2017-01-21 17:35:55.745904	2017-01-21 17:35:55.745904
15882	2016-06-01 00:00:00	2016-08-31 18:59:59	10244	10031	29	2017-01-21 17:35:55.750612	2017-01-21 17:35:55.750612
15883	2016-09-01 00:00:00	2016-12-31 18:59:59	10244	10030	14	2017-01-21 17:35:55.756048	2017-01-21 17:35:55.756048
15884	2016-09-01 00:00:00	2016-12-31 18:59:59	10244	10031	19	2017-01-21 17:35:55.760606	2017-01-21 17:35:55.760606
15885	2017-01-01 00:00:00	2099-12-31 18:59:59	10244	10030	22	2017-01-21 17:35:55.765977	2017-01-21 17:35:55.765977
15886	2017-01-01 00:00:00	2099-12-31 18:59:59	10244	10031	10	2017-01-21 17:35:55.770747	2017-01-21 17:35:55.770747
15887	2000-01-01 00:00:00	2016-05-31 18:59:59	10245	10030	23	2017-01-21 17:35:55.776066	2017-01-21 17:35:55.776066
15888	2000-01-01 00:00:00	2016-05-31 18:59:59	10245	10031	10	2017-01-21 17:35:55.780989	2017-01-21 17:35:55.780989
15889	2016-06-01 00:00:00	2016-08-31 18:59:59	10245	10030	24	2017-01-21 17:35:55.786533	2017-01-21 17:35:55.786533
15890	2016-06-01 00:00:00	2016-08-31 18:59:59	10245	10031	21	2017-01-21 17:35:55.791191	2017-01-21 17:35:55.791191
15891	2016-09-01 00:00:00	2016-12-31 18:59:59	10245	10030	23	2017-01-21 17:35:55.796433	2017-01-21 17:35:55.796433
15892	2016-09-01 00:00:00	2016-12-31 18:59:59	10245	10031	12	2017-01-21 17:35:55.801118	2017-01-21 17:35:55.801118
15893	2017-01-01 00:00:00	2099-12-31 18:59:59	10245	10030	29	2017-01-21 17:35:55.806535	2017-01-21 17:35:55.806535
15894	2017-01-01 00:00:00	2099-12-31 18:59:59	10245	10031	15	2017-01-21 17:35:55.811009	2017-01-21 17:35:55.811009
15895	2000-01-01 00:00:00	2016-05-31 18:59:59	10246	10030	23	2017-01-21 17:35:55.816846	2017-01-21 17:35:55.816846
15896	2000-01-01 00:00:00	2016-05-31 18:59:59	10246	10031	10	2017-01-21 17:35:55.821616	2017-01-21 17:35:55.821616
15897	2016-06-01 00:00:00	2016-08-31 18:59:59	10246	10030	23	2017-01-21 17:35:55.826865	2017-01-21 17:35:55.826865
15898	2016-06-01 00:00:00	2016-08-31 18:59:59	10246	10031	12	2017-01-21 17:35:55.831729	2017-01-21 17:35:55.831729
15899	2016-09-01 00:00:00	2016-12-31 18:59:59	10246	10030	20	2017-01-21 17:35:55.836983	2017-01-21 17:35:55.836983
15900	2016-09-01 00:00:00	2016-12-31 18:59:59	10246	10031	10	2017-01-21 17:35:55.841668	2017-01-21 17:35:55.841668
15901	2017-01-01 00:00:00	2099-12-31 18:59:59	10246	10030	29	2017-01-21 17:35:55.847083	2017-01-21 17:35:55.847083
15902	2017-01-01 00:00:00	2099-12-31 18:59:59	10246	10031	11	2017-01-21 17:35:55.851797	2017-01-21 17:35:55.851797
15903	2000-01-01 00:00:00	2016-05-31 18:59:59	10247	10030	21	2017-01-21 17:35:55.856759	2017-01-21 17:35:55.856759
15904	2000-01-01 00:00:00	2016-05-31 18:59:59	10247	10031	26	2017-01-21 17:35:55.861052	2017-01-21 17:35:55.861052
15905	2016-06-01 00:00:00	2016-08-31 18:59:59	10247	10030	17	2017-01-21 17:35:55.866735	2017-01-21 17:35:55.866735
15906	2016-06-01 00:00:00	2016-08-31 18:59:59	10247	10031	13	2017-01-21 17:35:55.871387	2017-01-21 17:35:55.871387
15907	2016-09-01 00:00:00	2016-12-31 18:59:59	10247	10030	26	2017-01-21 17:35:55.876629	2017-01-21 17:35:55.876629
15908	2016-09-01 00:00:00	2016-12-31 18:59:59	10247	10031	21	2017-01-21 17:35:55.880627	2017-01-21 17:35:55.880627
15909	2017-01-01 00:00:00	2099-12-31 18:59:59	10247	10030	12	2017-01-21 17:35:55.88669	2017-01-21 17:35:55.88669
15910	2017-01-01 00:00:00	2099-12-31 18:59:59	10247	10031	12	2017-01-21 17:35:55.891388	2017-01-21 17:35:55.891388
15911	2000-01-01 00:00:00	2016-05-31 18:59:59	10248	10030	23	2017-01-21 17:35:55.897279	2017-01-21 17:35:55.897279
15912	2000-01-01 00:00:00	2016-05-31 18:59:59	10248	10031	17	2017-01-21 17:35:55.90193	2017-01-21 17:35:55.90193
15913	2016-06-01 00:00:00	2016-08-31 18:59:59	10248	10030	26	2017-01-21 17:35:55.907043	2017-01-21 17:35:55.907043
15914	2016-06-01 00:00:00	2016-08-31 18:59:59	10248	10031	21	2017-01-21 17:35:55.911786	2017-01-21 17:35:55.911786
15915	2016-09-01 00:00:00	2016-12-31 18:59:59	10248	10030	26	2017-01-21 17:35:55.917448	2017-01-21 17:35:55.917448
15916	2016-09-01 00:00:00	2016-12-31 18:59:59	10248	10031	16	2017-01-21 17:35:55.922103	2017-01-21 17:35:55.922103
15917	2017-01-01 00:00:00	2099-12-31 18:59:59	10248	10030	25	2017-01-21 17:35:55.927395	2017-01-21 17:35:55.927395
15918	2017-01-01 00:00:00	2099-12-31 18:59:59	10248	10031	17	2017-01-21 17:35:55.931954	2017-01-21 17:35:55.931954
15919	2000-01-01 00:00:00	2016-05-31 18:59:59	10249	10030	24	2017-01-21 17:35:55.937449	2017-01-21 17:35:55.937449
15920	2000-01-01 00:00:00	2016-05-31 18:59:59	10249	10031	12	2017-01-21 17:35:55.942008	2017-01-21 17:35:55.942008
15921	2016-06-01 00:00:00	2016-08-31 18:59:59	10249	10030	25	2017-01-21 17:35:55.947638	2017-01-21 17:35:55.947638
15922	2016-06-01 00:00:00	2016-08-31 18:59:59	10249	10031	15	2017-01-21 17:35:55.952163	2017-01-21 17:35:55.952163
15923	2016-09-01 00:00:00	2016-12-31 18:59:59	10249	10030	18	2017-01-21 17:35:55.957339	2017-01-21 17:35:55.957339
15924	2016-09-01 00:00:00	2016-12-31 18:59:59	10249	10031	14	2017-01-21 17:35:55.962057	2017-01-21 17:35:55.962057
15925	2017-01-01 00:00:00	2099-12-31 18:59:59	10249	10030	19	2017-01-21 17:35:55.967675	2017-01-21 17:35:55.967675
15926	2017-01-01 00:00:00	2099-12-31 18:59:59	10249	10031	17	2017-01-21 17:35:55.972177	2017-01-21 17:35:55.972177
15927	2000-01-01 00:00:00	2016-05-31 18:59:59	10250	10030	24	2017-01-21 17:35:55.977386	2017-01-21 17:35:55.977386
15928	2000-01-01 00:00:00	2016-05-31 18:59:59	10250	10031	21	2017-01-21 17:35:55.982059	2017-01-21 17:35:55.982059
15929	2016-06-01 00:00:00	2016-08-31 18:59:59	10250	10030	12	2017-01-21 17:35:55.987385	2017-01-21 17:35:55.987385
15930	2016-06-01 00:00:00	2016-08-31 18:59:59	10250	10031	10	2017-01-21 17:35:55.99194	2017-01-21 17:35:55.99194
15931	2016-09-01 00:00:00	2016-12-31 18:59:59	10250	10030	23	2017-01-21 17:35:55.997265	2017-01-21 17:35:55.997265
15932	2016-09-01 00:00:00	2016-12-31 18:59:59	10250	10031	13	2017-01-21 17:35:56.001974	2017-01-21 17:35:56.001974
15933	2017-01-01 00:00:00	2099-12-31 18:59:59	10250	10030	18	2017-01-21 17:35:56.007445	2017-01-21 17:35:56.007445
15934	2017-01-01 00:00:00	2099-12-31 18:59:59	10250	10031	24	2017-01-21 17:35:56.011979	2017-01-21 17:35:56.011979
15935	2000-01-01 00:00:00	2016-05-31 18:59:59	10251	10030	20	2017-01-21 17:35:56.017424	2017-01-21 17:35:56.017424
15936	2000-01-01 00:00:00	2016-05-31 18:59:59	10251	10031	24	2017-01-21 17:35:56.021969	2017-01-21 17:35:56.021969
15937	2016-06-01 00:00:00	2016-08-31 18:59:59	10251	10030	28	2017-01-21 17:35:56.027254	2017-01-21 17:35:56.027254
15938	2016-06-01 00:00:00	2016-08-31 18:59:59	10251	10031	11	2017-01-21 17:35:56.031872	2017-01-21 17:35:56.031872
15939	2016-09-01 00:00:00	2016-12-31 18:59:59	10251	10030	14	2017-01-21 17:35:56.037552	2017-01-21 17:35:56.037552
15940	2016-09-01 00:00:00	2016-12-31 18:59:59	10251	10031	10	2017-01-21 17:35:56.042089	2017-01-21 17:35:56.042089
15941	2017-01-01 00:00:00	2099-12-31 18:59:59	10251	10030	21	2017-01-21 17:35:56.047657	2017-01-21 17:35:56.047657
15942	2017-01-01 00:00:00	2099-12-31 18:59:59	10251	10031	21	2017-01-21 17:35:56.052978	2017-01-21 17:35:56.052978
15943	2000-01-01 00:00:00	2016-05-31 18:59:59	10252	10030	15	2017-01-21 17:35:56.058276	2017-01-21 17:35:56.058276
15944	2000-01-01 00:00:00	2016-05-31 18:59:59	10252	10031	24	2017-01-21 17:35:56.062991	2017-01-21 17:35:56.062991
15945	2016-06-01 00:00:00	2016-08-31 18:59:59	10252	10030	24	2017-01-21 17:35:56.068595	2017-01-21 17:35:56.068595
15946	2016-06-01 00:00:00	2016-08-31 18:59:59	10252	10031	25	2017-01-21 17:35:56.072729	2017-01-21 17:35:56.072729
15947	2016-09-01 00:00:00	2016-12-31 18:59:59	10252	10030	18	2017-01-21 17:35:56.077482	2017-01-21 17:35:56.077482
15948	2016-09-01 00:00:00	2016-12-31 18:59:59	10252	10031	29	2017-01-21 17:35:56.08212	2017-01-21 17:35:56.08212
15949	2017-01-01 00:00:00	2099-12-31 18:59:59	10252	10030	27	2017-01-21 17:35:56.087384	2017-01-21 17:35:56.087384
15950	2017-01-01 00:00:00	2099-12-31 18:59:59	10252	10031	15	2017-01-21 17:35:56.092781	2017-01-21 17:35:56.092781
15951	2000-01-01 00:00:00	2016-05-31 18:59:59	10253	10030	18	2017-01-21 17:35:56.098025	2017-01-21 17:35:56.098025
15952	2000-01-01 00:00:00	2016-05-31 18:59:59	10253	10031	28	2017-01-21 17:35:56.102862	2017-01-21 17:35:56.102862
15953	2016-06-01 00:00:00	2016-08-31 18:59:59	10253	10030	20	2017-01-21 17:35:56.108639	2017-01-21 17:35:56.108639
15954	2016-06-01 00:00:00	2016-08-31 18:59:59	10253	10031	11	2017-01-21 17:35:56.113399	2017-01-21 17:35:56.113399
15955	2016-09-01 00:00:00	2016-12-31 18:59:59	10253	10030	28	2017-01-21 17:35:56.118533	2017-01-21 17:35:56.118533
15956	2016-09-01 00:00:00	2016-12-31 18:59:59	10253	10031	22	2017-01-21 17:35:56.123319	2017-01-21 17:35:56.123319
15957	2017-01-01 00:00:00	2099-12-31 18:59:59	10253	10030	16	2017-01-21 17:35:56.128427	2017-01-21 17:35:56.128427
15958	2017-01-01 00:00:00	2099-12-31 18:59:59	10253	10031	12	2017-01-21 17:35:56.133149	2017-01-21 17:35:56.133149
15959	2000-01-01 00:00:00	2016-05-31 18:59:59	10254	10030	12	2017-01-21 17:35:56.138555	2017-01-21 17:35:56.138555
15960	2000-01-01 00:00:00	2016-05-31 18:59:59	10254	10031	17	2017-01-21 17:35:56.143259	2017-01-21 17:35:56.143259
15961	2016-06-01 00:00:00	2016-08-31 18:59:59	10254	10030	11	2017-01-21 17:35:56.148539	2017-01-21 17:35:56.148539
15962	2016-06-01 00:00:00	2016-08-31 18:59:59	10254	10031	25	2017-01-21 17:35:56.153162	2017-01-21 17:35:56.153162
15963	2016-09-01 00:00:00	2016-12-31 18:59:59	10254	10030	12	2017-01-21 17:35:56.158423	2017-01-21 17:35:56.158423
15964	2016-09-01 00:00:00	2016-12-31 18:59:59	10254	10031	24	2017-01-21 17:35:56.163082	2017-01-21 17:35:56.163082
15965	2017-01-01 00:00:00	2099-12-31 18:59:59	10254	10030	21	2017-01-21 17:35:56.168424	2017-01-21 17:35:56.168424
15966	2017-01-01 00:00:00	2099-12-31 18:59:59	10254	10031	12	2017-01-21 17:35:56.173045	2017-01-21 17:35:56.173045
15967	2000-01-01 00:00:00	2016-05-31 18:59:59	10255	10030	21	2017-01-21 17:35:56.178758	2017-01-21 17:35:56.178758
15968	2000-01-01 00:00:00	2016-05-31 18:59:59	10255	10031	10	2017-01-21 17:35:56.18371	2017-01-21 17:35:56.18371
15969	2016-06-01 00:00:00	2016-08-31 18:59:59	10255	10030	28	2017-01-21 17:35:56.189214	2017-01-21 17:35:56.189214
15970	2016-06-01 00:00:00	2016-08-31 18:59:59	10255	10031	14	2017-01-21 17:35:56.193902	2017-01-21 17:35:56.193902
15971	2016-09-01 00:00:00	2016-12-31 18:59:59	10255	10030	28	2017-01-21 17:35:56.199187	2017-01-21 17:35:56.199187
15972	2016-09-01 00:00:00	2016-12-31 18:59:59	10255	10031	14	2017-01-21 17:35:56.203841	2017-01-21 17:35:56.203841
15973	2017-01-01 00:00:00	2099-12-31 18:59:59	10255	10030	13	2017-01-21 17:35:56.209512	2017-01-21 17:35:56.209512
15974	2017-01-01 00:00:00	2099-12-31 18:59:59	10255	10031	18	2017-01-21 17:35:56.214092	2017-01-21 17:35:56.214092
15975	2000-01-01 00:00:00	2016-05-31 18:59:59	10256	10030	25	2017-01-21 17:35:56.219565	2017-01-21 17:35:56.219565
15976	2000-01-01 00:00:00	2016-05-31 18:59:59	10256	10031	21	2017-01-21 17:35:56.224117	2017-01-21 17:35:56.224117
15977	2016-06-01 00:00:00	2016-08-31 18:59:59	10256	10030	14	2017-01-21 17:35:56.229366	2017-01-21 17:35:56.229366
15978	2016-06-01 00:00:00	2016-08-31 18:59:59	10256	10031	17	2017-01-21 17:35:56.234085	2017-01-21 17:35:56.234085
15979	2016-09-01 00:00:00	2016-12-31 18:59:59	10256	10030	24	2017-01-21 17:35:56.239335	2017-01-21 17:35:56.239335
15980	2016-09-01 00:00:00	2016-12-31 18:59:59	10256	10031	18	2017-01-21 17:35:56.243831	2017-01-21 17:35:56.243831
15981	2017-01-01 00:00:00	2099-12-31 18:59:59	10256	10030	26	2017-01-21 17:35:56.248916	2017-01-21 17:35:56.248916
15982	2017-01-01 00:00:00	2099-12-31 18:59:59	10256	10031	15	2017-01-21 17:35:56.253406	2017-01-21 17:35:56.253406
15983	2000-01-01 00:00:00	2016-05-31 18:59:59	10257	10030	16	2017-01-21 17:35:56.258585	2017-01-21 17:35:56.258585
15984	2000-01-01 00:00:00	2016-05-31 18:59:59	10257	10031	16	2017-01-21 17:35:56.263181	2017-01-21 17:35:56.263181
15985	2016-06-01 00:00:00	2016-08-31 18:59:59	10257	10030	10	2017-01-21 17:35:56.267872	2017-01-21 17:35:56.267872
15986	2016-06-01 00:00:00	2016-08-31 18:59:59	10257	10031	11	2017-01-21 17:35:56.271639	2017-01-21 17:35:56.271639
15987	2016-09-01 00:00:00	2016-12-31 18:59:59	10257	10030	16	2017-01-21 17:35:56.276026	2017-01-21 17:35:56.276026
15988	2016-09-01 00:00:00	2016-12-31 18:59:59	10257	10031	21	2017-01-21 17:35:56.280382	2017-01-21 17:35:56.280382
15989	2017-01-01 00:00:00	2099-12-31 18:59:59	10257	10030	16	2017-01-21 17:35:56.28536	2017-01-21 17:35:56.28536
15990	2017-01-01 00:00:00	2099-12-31 18:59:59	10257	10031	25	2017-01-21 17:35:56.290013	2017-01-21 17:35:56.290013
15991	2000-01-01 00:00:00	2016-05-31 18:59:59	10258	10030	24	2017-01-21 17:35:56.295571	2017-01-21 17:35:56.295571
15992	2000-01-01 00:00:00	2016-05-31 18:59:59	10258	10031	12	2017-01-21 17:35:56.30041	2017-01-21 17:35:56.30041
15993	2016-06-01 00:00:00	2016-08-31 18:59:59	10258	10030	28	2017-01-21 17:35:56.305642	2017-01-21 17:35:56.305642
15994	2016-06-01 00:00:00	2016-08-31 18:59:59	10258	10031	18	2017-01-21 17:35:56.310929	2017-01-21 17:35:56.310929
15995	2016-09-01 00:00:00	2016-12-31 18:59:59	10258	10030	27	2017-01-21 17:35:56.316212	2017-01-21 17:35:56.316212
15996	2016-09-01 00:00:00	2016-12-31 18:59:59	10258	10031	10	2017-01-21 17:35:56.320656	2017-01-21 17:35:56.320656
15997	2017-01-01 00:00:00	2099-12-31 18:59:59	10258	10030	14	2017-01-21 17:35:56.325809	2017-01-21 17:35:56.325809
15998	2017-01-01 00:00:00	2099-12-31 18:59:59	10258	10031	14	2017-01-21 17:35:56.330608	2017-01-21 17:35:56.330608
15999	2000-01-01 00:00:00	2016-05-31 18:59:59	10259	10030	20	2017-01-21 17:35:56.33607	2017-01-21 17:35:56.33607
16000	2000-01-01 00:00:00	2016-05-31 18:59:59	10259	10031	21	2017-01-21 17:35:56.340801	2017-01-21 17:35:56.340801
16001	2016-06-01 00:00:00	2016-08-31 18:59:59	10259	10030	19	2017-01-21 17:35:56.34627	2017-01-21 17:35:56.34627
16002	2016-06-01 00:00:00	2016-08-31 18:59:59	10259	10031	25	2017-01-21 17:35:56.350933	2017-01-21 17:35:56.350933
16003	2016-09-01 00:00:00	2016-12-31 18:59:59	10259	10030	26	2017-01-21 17:35:56.356454	2017-01-21 17:35:56.356454
16004	2016-09-01 00:00:00	2016-12-31 18:59:59	10259	10031	13	2017-01-21 17:35:56.361218	2017-01-21 17:35:56.361218
16005	2017-01-01 00:00:00	2099-12-31 18:59:59	10259	10030	23	2017-01-21 17:35:56.366395	2017-01-21 17:35:56.366395
16006	2017-01-01 00:00:00	2099-12-31 18:59:59	10259	10031	18	2017-01-21 17:35:56.371082	2017-01-21 17:35:56.371082
16007	2000-01-01 00:00:00	2016-05-31 18:59:59	10260	10030	22	2017-01-21 17:35:56.376797	2017-01-21 17:35:56.376797
16008	2000-01-01 00:00:00	2016-05-31 18:59:59	10260	10031	27	2017-01-21 17:35:56.38149	2017-01-21 17:35:56.38149
16009	2016-06-01 00:00:00	2016-08-31 18:59:59	10260	10030	21	2017-01-21 17:35:56.386616	2017-01-21 17:35:56.386616
16010	2016-06-01 00:00:00	2016-08-31 18:59:59	10260	10031	19	2017-01-21 17:35:56.391095	2017-01-21 17:35:56.391095
16011	2016-09-01 00:00:00	2016-12-31 18:59:59	10260	10030	21	2017-01-21 17:35:56.396525	2017-01-21 17:35:56.396525
16012	2016-09-01 00:00:00	2016-12-31 18:59:59	10260	10031	29	2017-01-21 17:35:56.401136	2017-01-21 17:35:56.401136
16013	2017-01-01 00:00:00	2099-12-31 18:59:59	10260	10030	28	2017-01-21 17:35:56.406679	2017-01-21 17:35:56.406679
16014	2017-01-01 00:00:00	2099-12-31 18:59:59	10260	10031	22	2017-01-21 17:35:56.411243	2017-01-21 17:35:56.411243
16015	2000-01-01 00:00:00	2016-05-31 18:59:59	10261	10030	26	2017-01-21 17:35:56.416415	2017-01-21 17:35:56.416415
16016	2000-01-01 00:00:00	2016-05-31 18:59:59	10261	10031	22	2017-01-21 17:35:56.421034	2017-01-21 17:35:56.421034
16017	2016-06-01 00:00:00	2016-08-31 18:59:59	10261	10030	13	2017-01-21 17:35:56.426357	2017-01-21 17:35:56.426357
16018	2016-06-01 00:00:00	2016-08-31 18:59:59	10261	10031	15	2017-01-21 17:35:56.430587	2017-01-21 17:35:56.430587
16019	2016-09-01 00:00:00	2016-12-31 18:59:59	10261	10030	25	2017-01-21 17:35:56.435931	2017-01-21 17:35:56.435931
16020	2016-09-01 00:00:00	2016-12-31 18:59:59	10261	10031	10	2017-01-21 17:35:56.440759	2017-01-21 17:35:56.440759
16021	2017-01-01 00:00:00	2099-12-31 18:59:59	10261	10030	24	2017-01-21 17:35:56.446434	2017-01-21 17:35:56.446434
16022	2017-01-01 00:00:00	2099-12-31 18:59:59	10261	10031	10	2017-01-21 17:35:56.451041	2017-01-21 17:35:56.451041
16023	2000-01-01 00:00:00	2016-05-31 18:59:59	10262	10030	17	2017-01-21 17:35:56.456598	2017-01-21 17:35:56.456598
16024	2000-01-01 00:00:00	2016-05-31 18:59:59	10262	10031	13	2017-01-21 17:35:56.461162	2017-01-21 17:35:56.461162
16025	2016-06-01 00:00:00	2016-08-31 18:59:59	10262	10030	24	2017-01-21 17:35:56.466332	2017-01-21 17:35:56.466332
16026	2016-06-01 00:00:00	2016-08-31 18:59:59	10262	10031	23	2017-01-21 17:35:56.471048	2017-01-21 17:35:56.471048
16027	2016-09-01 00:00:00	2016-12-31 18:59:59	10262	10030	11	2017-01-21 17:35:56.47662	2017-01-21 17:35:56.47662
16028	2016-09-01 00:00:00	2016-12-31 18:59:59	10262	10031	21	2017-01-21 17:35:56.481368	2017-01-21 17:35:56.481368
16029	2017-01-01 00:00:00	2099-12-31 18:59:59	10262	10030	24	2017-01-21 17:35:56.486578	2017-01-21 17:35:56.486578
16030	2017-01-01 00:00:00	2099-12-31 18:59:59	10262	10031	10	2017-01-21 17:35:56.491329	2017-01-21 17:35:56.491329
16031	2000-01-01 00:00:00	2016-05-31 18:59:59	10263	10030	26	2017-01-21 17:35:56.496588	2017-01-21 17:35:56.496588
16032	2000-01-01 00:00:00	2016-05-31 18:59:59	10263	10031	13	2017-01-21 17:35:56.501251	2017-01-21 17:35:56.501251
16033	2016-06-01 00:00:00	2016-08-31 18:59:59	10263	10030	28	2017-01-21 17:35:56.506228	2017-01-21 17:35:56.506228
16034	2016-06-01 00:00:00	2016-08-31 18:59:59	10263	10031	24	2017-01-21 17:35:56.510615	2017-01-21 17:35:56.510615
16035	2016-09-01 00:00:00	2016-12-31 18:59:59	10263	10030	13	2017-01-21 17:35:56.516071	2017-01-21 17:35:56.516071
16036	2016-09-01 00:00:00	2016-12-31 18:59:59	10263	10031	22	2017-01-21 17:35:56.520712	2017-01-21 17:35:56.520712
16037	2017-01-01 00:00:00	2099-12-31 18:59:59	10263	10030	18	2017-01-21 17:35:56.526091	2017-01-21 17:35:56.526091
16038	2017-01-01 00:00:00	2099-12-31 18:59:59	10263	10031	29	2017-01-21 17:35:56.531279	2017-01-21 17:35:56.531279
16039	2000-01-01 00:00:00	2016-05-31 18:59:59	10264	10030	19	2017-01-21 17:35:56.53642	2017-01-21 17:35:56.53642
16040	2000-01-01 00:00:00	2016-05-31 18:59:59	10264	10031	22	2017-01-21 17:35:56.541171	2017-01-21 17:35:56.541171
16041	2016-06-01 00:00:00	2016-08-31 18:59:59	10264	10030	19	2017-01-21 17:35:56.546676	2017-01-21 17:35:56.546676
16042	2016-06-01 00:00:00	2016-08-31 18:59:59	10264	10031	13	2017-01-21 17:35:56.551746	2017-01-21 17:35:56.551746
16043	2016-09-01 00:00:00	2016-12-31 18:59:59	10264	10030	27	2017-01-21 17:35:56.557308	2017-01-21 17:35:56.557308
16044	2016-09-01 00:00:00	2016-12-31 18:59:59	10264	10031	23	2017-01-21 17:35:56.561913	2017-01-21 17:35:56.561913
16045	2017-01-01 00:00:00	2099-12-31 18:59:59	10264	10030	22	2017-01-21 17:35:56.567504	2017-01-21 17:35:56.567504
16046	2017-01-01 00:00:00	2099-12-31 18:59:59	10264	10031	29	2017-01-21 17:35:56.57216	2017-01-21 17:35:56.57216
16047	2000-01-01 00:00:00	2016-05-31 18:59:59	10265	10030	15	2017-01-21 17:35:56.577273	2017-01-21 17:35:56.577273
16048	2000-01-01 00:00:00	2016-05-31 18:59:59	10265	10031	20	2017-01-21 17:35:56.581612	2017-01-21 17:35:56.581612
16049	2016-06-01 00:00:00	2016-08-31 18:59:59	10265	10030	23	2017-01-21 17:35:56.586962	2017-01-21 17:35:56.586962
16050	2016-06-01 00:00:00	2016-08-31 18:59:59	10265	10031	20	2017-01-21 17:35:56.59273	2017-01-21 17:35:56.59273
16051	2016-09-01 00:00:00	2016-12-31 18:59:59	10265	10030	14	2017-01-21 17:35:56.598226	2017-01-21 17:35:56.598226
16052	2016-09-01 00:00:00	2016-12-31 18:59:59	10265	10031	22	2017-01-21 17:35:56.603133	2017-01-21 17:35:56.603133
16053	2017-01-01 00:00:00	2099-12-31 18:59:59	10265	10030	23	2017-01-21 17:35:56.608623	2017-01-21 17:35:56.608623
16054	2017-01-01 00:00:00	2099-12-31 18:59:59	10265	10031	17	2017-01-21 17:35:56.613252	2017-01-21 17:35:56.613252
16055	2000-01-01 00:00:00	2016-05-31 18:59:59	10266	10030	27	2017-01-21 17:35:56.618448	2017-01-21 17:35:56.618448
16056	2000-01-01 00:00:00	2016-05-31 18:59:59	10266	10031	29	2017-01-21 17:35:56.622989	2017-01-21 17:35:56.622989
16057	2016-06-01 00:00:00	2016-08-31 18:59:59	10266	10030	11	2017-01-21 17:35:56.629209	2017-01-21 17:35:56.629209
16058	2016-06-01 00:00:00	2016-08-31 18:59:59	10266	10031	28	2017-01-21 17:35:56.633598	2017-01-21 17:35:56.633598
16059	2016-09-01 00:00:00	2016-12-31 18:59:59	10266	10030	10	2017-01-21 17:35:56.63881	2017-01-21 17:35:56.63881
16060	2016-09-01 00:00:00	2016-12-31 18:59:59	10266	10031	11	2017-01-21 17:35:56.643663	2017-01-21 17:35:56.643663
16061	2017-01-01 00:00:00	2099-12-31 18:59:59	10266	10030	13	2017-01-21 17:35:56.64916	2017-01-21 17:35:56.64916
16062	2017-01-01 00:00:00	2099-12-31 18:59:59	10266	10031	21	2017-01-21 17:35:56.654062	2017-01-21 17:35:56.654062
16063	2000-01-01 00:00:00	2016-05-31 18:59:59	10267	10030	16	2017-01-21 17:35:56.659161	2017-01-21 17:35:56.659161
16064	2000-01-01 00:00:00	2016-05-31 18:59:59	10267	10031	29	2017-01-21 17:35:56.663889	2017-01-21 17:35:56.663889
16065	2016-06-01 00:00:00	2016-08-31 18:59:59	10267	10030	11	2017-01-21 17:35:56.669117	2017-01-21 17:35:56.669117
16066	2016-06-01 00:00:00	2016-08-31 18:59:59	10267	10031	22	2017-01-21 17:35:56.673491	2017-01-21 17:35:56.673491
16067	2016-09-01 00:00:00	2016-12-31 18:59:59	10267	10030	19	2017-01-21 17:35:56.678711	2017-01-21 17:35:56.678711
16068	2016-09-01 00:00:00	2016-12-31 18:59:59	10267	10031	23	2017-01-21 17:35:56.683452	2017-01-21 17:35:56.683452
16069	2017-01-01 00:00:00	2099-12-31 18:59:59	10267	10030	18	2017-01-21 17:35:56.688579	2017-01-21 17:35:56.688579
16070	2017-01-01 00:00:00	2099-12-31 18:59:59	10267	10031	25	2017-01-21 17:35:56.693203	2017-01-21 17:35:56.693203
16071	2000-01-01 00:00:00	2016-05-31 18:59:59	10268	10030	26	2017-01-21 17:35:56.698268	2017-01-21 17:35:56.698268
16072	2000-01-01 00:00:00	2016-05-31 18:59:59	10268	10031	17	2017-01-21 17:35:56.702495	2017-01-21 17:35:56.702495
16073	2016-06-01 00:00:00	2016-08-31 18:59:59	10268	10030	28	2017-01-21 17:35:56.707042	2017-01-21 17:35:56.707042
16074	2016-06-01 00:00:00	2016-08-31 18:59:59	10268	10031	11	2017-01-21 17:35:56.711057	2017-01-21 17:35:56.711057
16075	2016-09-01 00:00:00	2016-12-31 18:59:59	10268	10030	12	2017-01-21 17:35:56.716117	2017-01-21 17:35:56.716117
16076	2016-09-01 00:00:00	2016-12-31 18:59:59	10268	10031	17	2017-01-21 17:35:56.720309	2017-01-21 17:35:56.720309
16077	2017-01-01 00:00:00	2099-12-31 18:59:59	10268	10030	16	2017-01-21 17:35:56.72512	2017-01-21 17:35:56.72512
16078	2017-01-01 00:00:00	2099-12-31 18:59:59	10268	10031	12	2017-01-21 17:35:56.729577	2017-01-21 17:35:56.729577
16079	2000-01-01 00:00:00	2016-05-31 18:59:59	10269	10030	14	2017-01-21 17:35:56.734711	2017-01-21 17:35:56.734711
16080	2000-01-01 00:00:00	2016-05-31 18:59:59	10269	10031	24	2017-01-21 17:35:56.739036	2017-01-21 17:35:56.739036
16081	2016-06-01 00:00:00	2016-08-31 18:59:59	10269	10030	14	2017-01-21 17:35:56.744253	2017-01-21 17:35:56.744253
16082	2016-06-01 00:00:00	2016-08-31 18:59:59	10269	10031	23	2017-01-21 17:35:56.749568	2017-01-21 17:35:56.749568
16083	2016-09-01 00:00:00	2016-12-31 18:59:59	10269	10030	11	2017-01-21 17:35:56.754606	2017-01-21 17:35:56.754606
16084	2016-09-01 00:00:00	2016-12-31 18:59:59	10269	10031	24	2017-01-21 17:35:56.759029	2017-01-21 17:35:56.759029
16085	2017-01-01 00:00:00	2099-12-31 18:59:59	10269	10030	29	2017-01-21 17:35:56.764189	2017-01-21 17:35:56.764189
16086	2017-01-01 00:00:00	2099-12-31 18:59:59	10269	10031	17	2017-01-21 17:35:56.768559	2017-01-21 17:35:56.768559
16087	2000-01-01 00:00:00	2016-05-31 18:59:59	10270	10030	16	2017-01-21 17:35:56.773732	2017-01-21 17:35:56.773732
16088	2000-01-01 00:00:00	2016-05-31 18:59:59	10270	10031	29	2017-01-21 17:35:56.778334	2017-01-21 17:35:56.778334
16089	2016-06-01 00:00:00	2016-08-31 18:59:59	10270	10030	15	2017-01-21 17:35:56.783393	2017-01-21 17:35:56.783393
16090	2016-06-01 00:00:00	2016-08-31 18:59:59	10270	10031	27	2017-01-21 17:35:56.787997	2017-01-21 17:35:56.787997
16091	2016-09-01 00:00:00	2016-12-31 18:59:59	10270	10030	14	2017-01-21 17:35:56.793107	2017-01-21 17:35:56.793107
16092	2016-09-01 00:00:00	2016-12-31 18:59:59	10270	10031	18	2017-01-21 17:35:56.797971	2017-01-21 17:35:56.797971
16093	2017-01-01 00:00:00	2099-12-31 18:59:59	10270	10030	22	2017-01-21 17:35:56.802972	2017-01-21 17:35:56.802972
16094	2017-01-01 00:00:00	2099-12-31 18:59:59	10270	10031	25	2017-01-21 17:35:56.80723	2017-01-21 17:35:56.80723
16095	2000-01-01 00:00:00	2016-05-31 18:59:59	10271	10030	16	2017-01-21 17:35:56.812248	2017-01-21 17:35:56.812248
16096	2000-01-01 00:00:00	2016-05-31 18:59:59	10271	10031	12	2017-01-21 17:35:56.81681	2017-01-21 17:35:56.81681
16097	2016-06-01 00:00:00	2016-08-31 18:59:59	10271	10030	23	2017-01-21 17:35:56.821792	2017-01-21 17:35:56.821792
16098	2016-06-01 00:00:00	2016-08-31 18:59:59	10271	10031	26	2017-01-21 17:35:56.826385	2017-01-21 17:35:56.826385
16099	2016-09-01 00:00:00	2016-12-31 18:59:59	10271	10030	11	2017-01-21 17:35:56.832397	2017-01-21 17:35:56.832397
16100	2016-09-01 00:00:00	2016-12-31 18:59:59	10271	10031	18	2017-01-21 17:35:56.836682	2017-01-21 17:35:56.836682
16101	2017-01-01 00:00:00	2099-12-31 18:59:59	10271	10030	29	2017-01-21 17:35:56.842314	2017-01-21 17:35:56.842314
16102	2017-01-01 00:00:00	2099-12-31 18:59:59	10271	10031	18	2017-01-21 17:35:56.846831	2017-01-21 17:35:56.846831
16103	2000-01-01 00:00:00	2016-05-31 18:59:59	10272	10030	18	2017-01-21 17:35:56.851898	2017-01-21 17:35:56.851898
16104	2000-01-01 00:00:00	2016-05-31 18:59:59	10272	10031	14	2017-01-21 17:35:56.85643	2017-01-21 17:35:56.85643
16105	2016-06-01 00:00:00	2016-08-31 18:59:59	10272	10030	17	2017-01-21 17:35:56.861579	2017-01-21 17:35:56.861579
16106	2016-06-01 00:00:00	2016-08-31 18:59:59	10272	10031	27	2017-01-21 17:35:56.866768	2017-01-21 17:35:56.866768
16107	2016-09-01 00:00:00	2016-12-31 18:59:59	10272	10030	21	2017-01-21 17:35:56.871955	2017-01-21 17:35:56.871955
16108	2016-09-01 00:00:00	2016-12-31 18:59:59	10272	10031	23	2017-01-21 17:35:56.876583	2017-01-21 17:35:56.876583
16109	2017-01-01 00:00:00	2099-12-31 18:59:59	10272	10030	25	2017-01-21 17:35:56.88216	2017-01-21 17:35:56.88216
16110	2017-01-01 00:00:00	2099-12-31 18:59:59	10272	10031	13	2017-01-21 17:35:56.886927	2017-01-21 17:35:56.886927
16111	2000-01-01 00:00:00	2016-05-31 18:59:59	10273	10030	11	2017-01-21 17:35:56.892315	2017-01-21 17:35:56.892315
16112	2000-01-01 00:00:00	2016-05-31 18:59:59	10273	10031	13	2017-01-21 17:35:56.896916	2017-01-21 17:35:56.896916
16113	2016-06-01 00:00:00	2016-08-31 18:59:59	10273	10030	16	2017-01-21 17:35:56.902422	2017-01-21 17:35:56.902422
16114	2016-06-01 00:00:00	2016-08-31 18:59:59	10273	10031	18	2017-01-21 17:35:56.907695	2017-01-21 17:35:56.907695
16115	2016-09-01 00:00:00	2016-12-31 18:59:59	10273	10030	17	2017-01-21 17:35:56.913184	2017-01-21 17:35:56.913184
16116	2016-09-01 00:00:00	2016-12-31 18:59:59	10273	10031	22	2017-01-21 17:35:56.917918	2017-01-21 17:35:56.917918
16117	2017-01-01 00:00:00	2099-12-31 18:59:59	10273	10030	22	2017-01-21 17:35:56.92333	2017-01-21 17:35:56.92333
16118	2017-01-01 00:00:00	2099-12-31 18:59:59	10273	10031	26	2017-01-21 17:35:56.927931	2017-01-21 17:35:56.927931
16119	2000-01-01 00:00:00	2016-05-31 18:59:59	10274	10030	11	2017-01-21 17:35:56.932877	2017-01-21 17:35:56.932877
16120	2000-01-01 00:00:00	2016-05-31 18:59:59	10274	10031	20	2017-01-21 17:35:56.93721	2017-01-21 17:35:56.93721
16121	2016-06-01 00:00:00	2016-08-31 18:59:59	10274	10030	15	2017-01-21 17:35:56.942456	2017-01-21 17:35:56.942456
16122	2016-06-01 00:00:00	2016-08-31 18:59:59	10274	10031	16	2017-01-21 17:35:56.946844	2017-01-21 17:35:56.946844
16123	2016-09-01 00:00:00	2016-12-31 18:59:59	10274	10030	18	2017-01-21 17:35:56.952339	2017-01-21 17:35:56.952339
16124	2016-09-01 00:00:00	2016-12-31 18:59:59	10274	10031	28	2017-01-21 17:35:56.957042	2017-01-21 17:35:56.957042
16125	2017-01-01 00:00:00	2099-12-31 18:59:59	10274	10030	12	2017-01-21 17:35:56.962428	2017-01-21 17:35:56.962428
16126	2017-01-01 00:00:00	2099-12-31 18:59:59	10274	10031	16	2017-01-21 17:35:56.967936	2017-01-21 17:35:56.967936
16127	2000-01-01 00:00:00	2016-05-31 18:59:59	10275	10030	11	2017-01-21 17:35:56.973552	2017-01-21 17:35:56.973552
16128	2000-01-01 00:00:00	2016-05-31 18:59:59	10275	10031	28	2017-01-21 17:35:56.978109	2017-01-21 17:35:56.978109
16129	2016-06-01 00:00:00	2016-08-31 18:59:59	10275	10030	28	2017-01-21 17:35:56.983495	2017-01-21 17:35:56.983495
16130	2016-06-01 00:00:00	2016-08-31 18:59:59	10275	10031	14	2017-01-21 17:35:56.98818	2017-01-21 17:35:56.98818
16131	2016-09-01 00:00:00	2016-12-31 18:59:59	10275	10030	27	2017-01-21 17:35:56.993455	2017-01-21 17:35:56.993455
16132	2016-09-01 00:00:00	2016-12-31 18:59:59	10275	10031	21	2017-01-21 17:35:56.9982	2017-01-21 17:35:56.9982
16133	2017-01-01 00:00:00	2099-12-31 18:59:59	10275	10030	22	2017-01-21 17:35:57.003709	2017-01-21 17:35:57.003709
16134	2017-01-01 00:00:00	2099-12-31 18:59:59	10275	10031	18	2017-01-21 17:35:57.007806	2017-01-21 17:35:57.007806
16135	2000-01-01 00:00:00	2016-05-31 18:59:59	10276	10030	19	2017-01-21 17:35:57.012372	2017-01-21 17:35:57.012372
16136	2000-01-01 00:00:00	2016-05-31 18:59:59	10276	10031	22	2017-01-21 17:35:57.017094	2017-01-21 17:35:57.017094
16137	2016-06-01 00:00:00	2016-08-31 18:59:59	10276	10030	25	2017-01-21 17:35:57.022524	2017-01-21 17:35:57.022524
16138	2016-06-01 00:00:00	2016-08-31 18:59:59	10276	10031	23	2017-01-21 17:35:57.02725	2017-01-21 17:35:57.02725
16139	2016-09-01 00:00:00	2016-12-31 18:59:59	10276	10030	22	2017-01-21 17:35:57.032397	2017-01-21 17:35:57.032397
16140	2016-09-01 00:00:00	2016-12-31 18:59:59	10276	10031	14	2017-01-21 17:35:57.036938	2017-01-21 17:35:57.036938
16141	2017-01-01 00:00:00	2099-12-31 18:59:59	10276	10030	18	2017-01-21 17:35:57.042456	2017-01-21 17:35:57.042456
16142	2017-01-01 00:00:00	2099-12-31 18:59:59	10276	10031	17	2017-01-21 17:35:57.047161	2017-01-21 17:35:57.047161
16143	2000-01-01 00:00:00	2016-05-31 18:59:59	10277	10030	10	2017-01-21 17:35:57.053215	2017-01-21 17:35:57.053215
16144	2000-01-01 00:00:00	2016-05-31 18:59:59	10277	10031	12	2017-01-21 17:35:57.057862	2017-01-21 17:35:57.057862
16145	2016-06-01 00:00:00	2016-08-31 18:59:59	10277	10030	26	2017-01-21 17:35:57.06357	2017-01-21 17:35:57.06357
16146	2016-06-01 00:00:00	2016-08-31 18:59:59	10277	10031	25	2017-01-21 17:35:57.068215	2017-01-21 17:35:57.068215
16147	2016-09-01 00:00:00	2016-12-31 18:59:59	10277	10030	19	2017-01-21 17:35:57.073386	2017-01-21 17:35:57.073386
16148	2016-09-01 00:00:00	2016-12-31 18:59:59	10277	10031	21	2017-01-21 17:35:57.077867	2017-01-21 17:35:57.077867
16149	2017-01-01 00:00:00	2099-12-31 18:59:59	10277	10030	14	2017-01-21 17:35:57.083468	2017-01-21 17:35:57.083468
16150	2017-01-01 00:00:00	2099-12-31 18:59:59	10277	10031	21	2017-01-21 17:35:57.087988	2017-01-21 17:35:57.087988
16151	2000-01-01 00:00:00	2016-05-31 18:59:59	10278	10030	18	2017-01-21 17:35:57.093345	2017-01-21 17:35:57.093345
16152	2000-01-01 00:00:00	2016-05-31 18:59:59	10278	10031	23	2017-01-21 17:35:57.098035	2017-01-21 17:35:57.098035
16153	2016-06-01 00:00:00	2016-08-31 18:59:59	10278	10030	13	2017-01-21 17:35:57.103601	2017-01-21 17:35:57.103601
16154	2016-06-01 00:00:00	2016-08-31 18:59:59	10278	10031	16	2017-01-21 17:35:57.108165	2017-01-21 17:35:57.108165
16155	2016-09-01 00:00:00	2016-12-31 18:59:59	10278	10030	28	2017-01-21 17:35:57.113414	2017-01-21 17:35:57.113414
16156	2016-09-01 00:00:00	2016-12-31 18:59:59	10278	10031	16	2017-01-21 17:35:57.118057	2017-01-21 17:35:57.118057
16157	2017-01-01 00:00:00	2099-12-31 18:59:59	10278	10030	28	2017-01-21 17:35:57.123482	2017-01-21 17:35:57.123482
16158	2017-01-01 00:00:00	2099-12-31 18:59:59	10278	10031	18	2017-01-21 17:35:57.128051	2017-01-21 17:35:57.128051
16159	2000-01-01 00:00:00	2016-05-31 18:59:59	10279	10030	15	2017-01-21 17:35:57.133459	2017-01-21 17:35:57.133459
16160	2000-01-01 00:00:00	2016-05-31 18:59:59	10279	10031	15	2017-01-21 17:35:57.138186	2017-01-21 17:35:57.138186
16161	2016-06-01 00:00:00	2016-08-31 18:59:59	10279	10030	20	2017-01-21 17:35:57.14364	2017-01-21 17:35:57.14364
16162	2016-06-01 00:00:00	2016-08-31 18:59:59	10279	10031	26	2017-01-21 17:35:57.148337	2017-01-21 17:35:57.148337
16163	2016-09-01 00:00:00	2016-12-31 18:59:59	10279	10030	22	2017-01-21 17:35:57.153483	2017-01-21 17:35:57.153483
16164	2016-09-01 00:00:00	2016-12-31 18:59:59	10279	10031	13	2017-01-21 17:35:57.158509	2017-01-21 17:35:57.158509
16165	2017-01-01 00:00:00	2099-12-31 18:59:59	10279	10030	15	2017-01-21 17:35:57.16309	2017-01-21 17:35:57.16309
16166	2017-01-01 00:00:00	2099-12-31 18:59:59	10279	10031	26	2017-01-21 17:35:57.167833	2017-01-21 17:35:57.167833
16167	2000-01-01 00:00:00	2016-05-31 18:59:59	10280	10030	27	2017-01-21 17:35:57.173444	2017-01-21 17:35:57.173444
16168	2000-01-01 00:00:00	2016-05-31 18:59:59	10280	10031	18	2017-01-21 17:35:57.17804	2017-01-21 17:35:57.17804
16169	2016-06-01 00:00:00	2016-08-31 18:59:59	10280	10030	22	2017-01-21 17:35:57.184144	2017-01-21 17:35:57.184144
16170	2016-06-01 00:00:00	2016-08-31 18:59:59	10280	10031	26	2017-01-21 17:35:57.188759	2017-01-21 17:35:57.188759
16171	2016-09-01 00:00:00	2016-12-31 18:59:59	10280	10030	12	2017-01-21 17:35:57.193939	2017-01-21 17:35:57.193939
16172	2016-09-01 00:00:00	2016-12-31 18:59:59	10280	10031	17	2017-01-21 17:35:57.198444	2017-01-21 17:35:57.198444
16173	2017-01-01 00:00:00	2099-12-31 18:59:59	10280	10030	29	2017-01-21 17:35:57.203625	2017-01-21 17:35:57.203625
16174	2017-01-01 00:00:00	2099-12-31 18:59:59	10280	10031	22	2017-01-21 17:35:57.208299	2017-01-21 17:35:57.208299
16175	2000-01-01 00:00:00	2016-05-31 18:59:59	10281	10030	20	2017-01-21 17:35:57.213509	2017-01-21 17:35:57.213509
16176	2000-01-01 00:00:00	2016-05-31 18:59:59	10281	10031	20	2017-01-21 17:35:57.218009	2017-01-21 17:35:57.218009
16177	2016-06-01 00:00:00	2016-08-31 18:59:59	10281	10030	16	2017-01-21 17:35:57.223124	2017-01-21 17:35:57.223124
16178	2016-06-01 00:00:00	2016-08-31 18:59:59	10281	10031	27	2017-01-21 17:35:57.228057	2017-01-21 17:35:57.228057
16179	2016-09-01 00:00:00	2016-12-31 18:59:59	10281	10030	16	2017-01-21 17:35:57.233245	2017-01-21 17:35:57.233245
16180	2016-09-01 00:00:00	2016-12-31 18:59:59	10281	10031	25	2017-01-21 17:35:57.237762	2017-01-21 17:35:57.237762
16181	2017-01-01 00:00:00	2099-12-31 18:59:59	10281	10030	26	2017-01-21 17:35:57.242969	2017-01-21 17:35:57.242969
16182	2017-01-01 00:00:00	2099-12-31 18:59:59	10281	10031	15	2017-01-21 17:35:57.247776	2017-01-21 17:35:57.247776
16183	2000-01-01 00:00:00	2016-05-31 18:59:59	10282	10030	11	2017-01-21 17:35:57.253426	2017-01-21 17:35:57.253426
16184	2000-01-01 00:00:00	2016-05-31 18:59:59	10282	10031	28	2017-01-21 17:35:57.258358	2017-01-21 17:35:57.258358
16185	2016-06-01 00:00:00	2016-08-31 18:59:59	10282	10030	12	2017-01-21 17:35:57.263725	2017-01-21 17:35:57.263725
16186	2016-06-01 00:00:00	2016-08-31 18:59:59	10282	10031	26	2017-01-21 17:35:57.26867	2017-01-21 17:35:57.26867
16187	2016-09-01 00:00:00	2016-12-31 18:59:59	10282	10030	28	2017-01-21 17:35:57.274502	2017-01-21 17:35:57.274502
16188	2016-09-01 00:00:00	2016-12-31 18:59:59	10282	10031	11	2017-01-21 17:35:57.27925	2017-01-21 17:35:57.27925
16189	2017-01-01 00:00:00	2099-12-31 18:59:59	10282	10030	18	2017-01-21 17:35:57.284714	2017-01-21 17:35:57.284714
16190	2017-01-01 00:00:00	2099-12-31 18:59:59	10282	10031	12	2017-01-21 17:35:57.289193	2017-01-21 17:35:57.289193
16191	2000-01-01 00:00:00	2016-05-31 18:59:59	10283	10030	25	2017-01-21 17:35:57.294414	2017-01-21 17:35:57.294414
16192	2000-01-01 00:00:00	2016-05-31 18:59:59	10283	10031	28	2017-01-21 17:35:57.299167	2017-01-21 17:35:57.299167
16193	2016-06-01 00:00:00	2016-08-31 18:59:59	10283	10030	25	2017-01-21 17:35:57.304374	2017-01-21 17:35:57.304374
16194	2016-06-01 00:00:00	2016-08-31 18:59:59	10283	10031	15	2017-01-21 17:35:57.309003	2017-01-21 17:35:57.309003
16195	2016-09-01 00:00:00	2016-12-31 18:59:59	10283	10030	19	2017-01-21 17:35:57.314728	2017-01-21 17:35:57.314728
16196	2016-09-01 00:00:00	2016-12-31 18:59:59	10283	10031	26	2017-01-21 17:35:57.319285	2017-01-21 17:35:57.319285
16197	2017-01-01 00:00:00	2099-12-31 18:59:59	10283	10030	16	2017-01-21 17:35:57.324522	2017-01-21 17:35:57.324522
16198	2017-01-01 00:00:00	2099-12-31 18:59:59	10283	10031	26	2017-01-21 17:35:57.329302	2017-01-21 17:35:57.329302
16199	2000-01-01 00:00:00	2016-05-31 18:59:59	10284	10030	29	2017-01-21 17:35:57.334239	2017-01-21 17:35:57.334239
16200	2000-01-01 00:00:00	2016-05-31 18:59:59	10284	10031	19	2017-01-21 17:35:57.338378	2017-01-21 17:35:57.338378
16201	2016-06-01 00:00:00	2016-08-31 18:59:59	10284	10030	15	2017-01-21 17:35:57.342913	2017-01-21 17:35:57.342913
16202	2016-06-01 00:00:00	2016-08-31 18:59:59	10284	10031	10	2017-01-21 17:35:57.346734	2017-01-21 17:35:57.346734
16203	2016-09-01 00:00:00	2016-12-31 18:59:59	10284	10030	23	2017-01-21 17:35:57.351371	2017-01-21 17:35:57.351371
16204	2016-09-01 00:00:00	2016-12-31 18:59:59	10284	10031	27	2017-01-21 17:35:57.35584	2017-01-21 17:35:57.35584
16205	2017-01-01 00:00:00	2099-12-31 18:59:59	10284	10030	29	2017-01-21 17:35:57.361017	2017-01-21 17:35:57.361017
16206	2017-01-01 00:00:00	2099-12-31 18:59:59	10284	10031	28	2017-01-21 17:35:57.36593	2017-01-21 17:35:57.36593
16207	2000-01-01 00:00:00	2016-05-31 18:59:59	10285	10030	22	2017-01-21 17:35:57.371173	2017-01-21 17:35:57.371173
16208	2000-01-01 00:00:00	2016-05-31 18:59:59	10285	10031	11	2017-01-21 17:35:57.375752	2017-01-21 17:35:57.375752
16209	2016-06-01 00:00:00	2016-08-31 18:59:59	10285	10030	28	2017-01-21 17:35:57.381391	2017-01-21 17:35:57.381391
16210	2016-06-01 00:00:00	2016-08-31 18:59:59	10285	10031	24	2017-01-21 17:35:57.386038	2017-01-21 17:35:57.386038
16211	2016-09-01 00:00:00	2016-12-31 18:59:59	10285	10030	10	2017-01-21 17:35:57.391633	2017-01-21 17:35:57.391633
16212	2016-09-01 00:00:00	2016-12-31 18:59:59	10285	10031	26	2017-01-21 17:35:57.39626	2017-01-21 17:35:57.39626
16213	2017-01-01 00:00:00	2099-12-31 18:59:59	10285	10030	12	2017-01-21 17:35:57.402252	2017-01-21 17:35:57.402252
16214	2017-01-01 00:00:00	2099-12-31 18:59:59	10285	10031	13	2017-01-21 17:35:57.406996	2017-01-21 17:35:57.406996
16215	2000-01-01 00:00:00	2016-05-31 18:59:59	10286	10030	14	2017-01-21 17:35:57.412553	2017-01-21 17:35:57.412553
16216	2000-01-01 00:00:00	2016-05-31 18:59:59	10286	10031	13	2017-01-21 17:35:57.417579	2017-01-21 17:35:57.417579
16217	2016-06-01 00:00:00	2016-08-31 18:59:59	10286	10030	26	2017-01-21 17:35:57.423006	2017-01-21 17:35:57.423006
16218	2016-06-01 00:00:00	2016-08-31 18:59:59	10286	10031	23	2017-01-21 17:35:57.42765	2017-01-21 17:35:57.42765
16219	2016-09-01 00:00:00	2016-12-31 18:59:59	10286	10030	14	2017-01-21 17:35:57.433213	2017-01-21 17:35:57.433213
16220	2016-09-01 00:00:00	2016-12-31 18:59:59	10286	10031	21	2017-01-21 17:35:57.437882	2017-01-21 17:35:57.437882
16221	2017-01-01 00:00:00	2099-12-31 18:59:59	10286	10030	26	2017-01-21 17:35:57.443069	2017-01-21 17:35:57.443069
16222	2017-01-01 00:00:00	2099-12-31 18:59:59	10286	10031	18	2017-01-21 17:35:57.448033	2017-01-21 17:35:57.448033
16223	2000-01-01 00:00:00	2016-05-31 18:59:59	10287	10030	20	2017-01-21 17:35:57.453484	2017-01-21 17:35:57.453484
16224	2000-01-01 00:00:00	2016-05-31 18:59:59	10287	10031	10	2017-01-21 17:35:57.4581	2017-01-21 17:35:57.4581
16225	2016-06-01 00:00:00	2016-08-31 18:59:59	10287	10030	13	2017-01-21 17:35:57.463738	2017-01-21 17:35:57.463738
16226	2016-06-01 00:00:00	2016-08-31 18:59:59	10287	10031	16	2017-01-21 17:35:57.468409	2017-01-21 17:35:57.468409
16227	2016-09-01 00:00:00	2016-12-31 18:59:59	10287	10030	18	2017-01-21 17:35:57.47369	2017-01-21 17:35:57.47369
16228	2016-09-01 00:00:00	2016-12-31 18:59:59	10287	10031	23	2017-01-21 17:35:57.478255	2017-01-21 17:35:57.478255
16229	2017-01-01 00:00:00	2099-12-31 18:59:59	10287	10030	18	2017-01-21 17:35:57.483511	2017-01-21 17:35:57.483511
16230	2017-01-01 00:00:00	2099-12-31 18:59:59	10287	10031	12	2017-01-21 17:35:57.488203	2017-01-21 17:35:57.488203
16231	2000-01-01 00:00:00	2016-05-31 18:59:59	10288	10030	18	2017-01-21 17:35:57.493202	2017-01-21 17:35:57.493202
16232	2000-01-01 00:00:00	2016-05-31 18:59:59	10288	10031	11	2017-01-21 17:35:57.497605	2017-01-21 17:35:57.497605
16233	2016-06-01 00:00:00	2016-08-31 18:59:59	10288	10030	14	2017-01-21 17:35:57.502329	2017-01-21 17:35:57.502329
16234	2016-06-01 00:00:00	2016-08-31 18:59:59	10288	10031	23	2017-01-21 17:35:57.506684	2017-01-21 17:35:57.506684
16235	2016-09-01 00:00:00	2016-12-31 18:59:59	10288	10030	24	2017-01-21 17:35:57.511467	2017-01-21 17:35:57.511467
16236	2016-09-01 00:00:00	2016-12-31 18:59:59	10288	10031	15	2017-01-21 17:35:57.515777	2017-01-21 17:35:57.515777
16237	2017-01-01 00:00:00	2099-12-31 18:59:59	10288	10030	25	2017-01-21 17:35:57.520649	2017-01-21 17:35:57.520649
16238	2017-01-01 00:00:00	2099-12-31 18:59:59	10288	10031	21	2017-01-21 17:35:57.524797	2017-01-21 17:35:57.524797
16239	2000-01-01 00:00:00	2016-05-31 18:59:59	10289	10030	26	2017-01-21 17:35:57.53068	2017-01-21 17:35:57.53068
16240	2000-01-01 00:00:00	2016-05-31 18:59:59	10289	10031	17	2017-01-21 17:35:57.535513	2017-01-21 17:35:57.535513
16241	2016-06-01 00:00:00	2016-08-31 18:59:59	10289	10030	27	2017-01-21 17:35:57.540913	2017-01-21 17:35:57.540913
16242	2016-06-01 00:00:00	2016-08-31 18:59:59	10289	10031	10	2017-01-21 17:35:57.545872	2017-01-21 17:35:57.545872
16243	2016-09-01 00:00:00	2016-12-31 18:59:59	10289	10030	20	2017-01-21 17:35:57.551831	2017-01-21 17:35:57.551831
16244	2016-09-01 00:00:00	2016-12-31 18:59:59	10289	10031	22	2017-01-21 17:35:57.556633	2017-01-21 17:35:57.556633
16245	2017-01-01 00:00:00	2099-12-31 18:59:59	10289	10030	15	2017-01-21 17:35:57.561825	2017-01-21 17:35:57.561825
16246	2017-01-01 00:00:00	2099-12-31 18:59:59	10289	10031	19	2017-01-21 17:35:57.566474	2017-01-21 17:35:57.566474
16247	2000-01-01 00:00:00	2016-05-31 18:59:59	10290	10030	28	2017-01-21 17:35:57.571675	2017-01-21 17:35:57.571675
16248	2000-01-01 00:00:00	2016-05-31 18:59:59	10290	10031	16	2017-01-21 17:35:57.576272	2017-01-21 17:35:57.576272
16249	2016-06-01 00:00:00	2016-08-31 18:59:59	10290	10030	18	2017-01-21 17:35:57.581632	2017-01-21 17:35:57.581632
16250	2016-06-01 00:00:00	2016-08-31 18:59:59	10290	10031	10	2017-01-21 17:35:57.586377	2017-01-21 17:35:57.586377
16251	2016-09-01 00:00:00	2016-12-31 18:59:59	10290	10030	13	2017-01-21 17:35:57.591701	2017-01-21 17:35:57.591701
16252	2016-09-01 00:00:00	2016-12-31 18:59:59	10290	10031	22	2017-01-21 17:35:57.596502	2017-01-21 17:35:57.596502
16253	2017-01-01 00:00:00	2099-12-31 18:59:59	10290	10030	19	2017-01-21 17:35:57.601756	2017-01-21 17:35:57.601756
16254	2017-01-01 00:00:00	2099-12-31 18:59:59	10290	10031	21	2017-01-21 17:35:57.60638	2017-01-21 17:35:57.60638
16255	2000-01-01 00:00:00	2016-05-31 18:59:59	10291	10030	11	2017-01-21 17:35:57.611983	2017-01-21 17:35:57.611983
16256	2000-01-01 00:00:00	2016-05-31 18:59:59	10291	10031	19	2017-01-21 17:35:57.61674	2017-01-21 17:35:57.61674
16257	2016-06-01 00:00:00	2016-08-31 18:59:59	10291	10030	10	2017-01-21 17:35:57.623149	2017-01-21 17:35:57.623149
16258	2016-06-01 00:00:00	2016-08-31 18:59:59	10291	10031	14	2017-01-21 17:35:57.627817	2017-01-21 17:35:57.627817
16259	2016-09-01 00:00:00	2016-12-31 18:59:59	10291	10030	21	2017-01-21 17:35:57.633423	2017-01-21 17:35:57.633423
16260	2016-09-01 00:00:00	2016-12-31 18:59:59	10291	10031	29	2017-01-21 17:35:57.638332	2017-01-21 17:35:57.638332
16261	2017-01-01 00:00:00	2099-12-31 18:59:59	10291	10030	22	2017-01-21 17:35:57.643569	2017-01-21 17:35:57.643569
16262	2017-01-01 00:00:00	2099-12-31 18:59:59	10291	10031	23	2017-01-21 17:35:57.648248	2017-01-21 17:35:57.648248
16263	2000-01-01 00:00:00	2016-05-31 18:59:59	10292	10030	23	2017-01-21 17:35:57.653436	2017-01-21 17:35:57.653436
16264	2000-01-01 00:00:00	2016-05-31 18:59:59	10292	10031	13	2017-01-21 17:35:57.658179	2017-01-21 17:35:57.658179
16265	2016-06-01 00:00:00	2016-08-31 18:59:59	10292	10030	23	2017-01-21 17:35:57.66338	2017-01-21 17:35:57.66338
16266	2016-06-01 00:00:00	2016-08-31 18:59:59	10292	10031	11	2017-01-21 17:35:57.667923	2017-01-21 17:35:57.667923
16267	2016-09-01 00:00:00	2016-12-31 18:59:59	10292	10030	15	2017-01-21 17:35:57.673282	2017-01-21 17:35:57.673282
16268	2016-09-01 00:00:00	2016-12-31 18:59:59	10292	10031	16	2017-01-21 17:35:57.677917	2017-01-21 17:35:57.677917
16269	2017-01-01 00:00:00	2099-12-31 18:59:59	10292	10030	15	2017-01-21 17:35:57.683545	2017-01-21 17:35:57.683545
16270	2017-01-01 00:00:00	2099-12-31 18:59:59	10292	10031	24	2017-01-21 17:35:57.688209	2017-01-21 17:35:57.688209
16271	2000-01-01 00:00:00	2016-05-31 18:59:59	10293	10030	18	2017-01-21 17:35:57.69341	2017-01-21 17:35:57.69341
16272	2000-01-01 00:00:00	2016-05-31 18:59:59	10293	10031	27	2017-01-21 17:35:57.698176	2017-01-21 17:35:57.698176
16273	2016-06-01 00:00:00	2016-08-31 18:59:59	10293	10030	26	2017-01-21 17:35:57.703542	2017-01-21 17:35:57.703542
16274	2016-06-01 00:00:00	2016-08-31 18:59:59	10293	10031	11	2017-01-21 17:35:57.707931	2017-01-21 17:35:57.707931
16275	2016-09-01 00:00:00	2016-12-31 18:59:59	10293	10030	25	2017-01-21 17:35:57.7128	2017-01-21 17:35:57.7128
16276	2016-09-01 00:00:00	2016-12-31 18:59:59	10293	10031	20	2017-01-21 17:35:57.717328	2017-01-21 17:35:57.717328
16277	2017-01-01 00:00:00	2099-12-31 18:59:59	10293	10030	10	2017-01-21 17:35:57.722553	2017-01-21 17:35:57.722553
16278	2017-01-01 00:00:00	2099-12-31 18:59:59	10293	10031	19	2017-01-21 17:35:57.727247	2017-01-21 17:35:57.727247
16279	2000-01-01 00:00:00	2016-05-31 18:59:59	10294	10030	10	2017-01-21 17:35:57.732392	2017-01-21 17:35:57.732392
16280	2000-01-01 00:00:00	2016-05-31 18:59:59	10294	10031	18	2017-01-21 17:35:57.737085	2017-01-21 17:35:57.737085
16281	2016-06-01 00:00:00	2016-08-31 18:59:59	10294	10030	16	2017-01-21 17:35:57.74253	2017-01-21 17:35:57.74253
16282	2016-06-01 00:00:00	2016-08-31 18:59:59	10294	10031	12	2017-01-21 17:35:57.747246	2017-01-21 17:35:57.747246
16283	2016-09-01 00:00:00	2016-12-31 18:59:59	10294	10030	29	2017-01-21 17:35:57.752703	2017-01-21 17:35:57.752703
16284	2016-09-01 00:00:00	2016-12-31 18:59:59	10294	10031	16	2017-01-21 17:35:57.757429	2017-01-21 17:35:57.757429
16285	2017-01-01 00:00:00	2099-12-31 18:59:59	10294	10030	21	2017-01-21 17:35:57.762745	2017-01-21 17:35:57.762745
16286	2017-01-01 00:00:00	2099-12-31 18:59:59	10294	10031	10	2017-01-21 17:35:57.767685	2017-01-21 17:35:57.767685
16287	2000-01-01 00:00:00	2016-05-31 18:59:59	10295	10030	15	2017-01-21 17:35:57.773027	2017-01-21 17:35:57.773027
16288	2000-01-01 00:00:00	2016-05-31 18:59:59	10295	10031	12	2017-01-21 17:35:57.77787	2017-01-21 17:35:57.77787
16289	2016-06-01 00:00:00	2016-08-31 18:59:59	10295	10030	19	2017-01-21 17:35:57.783657	2017-01-21 17:35:57.783657
16290	2016-06-01 00:00:00	2016-08-31 18:59:59	10295	10031	12	2017-01-21 17:35:57.78843	2017-01-21 17:35:57.78843
16291	2016-09-01 00:00:00	2016-12-31 18:59:59	10295	10030	14	2017-01-21 17:35:57.794042	2017-01-21 17:35:57.794042
16292	2016-09-01 00:00:00	2016-12-31 18:59:59	10295	10031	25	2017-01-21 17:35:57.798827	2017-01-21 17:35:57.798827
16293	2017-01-01 00:00:00	2099-12-31 18:59:59	10295	10030	14	2017-01-21 17:35:57.804364	2017-01-21 17:35:57.804364
16294	2017-01-01 00:00:00	2099-12-31 18:59:59	10295	10031	29	2017-01-21 17:35:57.808944	2017-01-21 17:35:57.808944
16295	2000-01-01 00:00:00	2016-05-31 18:59:59	10296	10030	12	2017-01-21 17:35:57.81472	2017-01-21 17:35:57.81472
16296	2000-01-01 00:00:00	2016-05-31 18:59:59	10296	10031	14	2017-01-21 17:35:57.819887	2017-01-21 17:35:57.819887
16297	2016-06-01 00:00:00	2016-08-31 18:59:59	10296	10030	13	2017-01-21 17:35:57.825504	2017-01-21 17:35:57.825504
16298	2016-06-01 00:00:00	2016-08-31 18:59:59	10296	10031	19	2017-01-21 17:35:57.830224	2017-01-21 17:35:57.830224
16299	2016-09-01 00:00:00	2016-12-31 18:59:59	10296	10030	14	2017-01-21 17:35:57.835701	2017-01-21 17:35:57.835701
16300	2016-09-01 00:00:00	2016-12-31 18:59:59	10296	10031	24	2017-01-21 17:35:57.840306	2017-01-21 17:35:57.840306
16301	2017-01-01 00:00:00	2099-12-31 18:59:59	10296	10030	19	2017-01-21 17:35:57.851318	2017-01-21 17:35:57.851318
16302	2017-01-01 00:00:00	2099-12-31 18:59:59	10296	10031	18	2017-01-21 17:35:57.861382	2017-01-21 17:35:57.861382
16303	2000-01-01 00:00:00	2016-05-31 18:59:59	10297	10030	19	2017-01-21 17:35:57.871985	2017-01-21 17:35:57.871985
16304	2000-01-01 00:00:00	2016-05-31 18:59:59	10297	10031	21	2017-01-21 17:35:57.876817	2017-01-21 17:35:57.876817
16305	2016-06-01 00:00:00	2016-08-31 18:59:59	10297	10030	12	2017-01-21 17:35:57.882069	2017-01-21 17:35:57.882069
16306	2016-06-01 00:00:00	2016-08-31 18:59:59	10297	10031	23	2017-01-21 17:35:57.887387	2017-01-21 17:35:57.887387
16307	2016-09-01 00:00:00	2016-12-31 18:59:59	10297	10030	18	2017-01-21 17:35:57.892982	2017-01-21 17:35:57.892982
16308	2016-09-01 00:00:00	2016-12-31 18:59:59	10297	10031	17	2017-01-21 17:35:57.897198	2017-01-21 17:35:57.897198
16309	2017-01-01 00:00:00	2099-12-31 18:59:59	10297	10030	21	2017-01-21 17:35:57.90178	2017-01-21 17:35:57.90178
16310	2017-01-01 00:00:00	2099-12-31 18:59:59	10297	10031	22	2017-01-21 17:35:57.906306	2017-01-21 17:35:57.906306
16311	2000-01-01 00:00:00	2016-05-31 18:59:59	10298	10030	14	2017-01-21 17:35:57.911826	2017-01-21 17:35:57.911826
16312	2000-01-01 00:00:00	2016-05-31 18:59:59	10298	10031	13	2017-01-21 17:35:57.916716	2017-01-21 17:35:57.916716
16313	2016-06-01 00:00:00	2016-08-31 18:59:59	10298	10030	18	2017-01-21 17:35:57.922314	2017-01-21 17:35:57.922314
16314	2016-06-01 00:00:00	2016-08-31 18:59:59	10298	10031	13	2017-01-21 17:35:57.92688	2017-01-21 17:35:57.92688
16315	2016-09-01 00:00:00	2016-12-31 18:59:59	10298	10030	19	2017-01-21 17:35:57.932292	2017-01-21 17:35:57.932292
16316	2016-09-01 00:00:00	2016-12-31 18:59:59	10298	10031	18	2017-01-21 17:35:57.936963	2017-01-21 17:35:57.936963
16317	2017-01-01 00:00:00	2099-12-31 18:59:59	10298	10030	23	2017-01-21 17:35:57.942539	2017-01-21 17:35:57.942539
16318	2017-01-01 00:00:00	2099-12-31 18:59:59	10298	10031	20	2017-01-21 17:35:57.947603	2017-01-21 17:35:57.947603
16319	2000-01-01 00:00:00	2016-05-31 18:59:59	10299	10030	26	2017-01-21 17:35:57.953033	2017-01-21 17:35:57.953033
16320	2000-01-01 00:00:00	2016-05-31 18:59:59	10299	10031	26	2017-01-21 17:35:57.9578	2017-01-21 17:35:57.9578
16321	2016-06-01 00:00:00	2016-08-31 18:59:59	10299	10030	24	2017-01-21 17:35:57.963499	2017-01-21 17:35:57.963499
16322	2016-06-01 00:00:00	2016-08-31 18:59:59	10299	10031	14	2017-01-21 17:35:57.968599	2017-01-21 17:35:57.968599
16323	2016-09-01 00:00:00	2016-12-31 18:59:59	10299	10030	15	2017-01-21 17:35:57.974065	2017-01-21 17:35:57.974065
16324	2016-09-01 00:00:00	2016-12-31 18:59:59	10299	10031	24	2017-01-21 17:35:57.978991	2017-01-21 17:35:57.978991
16325	2017-01-01 00:00:00	2099-12-31 18:59:59	10299	10030	19	2017-01-21 17:35:57.984427	2017-01-21 17:35:57.984427
16326	2017-01-01 00:00:00	2099-12-31 18:59:59	10299	10031	17	2017-01-21 17:35:57.989095	2017-01-21 17:35:57.989095
16327	2000-01-01 00:00:00	2016-05-31 18:59:59	10300	10030	27	2017-01-21 17:35:57.994513	2017-01-21 17:35:57.994513
16328	2000-01-01 00:00:00	2016-05-31 18:59:59	10300	10031	27	2017-01-21 17:35:57.999277	2017-01-21 17:35:57.999277
16329	2016-06-01 00:00:00	2016-08-31 18:59:59	10300	10030	26	2017-01-21 17:35:58.004453	2017-01-21 17:35:58.004453
16330	2016-06-01 00:00:00	2016-08-31 18:59:59	10300	10031	29	2017-01-21 17:35:58.009204	2017-01-21 17:35:58.009204
16331	2016-09-01 00:00:00	2016-12-31 18:59:59	10300	10030	14	2017-01-21 17:35:58.014662	2017-01-21 17:35:58.014662
16332	2016-09-01 00:00:00	2016-12-31 18:59:59	10300	10031	11	2017-01-21 17:35:58.019248	2017-01-21 17:35:58.019248
16333	2017-01-01 00:00:00	2099-12-31 18:59:59	10300	10030	10	2017-01-21 17:35:58.024496	2017-01-21 17:35:58.024496
16334	2017-01-01 00:00:00	2099-12-31 18:59:59	10300	10031	23	2017-01-21 17:35:58.02902	2017-01-21 17:35:58.02902
16335	2000-01-01 00:00:00	2016-05-31 18:59:59	10301	10030	10	2017-01-21 17:35:58.034626	2017-01-21 17:35:58.034626
16336	2000-01-01 00:00:00	2016-05-31 18:59:59	10301	10031	29	2017-01-21 17:35:58.039252	2017-01-21 17:35:58.039252
16337	2016-06-01 00:00:00	2016-08-31 18:59:59	10301	10030	11	2017-01-21 17:35:58.044548	2017-01-21 17:35:58.044548
16338	2016-06-01 00:00:00	2016-08-31 18:59:59	10301	10031	29	2017-01-21 17:35:58.049203	2017-01-21 17:35:58.049203
16339	2016-09-01 00:00:00	2016-12-31 18:59:59	10301	10030	15	2017-01-21 17:35:58.05447	2017-01-21 17:35:58.05447
16340	2016-09-01 00:00:00	2016-12-31 18:59:59	10301	10031	15	2017-01-21 17:35:58.05921	2017-01-21 17:35:58.05921
16341	2017-01-01 00:00:00	2099-12-31 18:59:59	10301	10030	10	2017-01-21 17:35:58.064987	2017-01-21 17:35:58.064987
16342	2017-01-01 00:00:00	2099-12-31 18:59:59	10301	10031	16	2017-01-21 17:35:58.070039	2017-01-21 17:35:58.070039
16343	2000-01-01 00:00:00	2016-05-31 18:59:59	10302	10030	10	2017-01-21 17:35:58.074891	2017-01-21 17:35:58.074891
16344	2000-01-01 00:00:00	2016-05-31 18:59:59	10302	10031	21	2017-01-21 17:35:58.079733	2017-01-21 17:35:58.079733
16345	2016-06-01 00:00:00	2016-08-31 18:59:59	10302	10030	26	2017-01-21 17:35:58.084483	2017-01-21 17:35:58.084483
16346	2016-06-01 00:00:00	2016-08-31 18:59:59	10302	10031	29	2017-01-21 17:35:58.089092	2017-01-21 17:35:58.089092
16347	2016-09-01 00:00:00	2016-12-31 18:59:59	10302	10030	27	2017-01-21 17:35:58.094692	2017-01-21 17:35:58.094692
16348	2016-09-01 00:00:00	2016-12-31 18:59:59	10302	10031	11	2017-01-21 17:35:58.099388	2017-01-21 17:35:58.099388
16349	2017-01-01 00:00:00	2099-12-31 18:59:59	10302	10030	11	2017-01-21 17:35:58.104613	2017-01-21 17:35:58.104613
16350	2017-01-01 00:00:00	2099-12-31 18:59:59	10302	10031	28	2017-01-21 17:35:58.109386	2017-01-21 17:35:58.109386
16351	2000-01-01 00:00:00	2016-05-31 18:59:59	10303	10030	15	2017-01-21 17:35:58.11477	2017-01-21 17:35:58.11477
16352	2000-01-01 00:00:00	2016-05-31 18:59:59	10303	10031	22	2017-01-21 17:35:58.119299	2017-01-21 17:35:58.119299
16353	2016-06-01 00:00:00	2016-08-31 18:59:59	10303	10030	15	2017-01-21 17:35:58.124531	2017-01-21 17:35:58.124531
16354	2016-06-01 00:00:00	2016-08-31 18:59:59	10303	10031	13	2017-01-21 17:35:58.129308	2017-01-21 17:35:58.129308
16355	2016-09-01 00:00:00	2016-12-31 18:59:59	10303	10030	25	2017-01-21 17:35:58.134786	2017-01-21 17:35:58.134786
16356	2016-09-01 00:00:00	2016-12-31 18:59:59	10303	10031	10	2017-01-21 17:35:58.139339	2017-01-21 17:35:58.139339
16357	2017-01-01 00:00:00	2099-12-31 18:59:59	10303	10030	25	2017-01-21 17:35:58.144713	2017-01-21 17:35:58.144713
16358	2017-01-01 00:00:00	2099-12-31 18:59:59	10303	10031	26	2017-01-21 17:35:58.149443	2017-01-21 17:35:58.149443
16359	2000-01-01 00:00:00	2016-05-31 18:59:59	10304	10030	17	2017-01-21 17:35:58.154623	2017-01-21 17:35:58.154623
16360	2000-01-01 00:00:00	2016-05-31 18:59:59	10304	10031	21	2017-01-21 17:35:58.159246	2017-01-21 17:35:58.159246
16361	2016-06-01 00:00:00	2016-08-31 18:59:59	10304	10030	16	2017-01-21 17:35:58.164558	2017-01-21 17:35:58.164558
16362	2016-06-01 00:00:00	2016-08-31 18:59:59	10304	10031	19	2017-01-21 17:35:58.168912	2017-01-21 17:35:58.168912
16363	2016-09-01 00:00:00	2016-12-31 18:59:59	10304	10030	23	2017-01-21 17:35:58.174539	2017-01-21 17:35:58.174539
16364	2016-09-01 00:00:00	2016-12-31 18:59:59	10304	10031	14	2017-01-21 17:35:58.179197	2017-01-21 17:35:58.179197
16365	2017-01-01 00:00:00	2099-12-31 18:59:59	10304	10030	11	2017-01-21 17:35:58.184485	2017-01-21 17:35:58.184485
16366	2017-01-01 00:00:00	2099-12-31 18:59:59	10304	10031	23	2017-01-21 17:35:58.189223	2017-01-21 17:35:58.189223
16367	2000-01-01 00:00:00	2016-05-31 18:59:59	10305	10030	29	2017-01-21 17:35:58.194458	2017-01-21 17:35:58.194458
16368	2000-01-01 00:00:00	2016-05-31 18:59:59	10305	10031	14	2017-01-21 17:35:58.199074	2017-01-21 17:35:58.199074
16369	2016-06-01 00:00:00	2016-08-31 18:59:59	10305	10030	20	2017-01-21 17:35:58.204746	2017-01-21 17:35:58.204746
16370	2016-06-01 00:00:00	2016-08-31 18:59:59	10305	10031	27	2017-01-21 17:35:58.209391	2017-01-21 17:35:58.209391
16371	2016-09-01 00:00:00	2016-12-31 18:59:59	10305	10030	24	2017-01-21 17:35:58.215085	2017-01-21 17:35:58.215085
16372	2016-09-01 00:00:00	2016-12-31 18:59:59	10305	10031	10	2017-01-21 17:35:58.219978	2017-01-21 17:35:58.219978
16373	2017-01-01 00:00:00	2099-12-31 18:59:59	10305	10030	13	2017-01-21 17:35:58.225579	2017-01-21 17:35:58.225579
16374	2017-01-01 00:00:00	2099-12-31 18:59:59	10305	10031	24	2017-01-21 17:35:58.230345	2017-01-21 17:35:58.230345
16375	2000-01-01 00:00:00	2016-05-31 18:59:59	10306	10030	17	2017-01-21 17:35:58.235757	2017-01-21 17:35:58.235757
16376	2000-01-01 00:00:00	2016-05-31 18:59:59	10306	10031	14	2017-01-21 17:35:58.24036	2017-01-21 17:35:58.24036
16377	2016-06-01 00:00:00	2016-08-31 18:59:59	10306	10030	16	2017-01-21 17:35:58.245555	2017-01-21 17:35:58.245555
16378	2016-06-01 00:00:00	2016-08-31 18:59:59	10306	10031	29	2017-01-21 17:35:58.250244	2017-01-21 17:35:58.250244
16379	2016-09-01 00:00:00	2016-12-31 18:59:59	10306	10030	21	2017-01-21 17:35:58.255561	2017-01-21 17:35:58.255561
16380	2016-09-01 00:00:00	2016-12-31 18:59:59	10306	10031	14	2017-01-21 17:35:58.259991	2017-01-21 17:35:58.259991
16381	2017-01-01 00:00:00	2099-12-31 18:59:59	10306	10030	29	2017-01-21 17:35:58.26565	2017-01-21 17:35:58.26565
16382	2017-01-01 00:00:00	2099-12-31 18:59:59	10306	10031	25	2017-01-21 17:35:58.269679	2017-01-21 17:35:58.269679
16383	2000-01-01 00:00:00	2016-05-31 18:59:59	10307	10030	23	2017-01-21 17:35:58.274231	2017-01-21 17:35:58.274231
16384	2000-01-01 00:00:00	2016-05-31 18:59:59	10307	10031	26	2017-01-21 17:35:58.278253	2017-01-21 17:35:58.278253
16385	2016-06-01 00:00:00	2016-08-31 18:59:59	10307	10030	28	2017-01-21 17:35:58.283471	2017-01-21 17:35:58.283471
16386	2016-06-01 00:00:00	2016-08-31 18:59:59	10307	10031	18	2017-01-21 17:35:58.288172	2017-01-21 17:35:58.288172
16387	2016-09-01 00:00:00	2016-12-31 18:59:59	10307	10030	17	2017-01-21 17:35:58.293659	2017-01-21 17:35:58.293659
16388	2016-09-01 00:00:00	2016-12-31 18:59:59	10307	10031	19	2017-01-21 17:35:58.299063	2017-01-21 17:35:58.299063
16389	2017-01-01 00:00:00	2099-12-31 18:59:59	10307	10030	20	2017-01-21 17:35:58.304478	2017-01-21 17:35:58.304478
16390	2017-01-01 00:00:00	2099-12-31 18:59:59	10307	10031	29	2017-01-21 17:35:58.309149	2017-01-21 17:35:58.309149
16391	2000-01-01 00:00:00	2016-05-31 18:59:59	10308	10030	25	2017-01-21 17:35:58.314508	2017-01-21 17:35:58.314508
16392	2000-01-01 00:00:00	2016-05-31 18:59:59	10308	10031	29	2017-01-21 17:35:58.319168	2017-01-21 17:35:58.319168
16393	2016-06-01 00:00:00	2016-08-31 18:59:59	10308	10030	24	2017-01-21 17:35:58.324549	2017-01-21 17:35:58.324549
16394	2016-06-01 00:00:00	2016-08-31 18:59:59	10308	10031	21	2017-01-21 17:35:58.329308	2017-01-21 17:35:58.329308
16395	2016-09-01 00:00:00	2016-12-31 18:59:59	10308	10030	24	2017-01-21 17:35:58.334714	2017-01-21 17:35:58.334714
16396	2016-09-01 00:00:00	2016-12-31 18:59:59	10308	10031	26	2017-01-21 17:35:58.339303	2017-01-21 17:35:58.339303
16397	2017-01-01 00:00:00	2099-12-31 18:59:59	10308	10030	18	2017-01-21 17:35:58.344543	2017-01-21 17:35:58.344543
16398	2017-01-01 00:00:00	2099-12-31 18:59:59	10308	10031	10	2017-01-21 17:35:58.349165	2017-01-21 17:35:58.349165
16399	2000-01-01 00:00:00	2016-05-31 18:59:59	10309	10030	13	2017-01-21 17:35:58.354428	2017-01-21 17:35:58.354428
16400	2000-01-01 00:00:00	2016-05-31 18:59:59	10309	10031	19	2017-01-21 17:35:58.359019	2017-01-21 17:35:58.359019
16401	2016-06-01 00:00:00	2016-08-31 18:59:59	10309	10030	14	2017-01-21 17:35:58.364165	2017-01-21 17:35:58.364165
16402	2016-06-01 00:00:00	2016-08-31 18:59:59	10309	10031	25	2017-01-21 17:35:58.368467	2017-01-21 17:35:58.368467
16403	2016-09-01 00:00:00	2016-12-31 18:59:59	10309	10030	25	2017-01-21 17:35:58.373603	2017-01-21 17:35:58.373603
16404	2016-09-01 00:00:00	2016-12-31 18:59:59	10309	10031	22	2017-01-21 17:35:58.377727	2017-01-21 17:35:58.377727
16405	2017-01-01 00:00:00	2099-12-31 18:59:59	10309	10030	24	2017-01-21 17:35:58.382595	2017-01-21 17:35:58.382595
16406	2017-01-01 00:00:00	2099-12-31 18:59:59	10309	10031	26	2017-01-21 17:35:58.386966	2017-01-21 17:35:58.386966
16407	2000-01-01 00:00:00	2016-05-31 18:59:59	10310	10030	18	2017-01-21 17:35:58.392229	2017-01-21 17:35:58.392229
16408	2000-01-01 00:00:00	2016-05-31 18:59:59	10310	10031	22	2017-01-21 17:35:58.396564	2017-01-21 17:35:58.396564
16409	2016-06-01 00:00:00	2016-08-31 18:59:59	10310	10030	22	2017-01-21 17:35:58.401836	2017-01-21 17:35:58.401836
16410	2016-06-01 00:00:00	2016-08-31 18:59:59	10310	10031	29	2017-01-21 17:35:58.406403	2017-01-21 17:35:58.406403
16411	2016-09-01 00:00:00	2016-12-31 18:59:59	10310	10030	26	2017-01-21 17:35:58.411902	2017-01-21 17:35:58.411902
16412	2016-09-01 00:00:00	2016-12-31 18:59:59	10310	10031	16	2017-01-21 17:35:58.416856	2017-01-21 17:35:58.416856
16413	2017-01-01 00:00:00	2099-12-31 18:59:59	10310	10030	14	2017-01-21 17:35:58.422313	2017-01-21 17:35:58.422313
16414	2017-01-01 00:00:00	2099-12-31 18:59:59	10310	10031	26	2017-01-21 17:35:58.427101	2017-01-21 17:35:58.427101
16415	2000-01-01 00:00:00	2016-05-31 18:59:59	10311	10030	27	2017-01-21 17:35:58.432381	2017-01-21 17:35:58.432381
16416	2000-01-01 00:00:00	2016-05-31 18:59:59	10311	10031	21	2017-01-21 17:35:58.437031	2017-01-21 17:35:58.437031
16417	2016-06-01 00:00:00	2016-08-31 18:59:59	10311	10030	16	2017-01-21 17:35:58.442474	2017-01-21 17:35:58.442474
16418	2016-06-01 00:00:00	2016-08-31 18:59:59	10311	10031	18	2017-01-21 17:35:58.447227	2017-01-21 17:35:58.447227
16419	2016-09-01 00:00:00	2016-12-31 18:59:59	10311	10030	15	2017-01-21 17:35:58.452647	2017-01-21 17:35:58.452647
16420	2016-09-01 00:00:00	2016-12-31 18:59:59	10311	10031	11	2017-01-21 17:35:58.457227	2017-01-21 17:35:58.457227
16421	2017-01-01 00:00:00	2099-12-31 18:59:59	10311	10030	17	2017-01-21 17:35:58.462718	2017-01-21 17:35:58.462718
16422	2017-01-01 00:00:00	2099-12-31 18:59:59	10311	10031	10	2017-01-21 17:35:58.467669	2017-01-21 17:35:58.467669
16423	2000-01-01 00:00:00	2016-05-31 18:59:59	10312	10030	20	2017-01-21 17:35:58.473312	2017-01-21 17:35:58.473312
16424	2000-01-01 00:00:00	2016-05-31 18:59:59	10312	10031	17	2017-01-21 17:35:58.478064	2017-01-21 17:35:58.478064
16425	2016-06-01 00:00:00	2016-08-31 18:59:59	10312	10030	25	2017-01-21 17:35:58.483684	2017-01-21 17:35:58.483684
16426	2016-06-01 00:00:00	2016-08-31 18:59:59	10312	10031	14	2017-01-21 17:35:58.488351	2017-01-21 17:35:58.488351
16427	2016-09-01 00:00:00	2016-12-31 18:59:59	10312	10030	22	2017-01-21 17:35:58.493613	2017-01-21 17:35:58.493613
16428	2016-09-01 00:00:00	2016-12-31 18:59:59	10312	10031	12	2017-01-21 17:35:58.498276	2017-01-21 17:35:58.498276
16429	2017-01-01 00:00:00	2099-12-31 18:59:59	10312	10030	24	2017-01-21 17:35:58.50349	2017-01-21 17:35:58.50349
16430	2017-01-01 00:00:00	2099-12-31 18:59:59	10312	10031	28	2017-01-21 17:35:58.507962	2017-01-21 17:35:58.507962
16431	2000-01-01 00:00:00	2016-05-31 18:59:59	10313	10030	19	2017-01-21 17:35:58.514122	2017-01-21 17:35:58.514122
16432	2000-01-01 00:00:00	2016-05-31 18:59:59	10313	10031	27	2017-01-21 17:35:58.518954	2017-01-21 17:35:58.518954
16433	2016-06-01 00:00:00	2016-08-31 18:59:59	10313	10030	14	2017-01-21 17:35:58.524353	2017-01-21 17:35:58.524353
16434	2016-06-01 00:00:00	2016-08-31 18:59:59	10313	10031	24	2017-01-21 17:35:58.529032	2017-01-21 17:35:58.529032
16435	2016-09-01 00:00:00	2016-12-31 18:59:59	10313	10030	22	2017-01-21 17:35:58.534506	2017-01-21 17:35:58.534506
16436	2016-09-01 00:00:00	2016-12-31 18:59:59	10313	10031	20	2017-01-21 17:35:58.539251	2017-01-21 17:35:58.539251
16437	2017-01-01 00:00:00	2099-12-31 18:59:59	10313	10030	19	2017-01-21 17:35:58.544724	2017-01-21 17:35:58.544724
16438	2017-01-01 00:00:00	2099-12-31 18:59:59	10313	10031	29	2017-01-21 17:35:58.549761	2017-01-21 17:35:58.549761
16439	2000-01-01 00:00:00	2016-05-31 18:59:59	10314	10030	19	2017-01-21 17:35:58.55502	2017-01-21 17:35:58.55502
16440	2000-01-01 00:00:00	2016-05-31 18:59:59	10314	10031	28	2017-01-21 17:35:58.55983	2017-01-21 17:35:58.55983
16441	2016-06-01 00:00:00	2016-08-31 18:59:59	10314	10030	10	2017-01-21 17:35:58.565478	2017-01-21 17:35:58.565478
16442	2016-06-01 00:00:00	2016-08-31 18:59:59	10314	10031	20	2017-01-21 17:35:58.570126	2017-01-21 17:35:58.570126
16443	2016-09-01 00:00:00	2016-12-31 18:59:59	10314	10030	11	2017-01-21 17:35:58.575662	2017-01-21 17:35:58.575662
16444	2016-09-01 00:00:00	2016-12-31 18:59:59	10314	10031	12	2017-01-21 17:35:58.5806	2017-01-21 17:35:58.5806
16445	2017-01-01 00:00:00	2099-12-31 18:59:59	10314	10030	24	2017-01-21 17:35:58.586013	2017-01-21 17:35:58.586013
16446	2017-01-01 00:00:00	2099-12-31 18:59:59	10314	10031	15	2017-01-21 17:35:58.590879	2017-01-21 17:35:58.590879
16447	2000-01-01 00:00:00	2016-05-31 18:59:59	10315	10030	29	2017-01-21 17:35:58.59651	2017-01-21 17:35:58.59651
16448	2000-01-01 00:00:00	2016-05-31 18:59:59	10315	10031	23	2017-01-21 17:35:58.601603	2017-01-21 17:35:58.601603
16449	2016-06-01 00:00:00	2016-08-31 18:59:59	10315	10030	11	2017-01-21 17:35:58.607115	2017-01-21 17:35:58.607115
16450	2016-06-01 00:00:00	2016-08-31 18:59:59	10315	10031	28	2017-01-21 17:35:58.611863	2017-01-21 17:35:58.611863
16451	2016-09-01 00:00:00	2016-12-31 18:59:59	10315	10030	11	2017-01-21 17:35:58.617269	2017-01-21 17:35:58.617269
16452	2016-09-01 00:00:00	2016-12-31 18:59:59	10315	10031	14	2017-01-21 17:35:58.621286	2017-01-21 17:35:58.621286
16453	2017-01-01 00:00:00	2099-12-31 18:59:59	10315	10030	17	2017-01-21 17:35:58.62588	2017-01-21 17:35:58.62588
16454	2017-01-01 00:00:00	2099-12-31 18:59:59	10315	10031	14	2017-01-21 17:35:58.629917	2017-01-21 17:35:58.629917
16455	2000-01-01 00:00:00	2016-05-31 18:59:59	10316	10030	13	2017-01-21 17:35:58.635446	2017-01-21 17:35:58.635446
16456	2000-01-01 00:00:00	2016-05-31 18:59:59	10316	10031	21	2017-01-21 17:35:58.640142	2017-01-21 17:35:58.640142
16457	2016-06-01 00:00:00	2016-08-31 18:59:59	10316	10030	21	2017-01-21 17:35:58.645369	2017-01-21 17:35:58.645369
16458	2016-06-01 00:00:00	2016-08-31 18:59:59	10316	10031	26	2017-01-21 17:35:58.650048	2017-01-21 17:35:58.650048
16459	2016-09-01 00:00:00	2016-12-31 18:59:59	10316	10030	21	2017-01-21 17:35:58.655434	2017-01-21 17:35:58.655434
16460	2016-09-01 00:00:00	2016-12-31 18:59:59	10316	10031	11	2017-01-21 17:35:58.660102	2017-01-21 17:35:58.660102
16461	2017-01-01 00:00:00	2099-12-31 18:59:59	10316	10030	19	2017-01-21 17:35:58.665453	2017-01-21 17:35:58.665453
16462	2017-01-01 00:00:00	2099-12-31 18:59:59	10316	10031	11	2017-01-21 17:35:58.67012	2017-01-21 17:35:58.67012
16463	2000-01-01 00:00:00	2016-05-31 18:59:59	10317	10030	29	2017-01-21 17:35:58.675365	2017-01-21 17:35:58.675365
16464	2000-01-01 00:00:00	2016-05-31 18:59:59	10317	10031	22	2017-01-21 17:35:58.680117	2017-01-21 17:35:58.680117
16465	2016-06-01 00:00:00	2016-08-31 18:59:59	10317	10030	14	2017-01-21 17:35:58.685579	2017-01-21 17:35:58.685579
16466	2016-06-01 00:00:00	2016-08-31 18:59:59	10317	10031	27	2017-01-21 17:35:58.69028	2017-01-21 17:35:58.69028
16467	2016-09-01 00:00:00	2016-12-31 18:59:59	10317	10030	14	2017-01-21 17:35:58.695484	2017-01-21 17:35:58.695484
16468	2016-09-01 00:00:00	2016-12-31 18:59:59	10317	10031	27	2017-01-21 17:35:58.699978	2017-01-21 17:35:58.699978
16469	2017-01-01 00:00:00	2099-12-31 18:59:59	10317	10030	18	2017-01-21 17:35:58.705048	2017-01-21 17:35:58.705048
16470	2017-01-01 00:00:00	2099-12-31 18:59:59	10317	10031	20	2017-01-21 17:35:58.709797	2017-01-21 17:35:58.709797
16471	2000-01-01 00:00:00	2016-05-31 18:59:59	10318	10030	11	2017-01-21 17:35:58.715077	2017-01-21 17:35:58.715077
16472	2000-01-01 00:00:00	2016-05-31 18:59:59	10318	10031	29	2017-01-21 17:35:58.719476	2017-01-21 17:35:58.719476
16473	2016-06-01 00:00:00	2016-08-31 18:59:59	10318	10030	20	2017-01-21 17:35:58.724745	2017-01-21 17:35:58.724745
16474	2016-06-01 00:00:00	2016-08-31 18:59:59	10318	10031	11	2017-01-21 17:35:58.729707	2017-01-21 17:35:58.729707
16475	2016-09-01 00:00:00	2016-12-31 18:59:59	10318	10030	10	2017-01-21 17:35:58.736094	2017-01-21 17:35:58.736094
16476	2016-09-01 00:00:00	2016-12-31 18:59:59	10318	10031	11	2017-01-21 17:35:58.740943	2017-01-21 17:35:58.740943
16477	2017-01-01 00:00:00	2099-12-31 18:59:59	10318	10030	13	2017-01-21 17:35:58.746549	2017-01-21 17:35:58.746549
16478	2017-01-01 00:00:00	2099-12-31 18:59:59	10318	10031	24	2017-01-21 17:35:58.751239	2017-01-21 17:35:58.751239
16479	2000-01-01 00:00:00	2016-05-31 18:59:59	10319	10030	25	2017-01-21 17:35:58.756458	2017-01-21 17:35:58.756458
16480	2000-01-01 00:00:00	2016-05-31 18:59:59	10319	10031	10	2017-01-21 17:35:58.76106	2017-01-21 17:35:58.76106
16481	2016-06-01 00:00:00	2016-08-31 18:59:59	10319	10030	19	2017-01-21 17:35:58.766599	2017-01-21 17:35:58.766599
16482	2016-06-01 00:00:00	2016-08-31 18:59:59	10319	10031	26	2017-01-21 17:35:58.771152	2017-01-21 17:35:58.771152
16483	2016-09-01 00:00:00	2016-12-31 18:59:59	10319	10030	15	2017-01-21 17:35:58.77665	2017-01-21 17:35:58.77665
16484	2016-09-01 00:00:00	2016-12-31 18:59:59	10319	10031	25	2017-01-21 17:35:58.781268	2017-01-21 17:35:58.781268
16485	2017-01-01 00:00:00	2099-12-31 18:59:59	10319	10030	29	2017-01-21 17:35:58.786813	2017-01-21 17:35:58.786813
16486	2017-01-01 00:00:00	2099-12-31 18:59:59	10319	10031	16	2017-01-21 17:35:58.791739	2017-01-21 17:35:58.791739
16487	2000-01-01 00:00:00	2016-05-31 18:59:59	10320	10030	19	2017-01-21 17:35:58.797719	2017-01-21 17:35:58.797719
16488	2000-01-01 00:00:00	2016-05-31 18:59:59	10320	10031	27	2017-01-21 17:35:58.802572	2017-01-21 17:35:58.802572
16489	2016-06-01 00:00:00	2016-08-31 18:59:59	10320	10030	11	2017-01-21 17:35:58.808087	2017-01-21 17:35:58.808087
16490	2016-06-01 00:00:00	2016-08-31 18:59:59	10320	10031	18	2017-01-21 17:35:58.812876	2017-01-21 17:35:58.812876
16491	2016-09-01 00:00:00	2016-12-31 18:59:59	10320	10030	27	2017-01-21 17:35:58.818811	2017-01-21 17:35:58.818811
16492	2016-09-01 00:00:00	2016-12-31 18:59:59	10320	10031	25	2017-01-21 17:35:58.823769	2017-01-21 17:35:58.823769
16493	2017-01-01 00:00:00	2099-12-31 18:59:59	10320	10030	14	2017-01-21 17:35:58.829314	2017-01-21 17:35:58.829314
16494	2017-01-01 00:00:00	2099-12-31 18:59:59	10320	10031	23	2017-01-21 17:35:58.834093	2017-01-21 17:35:58.834093
16495	2000-01-01 00:00:00	2016-05-31 18:59:59	10321	10030	27	2017-01-21 17:35:58.839387	2017-01-21 17:35:58.839387
16496	2000-01-01 00:00:00	2016-05-31 18:59:59	10321	10031	20	2017-01-21 17:35:58.844042	2017-01-21 17:35:58.844042
16497	2016-06-01 00:00:00	2016-08-31 18:59:59	10321	10030	23	2017-01-21 17:35:58.849331	2017-01-21 17:35:58.849331
16498	2016-06-01 00:00:00	2016-08-31 18:59:59	10321	10031	15	2017-01-21 17:35:58.854054	2017-01-21 17:35:58.854054
16499	2016-09-01 00:00:00	2016-12-31 18:59:59	10321	10030	26	2017-01-21 17:35:58.85967	2017-01-21 17:35:58.85967
16500	2016-09-01 00:00:00	2016-12-31 18:59:59	10321	10031	23	2017-01-21 17:35:58.864405	2017-01-21 17:35:58.864405
16501	2017-01-01 00:00:00	2099-12-31 18:59:59	10321	10030	17	2017-01-21 17:35:58.869277	2017-01-21 17:35:58.869277
16502	2017-01-01 00:00:00	2099-12-31 18:59:59	10321	10031	18	2017-01-21 17:35:58.874021	2017-01-21 17:35:58.874021
16503	2000-01-01 00:00:00	2016-05-31 18:59:59	10322	10030	29	2017-01-21 17:35:58.879635	2017-01-21 17:35:58.879635
16504	2000-01-01 00:00:00	2016-05-31 18:59:59	10322	10031	10	2017-01-21 17:35:58.885157	2017-01-21 17:35:58.885157
16505	2016-06-01 00:00:00	2016-08-31 18:59:59	10322	10030	14	2017-01-21 17:35:58.891037	2017-01-21 17:35:58.891037
16506	2016-06-01 00:00:00	2016-08-31 18:59:59	10322	10031	16	2017-01-21 17:35:58.895943	2017-01-21 17:35:58.895943
16507	2016-09-01 00:00:00	2016-12-31 18:59:59	10322	10030	22	2017-01-21 17:35:58.901427	2017-01-21 17:35:58.901427
16508	2016-09-01 00:00:00	2016-12-31 18:59:59	10322	10031	11	2017-01-21 17:35:58.906117	2017-01-21 17:35:58.906117
16509	2017-01-01 00:00:00	2099-12-31 18:59:59	10322	10030	24	2017-01-21 17:35:58.911582	2017-01-21 17:35:58.911582
16510	2017-01-01 00:00:00	2099-12-31 18:59:59	10322	10031	14	2017-01-21 17:35:58.916306	2017-01-21 17:35:58.916306
16511	2000-01-01 00:00:00	2016-05-31 18:59:59	10323	10030	21	2017-01-21 17:35:58.921581	2017-01-21 17:35:58.921581
16512	2000-01-01 00:00:00	2016-05-31 18:59:59	10323	10031	14	2017-01-21 17:35:58.926258	2017-01-21 17:35:58.926258
16513	2016-06-01 00:00:00	2016-08-31 18:59:59	10323	10030	21	2017-01-21 17:35:58.931591	2017-01-21 17:35:58.931591
16514	2016-06-01 00:00:00	2016-08-31 18:59:59	10323	10031	20	2017-01-21 17:35:58.936238	2017-01-21 17:35:58.936238
16515	2016-09-01 00:00:00	2016-12-31 18:59:59	10323	10030	29	2017-01-21 17:35:58.941264	2017-01-21 17:35:58.941264
16516	2016-09-01 00:00:00	2016-12-31 18:59:59	10323	10031	29	2017-01-21 17:35:58.945585	2017-01-21 17:35:58.945585
16517	2017-01-01 00:00:00	2099-12-31 18:59:59	10323	10030	13	2017-01-21 17:35:58.95092	2017-01-21 17:35:58.95092
16518	2017-01-01 00:00:00	2099-12-31 18:59:59	10323	10031	12	2017-01-21 17:35:58.956108	2017-01-21 17:35:58.956108
16519	2000-01-01 00:00:00	2016-05-31 18:59:59	10324	10030	23	2017-01-21 17:35:58.96167	2017-01-21 17:35:58.96167
16520	2000-01-01 00:00:00	2016-05-31 18:59:59	10324	10031	23	2017-01-21 17:35:58.966313	2017-01-21 17:35:58.966313
16521	2016-06-01 00:00:00	2016-08-31 18:59:59	10324	10030	10	2017-01-21 17:35:58.971749	2017-01-21 17:35:58.971749
16522	2016-06-01 00:00:00	2016-08-31 18:59:59	10324	10031	16	2017-01-21 17:35:58.976605	2017-01-21 17:35:58.976605
16523	2016-09-01 00:00:00	2016-12-31 18:59:59	10324	10030	12	2017-01-21 17:35:58.982145	2017-01-21 17:35:58.982145
16524	2016-09-01 00:00:00	2016-12-31 18:59:59	10324	10031	18	2017-01-21 17:35:58.986329	2017-01-21 17:35:58.986329
16525	2017-01-01 00:00:00	2099-12-31 18:59:59	10324	10030	23	2017-01-21 17:35:58.991032	2017-01-21 17:35:58.991032
16526	2017-01-01 00:00:00	2099-12-31 18:59:59	10324	10031	25	2017-01-21 17:35:58.994901	2017-01-21 17:35:58.994901
16527	2000-01-01 00:00:00	2016-05-31 18:59:59	10325	10030	18	2017-01-21 17:35:59.00006	2017-01-21 17:35:59.00006
16528	2000-01-01 00:00:00	2016-05-31 18:59:59	10325	10031	23	2017-01-21 17:35:59.004758	2017-01-21 17:35:59.004758
16529	2016-06-01 00:00:00	2016-08-31 18:59:59	10325	10030	16	2017-01-21 17:35:59.010378	2017-01-21 17:35:59.010378
16530	2016-06-01 00:00:00	2016-08-31 18:59:59	10325	10031	15	2017-01-21 17:35:59.015202	2017-01-21 17:35:59.015202
16531	2016-09-01 00:00:00	2016-12-31 18:59:59	10325	10030	25	2017-01-21 17:35:59.020443	2017-01-21 17:35:59.020443
16532	2016-09-01 00:00:00	2016-12-31 18:59:59	10325	10031	16	2017-01-21 17:35:59.025091	2017-01-21 17:35:59.025091
16533	2017-01-01 00:00:00	2099-12-31 18:59:59	10325	10030	22	2017-01-21 17:35:59.030636	2017-01-21 17:35:59.030636
16534	2017-01-01 00:00:00	2099-12-31 18:59:59	10325	10031	16	2017-01-21 17:35:59.035817	2017-01-21 17:35:59.035817
16535	2000-01-01 00:00:00	2016-05-31 18:59:59	10326	10030	20	2017-01-21 17:35:59.041237	2017-01-21 17:35:59.041237
16536	2000-01-01 00:00:00	2016-05-31 18:59:59	10326	10031	12	2017-01-21 17:35:59.046096	2017-01-21 17:35:59.046096
16537	2016-06-01 00:00:00	2016-08-31 18:59:59	10326	10030	17	2017-01-21 17:35:59.053308	2017-01-21 17:35:59.053308
16538	2016-06-01 00:00:00	2016-08-31 18:59:59	10326	10031	28	2017-01-21 17:35:59.059123	2017-01-21 17:35:59.059123
16539	2016-09-01 00:00:00	2016-12-31 18:59:59	10326	10030	19	2017-01-21 17:35:59.065276	2017-01-21 17:35:59.065276
16540	2016-09-01 00:00:00	2016-12-31 18:59:59	10326	10031	22	2017-01-21 17:35:59.070363	2017-01-21 17:35:59.070363
16541	2017-01-01 00:00:00	2099-12-31 18:59:59	10326	10030	21	2017-01-21 17:35:59.075113	2017-01-21 17:35:59.075113
16542	2017-01-01 00:00:00	2099-12-31 18:59:59	10326	10031	23	2017-01-21 17:35:59.079741	2017-01-21 17:35:59.079741
16543	2000-01-01 00:00:00	2016-05-31 18:59:59	10327	10030	19	2017-01-21 17:35:59.084827	2017-01-21 17:35:59.084827
16544	2000-01-01 00:00:00	2016-05-31 18:59:59	10327	10031	23	2017-01-21 17:35:59.089474	2017-01-21 17:35:59.089474
16545	2016-06-01 00:00:00	2016-08-31 18:59:59	10327	10030	25	2017-01-21 17:35:59.094686	2017-01-21 17:35:59.094686
16546	2016-06-01 00:00:00	2016-08-31 18:59:59	10327	10031	23	2017-01-21 17:35:59.099643	2017-01-21 17:35:59.099643
16547	2016-09-01 00:00:00	2016-12-31 18:59:59	10327	10030	11	2017-01-21 17:35:59.105364	2017-01-21 17:35:59.105364
16548	2016-09-01 00:00:00	2016-12-31 18:59:59	10327	10031	11	2017-01-21 17:35:59.110207	2017-01-21 17:35:59.110207
16549	2017-01-01 00:00:00	2099-12-31 18:59:59	10327	10030	21	2017-01-21 17:35:59.115641	2017-01-21 17:35:59.115641
16550	2017-01-01 00:00:00	2099-12-31 18:59:59	10327	10031	18	2017-01-21 17:35:59.120269	2017-01-21 17:35:59.120269
16551	2000-01-01 00:00:00	2016-05-31 18:59:59	10328	10030	13	2017-01-21 17:35:59.125825	2017-01-21 17:35:59.125825
16552	2000-01-01 00:00:00	2016-05-31 18:59:59	10328	10031	27	2017-01-21 17:35:59.130656	2017-01-21 17:35:59.130656
16553	2016-06-01 00:00:00	2016-08-31 18:59:59	10328	10030	23	2017-01-21 17:35:59.136179	2017-01-21 17:35:59.136179
16554	2016-06-01 00:00:00	2016-08-31 18:59:59	10328	10031	12	2017-01-21 17:35:59.140958	2017-01-21 17:35:59.140958
16555	2016-09-01 00:00:00	2016-12-31 18:59:59	10328	10030	28	2017-01-21 17:35:59.146593	2017-01-21 17:35:59.146593
16556	2016-09-01 00:00:00	2016-12-31 18:59:59	10328	10031	17	2017-01-21 17:35:59.15153	2017-01-21 17:35:59.15153
16557	2017-01-01 00:00:00	2099-12-31 18:59:59	10328	10030	16	2017-01-21 17:35:59.157089	2017-01-21 17:35:59.157089
16558	2017-01-01 00:00:00	2099-12-31 18:59:59	10328	10031	19	2017-01-21 17:35:59.161899	2017-01-21 17:35:59.161899
16559	2000-01-01 00:00:00	2016-05-31 18:59:59	10329	10030	28	2017-01-21 17:35:59.167274	2017-01-21 17:35:59.167274
16560	2000-01-01 00:00:00	2016-05-31 18:59:59	10329	10031	23	2017-01-21 17:35:59.172035	2017-01-21 17:35:59.172035
16561	2016-06-01 00:00:00	2016-08-31 18:59:59	10329	10030	10	2017-01-21 17:35:59.178411	2017-01-21 17:35:59.178411
16562	2016-06-01 00:00:00	2016-08-31 18:59:59	10329	10031	26	2017-01-21 17:35:59.183185	2017-01-21 17:35:59.183185
16563	2016-09-01 00:00:00	2016-12-31 18:59:59	10329	10030	23	2017-01-21 17:35:59.188415	2017-01-21 17:35:59.188415
16564	2016-09-01 00:00:00	2016-12-31 18:59:59	10329	10031	10	2017-01-21 17:35:59.19307	2017-01-21 17:35:59.19307
16565	2017-01-01 00:00:00	2099-12-31 18:59:59	10329	10030	11	2017-01-21 17:35:59.198591	2017-01-21 17:35:59.198591
16566	2017-01-01 00:00:00	2099-12-31 18:59:59	10329	10031	28	2017-01-21 17:35:59.203267	2017-01-21 17:35:59.203267
16567	2000-01-01 00:00:00	2016-05-31 18:59:59	10330	10030	29	2017-01-21 17:35:59.208592	2017-01-21 17:35:59.208592
16568	2000-01-01 00:00:00	2016-05-31 18:59:59	10330	10031	19	2017-01-21 17:35:59.213301	2017-01-21 17:35:59.213301
16569	2016-06-01 00:00:00	2016-08-31 18:59:59	10330	10030	16	2017-01-21 17:35:59.218561	2017-01-21 17:35:59.218561
16570	2016-06-01 00:00:00	2016-08-31 18:59:59	10330	10031	18	2017-01-21 17:35:59.223199	2017-01-21 17:35:59.223199
16571	2016-09-01 00:00:00	2016-12-31 18:59:59	10330	10030	21	2017-01-21 17:35:59.228526	2017-01-21 17:35:59.228526
16572	2016-09-01 00:00:00	2016-12-31 18:59:59	10330	10031	28	2017-01-21 17:35:59.233121	2017-01-21 17:35:59.233121
16573	2017-01-01 00:00:00	2099-12-31 18:59:59	10330	10030	10	2017-01-21 17:35:59.238726	2017-01-21 17:35:59.238726
16574	2017-01-01 00:00:00	2099-12-31 18:59:59	10330	10031	18	2017-01-21 17:35:59.243296	2017-01-21 17:35:59.243296
\.


--
-- Data for Name: t_prices_specials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices_specials (id, price_spec_code, price_spec_dscr, price_spec_sum_flag, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: t_prices_specials_conditions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY t_prices_specials_conditions (id, beg_date_order, end_date_order, pediod_beg_date, pediod_end_date, bike_model_id, customer_group_id, bike_count, period_order_in_hour, val_id, prct_flag, price_specials_value, created_at, updated_at) FROM stdin;
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
-- Name: dict_booking_states PK_booking_state_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_booking_states
    ADD CONSTRAINT "PK_booking_state_id" PRIMARY KEY (booking_state_id);


--
-- Name: dict_currencies PK_currencies_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_currencies
    ADD CONSTRAINT "PK_currencies_id" PRIMARY KEY (val_id);


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
-- Name: t_bikes PK_t_bikes_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes
    ADD CONSTRAINT "PK_t_bikes_id" PRIMARY KEY (bike_id);


--
-- Name: dict_currencies UNIQ_val_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_currencies
    ADD CONSTRAINT "UNIQ_val_code" UNIQUE (val_code);


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
-- Name: PK_idx_booking_state_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_booking_state_id" ON dict_booking_states USING btree (booking_state_id);


--
-- Name: PK_idx_currencies_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_currencies_id" ON dict_currencies USING btree (val_id);


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
-- Name: PK_idx_t_bikes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_t_bikes_id" ON t_bikes USING btree (bike_id);


--
-- Name: UNIQ_booking_state_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UNIQ_booking_state_code" ON dict_booking_states USING btree (booking_state_code);


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
-- PostgreSQL database dump complete
--


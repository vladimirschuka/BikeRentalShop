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
    brand_code character varying(100) NOT NULL,
    brand_name character varying(100) NOT NULL,
    brand_dscr character varying(4000) NOT NULL,
    brand_prof_flag boolean DEFAULT false,
    brand_country character varying(100),
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
    bike_model_code character varying(100) NOT NULL,
    bike_model_name character varying(100) NOT NULL,
    bike_model_brand_id integer NOT NULL,
    bike_model_type_id integer NOT NULL,
    bike_model_color_id integer NOT NULL,
    bike_model_speed_count integer NOT NULL,
    bike_model_wheel_size_inch double precision NOT NULL,
    bike_model_weight_kg double precision NOT NULL,
    bike_model_year integer NOT NULL,
    bike_model_folding_flag boolean DEFAULT false NOT NULL,
    bike_model_prof_flag boolean DEFAULT false NOT NULL,
    bike_model_current_state_id integer,
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
    bike_type_code character varying(100),
    bike_type_name character varying(100),
    created_at timestamp without time zone DEFAULT '2017-01-07 01:34:25.79555'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '2017-01-07 01:34:25.79555'::timestamp without time zone NOT NULL
);


ALTER TABLE dict_bike_types OWNER TO postgres;

--
-- Name: dict_vals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dict_vals (
    val_id integer DEFAULT nextval('main_sequence'::regclass),
    val_code character varying(100),
    val_name character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE dict_vals OWNER TO postgres;

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
    id integer DEFAULT nextval('main_sequence'::regclass),
    bike_id integer,
    bike_state_id integer,
    bike_state_date timestamp without time zone
);


ALTER TABLE t_bikes_states OWNER TO postgres;

--
-- Name: t_customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE t_customers (
    customer_id integer DEFAULT nextval('main_sequence'::regclass),
    customer_login character varying(100),
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
    customer_group_dscr character varying,
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
    order_code character varying(100),
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
    t1.bike_model_current_state_id,
    t4.bike_state_code,
    t4.bike_state_name,
    t1.created_at,
    t1.updated_at
   FROM dict_bike_models t1,
    dict_bike_brands t2,
    dict_bike_colors t3,
    dict_bike_states t4,
    dict_bike_types t5
  WHERE ((t1.bike_model_brand_id = t2.brand_id) AND (t1.bike_model_type_id = t5.bike_type_id) AND (t1.bike_model_color_id = t3.bike_color_id) AND (t1.bike_model_current_state_id = t4.bike_state_id));


ALTER TABLE v_bike_models OWNER TO postgres;

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

COPY dict_bike_models (bike_model_id, bike_model_code, bike_model_name, bike_model_brand_id, bike_model_type_id, bike_model_color_id, bike_model_speed_count, bike_model_wheel_size_inch, bike_model_weight_kg, bike_model_year, bike_model_folding_flag, bike_model_prof_flag, bike_model_current_state_id, created_at, updated_at) FROM stdin;
10019	Abc1	Giant mountains S1 (men)	10002	10005	10009	18	27	15	2015	f	t	10014	2017-01-07 14:41:45.30469	2017-01-07 23:24:33.937842
10021	Abc2	Giant mountains S1 (men)	10002	10005	10009	18	26	15	2015	f	t	10014	2017-01-07 14:41:45.30469	2017-01-07 14:41:45.30469
10022	Abc3	Giant mountains S1 (men)	10002	10005	10010	18	26	15	2016	f	t	10014	2017-01-08 02:13:22.870837	2017-01-08 02:15:22.056785
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
-- Data for Name: dict_vals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_vals (val_id, val_code, val_name, created_at, updated_at) FROM stdin;
10030	eur	EUR	2017-01-09 20:22:41.439588	2017-01-09 20:22:41.439588
10031	chf	CHF	2017-01-09 20:22:41.447907	2017-01-09 20:22:41.447907
\.


--
-- Name: main_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('main_sequence', 10066, true);


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

COPY t_prices_base_plans (id, bike_model_id, val_id, price, created_at, updated_at) FROM stdin;
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
-- Name: t_bikes PK_t_bikes_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes
    ADD CONSTRAINT "PK_t_bikes_id" PRIMARY KEY (bike_id);


--
-- Name: FKI_bike_model_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_bike_model_id" ON t_bikes USING btree (bike_model_id);


--
-- Name: FKI_model_brand_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_model_brand_id" ON dict_bike_models USING btree (bike_model_brand_id);


--
-- Name: FKI_model_color_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_model_color_id" ON dict_bike_models USING btree (bike_model_color_id);


--
-- Name: FKI_model_current_state_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_model_current_state_id" ON dict_bike_models USING btree (bike_model_current_state_id);


--
-- Name: FKI_model_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_model_type_id" ON dict_bike_models USING btree (bike_model_type_id);


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
-- Name: PK_idx_t_bikes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_t_bikes_id" ON t_bikes USING btree (bike_id);


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
-- Name: t_bikes FK_bike_model_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY t_bikes
    ADD CONSTRAINT "FK_bike_model_id" FOREIGN KEY (bike_model_id) REFERENCES dict_bike_models(bike_model_id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: dict_bike_models FK_model_current_state_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_models
    ADD CONSTRAINT "FK_model_current_state_id" FOREIGN KEY (bike_model_current_state_id) REFERENCES dict_bike_states(bike_state_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: dict_bike_models FK_model_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_models
    ADD CONSTRAINT "FK_model_type_id" FOREIGN KEY (bike_model_type_id) REFERENCES dict_bike_types(bike_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


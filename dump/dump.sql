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
-- Data for Name: dict_vals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dict_vals (val_id, val_code, val_name, created_at, updated_at) FROM stdin;
10030	eur	EUR	2017-01-09 20:22:41.439588	2017-01-09 20:22:41.439588
10031	chf	CHF	2017-01-09 20:22:41.447907	2017-01-09 20:22:41.447907
\.


--
-- Name: main_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('main_sequence', 13210, true);


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

COPY t_prices_base_plans (id, beg_date, end_date, bike_model_id, val_id, price, created_at, updated_at) FROM stdin;
12251	2000-01-01 00:00:00	2016-06-01 00:00:00	10211	10030	16	2017-01-18 17:14:45.413606	2017-01-18 17:14:45.413606
12252	2000-01-01 00:00:00	2016-06-01 00:00:00	10211	10031	21	2017-01-18 17:14:45.420002	2017-01-18 17:14:45.420002
12253	2016-06-01 00:00:00	2016-09-01 00:00:00	10211	10030	20	2017-01-18 17:14:45.425327	2017-01-18 17:14:45.425327
12254	2016-06-01 00:00:00	2016-09-01 00:00:00	10211	10031	19	2017-01-18 17:14:45.429755	2017-01-18 17:14:45.429755
12255	2016-09-01 00:00:00	2017-01-01 00:00:00	10211	10030	26	2017-01-18 17:14:45.434875	2017-01-18 17:14:45.434875
12256	2016-09-01 00:00:00	2017-01-01 00:00:00	10211	10031	18	2017-01-18 17:14:45.439521	2017-01-18 17:14:45.439521
12257	2017-01-01 00:00:00	2100-01-01 00:00:00	10211	10030	13	2017-01-18 17:14:45.444732	2017-01-18 17:14:45.444732
12258	2017-01-01 00:00:00	2100-01-01 00:00:00	10211	10031	29	2017-01-18 17:14:45.449529	2017-01-18 17:14:45.449529
12259	2000-01-01 00:00:00	2016-06-01 00:00:00	10212	10030	28	2017-01-18 17:14:45.45664	2017-01-18 17:14:45.45664
12260	2000-01-01 00:00:00	2016-06-01 00:00:00	10212	10031	13	2017-01-18 17:14:45.460511	2017-01-18 17:14:45.460511
12261	2016-06-01 00:00:00	2016-09-01 00:00:00	10212	10030	10	2017-01-18 17:14:45.465386	2017-01-18 17:14:45.465386
12262	2016-06-01 00:00:00	2016-09-01 00:00:00	10212	10031	21	2017-01-18 17:14:45.470957	2017-01-18 17:14:45.470957
12263	2016-09-01 00:00:00	2017-01-01 00:00:00	10212	10030	27	2017-01-18 17:14:45.476766	2017-01-18 17:14:45.476766
12264	2016-09-01 00:00:00	2017-01-01 00:00:00	10212	10031	29	2017-01-18 17:14:45.481601	2017-01-18 17:14:45.481601
12265	2017-01-01 00:00:00	2100-01-01 00:00:00	10212	10030	20	2017-01-18 17:14:45.486794	2017-01-18 17:14:45.486794
12266	2017-01-01 00:00:00	2100-01-01 00:00:00	10212	10031	26	2017-01-18 17:14:45.491705	2017-01-18 17:14:45.491705
12267	2000-01-01 00:00:00	2016-06-01 00:00:00	10213	10030	12	2017-01-18 17:14:45.497546	2017-01-18 17:14:45.497546
12268	2000-01-01 00:00:00	2016-06-01 00:00:00	10213	10031	26	2017-01-18 17:14:45.50224	2017-01-18 17:14:45.50224
12269	2016-06-01 00:00:00	2016-09-01 00:00:00	10213	10030	11	2017-01-18 17:14:45.50759	2017-01-18 17:14:45.50759
12270	2016-06-01 00:00:00	2016-09-01 00:00:00	10213	10031	18	2017-01-18 17:14:45.512502	2017-01-18 17:14:45.512502
12271	2016-09-01 00:00:00	2017-01-01 00:00:00	10213	10030	27	2017-01-18 17:14:45.518035	2017-01-18 17:14:45.518035
12272	2016-09-01 00:00:00	2017-01-01 00:00:00	10213	10031	17	2017-01-18 17:14:45.52345	2017-01-18 17:14:45.52345
12273	2017-01-01 00:00:00	2100-01-01 00:00:00	10213	10030	29	2017-01-18 17:14:45.528846	2017-01-18 17:14:45.528846
12274	2017-01-01 00:00:00	2100-01-01 00:00:00	10213	10031	10	2017-01-18 17:14:45.533368	2017-01-18 17:14:45.533368
12275	2000-01-01 00:00:00	2016-06-01 00:00:00	10214	10030	25	2017-01-18 17:14:45.538519	2017-01-18 17:14:45.538519
12276	2000-01-01 00:00:00	2016-06-01 00:00:00	10214	10031	21	2017-01-18 17:14:45.542979	2017-01-18 17:14:45.542979
12277	2016-06-01 00:00:00	2016-09-01 00:00:00	10214	10030	17	2017-01-18 17:14:45.548133	2017-01-18 17:14:45.548133
12278	2016-06-01 00:00:00	2016-09-01 00:00:00	10214	10031	23	2017-01-18 17:14:45.552706	2017-01-18 17:14:45.552706
12279	2016-09-01 00:00:00	2017-01-01 00:00:00	10214	10030	17	2017-01-18 17:14:45.557718	2017-01-18 17:14:45.557718
12280	2016-09-01 00:00:00	2017-01-01 00:00:00	10214	10031	23	2017-01-18 17:14:45.56206	2017-01-18 17:14:45.56206
12281	2017-01-01 00:00:00	2100-01-01 00:00:00	10214	10030	16	2017-01-18 17:14:45.56731	2017-01-18 17:14:45.56731
12282	2017-01-01 00:00:00	2100-01-01 00:00:00	10214	10031	26	2017-01-18 17:14:45.572132	2017-01-18 17:14:45.572132
12283	2000-01-01 00:00:00	2016-06-01 00:00:00	10215	10030	21	2017-01-18 17:14:45.577172	2017-01-18 17:14:45.577172
12284	2000-01-01 00:00:00	2016-06-01 00:00:00	10215	10031	27	2017-01-18 17:14:45.581397	2017-01-18 17:14:45.581397
12285	2016-06-01 00:00:00	2016-09-01 00:00:00	10215	10030	26	2017-01-18 17:14:45.586593	2017-01-18 17:14:45.586593
12286	2016-06-01 00:00:00	2016-09-01 00:00:00	10215	10031	23	2017-01-18 17:14:45.591223	2017-01-18 17:14:45.591223
12287	2016-09-01 00:00:00	2017-01-01 00:00:00	10215	10030	12	2017-01-18 17:14:45.596476	2017-01-18 17:14:45.596476
12288	2016-09-01 00:00:00	2017-01-01 00:00:00	10215	10031	13	2017-01-18 17:14:45.60116	2017-01-18 17:14:45.60116
12289	2017-01-01 00:00:00	2100-01-01 00:00:00	10215	10030	29	2017-01-18 17:14:45.606215	2017-01-18 17:14:45.606215
12290	2017-01-01 00:00:00	2100-01-01 00:00:00	10215	10031	21	2017-01-18 17:14:45.610578	2017-01-18 17:14:45.610578
12291	2000-01-01 00:00:00	2016-06-01 00:00:00	10216	10030	27	2017-01-18 17:14:45.615523	2017-01-18 17:14:45.615523
12292	2000-01-01 00:00:00	2016-06-01 00:00:00	10216	10031	13	2017-01-18 17:14:45.619804	2017-01-18 17:14:45.619804
12293	2016-06-01 00:00:00	2016-09-01 00:00:00	10216	10030	21	2017-01-18 17:14:45.624844	2017-01-18 17:14:45.624844
12294	2016-06-01 00:00:00	2016-09-01 00:00:00	10216	10031	28	2017-01-18 17:14:45.629822	2017-01-18 17:14:45.629822
12295	2016-09-01 00:00:00	2017-01-01 00:00:00	10216	10030	24	2017-01-18 17:14:45.635549	2017-01-18 17:14:45.635549
12296	2016-09-01 00:00:00	2017-01-01 00:00:00	10216	10031	27	2017-01-18 17:14:45.639973	2017-01-18 17:14:45.639973
12297	2017-01-01 00:00:00	2100-01-01 00:00:00	10216	10030	28	2017-01-18 17:14:45.645534	2017-01-18 17:14:45.645534
12298	2017-01-01 00:00:00	2100-01-01 00:00:00	10216	10031	18	2017-01-18 17:14:45.650246	2017-01-18 17:14:45.650246
12299	2000-01-01 00:00:00	2016-06-01 00:00:00	10217	10030	28	2017-01-18 17:14:45.655623	2017-01-18 17:14:45.655623
12300	2000-01-01 00:00:00	2016-06-01 00:00:00	10217	10031	23	2017-01-18 17:14:45.660117	2017-01-18 17:14:45.660117
12301	2016-06-01 00:00:00	2016-09-01 00:00:00	10217	10030	13	2017-01-18 17:14:45.665392	2017-01-18 17:14:45.665392
12302	2016-06-01 00:00:00	2016-09-01 00:00:00	10217	10031	24	2017-01-18 17:14:45.670054	2017-01-18 17:14:45.670054
12303	2016-09-01 00:00:00	2017-01-01 00:00:00	10217	10030	20	2017-01-18 17:14:45.675462	2017-01-18 17:14:45.675462
12304	2016-09-01 00:00:00	2017-01-01 00:00:00	10217	10031	15	2017-01-18 17:14:45.680115	2017-01-18 17:14:45.680115
12305	2017-01-01 00:00:00	2100-01-01 00:00:00	10217	10030	28	2017-01-18 17:14:45.685335	2017-01-18 17:14:45.685335
12306	2017-01-01 00:00:00	2100-01-01 00:00:00	10217	10031	18	2017-01-18 17:14:45.689859	2017-01-18 17:14:45.689859
12307	2000-01-01 00:00:00	2016-06-01 00:00:00	10218	10030	16	2017-01-18 17:14:45.695062	2017-01-18 17:14:45.695062
12308	2000-01-01 00:00:00	2016-06-01 00:00:00	10218	10031	16	2017-01-18 17:14:45.699902	2017-01-18 17:14:45.699902
12309	2016-06-01 00:00:00	2016-09-01 00:00:00	10218	10030	11	2017-01-18 17:14:45.705391	2017-01-18 17:14:45.705391
12310	2016-06-01 00:00:00	2016-09-01 00:00:00	10218	10031	21	2017-01-18 17:14:45.709888	2017-01-18 17:14:45.709888
12311	2016-09-01 00:00:00	2017-01-01 00:00:00	10218	10030	22	2017-01-18 17:14:45.714965	2017-01-18 17:14:45.714965
12312	2016-09-01 00:00:00	2017-01-01 00:00:00	10218	10031	12	2017-01-18 17:14:45.719429	2017-01-18 17:14:45.719429
12313	2017-01-01 00:00:00	2100-01-01 00:00:00	10218	10030	18	2017-01-18 17:14:45.724685	2017-01-18 17:14:45.724685
12314	2017-01-01 00:00:00	2100-01-01 00:00:00	10218	10031	13	2017-01-18 17:14:45.729176	2017-01-18 17:14:45.729176
12315	2000-01-01 00:00:00	2016-06-01 00:00:00	10219	10030	13	2017-01-18 17:14:45.735284	2017-01-18 17:14:45.735284
12316	2000-01-01 00:00:00	2016-06-01 00:00:00	10219	10031	15	2017-01-18 17:14:45.739941	2017-01-18 17:14:45.739941
12317	2016-06-01 00:00:00	2016-09-01 00:00:00	10219	10030	23	2017-01-18 17:14:45.745468	2017-01-18 17:14:45.745468
12318	2016-06-01 00:00:00	2016-09-01 00:00:00	10219	10031	21	2017-01-18 17:14:45.750285	2017-01-18 17:14:45.750285
12319	2016-09-01 00:00:00	2017-01-01 00:00:00	10219	10030	12	2017-01-18 17:14:45.755711	2017-01-18 17:14:45.755711
12320	2016-09-01 00:00:00	2017-01-01 00:00:00	10219	10031	25	2017-01-18 17:14:45.760779	2017-01-18 17:14:45.760779
12321	2017-01-01 00:00:00	2100-01-01 00:00:00	10219	10030	17	2017-01-18 17:14:45.766004	2017-01-18 17:14:45.766004
12322	2017-01-01 00:00:00	2100-01-01 00:00:00	10219	10031	18	2017-01-18 17:14:45.770753	2017-01-18 17:14:45.770753
12323	2000-01-01 00:00:00	2016-06-01 00:00:00	10220	10030	17	2017-01-18 17:14:45.776013	2017-01-18 17:14:45.776013
12324	2000-01-01 00:00:00	2016-06-01 00:00:00	10220	10031	17	2017-01-18 17:14:45.780888	2017-01-18 17:14:45.780888
12325	2016-06-01 00:00:00	2016-09-01 00:00:00	10220	10030	12	2017-01-18 17:14:45.786459	2017-01-18 17:14:45.786459
12326	2016-06-01 00:00:00	2016-09-01 00:00:00	10220	10031	27	2017-01-18 17:14:45.790891	2017-01-18 17:14:45.790891
12327	2016-09-01 00:00:00	2017-01-01 00:00:00	10220	10030	24	2017-01-18 17:14:45.795912	2017-01-18 17:14:45.795912
12328	2016-09-01 00:00:00	2017-01-01 00:00:00	10220	10031	13	2017-01-18 17:14:45.80064	2017-01-18 17:14:45.80064
12329	2017-01-01 00:00:00	2100-01-01 00:00:00	10220	10030	23	2017-01-18 17:14:45.805833	2017-01-18 17:14:45.805833
12330	2017-01-01 00:00:00	2100-01-01 00:00:00	10220	10031	11	2017-01-18 17:14:45.810372	2017-01-18 17:14:45.810372
12331	2000-01-01 00:00:00	2016-06-01 00:00:00	10221	10030	20	2017-01-18 17:14:45.815486	2017-01-18 17:14:45.815486
12332	2000-01-01 00:00:00	2016-06-01 00:00:00	10221	10031	23	2017-01-18 17:14:45.820689	2017-01-18 17:14:45.820689
12333	2016-06-01 00:00:00	2016-09-01 00:00:00	10221	10030	15	2017-01-18 17:14:45.826247	2017-01-18 17:14:45.826247
12334	2016-06-01 00:00:00	2016-09-01 00:00:00	10221	10031	11	2017-01-18 17:14:45.830869	2017-01-18 17:14:45.830869
12335	2016-09-01 00:00:00	2017-01-01 00:00:00	10221	10030	10	2017-01-18 17:14:45.83608	2017-01-18 17:14:45.83608
12336	2016-09-01 00:00:00	2017-01-01 00:00:00	10221	10031	28	2017-01-18 17:14:45.840654	2017-01-18 17:14:45.840654
12337	2017-01-01 00:00:00	2100-01-01 00:00:00	10221	10030	23	2017-01-18 17:14:45.84648	2017-01-18 17:14:45.84648
12338	2017-01-01 00:00:00	2100-01-01 00:00:00	10221	10031	18	2017-01-18 17:14:45.856904	2017-01-18 17:14:45.856904
12339	2000-01-01 00:00:00	2016-06-01 00:00:00	10222	10030	26	2017-01-18 17:14:45.86974	2017-01-18 17:14:45.86974
12340	2000-01-01 00:00:00	2016-06-01 00:00:00	10222	10031	22	2017-01-18 17:14:45.876422	2017-01-18 17:14:45.876422
12341	2016-06-01 00:00:00	2016-09-01 00:00:00	10222	10030	27	2017-01-18 17:14:45.884415	2017-01-18 17:14:45.884415
12342	2016-06-01 00:00:00	2016-09-01 00:00:00	10222	10031	19	2017-01-18 17:14:45.891161	2017-01-18 17:14:45.891161
12343	2016-09-01 00:00:00	2017-01-01 00:00:00	10222	10030	12	2017-01-18 17:14:45.898827	2017-01-18 17:14:45.898827
12344	2016-09-01 00:00:00	2017-01-01 00:00:00	10222	10031	19	2017-01-18 17:14:45.905704	2017-01-18 17:14:45.905704
12345	2017-01-01 00:00:00	2100-01-01 00:00:00	10222	10030	17	2017-01-18 17:14:45.913566	2017-01-18 17:14:45.913566
12346	2017-01-01 00:00:00	2100-01-01 00:00:00	10222	10031	21	2017-01-18 17:14:45.920488	2017-01-18 17:14:45.920488
12347	2000-01-01 00:00:00	2016-06-01 00:00:00	10223	10030	28	2017-01-18 17:14:45.928552	2017-01-18 17:14:45.928552
12348	2000-01-01 00:00:00	2016-06-01 00:00:00	10223	10031	23	2017-01-18 17:14:45.935198	2017-01-18 17:14:45.935198
12349	2016-06-01 00:00:00	2016-09-01 00:00:00	10223	10030	17	2017-01-18 17:14:45.943037	2017-01-18 17:14:45.943037
12350	2016-06-01 00:00:00	2016-09-01 00:00:00	10223	10031	23	2017-01-18 17:14:45.949924	2017-01-18 17:14:45.949924
12351	2016-09-01 00:00:00	2017-01-01 00:00:00	10223	10030	11	2017-01-18 17:14:45.958317	2017-01-18 17:14:45.958317
12352	2016-09-01 00:00:00	2017-01-01 00:00:00	10223	10031	26	2017-01-18 17:14:45.965139	2017-01-18 17:14:45.965139
12353	2017-01-01 00:00:00	2100-01-01 00:00:00	10223	10030	15	2017-01-18 17:14:45.972966	2017-01-18 17:14:45.972966
12354	2017-01-01 00:00:00	2100-01-01 00:00:00	10223	10031	28	2017-01-18 17:14:45.979735	2017-01-18 17:14:45.979735
12355	2000-01-01 00:00:00	2016-06-01 00:00:00	10224	10030	22	2017-01-18 17:14:45.9875	2017-01-18 17:14:45.9875
12356	2000-01-01 00:00:00	2016-06-01 00:00:00	10224	10031	24	2017-01-18 17:14:45.994829	2017-01-18 17:14:45.994829
12357	2016-06-01 00:00:00	2016-09-01 00:00:00	10224	10030	11	2017-01-18 17:14:46.001877	2017-01-18 17:14:46.001877
12358	2016-06-01 00:00:00	2016-09-01 00:00:00	10224	10031	17	2017-01-18 17:14:46.007592	2017-01-18 17:14:46.007592
12359	2016-09-01 00:00:00	2017-01-01 00:00:00	10224	10030	21	2017-01-18 17:14:46.012845	2017-01-18 17:14:46.012845
12360	2016-09-01 00:00:00	2017-01-01 00:00:00	10224	10031	15	2017-01-18 17:14:46.017584	2017-01-18 17:14:46.017584
12361	2017-01-01 00:00:00	2100-01-01 00:00:00	10224	10030	15	2017-01-18 17:14:46.023093	2017-01-18 17:14:46.023093
12362	2017-01-01 00:00:00	2100-01-01 00:00:00	10224	10031	22	2017-01-18 17:14:46.027671	2017-01-18 17:14:46.027671
12363	2000-01-01 00:00:00	2016-06-01 00:00:00	10225	10030	10	2017-01-18 17:14:46.032805	2017-01-18 17:14:46.032805
12364	2000-01-01 00:00:00	2016-06-01 00:00:00	10225	10031	21	2017-01-18 17:14:46.037672	2017-01-18 17:14:46.037672
12365	2016-06-01 00:00:00	2016-09-01 00:00:00	10225	10030	26	2017-01-18 17:14:46.042908	2017-01-18 17:14:46.042908
12366	2016-06-01 00:00:00	2016-09-01 00:00:00	10225	10031	21	2017-01-18 17:14:46.0478	2017-01-18 17:14:46.0478
12367	2016-09-01 00:00:00	2017-01-01 00:00:00	10225	10030	20	2017-01-18 17:14:46.053387	2017-01-18 17:14:46.053387
12368	2016-09-01 00:00:00	2017-01-01 00:00:00	10225	10031	24	2017-01-18 17:14:46.058116	2017-01-18 17:14:46.058116
12369	2017-01-01 00:00:00	2100-01-01 00:00:00	10225	10030	19	2017-01-18 17:14:46.063662	2017-01-18 17:14:46.063662
12370	2017-01-01 00:00:00	2100-01-01 00:00:00	10225	10031	25	2017-01-18 17:14:46.06831	2017-01-18 17:14:46.06831
12371	2000-01-01 00:00:00	2016-06-01 00:00:00	10226	10030	22	2017-01-18 17:14:46.073515	2017-01-18 17:14:46.073515
12372	2000-01-01 00:00:00	2016-06-01 00:00:00	10226	10031	13	2017-01-18 17:14:46.07802	2017-01-18 17:14:46.07802
12373	2016-06-01 00:00:00	2016-09-01 00:00:00	10226	10030	10	2017-01-18 17:14:46.083623	2017-01-18 17:14:46.083623
12374	2016-06-01 00:00:00	2016-09-01 00:00:00	10226	10031	24	2017-01-18 17:14:46.088174	2017-01-18 17:14:46.088174
12375	2016-09-01 00:00:00	2017-01-01 00:00:00	10226	10030	26	2017-01-18 17:14:46.093315	2017-01-18 17:14:46.093315
12376	2016-09-01 00:00:00	2017-01-01 00:00:00	10226	10031	20	2017-01-18 17:14:46.097538	2017-01-18 17:14:46.097538
12377	2017-01-01 00:00:00	2100-01-01 00:00:00	10226	10030	11	2017-01-18 17:14:46.102759	2017-01-18 17:14:46.102759
12378	2017-01-01 00:00:00	2100-01-01 00:00:00	10226	10031	11	2017-01-18 17:14:46.107382	2017-01-18 17:14:46.107382
12379	2000-01-01 00:00:00	2016-06-01 00:00:00	10227	10030	28	2017-01-18 17:14:46.112508	2017-01-18 17:14:46.112508
12380	2000-01-01 00:00:00	2016-06-01 00:00:00	10227	10031	10	2017-01-18 17:14:46.117101	2017-01-18 17:14:46.117101
12381	2016-06-01 00:00:00	2016-09-01 00:00:00	10227	10030	16	2017-01-18 17:14:46.122406	2017-01-18 17:14:46.122406
12382	2016-06-01 00:00:00	2016-09-01 00:00:00	10227	10031	25	2017-01-18 17:14:46.12713	2017-01-18 17:14:46.12713
12383	2016-09-01 00:00:00	2017-01-01 00:00:00	10227	10030	20	2017-01-18 17:14:46.132722	2017-01-18 17:14:46.132722
12384	2016-09-01 00:00:00	2017-01-01 00:00:00	10227	10031	23	2017-01-18 17:14:46.137654	2017-01-18 17:14:46.137654
12385	2017-01-01 00:00:00	2100-01-01 00:00:00	10227	10030	23	2017-01-18 17:14:46.143265	2017-01-18 17:14:46.143265
12386	2017-01-01 00:00:00	2100-01-01 00:00:00	10227	10031	29	2017-01-18 17:14:46.147949	2017-01-18 17:14:46.147949
12387	2000-01-01 00:00:00	2016-06-01 00:00:00	10228	10030	28	2017-01-18 17:14:46.153485	2017-01-18 17:14:46.153485
12388	2000-01-01 00:00:00	2016-06-01 00:00:00	10228	10031	11	2017-01-18 17:14:46.158268	2017-01-18 17:14:46.158268
12389	2016-06-01 00:00:00	2016-09-01 00:00:00	10228	10030	28	2017-01-18 17:14:46.163453	2017-01-18 17:14:46.163453
12390	2016-06-01 00:00:00	2016-09-01 00:00:00	10228	10031	21	2017-01-18 17:14:46.168182	2017-01-18 17:14:46.168182
12391	2016-09-01 00:00:00	2017-01-01 00:00:00	10228	10030	26	2017-01-18 17:14:46.173572	2017-01-18 17:14:46.173572
12392	2016-09-01 00:00:00	2017-01-01 00:00:00	10228	10031	16	2017-01-18 17:14:46.178709	2017-01-18 17:14:46.178709
12393	2017-01-01 00:00:00	2100-01-01 00:00:00	10228	10030	11	2017-01-18 17:14:46.184268	2017-01-18 17:14:46.184268
12394	2017-01-01 00:00:00	2100-01-01 00:00:00	10228	10031	10	2017-01-18 17:14:46.18905	2017-01-18 17:14:46.18905
12395	2000-01-01 00:00:00	2016-06-01 00:00:00	10229	10030	22	2017-01-18 17:14:46.194412	2017-01-18 17:14:46.194412
12396	2000-01-01 00:00:00	2016-06-01 00:00:00	10229	10031	21	2017-01-18 17:14:46.19924	2017-01-18 17:14:46.19924
12397	2016-06-01 00:00:00	2016-09-01 00:00:00	10229	10030	22	2017-01-18 17:14:46.20463	2017-01-18 17:14:46.20463
12398	2016-06-01 00:00:00	2016-09-01 00:00:00	10229	10031	21	2017-01-18 17:14:46.2091	2017-01-18 17:14:46.2091
12399	2016-09-01 00:00:00	2017-01-01 00:00:00	10229	10030	16	2017-01-18 17:14:46.214254	2017-01-18 17:14:46.214254
12400	2016-09-01 00:00:00	2017-01-01 00:00:00	10229	10031	14	2017-01-18 17:14:46.218631	2017-01-18 17:14:46.218631
12401	2017-01-01 00:00:00	2100-01-01 00:00:00	10229	10030	24	2017-01-18 17:14:46.223655	2017-01-18 17:14:46.223655
12402	2017-01-01 00:00:00	2100-01-01 00:00:00	10229	10031	11	2017-01-18 17:14:46.228711	2017-01-18 17:14:46.228711
12403	2000-01-01 00:00:00	2016-06-01 00:00:00	10230	10030	15	2017-01-18 17:14:46.233977	2017-01-18 17:14:46.233977
12404	2000-01-01 00:00:00	2016-06-01 00:00:00	10230	10031	19	2017-01-18 17:14:46.23872	2017-01-18 17:14:46.23872
12405	2016-06-01 00:00:00	2016-09-01 00:00:00	10230	10030	27	2017-01-18 17:14:46.244368	2017-01-18 17:14:46.244368
12406	2016-06-01 00:00:00	2016-09-01 00:00:00	10230	10031	14	2017-01-18 17:14:46.249514	2017-01-18 17:14:46.249514
12407	2016-09-01 00:00:00	2017-01-01 00:00:00	10230	10030	20	2017-01-18 17:14:46.255505	2017-01-18 17:14:46.255505
12408	2016-09-01 00:00:00	2017-01-01 00:00:00	10230	10031	26	2017-01-18 17:14:46.260225	2017-01-18 17:14:46.260225
12409	2017-01-01 00:00:00	2100-01-01 00:00:00	10230	10030	29	2017-01-18 17:14:46.265419	2017-01-18 17:14:46.265419
12410	2017-01-01 00:00:00	2100-01-01 00:00:00	10230	10031	19	2017-01-18 17:14:46.270193	2017-01-18 17:14:46.270193
12411	2000-01-01 00:00:00	2016-06-01 00:00:00	10231	10030	13	2017-01-18 17:14:46.275459	2017-01-18 17:14:46.275459
12412	2000-01-01 00:00:00	2016-06-01 00:00:00	10231	10031	15	2017-01-18 17:14:46.280223	2017-01-18 17:14:46.280223
12413	2016-06-01 00:00:00	2016-09-01 00:00:00	10231	10030	27	2017-01-18 17:14:46.285866	2017-01-18 17:14:46.285866
12414	2016-06-01 00:00:00	2016-09-01 00:00:00	10231	10031	13	2017-01-18 17:14:46.290614	2017-01-18 17:14:46.290614
12415	2016-09-01 00:00:00	2017-01-01 00:00:00	10231	10030	27	2017-01-18 17:14:46.296262	2017-01-18 17:14:46.296262
12416	2016-09-01 00:00:00	2017-01-01 00:00:00	10231	10031	21	2017-01-18 17:14:46.301053	2017-01-18 17:14:46.301053
12417	2017-01-01 00:00:00	2100-01-01 00:00:00	10231	10030	14	2017-01-18 17:14:46.306415	2017-01-18 17:14:46.306415
12418	2017-01-01 00:00:00	2100-01-01 00:00:00	10231	10031	28	2017-01-18 17:14:46.31088	2017-01-18 17:14:46.31088
12419	2000-01-01 00:00:00	2016-06-01 00:00:00	10232	10030	19	2017-01-18 17:14:46.316511	2017-01-18 17:14:46.316511
12420	2000-01-01 00:00:00	2016-06-01 00:00:00	10232	10031	10	2017-01-18 17:14:46.320943	2017-01-18 17:14:46.320943
12421	2016-06-01 00:00:00	2016-09-01 00:00:00	10232	10030	17	2017-01-18 17:14:46.32632	2017-01-18 17:14:46.32632
12422	2016-06-01 00:00:00	2016-09-01 00:00:00	10232	10031	14	2017-01-18 17:14:46.330946	2017-01-18 17:14:46.330946
12423	2016-09-01 00:00:00	2017-01-01 00:00:00	10232	10030	19	2017-01-18 17:14:46.336219	2017-01-18 17:14:46.336219
12424	2016-09-01 00:00:00	2017-01-01 00:00:00	10232	10031	18	2017-01-18 17:14:46.340835	2017-01-18 17:14:46.340835
12425	2017-01-01 00:00:00	2100-01-01 00:00:00	10232	10030	14	2017-01-18 17:14:46.34592	2017-01-18 17:14:46.34592
12426	2017-01-01 00:00:00	2100-01-01 00:00:00	10232	10031	22	2017-01-18 17:14:46.350911	2017-01-18 17:14:46.350911
12427	2000-01-01 00:00:00	2016-06-01 00:00:00	10233	10030	17	2017-01-18 17:14:46.356401	2017-01-18 17:14:46.356401
12428	2000-01-01 00:00:00	2016-06-01 00:00:00	10233	10031	14	2017-01-18 17:14:46.360858	2017-01-18 17:14:46.360858
12429	2016-06-01 00:00:00	2016-09-01 00:00:00	10233	10030	17	2017-01-18 17:14:46.366408	2017-01-18 17:14:46.366408
12430	2016-06-01 00:00:00	2016-09-01 00:00:00	10233	10031	12	2017-01-18 17:14:46.372038	2017-01-18 17:14:46.372038
12431	2016-09-01 00:00:00	2017-01-01 00:00:00	10233	10030	19	2017-01-18 17:14:46.377019	2017-01-18 17:14:46.377019
12432	2016-09-01 00:00:00	2017-01-01 00:00:00	10233	10031	29	2017-01-18 17:14:46.381441	2017-01-18 17:14:46.381441
12433	2017-01-01 00:00:00	2100-01-01 00:00:00	10233	10030	24	2017-01-18 17:14:46.386334	2017-01-18 17:14:46.386334
12434	2017-01-01 00:00:00	2100-01-01 00:00:00	10233	10031	21	2017-01-18 17:14:46.390991	2017-01-18 17:14:46.390991
12435	2000-01-01 00:00:00	2016-06-01 00:00:00	10234	10030	16	2017-01-18 17:14:46.396089	2017-01-18 17:14:46.396089
12436	2000-01-01 00:00:00	2016-06-01 00:00:00	10234	10031	28	2017-01-18 17:14:46.40075	2017-01-18 17:14:46.40075
12437	2016-06-01 00:00:00	2016-09-01 00:00:00	10234	10030	16	2017-01-18 17:14:46.406313	2017-01-18 17:14:46.406313
12438	2016-06-01 00:00:00	2016-09-01 00:00:00	10234	10031	20	2017-01-18 17:14:46.410936	2017-01-18 17:14:46.410936
12439	2016-09-01 00:00:00	2017-01-01 00:00:00	10234	10030	16	2017-01-18 17:14:46.416239	2017-01-18 17:14:46.416239
12440	2016-09-01 00:00:00	2017-01-01 00:00:00	10234	10031	28	2017-01-18 17:14:46.420961	2017-01-18 17:14:46.420961
12441	2017-01-01 00:00:00	2100-01-01 00:00:00	10234	10030	20	2017-01-18 17:14:46.426097	2017-01-18 17:14:46.426097
12442	2017-01-01 00:00:00	2100-01-01 00:00:00	10234	10031	14	2017-01-18 17:14:46.430755	2017-01-18 17:14:46.430755
12443	2000-01-01 00:00:00	2016-06-01 00:00:00	10235	10030	12	2017-01-18 17:14:46.436377	2017-01-18 17:14:46.436377
12444	2000-01-01 00:00:00	2016-06-01 00:00:00	10235	10031	21	2017-01-18 17:14:46.441189	2017-01-18 17:14:46.441189
12445	2016-06-01 00:00:00	2016-09-01 00:00:00	10235	10030	27	2017-01-18 17:14:46.447405	2017-01-18 17:14:46.447405
12446	2016-06-01 00:00:00	2016-09-01 00:00:00	10235	10031	22	2017-01-18 17:14:46.452067	2017-01-18 17:14:46.452067
12447	2016-09-01 00:00:00	2017-01-01 00:00:00	10235	10030	16	2017-01-18 17:14:46.457182	2017-01-18 17:14:46.457182
12448	2016-09-01 00:00:00	2017-01-01 00:00:00	10235	10031	24	2017-01-18 17:14:46.461544	2017-01-18 17:14:46.461544
12449	2017-01-01 00:00:00	2100-01-01 00:00:00	10235	10030	14	2017-01-18 17:14:46.466274	2017-01-18 17:14:46.466274
12450	2017-01-01 00:00:00	2100-01-01 00:00:00	10235	10031	25	2017-01-18 17:14:46.470841	2017-01-18 17:14:46.470841
12451	2000-01-01 00:00:00	2016-06-01 00:00:00	10236	10030	13	2017-01-18 17:14:46.476135	2017-01-18 17:14:46.476135
12452	2000-01-01 00:00:00	2016-06-01 00:00:00	10236	10031	26	2017-01-18 17:14:46.480653	2017-01-18 17:14:46.480653
12453	2016-06-01 00:00:00	2016-09-01 00:00:00	10236	10030	19	2017-01-18 17:14:46.486464	2017-01-18 17:14:46.486464
12454	2016-06-01 00:00:00	2016-09-01 00:00:00	10236	10031	24	2017-01-18 17:14:46.490885	2017-01-18 17:14:46.490885
12455	2016-09-01 00:00:00	2017-01-01 00:00:00	10236	10030	26	2017-01-18 17:14:46.496136	2017-01-18 17:14:46.496136
12456	2016-09-01 00:00:00	2017-01-01 00:00:00	10236	10031	14	2017-01-18 17:14:46.500991	2017-01-18 17:14:46.500991
12457	2017-01-01 00:00:00	2100-01-01 00:00:00	10236	10030	25	2017-01-18 17:14:46.506321	2017-01-18 17:14:46.506321
12458	2017-01-01 00:00:00	2100-01-01 00:00:00	10236	10031	23	2017-01-18 17:14:46.511579	2017-01-18 17:14:46.511579
12459	2000-01-01 00:00:00	2016-06-01 00:00:00	10237	10030	17	2017-01-18 17:14:46.516787	2017-01-18 17:14:46.516787
12460	2000-01-01 00:00:00	2016-06-01 00:00:00	10237	10031	13	2017-01-18 17:14:46.521915	2017-01-18 17:14:46.521915
12461	2016-06-01 00:00:00	2016-09-01 00:00:00	10237	10030	19	2017-01-18 17:14:46.527478	2017-01-18 17:14:46.527478
12462	2016-06-01 00:00:00	2016-09-01 00:00:00	10237	10031	17	2017-01-18 17:14:46.531985	2017-01-18 17:14:46.531985
12463	2016-09-01 00:00:00	2017-01-01 00:00:00	10237	10030	25	2017-01-18 17:14:46.53757	2017-01-18 17:14:46.53757
12464	2016-09-01 00:00:00	2017-01-01 00:00:00	10237	10031	18	2017-01-18 17:14:46.542167	2017-01-18 17:14:46.542167
12465	2017-01-01 00:00:00	2100-01-01 00:00:00	10237	10030	13	2017-01-18 17:14:46.547725	2017-01-18 17:14:46.547725
12466	2017-01-01 00:00:00	2100-01-01 00:00:00	10237	10031	18	2017-01-18 17:14:46.552546	2017-01-18 17:14:46.552546
12467	2000-01-01 00:00:00	2016-06-01 00:00:00	10238	10030	12	2017-01-18 17:14:46.557955	2017-01-18 17:14:46.557955
12468	2000-01-01 00:00:00	2016-06-01 00:00:00	10238	10031	21	2017-01-18 17:14:46.562832	2017-01-18 17:14:46.562832
12469	2016-06-01 00:00:00	2016-09-01 00:00:00	10238	10030	16	2017-01-18 17:14:46.568039	2017-01-18 17:14:46.568039
12470	2016-06-01 00:00:00	2016-09-01 00:00:00	10238	10031	18	2017-01-18 17:14:46.572407	2017-01-18 17:14:46.572407
12471	2016-09-01 00:00:00	2017-01-01 00:00:00	10238	10030	20	2017-01-18 17:14:46.577742	2017-01-18 17:14:46.577742
12472	2016-09-01 00:00:00	2017-01-01 00:00:00	10238	10031	18	2017-01-18 17:14:46.583014	2017-01-18 17:14:46.583014
12473	2017-01-01 00:00:00	2100-01-01 00:00:00	10238	10030	13	2017-01-18 17:14:46.588284	2017-01-18 17:14:46.588284
12474	2017-01-01 00:00:00	2100-01-01 00:00:00	10238	10031	16	2017-01-18 17:14:46.592577	2017-01-18 17:14:46.592577
12475	2000-01-01 00:00:00	2016-06-01 00:00:00	10239	10030	27	2017-01-18 17:14:46.597556	2017-01-18 17:14:46.597556
12476	2000-01-01 00:00:00	2016-06-01 00:00:00	10239	10031	29	2017-01-18 17:14:46.60195	2017-01-18 17:14:46.60195
12477	2016-06-01 00:00:00	2016-09-01 00:00:00	10239	10030	10	2017-01-18 17:14:46.607172	2017-01-18 17:14:46.607172
12478	2016-06-01 00:00:00	2016-09-01 00:00:00	10239	10031	25	2017-01-18 17:14:46.611464	2017-01-18 17:14:46.611464
12479	2016-09-01 00:00:00	2017-01-01 00:00:00	10239	10030	11	2017-01-18 17:14:46.616408	2017-01-18 17:14:46.616408
12480	2016-09-01 00:00:00	2017-01-01 00:00:00	10239	10031	26	2017-01-18 17:14:46.62131	2017-01-18 17:14:46.62131
12481	2017-01-01 00:00:00	2100-01-01 00:00:00	10239	10030	22	2017-01-18 17:14:46.626068	2017-01-18 17:14:46.626068
12482	2017-01-01 00:00:00	2100-01-01 00:00:00	10239	10031	12	2017-01-18 17:14:46.630352	2017-01-18 17:14:46.630352
12483	2000-01-01 00:00:00	2016-06-01 00:00:00	10240	10030	25	2017-01-18 17:14:46.635994	2017-01-18 17:14:46.635994
12484	2000-01-01 00:00:00	2016-06-01 00:00:00	10240	10031	20	2017-01-18 17:14:46.640275	2017-01-18 17:14:46.640275
12485	2016-06-01 00:00:00	2016-09-01 00:00:00	10240	10030	28	2017-01-18 17:14:46.645252	2017-01-18 17:14:46.645252
12486	2016-06-01 00:00:00	2016-09-01 00:00:00	10240	10031	17	2017-01-18 17:14:46.64986	2017-01-18 17:14:46.64986
12487	2016-09-01 00:00:00	2017-01-01 00:00:00	10240	10030	19	2017-01-18 17:14:46.655302	2017-01-18 17:14:46.655302
12488	2016-09-01 00:00:00	2017-01-01 00:00:00	10240	10031	22	2017-01-18 17:14:46.660691	2017-01-18 17:14:46.660691
12489	2017-01-01 00:00:00	2100-01-01 00:00:00	10240	10030	26	2017-01-18 17:14:46.665646	2017-01-18 17:14:46.665646
12490	2017-01-01 00:00:00	2100-01-01 00:00:00	10240	10031	14	2017-01-18 17:14:46.669909	2017-01-18 17:14:46.669909
12491	2000-01-01 00:00:00	2016-06-01 00:00:00	10241	10030	26	2017-01-18 17:14:46.674901	2017-01-18 17:14:46.674901
12492	2000-01-01 00:00:00	2016-06-01 00:00:00	10241	10031	26	2017-01-18 17:14:46.67964	2017-01-18 17:14:46.67964
12493	2016-06-01 00:00:00	2016-09-01 00:00:00	10241	10030	29	2017-01-18 17:14:46.68488	2017-01-18 17:14:46.68488
12494	2016-06-01 00:00:00	2016-09-01 00:00:00	10241	10031	19	2017-01-18 17:14:46.689584	2017-01-18 17:14:46.689584
12495	2016-09-01 00:00:00	2017-01-01 00:00:00	10241	10030	12	2017-01-18 17:14:46.694695	2017-01-18 17:14:46.694695
12496	2016-09-01 00:00:00	2017-01-01 00:00:00	10241	10031	16	2017-01-18 17:14:46.698941	2017-01-18 17:14:46.698941
12497	2017-01-01 00:00:00	2100-01-01 00:00:00	10241	10030	11	2017-01-18 17:14:46.704049	2017-01-18 17:14:46.704049
12498	2017-01-01 00:00:00	2100-01-01 00:00:00	10241	10031	27	2017-01-18 17:14:46.708386	2017-01-18 17:14:46.708386
12499	2000-01-01 00:00:00	2016-06-01 00:00:00	10242	10030	29	2017-01-18 17:14:46.713625	2017-01-18 17:14:46.713625
12500	2000-01-01 00:00:00	2016-06-01 00:00:00	10242	10031	27	2017-01-18 17:14:46.717876	2017-01-18 17:14:46.717876
12501	2016-06-01 00:00:00	2016-09-01 00:00:00	10242	10030	17	2017-01-18 17:14:46.723037	2017-01-18 17:14:46.723037
12502	2016-06-01 00:00:00	2016-09-01 00:00:00	10242	10031	27	2017-01-18 17:14:46.727247	2017-01-18 17:14:46.727247
12503	2016-09-01 00:00:00	2017-01-01 00:00:00	10242	10030	15	2017-01-18 17:14:46.732119	2017-01-18 17:14:46.732119
12504	2016-09-01 00:00:00	2017-01-01 00:00:00	10242	10031	21	2017-01-18 17:14:46.73671	2017-01-18 17:14:46.73671
12505	2017-01-01 00:00:00	2100-01-01 00:00:00	10242	10030	12	2017-01-18 17:14:46.741577	2017-01-18 17:14:46.741577
12506	2017-01-01 00:00:00	2100-01-01 00:00:00	10242	10031	21	2017-01-18 17:14:46.746015	2017-01-18 17:14:46.746015
12507	2000-01-01 00:00:00	2016-06-01 00:00:00	10243	10030	25	2017-01-18 17:14:46.75119	2017-01-18 17:14:46.75119
12508	2000-01-01 00:00:00	2016-06-01 00:00:00	10243	10031	29	2017-01-18 17:14:46.755519	2017-01-18 17:14:46.755519
12509	2016-06-01 00:00:00	2016-09-01 00:00:00	10243	10030	27	2017-01-18 17:14:46.761595	2017-01-18 17:14:46.761595
12510	2016-06-01 00:00:00	2016-09-01 00:00:00	10243	10031	10	2017-01-18 17:14:46.766061	2017-01-18 17:14:46.766061
12511	2016-09-01 00:00:00	2017-01-01 00:00:00	10243	10030	14	2017-01-18 17:14:46.771483	2017-01-18 17:14:46.771483
12512	2016-09-01 00:00:00	2017-01-01 00:00:00	10243	10031	27	2017-01-18 17:14:46.775853	2017-01-18 17:14:46.775853
12513	2017-01-01 00:00:00	2100-01-01 00:00:00	10243	10030	11	2017-01-18 17:14:46.78118	2017-01-18 17:14:46.78118
12514	2017-01-01 00:00:00	2100-01-01 00:00:00	10243	10031	29	2017-01-18 17:14:46.785641	2017-01-18 17:14:46.785641
12515	2000-01-01 00:00:00	2016-06-01 00:00:00	10244	10030	28	2017-01-18 17:14:46.790896	2017-01-18 17:14:46.790896
12516	2000-01-01 00:00:00	2016-06-01 00:00:00	10244	10031	27	2017-01-18 17:14:46.79565	2017-01-18 17:14:46.79565
12517	2016-06-01 00:00:00	2016-09-01 00:00:00	10244	10030	26	2017-01-18 17:14:46.800714	2017-01-18 17:14:46.800714
12518	2016-06-01 00:00:00	2016-09-01 00:00:00	10244	10031	16	2017-01-18 17:14:46.805313	2017-01-18 17:14:46.805313
12519	2016-09-01 00:00:00	2017-01-01 00:00:00	10244	10030	10	2017-01-18 17:14:46.810678	2017-01-18 17:14:46.810678
12520	2016-09-01 00:00:00	2017-01-01 00:00:00	10244	10031	13	2017-01-18 17:14:46.815159	2017-01-18 17:14:46.815159
12521	2017-01-01 00:00:00	2100-01-01 00:00:00	10244	10030	14	2017-01-18 17:14:46.820815	2017-01-18 17:14:46.820815
12522	2017-01-01 00:00:00	2100-01-01 00:00:00	10244	10031	25	2017-01-18 17:14:46.82575	2017-01-18 17:14:46.82575
12523	2000-01-01 00:00:00	2016-06-01 00:00:00	10245	10030	27	2017-01-18 17:14:46.831356	2017-01-18 17:14:46.831356
12524	2000-01-01 00:00:00	2016-06-01 00:00:00	10245	10031	23	2017-01-18 17:14:46.836009	2017-01-18 17:14:46.836009
12525	2016-06-01 00:00:00	2016-09-01 00:00:00	10245	10030	24	2017-01-18 17:14:46.841596	2017-01-18 17:14:46.841596
12526	2016-06-01 00:00:00	2016-09-01 00:00:00	10245	10031	25	2017-01-18 17:14:46.846054	2017-01-18 17:14:46.846054
12527	2016-09-01 00:00:00	2017-01-01 00:00:00	10245	10030	26	2017-01-18 17:14:46.851488	2017-01-18 17:14:46.851488
12528	2016-09-01 00:00:00	2017-01-01 00:00:00	10245	10031	25	2017-01-18 17:14:46.856025	2017-01-18 17:14:46.856025
12529	2017-01-01 00:00:00	2100-01-01 00:00:00	10245	10030	19	2017-01-18 17:14:46.861854	2017-01-18 17:14:46.861854
12530	2017-01-01 00:00:00	2100-01-01 00:00:00	10245	10031	27	2017-01-18 17:14:46.866619	2017-01-18 17:14:46.866619
12531	2000-01-01 00:00:00	2016-06-01 00:00:00	10246	10030	18	2017-01-18 17:14:46.87416	2017-01-18 17:14:46.87416
12532	2000-01-01 00:00:00	2016-06-01 00:00:00	10246	10031	22	2017-01-18 17:14:46.878408	2017-01-18 17:14:46.878408
12533	2016-06-01 00:00:00	2016-09-01 00:00:00	10246	10030	10	2017-01-18 17:14:46.883763	2017-01-18 17:14:46.883763
12534	2016-06-01 00:00:00	2016-09-01 00:00:00	10246	10031	27	2017-01-18 17:14:46.888597	2017-01-18 17:14:46.888597
12535	2016-09-01 00:00:00	2017-01-01 00:00:00	10246	10030	21	2017-01-18 17:14:46.893742	2017-01-18 17:14:46.893742
12536	2016-09-01 00:00:00	2017-01-01 00:00:00	10246	10031	20	2017-01-18 17:14:46.898683	2017-01-18 17:14:46.898683
12537	2017-01-01 00:00:00	2100-01-01 00:00:00	10246	10030	28	2017-01-18 17:14:46.90398	2017-01-18 17:14:46.90398
12538	2017-01-01 00:00:00	2100-01-01 00:00:00	10246	10031	12	2017-01-18 17:14:46.909165	2017-01-18 17:14:46.909165
12539	2000-01-01 00:00:00	2016-06-01 00:00:00	10247	10030	20	2017-01-18 17:14:46.914395	2017-01-18 17:14:46.914395
12540	2000-01-01 00:00:00	2016-06-01 00:00:00	10247	10031	23	2017-01-18 17:14:46.919273	2017-01-18 17:14:46.919273
12541	2016-06-01 00:00:00	2016-09-01 00:00:00	10247	10030	26	2017-01-18 17:14:46.924525	2017-01-18 17:14:46.924525
12542	2016-06-01 00:00:00	2016-09-01 00:00:00	10247	10031	24	2017-01-18 17:14:46.92901	2017-01-18 17:14:46.92901
12543	2016-09-01 00:00:00	2017-01-01 00:00:00	10247	10030	20	2017-01-18 17:14:46.934366	2017-01-18 17:14:46.934366
12544	2016-09-01 00:00:00	2017-01-01 00:00:00	10247	10031	17	2017-01-18 17:14:46.939031	2017-01-18 17:14:46.939031
12545	2017-01-01 00:00:00	2100-01-01 00:00:00	10247	10030	22	2017-01-18 17:14:46.944231	2017-01-18 17:14:46.944231
12546	2017-01-01 00:00:00	2100-01-01 00:00:00	10247	10031	14	2017-01-18 17:14:46.948898	2017-01-18 17:14:46.948898
12547	2000-01-01 00:00:00	2016-06-01 00:00:00	10248	10030	23	2017-01-18 17:14:46.954621	2017-01-18 17:14:46.954621
12548	2000-01-01 00:00:00	2016-06-01 00:00:00	10248	10031	19	2017-01-18 17:14:46.959109	2017-01-18 17:14:46.959109
12549	2016-06-01 00:00:00	2016-09-01 00:00:00	10248	10030	25	2017-01-18 17:14:46.964343	2017-01-18 17:14:46.964343
12550	2016-06-01 00:00:00	2016-09-01 00:00:00	10248	10031	12	2017-01-18 17:14:46.969076	2017-01-18 17:14:46.969076
12551	2016-09-01 00:00:00	2017-01-01 00:00:00	10248	10030	25	2017-01-18 17:14:46.97459	2017-01-18 17:14:46.97459
12552	2016-09-01 00:00:00	2017-01-01 00:00:00	10248	10031	27	2017-01-18 17:14:46.979203	2017-01-18 17:14:46.979203
12553	2017-01-01 00:00:00	2100-01-01 00:00:00	10248	10030	26	2017-01-18 17:14:46.984516	2017-01-18 17:14:46.984516
12554	2017-01-01 00:00:00	2100-01-01 00:00:00	10248	10031	14	2017-01-18 17:14:46.989175	2017-01-18 17:14:46.989175
12555	2000-01-01 00:00:00	2016-06-01 00:00:00	10249	10030	16	2017-01-18 17:14:46.99388	2017-01-18 17:14:46.99388
12556	2000-01-01 00:00:00	2016-06-01 00:00:00	10249	10031	13	2017-01-18 17:14:46.998602	2017-01-18 17:14:46.998602
12557	2016-06-01 00:00:00	2016-09-01 00:00:00	10249	10030	23	2017-01-18 17:14:47.004593	2017-01-18 17:14:47.004593
12558	2016-06-01 00:00:00	2016-09-01 00:00:00	10249	10031	18	2017-01-18 17:14:47.009255	2017-01-18 17:14:47.009255
12559	2016-09-01 00:00:00	2017-01-01 00:00:00	10249	10030	18	2017-01-18 17:14:47.014744	2017-01-18 17:14:47.014744
12560	2016-09-01 00:00:00	2017-01-01 00:00:00	10249	10031	13	2017-01-18 17:14:47.019956	2017-01-18 17:14:47.019956
12561	2017-01-01 00:00:00	2100-01-01 00:00:00	10249	10030	17	2017-01-18 17:14:47.02562	2017-01-18 17:14:47.02562
12562	2017-01-01 00:00:00	2100-01-01 00:00:00	10249	10031	17	2017-01-18 17:14:47.030016	2017-01-18 17:14:47.030016
12563	2000-01-01 00:00:00	2016-06-01 00:00:00	10250	10030	16	2017-01-18 17:14:47.035999	2017-01-18 17:14:47.035999
12564	2000-01-01 00:00:00	2016-06-01 00:00:00	10250	10031	26	2017-01-18 17:14:47.040652	2017-01-18 17:14:47.040652
12565	2016-06-01 00:00:00	2016-09-01 00:00:00	10250	10030	14	2017-01-18 17:14:47.046121	2017-01-18 17:14:47.046121
12566	2016-06-01 00:00:00	2016-09-01 00:00:00	10250	10031	12	2017-01-18 17:14:47.05092	2017-01-18 17:14:47.05092
12567	2016-09-01 00:00:00	2017-01-01 00:00:00	10250	10030	15	2017-01-18 17:14:47.056697	2017-01-18 17:14:47.056697
12568	2016-09-01 00:00:00	2017-01-01 00:00:00	10250	10031	10	2017-01-18 17:14:47.061395	2017-01-18 17:14:47.061395
12569	2017-01-01 00:00:00	2100-01-01 00:00:00	10250	10030	14	2017-01-18 17:14:47.06717	2017-01-18 17:14:47.06717
12570	2017-01-01 00:00:00	2100-01-01 00:00:00	10250	10031	22	2017-01-18 17:14:47.071544	2017-01-18 17:14:47.071544
12571	2000-01-01 00:00:00	2016-06-01 00:00:00	10251	10030	26	2017-01-18 17:14:47.076853	2017-01-18 17:14:47.076853
12572	2000-01-01 00:00:00	2016-06-01 00:00:00	10251	10031	16	2017-01-18 17:14:47.08164	2017-01-18 17:14:47.08164
12573	2016-06-01 00:00:00	2016-09-01 00:00:00	10251	10030	19	2017-01-18 17:14:47.087155	2017-01-18 17:14:47.087155
12574	2016-06-01 00:00:00	2016-09-01 00:00:00	10251	10031	28	2017-01-18 17:14:47.092432	2017-01-18 17:14:47.092432
12575	2016-09-01 00:00:00	2017-01-01 00:00:00	10251	10030	20	2017-01-18 17:14:47.097679	2017-01-18 17:14:47.097679
12576	2016-09-01 00:00:00	2017-01-01 00:00:00	10251	10031	10	2017-01-18 17:14:47.102289	2017-01-18 17:14:47.102289
12577	2017-01-01 00:00:00	2100-01-01 00:00:00	10251	10030	24	2017-01-18 17:14:47.107183	2017-01-18 17:14:47.107183
12578	2017-01-01 00:00:00	2100-01-01 00:00:00	10251	10031	24	2017-01-18 17:14:47.111545	2017-01-18 17:14:47.111545
12579	2000-01-01 00:00:00	2016-06-01 00:00:00	10252	10030	11	2017-01-18 17:14:47.116465	2017-01-18 17:14:47.116465
12580	2000-01-01 00:00:00	2016-06-01 00:00:00	10252	10031	19	2017-01-18 17:14:47.120764	2017-01-18 17:14:47.120764
12581	2016-06-01 00:00:00	2016-09-01 00:00:00	10252	10030	17	2017-01-18 17:14:47.125865	2017-01-18 17:14:47.125865
12582	2016-06-01 00:00:00	2016-09-01 00:00:00	10252	10031	16	2017-01-18 17:14:47.130397	2017-01-18 17:14:47.130397
12583	2016-09-01 00:00:00	2017-01-01 00:00:00	10252	10030	24	2017-01-18 17:14:47.135408	2017-01-18 17:14:47.135408
12584	2016-09-01 00:00:00	2017-01-01 00:00:00	10252	10031	18	2017-01-18 17:14:47.140254	2017-01-18 17:14:47.140254
12585	2017-01-01 00:00:00	2100-01-01 00:00:00	10252	10030	16	2017-01-18 17:14:47.145604	2017-01-18 17:14:47.145604
12586	2017-01-01 00:00:00	2100-01-01 00:00:00	10252	10031	10	2017-01-18 17:14:47.150341	2017-01-18 17:14:47.150341
12587	2000-01-01 00:00:00	2016-06-01 00:00:00	10253	10030	20	2017-01-18 17:14:47.155947	2017-01-18 17:14:47.155947
12588	2000-01-01 00:00:00	2016-06-01 00:00:00	10253	10031	26	2017-01-18 17:14:47.160689	2017-01-18 17:14:47.160689
12589	2016-06-01 00:00:00	2016-09-01 00:00:00	10253	10030	16	2017-01-18 17:14:47.166328	2017-01-18 17:14:47.166328
12590	2016-06-01 00:00:00	2016-09-01 00:00:00	10253	10031	24	2017-01-18 17:14:47.170964	2017-01-18 17:14:47.170964
12591	2016-09-01 00:00:00	2017-01-01 00:00:00	10253	10030	17	2017-01-18 17:14:47.176388	2017-01-18 17:14:47.176388
12592	2016-09-01 00:00:00	2017-01-01 00:00:00	10253	10031	12	2017-01-18 17:14:47.181034	2017-01-18 17:14:47.181034
12593	2017-01-01 00:00:00	2100-01-01 00:00:00	10253	10030	20	2017-01-18 17:14:47.186698	2017-01-18 17:14:47.186698
12594	2017-01-01 00:00:00	2100-01-01 00:00:00	10253	10031	18	2017-01-18 17:14:47.191578	2017-01-18 17:14:47.191578
12595	2000-01-01 00:00:00	2016-06-01 00:00:00	10254	10030	11	2017-01-18 17:14:47.196737	2017-01-18 17:14:47.196737
12596	2000-01-01 00:00:00	2016-06-01 00:00:00	10254	10031	10	2017-01-18 17:14:47.201749	2017-01-18 17:14:47.201749
12597	2016-06-01 00:00:00	2016-09-01 00:00:00	10254	10030	27	2017-01-18 17:14:47.207309	2017-01-18 17:14:47.207309
12598	2016-06-01 00:00:00	2016-09-01 00:00:00	10254	10031	26	2017-01-18 17:14:47.211872	2017-01-18 17:14:47.211872
12599	2016-09-01 00:00:00	2017-01-01 00:00:00	10254	10030	27	2017-01-18 17:14:47.217466	2017-01-18 17:14:47.217466
12600	2016-09-01 00:00:00	2017-01-01 00:00:00	10254	10031	22	2017-01-18 17:14:47.222336	2017-01-18 17:14:47.222336
12601	2017-01-01 00:00:00	2100-01-01 00:00:00	10254	10030	19	2017-01-18 17:14:47.227516	2017-01-18 17:14:47.227516
12602	2017-01-01 00:00:00	2100-01-01 00:00:00	10254	10031	18	2017-01-18 17:14:47.232085	2017-01-18 17:14:47.232085
12603	2000-01-01 00:00:00	2016-06-01 00:00:00	10255	10030	29	2017-01-18 17:14:47.237592	2017-01-18 17:14:47.237592
12604	2000-01-01 00:00:00	2016-06-01 00:00:00	10255	10031	19	2017-01-18 17:14:47.242288	2017-01-18 17:14:47.242288
12605	2016-06-01 00:00:00	2016-09-01 00:00:00	10255	10030	16	2017-01-18 17:14:47.247857	2017-01-18 17:14:47.247857
12606	2016-06-01 00:00:00	2016-09-01 00:00:00	10255	10031	24	2017-01-18 17:14:47.252574	2017-01-18 17:14:47.252574
12607	2016-09-01 00:00:00	2017-01-01 00:00:00	10255	10030	26	2017-01-18 17:14:47.257754	2017-01-18 17:14:47.257754
12608	2016-09-01 00:00:00	2017-01-01 00:00:00	10255	10031	10	2017-01-18 17:14:47.262331	2017-01-18 17:14:47.262331
12609	2017-01-01 00:00:00	2100-01-01 00:00:00	10255	10030	22	2017-01-18 17:14:47.267629	2017-01-18 17:14:47.267629
12610	2017-01-01 00:00:00	2100-01-01 00:00:00	10255	10031	28	2017-01-18 17:14:47.272233	2017-01-18 17:14:47.272233
12611	2000-01-01 00:00:00	2016-06-01 00:00:00	10256	10030	15	2017-01-18 17:14:47.277446	2017-01-18 17:14:47.277446
12612	2000-01-01 00:00:00	2016-06-01 00:00:00	10256	10031	13	2017-01-18 17:14:47.282077	2017-01-18 17:14:47.282077
12613	2016-06-01 00:00:00	2016-09-01 00:00:00	10256	10030	14	2017-01-18 17:14:47.287619	2017-01-18 17:14:47.287619
12614	2016-06-01 00:00:00	2016-09-01 00:00:00	10256	10031	20	2017-01-18 17:14:47.292233	2017-01-18 17:14:47.292233
12615	2016-09-01 00:00:00	2017-01-01 00:00:00	10256	10030	15	2017-01-18 17:14:47.297404	2017-01-18 17:14:47.297404
12616	2016-09-01 00:00:00	2017-01-01 00:00:00	10256	10031	14	2017-01-18 17:14:47.302388	2017-01-18 17:14:47.302388
12617	2017-01-01 00:00:00	2100-01-01 00:00:00	10256	10030	12	2017-01-18 17:14:47.30827	2017-01-18 17:14:47.30827
12618	2017-01-01 00:00:00	2100-01-01 00:00:00	10256	10031	24	2017-01-18 17:14:47.312856	2017-01-18 17:14:47.312856
12619	2000-01-01 00:00:00	2016-06-01 00:00:00	10257	10030	28	2017-01-18 17:14:47.318568	2017-01-18 17:14:47.318568
12620	2000-01-01 00:00:00	2016-06-01 00:00:00	10257	10031	18	2017-01-18 17:14:47.323239	2017-01-18 17:14:47.323239
12621	2016-06-01 00:00:00	2016-09-01 00:00:00	10257	10030	19	2017-01-18 17:14:47.328465	2017-01-18 17:14:47.328465
12622	2016-06-01 00:00:00	2016-09-01 00:00:00	10257	10031	25	2017-01-18 17:14:47.333132	2017-01-18 17:14:47.333132
12623	2016-09-01 00:00:00	2017-01-01 00:00:00	10257	10030	28	2017-01-18 17:14:47.338592	2017-01-18 17:14:47.338592
12624	2016-09-01 00:00:00	2017-01-01 00:00:00	10257	10031	23	2017-01-18 17:14:47.343336	2017-01-18 17:14:47.343336
12625	2017-01-01 00:00:00	2100-01-01 00:00:00	10257	10030	17	2017-01-18 17:14:47.348653	2017-01-18 17:14:47.348653
12626	2017-01-01 00:00:00	2100-01-01 00:00:00	10257	10031	16	2017-01-18 17:14:47.353189	2017-01-18 17:14:47.353189
12627	2000-01-01 00:00:00	2016-06-01 00:00:00	10258	10030	22	2017-01-18 17:14:47.35843	2017-01-18 17:14:47.35843
12628	2000-01-01 00:00:00	2016-06-01 00:00:00	10258	10031	21	2017-01-18 17:14:47.36316	2017-01-18 17:14:47.36316
12629	2016-06-01 00:00:00	2016-09-01 00:00:00	10258	10030	27	2017-01-18 17:14:47.369188	2017-01-18 17:14:47.369188
12630	2016-06-01 00:00:00	2016-09-01 00:00:00	10258	10031	28	2017-01-18 17:14:47.373845	2017-01-18 17:14:47.373845
12631	2016-09-01 00:00:00	2017-01-01 00:00:00	10258	10030	21	2017-01-18 17:14:47.379332	2017-01-18 17:14:47.379332
12632	2016-09-01 00:00:00	2017-01-01 00:00:00	10258	10031	27	2017-01-18 17:14:47.384539	2017-01-18 17:14:47.384539
12633	2017-01-01 00:00:00	2100-01-01 00:00:00	10258	10030	23	2017-01-18 17:14:47.389865	2017-01-18 17:14:47.389865
12634	2017-01-01 00:00:00	2100-01-01 00:00:00	10258	10031	28	2017-01-18 17:14:47.39446	2017-01-18 17:14:47.39446
12635	2000-01-01 00:00:00	2016-06-01 00:00:00	10259	10030	16	2017-01-18 17:14:47.39968	2017-01-18 17:14:47.39968
12636	2000-01-01 00:00:00	2016-06-01 00:00:00	10259	10031	22	2017-01-18 17:14:47.404344	2017-01-18 17:14:47.404344
12637	2016-06-01 00:00:00	2016-09-01 00:00:00	10259	10030	12	2017-01-18 17:14:47.409273	2017-01-18 17:14:47.409273
12638	2016-06-01 00:00:00	2016-09-01 00:00:00	10259	10031	27	2017-01-18 17:14:47.413733	2017-01-18 17:14:47.413733
12639	2016-09-01 00:00:00	2017-01-01 00:00:00	10259	10030	26	2017-01-18 17:14:47.419666	2017-01-18 17:14:47.419666
12640	2016-09-01 00:00:00	2017-01-01 00:00:00	10259	10031	24	2017-01-18 17:14:47.424466	2017-01-18 17:14:47.424466
12641	2017-01-01 00:00:00	2100-01-01 00:00:00	10259	10030	14	2017-01-18 17:14:47.429684	2017-01-18 17:14:47.429684
12642	2017-01-01 00:00:00	2100-01-01 00:00:00	10259	10031	12	2017-01-18 17:14:47.434497	2017-01-18 17:14:47.434497
12643	2000-01-01 00:00:00	2016-06-01 00:00:00	10260	10030	25	2017-01-18 17:14:47.43985	2017-01-18 17:14:47.43985
12644	2000-01-01 00:00:00	2016-06-01 00:00:00	10260	10031	19	2017-01-18 17:14:47.444737	2017-01-18 17:14:47.444737
12645	2016-06-01 00:00:00	2016-09-01 00:00:00	10260	10030	11	2017-01-18 17:14:47.450398	2017-01-18 17:14:47.450398
12646	2016-06-01 00:00:00	2016-09-01 00:00:00	10260	10031	27	2017-01-18 17:14:47.455179	2017-01-18 17:14:47.455179
12647	2016-09-01 00:00:00	2017-01-01 00:00:00	10260	10030	10	2017-01-18 17:14:47.460403	2017-01-18 17:14:47.460403
12648	2016-09-01 00:00:00	2017-01-01 00:00:00	10260	10031	22	2017-01-18 17:14:47.465167	2017-01-18 17:14:47.465167
12649	2017-01-01 00:00:00	2100-01-01 00:00:00	10260	10030	23	2017-01-18 17:14:47.470571	2017-01-18 17:14:47.470571
12650	2017-01-01 00:00:00	2100-01-01 00:00:00	10260	10031	28	2017-01-18 17:14:47.475187	2017-01-18 17:14:47.475187
12651	2000-01-01 00:00:00	2016-06-01 00:00:00	10261	10030	28	2017-01-18 17:14:47.480475	2017-01-18 17:14:47.480475
12652	2000-01-01 00:00:00	2016-06-01 00:00:00	10261	10031	24	2017-01-18 17:14:47.48522	2017-01-18 17:14:47.48522
12653	2016-06-01 00:00:00	2016-09-01 00:00:00	10261	10030	28	2017-01-18 17:14:47.490747	2017-01-18 17:14:47.490747
12654	2016-06-01 00:00:00	2016-09-01 00:00:00	10261	10031	15	2017-01-18 17:14:47.495528	2017-01-18 17:14:47.495528
12655	2016-09-01 00:00:00	2017-01-01 00:00:00	10261	10030	21	2017-01-18 17:14:47.501223	2017-01-18 17:14:47.501223
12656	2016-09-01 00:00:00	2017-01-01 00:00:00	10261	10031	23	2017-01-18 17:14:47.506167	2017-01-18 17:14:47.506167
12657	2017-01-01 00:00:00	2100-01-01 00:00:00	10261	10030	12	2017-01-18 17:14:47.511859	2017-01-18 17:14:47.511859
12658	2017-01-01 00:00:00	2100-01-01 00:00:00	10261	10031	21	2017-01-18 17:14:47.516655	2017-01-18 17:14:47.516655
12659	2000-01-01 00:00:00	2016-06-01 00:00:00	10262	10030	16	2017-01-18 17:14:47.523203	2017-01-18 17:14:47.523203
12660	2000-01-01 00:00:00	2016-06-01 00:00:00	10262	10031	12	2017-01-18 17:14:47.528097	2017-01-18 17:14:47.528097
12661	2016-06-01 00:00:00	2016-09-01 00:00:00	10262	10030	20	2017-01-18 17:14:47.533458	2017-01-18 17:14:47.533458
12662	2016-06-01 00:00:00	2016-09-01 00:00:00	10262	10031	26	2017-01-18 17:14:47.538625	2017-01-18 17:14:47.538625
12663	2016-09-01 00:00:00	2017-01-01 00:00:00	10262	10030	12	2017-01-18 17:14:47.544078	2017-01-18 17:14:47.544078
12664	2016-09-01 00:00:00	2017-01-01 00:00:00	10262	10031	18	2017-01-18 17:14:47.548811	2017-01-18 17:14:47.548811
12665	2017-01-01 00:00:00	2100-01-01 00:00:00	10262	10030	21	2017-01-18 17:14:47.554596	2017-01-18 17:14:47.554596
12666	2017-01-01 00:00:00	2100-01-01 00:00:00	10262	10031	10	2017-01-18 17:14:47.559277	2017-01-18 17:14:47.559277
12667	2000-01-01 00:00:00	2016-06-01 00:00:00	10263	10030	24	2017-01-18 17:14:47.564307	2017-01-18 17:14:47.564307
12668	2000-01-01 00:00:00	2016-06-01 00:00:00	10263	10031	26	2017-01-18 17:14:47.568986	2017-01-18 17:14:47.568986
12669	2016-06-01 00:00:00	2016-09-01 00:00:00	10263	10030	22	2017-01-18 17:14:47.574328	2017-01-18 17:14:47.574328
12670	2016-06-01 00:00:00	2016-09-01 00:00:00	10263	10031	27	2017-01-18 17:14:47.579098	2017-01-18 17:14:47.579098
12671	2016-09-01 00:00:00	2017-01-01 00:00:00	10263	10030	10	2017-01-18 17:14:47.584643	2017-01-18 17:14:47.584643
12672	2016-09-01 00:00:00	2017-01-01 00:00:00	10263	10031	24	2017-01-18 17:14:47.58929	2017-01-18 17:14:47.58929
12673	2017-01-01 00:00:00	2100-01-01 00:00:00	10263	10030	15	2017-01-18 17:14:47.594448	2017-01-18 17:14:47.594448
12674	2017-01-01 00:00:00	2100-01-01 00:00:00	10263	10031	23	2017-01-18 17:14:47.598986	2017-01-18 17:14:47.598986
12675	2000-01-01 00:00:00	2016-06-01 00:00:00	10264	10030	11	2017-01-18 17:14:47.604366	2017-01-18 17:14:47.604366
12676	2000-01-01 00:00:00	2016-06-01 00:00:00	10264	10031	23	2017-01-18 17:14:47.608937	2017-01-18 17:14:47.608937
12677	2016-06-01 00:00:00	2016-09-01 00:00:00	10264	10030	14	2017-01-18 17:14:47.614085	2017-01-18 17:14:47.614085
12678	2016-06-01 00:00:00	2016-09-01 00:00:00	10264	10031	22	2017-01-18 17:14:47.619102	2017-01-18 17:14:47.619102
12679	2016-09-01 00:00:00	2017-01-01 00:00:00	10264	10030	18	2017-01-18 17:14:47.624213	2017-01-18 17:14:47.624213
12680	2016-09-01 00:00:00	2017-01-01 00:00:00	10264	10031	26	2017-01-18 17:14:47.6287	2017-01-18 17:14:47.6287
12681	2017-01-01 00:00:00	2100-01-01 00:00:00	10264	10030	10	2017-01-18 17:14:47.633953	2017-01-18 17:14:47.633953
12682	2017-01-01 00:00:00	2100-01-01 00:00:00	10264	10031	22	2017-01-18 17:14:47.639037	2017-01-18 17:14:47.639037
12683	2000-01-01 00:00:00	2016-06-01 00:00:00	10265	10030	22	2017-01-18 17:14:47.64435	2017-01-18 17:14:47.64435
12684	2000-01-01 00:00:00	2016-06-01 00:00:00	10265	10031	24	2017-01-18 17:14:47.649051	2017-01-18 17:14:47.649051
12685	2016-06-01 00:00:00	2016-09-01 00:00:00	10265	10030	24	2017-01-18 17:14:47.654405	2017-01-18 17:14:47.654405
12686	2016-06-01 00:00:00	2016-09-01 00:00:00	10265	10031	20	2017-01-18 17:14:47.659076	2017-01-18 17:14:47.659076
12687	2016-09-01 00:00:00	2017-01-01 00:00:00	10265	10030	28	2017-01-18 17:14:47.664051	2017-01-18 17:14:47.664051
12688	2016-09-01 00:00:00	2017-01-01 00:00:00	10265	10031	13	2017-01-18 17:14:47.668901	2017-01-18 17:14:47.668901
12689	2017-01-01 00:00:00	2100-01-01 00:00:00	10265	10030	19	2017-01-18 17:14:47.674582	2017-01-18 17:14:47.674582
12690	2017-01-01 00:00:00	2100-01-01 00:00:00	10265	10031	23	2017-01-18 17:14:47.679182	2017-01-18 17:14:47.679182
12691	2000-01-01 00:00:00	2016-06-01 00:00:00	10266	10030	13	2017-01-18 17:14:47.684463	2017-01-18 17:14:47.684463
12692	2000-01-01 00:00:00	2016-06-01 00:00:00	10266	10031	28	2017-01-18 17:14:47.689306	2017-01-18 17:14:47.689306
12693	2016-06-01 00:00:00	2016-09-01 00:00:00	10266	10030	25	2017-01-18 17:14:47.694782	2017-01-18 17:14:47.694782
12694	2016-06-01 00:00:00	2016-09-01 00:00:00	10266	10031	15	2017-01-18 17:14:47.69969	2017-01-18 17:14:47.69969
12695	2016-09-01 00:00:00	2017-01-01 00:00:00	10266	10030	25	2017-01-18 17:14:47.705364	2017-01-18 17:14:47.705364
12696	2016-09-01 00:00:00	2017-01-01 00:00:00	10266	10031	27	2017-01-18 17:14:47.709976	2017-01-18 17:14:47.709976
12697	2017-01-01 00:00:00	2100-01-01 00:00:00	10266	10030	27	2017-01-18 17:14:47.715255	2017-01-18 17:14:47.715255
12698	2017-01-01 00:00:00	2100-01-01 00:00:00	10266	10031	23	2017-01-18 17:14:47.720045	2017-01-18 17:14:47.720045
12699	2000-01-01 00:00:00	2016-06-01 00:00:00	10267	10030	19	2017-01-18 17:14:47.725565	2017-01-18 17:14:47.725565
12700	2000-01-01 00:00:00	2016-06-01 00:00:00	10267	10031	22	2017-01-18 17:14:47.730451	2017-01-18 17:14:47.730451
12701	2016-06-01 00:00:00	2016-09-01 00:00:00	10267	10030	21	2017-01-18 17:14:47.736451	2017-01-18 17:14:47.736451
12702	2016-06-01 00:00:00	2016-09-01 00:00:00	10267	10031	19	2017-01-18 17:14:47.741994	2017-01-18 17:14:47.741994
12703	2016-09-01 00:00:00	2017-01-01 00:00:00	10267	10030	21	2017-01-18 17:14:47.747362	2017-01-18 17:14:47.747362
12704	2016-09-01 00:00:00	2017-01-01 00:00:00	10267	10031	26	2017-01-18 17:14:47.752076	2017-01-18 17:14:47.752076
12705	2017-01-01 00:00:00	2100-01-01 00:00:00	10267	10030	20	2017-01-18 17:14:47.757573	2017-01-18 17:14:47.757573
12706	2017-01-01 00:00:00	2100-01-01 00:00:00	10267	10031	29	2017-01-18 17:14:47.762198	2017-01-18 17:14:47.762198
12707	2000-01-01 00:00:00	2016-06-01 00:00:00	10268	10030	25	2017-01-18 17:14:47.767872	2017-01-18 17:14:47.767872
12708	2000-01-01 00:00:00	2016-06-01 00:00:00	10268	10031	21	2017-01-18 17:14:47.772578	2017-01-18 17:14:47.772578
12709	2016-06-01 00:00:00	2016-09-01 00:00:00	10268	10030	23	2017-01-18 17:14:47.778149	2017-01-18 17:14:47.778149
12710	2016-06-01 00:00:00	2016-09-01 00:00:00	10268	10031	21	2017-01-18 17:14:47.782735	2017-01-18 17:14:47.782735
12711	2016-09-01 00:00:00	2017-01-01 00:00:00	10268	10030	16	2017-01-18 17:14:47.788078	2017-01-18 17:14:47.788078
12712	2016-09-01 00:00:00	2017-01-01 00:00:00	10268	10031	28	2017-01-18 17:14:47.792806	2017-01-18 17:14:47.792806
12713	2017-01-01 00:00:00	2100-01-01 00:00:00	10268	10030	28	2017-01-18 17:14:47.798471	2017-01-18 17:14:47.798471
12714	2017-01-01 00:00:00	2100-01-01 00:00:00	10268	10031	18	2017-01-18 17:14:47.803347	2017-01-18 17:14:47.803347
12715	2000-01-01 00:00:00	2016-06-01 00:00:00	10269	10030	14	2017-01-18 17:14:47.80857	2017-01-18 17:14:47.80857
12716	2000-01-01 00:00:00	2016-06-01 00:00:00	10269	10031	23	2017-01-18 17:14:47.813329	2017-01-18 17:14:47.813329
12717	2016-06-01 00:00:00	2016-09-01 00:00:00	10269	10030	13	2017-01-18 17:14:47.818763	2017-01-18 17:14:47.818763
12718	2016-06-01 00:00:00	2016-09-01 00:00:00	10269	10031	19	2017-01-18 17:14:47.823688	2017-01-18 17:14:47.823688
12719	2016-09-01 00:00:00	2017-01-01 00:00:00	10269	10030	12	2017-01-18 17:14:47.829455	2017-01-18 17:14:47.829455
12720	2016-09-01 00:00:00	2017-01-01 00:00:00	10269	10031	17	2017-01-18 17:14:47.834078	2017-01-18 17:14:47.834078
12721	2017-01-01 00:00:00	2100-01-01 00:00:00	10269	10030	20	2017-01-18 17:14:47.839533	2017-01-18 17:14:47.839533
12722	2017-01-01 00:00:00	2100-01-01 00:00:00	10269	10031	23	2017-01-18 17:14:47.844326	2017-01-18 17:14:47.844326
12723	2000-01-01 00:00:00	2016-06-01 00:00:00	10270	10030	13	2017-01-18 17:14:47.85014	2017-01-18 17:14:47.85014
12724	2000-01-01 00:00:00	2016-06-01 00:00:00	10270	10031	11	2017-01-18 17:14:47.855022	2017-01-18 17:14:47.855022
12725	2016-06-01 00:00:00	2016-09-01 00:00:00	10270	10030	12	2017-01-18 17:14:47.860603	2017-01-18 17:14:47.860603
12726	2016-06-01 00:00:00	2016-09-01 00:00:00	10270	10031	22	2017-01-18 17:14:47.865175	2017-01-18 17:14:47.865175
12727	2016-09-01 00:00:00	2017-01-01 00:00:00	10270	10030	28	2017-01-18 17:14:47.87033	2017-01-18 17:14:47.87033
12728	2016-09-01 00:00:00	2017-01-01 00:00:00	10270	10031	26	2017-01-18 17:14:47.8749	2017-01-18 17:14:47.8749
12729	2017-01-01 00:00:00	2100-01-01 00:00:00	10270	10030	13	2017-01-18 17:14:47.880024	2017-01-18 17:14:47.880024
12730	2017-01-01 00:00:00	2100-01-01 00:00:00	10270	10031	15	2017-01-18 17:14:47.884782	2017-01-18 17:14:47.884782
12731	2000-01-01 00:00:00	2016-06-01 00:00:00	10271	10030	21	2017-01-18 17:14:47.890165	2017-01-18 17:14:47.890165
12732	2000-01-01 00:00:00	2016-06-01 00:00:00	10271	10031	20	2017-01-18 17:14:47.895105	2017-01-18 17:14:47.895105
12733	2016-06-01 00:00:00	2016-09-01 00:00:00	10271	10030	11	2017-01-18 17:14:47.900514	2017-01-18 17:14:47.900514
12734	2016-06-01 00:00:00	2016-09-01 00:00:00	10271	10031	23	2017-01-18 17:14:47.905115	2017-01-18 17:14:47.905115
12735	2016-09-01 00:00:00	2017-01-01 00:00:00	10271	10030	26	2017-01-18 17:14:47.910844	2017-01-18 17:14:47.910844
12736	2016-09-01 00:00:00	2017-01-01 00:00:00	10271	10031	15	2017-01-18 17:14:47.915412	2017-01-18 17:14:47.915412
12737	2017-01-01 00:00:00	2100-01-01 00:00:00	10271	10030	19	2017-01-18 17:14:47.921175	2017-01-18 17:14:47.921175
12738	2017-01-01 00:00:00	2100-01-01 00:00:00	10271	10031	11	2017-01-18 17:14:47.926045	2017-01-18 17:14:47.926045
12739	2000-01-01 00:00:00	2016-06-01 00:00:00	10272	10030	16	2017-01-18 17:14:47.931465	2017-01-18 17:14:47.931465
12740	2000-01-01 00:00:00	2016-06-01 00:00:00	10272	10031	29	2017-01-18 17:14:47.936084	2017-01-18 17:14:47.936084
12741	2016-06-01 00:00:00	2016-09-01 00:00:00	10272	10030	19	2017-01-18 17:14:47.941953	2017-01-18 17:14:47.941953
12742	2016-06-01 00:00:00	2016-09-01 00:00:00	10272	10031	19	2017-01-18 17:14:47.946996	2017-01-18 17:14:47.946996
12743	2016-09-01 00:00:00	2017-01-01 00:00:00	10272	10030	12	2017-01-18 17:14:47.952978	2017-01-18 17:14:47.952978
12744	2016-09-01 00:00:00	2017-01-01 00:00:00	10272	10031	13	2017-01-18 17:14:47.957697	2017-01-18 17:14:47.957697
12745	2017-01-01 00:00:00	2100-01-01 00:00:00	10272	10030	19	2017-01-18 17:14:47.96372	2017-01-18 17:14:47.96372
12746	2017-01-01 00:00:00	2100-01-01 00:00:00	10272	10031	26	2017-01-18 17:14:47.968435	2017-01-18 17:14:47.968435
12747	2000-01-01 00:00:00	2016-06-01 00:00:00	10273	10030	28	2017-01-18 17:14:47.973602	2017-01-18 17:14:47.973602
12748	2000-01-01 00:00:00	2016-06-01 00:00:00	10273	10031	12	2017-01-18 17:14:47.978269	2017-01-18 17:14:47.978269
12749	2016-06-01 00:00:00	2016-09-01 00:00:00	10273	10030	14	2017-01-18 17:14:47.98373	2017-01-18 17:14:47.98373
12750	2016-06-01 00:00:00	2016-09-01 00:00:00	10273	10031	26	2017-01-18 17:14:47.988637	2017-01-18 17:14:47.988637
12751	2016-09-01 00:00:00	2017-01-01 00:00:00	10273	10030	17	2017-01-18 17:14:47.995066	2017-01-18 17:14:47.995066
12752	2016-09-01 00:00:00	2017-01-01 00:00:00	10273	10031	19	2017-01-18 17:14:48.000018	2017-01-18 17:14:48.000018
12753	2017-01-01 00:00:00	2100-01-01 00:00:00	10273	10030	19	2017-01-18 17:14:48.005912	2017-01-18 17:14:48.005912
12754	2017-01-01 00:00:00	2100-01-01 00:00:00	10273	10031	10	2017-01-18 17:14:48.010749	2017-01-18 17:14:48.010749
12755	2000-01-01 00:00:00	2016-06-01 00:00:00	10274	10030	24	2017-01-18 17:14:48.015547	2017-01-18 17:14:48.015547
12756	2000-01-01 00:00:00	2016-06-01 00:00:00	10274	10031	22	2017-01-18 17:14:48.022435	2017-01-18 17:14:48.022435
12757	2016-06-01 00:00:00	2016-09-01 00:00:00	10274	10030	24	2017-01-18 17:14:48.027974	2017-01-18 17:14:48.027974
12758	2016-06-01 00:00:00	2016-09-01 00:00:00	10274	10031	29	2017-01-18 17:14:48.032624	2017-01-18 17:14:48.032624
12759	2016-09-01 00:00:00	2017-01-01 00:00:00	10274	10030	17	2017-01-18 17:14:48.038051	2017-01-18 17:14:48.038051
12760	2016-09-01 00:00:00	2017-01-01 00:00:00	10274	10031	22	2017-01-18 17:14:48.042909	2017-01-18 17:14:48.042909
12761	2017-01-01 00:00:00	2100-01-01 00:00:00	10274	10030	26	2017-01-18 17:14:48.048684	2017-01-18 17:14:48.048684
12762	2017-01-01 00:00:00	2100-01-01 00:00:00	10274	10031	11	2017-01-18 17:14:48.053554	2017-01-18 17:14:48.053554
12763	2000-01-01 00:00:00	2016-06-01 00:00:00	10275	10030	22	2017-01-18 17:14:48.058936	2017-01-18 17:14:48.058936
12764	2000-01-01 00:00:00	2016-06-01 00:00:00	10275	10031	11	2017-01-18 17:14:48.06384	2017-01-18 17:14:48.06384
12765	2016-06-01 00:00:00	2016-09-01 00:00:00	10275	10030	22	2017-01-18 17:14:48.069237	2017-01-18 17:14:48.069237
12766	2016-06-01 00:00:00	2016-09-01 00:00:00	10275	10031	22	2017-01-18 17:14:48.073978	2017-01-18 17:14:48.073978
12767	2016-09-01 00:00:00	2017-01-01 00:00:00	10275	10030	20	2017-01-18 17:14:48.079702	2017-01-18 17:14:48.079702
12768	2016-09-01 00:00:00	2017-01-01 00:00:00	10275	10031	11	2017-01-18 17:14:48.084799	2017-01-18 17:14:48.084799
12769	2017-01-01 00:00:00	2100-01-01 00:00:00	10275	10030	19	2017-01-18 17:14:48.090293	2017-01-18 17:14:48.090293
12770	2017-01-01 00:00:00	2100-01-01 00:00:00	10275	10031	24	2017-01-18 17:14:48.094972	2017-01-18 17:14:48.094972
12771	2000-01-01 00:00:00	2016-06-01 00:00:00	10276	10030	20	2017-01-18 17:14:48.100239	2017-01-18 17:14:48.100239
12772	2000-01-01 00:00:00	2016-06-01 00:00:00	10276	10031	11	2017-01-18 17:14:48.104853	2017-01-18 17:14:48.104853
12773	2016-06-01 00:00:00	2016-09-01 00:00:00	10276	10030	14	2017-01-18 17:14:48.110501	2017-01-18 17:14:48.110501
12774	2016-06-01 00:00:00	2016-09-01 00:00:00	10276	10031	10	2017-01-18 17:14:48.115222	2017-01-18 17:14:48.115222
12775	2016-09-01 00:00:00	2017-01-01 00:00:00	10276	10030	10	2017-01-18 17:14:48.120657	2017-01-18 17:14:48.120657
12776	2016-09-01 00:00:00	2017-01-01 00:00:00	10276	10031	20	2017-01-18 17:14:48.125373	2017-01-18 17:14:48.125373
12777	2017-01-01 00:00:00	2100-01-01 00:00:00	10276	10030	27	2017-01-18 17:14:48.130675	2017-01-18 17:14:48.130675
12778	2017-01-01 00:00:00	2100-01-01 00:00:00	10276	10031	25	2017-01-18 17:14:48.135402	2017-01-18 17:14:48.135402
12779	2000-01-01 00:00:00	2016-06-01 00:00:00	10277	10030	28	2017-01-18 17:14:48.140689	2017-01-18 17:14:48.140689
12780	2000-01-01 00:00:00	2016-06-01 00:00:00	10277	10031	15	2017-01-18 17:14:48.145318	2017-01-18 17:14:48.145318
12781	2016-06-01 00:00:00	2016-09-01 00:00:00	10277	10030	14	2017-01-18 17:14:48.151146	2017-01-18 17:14:48.151146
12782	2016-06-01 00:00:00	2016-09-01 00:00:00	10277	10031	18	2017-01-18 17:14:48.155858	2017-01-18 17:14:48.155858
12783	2016-09-01 00:00:00	2017-01-01 00:00:00	10277	10030	12	2017-01-18 17:14:48.161511	2017-01-18 17:14:48.161511
12784	2016-09-01 00:00:00	2017-01-01 00:00:00	10277	10031	24	2017-01-18 17:14:48.16615	2017-01-18 17:14:48.16615
12785	2017-01-01 00:00:00	2100-01-01 00:00:00	10277	10030	28	2017-01-18 17:14:48.171613	2017-01-18 17:14:48.171613
12786	2017-01-01 00:00:00	2100-01-01 00:00:00	10277	10031	19	2017-01-18 17:14:48.176407	2017-01-18 17:14:48.176407
12787	2000-01-01 00:00:00	2016-06-01 00:00:00	10278	10030	25	2017-01-18 17:14:48.181568	2017-01-18 17:14:48.181568
12788	2000-01-01 00:00:00	2016-06-01 00:00:00	10278	10031	25	2017-01-18 17:14:48.186739	2017-01-18 17:14:48.186739
12789	2016-06-01 00:00:00	2016-09-01 00:00:00	10278	10030	17	2017-01-18 17:14:48.191927	2017-01-18 17:14:48.191927
12790	2016-06-01 00:00:00	2016-09-01 00:00:00	10278	10031	24	2017-01-18 17:14:48.197	2017-01-18 17:14:48.197
12791	2016-09-01 00:00:00	2017-01-01 00:00:00	10278	10030	14	2017-01-18 17:14:48.202439	2017-01-18 17:14:48.202439
12792	2016-09-01 00:00:00	2017-01-01 00:00:00	10278	10031	22	2017-01-18 17:14:48.207062	2017-01-18 17:14:48.207062
12793	2017-01-01 00:00:00	2100-01-01 00:00:00	10278	10030	20	2017-01-18 17:14:48.212627	2017-01-18 17:14:48.212627
12794	2017-01-01 00:00:00	2100-01-01 00:00:00	10278	10031	19	2017-01-18 17:14:48.217324	2017-01-18 17:14:48.217324
12795	2000-01-01 00:00:00	2016-06-01 00:00:00	10279	10030	14	2017-01-18 17:14:48.222976	2017-01-18 17:14:48.222976
12796	2000-01-01 00:00:00	2016-06-01 00:00:00	10279	10031	16	2017-01-18 17:14:48.227879	2017-01-18 17:14:48.227879
12797	2016-06-01 00:00:00	2016-09-01 00:00:00	10279	10030	19	2017-01-18 17:14:48.233225	2017-01-18 17:14:48.233225
12798	2016-06-01 00:00:00	2016-09-01 00:00:00	10279	10031	23	2017-01-18 17:14:48.237994	2017-01-18 17:14:48.237994
12799	2016-09-01 00:00:00	2017-01-01 00:00:00	10279	10030	17	2017-01-18 17:14:48.243545	2017-01-18 17:14:48.243545
12800	2016-09-01 00:00:00	2017-01-01 00:00:00	10279	10031	11	2017-01-18 17:14:48.248141	2017-01-18 17:14:48.248141
12801	2017-01-01 00:00:00	2100-01-01 00:00:00	10279	10030	15	2017-01-18 17:14:48.253423	2017-01-18 17:14:48.253423
12802	2017-01-01 00:00:00	2100-01-01 00:00:00	10279	10031	27	2017-01-18 17:14:48.258285	2017-01-18 17:14:48.258285
12803	2000-01-01 00:00:00	2016-06-01 00:00:00	10280	10030	24	2017-01-18 17:14:48.2637	2017-01-18 17:14:48.2637
12804	2000-01-01 00:00:00	2016-06-01 00:00:00	10280	10031	16	2017-01-18 17:14:48.268733	2017-01-18 17:14:48.268733
12805	2016-06-01 00:00:00	2016-09-01 00:00:00	10280	10030	19	2017-01-18 17:14:48.27397	2017-01-18 17:14:48.27397
12806	2016-06-01 00:00:00	2016-09-01 00:00:00	10280	10031	19	2017-01-18 17:14:48.278792	2017-01-18 17:14:48.278792
12807	2016-09-01 00:00:00	2017-01-01 00:00:00	10280	10030	12	2017-01-18 17:14:48.284362	2017-01-18 17:14:48.284362
12808	2016-09-01 00:00:00	2017-01-01 00:00:00	10280	10031	22	2017-01-18 17:14:48.289088	2017-01-18 17:14:48.289088
12809	2017-01-01 00:00:00	2100-01-01 00:00:00	10280	10030	13	2017-01-18 17:14:48.294474	2017-01-18 17:14:48.294474
12810	2017-01-01 00:00:00	2100-01-01 00:00:00	10280	10031	17	2017-01-18 17:14:48.299146	2017-01-18 17:14:48.299146
12811	2000-01-01 00:00:00	2016-06-01 00:00:00	10281	10030	15	2017-01-18 17:14:48.304591	2017-01-18 17:14:48.304591
12812	2000-01-01 00:00:00	2016-06-01 00:00:00	10281	10031	20	2017-01-18 17:14:48.309293	2017-01-18 17:14:48.309293
12813	2016-06-01 00:00:00	2016-09-01 00:00:00	10281	10030	27	2017-01-18 17:14:48.314438	2017-01-18 17:14:48.314438
12814	2016-06-01 00:00:00	2016-09-01 00:00:00	10281	10031	24	2017-01-18 17:14:48.319125	2017-01-18 17:14:48.319125
12815	2016-09-01 00:00:00	2017-01-01 00:00:00	10281	10030	13	2017-01-18 17:14:48.324729	2017-01-18 17:14:48.324729
12816	2016-09-01 00:00:00	2017-01-01 00:00:00	10281	10031	13	2017-01-18 17:14:48.32931	2017-01-18 17:14:48.32931
12817	2017-01-01 00:00:00	2100-01-01 00:00:00	10281	10030	27	2017-01-18 17:14:48.334515	2017-01-18 17:14:48.334515
12818	2017-01-01 00:00:00	2100-01-01 00:00:00	10281	10031	27	2017-01-18 17:14:48.339192	2017-01-18 17:14:48.339192
12819	2000-01-01 00:00:00	2016-06-01 00:00:00	10282	10030	12	2017-01-18 17:14:48.34483	2017-01-18 17:14:48.34483
12820	2000-01-01 00:00:00	2016-06-01 00:00:00	10282	10031	23	2017-01-18 17:14:48.34982	2017-01-18 17:14:48.34982
12821	2016-06-01 00:00:00	2016-09-01 00:00:00	10282	10030	14	2017-01-18 17:14:48.355768	2017-01-18 17:14:48.355768
12822	2016-06-01 00:00:00	2016-09-01 00:00:00	10282	10031	12	2017-01-18 17:14:48.360439	2017-01-18 17:14:48.360439
12823	2016-09-01 00:00:00	2017-01-01 00:00:00	10282	10030	21	2017-01-18 17:14:48.365859	2017-01-18 17:14:48.365859
12824	2016-09-01 00:00:00	2017-01-01 00:00:00	10282	10031	23	2017-01-18 17:14:48.371381	2017-01-18 17:14:48.371381
12825	2017-01-01 00:00:00	2100-01-01 00:00:00	10282	10030	21	2017-01-18 17:14:48.376614	2017-01-18 17:14:48.376614
12826	2017-01-01 00:00:00	2100-01-01 00:00:00	10282	10031	27	2017-01-18 17:14:48.381499	2017-01-18 17:14:48.381499
12827	2000-01-01 00:00:00	2016-06-01 00:00:00	10283	10030	15	2017-01-18 17:14:48.387373	2017-01-18 17:14:48.387373
12828	2000-01-01 00:00:00	2016-06-01 00:00:00	10283	10031	17	2017-01-18 17:14:48.392029	2017-01-18 17:14:48.392029
12829	2016-06-01 00:00:00	2016-09-01 00:00:00	10283	10030	15	2017-01-18 17:14:48.397655	2017-01-18 17:14:48.397655
12830	2016-06-01 00:00:00	2016-09-01 00:00:00	10283	10031	16	2017-01-18 17:14:48.402889	2017-01-18 17:14:48.402889
12831	2016-09-01 00:00:00	2017-01-01 00:00:00	10283	10030	19	2017-01-18 17:14:48.408458	2017-01-18 17:14:48.408458
12832	2016-09-01 00:00:00	2017-01-01 00:00:00	10283	10031	10	2017-01-18 17:14:48.413192	2017-01-18 17:14:48.413192
12833	2017-01-01 00:00:00	2100-01-01 00:00:00	10283	10030	26	2017-01-18 17:14:48.418583	2017-01-18 17:14:48.418583
12834	2017-01-01 00:00:00	2100-01-01 00:00:00	10283	10031	21	2017-01-18 17:14:48.42334	2017-01-18 17:14:48.42334
12835	2000-01-01 00:00:00	2016-06-01 00:00:00	10284	10030	18	2017-01-18 17:14:48.428865	2017-01-18 17:14:48.428865
12836	2000-01-01 00:00:00	2016-06-01 00:00:00	10284	10031	24	2017-01-18 17:14:48.43367	2017-01-18 17:14:48.43367
12837	2016-06-01 00:00:00	2016-09-01 00:00:00	10284	10030	10	2017-01-18 17:14:48.439169	2017-01-18 17:14:48.439169
12838	2016-06-01 00:00:00	2016-09-01 00:00:00	10284	10031	23	2017-01-18 17:14:48.4439	2017-01-18 17:14:48.4439
12839	2016-09-01 00:00:00	2017-01-01 00:00:00	10284	10030	25	2017-01-18 17:14:48.449474	2017-01-18 17:14:48.449474
12840	2016-09-01 00:00:00	2017-01-01 00:00:00	10284	10031	20	2017-01-18 17:14:48.454213	2017-01-18 17:14:48.454213
12841	2017-01-01 00:00:00	2100-01-01 00:00:00	10284	10030	10	2017-01-18 17:14:48.459524	2017-01-18 17:14:48.459524
12842	2017-01-01 00:00:00	2100-01-01 00:00:00	10284	10031	15	2017-01-18 17:14:48.464108	2017-01-18 17:14:48.464108
12843	2000-01-01 00:00:00	2016-06-01 00:00:00	10285	10030	22	2017-01-18 17:14:48.469196	2017-01-18 17:14:48.469196
12844	2000-01-01 00:00:00	2016-06-01 00:00:00	10285	10031	23	2017-01-18 17:14:48.47369	2017-01-18 17:14:48.47369
12845	2016-06-01 00:00:00	2016-09-01 00:00:00	10285	10030	18	2017-01-18 17:14:48.479278	2017-01-18 17:14:48.479278
12846	2016-06-01 00:00:00	2016-09-01 00:00:00	10285	10031	24	2017-01-18 17:14:48.484065	2017-01-18 17:14:48.484065
12847	2016-09-01 00:00:00	2017-01-01 00:00:00	10285	10030	19	2017-01-18 17:14:48.489629	2017-01-18 17:14:48.489629
12848	2016-09-01 00:00:00	2017-01-01 00:00:00	10285	10031	29	2017-01-18 17:14:48.494284	2017-01-18 17:14:48.494284
12849	2017-01-01 00:00:00	2100-01-01 00:00:00	10285	10030	18	2017-01-18 17:14:48.500049	2017-01-18 17:14:48.500049
12850	2017-01-01 00:00:00	2100-01-01 00:00:00	10285	10031	12	2017-01-18 17:14:48.505241	2017-01-18 17:14:48.505241
12851	2000-01-01 00:00:00	2016-06-01 00:00:00	10286	10030	17	2017-01-18 17:14:48.511108	2017-01-18 17:14:48.511108
12852	2000-01-01 00:00:00	2016-06-01 00:00:00	10286	10031	26	2017-01-18 17:14:48.515728	2017-01-18 17:14:48.515728
12853	2016-06-01 00:00:00	2016-09-01 00:00:00	10286	10030	25	2017-01-18 17:14:48.521609	2017-01-18 17:14:48.521609
12854	2016-06-01 00:00:00	2016-09-01 00:00:00	10286	10031	28	2017-01-18 17:14:48.52636	2017-01-18 17:14:48.52636
12855	2016-09-01 00:00:00	2017-01-01 00:00:00	10286	10030	13	2017-01-18 17:14:48.531604	2017-01-18 17:14:48.531604
12856	2016-09-01 00:00:00	2017-01-01 00:00:00	10286	10031	26	2017-01-18 17:14:48.53637	2017-01-18 17:14:48.53637
12857	2017-01-01 00:00:00	2100-01-01 00:00:00	10286	10030	27	2017-01-18 17:14:48.541737	2017-01-18 17:14:48.541737
12858	2017-01-01 00:00:00	2100-01-01 00:00:00	10286	10031	20	2017-01-18 17:14:48.546265	2017-01-18 17:14:48.546265
12859	2000-01-01 00:00:00	2016-06-01 00:00:00	10287	10030	13	2017-01-18 17:14:48.551467	2017-01-18 17:14:48.551467
12860	2000-01-01 00:00:00	2016-06-01 00:00:00	10287	10031	19	2017-01-18 17:14:48.5562	2017-01-18 17:14:48.5562
12861	2016-06-01 00:00:00	2016-09-01 00:00:00	10287	10030	25	2017-01-18 17:14:48.561362	2017-01-18 17:14:48.561362
12862	2016-06-01 00:00:00	2016-09-01 00:00:00	10287	10031	15	2017-01-18 17:14:48.565999	2017-01-18 17:14:48.565999
12863	2016-09-01 00:00:00	2017-01-01 00:00:00	10287	10030	27	2017-01-18 17:14:48.571634	2017-01-18 17:14:48.571634
12864	2016-09-01 00:00:00	2017-01-01 00:00:00	10287	10031	10	2017-01-18 17:14:48.57632	2017-01-18 17:14:48.57632
12865	2017-01-01 00:00:00	2100-01-01 00:00:00	10287	10030	23	2017-01-18 17:14:48.581527	2017-01-18 17:14:48.581527
12866	2017-01-01 00:00:00	2100-01-01 00:00:00	10287	10031	29	2017-01-18 17:14:48.586258	2017-01-18 17:14:48.586258
12867	2000-01-01 00:00:00	2016-06-01 00:00:00	10288	10030	16	2017-01-18 17:14:48.591742	2017-01-18 17:14:48.591742
12868	2000-01-01 00:00:00	2016-06-01 00:00:00	10288	10031	23	2017-01-18 17:14:48.596676	2017-01-18 17:14:48.596676
12869	2016-06-01 00:00:00	2016-09-01 00:00:00	10288	10030	23	2017-01-18 17:14:48.602444	2017-01-18 17:14:48.602444
12870	2016-06-01 00:00:00	2016-09-01 00:00:00	10288	10031	21	2017-01-18 17:14:48.607051	2017-01-18 17:14:48.607051
12871	2016-09-01 00:00:00	2017-01-01 00:00:00	10288	10030	21	2017-01-18 17:14:48.612673	2017-01-18 17:14:48.612673
12872	2016-09-01 00:00:00	2017-01-01 00:00:00	10288	10031	27	2017-01-18 17:14:48.617503	2017-01-18 17:14:48.617503
12873	2017-01-01 00:00:00	2100-01-01 00:00:00	10288	10030	17	2017-01-18 17:14:48.623703	2017-01-18 17:14:48.623703
12874	2017-01-01 00:00:00	2100-01-01 00:00:00	10288	10031	29	2017-01-18 17:14:48.628342	2017-01-18 17:14:48.628342
12875	2000-01-01 00:00:00	2016-06-01 00:00:00	10289	10030	22	2017-01-18 17:14:48.633587	2017-01-18 17:14:48.633587
12876	2000-01-01 00:00:00	2016-06-01 00:00:00	10289	10031	23	2017-01-18 17:14:48.638564	2017-01-18 17:14:48.638564
12877	2016-06-01 00:00:00	2016-09-01 00:00:00	10289	10030	19	2017-01-18 17:14:48.643939	2017-01-18 17:14:48.643939
12878	2016-06-01 00:00:00	2016-09-01 00:00:00	10289	10031	28	2017-01-18 17:14:48.648933	2017-01-18 17:14:48.648933
12879	2016-09-01 00:00:00	2017-01-01 00:00:00	10289	10030	16	2017-01-18 17:14:48.654558	2017-01-18 17:14:48.654558
12880	2016-09-01 00:00:00	2017-01-01 00:00:00	10289	10031	26	2017-01-18 17:14:48.659081	2017-01-18 17:14:48.659081
12881	2017-01-01 00:00:00	2100-01-01 00:00:00	10289	10030	19	2017-01-18 17:14:48.664701	2017-01-18 17:14:48.664701
12882	2017-01-01 00:00:00	2100-01-01 00:00:00	10289	10031	12	2017-01-18 17:14:48.669628	2017-01-18 17:14:48.669628
12883	2000-01-01 00:00:00	2016-06-01 00:00:00	10290	10030	13	2017-01-18 17:14:48.675092	2017-01-18 17:14:48.675092
12884	2000-01-01 00:00:00	2016-06-01 00:00:00	10290	10031	11	2017-01-18 17:14:48.679857	2017-01-18 17:14:48.679857
12885	2016-06-01 00:00:00	2016-09-01 00:00:00	10290	10030	23	2017-01-18 17:14:48.685445	2017-01-18 17:14:48.685445
12886	2016-06-01 00:00:00	2016-09-01 00:00:00	10290	10031	28	2017-01-18 17:14:48.690125	2017-01-18 17:14:48.690125
12887	2016-09-01 00:00:00	2017-01-01 00:00:00	10290	10030	22	2017-01-18 17:14:48.695495	2017-01-18 17:14:48.695495
12888	2016-09-01 00:00:00	2017-01-01 00:00:00	10290	10031	16	2017-01-18 17:14:48.699883	2017-01-18 17:14:48.699883
12889	2017-01-01 00:00:00	2100-01-01 00:00:00	10290	10030	19	2017-01-18 17:14:48.705397	2017-01-18 17:14:48.705397
12890	2017-01-01 00:00:00	2100-01-01 00:00:00	10290	10031	24	2017-01-18 17:14:48.710253	2017-01-18 17:14:48.710253
12891	2000-01-01 00:00:00	2016-06-01 00:00:00	10291	10030	18	2017-01-18 17:14:48.71566	2017-01-18 17:14:48.71566
12892	2000-01-01 00:00:00	2016-06-01 00:00:00	10291	10031	28	2017-01-18 17:14:48.72025	2017-01-18 17:14:48.72025
12893	2016-06-01 00:00:00	2016-09-01 00:00:00	10291	10030	15	2017-01-18 17:14:48.725419	2017-01-18 17:14:48.725419
12894	2016-06-01 00:00:00	2016-09-01 00:00:00	10291	10031	16	2017-01-18 17:14:48.730205	2017-01-18 17:14:48.730205
12895	2016-09-01 00:00:00	2017-01-01 00:00:00	10291	10030	20	2017-01-18 17:14:48.735649	2017-01-18 17:14:48.735649
12896	2016-09-01 00:00:00	2017-01-01 00:00:00	10291	10031	22	2017-01-18 17:14:48.740261	2017-01-18 17:14:48.740261
12897	2017-01-01 00:00:00	2100-01-01 00:00:00	10291	10030	12	2017-01-18 17:14:48.745527	2017-01-18 17:14:48.745527
12898	2017-01-01 00:00:00	2100-01-01 00:00:00	10291	10031	17	2017-01-18 17:14:48.750163	2017-01-18 17:14:48.750163
12899	2000-01-01 00:00:00	2016-06-01 00:00:00	10292	10030	15	2017-01-18 17:14:48.755507	2017-01-18 17:14:48.755507
12900	2000-01-01 00:00:00	2016-06-01 00:00:00	10292	10031	26	2017-01-18 17:14:48.760984	2017-01-18 17:14:48.760984
12901	2016-06-01 00:00:00	2016-09-01 00:00:00	10292	10030	13	2017-01-18 17:14:48.766698	2017-01-18 17:14:48.766698
12902	2016-06-01 00:00:00	2016-09-01 00:00:00	10292	10031	17	2017-01-18 17:14:48.771364	2017-01-18 17:14:48.771364
12903	2016-09-01 00:00:00	2017-01-01 00:00:00	10292	10030	12	2017-01-18 17:14:48.776946	2017-01-18 17:14:48.776946
12904	2016-09-01 00:00:00	2017-01-01 00:00:00	10292	10031	21	2017-01-18 17:14:48.781921	2017-01-18 17:14:48.781921
12905	2017-01-01 00:00:00	2100-01-01 00:00:00	10292	10030	11	2017-01-18 17:14:48.787583	2017-01-18 17:14:48.787583
12906	2017-01-01 00:00:00	2100-01-01 00:00:00	10292	10031	19	2017-01-18 17:14:48.792487	2017-01-18 17:14:48.792487
12907	2000-01-01 00:00:00	2016-06-01 00:00:00	10293	10030	28	2017-01-18 17:14:48.797921	2017-01-18 17:14:48.797921
12908	2000-01-01 00:00:00	2016-06-01 00:00:00	10293	10031	18	2017-01-18 17:14:48.802873	2017-01-18 17:14:48.802873
12909	2016-06-01 00:00:00	2016-09-01 00:00:00	10293	10030	11	2017-01-18 17:14:48.808475	2017-01-18 17:14:48.808475
12910	2016-06-01 00:00:00	2016-09-01 00:00:00	10293	10031	15	2017-01-18 17:14:48.813013	2017-01-18 17:14:48.813013
12911	2016-09-01 00:00:00	2017-01-01 00:00:00	10293	10030	29	2017-01-18 17:14:48.818206	2017-01-18 17:14:48.818206
12912	2016-09-01 00:00:00	2017-01-01 00:00:00	10293	10031	20	2017-01-18 17:14:48.823133	2017-01-18 17:14:48.823133
12913	2017-01-01 00:00:00	2100-01-01 00:00:00	10293	10030	26	2017-01-18 17:14:48.828579	2017-01-18 17:14:48.828579
12914	2017-01-01 00:00:00	2100-01-01 00:00:00	10293	10031	17	2017-01-18 17:14:48.833173	2017-01-18 17:14:48.833173
12915	2000-01-01 00:00:00	2016-06-01 00:00:00	10294	10030	29	2017-01-18 17:14:48.839143	2017-01-18 17:14:48.839143
12916	2000-01-01 00:00:00	2016-06-01 00:00:00	10294	10031	20	2017-01-18 17:14:48.843873	2017-01-18 17:14:48.843873
12917	2016-06-01 00:00:00	2016-09-01 00:00:00	10294	10030	20	2017-01-18 17:14:48.84936	2017-01-18 17:14:48.84936
12918	2016-06-01 00:00:00	2016-09-01 00:00:00	10294	10031	20	2017-01-18 17:14:48.854563	2017-01-18 17:14:48.854563
12919	2016-09-01 00:00:00	2017-01-01 00:00:00	10294	10030	14	2017-01-18 17:14:48.860553	2017-01-18 17:14:48.860553
12920	2016-09-01 00:00:00	2017-01-01 00:00:00	10294	10031	16	2017-01-18 17:14:48.865157	2017-01-18 17:14:48.865157
12921	2017-01-01 00:00:00	2100-01-01 00:00:00	10294	10030	13	2017-01-18 17:14:48.871249	2017-01-18 17:14:48.871249
12922	2017-01-01 00:00:00	2100-01-01 00:00:00	10294	10031	18	2017-01-18 17:14:48.876137	2017-01-18 17:14:48.876137
12923	2000-01-01 00:00:00	2016-06-01 00:00:00	10295	10030	14	2017-01-18 17:14:48.881866	2017-01-18 17:14:48.881866
12924	2000-01-01 00:00:00	2016-06-01 00:00:00	10295	10031	18	2017-01-18 17:14:48.886715	2017-01-18 17:14:48.886715
12925	2016-06-01 00:00:00	2016-09-01 00:00:00	10295	10030	12	2017-01-18 17:14:48.892242	2017-01-18 17:14:48.892242
12926	2016-06-01 00:00:00	2016-09-01 00:00:00	10295	10031	18	2017-01-18 17:14:48.897019	2017-01-18 17:14:48.897019
12927	2016-09-01 00:00:00	2017-01-01 00:00:00	10295	10030	12	2017-01-18 17:14:48.902507	2017-01-18 17:14:48.902507
12928	2016-09-01 00:00:00	2017-01-01 00:00:00	10295	10031	29	2017-01-18 17:14:48.907196	2017-01-18 17:14:48.907196
12929	2017-01-01 00:00:00	2100-01-01 00:00:00	10295	10030	12	2017-01-18 17:14:48.912202	2017-01-18 17:14:48.912202
12930	2017-01-01 00:00:00	2100-01-01 00:00:00	10295	10031	22	2017-01-18 17:14:48.917089	2017-01-18 17:14:48.917089
12931	2000-01-01 00:00:00	2016-06-01 00:00:00	10296	10030	26	2017-01-18 17:14:48.922385	2017-01-18 17:14:48.922385
12932	2000-01-01 00:00:00	2016-06-01 00:00:00	10296	10031	20	2017-01-18 17:14:48.927207	2017-01-18 17:14:48.927207
12933	2016-06-01 00:00:00	2016-09-01 00:00:00	10296	10030	12	2017-01-18 17:14:48.932738	2017-01-18 17:14:48.932738
12934	2016-06-01 00:00:00	2016-09-01 00:00:00	10296	10031	21	2017-01-18 17:14:48.937382	2017-01-18 17:14:48.937382
12935	2016-09-01 00:00:00	2017-01-01 00:00:00	10296	10030	26	2017-01-18 17:14:48.942783	2017-01-18 17:14:48.942783
12936	2016-09-01 00:00:00	2017-01-01 00:00:00	10296	10031	24	2017-01-18 17:14:48.947698	2017-01-18 17:14:48.947698
12937	2017-01-01 00:00:00	2100-01-01 00:00:00	10296	10030	28	2017-01-18 17:14:48.953205	2017-01-18 17:14:48.953205
12938	2017-01-01 00:00:00	2100-01-01 00:00:00	10296	10031	13	2017-01-18 17:14:48.957899	2017-01-18 17:14:48.957899
12939	2000-01-01 00:00:00	2016-06-01 00:00:00	10297	10030	18	2017-01-18 17:14:48.963546	2017-01-18 17:14:48.963546
12940	2000-01-01 00:00:00	2016-06-01 00:00:00	10297	10031	19	2017-01-18 17:14:48.968229	2017-01-18 17:14:48.968229
12941	2016-06-01 00:00:00	2016-09-01 00:00:00	10297	10030	27	2017-01-18 17:14:48.973709	2017-01-18 17:14:48.973709
12942	2016-06-01 00:00:00	2016-09-01 00:00:00	10297	10031	19	2017-01-18 17:14:48.9784	2017-01-18 17:14:48.9784
12943	2016-09-01 00:00:00	2017-01-01 00:00:00	10297	10030	27	2017-01-18 17:14:48.983948	2017-01-18 17:14:48.983948
12944	2016-09-01 00:00:00	2017-01-01 00:00:00	10297	10031	17	2017-01-18 17:14:48.989039	2017-01-18 17:14:48.989039
12945	2017-01-01 00:00:00	2100-01-01 00:00:00	10297	10030	25	2017-01-18 17:14:48.994153	2017-01-18 17:14:48.994153
12946	2017-01-01 00:00:00	2100-01-01 00:00:00	10297	10031	26	2017-01-18 17:14:48.998739	2017-01-18 17:14:48.998739
12947	2000-01-01 00:00:00	2016-06-01 00:00:00	10298	10030	22	2017-01-18 17:14:49.004027	2017-01-18 17:14:49.004027
12948	2000-01-01 00:00:00	2016-06-01 00:00:00	10298	10031	20	2017-01-18 17:14:49.008923	2017-01-18 17:14:49.008923
12949	2016-06-01 00:00:00	2016-09-01 00:00:00	10298	10030	25	2017-01-18 17:14:49.014622	2017-01-18 17:14:49.014622
12950	2016-06-01 00:00:00	2016-09-01 00:00:00	10298	10031	28	2017-01-18 17:14:49.019883	2017-01-18 17:14:49.019883
12951	2016-09-01 00:00:00	2017-01-01 00:00:00	10298	10030	14	2017-01-18 17:14:49.025581	2017-01-18 17:14:49.025581
12952	2016-09-01 00:00:00	2017-01-01 00:00:00	10298	10031	17	2017-01-18 17:14:49.030309	2017-01-18 17:14:49.030309
12953	2017-01-01 00:00:00	2100-01-01 00:00:00	10298	10030	27	2017-01-18 17:14:49.036062	2017-01-18 17:14:49.036062
12954	2017-01-01 00:00:00	2100-01-01 00:00:00	10298	10031	23	2017-01-18 17:14:49.040935	2017-01-18 17:14:49.040935
12955	2000-01-01 00:00:00	2016-06-01 00:00:00	10299	10030	28	2017-01-18 17:14:49.046593	2017-01-18 17:14:49.046593
12956	2000-01-01 00:00:00	2016-06-01 00:00:00	10299	10031	12	2017-01-18 17:14:49.05145	2017-01-18 17:14:49.05145
12957	2016-06-01 00:00:00	2016-09-01 00:00:00	10299	10030	17	2017-01-18 17:14:49.057501	2017-01-18 17:14:49.057501
12958	2016-06-01 00:00:00	2016-09-01 00:00:00	10299	10031	29	2017-01-18 17:14:49.062142	2017-01-18 17:14:49.062142
12959	2016-09-01 00:00:00	2017-01-01 00:00:00	10299	10030	18	2017-01-18 17:14:49.067846	2017-01-18 17:14:49.067846
12960	2016-09-01 00:00:00	2017-01-01 00:00:00	10299	10031	25	2017-01-18 17:14:49.072876	2017-01-18 17:14:49.072876
12961	2017-01-01 00:00:00	2100-01-01 00:00:00	10299	10030	11	2017-01-18 17:14:49.078629	2017-01-18 17:14:49.078629
12962	2017-01-01 00:00:00	2100-01-01 00:00:00	10299	10031	24	2017-01-18 17:14:49.08339	2017-01-18 17:14:49.08339
12963	2000-01-01 00:00:00	2016-06-01 00:00:00	10300	10030	27	2017-01-18 17:14:49.089119	2017-01-18 17:14:49.089119
12964	2000-01-01 00:00:00	2016-06-01 00:00:00	10300	10031	27	2017-01-18 17:14:49.094118	2017-01-18 17:14:49.094118
12965	2016-06-01 00:00:00	2016-09-01 00:00:00	10300	10030	24	2017-01-18 17:14:49.099632	2017-01-18 17:14:49.099632
12966	2016-06-01 00:00:00	2016-09-01 00:00:00	10300	10031	21	2017-01-18 17:14:49.104345	2017-01-18 17:14:49.104345
12967	2016-09-01 00:00:00	2017-01-01 00:00:00	10300	10030	25	2017-01-18 17:14:49.10949	2017-01-18 17:14:49.10949
12968	2016-09-01 00:00:00	2017-01-01 00:00:00	10300	10031	19	2017-01-18 17:14:49.114401	2017-01-18 17:14:49.114401
12969	2017-01-01 00:00:00	2100-01-01 00:00:00	10300	10030	17	2017-01-18 17:14:49.119804	2017-01-18 17:14:49.119804
12970	2017-01-01 00:00:00	2100-01-01 00:00:00	10300	10031	14	2017-01-18 17:14:49.124775	2017-01-18 17:14:49.124775
12971	2000-01-01 00:00:00	2016-06-01 00:00:00	10301	10030	12	2017-01-18 17:14:49.13031	2017-01-18 17:14:49.13031
12972	2000-01-01 00:00:00	2016-06-01 00:00:00	10301	10031	25	2017-01-18 17:14:49.135088	2017-01-18 17:14:49.135088
12973	2016-06-01 00:00:00	2016-09-01 00:00:00	10301	10030	12	2017-01-18 17:14:49.1406	2017-01-18 17:14:49.1406
12974	2016-06-01 00:00:00	2016-09-01 00:00:00	10301	10031	21	2017-01-18 17:14:49.145429	2017-01-18 17:14:49.145429
12975	2016-09-01 00:00:00	2017-01-01 00:00:00	10301	10030	23	2017-01-18 17:14:49.150542	2017-01-18 17:14:49.150542
12976	2016-09-01 00:00:00	2017-01-01 00:00:00	10301	10031	29	2017-01-18 17:14:49.155166	2017-01-18 17:14:49.155166
12977	2017-01-01 00:00:00	2100-01-01 00:00:00	10301	10030	21	2017-01-18 17:14:49.160627	2017-01-18 17:14:49.160627
12978	2017-01-01 00:00:00	2100-01-01 00:00:00	10301	10031	18	2017-01-18 17:14:49.165381	2017-01-18 17:14:49.165381
12979	2000-01-01 00:00:00	2016-06-01 00:00:00	10302	10030	20	2017-01-18 17:14:49.170976	2017-01-18 17:14:49.170976
12980	2000-01-01 00:00:00	2016-06-01 00:00:00	10302	10031	15	2017-01-18 17:14:49.175695	2017-01-18 17:14:49.175695
12981	2016-06-01 00:00:00	2016-09-01 00:00:00	10302	10030	12	2017-01-18 17:14:49.181387	2017-01-18 17:14:49.181387
12982	2016-06-01 00:00:00	2016-09-01 00:00:00	10302	10031	17	2017-01-18 17:14:49.186522	2017-01-18 17:14:49.186522
12983	2016-09-01 00:00:00	2017-01-01 00:00:00	10302	10030	12	2017-01-18 17:14:49.191967	2017-01-18 17:14:49.191967
12984	2016-09-01 00:00:00	2017-01-01 00:00:00	10302	10031	28	2017-01-18 17:14:49.196594	2017-01-18 17:14:49.196594
12985	2017-01-01 00:00:00	2100-01-01 00:00:00	10302	10030	16	2017-01-18 17:14:49.201928	2017-01-18 17:14:49.201928
12986	2017-01-01 00:00:00	2100-01-01 00:00:00	10302	10031	21	2017-01-18 17:14:49.20698	2017-01-18 17:14:49.20698
12987	2000-01-01 00:00:00	2016-06-01 00:00:00	10303	10030	17	2017-01-18 17:14:49.212727	2017-01-18 17:14:49.212727
12988	2000-01-01 00:00:00	2016-06-01 00:00:00	10303	10031	16	2017-01-18 17:14:49.217424	2017-01-18 17:14:49.217424
12989	2016-06-01 00:00:00	2016-09-01 00:00:00	10303	10030	23	2017-01-18 17:14:49.222963	2017-01-18 17:14:49.222963
12990	2016-06-01 00:00:00	2016-09-01 00:00:00	10303	10031	28	2017-01-18 17:14:49.227758	2017-01-18 17:14:49.227758
12991	2016-09-01 00:00:00	2017-01-01 00:00:00	10303	10030	14	2017-01-18 17:14:49.233388	2017-01-18 17:14:49.233388
12992	2016-09-01 00:00:00	2017-01-01 00:00:00	10303	10031	13	2017-01-18 17:14:49.238246	2017-01-18 17:14:49.238246
12993	2017-01-01 00:00:00	2100-01-01 00:00:00	10303	10030	18	2017-01-18 17:14:49.243428	2017-01-18 17:14:49.243428
12994	2017-01-01 00:00:00	2100-01-01 00:00:00	10303	10031	29	2017-01-18 17:14:49.248102	2017-01-18 17:14:49.248102
12995	2000-01-01 00:00:00	2016-06-01 00:00:00	10304	10030	16	2017-01-18 17:14:49.253982	2017-01-18 17:14:49.253982
12996	2000-01-01 00:00:00	2016-06-01 00:00:00	10304	10031	21	2017-01-18 17:14:49.258733	2017-01-18 17:14:49.258733
12997	2016-06-01 00:00:00	2016-09-01 00:00:00	10304	10030	14	2017-01-18 17:14:49.26454	2017-01-18 17:14:49.26454
12998	2016-06-01 00:00:00	2016-09-01 00:00:00	10304	10031	25	2017-01-18 17:14:49.269391	2017-01-18 17:14:49.269391
12999	2016-09-01 00:00:00	2017-01-01 00:00:00	10304	10030	15	2017-01-18 17:14:49.27463	2017-01-18 17:14:49.27463
13000	2016-09-01 00:00:00	2017-01-01 00:00:00	10304	10031	23	2017-01-18 17:14:49.279899	2017-01-18 17:14:49.279899
13001	2017-01-01 00:00:00	2100-01-01 00:00:00	10304	10030	18	2017-01-18 17:14:49.285222	2017-01-18 17:14:49.285222
13002	2017-01-01 00:00:00	2100-01-01 00:00:00	10304	10031	24	2017-01-18 17:14:49.289894	2017-01-18 17:14:49.289894
13003	2000-01-01 00:00:00	2016-06-01 00:00:00	10305	10030	13	2017-01-18 17:14:49.295098	2017-01-18 17:14:49.295098
13004	2000-01-01 00:00:00	2016-06-01 00:00:00	10305	10031	18	2017-01-18 17:14:49.300098	2017-01-18 17:14:49.300098
13005	2016-06-01 00:00:00	2016-09-01 00:00:00	10305	10030	12	2017-01-18 17:14:49.305548	2017-01-18 17:14:49.305548
13006	2016-06-01 00:00:00	2016-09-01 00:00:00	10305	10031	28	2017-01-18 17:14:49.310198	2017-01-18 17:14:49.310198
13007	2016-09-01 00:00:00	2017-01-01 00:00:00	10305	10030	14	2017-01-18 17:14:49.315616	2017-01-18 17:14:49.315616
13008	2016-09-01 00:00:00	2017-01-01 00:00:00	10305	10031	11	2017-01-18 17:14:49.320057	2017-01-18 17:14:49.320057
13009	2017-01-01 00:00:00	2100-01-01 00:00:00	10305	10030	27	2017-01-18 17:14:49.325491	2017-01-18 17:14:49.325491
13010	2017-01-01 00:00:00	2100-01-01 00:00:00	10305	10031	19	2017-01-18 17:14:49.330078	2017-01-18 17:14:49.330078
13011	2000-01-01 00:00:00	2016-06-01 00:00:00	10306	10030	16	2017-01-18 17:14:49.33557	2017-01-18 17:14:49.33557
13012	2000-01-01 00:00:00	2016-06-01 00:00:00	10306	10031	22	2017-01-18 17:14:49.340359	2017-01-18 17:14:49.340359
13013	2016-06-01 00:00:00	2016-09-01 00:00:00	10306	10030	15	2017-01-18 17:14:49.345664	2017-01-18 17:14:49.345664
13014	2016-06-01 00:00:00	2016-09-01 00:00:00	10306	10031	20	2017-01-18 17:14:49.350259	2017-01-18 17:14:49.350259
13015	2016-09-01 00:00:00	2017-01-01 00:00:00	10306	10030	10	2017-01-18 17:14:49.355652	2017-01-18 17:14:49.355652
13016	2016-09-01 00:00:00	2017-01-01 00:00:00	10306	10031	20	2017-01-18 17:14:49.360426	2017-01-18 17:14:49.360426
13017	2017-01-01 00:00:00	2100-01-01 00:00:00	10306	10030	14	2017-01-18 17:14:49.365676	2017-01-18 17:14:49.365676
13018	2017-01-01 00:00:00	2100-01-01 00:00:00	10306	10031	18	2017-01-18 17:14:49.370536	2017-01-18 17:14:49.370536
13019	2000-01-01 00:00:00	2016-06-01 00:00:00	10307	10030	11	2017-01-18 17:14:49.375832	2017-01-18 17:14:49.375832
13020	2000-01-01 00:00:00	2016-06-01 00:00:00	10307	10031	27	2017-01-18 17:14:49.380789	2017-01-18 17:14:49.380789
13021	2016-06-01 00:00:00	2016-09-01 00:00:00	10307	10030	27	2017-01-18 17:14:49.386162	2017-01-18 17:14:49.386162
13022	2016-06-01 00:00:00	2016-09-01 00:00:00	10307	10031	10	2017-01-18 17:14:49.390805	2017-01-18 17:14:49.390805
13023	2016-09-01 00:00:00	2017-01-01 00:00:00	10307	10030	23	2017-01-18 17:14:49.396253	2017-01-18 17:14:49.396253
13024	2016-09-01 00:00:00	2017-01-01 00:00:00	10307	10031	22	2017-01-18 17:14:49.401062	2017-01-18 17:14:49.401062
13025	2017-01-01 00:00:00	2100-01-01 00:00:00	10307	10030	22	2017-01-18 17:14:49.406292	2017-01-18 17:14:49.406292
13026	2017-01-01 00:00:00	2100-01-01 00:00:00	10307	10031	12	2017-01-18 17:14:49.41112	2017-01-18 17:14:49.41112
13027	2000-01-01 00:00:00	2016-06-01 00:00:00	10308	10030	14	2017-01-18 17:14:49.416662	2017-01-18 17:14:49.416662
13028	2000-01-01 00:00:00	2016-06-01 00:00:00	10308	10031	20	2017-01-18 17:14:49.421257	2017-01-18 17:14:49.421257
13029	2016-06-01 00:00:00	2016-09-01 00:00:00	10308	10030	19	2017-01-18 17:14:49.426817	2017-01-18 17:14:49.426817
13030	2016-06-01 00:00:00	2016-09-01 00:00:00	10308	10031	27	2017-01-18 17:14:49.431478	2017-01-18 17:14:49.431478
13031	2016-09-01 00:00:00	2017-01-01 00:00:00	10308	10030	23	2017-01-18 17:14:49.436737	2017-01-18 17:14:49.436737
13032	2016-09-01 00:00:00	2017-01-01 00:00:00	10308	10031	17	2017-01-18 17:14:49.44163	2017-01-18 17:14:49.44163
13033	2017-01-01 00:00:00	2100-01-01 00:00:00	10308	10030	10	2017-01-18 17:14:49.446867	2017-01-18 17:14:49.446867
13034	2017-01-01 00:00:00	2100-01-01 00:00:00	10308	10031	17	2017-01-18 17:14:49.451637	2017-01-18 17:14:49.451637
13035	2000-01-01 00:00:00	2016-06-01 00:00:00	10309	10030	13	2017-01-18 17:14:49.457204	2017-01-18 17:14:49.457204
13036	2000-01-01 00:00:00	2016-06-01 00:00:00	10309	10031	25	2017-01-18 17:14:49.462091	2017-01-18 17:14:49.462091
13037	2016-06-01 00:00:00	2016-09-01 00:00:00	10309	10030	19	2017-01-18 17:14:49.467588	2017-01-18 17:14:49.467588
13038	2016-06-01 00:00:00	2016-09-01 00:00:00	10309	10031	29	2017-01-18 17:14:49.472254	2017-01-18 17:14:49.472254
13039	2016-09-01 00:00:00	2017-01-01 00:00:00	10309	10030	28	2017-01-18 17:14:49.477976	2017-01-18 17:14:49.477976
13040	2016-09-01 00:00:00	2017-01-01 00:00:00	10309	10031	19	2017-01-18 17:14:49.482769	2017-01-18 17:14:49.482769
13041	2017-01-01 00:00:00	2100-01-01 00:00:00	10309	10030	19	2017-01-18 17:14:49.488672	2017-01-18 17:14:49.488672
13042	2017-01-01 00:00:00	2100-01-01 00:00:00	10309	10031	20	2017-01-18 17:14:49.49395	2017-01-18 17:14:49.49395
13043	2000-01-01 00:00:00	2016-06-01 00:00:00	10310	10030	28	2017-01-18 17:14:49.499317	2017-01-18 17:14:49.499317
13044	2000-01-01 00:00:00	2016-06-01 00:00:00	10310	10031	29	2017-01-18 17:14:49.504011	2017-01-18 17:14:49.504011
13045	2016-06-01 00:00:00	2016-09-01 00:00:00	10310	10030	26	2017-01-18 17:14:49.509693	2017-01-18 17:14:49.509693
13046	2016-06-01 00:00:00	2016-09-01 00:00:00	10310	10031	13	2017-01-18 17:14:49.514923	2017-01-18 17:14:49.514923
13047	2016-09-01 00:00:00	2017-01-01 00:00:00	10310	10030	15	2017-01-18 17:14:49.520488	2017-01-18 17:14:49.520488
13048	2016-09-01 00:00:00	2017-01-01 00:00:00	10310	10031	17	2017-01-18 17:14:49.525223	2017-01-18 17:14:49.525223
13049	2017-01-01 00:00:00	2100-01-01 00:00:00	10310	10030	19	2017-01-18 17:14:49.530649	2017-01-18 17:14:49.530649
13050	2017-01-01 00:00:00	2100-01-01 00:00:00	10310	10031	17	2017-01-18 17:14:49.53539	2017-01-18 17:14:49.53539
13051	2000-01-01 00:00:00	2016-06-01 00:00:00	10311	10030	12	2017-01-18 17:14:49.540899	2017-01-18 17:14:49.540899
13052	2000-01-01 00:00:00	2016-06-01 00:00:00	10311	10031	10	2017-01-18 17:14:49.545758	2017-01-18 17:14:49.545758
13053	2016-06-01 00:00:00	2016-09-01 00:00:00	10311	10030	19	2017-01-18 17:14:49.551369	2017-01-18 17:14:49.551369
13054	2016-06-01 00:00:00	2016-09-01 00:00:00	10311	10031	28	2017-01-18 17:14:49.556057	2017-01-18 17:14:49.556057
13055	2016-09-01 00:00:00	2017-01-01 00:00:00	10311	10030	14	2017-01-18 17:14:49.561671	2017-01-18 17:14:49.561671
13056	2016-09-01 00:00:00	2017-01-01 00:00:00	10311	10031	14	2017-01-18 17:14:49.566427	2017-01-18 17:14:49.566427
13057	2017-01-01 00:00:00	2100-01-01 00:00:00	10311	10030	16	2017-01-18 17:14:49.572026	2017-01-18 17:14:49.572026
13058	2017-01-01 00:00:00	2100-01-01 00:00:00	10311	10031	14	2017-01-18 17:14:49.576774	2017-01-18 17:14:49.576774
13059	2000-01-01 00:00:00	2016-06-01 00:00:00	10312	10030	21	2017-01-18 17:14:49.582433	2017-01-18 17:14:49.582433
13060	2000-01-01 00:00:00	2016-06-01 00:00:00	10312	10031	23	2017-01-18 17:14:49.587206	2017-01-18 17:14:49.587206
13061	2016-06-01 00:00:00	2016-09-01 00:00:00	10312	10030	18	2017-01-18 17:14:49.59257	2017-01-18 17:14:49.59257
13062	2016-06-01 00:00:00	2016-09-01 00:00:00	10312	10031	21	2017-01-18 17:14:49.597166	2017-01-18 17:14:49.597166
13063	2016-09-01 00:00:00	2017-01-01 00:00:00	10312	10030	17	2017-01-18 17:14:49.602515	2017-01-18 17:14:49.602515
13064	2016-09-01 00:00:00	2017-01-01 00:00:00	10312	10031	29	2017-01-18 17:14:49.607149	2017-01-18 17:14:49.607149
13065	2017-01-01 00:00:00	2100-01-01 00:00:00	10312	10030	20	2017-01-18 17:14:49.612801	2017-01-18 17:14:49.612801
13066	2017-01-01 00:00:00	2100-01-01 00:00:00	10312	10031	13	2017-01-18 17:14:49.617882	2017-01-18 17:14:49.617882
13067	2000-01-01 00:00:00	2016-06-01 00:00:00	10313	10030	21	2017-01-18 17:14:49.623248	2017-01-18 17:14:49.623248
13068	2000-01-01 00:00:00	2016-06-01 00:00:00	10313	10031	19	2017-01-18 17:14:49.628101	2017-01-18 17:14:49.628101
13069	2016-06-01 00:00:00	2016-09-01 00:00:00	10313	10030	18	2017-01-18 17:14:49.633125	2017-01-18 17:14:49.633125
13070	2016-06-01 00:00:00	2016-09-01 00:00:00	10313	10031	29	2017-01-18 17:14:49.637518	2017-01-18 17:14:49.637518
13071	2016-09-01 00:00:00	2017-01-01 00:00:00	10313	10030	11	2017-01-18 17:14:49.642687	2017-01-18 17:14:49.642687
13072	2016-09-01 00:00:00	2017-01-01 00:00:00	10313	10031	28	2017-01-18 17:14:49.647658	2017-01-18 17:14:49.647658
13073	2017-01-01 00:00:00	2100-01-01 00:00:00	10313	10030	24	2017-01-18 17:14:49.653123	2017-01-18 17:14:49.653123
13074	2017-01-01 00:00:00	2100-01-01 00:00:00	10313	10031	18	2017-01-18 17:14:49.657903	2017-01-18 17:14:49.657903
13075	2000-01-01 00:00:00	2016-06-01 00:00:00	10314	10030	26	2017-01-18 17:14:49.663588	2017-01-18 17:14:49.663588
13076	2000-01-01 00:00:00	2016-06-01 00:00:00	10314	10031	25	2017-01-18 17:14:49.668471	2017-01-18 17:14:49.668471
13077	2016-06-01 00:00:00	2016-09-01 00:00:00	10314	10030	15	2017-01-18 17:14:49.674087	2017-01-18 17:14:49.674087
13078	2016-06-01 00:00:00	2016-09-01 00:00:00	10314	10031	11	2017-01-18 17:14:49.679076	2017-01-18 17:14:49.679076
13079	2016-09-01 00:00:00	2017-01-01 00:00:00	10314	10030	28	2017-01-18 17:14:49.684515	2017-01-18 17:14:49.684515
13080	2016-09-01 00:00:00	2017-01-01 00:00:00	10314	10031	25	2017-01-18 17:14:49.689178	2017-01-18 17:14:49.689178
13081	2017-01-01 00:00:00	2100-01-01 00:00:00	10314	10030	14	2017-01-18 17:14:49.694513	2017-01-18 17:14:49.694513
13082	2017-01-01 00:00:00	2100-01-01 00:00:00	10314	10031	26	2017-01-18 17:14:49.699319	2017-01-18 17:14:49.699319
13083	2000-01-01 00:00:00	2016-06-01 00:00:00	10315	10030	16	2017-01-18 17:14:49.704655	2017-01-18 17:14:49.704655
13084	2000-01-01 00:00:00	2016-06-01 00:00:00	10315	10031	22	2017-01-18 17:14:49.710104	2017-01-18 17:14:49.710104
13085	2016-06-01 00:00:00	2016-09-01 00:00:00	10315	10030	14	2017-01-18 17:14:49.715574	2017-01-18 17:14:49.715574
13086	2016-06-01 00:00:00	2016-09-01 00:00:00	10315	10031	16	2017-01-18 17:14:49.720752	2017-01-18 17:14:49.720752
13087	2016-09-01 00:00:00	2017-01-01 00:00:00	10315	10030	12	2017-01-18 17:14:49.726291	2017-01-18 17:14:49.726291
13088	2016-09-01 00:00:00	2017-01-01 00:00:00	10315	10031	24	2017-01-18 17:14:49.730832	2017-01-18 17:14:49.730832
13089	2017-01-01 00:00:00	2100-01-01 00:00:00	10315	10030	26	2017-01-18 17:14:49.736276	2017-01-18 17:14:49.736276
13090	2017-01-01 00:00:00	2100-01-01 00:00:00	10315	10031	17	2017-01-18 17:14:49.74118	2017-01-18 17:14:49.74118
13091	2000-01-01 00:00:00	2016-06-01 00:00:00	10316	10030	26	2017-01-18 17:14:49.746518	2017-01-18 17:14:49.746518
13092	2000-01-01 00:00:00	2016-06-01 00:00:00	10316	10031	11	2017-01-18 17:14:49.751225	2017-01-18 17:14:49.751225
13093	2016-06-01 00:00:00	2016-09-01 00:00:00	10316	10030	12	2017-01-18 17:14:49.75677	2017-01-18 17:14:49.75677
13094	2016-06-01 00:00:00	2016-09-01 00:00:00	10316	10031	25	2017-01-18 17:14:49.761676	2017-01-18 17:14:49.761676
13095	2016-09-01 00:00:00	2017-01-01 00:00:00	10316	10030	11	2017-01-18 17:14:49.767302	2017-01-18 17:14:49.767302
13096	2016-09-01 00:00:00	2017-01-01 00:00:00	10316	10031	23	2017-01-18 17:14:49.77219	2017-01-18 17:14:49.77219
13097	2017-01-01 00:00:00	2100-01-01 00:00:00	10316	10030	24	2017-01-18 17:14:49.777491	2017-01-18 17:14:49.777491
13098	2017-01-01 00:00:00	2100-01-01 00:00:00	10316	10031	18	2017-01-18 17:14:49.783242	2017-01-18 17:14:49.783242
13099	2000-01-01 00:00:00	2016-06-01 00:00:00	10317	10030	17	2017-01-18 17:14:49.790616	2017-01-18 17:14:49.790616
13100	2000-01-01 00:00:00	2016-06-01 00:00:00	10317	10031	27	2017-01-18 17:14:49.796903	2017-01-18 17:14:49.796903
13101	2016-06-01 00:00:00	2016-09-01 00:00:00	10317	10030	10	2017-01-18 17:14:49.804197	2017-01-18 17:14:49.804197
13102	2016-06-01 00:00:00	2016-09-01 00:00:00	10317	10031	29	2017-01-18 17:14:49.809932	2017-01-18 17:14:49.809932
13103	2016-09-01 00:00:00	2017-01-01 00:00:00	10317	10030	15	2017-01-18 17:14:49.816055	2017-01-18 17:14:49.816055
13104	2016-09-01 00:00:00	2017-01-01 00:00:00	10317	10031	25	2017-01-18 17:14:49.820588	2017-01-18 17:14:49.820588
13105	2017-01-01 00:00:00	2100-01-01 00:00:00	10317	10030	22	2017-01-18 17:14:49.826066	2017-01-18 17:14:49.826066
13106	2017-01-01 00:00:00	2100-01-01 00:00:00	10317	10031	17	2017-01-18 17:14:49.831015	2017-01-18 17:14:49.831015
13107	2000-01-01 00:00:00	2016-06-01 00:00:00	10318	10030	15	2017-01-18 17:14:49.836598	2017-01-18 17:14:49.836598
13108	2000-01-01 00:00:00	2016-06-01 00:00:00	10318	10031	20	2017-01-18 17:14:49.841262	2017-01-18 17:14:49.841262
13109	2016-06-01 00:00:00	2016-09-01 00:00:00	10318	10030	10	2017-01-18 17:14:49.846646	2017-01-18 17:14:49.846646
13110	2016-06-01 00:00:00	2016-09-01 00:00:00	10318	10031	17	2017-01-18 17:14:49.851564	2017-01-18 17:14:49.851564
13111	2016-09-01 00:00:00	2017-01-01 00:00:00	10318	10030	15	2017-01-18 17:14:49.857377	2017-01-18 17:14:49.857377
13112	2016-09-01 00:00:00	2017-01-01 00:00:00	10318	10031	26	2017-01-18 17:14:49.862112	2017-01-18 17:14:49.862112
13113	2017-01-01 00:00:00	2100-01-01 00:00:00	10318	10030	12	2017-01-18 17:14:49.867947	2017-01-18 17:14:49.867947
13114	2017-01-01 00:00:00	2100-01-01 00:00:00	10318	10031	27	2017-01-18 17:14:49.873251	2017-01-18 17:14:49.873251
13115	2000-01-01 00:00:00	2016-06-01 00:00:00	10319	10030	16	2017-01-18 17:14:49.878792	2017-01-18 17:14:49.878792
13116	2000-01-01 00:00:00	2016-06-01 00:00:00	10319	10031	12	2017-01-18 17:14:49.883714	2017-01-18 17:14:49.883714
13117	2016-06-01 00:00:00	2016-09-01 00:00:00	10319	10030	10	2017-01-18 17:14:49.889363	2017-01-18 17:14:49.889363
13118	2016-06-01 00:00:00	2016-09-01 00:00:00	10319	10031	29	2017-01-18 17:14:49.894108	2017-01-18 17:14:49.894108
13119	2016-09-01 00:00:00	2017-01-01 00:00:00	10319	10030	26	2017-01-18 17:14:49.899404	2017-01-18 17:14:49.899404
13120	2016-09-01 00:00:00	2017-01-01 00:00:00	10319	10031	14	2017-01-18 17:14:49.904149	2017-01-18 17:14:49.904149
13121	2017-01-01 00:00:00	2100-01-01 00:00:00	10319	10030	26	2017-01-18 17:14:49.909411	2017-01-18 17:14:49.909411
13122	2017-01-01 00:00:00	2100-01-01 00:00:00	10319	10031	19	2017-01-18 17:14:49.914097	2017-01-18 17:14:49.914097
13123	2000-01-01 00:00:00	2016-06-01 00:00:00	10320	10030	28	2017-01-18 17:14:49.919645	2017-01-18 17:14:49.919645
13124	2000-01-01 00:00:00	2016-06-01 00:00:00	10320	10031	17	2017-01-18 17:14:49.924537	2017-01-18 17:14:49.924537
13125	2016-06-01 00:00:00	2016-09-01 00:00:00	10320	10030	28	2017-01-18 17:14:49.930103	2017-01-18 17:14:49.930103
13126	2016-06-01 00:00:00	2016-09-01 00:00:00	10320	10031	25	2017-01-18 17:14:49.934974	2017-01-18 17:14:49.934974
13127	2016-09-01 00:00:00	2017-01-01 00:00:00	10320	10030	18	2017-01-18 17:14:49.940885	2017-01-18 17:14:49.940885
13128	2016-09-01 00:00:00	2017-01-01 00:00:00	10320	10031	19	2017-01-18 17:14:49.945764	2017-01-18 17:14:49.945764
13129	2017-01-01 00:00:00	2100-01-01 00:00:00	10320	10030	18	2017-01-18 17:14:49.951417	2017-01-18 17:14:49.951417
13130	2017-01-01 00:00:00	2100-01-01 00:00:00	10320	10031	20	2017-01-18 17:14:49.956168	2017-01-18 17:14:49.956168
13131	2000-01-01 00:00:00	2016-06-01 00:00:00	10321	10030	26	2017-01-18 17:14:49.961797	2017-01-18 17:14:49.961797
13132	2000-01-01 00:00:00	2016-06-01 00:00:00	10321	10031	14	2017-01-18 17:14:49.966402	2017-01-18 17:14:49.966402
13133	2016-06-01 00:00:00	2016-09-01 00:00:00	10321	10030	16	2017-01-18 17:14:49.972091	2017-01-18 17:14:49.972091
13134	2016-06-01 00:00:00	2016-09-01 00:00:00	10321	10031	13	2017-01-18 17:14:49.976808	2017-01-18 17:14:49.976808
13135	2016-09-01 00:00:00	2017-01-01 00:00:00	10321	10030	25	2017-01-18 17:14:49.982074	2017-01-18 17:14:49.982074
13136	2016-09-01 00:00:00	2017-01-01 00:00:00	10321	10031	27	2017-01-18 17:14:49.987025	2017-01-18 17:14:49.987025
13137	2017-01-01 00:00:00	2100-01-01 00:00:00	10321	10030	26	2017-01-18 17:14:49.993017	2017-01-18 17:14:49.993017
13138	2017-01-01 00:00:00	2100-01-01 00:00:00	10321	10031	24	2017-01-18 17:14:49.997235	2017-01-18 17:14:49.997235
13139	2000-01-01 00:00:00	2016-06-01 00:00:00	10322	10030	11	2017-01-18 17:14:50.00231	2017-01-18 17:14:50.00231
13140	2000-01-01 00:00:00	2016-06-01 00:00:00	10322	10031	15	2017-01-18 17:14:50.006548	2017-01-18 17:14:50.006548
13141	2016-06-01 00:00:00	2016-09-01 00:00:00	10322	10030	21	2017-01-18 17:14:50.012085	2017-01-18 17:14:50.012085
13142	2016-06-01 00:00:00	2016-09-01 00:00:00	10322	10031	25	2017-01-18 17:14:50.016423	2017-01-18 17:14:50.016423
13143	2016-09-01 00:00:00	2017-01-01 00:00:00	10322	10030	15	2017-01-18 17:14:50.02154	2017-01-18 17:14:50.02154
13144	2016-09-01 00:00:00	2017-01-01 00:00:00	10322	10031	18	2017-01-18 17:14:50.025534	2017-01-18 17:14:50.025534
13145	2017-01-01 00:00:00	2100-01-01 00:00:00	10322	10030	28	2017-01-18 17:14:50.031158	2017-01-18 17:14:50.031158
13146	2017-01-01 00:00:00	2100-01-01 00:00:00	10322	10031	16	2017-01-18 17:14:50.035871	2017-01-18 17:14:50.035871
13147	2000-01-01 00:00:00	2016-06-01 00:00:00	10323	10030	29	2017-01-18 17:14:50.041489	2017-01-18 17:14:50.041489
13148	2000-01-01 00:00:00	2016-06-01 00:00:00	10323	10031	19	2017-01-18 17:14:50.046233	2017-01-18 17:14:50.046233
13149	2016-06-01 00:00:00	2016-09-01 00:00:00	10323	10030	28	2017-01-18 17:14:50.051739	2017-01-18 17:14:50.051739
13150	2016-06-01 00:00:00	2016-09-01 00:00:00	10323	10031	28	2017-01-18 17:14:50.056442	2017-01-18 17:14:50.056442
13151	2016-09-01 00:00:00	2017-01-01 00:00:00	10323	10030	12	2017-01-18 17:14:50.061599	2017-01-18 17:14:50.061599
13152	2016-09-01 00:00:00	2017-01-01 00:00:00	10323	10031	15	2017-01-18 17:14:50.066494	2017-01-18 17:14:50.066494
13153	2017-01-01 00:00:00	2100-01-01 00:00:00	10323	10030	27	2017-01-18 17:14:50.071973	2017-01-18 17:14:50.071973
13154	2017-01-01 00:00:00	2100-01-01 00:00:00	10323	10031	10	2017-01-18 17:14:50.076503	2017-01-18 17:14:50.076503
13155	2000-01-01 00:00:00	2016-06-01 00:00:00	10324	10030	14	2017-01-18 17:14:50.081729	2017-01-18 17:14:50.081729
13156	2000-01-01 00:00:00	2016-06-01 00:00:00	10324	10031	24	2017-01-18 17:14:50.086397	2017-01-18 17:14:50.086397
13157	2016-06-01 00:00:00	2016-09-01 00:00:00	10324	10030	13	2017-01-18 17:14:50.091971	2017-01-18 17:14:50.091971
13158	2016-06-01 00:00:00	2016-09-01 00:00:00	10324	10031	24	2017-01-18 17:14:50.096832	2017-01-18 17:14:50.096832
13159	2016-09-01 00:00:00	2017-01-01 00:00:00	10324	10030	19	2017-01-18 17:14:50.102555	2017-01-18 17:14:50.102555
13160	2016-09-01 00:00:00	2017-01-01 00:00:00	10324	10031	24	2017-01-18 17:14:50.107201	2017-01-18 17:14:50.107201
13161	2017-01-01 00:00:00	2100-01-01 00:00:00	10324	10030	23	2017-01-18 17:14:50.112558	2017-01-18 17:14:50.112558
13162	2017-01-01 00:00:00	2100-01-01 00:00:00	10324	10031	12	2017-01-18 17:14:50.117257	2017-01-18 17:14:50.117257
13163	2000-01-01 00:00:00	2016-06-01 00:00:00	10325	10030	27	2017-01-18 17:14:50.122932	2017-01-18 17:14:50.122932
13164	2000-01-01 00:00:00	2016-06-01 00:00:00	10325	10031	22	2017-01-18 17:14:50.127979	2017-01-18 17:14:50.127979
13165	2016-06-01 00:00:00	2016-09-01 00:00:00	10325	10030	17	2017-01-18 17:14:50.133516	2017-01-18 17:14:50.133516
13166	2016-06-01 00:00:00	2016-09-01 00:00:00	10325	10031	26	2017-01-18 17:14:50.138458	2017-01-18 17:14:50.138458
13167	2016-09-01 00:00:00	2017-01-01 00:00:00	10325	10030	10	2017-01-18 17:14:50.143877	2017-01-18 17:14:50.143877
13168	2016-09-01 00:00:00	2017-01-01 00:00:00	10325	10031	21	2017-01-18 17:14:50.148702	2017-01-18 17:14:50.148702
13169	2017-01-01 00:00:00	2100-01-01 00:00:00	10325	10030	24	2017-01-18 17:14:50.154492	2017-01-18 17:14:50.154492
13170	2017-01-01 00:00:00	2100-01-01 00:00:00	10325	10031	16	2017-01-18 17:14:50.159197	2017-01-18 17:14:50.159197
13171	2000-01-01 00:00:00	2016-06-01 00:00:00	10326	10030	25	2017-01-18 17:14:50.16447	2017-01-18 17:14:50.16447
13172	2000-01-01 00:00:00	2016-06-01 00:00:00	10326	10031	19	2017-01-18 17:14:50.168959	2017-01-18 17:14:50.168959
13173	2016-06-01 00:00:00	2016-09-01 00:00:00	10326	10030	24	2017-01-18 17:14:50.174675	2017-01-18 17:14:50.174675
13174	2016-06-01 00:00:00	2016-09-01 00:00:00	10326	10031	26	2017-01-18 17:14:50.179332	2017-01-18 17:14:50.179332
13175	2016-09-01 00:00:00	2017-01-01 00:00:00	10326	10030	26	2017-01-18 17:14:50.184731	2017-01-18 17:14:50.184731
13176	2016-09-01 00:00:00	2017-01-01 00:00:00	10326	10031	22	2017-01-18 17:14:50.189487	2017-01-18 17:14:50.189487
13177	2017-01-01 00:00:00	2100-01-01 00:00:00	10326	10030	17	2017-01-18 17:14:50.194955	2017-01-18 17:14:50.194955
13178	2017-01-01 00:00:00	2100-01-01 00:00:00	10326	10031	23	2017-01-18 17:14:50.199734	2017-01-18 17:14:50.199734
13179	2000-01-01 00:00:00	2016-06-01 00:00:00	10327	10030	15	2017-01-18 17:14:50.205275	2017-01-18 17:14:50.205275
13180	2000-01-01 00:00:00	2016-06-01 00:00:00	10327	10031	19	2017-01-18 17:14:50.210044	2017-01-18 17:14:50.210044
13181	2016-06-01 00:00:00	2016-09-01 00:00:00	10327	10030	12	2017-01-18 17:14:50.2156	2017-01-18 17:14:50.2156
13182	2016-06-01 00:00:00	2016-09-01 00:00:00	10327	10031	16	2017-01-18 17:14:50.220357	2017-01-18 17:14:50.220357
13183	2016-09-01 00:00:00	2017-01-01 00:00:00	10327	10030	24	2017-01-18 17:14:50.225893	2017-01-18 17:14:50.225893
13184	2016-09-01 00:00:00	2017-01-01 00:00:00	10327	10031	13	2017-01-18 17:14:50.230912	2017-01-18 17:14:50.230912
13185	2017-01-01 00:00:00	2100-01-01 00:00:00	10327	10030	24	2017-01-18 17:14:50.236728	2017-01-18 17:14:50.236728
13186	2017-01-01 00:00:00	2100-01-01 00:00:00	10327	10031	20	2017-01-18 17:14:50.241555	2017-01-18 17:14:50.241555
13187	2000-01-01 00:00:00	2016-06-01 00:00:00	10328	10030	12	2017-01-18 17:14:50.246793	2017-01-18 17:14:50.246793
13188	2000-01-01 00:00:00	2016-06-01 00:00:00	10328	10031	18	2017-01-18 17:14:50.251553	2017-01-18 17:14:50.251553
13189	2016-06-01 00:00:00	2016-09-01 00:00:00	10328	10030	18	2017-01-18 17:14:50.25698	2017-01-18 17:14:50.25698
13190	2016-06-01 00:00:00	2016-09-01 00:00:00	10328	10031	14	2017-01-18 17:14:50.261879	2017-01-18 17:14:50.261879
13191	2016-09-01 00:00:00	2017-01-01 00:00:00	10328	10030	14	2017-01-18 17:14:50.267486	2017-01-18 17:14:50.267486
13192	2016-09-01 00:00:00	2017-01-01 00:00:00	10328	10031	13	2017-01-18 17:14:50.272187	2017-01-18 17:14:50.272187
13193	2017-01-01 00:00:00	2100-01-01 00:00:00	10328	10030	29	2017-01-18 17:14:50.277767	2017-01-18 17:14:50.277767
13194	2017-01-01 00:00:00	2100-01-01 00:00:00	10328	10031	27	2017-01-18 17:14:50.282446	2017-01-18 17:14:50.282446
13195	2000-01-01 00:00:00	2016-06-01 00:00:00	10329	10030	23	2017-01-18 17:14:50.287878	2017-01-18 17:14:50.287878
13196	2000-01-01 00:00:00	2016-06-01 00:00:00	10329	10031	20	2017-01-18 17:14:50.292681	2017-01-18 17:14:50.292681
13197	2016-06-01 00:00:00	2016-09-01 00:00:00	10329	10030	25	2017-01-18 17:14:50.297989	2017-01-18 17:14:50.297989
13198	2016-06-01 00:00:00	2016-09-01 00:00:00	10329	10031	12	2017-01-18 17:14:50.302853	2017-01-18 17:14:50.302853
13199	2016-09-01 00:00:00	2017-01-01 00:00:00	10329	10030	23	2017-01-18 17:14:50.308632	2017-01-18 17:14:50.308632
13200	2016-09-01 00:00:00	2017-01-01 00:00:00	10329	10031	25	2017-01-18 17:14:50.313427	2017-01-18 17:14:50.313427
13201	2017-01-01 00:00:00	2100-01-01 00:00:00	10329	10030	10	2017-01-18 17:14:50.318789	2017-01-18 17:14:50.318789
13202	2017-01-01 00:00:00	2100-01-01 00:00:00	10329	10031	22	2017-01-18 17:14:50.323662	2017-01-18 17:14:50.323662
13203	2000-01-01 00:00:00	2016-06-01 00:00:00	10330	10030	17	2017-01-18 17:14:50.329725	2017-01-18 17:14:50.329725
13204	2000-01-01 00:00:00	2016-06-01 00:00:00	10330	10031	27	2017-01-18 17:14:50.334591	2017-01-18 17:14:50.334591
13205	2016-06-01 00:00:00	2016-09-01 00:00:00	10330	10030	22	2017-01-18 17:14:50.339949	2017-01-18 17:14:50.339949
13206	2016-06-01 00:00:00	2016-09-01 00:00:00	10330	10031	19	2017-01-18 17:14:50.345209	2017-01-18 17:14:50.345209
13207	2016-09-01 00:00:00	2017-01-01 00:00:00	10330	10030	28	2017-01-18 17:14:50.350687	2017-01-18 17:14:50.350687
13208	2016-09-01 00:00:00	2017-01-01 00:00:00	10330	10031	10	2017-01-18 17:14:50.355855	2017-01-18 17:14:50.355855
13209	2017-01-01 00:00:00	2100-01-01 00:00:00	10330	10030	27	2017-01-18 17:14:50.361641	2017-01-18 17:14:50.361641
13210	2017-01-01 00:00:00	2100-01-01 00:00:00	10330	10031	14	2017-01-18 17:14:50.366309	2017-01-18 17:14:50.366309
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
-- Name: dict_bike_models FK_model_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dict_bike_models
    ADD CONSTRAINT "FK_model_type_id" FOREIGN KEY (bike_model_type_id) REFERENCES dict_bike_types(bike_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


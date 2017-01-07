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
    bike_mode_id integer DEFAULT nextval('main_sequence'::regclass) NOT NULL,
    bike_model_code character varying(100) NOT NULL,
    bike_model_brand_id integer NOT NULL,
    bike_model_type_name_id integer NOT NULL,
    bike_model_color_id integer NOT NULL,
    bike_model_speed_count integer NOT NULL,
    bike_model_wheel_size_inch double precision NOT NULL,
    bike_model_weight_kg double precision NOT NULL,
    bike_model_year integer NOT NULL,
    bike_model_folding_flag boolean DEFAULT false NOT NULL,
    bike_model_prof_flag boolean DEFAULT false NOT NULL,
    bike_model_current_state_id integer,
    created_at timestamp without time zone DEFAULT '2017-01-07 14:41:45.30469'::timestamp without time zone,
    updated_at timestamp without time zone DEFAULT '2017-01-07 14:41:45.30469'::timestamp without time zone
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
    ADD CONSTRAINT "PK_dict_bike_models_id" PRIMARY KEY (bike_mode_id);


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

CREATE UNIQUE INDEX "PK_idx_dict_bike_models_id" ON dict_bike_models USING btree (bike_mode_id);


--
-- Name: PK_idx_dict_bike_states_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_dict_bike_states_id" ON dict_bike_states USING btree (bike_state_id);


--
-- Name: PK_idx_dict_bike_types_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PK_idx_dict_bike_types_id" ON dict_bike_types USING btree (bike_type_id);


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
-- PostgreSQL database dump complete
--


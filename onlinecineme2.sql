--
-- PostgreSQL database dump
--

-- Dumped from database version 13.5 (Ubuntu 13.5-2.pgdg20.04+1)
-- Dumped by pg_dump version 13.5 (Ubuntu 13.5-2.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_session_date(); Type: FUNCTION; Schema: public; Owner: sergey
--

CREATE FUNCTION public.check_session_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
sessions_count smallint;
BEGIN
IF TG_OP = 'UPDATE' AND OLD.date = NEW.date THEN
RETURN NEW;
END IF;

WITH t1 AS (SELECT NEW.date AT TIME ZONE 'utc' AS start, (NEW.date + duration + '10 minutes') AT TIME ZONE 'utc' AS end FROM films WHERE films.id = NEW.filmId),
t2 AS (SELECT sessions.date AT TIME ZONE 'utc' as start, (sessions.date + duration + '10 minutes') AT TIME ZONE 'utc' AS end FROM sessions, films WHERE sessions.filmId = films.id AND sessions.hallId = NEW.hallId)
SELECT count(*) AS c
INTO sessions_count
FROM t1
JOIN t2
ON tsrange(t1.start, t1.end) && tsrange(t2.start, t2.end);

if sessions_count > 0 THEN
RAISE EXCEPTION 'could not insert session with specified date';
END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_session_date() OWNER TO sergey;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: administrators; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.administrators (
    id integer NOT NULL,
    login character varying(30) NOT NULL,
    password character varying(256) NOT NULL,
    name character varying(40) NOT NULL,
    surname character varying(40) NOT NULL,
    patronymic character varying(40),
    CONSTRAINT administrators_login_check CHECK ((char_length((login)::text) >= 3)),
    CONSTRAINT administrators_name_check CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT administrators_password_check CHECK ((char_length((password)::text) >= 10)),
    CONSTRAINT administrators_patronymic_check CHECK ((char_length((patronymic)::text) >= 1)),
    CONSTRAINT administrators_surname_check CHECK ((char_length((surname)::text) >= 1))
);


ALTER TABLE public.administrators OWNER TO sergey;

--
-- Name: administrators_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.administrators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.administrators_id_seq OWNER TO sergey;

--
-- Name: administrators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.administrators_id_seq OWNED BY public.administrators.id;


--
-- Name: cinemachains; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.cinemachains (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    CONSTRAINT cinemachains_name_check CHECK ((char_length((name)::text) >= 3))
);


ALTER TABLE public.cinemachains OWNER TO sergey;

--
-- Name: cinemachains_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.cinemachains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cinemachains_id_seq OWNER TO sergey;

--
-- Name: cinemachains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.cinemachains_id_seq OWNED BY public.cinemachains.id;


--
-- Name: cinemas; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.cinemas (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    telephone character varying(50) NOT NULL,
    city character varying(50) NOT NULL,
    street character varying(50) NOT NULL,
    metro character varying(50),
    house integer NOT NULL,
    housing integer,
    chainid integer NOT NULL,
    CONSTRAINT cinemas_city_check CHECK ((char_length((city)::text) >= 1)),
    CONSTRAINT cinemas_house_check CHECK ((house > 0)),
    CONSTRAINT cinemas_housing_check CHECK ((housing > 0)),
    CONSTRAINT cinemas_metro_check CHECK ((char_length((metro)::text) >= 1)),
    CONSTRAINT cinemas_name_check CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT cinemas_street_check CHECK ((char_length((street)::text) >= 1)),
    CONSTRAINT cinemas_telephone_check CHECK ((char_length((telephone)::text) = 11))
);


ALTER TABLE public.cinemas OWNER TO sergey;

--
-- Name: cinemas_chainid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.cinemas_chainid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cinemas_chainid_seq OWNER TO sergey;

--
-- Name: cinemas_chainid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.cinemas_chainid_seq OWNED BY public.cinemas.chainid;


--
-- Name: cinemas_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.cinemas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cinemas_id_seq OWNER TO sergey;

--
-- Name: cinemas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.cinemas_id_seq OWNED BY public.cinemas.id;


--
-- Name: favourites; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.favourites (
    viewerid integer NOT NULL,
    cinemaid integer NOT NULL
);


ALTER TABLE public.favourites OWNER TO sergey;

--
-- Name: favourites_cinemaid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.favourites_cinemaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.favourites_cinemaid_seq OWNER TO sergey;

--
-- Name: favourites_cinemaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.favourites_cinemaid_seq OWNED BY public.favourites.cinemaid;


--
-- Name: favourites_viewerid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.favourites_viewerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.favourites_viewerid_seq OWNER TO sergey;

--
-- Name: favourites_viewerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.favourites_viewerid_seq OWNED BY public.favourites.viewerid;


--
-- Name: films; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.films (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    description text NOT NULL,
    duration interval,
    agelimit integer,
    releasedate date,
    CONSTRAINT films_agelimit_check CHECK (((agelimit >= 0) AND (agelimit <= 150))),
    CONSTRAINT films_description_check CHECK ((char_length(description) >= 1)),
    CONSTRAINT films_duration_check CHECK ((duration >= '00:30:00'::interval)),
    CONSTRAINT films_name_check CHECK ((char_length((name)::text) >= 1))
);


ALTER TABLE public.films OWNER TO sergey;

--
-- Name: films_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.films_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.films_id_seq OWNER TO sergey;

--
-- Name: films_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.films_id_seq OWNED BY public.films.id;


--
-- Name: halls; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.halls (
    id integer NOT NULL,
    number smallint NOT NULL,
    cinemaid integer NOT NULL,
    CONSTRAINT halls_number_check CHECK ((number > 0))
);


ALTER TABLE public.halls OWNER TO sergey;

--
-- Name: halls_cinemaid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.halls_cinemaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.halls_cinemaid_seq OWNER TO sergey;

--
-- Name: halls_cinemaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.halls_cinemaid_seq OWNED BY public.halls.cinemaid;


--
-- Name: halls_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.halls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.halls_id_seq OWNER TO sergey;

--
-- Name: halls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.halls_id_seq OWNED BY public.halls.id;


--
-- Name: paymentinfo; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.paymentinfo (
    id integer NOT NULL,
    cardnumber bigint NOT NULL,
    viewerid integer NOT NULL,
    paymentsystemid integer NOT NULL,
    CONSTRAINT paymentinfo_cardnumber_check CHECK (((cardnumber > '999999999999999'::bigint) AND (cardnumber <= '9999999999999999'::bigint)))
);


ALTER TABLE public.paymentinfo OWNER TO sergey;

--
-- Name: paymentinfo_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.paymentinfo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paymentinfo_id_seq OWNER TO sergey;

--
-- Name: paymentinfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.paymentinfo_id_seq OWNED BY public.paymentinfo.id;


--
-- Name: paymentinfo_paymentsystemid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.paymentinfo_paymentsystemid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paymentinfo_paymentsystemid_seq OWNER TO sergey;

--
-- Name: paymentinfo_paymentsystemid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.paymentinfo_paymentsystemid_seq OWNED BY public.paymentinfo.paymentsystemid;


--
-- Name: paymentinfo_viewerid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.paymentinfo_viewerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paymentinfo_viewerid_seq OWNER TO sergey;

--
-- Name: paymentinfo_viewerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.paymentinfo_viewerid_seq OWNED BY public.paymentinfo.viewerid;


--
-- Name: paymentsystems; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.paymentsystems (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    CONSTRAINT paymentsystems_name_check CHECK (((name)::text <> ''::text))
);


ALTER TABLE public.paymentsystems OWNER TO sergey;

--
-- Name: paymentsystems_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.paymentsystems_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paymentsystems_id_seq OWNER TO sergey;

--
-- Name: paymentsystems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.paymentsystems_id_seq OWNED BY public.paymentsystems.id;


--
-- Name: resposibles; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.resposibles (
    administratorid integer NOT NULL,
    cinemaid integer NOT NULL
);


ALTER TABLE public.resposibles OWNER TO sergey;

--
-- Name: resposibles_administratorid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.resposibles_administratorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resposibles_administratorid_seq OWNER TO sergey;

--
-- Name: resposibles_administratorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.resposibles_administratorid_seq OWNED BY public.resposibles.administratorid;


--
-- Name: resposibles_cinemaid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.resposibles_cinemaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resposibles_cinemaid_seq OWNER TO sergey;

--
-- Name: resposibles_cinemaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.resposibles_cinemaid_seq OWNED BY public.resposibles.cinemaid;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    title character varying(50) NOT NULL,
    description text NOT NULL,
    score smallint NOT NULL,
    viewerid integer NOT NULL,
    filmid integer NOT NULL,
    CONSTRAINT reviews_description_check CHECK ((char_length(description) >= 5)),
    CONSTRAINT reviews_score_check CHECK (((score > 0) AND (score <= 10))),
    CONSTRAINT reviews_title_check CHECK ((char_length((title)::text) >= 3))
);


ALTER TABLE public.reviews OWNER TO sergey;

--
-- Name: reviews_filmid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.reviews_filmid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reviews_filmid_seq OWNER TO sergey;

--
-- Name: reviews_filmid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.reviews_filmid_seq OWNED BY public.reviews.filmid;


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reviews_id_seq OWNER TO sergey;

--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: reviews_viewerid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.reviews_viewerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reviews_viewerid_seq OWNER TO sergey;

--
-- Name: reviews_viewerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.reviews_viewerid_seq OWNED BY public.reviews.viewerid;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    cost integer NOT NULL,
    filmid integer NOT NULL,
    hallid integer NOT NULL,
    CONSTRAINT sessions_cost_check CHECK ((cost > 0))
);


ALTER TABLE public.sessions OWNER TO sergey;

--
-- Name: sessions_filmid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.sessions_filmid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_filmid_seq OWNER TO sergey;

--
-- Name: sessions_filmid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.sessions_filmid_seq OWNED BY public.sessions.filmid;


--
-- Name: sessions_hallid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.sessions_hallid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_hallid_seq OWNER TO sergey;

--
-- Name: sessions_hallid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.sessions_hallid_seq OWNED BY public.sessions.hallid;


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO sergey;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: spots; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.spots (
    id integer NOT NULL,
    "row" integer NOT NULL,
    number integer NOT NULL,
    hallid integer NOT NULL,
    CONSTRAINT spots_number_check CHECK ((number > 0)),
    CONSTRAINT spots_row_check CHECK (("row" > 0))
);


ALTER TABLE public.spots OWNER TO sergey;

--
-- Name: spots_hallid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.spots_hallid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.spots_hallid_seq OWNER TO sergey;

--
-- Name: spots_hallid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.spots_hallid_seq OWNED BY public.spots.hallid;


--
-- Name: spots_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.spots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.spots_id_seq OWNER TO sergey;

--
-- Name: spots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.spots_id_seq OWNED BY public.spots.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    transactionurl text NOT NULL,
    viewerid integer NOT NULL,
    sessionid integer NOT NULL,
    spotid integer NOT NULL,
    CONSTRAINT tickets_transactionurl_check CHECK ((char_length(transactionurl) >= 7))
);


ALTER TABLE public.tickets OWNER TO sergey;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_id_seq OWNER TO sergey;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: tickets_sessionid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.tickets_sessionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_sessionid_seq OWNER TO sergey;

--
-- Name: tickets_sessionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.tickets_sessionid_seq OWNED BY public.tickets.sessionid;


--
-- Name: tickets_spotid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.tickets_spotid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_spotid_seq OWNER TO sergey;

--
-- Name: tickets_spotid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.tickets_spotid_seq OWNED BY public.tickets.spotid;


--
-- Name: tickets_viewerid_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.tickets_viewerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_viewerid_seq OWNER TO sergey;

--
-- Name: tickets_viewerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.tickets_viewerid_seq OWNED BY public.tickets.viewerid;


--
-- Name: viewers; Type: TABLE; Schema: public; Owner: sergey
--

CREATE TABLE public.viewers (
    id integer NOT NULL,
    login character varying(40) NOT NULL,
    password character varying(256) NOT NULL,
    name character varying(40) NOT NULL,
    surname character varying(40) NOT NULL,
    patronymic character varying(40),
    CONSTRAINT viewers_login_check CHECK ((char_length((login)::text) >= 3)),
    CONSTRAINT viewers_name_check CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT viewers_password_check CHECK ((char_length((password)::text) >= 10)),
    CONSTRAINT viewers_patronymic_check CHECK ((char_length((patronymic)::text) >= 1)),
    CONSTRAINT viewers_surname_check CHECK ((char_length((surname)::text) >= 1))
);


ALTER TABLE public.viewers OWNER TO sergey;

--
-- Name: viewers_id_seq; Type: SEQUENCE; Schema: public; Owner: sergey
--

CREATE SEQUENCE public.viewers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.viewers_id_seq OWNER TO sergey;

--
-- Name: viewers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sergey
--

ALTER SEQUENCE public.viewers_id_seq OWNED BY public.viewers.id;


--
-- Name: administrators id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.administrators ALTER COLUMN id SET DEFAULT nextval('public.administrators_id_seq'::regclass);


--
-- Name: cinemachains id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.cinemachains ALTER COLUMN id SET DEFAULT nextval('public.cinemachains_id_seq'::regclass);


--
-- Name: cinemas id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.cinemas ALTER COLUMN id SET DEFAULT nextval('public.cinemas_id_seq'::regclass);


--
-- Name: cinemas chainid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.cinemas ALTER COLUMN chainid SET DEFAULT nextval('public.cinemas_chainid_seq'::regclass);


--
-- Name: favourites viewerid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.favourites ALTER COLUMN viewerid SET DEFAULT nextval('public.favourites_viewerid_seq'::regclass);


--
-- Name: favourites cinemaid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.favourites ALTER COLUMN cinemaid SET DEFAULT nextval('public.favourites_cinemaid_seq'::regclass);


--
-- Name: films id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.films ALTER COLUMN id SET DEFAULT nextval('public.films_id_seq'::regclass);


--
-- Name: halls id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.halls ALTER COLUMN id SET DEFAULT nextval('public.halls_id_seq'::regclass);


--
-- Name: halls cinemaid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.halls ALTER COLUMN cinemaid SET DEFAULT nextval('public.halls_cinemaid_seq'::regclass);


--
-- Name: paymentinfo id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentinfo ALTER COLUMN id SET DEFAULT nextval('public.paymentinfo_id_seq'::regclass);


--
-- Name: paymentinfo viewerid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentinfo ALTER COLUMN viewerid SET DEFAULT nextval('public.paymentinfo_viewerid_seq'::regclass);


--
-- Name: paymentinfo paymentsystemid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentinfo ALTER COLUMN paymentsystemid SET DEFAULT nextval('public.paymentinfo_paymentsystemid_seq'::regclass);


--
-- Name: paymentsystems id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentsystems ALTER COLUMN id SET DEFAULT nextval('public.paymentsystems_id_seq'::regclass);


--
-- Name: resposibles administratorid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.resposibles ALTER COLUMN administratorid SET DEFAULT nextval('public.resposibles_administratorid_seq'::regclass);


--
-- Name: resposibles cinemaid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.resposibles ALTER COLUMN cinemaid SET DEFAULT nextval('public.resposibles_cinemaid_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: reviews viewerid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.reviews ALTER COLUMN viewerid SET DEFAULT nextval('public.reviews_viewerid_seq'::regclass);


--
-- Name: reviews filmid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.reviews ALTER COLUMN filmid SET DEFAULT nextval('public.reviews_filmid_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: sessions filmid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.sessions ALTER COLUMN filmid SET DEFAULT nextval('public.sessions_filmid_seq'::regclass);


--
-- Name: sessions hallid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.sessions ALTER COLUMN hallid SET DEFAULT nextval('public.sessions_hallid_seq'::regclass);


--
-- Name: spots id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.spots ALTER COLUMN id SET DEFAULT nextval('public.spots_id_seq'::regclass);


--
-- Name: spots hallid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.spots ALTER COLUMN hallid SET DEFAULT nextval('public.spots_hallid_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: tickets viewerid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets ALTER COLUMN viewerid SET DEFAULT nextval('public.tickets_viewerid_seq'::regclass);


--
-- Name: tickets sessionid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets ALTER COLUMN sessionid SET DEFAULT nextval('public.tickets_sessionid_seq'::regclass);


--
-- Name: tickets spotid; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets ALTER COLUMN spotid SET DEFAULT nextval('public.tickets_spotid_seq'::regclass);


--
-- Name: viewers id; Type: DEFAULT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.viewers ALTER COLUMN id SET DEFAULT nextval('public.viewers_id_seq'::regclass);


--
-- Data for Name: administrators; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.administrators (id, login, password, name, surname, patronymic) FROM stdin;
6	petrov_i	b1b3773a05c0ed0176787a4f1574ff0075f7521e	Иван	Петров	Иванович
7	ivanov_n	b1b3773a05c0ed0176787a4f1574ff0075f7521e	Николай	Иванов	Иванович
8	sidorov_a	ad70ab97ae1376e656002641cfb067c9c94906a2	Александр	Сидоров	Николаевич
9	kazakov_v	ad70ab97ae1376e656002641cfb067c9c94906a2	Виталий	Казаков	Сергеевич
10	carpov_m	cd0c2125b673671ceb65a5c32bf75cc673161599	Михаил	Карпов	Леонидович
11	sokolov_g	cd0c2125b673671ceb65a5c32bf75cc673161599	Георгий	Соколов	Денисович
12	kataev_a	9e659cfe1440248fa3aeb62c7524fec1983dde95	Алексей	Катаев	Александрович
13	golubev_d	9e659cfe1440248fa3aeb62c7524fec1983dde95	Денис	Голубев	Андреевич
14	panov_m	8a603edae1b76e8e98b55a20d3abb6f9ce79cdfe	Мирон	Панов	Никитович
15	volkova_e	8a603edae1b76e8e98b55a20d3abb6f9ce79cdfe	Екатерина	Волкова	Сергеевна
\.


--
-- Data for Name: cinemachains; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.cinemachains (id, name) FROM stdin;
1	Cinema Park
2	Kinomax
3	Премьер-зал
4	Формула кино
5	Luxor film
\.


--
-- Data for Name: cinemas; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.cinemas (id, name, telephone, city, street, metro, house, housing, chainid) FROM stdin;
1	Синема Парк Мега Белая Дача	88007000111	Котельники	Покровский проезд	Люблино	1	\N	1
2	Синема Парк Бутово Молл	88007000111	Москва	Чечерский проезд	Бунинская аллея	51	\N	1
3	Синема Парк Глобал сити на Южной	88007000111	Москва	улица Днепропетровская	Южная	2	\N	1
4	Синема Парк Зеленопарк	88007000111	Зеленоград	Ленинградское шоссе	\N	4	\N	1
5	Синема Парк на Калужской	88007000111	Москва	улица Профсоюзная	Калужская	61	\N	1
6	Киномакс-XL Москва	88007351144	Москва	Дмитровское шоссе	Селигерская	89	\N	2
7	Киномакс-Водный Москва	88007351144	Москва	Головинское шоссе	Водный стадион	5	\N	2
8	Киномакс-Жулебино Москва	88007351144	Москва	Генерала Кузнецова	Жулебино	22	\N	2
9	Киномакс-Мозаика Москва	88007351144	Москва	улица 7-ая Кожуховская	Пражская	9	\N	2
10	Киномакс-Жулебино Москва	88007351144	Москва	улица Перерва	Братиславская	43	\N	2
11	Киноконцертный театр Космос	83432020903	Екатеринбург	улица Дзержинского	\N	2	\N	3
12	Премьер Зал Гранат	83432366661	Екатеринбург	улица Амундсена	\N	63	\N	3
13	Премьер Зал Заря	89222061760	Екатеринбург	улица Баумана	\N	2	\N	3
14	Премьер Зал Омега	83432366665	Екатеринбург	улица Космонавтор	\N	41	\N	3
15	Премьер Зал Парк-Хаус	83432366667	Екатеринбург	улица Сулимова	\N	50	\N	3
16	Формула Кино Европа	88007000111	Москва	площадь Киевского Вокзала	Киевская	2	\N	4
17	Формула Кино на Кутузовском	88007000111	Москва	Кутузовский проспект	Славянский бульвар	57	\N	4
18	Формула Кино Ладога	88007000111	Москва	улица Широкая	Медведково	12	\N	4
19	Формула Кино Лефортово	88007000111	Москва	шоссе Энтузиастов	Авиамоторная	12	2	4
20	Формула Кино на Мичуринском	88007000111	Москва	Мичуринский проспект	Озерная	3	1	4
21	Люксор Гудзон	88004205522	Москва	Каширское шоссе	Каширская	14	\N	5
22	Люксор Континент	88004205522	Санкт-Петербург	Бухарестская	Воздухоплавательный парк	30	32	5
23	Люксор Лето	88004205522	Санкт-Петербург	Пулковское шоссе	Предпочтовая	25	\N	5
24	Люксор Круиз	88004205522	Рязань	Солотчинское шоссе	\N	11	2	5
25	Люксор Европа	88004205522	Курск	Студенческая	\N	1	\N	5
\.


--
-- Data for Name: favourites; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.favourites (viewerid, cinemaid) FROM stdin;
28	5
142	18
11	9
34	2
142	15
74	15
32	10
140	15
169	15
31	3
10	2
19	6
14	2
149	14
91	17
20	9
116	19
16	3
141	20
172	21
118	21
97	19
125	15
6	7
163	19
113	16
155	16
125	22
8	4
138	16
90	14
168	14
134	19
125	18
117	17
86	19
153	21
93	20
117	15
150	20
148	18
29	3
165	22
109	21
30	1
122	20
139	17
30	9
19	8
92	19
11	10
146	18
147	21
165	21
27	1
168	21
33	1
158	19
123	17
132	21
171	16
152	14
131	16
162	19
34	4
91	20
80	17
119	17
147	17
29	4
151	17
131	19
81	18
105	19
172	20
143	17
32	5
118	22
160	16
83	19
28	8
144	18
101	19
27	5
136	19
23	6
113	19
141	14
161	17
109	20
15	1
6	10
12	7
134	20
74	17
33	9
163	17
75	20
18	6
124	19
113	18
118	15
170	19
75	16
161	22
161	21
12	5
165	15
25	10
18	8
82	19
26	5
166	18
28	7
166	15
140	22
32	7
8	8
17	8
82	15
23	10
23	1
28	10
109	19
29	10
115	21
115	19
133	19
112	15
23	8
127	20
10	3
147	16
156	20
34	6
10	7
105	14
103	16
112	18
92	21
102	14
109	15
9	6
89	16
166	22
114	18
25	8
136	16
158	21
171	22
163	22
13	2
161	16
96	22
79	16
5	1
151	14
107	22
160	20
89	21
92	16
22	1
7	4
30	5
20	7
15	5
83	18
73	17
126	21
134	14
15	10
142	19
159	15
99	16
112	21
33	3
164	16
14	1
26	1
11	8
7	2
107	14
145	22
73	22
105	18
130	18
18	3
111	18
146	22
27	6
9	3
170	17
6	5
169	22
6	2
114	20
86	21
17	6
9	5
142	21
167	18
8	1
133	18
94	15
90	19
21	9
168	22
95	20
148	20
24	8
16	10
12	8
129	14
146	14
14	8
33	2
8	9
153	19
146	15
166	17
29	8
5	4
19	10
17	3
12	1
110	21
172	18
128	21
153	18
6	6
18	5
142	16
161	20
149	20
33	10
87	17
10	8
18	9
27	8
13	8
26	6
77	15
137	22
131	22
144	14
20	5
163	21
25	7
31	6
153	15
78	20
11	6
32	4
75	14
113	17
22	2
135	18
153	14
117	20
14	6
12	9
15	7
92	20
132	14
154	19
25	6
136	15
101	17
129	19
124	14
139	15
23	2
8	3
159	14
139	18
22	6
81	15
15	8
101	14
24	7
25	9
115	20
11	1
150	21
34	7
133	16
167	19
75	17
24	2
20	6
171	18
19	9
97	15
89	15
82	20
122	18
79	19
28	3
163	20
126	18
16	7
140	17
21	10
13	9
126	19
129	20
158	16
14	4
21	5
103	15
128	18
11	2
7	7
165	14
30	10
28	6
18	2
123	19
112	22
107	18
24	9
142	17
24	6
122	22
16	5
29	2
75	19
33	4
8	7
79	21
15	3
14	3
100	21
122	19
112	19
34	3
148	15
10	1
115	18
29	6
33	7
100	15
115	15
101	16
19	7
34	10
31	1
168	20
74	18
84	17
161	15
91	22
111	22
122	21
153	22
15	4
155	20
29	5
91	16
163	18
76	17
148	14
28	9
17	2
162	20
20	10
125	19
17	1
13	6
27	2
17	10
164	14
137	19
21	8
141	16
95	21
121	14
30	6
166	19
102	17
22	5
92	18
5	7
27	7
111	20
133	21
29	7
154	22
133	20
17	9
144	17
20	8
109	16
22	9
30	8
84	16
130	20
86	15
140	21
30	7
8	5
33	5
154	20
84	21
26	10
115	17
23	9
76	22
133	15
28	1
27	3
6	3
87	20
108	22
14	10
16	1
94	17
24	5
97	18
22	3
140	19
18	10
154	17
8	6
31	10
91	18
78	21
124	21
163	15
13	5
86	16
110	15
166	14
87	14
87	15
167	21
144	15
31	2
16	8
140	20
95	18
84	22
119	21
149	21
130	19
161	18
5	6
121	16
21	1
172	16
7	1
123	20
92	17
107	21
93	18
165	16
23	5
24	1
171	14
139	21
23	4
87	18
109	22
19	1
25	3
22	8
34	1
22	4
82	16
148	16
172	22
32	1
150	18
16	9
143	15
100	22
94	21
16	4
111	21
83	20
107	16
31	4
149	18
77	20
111	17
127	18
160	17
15	2
22	10
89	22
10	4
30	4
134	15
94	19
32	9
27	10
132	18
100	20
33	8
19	3
169	17
134	17
88	14
91	19
9	9
155	21
118	20
142	22
13	10
162	18
123	21
79	18
135	20
24	3
137	18
28	2
78	15
103	17
32	6
107	15
145	15
126	14
16	2
7	6
26	9
137	16
118	14
170	16
31	7
108	20
105	16
106	21
108	15
14	5
127	21
145	17
98	18
119	16
154	18
143	20
95	15
17	7
139	16
94	20
26	4
103	18
8	2
103	21
104	17
168	15
159	22
12	10
128	20
148	19
87	19
18	7
7	5
141	22
15	6
9	7
31	8
31	9
17	5
21	4
34	9
9	2
25	4
5	2
13	3
23	3
166	21
161	14
106	19
21	2
17	4
12	4
131	17
119	20
7	9
12	6
74	16
104	19
5	8
146	21
110	18
26	2
130	15
94	14
75	15
25	2
136	14
137	20
128	19
124	15
22	7
138	19
14	7
13	7
11	7
141	17
129	21
5	3
146	16
138	21
157	14
162	21
162	22
26	3
108	18
160	21
152	18
122	17
9	4
93	16
120	18
6	8
90	15
74	14
20	2
6	1
85	18
89	20
6	4
154	21
12	2
78	18
116	15
77	16
156	14
129	15
105	17
104	15
\.


--
-- Data for Name: films; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.films (id, name, description, duration, agelimit, releasedate) FROM stdin;
1	Человек-паук: Нет пути домой	Жизнь и репутация Питера Паркера оказываются под угрозой, поскольку Мистерио раскрыл всему миру тайну личности Человека-паука. Пытаясь исправить ситуацию, Питер обращается за помощью к Стивену Стрэнджу, но вскоре всё становится намного опаснее.	02:30:00	12	2021-12-15
2	Матрица: Воскрешение	«Матрица: Воскрешение» — предстоящий американский научно-фантастический боевик, снятый Ланой Вачовски, которая также написала сценарий вместе с Дэвидом Митчеллом и Александром Хемоном и выступила продюсером совместно с Грантом Хиллом и Джеймсом Мактигом.	02:28:00	16	2021-12-16
3	Дом Gucci	Фамилия Гуччи звучала так сладко, так соблазнительно… Синоним роскоши, стиля, власти. Но она же была их проклятьем. Шокирующая история любви, предательства, падения и мести, которая привела к жестокому убийству в одной из самых знаменитых модных империй мира.	02:38:00	18	2021-12-02
4	Большой красный пёс Клиффорд	Когда школьница Эмили получает в подарок от спасателя животных очаровательного щенка с красной шерстью, она и представить не может, что на утро обнаружит в своей маленькой нью-йоркской квартирке… огромного 3-метрового пса! Мама в командировке, поэтому самые захватывающие и необыкновенные приключения ждут Эмили и ее веселого и порывистого дядю Кейси. Клиффорд научит их — а заодно и весь мир — любить по-крупному.	01:36:00	16	2021-12-09
5	Последняя дуэль	Нормандский рыцарь Жан де Карруж по возвращении с войны узнаёт, что его сосед и соперник Жак Ле Гри изнасиловал его жену Маргарит. Однако у Ле Гри обнаружились сильные союзники, словам женщины никто не верит, и Карруж обращается за помощью лично к королю Франции Карлу VI.	02:32:00	18	2021-11-18
6	Охотники за привидениями: Наследники	Мать-одиночка с двумя детьми-подростками селится на старой ферме в Оклахоме, полученной в наследство от отца, которого она не знала. Дети пытаются больше узнать о своем деде и находят автомобиль Ecto-1, принадлежавший знаменитым охотникам за привидениями.	02:04:00	12	2021-11-18
7	Бумеранг	Богатый владелец фармацевтического бизнеса, Эдик привык управлять и контролировать. Но судьба преподносит ему неожиданный сюрприз. Решивший попрощаться с жизнью безработный художник Петрович падает с крыши высотки на новенькую дорогую машину бизнесмена. Стоит ли жалкая жизнь неудачника таких денег? Тем более, что он никогда не сможет их вернуть. Но долг нужно во что бы то ни стало получить, для Эдика это вопрос принципа, прощать других — не в его правилах...	01:45:00	16	2021-12-02
9	Спенсер: Тайна принцессы Дианы	Брак принцессы Дианы и принца Чарльза трещит по швам. Злые языки судачат о романе на стороне и прогнозируют развод. Тем не менее, на рождественские праздники в поместье Сандрингем королевская семья изображает мир. Они едят и пьют за одним столом, традиционно выезжают на охоту, но сможет ли Диана продолжать эту игру?	01:57:00	16	2021-12-09
10	Черная Пантера: Ваканда навеки	Кинокомикс "Черная Пантера" стал самым кассовым в истории Marvel дебютным сольным фильмом о супергерое. У сиквела сложная задача – в связи со смертью Чедвика Боузмана, исполнявшего роль Т’Чаллы (Черной Пантеры), сценаристам пришлось спешно переписывать историю. Однако, по словам главы Marvel Кевина Файги, замену Боузману было решено не искать. То есть костюм Черной Пантеры, скорее всего, перейдет к кому-то из уже известных персонажей. Поклонники полагают, что его в новом фильме примерит Шури – сестра Т’Чаллы, роль которой вновь исполнит Летиша Райт.	\N	\N	\N
11	Человек-муравей и Оса: Квантомания	После событий, описанных в кинокомиксе "Мстители: Финал", Скотт Лэнг, Хоуп ван Дайн, Хэнк Пим и Джанет ван Дайн погрузятся в изучение квантового мира (благодаря этому изменению, Мстителям удалось отправиться в путешествие сквозь время, чтобы собрать воедино все Камни Бесконечности). По слухам, главным антагонистом в фильме должен стать Канг-завоеватель, родившийся в XXXI веке. Он не обладает сверхспособностями, но компенсирует это своим острым умом. В комиксах Канг перемещался во времени при помощи обнаруженной им машины времени.	\N	\N	\N
12	Флешбэк	Алекс Льюис, профессиональный киллер с репутацией, в какой-то момент пошел против ветра, и теперь вынужден отбиваться и от ФБР, и от криминального босса. Все потому, что убийца отказался нарушить свой моральный кодекс.	01:54:00	18	2022-05-12
13	Ботан и супербаба	Стеснительный ботаник Иван, ученый из «Сколково», которого в школе все называли Калом (сокращенно от фамилии Калинин) для встречи выпускников крадет девушку-андроида из научного центра и приделывает к её кибертелу лицо первой красавицы школы, чтобы выдать покорного робота за свою жену.	01:21:00	16	2022-05-12
14	Бука. Мое любимое чудище	Скандал в царском семействе: своенравная принцесса Варвара сбежала из дворца и отправилась через лес на поиски прекрасного принца. Однако вместо заветной встречи с возлюбленным её берет в плен Бука, самый опасный разбойник королевства.	01:38:00	6	2022-04-28
15	Будь моими глазами	Незрячую девушку Софи приглашают в отсутствие хозяев пожить в роскошном уединенном особняке. Вскоре в дом вламываются грабители, и единственная надежда Софи на спасение — приложение, которое позволяет связаться со случайным волонтером, по видеосвязи описывающим происходящее вокруг.	01:32:00	16	2022-05-19
16	1941. Крылья над Берлином	История о подвиге лётчиков 1-го минно-торпедного авиационного полка ВВС Балтийского флота во главе с полковником Преображенским. У них была сложнейшая боевая задача — нанести первые бомбовые удары по Берлину, столице фашистской Германии.	01:40:00	12	2022-04-28
17	Заклятье: Спуск к дьяволу	Дочь Киры Вудс таинственным образом исчезает в подвале их нового загородного дома. Вскоре Кира обнаруживает, что дом контролирует древняя и могущественная сущность, с которой ей придется сразиться, чтобы защитить души близких.	01:34:00	16	2022-05-12
18	Клон 	В мире будущего люди вынуждены отстаивать свое право на существование в публичных смертельных поединках со своими клонами. Когда специалисты ставят Саре тяжелый диагноз, она приобретает собственного двойника, чтобы он заботился о близких. Но когда девушка выздоравливает и решает деактивировать клона, она сталкивается с новым суровым законом.	01:34:00	16	2022-05-19
19	Анчартед: На картах не значится	Нейтан Дрейк не видел старшего брата Сэма 15 лет, с тех пор как тот сбежал из сиротского приюта. Парень работает барменом и промышляет мелким воровством, когда на него выходит Виктор Салливан по прозвищу Салли и предлагает отправиться на поиски давно потерянных сокровищ Магеллана. 	01:55:00	12	2022-02-10
20	Ника	В детстве Ника Турбина вместе с мамой гастролировала по Советскому Союзу, читая свои стихи: полные стадионы любителей поэзии, богемные вечеринки, встречи со знаменитостями. 8-летний вундеркинд, она поражала недетской грустью и пронзительностью строк… И вот Нике 27.	01:20:00	18	2022-05-19
21	Казнь	В деле о серийных убийствах, которое расследовалось долгие 10 лет и было официально закрыто, появляется новое обстоятельство — выжившая жертва. Следователь по особо важным делам Исса Давыдов вынужден срочно выехать на место, чтобы разобраться в ситуации и оправдаться в глазах системы правосудия, под давлением которой он закрыл глаза на недостаточность улик.	02:17:00	18	2022-04-21
\.


--
-- Data for Name: halls; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.halls (id, number, cinemaid) FROM stdin;
1	1	1
2	2	1
3	3	1
4	4	1
5	5	1
6	1	2
7	2	2
8	3	2
9	4	2
10	5	2
11	6	2
12	7	2
13	8	2
14	1	3
15	2	3
16	3	3
17	4	3
18	5	3
19	6	3
20	7	3
21	8	3
22	9	3
23	10	3
24	11	3
25	12	3
26	13	3
27	1	4
28	2	4
29	3	4
30	4	4
31	5	4
32	6	4
33	7	4
34	8	4
35	9	4
36	10	4
37	11	4
38	1	5
39	2	5
40	3	5
41	4	5
42	5	5
43	6	5
44	7	5
45	8	5
46	1	6
47	2	6
48	3	6
49	4	6
50	5	6
51	6	6
52	7	6
53	8	6
54	9	6
55	10	6
56	11	6
57	12	6
58	13	6
59	14	6
60	1	7
61	2	7
62	3	7
63	4	7
64	5	7
65	6	7
66	7	7
67	8	7
68	9	7
69	1	8
70	2	8
71	3	8
72	4	8
73	5	8
74	6	8
75	7	8
76	8	8
77	9	8
78	10	8
79	11	8
80	12	8
81	13	8
82	14	8
83	15	8
84	1	9
85	2	9
86	3	9
87	4	9
88	5	9
89	6	9
90	7	9
91	8	9
92	9	9
93	10	9
94	1	10
95	2	10
96	3	10
97	4	10
98	5	10
99	1	11
100	2	11
101	3	11
102	4	11
103	5	11
104	6	11
105	7	11
106	8	11
107	9	11
108	10	11
109	11	11
110	12	11
111	1	12
112	2	12
113	3	12
114	4	12
115	5	12
116	6	12
117	7	12
118	8	12
119	1	13
120	2	13
121	3	13
122	4	13
123	5	13
124	6	13
125	7	13
126	8	13
127	9	13
128	1	14
129	2	14
130	3	14
131	4	14
132	5	14
133	6	14
134	7	14
135	8	14
136	9	14
137	10	14
138	11	14
139	12	14
140	13	14
141	1	15
142	2	15
143	3	15
144	4	15
145	5	15
146	6	15
147	7	15
148	8	15
149	9	15
150	1	16
151	2	16
152	3	16
153	4	16
154	5	16
155	6	16
156	1	17
157	2	17
158	3	17
159	4	17
160	5	17
161	6	17
162	7	17
163	8	17
164	9	17
165	10	17
166	11	17
167	12	17
168	13	17
169	1	18
170	2	18
171	3	18
172	4	18
173	5	18
174	6	18
175	7	18
176	8	18
177	9	18
178	10	18
179	11	18
180	12	18
181	13	18
182	14	18
183	15	18
184	1	19
185	2	19
186	3	19
187	4	19
188	5	19
189	6	19
190	1	20
191	2	20
192	3	20
193	4	20
194	5	20
195	6	20
196	7	20
197	8	20
198	1	21
199	2	21
200	3	21
201	4	21
202	5	21
203	6	21
204	7	21
205	8	21
206	9	21
207	10	21
208	1	22
209	2	22
210	3	22
211	4	22
212	5	22
213	6	22
214	7	22
215	8	22
216	9	22
217	10	22
218	11	22
219	12	22
220	13	22
221	14	22
222	15	22
223	1	23
224	2	23
225	3	23
226	4	23
227	5	23
228	6	23
229	7	23
230	8	23
231	9	23
232	10	23
233	11	23
234	12	23
235	13	23
236	14	23
237	1	24
238	2	24
239	3	24
240	4	24
241	5	24
242	6	24
243	7	24
244	8	24
245	9	24
246	10	24
247	11	24
248	12	24
249	13	24
250	14	24
251	15	24
252	1	25
253	2	25
254	3	25
255	4	25
256	5	25
257	6	25
258	7	25
\.


--
-- Data for Name: paymentinfo; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.paymentinfo (id, cardnumber, viewerid, paymentsystemid) FROM stdin;
1	3624567912844067	16	1
2	8519130355770755	175	2
3	4352258695203587	7	2
4	2460789225097055	186	1
5	6993494075325209	196	1
6	2263743907062775	6	1
7	9583384505556068	94	1
8	9183977824178622	148	2
9	8931758883101398	17	2
10	1180779944386511	15	1
11	3809939027861261	92	2
12	7143837251479798	218	1
13	1636116445871067	25	2
14	1402539662983688	121	1
15	3500407331594221	52	2
16	8957875743861165	171	2
17	8770673500474397	220	2
18	2377205232564179	124	1
19	8820966902020536	41	2
20	8861425401860013	99	1
21	3463264601238844	212	1
22	9068194896332448	83	1
23	4077832651851146	173	1
24	5253886065557850	37	2
25	8237956652558554	167	1
26	9301195748377324	82	2
27	6776231528700641	30	2
28	2300147584548657	12	1
29	7286181098395445	26	1
30	9387758371175358	192	2
31	1231965264818086	197	2
32	8852968676368774	31	2
33	4040702838348540	108	2
34	9044184385408704	118	1
35	9236688576405860	111	1
36	3987243866859202	148	2
37	8701120339181254	218	2
38	3649775117359457	43	2
39	4518729779249824	217	1
40	3845001958222461	77	1
41	5008646229849958	188	1
42	1521181395717782	162	1
43	1271948513924876	16	2
44	9348390428857416	23	2
45	6969190633196443	161	1
46	7387039203667228	19	1
47	5368910429671298	28	2
48	8107087061702219	132	2
49	2691515254678986	43	2
50	7980964163319491	158	2
51	3420453415060052	40	2
52	9229888775805320	13	2
53	6050747025355516	146	1
54	7968404017456950	38	1
55	4658892023131344	105	2
56	3740065133925657	160	1
57	9467013150734526	185	1
58	7020498121096448	26	2
59	5397336574038028	90	2
60	1558201584206745	27	1
61	2114547548434313	84	2
62	5798434816151310	77	1
63	8074731188475091	21	2
64	6564785511262627	76	1
65	7079534098467565	10	2
66	3081719904937610	191	2
67	6954233145589007	46	1
68	8591306334522286	52	2
69	1245921904846884	53	1
70	8834054692671898	45	1
71	5679500283530927	15	2
72	1390934983220891	184	2
73	8251594617390881	30	1
74	1620105596626484	40	1
75	7061140393802290	109	2
76	4822287989851712	109	1
77	2770248448858467	209	1
78	7107954847324432	25	1
79	7452042044377033	129	1
80	7689830527894968	187	1
81	8692100004539145	129	2
82	3705334187171175	32	2
83	4374189747615932	137	2
84	6771674437172762	41	1
85	2564851307810595	103	2
86	4651435547709180	99	2
87	5391322388813730	7	1
88	3430936997398834	217	1
89	4035431062883510	211	2
90	1237586391655394	30	1
91	6092553218146438	219	1
92	2402912958282900	10	2
93	8351280553167501	173	1
94	4839089232570166	33	2
95	8383040484483259	149	2
96	5039305295426348	30	2
97	8016806295451253	43	2
98	5749949988108578	8	2
99	7563471821175223	9	2
100	4574608329265754	128	2
101	1510337827315162	105	2
102	2576644105100676	23	2
103	4673578479557410	199	1
104	7372831310105858	13	1
105	1414432992484485	98	1
106	1835631748542361	131	1
107	9892774515774104	42	1
108	6034548246564543	47	2
109	9151928720225572	25	2
110	8086303779685721	46	1
111	5698638784944797	22	1
112	5432014763548242	149	1
113	8906706737351388	76	1
114	4771701475628628	36	1
115	4254420241872427	12	2
116	2653602736715967	176	2
117	1894197910905141	6	1
118	4670233534125412	26	2
119	5821925047349672	54	1
120	2745173897837602	196	2
121	2343970706143903	117	1
122	7317519068204347	116	2
123	8095303482736994	44	1
124	9657185472016024	52	1
125	1454051091180183	181	2
126	2979925203388685	23	2
127	6063980291937859	9	2
128	3036055119696044	170	1
129	1772671169398176	37	1
130	7393467498265550	126	2
131	9747388231254940	186	2
132	2653712945618547	10	2
133	7668473113933859	222	1
134	1915054091199518	147	2
135	7273047518414027	132	2
136	5085372254100456	17	1
137	6066990878120961	50	1
138	9949831158267300	74	1
139	8188663195170356	137	2
140	1033040520639811	34	2
141	2285267482434403	50	2
142	3613276421753130	33	1
143	1669088618547590	30	1
144	6869157984987971	28	1
145	4621541629258960	28	1
146	2860319878199611	151	1
147	8737893495474782	34	2
148	9413757241917752	43	1
149	8587062245267819	201	2
150	5684399734703791	212	1
151	7695230293051323	13	2
152	2138845723179077	210	1
153	8628421723320517	121	1
154	4546990565238779	21	1
155	5484703951279850	53	1
156	8131930347676643	129	1
157	4822921939019338	182	1
158	9062286082871848	27	1
159	3105124589804898	127	2
160	8579209504752405	125	1
161	7586935098382706	110	2
162	2479980698307475	37	2
163	6014139899138044	5	1
164	7448847052519457	118	1
165	4774347560208685	21	1
166	7305450009179562	188	1
167	7230209808408836	31	1
168	7124377509725871	209	1
169	3688687189140047	190	2
170	2954862385377808	11	1
171	7542207677179049	175	2
172	5369327957713231	133	2
173	3305229246002909	100	1
174	4517943139726544	36	1
175	3916443654333125	212	2
176	3682765935604589	124	1
177	3896889066233605	6	1
178	6553554337033691	142	2
179	7832373877505876	95	1
180	5653019805962049	34	2
181	5087459819915068	31	2
182	2870732656601728	149	1
183	6044091439105038	132	2
184	5664875791919005	172	1
185	7505979734625149	24	2
186	8063299286014135	20	2
187	6986714316471235	195	2
188	5704807601380387	202	2
189	6009913995616816	10	2
190	7353581593310732	44	1
191	2925984905681392	12	1
192	1576956222972420	149	2
193	8622645472988359	53	2
194	8290599819277051	7	1
195	6559140874064428	25	1
196	8938087828573898	109	2
197	1728691390758761	22	2
198	9747813930100396	28	2
199	3415022407091807	39	2
200	4481219878243155	87	1
201	5706939206072025	50	2
202	9693964383610556	52	2
203	8098861812051971	26	1
204	3787118280761266	20	1
205	1018622700797507	111	2
206	8094425976001463	44	1
207	3273275313257318	8	1
208	2921408737087443	54	2
209	7292397408113973	44	2
210	9633425744833892	215	2
211	4572960089410976	119	2
212	5835408783051253	49	2
213	9259209547428198	169	1
214	4695394439225332	214	1
215	9802167335940284	157	1
216	7923859122599107	11	1
217	5266319593561440	204	2
218	1346502327408274	25	1
219	9237476736702248	18	2
220	9175062027291284	184	2
221	7837497856625823	52	1
222	8351194716171782	51	1
223	2587010309635822	25	2
224	1089290273304008	11	2
225	9418135630479704	119	2
226	6264102184990502	37	2
227	3595683730365738	124	1
228	4460874340811940	18	2
229	4691605606964184	22	1
230	3238984095055510	98	1
231	7891894348473019	15	2
232	8577348621764894	23	2
233	9026115985175300	32	2
234	1349245323877340	206	1
235	8815307399433034	24	2
236	1014806734565386	34	1
237	8244836456565618	184	2
238	7992162739116473	31	2
239	3847420936267212	126	2
240	2603410852956486	202	2
241	5939968091180098	208	1
242	4636237199313022	124	1
243	5369451386539782	149	1
244	2868216699933029	26	1
245	2814633694184156	23	1
246	6949546844509366	21	2
247	4206892514774530	192	2
248	3937565850124396	20	1
249	7070555800666504	116	2
250	6880001756845316	200	2
251	5557395179920057	97	1
252	1048738195718723	5	2
253	3069606394226621	51	2
254	3716279608821231	175	1
255	4931978324446188	116	1
256	2728809255658934	77	1
257	2824771524952876	39	1
258	9979389873161504	38	1
259	4323077186577300	161	1
260	4634199922541548	173	1
261	5342870752337166	141	2
262	1764399217221921	18	1
263	9550710862430608	11	1
264	8671635755984599	45	2
265	8492456466350638	161	2
266	5021610501532346	14	2
267	3502259268209193	17	2
268	3977026104260463	178	2
269	9576602071418868	50	2
270	8422850620515006	165	1
271	7211692385809072	33	1
272	8468286595032637	45	1
273	5612462339040746	134	1
274	1530819795205690	112	2
275	5893338043040280	100	2
276	7246616084995011	165	1
277	3940147109212215	19	1
278	1444550588100071	22	2
279	8276276072247135	23	2
280	8742084522301933	75	1
281	5709540741890123	21	1
282	7370321143719589	145	2
283	2280839240530294	141	1
284	2105850021812198	30	2
285	9209016264492964	45	2
286	3244745192289276	42	1
287	4282407728002414	21	2
288	1296656095886632	109	2
289	7848528583716479	160	2
290	9814209312468952	17	1
291	6726079184764991	172	1
292	4859532666988442	83	1
293	8934450539763499	17	2
294	1762528113547137	27	1
295	5824114395300668	44	2
296	7309781115358095	21	1
297	2041829856414715	162	2
298	3441193326169013	209	2
299	2120743757282273	180	1
300	1118632196457014	50	2
301	9916142202344548	196	2
302	7531092973771741	19	1
303	7841686900090603	38	1
304	4655501796008980	86	1
305	5748439531155113	20	2
306	2669576412325820	171	2
307	7102642565630471	159	2
308	5848565761079242	104	1
309	8121470500067530	172	1
310	8085466428406142	34	2
311	7838173650976862	108	1
312	3530535158627088	79	1
313	5412491651564515	48	2
314	6869703361650074	17	2
315	6945632365196832	210	2
316	2206362994508694	35	2
317	2709484450222774	89	2
318	7288464133860987	26	2
319	3905658108199478	54	2
320	8987352341371596	171	2
321	8495104307291288	77	2
322	4173519187654839	214	2
323	8553034829344560	100	2
324	2417153782418218	127	1
325	4656311196829684	42	2
326	7631518244592043	210	2
327	2401607282085052	158	2
328	9528663127868944	150	2
329	6148718487649016	42	2
330	6819147707057361	177	2
331	5251058955838594	189	2
332	9342373799932068	49	1
333	1230671793300576	35	1
334	9479058619007176	9	1
335	4323184166455952	134	2
336	7092036083950904	168	2
337	2846726362191042	216	2
338	3993598194865889	167	2
339	8693269002898059	36	1
340	1114072221650751	13	2
341	7508189971541422	206	1
342	3258440001925219	103	2
343	6634542509938391	18	1
344	9339833356712854	51	2
345	7144471390564177	153	1
346	6491257672227284	20	1
347	9572708520248144	52	1
348	2201355257212210	136	1
349	6776226210027619	134	1
350	8902585966551409	196	2
351	2823103777410057	44	1
352	6305440008037411	107	2
353	9541668866956716	22	1
354	7972329872042304	175	1
355	7935163152913208	24	1
356	4804525648061634	52	2
357	9368548999040740	114	1
358	9385981261479894	43	2
359	8778056551271365	28	2
360	8249550970514579	221	1
361	6769063199093782	210	2
362	1641232697623021	43	1
363	3793338969186695	117	1
364	9835239608958072	132	1
365	2421479520407306	10	1
366	6140340732431010	171	2
367	4711859201978935	95	1
368	8621561771390236	49	2
369	8758994019713149	183	1
370	1888417063097527	11	1
371	3275515549890830	141	2
372	9968082987339892	18	2
373	6470901793674958	15	2
374	3351708639391429	90	1
375	8358407564120262	163	2
376	3162398096878341	33	1
377	9493711762230836	162	1
378	6897594040604889	78	2
379	4084510788842514	99	1
380	6238851726051102	9	1
381	5295723971665448	52	2
382	8466687358698652	43	2
383	8122506771329930	17	1
384	9905909349900116	28	1
385	7445580703499782	73	1
386	7345321890113076	200	1
387	3448747801112890	206	1
388	8206605849070349	16	2
389	5040775899282479	165	2
390	8206694136591898	29	2
391	3772555576209228	200	1
392	1186526379959175	47	2
393	9485887054847368	114	2
394	2544015782848735	204	1
395	4798042394706566	22	1
396	2662341746605623	9	1
397	5991007143457252	145	2
398	1923582627286659	180	2
399	9369717369828890	19	1
400	7339917085629302	54	2
401	6726163408767227	22	1
402	6572213932976921	16	2
403	5651448778962134	129	2
404	3583269249458496	153	1
405	1964593611042577	79	1
406	6865285535693175	39	2
407	8451835765648339	11	2
408	5555621389079000	26	2
409	2255101759183020	170	1
410	5621544186656770	101	2
411	8211738792511166	53	2
412	4027677384943519	173	1
413	6883054511081116	79	2
414	3308192404449009	44	2
415	3563186039940305	18	1
416	2867076523562175	28	1
417	1742186444671382	221	1
418	3994895572048086	100	2
419	5772615679096272	76	2
420	4185746032285677	27	1
421	6489368605592293	27	2
422	5484989225936580	25	2
423	3344802505890868	45	2
424	9324099787844626	27	2
425	5072886745110310	14	2
426	9418559495793240	89	1
427	6501315178804034	47	1
428	9131814615786136	104	1
429	6993868174199583	13	1
430	5347162684872810	52	1
431	6510623166713301	214	2
432	3020396940584685	21	2
433	4129272401637361	46	1
434	5131292654851229	11	2
435	8180213521066462	126	2
436	5327138569045104	206	2
437	3364407480525940	141	2
438	8705454049658324	49	1
439	7624222925143214	144	2
440	6954829003795175	32	1
441	5643485046279742	222	2
442	3382075199195639	119	2
443	3638441976726529	135	2
444	4385186480624511	124	2
445	2149610240192838	147	1
446	1468382290856567	95	2
447	2147390626859706	148	2
448	9326621514128384	54	2
449	3423558318327216	32	1
450	2708309255270222	11	2
451	9642129173417230	43	2
452	7218404262021809	43	1
453	1824766271366481	97	2
454	5127517740025798	130	2
455	3059171388367669	111	2
456	5458255649485625	45	2
457	8731455681419173	115	1
458	2120121574437924	26	2
459	5281679335327180	134	1
460	4684812482469457	25	1
461	4316811322241402	16	1
462	3988752334261967	16	2
463	4046602246173989	149	2
464	9345514791468086	169	2
465	6829730325252203	127	2
466	4526652668420091	203	1
467	6200461624532021	14	2
468	9077630317820764	15	1
469	3645759380032629	16	1
470	8751001498536449	208	2
471	3602505917347475	128	1
472	2901277313368396	92	2
473	9298806134365888	170	2
474	1893056650332376	30	2
475	4976546633693434	49	1
476	7262794948052888	106	2
477	4034026915573917	102	1
478	7262042690550167	29	1
479	7869027198727362	92	1
480	9786434487724268	10	2
481	1425995814986649	10	2
482	4041522101697349	118	1
483	6452850164494964	98	1
484	7672863745838309	13	2
485	3997097123401115	180	2
486	5534750391641974	136	1
487	9007085273075130	219	2
488	4577586896910986	111	2
489	5789027797236631	92	1
490	2997704260972728	156	1
491	2937583928409797	172	2
492	2110983556732264	23	1
493	6368273937594459	132	2
494	9433331063059120	6	2
495	4229466402697937	11	2
496	6267032189525337	25	1
497	9241880454206916	193	2
498	9533091483075508	134	2
499	7898897308470608	6	1
500	4071712360982544	86	1
501	7977638869779511	73	1
502	9039758437013500	28	1
503	9425701813119416	107	1
504	5313192565042893	16	1
505	4707288208901193	5	1
506	8080635381542918	104	2
507	3574456915721302	51	1
508	6615316025997465	124	1
509	8954885834803899	77	2
510	8521507137418570	16	1
511	8008256399944886	194	2
512	4250548430240097	207	2
513	2373373541123179	8	1
514	7966757636925173	191	2
515	3516740207854994	33	1
516	9873541031856004	20	2
517	5349837689944372	214	2
518	5757743277502207	222	2
519	9205677850359254	200	2
520	7393447447829519	213	2
521	4901697714346834	163	1
522	6527014960700675	43	2
523	6361065000106989	147	2
524	1392078667971827	53	1
525	5793978169576682	27	1
526	6132773366255658	48	2
527	6531517612951340	135	2
528	2539800457228878	162	1
529	6039109605467036	22	1
530	1738888641115547	49	1
531	3745426891383168	29	2
532	5997119855780734	160	1
533	8799710582728095	137	1
534	7870871725604775	208	1
535	1701219195922568	10	1
536	7618361773474056	44	1
537	9317054242743466	193	1
538	9413559745041556	28	2
539	1211923970725553	13	1
540	2756335023306242	47	2
541	1319234976428102	99	2
542	8141370550454723	7	2
543	8913023757015515	5	1
544	9108359109401262	16	2
545	3568887937957725	5	2
546	3618446110904805	94	1
547	7434889845225672	203	1
548	5995845741419007	140	1
549	3948678051746238	32	1
550	3343296591605884	79	1
551	8598939267871983	131	1
552	6087190858573993	96	2
553	9784096580269212	175	2
554	9904080819904954	27	1
555	8527610512751926	116	1
556	7053146723204647	11	2
557	5393057391085694	157	2
558	9698115764460676	53	2
559	7212529583040868	104	2
560	9967425206385068	121	2
561	2908176884113690	47	2
562	4499776651454968	212	1
563	9892199597072688	21	1
564	4016174958914074	204	2
565	4017639644288692	26	1
566	3912074649537675	143	2
567	8690973832585054	53	1
568	5077000862772504	161	2
569	9232570471205238	95	2
570	9721287171685064	47	2
571	7169461266163359	105	1
572	2891640439583188	52	1
573	7907190020181306	29	2
574	8807507578295236	43	1
575	6817273147995656	83	1
576	7450397390753824	40	1
577	5018367167706134	155	2
578	4663540844860609	142	1
579	3764684665256275	6	1
580	6144633144367588	18	2
581	7948836970792178	96	1
582	2793032170915175	118	1
583	5015292829114432	135	2
584	9728829817319316	98	1
585	5014848364638584	47	1
586	5878455196715918	36	1
587	9291094237420306	128	2
588	9882200943104708	154	1
589	3285142490341467	199	2
590	4213865709495219	33	1
591	2857203258339439	195	1
592	2685437599801059	157	1
593	9538381319088860	98	1
594	6226331984567700	126	2
595	7953437215937345	152	2
596	5408263079046232	123	1
597	3896254294459612	206	1
598	1702974795661433	36	1
599	3212831179403870	22	2
600	7774351301575730	176	2
601	2952008802010159	103	1
602	1830822912790807	207	1
603	3158493511377848	15	1
604	4735153309916402	103	2
605	2454058964260799	97	1
606	2867696230990812	30	2
607	1878540410209634	133	2
608	4302675881102590	206	2
609	2498785115713431	21	2
610	9153306468042332	46	2
611	1873196677997388	6	1
612	3788030496368573	166	1
613	5833490809657323	17	2
614	3083797536695030	17	2
615	3546017234931934	48	1
616	8475910747527602	122	1
617	5370300757245232	6	2
618	2250264693843071	33	1
619	2738547719384922	113	1
620	3982974168435326	21	1
621	8171081379235885	146	2
622	7707548391947522	41	2
623	5085045116726146	48	1
624	5554663419794142	79	2
625	1216081289046926	52	1
626	3342771049117061	189	1
627	2829564617396780	47	2
628	6347332548889003	18	2
629	6270047290412730	203	1
630	4111994433872620	211	1
631	2412907390446566	201	2
632	6083803872826479	17	1
633	5536948929097231	81	1
634	2012161867578839	51	1
635	3417582911376918	202	2
636	5125780156620862	26	2
637	1047197728263366	12	1
638	2860137987127743	119	1
639	2977890121271620	127	2
640	1239740159049969	197	2
641	8406734846002684	25	2
642	1193966389881943	16	2
643	8560158413531762	148	1
644	8865143938338430	99	1
645	2879419960740438	102	2
646	8360252244491405	135	1
647	5860504100874699	135	1
648	7668036360487778	85	2
649	2865846400629987	14	1
650	9302814071414150	29	1
651	3898344294294570	140	2
652	7988235577637677	81	1
653	5903475628016845	202	1
654	3850610214623852	98	2
655	5558417257069404	41	1
656	2900177120452713	81	2
657	4917795869089449	18	2
658	4578288329030862	42	2
659	7536865266737880	28	2
660	4083238674665508	204	1
661	2112845823050602	53	1
662	4230839239893892	39	2
663	8616945521914281	49	1
664	3714004327768545	49	1
665	8476284023493675	13	1
666	1002561976807310	173	1
667	9855919560155086	32	2
668	5904533548957711	25	2
669	2480148868748120	128	2
670	8623981679221891	98	2
671	2298937490802714	42	1
672	5481041975139160	159	2
673	9752676437385918	94	2
674	6552150296906105	6	1
675	2610663878604054	166	2
676	7679924892308082	145	2
677	6505259793601236	152	1
678	3001091736529076	42	2
679	1219012472692522	99	2
680	3956216528369239	42	1
681	1251247398757414	207	2
682	6062939085132573	193	2
683	8336885530474997	10	2
684	5785373502769701	12	2
685	5776702283629187	9	2
686	5381281379252829	143	1
687	3667347481336214	158	1
688	5351052093579049	97	2
689	2973266993653865	99	2
690	1041091123402676	80	1
691	2882938762491314	103	2
692	4764100839026703	155	1
693	4071461215054906	35	2
694	9406576865478658	10	1
695	2042601788527378	196	2
696	8480842780804969	209	2
697	6510985065588584	86	2
698	8507441771483413	29	1
699	6684438237520595	126	2
700	1010118661152201	168	1
701	3910647525350530	139	2
702	8402186660242353	31	1
703	1006203591765725	6	2
704	6015400144323404	146	1
705	5955016026038375	42	1
706	6194135992618356	168	2
707	3438293199141334	170	2
708	5590812425374604	86	1
709	3998575390519942	37	2
710	7932785362740353	117	1
711	7131857486139235	36	1
712	4926536280514472	119	1
713	1412820258684572	47	2
714	5025997015241668	35	2
715	5791122666045772	48	1
716	3603627261519040	221	1
717	8369075530933485	183	2
718	5137994168709120	33	2
719	1228589193164616	141	2
720	1386980055048830	31	1
721	6663064416375842	19	2
722	2689628971213370	131	1
723	5206402910020220	145	2
724	6297955548929991	31	1
725	6243335488206135	101	1
726	7205537977904331	44	1
727	1367876656834795	29	1
728	1687063469673781	47	1
729	8067027448383260	42	2
730	5822473590064763	218	2
731	3248930917799249	39	1
732	2069680902807306	158	1
733	1375881783565184	42	1
734	9625855170467388	51	2
735	1781568954680569	9	2
736	8164736230852692	149	2
737	2886037716504205	18	1
738	9090987756370088	214	2
739	6751424866233708	54	2
740	5903724161733428	199	1
741	5096850800548036	38	2
742	9789996214128958	107	1
743	5455463252814166	213	2
744	5133520948949524	36	2
745	9294286214288888	146	1
746	2733709705672201	13	2
747	4464352354046411	48	2
748	7623564198901948	12	1
749	5167075650231624	29	2
750	5992154942392669	17	1
751	6284490041144579	53	2
752	1501311070595814	13	1
753	6001247824085449	40	2
754	5089510897483656	115	1
755	1169464527001412	117	2
756	7227329365445551	17	2
757	9922262780755844	222	2
758	9226623805561012	41	2
759	5937547520206454	183	2
760	4893163741906118	161	2
761	5644723617505579	146	1
762	2447268591781327	137	1
763	3813614019840695	136	1
764	3057502941902139	16	2
765	4608557410166512	17	1
766	7720525661807197	33	2
767	7155737989868178	53	1
768	6639205885218629	32	2
769	7243810641411488	191	1
770	9314843104411516	200	1
771	3037707758809379	51	1
772	6736149058718367	125	2
773	4465034348468691	36	2
774	8803647809513239	27	1
775	1965509116484625	22	1
776	6243218326979654	183	2
777	9745066985203504	200	2
778	8158636849498595	15	1
779	8535251133982228	31	1
780	1562236893466416	45	2
781	7605829733023689	34	1
782	1702597245820058	47	2
783	6435760527379283	53	1
784	7044510343229862	26	2
785	6673498111087251	34	2
786	6534952817513843	202	1
787	6437264070932240	188	1
788	3017651996619054	36	2
789	6526500678641241	22	1
790	8920886084920883	9	1
791	8215368642694346	28	2
792	5083584031325638	104	2
793	7549520470272298	112	1
794	3611299861434449	30	1
795	8177508483434461	28	1
796	7367450118096460	124	2
797	4556412113079552	115	2
798	8268030351079925	17	1
799	2692599535176597	180	2
800	3769586293942797	133	1
801	6125419132559620	54	2
802	2383141886819793	20	2
803	8272160177042763	50	2
804	2401456441777256	210	1
805	6519050350567788	83	1
806	2863078279775276	196	1
807	8531881309938163	45	1
808	9540086064225592	162	1
809	2380991662000092	81	1
810	6895692434683009	25	1
811	7840009315861695	42	1
812	3833030941018289	217	1
813	5729568705642783	52	1
814	1686342887402233	15	1
815	7721121768020420	11	2
816	1345584993197441	30	1
817	3396134063566005	207	2
818	6541845589521852	47	1
819	5202104167427769	154	2
820	2969213451955948	44	1
821	5028514420652740	156	1
822	9528863310157770	137	2
823	1028827378850639	37	2
824	6400558770727812	32	2
825	4113546222542662	52	2
826	7549106459641848	49	1
827	3582644806023647	200	1
828	7599897518446013	84	2
829	1911490000520036	29	2
830	5467658519056876	38	2
831	3998140382399760	32	2
832	1473125724431231	17	2
833	6779233185507976	115	1
834	7409170361994259	34	1
835	5820725918969561	189	2
836	1285071806153819	30	2
837	2423324044117141	5	1
838	9551755168664032	52	1
839	2494925392474588	34	1
840	8539256084499978	95	1
841	2449429000359792	8	2
842	6362675731831629	39	1
843	8417534335416206	35	1
844	9837236872257364	9	1
845	7551971424292325	18	2
846	5273898474431814	48	2
847	7199347869956411	43	1
848	5685124144758997	40	2
849	9751852254890004	120	1
850	2971683977867346	30	1
851	7923848917259782	19	2
852	9517009211807044	43	2
853	1904031254714823	36	2
854	4804677057289989	31	2
855	2070257152355928	158	1
856	8598725067168025	178	2
857	3724734429927980	205	1
858	3617035599016141	82	1
859	3690321910093562	153	1
860	4189168840617515	50	1
861	6523879883994915	122	2
862	6866975908068176	161	2
863	4872935832086394	202	1
864	9326162494910356	81	2
865	9671851216738474	149	1
866	5810519322393776	21	1
867	6087599523699573	110	2
868	3796123921267739	219	2
869	7041374106503031	75	2
870	8763229893338926	27	1
871	2823086489927028	104	2
872	1477319137320929	34	2
873	4857645556561734	198	2
874	3934034772274760	207	1
875	7923573586154922	17	2
876	2616650354049209	135	2
877	5715758253121492	50	2
878	4047683853120620	86	2
879	2497001969264822	132	1
880	4867643957517480	43	1
881	3489811776267373	206	2
882	6639429247082642	37	1
883	1870798159118294	17	2
884	6649966354515988	46	2
885	1708558037562976	42	2
886	6771598995694802	171	1
887	7005057969380331	49	2
888	6523573387587717	46	2
889	4321140202149919	157	2
890	8474925986227993	51	2
891	3331540928862793	9	2
892	2641131039941193	40	1
893	2111267674042391	21	1
894	1817995196191724	198	1
895	5628740762259763	124	1
896	5734370298283842	42	2
897	2136479829466711	166	2
898	2408499627113809	119	2
899	2573898470924405	52	2
900	7164728881539921	29	1
901	5259286537448780	85	2
902	6171951325170766	99	1
903	8737756127627573	94	2
904	1987511010711497	10	1
905	9964418326627340	168	1
906	2256349902301256	19	2
907	2126704318346323	21	1
908	7595793494069034	34	2
909	1356157095069335	81	1
910	9241664977205492	23	1
911	3239465793380418	97	1
912	8896205840412963	104	2
913	2363304461246542	88	1
914	5930578319839476	43	1
915	4067113639655538	213	2
916	6070286620879727	22	1
917	1280765332249362	9	1
918	8465405428846622	119	2
919	5094074093447020	162	2
920	8292394853831264	22	1
921	5142505958765209	104	1
922	5585496401702236	30	1
923	3215838955884326	22	2
924	3456633976358936	5	1
925	2288178067757496	41	1
926	3151034562584897	36	1
927	1006827204023782	7	1
928	5213475116505584	12	2
929	5774553418064691	5	1
930	7198752275746364	176	2
931	6317360302181910	41	2
932	4132620927648776	44	1
933	2014981693197221	114	2
934	5379294969189800	195	1
935	9807154848533416	88	1
936	2473592861182268	29	1
937	1935847782041371	5	2
938	8641675077146505	28	2
939	3186798673304608	176	1
940	5394129632521366	104	1
941	2874024886174655	105	1
942	3614170801810121	194	1
943	4148566843264006	44	2
944	8414297113811986	120	1
945	3028822386558612	31	1
946	3275676108710413	78	1
947	3178837330162750	54	2
948	7021359549759409	15	2
949	5611199103231189	16	1
950	4881292904698692	25	1
951	9029919262644838	170	2
952	7109514995692815	137	1
953	5241044223320060	135	1
954	7703116865341399	38	1
955	7130394860092557	35	2
956	4425369612719862	88	1
957	1173195147003834	99	1
958	3459130924466446	36	1
959	9970214623758472	105	2
960	3515697358422361	15	1
961	4225145904884119	155	2
962	3591993376223243	32	1
963	9351587090932268	194	2
964	4690103595520483	54	2
965	7815661626895184	10	2
966	3473080603417226	17	2
967	2297682708981003	42	2
968	5676071629353906	175	1
969	7334666819439209	18	1
970	4304899413394799	27	2
971	9086990948277920	164	1
972	2039761806300742	35	1
973	4966147331323000	89	2
974	8789392763439671	104	1
975	1332292193397414	21	2
976	1684422003470764	17	2
977	5062756389388411	25	1
978	9456386972525720	209	1
979	2038264578316845	201	1
980	3830102795273472	207	1
981	8228030450341286	181	2
982	8504519636795144	123	1
983	8991840010318607	17	2
984	4351410322708772	13	1
985	2439172682953803	217	1
986	3725547759703349	91	1
987	2876391231809329	37	2
988	8591090469097582	19	2
989	5594538172544009	53	1
990	7554587781811313	221	2
991	5481676925195372	103	2
992	3338524108736443	45	2
993	4359472931541727	149	1
994	1579675967424503	47	1
995	7848793314110341	8	1
996	9300678320901066	113	2
997	7400823074445568	137	2
998	2715856346482361	138	1
999	6914686846889978	97	2
1000	6737561405178343	18	1
\.


--
-- Data for Name: paymentsystems; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.paymentsystems (id, name) FROM stdin;
1	Visa
2	Mastercard
3	Мир
\.


--
-- Data for Name: resposibles; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.resposibles (administratorid, cinemaid) FROM stdin;
6	1
6	2
6	3
7	3
7	4
7	5
8	6
8	7
9	7
9	8
9	9
9	10
10	11
10	12
11	13
11	14
11	15
12	16
12	17
12	18
12	19
12	20
13	16
13	17
13	18
13	19
13	20
14	21
14	22
14	23
15	24
15	25
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.reviews (id, title, description, score, viewerid, filmid) FROM stdin;
1	Отравратительный фильм	250854b504e675b37e531581812dcd4c 5b0b3f8a2616200c8fec3914ee564dd2 4439f02f0c4e284ce88711c6fb73fca7 9124b8348e269413b88f650b19711c6d 11074d815b2e0b724b65f7b4fbe36552 fa08f62ce04f36a0c8e8fe3056632216	1	40	5
2	Плохой фильм	2453effa0b306c13c780dc5e8a54d27a 6d068232e4d06ab34e270db5aa2769a8 e2920c95db15ffec288d213356071bff 30f701bb2f8eef77951be1d0b540f71d 4e1bd36cd642ff6c263df1d59a1cff5e 50dc1610c4258719cf5bedfedb606785	2	41	6
3	Фильм не понравился	641cb1511dc89e4413b8aba34159244a 2119c7acaa12113fa703bbd34c70872e b5a4f4735d06d438a81dff582d0a6e08 2065246b4934ebb48f9cf38915c223ae f3f5103786d27806e564d9d78be2d098 24aea114f98b694ec6bf8826349a9d0d	3	42	2
4	Непонятный фильм	8de6cd393661d00f812e8f278788acda 720ef58ea5f6ce2cd7d1c32017eed791 2767bbfd8de234b69e28147a8e03a9d7 83d61d331d8a147f9a4ccfe9517f91c1 442e740e5d512758f07e90e6cbf99d64 6096579df47e9a7df6e34ad5c930d970	4	43	2
5	Средний фильм	8f69e76a180548b396e18fbeefc1e035 bee1194d9cd5d5e1a05d67dd411b76f1 d51210b1956f29b7c47d5642c251774c e3d32fbde2fa811b94ba28a61a2f569b b9efa94ec2fa9d6714e4b9c6aeea19c3 21d5b4863c3e43dd571ef6ea6ad4a444	5	44	1
6	Нормальный фильм	8023fa0ab455661e0bed9531ae084b44 041dcaeff216c8e23fc628588b10500a 5526058fea0f26cb57feb903e5667ff1 88bf7697d360043a95c4b7e712802657 e9dbf25cbb843f52b35680129b7d12b8 d650a03e062c0d91ab0114111245b731	6	45	3
7	Фильм понравился	433b738d4c0b9924fa35d5bde1e5b563 dbe3345ba13d1475384f487950f4d825 f815f906929ab1975a07f124ccf8ace3 de9f2d395be9f321e51abe01b46ba765 a8adf5ab34888678aac66ddff8e0e941 a20a74bea3e18aa92de7f6c8b1e17333	7	46	4
8	Хороший фильм	cadd08b9a4f076d57e021d6b2cad71fd 8566c8d6de3b34cc1e55ae547dc8771e 5eb148a3092201dfd2e58d5e695f7d28 62001ce9575531147441c5eaaae22567 3bc25c8d341e23cf2edef27e23daf87c 3c71ae74ff486c5125dc3dd95ce8699d	8	47	7
9	Отличный фильм	2b51d485b65a58100d8adf133c4ea0b5 546f99fbfef9185d164f7aad34422adb a2748c556598fca932545a0723ad8dd5 09d89a69d57938a0e7fc0bbcf710bfa0 d46f98d03515c4b4d4cc4766d4a9c875 6298fd827fab1632f2135c487b832f6d	9	48	7
10	Лучший фильм	be27727725830acba29601e15ae7938e 4e998865addf3112ed5d68229f63c035 a7719cf4bb91070f45f9d603b31ad5cf 175d041f89de4498df7f4afa2e39eb45 af7d39b112e13b3a5ab82085fbd8424c bc9b82012c749ea6eb556347b2d424bc	10	49	1
12	Плохой фильм	4b5ee3e77df952723fca50b7fa79e996 52e182f25bdb01a43525cc9b789aed48 1a835f7ab17b58df63e16faca86db8c1 b694f70bf2ba424437991c21f39d0ff3 933bb0a2b431a35efbf77e0ff2e5ac2f f9442b62274c52023776ae0d4e9fa9bc	2	51	2
13	Фильм не понравился	8e9dfef67a83aee2bd6f2592c8296710 c5d44bf57854527fb4af35f7ece58b09 4c8205dcc61e2f04cb9cfb35df681359 dabb2b7ff11afbb059aaf0a62c05e907 1144ffb6caa684ef0a38f037e8e173e2 000be9b21f757b96c10780ab1b54f1a2	3	52	5
14	Непонятный фильм	c81e9db232ddd65167ec1445884565c6 a94e366a557d00b5fc6443b4aac8276f fb451742814f5926bb0455205f00acf9 b200a54b216931d904c4ac6338c671eb 55e69fb58592deb3d765f40b2313130c f3e7ad83e3329f7c8bd9c2123155a477	4	53	5
15	Средний фильм	71bb6231a73780e06c937d574410ee32 b960eadc67bb22d206d325c2327deedf 4aa673e43aaec1b1a5bb29265d5e9f00 8995d67bfd35e0e0b73cbf8dd9d01a9f d6dff2fb915141db2d98490aeeeb1eb5 7bc017aa0a8b7ead39f224020e2396ad	5	54	2
16	Нормальный фильм	71e0f4dbc270d5a1d00fe9a66bafb3c6 5136077a13e82fae364ec3a3cce1e075 5edccba94816b31c0bbf91a821c32577 f74ab15f1cef96247bd1c3ebe1aa2b87 39120def271efd082e35e60ecf167e52 6551911277736106c15235014064d254	6	55	7
17	Фильм понравился	50fbaa704163f7146487742166750a6c daff852a39b9e313c3c14e35e7660c65 e78e62ab40e6a7e4aa119c1acd92e4b6 c6cfdf238b38af04bee16996d72fadde d61a86f760e9ee4a41cf1533775df895 220fdefc074e3ab9947b0b4ae0339500	7	56	6
18	Хороший фильм	d6c3ff2d1d8d832df4ead10e5385f762 e34d6514d24c4e918acf52ba8473d6e0 4207bb59c96b77b0119aaf8803ebe5e8 62990bff9834ad1a66c3826822a44351 a4122551b9d6e700f400affb6171dc89 cdb647a83c47f80aa1bae8901b425cb3	8	57	4
19	Отличный фильм	f663592c9075ad480816c66fcfe423b5 8c5950b0e0d584ec256ea6112a2ea80b 5a8af6b49929ce45399e4cea097336fa 950f340d5f1c603dccc5b07117059e44 e65a3cea183a327e1974eaecfb9e6701 fde011c6b78e5b4b40a5402c0473650d	9	58	6
20	Лучший фильм	58037c079cbcc66a978b6bdb52b908b1 63de105b2b364f6358ea107e8803c65c cff7c856698c0a1c91b4b41a0b086e68 b5ba75ee73a238e4163cb516a87312fd f1e9f362884e5e4a7131a1c847a4853a 745ff7bc391635946f8065c331bcc7fc	10	59	2
21	Отравратительный фильм	f6e8aac93cff04c9002ae63b0ceaf454 eb23f3123bf84fb9b0a5db66e1882e75 fd7a3cbbc1948d7f43eb9e37707faa68 cf8b1c8bfcf9fc7d998769c8d3fa8886 6d542849a21941db2b4a517926ceab7c 0aaca1a0ba2afe38e47aa7d55d5582a2	1	60	7
22	Плохой фильм	9c57d67d7cc82b73e28f2a80319b7643 fdf93dfcd6cc31e3a83911d8f8858658 1158180d0dbef1c4c5b0841b5cb2e0e2 701683e346617fb54f0f365713b2de2f b74d58a1124344f81bbf86932bef583a 90459f191f09626e5ff63690a194ee4c	2	61	3
23	Фильм не понравился	0b1a23da61e5afcdd6288503031788ca b1f1689fbb4aadaaee54cb95174deed5 b8ceccac4672e0fffd101d2679631d18 d4b8eaddc905974efd495dbe299455d2 2a2cf63d015f91f094636009728da82f c7d78e3c291057537db9782f909aa124	3	62	1
24	Непонятный фильм	5f50197f24be4127510ad3301ab19ac8 fe3dfe318de99629c8807fd44298739b a61627e2a38556b4dc655485a27b7a73 5b7001e5b7d4320b2db1c3bf2c7c8ba4 c9267f7e1d6641ef483faccb6320ec97 4851fc7ef15271650e027a91df42948d	4	63	3
25	Средний фильм	3ab6be13fea60ce24266a6589b8b3547 e20e14968ac749e9333fbc4f7ac313b7 ec37d07adbca7f6268f240e619599ce4 7b78d3c088a9a127d4bb21f35bb5f952 12d1a9f41e171dd2872de0c4bc2e2347 b31d94617aa690f6b2b0262a4928252e	5	64	7
26	Нормальный фильм	07bf53822967838bd0ea361bca3bddde 433e2902c3c7abf46d06a87f1df6fd2f 238aff16eea2d5a39bf101beaa43c5b9 39b3b4b2c0d98915e30819dd0e3d5d41 5032fcabbabb0ca09812222f96e62d5f 4bd1acfc2dee7e9ff5b4ce79e4d313d2	6	65	3
27	Фильм понравился	fb6f5e37cfdf8db17c4465f8842496b5 2a1d6130d668fc7b579156b41dc462e4 ce25ed4168b1810da9f7d5f594faf607 5b6dadf250a8b6a3910592532c8bc6ee 794926683c89e152b901161cb52dab98 bfa0ffabe812abf93668e8abbf34381b	7	66	1
28	Хороший фильм	497e1232080ec0bd93c2be58798f7102 6636b300c99db7e4e37137e67ead79e3 8ede0fa7fa83d720b8f94a7b8a9370f5 0455f964dec1cf5f871bf85131455ce1 0abb66368c0583884099caebbb134c00 c448d526491b21029e6b8780e5891326	8	67	7
29	Отличный фильм	3ed8ee6221528ef1ae2916f0a9a78e23 4e60c0de8694ecd781e2c8f9eb0f32fc cc02603516d15e8d939df7529a31de26 695cbd8c7629d4b7927a5c7318db0c12 fef060beaa35d53c20af03af04d0bbae 21a647821edf9047e2f74c3c877ed7d7	9	68	6
30	Лучший фильм	b9b29fe83f017c0d157cecf2c3e873b2 ee302bf625afe2627d969313a85c9016 01ae2291a505442c1407e5edb4269b4b 72b93ee85c89e4099d154ced0c0b0e17 29d8e2867dd4ec88024fc85c7d970a0a ce16935f3c130886c81d5b75fe8eccf2	10	69	4
31	Отравратительный фильм	83c2f22c4dccfbfb6377b4fccb657efa 92e0ac7037a45f5af941a7c2efeceb7a 4dd4a90a27a49f302386e5a329dbae74 1da10b6075ca27ff64228cc77bacef2a b6083583b268b662b42cb95dc50e817d fe769fa7fcc202b2cbee340af8b246d5	1	70	7
32	Плохой фильм	db5bb3e22a9387b8d37a64e7c2f01e11 c7cc297791308418e675308d57a667d3 6697ecdfa4db738750b18057b4c4b219 baf6c492b8fcc2d49224a07bd2493de3 b5174c1bfc2302b6edf05090fadefba5 c1c387b64af4d13dead9a853e276946c	2	71	1
33	Фильм не понравился	caaacbff498a2b10dcb402f4a2c07a1e 20c3c135e717f80b18031e4f7d95d300 b17bc1e60ea133f698db7ecfef1fc5ac dec33d0d7c0f0fc86cccdf25bff33613 771bac6eaeb1b9c2161bc8bb6d67f5cf d8a6bc6114888743292bf3097802f357	3	72	6
34	Непонятный фильм	b3a35bcd85f91e5f6d87fd2fcdd203c3 3fcf462bc079d2ecef812977089093fe c3965e8ec434563c403a8dffff6f0366 a661a9f2e77d33d3a96a0248daa47ced 947cac3a34ee67e7dd01a7156a4473e2 82a570a1bcf4e3d2f1031e2bbde5cb32	4	73	4
35	Средний фильм	bdcc800c021af646a756340296f05903 019a379a8d962b79705ae6dff98476a3 c9fe15cdc180ec89e79a37cb78f4ccb1 eb18b33bf51a3015ddddbc3bc32047a5 387e74c0225eee6b81d94d20284b6a0a 6524dce50e856f3ee04233ce91cbb6da	5	74	2
36	Нормальный фильм	d99a88e7d44ab57ef9c36b1c513bb71f b85bfd772b83863b8b84eb68f97d8e64 68ea28b16f36ccc5e6801c4012aee0fa c31fc80913902c31dbe9b8b2cf6e13e3 a25d2f5de0b6be713e1baee0c8d3e4d6 900da31bc7e9fc9fc8034da57a386f14	6	75	4
37	Фильм понравился	33ae56177361163179e986b94e9825f3 a6f0cbcc344ed62057e9562bcbab2468 3a49184e900ef0f73fe854d882101b4c 7f226b0d034cce293a87020ab7994d5a 31595600c77991d6754f00dedede871d 1064e21dc5dc0d77d3704ec88e48d3f5	7	76	2
38	Хороший фильм	e1ff731d43708cdd6f8a6a8c7060d0c1 87099c3dc8d7747ef64a344ef18aa4e7 4bff214823b2a3b6615c76b4471fb244 2417fda4aa20e57f78d3b714be08939e dcdb68374d64795c4cd0bc17c71803ba 35d108d2616e44986f0027caef3b33c7	8	77	6
39	Отличный фильм	085eaa80fbf01ca0b36a5b2fb509023a 0f108d72906abe0d15729167195d0e2d 92a94cea0bbc35bb0bff720bb16754fd dcf2d0940e7c5ae0eca43f04ba5ccff2 3f9216e9ee0375cfd7e6f69d1d867b34 14b86ec4366ab55b9cab05e42d612d33	9	78	4
40	Лучший фильм	42f56290f4bf70bb87b397ac1512cb26 44dc8d0018ea97e070a5a939575a4252 a15d76653860b178663e3cde7850cdf9 8d7636e5fca3fc4814f80e0b6b9662a5 bced8f58765f20ac90d25000a7b2a5de 15e8c72f9cbe59f1762325a0ee704ee0	10	79	5
41	Отравратительный фильм	91c59dfe290be978c13d3278949f08df 30051d16b5873f8158030b8f28bb5bc2 d025e3446f7173d7397569391799c61d c8bce68497cd20f5efee5e99215388a9 10b14e9e18ff2328fde0fdbd6091ebfd 62c4444b1adfe930b8f0a9e8bda9f617	1	80	7
42	Плохой фильм	5d82842c806855d1835dfce7f4023fdb 276d984bf3387512ab7b1d88996b7be0 f0b9a73160b4880495c15f2040d4dd02 5b9ca4663cb9de70e68e46e15b8bcbdf 8526aca1720cf8e726d5cb5a03bb3841 a51b1cae75add975712973fca16bbfe5	2	81	6
43	Фильм не понравился	1a2d1ffdd7958c391b8b17ea60173620 aee16c5df19605ed879f65bf19e38c55 356fce95cc0f534b0dacd1920ba8525f 1d2ca269691cf97ed74395bc432eaf22 157c8af3c9b7558c9afaabaabe3f78ae adf9d3bc23f3fc1be1badc35f439ee7b	3	82	2
44	Непонятный фильм	82865467f7bc316cd47bdcc6b95e5f65 4a93bfd3cc907c33c24599743e7b69af 9c50a420fa1e4a5a7295ec048c1d4dfe b3280b41520e69a40c164f1c7fa8e822 76f0388accaa526c0c1dba83445c1ea0 8d293a34cf476004364920dce916cac4	4	83	5
45	Средний фильм	d13ef308b15b002c4ea4ee31d37124dd 212ac311084caa014b4a26bd05f52b5b d41044742a787f401b34403c73f5e5e4 0d54cd9c32e35dcebf5f77e346403067 74645ea08d6479a0efae2aee73aa11b3 d9b19185e94716a403b495982a9ae107	5	84	7
46	Нормальный фильм	c5c73b3ae6536f40cb4386a0fc4483cb 66dca360b51b45a405573937aef8ab58 f2e060928bfdb0747a681909c83e70fc 69fd7186c43db1f412014a86b714013d c227271dadd241c17c179eea9796c4ce c562ffd65dc8c8543eeddc1decfadb17	6	85	3
47	Фильм понравился	357d086a8ea57cb7fac60d24c48b40c1 6304e428db36efa38950359452ed0c3c 853b083cb80ef001e42bc060f4baeff4 ea7412cca738d320e0d602631c3b60b4 a79e48e196fc0d55544ba3ddd8f42457 9231ce174bc07ea91d534918513d3778	7	86	6
48	Хороший фильм	4c2a0264cfaf9a5b70f9afcfb37c61fd 51c96720d18aeae875ea3dc0a0f6e636 6dbc8d30ea9ad992eed3d1471c09f759 68290ab1a71f4f4f552641622ca0f8b0 2bc1d8fb0842b335ea79c7f678cf7b9e 49bf265ee35b30403af031f8ae65d0de	8	87	2
49	Отличный фильм	e79d10f68b32bb7e637c3197f9fc2d03 fe8b46c7876fe1bb25f47d527e393efc 1a75835c2aa5155b5f16416462d5ee1f be35468fcf31415d87d823f8bd10f4b7 e16db3583315d15d2f4c8b6c742cd9fb 81b8c54437ec59acceb54b581853c265	9	88	5
50	Лучший фильм	3f43cce510f3ec9a2bd2f2855f1242b7 a526cc275a84e220c195c6d4ebba9f55 919586d7258f0518e684c53bbd343059 961d26db77a0b1ab5d1b2210489ab8fa caa3d263451985b1a11e2f8af6438f7d f960c7f4202c8a320c1330b9c0c8ab03	10	89	7
51	Отравратительный фильм	0647291f16984a1e8fe8c042f9caee3f 8d8516eed4db7027ae10e4c6aa838c95 94bfe6ccbba1e82c19c21080171ed736 58090cb27a33703efe8e44d8759a5ade 48891966559ba351d3b245e32bc358a7 a3e66065526d50169989db581497ba28	1	90	1
52	Плохой фильм	a4a4c067e3f7a5d0ef36d3a568f7b461 734ac77e2ccc6c2e96e63272b505397f af1f59f9991ee06efd64d1117e1a6b30 04cf8fe813efba9704e27a8c81bb8c29 115162bca22b999ceb4fb247812466ad 89bc327719130241615e2df9e0db101c	2	91	3
53	Фильм не понравился	7cdcc5a8f4fbcc1b65dbd533aa06537b 43cd99a4d3618509d9427920d45c6f93 cfd26ea5cc792f572b51d34655d3cb14 99868028ba2adc203edff8fe35a2beb8 8b6ff95fb5b61afd6cd4dc85b8eb1283 b616d3acc16cd10f17b7fec61d9d5b0b	3	92	1
54	Непонятный фильм	d5ccac3db5f98a96fccde6f93fed95d0 8b069af06a3aca103e8eff0f67e732c6 0a91e6796e55374871b00c8cf19c9cb3 6759857642fa7580aa47f427752e0dd7 0a0c46115d0eb88d2140a65326fcc5d8 f71f70e8af2e5a379696e8aafc802160	4	93	2
55	Средний фильм	926a943e222d4af90f5895c812363209 3cc77f2f9d126af10e7932651390e239 a7ccf5b956b88b8f2dce0402f51c832f b72478df09f626968235191e6f831d46 689b0d66c5b80396a09afca627982a95 d6ba36fd7481b859a9f9c0b6f676e97b	5	94	5
56	Нормальный фильм	e4c93351d7cfeb4eebc7fd3ef30b872a df6bd3cfbe34486a0029fcc5a049637d da9d4ec33ca23db3a02cf4ea8dae2de6 37a4b1960cf79346976a055b173ebbce 2633aa1a1ad7296dc7368ddeb3e82231 6fd49a7e285a31f3b23b38b21a1322e7	6	95	6
57	Фильм понравился	ac615e3713ea2a971beeef81548a07f2 df5c364387ba30244f2ae3a7d6885b21 a653f3400607737ad9055a0e6c8d3834 0934483457317e4978e808d5c8686993 fa93b0923621fca6623a7e45076257c6 5adf2229d2346c4fdf57dc7e4a07d2b1	7	96	6
58	Хороший фильм	75b0547ab953da8fd53608c208ccc9da 1944ebef559cbc68aa05543b18aa3d76 a326feb166d98e23cb03af11ac191f0d 736ef07544709c84342aecfc466851b3 8128b96699f9bf61246f0716a1e67d93 6ab5faa6e4871feab7c6500fc17f0c8d	8	97	7
59	Отличный фильм	9de5274fc26be8711e852fe97ba9eab3 557675e1f245999df7ed6a3880366284 1e6b41c5bbd7fcc17539d458879579dd 2730b4e8a5f76d5d3155b50a8f8c418e 5ccf47d087cf35c7d80ef47c90e19be4 2840998db2d2e60537af359563443654	9	98	4
60	Лучший фильм	e5b0ce785389d2f7bd79c7b5b4e5c7bb 0c64a196f943a22bc96707b6004f1e05 e2ebfb3fee0a985b7e3bccb818285a8a 4afe7c36e3f11056769c2a5696569148 d6dcdd069b378c3cb6ae428b4cfb135e 3622849d9aea1b81b8d0e51f8b7f5e74	10	99	5
61	Отравратительный фильм	9cb79e268fab9b0005cccd6c84d45379 477d415ab5a7ed6d6a62f72956fe5592 a3fb929672f3aa559a47216571d3bc7b 70cd5631b7a29294b040585df2b5f3a6 62dc1e26dd86012954563fbb5109a48e 4720b1be1010f6d839aca6f6da325251	1	100	5
62	Плохой фильм	6e47305317739f92bfa25879bed41990 65e7f83aa74c19d8d09110c039e73223 1ba8d120b9fcc4a0287c095ff1f65bb2 f82351501c5632237bd3960d0449b216 4c16c38872ad4195997f474f944e575c d1c04bfedc65e9e94f9114077bd805d3	2	101	2
63	Фильм не понравился	ce827e8635d4f201e817832a5253e2a2 38568ba0550d523d26196bb486522a3b 1ece211d8c6ed42037ad2923a52a4615 1f92250d4da54569a58a2880a62a5987 660772b0770882815255a06b57209935 c27bdbc3f58bbe4f73d3b2e940399b1b	3	102	6
64	Непонятный фильм	1f16be21d7a8c670a48948e5ed3a247b cec34cdc7ecf65ec2b936d3cef2c7025 e386dd5cb56024a811bc38a9058c769e 64d80f4111812f7b04bc91dd7cc7ebdd 1af049664e3dbd0a74dba97c6a20efdb 2123c21be0b155854be039fb3ee27adb	4	103	1
65	Средний фильм	74a8757b688f3e1708be3a990fdc6b8c 19f71e6624bbfb3588b92f68283dc826 b59fe64f7151ecd7e4b35d206d8ad590 449ffbc1b34f5ed508f6677be4abcee5 1a67e6ef54479d776a7fd3264d10d342 12c36a43a68cd1cdbedc6c9a41699e14	5	104	3
66	Нормальный фильм	6a5489dc6cf7f9cf5a7cd33ca0f4d268 153b1a665e2aeed7ece72fb9a35400a2 391dd509fd778d5823e0fc035d19e6aa 4941d6adcad983c42973cdc79eb46869 404ba1ea526334fe0d0c46521456e76d f06b3395d532804d3fc68ee9a92dc14b	6	105	7
67	Фильм понравился	320aabfca5af11197aee2a6b60e24e1b 0a800926671851fd68fd5deb82d0c992 85e57e10d8b0979b5c83bf10d4c75306 704da9a071af10d54da29bfc789c8169 bf5760530a0987e55cb548b89bdfbc2d 6cb62bd082c636b5d54578a5bdeaa948	7	106	7
68	Хороший фильм	ef2d05db0e25c362814ba0022c29ca00 dc42ce4ff2d9390ffd1d867305b33712 8b567d0d904d43f89ce9513fe9f99203 d49a7339bc2ef9c2039add41d459dd0a d3045aff00ed7c99545bb0997822743c 7bb0b0fc88d8b84d037edb524ddafee4	8	107	3
69	Отличный фильм	4fa0737ef09bdc27eb39c7cfabf141ae aac20194b3861d9e3a256771bb3db78d d7a792d628f4fdc426fecdf931c4da4e 984d911eb099a234f45db6994758b374 6bf1c4aa63f3858d3f8963ef8fc2a772 ff955fa05c4c0d9a31f227ff8699ca4c	9	108	1
70	Лучший фильм	39a52554e1163bf6988fa7d6ea33d7be 1b436b968bb6aa0ec43dc02260fe24f4 c2fb8e36aa7984fe6dd7c82315f07701 689c6292caa13eba7c706305aa0c231c 3e0c95a0408c737bbad18fcdf18f3be2 0124fb556cde0a0a1e55e6910f8b8476	10	109	6
71	Отравратительный фильм	fd70b925835a704bf93c0ffe64356c25 3cf5a0bf4d9a34065256764df3d748c5 14b81dfe8a35120064cb10eca19b049c d21245ace373c70c9053ed8d632efdc4 2c5122b9cad0ab40c9a856e2916d3e83 85f3de5eee5ccc14a46fbb9b8bfcd731	1	110	5
72	Плохой фильм	26ba4653c80e41f072cd92348a9792ff 9f2181cb9dae6124f95f01c984cddf28 0e49a6f50773f7ccbc067f00a2f854cf 0cbb169709e07ad94cb3903af674f55c b5af283be07974043e85edbc01a50214 b316e0f57c57a0a962c09c29cdbf0897	2	111	6
73	Фильм не понравился	7164767ab3d8f42b6cdc827ad1dde4a3 08f8897a05de5ec0357198a461bfad03 8058d3da591e428ca7824d58d9312a7e 555b7467b37f9692098d0f4a1b01d9f9 900d31d0954d3685ed7e6b579ce922fd ff682b678b4baad9683a1389726e336d	3	112	4
74	Непонятный фильм	7081b1279d79cb67cd2033eec8c55ab0 8a1bee914240a4fc73b3a9a1de13da8e b19b4484e5dca9209ed68099b32c40e8 67f344c0851d2d7d8d0c39bee022259b 2f2905bcf200bc8d473b80974572d555 bed6c4c70ae9b688e35a592b22aa26ea	4	113	2
75	Средний фильм	642f11b80920b2d233f07fbad33fc3fe c20725304e96e6c11eb43b14aace3aa6 df4b3f0457c62344830c8408abcca08a b7f9d65937ed5fd93ad0b2d2563038d1 1b26d623da8fffb5c65525f08cb6adc2 7017f542eb892136fc988ddfe3842254	5	114	5
76	Нормальный фильм	766312690b2d9df6e8efcb2fdf335e9f 88d670eec7913055b7a3f5f6edd2e3dc 04434adb790bb45b5ee7fce94d1bb62d 89a719cd484cafbf10b4f077d9ea3724 fe8d0a9c25c0cca808995053ed835922 0fee0e594fa49000fef1b3fb4957123c	6	115	7
77	Фильм понравился	4856a06b2e37ca695655d5a4406aed47 792c151f73d8fb4585ca1b42e9ed38c1 2021f4aec1d4b45f426cd5dab1a1f615 beb24a1968c31ac5a31fe53260ef5dd9 734c0b42f0d5f6c9c14d41a95793c37e 48432b4e11f029e0077f94e3922457b7	7	116	3
78	Хороший фильм	4eb7dae5c81c0590199907e80e5e120e 3a18f8b96edf86ef32f6cd49ab1b5dc5 96ae3153fe2fe7a06ccb89c20bf63530 fa87179f2f5d545776de80a5bfe3fdda a59cb7e56323178f7b95786016f90a87 f4ec46ad1efa2839d248194d995ce6ed	8	117	4
79	Отличный фильм	fd55c42e97c73059e516782b091d2ee4 ae6be214f0e0bc4785f82a0bbaa0af9f 67385e2a14addee996be6afdab95a0b6 896c1345647011c1fcfcbe7ccbad021a a1016dfa88a651416c65a3cf5757206a b814ba03cf5141a0feec0e8b2d26ad68	9	118	5
80	Лучший фильм	23cec25f246a5c09c14e342a7821eaa5 dff3ff9828cd30b70712490cc6b15422 580f2f057d8be6f989fb10ef00b66362 cfd605771c165ecd8f2f8127b47fc14b d05f2ec16132497f6e8208696bcd90db c7ea187f210cf879cf776b51a9caf984	10	119	3
81	Отравратительный фильм	5298594e22282620ead65b585eb4b6c8 1dd0b8d00ad760588e5b7e9485945348 a4324e44e0dab7d7099dbed5d540cb67 72e8bc13706b4cb66d5cd94d77e471a8 d86531445aeb11cd127d677647896d5b cda055ddec59d2edcc5fc160609c3676	1	120	3
82	Плохой фильм	76a6d517b38d59e548e33eb6546d4e35 2614054133b56c556f84e7223be5bd73 0025f9c4cdba88b9b65fd2f986009339 f9cad127d9ecc20272102c6769ff92f5 c59a533385c728cb215b9b85dbea16b1 109fdf763cc22775f7356bf8b5a666ae	2	121	2
83	Фильм не понравился	4ececcdba31886ee92296f39c4152342 2e754adc5e960c5b3b6c91fe690c0fa4 ed73f05208329829737f04daa62f3588 965298015531253bffa5f67f250f4d59 60358fd01fe65ed6af74886daddda31b bd6328986bfabb960e6b53b280cc7171	3	122	4
84	Непонятный фильм	7fd0e6cc48146a33204ca8a3ada801dd 985ea3dc0484946778fa10b463e484d5 ae7fc4da489b1d3bdbc4da4247dd50bf ce25f23c004f5f7cf22d4c513e7f5f17 ca0b36ee6de9d1eb1ec6180f40dfc08f eed9bb1d9ade91c3d3c369e8152de27c	4	123	7
85	Средний фильм	8bff0654a7caf70672efce41eb0c518c 957a710da457596fcef99aaf667c474d dd18e888a17037a8fc2a60431c49f25b b7f73feed98f56b00d8e1e53869194c9 6e3a336a57f5b19e4fd7cd180d357962 63f1e83a6e3540c3e2e57cc2c9636b0f	5	124	7
86	Нормальный фильм	ffc2a4f0c70fb3ac19cac3df22f59a57 4fce3c91a9e116ccebd13fff17ef63a9 a34aeb58d47af27b6251ea85cde0fc2f 5ee3ba9bc5016bf6a450518da99a5185 2b6d1f816bdd2dd77db74ada279fb7d0 dbae273d48c608af41efe4073cffad07	6	125	4
87	Фильм понравился	fb5c067cbc30fa2255d5c5d52ca7240e c5db96aa37e5d77065154c2e5e17d232 fede4d5b47831c16f0831b7547b96528 d284e48e8f8711f2adec3f5befb99820 767aca28f63ae703c17107aeed7af00d 95e3ffb3b0370b49b6816f202564ea53	7	126	7
88	Хороший фильм	7ca3c66fe042054d473bbd56c65d4456 6fc74e0adee1173fd4ba753ac09767ee e77f55706f9ec133a00ee907efd2a0d4 36c7641be5dd6b059b19efbccd6ae964 b13507a8b1131660c7ef9553b3249a9d 366ce58afa75869f952842c8a884a2af	8	127	2
89	Отличный фильм	53d416759fa5b6077263788f45cd1a07 34eba3f3d0116f7fa1422c1d9c80ea47 ac0bd83cfe739327056c37f035bc40ce 12895694242d3f585788ff783d68d8ec 00b54559e0fd3bf5c28f5349c6c859aa 0a9f37f1ac97ab3fa9da5ea296ee5723	9	128	1
90	Лучший фильм	ab018702c79fa767d965f8aff24a3791 b11a7d145d98bf6dc0734ba3e428ed2b 4f332bf09a492bbd4086681a81942e93 34fba698ab106657ed528fb3cc6c424f 9b98383cf68ef311320de9b33e831a1c e12d019152816dfd49f3270c00122e98	10	129	5
91	Отравратительный фильм	767cdeca531ad69e5add9053b496e3e7 66a9b695a73f4c8500dd3d4da1e31990 407b4b979ca355f889ec04d27a4a218d 2f7192a37aa89556c77d41fb1121b125 a78b59ad91b6fbdd0f486164456c56c0 8636bc7be1eab7166b8e9e0d0797b740	1	130	7
92	Плохой фильм	2e9405a8e27e3a08f855c73f21235627 35bd01b09c8eaf03d0d60a0e6a9b3f30 b0206db6f967deaee851d1569c8cbf05 1e45ec43549023544a7cce501ea6fe46 fa00aa517279b3ee0ec03bf38c81e9a8 7fd895c214c6dab2a9f4b17a4f3f7173	2	131	1
93	Фильм не понравился	68b7ca5d20654954242e04a55f264eac 577733c30b7d75b2928c27c5002d4072 5eaad5d3a44ca3c9a59d1ee0a936c49e 29dca4a1f75e1b3006ad807e6dbd181f 17897b6c18063f3306b554e5cb21fe24 3e3734b4400c4c8b080fcc8ac2bffb68	3	132	7
94	Непонятный фильм	ca0ed55afc9b2cba3ee576b56bddc525 878a78c55d7bea621434d528bb748b50 212704f3c99af08a5d2b0099cac7fa88 4a5b70145050e31643cf789cb99ff02c fff350f980041828cce997329a296327 53df8ca809457db65aff4034bfe80dd7	4	133	3
95	Средний фильм	a95e5f680116587c68ecae1d0e5ced69 1666a6fee25a94d74b995ba26603b7b2 f466c5b839e1477468cf9aef0863e055 fa6cd6a26eb49b0032681723f652cdb8 de64ce73031016fa01684987f2082a70 959a7e68adbea3af633788c8824a0543	5	134	1
96	Нормальный фильм	a111c9b43881b1baa7ccc10d7a9feb14 a6a87d76aa2d12adf234001ef1fe0f8c 15a116bba30536ff4a723ca20a93affa 341a93c02e4437b3943582a186e8a5ef b20c9bb9d61ef68b421e294b2741eec2 46690f12fed96e028893da3f39a49aa2	6	135	2
97	Фильм понравился	5343a8dad848282c124ad4a56adeff70 2067dc4b8d05b70e9bb0b520133bb6da 90561da315989afc32f603b868fd0850 1fae0377e46f8806232e7360224a153b 6ceb773f0b6e7e8fd1e9519a29f5f02a bc0d1c53cab9cb1e3f97eda896077ca8	7	136	4
98	Хороший фильм	fc3df9cbb4e5b91ecb2c4a496afb9eae f99193a5988e826f8c6f5af0e5ad7cb0 4731d2f682d758c08fac79546dffe2b3 fd7a543ad29677ed880ca2accbf8f52b 247dc8ccdd1178dee0561c62be8fcde9 e386064f7a13633faadbe136cfee8f83	8	137	3
99	Отличный фильм	b90bf1ef63e792dd435a44a570420f43 3c11cd1beaadde6a7500e8319eee0a6c 381267c969cb46fec487994d966cb320 1fa05294427e428189fe5886c44ceb5b 9467298cffd086b53323586134fdd2f6 3fa6de48e24684812d9a4ac76ae07e03	9	138	5
100	Лучший фильм	e765a4ed46169b7dee5958c9fa13b2df 772d18f5d6f0a0eeb9dca6914fa5b95a fe448e57fdf2827c6f8b53281c05459f 8efbb3ca207422214c98162c1f5a9de3 85a6b325503ff14886f6b244c2f16101 8bf09ac21151a13f245c10f3d8d68a41	10	139	6
101	Отравратительный фильм	42b6415c73dd2a67bfb3b784afad0d4a f2a0a5f570e2b98e0ee614d9c11bfd63 23f35d9200f738426e76cd04992be3de f6c8e7874d323b8b8b990074c0087d97 24cbd1511fe9ebb6ed6044ed6f3b3728 4a26e6bae79695fee7ab564a61f01bb0	1	140	1
102	Плохой фильм	335f7d9fe513d104260173373849b6b1 4d6286ae9e588971eb321dc50afd935d 8242fe354260380532e121b32fd0f36f d6ddbc9f20624db7a7c23aa1dfa7c603 b7a003050a6b26ec97cecf550c6098dd b4027a2a78dbc7ece9206137813d5b3a	2	141	1
103	Фильм не понравился	9a55b4d8f74214d6beaa7dfdb131f29e 8195af259b18e6f9317f04fc76b9564d 580c6ee0ce12ad1ebc11b3ced8bbefad 7f380028c608c2412ccb60bcd97df58b c31c2c7adf1b2737f2f998656d8ff1d9 2189273a0db53f83fc757ac0ddf69209	3	142	6
104	Непонятный фильм	5b6f6ecd0a8d9c7bf6c8e31f226880df e048cb11d1aee6f08ce211da5ef1d906 bbab179edf88602c3d5c48cfceb96f26 5e3d80d97c52233156deae8fb7945905 56eaf88a46ce788834725dd9068f8b9a 8308ddd3442985fe8176a3d0d99b9cf6	4	143	6
105	Средний фильм	f9dd27301ac1d2fc03aa87197966d6e9 0538c26b5d9fccec519bf701780b47e4 c25bc5e71351e717df7f14b0a8285bf7 22e75251c880e5acd07fd61e46931514 396c5d8740da60cc33a019c3a792e3b0 e3b0960165d5e8817de8492ffae84771	5	144	3
106	Нормальный фильм	1c08ee4b06215e418a10f460aa357023 47a579b5c4852b17b7b931af593404e6 26077e3b865f9fa6e804a16c737c77a9 1a88374c2496c1bbaecad7fbe7a15fde 51014f5c9e8e5c47c1dc27a072cd5200 d2c0630b76d7a582adee1ccb46beb279	6	145	3
107	Фильм понравился	c520f811749c4311a7dcfd08a71b4a6d bd0a169214ae2cbd62504d783aa0471a 958a12a53443b7b637a1c853e9206cf1 01cef9aa310937e553dcfeae05e00f65 e74c5421f4f43108c6ccd816906f51cb 6e667626b0fd58b0ab56334272c765d8	7	146	5
109	Отличный фильм	4e44caea4c3ec6c6580b77be4b14f251 49e264601d8f03bfb18932876d0b1801 54a677654462c5896fa90fc05487f1a2 38a3663a5a5fca079e194b250771eee3 1b2230d6e790397cd2e7a17ad58a01b8 f6244b1c8b7488fa94e891a96b6a406e	9	148	4
110	Лучший фильм	9d34ff97b64d4499ab926949e96cac7e cbc42f85b73971318ec48940cc9dba58 690243f5d568034bd726ed96dfa764b1 d4a4d32e8477b891ff0c7f0b9cca7d3a beb169123415d8c3c2298643d8718557 e3ba3ceb8522d6c9edfcdb13673ea9a5	10	149	3
111	Отравратительный фильм	32975bc7461cff102c9708992243e0f8 ce3959fad2dcc9c0079449cf8c7a447d 99774ece7869e6c59e562a7df467dd2a 90c18fef8c6375d4236eb78bb67a5a28 c8bdb37fcfde7b4f12cd948ca331de3e 3e1ab4661072b7900e162fd9cc2f114c	1	150	1
112	Плохой фильм	6af9149c11fdc72050f5f5bc7585ed6f d5f58e82a08dcb6311b1d2be24c9a3be 034470b4bb4e2c9f6c20f945320689a1 13e5ef44a25a7523594fef1cc59a2ecf 70ed8a55b91245b205a43c66c9041c9d 26e35b1d60652b3849226fe06d733d3c	2	151	4
113	Фильм не понравился	2576a130f0e5abbec747ac1dfdb09210 34fd59aa32401257dcf56c60a2c3731c fd520c77e334ae0378c770260638fa0c b1dbf2541b4b74447b444189a04321b7 c64ddc9f363071edf4f63833f032763c b9167014a61fdfb72f57e6914ff240ac	3	152	1
114	Непонятный фильм	f45e4fa58248d6659329116bcb87564e 040839f028d58ce0805042270d2e641a b689cbb7a208bfd3e97892a4f0293718 8bd52a4d00357ee45bc6e26b716d0fa1 f0c1b4c88af06425e76c9b29e401dd4c 6ff19db301b50731a6d50471e2f23365	4	153	3
115	Средний фильм	e82c4f32a5398865d75da19975b86ff4 7b8641ba44af6bbacb49d10b1835f9d9 f8190297dc419a9f4d9a01dd22c48136 b9a39a7cee4ce910a9ed0011c6de8697 a65b7399082190749d35d1dbfb176037 ef27dfd0c983e87a9ef0dc80c3e7ad59	5	154	1
116	Нормальный фильм	8db608d768234d0b7bb2d7942db74497 37bc77931a4914aad1f3cc8b4bd34de7 cbcaae987bac8283061c7c80672bf7eb ca7a86d4e9cc1d5f43312736da29f012 30f73e6624efec62c8a4dd38af2279b6 b0211e28340139b1dfa4b9e13f613429	6	155	4
117	Фильм понравился	fab41be07ac9e9c3e6506d885bcd0251 ee1349dc8f8b774aaec9845ed131c199 9626f7ecdc510808308e58b1511e05f8 042b1b2ac416f513837f433c62845551 73471a07c7171e07bbf89cd47d2395ff 1d6f9166f61709726844bec66c8501eb	7	156	3
118	Хороший фильм	d2da94e82b6b10b863e7bc33c20022c9 2ee505caec5c0140b1131e505b6150de cabb7e1475e9c948c295ab24f3ec7097 a7fe49fe0b704a5bf1b178b650404e78 3dddcba6b8912ebe9680670c086fc388 169a04c80610d2da48d736d172d3d8fb	8	157	6
119	Отличный фильм	04b5b5afb77d124f56772ffbbfa153a1 ce075ca5c2694102d15ddf28679e7ce8 28b933cf6d2685b2ba7eefd468960a63 5d574ddc1c779d42e143ce501081f190 88878f2cfa26ba1c5006fb32f09d4f71 cc2eab7ecbbb5b330091c7fe371dfc70	9	158	5
120	Лучший фильм	2b83cde4f921610c094636e9cbfd7f09 b8cf6ce3e38ebdbf14bdf1ba2621311c c37256068845b9dbf5311ad2df587ca2 1c8aa73a372f5527b5e69dc75bf6ab6f 9a80022c6a328010917fe8c3af73ecdf b8205ce21b07b895be5833cc6d9f2eb8	10	159	5
121	Отравратительный фильм	9f15b45c772c3aa0fbadbf5dec7ec13a 070c714592639c6c37527e9631786375 b5d1f4a915f242eda71c8c4155a10e6c 1578f3a7660cb0e5153f0e8aa08d9b13 a14000dfb1227752866384830591c28e 320054fd61c948aff4e44c886b794dba	1	160	1
122	Плохой фильм	1085930257dd9dd22c8d0cfb3659f73b ca5943c5895659ad85bab57d80b8d60c 39ccf89de437ebdb27e78f4cb77df5f4 bd7e53dd7d3ab2df7b781301187052cf 4e82099d1e359c76d3f1948b26f7c2b2 a3e2fb88107ddc34b809dc16e871e182	2	161	1
123	Фильм не понравился	4e3c2d0828b9b5e66aa64bf729c5c4c7 674197af4c20e76d9bdf7a6fee2d660a eee6b5b2184bbfe28a62ce7081c19e26 ca30f7801ca7bee8123ece193d1214dd 16150b567d4991598702cfff6590c993 b52eb6ab8f21a3af480c0cf708833cae	3	162	1
124	Непонятный фильм	04e7b4ec6705bd9b978de6c30305c0f9 77e1fae7d202391aca1e0881e1e20a36 e2895eb49875da959e1dbb3e7192a59c 741a83672f8200b37a0c9ca2fe65c21e 834afe3da53dafece4b4669bce272c4e 9eb9854d8bfe7f15f524f0f0b0879511	4	163	7
125	Средний фильм	48996e1e3a724c083df7dfd921c8a2f6 08dd8e33b2aa2faf6ca92cdcb1988b65 c11571c2db693a39ddcec41fd901f78f a52a265ea8229c3a867ece6acb457fbc fe75bf4fba2df048c093133101a292af 0392fc2bbe0d761c68aea3592ae69cb5	5	164	5
126	Нормальный фильм	49c48690d75d71788f350f623606ca89 aaecabff5bc76a8d6a479e0bc90a2d33 474981a188bd18540c37196a7f804dce a7b60a9b87426a04be15b2b6eab831bb 1d624f0ab0af5414376da844ef846552 38bcc97997fa7f975003af0e93257af8	6	165	5
127	Фильм понравился	8b60b45e8ebfa7969106f04223ef572c 5fd52964ba64fa356e8f20d73319c2e0 a3d653810a0ef70668bdfe81ff464df7 a364a9283d2a2fc5eab9f5a249ee3057 0189af34e968fbaf162ea1608932dafb 68e84335200293b1fdd34da513152727	7	166	1
128	Хороший фильм	0426b57af09dfc25c2723bcee78e1f85 293710889e0a7963312cc8d30b7179bd 6698e7d2a2dccca1f5cfa116caa0a64e 4b1ba4aa61f7c953d8832da09e118a92 14e5554b2ae878b000f3fa309fcabe5c b4612e6bf7229b4fc83309a6ebf0a54f	8	167	7
129	Отличный фильм	0700260fbd9e9982c7aff6f7a8599655 ffc5a3e5d03f36f7a7529deb5f016ece cf4130b15228e43fce963287cc313ba1 0380c0d3c845602374b2b047301d4fac 4fe8998280fc679f07bbabbc3c345486 cea8ff6a96272e0841963a0da52417d8	9	168	1
130	Лучший фильм	c461515852d90fecdf41ce31e928e1fa efc92b49bce328582f3d4522c73eefe6 40ee4ceec24a6da23f7652c712a7050d 18e91b0b9b51780670c40306797211cb 5579b934bd16f5d84a48191de1467849 dc796268a60676483d40c5392398f32c	10	169	6
131	Отравратительный фильм	b0b9ded078ae01e43bf5939386600eaf 67a5596162c527542a4453164c7f6040 30670a5865e992fb07826915ff38fe50 6cc603529e1fe62db8acc911a1b6ecd7 75906b5dd8384d917880f1e793ff642c ff0616ad5c1f1e66442035bdcdc1b4be	1	170	4
132	Плохой фильм	37f2ea5e899b96b8060c26dbb1f76ad9 1adacae0bdfe605a3efbf16acc501873 f19404e60af94a3191fc4904b6902cff 6b62de93ce195f6ca39253496297229a 0c2ea72ade07e6facb3aa1568e0abe9e 868b34c955079b701aba7779fdfaf6b2	2	171	2
134	Непонятный фильм	35f7fd680cd6f22fffbafaa5b23c5193 4b52aee041f71ec60889227affe3efb1 06730c66b712af480f9e9026419a85ae 64e8e9c33d1786d12f8bf26c8ad4c82e 86410cf3e20fa2523d2f2f65e63fa4c3 412745d637faa759ad04f211f19c9fe4	4	173	6
136	Нормальный фильм	f0365b481f70d975b88ec566a2d54dff af64dd6973cba3d843b29ef32c53b389 f6a6e8bd64f577be860764d998c5b91d 5f0902f1383acbd2068bc35e61fb0c60 0c852bade72d159bd888cf6b2275cc35 7badf3261710eedb5059586411674ad0	6	175	2
137	Фильм понравился	75c9dc951ef868118ec879fc45804db0 a01c890dc9b2da1b4254047bddcc1699 b9f468fa36f8ae52375181f18f3aef17 6a525de438c99edbc8f4ce37c1196411 e4cebbfe0b06afe293716b7f8315f67b 5287ef5037c15df2f8e98dfdc9fc6c7f	7	176	7
138	Хороший фильм	4d66e2c70caa82c816efaea97d4a1c5e 66cc0ba7cd5a9bc41e7fcbae50677a49 25752b4bef890bf3936f7ca790bb531b d7c8c5a1130aaf0a0d96d8a4fc7909eb 55fb2036e31d7daa7e1507dad2da2cee 481bc08ea26732ce96ab0d0aacb16118	8	177	3
139	Отличный фильм	3604446f96c0c09208f9bcec4a6b2392 3c6a1a3e7b0ecb8abd0527a89cc90292 91f45f7e452224db04963c7a447386e6 6ea26acb82b041b9d43b02669ded26b6 05a7a83645c5e73b5939e74c91056ad0 478589d2837aa4ca6b3b947dfc28e264	9	178	2
141	Отравратительный фильм	bc317b1ce1b112454a6b14ae090cfd98 fbf3d494dbfc808b709f6e59d2fcdebb 8975d6b496a6cee8242708d72911b87a 5915846cfc014b1818c1e85d415d8ac8 712ddf37c2c64d6287b556a3cd3460ea 979b0a9cea889a7f737028789fc059fb	1	180	3
142	Плохой фильм	2e12f15bfd1bb993bed9868180e6cec5 3ada39da7354a785e8170db703276a76 0e38fe6570aee581c009ae1364f88360 a16a4a259ad14e089587c2b4ef9459b8 01b2f5e6005a0dc9d5649dfc1d8f14ee 37c162aa1f8558d499d4bacf1c9c1d9b	2	181	2
143	Фильм не понравился	7b4391e58e6ccb0e7ed4cc890a06fab8 863374cb4ecff9943a3012b6ed13d6b9 1ea25bedc1828cfc782742ba4060ea03 45cef4ca76fa2b0b896f040935d6d6c2 faf5a13ff631edc114a788708a87496e 90dc8b48a8a3462cd2a36825c1a6cd2f	3	182	6
144	Непонятный фильм	3a65fcf64335f0ab887ea2449bd2e59e b9f5b7d2a52cf1e237f038b851cd6d9d d79206c3edaa61ee5968fc11636963c9 bea0082914f360d55097819ec7936c82 6a21645de6f37344757fc5a2878cbc29 b9f3008ea62935ca9fd0424cfb0ef0eb	4	183	5
145	Средний фильм	d1e7b346f8eaf5c65aa7703d6a44adaa 2a850f7b517385647a43e863f6dc2ad3 b5bdb967455af386fa21ca983d231304 f9420281006d7565b9673770c316cf44 c1b672dfbe644f255d978f8557404268 f903dbccfcb90280522d612b2b459946	5	184	6
135	Средний фильм	6006daa0b9f271cf27cf3fd3b8cef167 229639cf25af5c34224725108395b4af 3ac92d75ed54ea6d0ca7ece673961e1a 8112cf1fec305ed91ddcfc1a82b87615 b8eb14e7005f9b566af9b06ffaf6f141 437a6e151be3f4fc5681c0db5c2b0c7b	5	174	9
140	Лучший фильм	3cf4f51ae9cb69c4ae9898934fb06259 3a8bef00bdd6055f26ee07179fded6ca b8979174f2877f2bd4fbd4866314ee78 881693b9be651b887f806516c737f8dc 0ac56991e979b4b3a29c133f2deee2f9 c8fa537cc3d2853808a84c0d302994f3	10	179	9
147	Фильм понравился	a3d0a7f075b72974ec468332ad890d7c 217b42bd648f745a713850236877858c 6bf7159f5ef547a00cdedccbfb3207cc cddd805ab841f2a1997321b58bf5c8e3 55c9d8cd6629316c33211fde87ad0492 46072ec480821315964b8e7e26aa9c1d	7	186	3
148	Хороший фильм	4c7eaab2ed1005ae43654962df499119 7980fcfd2c645fa524fc40a3929ab150 4fef742c303e9708423a682092c9035e 149474e932ec055c34802e65965f39fe 421c9ec474d6493b3186e69b8fdbd509 b8fdcfecc38fd0e11ddd43b872b3e80a	8	187	7
149	Отличный фильм	d86a679c3a61d31c98f91e77bdab8c53 d3ffc1bf32b000ec2f99cb300e158ec0 89af2f8517d6e6caba9b895830a77586 b13b2e07dc8edfe9ea854bfcbc694cd2 818d7e7515d4b3bd98dbd7336d4e03d4 990f05bd6a85e628dfa89d39bbbc8636	9	188	6
150	Лучший фильм	38751308788adfa3567b9035c0d48eec 38d1175d3f883cc72c9a5a830ff141d7 585d5da70fc143d3e8f57bddf5d5ee74 093ae8ca193f8757a843f59a198f6c8f 5d45b3e96313ae89479fdfda2283677c 85f646bc6ba2de30400b7a863df6b493	10	189	7
151	Отравратительный фильм	f48e8a43aa1c3f9d146091ee289fe291 1159b521415e9711cad2be6ccac2b0cc fd64157eeab341b666c7fbc1e9a0fdd9 c4b6c0ad67125d95df2c278e0ec3bf8a 6dca4ae466cf7ae634e219a8a1b87ba4 f0eee4df18bf9e4b8a80a7520009e3f6	1	190	7
152	Плохой фильм	28a0e8d8ac29a3231d88c41b5ced34a2 2798471ca4758817874b04729ecd983c a5ee7e09257bda7b4da3b28c13630e4b b133b5de26caa6b17274b8e38a3b72c8 f056a0d16582bead59935f1f9ae41e46 1759bc7d543d77ecde42f3570baa7851	2	191	4
154	Непонятный фильм	196581598e4cbd763cc5e3a07de201b9 bdbcd54737ba6b7e54e63c69207ffa34 0e3c85bb23a8821148a1326f223edfd0 20d7bc1d5507ab965cf320517afe6c17 acb2fc2a0a56df80ae586cf3f42c6934 28420c749170bfe7aabb17bd76f42efb	4	193	4
155	Средний фильм	f28edcfd1fb7f183b805714aba44c95e 918576f8593ed58755af54c7722f4c19 b96b82d82f45da5b2646961d8713eb7f 4e7926bb0bd527fea0538c4fdffe084c 5d69eafcadf11821833a1d70b027a377 fd5131ce87983eec04f41affe85954df	5	194	4
156	Нормальный фильм	d6e2f4d726de972b21a0e8bbcad562cf ed288b24ea581b9fed4d75d6916e1dba 20bbf8ed6419883a4f79886b6af36fac 9b5ac2523fab53f92beff37faaf42ff3 52c3ce211b98aa76451372bcdd632791 f6696042657539a4af9c36b63b37bd0d	6	195	4
158	Хороший фильм	ed2cdf9a60055232a7023951d5d6973a ceea827a5f7982c71461b9b3f6881023 96cdf611f5f0faf5b92051010ac90419 4248fcb770e465fffbc2f2ffd88b7457 b51cecb00ec16077e282399fe0fab8d1 fa922339da5f967152f1494251f0875c	8	197	4
159	Отличный фильм	155d025df72280c30be8a8b436f04f1c db1a547f3a87702efd4e0d168d0d54dd e7ae91cc5ce587e8b426f7a3fb642049 15062548f257e14c99ba0400757ce749 d7f0a56117e15087f0922e9e6d617e99 f7612c8f75937f3c9e5396bceddce616	9	198	7
160	Лучший фильм	a7275a62033bda01c5f6ede94f9447a4 1634af664d9c173cbfcd6279dff6303d 3b54e7febffea650538144c8efa32f4b 5b60ba4b4f121d39f2e0a5a53f689bc4 ddc895c2e95f70eb3d33786a205cb15e e96674077e5bd08aa060dcad67cfc1c2	10	199	4
161	Отравратительный фильм	d9a25e47aeab59d1faafef31eb877dda 2cef55b8071f8e372d973146c86a781c c5ec7419374fdc2128a956a1c105be4e a9ba8d0056534cebbe2821da3efcf18f e0ec80cffdfeb210d126a5749762f733 6b44bba70601d02770a477b514c654c3	1	200	4
11	Отравратительный фильм	e1fe7a9a326485f6fc188683d89881bc 93e917faac043897fd06a7b3dfcd4916 4b95ac5378b6c3b3e795d1fee1871c24 6abd6c6d5dd29afd8391b9a119f61e6a f2da04f7782f4edd125924f445422ad4 d9a843f13b54091a5efce3da6f06e73f	1	50	9
108	Хороший фильм	367a8abedad56f537bd970a611f6a2c4 ae1cbd1b1f913418570008935bf80765 bc569225acbf0df1418970c2fce2a561 c0091e095ab81170581a1194d1637f80 5c008fe91d92c2431a319ed8a3ac7ad3 b17f61126af52c4f6fc57d06221d0f44	8	147	9
133	Фильм не понравился	46fc9f779dbe316c0c66e3f0fe4088e7 bde730eca977b94c8edf224fc5afeebe 55672f24c931fdf93bf8ee90bf076154 9a94cb3566cf42ce1ba01c9210db791c fa5ead1ce15807b60fd8ed436af4e0ef 579075ed64c5a96b9fb2e1941242fa71	3	172	9
146	Нормальный фильм	00a04cc3ea02d9050d4a5e469c6c315d 76acf9953100cc048fd8d6c80f9ed4d2 f889f2c65ad2382fc3049f15533a2c09 cd959fd3b73ccd28f4ae8cd5a0d283ea 07d8536fcf917ebf8c76f3fd33bc67e4 5b6c7722867747746ed5865cda5f7274	6	185	9
153	Фильм не понравился	d79d1bbd78ec1a0c99bbe582d1c74676 cf1f471cd71d48a5cdc19dbe83a176af 920bd201ca7d48e0428471604ad886f4 ddfa3cd6f03e71552e0bbc9c916d087d 1c2016b371e4c3cde34817c8b46a4d01 e941262b1bc1be7024360ef5788b433c	3	192	9
157	Фильм понравился	85050e23ea66af3e5334818c879eefb1 16c2e2aba00c120a64994f88d60cd951 a1f44587c3af0d330ab766389167a780 9707c25cf96d49c9f28fde1037add9c9 7d348d0c6aad901676be35633ae6f539 7237f2ac0448b79f5ac54624a4778e2a	7	196	9
163	Отравратительный фильм	ab159847c9b8fa063774e0bc7bc18fe0 d897a02f66c315d1655795f385a839be cee1c4d568bacc27ab420f666e1eb88f 84182c27b7ba87228914ce52a59b7046 dda518733600b80b439fc52b4123acd3 35e047d990a154c5a2d768b7ebcf412e	1	40	18
164	Плохой фильм	50a75888d9aaa9a3e5403ff9b604e280 72c3635e8c187638593a49306dd0938d a128c86ac6f78d4a2f0789fa6921d676 3485011bd3c58652fb8bf39ffbcc4100 9ff002b76ecd43ab0b3b5e9dc4789390 f7641ef3734eac7ba7699967949df233	2	41	18
165	Фильм не понравился	944c6bd5349e22992d3be6f4c90a3689 87c8f2883fce4b382cd92b524ae0a095 e934b549b883d2e2ecb3eaa3e5504cfd d13bf7aadd9e9f4f8a3b8e07800e8441 c79387c9d0e5bde7813cdbb1924caaa6 bdcdc95fc17feb8abe39760d1cdca031	3	42	15
166	Непонятный фильм	a40a9108e1db0bcbc3418e8fc8a51a21 f917aa9767d6a8534c7ca94d21755f3b e3faf892dc15834a5ab7acae400f73f6 52354b86c8be38dfa6069600cb8886b1 fcee36f8255481a11b7da4f0ce5c4f2d ee6fd9aca16f7b6d138a7870f8c42011	4	43	20
167	Средний фильм	8188eccc6aff54b0f2becd3d037ea6c7 a7f7b87aa525369ea7f64a0ce5abb510 b872c3225a4959de0668591d18dafe9b 9bd76edd8028b1097fe2f5c419462375 a5bf4bf136c842caa99846690b5e6265 549715962fffd1ac1769c7e7101e0876	5	44	15
168	Нормальный фильм	913e47514c07c56d3930de3d13ce8935 1080c7b4b36e52aef636f34b73fc3bd1 d1244c6a8da0def9edee34376ae726f4 392deb56aa61f1b86fe9037903979198 ab53682ac6d80eb74ef99c2d5461a899 36eebdf5bb1a96c28692b3965b8c8499	6	45	16
169	Фильм понравился	cac199607cd81c7d33b6ccf336635b2b 39db55e0901681fce3c1dfda6c94b4a9 efa0a70e5e94e410ad73cc8ebce98b8e eb7164aaeb1e7a8263aa1564507e4eb7 0d150b5e097dccf4eb9f4b5f142256ba 031df6bebeb0b9e32990668b7da56938	7	46	19
170	Хороший фильм	bf6dae28fc44db3569a0f6cf3554f4fc 71ad62a3a9206696fa33a6f25163ca51 4f8de1fc770e738631aeecf3daea58b6 ef91d7dbdc434350f3d43b885cf5e02e 94703e669f24e086de6053dd1cdd720b 4baa16a800096da2853af2acd146e213	8	47	17
171	Отличный фильм	34f693f01720e7ac7d4b6a65906ec1a2 8da29ad42d4513c544ae57752ffc3f8f a1e83a39701505056b26937d325a0c10 7a730592a0a622671dc5911e23c37d95 00db15ab2e841978a48b46a8a368688f 4030938919a546472f104ee0772ebd85	9	48	19
172	Лучший фильм	58407fe7f6fb45750f324ce7ccc3588d 2c287fcac004e09878bfabca9b1c74e8 cb2b9fa1580e83e5e72fbed69d76cdfe 0fcf008d2f9716cbfa8b0303d02dd08e 653013790e0c41ec7383fe91f5ebb260 f05b1960b2da512e5952b5caeab9300c	10	49	19
173	Отравратительный фильм	e7ca15491505956dccbee8ff17256f1e a83108d494bf72f2105654fd58eef148 bf562ecd70dcf84f2313a92c35ad6e1b b1778553e77df524be66451438288282 cd5c82355a47da6437b8f838a5ab9914 3490dfd8e65161ad8eb2baeae6e32d7b	1	50	17
174	Плохой фильм	c41ceb25a113ad418d8f725aca1d015f a46d504ec32c3f47ec4ce822c320e05a d8e3b6798bec477a4ca7c7fd1a7cfc80 71df68eef406c36068b9a3c81e661517 b0483790e777833bfa5644c8856eb5bd b5af9a70851bd8c9fafb6a8a0002c4ef	2	51	13
175	Фильм не понравился	3cb2ba5f0b93857b48db0e6bc2b67faf 265a9ee816365e8aa33446121138006d 2d58968b6a3649619b21c16d6300cd7c 0a9f6f52004749778ee8039a3ff316d8 6cf56cd20989eaa0ab9457298e9645ae 9912a019eb554b808a83deb58fee4696	3	52	18
176	Непонятный фильм	6c486e6ef034f16fb18bb5b753816419 abc05b00b1677594267e7981d2d3eed7 3c5fb60e9927ed9c7bef9b4517225941 59f41fb3f298c1009fc12bfe6efa5837 5691f0fee2d7125a5745286983cae0e0 b8a71a4526d821245bcfebb14f790464	4	53	20
177	Средний фильм	5e2095910e056532702d46654525114e 2c8e69673ab318287c95613d0de76661 fc4440112f3c5646c7fe16cfdd235bdb 628b0b4269f3564aff55f4159f9ceb85 851ed21608235bb746dd3f816ae1cd67 61ad9cc08c14d5ac63ec3f85777fe00c	5	54	12
178	Нормальный фильм	609807b533fad5ba6c4263e11812aeb6 90917be916f22e83b0654e1735e1e51d 3a183da17c7fb17912565dafc7167426 ce6cbac1683e78a4dc83431da19e5437 cb3685e7cd7a7a94eaf10e338673c5da cd4c048a61795c4339be8dddf88be594	6	55	16
179	Фильм понравился	a0cf4742e3716eb20bd614a37a00cd82 268c434e615e11ed13d70a45fcf01c16 69e9ea18fa0f3008404d2c2671bd50bc 1e7cd189bbc24c828f0bbd3ddfccc7a4 efe26e8a08116af331cf0962ac0306a6 fe6a20ae1ac8fbea3944c8c6ea528779	7	56	15
180	Хороший фильм	8889143a9ef5b72bbd43a10597fff2a4 6ac3df9d905c90334f8e964d4d7666bc 92fd78657584a8cf8db938e880e9bcd9 93bf9b5d657d7fd776ec2dc11247d731 d89b47d366e6194b9dde9ae9c109fbd3 c710bdc1d74f7538e3724011fd59817e	8	57	18
181	Отличный фильм	8fc8a1dd1360cafda3b8a520874f253e 5e3d5a3d963cf1efe2d8e21587ec4d7d 278e84f9d07c2856ecb6b805284b4e34 346f391b58b28e111be4f4977a54512e dab0b917e62bca927bd8280b2901df0f 7ab0ee4910ffdc911999cf71c69ac828	9	58	17
182	Лучший фильм	08f6cc048330adb4a01d805523e644d8 e9264ed919ece33860218e1fe64f3062 7d886158881f46153e8b29b6cd940955 4d53d222ce44e594be17e0d12a31dbbc 8cfd0f55f6384023eddf574972caa1de a0e61a3709787eb16b53288bb703f424	10	59	19
183	Отравратительный фильм	10912083a2e493554c41731d1829f5f4 0464d26eafc3e6975227afed060700d5 300745beb82b1d01c949ecc2ce72c347 d1557f2c15a0ad4b2566ea5589021a4c 7ac589513315b65a4b210519e47080de a716ce039dcd70445fa8b13c8ede2a55	1	60	17
184	Плохой фильм	1fea87d168e109fc621fbeb43f805484 2598108bd5efa9d96268f27a0aa776bb f47b9466ed69c872c62bde794c0e8053 577d351cd09d921321022364ca315adc 6da60e6de06c7b6bbdc35e6a1d0791d9 0eebe9be0440cd3a445731c934056494	2	61	19
185	Фильм не понравился	f3c694e8528b6cadc47038edf830e04d 0ec99f789690fcd9723d7968dd17753c d152f96978439521bfc19259c75be8b7 fa7044e3d74078d3f1bd89ad2583c909 a2cdadb7d267623f31197189c8d3f241 78c38dca974bc0bf25fae48ba92ba2f6	3	62	19
186	Непонятный фильм	871dc5016ab021dc5c6c9b15cdb80296 7567361da722917c167f8b463f577fb9 98ba09fa161323298a6942b6698a099f fd69d2251c9790c7d0b9c9a920a4e132 f16611afc4f94b7b0135c6011eab2c31 b9dfef9ae37374a442bb7582d321e657	4	63	12
187	Средний фильм	2374a43b8b4857d34b49d0f07f8b7ec6 b299fc8059ded6153a07f8cab6194b5c 9735402565ed1c3972dea03cea78f84d 9c1248602991cf13de2348c72dc14617 31f2b26ee55fa369e5daebc55cd74205 8f7819a03f294090e2f8aba446f4640d	5	64	13
188	Нормальный фильм	b2550f03f6e0544431c60cbc06b41142 6ffe770aad475b25fa4de14006cb3350 6e97e35beb8aff07eb7983961d2d7e40 bc5f2a2da2a3a685148d35d10ed2c6be a15c024948171c214231a3f23c4f9b80 fb716f07da2ba00999069f2e5b1ce19e	6	65	17
189	Фильм понравился	b17469fbf8d7dbcef472896e962a2625 42404cd20a4bf988ae4cca84d8ec143f 5806e78458070ed33e36aa2494b9ed6f 5f26215f451a7e4aa4f1063369aa145e efbf721ff71a315be54b6c38147b420a e8f41cd23d1ad485a6445e6d9372b28b	7	66	15
190	Хороший фильм	75638e5c6f5d65cc1433840c3cba7d88 9fe1cb4e50c15aa90ebe1bd08643a712 8b505fdd47f85e8dbbee8e0c82847f1d f44891833691c55306f2e1c6b0135050 b18b194765dc2b9f06b76c3f9456cbef 7199fdb0801ad38333cc35ade509c2ec	8	67	17
191	Отличный фильм	45df6ee4147007968840839d11a0ecf7 4d9fe37147f4889e95bd737239c4aadd 68da1daee421857550ca19377e4a171a 01c60f210078ba8a4e999cc4b12e3e68 090765d46ee3c6a56e8c4ad5630a81a7 ddee9b73a6d25ae2cb93b8ab9eda9db7	9	68	19
192	Лучший фильм	9148ce4029b509928b7f3119ef1f6f18 7d3b434b0872bc86bbb70b94d1e681e5 42e27070bbae88706b6d171e917de490 b143bd2acafcf0e569b6df10ba312f20 725b70d7baca347785225f5c671ea0db 56d2ee1376fccba398b71a8b91e77c7b	10	69	16
193	Отравратительный фильм	67c02b2afd7f50d38a37f454d58299ab e3b97366b4113a2887606fd0ab0e667d d0b6de6cbbfbe857cbc8e3408b9f748a 5630676d3b0172aea3f3dcfb30c9347f 559aba44a9e7dfaab9c4cb8420c13c3c ae7eb0a25a7dc82ef61c25b1292f209e	1	70	13
194	Плохой фильм	03e9310f2ebe5beb1d55056bef27c116 636608d430f51b918531d161050bb941 6209db92e2da9b5c88187396853f36af f4e9081210f1f26084cd648bb2a5f31b cb82d5627809ad160f90bb593b52d7a6 d73060d9fce6c35f20db016ec12937e8	2	71	13
195	Фильм не понравился	3cf120ffdf64f026c03aa38f3c3ac33d 671316f8f75f402d6812f0d71bf36f33 ed39bb8760887355ee2e69ab6e5c5fbc 51e920a9da4a352a71f794493a17e0d8 371260bb48a9b1f201541838fa8a15ed 16b534a7ddfd3e5eccde9c9b0f51fe3f	3	72	20
196	Непонятный фильм	d0164ae3d228b0830c36e931679fd98b 5059694108bc2ba52995a9b4ec934ee5 452cb72a7b3e2451c5549577344e1b8c caa070384c59e1e5f5d3e68794723993 6ebd301f2e6a2b8ffb2720e0b464c4c1 e3ea86f5d8f4e34a006272ba72fe0ef9	4	73	16
197	Средний фильм	d8b857c46551ad7fd4c7f4f09782f819 050c62c296b7bc8af41b3e3909848267 e9e46dafb2aa94278d30f2f2532e7fd9 8614c05e50dc2b8561013cd2047ba2ac 23a17721c02a0701371c53a14afd52f6 8eef40a949964b5a8b294bbd0501b799	5	74	18
198	Нормальный фильм	8105c7c79d1cb81d10e7990b3a9c58cf ab7f260352de705c36d507388a27e954 dac9ecf2eff35d590f943f93a1c31005 feeef36d2586529c54f9e57415df190d 5a856b30d7c4f17991a96b1d37844c02 dcfefb3475f1e160bf936d8b2304dfe7	6	75	18
199	Фильм понравился	8e51b8a2172d4a92fe39a821f26e72a9 2d9b9339c268bc61d5e909717caa89d3 c7e2aa78aba47ce99cd648e0a6029e12 0cc0b6e59cecf528a339b723b0f5af90 75c93db4150844a65806587638d462be 133586c6e15e7ba86ea10522e73dcded	7	76	19
200	Хороший фильм	ab32e71e4a306a86ce527d27cd24aae9 8f3386edb50d04da84b95bf629718e70 32a9083269ad64adb96c5a350e7f7ada 9e5d84f099948db4fff4d43d5c7f31c4 bbbf8bcd11d63ee4c1aa7428e9f2d8df 85bc848f233a2bd0c5e917c17d346f01	8	77	16
201	Отличный фильм	e9a08263f2d47346b222f7f1b7e3f878 8cc0e7dd6d4b2dda6138534158cdb962 d966bbd1b8718956f404b3d3c3b32754 f67c33d31b453071e3a9adda42fd12a4 b55b1102e3dbb58dbe280d1b8f717b6f 3dcb705804b873b9bf37bb822ca2feb4	9	78	15
202	Лучший фильм	65577411ae91f9404962c3a7cfa209d6 f537fe2aa8cb1fdd73b94b40712b551f fb2ac5dd8021c60ef0e533d27645546f d360816c50858bf47cec2b565cf3ff1c 2943ed3b1382fe432939a5aeedc6a508 751ecab31ece196cce3ba8ef1e61f5b8	10	79	19
203	Отравратительный фильм	8c4d89d2f6d7ddfe585ec9b100887f87 0f2aaee9219b00d7d65491108aa857d1 e06ff0f07eba7ff4911da42631775ffe 80cbdb55859dce58687ce00f311c3b9a 0e4de7eab9e688f46616983d1efb6c41 89580a8f5c4452d62f0f9672ba08a3b5	1	80	19
204	Плохой фильм	c9213372b4421ef4523ff80985bddf1a a3a1523b0d2b3c7bef0dae4b6dfd2981 532d92436a567517d1c321701bbff84f 32451b983e48dc684f95684964093053 6cedebddddbf1423637c7c534c87cea6 6edcf4df6920ba86ba3ba4d071bbf517	2	81	20
205	Фильм не понравился	87108ec995fbbc37954dae3a655d5bdb 11b220e3c8fba1b76abb67afdad1c5e3 a976a0939e45c76401f744e7be4e6048 9fb3b7582552f6f442da870f9ed42da6 d99f24b53ece95ee0396b8fda4d16061 2d2ee0de8b2c63e1017885b596a77e0d	3	82	20
206	Непонятный фильм	e7555ce2247fe619d563640411864ba8 212cf6e49cc067a7fbdc2a31da75bbd1 827ec0803eef17f2446a2ba744b1598f 05c6b497c671ecd7efffbac63177c99e ed2981822e47ab5cd0fccc08a5c4579a 4f90fa301eb45aad00b7f723a2bdd4f9	4	83	13
207	Средний фильм	568b5b4dc020616348701534f99d79b6 209042481f3a3e5b6b4b7c5e5d6f22c7 b568b74b5922c56e4e906598971a4ef2 bd617f16a09920377ead5b2be7dbe2bd 93d129a060118e509e0b34b1edb17b02 e6706fa8b3fe5c1f9c9c1e6d7e7c6cb3	5	84	19
208	Нормальный фильм	fbf50b8fd733cf9ae0ac782baf3ce3dd a88cd3ca7b32607594cc54adb5f5db16 c1b3051b41a6c92e881a957fcd97a78f e7fb40a589b3c9f2c3be7041ff52364f c1b3c4b71eb284040ab31e949c19a37d 619af87e447ac90024df4a7c1b05dcf8	6	85	13
209	Фильм понравился	e42819c969816bbbc8087c378c769a44 e8890cb94a73c21aae5f00051b40c5e4 10dc5f044eda8e266b42576b12d90cb2 f94a88a8c9e1c74c8228594b212003b2 3586ce867b14e498ef312c781a8a16ee 4f0d45bd0a2bd307974c5070cb973470	7	86	13
210	Хороший фильм	45e8aadd4d715624ce58f79e14faaa2f 54cdd6d8d1cc36caf85eb5984559d7fd 75f07dd8fddcb69bc0401a4c8d55935d 0c5c2e9c4960b977165306cde0f581eb af75ddc72f5f88f25f5d98c8ff2ebdf3 5a548a2ad07c10d3f8573ac3882db747	8	87	20
211	Отличный фильм	bd8ab0f6fdbdecd8a6eb8aa4f4e21144 365ce1c303778c77c1e4070c6259c54c aaeb16fa4e7a4ae87491f70649b97247 23209675e0b1378137a451ab4537333f 23ddd5350b654d84e6b980b96d1d8812 9c7c514e823285bb6e231ad30a10734d	9	88	19
212	Лучший фильм	87c4080eb852b48d7ac0c8f0acf45527 c8283f440613aff26241e465446e571d 6a22a3e3c17fc20635999eddda0f933b d18327e25e75e92035d8eaeeb93a5efa 8a5bb1a50eb5874b93f81034ab38a376 5f8e3c0bbc651c6b57d9df2242a142e7	10	89	17
213	Отравратительный фильм	6a2efe31fdb4068072e6f44b870e2836 01001df070a16fb0cdb882e640d63187 919b999083851ef083fbf11e5a35b36e 5b100f203b0d53e5e19b7612c92997f0 fb8677a2ca4a2815b3c6976cc06450af bd7265b552aea8e66ab3eddd19b1aa75	1	90	15
214	Плохой фильм	0bf1aa4a7d497b54de6cc77852bf6283 4b76e1d19e0b49bb7921367e346dbee4 f0fb35e7096a0cc5184cff986f31e3e1 ab97c274eae4c3e804dcc3a86914baf9 bbf7a909a21c6080ecbe3d1eeb5d90f7 e1f8f4232b7994dba25df753cc463588	2	91	15
215	Фильм не понравился	0ff3cfb0e72edd3d0a7db27c429c11eb 29d07cc7839b9d7f090dd63a6e407c2f e1d213d1b4c300536840d4ac396b0462 58754d700ad5f11e5fdc55499b560335 a2d9a191fef946a1cbc79ad06d9b0219 8feae28868d4a6422a808feeba837f62	3	92	14
216	Непонятный фильм	204e8266701aa6f5868a8bc8050fd37b 1a1ccf86dbe3079a2cc02c75a010f9ba 390ec091cef79ebd857c52f31ff196da 4991260a13aac36e2424731cd880e949 71853488f09bc0b9feb2f4b2d77a3c07 9ce87e87b1aa96f5f5333e6db9fb64a1	4	93	17
217	Средний фильм	07bf471796d2b933144103ae268f3e2e a7e9bdffa02ad1f2a6583595187f102d a2a84108d60a606439d5c85a5b2de3ca 4bee5d4fed65cd2a59b2e04bb93b2e80 b7e64a6dbaafbd6cc33d500b9973ba0e 8536b825557b713fac0ae73bb871fab7	5	94	20
218	Нормальный фильм	e9cb106c82d5e0aacd0fa6ebd0b0ca81 d11d7328efaa6d0843308ee085a9cd2b 2358ef8f2adc947966378664cae5473d 0ef621b2ddd86b09ee06ac096f0783a4 64fc75d9d603e27738a655d12d7e2dec 25579c1d6e76e33eaf4cefbe3343dafd	6	95	12
219	Фильм понравился	57e7033469d5f7fd85ec3f48dcc8eb80 ae56ee2e6f999c37d80e41ef215cdc29 7f8e69a4cd3d6b5060c3dd2724536f34 3508ac290b5bd3929e757bcc675da144 e5721924e54b93dca3f5996b0f36538b 67803eb52c0e2655f6baa913c18f38e3	7	96	16
220	Хороший фильм	7345fc397c4b00f3081e6bee413c6644 c1ff28968a06ea05230a76e1a3694762 ea56be8e2ccec41f26ffa56115aafc9f b4883cfe9b38905cae3ad6298fdac3ed 1e980dce40ca74b6c197e5d5213afe38 aa05771f2d494d52aec2960c3e90e912	8	97	15
221	Отличный фильм	fae9923afb9df5dcf5842b5a2ed67b7e 7be59bad155aafddc16d7b83334fc77f 464491b03feca37da3f3bc554581775c 4a92a675ab047017532088c921171a11 a9e6f16b10933530caa6b3c8d0a3a8db 152650adc672c1057fdb13a84fae0712	9	98	15
222	Лучший фильм	fabfb9ee1294224774dd23066755a04c 63ef6e191194690d469b60e37b869698 be96ef56975945d1fcf2bd6ae86eda71 ce1b357ae3d2c2dfc39047e4f351fb1f 108470b4b31e49450bc99abd859ed836 7d6be4ac56dd86ad86c5523d5b00a06e	10	99	12
223	Отравратительный фильм	b10541196c846e987330024b0c689f22 bf03c363fc63cc43371ff605e14a40bf 5adf895e1dbd86dad314ba6d1ea8daf4 74d612d3d97bac91878a11915beae756 64ca10fe554790e62042422d6ebec26e b67e4fe14a84f8faadee1e898a43919f	1	100	18
224	Плохой фильм	551b546184a9f6e75929d494e1cc4560 c862c49264fa696d3a682f6686ebe1ae 139d4d53ffc33261222a72fa982bc4b4 09cf3afafac284a31dbf6d5d4acc5cce 1b109c23f4f754e3e177e293cc05faf1 d57d04a05b36fc03e8cc1eb3ff9db539	2	101	13
225	Фильм не понравился	aab96f374944e63278e16d3024d3a01b 56743be0c70ab4d901664de23b27e91a 2bc442ee2de976d3da5aca784157c745 22fb0885d31cee578df942c5f7380c6c 25c826144cc538c3a0b44e92a5f546cc e003a5714175dc5a3c1b9a154c71d2f9	3	102	20
226	Непонятный фильм	356d09d47f6e1434b7a5244eda5a1c9e a88f4ea6b70b69d2c6b4b2115cabcdf8 93a76d2e5acc0b91c046182078ddd805 6fd28e80ade2d552df4a7b45d9a98a53 e53513c2ca9af9d0d2a1f2a119cc2633 d7c6dca3b61d3656348cb28fb9b60e5f	4	103	20
227	Средний фильм	fe4e4a5d4949d9d0a9154108858981e3 91a4b1db3b656d3095722bc61b196d9d b935888ff20c90a464487857b8a37da2 37004692f5e611cad7aad92be0170b08 a65d3bf95775f447ec4d75b7355b26be b489f7d1474529e1e5479826cf824855	5	104	15
228	Нормальный фильм	81a73a8e6a9fd7ca25210056d83b54cb ba1483f3f7eb6c302631a12a15fb891c c234be60908716bf251d874930965252 c9afd7ffc4e4adcde8f7eb93acf70675 e31dc42567dee804de3b1ffd99e95324 60b865d802c6290dd566cdd4b197389d	6	105	12
229	Фильм понравился	61bf50da2c3bc0f912280a9a0c4eb7d1 11a0d3f29f26128058a4d82438bb8328 93d8e7781f89426fd2575fc11be43ac0 53885bbcd074bb328919f07825099578 cfab9a8e27ae33ee3d6215de0bc25e42 317a801423d684913e9decf8f7da577c	7	106	13
230	Хороший фильм	55aced4e232cd7bd31383fe3ea839618 fdf11ab3ac1c71c77f6f5095cf41e4e8 2168c30786166354aecfb167d7d2bcb1 bca4138b02506e7a75d90ef09465be4a f23a91f22c28509d5ff173098c2264c1 e38f184df5b9ef996f9bb567e12799c7	8	107	19
231	Отличный фильм	ccbb1ca1de5f1d01cb65d29a3e21b853 e8188a66f2f496901d07849eeea1ffe0 756d333ac0a77c6040a41b5b07a8bcdf de0681554a0535c2640bfe58bfc87d82 34aeeabfb4a0c1e233c13650766882f5 7099be26dffe2d41c123463dd73eef1e	9	108	15
232	Лучший фильм	6c1665b02ae4d6c923ce9a851fc70466 6395d6e4037bcae95e64b935351322c5 059418ddeb92d9c84771f936006cb788 8bbe797170b0bccad140f0376b0f1008 5d13262c2ba6de579af0601dc4d7d9a5 ab4f9cb787bce2dcdf2787eb2f75535e	10	109	20
233	Отравратительный фильм	a7f0aee4b68eacce1c40771179f1c02e 1405291970ceae30b3fa7872ef7bee5f a7c332528d268679006686837cff2907 7a7c7520da5fb8267313e694c924d18e 521cb52cecb0dfaadd37fb269a0a38c8 50ddbf91e421cb9bf7a25335bfd0bf79	1	110	19
234	Плохой фильм	4fc5d58fe17c31844fa723e30f97c8cf 7971224ccc6499922367463d650859c6 bd1eb3e7859a9a3e04e4a31d368328a7 b08af7a677565f3d84e75e9cb79d901f 7f6a8db97c2a4aa999697c9772074eed b5cb4c4853540a75a98beae71844359a	2	111	17
235	Фильм не понравился	a578a8226323553dd02018f5b7385f22 8d252fbd979aceb2c250b9e0e2ddf8c3 3a06b9179a462a0f1fe39ca4b7eb9c0c 1e60601c65eb2def15db30af3dbb3981 db8db39ae1c7cd14d5a90412283ee96a c1f41c63a2fa75b640b830aed455e3e7	3	112	12
236	Непонятный фильм	a3e89a22d1595563b12a8135754b2b59 a68219075d2830308a3c791de0685646 cb7c42a428c53999932b5f0c901058c1 37374bc164e7cc39402c8259dce8c94d 8d87894b45cda9085ef5ea8238200863 1b1150a03f94d662d6f9e9ef4c932177	4	113	16
237	Средний фильм	bd488b8b73b781bae7cfb4b2a18c1f10 c0c8e4803456372d136bdc01e7fe82e9 999b57542c80fd61aba5a12d456a6488 2e22d91af20d8bd83a77db1567d3785e 07663f888514f215848f7582437bc562 8951cb13766b50f739744e3962c67383	5	114	16
238	Нормальный фильм	4a0201ceee08588e6cdb52a80ce4e2fe d83e7d8b35ee1f9fd5f2e84818714ec1 630a9ef12cb5104225d4dd4a5d2937d5 8eb0cb45c76478a57d4b1444c6ea3eb0 6a50ac0b22995d1d606ceae5c1d90a87 d04afb2d37a85c60610a758dae386a8d	6	115	17
239	Фильм понравился	2d5740e1ca3662e0a12a138e857ffce8 da13ed6c5f7e1bf197afd0cffd115cd1 f33adc9849e5b06db1d12296e60c5cc5 32cc3170bbbbba266be10f9eec161e31 bac68c27c84bce4d8a9038f1b9339746 ef59cfdd5649a877c67799f277d47ed0	7	116	16
240	Хороший фильм	a30ccae648e317e41a8226e2c8ab2b57 633db971a934500f99ed572447f7a66f 07858b40fa839fe2a56cd1b14b9e0712 44c1dca4b82b1fe91bcc582f11d9e813 ad61b6d8ac0894c0d875b1c25b42649d 7877ccdfc6b68d9ce6c246ac9b9be115	8	117	19
241	Отличный фильм	fe0e1044de9ec2b83fca97ed5247e38d 412775f9323b10775ee1c074b924b9dd 1b2ec27aa69cc89ecf41a1b9ee328357 60faf39912ea37d5340260668b95aee8 aa789b27c0fb77f89a3404e7c2ea8977 1253e2c662ce7d3dce2adf96e58ae014	9	118	15
242	Лучший фильм	0ea14f5aea6541518f5f0cc06da6b597 8efafa19ac20830a15cd75783beacbc5 a66f2df8bde5c48e9c4c4c411324ae23 155e64329206112cb65180cf11d70917 a819823e0c391385cef82d55abbb50ef 72afb773b518ad624f9b74195051bc18	10	119	13
243	Отравратительный фильм	ffb273bdd71b7a34ecb2d820133dc17d 6a8a3eba253c593ebe611f712f4eed68 317cfad15d9403631880b2b2c55cd49f aae19371c15070073d7feeef7e729f91 9d81fc0f82dea2d88f45eddf84cf54ec 17997f24772df59e55f84480662a2064	1	120	14
244	Плохой фильм	04cdad777f86cc5065b7ccf2f01c5ce0 23db2ab368afb05825981df1c592a8c3 d65ca7879a5766cdc4c30e5b64f94882 6b50d036e7d4fded2b75dce1d95db991 0aec3f25de90c04e6b07ebb8c1c8643e 597faee00fa6b779b2526b8df662c39c	2	121	16
245	Фильм не понравился	34515bba18924a9f655e1cd422406502 7b76530e92551ab15c5405e0d9294900 5cf8a8608d409a94fc4bc46fe8d2d667 b69541e03cdae658a77248e3b6dd028f db29c45f8a3be3e5c26181b9933d30a6 a6615fc5c743b414474ddfff9dfa4d69	3	122	12
246	Непонятный фильм	e85375b5ea1c392fd585dff77dbe7e28 3510b4cdced1cc336d5f352e6efc8188 419d5396ef3bfe07700d3ad015a3e133 a4c8a69da3d9fbaa0875c24f3f603b1a ec6fd7547fd6ebb0e482eb4a474c3832 4387f0afd58c307af8870ee12ea64992	4	123	19
247	Средний фильм	6a60242f351fb46c3fa5a73a77da4113 7af13e9541307ae62223908203828db5 a042ed82c2df90a935e42de7a76409d4 d1bef096a63c8cd6e9ebbc6e369dc073 0287b3636abbf288d56f35dae566b1a2 d8d75f6bcd460feec07c4462b153d9d7	5	124	15
248	Нормальный фильм	1914b1670ad04a84ae9d9689d13bb770 593f50fcc92340fd9b01687c4986e23e c3dd3879826ca26e076a628d91d7149b b9c3380062778e562352d6244d3bcb15 d20a84e367a0f693d5f82dc19f0030c4 9c5f2da269304035912828dae5c75c6a	6	125	19
249	Фильм понравился	28ff1239e55059848c16a8164057a00b d44f6f2459803bf4a992ef82b645daf2 86c03c082c30cb4374199a8e12d46fe8 574b0a7ae6d126a6cd926a20236841d7 67beb433bb9b7e67cdaeec9b80ac2b75 89490eb5ededc96c439dd412b2ba66aa	7	126	14
250	Хороший фильм	fe980979267e10a60a8869ef8b035cfa c75f7f7303545320021de8912692bf41 d2c80358fcb4432a3ce9a708b440f80a 2a4fe0babdc3e72b58a1cce89dcc6876 ee8b4a2e94250fbcd74fe518271fa865 f5115bf3e3e4406a45755295fce757d5	8	127	20
251	Отличный фильм	a54ea7322fe29440957b2d609d2f1bd0 6bff8658dc4515ff2a5f7786ce6cf0cf 960912e954e2c905d9f0d772b640bf60 d52b76dacd8834caf92398a81721bad3 0a5e1bd6e265f05095b587321f8607b4 93ad36251490e57eb7dc2b0ab02001cf	9	128	20
252	Лучший фильм	88b4d516f0aa5ab63a5ade792297d1a6 7e22d41076f5c738f4e97c84733452f1 f803fff0bd65b8d44170aee5bd862fd8 a8bf39a771d1b064e913eb07b90f622f a7ad2cfc67f1e71ee0a16a4ae91148a8 dea850f1c7ea687ee37e1cc36b9931de	10	129	13
253	Отравратительный фильм	9c644c9b0eaca33f9bc4ccbd12c32259 314c8e6a7cabf025841d07b090b59171 451f86f3ca63b224c37898d65c31466b 7d9c985c52f1b58333811520fbfd07d5 ce3849d710569e8745762db85d98eb3b cbcaac63e663ce60e16b943041edad4d	1	130	15
254	Плохой фильм	f98d1db3125cbf0c82a7cd317c3c6158 3a4c2b243c6c1a7c5eb926413bbba982 7d10e5063b60590a91eb994419a3d878 b81d534cae85b19ad8e808b690e986c1 899a84b72bc2e65c7a8b2dff4f2b2e76 af9eb521033681524ec0f51d83df7cd9	2	131	15
255	Фильм не понравился	822b010766b6be8f3a07927462843d8f ba1e1ca30647a6e206e6225e4525bd5b a4e5efb97e183e5628435581f482378f 8233b4724e07f6402cf31ac142de6774 15961e96fab35c793bc9ef5cee0c2935 65c472c8ebf2974fc0fd4be595b9178e	3	132	18
256	Непонятный фильм	93ee1f302be56b3af02ad572fba8b2fc d34ea51384b20902fe017c32edacab59 db941c29fd7ea39188b32aa55fecda49 6d25b0f9a9f263aa0a9ed3eb205bfbf7 84c4b98f062855b88d977ee7e2421f37 d6b5a9a27b1882f2b0c1433597fe3946	4	133	18
257	Средний фильм	0b5744cb8afb7207724fa368aebcf8c1 cde7cc356ef6ef0a490f6ce7eb3a1ec4 95286a184e83e5b2552065db5bf7ce4b fdf44a8a34d4519aa0a1323f8d528f7c cc12f5dac9567674605dab0cdcacaa00 8ba4f2aad031fd9f5ea68f52e8d260dd	5	134	18
258	Нормальный фильм	0ccb2767c6d225feda25576ba983bc78 3b9d38bde8d68ea8953ef68e3d27552f b231edf3ce10b55d85be8aa00a1ce3d3 34dfd36e5973f2adb5f03f41fae35d90 afacfcc9a0217c217b14f59b1ab1cfb9 ae16888e336870f10a120ba280dd5294	6	135	12
259	Фильм понравился	e080509beef5d9be62ae1134bae2bafc d002fdd14ba50b1bff5f8de098ae2efb cfd10fe72c69ba8f93b71aa062294149 77946849a79f016cdc448586f43afbea 9c6d1ccf9d43ce4cd45590a7915b3d03 3ca71bbcc269d02ced713bbd56762f97	7	136	16
260	Хороший фильм	caf2beb1b2f948e80047a0e9f5dcf1c2 776a1bced21b5bf6c8315019d76c3df0 b5923d257b9fde02283d328260cffbfb 65eec77a476ebc109942bdf2a497aebe 20511c573fae24b9f8208357d52a6a7f 3548e9cc8a6e5f3156390aa49420cef6	8	137	14
261	Отличный фильм	5617d24645b89f7c75fccc6e8e66e24a 09f145f1409c6ea08645df4bdcf59aee 3ba59a601e51435d3678a30939e8a633 b096688582c18de637d776795000f2bf 43b12821c664f73df9c317a808412c15 7ef39966b45bed547390ff5a90b63d28	9	138	14
262	Лучший фильм	76028c60395a7127146b17c41b698168 a54c22bb4e59363845464983147ee8ed fd08f8795ea16d988eb7adfe17b454b0 6a1755318f05425b34602064171b18db 6a39f910dbe3d4988b0a54a81527c964 0d3cc68447f16895e036cbf1c7888b46	10	139	20
263	Отравратительный фильм	eee817e976f7eb1496e28408de5e1870 2f2d064c43bbd73a11b6cb2454c17231 455ad583f2c4a2affeea8a648ab9b3ca 331623aab79b9e7a4860ece41c03fa39 5fd2cf0b2f910cecfbf6cd504f5592fc e87f43239c2b162c5c6ec353738701dd	1	140	16
264	Плохой фильм	f2a8f8d5d5d5297d3f3757fcf364dd6c 353c66976167dcd339610e4997de1fb9 8df0d5af565d7be62a3429c6a2e86f2c 5f18b26a202534762a635e16bb7b73a7 bd77ca01a0085cc3fb67f1d2dc068079 91b44d52d41a6beb6d76967e2758b94a	2	141	14
265	Фильм не понравился	fa4e8b6fa53a5dfd86ab88ff93de21dc 030f9df5e6ff85a12f31d0083fb8976d 2047d7cc8fd2afa1e74d77039e5f58d6 212ebe045f3ffe4e5be6277f4d72fd98 2762ca5aa60956d3585d8527d04839cd c9d4ef06709dcc74142a21c1cb2acaa6	3	142	13
266	Непонятный фильм	907bddbf6ca7645ee6fc624d19b61c5c cf6b9f689020d94ebec8bfe6669e106f 0c887c06a76c8d0843fe7c7080cd16c3 7f00bd7860b94eeb61e937fd79c032be e616b0687277f7afe3ca80f7d2ae6f57 17f183b8ab113e58a67b3b5c679e4fa8	4	143	20
267	Средний фильм	a1580901d781395438a98ae01eee8dcc 1395b632826cd425f653ce2d427bbe5b b98f3b5fa6f2fc57b76ae9831f3f621b 250467f9559032edbe8983e67f17106c 2c1bb613c371c3552285408b4a2bf29a 6519b543ead34338d99753f5ce10560a	5	144	12
268	Нормальный фильм	472c4f6cc2349fbb30e7373804d6c3fb ff9b6c3bd718e8dd9be468075f61b49a 0066a4d5124a0cc2131c9a8bd47bec43 9641b13e636879c5c51efb426b2fee07 864e36cd5e88491679da23e1f7427f20 ae17c413b47ef9597ae2bdf49dc90d95	6	145	18
269	Фильм понравился	8071337a502c07688b754dda23bbb090 931fc08c38e8626b56c901fb13a9b54c 374b4e624a9439a6f7c10205b96c371a 3d5e583a2a0186591957be77e84e25e5 ec2e17f50fcb7c933fef4137b769a37c 7fc67ab8bb5234abc731157e4e955b77	7	146	20
270	Хороший фильм	cb199cca86d28d2f68fc7b87030a03c3 9ba275cb6bbb5c1243e1f9c68f344864 77ed57999a5b7cf5f558ba604c3aa7f3 3a5e76b3378559cb420f84f14efbf5d7 b3ec893a2a4c6c99d78159cf6ef85066 f2cf57d0c37b6dc406b82730a9f9e26d	8	147	18
271	Отличный фильм	4de743c79cb21e03e318ea856fe4bfe9 4d5bb91eebd18eab63e23f3630e9f44d 248b3d89b3ca2721dc16fac91660713d 5d062a338b84e89396ebe1d71e9e18c5 2690b02906967d8afbb0018dad5dcafb ce6e2b3c2c9d4609d4790fc2ef2741a1	9	148	15
272	Лучший фильм	6b35ebd56ce86e3d6f7f0c37dff04bf1 00c2e06f5b3ac129465e26748631c88e a84e72951bb9b95ca0c7b9245344ca8f c617732fdcdea8a854e1f6cdf7f4bd9a 7d4ce6268fbcb66dc03012ada8dc701b cafa4689b0b3119bb4b7b87e81237ff3	10	149	16
273	Отравратительный фильм	965f1b2095733a63b38c6b8b314886fc 36222c73baa78936a06d5867806ee256 93229272ee17d6b408de442cc0877af2 705725be092a362661de401300be7768 d9def0689d48890f72348443adad25db 1cd23982514a1435f33416ddb1603966	1	150	16
274	Плохой фильм	597f3f701b04de90c2344f5d8670d7bf 48a8792ee9e5f787d3e8b25d77869187 61ac7de05326652bd6d05b77f179dbfd 94187f312833b2291f4c734b3b9df4c1 20c2fae43a35768d59ebf5ece54ab01f 1b5bee28d345190c38f05261bb360ce4	2	151	14
275	Фильм не понравился	cc81ccd456f6f63f1b09eeb9b45348f2 930ee06670a223cb1e99d251f15c2acc a26eaae759516954a62a36751781e75a 21934511001fef82dfd3eaffb56bf1c7 3c89b22413a5e822a3fc4ec4344e772e 38bf7070237d2c4f06fd2f7d60893486	3	152	17
276	Непонятный фильм	5209b9061b8885cb7d794b1d7ebc164a 57b5485861de0f57588d793a4dd4e10e 72974b690114f8de882287843dfa9cc1 063db1dffdf45f7f5256f23f6a205221 62ce812e31f531b0fcf5b57b2350186a 39a4d4cfc71c6b4edc5030632fc87097	4	153	18
277	Средний фильм	2f77b9b4fd4c2d77b835ff793f8613a1 4ffaf73f2ee4e01f8aae9843356216d0 a7865562cbe4a8c53950d3b28361940f 8483081fb42a8a126713cb581906540a 807f1e688fffd500b0b8f5a665164c43 e0bc7b26c70e707ec3f20ce625fd6dde	5	154	18
278	Нормальный фильм	58f280271b5eea606dc96765c5689a21 d01d22cdc6f12e33feb2fe606795e7e0 48fc72ba233232cf69b2e59ad2428f1c f093d0f0926c988fc65a7c6e7a768b01 2406670d32bdda8ef043497d9e3af1b8 7dcf6e667f783982a92a5878a5faf656	6	155	12
279	Фильм понравился	cdc39984bd435b5574a1154c67adcda4 a47db0194d21b4aa8f8e3ffb5864ea56 09d75637392e1579bce1dfb2ffd81f3b 7467a7c3e077b053931f1f317b9606cb d904c1f7d33dd0a4c753900b2a84ddc1 926a8ffa752cece600cb7bb7c4f17953	7	156	16
280	Хороший фильм	82e71aac0006244038865e672eec0bef a8a6c4c28ff744792342c787926307b0 3393e1c214f4808bb9484870594c8096 46b725e9bf3f2b1e3b1939635f03e9f7 68c627cf00399dfdf362ad7b7fd92f60 4c9f8a5aed9a079a5d06e08935500708	8	157	12
281	Отличный фильм	f91fc12b842be83b90a5b074c783f684 b6a59066ac4f1297afb1b4da854c7316 b1cfa3a05c4aca3eb33fe2805d763797 843f349e491e61c73f729b73edb531ed 2db31df5a9aec144d06d5dcc9bcf63e9 1ee561e772511eda0b63a981647d869b	9	158	18
282	Лучший фильм	b6f577c3453dae83509cf63ecc2ab042 d47dd410725a4a57a7d13ed41e9d965d f243ab3102726f15576a62a6c8999b03 a5225ca04a65ca0de7706180751edce5 f965af6894273a783ffe59fab76ab312 b9c88e82f2ea7381cb43250ea7fc2180	10	159	17
283	Отравратительный фильм	84e519ebc7e17af2346375d057d85ba2 6c7aea73e2bc1096cc3265523b19dc99 e1ee89a244fc9a3243c5bb1cff390a03 25d97f1b41805c8828705a0446dbcc56 251a70eef12233d0846931987c5e9815 12972df0441f976a0571ece9d7fa57ac	1	160	13
284	Плохой фильм	0a0bfacae1e197ab268df9ad9508678f c6e7ed909634cfd4703d5b712083ebff 60c85b3a2aff337c46e12c6e98b357d4 05d1844017e9f18e0b072573c4e9686d e6331e46fe9305509b222c71cad762f3 559bf44144d0197d75910c195e2a6631	2	161	12
285	Фильм не понравился	06ece9b32ff2ee937c7d51c0f04261ab f5cbe791b322ff13847c90a370bafe60 f03e4a33cf1f8a0d0f828f7310d7944f f3c588bc1397b422e60eb251814b276d cf29cd5d24e827039efdc54df10a436a 5237ebb22e90f19504994aa14df4dad8	3	162	16
286	Непонятный фильм	6f757e9acb2eca1fa3add1435d09d2d2 e06ae9898c6c802965c23a3f924a845f abc05853d7d82c307cefca658649e6a3 57ffbc6af6ad04c85ebcfe0fdec5f66b ec4531691b18655df1783c75a41394c4 e828f0c7e5f505e294061c5f78f9a400	4	163	20
287	Средний фильм	5c9047d7235552728be086b84e94cf60 606000e41ae60620f98e235834ebd81c ce8255b4f9c0450caeb31f3b8503fa35 bb0119c1a0ccf93eceaa3a95d9b25139 885aa07ed7c035b51971c5e7b6d9b4bd 09a813576be62e85dcb96bb0343f4b0d	5	164	18
288	Нормальный фильм	44bbc315a7ebd33c2fb0e03d84ac685f 2e892461b8fe3819005a7cfc060d8996 63900d5c0f6f59e8ec50d0d1760a8b4c 606d2a438bb85290a21cc9e79c3aed62 c316d43746bf9383c63c88c9a0465d7e 71e67e77249c07b40430439edf59f819	6	165	13
289	Фильм понравился	4daa3b813f194bd54dc41548fcd03cfc 818e5b1f5c4c996b40f0aa796a80f75c 077508a4abfe413d973f51684c273f07 83c1404e5656f186270ff7cae926aaa3 55cf5f7220a83720e17d34eee6239cf6 00abd5d164b86ba0cda3eca920ea397a	7	166	20
290	Хороший фильм	cbd63593cb25ebc64a19b0ff505f78c5 a12246cb35b3a40ccbc9b9de859df30b 051268acfadd277585a935e3c1334351 e3a5acecf88f4a21a45c3476066c4f23 ddff668676456f65eaf79d360b99d4f0 7e35f7f420b83282e899cb0f05ec792d	8	167	14
291	Отличный фильм	cbd3c608b6c1884dd5439ff70547c36f c58aad63081c7f19df861a31c715d5f7 0693b5a13ca1d2c4f4b62d1a63a56180 cda536380b8fb481f39f57b086e4020c a7d684d8ce720e7ad1c925fb9a40b1c6 651880e0896b197f0e2cd392a546638d	9	168	13
292	Лучший фильм	51a0b6bb65140c664632e7dc5aac229c ece591ad053ed4892ab8475287289f50 8fad82a9c96e93d562af0f329ec3b1bc d151ea37a8255fd250dfa6777a14d54b 81d79746ff561604fdd9544acc5e6b9b efc14ebb992e472949c23953c00a696b	10	169	20
293	Отравратительный фильм	b12ef9327b39ba5c9417c557cf678072 63784fab70d4535a876eb7a73c39c9af 049f116bd0702008fbd57acfa4418463 6460a2cae4d1212b2a07eddbe19ed910 a68818c5667cc7a09a2a51528b72ed15 c1e10e31b9d01761dcae8ca054772cc0	1	170	20
294	Плохой фильм	f396cd7de2ad052f4ffa5a4826712e80 33e1caaed0f8f6165ad5d162f4da6c94 d90ae4b0c9f96d4f7bcd6bd0a843f773 c47f67bc83a1eae81c17d95061d75db0 8bf42a0560a0266bebe0f95076ec0ffc 79ca3a0f6ff3b6bcd77b3a682b6d27d7	2	171	17
295	Фильм не понравился	6a19279d0503059a05ead2cd143254e9 274c62cb550838b8963e026135ab015c 6f1f1994833afffa1fa01638fae84b4d d73d55489a48c55898a257a31fa0d273 c896ff308ecbae305bc1c2181aa88cd5 6639ef1c58df03d9a4c0c52dc808dce3	3	172	12
296	Непонятный фильм	a02a7f1ea8b22971eacc2463436445ab 63dff180e091c4110481b5c0d0593752 71bca399f27398be43c369c6cf3268bf dd3e2f5fe6223cbb3f24f9be52239252 db9e106224e2dd4cc519e53f290657c5 7683df6c1b09b2e99f6e73bc0f9fa495	4	173	18
297	Средний фильм	707344fe7f7b808be14df00fa7df751a a35703b0898b765afac7e9a9c3db709a f17670d38273130234ebdb711c97085f 072c6d55f391834216ae3c6cd554b409 5c21b533af644e87d2e8e8f052212f38 59ee8170db66970d972e5d3dfb0a9ce1	5	174	17
298	Нормальный фильм	4b90491094a5bc812640885c30c12a5b 621c105fc29455e73d36bae266f4a15f 1a4efec3a59813b2fe4b3d6bffb032b3 c326503ebf5dab4f1dd04d816f4b44b3 0263a9cf036c290d9e2e191c250ee36e 1dae1b076b1657ec0ea5c8973b39ee01	6	175	16
299	Фильм понравился	e49ac7c760172ea07bd4b8823c718f31 1c7f14f98517acd661b1ce56a7d19fb8 e3073532b35b0bcac974b45a3361e78d fca6b0f84925be087b751fa58f228964 d643c02b03bd48567a0a263d75f98668 debc9f022f9a15bdb4d53e1b5903a688	7	176	15
300	Хороший фильм	2d755a7f294ac413ba0daea0fb379521 f9d66150fcd416154c1a7e35ed173ab5 dd670cc767ddad9e1285ed1ab0c86c69 eb297db7c764557ad7498426e1c8e17c eee1c91b4525d11fe0d2388e2b1db1d7 48354ce46d6e563b0bc1bc731be18942	8	177	17
301	Отличный фильм	2e3e89f267c5bd980b5a81f86a001cfe ddf6af60ec2f102978a3b07bfee9c7f9 7ab71b707c3d73023606df4e11dae18c 28157b121a52e7f4e4b97d6d696a1ca5 84fce973c856c8b0d345574fffb8aab7 94650ea1c72df65370e67a6fe58d3e73	9	178	19
302	Лучший фильм	38ab56b277e449cac63770f12bf8e249 2419b768f09a1a9b3d12127ee181c874 ef26eba1ad9353fd3d43495d5397b666 3b49c1f16186db08a246eca55e233dcf c5366e8b4ebff01e6a62183c82dddc6f 2e873f2b5bc98b3f5b8ce517b68eeec3	10	179	20
303	Отравратительный фильм	9f4d4cae057c3423a6b23d7f26664bc1 876e8e0841e07ade9cc2a11b81af354d d20b5cd0d32f8c40bc9d4e6dea7114ac f7525ae8a42408f28cac0ab98090f37d 094a7dea53f83b154df3c1a9654da03e 98593f5a8bf8017ced5c80d5421d8525	1	180	20
304	Плохой фильм	f5323f88e3215609ac82902b31b010ce 1e363f0d6c429c57d75c49aa31cc2d39 a6292290eafe5c3bdb3d824e394ada80 56261094741bcb5438402ecbd4528681 f7e5b0ea133d15bc69bf1ebf9d499df2 3e7f1ad9733e91527c52f58764b19d04	2	181	19
305	Фильм не понравился	7b4fc54204e3dfde1af1b2fa865429f4 1bef9491ce54f47b590d1e02a2ee5482 192f8bd422ac50c47473d74133ffc4d0 25ddfe3e851c66824d5529e3f080b3e1 3ef81572b8da1aef2ad611cf5a5601be 835618fee3ecc5dc722f17968b2ccbc2	3	182	18
306	Непонятный фильм	eafe0760ca8750f6ce4f1c7a20c113a7 6a4c74bb03511abf44595435cbf9b7ea 3c60fb6f424a95edff426f41f9bffe26 30baa522769e24271c92077d8eca5e80 3309979bd1ff0269ece587752fa9faa5 8c52d0e343f9bcda13b63c70a722e302	4	183	20
307	Средний фильм	921cbb740f9fd10d2c403457053e0466 5ee49432c1b91bd704aa5514b3664476 3d530ef96d867f14f59e92a500242baa babe787fc9c6fed16d2455c2c3772b3c 2314445c3bebe15b9b05a61d20727805 059d4b7baf378d85665a74ef9631ea75	5	184	13
308	Нормальный фильм	dc0f0814c521c33c2a588f275c391314 b7ee3056f1eba7848871e9677dbe71fc 57fa7ba559fa376ae1c4d513f58ba457 569f5dff21db04855ecc88bc4c9b10d2 f1a851e6200b177628923f04900a44c3 b090f2bdfc6120e24bafe96b84b7b71c	6	185	15
309	Фильм понравился	6051fbf6293cb44b549a564d3639cfc9 54e1e578790a9d4b8dc7ce4aff4687c5 3e8be17404f814f9ec57ca71f4259b46 3ece0050398004384db1a8d607f47161 1a1f0a17a4b69904f594a0cedd16998a 36f8de294417af03641ebc0f5a8e6144	7	186	20
310	Хороший фильм	8afa5f541d7093c38a8675dab15cf2f7 f2bed061baaffa4ab43dd5623b6fddd3 39cecf79719fdf4a6630508831354f39 75352972cc691f0c636dfa7b169e1e6b 81613dbb6985c0287e84361f3f588ede b4fd0035968dc49ebc7d3c93fc9d5fc3	8	187	14
311	Отличный фильм	f95bc377222af5b45ed2f98a9d22f390 ac954637df9d1075eebc8d59e835ba81 2ff337fd2bdc37ab9b6e34d07621f1d9 f6424303544ef748f28f5746dfa26adb bc533a791d8959d61fd281e6cefae84a a25df038144b1c2f96dd1f45f213842a	9	188	20
312	Лучший фильм	757c4729970b3a13ab86909b341c9708 3c4768c249712664720ff5ce95313f03 e529867f5019f775894a73e47bacf076 3596b22e5767a7da28dfa132dd8b4c95 e687b85cf067cf07f2b483ffb2a3cbf0 a645fde152982a8449b2d6a891f4a2ba	10	189	15
313	Отравратительный фильм	1b948d4882b04a433124e48a0a63f456 d38f256e609912dc8f2982b9b7e91a49 43ebd9bd7b8a6909a23b3e0295d2b9cf 7158e6f798460a0f2dddd47e8d222a3e b926af7a570a6bcb3783ed397a1876b4 562cf13692f0a1248a9ee7a77e5fe7d2	1	190	12
314	Плохой фильм	9f7b7d050b628f938143853d423601e3 ebe0ffbfbcacabbb4aa2f97f3536e982 a59ccd84c85ca2fbeb5eb8c3de16b795 a2aa799af5d41c8f7f2503d9ff1e8138 69100b0eac15ad0e7a42596215d5a4ac 9d1a7e9cf3eacef63cc7ecc2a2e30c28	2	191	17
315	Фильм не понравился	6ed23c97400742246ca78113c561381e 39de8e328b6ee68215bd79b79fdf834b fcaad47b2bd5ea5062b8b7d929c44d02 f45d894f0def7ae32b347d9c3d7f3957 93ebd29edb5d8286edc98de121062a66 40a731a44e83a3a060a8c7b43efe8c50	3	192	15
316	Непонятный фильм	dcad45e28ee2fe512de24606467fbcc6 446c151b4501210002e9dfbfb7023fb4 df95dece2fb12a3f1ada8a64d3bef85a 3ef537ccaacc2c855da815f556e9db1f ce252823b5a90b595242af35329c2315 fc2525293eed762799f339407ce98605	4	193	16
317	Средний фильм	67643e98fbcff34ed10e9db962207c72 0465a8fe1a96914ec9d78eee177babf9 f991e84801ce26264031fbbecab66a17 b51e51fae85a04a0a2633b289e1ae3e8 28ef6dbb129a81d0406b7a4079b9dcb0 6d3d08bfb2096c82867cbff570c2c7d9	5	194	16
318	Нормальный фильм	6acb0c5c0f4b8fabde531afc7bac6ea1 b86b0bbad86c591de2bf50be0f94b6a5 b4d061ce793062a167339b46fd9b95d3 376eb95cdfb48daa2ec5c80f7d513343 74039d393b74551844367503a594098c 1f8526c54b4d3bca6171c1c4e834d04c	6	195	12
319	Фильм понравился	ac43ade4c71518cb9b40d6fcf72f1ae4 5949a8b5fdf22a96c315c6713f27faf7 19b8ea0d14c79b81c2503e476a8e7a0f 7a5ccefab7ca1589e5d582094cd320e1 5dda1122a48eb9c5c9e55b6f9768b37e f5e8a0310871ca6d977cdb813f296e7a	7	196	16
320	Хороший фильм	62a390000e74d03e840ce4e02fa46e1f 7e4e0e7d5cfcee785662c9cbbfc50ba3 0fa6c15f446a0089e3b18f3f8b66c561 9f0deaefef237820764f8005312e6fe0 5417d7417b3b63be61e071293842ec2d 46ad05e5c8ff3cf046bd0e4bcbed268d	8	197	20
321	Отличный фильм	a444c4352d2a3bba7bd3828c2dc6c1e1 68eeead3d9e341d2680ca41d853e5181 68b3fdea689bc4fd86ad786a19be3900 15fc6de581031f4a49a2d5e8a4946b5b 31b2515a04d8421793c9d9fa6d8ae60b 5f36395df1edfe3a9d7d435d49b1b71e	9	198	15
322	Лучший фильм	2376f930b00c4473e1e3d8a9f8be9ea0 1f6f2409ae05067c9d628f7053b243ea 9f7f27a438b022cf218f860af37ad7c7 73c2bfbca75b809cd3ea835bf861f6a6 c3790898459d44578bd5edad566b75f9 2f2fc1443478cb67a5e40c5814e25d92	10	199	12
323	Отравратительный фильм	145a9940a572d314759a847574d88c5d 6d3c0bcfb8252382bb03efc3f084e704 d5c4227cefc540e4068490820cfa6c08 37617f37a67d28c28d9e34f1a41283c4 2e54ea99765013f580070dc278ef6335 ad5e4869620005e528d44afe406e812b	1	200	16
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.sessions (id, date, cost, filmid, hallid) FROM stdin;
30	2021-12-28 10:00:00+03	350	1	1
31	2021-12-28 13:00:00+03	400	1	1
32	2021-12-28 16:00:00+03	400	1	1
33	2021-12-28 19:00:00+03	500	1	1
34	2021-12-28 22:00:00+03	400	1	1
35	2021-12-28 09:00:00+03	250	2	46
36	2021-12-28 12:00:00+03	300	3	46
37	2021-12-28 15:00:00+03	400	3	46
38	2021-12-28 18:00:00+03	400	3	46
39	2021-12-28 21:00:00+03	500	3	46
40	2021-12-28 07:00:00+03	300	4	99
41	2021-12-28 09:00:00+03	300	5	99
42	2021-12-28 12:00:00+03	500	6	99
43	2021-12-28 15:00:00+03	500	7	99
44	2021-12-28 19:30:00+03	700	9	99
45	2021-12-28 09:00:00+03	500	4	150
46	2021-12-28 11:00:00+03	500	4	150
47	2021-12-28 13:00:00+03	500	5	150
48	2021-12-28 16:00:00+03	500	1	150
49	2021-12-28 19:00:00+03	500	3	150
50	2021-12-28 22:30:00+03	500	5	150
51	2021-12-28 09:00:00+03	500	7	198
52	2021-12-28 11:00:00+03	500	7	198
53	2021-12-28 13:00:00+03	500	7	198
54	2021-12-28 17:00:00+03	500	7	198
55	2021-12-28 19:30:00+03	500	7	198
56	2021-12-28 21:30:00+03	500	7	198
57	2021-12-28 23:30:00+03	500	7	198
58	2021-12-29 10:00:00+03	350	1	2
59	2021-12-29 13:00:00+03	400	1	2
60	2021-12-29 16:00:00+03	400	1	2
61	2021-12-29 19:00:00+03	500	1	2
62	2021-12-29 22:00:00+03	400	1	2
63	2021-12-29 09:00:00+03	250	2	46
64	2021-12-29 12:00:00+03	300	3	46
65	2021-12-29 15:00:00+03	400	3	46
66	2021-12-29 18:00:00+03	400	3	46
67	2021-12-29 21:00:00+03	500	3	46
68	2021-12-29 07:00:00+03	300	4	99
69	2021-12-29 09:00:00+03	300	5	99
70	2021-12-29 12:00:00+03	500	6	99
71	2021-12-29 15:00:00+03	500	7	99
72	2021-12-29 19:30:00+03	700	9	99
73	2021-12-29 09:00:00+03	500	4	150
74	2021-12-29 11:00:00+03	500	4	150
75	2021-12-29 13:00:00+03	500	5	150
76	2021-12-29 16:00:00+03	500	1	150
77	2021-12-29 19:00:00+03	500	3	150
78	2021-12-29 22:30:00+03	500	5	150
79	2021-12-29 09:00:00+03	500	7	198
80	2021-12-29 11:00:00+03	500	7	198
81	2021-12-29 13:00:00+03	500	7	198
82	2021-12-29 17:00:00+03	500	7	198
83	2021-12-29 19:30:00+03	500	7	198
84	2021-12-29 21:30:00+03	500	7	198
85	2021-12-29 23:30:00+03	500	7	198
86	2021-12-12 10:00:00+03	350	1	2
87	2021-12-12 13:00:00+03	400	1	2
88	2021-12-12 16:00:00+03	400	1	2
89	2021-12-12 19:00:00+03	500	1	2
90	2021-12-12 22:00:00+03	400	1	2
91	2021-12-12 09:00:00+03	250	2	46
92	2021-12-12 12:00:00+03	300	3	46
93	2021-12-12 15:00:00+03	400	3	46
94	2021-12-12 18:00:00+03	400	3	46
95	2021-12-12 21:00:00+03	500	3	46
96	2021-12-12 07:00:00+03	300	4	99
97	2021-12-12 09:00:00+03	300	5	99
98	2021-12-12 12:00:00+03	500	6	99
99	2021-12-12 15:00:00+03	500	7	99
100	2021-12-12 19:30:00+03	700	9	99
101	2021-12-12 09:00:00+03	500	4	150
102	2021-12-12 11:00:00+03	500	4	150
103	2021-12-12 13:00:00+03	500	5	150
104	2021-12-12 16:00:00+03	500	1	150
105	2021-12-12 19:00:00+03	500	3	150
106	2021-12-12 22:30:00+03	500	5	150
107	2021-12-12 09:00:00+03	500	7	198
108	2021-12-12 11:00:00+03	500	7	198
109	2021-12-12 13:00:00+03	500	7	198
110	2021-12-12 17:00:00+03	500	7	198
111	2021-12-12 19:30:00+03	500	7	198
112	2021-12-12 21:30:00+03	500	7	198
113	2021-12-12 23:30:00+03	500	7	198
131	2022-05-19 09:00:00+03	250	12	46
132	2022-05-19 12:00:00+03	300	13	46
133	2022-05-19 15:00:00+03	400	13	46
134	2022-05-19 18:00:00+03	400	13	46
135	2022-05-19 21:00:00+03	500	13	46
136	2022-05-19 07:00:00+03	300	14	99
137	2022-05-19 09:00:00+03	300	15	99
138	2022-05-19 12:00:00+03	500	16	99
139	2022-05-19 15:00:00+03	500	17	99
140	2022-05-19 19:30:00+03	700	19	99
151	2022-05-19 09:00:00+03	500	14	150
152	2022-05-19 11:00:00+03	500	14	150
153	2022-05-19 13:00:00+03	500	15	150
154	2022-05-19 16:00:00+03	500	14	150
155	2022-05-19 19:00:00+03	500	13	150
156	2022-05-19 22:30:00+03	500	15	150
157	2022-05-19 09:00:00+03	500	17	198
158	2022-05-19 11:00:00+03	500	17	198
159	2022-05-19 13:00:00+03	500	17	198
160	2022-05-19 17:00:00+03	500	17	198
161	2022-05-19 19:30:00+03	500	17	198
162	2022-05-19 21:30:00+03	500	17	198
163	2022-05-19 23:30:00+03	500	17	198
164	2022-05-20 10:00:00+03	350	12	2
165	2022-05-20 13:00:00+03	400	12	2
166	2022-05-20 16:00:00+03	400	12	2
167	2022-05-20 19:00:00+03	500	12	2
168	2022-05-20 22:00:00+03	400	12	2
169	2022-05-20 09:00:00+03	250	12	46
170	2022-05-20 12:00:00+03	300	13	46
171	2022-05-20 15:00:00+03	400	13	46
172	2022-05-20 18:00:00+03	400	13	46
173	2022-05-20 21:00:00+03	500	13	46
174	2022-05-20 07:00:00+03	300	14	99
175	2022-05-20 09:00:00+03	300	15	99
176	2022-05-20 12:00:00+03	500	16	99
177	2022-05-20 15:00:00+03	500	17	99
178	2022-05-20 19:30:00+03	700	19	99
185	2022-05-20 09:00:00+03	500	14	150
186	2022-05-20 11:00:00+03	500	14	150
187	2022-05-20 13:00:00+03	500	15	150
188	2022-05-20 16:00:00+03	500	12	150
189	2022-05-20 19:00:00+03	500	13	150
190	2022-05-20 22:30:00+03	500	15	150
193	2022-05-22 09:00:00+03	500	17	198
194	2022-05-22 11:00:00+03	500	17	198
195	2022-05-22 13:00:00+03	500	17	198
196	2022-05-22 17:00:00+03	500	17	198
197	2022-05-22 19:30:00+03	500	17	198
198	2022-05-22 21:30:00+03	500	17	198
199	2022-05-22 23:30:00+03	500	17	198
200	2022-05-21 10:00:00+03	350	21	2
201	2022-05-21 13:00:00+03	400	21	2
202	2022-05-21 16:00:00+03	400	21	2
203	2022-05-21 19:00:00+03	500	21	2
204	2022-05-21 22:00:00+03	400	21	2
205	2022-05-21 09:00:00+03	250	12	46
206	2022-05-21 12:00:00+03	300	13	46
207	2022-05-21 15:00:00+03	400	13	46
208	2022-05-21 18:00:00+03	400	13	46
209	2022-05-21 21:00:00+03	500	13	46
210	2022-05-21 07:00:00+03	300	14	99
211	2022-05-21 09:00:00+03	300	15	99
212	2022-05-21 12:00:00+03	500	16	99
213	2022-05-21 15:00:00+03	500	17	99
214	2022-05-21 19:30:00+03	700	19	99
229	2022-05-21 09:00:00+03	500	14	150
230	2022-05-21 11:00:00+03	500	14	150
231	2022-05-21 13:00:00+03	500	15	150
232	2022-05-21 16:00:00+03	500	12	150
233	2022-05-21 19:00:00+03	500	13	150
234	2022-05-21 22:30:00+03	500	15	150
235	2022-05-21 09:00:00+03	500	17	198
236	2022-05-21 11:00:00+03	500	17	198
237	2022-05-21 13:00:00+03	500	17	198
238	2022-05-21 17:00:00+03	500	17	198
239	2022-05-21 19:30:00+03	500	17	198
240	2022-05-21 21:30:00+03	500	17	198
241	2022-05-21 23:30:00+03	500	17	198
243	2022-05-23 09:00:00+03	500	18	198
244	2022-05-23 11:00:00+03	500	18	198
245	2022-05-23 13:00:00+03	500	18	198
246	2022-05-23 17:00:00+03	500	18	198
247	2022-05-23 19:30:00+03	500	18	198
248	2022-05-23 21:30:00+03	500	18	198
249	2022-05-23 23:30:00+03	500	18	198
256	2022-05-23 09:00:00+03	500	19	150
257	2022-05-23 12:00:00+03	500	19	150
258	2022-05-23 15:00:00+03	500	19	150
259	2022-05-23 18:00:00+03	500	19	150
260	2022-05-23 21:30:00+03	500	19	150
261	2022-05-22 09:00:00+03	500	20	99
262	2022-05-22 11:00:00+03	500	20	99
263	2022-05-22 13:00:00+03	500	20	99
264	2022-05-22 17:00:00+03	500	20	99
265	2022-05-22 19:30:00+03	500	20	99
266	2022-05-22 21:30:00+03	500	20	99
267	2022-05-22 23:30:00+03	500	20	99
269	2022-05-23 09:00:00+03	500	21	99
270	2022-05-23 12:00:00+03	500	21	99
271	2022-05-23 15:00:00+03	500	21	99
272	2022-05-23 18:00:00+03	500	21	99
273	2022-05-23 21:30:00+03	500	21	99
\.


--
-- Data for Name: spots; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.spots (id, "row", number, hallid) FROM stdin;
1	1	1	1
2	1	2	1
3	1	3	1
4	1	4	1
5	1	5	1
6	1	6	1
7	1	7	1
8	1	8	1
9	1	9	1
10	1	10	1
11	2	1	1
12	2	2	1
13	2	3	1
14	2	4	1
15	2	5	1
16	2	6	1
17	2	7	1
18	2	8	1
19	2	9	1
20	2	10	1
21	3	1	1
22	3	2	1
23	3	3	1
24	3	4	1
25	3	5	1
26	3	6	1
27	3	7	1
28	3	8	1
29	3	9	1
30	3	10	1
31	4	1	1
32	4	2	1
33	4	3	1
34	4	4	1
35	4	5	1
36	4	6	1
37	4	7	1
38	4	8	1
39	4	9	1
40	4	10	1
41	5	1	1
42	5	2	1
43	5	3	1
44	5	4	1
45	5	5	1
46	5	6	1
47	5	7	1
48	5	8	1
49	5	9	1
50	5	10	1
51	6	1	1
52	6	2	1
53	6	3	1
54	6	4	1
55	6	5	1
56	6	6	1
57	6	7	1
58	6	8	1
59	6	9	1
60	6	10	1
61	7	1	1
62	7	2	1
63	7	3	1
64	7	4	1
65	7	5	1
66	7	6	1
67	7	7	1
68	7	8	1
69	7	9	1
70	7	10	1
71	8	1	1
72	8	2	1
73	8	3	1
74	8	4	1
75	8	5	1
76	8	6	1
77	8	7	1
78	8	8	1
79	8	9	1
80	8	10	1
81	9	1	1
82	9	2	1
83	9	3	1
84	9	4	1
85	9	5	1
86	9	6	1
87	9	7	1
88	9	8	1
89	9	9	1
90	9	10	1
91	10	1	1
92	10	2	1
93	10	3	1
94	10	4	1
95	10	5	1
96	10	6	1
97	10	7	1
98	10	8	1
99	10	9	1
100	10	10	1
101	1	1	2
102	1	2	2
103	1	3	2
104	1	4	2
105	1	5	2
106	1	6	2
107	1	7	2
108	1	8	2
109	1	9	2
110	1	10	2
111	2	1	2
112	2	2	2
113	2	3	2
114	2	4	2
115	2	5	2
116	2	6	2
117	2	7	2
118	2	8	2
119	2	9	2
120	2	10	2
121	3	1	2
122	3	2	2
123	3	3	2
124	3	4	2
125	3	5	2
126	3	6	2
127	3	7	2
128	3	8	2
129	3	9	2
130	3	10	2
131	4	1	2
132	4	2	2
133	4	3	2
134	4	4	2
135	4	5	2
136	4	6	2
137	4	7	2
138	4	8	2
139	4	9	2
140	4	10	2
141	5	1	2
142	5	2	2
143	5	3	2
144	5	4	2
145	5	5	2
146	5	6	2
147	5	7	2
148	5	8	2
149	5	9	2
150	5	10	2
151	6	1	2
152	6	2	2
153	6	3	2
154	6	4	2
155	6	5	2
156	6	6	2
157	6	7	2
158	6	8	2
159	6	9	2
160	6	10	2
161	7	1	2
162	7	2	2
163	7	3	2
164	7	4	2
165	7	5	2
166	7	6	2
167	7	7	2
168	7	8	2
169	7	9	2
170	7	10	2
171	8	1	2
172	8	2	2
173	8	3	2
174	8	4	2
175	8	5	2
176	8	6	2
177	8	7	2
178	8	8	2
179	8	9	2
180	8	10	2
181	9	1	2
182	9	2	2
183	9	3	2
184	9	4	2
185	9	5	2
186	9	6	2
187	9	7	2
188	9	8	2
189	9	9	2
190	9	10	2
191	10	1	2
192	10	2	2
193	10	3	2
194	10	4	2
195	10	5	2
196	10	6	2
197	10	7	2
198	10	8	2
199	10	9	2
200	10	10	2
201	1	1	3
202	1	2	3
203	1	3	3
204	1	4	3
205	1	5	3
206	1	6	3
207	1	7	3
208	1	8	3
209	1	9	3
210	1	10	3
211	2	1	3
212	2	2	3
213	2	3	3
214	2	4	3
215	2	5	3
216	2	6	3
217	2	7	3
218	2	8	3
219	2	9	3
220	2	10	3
221	3	1	3
222	3	2	3
223	3	3	3
224	3	4	3
225	3	5	3
226	3	6	3
227	3	7	3
228	3	8	3
229	3	9	3
230	3	10	3
231	4	1	3
232	4	2	3
233	4	3	3
234	4	4	3
235	4	5	3
236	4	6	3
237	4	7	3
238	4	8	3
239	4	9	3
240	4	10	3
241	5	1	3
242	5	2	3
243	5	3	3
244	5	4	3
245	5	5	3
246	5	6	3
247	5	7	3
248	5	8	3
249	5	9	3
250	5	10	3
251	6	1	3
252	6	2	3
253	6	3	3
254	6	4	3
255	6	5	3
256	6	6	3
257	6	7	3
258	6	8	3
259	6	9	3
260	6	10	3
261	7	1	3
262	7	2	3
263	7	3	3
264	7	4	3
265	7	5	3
266	7	6	3
267	7	7	3
268	7	8	3
269	7	9	3
270	7	10	3
271	8	1	3
272	8	2	3
273	8	3	3
274	8	4	3
275	8	5	3
276	8	6	3
277	8	7	3
278	8	8	3
279	8	9	3
280	8	10	3
281	9	1	3
282	9	2	3
283	9	3	3
284	9	4	3
285	9	5	3
286	9	6	3
287	9	7	3
288	9	8	3
289	9	9	3
290	9	10	3
291	10	1	3
292	10	2	3
293	10	3	3
294	10	4	3
295	10	5	3
296	10	6	3
297	10	7	3
298	10	8	3
299	10	9	3
300	10	10	3
301	1	1	4
302	1	2	4
303	1	3	4
304	1	4	4
305	1	5	4
306	1	6	4
307	1	7	4
308	1	8	4
309	1	9	4
310	1	10	4
311	2	1	4
312	2	2	4
313	2	3	4
314	2	4	4
315	2	5	4
316	2	6	4
317	2	7	4
318	2	8	4
319	2	9	4
320	2	10	4
321	3	1	4
322	3	2	4
323	3	3	4
324	3	4	4
325	3	5	4
326	3	6	4
327	3	7	4
328	3	8	4
329	3	9	4
330	3	10	4
331	4	1	4
332	4	2	4
333	4	3	4
334	4	4	4
335	4	5	4
336	4	6	4
337	4	7	4
338	4	8	4
339	4	9	4
340	4	10	4
341	5	1	4
342	5	2	4
343	5	3	4
344	5	4	4
345	5	5	4
346	5	6	4
347	5	7	4
348	5	8	4
349	5	9	4
350	5	10	4
351	6	1	4
352	6	2	4
353	6	3	4
354	6	4	4
355	6	5	4
356	6	6	4
357	6	7	4
358	6	8	4
359	6	9	4
360	6	10	4
361	7	1	4
362	7	2	4
363	7	3	4
364	7	4	4
365	7	5	4
366	7	6	4
367	7	7	4
368	7	8	4
369	7	9	4
370	7	10	4
371	8	1	4
372	8	2	4
373	8	3	4
374	8	4	4
375	8	5	4
376	8	6	4
377	8	7	4
378	8	8	4
379	8	9	4
380	8	10	4
381	9	1	4
382	9	2	4
383	9	3	4
384	9	4	4
385	9	5	4
386	9	6	4
387	9	7	4
388	9	8	4
389	9	9	4
390	9	10	4
391	10	1	4
392	10	2	4
393	10	3	4
394	10	4	4
395	10	5	4
396	10	6	4
397	10	7	4
398	10	8	4
399	10	9	4
400	10	10	4
401	1	1	5
402	1	2	5
403	1	3	5
404	1	4	5
405	1	5	5
406	1	6	5
407	1	7	5
408	1	8	5
409	1	9	5
410	1	10	5
411	2	1	5
412	2	2	5
413	2	3	5
414	2	4	5
415	2	5	5
416	2	6	5
417	2	7	5
418	2	8	5
419	2	9	5
420	2	10	5
421	3	1	5
422	3	2	5
423	3	3	5
424	3	4	5
425	3	5	5
426	3	6	5
427	3	7	5
428	3	8	5
429	3	9	5
430	3	10	5
431	4	1	5
432	4	2	5
433	4	3	5
434	4	4	5
435	4	5	5
436	4	6	5
437	4	7	5
438	4	8	5
439	4	9	5
440	4	10	5
441	5	1	5
442	5	2	5
443	5	3	5
444	5	4	5
445	5	5	5
446	5	6	5
447	5	7	5
448	5	8	5
449	5	9	5
450	5	10	5
451	6	1	5
452	6	2	5
453	6	3	5
454	6	4	5
455	6	5	5
456	6	6	5
457	6	7	5
458	6	8	5
459	6	9	5
460	6	10	5
461	7	1	5
462	7	2	5
463	7	3	5
464	7	4	5
465	7	5	5
466	7	6	5
467	7	7	5
468	7	8	5
469	7	9	5
470	7	10	5
471	8	1	5
472	8	2	5
473	8	3	5
474	8	4	5
475	8	5	5
476	8	6	5
477	8	7	5
478	8	8	5
479	8	9	5
480	8	10	5
481	9	1	5
482	9	2	5
483	9	3	5
484	9	4	5
485	9	5	5
486	9	6	5
487	9	7	5
488	9	8	5
489	9	9	5
490	9	10	5
491	10	1	5
492	10	2	5
493	10	3	5
494	10	4	5
495	10	5	5
496	10	6	5
497	10	7	5
498	10	8	5
499	10	9	5
500	10	10	5
501	1	1	6
502	1	2	6
503	1	3	6
504	1	4	6
505	1	5	6
506	1	6	6
507	1	7	6
508	1	8	6
509	1	9	6
510	1	10	6
511	2	1	6
512	2	2	6
513	2	3	6
514	2	4	6
515	2	5	6
516	2	6	6
517	2	7	6
518	2	8	6
519	2	9	6
520	2	10	6
521	3	1	6
522	3	2	6
523	3	3	6
524	3	4	6
525	3	5	6
526	3	6	6
527	3	7	6
528	3	8	6
529	3	9	6
530	3	10	6
531	4	1	6
532	4	2	6
533	4	3	6
534	4	4	6
535	4	5	6
536	4	6	6
537	4	7	6
538	4	8	6
539	4	9	6
540	4	10	6
541	5	1	6
542	5	2	6
543	5	3	6
544	5	4	6
545	5	5	6
546	5	6	6
547	5	7	6
548	5	8	6
549	5	9	6
550	5	10	6
551	6	1	6
552	6	2	6
553	6	3	6
554	6	4	6
555	6	5	6
556	6	6	6
557	6	7	6
558	6	8	6
559	6	9	6
560	6	10	6
561	7	1	6
562	7	2	6
563	7	3	6
564	7	4	6
565	7	5	6
566	7	6	6
567	7	7	6
568	7	8	6
569	7	9	6
570	7	10	6
571	8	1	6
572	8	2	6
573	8	3	6
574	8	4	6
575	8	5	6
576	8	6	6
577	8	7	6
578	8	8	6
579	8	9	6
580	8	10	6
581	9	1	6
582	9	2	6
583	9	3	6
584	9	4	6
585	9	5	6
586	9	6	6
587	9	7	6
588	9	8	6
589	9	9	6
590	9	10	6
591	10	1	6
592	10	2	6
593	10	3	6
594	10	4	6
595	10	5	6
596	10	6	6
597	10	7	6
598	10	8	6
599	10	9	6
600	10	10	6
601	1	1	7
602	1	2	7
603	1	3	7
604	1	4	7
605	1	5	7
606	1	6	7
607	1	7	7
608	1	8	7
609	1	9	7
610	1	10	7
611	2	1	7
612	2	2	7
613	2	3	7
614	2	4	7
615	2	5	7
616	2	6	7
617	2	7	7
618	2	8	7
619	2	9	7
620	2	10	7
621	3	1	7
622	3	2	7
623	3	3	7
624	3	4	7
625	3	5	7
626	3	6	7
627	3	7	7
628	3	8	7
629	3	9	7
630	3	10	7
631	4	1	7
632	4	2	7
633	4	3	7
634	4	4	7
635	4	5	7
636	4	6	7
637	4	7	7
638	4	8	7
639	4	9	7
640	4	10	7
641	5	1	7
642	5	2	7
643	5	3	7
644	5	4	7
645	5	5	7
646	5	6	7
647	5	7	7
648	5	8	7
649	5	9	7
650	5	10	7
651	6	1	7
652	6	2	7
653	6	3	7
654	6	4	7
655	6	5	7
656	6	6	7
657	6	7	7
658	6	8	7
659	6	9	7
660	6	10	7
661	7	1	7
662	7	2	7
663	7	3	7
664	7	4	7
665	7	5	7
666	7	6	7
667	7	7	7
668	7	8	7
669	7	9	7
670	7	10	7
671	8	1	7
672	8	2	7
673	8	3	7
674	8	4	7
675	8	5	7
676	8	6	7
677	8	7	7
678	8	8	7
679	8	9	7
680	8	10	7
681	9	1	7
682	9	2	7
683	9	3	7
684	9	4	7
685	9	5	7
686	9	6	7
687	9	7	7
688	9	8	7
689	9	9	7
690	9	10	7
691	10	1	7
692	10	2	7
693	10	3	7
694	10	4	7
695	10	5	7
696	10	6	7
697	10	7	7
698	10	8	7
699	10	9	7
700	10	10	7
701	1	1	8
702	1	2	8
703	1	3	8
704	1	4	8
705	1	5	8
706	1	6	8
707	1	7	8
708	1	8	8
709	1	9	8
710	1	10	8
711	2	1	8
712	2	2	8
713	2	3	8
714	2	4	8
715	2	5	8
716	2	6	8
717	2	7	8
718	2	8	8
719	2	9	8
720	2	10	8
721	3	1	8
722	3	2	8
723	3	3	8
724	3	4	8
725	3	5	8
726	3	6	8
727	3	7	8
728	3	8	8
729	3	9	8
730	3	10	8
731	4	1	8
732	4	2	8
733	4	3	8
734	4	4	8
735	4	5	8
736	4	6	8
737	4	7	8
738	4	8	8
739	4	9	8
740	4	10	8
741	5	1	8
742	5	2	8
743	5	3	8
744	5	4	8
745	5	5	8
746	5	6	8
747	5	7	8
748	5	8	8
749	5	9	8
750	5	10	8
751	6	1	8
752	6	2	8
753	6	3	8
754	6	4	8
755	6	5	8
756	6	6	8
757	6	7	8
758	6	8	8
759	6	9	8
760	6	10	8
761	7	1	8
762	7	2	8
763	7	3	8
764	7	4	8
765	7	5	8
766	7	6	8
767	7	7	8
768	7	8	8
769	7	9	8
770	7	10	8
771	8	1	8
772	8	2	8
773	8	3	8
774	8	4	8
775	8	5	8
776	8	6	8
777	8	7	8
778	8	8	8
779	8	9	8
780	8	10	8
781	9	1	8
782	9	2	8
783	9	3	8
784	9	4	8
785	9	5	8
786	9	6	8
787	9	7	8
788	9	8	8
789	9	9	8
790	9	10	8
791	10	1	8
792	10	2	8
793	10	3	8
794	10	4	8
795	10	5	8
796	10	6	8
797	10	7	8
798	10	8	8
799	10	9	8
800	10	10	8
801	1	1	9
802	1	2	9
803	1	3	9
804	1	4	9
805	1	5	9
806	1	6	9
807	1	7	9
808	1	8	9
809	1	9	9
810	1	10	9
811	2	1	9
812	2	2	9
813	2	3	9
814	2	4	9
815	2	5	9
816	2	6	9
817	2	7	9
818	2	8	9
819	2	9	9
820	2	10	9
821	3	1	9
822	3	2	9
823	3	3	9
824	3	4	9
825	3	5	9
826	3	6	9
827	3	7	9
828	3	8	9
829	3	9	9
830	3	10	9
831	4	1	9
832	4	2	9
833	4	3	9
834	4	4	9
835	4	5	9
836	4	6	9
837	4	7	9
838	4	8	9
839	4	9	9
840	4	10	9
841	5	1	9
842	5	2	9
843	5	3	9
844	5	4	9
845	5	5	9
846	5	6	9
847	5	7	9
848	5	8	9
849	5	9	9
850	5	10	9
851	6	1	9
852	6	2	9
853	6	3	9
854	6	4	9
855	6	5	9
856	6	6	9
857	6	7	9
858	6	8	9
859	6	9	9
860	6	10	9
861	7	1	9
862	7	2	9
863	7	3	9
864	7	4	9
865	7	5	9
866	7	6	9
867	7	7	9
868	7	8	9
869	7	9	9
870	7	10	9
871	8	1	9
872	8	2	9
873	8	3	9
874	8	4	9
875	8	5	9
876	8	6	9
877	8	7	9
878	8	8	9
879	8	9	9
880	8	10	9
881	9	1	9
882	9	2	9
883	9	3	9
884	9	4	9
885	9	5	9
886	9	6	9
887	9	7	9
888	9	8	9
889	9	9	9
890	9	10	9
891	10	1	9
892	10	2	9
893	10	3	9
894	10	4	9
895	10	5	9
896	10	6	9
897	10	7	9
898	10	8	9
899	10	9	9
900	10	10	9
901	1	1	10
902	1	2	10
903	1	3	10
904	1	4	10
905	1	5	10
906	1	6	10
907	1	7	10
908	1	8	10
909	1	9	10
910	1	10	10
911	2	1	10
912	2	2	10
913	2	3	10
914	2	4	10
915	2	5	10
916	2	6	10
917	2	7	10
918	2	8	10
919	2	9	10
920	2	10	10
921	3	1	10
922	3	2	10
923	3	3	10
924	3	4	10
925	3	5	10
926	3	6	10
927	3	7	10
928	3	8	10
929	3	9	10
930	3	10	10
931	4	1	10
932	4	2	10
933	4	3	10
934	4	4	10
935	4	5	10
936	4	6	10
937	4	7	10
938	4	8	10
939	4	9	10
940	4	10	10
941	5	1	10
942	5	2	10
943	5	3	10
944	5	4	10
945	5	5	10
946	5	6	10
947	5	7	10
948	5	8	10
949	5	9	10
950	5	10	10
951	6	1	10
952	6	2	10
953	6	3	10
954	6	4	10
955	6	5	10
956	6	6	10
957	6	7	10
958	6	8	10
959	6	9	10
960	6	10	10
961	7	1	10
962	7	2	10
963	7	3	10
964	7	4	10
965	7	5	10
966	7	6	10
967	7	7	10
968	7	8	10
969	7	9	10
970	7	10	10
971	8	1	10
972	8	2	10
973	8	3	10
974	8	4	10
975	8	5	10
976	8	6	10
977	8	7	10
978	8	8	10
979	8	9	10
980	8	10	10
981	9	1	10
982	9	2	10
983	9	3	10
984	9	4	10
985	9	5	10
986	9	6	10
987	9	7	10
988	9	8	10
989	9	9	10
990	9	10	10
991	10	1	10
992	10	2	10
993	10	3	10
994	10	4	10
995	10	5	10
996	10	6	10
997	10	7	10
998	10	8	10
999	10	9	10
1000	10	10	10
1001	1	1	11
1002	1	2	11
1003	1	3	11
1004	1	4	11
1005	1	5	11
1006	1	6	11
1007	1	7	11
1008	1	8	11
1009	1	9	11
1010	1	10	11
1011	2	1	11
1012	2	2	11
1013	2	3	11
1014	2	4	11
1015	2	5	11
1016	2	6	11
1017	2	7	11
1018	2	8	11
1019	2	9	11
1020	2	10	11
1021	3	1	11
1022	3	2	11
1023	3	3	11
1024	3	4	11
1025	3	5	11
1026	3	6	11
1027	3	7	11
1028	3	8	11
1029	3	9	11
1030	3	10	11
1031	4	1	11
1032	4	2	11
1033	4	3	11
1034	4	4	11
1035	4	5	11
1036	4	6	11
1037	4	7	11
1038	4	8	11
1039	4	9	11
1040	4	10	11
1041	5	1	11
1042	5	2	11
1043	5	3	11
1044	5	4	11
1045	5	5	11
1046	5	6	11
1047	5	7	11
1048	5	8	11
1049	5	9	11
1050	5	10	11
1051	6	1	11
1052	6	2	11
1053	6	3	11
1054	6	4	11
1055	6	5	11
1056	6	6	11
1057	6	7	11
1058	6	8	11
1059	6	9	11
1060	6	10	11
1061	7	1	11
1062	7	2	11
1063	7	3	11
1064	7	4	11
1065	7	5	11
1066	7	6	11
1067	7	7	11
1068	7	8	11
1069	7	9	11
1070	7	10	11
1071	8	1	11
1072	8	2	11
1073	8	3	11
1074	8	4	11
1075	8	5	11
1076	8	6	11
1077	8	7	11
1078	8	8	11
1079	8	9	11
1080	8	10	11
1081	9	1	11
1082	9	2	11
1083	9	3	11
1084	9	4	11
1085	9	5	11
1086	9	6	11
1087	9	7	11
1088	9	8	11
1089	9	9	11
1090	9	10	11
1091	10	1	11
1092	10	2	11
1093	10	3	11
1094	10	4	11
1095	10	5	11
1096	10	6	11
1097	10	7	11
1098	10	8	11
1099	10	9	11
1100	10	10	11
1101	1	1	12
1102	1	2	12
1103	1	3	12
1104	1	4	12
1105	1	5	12
1106	1	6	12
1107	1	7	12
1108	1	8	12
1109	1	9	12
1110	1	10	12
1111	2	1	12
1112	2	2	12
1113	2	3	12
1114	2	4	12
1115	2	5	12
1116	2	6	12
1117	2	7	12
1118	2	8	12
1119	2	9	12
1120	2	10	12
1121	3	1	12
1122	3	2	12
1123	3	3	12
1124	3	4	12
1125	3	5	12
1126	3	6	12
1127	3	7	12
1128	3	8	12
1129	3	9	12
1130	3	10	12
1131	4	1	12
1132	4	2	12
1133	4	3	12
1134	4	4	12
1135	4	5	12
1136	4	6	12
1137	4	7	12
1138	4	8	12
1139	4	9	12
1140	4	10	12
1141	5	1	12
1142	5	2	12
1143	5	3	12
1144	5	4	12
1145	5	5	12
1146	5	6	12
1147	5	7	12
1148	5	8	12
1149	5	9	12
1150	5	10	12
1151	6	1	12
1152	6	2	12
1153	6	3	12
1154	6	4	12
1155	6	5	12
1156	6	6	12
1157	6	7	12
1158	6	8	12
1159	6	9	12
1160	6	10	12
1161	7	1	12
1162	7	2	12
1163	7	3	12
1164	7	4	12
1165	7	5	12
1166	7	6	12
1167	7	7	12
1168	7	8	12
1169	7	9	12
1170	7	10	12
1171	8	1	12
1172	8	2	12
1173	8	3	12
1174	8	4	12
1175	8	5	12
1176	8	6	12
1177	8	7	12
1178	8	8	12
1179	8	9	12
1180	8	10	12
1181	9	1	12
1182	9	2	12
1183	9	3	12
1184	9	4	12
1185	9	5	12
1186	9	6	12
1187	9	7	12
1188	9	8	12
1189	9	9	12
1190	9	10	12
1191	10	1	12
1192	10	2	12
1193	10	3	12
1194	10	4	12
1195	10	5	12
1196	10	6	12
1197	10	7	12
1198	10	8	12
1199	10	9	12
1200	10	10	12
1201	1	1	13
1202	1	2	13
1203	1	3	13
1204	1	4	13
1205	1	5	13
1206	1	6	13
1207	1	7	13
1208	1	8	13
1209	1	9	13
1210	1	10	13
1211	2	1	13
1212	2	2	13
1213	2	3	13
1214	2	4	13
1215	2	5	13
1216	2	6	13
1217	2	7	13
1218	2	8	13
1219	2	9	13
1220	2	10	13
1221	3	1	13
1222	3	2	13
1223	3	3	13
1224	3	4	13
1225	3	5	13
1226	3	6	13
1227	3	7	13
1228	3	8	13
1229	3	9	13
1230	3	10	13
1231	4	1	13
1232	4	2	13
1233	4	3	13
1234	4	4	13
1235	4	5	13
1236	4	6	13
1237	4	7	13
1238	4	8	13
1239	4	9	13
1240	4	10	13
1241	5	1	13
1242	5	2	13
1243	5	3	13
1244	5	4	13
1245	5	5	13
1246	5	6	13
1247	5	7	13
1248	5	8	13
1249	5	9	13
1250	5	10	13
1251	6	1	13
1252	6	2	13
1253	6	3	13
1254	6	4	13
1255	6	5	13
1256	6	6	13
1257	6	7	13
1258	6	8	13
1259	6	9	13
1260	6	10	13
1261	7	1	13
1262	7	2	13
1263	7	3	13
1264	7	4	13
1265	7	5	13
1266	7	6	13
1267	7	7	13
1268	7	8	13
1269	7	9	13
1270	7	10	13
1271	8	1	13
1272	8	2	13
1273	8	3	13
1274	8	4	13
1275	8	5	13
1276	8	6	13
1277	8	7	13
1278	8	8	13
1279	8	9	13
1280	8	10	13
1281	9	1	13
1282	9	2	13
1283	9	3	13
1284	9	4	13
1285	9	5	13
1286	9	6	13
1287	9	7	13
1288	9	8	13
1289	9	9	13
1290	9	10	13
1291	10	1	13
1292	10	2	13
1293	10	3	13
1294	10	4	13
1295	10	5	13
1296	10	6	13
1297	10	7	13
1298	10	8	13
1299	10	9	13
1300	10	10	13
1301	1	1	14
1302	1	2	14
1303	1	3	14
1304	1	4	14
1305	1	5	14
1306	1	6	14
1307	1	7	14
1308	1	8	14
1309	1	9	14
1310	1	10	14
1311	2	1	14
1312	2	2	14
1313	2	3	14
1314	2	4	14
1315	2	5	14
1316	2	6	14
1317	2	7	14
1318	2	8	14
1319	2	9	14
1320	2	10	14
1321	3	1	14
1322	3	2	14
1323	3	3	14
1324	3	4	14
1325	3	5	14
1326	3	6	14
1327	3	7	14
1328	3	8	14
1329	3	9	14
1330	3	10	14
1331	4	1	14
1332	4	2	14
1333	4	3	14
1334	4	4	14
1335	4	5	14
1336	4	6	14
1337	4	7	14
1338	4	8	14
1339	4	9	14
1340	4	10	14
1341	5	1	14
1342	5	2	14
1343	5	3	14
1344	5	4	14
1345	5	5	14
1346	5	6	14
1347	5	7	14
1348	5	8	14
1349	5	9	14
1350	5	10	14
1351	6	1	14
1352	6	2	14
1353	6	3	14
1354	6	4	14
1355	6	5	14
1356	6	6	14
1357	6	7	14
1358	6	8	14
1359	6	9	14
1360	6	10	14
1361	7	1	14
1362	7	2	14
1363	7	3	14
1364	7	4	14
1365	7	5	14
1366	7	6	14
1367	7	7	14
1368	7	8	14
1369	7	9	14
1370	7	10	14
1371	8	1	14
1372	8	2	14
1373	8	3	14
1374	8	4	14
1375	8	5	14
1376	8	6	14
1377	8	7	14
1378	8	8	14
1379	8	9	14
1380	8	10	14
1381	9	1	14
1382	9	2	14
1383	9	3	14
1384	9	4	14
1385	9	5	14
1386	9	6	14
1387	9	7	14
1388	9	8	14
1389	9	9	14
1390	9	10	14
1391	10	1	14
1392	10	2	14
1393	10	3	14
1394	10	4	14
1395	10	5	14
1396	10	6	14
1397	10	7	14
1398	10	8	14
1399	10	9	14
1400	10	10	14
1401	1	1	15
1402	1	2	15
1403	1	3	15
1404	1	4	15
1405	1	5	15
1406	1	6	15
1407	1	7	15
1408	1	8	15
1409	1	9	15
1410	1	10	15
1411	2	1	15
1412	2	2	15
1413	2	3	15
1414	2	4	15
1415	2	5	15
1416	2	6	15
1417	2	7	15
1418	2	8	15
1419	2	9	15
1420	2	10	15
1421	3	1	15
1422	3	2	15
1423	3	3	15
1424	3	4	15
1425	3	5	15
1426	3	6	15
1427	3	7	15
1428	3	8	15
1429	3	9	15
1430	3	10	15
1431	4	1	15
1432	4	2	15
1433	4	3	15
1434	4	4	15
1435	4	5	15
1436	4	6	15
1437	4	7	15
1438	4	8	15
1439	4	9	15
1440	4	10	15
1441	5	1	15
1442	5	2	15
1443	5	3	15
1444	5	4	15
1445	5	5	15
1446	5	6	15
1447	5	7	15
1448	5	8	15
1449	5	9	15
1450	5	10	15
1451	6	1	15
1452	6	2	15
1453	6	3	15
1454	6	4	15
1455	6	5	15
1456	6	6	15
1457	6	7	15
1458	6	8	15
1459	6	9	15
1460	6	10	15
1461	7	1	15
1462	7	2	15
1463	7	3	15
1464	7	4	15
1465	7	5	15
1466	7	6	15
1467	7	7	15
1468	7	8	15
1469	7	9	15
1470	7	10	15
1471	8	1	15
1472	8	2	15
1473	8	3	15
1474	8	4	15
1475	8	5	15
1476	8	6	15
1477	8	7	15
1478	8	8	15
1479	8	9	15
1480	8	10	15
1481	9	1	15
1482	9	2	15
1483	9	3	15
1484	9	4	15
1485	9	5	15
1486	9	6	15
1487	9	7	15
1488	9	8	15
1489	9	9	15
1490	9	10	15
1491	10	1	15
1492	10	2	15
1493	10	3	15
1494	10	4	15
1495	10	5	15
1496	10	6	15
1497	10	7	15
1498	10	8	15
1499	10	9	15
1500	10	10	15
1501	1	1	16
1502	1	2	16
1503	1	3	16
1504	1	4	16
1505	1	5	16
1506	1	6	16
1507	1	7	16
1508	1	8	16
1509	1	9	16
1510	1	10	16
1511	2	1	16
1512	2	2	16
1513	2	3	16
1514	2	4	16
1515	2	5	16
1516	2	6	16
1517	2	7	16
1518	2	8	16
1519	2	9	16
1520	2	10	16
1521	3	1	16
1522	3	2	16
1523	3	3	16
1524	3	4	16
1525	3	5	16
1526	3	6	16
1527	3	7	16
1528	3	8	16
1529	3	9	16
1530	3	10	16
1531	4	1	16
1532	4	2	16
1533	4	3	16
1534	4	4	16
1535	4	5	16
1536	4	6	16
1537	4	7	16
1538	4	8	16
1539	4	9	16
1540	4	10	16
1541	5	1	16
1542	5	2	16
1543	5	3	16
1544	5	4	16
1545	5	5	16
1546	5	6	16
1547	5	7	16
1548	5	8	16
1549	5	9	16
1550	5	10	16
1551	6	1	16
1552	6	2	16
1553	6	3	16
1554	6	4	16
1555	6	5	16
1556	6	6	16
1557	6	7	16
1558	6	8	16
1559	6	9	16
1560	6	10	16
1561	7	1	16
1562	7	2	16
1563	7	3	16
1564	7	4	16
1565	7	5	16
1566	7	6	16
1567	7	7	16
1568	7	8	16
1569	7	9	16
1570	7	10	16
1571	8	1	16
1572	8	2	16
1573	8	3	16
1574	8	4	16
1575	8	5	16
1576	8	6	16
1577	8	7	16
1578	8	8	16
1579	8	9	16
1580	8	10	16
1581	9	1	16
1582	9	2	16
1583	9	3	16
1584	9	4	16
1585	9	5	16
1586	9	6	16
1587	9	7	16
1588	9	8	16
1589	9	9	16
1590	9	10	16
1591	10	1	16
1592	10	2	16
1593	10	3	16
1594	10	4	16
1595	10	5	16
1596	10	6	16
1597	10	7	16
1598	10	8	16
1599	10	9	16
1600	10	10	16
1601	1	1	17
1602	1	2	17
1603	1	3	17
1604	1	4	17
1605	1	5	17
1606	1	6	17
1607	1	7	17
1608	1	8	17
1609	1	9	17
1610	1	10	17
1611	2	1	17
1612	2	2	17
1613	2	3	17
1614	2	4	17
1615	2	5	17
1616	2	6	17
1617	2	7	17
1618	2	8	17
1619	2	9	17
1620	2	10	17
1621	3	1	17
1622	3	2	17
1623	3	3	17
1624	3	4	17
1625	3	5	17
1626	3	6	17
1627	3	7	17
1628	3	8	17
1629	3	9	17
1630	3	10	17
1631	4	1	17
1632	4	2	17
1633	4	3	17
1634	4	4	17
1635	4	5	17
1636	4	6	17
1637	4	7	17
1638	4	8	17
1639	4	9	17
1640	4	10	17
1641	5	1	17
1642	5	2	17
1643	5	3	17
1644	5	4	17
1645	5	5	17
1646	5	6	17
1647	5	7	17
1648	5	8	17
1649	5	9	17
1650	5	10	17
1651	6	1	17
1652	6	2	17
1653	6	3	17
1654	6	4	17
1655	6	5	17
1656	6	6	17
1657	6	7	17
1658	6	8	17
1659	6	9	17
1660	6	10	17
1661	7	1	17
1662	7	2	17
1663	7	3	17
1664	7	4	17
1665	7	5	17
1666	7	6	17
1667	7	7	17
1668	7	8	17
1669	7	9	17
1670	7	10	17
1671	8	1	17
1672	8	2	17
1673	8	3	17
1674	8	4	17
1675	8	5	17
1676	8	6	17
1677	8	7	17
1678	8	8	17
1679	8	9	17
1680	8	10	17
1681	9	1	17
1682	9	2	17
1683	9	3	17
1684	9	4	17
1685	9	5	17
1686	9	6	17
1687	9	7	17
1688	9	8	17
1689	9	9	17
1690	9	10	17
1691	10	1	17
1692	10	2	17
1693	10	3	17
1694	10	4	17
1695	10	5	17
1696	10	6	17
1697	10	7	17
1698	10	8	17
1699	10	9	17
1700	10	10	17
1701	1	1	18
1702	1	2	18
1703	1	3	18
1704	1	4	18
1705	1	5	18
1706	1	6	18
1707	1	7	18
1708	1	8	18
1709	1	9	18
1710	1	10	18
1711	2	1	18
1712	2	2	18
1713	2	3	18
1714	2	4	18
1715	2	5	18
1716	2	6	18
1717	2	7	18
1718	2	8	18
1719	2	9	18
1720	2	10	18
1721	3	1	18
1722	3	2	18
1723	3	3	18
1724	3	4	18
1725	3	5	18
1726	3	6	18
1727	3	7	18
1728	3	8	18
1729	3	9	18
1730	3	10	18
1731	4	1	18
1732	4	2	18
1733	4	3	18
1734	4	4	18
1735	4	5	18
1736	4	6	18
1737	4	7	18
1738	4	8	18
1739	4	9	18
1740	4	10	18
1741	5	1	18
1742	5	2	18
1743	5	3	18
1744	5	4	18
1745	5	5	18
1746	5	6	18
1747	5	7	18
1748	5	8	18
1749	5	9	18
1750	5	10	18
1751	6	1	18
1752	6	2	18
1753	6	3	18
1754	6	4	18
1755	6	5	18
1756	6	6	18
1757	6	7	18
1758	6	8	18
1759	6	9	18
1760	6	10	18
1761	7	1	18
1762	7	2	18
1763	7	3	18
1764	7	4	18
1765	7	5	18
1766	7	6	18
1767	7	7	18
1768	7	8	18
1769	7	9	18
1770	7	10	18
1771	8	1	18
1772	8	2	18
1773	8	3	18
1774	8	4	18
1775	8	5	18
1776	8	6	18
1777	8	7	18
1778	8	8	18
1779	8	9	18
1780	8	10	18
1781	9	1	18
1782	9	2	18
1783	9	3	18
1784	9	4	18
1785	9	5	18
1786	9	6	18
1787	9	7	18
1788	9	8	18
1789	9	9	18
1790	9	10	18
1791	10	1	18
1792	10	2	18
1793	10	3	18
1794	10	4	18
1795	10	5	18
1796	10	6	18
1797	10	7	18
1798	10	8	18
1799	10	9	18
1800	10	10	18
1801	1	1	19
1802	1	2	19
1803	1	3	19
1804	1	4	19
1805	1	5	19
1806	1	6	19
1807	1	7	19
1808	1	8	19
1809	1	9	19
1810	1	10	19
1811	2	1	19
1812	2	2	19
1813	2	3	19
1814	2	4	19
1815	2	5	19
1816	2	6	19
1817	2	7	19
1818	2	8	19
1819	2	9	19
1820	2	10	19
1821	3	1	19
1822	3	2	19
1823	3	3	19
1824	3	4	19
1825	3	5	19
1826	3	6	19
1827	3	7	19
1828	3	8	19
1829	3	9	19
1830	3	10	19
1831	4	1	19
1832	4	2	19
1833	4	3	19
1834	4	4	19
1835	4	5	19
1836	4	6	19
1837	4	7	19
1838	4	8	19
1839	4	9	19
1840	4	10	19
1841	5	1	19
1842	5	2	19
1843	5	3	19
1844	5	4	19
1845	5	5	19
1846	5	6	19
1847	5	7	19
1848	5	8	19
1849	5	9	19
1850	5	10	19
1851	6	1	19
1852	6	2	19
1853	6	3	19
1854	6	4	19
1855	6	5	19
1856	6	6	19
1857	6	7	19
1858	6	8	19
1859	6	9	19
1860	6	10	19
1861	7	1	19
1862	7	2	19
1863	7	3	19
1864	7	4	19
1865	7	5	19
1866	7	6	19
1867	7	7	19
1868	7	8	19
1869	7	9	19
1870	7	10	19
1871	8	1	19
1872	8	2	19
1873	8	3	19
1874	8	4	19
1875	8	5	19
1876	8	6	19
1877	8	7	19
1878	8	8	19
1879	8	9	19
1880	8	10	19
1881	9	1	19
1882	9	2	19
1883	9	3	19
1884	9	4	19
1885	9	5	19
1886	9	6	19
1887	9	7	19
1888	9	8	19
1889	9	9	19
1890	9	10	19
1891	10	1	19
1892	10	2	19
1893	10	3	19
1894	10	4	19
1895	10	5	19
1896	10	6	19
1897	10	7	19
1898	10	8	19
1899	10	9	19
1900	10	10	19
1901	1	1	20
1902	1	2	20
1903	1	3	20
1904	1	4	20
1905	1	5	20
1906	1	6	20
1907	1	7	20
1908	1	8	20
1909	1	9	20
1910	1	10	20
1911	2	1	20
1912	2	2	20
1913	2	3	20
1914	2	4	20
1915	2	5	20
1916	2	6	20
1917	2	7	20
1918	2	8	20
1919	2	9	20
1920	2	10	20
1921	3	1	20
1922	3	2	20
1923	3	3	20
1924	3	4	20
1925	3	5	20
1926	3	6	20
1927	3	7	20
1928	3	8	20
1929	3	9	20
1930	3	10	20
1931	4	1	20
1932	4	2	20
1933	4	3	20
1934	4	4	20
1935	4	5	20
1936	4	6	20
1937	4	7	20
1938	4	8	20
1939	4	9	20
1940	4	10	20
1941	5	1	20
1942	5	2	20
1943	5	3	20
1944	5	4	20
1945	5	5	20
1946	5	6	20
1947	5	7	20
1948	5	8	20
1949	5	9	20
1950	5	10	20
1951	6	1	20
1952	6	2	20
1953	6	3	20
1954	6	4	20
1955	6	5	20
1956	6	6	20
1957	6	7	20
1958	6	8	20
1959	6	9	20
1960	6	10	20
1961	7	1	20
1962	7	2	20
1963	7	3	20
1964	7	4	20
1965	7	5	20
1966	7	6	20
1967	7	7	20
1968	7	8	20
1969	7	9	20
1970	7	10	20
1971	8	1	20
1972	8	2	20
1973	8	3	20
1974	8	4	20
1975	8	5	20
1976	8	6	20
1977	8	7	20
1978	8	8	20
1979	8	9	20
1980	8	10	20
1981	9	1	20
1982	9	2	20
1983	9	3	20
1984	9	4	20
1985	9	5	20
1986	9	6	20
1987	9	7	20
1988	9	8	20
1989	9	9	20
1990	9	10	20
1991	10	1	20
1992	10	2	20
1993	10	3	20
1994	10	4	20
1995	10	5	20
1996	10	6	20
1997	10	7	20
1998	10	8	20
1999	10	9	20
2000	10	10	20
2001	1	1	21
2002	1	2	21
2003	1	3	21
2004	1	4	21
2005	1	5	21
2006	1	6	21
2007	1	7	21
2008	1	8	21
2009	1	9	21
2010	1	10	21
2011	2	1	21
2012	2	2	21
2013	2	3	21
2014	2	4	21
2015	2	5	21
2016	2	6	21
2017	2	7	21
2018	2	8	21
2019	2	9	21
2020	2	10	21
2021	3	1	21
2022	3	2	21
2023	3	3	21
2024	3	4	21
2025	3	5	21
2026	3	6	21
2027	3	7	21
2028	3	8	21
2029	3	9	21
2030	3	10	21
2031	4	1	21
2032	4	2	21
2033	4	3	21
2034	4	4	21
2035	4	5	21
2036	4	6	21
2037	4	7	21
2038	4	8	21
2039	4	9	21
2040	4	10	21
2041	5	1	21
2042	5	2	21
2043	5	3	21
2044	5	4	21
2045	5	5	21
2046	5	6	21
2047	5	7	21
2048	5	8	21
2049	5	9	21
2050	5	10	21
2051	6	1	21
2052	6	2	21
2053	6	3	21
2054	6	4	21
2055	6	5	21
2056	6	6	21
2057	6	7	21
2058	6	8	21
2059	6	9	21
2060	6	10	21
2061	7	1	21
2062	7	2	21
2063	7	3	21
2064	7	4	21
2065	7	5	21
2066	7	6	21
2067	7	7	21
2068	7	8	21
2069	7	9	21
2070	7	10	21
2071	8	1	21
2072	8	2	21
2073	8	3	21
2074	8	4	21
2075	8	5	21
2076	8	6	21
2077	8	7	21
2078	8	8	21
2079	8	9	21
2080	8	10	21
2081	9	1	21
2082	9	2	21
2083	9	3	21
2084	9	4	21
2085	9	5	21
2086	9	6	21
2087	9	7	21
2088	9	8	21
2089	9	9	21
2090	9	10	21
2091	10	1	21
2092	10	2	21
2093	10	3	21
2094	10	4	21
2095	10	5	21
2096	10	6	21
2097	10	7	21
2098	10	8	21
2099	10	9	21
2100	10	10	21
2101	1	1	22
2102	1	2	22
2103	1	3	22
2104	1	4	22
2105	1	5	22
2106	1	6	22
2107	1	7	22
2108	1	8	22
2109	1	9	22
2110	1	10	22
2111	2	1	22
2112	2	2	22
2113	2	3	22
2114	2	4	22
2115	2	5	22
2116	2	6	22
2117	2	7	22
2118	2	8	22
2119	2	9	22
2120	2	10	22
2121	3	1	22
2122	3	2	22
2123	3	3	22
2124	3	4	22
2125	3	5	22
2126	3	6	22
2127	3	7	22
2128	3	8	22
2129	3	9	22
2130	3	10	22
2131	4	1	22
2132	4	2	22
2133	4	3	22
2134	4	4	22
2135	4	5	22
2136	4	6	22
2137	4	7	22
2138	4	8	22
2139	4	9	22
2140	4	10	22
2141	5	1	22
2142	5	2	22
2143	5	3	22
2144	5	4	22
2145	5	5	22
2146	5	6	22
2147	5	7	22
2148	5	8	22
2149	5	9	22
2150	5	10	22
2151	6	1	22
2152	6	2	22
2153	6	3	22
2154	6	4	22
2155	6	5	22
2156	6	6	22
2157	6	7	22
2158	6	8	22
2159	6	9	22
2160	6	10	22
2161	7	1	22
2162	7	2	22
2163	7	3	22
2164	7	4	22
2165	7	5	22
2166	7	6	22
2167	7	7	22
2168	7	8	22
2169	7	9	22
2170	7	10	22
2171	8	1	22
2172	8	2	22
2173	8	3	22
2174	8	4	22
2175	8	5	22
2176	8	6	22
2177	8	7	22
2178	8	8	22
2179	8	9	22
2180	8	10	22
2181	9	1	22
2182	9	2	22
2183	9	3	22
2184	9	4	22
2185	9	5	22
2186	9	6	22
2187	9	7	22
2188	9	8	22
2189	9	9	22
2190	9	10	22
2191	10	1	22
2192	10	2	22
2193	10	3	22
2194	10	4	22
2195	10	5	22
2196	10	6	22
2197	10	7	22
2198	10	8	22
2199	10	9	22
2200	10	10	22
2201	1	1	23
2202	1	2	23
2203	1	3	23
2204	1	4	23
2205	1	5	23
2206	1	6	23
2207	1	7	23
2208	1	8	23
2209	1	9	23
2210	1	10	23
2211	2	1	23
2212	2	2	23
2213	2	3	23
2214	2	4	23
2215	2	5	23
2216	2	6	23
2217	2	7	23
2218	2	8	23
2219	2	9	23
2220	2	10	23
2221	3	1	23
2222	3	2	23
2223	3	3	23
2224	3	4	23
2225	3	5	23
2226	3	6	23
2227	3	7	23
2228	3	8	23
2229	3	9	23
2230	3	10	23
2231	4	1	23
2232	4	2	23
2233	4	3	23
2234	4	4	23
2235	4	5	23
2236	4	6	23
2237	4	7	23
2238	4	8	23
2239	4	9	23
2240	4	10	23
2241	5	1	23
2242	5	2	23
2243	5	3	23
2244	5	4	23
2245	5	5	23
2246	5	6	23
2247	5	7	23
2248	5	8	23
2249	5	9	23
2250	5	10	23
2251	6	1	23
2252	6	2	23
2253	6	3	23
2254	6	4	23
2255	6	5	23
2256	6	6	23
2257	6	7	23
2258	6	8	23
2259	6	9	23
2260	6	10	23
2261	7	1	23
2262	7	2	23
2263	7	3	23
2264	7	4	23
2265	7	5	23
2266	7	6	23
2267	7	7	23
2268	7	8	23
2269	7	9	23
2270	7	10	23
2271	8	1	23
2272	8	2	23
2273	8	3	23
2274	8	4	23
2275	8	5	23
2276	8	6	23
2277	8	7	23
2278	8	8	23
2279	8	9	23
2280	8	10	23
2281	9	1	23
2282	9	2	23
2283	9	3	23
2284	9	4	23
2285	9	5	23
2286	9	6	23
2287	9	7	23
2288	9	8	23
2289	9	9	23
2290	9	10	23
2291	10	1	23
2292	10	2	23
2293	10	3	23
2294	10	4	23
2295	10	5	23
2296	10	6	23
2297	10	7	23
2298	10	8	23
2299	10	9	23
2300	10	10	23
2301	1	1	24
2302	1	2	24
2303	1	3	24
2304	1	4	24
2305	1	5	24
2306	1	6	24
2307	1	7	24
2308	1	8	24
2309	1	9	24
2310	1	10	24
2311	2	1	24
2312	2	2	24
2313	2	3	24
2314	2	4	24
2315	2	5	24
2316	2	6	24
2317	2	7	24
2318	2	8	24
2319	2	9	24
2320	2	10	24
2321	3	1	24
2322	3	2	24
2323	3	3	24
2324	3	4	24
2325	3	5	24
2326	3	6	24
2327	3	7	24
2328	3	8	24
2329	3	9	24
2330	3	10	24
2331	4	1	24
2332	4	2	24
2333	4	3	24
2334	4	4	24
2335	4	5	24
2336	4	6	24
2337	4	7	24
2338	4	8	24
2339	4	9	24
2340	4	10	24
2341	5	1	24
2342	5	2	24
2343	5	3	24
2344	5	4	24
2345	5	5	24
2346	5	6	24
2347	5	7	24
2348	5	8	24
2349	5	9	24
2350	5	10	24
2351	6	1	24
2352	6	2	24
2353	6	3	24
2354	6	4	24
2355	6	5	24
2356	6	6	24
2357	6	7	24
2358	6	8	24
2359	6	9	24
2360	6	10	24
2361	7	1	24
2362	7	2	24
2363	7	3	24
2364	7	4	24
2365	7	5	24
2366	7	6	24
2367	7	7	24
2368	7	8	24
2369	7	9	24
2370	7	10	24
2371	8	1	24
2372	8	2	24
2373	8	3	24
2374	8	4	24
2375	8	5	24
2376	8	6	24
2377	8	7	24
2378	8	8	24
2379	8	9	24
2380	8	10	24
2381	9	1	24
2382	9	2	24
2383	9	3	24
2384	9	4	24
2385	9	5	24
2386	9	6	24
2387	9	7	24
2388	9	8	24
2389	9	9	24
2390	9	10	24
2391	10	1	24
2392	10	2	24
2393	10	3	24
2394	10	4	24
2395	10	5	24
2396	10	6	24
2397	10	7	24
2398	10	8	24
2399	10	9	24
2400	10	10	24
2401	1	1	25
2402	1	2	25
2403	1	3	25
2404	1	4	25
2405	1	5	25
2406	1	6	25
2407	1	7	25
2408	1	8	25
2409	1	9	25
2410	1	10	25
2411	2	1	25
2412	2	2	25
2413	2	3	25
2414	2	4	25
2415	2	5	25
2416	2	6	25
2417	2	7	25
2418	2	8	25
2419	2	9	25
2420	2	10	25
2421	3	1	25
2422	3	2	25
2423	3	3	25
2424	3	4	25
2425	3	5	25
2426	3	6	25
2427	3	7	25
2428	3	8	25
2429	3	9	25
2430	3	10	25
2431	4	1	25
2432	4	2	25
2433	4	3	25
2434	4	4	25
2435	4	5	25
2436	4	6	25
2437	4	7	25
2438	4	8	25
2439	4	9	25
2440	4	10	25
2441	5	1	25
2442	5	2	25
2443	5	3	25
2444	5	4	25
2445	5	5	25
2446	5	6	25
2447	5	7	25
2448	5	8	25
2449	5	9	25
2450	5	10	25
2451	6	1	25
2452	6	2	25
2453	6	3	25
2454	6	4	25
2455	6	5	25
2456	6	6	25
2457	6	7	25
2458	6	8	25
2459	6	9	25
2460	6	10	25
2461	7	1	25
2462	7	2	25
2463	7	3	25
2464	7	4	25
2465	7	5	25
2466	7	6	25
2467	7	7	25
2468	7	8	25
2469	7	9	25
2470	7	10	25
2471	8	1	25
2472	8	2	25
2473	8	3	25
2474	8	4	25
2475	8	5	25
2476	8	6	25
2477	8	7	25
2478	8	8	25
2479	8	9	25
2480	8	10	25
2481	9	1	25
2482	9	2	25
2483	9	3	25
2484	9	4	25
2485	9	5	25
2486	9	6	25
2487	9	7	25
2488	9	8	25
2489	9	9	25
2490	9	10	25
2491	10	1	25
2492	10	2	25
2493	10	3	25
2494	10	4	25
2495	10	5	25
2496	10	6	25
2497	10	7	25
2498	10	8	25
2499	10	9	25
2500	10	10	25
2501	1	1	26
2502	1	2	26
2503	1	3	26
2504	1	4	26
2505	1	5	26
2506	1	6	26
2507	1	7	26
2508	1	8	26
2509	1	9	26
2510	1	10	26
2511	2	1	26
2512	2	2	26
2513	2	3	26
2514	2	4	26
2515	2	5	26
2516	2	6	26
2517	2	7	26
2518	2	8	26
2519	2	9	26
2520	2	10	26
2521	3	1	26
2522	3	2	26
2523	3	3	26
2524	3	4	26
2525	3	5	26
2526	3	6	26
2527	3	7	26
2528	3	8	26
2529	3	9	26
2530	3	10	26
2531	4	1	26
2532	4	2	26
2533	4	3	26
2534	4	4	26
2535	4	5	26
2536	4	6	26
2537	4	7	26
2538	4	8	26
2539	4	9	26
2540	4	10	26
2541	5	1	26
2542	5	2	26
2543	5	3	26
2544	5	4	26
2545	5	5	26
2546	5	6	26
2547	5	7	26
2548	5	8	26
2549	5	9	26
2550	5	10	26
2551	6	1	26
2552	6	2	26
2553	6	3	26
2554	6	4	26
2555	6	5	26
2556	6	6	26
2557	6	7	26
2558	6	8	26
2559	6	9	26
2560	6	10	26
2561	7	1	26
2562	7	2	26
2563	7	3	26
2564	7	4	26
2565	7	5	26
2566	7	6	26
2567	7	7	26
2568	7	8	26
2569	7	9	26
2570	7	10	26
2571	8	1	26
2572	8	2	26
2573	8	3	26
2574	8	4	26
2575	8	5	26
2576	8	6	26
2577	8	7	26
2578	8	8	26
2579	8	9	26
2580	8	10	26
2581	9	1	26
2582	9	2	26
2583	9	3	26
2584	9	4	26
2585	9	5	26
2586	9	6	26
2587	9	7	26
2588	9	8	26
2589	9	9	26
2590	9	10	26
2591	10	1	26
2592	10	2	26
2593	10	3	26
2594	10	4	26
2595	10	5	26
2596	10	6	26
2597	10	7	26
2598	10	8	26
2599	10	9	26
2600	10	10	26
2601	1	1	27
2602	1	2	27
2603	1	3	27
2604	1	4	27
2605	1	5	27
2606	1	6	27
2607	1	7	27
2608	1	8	27
2609	1	9	27
2610	1	10	27
2611	2	1	27
2612	2	2	27
2613	2	3	27
2614	2	4	27
2615	2	5	27
2616	2	6	27
2617	2	7	27
2618	2	8	27
2619	2	9	27
2620	2	10	27
2621	3	1	27
2622	3	2	27
2623	3	3	27
2624	3	4	27
2625	3	5	27
2626	3	6	27
2627	3	7	27
2628	3	8	27
2629	3	9	27
2630	3	10	27
2631	4	1	27
2632	4	2	27
2633	4	3	27
2634	4	4	27
2635	4	5	27
2636	4	6	27
2637	4	7	27
2638	4	8	27
2639	4	9	27
2640	4	10	27
2641	5	1	27
2642	5	2	27
2643	5	3	27
2644	5	4	27
2645	5	5	27
2646	5	6	27
2647	5	7	27
2648	5	8	27
2649	5	9	27
2650	5	10	27
2651	6	1	27
2652	6	2	27
2653	6	3	27
2654	6	4	27
2655	6	5	27
2656	6	6	27
2657	6	7	27
2658	6	8	27
2659	6	9	27
2660	6	10	27
2661	7	1	27
2662	7	2	27
2663	7	3	27
2664	7	4	27
2665	7	5	27
2666	7	6	27
2667	7	7	27
2668	7	8	27
2669	7	9	27
2670	7	10	27
2671	8	1	27
2672	8	2	27
2673	8	3	27
2674	8	4	27
2675	8	5	27
2676	8	6	27
2677	8	7	27
2678	8	8	27
2679	8	9	27
2680	8	10	27
2681	9	1	27
2682	9	2	27
2683	9	3	27
2684	9	4	27
2685	9	5	27
2686	9	6	27
2687	9	7	27
2688	9	8	27
2689	9	9	27
2690	9	10	27
2691	10	1	27
2692	10	2	27
2693	10	3	27
2694	10	4	27
2695	10	5	27
2696	10	6	27
2697	10	7	27
2698	10	8	27
2699	10	9	27
2700	10	10	27
2701	1	1	28
2702	1	2	28
2703	1	3	28
2704	1	4	28
2705	1	5	28
2706	1	6	28
2707	1	7	28
2708	1	8	28
2709	1	9	28
2710	1	10	28
2711	2	1	28
2712	2	2	28
2713	2	3	28
2714	2	4	28
2715	2	5	28
2716	2	6	28
2717	2	7	28
2718	2	8	28
2719	2	9	28
2720	2	10	28
2721	3	1	28
2722	3	2	28
2723	3	3	28
2724	3	4	28
2725	3	5	28
2726	3	6	28
2727	3	7	28
2728	3	8	28
2729	3	9	28
2730	3	10	28
2731	4	1	28
2732	4	2	28
2733	4	3	28
2734	4	4	28
2735	4	5	28
2736	4	6	28
2737	4	7	28
2738	4	8	28
2739	4	9	28
2740	4	10	28
2741	5	1	28
2742	5	2	28
2743	5	3	28
2744	5	4	28
2745	5	5	28
2746	5	6	28
2747	5	7	28
2748	5	8	28
2749	5	9	28
2750	5	10	28
2751	6	1	28
2752	6	2	28
2753	6	3	28
2754	6	4	28
2755	6	5	28
2756	6	6	28
2757	6	7	28
2758	6	8	28
2759	6	9	28
2760	6	10	28
2761	7	1	28
2762	7	2	28
2763	7	3	28
2764	7	4	28
2765	7	5	28
2766	7	6	28
2767	7	7	28
2768	7	8	28
2769	7	9	28
2770	7	10	28
2771	8	1	28
2772	8	2	28
2773	8	3	28
2774	8	4	28
2775	8	5	28
2776	8	6	28
2777	8	7	28
2778	8	8	28
2779	8	9	28
2780	8	10	28
2781	9	1	28
2782	9	2	28
2783	9	3	28
2784	9	4	28
2785	9	5	28
2786	9	6	28
2787	9	7	28
2788	9	8	28
2789	9	9	28
2790	9	10	28
2791	10	1	28
2792	10	2	28
2793	10	3	28
2794	10	4	28
2795	10	5	28
2796	10	6	28
2797	10	7	28
2798	10	8	28
2799	10	9	28
2800	10	10	28
2801	1	1	29
2802	1	2	29
2803	1	3	29
2804	1	4	29
2805	1	5	29
2806	1	6	29
2807	1	7	29
2808	1	8	29
2809	1	9	29
2810	1	10	29
2811	2	1	29
2812	2	2	29
2813	2	3	29
2814	2	4	29
2815	2	5	29
2816	2	6	29
2817	2	7	29
2818	2	8	29
2819	2	9	29
2820	2	10	29
2821	3	1	29
2822	3	2	29
2823	3	3	29
2824	3	4	29
2825	3	5	29
2826	3	6	29
2827	3	7	29
2828	3	8	29
2829	3	9	29
2830	3	10	29
2831	4	1	29
2832	4	2	29
2833	4	3	29
2834	4	4	29
2835	4	5	29
2836	4	6	29
2837	4	7	29
2838	4	8	29
2839	4	9	29
2840	4	10	29
2841	5	1	29
2842	5	2	29
2843	5	3	29
2844	5	4	29
2845	5	5	29
2846	5	6	29
2847	5	7	29
2848	5	8	29
2849	5	9	29
2850	5	10	29
2851	6	1	29
2852	6	2	29
2853	6	3	29
2854	6	4	29
2855	6	5	29
2856	6	6	29
2857	6	7	29
2858	6	8	29
2859	6	9	29
2860	6	10	29
2861	7	1	29
2862	7	2	29
2863	7	3	29
2864	7	4	29
2865	7	5	29
2866	7	6	29
2867	7	7	29
2868	7	8	29
2869	7	9	29
2870	7	10	29
2871	8	1	29
2872	8	2	29
2873	8	3	29
2874	8	4	29
2875	8	5	29
2876	8	6	29
2877	8	7	29
2878	8	8	29
2879	8	9	29
2880	8	10	29
2881	9	1	29
2882	9	2	29
2883	9	3	29
2884	9	4	29
2885	9	5	29
2886	9	6	29
2887	9	7	29
2888	9	8	29
2889	9	9	29
2890	9	10	29
2891	10	1	29
2892	10	2	29
2893	10	3	29
2894	10	4	29
2895	10	5	29
2896	10	6	29
2897	10	7	29
2898	10	8	29
2899	10	9	29
2900	10	10	29
2901	1	1	30
2902	1	2	30
2903	1	3	30
2904	1	4	30
2905	1	5	30
2906	1	6	30
2907	1	7	30
2908	1	8	30
2909	1	9	30
2910	1	10	30
2911	2	1	30
2912	2	2	30
2913	2	3	30
2914	2	4	30
2915	2	5	30
2916	2	6	30
2917	2	7	30
2918	2	8	30
2919	2	9	30
2920	2	10	30
2921	3	1	30
2922	3	2	30
2923	3	3	30
2924	3	4	30
2925	3	5	30
2926	3	6	30
2927	3	7	30
2928	3	8	30
2929	3	9	30
2930	3	10	30
2931	4	1	30
2932	4	2	30
2933	4	3	30
2934	4	4	30
2935	4	5	30
2936	4	6	30
2937	4	7	30
2938	4	8	30
2939	4	9	30
2940	4	10	30
2941	5	1	30
2942	5	2	30
2943	5	3	30
2944	5	4	30
2945	5	5	30
2946	5	6	30
2947	5	7	30
2948	5	8	30
2949	5	9	30
2950	5	10	30
2951	6	1	30
2952	6	2	30
2953	6	3	30
2954	6	4	30
2955	6	5	30
2956	6	6	30
2957	6	7	30
2958	6	8	30
2959	6	9	30
2960	6	10	30
2961	7	1	30
2962	7	2	30
2963	7	3	30
2964	7	4	30
2965	7	5	30
2966	7	6	30
2967	7	7	30
2968	7	8	30
2969	7	9	30
2970	7	10	30
2971	8	1	30
2972	8	2	30
2973	8	3	30
2974	8	4	30
2975	8	5	30
2976	8	6	30
2977	8	7	30
2978	8	8	30
2979	8	9	30
2980	8	10	30
2981	9	1	30
2982	9	2	30
2983	9	3	30
2984	9	4	30
2985	9	5	30
2986	9	6	30
2987	9	7	30
2988	9	8	30
2989	9	9	30
2990	9	10	30
2991	10	1	30
2992	10	2	30
2993	10	3	30
2994	10	4	30
2995	10	5	30
2996	10	6	30
2997	10	7	30
2998	10	8	30
2999	10	9	30
3000	10	10	30
3001	1	1	31
3002	1	2	31
3003	1	3	31
3004	1	4	31
3005	1	5	31
3006	1	6	31
3007	1	7	31
3008	1	8	31
3009	1	9	31
3010	1	10	31
3011	2	1	31
3012	2	2	31
3013	2	3	31
3014	2	4	31
3015	2	5	31
3016	2	6	31
3017	2	7	31
3018	2	8	31
3019	2	9	31
3020	2	10	31
3021	3	1	31
3022	3	2	31
3023	3	3	31
3024	3	4	31
3025	3	5	31
3026	3	6	31
3027	3	7	31
3028	3	8	31
3029	3	9	31
3030	3	10	31
3031	4	1	31
3032	4	2	31
3033	4	3	31
3034	4	4	31
3035	4	5	31
3036	4	6	31
3037	4	7	31
3038	4	8	31
3039	4	9	31
3040	4	10	31
3041	5	1	31
3042	5	2	31
3043	5	3	31
3044	5	4	31
3045	5	5	31
3046	5	6	31
3047	5	7	31
3048	5	8	31
3049	5	9	31
3050	5	10	31
3051	6	1	31
3052	6	2	31
3053	6	3	31
3054	6	4	31
3055	6	5	31
3056	6	6	31
3057	6	7	31
3058	6	8	31
3059	6	9	31
3060	6	10	31
3061	7	1	31
3062	7	2	31
3063	7	3	31
3064	7	4	31
3065	7	5	31
3066	7	6	31
3067	7	7	31
3068	7	8	31
3069	7	9	31
3070	7	10	31
3071	8	1	31
3072	8	2	31
3073	8	3	31
3074	8	4	31
3075	8	5	31
3076	8	6	31
3077	8	7	31
3078	8	8	31
3079	8	9	31
3080	8	10	31
3081	9	1	31
3082	9	2	31
3083	9	3	31
3084	9	4	31
3085	9	5	31
3086	9	6	31
3087	9	7	31
3088	9	8	31
3089	9	9	31
3090	9	10	31
3091	10	1	31
3092	10	2	31
3093	10	3	31
3094	10	4	31
3095	10	5	31
3096	10	6	31
3097	10	7	31
3098	10	8	31
3099	10	9	31
3100	10	10	31
3101	1	1	32
3102	1	2	32
3103	1	3	32
3104	1	4	32
3105	1	5	32
3106	1	6	32
3107	1	7	32
3108	1	8	32
3109	1	9	32
3110	1	10	32
3111	2	1	32
3112	2	2	32
3113	2	3	32
3114	2	4	32
3115	2	5	32
3116	2	6	32
3117	2	7	32
3118	2	8	32
3119	2	9	32
3120	2	10	32
3121	3	1	32
3122	3	2	32
3123	3	3	32
3124	3	4	32
3125	3	5	32
3126	3	6	32
3127	3	7	32
3128	3	8	32
3129	3	9	32
3130	3	10	32
3131	4	1	32
3132	4	2	32
3133	4	3	32
3134	4	4	32
3135	4	5	32
3136	4	6	32
3137	4	7	32
3138	4	8	32
3139	4	9	32
3140	4	10	32
3141	5	1	32
3142	5	2	32
3143	5	3	32
3144	5	4	32
3145	5	5	32
3146	5	6	32
3147	5	7	32
3148	5	8	32
3149	5	9	32
3150	5	10	32
3151	6	1	32
3152	6	2	32
3153	6	3	32
3154	6	4	32
3155	6	5	32
3156	6	6	32
3157	6	7	32
3158	6	8	32
3159	6	9	32
3160	6	10	32
3161	7	1	32
3162	7	2	32
3163	7	3	32
3164	7	4	32
3165	7	5	32
3166	7	6	32
3167	7	7	32
3168	7	8	32
3169	7	9	32
3170	7	10	32
3171	8	1	32
3172	8	2	32
3173	8	3	32
3174	8	4	32
3175	8	5	32
3176	8	6	32
3177	8	7	32
3178	8	8	32
3179	8	9	32
3180	8	10	32
3181	9	1	32
3182	9	2	32
3183	9	3	32
3184	9	4	32
3185	9	5	32
3186	9	6	32
3187	9	7	32
3188	9	8	32
3189	9	9	32
3190	9	10	32
3191	10	1	32
3192	10	2	32
3193	10	3	32
3194	10	4	32
3195	10	5	32
3196	10	6	32
3197	10	7	32
3198	10	8	32
3199	10	9	32
3200	10	10	32
3201	1	1	33
3202	1	2	33
3203	1	3	33
3204	1	4	33
3205	1	5	33
3206	1	6	33
3207	1	7	33
3208	1	8	33
3209	1	9	33
3210	1	10	33
3211	2	1	33
3212	2	2	33
3213	2	3	33
3214	2	4	33
3215	2	5	33
3216	2	6	33
3217	2	7	33
3218	2	8	33
3219	2	9	33
3220	2	10	33
3221	3	1	33
3222	3	2	33
3223	3	3	33
3224	3	4	33
3225	3	5	33
3226	3	6	33
3227	3	7	33
3228	3	8	33
3229	3	9	33
3230	3	10	33
3231	4	1	33
3232	4	2	33
3233	4	3	33
3234	4	4	33
3235	4	5	33
3236	4	6	33
3237	4	7	33
3238	4	8	33
3239	4	9	33
3240	4	10	33
3241	5	1	33
3242	5	2	33
3243	5	3	33
3244	5	4	33
3245	5	5	33
3246	5	6	33
3247	5	7	33
3248	5	8	33
3249	5	9	33
3250	5	10	33
3251	6	1	33
3252	6	2	33
3253	6	3	33
3254	6	4	33
3255	6	5	33
3256	6	6	33
3257	6	7	33
3258	6	8	33
3259	6	9	33
3260	6	10	33
3261	7	1	33
3262	7	2	33
3263	7	3	33
3264	7	4	33
3265	7	5	33
3266	7	6	33
3267	7	7	33
3268	7	8	33
3269	7	9	33
3270	7	10	33
3271	8	1	33
3272	8	2	33
3273	8	3	33
3274	8	4	33
3275	8	5	33
3276	8	6	33
3277	8	7	33
3278	8	8	33
3279	8	9	33
3280	8	10	33
3281	9	1	33
3282	9	2	33
3283	9	3	33
3284	9	4	33
3285	9	5	33
3286	9	6	33
3287	9	7	33
3288	9	8	33
3289	9	9	33
3290	9	10	33
3291	10	1	33
3292	10	2	33
3293	10	3	33
3294	10	4	33
3295	10	5	33
3296	10	6	33
3297	10	7	33
3298	10	8	33
3299	10	9	33
3300	10	10	33
3301	1	1	34
3302	1	2	34
3303	1	3	34
3304	1	4	34
3305	1	5	34
3306	1	6	34
3307	1	7	34
3308	1	8	34
3309	1	9	34
3310	1	10	34
3311	2	1	34
3312	2	2	34
3313	2	3	34
3314	2	4	34
3315	2	5	34
3316	2	6	34
3317	2	7	34
3318	2	8	34
3319	2	9	34
3320	2	10	34
3321	3	1	34
3322	3	2	34
3323	3	3	34
3324	3	4	34
3325	3	5	34
3326	3	6	34
3327	3	7	34
3328	3	8	34
3329	3	9	34
3330	3	10	34
3331	4	1	34
3332	4	2	34
3333	4	3	34
3334	4	4	34
3335	4	5	34
3336	4	6	34
3337	4	7	34
3338	4	8	34
3339	4	9	34
3340	4	10	34
3341	5	1	34
3342	5	2	34
3343	5	3	34
3344	5	4	34
3345	5	5	34
3346	5	6	34
3347	5	7	34
3348	5	8	34
3349	5	9	34
3350	5	10	34
3351	6	1	34
3352	6	2	34
3353	6	3	34
3354	6	4	34
3355	6	5	34
3356	6	6	34
3357	6	7	34
3358	6	8	34
3359	6	9	34
3360	6	10	34
3361	7	1	34
3362	7	2	34
3363	7	3	34
3364	7	4	34
3365	7	5	34
3366	7	6	34
3367	7	7	34
3368	7	8	34
3369	7	9	34
3370	7	10	34
3371	8	1	34
3372	8	2	34
3373	8	3	34
3374	8	4	34
3375	8	5	34
3376	8	6	34
3377	8	7	34
3378	8	8	34
3379	8	9	34
3380	8	10	34
3381	9	1	34
3382	9	2	34
3383	9	3	34
3384	9	4	34
3385	9	5	34
3386	9	6	34
3387	9	7	34
3388	9	8	34
3389	9	9	34
3390	9	10	34
3391	10	1	34
3392	10	2	34
3393	10	3	34
3394	10	4	34
3395	10	5	34
3396	10	6	34
3397	10	7	34
3398	10	8	34
3399	10	9	34
3400	10	10	34
3401	1	1	35
3402	1	2	35
3403	1	3	35
3404	1	4	35
3405	1	5	35
3406	1	6	35
3407	1	7	35
3408	1	8	35
3409	1	9	35
3410	1	10	35
3411	2	1	35
3412	2	2	35
3413	2	3	35
3414	2	4	35
3415	2	5	35
3416	2	6	35
3417	2	7	35
3418	2	8	35
3419	2	9	35
3420	2	10	35
3421	3	1	35
3422	3	2	35
3423	3	3	35
3424	3	4	35
3425	3	5	35
3426	3	6	35
3427	3	7	35
3428	3	8	35
3429	3	9	35
3430	3	10	35
3431	4	1	35
3432	4	2	35
3433	4	3	35
3434	4	4	35
3435	4	5	35
3436	4	6	35
3437	4	7	35
3438	4	8	35
3439	4	9	35
3440	4	10	35
3441	5	1	35
3442	5	2	35
3443	5	3	35
3444	5	4	35
3445	5	5	35
3446	5	6	35
3447	5	7	35
3448	5	8	35
3449	5	9	35
3450	5	10	35
3451	6	1	35
3452	6	2	35
3453	6	3	35
3454	6	4	35
3455	6	5	35
3456	6	6	35
3457	6	7	35
3458	6	8	35
3459	6	9	35
3460	6	10	35
3461	7	1	35
3462	7	2	35
3463	7	3	35
3464	7	4	35
3465	7	5	35
3466	7	6	35
3467	7	7	35
3468	7	8	35
3469	7	9	35
3470	7	10	35
3471	8	1	35
3472	8	2	35
3473	8	3	35
3474	8	4	35
3475	8	5	35
3476	8	6	35
3477	8	7	35
3478	8	8	35
3479	8	9	35
3480	8	10	35
3481	9	1	35
3482	9	2	35
3483	9	3	35
3484	9	4	35
3485	9	5	35
3486	9	6	35
3487	9	7	35
3488	9	8	35
3489	9	9	35
3490	9	10	35
3491	10	1	35
3492	10	2	35
3493	10	3	35
3494	10	4	35
3495	10	5	35
3496	10	6	35
3497	10	7	35
3498	10	8	35
3499	10	9	35
3500	10	10	35
3501	1	1	36
3502	1	2	36
3503	1	3	36
3504	1	4	36
3505	1	5	36
3506	1	6	36
3507	1	7	36
3508	1	8	36
3509	1	9	36
3510	1	10	36
3511	2	1	36
3512	2	2	36
3513	2	3	36
3514	2	4	36
3515	2	5	36
3516	2	6	36
3517	2	7	36
3518	2	8	36
3519	2	9	36
3520	2	10	36
3521	3	1	36
3522	3	2	36
3523	3	3	36
3524	3	4	36
3525	3	5	36
3526	3	6	36
3527	3	7	36
3528	3	8	36
3529	3	9	36
3530	3	10	36
3531	4	1	36
3532	4	2	36
3533	4	3	36
3534	4	4	36
3535	4	5	36
3536	4	6	36
3537	4	7	36
3538	4	8	36
3539	4	9	36
3540	4	10	36
3541	5	1	36
3542	5	2	36
3543	5	3	36
3544	5	4	36
3545	5	5	36
3546	5	6	36
3547	5	7	36
3548	5	8	36
3549	5	9	36
3550	5	10	36
3551	6	1	36
3552	6	2	36
3553	6	3	36
3554	6	4	36
3555	6	5	36
3556	6	6	36
3557	6	7	36
3558	6	8	36
3559	6	9	36
3560	6	10	36
3561	7	1	36
3562	7	2	36
3563	7	3	36
3564	7	4	36
3565	7	5	36
3566	7	6	36
3567	7	7	36
3568	7	8	36
3569	7	9	36
3570	7	10	36
3571	8	1	36
3572	8	2	36
3573	8	3	36
3574	8	4	36
3575	8	5	36
3576	8	6	36
3577	8	7	36
3578	8	8	36
3579	8	9	36
3580	8	10	36
3581	9	1	36
3582	9	2	36
3583	9	3	36
3584	9	4	36
3585	9	5	36
3586	9	6	36
3587	9	7	36
3588	9	8	36
3589	9	9	36
3590	9	10	36
3591	10	1	36
3592	10	2	36
3593	10	3	36
3594	10	4	36
3595	10	5	36
3596	10	6	36
3597	10	7	36
3598	10	8	36
3599	10	9	36
3600	10	10	36
3601	1	1	37
3602	1	2	37
3603	1	3	37
3604	1	4	37
3605	1	5	37
3606	1	6	37
3607	1	7	37
3608	1	8	37
3609	1	9	37
3610	1	10	37
3611	2	1	37
3612	2	2	37
3613	2	3	37
3614	2	4	37
3615	2	5	37
3616	2	6	37
3617	2	7	37
3618	2	8	37
3619	2	9	37
3620	2	10	37
3621	3	1	37
3622	3	2	37
3623	3	3	37
3624	3	4	37
3625	3	5	37
3626	3	6	37
3627	3	7	37
3628	3	8	37
3629	3	9	37
3630	3	10	37
3631	4	1	37
3632	4	2	37
3633	4	3	37
3634	4	4	37
3635	4	5	37
3636	4	6	37
3637	4	7	37
3638	4	8	37
3639	4	9	37
3640	4	10	37
3641	5	1	37
3642	5	2	37
3643	5	3	37
3644	5	4	37
3645	5	5	37
3646	5	6	37
3647	5	7	37
3648	5	8	37
3649	5	9	37
3650	5	10	37
3651	6	1	37
3652	6	2	37
3653	6	3	37
3654	6	4	37
3655	6	5	37
3656	6	6	37
3657	6	7	37
3658	6	8	37
3659	6	9	37
3660	6	10	37
3661	7	1	37
3662	7	2	37
3663	7	3	37
3664	7	4	37
3665	7	5	37
3666	7	6	37
3667	7	7	37
3668	7	8	37
3669	7	9	37
3670	7	10	37
3671	8	1	37
3672	8	2	37
3673	8	3	37
3674	8	4	37
3675	8	5	37
3676	8	6	37
3677	8	7	37
3678	8	8	37
3679	8	9	37
3680	8	10	37
3681	9	1	37
3682	9	2	37
3683	9	3	37
3684	9	4	37
3685	9	5	37
3686	9	6	37
3687	9	7	37
3688	9	8	37
3689	9	9	37
3690	9	10	37
3691	10	1	37
3692	10	2	37
3693	10	3	37
3694	10	4	37
3695	10	5	37
3696	10	6	37
3697	10	7	37
3698	10	8	37
3699	10	9	37
3700	10	10	37
3701	1	1	38
3702	1	2	38
3703	1	3	38
3704	1	4	38
3705	1	5	38
3706	1	6	38
3707	1	7	38
3708	1	8	38
3709	1	9	38
3710	1	10	38
3711	2	1	38
3712	2	2	38
3713	2	3	38
3714	2	4	38
3715	2	5	38
3716	2	6	38
3717	2	7	38
3718	2	8	38
3719	2	9	38
3720	2	10	38
3721	3	1	38
3722	3	2	38
3723	3	3	38
3724	3	4	38
3725	3	5	38
3726	3	6	38
3727	3	7	38
3728	3	8	38
3729	3	9	38
3730	3	10	38
3731	4	1	38
3732	4	2	38
3733	4	3	38
3734	4	4	38
3735	4	5	38
3736	4	6	38
3737	4	7	38
3738	4	8	38
3739	4	9	38
3740	4	10	38
3741	5	1	38
3742	5	2	38
3743	5	3	38
3744	5	4	38
3745	5	5	38
3746	5	6	38
3747	5	7	38
3748	5	8	38
3749	5	9	38
3750	5	10	38
3751	6	1	38
3752	6	2	38
3753	6	3	38
3754	6	4	38
3755	6	5	38
3756	6	6	38
3757	6	7	38
3758	6	8	38
3759	6	9	38
3760	6	10	38
3761	7	1	38
3762	7	2	38
3763	7	3	38
3764	7	4	38
3765	7	5	38
3766	7	6	38
3767	7	7	38
3768	7	8	38
3769	7	9	38
3770	7	10	38
3771	8	1	38
3772	8	2	38
3773	8	3	38
3774	8	4	38
3775	8	5	38
3776	8	6	38
3777	8	7	38
3778	8	8	38
3779	8	9	38
3780	8	10	38
3781	9	1	38
3782	9	2	38
3783	9	3	38
3784	9	4	38
3785	9	5	38
3786	9	6	38
3787	9	7	38
3788	9	8	38
3789	9	9	38
3790	9	10	38
3791	10	1	38
3792	10	2	38
3793	10	3	38
3794	10	4	38
3795	10	5	38
3796	10	6	38
3797	10	7	38
3798	10	8	38
3799	10	9	38
3800	10	10	38
3801	1	1	39
3802	1	2	39
3803	1	3	39
3804	1	4	39
3805	1	5	39
3806	1	6	39
3807	1	7	39
3808	1	8	39
3809	1	9	39
3810	1	10	39
3811	2	1	39
3812	2	2	39
3813	2	3	39
3814	2	4	39
3815	2	5	39
3816	2	6	39
3817	2	7	39
3818	2	8	39
3819	2	9	39
3820	2	10	39
3821	3	1	39
3822	3	2	39
3823	3	3	39
3824	3	4	39
3825	3	5	39
3826	3	6	39
3827	3	7	39
3828	3	8	39
3829	3	9	39
3830	3	10	39
3831	4	1	39
3832	4	2	39
3833	4	3	39
3834	4	4	39
3835	4	5	39
3836	4	6	39
3837	4	7	39
3838	4	8	39
3839	4	9	39
3840	4	10	39
3841	5	1	39
3842	5	2	39
3843	5	3	39
3844	5	4	39
3845	5	5	39
3846	5	6	39
3847	5	7	39
3848	5	8	39
3849	5	9	39
3850	5	10	39
3851	6	1	39
3852	6	2	39
3853	6	3	39
3854	6	4	39
3855	6	5	39
3856	6	6	39
3857	6	7	39
3858	6	8	39
3859	6	9	39
3860	6	10	39
3861	7	1	39
3862	7	2	39
3863	7	3	39
3864	7	4	39
3865	7	5	39
3866	7	6	39
3867	7	7	39
3868	7	8	39
3869	7	9	39
3870	7	10	39
3871	8	1	39
3872	8	2	39
3873	8	3	39
3874	8	4	39
3875	8	5	39
3876	8	6	39
3877	8	7	39
3878	8	8	39
3879	8	9	39
3880	8	10	39
3881	9	1	39
3882	9	2	39
3883	9	3	39
3884	9	4	39
3885	9	5	39
3886	9	6	39
3887	9	7	39
3888	9	8	39
3889	9	9	39
3890	9	10	39
3891	10	1	39
3892	10	2	39
3893	10	3	39
3894	10	4	39
3895	10	5	39
3896	10	6	39
3897	10	7	39
3898	10	8	39
3899	10	9	39
3900	10	10	39
3901	1	1	40
3902	1	2	40
3903	1	3	40
3904	1	4	40
3905	1	5	40
3906	1	6	40
3907	1	7	40
3908	1	8	40
3909	1	9	40
3910	1	10	40
3911	2	1	40
3912	2	2	40
3913	2	3	40
3914	2	4	40
3915	2	5	40
3916	2	6	40
3917	2	7	40
3918	2	8	40
3919	2	9	40
3920	2	10	40
3921	3	1	40
3922	3	2	40
3923	3	3	40
3924	3	4	40
3925	3	5	40
3926	3	6	40
3927	3	7	40
3928	3	8	40
3929	3	9	40
3930	3	10	40
3931	4	1	40
3932	4	2	40
3933	4	3	40
3934	4	4	40
3935	4	5	40
3936	4	6	40
3937	4	7	40
3938	4	8	40
3939	4	9	40
3940	4	10	40
3941	5	1	40
3942	5	2	40
3943	5	3	40
3944	5	4	40
3945	5	5	40
3946	5	6	40
3947	5	7	40
3948	5	8	40
3949	5	9	40
3950	5	10	40
3951	6	1	40
3952	6	2	40
3953	6	3	40
3954	6	4	40
3955	6	5	40
3956	6	6	40
3957	6	7	40
3958	6	8	40
3959	6	9	40
3960	6	10	40
3961	7	1	40
3962	7	2	40
3963	7	3	40
3964	7	4	40
3965	7	5	40
3966	7	6	40
3967	7	7	40
3968	7	8	40
3969	7	9	40
3970	7	10	40
3971	8	1	40
3972	8	2	40
3973	8	3	40
3974	8	4	40
3975	8	5	40
3976	8	6	40
3977	8	7	40
3978	8	8	40
3979	8	9	40
3980	8	10	40
3981	9	1	40
3982	9	2	40
3983	9	3	40
3984	9	4	40
3985	9	5	40
3986	9	6	40
3987	9	7	40
3988	9	8	40
3989	9	9	40
3990	9	10	40
3991	10	1	40
3992	10	2	40
3993	10	3	40
3994	10	4	40
3995	10	5	40
3996	10	6	40
3997	10	7	40
3998	10	8	40
3999	10	9	40
4000	10	10	40
4001	1	1	41
4002	1	2	41
4003	1	3	41
4004	1	4	41
4005	1	5	41
4006	1	6	41
4007	1	7	41
4008	1	8	41
4009	1	9	41
4010	1	10	41
4011	2	1	41
4012	2	2	41
4013	2	3	41
4014	2	4	41
4015	2	5	41
4016	2	6	41
4017	2	7	41
4018	2	8	41
4019	2	9	41
4020	2	10	41
4021	3	1	41
4022	3	2	41
4023	3	3	41
4024	3	4	41
4025	3	5	41
4026	3	6	41
4027	3	7	41
4028	3	8	41
4029	3	9	41
4030	3	10	41
4031	4	1	41
4032	4	2	41
4033	4	3	41
4034	4	4	41
4035	4	5	41
4036	4	6	41
4037	4	7	41
4038	4	8	41
4039	4	9	41
4040	4	10	41
4041	5	1	41
4042	5	2	41
4043	5	3	41
4044	5	4	41
4045	5	5	41
4046	5	6	41
4047	5	7	41
4048	5	8	41
4049	5	9	41
4050	5	10	41
4051	6	1	41
4052	6	2	41
4053	6	3	41
4054	6	4	41
4055	6	5	41
4056	6	6	41
4057	6	7	41
4058	6	8	41
4059	6	9	41
4060	6	10	41
4061	7	1	41
4062	7	2	41
4063	7	3	41
4064	7	4	41
4065	7	5	41
4066	7	6	41
4067	7	7	41
4068	7	8	41
4069	7	9	41
4070	7	10	41
4071	8	1	41
4072	8	2	41
4073	8	3	41
4074	8	4	41
4075	8	5	41
4076	8	6	41
4077	8	7	41
4078	8	8	41
4079	8	9	41
4080	8	10	41
4081	9	1	41
4082	9	2	41
4083	9	3	41
4084	9	4	41
4085	9	5	41
4086	9	6	41
4087	9	7	41
4088	9	8	41
4089	9	9	41
4090	9	10	41
4091	10	1	41
4092	10	2	41
4093	10	3	41
4094	10	4	41
4095	10	5	41
4096	10	6	41
4097	10	7	41
4098	10	8	41
4099	10	9	41
4100	10	10	41
4101	1	1	42
4102	1	2	42
4103	1	3	42
4104	1	4	42
4105	1	5	42
4106	1	6	42
4107	1	7	42
4108	1	8	42
4109	1	9	42
4110	1	10	42
4111	2	1	42
4112	2	2	42
4113	2	3	42
4114	2	4	42
4115	2	5	42
4116	2	6	42
4117	2	7	42
4118	2	8	42
4119	2	9	42
4120	2	10	42
4121	3	1	42
4122	3	2	42
4123	3	3	42
4124	3	4	42
4125	3	5	42
4126	3	6	42
4127	3	7	42
4128	3	8	42
4129	3	9	42
4130	3	10	42
4131	4	1	42
4132	4	2	42
4133	4	3	42
4134	4	4	42
4135	4	5	42
4136	4	6	42
4137	4	7	42
4138	4	8	42
4139	4	9	42
4140	4	10	42
4141	5	1	42
4142	5	2	42
4143	5	3	42
4144	5	4	42
4145	5	5	42
4146	5	6	42
4147	5	7	42
4148	5	8	42
4149	5	9	42
4150	5	10	42
4151	6	1	42
4152	6	2	42
4153	6	3	42
4154	6	4	42
4155	6	5	42
4156	6	6	42
4157	6	7	42
4158	6	8	42
4159	6	9	42
4160	6	10	42
4161	7	1	42
4162	7	2	42
4163	7	3	42
4164	7	4	42
4165	7	5	42
4166	7	6	42
4167	7	7	42
4168	7	8	42
4169	7	9	42
4170	7	10	42
4171	8	1	42
4172	8	2	42
4173	8	3	42
4174	8	4	42
4175	8	5	42
4176	8	6	42
4177	8	7	42
4178	8	8	42
4179	8	9	42
4180	8	10	42
4181	9	1	42
4182	9	2	42
4183	9	3	42
4184	9	4	42
4185	9	5	42
4186	9	6	42
4187	9	7	42
4188	9	8	42
4189	9	9	42
4190	9	10	42
4191	10	1	42
4192	10	2	42
4193	10	3	42
4194	10	4	42
4195	10	5	42
4196	10	6	42
4197	10	7	42
4198	10	8	42
4199	10	9	42
4200	10	10	42
4201	1	1	43
4202	1	2	43
4203	1	3	43
4204	1	4	43
4205	1	5	43
4206	1	6	43
4207	1	7	43
4208	1	8	43
4209	1	9	43
4210	1	10	43
4211	2	1	43
4212	2	2	43
4213	2	3	43
4214	2	4	43
4215	2	5	43
4216	2	6	43
4217	2	7	43
4218	2	8	43
4219	2	9	43
4220	2	10	43
4221	3	1	43
4222	3	2	43
4223	3	3	43
4224	3	4	43
4225	3	5	43
4226	3	6	43
4227	3	7	43
4228	3	8	43
4229	3	9	43
4230	3	10	43
4231	4	1	43
4232	4	2	43
4233	4	3	43
4234	4	4	43
4235	4	5	43
4236	4	6	43
4237	4	7	43
4238	4	8	43
4239	4	9	43
4240	4	10	43
4241	5	1	43
4242	5	2	43
4243	5	3	43
4244	5	4	43
4245	5	5	43
4246	5	6	43
4247	5	7	43
4248	5	8	43
4249	5	9	43
4250	5	10	43
4251	6	1	43
4252	6	2	43
4253	6	3	43
4254	6	4	43
4255	6	5	43
4256	6	6	43
4257	6	7	43
4258	6	8	43
4259	6	9	43
4260	6	10	43
4261	7	1	43
4262	7	2	43
4263	7	3	43
4264	7	4	43
4265	7	5	43
4266	7	6	43
4267	7	7	43
4268	7	8	43
4269	7	9	43
4270	7	10	43
4271	8	1	43
4272	8	2	43
4273	8	3	43
4274	8	4	43
4275	8	5	43
4276	8	6	43
4277	8	7	43
4278	8	8	43
4279	8	9	43
4280	8	10	43
4281	9	1	43
4282	9	2	43
4283	9	3	43
4284	9	4	43
4285	9	5	43
4286	9	6	43
4287	9	7	43
4288	9	8	43
4289	9	9	43
4290	9	10	43
4291	10	1	43
4292	10	2	43
4293	10	3	43
4294	10	4	43
4295	10	5	43
4296	10	6	43
4297	10	7	43
4298	10	8	43
4299	10	9	43
4300	10	10	43
4301	1	1	44
4302	1	2	44
4303	1	3	44
4304	1	4	44
4305	1	5	44
4306	1	6	44
4307	1	7	44
4308	1	8	44
4309	1	9	44
4310	1	10	44
4311	2	1	44
4312	2	2	44
4313	2	3	44
4314	2	4	44
4315	2	5	44
4316	2	6	44
4317	2	7	44
4318	2	8	44
4319	2	9	44
4320	2	10	44
4321	3	1	44
4322	3	2	44
4323	3	3	44
4324	3	4	44
4325	3	5	44
4326	3	6	44
4327	3	7	44
4328	3	8	44
4329	3	9	44
4330	3	10	44
4331	4	1	44
4332	4	2	44
4333	4	3	44
4334	4	4	44
4335	4	5	44
4336	4	6	44
4337	4	7	44
4338	4	8	44
4339	4	9	44
4340	4	10	44
4341	5	1	44
4342	5	2	44
4343	5	3	44
4344	5	4	44
4345	5	5	44
4346	5	6	44
4347	5	7	44
4348	5	8	44
4349	5	9	44
4350	5	10	44
4351	6	1	44
4352	6	2	44
4353	6	3	44
4354	6	4	44
4355	6	5	44
4356	6	6	44
4357	6	7	44
4358	6	8	44
4359	6	9	44
4360	6	10	44
4361	7	1	44
4362	7	2	44
4363	7	3	44
4364	7	4	44
4365	7	5	44
4366	7	6	44
4367	7	7	44
4368	7	8	44
4369	7	9	44
4370	7	10	44
4371	8	1	44
4372	8	2	44
4373	8	3	44
4374	8	4	44
4375	8	5	44
4376	8	6	44
4377	8	7	44
4378	8	8	44
4379	8	9	44
4380	8	10	44
4381	9	1	44
4382	9	2	44
4383	9	3	44
4384	9	4	44
4385	9	5	44
4386	9	6	44
4387	9	7	44
4388	9	8	44
4389	9	9	44
4390	9	10	44
4391	10	1	44
4392	10	2	44
4393	10	3	44
4394	10	4	44
4395	10	5	44
4396	10	6	44
4397	10	7	44
4398	10	8	44
4399	10	9	44
4400	10	10	44
4401	1	1	45
4402	1	2	45
4403	1	3	45
4404	1	4	45
4405	1	5	45
4406	1	6	45
4407	1	7	45
4408	1	8	45
4409	1	9	45
4410	1	10	45
4411	2	1	45
4412	2	2	45
4413	2	3	45
4414	2	4	45
4415	2	5	45
4416	2	6	45
4417	2	7	45
4418	2	8	45
4419	2	9	45
4420	2	10	45
4421	3	1	45
4422	3	2	45
4423	3	3	45
4424	3	4	45
4425	3	5	45
4426	3	6	45
4427	3	7	45
4428	3	8	45
4429	3	9	45
4430	3	10	45
4431	4	1	45
4432	4	2	45
4433	4	3	45
4434	4	4	45
4435	4	5	45
4436	4	6	45
4437	4	7	45
4438	4	8	45
4439	4	9	45
4440	4	10	45
4441	5	1	45
4442	5	2	45
4443	5	3	45
4444	5	4	45
4445	5	5	45
4446	5	6	45
4447	5	7	45
4448	5	8	45
4449	5	9	45
4450	5	10	45
4451	6	1	45
4452	6	2	45
4453	6	3	45
4454	6	4	45
4455	6	5	45
4456	6	6	45
4457	6	7	45
4458	6	8	45
4459	6	9	45
4460	6	10	45
4461	7	1	45
4462	7	2	45
4463	7	3	45
4464	7	4	45
4465	7	5	45
4466	7	6	45
4467	7	7	45
4468	7	8	45
4469	7	9	45
4470	7	10	45
4471	8	1	45
4472	8	2	45
4473	8	3	45
4474	8	4	45
4475	8	5	45
4476	8	6	45
4477	8	7	45
4478	8	8	45
4479	8	9	45
4480	8	10	45
4481	9	1	45
4482	9	2	45
4483	9	3	45
4484	9	4	45
4485	9	5	45
4486	9	6	45
4487	9	7	45
4488	9	8	45
4489	9	9	45
4490	9	10	45
4491	10	1	45
4492	10	2	45
4493	10	3	45
4494	10	4	45
4495	10	5	45
4496	10	6	45
4497	10	7	45
4498	10	8	45
4499	10	9	45
4500	10	10	45
4501	1	1	46
4502	1	2	46
4503	1	3	46
4504	1	4	46
4505	1	5	46
4506	1	6	46
4507	1	7	46
4508	1	8	46
4509	1	9	46
4510	1	10	46
4511	2	1	46
4512	2	2	46
4513	2	3	46
4514	2	4	46
4515	2	5	46
4516	2	6	46
4517	2	7	46
4518	2	8	46
4519	2	9	46
4520	2	10	46
4521	3	1	46
4522	3	2	46
4523	3	3	46
4524	3	4	46
4525	3	5	46
4526	3	6	46
4527	3	7	46
4528	3	8	46
4529	3	9	46
4530	3	10	46
4531	4	1	46
4532	4	2	46
4533	4	3	46
4534	4	4	46
4535	4	5	46
4536	4	6	46
4537	4	7	46
4538	4	8	46
4539	4	9	46
4540	4	10	46
4541	5	1	46
4542	5	2	46
4543	5	3	46
4544	5	4	46
4545	5	5	46
4546	5	6	46
4547	5	7	46
4548	5	8	46
4549	5	9	46
4550	5	10	46
4551	6	1	46
4552	6	2	46
4553	6	3	46
4554	6	4	46
4555	6	5	46
4556	6	6	46
4557	6	7	46
4558	6	8	46
4559	6	9	46
4560	6	10	46
4561	7	1	46
4562	7	2	46
4563	7	3	46
4564	7	4	46
4565	7	5	46
4566	7	6	46
4567	7	7	46
4568	7	8	46
4569	7	9	46
4570	7	10	46
4571	8	1	46
4572	8	2	46
4573	8	3	46
4574	8	4	46
4575	8	5	46
4576	8	6	46
4577	8	7	46
4578	8	8	46
4579	8	9	46
4580	8	10	46
4581	9	1	46
4582	9	2	46
4583	9	3	46
4584	9	4	46
4585	9	5	46
4586	9	6	46
4587	9	7	46
4588	9	8	46
4589	9	9	46
4590	9	10	46
4591	10	1	46
4592	10	2	46
4593	10	3	46
4594	10	4	46
4595	10	5	46
4596	10	6	46
4597	10	7	46
4598	10	8	46
4599	10	9	46
4600	10	10	46
4601	1	1	47
4602	1	2	47
4603	1	3	47
4604	1	4	47
4605	1	5	47
4606	1	6	47
4607	1	7	47
4608	1	8	47
4609	1	9	47
4610	1	10	47
4611	2	1	47
4612	2	2	47
4613	2	3	47
4614	2	4	47
4615	2	5	47
4616	2	6	47
4617	2	7	47
4618	2	8	47
4619	2	9	47
4620	2	10	47
4621	3	1	47
4622	3	2	47
4623	3	3	47
4624	3	4	47
4625	3	5	47
4626	3	6	47
4627	3	7	47
4628	3	8	47
4629	3	9	47
4630	3	10	47
4631	4	1	47
4632	4	2	47
4633	4	3	47
4634	4	4	47
4635	4	5	47
4636	4	6	47
4637	4	7	47
4638	4	8	47
4639	4	9	47
4640	4	10	47
4641	5	1	47
4642	5	2	47
4643	5	3	47
4644	5	4	47
4645	5	5	47
4646	5	6	47
4647	5	7	47
4648	5	8	47
4649	5	9	47
4650	5	10	47
4651	6	1	47
4652	6	2	47
4653	6	3	47
4654	6	4	47
4655	6	5	47
4656	6	6	47
4657	6	7	47
4658	6	8	47
4659	6	9	47
4660	6	10	47
4661	7	1	47
4662	7	2	47
4663	7	3	47
4664	7	4	47
4665	7	5	47
4666	7	6	47
4667	7	7	47
4668	7	8	47
4669	7	9	47
4670	7	10	47
4671	8	1	47
4672	8	2	47
4673	8	3	47
4674	8	4	47
4675	8	5	47
4676	8	6	47
4677	8	7	47
4678	8	8	47
4679	8	9	47
4680	8	10	47
4681	9	1	47
4682	9	2	47
4683	9	3	47
4684	9	4	47
4685	9	5	47
4686	9	6	47
4687	9	7	47
4688	9	8	47
4689	9	9	47
4690	9	10	47
4691	10	1	47
4692	10	2	47
4693	10	3	47
4694	10	4	47
4695	10	5	47
4696	10	6	47
4697	10	7	47
4698	10	8	47
4699	10	9	47
4700	10	10	47
4701	1	1	48
4702	1	2	48
4703	1	3	48
4704	1	4	48
4705	1	5	48
4706	1	6	48
4707	1	7	48
4708	1	8	48
4709	1	9	48
4710	1	10	48
4711	2	1	48
4712	2	2	48
4713	2	3	48
4714	2	4	48
4715	2	5	48
4716	2	6	48
4717	2	7	48
4718	2	8	48
4719	2	9	48
4720	2	10	48
4721	3	1	48
4722	3	2	48
4723	3	3	48
4724	3	4	48
4725	3	5	48
4726	3	6	48
4727	3	7	48
4728	3	8	48
4729	3	9	48
4730	3	10	48
4731	4	1	48
4732	4	2	48
4733	4	3	48
4734	4	4	48
4735	4	5	48
4736	4	6	48
4737	4	7	48
4738	4	8	48
4739	4	9	48
4740	4	10	48
4741	5	1	48
4742	5	2	48
4743	5	3	48
4744	5	4	48
4745	5	5	48
4746	5	6	48
4747	5	7	48
4748	5	8	48
4749	5	9	48
4750	5	10	48
4751	6	1	48
4752	6	2	48
4753	6	3	48
4754	6	4	48
4755	6	5	48
4756	6	6	48
4757	6	7	48
4758	6	8	48
4759	6	9	48
4760	6	10	48
4761	7	1	48
4762	7	2	48
4763	7	3	48
4764	7	4	48
4765	7	5	48
4766	7	6	48
4767	7	7	48
4768	7	8	48
4769	7	9	48
4770	7	10	48
4771	8	1	48
4772	8	2	48
4773	8	3	48
4774	8	4	48
4775	8	5	48
4776	8	6	48
4777	8	7	48
4778	8	8	48
4779	8	9	48
4780	8	10	48
4781	9	1	48
4782	9	2	48
4783	9	3	48
4784	9	4	48
4785	9	5	48
4786	9	6	48
4787	9	7	48
4788	9	8	48
4789	9	9	48
4790	9	10	48
4791	10	1	48
4792	10	2	48
4793	10	3	48
4794	10	4	48
4795	10	5	48
4796	10	6	48
4797	10	7	48
4798	10	8	48
4799	10	9	48
4800	10	10	48
4801	1	1	49
4802	1	2	49
4803	1	3	49
4804	1	4	49
4805	1	5	49
4806	1	6	49
4807	1	7	49
4808	1	8	49
4809	1	9	49
4810	1	10	49
4811	2	1	49
4812	2	2	49
4813	2	3	49
4814	2	4	49
4815	2	5	49
4816	2	6	49
4817	2	7	49
4818	2	8	49
4819	2	9	49
4820	2	10	49
4821	3	1	49
4822	3	2	49
4823	3	3	49
4824	3	4	49
4825	3	5	49
4826	3	6	49
4827	3	7	49
4828	3	8	49
4829	3	9	49
4830	3	10	49
4831	4	1	49
4832	4	2	49
4833	4	3	49
4834	4	4	49
4835	4	5	49
4836	4	6	49
4837	4	7	49
4838	4	8	49
4839	4	9	49
4840	4	10	49
4841	5	1	49
4842	5	2	49
4843	5	3	49
4844	5	4	49
4845	5	5	49
4846	5	6	49
4847	5	7	49
4848	5	8	49
4849	5	9	49
4850	5	10	49
4851	6	1	49
4852	6	2	49
4853	6	3	49
4854	6	4	49
4855	6	5	49
4856	6	6	49
4857	6	7	49
4858	6	8	49
4859	6	9	49
4860	6	10	49
4861	7	1	49
4862	7	2	49
4863	7	3	49
4864	7	4	49
4865	7	5	49
4866	7	6	49
4867	7	7	49
4868	7	8	49
4869	7	9	49
4870	7	10	49
4871	8	1	49
4872	8	2	49
4873	8	3	49
4874	8	4	49
4875	8	5	49
4876	8	6	49
4877	8	7	49
4878	8	8	49
4879	8	9	49
4880	8	10	49
4881	9	1	49
4882	9	2	49
4883	9	3	49
4884	9	4	49
4885	9	5	49
4886	9	6	49
4887	9	7	49
4888	9	8	49
4889	9	9	49
4890	9	10	49
4891	10	1	49
4892	10	2	49
4893	10	3	49
4894	10	4	49
4895	10	5	49
4896	10	6	49
4897	10	7	49
4898	10	8	49
4899	10	9	49
4900	10	10	49
4901	1	1	50
4902	1	2	50
4903	1	3	50
4904	1	4	50
4905	1	5	50
4906	1	6	50
4907	1	7	50
4908	1	8	50
4909	1	9	50
4910	1	10	50
4911	2	1	50
4912	2	2	50
4913	2	3	50
4914	2	4	50
4915	2	5	50
4916	2	6	50
4917	2	7	50
4918	2	8	50
4919	2	9	50
4920	2	10	50
4921	3	1	50
4922	3	2	50
4923	3	3	50
4924	3	4	50
4925	3	5	50
4926	3	6	50
4927	3	7	50
4928	3	8	50
4929	3	9	50
4930	3	10	50
4931	4	1	50
4932	4	2	50
4933	4	3	50
4934	4	4	50
4935	4	5	50
4936	4	6	50
4937	4	7	50
4938	4	8	50
4939	4	9	50
4940	4	10	50
4941	5	1	50
4942	5	2	50
4943	5	3	50
4944	5	4	50
4945	5	5	50
4946	5	6	50
4947	5	7	50
4948	5	8	50
4949	5	9	50
4950	5	10	50
4951	6	1	50
4952	6	2	50
4953	6	3	50
4954	6	4	50
4955	6	5	50
4956	6	6	50
4957	6	7	50
4958	6	8	50
4959	6	9	50
4960	6	10	50
4961	7	1	50
4962	7	2	50
4963	7	3	50
4964	7	4	50
4965	7	5	50
4966	7	6	50
4967	7	7	50
4968	7	8	50
4969	7	9	50
4970	7	10	50
4971	8	1	50
4972	8	2	50
4973	8	3	50
4974	8	4	50
4975	8	5	50
4976	8	6	50
4977	8	7	50
4978	8	8	50
4979	8	9	50
4980	8	10	50
4981	9	1	50
4982	9	2	50
4983	9	3	50
4984	9	4	50
4985	9	5	50
4986	9	6	50
4987	9	7	50
4988	9	8	50
4989	9	9	50
4990	9	10	50
4991	10	1	50
4992	10	2	50
4993	10	3	50
4994	10	4	50
4995	10	5	50
4996	10	6	50
4997	10	7	50
4998	10	8	50
4999	10	9	50
5000	10	10	50
5001	1	1	51
5002	1	2	51
5003	1	3	51
5004	1	4	51
5005	1	5	51
5006	1	6	51
5007	1	7	51
5008	1	8	51
5009	1	9	51
5010	1	10	51
5011	2	1	51
5012	2	2	51
5013	2	3	51
5014	2	4	51
5015	2	5	51
5016	2	6	51
5017	2	7	51
5018	2	8	51
5019	2	9	51
5020	2	10	51
5021	3	1	51
5022	3	2	51
5023	3	3	51
5024	3	4	51
5025	3	5	51
5026	3	6	51
5027	3	7	51
5028	3	8	51
5029	3	9	51
5030	3	10	51
5031	4	1	51
5032	4	2	51
5033	4	3	51
5034	4	4	51
5035	4	5	51
5036	4	6	51
5037	4	7	51
5038	4	8	51
5039	4	9	51
5040	4	10	51
5041	5	1	51
5042	5	2	51
5043	5	3	51
5044	5	4	51
5045	5	5	51
5046	5	6	51
5047	5	7	51
5048	5	8	51
5049	5	9	51
5050	5	10	51
5051	6	1	51
5052	6	2	51
5053	6	3	51
5054	6	4	51
5055	6	5	51
5056	6	6	51
5057	6	7	51
5058	6	8	51
5059	6	9	51
5060	6	10	51
5061	7	1	51
5062	7	2	51
5063	7	3	51
5064	7	4	51
5065	7	5	51
5066	7	6	51
5067	7	7	51
5068	7	8	51
5069	7	9	51
5070	7	10	51
5071	8	1	51
5072	8	2	51
5073	8	3	51
5074	8	4	51
5075	8	5	51
5076	8	6	51
5077	8	7	51
5078	8	8	51
5079	8	9	51
5080	8	10	51
5081	9	1	51
5082	9	2	51
5083	9	3	51
5084	9	4	51
5085	9	5	51
5086	9	6	51
5087	9	7	51
5088	9	8	51
5089	9	9	51
5090	9	10	51
5091	10	1	51
5092	10	2	51
5093	10	3	51
5094	10	4	51
5095	10	5	51
5096	10	6	51
5097	10	7	51
5098	10	8	51
5099	10	9	51
5100	10	10	51
5101	1	1	52
5102	1	2	52
5103	1	3	52
5104	1	4	52
5105	1	5	52
5106	1	6	52
5107	1	7	52
5108	1	8	52
5109	1	9	52
5110	1	10	52
5111	2	1	52
5112	2	2	52
5113	2	3	52
5114	2	4	52
5115	2	5	52
5116	2	6	52
5117	2	7	52
5118	2	8	52
5119	2	9	52
5120	2	10	52
5121	3	1	52
5122	3	2	52
5123	3	3	52
5124	3	4	52
5125	3	5	52
5126	3	6	52
5127	3	7	52
5128	3	8	52
5129	3	9	52
5130	3	10	52
5131	4	1	52
5132	4	2	52
5133	4	3	52
5134	4	4	52
5135	4	5	52
5136	4	6	52
5137	4	7	52
5138	4	8	52
5139	4	9	52
5140	4	10	52
5141	5	1	52
5142	5	2	52
5143	5	3	52
5144	5	4	52
5145	5	5	52
5146	5	6	52
5147	5	7	52
5148	5	8	52
5149	5	9	52
5150	5	10	52
5151	6	1	52
5152	6	2	52
5153	6	3	52
5154	6	4	52
5155	6	5	52
5156	6	6	52
5157	6	7	52
5158	6	8	52
5159	6	9	52
5160	6	10	52
5161	7	1	52
5162	7	2	52
5163	7	3	52
5164	7	4	52
5165	7	5	52
5166	7	6	52
5167	7	7	52
5168	7	8	52
5169	7	9	52
5170	7	10	52
5171	8	1	52
5172	8	2	52
5173	8	3	52
5174	8	4	52
5175	8	5	52
5176	8	6	52
5177	8	7	52
5178	8	8	52
5179	8	9	52
5180	8	10	52
5181	9	1	52
5182	9	2	52
5183	9	3	52
5184	9	4	52
5185	9	5	52
5186	9	6	52
5187	9	7	52
5188	9	8	52
5189	9	9	52
5190	9	10	52
5191	10	1	52
5192	10	2	52
5193	10	3	52
5194	10	4	52
5195	10	5	52
5196	10	6	52
5197	10	7	52
5198	10	8	52
5199	10	9	52
5200	10	10	52
5201	1	1	53
5202	1	2	53
5203	1	3	53
5204	1	4	53
5205	1	5	53
5206	1	6	53
5207	1	7	53
5208	1	8	53
5209	1	9	53
5210	1	10	53
5211	2	1	53
5212	2	2	53
5213	2	3	53
5214	2	4	53
5215	2	5	53
5216	2	6	53
5217	2	7	53
5218	2	8	53
5219	2	9	53
5220	2	10	53
5221	3	1	53
5222	3	2	53
5223	3	3	53
5224	3	4	53
5225	3	5	53
5226	3	6	53
5227	3	7	53
5228	3	8	53
5229	3	9	53
5230	3	10	53
5231	4	1	53
5232	4	2	53
5233	4	3	53
5234	4	4	53
5235	4	5	53
5236	4	6	53
5237	4	7	53
5238	4	8	53
5239	4	9	53
5240	4	10	53
5241	5	1	53
5242	5	2	53
5243	5	3	53
5244	5	4	53
5245	5	5	53
5246	5	6	53
5247	5	7	53
5248	5	8	53
5249	5	9	53
5250	5	10	53
5251	6	1	53
5252	6	2	53
5253	6	3	53
5254	6	4	53
5255	6	5	53
5256	6	6	53
5257	6	7	53
5258	6	8	53
5259	6	9	53
5260	6	10	53
5261	7	1	53
5262	7	2	53
5263	7	3	53
5264	7	4	53
5265	7	5	53
5266	7	6	53
5267	7	7	53
5268	7	8	53
5269	7	9	53
5270	7	10	53
5271	8	1	53
5272	8	2	53
5273	8	3	53
5274	8	4	53
5275	8	5	53
5276	8	6	53
5277	8	7	53
5278	8	8	53
5279	8	9	53
5280	8	10	53
5281	9	1	53
5282	9	2	53
5283	9	3	53
5284	9	4	53
5285	9	5	53
5286	9	6	53
5287	9	7	53
5288	9	8	53
5289	9	9	53
5290	9	10	53
5291	10	1	53
5292	10	2	53
5293	10	3	53
5294	10	4	53
5295	10	5	53
5296	10	6	53
5297	10	7	53
5298	10	8	53
5299	10	9	53
5300	10	10	53
5301	1	1	54
5302	1	2	54
5303	1	3	54
5304	1	4	54
5305	1	5	54
5306	1	6	54
5307	1	7	54
5308	1	8	54
5309	1	9	54
5310	1	10	54
5311	2	1	54
5312	2	2	54
5313	2	3	54
5314	2	4	54
5315	2	5	54
5316	2	6	54
5317	2	7	54
5318	2	8	54
5319	2	9	54
5320	2	10	54
5321	3	1	54
5322	3	2	54
5323	3	3	54
5324	3	4	54
5325	3	5	54
5326	3	6	54
5327	3	7	54
5328	3	8	54
5329	3	9	54
5330	3	10	54
5331	4	1	54
5332	4	2	54
5333	4	3	54
5334	4	4	54
5335	4	5	54
5336	4	6	54
5337	4	7	54
5338	4	8	54
5339	4	9	54
5340	4	10	54
5341	5	1	54
5342	5	2	54
5343	5	3	54
5344	5	4	54
5345	5	5	54
5346	5	6	54
5347	5	7	54
5348	5	8	54
5349	5	9	54
5350	5	10	54
5351	6	1	54
5352	6	2	54
5353	6	3	54
5354	6	4	54
5355	6	5	54
5356	6	6	54
5357	6	7	54
5358	6	8	54
5359	6	9	54
5360	6	10	54
5361	7	1	54
5362	7	2	54
5363	7	3	54
5364	7	4	54
5365	7	5	54
5366	7	6	54
5367	7	7	54
5368	7	8	54
5369	7	9	54
5370	7	10	54
5371	8	1	54
5372	8	2	54
5373	8	3	54
5374	8	4	54
5375	8	5	54
5376	8	6	54
5377	8	7	54
5378	8	8	54
5379	8	9	54
5380	8	10	54
5381	9	1	54
5382	9	2	54
5383	9	3	54
5384	9	4	54
5385	9	5	54
5386	9	6	54
5387	9	7	54
5388	9	8	54
5389	9	9	54
5390	9	10	54
5391	10	1	54
5392	10	2	54
5393	10	3	54
5394	10	4	54
5395	10	5	54
5396	10	6	54
5397	10	7	54
5398	10	8	54
5399	10	9	54
5400	10	10	54
5401	1	1	55
5402	1	2	55
5403	1	3	55
5404	1	4	55
5405	1	5	55
5406	1	6	55
5407	1	7	55
5408	1	8	55
5409	1	9	55
5410	1	10	55
5411	2	1	55
5412	2	2	55
5413	2	3	55
5414	2	4	55
5415	2	5	55
5416	2	6	55
5417	2	7	55
5418	2	8	55
5419	2	9	55
5420	2	10	55
5421	3	1	55
5422	3	2	55
5423	3	3	55
5424	3	4	55
5425	3	5	55
5426	3	6	55
5427	3	7	55
5428	3	8	55
5429	3	9	55
5430	3	10	55
5431	4	1	55
5432	4	2	55
5433	4	3	55
5434	4	4	55
5435	4	5	55
5436	4	6	55
5437	4	7	55
5438	4	8	55
5439	4	9	55
5440	4	10	55
5441	5	1	55
5442	5	2	55
5443	5	3	55
5444	5	4	55
5445	5	5	55
5446	5	6	55
5447	5	7	55
5448	5	8	55
5449	5	9	55
5450	5	10	55
5451	6	1	55
5452	6	2	55
5453	6	3	55
5454	6	4	55
5455	6	5	55
5456	6	6	55
5457	6	7	55
5458	6	8	55
5459	6	9	55
5460	6	10	55
5461	7	1	55
5462	7	2	55
5463	7	3	55
5464	7	4	55
5465	7	5	55
5466	7	6	55
5467	7	7	55
5468	7	8	55
5469	7	9	55
5470	7	10	55
5471	8	1	55
5472	8	2	55
5473	8	3	55
5474	8	4	55
5475	8	5	55
5476	8	6	55
5477	8	7	55
5478	8	8	55
5479	8	9	55
5480	8	10	55
5481	9	1	55
5482	9	2	55
5483	9	3	55
5484	9	4	55
5485	9	5	55
5486	9	6	55
5487	9	7	55
5488	9	8	55
5489	9	9	55
5490	9	10	55
5491	10	1	55
5492	10	2	55
5493	10	3	55
5494	10	4	55
5495	10	5	55
5496	10	6	55
5497	10	7	55
5498	10	8	55
5499	10	9	55
5500	10	10	55
5501	1	1	56
5502	1	2	56
5503	1	3	56
5504	1	4	56
5505	1	5	56
5506	1	6	56
5507	1	7	56
5508	1	8	56
5509	1	9	56
5510	1	10	56
5511	2	1	56
5512	2	2	56
5513	2	3	56
5514	2	4	56
5515	2	5	56
5516	2	6	56
5517	2	7	56
5518	2	8	56
5519	2	9	56
5520	2	10	56
5521	3	1	56
5522	3	2	56
5523	3	3	56
5524	3	4	56
5525	3	5	56
5526	3	6	56
5527	3	7	56
5528	3	8	56
5529	3	9	56
5530	3	10	56
5531	4	1	56
5532	4	2	56
5533	4	3	56
5534	4	4	56
5535	4	5	56
5536	4	6	56
5537	4	7	56
5538	4	8	56
5539	4	9	56
5540	4	10	56
5541	5	1	56
5542	5	2	56
5543	5	3	56
5544	5	4	56
5545	5	5	56
5546	5	6	56
5547	5	7	56
5548	5	8	56
5549	5	9	56
5550	5	10	56
5551	6	1	56
5552	6	2	56
5553	6	3	56
5554	6	4	56
5555	6	5	56
5556	6	6	56
5557	6	7	56
5558	6	8	56
5559	6	9	56
5560	6	10	56
5561	7	1	56
5562	7	2	56
5563	7	3	56
5564	7	4	56
5565	7	5	56
5566	7	6	56
5567	7	7	56
5568	7	8	56
5569	7	9	56
5570	7	10	56
5571	8	1	56
5572	8	2	56
5573	8	3	56
5574	8	4	56
5575	8	5	56
5576	8	6	56
5577	8	7	56
5578	8	8	56
5579	8	9	56
5580	8	10	56
5581	9	1	56
5582	9	2	56
5583	9	3	56
5584	9	4	56
5585	9	5	56
5586	9	6	56
5587	9	7	56
5588	9	8	56
5589	9	9	56
5590	9	10	56
5591	10	1	56
5592	10	2	56
5593	10	3	56
5594	10	4	56
5595	10	5	56
5596	10	6	56
5597	10	7	56
5598	10	8	56
5599	10	9	56
5600	10	10	56
5601	1	1	57
5602	1	2	57
5603	1	3	57
5604	1	4	57
5605	1	5	57
5606	1	6	57
5607	1	7	57
5608	1	8	57
5609	1	9	57
5610	1	10	57
5611	2	1	57
5612	2	2	57
5613	2	3	57
5614	2	4	57
5615	2	5	57
5616	2	6	57
5617	2	7	57
5618	2	8	57
5619	2	9	57
5620	2	10	57
5621	3	1	57
5622	3	2	57
5623	3	3	57
5624	3	4	57
5625	3	5	57
5626	3	6	57
5627	3	7	57
5628	3	8	57
5629	3	9	57
5630	3	10	57
5631	4	1	57
5632	4	2	57
5633	4	3	57
5634	4	4	57
5635	4	5	57
5636	4	6	57
5637	4	7	57
5638	4	8	57
5639	4	9	57
5640	4	10	57
5641	5	1	57
5642	5	2	57
5643	5	3	57
5644	5	4	57
5645	5	5	57
5646	5	6	57
5647	5	7	57
5648	5	8	57
5649	5	9	57
5650	5	10	57
5651	6	1	57
5652	6	2	57
5653	6	3	57
5654	6	4	57
5655	6	5	57
5656	6	6	57
5657	6	7	57
5658	6	8	57
5659	6	9	57
5660	6	10	57
5661	7	1	57
5662	7	2	57
5663	7	3	57
5664	7	4	57
5665	7	5	57
5666	7	6	57
5667	7	7	57
5668	7	8	57
5669	7	9	57
5670	7	10	57
5671	8	1	57
5672	8	2	57
5673	8	3	57
5674	8	4	57
5675	8	5	57
5676	8	6	57
5677	8	7	57
5678	8	8	57
5679	8	9	57
5680	8	10	57
5681	9	1	57
5682	9	2	57
5683	9	3	57
5684	9	4	57
5685	9	5	57
5686	9	6	57
5687	9	7	57
5688	9	8	57
5689	9	9	57
5690	9	10	57
5691	10	1	57
5692	10	2	57
5693	10	3	57
5694	10	4	57
5695	10	5	57
5696	10	6	57
5697	10	7	57
5698	10	8	57
5699	10	9	57
5700	10	10	57
5701	1	1	58
5702	1	2	58
5703	1	3	58
5704	1	4	58
5705	1	5	58
5706	1	6	58
5707	1	7	58
5708	1	8	58
5709	1	9	58
5710	1	10	58
5711	2	1	58
5712	2	2	58
5713	2	3	58
5714	2	4	58
5715	2	5	58
5716	2	6	58
5717	2	7	58
5718	2	8	58
5719	2	9	58
5720	2	10	58
5721	3	1	58
5722	3	2	58
5723	3	3	58
5724	3	4	58
5725	3	5	58
5726	3	6	58
5727	3	7	58
5728	3	8	58
5729	3	9	58
5730	3	10	58
5731	4	1	58
5732	4	2	58
5733	4	3	58
5734	4	4	58
5735	4	5	58
5736	4	6	58
5737	4	7	58
5738	4	8	58
5739	4	9	58
5740	4	10	58
5741	5	1	58
5742	5	2	58
5743	5	3	58
5744	5	4	58
5745	5	5	58
5746	5	6	58
5747	5	7	58
5748	5	8	58
5749	5	9	58
5750	5	10	58
5751	6	1	58
5752	6	2	58
5753	6	3	58
5754	6	4	58
5755	6	5	58
5756	6	6	58
5757	6	7	58
5758	6	8	58
5759	6	9	58
5760	6	10	58
5761	7	1	58
5762	7	2	58
5763	7	3	58
5764	7	4	58
5765	7	5	58
5766	7	6	58
5767	7	7	58
5768	7	8	58
5769	7	9	58
5770	7	10	58
5771	8	1	58
5772	8	2	58
5773	8	3	58
5774	8	4	58
5775	8	5	58
5776	8	6	58
5777	8	7	58
5778	8	8	58
5779	8	9	58
5780	8	10	58
5781	9	1	58
5782	9	2	58
5783	9	3	58
5784	9	4	58
5785	9	5	58
5786	9	6	58
5787	9	7	58
5788	9	8	58
5789	9	9	58
5790	9	10	58
5791	10	1	58
5792	10	2	58
5793	10	3	58
5794	10	4	58
5795	10	5	58
5796	10	6	58
5797	10	7	58
5798	10	8	58
5799	10	9	58
5800	10	10	58
5801	1	1	59
5802	1	2	59
5803	1	3	59
5804	1	4	59
5805	1	5	59
5806	1	6	59
5807	1	7	59
5808	1	8	59
5809	1	9	59
5810	1	10	59
5811	2	1	59
5812	2	2	59
5813	2	3	59
5814	2	4	59
5815	2	5	59
5816	2	6	59
5817	2	7	59
5818	2	8	59
5819	2	9	59
5820	2	10	59
5821	3	1	59
5822	3	2	59
5823	3	3	59
5824	3	4	59
5825	3	5	59
5826	3	6	59
5827	3	7	59
5828	3	8	59
5829	3	9	59
5830	3	10	59
5831	4	1	59
5832	4	2	59
5833	4	3	59
5834	4	4	59
5835	4	5	59
5836	4	6	59
5837	4	7	59
5838	4	8	59
5839	4	9	59
5840	4	10	59
5841	5	1	59
5842	5	2	59
5843	5	3	59
5844	5	4	59
5845	5	5	59
5846	5	6	59
5847	5	7	59
5848	5	8	59
5849	5	9	59
5850	5	10	59
5851	6	1	59
5852	6	2	59
5853	6	3	59
5854	6	4	59
5855	6	5	59
5856	6	6	59
5857	6	7	59
5858	6	8	59
5859	6	9	59
5860	6	10	59
5861	7	1	59
5862	7	2	59
5863	7	3	59
5864	7	4	59
5865	7	5	59
5866	7	6	59
5867	7	7	59
5868	7	8	59
5869	7	9	59
5870	7	10	59
5871	8	1	59
5872	8	2	59
5873	8	3	59
5874	8	4	59
5875	8	5	59
5876	8	6	59
5877	8	7	59
5878	8	8	59
5879	8	9	59
5880	8	10	59
5881	9	1	59
5882	9	2	59
5883	9	3	59
5884	9	4	59
5885	9	5	59
5886	9	6	59
5887	9	7	59
5888	9	8	59
5889	9	9	59
5890	9	10	59
5891	10	1	59
5892	10	2	59
5893	10	3	59
5894	10	4	59
5895	10	5	59
5896	10	6	59
5897	10	7	59
5898	10	8	59
5899	10	9	59
5900	10	10	59
5901	1	1	60
5902	1	2	60
5903	1	3	60
5904	1	4	60
5905	1	5	60
5906	1	6	60
5907	1	7	60
5908	1	8	60
5909	1	9	60
5910	1	10	60
5911	2	1	60
5912	2	2	60
5913	2	3	60
5914	2	4	60
5915	2	5	60
5916	2	6	60
5917	2	7	60
5918	2	8	60
5919	2	9	60
5920	2	10	60
5921	3	1	60
5922	3	2	60
5923	3	3	60
5924	3	4	60
5925	3	5	60
5926	3	6	60
5927	3	7	60
5928	3	8	60
5929	3	9	60
5930	3	10	60
5931	4	1	60
5932	4	2	60
5933	4	3	60
5934	4	4	60
5935	4	5	60
5936	4	6	60
5937	4	7	60
5938	4	8	60
5939	4	9	60
5940	4	10	60
5941	5	1	60
5942	5	2	60
5943	5	3	60
5944	5	4	60
5945	5	5	60
5946	5	6	60
5947	5	7	60
5948	5	8	60
5949	5	9	60
5950	5	10	60
5951	6	1	60
5952	6	2	60
5953	6	3	60
5954	6	4	60
5955	6	5	60
5956	6	6	60
5957	6	7	60
5958	6	8	60
5959	6	9	60
5960	6	10	60
5961	7	1	60
5962	7	2	60
5963	7	3	60
5964	7	4	60
5965	7	5	60
5966	7	6	60
5967	7	7	60
5968	7	8	60
5969	7	9	60
5970	7	10	60
5971	8	1	60
5972	8	2	60
5973	8	3	60
5974	8	4	60
5975	8	5	60
5976	8	6	60
5977	8	7	60
5978	8	8	60
5979	8	9	60
5980	8	10	60
5981	9	1	60
5982	9	2	60
5983	9	3	60
5984	9	4	60
5985	9	5	60
5986	9	6	60
5987	9	7	60
5988	9	8	60
5989	9	9	60
5990	9	10	60
5991	10	1	60
5992	10	2	60
5993	10	3	60
5994	10	4	60
5995	10	5	60
5996	10	6	60
5997	10	7	60
5998	10	8	60
5999	10	9	60
6000	10	10	60
6001	1	1	61
6002	1	2	61
6003	1	3	61
6004	1	4	61
6005	1	5	61
6006	1	6	61
6007	1	7	61
6008	1	8	61
6009	1	9	61
6010	1	10	61
6011	2	1	61
6012	2	2	61
6013	2	3	61
6014	2	4	61
6015	2	5	61
6016	2	6	61
6017	2	7	61
6018	2	8	61
6019	2	9	61
6020	2	10	61
6021	3	1	61
6022	3	2	61
6023	3	3	61
6024	3	4	61
6025	3	5	61
6026	3	6	61
6027	3	7	61
6028	3	8	61
6029	3	9	61
6030	3	10	61
6031	4	1	61
6032	4	2	61
6033	4	3	61
6034	4	4	61
6035	4	5	61
6036	4	6	61
6037	4	7	61
6038	4	8	61
6039	4	9	61
6040	4	10	61
6041	5	1	61
6042	5	2	61
6043	5	3	61
6044	5	4	61
6045	5	5	61
6046	5	6	61
6047	5	7	61
6048	5	8	61
6049	5	9	61
6050	5	10	61
6051	6	1	61
6052	6	2	61
6053	6	3	61
6054	6	4	61
6055	6	5	61
6056	6	6	61
6057	6	7	61
6058	6	8	61
6059	6	9	61
6060	6	10	61
6061	7	1	61
6062	7	2	61
6063	7	3	61
6064	7	4	61
6065	7	5	61
6066	7	6	61
6067	7	7	61
6068	7	8	61
6069	7	9	61
6070	7	10	61
6071	8	1	61
6072	8	2	61
6073	8	3	61
6074	8	4	61
6075	8	5	61
6076	8	6	61
6077	8	7	61
6078	8	8	61
6079	8	9	61
6080	8	10	61
6081	9	1	61
6082	9	2	61
6083	9	3	61
6084	9	4	61
6085	9	5	61
6086	9	6	61
6087	9	7	61
6088	9	8	61
6089	9	9	61
6090	9	10	61
6091	10	1	61
6092	10	2	61
6093	10	3	61
6094	10	4	61
6095	10	5	61
6096	10	6	61
6097	10	7	61
6098	10	8	61
6099	10	9	61
6100	10	10	61
6101	1	1	62
6102	1	2	62
6103	1	3	62
6104	1	4	62
6105	1	5	62
6106	1	6	62
6107	1	7	62
6108	1	8	62
6109	1	9	62
6110	1	10	62
6111	2	1	62
6112	2	2	62
6113	2	3	62
6114	2	4	62
6115	2	5	62
6116	2	6	62
6117	2	7	62
6118	2	8	62
6119	2	9	62
6120	2	10	62
6121	3	1	62
6122	3	2	62
6123	3	3	62
6124	3	4	62
6125	3	5	62
6126	3	6	62
6127	3	7	62
6128	3	8	62
6129	3	9	62
6130	3	10	62
6131	4	1	62
6132	4	2	62
6133	4	3	62
6134	4	4	62
6135	4	5	62
6136	4	6	62
6137	4	7	62
6138	4	8	62
6139	4	9	62
6140	4	10	62
6141	5	1	62
6142	5	2	62
6143	5	3	62
6144	5	4	62
6145	5	5	62
6146	5	6	62
6147	5	7	62
6148	5	8	62
6149	5	9	62
6150	5	10	62
6151	6	1	62
6152	6	2	62
6153	6	3	62
6154	6	4	62
6155	6	5	62
6156	6	6	62
6157	6	7	62
6158	6	8	62
6159	6	9	62
6160	6	10	62
6161	7	1	62
6162	7	2	62
6163	7	3	62
6164	7	4	62
6165	7	5	62
6166	7	6	62
6167	7	7	62
6168	7	8	62
6169	7	9	62
6170	7	10	62
6171	8	1	62
6172	8	2	62
6173	8	3	62
6174	8	4	62
6175	8	5	62
6176	8	6	62
6177	8	7	62
6178	8	8	62
6179	8	9	62
6180	8	10	62
6181	9	1	62
6182	9	2	62
6183	9	3	62
6184	9	4	62
6185	9	5	62
6186	9	6	62
6187	9	7	62
6188	9	8	62
6189	9	9	62
6190	9	10	62
6191	10	1	62
6192	10	2	62
6193	10	3	62
6194	10	4	62
6195	10	5	62
6196	10	6	62
6197	10	7	62
6198	10	8	62
6199	10	9	62
6200	10	10	62
6201	1	1	63
6202	1	2	63
6203	1	3	63
6204	1	4	63
6205	1	5	63
6206	1	6	63
6207	1	7	63
6208	1	8	63
6209	1	9	63
6210	1	10	63
6211	2	1	63
6212	2	2	63
6213	2	3	63
6214	2	4	63
6215	2	5	63
6216	2	6	63
6217	2	7	63
6218	2	8	63
6219	2	9	63
6220	2	10	63
6221	3	1	63
6222	3	2	63
6223	3	3	63
6224	3	4	63
6225	3	5	63
6226	3	6	63
6227	3	7	63
6228	3	8	63
6229	3	9	63
6230	3	10	63
6231	4	1	63
6232	4	2	63
6233	4	3	63
6234	4	4	63
6235	4	5	63
6236	4	6	63
6237	4	7	63
6238	4	8	63
6239	4	9	63
6240	4	10	63
6241	5	1	63
6242	5	2	63
6243	5	3	63
6244	5	4	63
6245	5	5	63
6246	5	6	63
6247	5	7	63
6248	5	8	63
6249	5	9	63
6250	5	10	63
6251	6	1	63
6252	6	2	63
6253	6	3	63
6254	6	4	63
6255	6	5	63
6256	6	6	63
6257	6	7	63
6258	6	8	63
6259	6	9	63
6260	6	10	63
6261	7	1	63
6262	7	2	63
6263	7	3	63
6264	7	4	63
6265	7	5	63
6266	7	6	63
6267	7	7	63
6268	7	8	63
6269	7	9	63
6270	7	10	63
6271	8	1	63
6272	8	2	63
6273	8	3	63
6274	8	4	63
6275	8	5	63
6276	8	6	63
6277	8	7	63
6278	8	8	63
6279	8	9	63
6280	8	10	63
6281	9	1	63
6282	9	2	63
6283	9	3	63
6284	9	4	63
6285	9	5	63
6286	9	6	63
6287	9	7	63
6288	9	8	63
6289	9	9	63
6290	9	10	63
6291	10	1	63
6292	10	2	63
6293	10	3	63
6294	10	4	63
6295	10	5	63
6296	10	6	63
6297	10	7	63
6298	10	8	63
6299	10	9	63
6300	10	10	63
6301	1	1	64
6302	1	2	64
6303	1	3	64
6304	1	4	64
6305	1	5	64
6306	1	6	64
6307	1	7	64
6308	1	8	64
6309	1	9	64
6310	1	10	64
6311	2	1	64
6312	2	2	64
6313	2	3	64
6314	2	4	64
6315	2	5	64
6316	2	6	64
6317	2	7	64
6318	2	8	64
6319	2	9	64
6320	2	10	64
6321	3	1	64
6322	3	2	64
6323	3	3	64
6324	3	4	64
6325	3	5	64
6326	3	6	64
6327	3	7	64
6328	3	8	64
6329	3	9	64
6330	3	10	64
6331	4	1	64
6332	4	2	64
6333	4	3	64
6334	4	4	64
6335	4	5	64
6336	4	6	64
6337	4	7	64
6338	4	8	64
6339	4	9	64
6340	4	10	64
6341	5	1	64
6342	5	2	64
6343	5	3	64
6344	5	4	64
6345	5	5	64
6346	5	6	64
6347	5	7	64
6348	5	8	64
6349	5	9	64
6350	5	10	64
6351	6	1	64
6352	6	2	64
6353	6	3	64
6354	6	4	64
6355	6	5	64
6356	6	6	64
6357	6	7	64
6358	6	8	64
6359	6	9	64
6360	6	10	64
6361	7	1	64
6362	7	2	64
6363	7	3	64
6364	7	4	64
6365	7	5	64
6366	7	6	64
6367	7	7	64
6368	7	8	64
6369	7	9	64
6370	7	10	64
6371	8	1	64
6372	8	2	64
6373	8	3	64
6374	8	4	64
6375	8	5	64
6376	8	6	64
6377	8	7	64
6378	8	8	64
6379	8	9	64
6380	8	10	64
6381	9	1	64
6382	9	2	64
6383	9	3	64
6384	9	4	64
6385	9	5	64
6386	9	6	64
6387	9	7	64
6388	9	8	64
6389	9	9	64
6390	9	10	64
6391	10	1	64
6392	10	2	64
6393	10	3	64
6394	10	4	64
6395	10	5	64
6396	10	6	64
6397	10	7	64
6398	10	8	64
6399	10	9	64
6400	10	10	64
6401	1	1	65
6402	1	2	65
6403	1	3	65
6404	1	4	65
6405	1	5	65
6406	1	6	65
6407	1	7	65
6408	1	8	65
6409	1	9	65
6410	1	10	65
6411	2	1	65
6412	2	2	65
6413	2	3	65
6414	2	4	65
6415	2	5	65
6416	2	6	65
6417	2	7	65
6418	2	8	65
6419	2	9	65
6420	2	10	65
6421	3	1	65
6422	3	2	65
6423	3	3	65
6424	3	4	65
6425	3	5	65
6426	3	6	65
6427	3	7	65
6428	3	8	65
6429	3	9	65
6430	3	10	65
6431	4	1	65
6432	4	2	65
6433	4	3	65
6434	4	4	65
6435	4	5	65
6436	4	6	65
6437	4	7	65
6438	4	8	65
6439	4	9	65
6440	4	10	65
6441	5	1	65
6442	5	2	65
6443	5	3	65
6444	5	4	65
6445	5	5	65
6446	5	6	65
6447	5	7	65
6448	5	8	65
6449	5	9	65
6450	5	10	65
6451	6	1	65
6452	6	2	65
6453	6	3	65
6454	6	4	65
6455	6	5	65
6456	6	6	65
6457	6	7	65
6458	6	8	65
6459	6	9	65
6460	6	10	65
6461	7	1	65
6462	7	2	65
6463	7	3	65
6464	7	4	65
6465	7	5	65
6466	7	6	65
6467	7	7	65
6468	7	8	65
6469	7	9	65
6470	7	10	65
6471	8	1	65
6472	8	2	65
6473	8	3	65
6474	8	4	65
6475	8	5	65
6476	8	6	65
6477	8	7	65
6478	8	8	65
6479	8	9	65
6480	8	10	65
6481	9	1	65
6482	9	2	65
6483	9	3	65
6484	9	4	65
6485	9	5	65
6486	9	6	65
6487	9	7	65
6488	9	8	65
6489	9	9	65
6490	9	10	65
6491	10	1	65
6492	10	2	65
6493	10	3	65
6494	10	4	65
6495	10	5	65
6496	10	6	65
6497	10	7	65
6498	10	8	65
6499	10	9	65
6500	10	10	65
6501	1	1	66
6502	1	2	66
6503	1	3	66
6504	1	4	66
6505	1	5	66
6506	1	6	66
6507	1	7	66
6508	1	8	66
6509	1	9	66
6510	1	10	66
6511	2	1	66
6512	2	2	66
6513	2	3	66
6514	2	4	66
6515	2	5	66
6516	2	6	66
6517	2	7	66
6518	2	8	66
6519	2	9	66
6520	2	10	66
6521	3	1	66
6522	3	2	66
6523	3	3	66
6524	3	4	66
6525	3	5	66
6526	3	6	66
6527	3	7	66
6528	3	8	66
6529	3	9	66
6530	3	10	66
6531	4	1	66
6532	4	2	66
6533	4	3	66
6534	4	4	66
6535	4	5	66
6536	4	6	66
6537	4	7	66
6538	4	8	66
6539	4	9	66
6540	4	10	66
6541	5	1	66
6542	5	2	66
6543	5	3	66
6544	5	4	66
6545	5	5	66
6546	5	6	66
6547	5	7	66
6548	5	8	66
6549	5	9	66
6550	5	10	66
6551	6	1	66
6552	6	2	66
6553	6	3	66
6554	6	4	66
6555	6	5	66
6556	6	6	66
6557	6	7	66
6558	6	8	66
6559	6	9	66
6560	6	10	66
6561	7	1	66
6562	7	2	66
6563	7	3	66
6564	7	4	66
6565	7	5	66
6566	7	6	66
6567	7	7	66
6568	7	8	66
6569	7	9	66
6570	7	10	66
6571	8	1	66
6572	8	2	66
6573	8	3	66
6574	8	4	66
6575	8	5	66
6576	8	6	66
6577	8	7	66
6578	8	8	66
6579	8	9	66
6580	8	10	66
6581	9	1	66
6582	9	2	66
6583	9	3	66
6584	9	4	66
6585	9	5	66
6586	9	6	66
6587	9	7	66
6588	9	8	66
6589	9	9	66
6590	9	10	66
6591	10	1	66
6592	10	2	66
6593	10	3	66
6594	10	4	66
6595	10	5	66
6596	10	6	66
6597	10	7	66
6598	10	8	66
6599	10	9	66
6600	10	10	66
6601	1	1	67
6602	1	2	67
6603	1	3	67
6604	1	4	67
6605	1	5	67
6606	1	6	67
6607	1	7	67
6608	1	8	67
6609	1	9	67
6610	1	10	67
6611	2	1	67
6612	2	2	67
6613	2	3	67
6614	2	4	67
6615	2	5	67
6616	2	6	67
6617	2	7	67
6618	2	8	67
6619	2	9	67
6620	2	10	67
6621	3	1	67
6622	3	2	67
6623	3	3	67
6624	3	4	67
6625	3	5	67
6626	3	6	67
6627	3	7	67
6628	3	8	67
6629	3	9	67
6630	3	10	67
6631	4	1	67
6632	4	2	67
6633	4	3	67
6634	4	4	67
6635	4	5	67
6636	4	6	67
6637	4	7	67
6638	4	8	67
6639	4	9	67
6640	4	10	67
6641	5	1	67
6642	5	2	67
6643	5	3	67
6644	5	4	67
6645	5	5	67
6646	5	6	67
6647	5	7	67
6648	5	8	67
6649	5	9	67
6650	5	10	67
6651	6	1	67
6652	6	2	67
6653	6	3	67
6654	6	4	67
6655	6	5	67
6656	6	6	67
6657	6	7	67
6658	6	8	67
6659	6	9	67
6660	6	10	67
6661	7	1	67
6662	7	2	67
6663	7	3	67
6664	7	4	67
6665	7	5	67
6666	7	6	67
6667	7	7	67
6668	7	8	67
6669	7	9	67
6670	7	10	67
6671	8	1	67
6672	8	2	67
6673	8	3	67
6674	8	4	67
6675	8	5	67
6676	8	6	67
6677	8	7	67
6678	8	8	67
6679	8	9	67
6680	8	10	67
6681	9	1	67
6682	9	2	67
6683	9	3	67
6684	9	4	67
6685	9	5	67
6686	9	6	67
6687	9	7	67
6688	9	8	67
6689	9	9	67
6690	9	10	67
6691	10	1	67
6692	10	2	67
6693	10	3	67
6694	10	4	67
6695	10	5	67
6696	10	6	67
6697	10	7	67
6698	10	8	67
6699	10	9	67
6700	10	10	67
6701	1	1	68
6702	1	2	68
6703	1	3	68
6704	1	4	68
6705	1	5	68
6706	1	6	68
6707	1	7	68
6708	1	8	68
6709	1	9	68
6710	1	10	68
6711	2	1	68
6712	2	2	68
6713	2	3	68
6714	2	4	68
6715	2	5	68
6716	2	6	68
6717	2	7	68
6718	2	8	68
6719	2	9	68
6720	2	10	68
6721	3	1	68
6722	3	2	68
6723	3	3	68
6724	3	4	68
6725	3	5	68
6726	3	6	68
6727	3	7	68
6728	3	8	68
6729	3	9	68
6730	3	10	68
6731	4	1	68
6732	4	2	68
6733	4	3	68
6734	4	4	68
6735	4	5	68
6736	4	6	68
6737	4	7	68
6738	4	8	68
6739	4	9	68
6740	4	10	68
6741	5	1	68
6742	5	2	68
6743	5	3	68
6744	5	4	68
6745	5	5	68
6746	5	6	68
6747	5	7	68
6748	5	8	68
6749	5	9	68
6750	5	10	68
6751	6	1	68
6752	6	2	68
6753	6	3	68
6754	6	4	68
6755	6	5	68
6756	6	6	68
6757	6	7	68
6758	6	8	68
6759	6	9	68
6760	6	10	68
6761	7	1	68
6762	7	2	68
6763	7	3	68
6764	7	4	68
6765	7	5	68
6766	7	6	68
6767	7	7	68
6768	7	8	68
6769	7	9	68
6770	7	10	68
6771	8	1	68
6772	8	2	68
6773	8	3	68
6774	8	4	68
6775	8	5	68
6776	8	6	68
6777	8	7	68
6778	8	8	68
6779	8	9	68
6780	8	10	68
6781	9	1	68
6782	9	2	68
6783	9	3	68
6784	9	4	68
6785	9	5	68
6786	9	6	68
6787	9	7	68
6788	9	8	68
6789	9	9	68
6790	9	10	68
6791	10	1	68
6792	10	2	68
6793	10	3	68
6794	10	4	68
6795	10	5	68
6796	10	6	68
6797	10	7	68
6798	10	8	68
6799	10	9	68
6800	10	10	68
6801	1	1	69
6802	1	2	69
6803	1	3	69
6804	1	4	69
6805	1	5	69
6806	1	6	69
6807	1	7	69
6808	1	8	69
6809	1	9	69
6810	1	10	69
6811	2	1	69
6812	2	2	69
6813	2	3	69
6814	2	4	69
6815	2	5	69
6816	2	6	69
6817	2	7	69
6818	2	8	69
6819	2	9	69
6820	2	10	69
6821	3	1	69
6822	3	2	69
6823	3	3	69
6824	3	4	69
6825	3	5	69
6826	3	6	69
6827	3	7	69
6828	3	8	69
6829	3	9	69
6830	3	10	69
6831	4	1	69
6832	4	2	69
6833	4	3	69
6834	4	4	69
6835	4	5	69
6836	4	6	69
6837	4	7	69
6838	4	8	69
6839	4	9	69
6840	4	10	69
6841	5	1	69
6842	5	2	69
6843	5	3	69
6844	5	4	69
6845	5	5	69
6846	5	6	69
6847	5	7	69
6848	5	8	69
6849	5	9	69
6850	5	10	69
6851	6	1	69
6852	6	2	69
6853	6	3	69
6854	6	4	69
6855	6	5	69
6856	6	6	69
6857	6	7	69
6858	6	8	69
6859	6	9	69
6860	6	10	69
6861	7	1	69
6862	7	2	69
6863	7	3	69
6864	7	4	69
6865	7	5	69
6866	7	6	69
6867	7	7	69
6868	7	8	69
6869	7	9	69
6870	7	10	69
6871	8	1	69
6872	8	2	69
6873	8	3	69
6874	8	4	69
6875	8	5	69
6876	8	6	69
6877	8	7	69
6878	8	8	69
6879	8	9	69
6880	8	10	69
6881	9	1	69
6882	9	2	69
6883	9	3	69
6884	9	4	69
6885	9	5	69
6886	9	6	69
6887	9	7	69
6888	9	8	69
6889	9	9	69
6890	9	10	69
6891	10	1	69
6892	10	2	69
6893	10	3	69
6894	10	4	69
6895	10	5	69
6896	10	6	69
6897	10	7	69
6898	10	8	69
6899	10	9	69
6900	10	10	69
6901	1	1	70
6902	1	2	70
6903	1	3	70
6904	1	4	70
6905	1	5	70
6906	1	6	70
6907	1	7	70
6908	1	8	70
6909	1	9	70
6910	1	10	70
6911	2	1	70
6912	2	2	70
6913	2	3	70
6914	2	4	70
6915	2	5	70
6916	2	6	70
6917	2	7	70
6918	2	8	70
6919	2	9	70
6920	2	10	70
6921	3	1	70
6922	3	2	70
6923	3	3	70
6924	3	4	70
6925	3	5	70
6926	3	6	70
6927	3	7	70
6928	3	8	70
6929	3	9	70
6930	3	10	70
6931	4	1	70
6932	4	2	70
6933	4	3	70
6934	4	4	70
6935	4	5	70
6936	4	6	70
6937	4	7	70
6938	4	8	70
6939	4	9	70
6940	4	10	70
6941	5	1	70
6942	5	2	70
6943	5	3	70
6944	5	4	70
6945	5	5	70
6946	5	6	70
6947	5	7	70
6948	5	8	70
6949	5	9	70
6950	5	10	70
6951	6	1	70
6952	6	2	70
6953	6	3	70
6954	6	4	70
6955	6	5	70
6956	6	6	70
6957	6	7	70
6958	6	8	70
6959	6	9	70
6960	6	10	70
6961	7	1	70
6962	7	2	70
6963	7	3	70
6964	7	4	70
6965	7	5	70
6966	7	6	70
6967	7	7	70
6968	7	8	70
6969	7	9	70
6970	7	10	70
6971	8	1	70
6972	8	2	70
6973	8	3	70
6974	8	4	70
6975	8	5	70
6976	8	6	70
6977	8	7	70
6978	8	8	70
6979	8	9	70
6980	8	10	70
6981	9	1	70
6982	9	2	70
6983	9	3	70
6984	9	4	70
6985	9	5	70
6986	9	6	70
6987	9	7	70
6988	9	8	70
6989	9	9	70
6990	9	10	70
6991	10	1	70
6992	10	2	70
6993	10	3	70
6994	10	4	70
6995	10	5	70
6996	10	6	70
6997	10	7	70
6998	10	8	70
6999	10	9	70
7000	10	10	70
7001	1	1	71
7002	1	2	71
7003	1	3	71
7004	1	4	71
7005	1	5	71
7006	1	6	71
7007	1	7	71
7008	1	8	71
7009	1	9	71
7010	1	10	71
7011	2	1	71
7012	2	2	71
7013	2	3	71
7014	2	4	71
7015	2	5	71
7016	2	6	71
7017	2	7	71
7018	2	8	71
7019	2	9	71
7020	2	10	71
7021	3	1	71
7022	3	2	71
7023	3	3	71
7024	3	4	71
7025	3	5	71
7026	3	6	71
7027	3	7	71
7028	3	8	71
7029	3	9	71
7030	3	10	71
7031	4	1	71
7032	4	2	71
7033	4	3	71
7034	4	4	71
7035	4	5	71
7036	4	6	71
7037	4	7	71
7038	4	8	71
7039	4	9	71
7040	4	10	71
7041	5	1	71
7042	5	2	71
7043	5	3	71
7044	5	4	71
7045	5	5	71
7046	5	6	71
7047	5	7	71
7048	5	8	71
7049	5	9	71
7050	5	10	71
7051	6	1	71
7052	6	2	71
7053	6	3	71
7054	6	4	71
7055	6	5	71
7056	6	6	71
7057	6	7	71
7058	6	8	71
7059	6	9	71
7060	6	10	71
7061	7	1	71
7062	7	2	71
7063	7	3	71
7064	7	4	71
7065	7	5	71
7066	7	6	71
7067	7	7	71
7068	7	8	71
7069	7	9	71
7070	7	10	71
7071	8	1	71
7072	8	2	71
7073	8	3	71
7074	8	4	71
7075	8	5	71
7076	8	6	71
7077	8	7	71
7078	8	8	71
7079	8	9	71
7080	8	10	71
7081	9	1	71
7082	9	2	71
7083	9	3	71
7084	9	4	71
7085	9	5	71
7086	9	6	71
7087	9	7	71
7088	9	8	71
7089	9	9	71
7090	9	10	71
7091	10	1	71
7092	10	2	71
7093	10	3	71
7094	10	4	71
7095	10	5	71
7096	10	6	71
7097	10	7	71
7098	10	8	71
7099	10	9	71
7100	10	10	71
7101	1	1	72
7102	1	2	72
7103	1	3	72
7104	1	4	72
7105	1	5	72
7106	1	6	72
7107	1	7	72
7108	1	8	72
7109	1	9	72
7110	1	10	72
7111	2	1	72
7112	2	2	72
7113	2	3	72
7114	2	4	72
7115	2	5	72
7116	2	6	72
7117	2	7	72
7118	2	8	72
7119	2	9	72
7120	2	10	72
7121	3	1	72
7122	3	2	72
7123	3	3	72
7124	3	4	72
7125	3	5	72
7126	3	6	72
7127	3	7	72
7128	3	8	72
7129	3	9	72
7130	3	10	72
7131	4	1	72
7132	4	2	72
7133	4	3	72
7134	4	4	72
7135	4	5	72
7136	4	6	72
7137	4	7	72
7138	4	8	72
7139	4	9	72
7140	4	10	72
7141	5	1	72
7142	5	2	72
7143	5	3	72
7144	5	4	72
7145	5	5	72
7146	5	6	72
7147	5	7	72
7148	5	8	72
7149	5	9	72
7150	5	10	72
7151	6	1	72
7152	6	2	72
7153	6	3	72
7154	6	4	72
7155	6	5	72
7156	6	6	72
7157	6	7	72
7158	6	8	72
7159	6	9	72
7160	6	10	72
7161	7	1	72
7162	7	2	72
7163	7	3	72
7164	7	4	72
7165	7	5	72
7166	7	6	72
7167	7	7	72
7168	7	8	72
7169	7	9	72
7170	7	10	72
7171	8	1	72
7172	8	2	72
7173	8	3	72
7174	8	4	72
7175	8	5	72
7176	8	6	72
7177	8	7	72
7178	8	8	72
7179	8	9	72
7180	8	10	72
7181	9	1	72
7182	9	2	72
7183	9	3	72
7184	9	4	72
7185	9	5	72
7186	9	6	72
7187	9	7	72
7188	9	8	72
7189	9	9	72
7190	9	10	72
7191	10	1	72
7192	10	2	72
7193	10	3	72
7194	10	4	72
7195	10	5	72
7196	10	6	72
7197	10	7	72
7198	10	8	72
7199	10	9	72
7200	10	10	72
7201	1	1	73
7202	1	2	73
7203	1	3	73
7204	1	4	73
7205	1	5	73
7206	1	6	73
7207	1	7	73
7208	1	8	73
7209	1	9	73
7210	1	10	73
7211	2	1	73
7212	2	2	73
7213	2	3	73
7214	2	4	73
7215	2	5	73
7216	2	6	73
7217	2	7	73
7218	2	8	73
7219	2	9	73
7220	2	10	73
7221	3	1	73
7222	3	2	73
7223	3	3	73
7224	3	4	73
7225	3	5	73
7226	3	6	73
7227	3	7	73
7228	3	8	73
7229	3	9	73
7230	3	10	73
7231	4	1	73
7232	4	2	73
7233	4	3	73
7234	4	4	73
7235	4	5	73
7236	4	6	73
7237	4	7	73
7238	4	8	73
7239	4	9	73
7240	4	10	73
7241	5	1	73
7242	5	2	73
7243	5	3	73
7244	5	4	73
7245	5	5	73
7246	5	6	73
7247	5	7	73
7248	5	8	73
7249	5	9	73
7250	5	10	73
7251	6	1	73
7252	6	2	73
7253	6	3	73
7254	6	4	73
7255	6	5	73
7256	6	6	73
7257	6	7	73
7258	6	8	73
7259	6	9	73
7260	6	10	73
7261	7	1	73
7262	7	2	73
7263	7	3	73
7264	7	4	73
7265	7	5	73
7266	7	6	73
7267	7	7	73
7268	7	8	73
7269	7	9	73
7270	7	10	73
7271	8	1	73
7272	8	2	73
7273	8	3	73
7274	8	4	73
7275	8	5	73
7276	8	6	73
7277	8	7	73
7278	8	8	73
7279	8	9	73
7280	8	10	73
7281	9	1	73
7282	9	2	73
7283	9	3	73
7284	9	4	73
7285	9	5	73
7286	9	6	73
7287	9	7	73
7288	9	8	73
7289	9	9	73
7290	9	10	73
7291	10	1	73
7292	10	2	73
7293	10	3	73
7294	10	4	73
7295	10	5	73
7296	10	6	73
7297	10	7	73
7298	10	8	73
7299	10	9	73
7300	10	10	73
7301	1	1	74
7302	1	2	74
7303	1	3	74
7304	1	4	74
7305	1	5	74
7306	1	6	74
7307	1	7	74
7308	1	8	74
7309	1	9	74
7310	1	10	74
7311	2	1	74
7312	2	2	74
7313	2	3	74
7314	2	4	74
7315	2	5	74
7316	2	6	74
7317	2	7	74
7318	2	8	74
7319	2	9	74
7320	2	10	74
7321	3	1	74
7322	3	2	74
7323	3	3	74
7324	3	4	74
7325	3	5	74
7326	3	6	74
7327	3	7	74
7328	3	8	74
7329	3	9	74
7330	3	10	74
7331	4	1	74
7332	4	2	74
7333	4	3	74
7334	4	4	74
7335	4	5	74
7336	4	6	74
7337	4	7	74
7338	4	8	74
7339	4	9	74
7340	4	10	74
7341	5	1	74
7342	5	2	74
7343	5	3	74
7344	5	4	74
7345	5	5	74
7346	5	6	74
7347	5	7	74
7348	5	8	74
7349	5	9	74
7350	5	10	74
7351	6	1	74
7352	6	2	74
7353	6	3	74
7354	6	4	74
7355	6	5	74
7356	6	6	74
7357	6	7	74
7358	6	8	74
7359	6	9	74
7360	6	10	74
7361	7	1	74
7362	7	2	74
7363	7	3	74
7364	7	4	74
7365	7	5	74
7366	7	6	74
7367	7	7	74
7368	7	8	74
7369	7	9	74
7370	7	10	74
7371	8	1	74
7372	8	2	74
7373	8	3	74
7374	8	4	74
7375	8	5	74
7376	8	6	74
7377	8	7	74
7378	8	8	74
7379	8	9	74
7380	8	10	74
7381	9	1	74
7382	9	2	74
7383	9	3	74
7384	9	4	74
7385	9	5	74
7386	9	6	74
7387	9	7	74
7388	9	8	74
7389	9	9	74
7390	9	10	74
7391	10	1	74
7392	10	2	74
7393	10	3	74
7394	10	4	74
7395	10	5	74
7396	10	6	74
7397	10	7	74
7398	10	8	74
7399	10	9	74
7400	10	10	74
7401	1	1	75
7402	1	2	75
7403	1	3	75
7404	1	4	75
7405	1	5	75
7406	1	6	75
7407	1	7	75
7408	1	8	75
7409	1	9	75
7410	1	10	75
7411	2	1	75
7412	2	2	75
7413	2	3	75
7414	2	4	75
7415	2	5	75
7416	2	6	75
7417	2	7	75
7418	2	8	75
7419	2	9	75
7420	2	10	75
7421	3	1	75
7422	3	2	75
7423	3	3	75
7424	3	4	75
7425	3	5	75
7426	3	6	75
7427	3	7	75
7428	3	8	75
7429	3	9	75
7430	3	10	75
7431	4	1	75
7432	4	2	75
7433	4	3	75
7434	4	4	75
7435	4	5	75
7436	4	6	75
7437	4	7	75
7438	4	8	75
7439	4	9	75
7440	4	10	75
7441	5	1	75
7442	5	2	75
7443	5	3	75
7444	5	4	75
7445	5	5	75
7446	5	6	75
7447	5	7	75
7448	5	8	75
7449	5	9	75
7450	5	10	75
7451	6	1	75
7452	6	2	75
7453	6	3	75
7454	6	4	75
7455	6	5	75
7456	6	6	75
7457	6	7	75
7458	6	8	75
7459	6	9	75
7460	6	10	75
7461	7	1	75
7462	7	2	75
7463	7	3	75
7464	7	4	75
7465	7	5	75
7466	7	6	75
7467	7	7	75
7468	7	8	75
7469	7	9	75
7470	7	10	75
7471	8	1	75
7472	8	2	75
7473	8	3	75
7474	8	4	75
7475	8	5	75
7476	8	6	75
7477	8	7	75
7478	8	8	75
7479	8	9	75
7480	8	10	75
7481	9	1	75
7482	9	2	75
7483	9	3	75
7484	9	4	75
7485	9	5	75
7486	9	6	75
7487	9	7	75
7488	9	8	75
7489	9	9	75
7490	9	10	75
7491	10	1	75
7492	10	2	75
7493	10	3	75
7494	10	4	75
7495	10	5	75
7496	10	6	75
7497	10	7	75
7498	10	8	75
7499	10	9	75
7500	10	10	75
7501	1	1	76
7502	1	2	76
7503	1	3	76
7504	1	4	76
7505	1	5	76
7506	1	6	76
7507	1	7	76
7508	1	8	76
7509	1	9	76
7510	1	10	76
7511	2	1	76
7512	2	2	76
7513	2	3	76
7514	2	4	76
7515	2	5	76
7516	2	6	76
7517	2	7	76
7518	2	8	76
7519	2	9	76
7520	2	10	76
7521	3	1	76
7522	3	2	76
7523	3	3	76
7524	3	4	76
7525	3	5	76
7526	3	6	76
7527	3	7	76
7528	3	8	76
7529	3	9	76
7530	3	10	76
7531	4	1	76
7532	4	2	76
7533	4	3	76
7534	4	4	76
7535	4	5	76
7536	4	6	76
7537	4	7	76
7538	4	8	76
7539	4	9	76
7540	4	10	76
7541	5	1	76
7542	5	2	76
7543	5	3	76
7544	5	4	76
7545	5	5	76
7546	5	6	76
7547	5	7	76
7548	5	8	76
7549	5	9	76
7550	5	10	76
7551	6	1	76
7552	6	2	76
7553	6	3	76
7554	6	4	76
7555	6	5	76
7556	6	6	76
7557	6	7	76
7558	6	8	76
7559	6	9	76
7560	6	10	76
7561	7	1	76
7562	7	2	76
7563	7	3	76
7564	7	4	76
7565	7	5	76
7566	7	6	76
7567	7	7	76
7568	7	8	76
7569	7	9	76
7570	7	10	76
7571	8	1	76
7572	8	2	76
7573	8	3	76
7574	8	4	76
7575	8	5	76
7576	8	6	76
7577	8	7	76
7578	8	8	76
7579	8	9	76
7580	8	10	76
7581	9	1	76
7582	9	2	76
7583	9	3	76
7584	9	4	76
7585	9	5	76
7586	9	6	76
7587	9	7	76
7588	9	8	76
7589	9	9	76
7590	9	10	76
7591	10	1	76
7592	10	2	76
7593	10	3	76
7594	10	4	76
7595	10	5	76
7596	10	6	76
7597	10	7	76
7598	10	8	76
7599	10	9	76
7600	10	10	76
7601	1	1	77
7602	1	2	77
7603	1	3	77
7604	1	4	77
7605	1	5	77
7606	1	6	77
7607	1	7	77
7608	1	8	77
7609	1	9	77
7610	1	10	77
7611	2	1	77
7612	2	2	77
7613	2	3	77
7614	2	4	77
7615	2	5	77
7616	2	6	77
7617	2	7	77
7618	2	8	77
7619	2	9	77
7620	2	10	77
7621	3	1	77
7622	3	2	77
7623	3	3	77
7624	3	4	77
7625	3	5	77
7626	3	6	77
7627	3	7	77
7628	3	8	77
7629	3	9	77
7630	3	10	77
7631	4	1	77
7632	4	2	77
7633	4	3	77
7634	4	4	77
7635	4	5	77
7636	4	6	77
7637	4	7	77
7638	4	8	77
7639	4	9	77
7640	4	10	77
7641	5	1	77
7642	5	2	77
7643	5	3	77
7644	5	4	77
7645	5	5	77
7646	5	6	77
7647	5	7	77
7648	5	8	77
7649	5	9	77
7650	5	10	77
7651	6	1	77
7652	6	2	77
7653	6	3	77
7654	6	4	77
7655	6	5	77
7656	6	6	77
7657	6	7	77
7658	6	8	77
7659	6	9	77
7660	6	10	77
7661	7	1	77
7662	7	2	77
7663	7	3	77
7664	7	4	77
7665	7	5	77
7666	7	6	77
7667	7	7	77
7668	7	8	77
7669	7	9	77
7670	7	10	77
7671	8	1	77
7672	8	2	77
7673	8	3	77
7674	8	4	77
7675	8	5	77
7676	8	6	77
7677	8	7	77
7678	8	8	77
7679	8	9	77
7680	8	10	77
7681	9	1	77
7682	9	2	77
7683	9	3	77
7684	9	4	77
7685	9	5	77
7686	9	6	77
7687	9	7	77
7688	9	8	77
7689	9	9	77
7690	9	10	77
7691	10	1	77
7692	10	2	77
7693	10	3	77
7694	10	4	77
7695	10	5	77
7696	10	6	77
7697	10	7	77
7698	10	8	77
7699	10	9	77
7700	10	10	77
7701	1	1	78
7702	1	2	78
7703	1	3	78
7704	1	4	78
7705	1	5	78
7706	1	6	78
7707	1	7	78
7708	1	8	78
7709	1	9	78
7710	1	10	78
7711	2	1	78
7712	2	2	78
7713	2	3	78
7714	2	4	78
7715	2	5	78
7716	2	6	78
7717	2	7	78
7718	2	8	78
7719	2	9	78
7720	2	10	78
7721	3	1	78
7722	3	2	78
7723	3	3	78
7724	3	4	78
7725	3	5	78
7726	3	6	78
7727	3	7	78
7728	3	8	78
7729	3	9	78
7730	3	10	78
7731	4	1	78
7732	4	2	78
7733	4	3	78
7734	4	4	78
7735	4	5	78
7736	4	6	78
7737	4	7	78
7738	4	8	78
7739	4	9	78
7740	4	10	78
7741	5	1	78
7742	5	2	78
7743	5	3	78
7744	5	4	78
7745	5	5	78
7746	5	6	78
7747	5	7	78
7748	5	8	78
7749	5	9	78
7750	5	10	78
7751	6	1	78
7752	6	2	78
7753	6	3	78
7754	6	4	78
7755	6	5	78
7756	6	6	78
7757	6	7	78
7758	6	8	78
7759	6	9	78
7760	6	10	78
7761	7	1	78
7762	7	2	78
7763	7	3	78
7764	7	4	78
7765	7	5	78
7766	7	6	78
7767	7	7	78
7768	7	8	78
7769	7	9	78
7770	7	10	78
7771	8	1	78
7772	8	2	78
7773	8	3	78
7774	8	4	78
7775	8	5	78
7776	8	6	78
7777	8	7	78
7778	8	8	78
7779	8	9	78
7780	8	10	78
7781	9	1	78
7782	9	2	78
7783	9	3	78
7784	9	4	78
7785	9	5	78
7786	9	6	78
7787	9	7	78
7788	9	8	78
7789	9	9	78
7790	9	10	78
7791	10	1	78
7792	10	2	78
7793	10	3	78
7794	10	4	78
7795	10	5	78
7796	10	6	78
7797	10	7	78
7798	10	8	78
7799	10	9	78
7800	10	10	78
7801	1	1	79
7802	1	2	79
7803	1	3	79
7804	1	4	79
7805	1	5	79
7806	1	6	79
7807	1	7	79
7808	1	8	79
7809	1	9	79
7810	1	10	79
7811	2	1	79
7812	2	2	79
7813	2	3	79
7814	2	4	79
7815	2	5	79
7816	2	6	79
7817	2	7	79
7818	2	8	79
7819	2	9	79
7820	2	10	79
7821	3	1	79
7822	3	2	79
7823	3	3	79
7824	3	4	79
7825	3	5	79
7826	3	6	79
7827	3	7	79
7828	3	8	79
7829	3	9	79
7830	3	10	79
7831	4	1	79
7832	4	2	79
7833	4	3	79
7834	4	4	79
7835	4	5	79
7836	4	6	79
7837	4	7	79
7838	4	8	79
7839	4	9	79
7840	4	10	79
7841	5	1	79
7842	5	2	79
7843	5	3	79
7844	5	4	79
7845	5	5	79
7846	5	6	79
7847	5	7	79
7848	5	8	79
7849	5	9	79
7850	5	10	79
7851	6	1	79
7852	6	2	79
7853	6	3	79
7854	6	4	79
7855	6	5	79
7856	6	6	79
7857	6	7	79
7858	6	8	79
7859	6	9	79
7860	6	10	79
7861	7	1	79
7862	7	2	79
7863	7	3	79
7864	7	4	79
7865	7	5	79
7866	7	6	79
7867	7	7	79
7868	7	8	79
7869	7	9	79
7870	7	10	79
7871	8	1	79
7872	8	2	79
7873	8	3	79
7874	8	4	79
7875	8	5	79
7876	8	6	79
7877	8	7	79
7878	8	8	79
7879	8	9	79
7880	8	10	79
7881	9	1	79
7882	9	2	79
7883	9	3	79
7884	9	4	79
7885	9	5	79
7886	9	6	79
7887	9	7	79
7888	9	8	79
7889	9	9	79
7890	9	10	79
7891	10	1	79
7892	10	2	79
7893	10	3	79
7894	10	4	79
7895	10	5	79
7896	10	6	79
7897	10	7	79
7898	10	8	79
7899	10	9	79
7900	10	10	79
7901	1	1	80
7902	1	2	80
7903	1	3	80
7904	1	4	80
7905	1	5	80
7906	1	6	80
7907	1	7	80
7908	1	8	80
7909	1	9	80
7910	1	10	80
7911	2	1	80
7912	2	2	80
7913	2	3	80
7914	2	4	80
7915	2	5	80
7916	2	6	80
7917	2	7	80
7918	2	8	80
7919	2	9	80
7920	2	10	80
7921	3	1	80
7922	3	2	80
7923	3	3	80
7924	3	4	80
7925	3	5	80
7926	3	6	80
7927	3	7	80
7928	3	8	80
7929	3	9	80
7930	3	10	80
7931	4	1	80
7932	4	2	80
7933	4	3	80
7934	4	4	80
7935	4	5	80
7936	4	6	80
7937	4	7	80
7938	4	8	80
7939	4	9	80
7940	4	10	80
7941	5	1	80
7942	5	2	80
7943	5	3	80
7944	5	4	80
7945	5	5	80
7946	5	6	80
7947	5	7	80
7948	5	8	80
7949	5	9	80
7950	5	10	80
7951	6	1	80
7952	6	2	80
7953	6	3	80
7954	6	4	80
7955	6	5	80
7956	6	6	80
7957	6	7	80
7958	6	8	80
7959	6	9	80
7960	6	10	80
7961	7	1	80
7962	7	2	80
7963	7	3	80
7964	7	4	80
7965	7	5	80
7966	7	6	80
7967	7	7	80
7968	7	8	80
7969	7	9	80
7970	7	10	80
7971	8	1	80
7972	8	2	80
7973	8	3	80
7974	8	4	80
7975	8	5	80
7976	8	6	80
7977	8	7	80
7978	8	8	80
7979	8	9	80
7980	8	10	80
7981	9	1	80
7982	9	2	80
7983	9	3	80
7984	9	4	80
7985	9	5	80
7986	9	6	80
7987	9	7	80
7988	9	8	80
7989	9	9	80
7990	9	10	80
7991	10	1	80
7992	10	2	80
7993	10	3	80
7994	10	4	80
7995	10	5	80
7996	10	6	80
7997	10	7	80
7998	10	8	80
7999	10	9	80
8000	10	10	80
8001	1	1	81
8002	1	2	81
8003	1	3	81
8004	1	4	81
8005	1	5	81
8006	1	6	81
8007	1	7	81
8008	1	8	81
8009	1	9	81
8010	1	10	81
8011	2	1	81
8012	2	2	81
8013	2	3	81
8014	2	4	81
8015	2	5	81
8016	2	6	81
8017	2	7	81
8018	2	8	81
8019	2	9	81
8020	2	10	81
8021	3	1	81
8022	3	2	81
8023	3	3	81
8024	3	4	81
8025	3	5	81
8026	3	6	81
8027	3	7	81
8028	3	8	81
8029	3	9	81
8030	3	10	81
8031	4	1	81
8032	4	2	81
8033	4	3	81
8034	4	4	81
8035	4	5	81
8036	4	6	81
8037	4	7	81
8038	4	8	81
8039	4	9	81
8040	4	10	81
8041	5	1	81
8042	5	2	81
8043	5	3	81
8044	5	4	81
8045	5	5	81
8046	5	6	81
8047	5	7	81
8048	5	8	81
8049	5	9	81
8050	5	10	81
8051	6	1	81
8052	6	2	81
8053	6	3	81
8054	6	4	81
8055	6	5	81
8056	6	6	81
8057	6	7	81
8058	6	8	81
8059	6	9	81
8060	6	10	81
8061	7	1	81
8062	7	2	81
8063	7	3	81
8064	7	4	81
8065	7	5	81
8066	7	6	81
8067	7	7	81
8068	7	8	81
8069	7	9	81
8070	7	10	81
8071	8	1	81
8072	8	2	81
8073	8	3	81
8074	8	4	81
8075	8	5	81
8076	8	6	81
8077	8	7	81
8078	8	8	81
8079	8	9	81
8080	8	10	81
8081	9	1	81
8082	9	2	81
8083	9	3	81
8084	9	4	81
8085	9	5	81
8086	9	6	81
8087	9	7	81
8088	9	8	81
8089	9	9	81
8090	9	10	81
8091	10	1	81
8092	10	2	81
8093	10	3	81
8094	10	4	81
8095	10	5	81
8096	10	6	81
8097	10	7	81
8098	10	8	81
8099	10	9	81
8100	10	10	81
8101	1	1	82
8102	1	2	82
8103	1	3	82
8104	1	4	82
8105	1	5	82
8106	1	6	82
8107	1	7	82
8108	1	8	82
8109	1	9	82
8110	1	10	82
8111	2	1	82
8112	2	2	82
8113	2	3	82
8114	2	4	82
8115	2	5	82
8116	2	6	82
8117	2	7	82
8118	2	8	82
8119	2	9	82
8120	2	10	82
8121	3	1	82
8122	3	2	82
8123	3	3	82
8124	3	4	82
8125	3	5	82
8126	3	6	82
8127	3	7	82
8128	3	8	82
8129	3	9	82
8130	3	10	82
8131	4	1	82
8132	4	2	82
8133	4	3	82
8134	4	4	82
8135	4	5	82
8136	4	6	82
8137	4	7	82
8138	4	8	82
8139	4	9	82
8140	4	10	82
8141	5	1	82
8142	5	2	82
8143	5	3	82
8144	5	4	82
8145	5	5	82
8146	5	6	82
8147	5	7	82
8148	5	8	82
8149	5	9	82
8150	5	10	82
8151	6	1	82
8152	6	2	82
8153	6	3	82
8154	6	4	82
8155	6	5	82
8156	6	6	82
8157	6	7	82
8158	6	8	82
8159	6	9	82
8160	6	10	82
8161	7	1	82
8162	7	2	82
8163	7	3	82
8164	7	4	82
8165	7	5	82
8166	7	6	82
8167	7	7	82
8168	7	8	82
8169	7	9	82
8170	7	10	82
8171	8	1	82
8172	8	2	82
8173	8	3	82
8174	8	4	82
8175	8	5	82
8176	8	6	82
8177	8	7	82
8178	8	8	82
8179	8	9	82
8180	8	10	82
8181	9	1	82
8182	9	2	82
8183	9	3	82
8184	9	4	82
8185	9	5	82
8186	9	6	82
8187	9	7	82
8188	9	8	82
8189	9	9	82
8190	9	10	82
8191	10	1	82
8192	10	2	82
8193	10	3	82
8194	10	4	82
8195	10	5	82
8196	10	6	82
8197	10	7	82
8198	10	8	82
8199	10	9	82
8200	10	10	82
8201	1	1	83
8202	1	2	83
8203	1	3	83
8204	1	4	83
8205	1	5	83
8206	1	6	83
8207	1	7	83
8208	1	8	83
8209	1	9	83
8210	1	10	83
8211	2	1	83
8212	2	2	83
8213	2	3	83
8214	2	4	83
8215	2	5	83
8216	2	6	83
8217	2	7	83
8218	2	8	83
8219	2	9	83
8220	2	10	83
8221	3	1	83
8222	3	2	83
8223	3	3	83
8224	3	4	83
8225	3	5	83
8226	3	6	83
8227	3	7	83
8228	3	8	83
8229	3	9	83
8230	3	10	83
8231	4	1	83
8232	4	2	83
8233	4	3	83
8234	4	4	83
8235	4	5	83
8236	4	6	83
8237	4	7	83
8238	4	8	83
8239	4	9	83
8240	4	10	83
8241	5	1	83
8242	5	2	83
8243	5	3	83
8244	5	4	83
8245	5	5	83
8246	5	6	83
8247	5	7	83
8248	5	8	83
8249	5	9	83
8250	5	10	83
8251	6	1	83
8252	6	2	83
8253	6	3	83
8254	6	4	83
8255	6	5	83
8256	6	6	83
8257	6	7	83
8258	6	8	83
8259	6	9	83
8260	6	10	83
8261	7	1	83
8262	7	2	83
8263	7	3	83
8264	7	4	83
8265	7	5	83
8266	7	6	83
8267	7	7	83
8268	7	8	83
8269	7	9	83
8270	7	10	83
8271	8	1	83
8272	8	2	83
8273	8	3	83
8274	8	4	83
8275	8	5	83
8276	8	6	83
8277	8	7	83
8278	8	8	83
8279	8	9	83
8280	8	10	83
8281	9	1	83
8282	9	2	83
8283	9	3	83
8284	9	4	83
8285	9	5	83
8286	9	6	83
8287	9	7	83
8288	9	8	83
8289	9	9	83
8290	9	10	83
8291	10	1	83
8292	10	2	83
8293	10	3	83
8294	10	4	83
8295	10	5	83
8296	10	6	83
8297	10	7	83
8298	10	8	83
8299	10	9	83
8300	10	10	83
8301	1	1	84
8302	1	2	84
8303	1	3	84
8304	1	4	84
8305	1	5	84
8306	1	6	84
8307	1	7	84
8308	1	8	84
8309	1	9	84
8310	1	10	84
8311	2	1	84
8312	2	2	84
8313	2	3	84
8314	2	4	84
8315	2	5	84
8316	2	6	84
8317	2	7	84
8318	2	8	84
8319	2	9	84
8320	2	10	84
8321	3	1	84
8322	3	2	84
8323	3	3	84
8324	3	4	84
8325	3	5	84
8326	3	6	84
8327	3	7	84
8328	3	8	84
8329	3	9	84
8330	3	10	84
8331	4	1	84
8332	4	2	84
8333	4	3	84
8334	4	4	84
8335	4	5	84
8336	4	6	84
8337	4	7	84
8338	4	8	84
8339	4	9	84
8340	4	10	84
8341	5	1	84
8342	5	2	84
8343	5	3	84
8344	5	4	84
8345	5	5	84
8346	5	6	84
8347	5	7	84
8348	5	8	84
8349	5	9	84
8350	5	10	84
8351	6	1	84
8352	6	2	84
8353	6	3	84
8354	6	4	84
8355	6	5	84
8356	6	6	84
8357	6	7	84
8358	6	8	84
8359	6	9	84
8360	6	10	84
8361	7	1	84
8362	7	2	84
8363	7	3	84
8364	7	4	84
8365	7	5	84
8366	7	6	84
8367	7	7	84
8368	7	8	84
8369	7	9	84
8370	7	10	84
8371	8	1	84
8372	8	2	84
8373	8	3	84
8374	8	4	84
8375	8	5	84
8376	8	6	84
8377	8	7	84
8378	8	8	84
8379	8	9	84
8380	8	10	84
8381	9	1	84
8382	9	2	84
8383	9	3	84
8384	9	4	84
8385	9	5	84
8386	9	6	84
8387	9	7	84
8388	9	8	84
8389	9	9	84
8390	9	10	84
8391	10	1	84
8392	10	2	84
8393	10	3	84
8394	10	4	84
8395	10	5	84
8396	10	6	84
8397	10	7	84
8398	10	8	84
8399	10	9	84
8400	10	10	84
8401	1	1	85
8402	1	2	85
8403	1	3	85
8404	1	4	85
8405	1	5	85
8406	1	6	85
8407	1	7	85
8408	1	8	85
8409	1	9	85
8410	1	10	85
8411	2	1	85
8412	2	2	85
8413	2	3	85
8414	2	4	85
8415	2	5	85
8416	2	6	85
8417	2	7	85
8418	2	8	85
8419	2	9	85
8420	2	10	85
8421	3	1	85
8422	3	2	85
8423	3	3	85
8424	3	4	85
8425	3	5	85
8426	3	6	85
8427	3	7	85
8428	3	8	85
8429	3	9	85
8430	3	10	85
8431	4	1	85
8432	4	2	85
8433	4	3	85
8434	4	4	85
8435	4	5	85
8436	4	6	85
8437	4	7	85
8438	4	8	85
8439	4	9	85
8440	4	10	85
8441	5	1	85
8442	5	2	85
8443	5	3	85
8444	5	4	85
8445	5	5	85
8446	5	6	85
8447	5	7	85
8448	5	8	85
8449	5	9	85
8450	5	10	85
8451	6	1	85
8452	6	2	85
8453	6	3	85
8454	6	4	85
8455	6	5	85
8456	6	6	85
8457	6	7	85
8458	6	8	85
8459	6	9	85
8460	6	10	85
8461	7	1	85
8462	7	2	85
8463	7	3	85
8464	7	4	85
8465	7	5	85
8466	7	6	85
8467	7	7	85
8468	7	8	85
8469	7	9	85
8470	7	10	85
8471	8	1	85
8472	8	2	85
8473	8	3	85
8474	8	4	85
8475	8	5	85
8476	8	6	85
8477	8	7	85
8478	8	8	85
8479	8	9	85
8480	8	10	85
8481	9	1	85
8482	9	2	85
8483	9	3	85
8484	9	4	85
8485	9	5	85
8486	9	6	85
8487	9	7	85
8488	9	8	85
8489	9	9	85
8490	9	10	85
8491	10	1	85
8492	10	2	85
8493	10	3	85
8494	10	4	85
8495	10	5	85
8496	10	6	85
8497	10	7	85
8498	10	8	85
8499	10	9	85
8500	10	10	85
8501	1	1	86
8502	1	2	86
8503	1	3	86
8504	1	4	86
8505	1	5	86
8506	1	6	86
8507	1	7	86
8508	1	8	86
8509	1	9	86
8510	1	10	86
8511	2	1	86
8512	2	2	86
8513	2	3	86
8514	2	4	86
8515	2	5	86
8516	2	6	86
8517	2	7	86
8518	2	8	86
8519	2	9	86
8520	2	10	86
8521	3	1	86
8522	3	2	86
8523	3	3	86
8524	3	4	86
8525	3	5	86
8526	3	6	86
8527	3	7	86
8528	3	8	86
8529	3	9	86
8530	3	10	86
8531	4	1	86
8532	4	2	86
8533	4	3	86
8534	4	4	86
8535	4	5	86
8536	4	6	86
8537	4	7	86
8538	4	8	86
8539	4	9	86
8540	4	10	86
8541	5	1	86
8542	5	2	86
8543	5	3	86
8544	5	4	86
8545	5	5	86
8546	5	6	86
8547	5	7	86
8548	5	8	86
8549	5	9	86
8550	5	10	86
8551	6	1	86
8552	6	2	86
8553	6	3	86
8554	6	4	86
8555	6	5	86
8556	6	6	86
8557	6	7	86
8558	6	8	86
8559	6	9	86
8560	6	10	86
8561	7	1	86
8562	7	2	86
8563	7	3	86
8564	7	4	86
8565	7	5	86
8566	7	6	86
8567	7	7	86
8568	7	8	86
8569	7	9	86
8570	7	10	86
8571	8	1	86
8572	8	2	86
8573	8	3	86
8574	8	4	86
8575	8	5	86
8576	8	6	86
8577	8	7	86
8578	8	8	86
8579	8	9	86
8580	8	10	86
8581	9	1	86
8582	9	2	86
8583	9	3	86
8584	9	4	86
8585	9	5	86
8586	9	6	86
8587	9	7	86
8588	9	8	86
8589	9	9	86
8590	9	10	86
8591	10	1	86
8592	10	2	86
8593	10	3	86
8594	10	4	86
8595	10	5	86
8596	10	6	86
8597	10	7	86
8598	10	8	86
8599	10	9	86
8600	10	10	86
8601	1	1	87
8602	1	2	87
8603	1	3	87
8604	1	4	87
8605	1	5	87
8606	1	6	87
8607	1	7	87
8608	1	8	87
8609	1	9	87
8610	1	10	87
8611	2	1	87
8612	2	2	87
8613	2	3	87
8614	2	4	87
8615	2	5	87
8616	2	6	87
8617	2	7	87
8618	2	8	87
8619	2	9	87
8620	2	10	87
8621	3	1	87
8622	3	2	87
8623	3	3	87
8624	3	4	87
8625	3	5	87
8626	3	6	87
8627	3	7	87
8628	3	8	87
8629	3	9	87
8630	3	10	87
8631	4	1	87
8632	4	2	87
8633	4	3	87
8634	4	4	87
8635	4	5	87
8636	4	6	87
8637	4	7	87
8638	4	8	87
8639	4	9	87
8640	4	10	87
8641	5	1	87
8642	5	2	87
8643	5	3	87
8644	5	4	87
8645	5	5	87
8646	5	6	87
8647	5	7	87
8648	5	8	87
8649	5	9	87
8650	5	10	87
8651	6	1	87
8652	6	2	87
8653	6	3	87
8654	6	4	87
8655	6	5	87
8656	6	6	87
8657	6	7	87
8658	6	8	87
8659	6	9	87
8660	6	10	87
8661	7	1	87
8662	7	2	87
8663	7	3	87
8664	7	4	87
8665	7	5	87
8666	7	6	87
8667	7	7	87
8668	7	8	87
8669	7	9	87
8670	7	10	87
8671	8	1	87
8672	8	2	87
8673	8	3	87
8674	8	4	87
8675	8	5	87
8676	8	6	87
8677	8	7	87
8678	8	8	87
8679	8	9	87
8680	8	10	87
8681	9	1	87
8682	9	2	87
8683	9	3	87
8684	9	4	87
8685	9	5	87
8686	9	6	87
8687	9	7	87
8688	9	8	87
8689	9	9	87
8690	9	10	87
8691	10	1	87
8692	10	2	87
8693	10	3	87
8694	10	4	87
8695	10	5	87
8696	10	6	87
8697	10	7	87
8698	10	8	87
8699	10	9	87
8700	10	10	87
8701	1	1	88
8702	1	2	88
8703	1	3	88
8704	1	4	88
8705	1	5	88
8706	1	6	88
8707	1	7	88
8708	1	8	88
8709	1	9	88
8710	1	10	88
8711	2	1	88
8712	2	2	88
8713	2	3	88
8714	2	4	88
8715	2	5	88
8716	2	6	88
8717	2	7	88
8718	2	8	88
8719	2	9	88
8720	2	10	88
8721	3	1	88
8722	3	2	88
8723	3	3	88
8724	3	4	88
8725	3	5	88
8726	3	6	88
8727	3	7	88
8728	3	8	88
8729	3	9	88
8730	3	10	88
8731	4	1	88
8732	4	2	88
8733	4	3	88
8734	4	4	88
8735	4	5	88
8736	4	6	88
8737	4	7	88
8738	4	8	88
8739	4	9	88
8740	4	10	88
8741	5	1	88
8742	5	2	88
8743	5	3	88
8744	5	4	88
8745	5	5	88
8746	5	6	88
8747	5	7	88
8748	5	8	88
8749	5	9	88
8750	5	10	88
8751	6	1	88
8752	6	2	88
8753	6	3	88
8754	6	4	88
8755	6	5	88
8756	6	6	88
8757	6	7	88
8758	6	8	88
8759	6	9	88
8760	6	10	88
8761	7	1	88
8762	7	2	88
8763	7	3	88
8764	7	4	88
8765	7	5	88
8766	7	6	88
8767	7	7	88
8768	7	8	88
8769	7	9	88
8770	7	10	88
8771	8	1	88
8772	8	2	88
8773	8	3	88
8774	8	4	88
8775	8	5	88
8776	8	6	88
8777	8	7	88
8778	8	8	88
8779	8	9	88
8780	8	10	88
8781	9	1	88
8782	9	2	88
8783	9	3	88
8784	9	4	88
8785	9	5	88
8786	9	6	88
8787	9	7	88
8788	9	8	88
8789	9	9	88
8790	9	10	88
8791	10	1	88
8792	10	2	88
8793	10	3	88
8794	10	4	88
8795	10	5	88
8796	10	6	88
8797	10	7	88
8798	10	8	88
8799	10	9	88
8800	10	10	88
8801	1	1	89
8802	1	2	89
8803	1	3	89
8804	1	4	89
8805	1	5	89
8806	1	6	89
8807	1	7	89
8808	1	8	89
8809	1	9	89
8810	1	10	89
8811	2	1	89
8812	2	2	89
8813	2	3	89
8814	2	4	89
8815	2	5	89
8816	2	6	89
8817	2	7	89
8818	2	8	89
8819	2	9	89
8820	2	10	89
8821	3	1	89
8822	3	2	89
8823	3	3	89
8824	3	4	89
8825	3	5	89
8826	3	6	89
8827	3	7	89
8828	3	8	89
8829	3	9	89
8830	3	10	89
8831	4	1	89
8832	4	2	89
8833	4	3	89
8834	4	4	89
8835	4	5	89
8836	4	6	89
8837	4	7	89
8838	4	8	89
8839	4	9	89
8840	4	10	89
8841	5	1	89
8842	5	2	89
8843	5	3	89
8844	5	4	89
8845	5	5	89
8846	5	6	89
8847	5	7	89
8848	5	8	89
8849	5	9	89
8850	5	10	89
8851	6	1	89
8852	6	2	89
8853	6	3	89
8854	6	4	89
8855	6	5	89
8856	6	6	89
8857	6	7	89
8858	6	8	89
8859	6	9	89
8860	6	10	89
8861	7	1	89
8862	7	2	89
8863	7	3	89
8864	7	4	89
8865	7	5	89
8866	7	6	89
8867	7	7	89
8868	7	8	89
8869	7	9	89
8870	7	10	89
8871	8	1	89
8872	8	2	89
8873	8	3	89
8874	8	4	89
8875	8	5	89
8876	8	6	89
8877	8	7	89
8878	8	8	89
8879	8	9	89
8880	8	10	89
8881	9	1	89
8882	9	2	89
8883	9	3	89
8884	9	4	89
8885	9	5	89
8886	9	6	89
8887	9	7	89
8888	9	8	89
8889	9	9	89
8890	9	10	89
8891	10	1	89
8892	10	2	89
8893	10	3	89
8894	10	4	89
8895	10	5	89
8896	10	6	89
8897	10	7	89
8898	10	8	89
8899	10	9	89
8900	10	10	89
8901	1	1	90
8902	1	2	90
8903	1	3	90
8904	1	4	90
8905	1	5	90
8906	1	6	90
8907	1	7	90
8908	1	8	90
8909	1	9	90
8910	1	10	90
8911	2	1	90
8912	2	2	90
8913	2	3	90
8914	2	4	90
8915	2	5	90
8916	2	6	90
8917	2	7	90
8918	2	8	90
8919	2	9	90
8920	2	10	90
8921	3	1	90
8922	3	2	90
8923	3	3	90
8924	3	4	90
8925	3	5	90
8926	3	6	90
8927	3	7	90
8928	3	8	90
8929	3	9	90
8930	3	10	90
8931	4	1	90
8932	4	2	90
8933	4	3	90
8934	4	4	90
8935	4	5	90
8936	4	6	90
8937	4	7	90
8938	4	8	90
8939	4	9	90
8940	4	10	90
8941	5	1	90
8942	5	2	90
8943	5	3	90
8944	5	4	90
8945	5	5	90
8946	5	6	90
8947	5	7	90
8948	5	8	90
8949	5	9	90
8950	5	10	90
8951	6	1	90
8952	6	2	90
8953	6	3	90
8954	6	4	90
8955	6	5	90
8956	6	6	90
8957	6	7	90
8958	6	8	90
8959	6	9	90
8960	6	10	90
8961	7	1	90
8962	7	2	90
8963	7	3	90
8964	7	4	90
8965	7	5	90
8966	7	6	90
8967	7	7	90
8968	7	8	90
8969	7	9	90
8970	7	10	90
8971	8	1	90
8972	8	2	90
8973	8	3	90
8974	8	4	90
8975	8	5	90
8976	8	6	90
8977	8	7	90
8978	8	8	90
8979	8	9	90
8980	8	10	90
8981	9	1	90
8982	9	2	90
8983	9	3	90
8984	9	4	90
8985	9	5	90
8986	9	6	90
8987	9	7	90
8988	9	8	90
8989	9	9	90
8990	9	10	90
8991	10	1	90
8992	10	2	90
8993	10	3	90
8994	10	4	90
8995	10	5	90
8996	10	6	90
8997	10	7	90
8998	10	8	90
8999	10	9	90
9000	10	10	90
9001	1	1	91
9002	1	2	91
9003	1	3	91
9004	1	4	91
9005	1	5	91
9006	1	6	91
9007	1	7	91
9008	1	8	91
9009	1	9	91
9010	1	10	91
9011	2	1	91
9012	2	2	91
9013	2	3	91
9014	2	4	91
9015	2	5	91
9016	2	6	91
9017	2	7	91
9018	2	8	91
9019	2	9	91
9020	2	10	91
9021	3	1	91
9022	3	2	91
9023	3	3	91
9024	3	4	91
9025	3	5	91
9026	3	6	91
9027	3	7	91
9028	3	8	91
9029	3	9	91
9030	3	10	91
9031	4	1	91
9032	4	2	91
9033	4	3	91
9034	4	4	91
9035	4	5	91
9036	4	6	91
9037	4	7	91
9038	4	8	91
9039	4	9	91
9040	4	10	91
9041	5	1	91
9042	5	2	91
9043	5	3	91
9044	5	4	91
9045	5	5	91
9046	5	6	91
9047	5	7	91
9048	5	8	91
9049	5	9	91
9050	5	10	91
9051	6	1	91
9052	6	2	91
9053	6	3	91
9054	6	4	91
9055	6	5	91
9056	6	6	91
9057	6	7	91
9058	6	8	91
9059	6	9	91
9060	6	10	91
9061	7	1	91
9062	7	2	91
9063	7	3	91
9064	7	4	91
9065	7	5	91
9066	7	6	91
9067	7	7	91
9068	7	8	91
9069	7	9	91
9070	7	10	91
9071	8	1	91
9072	8	2	91
9073	8	3	91
9074	8	4	91
9075	8	5	91
9076	8	6	91
9077	8	7	91
9078	8	8	91
9079	8	9	91
9080	8	10	91
9081	9	1	91
9082	9	2	91
9083	9	3	91
9084	9	4	91
9085	9	5	91
9086	9	6	91
9087	9	7	91
9088	9	8	91
9089	9	9	91
9090	9	10	91
9091	10	1	91
9092	10	2	91
9093	10	3	91
9094	10	4	91
9095	10	5	91
9096	10	6	91
9097	10	7	91
9098	10	8	91
9099	10	9	91
9100	10	10	91
9101	1	1	92
9102	1	2	92
9103	1	3	92
9104	1	4	92
9105	1	5	92
9106	1	6	92
9107	1	7	92
9108	1	8	92
9109	1	9	92
9110	1	10	92
9111	2	1	92
9112	2	2	92
9113	2	3	92
9114	2	4	92
9115	2	5	92
9116	2	6	92
9117	2	7	92
9118	2	8	92
9119	2	9	92
9120	2	10	92
9121	3	1	92
9122	3	2	92
9123	3	3	92
9124	3	4	92
9125	3	5	92
9126	3	6	92
9127	3	7	92
9128	3	8	92
9129	3	9	92
9130	3	10	92
9131	4	1	92
9132	4	2	92
9133	4	3	92
9134	4	4	92
9135	4	5	92
9136	4	6	92
9137	4	7	92
9138	4	8	92
9139	4	9	92
9140	4	10	92
9141	5	1	92
9142	5	2	92
9143	5	3	92
9144	5	4	92
9145	5	5	92
9146	5	6	92
9147	5	7	92
9148	5	8	92
9149	5	9	92
9150	5	10	92
9151	6	1	92
9152	6	2	92
9153	6	3	92
9154	6	4	92
9155	6	5	92
9156	6	6	92
9157	6	7	92
9158	6	8	92
9159	6	9	92
9160	6	10	92
9161	7	1	92
9162	7	2	92
9163	7	3	92
9164	7	4	92
9165	7	5	92
9166	7	6	92
9167	7	7	92
9168	7	8	92
9169	7	9	92
9170	7	10	92
9171	8	1	92
9172	8	2	92
9173	8	3	92
9174	8	4	92
9175	8	5	92
9176	8	6	92
9177	8	7	92
9178	8	8	92
9179	8	9	92
9180	8	10	92
9181	9	1	92
9182	9	2	92
9183	9	3	92
9184	9	4	92
9185	9	5	92
9186	9	6	92
9187	9	7	92
9188	9	8	92
9189	9	9	92
9190	9	10	92
9191	10	1	92
9192	10	2	92
9193	10	3	92
9194	10	4	92
9195	10	5	92
9196	10	6	92
9197	10	7	92
9198	10	8	92
9199	10	9	92
9200	10	10	92
9201	1	1	93
9202	1	2	93
9203	1	3	93
9204	1	4	93
9205	1	5	93
9206	1	6	93
9207	1	7	93
9208	1	8	93
9209	1	9	93
9210	1	10	93
9211	2	1	93
9212	2	2	93
9213	2	3	93
9214	2	4	93
9215	2	5	93
9216	2	6	93
9217	2	7	93
9218	2	8	93
9219	2	9	93
9220	2	10	93
9221	3	1	93
9222	3	2	93
9223	3	3	93
9224	3	4	93
9225	3	5	93
9226	3	6	93
9227	3	7	93
9228	3	8	93
9229	3	9	93
9230	3	10	93
9231	4	1	93
9232	4	2	93
9233	4	3	93
9234	4	4	93
9235	4	5	93
9236	4	6	93
9237	4	7	93
9238	4	8	93
9239	4	9	93
9240	4	10	93
9241	5	1	93
9242	5	2	93
9243	5	3	93
9244	5	4	93
9245	5	5	93
9246	5	6	93
9247	5	7	93
9248	5	8	93
9249	5	9	93
9250	5	10	93
9251	6	1	93
9252	6	2	93
9253	6	3	93
9254	6	4	93
9255	6	5	93
9256	6	6	93
9257	6	7	93
9258	6	8	93
9259	6	9	93
9260	6	10	93
9261	7	1	93
9262	7	2	93
9263	7	3	93
9264	7	4	93
9265	7	5	93
9266	7	6	93
9267	7	7	93
9268	7	8	93
9269	7	9	93
9270	7	10	93
9271	8	1	93
9272	8	2	93
9273	8	3	93
9274	8	4	93
9275	8	5	93
9276	8	6	93
9277	8	7	93
9278	8	8	93
9279	8	9	93
9280	8	10	93
9281	9	1	93
9282	9	2	93
9283	9	3	93
9284	9	4	93
9285	9	5	93
9286	9	6	93
9287	9	7	93
9288	9	8	93
9289	9	9	93
9290	9	10	93
9291	10	1	93
9292	10	2	93
9293	10	3	93
9294	10	4	93
9295	10	5	93
9296	10	6	93
9297	10	7	93
9298	10	8	93
9299	10	9	93
9300	10	10	93
9301	1	1	94
9302	1	2	94
9303	1	3	94
9304	1	4	94
9305	1	5	94
9306	1	6	94
9307	1	7	94
9308	1	8	94
9309	1	9	94
9310	1	10	94
9311	2	1	94
9312	2	2	94
9313	2	3	94
9314	2	4	94
9315	2	5	94
9316	2	6	94
9317	2	7	94
9318	2	8	94
9319	2	9	94
9320	2	10	94
9321	3	1	94
9322	3	2	94
9323	3	3	94
9324	3	4	94
9325	3	5	94
9326	3	6	94
9327	3	7	94
9328	3	8	94
9329	3	9	94
9330	3	10	94
9331	4	1	94
9332	4	2	94
9333	4	3	94
9334	4	4	94
9335	4	5	94
9336	4	6	94
9337	4	7	94
9338	4	8	94
9339	4	9	94
9340	4	10	94
9341	5	1	94
9342	5	2	94
9343	5	3	94
9344	5	4	94
9345	5	5	94
9346	5	6	94
9347	5	7	94
9348	5	8	94
9349	5	9	94
9350	5	10	94
9351	6	1	94
9352	6	2	94
9353	6	3	94
9354	6	4	94
9355	6	5	94
9356	6	6	94
9357	6	7	94
9358	6	8	94
9359	6	9	94
9360	6	10	94
9361	7	1	94
9362	7	2	94
9363	7	3	94
9364	7	4	94
9365	7	5	94
9366	7	6	94
9367	7	7	94
9368	7	8	94
9369	7	9	94
9370	7	10	94
9371	8	1	94
9372	8	2	94
9373	8	3	94
9374	8	4	94
9375	8	5	94
9376	8	6	94
9377	8	7	94
9378	8	8	94
9379	8	9	94
9380	8	10	94
9381	9	1	94
9382	9	2	94
9383	9	3	94
9384	9	4	94
9385	9	5	94
9386	9	6	94
9387	9	7	94
9388	9	8	94
9389	9	9	94
9390	9	10	94
9391	10	1	94
9392	10	2	94
9393	10	3	94
9394	10	4	94
9395	10	5	94
9396	10	6	94
9397	10	7	94
9398	10	8	94
9399	10	9	94
9400	10	10	94
9401	1	1	95
9402	1	2	95
9403	1	3	95
9404	1	4	95
9405	1	5	95
9406	1	6	95
9407	1	7	95
9408	1	8	95
9409	1	9	95
9410	1	10	95
9411	2	1	95
9412	2	2	95
9413	2	3	95
9414	2	4	95
9415	2	5	95
9416	2	6	95
9417	2	7	95
9418	2	8	95
9419	2	9	95
9420	2	10	95
9421	3	1	95
9422	3	2	95
9423	3	3	95
9424	3	4	95
9425	3	5	95
9426	3	6	95
9427	3	7	95
9428	3	8	95
9429	3	9	95
9430	3	10	95
9431	4	1	95
9432	4	2	95
9433	4	3	95
9434	4	4	95
9435	4	5	95
9436	4	6	95
9437	4	7	95
9438	4	8	95
9439	4	9	95
9440	4	10	95
9441	5	1	95
9442	5	2	95
9443	5	3	95
9444	5	4	95
9445	5	5	95
9446	5	6	95
9447	5	7	95
9448	5	8	95
9449	5	9	95
9450	5	10	95
9451	6	1	95
9452	6	2	95
9453	6	3	95
9454	6	4	95
9455	6	5	95
9456	6	6	95
9457	6	7	95
9458	6	8	95
9459	6	9	95
9460	6	10	95
9461	7	1	95
9462	7	2	95
9463	7	3	95
9464	7	4	95
9465	7	5	95
9466	7	6	95
9467	7	7	95
9468	7	8	95
9469	7	9	95
9470	7	10	95
9471	8	1	95
9472	8	2	95
9473	8	3	95
9474	8	4	95
9475	8	5	95
9476	8	6	95
9477	8	7	95
9478	8	8	95
9479	8	9	95
9480	8	10	95
9481	9	1	95
9482	9	2	95
9483	9	3	95
9484	9	4	95
9485	9	5	95
9486	9	6	95
9487	9	7	95
9488	9	8	95
9489	9	9	95
9490	9	10	95
9491	10	1	95
9492	10	2	95
9493	10	3	95
9494	10	4	95
9495	10	5	95
9496	10	6	95
9497	10	7	95
9498	10	8	95
9499	10	9	95
9500	10	10	95
9501	1	1	96
9502	1	2	96
9503	1	3	96
9504	1	4	96
9505	1	5	96
9506	1	6	96
9507	1	7	96
9508	1	8	96
9509	1	9	96
9510	1	10	96
9511	2	1	96
9512	2	2	96
9513	2	3	96
9514	2	4	96
9515	2	5	96
9516	2	6	96
9517	2	7	96
9518	2	8	96
9519	2	9	96
9520	2	10	96
9521	3	1	96
9522	3	2	96
9523	3	3	96
9524	3	4	96
9525	3	5	96
9526	3	6	96
9527	3	7	96
9528	3	8	96
9529	3	9	96
9530	3	10	96
9531	4	1	96
9532	4	2	96
9533	4	3	96
9534	4	4	96
9535	4	5	96
9536	4	6	96
9537	4	7	96
9538	4	8	96
9539	4	9	96
9540	4	10	96
9541	5	1	96
9542	5	2	96
9543	5	3	96
9544	5	4	96
9545	5	5	96
9546	5	6	96
9547	5	7	96
9548	5	8	96
9549	5	9	96
9550	5	10	96
9551	6	1	96
9552	6	2	96
9553	6	3	96
9554	6	4	96
9555	6	5	96
9556	6	6	96
9557	6	7	96
9558	6	8	96
9559	6	9	96
9560	6	10	96
9561	7	1	96
9562	7	2	96
9563	7	3	96
9564	7	4	96
9565	7	5	96
9566	7	6	96
9567	7	7	96
9568	7	8	96
9569	7	9	96
9570	7	10	96
9571	8	1	96
9572	8	2	96
9573	8	3	96
9574	8	4	96
9575	8	5	96
9576	8	6	96
9577	8	7	96
9578	8	8	96
9579	8	9	96
9580	8	10	96
9581	9	1	96
9582	9	2	96
9583	9	3	96
9584	9	4	96
9585	9	5	96
9586	9	6	96
9587	9	7	96
9588	9	8	96
9589	9	9	96
9590	9	10	96
9591	10	1	96
9592	10	2	96
9593	10	3	96
9594	10	4	96
9595	10	5	96
9596	10	6	96
9597	10	7	96
9598	10	8	96
9599	10	9	96
9600	10	10	96
9601	1	1	97
9602	1	2	97
9603	1	3	97
9604	1	4	97
9605	1	5	97
9606	1	6	97
9607	1	7	97
9608	1	8	97
9609	1	9	97
9610	1	10	97
9611	2	1	97
9612	2	2	97
9613	2	3	97
9614	2	4	97
9615	2	5	97
9616	2	6	97
9617	2	7	97
9618	2	8	97
9619	2	9	97
9620	2	10	97
9621	3	1	97
9622	3	2	97
9623	3	3	97
9624	3	4	97
9625	3	5	97
9626	3	6	97
9627	3	7	97
9628	3	8	97
9629	3	9	97
9630	3	10	97
9631	4	1	97
9632	4	2	97
9633	4	3	97
9634	4	4	97
9635	4	5	97
9636	4	6	97
9637	4	7	97
9638	4	8	97
9639	4	9	97
9640	4	10	97
9641	5	1	97
9642	5	2	97
9643	5	3	97
9644	5	4	97
9645	5	5	97
9646	5	6	97
9647	5	7	97
9648	5	8	97
9649	5	9	97
9650	5	10	97
9651	6	1	97
9652	6	2	97
9653	6	3	97
9654	6	4	97
9655	6	5	97
9656	6	6	97
9657	6	7	97
9658	6	8	97
9659	6	9	97
9660	6	10	97
9661	7	1	97
9662	7	2	97
9663	7	3	97
9664	7	4	97
9665	7	5	97
9666	7	6	97
9667	7	7	97
9668	7	8	97
9669	7	9	97
9670	7	10	97
9671	8	1	97
9672	8	2	97
9673	8	3	97
9674	8	4	97
9675	8	5	97
9676	8	6	97
9677	8	7	97
9678	8	8	97
9679	8	9	97
9680	8	10	97
9681	9	1	97
9682	9	2	97
9683	9	3	97
9684	9	4	97
9685	9	5	97
9686	9	6	97
9687	9	7	97
9688	9	8	97
9689	9	9	97
9690	9	10	97
9691	10	1	97
9692	10	2	97
9693	10	3	97
9694	10	4	97
9695	10	5	97
9696	10	6	97
9697	10	7	97
9698	10	8	97
9699	10	9	97
9700	10	10	97
9701	1	1	98
9702	1	2	98
9703	1	3	98
9704	1	4	98
9705	1	5	98
9706	1	6	98
9707	1	7	98
9708	1	8	98
9709	1	9	98
9710	1	10	98
9711	2	1	98
9712	2	2	98
9713	2	3	98
9714	2	4	98
9715	2	5	98
9716	2	6	98
9717	2	7	98
9718	2	8	98
9719	2	9	98
9720	2	10	98
9721	3	1	98
9722	3	2	98
9723	3	3	98
9724	3	4	98
9725	3	5	98
9726	3	6	98
9727	3	7	98
9728	3	8	98
9729	3	9	98
9730	3	10	98
9731	4	1	98
9732	4	2	98
9733	4	3	98
9734	4	4	98
9735	4	5	98
9736	4	6	98
9737	4	7	98
9738	4	8	98
9739	4	9	98
9740	4	10	98
9741	5	1	98
9742	5	2	98
9743	5	3	98
9744	5	4	98
9745	5	5	98
9746	5	6	98
9747	5	7	98
9748	5	8	98
9749	5	9	98
9750	5	10	98
9751	6	1	98
9752	6	2	98
9753	6	3	98
9754	6	4	98
9755	6	5	98
9756	6	6	98
9757	6	7	98
9758	6	8	98
9759	6	9	98
9760	6	10	98
9761	7	1	98
9762	7	2	98
9763	7	3	98
9764	7	4	98
9765	7	5	98
9766	7	6	98
9767	7	7	98
9768	7	8	98
9769	7	9	98
9770	7	10	98
9771	8	1	98
9772	8	2	98
9773	8	3	98
9774	8	4	98
9775	8	5	98
9776	8	6	98
9777	8	7	98
9778	8	8	98
9779	8	9	98
9780	8	10	98
9781	9	1	98
9782	9	2	98
9783	9	3	98
9784	9	4	98
9785	9	5	98
9786	9	6	98
9787	9	7	98
9788	9	8	98
9789	9	9	98
9790	9	10	98
9791	10	1	98
9792	10	2	98
9793	10	3	98
9794	10	4	98
9795	10	5	98
9796	10	6	98
9797	10	7	98
9798	10	8	98
9799	10	9	98
9800	10	10	98
9801	1	1	99
9802	1	2	99
9803	1	3	99
9804	1	4	99
9805	1	5	99
9806	1	6	99
9807	1	7	99
9808	1	8	99
9809	1	9	99
9810	1	10	99
9811	2	1	99
9812	2	2	99
9813	2	3	99
9814	2	4	99
9815	2	5	99
9816	2	6	99
9817	2	7	99
9818	2	8	99
9819	2	9	99
9820	2	10	99
9821	3	1	99
9822	3	2	99
9823	3	3	99
9824	3	4	99
9825	3	5	99
9826	3	6	99
9827	3	7	99
9828	3	8	99
9829	3	9	99
9830	3	10	99
9831	4	1	99
9832	4	2	99
9833	4	3	99
9834	4	4	99
9835	4	5	99
9836	4	6	99
9837	4	7	99
9838	4	8	99
9839	4	9	99
9840	4	10	99
9841	5	1	99
9842	5	2	99
9843	5	3	99
9844	5	4	99
9845	5	5	99
9846	5	6	99
9847	5	7	99
9848	5	8	99
9849	5	9	99
9850	5	10	99
9851	6	1	99
9852	6	2	99
9853	6	3	99
9854	6	4	99
9855	6	5	99
9856	6	6	99
9857	6	7	99
9858	6	8	99
9859	6	9	99
9860	6	10	99
9861	7	1	99
9862	7	2	99
9863	7	3	99
9864	7	4	99
9865	7	5	99
9866	7	6	99
9867	7	7	99
9868	7	8	99
9869	7	9	99
9870	7	10	99
9871	8	1	99
9872	8	2	99
9873	8	3	99
9874	8	4	99
9875	8	5	99
9876	8	6	99
9877	8	7	99
9878	8	8	99
9879	8	9	99
9880	8	10	99
9881	9	1	99
9882	9	2	99
9883	9	3	99
9884	9	4	99
9885	9	5	99
9886	9	6	99
9887	9	7	99
9888	9	8	99
9889	9	9	99
9890	9	10	99
9891	10	1	99
9892	10	2	99
9893	10	3	99
9894	10	4	99
9895	10	5	99
9896	10	6	99
9897	10	7	99
9898	10	8	99
9899	10	9	99
9900	10	10	99
9901	1	1	100
9902	1	2	100
9903	1	3	100
9904	1	4	100
9905	1	5	100
9906	1	6	100
9907	1	7	100
9908	1	8	100
9909	1	9	100
9910	1	10	100
9911	2	1	100
9912	2	2	100
9913	2	3	100
9914	2	4	100
9915	2	5	100
9916	2	6	100
9917	2	7	100
9918	2	8	100
9919	2	9	100
9920	2	10	100
9921	3	1	100
9922	3	2	100
9923	3	3	100
9924	3	4	100
9925	3	5	100
9926	3	6	100
9927	3	7	100
9928	3	8	100
9929	3	9	100
9930	3	10	100
9931	4	1	100
9932	4	2	100
9933	4	3	100
9934	4	4	100
9935	4	5	100
9936	4	6	100
9937	4	7	100
9938	4	8	100
9939	4	9	100
9940	4	10	100
9941	5	1	100
9942	5	2	100
9943	5	3	100
9944	5	4	100
9945	5	5	100
9946	5	6	100
9947	5	7	100
9948	5	8	100
9949	5	9	100
9950	5	10	100
9951	6	1	100
9952	6	2	100
9953	6	3	100
9954	6	4	100
9955	6	5	100
9956	6	6	100
9957	6	7	100
9958	6	8	100
9959	6	9	100
9960	6	10	100
9961	7	1	100
9962	7	2	100
9963	7	3	100
9964	7	4	100
9965	7	5	100
9966	7	6	100
9967	7	7	100
9968	7	8	100
9969	7	9	100
9970	7	10	100
9971	8	1	100
9972	8	2	100
9973	8	3	100
9974	8	4	100
9975	8	5	100
9976	8	6	100
9977	8	7	100
9978	8	8	100
9979	8	9	100
9980	8	10	100
9981	9	1	100
9982	9	2	100
9983	9	3	100
9984	9	4	100
9985	9	5	100
9986	9	6	100
9987	9	7	100
9988	9	8	100
9989	9	9	100
9990	9	10	100
9991	10	1	100
9992	10	2	100
9993	10	3	100
9994	10	4	100
9995	10	5	100
9996	10	6	100
9997	10	7	100
9998	10	8	100
9999	10	9	100
10000	10	10	100
10001	1	1	101
10002	1	2	101
10003	1	3	101
10004	1	4	101
10005	1	5	101
10006	1	6	101
10007	1	7	101
10008	1	8	101
10009	1	9	101
10010	1	10	101
10011	2	1	101
10012	2	2	101
10013	2	3	101
10014	2	4	101
10015	2	5	101
10016	2	6	101
10017	2	7	101
10018	2	8	101
10019	2	9	101
10020	2	10	101
10021	3	1	101
10022	3	2	101
10023	3	3	101
10024	3	4	101
10025	3	5	101
10026	3	6	101
10027	3	7	101
10028	3	8	101
10029	3	9	101
10030	3	10	101
10031	4	1	101
10032	4	2	101
10033	4	3	101
10034	4	4	101
10035	4	5	101
10036	4	6	101
10037	4	7	101
10038	4	8	101
10039	4	9	101
10040	4	10	101
10041	5	1	101
10042	5	2	101
10043	5	3	101
10044	5	4	101
10045	5	5	101
10046	5	6	101
10047	5	7	101
10048	5	8	101
10049	5	9	101
10050	5	10	101
10051	6	1	101
10052	6	2	101
10053	6	3	101
10054	6	4	101
10055	6	5	101
10056	6	6	101
10057	6	7	101
10058	6	8	101
10059	6	9	101
10060	6	10	101
10061	7	1	101
10062	7	2	101
10063	7	3	101
10064	7	4	101
10065	7	5	101
10066	7	6	101
10067	7	7	101
10068	7	8	101
10069	7	9	101
10070	7	10	101
10071	8	1	101
10072	8	2	101
10073	8	3	101
10074	8	4	101
10075	8	5	101
10076	8	6	101
10077	8	7	101
10078	8	8	101
10079	8	9	101
10080	8	10	101
10081	9	1	101
10082	9	2	101
10083	9	3	101
10084	9	4	101
10085	9	5	101
10086	9	6	101
10087	9	7	101
10088	9	8	101
10089	9	9	101
10090	9	10	101
10091	10	1	101
10092	10	2	101
10093	10	3	101
10094	10	4	101
10095	10	5	101
10096	10	6	101
10097	10	7	101
10098	10	8	101
10099	10	9	101
10100	10	10	101
10101	1	1	102
10102	1	2	102
10103	1	3	102
10104	1	4	102
10105	1	5	102
10106	1	6	102
10107	1	7	102
10108	1	8	102
10109	1	9	102
10110	1	10	102
10111	2	1	102
10112	2	2	102
10113	2	3	102
10114	2	4	102
10115	2	5	102
10116	2	6	102
10117	2	7	102
10118	2	8	102
10119	2	9	102
10120	2	10	102
10121	3	1	102
10122	3	2	102
10123	3	3	102
10124	3	4	102
10125	3	5	102
10126	3	6	102
10127	3	7	102
10128	3	8	102
10129	3	9	102
10130	3	10	102
10131	4	1	102
10132	4	2	102
10133	4	3	102
10134	4	4	102
10135	4	5	102
10136	4	6	102
10137	4	7	102
10138	4	8	102
10139	4	9	102
10140	4	10	102
10141	5	1	102
10142	5	2	102
10143	5	3	102
10144	5	4	102
10145	5	5	102
10146	5	6	102
10147	5	7	102
10148	5	8	102
10149	5	9	102
10150	5	10	102
10151	6	1	102
10152	6	2	102
10153	6	3	102
10154	6	4	102
10155	6	5	102
10156	6	6	102
10157	6	7	102
10158	6	8	102
10159	6	9	102
10160	6	10	102
10161	7	1	102
10162	7	2	102
10163	7	3	102
10164	7	4	102
10165	7	5	102
10166	7	6	102
10167	7	7	102
10168	7	8	102
10169	7	9	102
10170	7	10	102
10171	8	1	102
10172	8	2	102
10173	8	3	102
10174	8	4	102
10175	8	5	102
10176	8	6	102
10177	8	7	102
10178	8	8	102
10179	8	9	102
10180	8	10	102
10181	9	1	102
10182	9	2	102
10183	9	3	102
10184	9	4	102
10185	9	5	102
10186	9	6	102
10187	9	7	102
10188	9	8	102
10189	9	9	102
10190	9	10	102
10191	10	1	102
10192	10	2	102
10193	10	3	102
10194	10	4	102
10195	10	5	102
10196	10	6	102
10197	10	7	102
10198	10	8	102
10199	10	9	102
10200	10	10	102
10201	1	1	103
10202	1	2	103
10203	1	3	103
10204	1	4	103
10205	1	5	103
10206	1	6	103
10207	1	7	103
10208	1	8	103
10209	1	9	103
10210	1	10	103
10211	2	1	103
10212	2	2	103
10213	2	3	103
10214	2	4	103
10215	2	5	103
10216	2	6	103
10217	2	7	103
10218	2	8	103
10219	2	9	103
10220	2	10	103
10221	3	1	103
10222	3	2	103
10223	3	3	103
10224	3	4	103
10225	3	5	103
10226	3	6	103
10227	3	7	103
10228	3	8	103
10229	3	9	103
10230	3	10	103
10231	4	1	103
10232	4	2	103
10233	4	3	103
10234	4	4	103
10235	4	5	103
10236	4	6	103
10237	4	7	103
10238	4	8	103
10239	4	9	103
10240	4	10	103
10241	5	1	103
10242	5	2	103
10243	5	3	103
10244	5	4	103
10245	5	5	103
10246	5	6	103
10247	5	7	103
10248	5	8	103
10249	5	9	103
10250	5	10	103
10251	6	1	103
10252	6	2	103
10253	6	3	103
10254	6	4	103
10255	6	5	103
10256	6	6	103
10257	6	7	103
10258	6	8	103
10259	6	9	103
10260	6	10	103
10261	7	1	103
10262	7	2	103
10263	7	3	103
10264	7	4	103
10265	7	5	103
10266	7	6	103
10267	7	7	103
10268	7	8	103
10269	7	9	103
10270	7	10	103
10271	8	1	103
10272	8	2	103
10273	8	3	103
10274	8	4	103
10275	8	5	103
10276	8	6	103
10277	8	7	103
10278	8	8	103
10279	8	9	103
10280	8	10	103
10281	9	1	103
10282	9	2	103
10283	9	3	103
10284	9	4	103
10285	9	5	103
10286	9	6	103
10287	9	7	103
10288	9	8	103
10289	9	9	103
10290	9	10	103
10291	10	1	103
10292	10	2	103
10293	10	3	103
10294	10	4	103
10295	10	5	103
10296	10	6	103
10297	10	7	103
10298	10	8	103
10299	10	9	103
10300	10	10	103
10301	1	1	104
10302	1	2	104
10303	1	3	104
10304	1	4	104
10305	1	5	104
10306	1	6	104
10307	1	7	104
10308	1	8	104
10309	1	9	104
10310	1	10	104
10311	2	1	104
10312	2	2	104
10313	2	3	104
10314	2	4	104
10315	2	5	104
10316	2	6	104
10317	2	7	104
10318	2	8	104
10319	2	9	104
10320	2	10	104
10321	3	1	104
10322	3	2	104
10323	3	3	104
10324	3	4	104
10325	3	5	104
10326	3	6	104
10327	3	7	104
10328	3	8	104
10329	3	9	104
10330	3	10	104
10331	4	1	104
10332	4	2	104
10333	4	3	104
10334	4	4	104
10335	4	5	104
10336	4	6	104
10337	4	7	104
10338	4	8	104
10339	4	9	104
10340	4	10	104
10341	5	1	104
10342	5	2	104
10343	5	3	104
10344	5	4	104
10345	5	5	104
10346	5	6	104
10347	5	7	104
10348	5	8	104
10349	5	9	104
10350	5	10	104
10351	6	1	104
10352	6	2	104
10353	6	3	104
10354	6	4	104
10355	6	5	104
10356	6	6	104
10357	6	7	104
10358	6	8	104
10359	6	9	104
10360	6	10	104
10361	7	1	104
10362	7	2	104
10363	7	3	104
10364	7	4	104
10365	7	5	104
10366	7	6	104
10367	7	7	104
10368	7	8	104
10369	7	9	104
10370	7	10	104
10371	8	1	104
10372	8	2	104
10373	8	3	104
10374	8	4	104
10375	8	5	104
10376	8	6	104
10377	8	7	104
10378	8	8	104
10379	8	9	104
10380	8	10	104
10381	9	1	104
10382	9	2	104
10383	9	3	104
10384	9	4	104
10385	9	5	104
10386	9	6	104
10387	9	7	104
10388	9	8	104
10389	9	9	104
10390	9	10	104
10391	10	1	104
10392	10	2	104
10393	10	3	104
10394	10	4	104
10395	10	5	104
10396	10	6	104
10397	10	7	104
10398	10	8	104
10399	10	9	104
10400	10	10	104
10401	1	1	105
10402	1	2	105
10403	1	3	105
10404	1	4	105
10405	1	5	105
10406	1	6	105
10407	1	7	105
10408	1	8	105
10409	1	9	105
10410	1	10	105
10411	2	1	105
10412	2	2	105
10413	2	3	105
10414	2	4	105
10415	2	5	105
10416	2	6	105
10417	2	7	105
10418	2	8	105
10419	2	9	105
10420	2	10	105
10421	3	1	105
10422	3	2	105
10423	3	3	105
10424	3	4	105
10425	3	5	105
10426	3	6	105
10427	3	7	105
10428	3	8	105
10429	3	9	105
10430	3	10	105
10431	4	1	105
10432	4	2	105
10433	4	3	105
10434	4	4	105
10435	4	5	105
10436	4	6	105
10437	4	7	105
10438	4	8	105
10439	4	9	105
10440	4	10	105
10441	5	1	105
10442	5	2	105
10443	5	3	105
10444	5	4	105
10445	5	5	105
10446	5	6	105
10447	5	7	105
10448	5	8	105
10449	5	9	105
10450	5	10	105
10451	6	1	105
10452	6	2	105
10453	6	3	105
10454	6	4	105
10455	6	5	105
10456	6	6	105
10457	6	7	105
10458	6	8	105
10459	6	9	105
10460	6	10	105
10461	7	1	105
10462	7	2	105
10463	7	3	105
10464	7	4	105
10465	7	5	105
10466	7	6	105
10467	7	7	105
10468	7	8	105
10469	7	9	105
10470	7	10	105
10471	8	1	105
10472	8	2	105
10473	8	3	105
10474	8	4	105
10475	8	5	105
10476	8	6	105
10477	8	7	105
10478	8	8	105
10479	8	9	105
10480	8	10	105
10481	9	1	105
10482	9	2	105
10483	9	3	105
10484	9	4	105
10485	9	5	105
10486	9	6	105
10487	9	7	105
10488	9	8	105
10489	9	9	105
10490	9	10	105
10491	10	1	105
10492	10	2	105
10493	10	3	105
10494	10	4	105
10495	10	5	105
10496	10	6	105
10497	10	7	105
10498	10	8	105
10499	10	9	105
10500	10	10	105
10501	1	1	106
10502	1	2	106
10503	1	3	106
10504	1	4	106
10505	1	5	106
10506	1	6	106
10507	1	7	106
10508	1	8	106
10509	1	9	106
10510	1	10	106
10511	2	1	106
10512	2	2	106
10513	2	3	106
10514	2	4	106
10515	2	5	106
10516	2	6	106
10517	2	7	106
10518	2	8	106
10519	2	9	106
10520	2	10	106
10521	3	1	106
10522	3	2	106
10523	3	3	106
10524	3	4	106
10525	3	5	106
10526	3	6	106
10527	3	7	106
10528	3	8	106
10529	3	9	106
10530	3	10	106
10531	4	1	106
10532	4	2	106
10533	4	3	106
10534	4	4	106
10535	4	5	106
10536	4	6	106
10537	4	7	106
10538	4	8	106
10539	4	9	106
10540	4	10	106
10541	5	1	106
10542	5	2	106
10543	5	3	106
10544	5	4	106
10545	5	5	106
10546	5	6	106
10547	5	7	106
10548	5	8	106
10549	5	9	106
10550	5	10	106
10551	6	1	106
10552	6	2	106
10553	6	3	106
10554	6	4	106
10555	6	5	106
10556	6	6	106
10557	6	7	106
10558	6	8	106
10559	6	9	106
10560	6	10	106
10561	7	1	106
10562	7	2	106
10563	7	3	106
10564	7	4	106
10565	7	5	106
10566	7	6	106
10567	7	7	106
10568	7	8	106
10569	7	9	106
10570	7	10	106
10571	8	1	106
10572	8	2	106
10573	8	3	106
10574	8	4	106
10575	8	5	106
10576	8	6	106
10577	8	7	106
10578	8	8	106
10579	8	9	106
10580	8	10	106
10581	9	1	106
10582	9	2	106
10583	9	3	106
10584	9	4	106
10585	9	5	106
10586	9	6	106
10587	9	7	106
10588	9	8	106
10589	9	9	106
10590	9	10	106
10591	10	1	106
10592	10	2	106
10593	10	3	106
10594	10	4	106
10595	10	5	106
10596	10	6	106
10597	10	7	106
10598	10	8	106
10599	10	9	106
10600	10	10	106
10601	1	1	107
10602	1	2	107
10603	1	3	107
10604	1	4	107
10605	1	5	107
10606	1	6	107
10607	1	7	107
10608	1	8	107
10609	1	9	107
10610	1	10	107
10611	2	1	107
10612	2	2	107
10613	2	3	107
10614	2	4	107
10615	2	5	107
10616	2	6	107
10617	2	7	107
10618	2	8	107
10619	2	9	107
10620	2	10	107
10621	3	1	107
10622	3	2	107
10623	3	3	107
10624	3	4	107
10625	3	5	107
10626	3	6	107
10627	3	7	107
10628	3	8	107
10629	3	9	107
10630	3	10	107
10631	4	1	107
10632	4	2	107
10633	4	3	107
10634	4	4	107
10635	4	5	107
10636	4	6	107
10637	4	7	107
10638	4	8	107
10639	4	9	107
10640	4	10	107
10641	5	1	107
10642	5	2	107
10643	5	3	107
10644	5	4	107
10645	5	5	107
10646	5	6	107
10647	5	7	107
10648	5	8	107
10649	5	9	107
10650	5	10	107
10651	6	1	107
10652	6	2	107
10653	6	3	107
10654	6	4	107
10655	6	5	107
10656	6	6	107
10657	6	7	107
10658	6	8	107
10659	6	9	107
10660	6	10	107
10661	7	1	107
10662	7	2	107
10663	7	3	107
10664	7	4	107
10665	7	5	107
10666	7	6	107
10667	7	7	107
10668	7	8	107
10669	7	9	107
10670	7	10	107
10671	8	1	107
10672	8	2	107
10673	8	3	107
10674	8	4	107
10675	8	5	107
10676	8	6	107
10677	8	7	107
10678	8	8	107
10679	8	9	107
10680	8	10	107
10681	9	1	107
10682	9	2	107
10683	9	3	107
10684	9	4	107
10685	9	5	107
10686	9	6	107
10687	9	7	107
10688	9	8	107
10689	9	9	107
10690	9	10	107
10691	10	1	107
10692	10	2	107
10693	10	3	107
10694	10	4	107
10695	10	5	107
10696	10	6	107
10697	10	7	107
10698	10	8	107
10699	10	9	107
10700	10	10	107
10701	1	1	108
10702	1	2	108
10703	1	3	108
10704	1	4	108
10705	1	5	108
10706	1	6	108
10707	1	7	108
10708	1	8	108
10709	1	9	108
10710	1	10	108
10711	2	1	108
10712	2	2	108
10713	2	3	108
10714	2	4	108
10715	2	5	108
10716	2	6	108
10717	2	7	108
10718	2	8	108
10719	2	9	108
10720	2	10	108
10721	3	1	108
10722	3	2	108
10723	3	3	108
10724	3	4	108
10725	3	5	108
10726	3	6	108
10727	3	7	108
10728	3	8	108
10729	3	9	108
10730	3	10	108
10731	4	1	108
10732	4	2	108
10733	4	3	108
10734	4	4	108
10735	4	5	108
10736	4	6	108
10737	4	7	108
10738	4	8	108
10739	4	9	108
10740	4	10	108
10741	5	1	108
10742	5	2	108
10743	5	3	108
10744	5	4	108
10745	5	5	108
10746	5	6	108
10747	5	7	108
10748	5	8	108
10749	5	9	108
10750	5	10	108
10751	6	1	108
10752	6	2	108
10753	6	3	108
10754	6	4	108
10755	6	5	108
10756	6	6	108
10757	6	7	108
10758	6	8	108
10759	6	9	108
10760	6	10	108
10761	7	1	108
10762	7	2	108
10763	7	3	108
10764	7	4	108
10765	7	5	108
10766	7	6	108
10767	7	7	108
10768	7	8	108
10769	7	9	108
10770	7	10	108
10771	8	1	108
10772	8	2	108
10773	8	3	108
10774	8	4	108
10775	8	5	108
10776	8	6	108
10777	8	7	108
10778	8	8	108
10779	8	9	108
10780	8	10	108
10781	9	1	108
10782	9	2	108
10783	9	3	108
10784	9	4	108
10785	9	5	108
10786	9	6	108
10787	9	7	108
10788	9	8	108
10789	9	9	108
10790	9	10	108
10791	10	1	108
10792	10	2	108
10793	10	3	108
10794	10	4	108
10795	10	5	108
10796	10	6	108
10797	10	7	108
10798	10	8	108
10799	10	9	108
10800	10	10	108
10801	1	1	109
10802	1	2	109
10803	1	3	109
10804	1	4	109
10805	1	5	109
10806	1	6	109
10807	1	7	109
10808	1	8	109
10809	1	9	109
10810	1	10	109
10811	2	1	109
10812	2	2	109
10813	2	3	109
10814	2	4	109
10815	2	5	109
10816	2	6	109
10817	2	7	109
10818	2	8	109
10819	2	9	109
10820	2	10	109
10821	3	1	109
10822	3	2	109
10823	3	3	109
10824	3	4	109
10825	3	5	109
10826	3	6	109
10827	3	7	109
10828	3	8	109
10829	3	9	109
10830	3	10	109
10831	4	1	109
10832	4	2	109
10833	4	3	109
10834	4	4	109
10835	4	5	109
10836	4	6	109
10837	4	7	109
10838	4	8	109
10839	4	9	109
10840	4	10	109
10841	5	1	109
10842	5	2	109
10843	5	3	109
10844	5	4	109
10845	5	5	109
10846	5	6	109
10847	5	7	109
10848	5	8	109
10849	5	9	109
10850	5	10	109
10851	6	1	109
10852	6	2	109
10853	6	3	109
10854	6	4	109
10855	6	5	109
10856	6	6	109
10857	6	7	109
10858	6	8	109
10859	6	9	109
10860	6	10	109
10861	7	1	109
10862	7	2	109
10863	7	3	109
10864	7	4	109
10865	7	5	109
10866	7	6	109
10867	7	7	109
10868	7	8	109
10869	7	9	109
10870	7	10	109
10871	8	1	109
10872	8	2	109
10873	8	3	109
10874	8	4	109
10875	8	5	109
10876	8	6	109
10877	8	7	109
10878	8	8	109
10879	8	9	109
10880	8	10	109
10881	9	1	109
10882	9	2	109
10883	9	3	109
10884	9	4	109
10885	9	5	109
10886	9	6	109
10887	9	7	109
10888	9	8	109
10889	9	9	109
10890	9	10	109
10891	10	1	109
10892	10	2	109
10893	10	3	109
10894	10	4	109
10895	10	5	109
10896	10	6	109
10897	10	7	109
10898	10	8	109
10899	10	9	109
10900	10	10	109
10901	1	1	110
10902	1	2	110
10903	1	3	110
10904	1	4	110
10905	1	5	110
10906	1	6	110
10907	1	7	110
10908	1	8	110
10909	1	9	110
10910	1	10	110
10911	2	1	110
10912	2	2	110
10913	2	3	110
10914	2	4	110
10915	2	5	110
10916	2	6	110
10917	2	7	110
10918	2	8	110
10919	2	9	110
10920	2	10	110
10921	3	1	110
10922	3	2	110
10923	3	3	110
10924	3	4	110
10925	3	5	110
10926	3	6	110
10927	3	7	110
10928	3	8	110
10929	3	9	110
10930	3	10	110
10931	4	1	110
10932	4	2	110
10933	4	3	110
10934	4	4	110
10935	4	5	110
10936	4	6	110
10937	4	7	110
10938	4	8	110
10939	4	9	110
10940	4	10	110
10941	5	1	110
10942	5	2	110
10943	5	3	110
10944	5	4	110
10945	5	5	110
10946	5	6	110
10947	5	7	110
10948	5	8	110
10949	5	9	110
10950	5	10	110
10951	6	1	110
10952	6	2	110
10953	6	3	110
10954	6	4	110
10955	6	5	110
10956	6	6	110
10957	6	7	110
10958	6	8	110
10959	6	9	110
10960	6	10	110
10961	7	1	110
10962	7	2	110
10963	7	3	110
10964	7	4	110
10965	7	5	110
10966	7	6	110
10967	7	7	110
10968	7	8	110
10969	7	9	110
10970	7	10	110
10971	8	1	110
10972	8	2	110
10973	8	3	110
10974	8	4	110
10975	8	5	110
10976	8	6	110
10977	8	7	110
10978	8	8	110
10979	8	9	110
10980	8	10	110
10981	9	1	110
10982	9	2	110
10983	9	3	110
10984	9	4	110
10985	9	5	110
10986	9	6	110
10987	9	7	110
10988	9	8	110
10989	9	9	110
10990	9	10	110
10991	10	1	110
10992	10	2	110
10993	10	3	110
10994	10	4	110
10995	10	5	110
10996	10	6	110
10997	10	7	110
10998	10	8	110
10999	10	9	110
11000	10	10	110
11001	1	1	111
11002	1	2	111
11003	1	3	111
11004	1	4	111
11005	1	5	111
11006	1	6	111
11007	1	7	111
11008	1	8	111
11009	1	9	111
11010	1	10	111
11011	2	1	111
11012	2	2	111
11013	2	3	111
11014	2	4	111
11015	2	5	111
11016	2	6	111
11017	2	7	111
11018	2	8	111
11019	2	9	111
11020	2	10	111
11021	3	1	111
11022	3	2	111
11023	3	3	111
11024	3	4	111
11025	3	5	111
11026	3	6	111
11027	3	7	111
11028	3	8	111
11029	3	9	111
11030	3	10	111
11031	4	1	111
11032	4	2	111
11033	4	3	111
11034	4	4	111
11035	4	5	111
11036	4	6	111
11037	4	7	111
11038	4	8	111
11039	4	9	111
11040	4	10	111
11041	5	1	111
11042	5	2	111
11043	5	3	111
11044	5	4	111
11045	5	5	111
11046	5	6	111
11047	5	7	111
11048	5	8	111
11049	5	9	111
11050	5	10	111
11051	6	1	111
11052	6	2	111
11053	6	3	111
11054	6	4	111
11055	6	5	111
11056	6	6	111
11057	6	7	111
11058	6	8	111
11059	6	9	111
11060	6	10	111
11061	7	1	111
11062	7	2	111
11063	7	3	111
11064	7	4	111
11065	7	5	111
11066	7	6	111
11067	7	7	111
11068	7	8	111
11069	7	9	111
11070	7	10	111
11071	8	1	111
11072	8	2	111
11073	8	3	111
11074	8	4	111
11075	8	5	111
11076	8	6	111
11077	8	7	111
11078	8	8	111
11079	8	9	111
11080	8	10	111
11081	9	1	111
11082	9	2	111
11083	9	3	111
11084	9	4	111
11085	9	5	111
11086	9	6	111
11087	9	7	111
11088	9	8	111
11089	9	9	111
11090	9	10	111
11091	10	1	111
11092	10	2	111
11093	10	3	111
11094	10	4	111
11095	10	5	111
11096	10	6	111
11097	10	7	111
11098	10	8	111
11099	10	9	111
11100	10	10	111
11101	1	1	112
11102	1	2	112
11103	1	3	112
11104	1	4	112
11105	1	5	112
11106	1	6	112
11107	1	7	112
11108	1	8	112
11109	1	9	112
11110	1	10	112
11111	2	1	112
11112	2	2	112
11113	2	3	112
11114	2	4	112
11115	2	5	112
11116	2	6	112
11117	2	7	112
11118	2	8	112
11119	2	9	112
11120	2	10	112
11121	3	1	112
11122	3	2	112
11123	3	3	112
11124	3	4	112
11125	3	5	112
11126	3	6	112
11127	3	7	112
11128	3	8	112
11129	3	9	112
11130	3	10	112
11131	4	1	112
11132	4	2	112
11133	4	3	112
11134	4	4	112
11135	4	5	112
11136	4	6	112
11137	4	7	112
11138	4	8	112
11139	4	9	112
11140	4	10	112
11141	5	1	112
11142	5	2	112
11143	5	3	112
11144	5	4	112
11145	5	5	112
11146	5	6	112
11147	5	7	112
11148	5	8	112
11149	5	9	112
11150	5	10	112
11151	6	1	112
11152	6	2	112
11153	6	3	112
11154	6	4	112
11155	6	5	112
11156	6	6	112
11157	6	7	112
11158	6	8	112
11159	6	9	112
11160	6	10	112
11161	7	1	112
11162	7	2	112
11163	7	3	112
11164	7	4	112
11165	7	5	112
11166	7	6	112
11167	7	7	112
11168	7	8	112
11169	7	9	112
11170	7	10	112
11171	8	1	112
11172	8	2	112
11173	8	3	112
11174	8	4	112
11175	8	5	112
11176	8	6	112
11177	8	7	112
11178	8	8	112
11179	8	9	112
11180	8	10	112
11181	9	1	112
11182	9	2	112
11183	9	3	112
11184	9	4	112
11185	9	5	112
11186	9	6	112
11187	9	7	112
11188	9	8	112
11189	9	9	112
11190	9	10	112
11191	10	1	112
11192	10	2	112
11193	10	3	112
11194	10	4	112
11195	10	5	112
11196	10	6	112
11197	10	7	112
11198	10	8	112
11199	10	9	112
11200	10	10	112
11201	1	1	113
11202	1	2	113
11203	1	3	113
11204	1	4	113
11205	1	5	113
11206	1	6	113
11207	1	7	113
11208	1	8	113
11209	1	9	113
11210	1	10	113
11211	2	1	113
11212	2	2	113
11213	2	3	113
11214	2	4	113
11215	2	5	113
11216	2	6	113
11217	2	7	113
11218	2	8	113
11219	2	9	113
11220	2	10	113
11221	3	1	113
11222	3	2	113
11223	3	3	113
11224	3	4	113
11225	3	5	113
11226	3	6	113
11227	3	7	113
11228	3	8	113
11229	3	9	113
11230	3	10	113
11231	4	1	113
11232	4	2	113
11233	4	3	113
11234	4	4	113
11235	4	5	113
11236	4	6	113
11237	4	7	113
11238	4	8	113
11239	4	9	113
11240	4	10	113
11241	5	1	113
11242	5	2	113
11243	5	3	113
11244	5	4	113
11245	5	5	113
11246	5	6	113
11247	5	7	113
11248	5	8	113
11249	5	9	113
11250	5	10	113
11251	6	1	113
11252	6	2	113
11253	6	3	113
11254	6	4	113
11255	6	5	113
11256	6	6	113
11257	6	7	113
11258	6	8	113
11259	6	9	113
11260	6	10	113
11261	7	1	113
11262	7	2	113
11263	7	3	113
11264	7	4	113
11265	7	5	113
11266	7	6	113
11267	7	7	113
11268	7	8	113
11269	7	9	113
11270	7	10	113
11271	8	1	113
11272	8	2	113
11273	8	3	113
11274	8	4	113
11275	8	5	113
11276	8	6	113
11277	8	7	113
11278	8	8	113
11279	8	9	113
11280	8	10	113
11281	9	1	113
11282	9	2	113
11283	9	3	113
11284	9	4	113
11285	9	5	113
11286	9	6	113
11287	9	7	113
11288	9	8	113
11289	9	9	113
11290	9	10	113
11291	10	1	113
11292	10	2	113
11293	10	3	113
11294	10	4	113
11295	10	5	113
11296	10	6	113
11297	10	7	113
11298	10	8	113
11299	10	9	113
11300	10	10	113
11301	1	1	114
11302	1	2	114
11303	1	3	114
11304	1	4	114
11305	1	5	114
11306	1	6	114
11307	1	7	114
11308	1	8	114
11309	1	9	114
11310	1	10	114
11311	2	1	114
11312	2	2	114
11313	2	3	114
11314	2	4	114
11315	2	5	114
11316	2	6	114
11317	2	7	114
11318	2	8	114
11319	2	9	114
11320	2	10	114
11321	3	1	114
11322	3	2	114
11323	3	3	114
11324	3	4	114
11325	3	5	114
11326	3	6	114
11327	3	7	114
11328	3	8	114
11329	3	9	114
11330	3	10	114
11331	4	1	114
11332	4	2	114
11333	4	3	114
11334	4	4	114
11335	4	5	114
11336	4	6	114
11337	4	7	114
11338	4	8	114
11339	4	9	114
11340	4	10	114
11341	5	1	114
11342	5	2	114
11343	5	3	114
11344	5	4	114
11345	5	5	114
11346	5	6	114
11347	5	7	114
11348	5	8	114
11349	5	9	114
11350	5	10	114
11351	6	1	114
11352	6	2	114
11353	6	3	114
11354	6	4	114
11355	6	5	114
11356	6	6	114
11357	6	7	114
11358	6	8	114
11359	6	9	114
11360	6	10	114
11361	7	1	114
11362	7	2	114
11363	7	3	114
11364	7	4	114
11365	7	5	114
11366	7	6	114
11367	7	7	114
11368	7	8	114
11369	7	9	114
11370	7	10	114
11371	8	1	114
11372	8	2	114
11373	8	3	114
11374	8	4	114
11375	8	5	114
11376	8	6	114
11377	8	7	114
11378	8	8	114
11379	8	9	114
11380	8	10	114
11381	9	1	114
11382	9	2	114
11383	9	3	114
11384	9	4	114
11385	9	5	114
11386	9	6	114
11387	9	7	114
11388	9	8	114
11389	9	9	114
11390	9	10	114
11391	10	1	114
11392	10	2	114
11393	10	3	114
11394	10	4	114
11395	10	5	114
11396	10	6	114
11397	10	7	114
11398	10	8	114
11399	10	9	114
11400	10	10	114
11401	1	1	115
11402	1	2	115
11403	1	3	115
11404	1	4	115
11405	1	5	115
11406	1	6	115
11407	1	7	115
11408	1	8	115
11409	1	9	115
11410	1	10	115
11411	2	1	115
11412	2	2	115
11413	2	3	115
11414	2	4	115
11415	2	5	115
11416	2	6	115
11417	2	7	115
11418	2	8	115
11419	2	9	115
11420	2	10	115
11421	3	1	115
11422	3	2	115
11423	3	3	115
11424	3	4	115
11425	3	5	115
11426	3	6	115
11427	3	7	115
11428	3	8	115
11429	3	9	115
11430	3	10	115
11431	4	1	115
11432	4	2	115
11433	4	3	115
11434	4	4	115
11435	4	5	115
11436	4	6	115
11437	4	7	115
11438	4	8	115
11439	4	9	115
11440	4	10	115
11441	5	1	115
11442	5	2	115
11443	5	3	115
11444	5	4	115
11445	5	5	115
11446	5	6	115
11447	5	7	115
11448	5	8	115
11449	5	9	115
11450	5	10	115
11451	6	1	115
11452	6	2	115
11453	6	3	115
11454	6	4	115
11455	6	5	115
11456	6	6	115
11457	6	7	115
11458	6	8	115
11459	6	9	115
11460	6	10	115
11461	7	1	115
11462	7	2	115
11463	7	3	115
11464	7	4	115
11465	7	5	115
11466	7	6	115
11467	7	7	115
11468	7	8	115
11469	7	9	115
11470	7	10	115
11471	8	1	115
11472	8	2	115
11473	8	3	115
11474	8	4	115
11475	8	5	115
11476	8	6	115
11477	8	7	115
11478	8	8	115
11479	8	9	115
11480	8	10	115
11481	9	1	115
11482	9	2	115
11483	9	3	115
11484	9	4	115
11485	9	5	115
11486	9	6	115
11487	9	7	115
11488	9	8	115
11489	9	9	115
11490	9	10	115
11491	10	1	115
11492	10	2	115
11493	10	3	115
11494	10	4	115
11495	10	5	115
11496	10	6	115
11497	10	7	115
11498	10	8	115
11499	10	9	115
11500	10	10	115
11501	1	1	116
11502	1	2	116
11503	1	3	116
11504	1	4	116
11505	1	5	116
11506	1	6	116
11507	1	7	116
11508	1	8	116
11509	1	9	116
11510	1	10	116
11511	2	1	116
11512	2	2	116
11513	2	3	116
11514	2	4	116
11515	2	5	116
11516	2	6	116
11517	2	7	116
11518	2	8	116
11519	2	9	116
11520	2	10	116
11521	3	1	116
11522	3	2	116
11523	3	3	116
11524	3	4	116
11525	3	5	116
11526	3	6	116
11527	3	7	116
11528	3	8	116
11529	3	9	116
11530	3	10	116
11531	4	1	116
11532	4	2	116
11533	4	3	116
11534	4	4	116
11535	4	5	116
11536	4	6	116
11537	4	7	116
11538	4	8	116
11539	4	9	116
11540	4	10	116
11541	5	1	116
11542	5	2	116
11543	5	3	116
11544	5	4	116
11545	5	5	116
11546	5	6	116
11547	5	7	116
11548	5	8	116
11549	5	9	116
11550	5	10	116
11551	6	1	116
11552	6	2	116
11553	6	3	116
11554	6	4	116
11555	6	5	116
11556	6	6	116
11557	6	7	116
11558	6	8	116
11559	6	9	116
11560	6	10	116
11561	7	1	116
11562	7	2	116
11563	7	3	116
11564	7	4	116
11565	7	5	116
11566	7	6	116
11567	7	7	116
11568	7	8	116
11569	7	9	116
11570	7	10	116
11571	8	1	116
11572	8	2	116
11573	8	3	116
11574	8	4	116
11575	8	5	116
11576	8	6	116
11577	8	7	116
11578	8	8	116
11579	8	9	116
11580	8	10	116
11581	9	1	116
11582	9	2	116
11583	9	3	116
11584	9	4	116
11585	9	5	116
11586	9	6	116
11587	9	7	116
11588	9	8	116
11589	9	9	116
11590	9	10	116
11591	10	1	116
11592	10	2	116
11593	10	3	116
11594	10	4	116
11595	10	5	116
11596	10	6	116
11597	10	7	116
11598	10	8	116
11599	10	9	116
11600	10	10	116
11601	1	1	117
11602	1	2	117
11603	1	3	117
11604	1	4	117
11605	1	5	117
11606	1	6	117
11607	1	7	117
11608	1	8	117
11609	1	9	117
11610	1	10	117
11611	2	1	117
11612	2	2	117
11613	2	3	117
11614	2	4	117
11615	2	5	117
11616	2	6	117
11617	2	7	117
11618	2	8	117
11619	2	9	117
11620	2	10	117
11621	3	1	117
11622	3	2	117
11623	3	3	117
11624	3	4	117
11625	3	5	117
11626	3	6	117
11627	3	7	117
11628	3	8	117
11629	3	9	117
11630	3	10	117
11631	4	1	117
11632	4	2	117
11633	4	3	117
11634	4	4	117
11635	4	5	117
11636	4	6	117
11637	4	7	117
11638	4	8	117
11639	4	9	117
11640	4	10	117
11641	5	1	117
11642	5	2	117
11643	5	3	117
11644	5	4	117
11645	5	5	117
11646	5	6	117
11647	5	7	117
11648	5	8	117
11649	5	9	117
11650	5	10	117
11651	6	1	117
11652	6	2	117
11653	6	3	117
11654	6	4	117
11655	6	5	117
11656	6	6	117
11657	6	7	117
11658	6	8	117
11659	6	9	117
11660	6	10	117
11661	7	1	117
11662	7	2	117
11663	7	3	117
11664	7	4	117
11665	7	5	117
11666	7	6	117
11667	7	7	117
11668	7	8	117
11669	7	9	117
11670	7	10	117
11671	8	1	117
11672	8	2	117
11673	8	3	117
11674	8	4	117
11675	8	5	117
11676	8	6	117
11677	8	7	117
11678	8	8	117
11679	8	9	117
11680	8	10	117
11681	9	1	117
11682	9	2	117
11683	9	3	117
11684	9	4	117
11685	9	5	117
11686	9	6	117
11687	9	7	117
11688	9	8	117
11689	9	9	117
11690	9	10	117
11691	10	1	117
11692	10	2	117
11693	10	3	117
11694	10	4	117
11695	10	5	117
11696	10	6	117
11697	10	7	117
11698	10	8	117
11699	10	9	117
11700	10	10	117
11701	1	1	118
11702	1	2	118
11703	1	3	118
11704	1	4	118
11705	1	5	118
11706	1	6	118
11707	1	7	118
11708	1	8	118
11709	1	9	118
11710	1	10	118
11711	2	1	118
11712	2	2	118
11713	2	3	118
11714	2	4	118
11715	2	5	118
11716	2	6	118
11717	2	7	118
11718	2	8	118
11719	2	9	118
11720	2	10	118
11721	3	1	118
11722	3	2	118
11723	3	3	118
11724	3	4	118
11725	3	5	118
11726	3	6	118
11727	3	7	118
11728	3	8	118
11729	3	9	118
11730	3	10	118
11731	4	1	118
11732	4	2	118
11733	4	3	118
11734	4	4	118
11735	4	5	118
11736	4	6	118
11737	4	7	118
11738	4	8	118
11739	4	9	118
11740	4	10	118
11741	5	1	118
11742	5	2	118
11743	5	3	118
11744	5	4	118
11745	5	5	118
11746	5	6	118
11747	5	7	118
11748	5	8	118
11749	5	9	118
11750	5	10	118
11751	6	1	118
11752	6	2	118
11753	6	3	118
11754	6	4	118
11755	6	5	118
11756	6	6	118
11757	6	7	118
11758	6	8	118
11759	6	9	118
11760	6	10	118
11761	7	1	118
11762	7	2	118
11763	7	3	118
11764	7	4	118
11765	7	5	118
11766	7	6	118
11767	7	7	118
11768	7	8	118
11769	7	9	118
11770	7	10	118
11771	8	1	118
11772	8	2	118
11773	8	3	118
11774	8	4	118
11775	8	5	118
11776	8	6	118
11777	8	7	118
11778	8	8	118
11779	8	9	118
11780	8	10	118
11781	9	1	118
11782	9	2	118
11783	9	3	118
11784	9	4	118
11785	9	5	118
11786	9	6	118
11787	9	7	118
11788	9	8	118
11789	9	9	118
11790	9	10	118
11791	10	1	118
11792	10	2	118
11793	10	3	118
11794	10	4	118
11795	10	5	118
11796	10	6	118
11797	10	7	118
11798	10	8	118
11799	10	9	118
11800	10	10	118
11801	1	1	119
11802	1	2	119
11803	1	3	119
11804	1	4	119
11805	1	5	119
11806	1	6	119
11807	1	7	119
11808	1	8	119
11809	1	9	119
11810	1	10	119
11811	2	1	119
11812	2	2	119
11813	2	3	119
11814	2	4	119
11815	2	5	119
11816	2	6	119
11817	2	7	119
11818	2	8	119
11819	2	9	119
11820	2	10	119
11821	3	1	119
11822	3	2	119
11823	3	3	119
11824	3	4	119
11825	3	5	119
11826	3	6	119
11827	3	7	119
11828	3	8	119
11829	3	9	119
11830	3	10	119
11831	4	1	119
11832	4	2	119
11833	4	3	119
11834	4	4	119
11835	4	5	119
11836	4	6	119
11837	4	7	119
11838	4	8	119
11839	4	9	119
11840	4	10	119
11841	5	1	119
11842	5	2	119
11843	5	3	119
11844	5	4	119
11845	5	5	119
11846	5	6	119
11847	5	7	119
11848	5	8	119
11849	5	9	119
11850	5	10	119
11851	6	1	119
11852	6	2	119
11853	6	3	119
11854	6	4	119
11855	6	5	119
11856	6	6	119
11857	6	7	119
11858	6	8	119
11859	6	9	119
11860	6	10	119
11861	7	1	119
11862	7	2	119
11863	7	3	119
11864	7	4	119
11865	7	5	119
11866	7	6	119
11867	7	7	119
11868	7	8	119
11869	7	9	119
11870	7	10	119
11871	8	1	119
11872	8	2	119
11873	8	3	119
11874	8	4	119
11875	8	5	119
11876	8	6	119
11877	8	7	119
11878	8	8	119
11879	8	9	119
11880	8	10	119
11881	9	1	119
11882	9	2	119
11883	9	3	119
11884	9	4	119
11885	9	5	119
11886	9	6	119
11887	9	7	119
11888	9	8	119
11889	9	9	119
11890	9	10	119
11891	10	1	119
11892	10	2	119
11893	10	3	119
11894	10	4	119
11895	10	5	119
11896	10	6	119
11897	10	7	119
11898	10	8	119
11899	10	9	119
11900	10	10	119
11901	1	1	120
11902	1	2	120
11903	1	3	120
11904	1	4	120
11905	1	5	120
11906	1	6	120
11907	1	7	120
11908	1	8	120
11909	1	9	120
11910	1	10	120
11911	2	1	120
11912	2	2	120
11913	2	3	120
11914	2	4	120
11915	2	5	120
11916	2	6	120
11917	2	7	120
11918	2	8	120
11919	2	9	120
11920	2	10	120
11921	3	1	120
11922	3	2	120
11923	3	3	120
11924	3	4	120
11925	3	5	120
11926	3	6	120
11927	3	7	120
11928	3	8	120
11929	3	9	120
11930	3	10	120
11931	4	1	120
11932	4	2	120
11933	4	3	120
11934	4	4	120
11935	4	5	120
11936	4	6	120
11937	4	7	120
11938	4	8	120
11939	4	9	120
11940	4	10	120
11941	5	1	120
11942	5	2	120
11943	5	3	120
11944	5	4	120
11945	5	5	120
11946	5	6	120
11947	5	7	120
11948	5	8	120
11949	5	9	120
11950	5	10	120
11951	6	1	120
11952	6	2	120
11953	6	3	120
11954	6	4	120
11955	6	5	120
11956	6	6	120
11957	6	7	120
11958	6	8	120
11959	6	9	120
11960	6	10	120
11961	7	1	120
11962	7	2	120
11963	7	3	120
11964	7	4	120
11965	7	5	120
11966	7	6	120
11967	7	7	120
11968	7	8	120
11969	7	9	120
11970	7	10	120
11971	8	1	120
11972	8	2	120
11973	8	3	120
11974	8	4	120
11975	8	5	120
11976	8	6	120
11977	8	7	120
11978	8	8	120
11979	8	9	120
11980	8	10	120
11981	9	1	120
11982	9	2	120
11983	9	3	120
11984	9	4	120
11985	9	5	120
11986	9	6	120
11987	9	7	120
11988	9	8	120
11989	9	9	120
11990	9	10	120
11991	10	1	120
11992	10	2	120
11993	10	3	120
11994	10	4	120
11995	10	5	120
11996	10	6	120
11997	10	7	120
11998	10	8	120
11999	10	9	120
12000	10	10	120
12001	1	1	121
12002	1	2	121
12003	1	3	121
12004	1	4	121
12005	1	5	121
12006	1	6	121
12007	1	7	121
12008	1	8	121
12009	1	9	121
12010	1	10	121
12011	2	1	121
12012	2	2	121
12013	2	3	121
12014	2	4	121
12015	2	5	121
12016	2	6	121
12017	2	7	121
12018	2	8	121
12019	2	9	121
12020	2	10	121
12021	3	1	121
12022	3	2	121
12023	3	3	121
12024	3	4	121
12025	3	5	121
12026	3	6	121
12027	3	7	121
12028	3	8	121
12029	3	9	121
12030	3	10	121
12031	4	1	121
12032	4	2	121
12033	4	3	121
12034	4	4	121
12035	4	5	121
12036	4	6	121
12037	4	7	121
12038	4	8	121
12039	4	9	121
12040	4	10	121
12041	5	1	121
12042	5	2	121
12043	5	3	121
12044	5	4	121
12045	5	5	121
12046	5	6	121
12047	5	7	121
12048	5	8	121
12049	5	9	121
12050	5	10	121
12051	6	1	121
12052	6	2	121
12053	6	3	121
12054	6	4	121
12055	6	5	121
12056	6	6	121
12057	6	7	121
12058	6	8	121
12059	6	9	121
12060	6	10	121
12061	7	1	121
12062	7	2	121
12063	7	3	121
12064	7	4	121
12065	7	5	121
12066	7	6	121
12067	7	7	121
12068	7	8	121
12069	7	9	121
12070	7	10	121
12071	8	1	121
12072	8	2	121
12073	8	3	121
12074	8	4	121
12075	8	5	121
12076	8	6	121
12077	8	7	121
12078	8	8	121
12079	8	9	121
12080	8	10	121
12081	9	1	121
12082	9	2	121
12083	9	3	121
12084	9	4	121
12085	9	5	121
12086	9	6	121
12087	9	7	121
12088	9	8	121
12089	9	9	121
12090	9	10	121
12091	10	1	121
12092	10	2	121
12093	10	3	121
12094	10	4	121
12095	10	5	121
12096	10	6	121
12097	10	7	121
12098	10	8	121
12099	10	9	121
12100	10	10	121
12101	1	1	122
12102	1	2	122
12103	1	3	122
12104	1	4	122
12105	1	5	122
12106	1	6	122
12107	1	7	122
12108	1	8	122
12109	1	9	122
12110	1	10	122
12111	2	1	122
12112	2	2	122
12113	2	3	122
12114	2	4	122
12115	2	5	122
12116	2	6	122
12117	2	7	122
12118	2	8	122
12119	2	9	122
12120	2	10	122
12121	3	1	122
12122	3	2	122
12123	3	3	122
12124	3	4	122
12125	3	5	122
12126	3	6	122
12127	3	7	122
12128	3	8	122
12129	3	9	122
12130	3	10	122
12131	4	1	122
12132	4	2	122
12133	4	3	122
12134	4	4	122
12135	4	5	122
12136	4	6	122
12137	4	7	122
12138	4	8	122
12139	4	9	122
12140	4	10	122
12141	5	1	122
12142	5	2	122
12143	5	3	122
12144	5	4	122
12145	5	5	122
12146	5	6	122
12147	5	7	122
12148	5	8	122
12149	5	9	122
12150	5	10	122
12151	6	1	122
12152	6	2	122
12153	6	3	122
12154	6	4	122
12155	6	5	122
12156	6	6	122
12157	6	7	122
12158	6	8	122
12159	6	9	122
12160	6	10	122
12161	7	1	122
12162	7	2	122
12163	7	3	122
12164	7	4	122
12165	7	5	122
12166	7	6	122
12167	7	7	122
12168	7	8	122
12169	7	9	122
12170	7	10	122
12171	8	1	122
12172	8	2	122
12173	8	3	122
12174	8	4	122
12175	8	5	122
12176	8	6	122
12177	8	7	122
12178	8	8	122
12179	8	9	122
12180	8	10	122
12181	9	1	122
12182	9	2	122
12183	9	3	122
12184	9	4	122
12185	9	5	122
12186	9	6	122
12187	9	7	122
12188	9	8	122
12189	9	9	122
12190	9	10	122
12191	10	1	122
12192	10	2	122
12193	10	3	122
12194	10	4	122
12195	10	5	122
12196	10	6	122
12197	10	7	122
12198	10	8	122
12199	10	9	122
12200	10	10	122
12201	1	1	123
12202	1	2	123
12203	1	3	123
12204	1	4	123
12205	1	5	123
12206	1	6	123
12207	1	7	123
12208	1	8	123
12209	1	9	123
12210	1	10	123
12211	2	1	123
12212	2	2	123
12213	2	3	123
12214	2	4	123
12215	2	5	123
12216	2	6	123
12217	2	7	123
12218	2	8	123
12219	2	9	123
12220	2	10	123
12221	3	1	123
12222	3	2	123
12223	3	3	123
12224	3	4	123
12225	3	5	123
12226	3	6	123
12227	3	7	123
12228	3	8	123
12229	3	9	123
12230	3	10	123
12231	4	1	123
12232	4	2	123
12233	4	3	123
12234	4	4	123
12235	4	5	123
12236	4	6	123
12237	4	7	123
12238	4	8	123
12239	4	9	123
12240	4	10	123
12241	5	1	123
12242	5	2	123
12243	5	3	123
12244	5	4	123
12245	5	5	123
12246	5	6	123
12247	5	7	123
12248	5	8	123
12249	5	9	123
12250	5	10	123
12251	6	1	123
12252	6	2	123
12253	6	3	123
12254	6	4	123
12255	6	5	123
12256	6	6	123
12257	6	7	123
12258	6	8	123
12259	6	9	123
12260	6	10	123
12261	7	1	123
12262	7	2	123
12263	7	3	123
12264	7	4	123
12265	7	5	123
12266	7	6	123
12267	7	7	123
12268	7	8	123
12269	7	9	123
12270	7	10	123
12271	8	1	123
12272	8	2	123
12273	8	3	123
12274	8	4	123
12275	8	5	123
12276	8	6	123
12277	8	7	123
12278	8	8	123
12279	8	9	123
12280	8	10	123
12281	9	1	123
12282	9	2	123
12283	9	3	123
12284	9	4	123
12285	9	5	123
12286	9	6	123
12287	9	7	123
12288	9	8	123
12289	9	9	123
12290	9	10	123
12291	10	1	123
12292	10	2	123
12293	10	3	123
12294	10	4	123
12295	10	5	123
12296	10	6	123
12297	10	7	123
12298	10	8	123
12299	10	9	123
12300	10	10	123
12301	1	1	124
12302	1	2	124
12303	1	3	124
12304	1	4	124
12305	1	5	124
12306	1	6	124
12307	1	7	124
12308	1	8	124
12309	1	9	124
12310	1	10	124
12311	2	1	124
12312	2	2	124
12313	2	3	124
12314	2	4	124
12315	2	5	124
12316	2	6	124
12317	2	7	124
12318	2	8	124
12319	2	9	124
12320	2	10	124
12321	3	1	124
12322	3	2	124
12323	3	3	124
12324	3	4	124
12325	3	5	124
12326	3	6	124
12327	3	7	124
12328	3	8	124
12329	3	9	124
12330	3	10	124
12331	4	1	124
12332	4	2	124
12333	4	3	124
12334	4	4	124
12335	4	5	124
12336	4	6	124
12337	4	7	124
12338	4	8	124
12339	4	9	124
12340	4	10	124
12341	5	1	124
12342	5	2	124
12343	5	3	124
12344	5	4	124
12345	5	5	124
12346	5	6	124
12347	5	7	124
12348	5	8	124
12349	5	9	124
12350	5	10	124
12351	6	1	124
12352	6	2	124
12353	6	3	124
12354	6	4	124
12355	6	5	124
12356	6	6	124
12357	6	7	124
12358	6	8	124
12359	6	9	124
12360	6	10	124
12361	7	1	124
12362	7	2	124
12363	7	3	124
12364	7	4	124
12365	7	5	124
12366	7	6	124
12367	7	7	124
12368	7	8	124
12369	7	9	124
12370	7	10	124
12371	8	1	124
12372	8	2	124
12373	8	3	124
12374	8	4	124
12375	8	5	124
12376	8	6	124
12377	8	7	124
12378	8	8	124
12379	8	9	124
12380	8	10	124
12381	9	1	124
12382	9	2	124
12383	9	3	124
12384	9	4	124
12385	9	5	124
12386	9	6	124
12387	9	7	124
12388	9	8	124
12389	9	9	124
12390	9	10	124
12391	10	1	124
12392	10	2	124
12393	10	3	124
12394	10	4	124
12395	10	5	124
12396	10	6	124
12397	10	7	124
12398	10	8	124
12399	10	9	124
12400	10	10	124
12401	1	1	125
12402	1	2	125
12403	1	3	125
12404	1	4	125
12405	1	5	125
12406	1	6	125
12407	1	7	125
12408	1	8	125
12409	1	9	125
12410	1	10	125
12411	2	1	125
12412	2	2	125
12413	2	3	125
12414	2	4	125
12415	2	5	125
12416	2	6	125
12417	2	7	125
12418	2	8	125
12419	2	9	125
12420	2	10	125
12421	3	1	125
12422	3	2	125
12423	3	3	125
12424	3	4	125
12425	3	5	125
12426	3	6	125
12427	3	7	125
12428	3	8	125
12429	3	9	125
12430	3	10	125
12431	4	1	125
12432	4	2	125
12433	4	3	125
12434	4	4	125
12435	4	5	125
12436	4	6	125
12437	4	7	125
12438	4	8	125
12439	4	9	125
12440	4	10	125
12441	5	1	125
12442	5	2	125
12443	5	3	125
12444	5	4	125
12445	5	5	125
12446	5	6	125
12447	5	7	125
12448	5	8	125
12449	5	9	125
12450	5	10	125
12451	6	1	125
12452	6	2	125
12453	6	3	125
12454	6	4	125
12455	6	5	125
12456	6	6	125
12457	6	7	125
12458	6	8	125
12459	6	9	125
12460	6	10	125
12461	7	1	125
12462	7	2	125
12463	7	3	125
12464	7	4	125
12465	7	5	125
12466	7	6	125
12467	7	7	125
12468	7	8	125
12469	7	9	125
12470	7	10	125
12471	8	1	125
12472	8	2	125
12473	8	3	125
12474	8	4	125
12475	8	5	125
12476	8	6	125
12477	8	7	125
12478	8	8	125
12479	8	9	125
12480	8	10	125
12481	9	1	125
12482	9	2	125
12483	9	3	125
12484	9	4	125
12485	9	5	125
12486	9	6	125
12487	9	7	125
12488	9	8	125
12489	9	9	125
12490	9	10	125
12491	10	1	125
12492	10	2	125
12493	10	3	125
12494	10	4	125
12495	10	5	125
12496	10	6	125
12497	10	7	125
12498	10	8	125
12499	10	9	125
12500	10	10	125
12501	1	1	126
12502	1	2	126
12503	1	3	126
12504	1	4	126
12505	1	5	126
12506	1	6	126
12507	1	7	126
12508	1	8	126
12509	1	9	126
12510	1	10	126
12511	2	1	126
12512	2	2	126
12513	2	3	126
12514	2	4	126
12515	2	5	126
12516	2	6	126
12517	2	7	126
12518	2	8	126
12519	2	9	126
12520	2	10	126
12521	3	1	126
12522	3	2	126
12523	3	3	126
12524	3	4	126
12525	3	5	126
12526	3	6	126
12527	3	7	126
12528	3	8	126
12529	3	9	126
12530	3	10	126
12531	4	1	126
12532	4	2	126
12533	4	3	126
12534	4	4	126
12535	4	5	126
12536	4	6	126
12537	4	7	126
12538	4	8	126
12539	4	9	126
12540	4	10	126
12541	5	1	126
12542	5	2	126
12543	5	3	126
12544	5	4	126
12545	5	5	126
12546	5	6	126
12547	5	7	126
12548	5	8	126
12549	5	9	126
12550	5	10	126
12551	6	1	126
12552	6	2	126
12553	6	3	126
12554	6	4	126
12555	6	5	126
12556	6	6	126
12557	6	7	126
12558	6	8	126
12559	6	9	126
12560	6	10	126
12561	7	1	126
12562	7	2	126
12563	7	3	126
12564	7	4	126
12565	7	5	126
12566	7	6	126
12567	7	7	126
12568	7	8	126
12569	7	9	126
12570	7	10	126
12571	8	1	126
12572	8	2	126
12573	8	3	126
12574	8	4	126
12575	8	5	126
12576	8	6	126
12577	8	7	126
12578	8	8	126
12579	8	9	126
12580	8	10	126
12581	9	1	126
12582	9	2	126
12583	9	3	126
12584	9	4	126
12585	9	5	126
12586	9	6	126
12587	9	7	126
12588	9	8	126
12589	9	9	126
12590	9	10	126
12591	10	1	126
12592	10	2	126
12593	10	3	126
12594	10	4	126
12595	10	5	126
12596	10	6	126
12597	10	7	126
12598	10	8	126
12599	10	9	126
12600	10	10	126
12601	1	1	127
12602	1	2	127
12603	1	3	127
12604	1	4	127
12605	1	5	127
12606	1	6	127
12607	1	7	127
12608	1	8	127
12609	1	9	127
12610	1	10	127
12611	2	1	127
12612	2	2	127
12613	2	3	127
12614	2	4	127
12615	2	5	127
12616	2	6	127
12617	2	7	127
12618	2	8	127
12619	2	9	127
12620	2	10	127
12621	3	1	127
12622	3	2	127
12623	3	3	127
12624	3	4	127
12625	3	5	127
12626	3	6	127
12627	3	7	127
12628	3	8	127
12629	3	9	127
12630	3	10	127
12631	4	1	127
12632	4	2	127
12633	4	3	127
12634	4	4	127
12635	4	5	127
12636	4	6	127
12637	4	7	127
12638	4	8	127
12639	4	9	127
12640	4	10	127
12641	5	1	127
12642	5	2	127
12643	5	3	127
12644	5	4	127
12645	5	5	127
12646	5	6	127
12647	5	7	127
12648	5	8	127
12649	5	9	127
12650	5	10	127
12651	6	1	127
12652	6	2	127
12653	6	3	127
12654	6	4	127
12655	6	5	127
12656	6	6	127
12657	6	7	127
12658	6	8	127
12659	6	9	127
12660	6	10	127
12661	7	1	127
12662	7	2	127
12663	7	3	127
12664	7	4	127
12665	7	5	127
12666	7	6	127
12667	7	7	127
12668	7	8	127
12669	7	9	127
12670	7	10	127
12671	8	1	127
12672	8	2	127
12673	8	3	127
12674	8	4	127
12675	8	5	127
12676	8	6	127
12677	8	7	127
12678	8	8	127
12679	8	9	127
12680	8	10	127
12681	9	1	127
12682	9	2	127
12683	9	3	127
12684	9	4	127
12685	9	5	127
12686	9	6	127
12687	9	7	127
12688	9	8	127
12689	9	9	127
12690	9	10	127
12691	10	1	127
12692	10	2	127
12693	10	3	127
12694	10	4	127
12695	10	5	127
12696	10	6	127
12697	10	7	127
12698	10	8	127
12699	10	9	127
12700	10	10	127
12701	1	1	128
12702	1	2	128
12703	1	3	128
12704	1	4	128
12705	1	5	128
12706	1	6	128
12707	1	7	128
12708	1	8	128
12709	1	9	128
12710	1	10	128
12711	2	1	128
12712	2	2	128
12713	2	3	128
12714	2	4	128
12715	2	5	128
12716	2	6	128
12717	2	7	128
12718	2	8	128
12719	2	9	128
12720	2	10	128
12721	3	1	128
12722	3	2	128
12723	3	3	128
12724	3	4	128
12725	3	5	128
12726	3	6	128
12727	3	7	128
12728	3	8	128
12729	3	9	128
12730	3	10	128
12731	4	1	128
12732	4	2	128
12733	4	3	128
12734	4	4	128
12735	4	5	128
12736	4	6	128
12737	4	7	128
12738	4	8	128
12739	4	9	128
12740	4	10	128
12741	5	1	128
12742	5	2	128
12743	5	3	128
12744	5	4	128
12745	5	5	128
12746	5	6	128
12747	5	7	128
12748	5	8	128
12749	5	9	128
12750	5	10	128
12751	6	1	128
12752	6	2	128
12753	6	3	128
12754	6	4	128
12755	6	5	128
12756	6	6	128
12757	6	7	128
12758	6	8	128
12759	6	9	128
12760	6	10	128
12761	7	1	128
12762	7	2	128
12763	7	3	128
12764	7	4	128
12765	7	5	128
12766	7	6	128
12767	7	7	128
12768	7	8	128
12769	7	9	128
12770	7	10	128
12771	8	1	128
12772	8	2	128
12773	8	3	128
12774	8	4	128
12775	8	5	128
12776	8	6	128
12777	8	7	128
12778	8	8	128
12779	8	9	128
12780	8	10	128
12781	9	1	128
12782	9	2	128
12783	9	3	128
12784	9	4	128
12785	9	5	128
12786	9	6	128
12787	9	7	128
12788	9	8	128
12789	9	9	128
12790	9	10	128
12791	10	1	128
12792	10	2	128
12793	10	3	128
12794	10	4	128
12795	10	5	128
12796	10	6	128
12797	10	7	128
12798	10	8	128
12799	10	9	128
12800	10	10	128
12801	1	1	129
12802	1	2	129
12803	1	3	129
12804	1	4	129
12805	1	5	129
12806	1	6	129
12807	1	7	129
12808	1	8	129
12809	1	9	129
12810	1	10	129
12811	2	1	129
12812	2	2	129
12813	2	3	129
12814	2	4	129
12815	2	5	129
12816	2	6	129
12817	2	7	129
12818	2	8	129
12819	2	9	129
12820	2	10	129
12821	3	1	129
12822	3	2	129
12823	3	3	129
12824	3	4	129
12825	3	5	129
12826	3	6	129
12827	3	7	129
12828	3	8	129
12829	3	9	129
12830	3	10	129
12831	4	1	129
12832	4	2	129
12833	4	3	129
12834	4	4	129
12835	4	5	129
12836	4	6	129
12837	4	7	129
12838	4	8	129
12839	4	9	129
12840	4	10	129
12841	5	1	129
12842	5	2	129
12843	5	3	129
12844	5	4	129
12845	5	5	129
12846	5	6	129
12847	5	7	129
12848	5	8	129
12849	5	9	129
12850	5	10	129
12851	6	1	129
12852	6	2	129
12853	6	3	129
12854	6	4	129
12855	6	5	129
12856	6	6	129
12857	6	7	129
12858	6	8	129
12859	6	9	129
12860	6	10	129
12861	7	1	129
12862	7	2	129
12863	7	3	129
12864	7	4	129
12865	7	5	129
12866	7	6	129
12867	7	7	129
12868	7	8	129
12869	7	9	129
12870	7	10	129
12871	8	1	129
12872	8	2	129
12873	8	3	129
12874	8	4	129
12875	8	5	129
12876	8	6	129
12877	8	7	129
12878	8	8	129
12879	8	9	129
12880	8	10	129
12881	9	1	129
12882	9	2	129
12883	9	3	129
12884	9	4	129
12885	9	5	129
12886	9	6	129
12887	9	7	129
12888	9	8	129
12889	9	9	129
12890	9	10	129
12891	10	1	129
12892	10	2	129
12893	10	3	129
12894	10	4	129
12895	10	5	129
12896	10	6	129
12897	10	7	129
12898	10	8	129
12899	10	9	129
12900	10	10	129
12901	1	1	130
12902	1	2	130
12903	1	3	130
12904	1	4	130
12905	1	5	130
12906	1	6	130
12907	1	7	130
12908	1	8	130
12909	1	9	130
12910	1	10	130
12911	2	1	130
12912	2	2	130
12913	2	3	130
12914	2	4	130
12915	2	5	130
12916	2	6	130
12917	2	7	130
12918	2	8	130
12919	2	9	130
12920	2	10	130
12921	3	1	130
12922	3	2	130
12923	3	3	130
12924	3	4	130
12925	3	5	130
12926	3	6	130
12927	3	7	130
12928	3	8	130
12929	3	9	130
12930	3	10	130
12931	4	1	130
12932	4	2	130
12933	4	3	130
12934	4	4	130
12935	4	5	130
12936	4	6	130
12937	4	7	130
12938	4	8	130
12939	4	9	130
12940	4	10	130
12941	5	1	130
12942	5	2	130
12943	5	3	130
12944	5	4	130
12945	5	5	130
12946	5	6	130
12947	5	7	130
12948	5	8	130
12949	5	9	130
12950	5	10	130
12951	6	1	130
12952	6	2	130
12953	6	3	130
12954	6	4	130
12955	6	5	130
12956	6	6	130
12957	6	7	130
12958	6	8	130
12959	6	9	130
12960	6	10	130
12961	7	1	130
12962	7	2	130
12963	7	3	130
12964	7	4	130
12965	7	5	130
12966	7	6	130
12967	7	7	130
12968	7	8	130
12969	7	9	130
12970	7	10	130
12971	8	1	130
12972	8	2	130
12973	8	3	130
12974	8	4	130
12975	8	5	130
12976	8	6	130
12977	8	7	130
12978	8	8	130
12979	8	9	130
12980	8	10	130
12981	9	1	130
12982	9	2	130
12983	9	3	130
12984	9	4	130
12985	9	5	130
12986	9	6	130
12987	9	7	130
12988	9	8	130
12989	9	9	130
12990	9	10	130
12991	10	1	130
12992	10	2	130
12993	10	3	130
12994	10	4	130
12995	10	5	130
12996	10	6	130
12997	10	7	130
12998	10	8	130
12999	10	9	130
13000	10	10	130
13001	1	1	131
13002	1	2	131
13003	1	3	131
13004	1	4	131
13005	1	5	131
13006	1	6	131
13007	1	7	131
13008	1	8	131
13009	1	9	131
13010	1	10	131
13011	2	1	131
13012	2	2	131
13013	2	3	131
13014	2	4	131
13015	2	5	131
13016	2	6	131
13017	2	7	131
13018	2	8	131
13019	2	9	131
13020	2	10	131
13021	3	1	131
13022	3	2	131
13023	3	3	131
13024	3	4	131
13025	3	5	131
13026	3	6	131
13027	3	7	131
13028	3	8	131
13029	3	9	131
13030	3	10	131
13031	4	1	131
13032	4	2	131
13033	4	3	131
13034	4	4	131
13035	4	5	131
13036	4	6	131
13037	4	7	131
13038	4	8	131
13039	4	9	131
13040	4	10	131
13041	5	1	131
13042	5	2	131
13043	5	3	131
13044	5	4	131
13045	5	5	131
13046	5	6	131
13047	5	7	131
13048	5	8	131
13049	5	9	131
13050	5	10	131
13051	6	1	131
13052	6	2	131
13053	6	3	131
13054	6	4	131
13055	6	5	131
13056	6	6	131
13057	6	7	131
13058	6	8	131
13059	6	9	131
13060	6	10	131
13061	7	1	131
13062	7	2	131
13063	7	3	131
13064	7	4	131
13065	7	5	131
13066	7	6	131
13067	7	7	131
13068	7	8	131
13069	7	9	131
13070	7	10	131
13071	8	1	131
13072	8	2	131
13073	8	3	131
13074	8	4	131
13075	8	5	131
13076	8	6	131
13077	8	7	131
13078	8	8	131
13079	8	9	131
13080	8	10	131
13081	9	1	131
13082	9	2	131
13083	9	3	131
13084	9	4	131
13085	9	5	131
13086	9	6	131
13087	9	7	131
13088	9	8	131
13089	9	9	131
13090	9	10	131
13091	10	1	131
13092	10	2	131
13093	10	3	131
13094	10	4	131
13095	10	5	131
13096	10	6	131
13097	10	7	131
13098	10	8	131
13099	10	9	131
13100	10	10	131
13101	1	1	132
13102	1	2	132
13103	1	3	132
13104	1	4	132
13105	1	5	132
13106	1	6	132
13107	1	7	132
13108	1	8	132
13109	1	9	132
13110	1	10	132
13111	2	1	132
13112	2	2	132
13113	2	3	132
13114	2	4	132
13115	2	5	132
13116	2	6	132
13117	2	7	132
13118	2	8	132
13119	2	9	132
13120	2	10	132
13121	3	1	132
13122	3	2	132
13123	3	3	132
13124	3	4	132
13125	3	5	132
13126	3	6	132
13127	3	7	132
13128	3	8	132
13129	3	9	132
13130	3	10	132
13131	4	1	132
13132	4	2	132
13133	4	3	132
13134	4	4	132
13135	4	5	132
13136	4	6	132
13137	4	7	132
13138	4	8	132
13139	4	9	132
13140	4	10	132
13141	5	1	132
13142	5	2	132
13143	5	3	132
13144	5	4	132
13145	5	5	132
13146	5	6	132
13147	5	7	132
13148	5	8	132
13149	5	9	132
13150	5	10	132
13151	6	1	132
13152	6	2	132
13153	6	3	132
13154	6	4	132
13155	6	5	132
13156	6	6	132
13157	6	7	132
13158	6	8	132
13159	6	9	132
13160	6	10	132
13161	7	1	132
13162	7	2	132
13163	7	3	132
13164	7	4	132
13165	7	5	132
13166	7	6	132
13167	7	7	132
13168	7	8	132
13169	7	9	132
13170	7	10	132
13171	8	1	132
13172	8	2	132
13173	8	3	132
13174	8	4	132
13175	8	5	132
13176	8	6	132
13177	8	7	132
13178	8	8	132
13179	8	9	132
13180	8	10	132
13181	9	1	132
13182	9	2	132
13183	9	3	132
13184	9	4	132
13185	9	5	132
13186	9	6	132
13187	9	7	132
13188	9	8	132
13189	9	9	132
13190	9	10	132
13191	10	1	132
13192	10	2	132
13193	10	3	132
13194	10	4	132
13195	10	5	132
13196	10	6	132
13197	10	7	132
13198	10	8	132
13199	10	9	132
13200	10	10	132
13201	1	1	133
13202	1	2	133
13203	1	3	133
13204	1	4	133
13205	1	5	133
13206	1	6	133
13207	1	7	133
13208	1	8	133
13209	1	9	133
13210	1	10	133
13211	2	1	133
13212	2	2	133
13213	2	3	133
13214	2	4	133
13215	2	5	133
13216	2	6	133
13217	2	7	133
13218	2	8	133
13219	2	9	133
13220	2	10	133
13221	3	1	133
13222	3	2	133
13223	3	3	133
13224	3	4	133
13225	3	5	133
13226	3	6	133
13227	3	7	133
13228	3	8	133
13229	3	9	133
13230	3	10	133
13231	4	1	133
13232	4	2	133
13233	4	3	133
13234	4	4	133
13235	4	5	133
13236	4	6	133
13237	4	7	133
13238	4	8	133
13239	4	9	133
13240	4	10	133
13241	5	1	133
13242	5	2	133
13243	5	3	133
13244	5	4	133
13245	5	5	133
13246	5	6	133
13247	5	7	133
13248	5	8	133
13249	5	9	133
13250	5	10	133
13251	6	1	133
13252	6	2	133
13253	6	3	133
13254	6	4	133
13255	6	5	133
13256	6	6	133
13257	6	7	133
13258	6	8	133
13259	6	9	133
13260	6	10	133
13261	7	1	133
13262	7	2	133
13263	7	3	133
13264	7	4	133
13265	7	5	133
13266	7	6	133
13267	7	7	133
13268	7	8	133
13269	7	9	133
13270	7	10	133
13271	8	1	133
13272	8	2	133
13273	8	3	133
13274	8	4	133
13275	8	5	133
13276	8	6	133
13277	8	7	133
13278	8	8	133
13279	8	9	133
13280	8	10	133
13281	9	1	133
13282	9	2	133
13283	9	3	133
13284	9	4	133
13285	9	5	133
13286	9	6	133
13287	9	7	133
13288	9	8	133
13289	9	9	133
13290	9	10	133
13291	10	1	133
13292	10	2	133
13293	10	3	133
13294	10	4	133
13295	10	5	133
13296	10	6	133
13297	10	7	133
13298	10	8	133
13299	10	9	133
13300	10	10	133
13301	1	1	134
13302	1	2	134
13303	1	3	134
13304	1	4	134
13305	1	5	134
13306	1	6	134
13307	1	7	134
13308	1	8	134
13309	1	9	134
13310	1	10	134
13311	2	1	134
13312	2	2	134
13313	2	3	134
13314	2	4	134
13315	2	5	134
13316	2	6	134
13317	2	7	134
13318	2	8	134
13319	2	9	134
13320	2	10	134
13321	3	1	134
13322	3	2	134
13323	3	3	134
13324	3	4	134
13325	3	5	134
13326	3	6	134
13327	3	7	134
13328	3	8	134
13329	3	9	134
13330	3	10	134
13331	4	1	134
13332	4	2	134
13333	4	3	134
13334	4	4	134
13335	4	5	134
13336	4	6	134
13337	4	7	134
13338	4	8	134
13339	4	9	134
13340	4	10	134
13341	5	1	134
13342	5	2	134
13343	5	3	134
13344	5	4	134
13345	5	5	134
13346	5	6	134
13347	5	7	134
13348	5	8	134
13349	5	9	134
13350	5	10	134
13351	6	1	134
13352	6	2	134
13353	6	3	134
13354	6	4	134
13355	6	5	134
13356	6	6	134
13357	6	7	134
13358	6	8	134
13359	6	9	134
13360	6	10	134
13361	7	1	134
13362	7	2	134
13363	7	3	134
13364	7	4	134
13365	7	5	134
13366	7	6	134
13367	7	7	134
13368	7	8	134
13369	7	9	134
13370	7	10	134
13371	8	1	134
13372	8	2	134
13373	8	3	134
13374	8	4	134
13375	8	5	134
13376	8	6	134
13377	8	7	134
13378	8	8	134
13379	8	9	134
13380	8	10	134
13381	9	1	134
13382	9	2	134
13383	9	3	134
13384	9	4	134
13385	9	5	134
13386	9	6	134
13387	9	7	134
13388	9	8	134
13389	9	9	134
13390	9	10	134
13391	10	1	134
13392	10	2	134
13393	10	3	134
13394	10	4	134
13395	10	5	134
13396	10	6	134
13397	10	7	134
13398	10	8	134
13399	10	9	134
13400	10	10	134
13401	1	1	135
13402	1	2	135
13403	1	3	135
13404	1	4	135
13405	1	5	135
13406	1	6	135
13407	1	7	135
13408	1	8	135
13409	1	9	135
13410	1	10	135
13411	2	1	135
13412	2	2	135
13413	2	3	135
13414	2	4	135
13415	2	5	135
13416	2	6	135
13417	2	7	135
13418	2	8	135
13419	2	9	135
13420	2	10	135
13421	3	1	135
13422	3	2	135
13423	3	3	135
13424	3	4	135
13425	3	5	135
13426	3	6	135
13427	3	7	135
13428	3	8	135
13429	3	9	135
13430	3	10	135
13431	4	1	135
13432	4	2	135
13433	4	3	135
13434	4	4	135
13435	4	5	135
13436	4	6	135
13437	4	7	135
13438	4	8	135
13439	4	9	135
13440	4	10	135
13441	5	1	135
13442	5	2	135
13443	5	3	135
13444	5	4	135
13445	5	5	135
13446	5	6	135
13447	5	7	135
13448	5	8	135
13449	5	9	135
13450	5	10	135
13451	6	1	135
13452	6	2	135
13453	6	3	135
13454	6	4	135
13455	6	5	135
13456	6	6	135
13457	6	7	135
13458	6	8	135
13459	6	9	135
13460	6	10	135
13461	7	1	135
13462	7	2	135
13463	7	3	135
13464	7	4	135
13465	7	5	135
13466	7	6	135
13467	7	7	135
13468	7	8	135
13469	7	9	135
13470	7	10	135
13471	8	1	135
13472	8	2	135
13473	8	3	135
13474	8	4	135
13475	8	5	135
13476	8	6	135
13477	8	7	135
13478	8	8	135
13479	8	9	135
13480	8	10	135
13481	9	1	135
13482	9	2	135
13483	9	3	135
13484	9	4	135
13485	9	5	135
13486	9	6	135
13487	9	7	135
13488	9	8	135
13489	9	9	135
13490	9	10	135
13491	10	1	135
13492	10	2	135
13493	10	3	135
13494	10	4	135
13495	10	5	135
13496	10	6	135
13497	10	7	135
13498	10	8	135
13499	10	9	135
13500	10	10	135
13501	1	1	136
13502	1	2	136
13503	1	3	136
13504	1	4	136
13505	1	5	136
13506	1	6	136
13507	1	7	136
13508	1	8	136
13509	1	9	136
13510	1	10	136
13511	2	1	136
13512	2	2	136
13513	2	3	136
13514	2	4	136
13515	2	5	136
13516	2	6	136
13517	2	7	136
13518	2	8	136
13519	2	9	136
13520	2	10	136
13521	3	1	136
13522	3	2	136
13523	3	3	136
13524	3	4	136
13525	3	5	136
13526	3	6	136
13527	3	7	136
13528	3	8	136
13529	3	9	136
13530	3	10	136
13531	4	1	136
13532	4	2	136
13533	4	3	136
13534	4	4	136
13535	4	5	136
13536	4	6	136
13537	4	7	136
13538	4	8	136
13539	4	9	136
13540	4	10	136
13541	5	1	136
13542	5	2	136
13543	5	3	136
13544	5	4	136
13545	5	5	136
13546	5	6	136
13547	5	7	136
13548	5	8	136
13549	5	9	136
13550	5	10	136
13551	6	1	136
13552	6	2	136
13553	6	3	136
13554	6	4	136
13555	6	5	136
13556	6	6	136
13557	6	7	136
13558	6	8	136
13559	6	9	136
13560	6	10	136
13561	7	1	136
13562	7	2	136
13563	7	3	136
13564	7	4	136
13565	7	5	136
13566	7	6	136
13567	7	7	136
13568	7	8	136
13569	7	9	136
13570	7	10	136
13571	8	1	136
13572	8	2	136
13573	8	3	136
13574	8	4	136
13575	8	5	136
13576	8	6	136
13577	8	7	136
13578	8	8	136
13579	8	9	136
13580	8	10	136
13581	9	1	136
13582	9	2	136
13583	9	3	136
13584	9	4	136
13585	9	5	136
13586	9	6	136
13587	9	7	136
13588	9	8	136
13589	9	9	136
13590	9	10	136
13591	10	1	136
13592	10	2	136
13593	10	3	136
13594	10	4	136
13595	10	5	136
13596	10	6	136
13597	10	7	136
13598	10	8	136
13599	10	9	136
13600	10	10	136
13601	1	1	137
13602	1	2	137
13603	1	3	137
13604	1	4	137
13605	1	5	137
13606	1	6	137
13607	1	7	137
13608	1	8	137
13609	1	9	137
13610	1	10	137
13611	2	1	137
13612	2	2	137
13613	2	3	137
13614	2	4	137
13615	2	5	137
13616	2	6	137
13617	2	7	137
13618	2	8	137
13619	2	9	137
13620	2	10	137
13621	3	1	137
13622	3	2	137
13623	3	3	137
13624	3	4	137
13625	3	5	137
13626	3	6	137
13627	3	7	137
13628	3	8	137
13629	3	9	137
13630	3	10	137
13631	4	1	137
13632	4	2	137
13633	4	3	137
13634	4	4	137
13635	4	5	137
13636	4	6	137
13637	4	7	137
13638	4	8	137
13639	4	9	137
13640	4	10	137
13641	5	1	137
13642	5	2	137
13643	5	3	137
13644	5	4	137
13645	5	5	137
13646	5	6	137
13647	5	7	137
13648	5	8	137
13649	5	9	137
13650	5	10	137
13651	6	1	137
13652	6	2	137
13653	6	3	137
13654	6	4	137
13655	6	5	137
13656	6	6	137
13657	6	7	137
13658	6	8	137
13659	6	9	137
13660	6	10	137
13661	7	1	137
13662	7	2	137
13663	7	3	137
13664	7	4	137
13665	7	5	137
13666	7	6	137
13667	7	7	137
13668	7	8	137
13669	7	9	137
13670	7	10	137
13671	8	1	137
13672	8	2	137
13673	8	3	137
13674	8	4	137
13675	8	5	137
13676	8	6	137
13677	8	7	137
13678	8	8	137
13679	8	9	137
13680	8	10	137
13681	9	1	137
13682	9	2	137
13683	9	3	137
13684	9	4	137
13685	9	5	137
13686	9	6	137
13687	9	7	137
13688	9	8	137
13689	9	9	137
13690	9	10	137
13691	10	1	137
13692	10	2	137
13693	10	3	137
13694	10	4	137
13695	10	5	137
13696	10	6	137
13697	10	7	137
13698	10	8	137
13699	10	9	137
13700	10	10	137
13701	1	1	138
13702	1	2	138
13703	1	3	138
13704	1	4	138
13705	1	5	138
13706	1	6	138
13707	1	7	138
13708	1	8	138
13709	1	9	138
13710	1	10	138
13711	2	1	138
13712	2	2	138
13713	2	3	138
13714	2	4	138
13715	2	5	138
13716	2	6	138
13717	2	7	138
13718	2	8	138
13719	2	9	138
13720	2	10	138
13721	3	1	138
13722	3	2	138
13723	3	3	138
13724	3	4	138
13725	3	5	138
13726	3	6	138
13727	3	7	138
13728	3	8	138
13729	3	9	138
13730	3	10	138
13731	4	1	138
13732	4	2	138
13733	4	3	138
13734	4	4	138
13735	4	5	138
13736	4	6	138
13737	4	7	138
13738	4	8	138
13739	4	9	138
13740	4	10	138
13741	5	1	138
13742	5	2	138
13743	5	3	138
13744	5	4	138
13745	5	5	138
13746	5	6	138
13747	5	7	138
13748	5	8	138
13749	5	9	138
13750	5	10	138
13751	6	1	138
13752	6	2	138
13753	6	3	138
13754	6	4	138
13755	6	5	138
13756	6	6	138
13757	6	7	138
13758	6	8	138
13759	6	9	138
13760	6	10	138
13761	7	1	138
13762	7	2	138
13763	7	3	138
13764	7	4	138
13765	7	5	138
13766	7	6	138
13767	7	7	138
13768	7	8	138
13769	7	9	138
13770	7	10	138
13771	8	1	138
13772	8	2	138
13773	8	3	138
13774	8	4	138
13775	8	5	138
13776	8	6	138
13777	8	7	138
13778	8	8	138
13779	8	9	138
13780	8	10	138
13781	9	1	138
13782	9	2	138
13783	9	3	138
13784	9	4	138
13785	9	5	138
13786	9	6	138
13787	9	7	138
13788	9	8	138
13789	9	9	138
13790	9	10	138
13791	10	1	138
13792	10	2	138
13793	10	3	138
13794	10	4	138
13795	10	5	138
13796	10	6	138
13797	10	7	138
13798	10	8	138
13799	10	9	138
13800	10	10	138
13801	1	1	139
13802	1	2	139
13803	1	3	139
13804	1	4	139
13805	1	5	139
13806	1	6	139
13807	1	7	139
13808	1	8	139
13809	1	9	139
13810	1	10	139
13811	2	1	139
13812	2	2	139
13813	2	3	139
13814	2	4	139
13815	2	5	139
13816	2	6	139
13817	2	7	139
13818	2	8	139
13819	2	9	139
13820	2	10	139
13821	3	1	139
13822	3	2	139
13823	3	3	139
13824	3	4	139
13825	3	5	139
13826	3	6	139
13827	3	7	139
13828	3	8	139
13829	3	9	139
13830	3	10	139
13831	4	1	139
13832	4	2	139
13833	4	3	139
13834	4	4	139
13835	4	5	139
13836	4	6	139
13837	4	7	139
13838	4	8	139
13839	4	9	139
13840	4	10	139
13841	5	1	139
13842	5	2	139
13843	5	3	139
13844	5	4	139
13845	5	5	139
13846	5	6	139
13847	5	7	139
13848	5	8	139
13849	5	9	139
13850	5	10	139
13851	6	1	139
13852	6	2	139
13853	6	3	139
13854	6	4	139
13855	6	5	139
13856	6	6	139
13857	6	7	139
13858	6	8	139
13859	6	9	139
13860	6	10	139
13861	7	1	139
13862	7	2	139
13863	7	3	139
13864	7	4	139
13865	7	5	139
13866	7	6	139
13867	7	7	139
13868	7	8	139
13869	7	9	139
13870	7	10	139
13871	8	1	139
13872	8	2	139
13873	8	3	139
13874	8	4	139
13875	8	5	139
13876	8	6	139
13877	8	7	139
13878	8	8	139
13879	8	9	139
13880	8	10	139
13881	9	1	139
13882	9	2	139
13883	9	3	139
13884	9	4	139
13885	9	5	139
13886	9	6	139
13887	9	7	139
13888	9	8	139
13889	9	9	139
13890	9	10	139
13891	10	1	139
13892	10	2	139
13893	10	3	139
13894	10	4	139
13895	10	5	139
13896	10	6	139
13897	10	7	139
13898	10	8	139
13899	10	9	139
13900	10	10	139
13901	1	1	140
13902	1	2	140
13903	1	3	140
13904	1	4	140
13905	1	5	140
13906	1	6	140
13907	1	7	140
13908	1	8	140
13909	1	9	140
13910	1	10	140
13911	2	1	140
13912	2	2	140
13913	2	3	140
13914	2	4	140
13915	2	5	140
13916	2	6	140
13917	2	7	140
13918	2	8	140
13919	2	9	140
13920	2	10	140
13921	3	1	140
13922	3	2	140
13923	3	3	140
13924	3	4	140
13925	3	5	140
13926	3	6	140
13927	3	7	140
13928	3	8	140
13929	3	9	140
13930	3	10	140
13931	4	1	140
13932	4	2	140
13933	4	3	140
13934	4	4	140
13935	4	5	140
13936	4	6	140
13937	4	7	140
13938	4	8	140
13939	4	9	140
13940	4	10	140
13941	5	1	140
13942	5	2	140
13943	5	3	140
13944	5	4	140
13945	5	5	140
13946	5	6	140
13947	5	7	140
13948	5	8	140
13949	5	9	140
13950	5	10	140
13951	6	1	140
13952	6	2	140
13953	6	3	140
13954	6	4	140
13955	6	5	140
13956	6	6	140
13957	6	7	140
13958	6	8	140
13959	6	9	140
13960	6	10	140
13961	7	1	140
13962	7	2	140
13963	7	3	140
13964	7	4	140
13965	7	5	140
13966	7	6	140
13967	7	7	140
13968	7	8	140
13969	7	9	140
13970	7	10	140
13971	8	1	140
13972	8	2	140
13973	8	3	140
13974	8	4	140
13975	8	5	140
13976	8	6	140
13977	8	7	140
13978	8	8	140
13979	8	9	140
13980	8	10	140
13981	9	1	140
13982	9	2	140
13983	9	3	140
13984	9	4	140
13985	9	5	140
13986	9	6	140
13987	9	7	140
13988	9	8	140
13989	9	9	140
13990	9	10	140
13991	10	1	140
13992	10	2	140
13993	10	3	140
13994	10	4	140
13995	10	5	140
13996	10	6	140
13997	10	7	140
13998	10	8	140
13999	10	9	140
14000	10	10	140
14001	1	1	141
14002	1	2	141
14003	1	3	141
14004	1	4	141
14005	1	5	141
14006	1	6	141
14007	1	7	141
14008	1	8	141
14009	1	9	141
14010	1	10	141
14011	2	1	141
14012	2	2	141
14013	2	3	141
14014	2	4	141
14015	2	5	141
14016	2	6	141
14017	2	7	141
14018	2	8	141
14019	2	9	141
14020	2	10	141
14021	3	1	141
14022	3	2	141
14023	3	3	141
14024	3	4	141
14025	3	5	141
14026	3	6	141
14027	3	7	141
14028	3	8	141
14029	3	9	141
14030	3	10	141
14031	4	1	141
14032	4	2	141
14033	4	3	141
14034	4	4	141
14035	4	5	141
14036	4	6	141
14037	4	7	141
14038	4	8	141
14039	4	9	141
14040	4	10	141
14041	5	1	141
14042	5	2	141
14043	5	3	141
14044	5	4	141
14045	5	5	141
14046	5	6	141
14047	5	7	141
14048	5	8	141
14049	5	9	141
14050	5	10	141
14051	6	1	141
14052	6	2	141
14053	6	3	141
14054	6	4	141
14055	6	5	141
14056	6	6	141
14057	6	7	141
14058	6	8	141
14059	6	9	141
14060	6	10	141
14061	7	1	141
14062	7	2	141
14063	7	3	141
14064	7	4	141
14065	7	5	141
14066	7	6	141
14067	7	7	141
14068	7	8	141
14069	7	9	141
14070	7	10	141
14071	8	1	141
14072	8	2	141
14073	8	3	141
14074	8	4	141
14075	8	5	141
14076	8	6	141
14077	8	7	141
14078	8	8	141
14079	8	9	141
14080	8	10	141
14081	9	1	141
14082	9	2	141
14083	9	3	141
14084	9	4	141
14085	9	5	141
14086	9	6	141
14087	9	7	141
14088	9	8	141
14089	9	9	141
14090	9	10	141
14091	10	1	141
14092	10	2	141
14093	10	3	141
14094	10	4	141
14095	10	5	141
14096	10	6	141
14097	10	7	141
14098	10	8	141
14099	10	9	141
14100	10	10	141
14101	1	1	142
14102	1	2	142
14103	1	3	142
14104	1	4	142
14105	1	5	142
14106	1	6	142
14107	1	7	142
14108	1	8	142
14109	1	9	142
14110	1	10	142
14111	2	1	142
14112	2	2	142
14113	2	3	142
14114	2	4	142
14115	2	5	142
14116	2	6	142
14117	2	7	142
14118	2	8	142
14119	2	9	142
14120	2	10	142
14121	3	1	142
14122	3	2	142
14123	3	3	142
14124	3	4	142
14125	3	5	142
14126	3	6	142
14127	3	7	142
14128	3	8	142
14129	3	9	142
14130	3	10	142
14131	4	1	142
14132	4	2	142
14133	4	3	142
14134	4	4	142
14135	4	5	142
14136	4	6	142
14137	4	7	142
14138	4	8	142
14139	4	9	142
14140	4	10	142
14141	5	1	142
14142	5	2	142
14143	5	3	142
14144	5	4	142
14145	5	5	142
14146	5	6	142
14147	5	7	142
14148	5	8	142
14149	5	9	142
14150	5	10	142
14151	6	1	142
14152	6	2	142
14153	6	3	142
14154	6	4	142
14155	6	5	142
14156	6	6	142
14157	6	7	142
14158	6	8	142
14159	6	9	142
14160	6	10	142
14161	7	1	142
14162	7	2	142
14163	7	3	142
14164	7	4	142
14165	7	5	142
14166	7	6	142
14167	7	7	142
14168	7	8	142
14169	7	9	142
14170	7	10	142
14171	8	1	142
14172	8	2	142
14173	8	3	142
14174	8	4	142
14175	8	5	142
14176	8	6	142
14177	8	7	142
14178	8	8	142
14179	8	9	142
14180	8	10	142
14181	9	1	142
14182	9	2	142
14183	9	3	142
14184	9	4	142
14185	9	5	142
14186	9	6	142
14187	9	7	142
14188	9	8	142
14189	9	9	142
14190	9	10	142
14191	10	1	142
14192	10	2	142
14193	10	3	142
14194	10	4	142
14195	10	5	142
14196	10	6	142
14197	10	7	142
14198	10	8	142
14199	10	9	142
14200	10	10	142
14201	1	1	143
14202	1	2	143
14203	1	3	143
14204	1	4	143
14205	1	5	143
14206	1	6	143
14207	1	7	143
14208	1	8	143
14209	1	9	143
14210	1	10	143
14211	2	1	143
14212	2	2	143
14213	2	3	143
14214	2	4	143
14215	2	5	143
14216	2	6	143
14217	2	7	143
14218	2	8	143
14219	2	9	143
14220	2	10	143
14221	3	1	143
14222	3	2	143
14223	3	3	143
14224	3	4	143
14225	3	5	143
14226	3	6	143
14227	3	7	143
14228	3	8	143
14229	3	9	143
14230	3	10	143
14231	4	1	143
14232	4	2	143
14233	4	3	143
14234	4	4	143
14235	4	5	143
14236	4	6	143
14237	4	7	143
14238	4	8	143
14239	4	9	143
14240	4	10	143
14241	5	1	143
14242	5	2	143
14243	5	3	143
14244	5	4	143
14245	5	5	143
14246	5	6	143
14247	5	7	143
14248	5	8	143
14249	5	9	143
14250	5	10	143
14251	6	1	143
14252	6	2	143
14253	6	3	143
14254	6	4	143
14255	6	5	143
14256	6	6	143
14257	6	7	143
14258	6	8	143
14259	6	9	143
14260	6	10	143
14261	7	1	143
14262	7	2	143
14263	7	3	143
14264	7	4	143
14265	7	5	143
14266	7	6	143
14267	7	7	143
14268	7	8	143
14269	7	9	143
14270	7	10	143
14271	8	1	143
14272	8	2	143
14273	8	3	143
14274	8	4	143
14275	8	5	143
14276	8	6	143
14277	8	7	143
14278	8	8	143
14279	8	9	143
14280	8	10	143
14281	9	1	143
14282	9	2	143
14283	9	3	143
14284	9	4	143
14285	9	5	143
14286	9	6	143
14287	9	7	143
14288	9	8	143
14289	9	9	143
14290	9	10	143
14291	10	1	143
14292	10	2	143
14293	10	3	143
14294	10	4	143
14295	10	5	143
14296	10	6	143
14297	10	7	143
14298	10	8	143
14299	10	9	143
14300	10	10	143
14301	1	1	144
14302	1	2	144
14303	1	3	144
14304	1	4	144
14305	1	5	144
14306	1	6	144
14307	1	7	144
14308	1	8	144
14309	1	9	144
14310	1	10	144
14311	2	1	144
14312	2	2	144
14313	2	3	144
14314	2	4	144
14315	2	5	144
14316	2	6	144
14317	2	7	144
14318	2	8	144
14319	2	9	144
14320	2	10	144
14321	3	1	144
14322	3	2	144
14323	3	3	144
14324	3	4	144
14325	3	5	144
14326	3	6	144
14327	3	7	144
14328	3	8	144
14329	3	9	144
14330	3	10	144
14331	4	1	144
14332	4	2	144
14333	4	3	144
14334	4	4	144
14335	4	5	144
14336	4	6	144
14337	4	7	144
14338	4	8	144
14339	4	9	144
14340	4	10	144
14341	5	1	144
14342	5	2	144
14343	5	3	144
14344	5	4	144
14345	5	5	144
14346	5	6	144
14347	5	7	144
14348	5	8	144
14349	5	9	144
14350	5	10	144
14351	6	1	144
14352	6	2	144
14353	6	3	144
14354	6	4	144
14355	6	5	144
14356	6	6	144
14357	6	7	144
14358	6	8	144
14359	6	9	144
14360	6	10	144
14361	7	1	144
14362	7	2	144
14363	7	3	144
14364	7	4	144
14365	7	5	144
14366	7	6	144
14367	7	7	144
14368	7	8	144
14369	7	9	144
14370	7	10	144
14371	8	1	144
14372	8	2	144
14373	8	3	144
14374	8	4	144
14375	8	5	144
14376	8	6	144
14377	8	7	144
14378	8	8	144
14379	8	9	144
14380	8	10	144
14381	9	1	144
14382	9	2	144
14383	9	3	144
14384	9	4	144
14385	9	5	144
14386	9	6	144
14387	9	7	144
14388	9	8	144
14389	9	9	144
14390	9	10	144
14391	10	1	144
14392	10	2	144
14393	10	3	144
14394	10	4	144
14395	10	5	144
14396	10	6	144
14397	10	7	144
14398	10	8	144
14399	10	9	144
14400	10	10	144
14401	1	1	145
14402	1	2	145
14403	1	3	145
14404	1	4	145
14405	1	5	145
14406	1	6	145
14407	1	7	145
14408	1	8	145
14409	1	9	145
14410	1	10	145
14411	2	1	145
14412	2	2	145
14413	2	3	145
14414	2	4	145
14415	2	5	145
14416	2	6	145
14417	2	7	145
14418	2	8	145
14419	2	9	145
14420	2	10	145
14421	3	1	145
14422	3	2	145
14423	3	3	145
14424	3	4	145
14425	3	5	145
14426	3	6	145
14427	3	7	145
14428	3	8	145
14429	3	9	145
14430	3	10	145
14431	4	1	145
14432	4	2	145
14433	4	3	145
14434	4	4	145
14435	4	5	145
14436	4	6	145
14437	4	7	145
14438	4	8	145
14439	4	9	145
14440	4	10	145
14441	5	1	145
14442	5	2	145
14443	5	3	145
14444	5	4	145
14445	5	5	145
14446	5	6	145
14447	5	7	145
14448	5	8	145
14449	5	9	145
14450	5	10	145
14451	6	1	145
14452	6	2	145
14453	6	3	145
14454	6	4	145
14455	6	5	145
14456	6	6	145
14457	6	7	145
14458	6	8	145
14459	6	9	145
14460	6	10	145
14461	7	1	145
14462	7	2	145
14463	7	3	145
14464	7	4	145
14465	7	5	145
14466	7	6	145
14467	7	7	145
14468	7	8	145
14469	7	9	145
14470	7	10	145
14471	8	1	145
14472	8	2	145
14473	8	3	145
14474	8	4	145
14475	8	5	145
14476	8	6	145
14477	8	7	145
14478	8	8	145
14479	8	9	145
14480	8	10	145
14481	9	1	145
14482	9	2	145
14483	9	3	145
14484	9	4	145
14485	9	5	145
14486	9	6	145
14487	9	7	145
14488	9	8	145
14489	9	9	145
14490	9	10	145
14491	10	1	145
14492	10	2	145
14493	10	3	145
14494	10	4	145
14495	10	5	145
14496	10	6	145
14497	10	7	145
14498	10	8	145
14499	10	9	145
14500	10	10	145
14501	1	1	146
14502	1	2	146
14503	1	3	146
14504	1	4	146
14505	1	5	146
14506	1	6	146
14507	1	7	146
14508	1	8	146
14509	1	9	146
14510	1	10	146
14511	2	1	146
14512	2	2	146
14513	2	3	146
14514	2	4	146
14515	2	5	146
14516	2	6	146
14517	2	7	146
14518	2	8	146
14519	2	9	146
14520	2	10	146
14521	3	1	146
14522	3	2	146
14523	3	3	146
14524	3	4	146
14525	3	5	146
14526	3	6	146
14527	3	7	146
14528	3	8	146
14529	3	9	146
14530	3	10	146
14531	4	1	146
14532	4	2	146
14533	4	3	146
14534	4	4	146
14535	4	5	146
14536	4	6	146
14537	4	7	146
14538	4	8	146
14539	4	9	146
14540	4	10	146
14541	5	1	146
14542	5	2	146
14543	5	3	146
14544	5	4	146
14545	5	5	146
14546	5	6	146
14547	5	7	146
14548	5	8	146
14549	5	9	146
14550	5	10	146
14551	6	1	146
14552	6	2	146
14553	6	3	146
14554	6	4	146
14555	6	5	146
14556	6	6	146
14557	6	7	146
14558	6	8	146
14559	6	9	146
14560	6	10	146
14561	7	1	146
14562	7	2	146
14563	7	3	146
14564	7	4	146
14565	7	5	146
14566	7	6	146
14567	7	7	146
14568	7	8	146
14569	7	9	146
14570	7	10	146
14571	8	1	146
14572	8	2	146
14573	8	3	146
14574	8	4	146
14575	8	5	146
14576	8	6	146
14577	8	7	146
14578	8	8	146
14579	8	9	146
14580	8	10	146
14581	9	1	146
14582	9	2	146
14583	9	3	146
14584	9	4	146
14585	9	5	146
14586	9	6	146
14587	9	7	146
14588	9	8	146
14589	9	9	146
14590	9	10	146
14591	10	1	146
14592	10	2	146
14593	10	3	146
14594	10	4	146
14595	10	5	146
14596	10	6	146
14597	10	7	146
14598	10	8	146
14599	10	9	146
14600	10	10	146
14601	1	1	147
14602	1	2	147
14603	1	3	147
14604	1	4	147
14605	1	5	147
14606	1	6	147
14607	1	7	147
14608	1	8	147
14609	1	9	147
14610	1	10	147
14611	2	1	147
14612	2	2	147
14613	2	3	147
14614	2	4	147
14615	2	5	147
14616	2	6	147
14617	2	7	147
14618	2	8	147
14619	2	9	147
14620	2	10	147
14621	3	1	147
14622	3	2	147
14623	3	3	147
14624	3	4	147
14625	3	5	147
14626	3	6	147
14627	3	7	147
14628	3	8	147
14629	3	9	147
14630	3	10	147
14631	4	1	147
14632	4	2	147
14633	4	3	147
14634	4	4	147
14635	4	5	147
14636	4	6	147
14637	4	7	147
14638	4	8	147
14639	4	9	147
14640	4	10	147
14641	5	1	147
14642	5	2	147
14643	5	3	147
14644	5	4	147
14645	5	5	147
14646	5	6	147
14647	5	7	147
14648	5	8	147
14649	5	9	147
14650	5	10	147
14651	6	1	147
14652	6	2	147
14653	6	3	147
14654	6	4	147
14655	6	5	147
14656	6	6	147
14657	6	7	147
14658	6	8	147
14659	6	9	147
14660	6	10	147
14661	7	1	147
14662	7	2	147
14663	7	3	147
14664	7	4	147
14665	7	5	147
14666	7	6	147
14667	7	7	147
14668	7	8	147
14669	7	9	147
14670	7	10	147
14671	8	1	147
14672	8	2	147
14673	8	3	147
14674	8	4	147
14675	8	5	147
14676	8	6	147
14677	8	7	147
14678	8	8	147
14679	8	9	147
14680	8	10	147
14681	9	1	147
14682	9	2	147
14683	9	3	147
14684	9	4	147
14685	9	5	147
14686	9	6	147
14687	9	7	147
14688	9	8	147
14689	9	9	147
14690	9	10	147
14691	10	1	147
14692	10	2	147
14693	10	3	147
14694	10	4	147
14695	10	5	147
14696	10	6	147
14697	10	7	147
14698	10	8	147
14699	10	9	147
14700	10	10	147
14701	1	1	148
14702	1	2	148
14703	1	3	148
14704	1	4	148
14705	1	5	148
14706	1	6	148
14707	1	7	148
14708	1	8	148
14709	1	9	148
14710	1	10	148
14711	2	1	148
14712	2	2	148
14713	2	3	148
14714	2	4	148
14715	2	5	148
14716	2	6	148
14717	2	7	148
14718	2	8	148
14719	2	9	148
14720	2	10	148
14721	3	1	148
14722	3	2	148
14723	3	3	148
14724	3	4	148
14725	3	5	148
14726	3	6	148
14727	3	7	148
14728	3	8	148
14729	3	9	148
14730	3	10	148
14731	4	1	148
14732	4	2	148
14733	4	3	148
14734	4	4	148
14735	4	5	148
14736	4	6	148
14737	4	7	148
14738	4	8	148
14739	4	9	148
14740	4	10	148
14741	5	1	148
14742	5	2	148
14743	5	3	148
14744	5	4	148
14745	5	5	148
14746	5	6	148
14747	5	7	148
14748	5	8	148
14749	5	9	148
14750	5	10	148
14751	6	1	148
14752	6	2	148
14753	6	3	148
14754	6	4	148
14755	6	5	148
14756	6	6	148
14757	6	7	148
14758	6	8	148
14759	6	9	148
14760	6	10	148
14761	7	1	148
14762	7	2	148
14763	7	3	148
14764	7	4	148
14765	7	5	148
14766	7	6	148
14767	7	7	148
14768	7	8	148
14769	7	9	148
14770	7	10	148
14771	8	1	148
14772	8	2	148
14773	8	3	148
14774	8	4	148
14775	8	5	148
14776	8	6	148
14777	8	7	148
14778	8	8	148
14779	8	9	148
14780	8	10	148
14781	9	1	148
14782	9	2	148
14783	9	3	148
14784	9	4	148
14785	9	5	148
14786	9	6	148
14787	9	7	148
14788	9	8	148
14789	9	9	148
14790	9	10	148
14791	10	1	148
14792	10	2	148
14793	10	3	148
14794	10	4	148
14795	10	5	148
14796	10	6	148
14797	10	7	148
14798	10	8	148
14799	10	9	148
14800	10	10	148
14801	1	1	149
14802	1	2	149
14803	1	3	149
14804	1	4	149
14805	1	5	149
14806	1	6	149
14807	1	7	149
14808	1	8	149
14809	1	9	149
14810	1	10	149
14811	2	1	149
14812	2	2	149
14813	2	3	149
14814	2	4	149
14815	2	5	149
14816	2	6	149
14817	2	7	149
14818	2	8	149
14819	2	9	149
14820	2	10	149
14821	3	1	149
14822	3	2	149
14823	3	3	149
14824	3	4	149
14825	3	5	149
14826	3	6	149
14827	3	7	149
14828	3	8	149
14829	3	9	149
14830	3	10	149
14831	4	1	149
14832	4	2	149
14833	4	3	149
14834	4	4	149
14835	4	5	149
14836	4	6	149
14837	4	7	149
14838	4	8	149
14839	4	9	149
14840	4	10	149
14841	5	1	149
14842	5	2	149
14843	5	3	149
14844	5	4	149
14845	5	5	149
14846	5	6	149
14847	5	7	149
14848	5	8	149
14849	5	9	149
14850	5	10	149
14851	6	1	149
14852	6	2	149
14853	6	3	149
14854	6	4	149
14855	6	5	149
14856	6	6	149
14857	6	7	149
14858	6	8	149
14859	6	9	149
14860	6	10	149
14861	7	1	149
14862	7	2	149
14863	7	3	149
14864	7	4	149
14865	7	5	149
14866	7	6	149
14867	7	7	149
14868	7	8	149
14869	7	9	149
14870	7	10	149
14871	8	1	149
14872	8	2	149
14873	8	3	149
14874	8	4	149
14875	8	5	149
14876	8	6	149
14877	8	7	149
14878	8	8	149
14879	8	9	149
14880	8	10	149
14881	9	1	149
14882	9	2	149
14883	9	3	149
14884	9	4	149
14885	9	5	149
14886	9	6	149
14887	9	7	149
14888	9	8	149
14889	9	9	149
14890	9	10	149
14891	10	1	149
14892	10	2	149
14893	10	3	149
14894	10	4	149
14895	10	5	149
14896	10	6	149
14897	10	7	149
14898	10	8	149
14899	10	9	149
14900	10	10	149
14901	1	1	150
14902	1	2	150
14903	1	3	150
14904	1	4	150
14905	1	5	150
14906	1	6	150
14907	1	7	150
14908	1	8	150
14909	1	9	150
14910	1	10	150
14911	2	1	150
14912	2	2	150
14913	2	3	150
14914	2	4	150
14915	2	5	150
14916	2	6	150
14917	2	7	150
14918	2	8	150
14919	2	9	150
14920	2	10	150
14921	3	1	150
14922	3	2	150
14923	3	3	150
14924	3	4	150
14925	3	5	150
14926	3	6	150
14927	3	7	150
14928	3	8	150
14929	3	9	150
14930	3	10	150
14931	4	1	150
14932	4	2	150
14933	4	3	150
14934	4	4	150
14935	4	5	150
14936	4	6	150
14937	4	7	150
14938	4	8	150
14939	4	9	150
14940	4	10	150
14941	5	1	150
14942	5	2	150
14943	5	3	150
14944	5	4	150
14945	5	5	150
14946	5	6	150
14947	5	7	150
14948	5	8	150
14949	5	9	150
14950	5	10	150
14951	6	1	150
14952	6	2	150
14953	6	3	150
14954	6	4	150
14955	6	5	150
14956	6	6	150
14957	6	7	150
14958	6	8	150
14959	6	9	150
14960	6	10	150
14961	7	1	150
14962	7	2	150
14963	7	3	150
14964	7	4	150
14965	7	5	150
14966	7	6	150
14967	7	7	150
14968	7	8	150
14969	7	9	150
14970	7	10	150
14971	8	1	150
14972	8	2	150
14973	8	3	150
14974	8	4	150
14975	8	5	150
14976	8	6	150
14977	8	7	150
14978	8	8	150
14979	8	9	150
14980	8	10	150
14981	9	1	150
14982	9	2	150
14983	9	3	150
14984	9	4	150
14985	9	5	150
14986	9	6	150
14987	9	7	150
14988	9	8	150
14989	9	9	150
14990	9	10	150
14991	10	1	150
14992	10	2	150
14993	10	3	150
14994	10	4	150
14995	10	5	150
14996	10	6	150
14997	10	7	150
14998	10	8	150
14999	10	9	150
15000	10	10	150
15001	1	1	151
15002	1	2	151
15003	1	3	151
15004	1	4	151
15005	1	5	151
15006	1	6	151
15007	1	7	151
15008	1	8	151
15009	1	9	151
15010	1	10	151
15011	2	1	151
15012	2	2	151
15013	2	3	151
15014	2	4	151
15015	2	5	151
15016	2	6	151
15017	2	7	151
15018	2	8	151
15019	2	9	151
15020	2	10	151
15021	3	1	151
15022	3	2	151
15023	3	3	151
15024	3	4	151
15025	3	5	151
15026	3	6	151
15027	3	7	151
15028	3	8	151
15029	3	9	151
15030	3	10	151
15031	4	1	151
15032	4	2	151
15033	4	3	151
15034	4	4	151
15035	4	5	151
15036	4	6	151
15037	4	7	151
15038	4	8	151
15039	4	9	151
15040	4	10	151
15041	5	1	151
15042	5	2	151
15043	5	3	151
15044	5	4	151
15045	5	5	151
15046	5	6	151
15047	5	7	151
15048	5	8	151
15049	5	9	151
15050	5	10	151
15051	6	1	151
15052	6	2	151
15053	6	3	151
15054	6	4	151
15055	6	5	151
15056	6	6	151
15057	6	7	151
15058	6	8	151
15059	6	9	151
15060	6	10	151
15061	7	1	151
15062	7	2	151
15063	7	3	151
15064	7	4	151
15065	7	5	151
15066	7	6	151
15067	7	7	151
15068	7	8	151
15069	7	9	151
15070	7	10	151
15071	8	1	151
15072	8	2	151
15073	8	3	151
15074	8	4	151
15075	8	5	151
15076	8	6	151
15077	8	7	151
15078	8	8	151
15079	8	9	151
15080	8	10	151
15081	9	1	151
15082	9	2	151
15083	9	3	151
15084	9	4	151
15085	9	5	151
15086	9	6	151
15087	9	7	151
15088	9	8	151
15089	9	9	151
15090	9	10	151
15091	10	1	151
15092	10	2	151
15093	10	3	151
15094	10	4	151
15095	10	5	151
15096	10	6	151
15097	10	7	151
15098	10	8	151
15099	10	9	151
15100	10	10	151
15101	1	1	152
15102	1	2	152
15103	1	3	152
15104	1	4	152
15105	1	5	152
15106	1	6	152
15107	1	7	152
15108	1	8	152
15109	1	9	152
15110	1	10	152
15111	2	1	152
15112	2	2	152
15113	2	3	152
15114	2	4	152
15115	2	5	152
15116	2	6	152
15117	2	7	152
15118	2	8	152
15119	2	9	152
15120	2	10	152
15121	3	1	152
15122	3	2	152
15123	3	3	152
15124	3	4	152
15125	3	5	152
15126	3	6	152
15127	3	7	152
15128	3	8	152
15129	3	9	152
15130	3	10	152
15131	4	1	152
15132	4	2	152
15133	4	3	152
15134	4	4	152
15135	4	5	152
15136	4	6	152
15137	4	7	152
15138	4	8	152
15139	4	9	152
15140	4	10	152
15141	5	1	152
15142	5	2	152
15143	5	3	152
15144	5	4	152
15145	5	5	152
15146	5	6	152
15147	5	7	152
15148	5	8	152
15149	5	9	152
15150	5	10	152
15151	6	1	152
15152	6	2	152
15153	6	3	152
15154	6	4	152
15155	6	5	152
15156	6	6	152
15157	6	7	152
15158	6	8	152
15159	6	9	152
15160	6	10	152
15161	7	1	152
15162	7	2	152
15163	7	3	152
15164	7	4	152
15165	7	5	152
15166	7	6	152
15167	7	7	152
15168	7	8	152
15169	7	9	152
15170	7	10	152
15171	8	1	152
15172	8	2	152
15173	8	3	152
15174	8	4	152
15175	8	5	152
15176	8	6	152
15177	8	7	152
15178	8	8	152
15179	8	9	152
15180	8	10	152
15181	9	1	152
15182	9	2	152
15183	9	3	152
15184	9	4	152
15185	9	5	152
15186	9	6	152
15187	9	7	152
15188	9	8	152
15189	9	9	152
15190	9	10	152
15191	10	1	152
15192	10	2	152
15193	10	3	152
15194	10	4	152
15195	10	5	152
15196	10	6	152
15197	10	7	152
15198	10	8	152
15199	10	9	152
15200	10	10	152
15201	1	1	153
15202	1	2	153
15203	1	3	153
15204	1	4	153
15205	1	5	153
15206	1	6	153
15207	1	7	153
15208	1	8	153
15209	1	9	153
15210	1	10	153
15211	2	1	153
15212	2	2	153
15213	2	3	153
15214	2	4	153
15215	2	5	153
15216	2	6	153
15217	2	7	153
15218	2	8	153
15219	2	9	153
15220	2	10	153
15221	3	1	153
15222	3	2	153
15223	3	3	153
15224	3	4	153
15225	3	5	153
15226	3	6	153
15227	3	7	153
15228	3	8	153
15229	3	9	153
15230	3	10	153
15231	4	1	153
15232	4	2	153
15233	4	3	153
15234	4	4	153
15235	4	5	153
15236	4	6	153
15237	4	7	153
15238	4	8	153
15239	4	9	153
15240	4	10	153
15241	5	1	153
15242	5	2	153
15243	5	3	153
15244	5	4	153
15245	5	5	153
15246	5	6	153
15247	5	7	153
15248	5	8	153
15249	5	9	153
15250	5	10	153
15251	6	1	153
15252	6	2	153
15253	6	3	153
15254	6	4	153
15255	6	5	153
15256	6	6	153
15257	6	7	153
15258	6	8	153
15259	6	9	153
15260	6	10	153
15261	7	1	153
15262	7	2	153
15263	7	3	153
15264	7	4	153
15265	7	5	153
15266	7	6	153
15267	7	7	153
15268	7	8	153
15269	7	9	153
15270	7	10	153
15271	8	1	153
15272	8	2	153
15273	8	3	153
15274	8	4	153
15275	8	5	153
15276	8	6	153
15277	8	7	153
15278	8	8	153
15279	8	9	153
15280	8	10	153
15281	9	1	153
15282	9	2	153
15283	9	3	153
15284	9	4	153
15285	9	5	153
15286	9	6	153
15287	9	7	153
15288	9	8	153
15289	9	9	153
15290	9	10	153
15291	10	1	153
15292	10	2	153
15293	10	3	153
15294	10	4	153
15295	10	5	153
15296	10	6	153
15297	10	7	153
15298	10	8	153
15299	10	9	153
15300	10	10	153
15301	1	1	154
15302	1	2	154
15303	1	3	154
15304	1	4	154
15305	1	5	154
15306	1	6	154
15307	1	7	154
15308	1	8	154
15309	1	9	154
15310	1	10	154
15311	2	1	154
15312	2	2	154
15313	2	3	154
15314	2	4	154
15315	2	5	154
15316	2	6	154
15317	2	7	154
15318	2	8	154
15319	2	9	154
15320	2	10	154
15321	3	1	154
15322	3	2	154
15323	3	3	154
15324	3	4	154
15325	3	5	154
15326	3	6	154
15327	3	7	154
15328	3	8	154
15329	3	9	154
15330	3	10	154
15331	4	1	154
15332	4	2	154
15333	4	3	154
15334	4	4	154
15335	4	5	154
15336	4	6	154
15337	4	7	154
15338	4	8	154
15339	4	9	154
15340	4	10	154
15341	5	1	154
15342	5	2	154
15343	5	3	154
15344	5	4	154
15345	5	5	154
15346	5	6	154
15347	5	7	154
15348	5	8	154
15349	5	9	154
15350	5	10	154
15351	6	1	154
15352	6	2	154
15353	6	3	154
15354	6	4	154
15355	6	5	154
15356	6	6	154
15357	6	7	154
15358	6	8	154
15359	6	9	154
15360	6	10	154
15361	7	1	154
15362	7	2	154
15363	7	3	154
15364	7	4	154
15365	7	5	154
15366	7	6	154
15367	7	7	154
15368	7	8	154
15369	7	9	154
15370	7	10	154
15371	8	1	154
15372	8	2	154
15373	8	3	154
15374	8	4	154
15375	8	5	154
15376	8	6	154
15377	8	7	154
15378	8	8	154
15379	8	9	154
15380	8	10	154
15381	9	1	154
15382	9	2	154
15383	9	3	154
15384	9	4	154
15385	9	5	154
15386	9	6	154
15387	9	7	154
15388	9	8	154
15389	9	9	154
15390	9	10	154
15391	10	1	154
15392	10	2	154
15393	10	3	154
15394	10	4	154
15395	10	5	154
15396	10	6	154
15397	10	7	154
15398	10	8	154
15399	10	9	154
15400	10	10	154
15401	1	1	155
15402	1	2	155
15403	1	3	155
15404	1	4	155
15405	1	5	155
15406	1	6	155
15407	1	7	155
15408	1	8	155
15409	1	9	155
15410	1	10	155
15411	2	1	155
15412	2	2	155
15413	2	3	155
15414	2	4	155
15415	2	5	155
15416	2	6	155
15417	2	7	155
15418	2	8	155
15419	2	9	155
15420	2	10	155
15421	3	1	155
15422	3	2	155
15423	3	3	155
15424	3	4	155
15425	3	5	155
15426	3	6	155
15427	3	7	155
15428	3	8	155
15429	3	9	155
15430	3	10	155
15431	4	1	155
15432	4	2	155
15433	4	3	155
15434	4	4	155
15435	4	5	155
15436	4	6	155
15437	4	7	155
15438	4	8	155
15439	4	9	155
15440	4	10	155
15441	5	1	155
15442	5	2	155
15443	5	3	155
15444	5	4	155
15445	5	5	155
15446	5	6	155
15447	5	7	155
15448	5	8	155
15449	5	9	155
15450	5	10	155
15451	6	1	155
15452	6	2	155
15453	6	3	155
15454	6	4	155
15455	6	5	155
15456	6	6	155
15457	6	7	155
15458	6	8	155
15459	6	9	155
15460	6	10	155
15461	7	1	155
15462	7	2	155
15463	7	3	155
15464	7	4	155
15465	7	5	155
15466	7	6	155
15467	7	7	155
15468	7	8	155
15469	7	9	155
15470	7	10	155
15471	8	1	155
15472	8	2	155
15473	8	3	155
15474	8	4	155
15475	8	5	155
15476	8	6	155
15477	8	7	155
15478	8	8	155
15479	8	9	155
15480	8	10	155
15481	9	1	155
15482	9	2	155
15483	9	3	155
15484	9	4	155
15485	9	5	155
15486	9	6	155
15487	9	7	155
15488	9	8	155
15489	9	9	155
15490	9	10	155
15491	10	1	155
15492	10	2	155
15493	10	3	155
15494	10	4	155
15495	10	5	155
15496	10	6	155
15497	10	7	155
15498	10	8	155
15499	10	9	155
15500	10	10	155
15501	1	1	156
15502	1	2	156
15503	1	3	156
15504	1	4	156
15505	1	5	156
15506	1	6	156
15507	1	7	156
15508	1	8	156
15509	1	9	156
15510	1	10	156
15511	2	1	156
15512	2	2	156
15513	2	3	156
15514	2	4	156
15515	2	5	156
15516	2	6	156
15517	2	7	156
15518	2	8	156
15519	2	9	156
15520	2	10	156
15521	3	1	156
15522	3	2	156
15523	3	3	156
15524	3	4	156
15525	3	5	156
15526	3	6	156
15527	3	7	156
15528	3	8	156
15529	3	9	156
15530	3	10	156
15531	4	1	156
15532	4	2	156
15533	4	3	156
15534	4	4	156
15535	4	5	156
15536	4	6	156
15537	4	7	156
15538	4	8	156
15539	4	9	156
15540	4	10	156
15541	5	1	156
15542	5	2	156
15543	5	3	156
15544	5	4	156
15545	5	5	156
15546	5	6	156
15547	5	7	156
15548	5	8	156
15549	5	9	156
15550	5	10	156
15551	6	1	156
15552	6	2	156
15553	6	3	156
15554	6	4	156
15555	6	5	156
15556	6	6	156
15557	6	7	156
15558	6	8	156
15559	6	9	156
15560	6	10	156
15561	7	1	156
15562	7	2	156
15563	7	3	156
15564	7	4	156
15565	7	5	156
15566	7	6	156
15567	7	7	156
15568	7	8	156
15569	7	9	156
15570	7	10	156
15571	8	1	156
15572	8	2	156
15573	8	3	156
15574	8	4	156
15575	8	5	156
15576	8	6	156
15577	8	7	156
15578	8	8	156
15579	8	9	156
15580	8	10	156
15581	9	1	156
15582	9	2	156
15583	9	3	156
15584	9	4	156
15585	9	5	156
15586	9	6	156
15587	9	7	156
15588	9	8	156
15589	9	9	156
15590	9	10	156
15591	10	1	156
15592	10	2	156
15593	10	3	156
15594	10	4	156
15595	10	5	156
15596	10	6	156
15597	10	7	156
15598	10	8	156
15599	10	9	156
15600	10	10	156
15601	1	1	157
15602	1	2	157
15603	1	3	157
15604	1	4	157
15605	1	5	157
15606	1	6	157
15607	1	7	157
15608	1	8	157
15609	1	9	157
15610	1	10	157
15611	2	1	157
15612	2	2	157
15613	2	3	157
15614	2	4	157
15615	2	5	157
15616	2	6	157
15617	2	7	157
15618	2	8	157
15619	2	9	157
15620	2	10	157
15621	3	1	157
15622	3	2	157
15623	3	3	157
15624	3	4	157
15625	3	5	157
15626	3	6	157
15627	3	7	157
15628	3	8	157
15629	3	9	157
15630	3	10	157
15631	4	1	157
15632	4	2	157
15633	4	3	157
15634	4	4	157
15635	4	5	157
15636	4	6	157
15637	4	7	157
15638	4	8	157
15639	4	9	157
15640	4	10	157
15641	5	1	157
15642	5	2	157
15643	5	3	157
15644	5	4	157
15645	5	5	157
15646	5	6	157
15647	5	7	157
15648	5	8	157
15649	5	9	157
15650	5	10	157
15651	6	1	157
15652	6	2	157
15653	6	3	157
15654	6	4	157
15655	6	5	157
15656	6	6	157
15657	6	7	157
15658	6	8	157
15659	6	9	157
15660	6	10	157
15661	7	1	157
15662	7	2	157
15663	7	3	157
15664	7	4	157
15665	7	5	157
15666	7	6	157
15667	7	7	157
15668	7	8	157
15669	7	9	157
15670	7	10	157
15671	8	1	157
15672	8	2	157
15673	8	3	157
15674	8	4	157
15675	8	5	157
15676	8	6	157
15677	8	7	157
15678	8	8	157
15679	8	9	157
15680	8	10	157
15681	9	1	157
15682	9	2	157
15683	9	3	157
15684	9	4	157
15685	9	5	157
15686	9	6	157
15687	9	7	157
15688	9	8	157
15689	9	9	157
15690	9	10	157
15691	10	1	157
15692	10	2	157
15693	10	3	157
15694	10	4	157
15695	10	5	157
15696	10	6	157
15697	10	7	157
15698	10	8	157
15699	10	9	157
15700	10	10	157
15701	1	1	158
15702	1	2	158
15703	1	3	158
15704	1	4	158
15705	1	5	158
15706	1	6	158
15707	1	7	158
15708	1	8	158
15709	1	9	158
15710	1	10	158
15711	2	1	158
15712	2	2	158
15713	2	3	158
15714	2	4	158
15715	2	5	158
15716	2	6	158
15717	2	7	158
15718	2	8	158
15719	2	9	158
15720	2	10	158
15721	3	1	158
15722	3	2	158
15723	3	3	158
15724	3	4	158
15725	3	5	158
15726	3	6	158
15727	3	7	158
15728	3	8	158
15729	3	9	158
15730	3	10	158
15731	4	1	158
15732	4	2	158
15733	4	3	158
15734	4	4	158
15735	4	5	158
15736	4	6	158
15737	4	7	158
15738	4	8	158
15739	4	9	158
15740	4	10	158
15741	5	1	158
15742	5	2	158
15743	5	3	158
15744	5	4	158
15745	5	5	158
15746	5	6	158
15747	5	7	158
15748	5	8	158
15749	5	9	158
15750	5	10	158
15751	6	1	158
15752	6	2	158
15753	6	3	158
15754	6	4	158
15755	6	5	158
15756	6	6	158
15757	6	7	158
15758	6	8	158
15759	6	9	158
15760	6	10	158
15761	7	1	158
15762	7	2	158
15763	7	3	158
15764	7	4	158
15765	7	5	158
15766	7	6	158
15767	7	7	158
15768	7	8	158
15769	7	9	158
15770	7	10	158
15771	8	1	158
15772	8	2	158
15773	8	3	158
15774	8	4	158
15775	8	5	158
15776	8	6	158
15777	8	7	158
15778	8	8	158
15779	8	9	158
15780	8	10	158
15781	9	1	158
15782	9	2	158
15783	9	3	158
15784	9	4	158
15785	9	5	158
15786	9	6	158
15787	9	7	158
15788	9	8	158
15789	9	9	158
15790	9	10	158
15791	10	1	158
15792	10	2	158
15793	10	3	158
15794	10	4	158
15795	10	5	158
15796	10	6	158
15797	10	7	158
15798	10	8	158
15799	10	9	158
15800	10	10	158
15801	1	1	159
15802	1	2	159
15803	1	3	159
15804	1	4	159
15805	1	5	159
15806	1	6	159
15807	1	7	159
15808	1	8	159
15809	1	9	159
15810	1	10	159
15811	2	1	159
15812	2	2	159
15813	2	3	159
15814	2	4	159
15815	2	5	159
15816	2	6	159
15817	2	7	159
15818	2	8	159
15819	2	9	159
15820	2	10	159
15821	3	1	159
15822	3	2	159
15823	3	3	159
15824	3	4	159
15825	3	5	159
15826	3	6	159
15827	3	7	159
15828	3	8	159
15829	3	9	159
15830	3	10	159
15831	4	1	159
15832	4	2	159
15833	4	3	159
15834	4	4	159
15835	4	5	159
15836	4	6	159
15837	4	7	159
15838	4	8	159
15839	4	9	159
15840	4	10	159
15841	5	1	159
15842	5	2	159
15843	5	3	159
15844	5	4	159
15845	5	5	159
15846	5	6	159
15847	5	7	159
15848	5	8	159
15849	5	9	159
15850	5	10	159
15851	6	1	159
15852	6	2	159
15853	6	3	159
15854	6	4	159
15855	6	5	159
15856	6	6	159
15857	6	7	159
15858	6	8	159
15859	6	9	159
15860	6	10	159
15861	7	1	159
15862	7	2	159
15863	7	3	159
15864	7	4	159
15865	7	5	159
15866	7	6	159
15867	7	7	159
15868	7	8	159
15869	7	9	159
15870	7	10	159
15871	8	1	159
15872	8	2	159
15873	8	3	159
15874	8	4	159
15875	8	5	159
15876	8	6	159
15877	8	7	159
15878	8	8	159
15879	8	9	159
15880	8	10	159
15881	9	1	159
15882	9	2	159
15883	9	3	159
15884	9	4	159
15885	9	5	159
15886	9	6	159
15887	9	7	159
15888	9	8	159
15889	9	9	159
15890	9	10	159
15891	10	1	159
15892	10	2	159
15893	10	3	159
15894	10	4	159
15895	10	5	159
15896	10	6	159
15897	10	7	159
15898	10	8	159
15899	10	9	159
15900	10	10	159
15901	1	1	160
15902	1	2	160
15903	1	3	160
15904	1	4	160
15905	1	5	160
15906	1	6	160
15907	1	7	160
15908	1	8	160
15909	1	9	160
15910	1	10	160
15911	2	1	160
15912	2	2	160
15913	2	3	160
15914	2	4	160
15915	2	5	160
15916	2	6	160
15917	2	7	160
15918	2	8	160
15919	2	9	160
15920	2	10	160
15921	3	1	160
15922	3	2	160
15923	3	3	160
15924	3	4	160
15925	3	5	160
15926	3	6	160
15927	3	7	160
15928	3	8	160
15929	3	9	160
15930	3	10	160
15931	4	1	160
15932	4	2	160
15933	4	3	160
15934	4	4	160
15935	4	5	160
15936	4	6	160
15937	4	7	160
15938	4	8	160
15939	4	9	160
15940	4	10	160
15941	5	1	160
15942	5	2	160
15943	5	3	160
15944	5	4	160
15945	5	5	160
15946	5	6	160
15947	5	7	160
15948	5	8	160
15949	5	9	160
15950	5	10	160
15951	6	1	160
15952	6	2	160
15953	6	3	160
15954	6	4	160
15955	6	5	160
15956	6	6	160
15957	6	7	160
15958	6	8	160
15959	6	9	160
15960	6	10	160
15961	7	1	160
15962	7	2	160
15963	7	3	160
15964	7	4	160
15965	7	5	160
15966	7	6	160
15967	7	7	160
15968	7	8	160
15969	7	9	160
15970	7	10	160
15971	8	1	160
15972	8	2	160
15973	8	3	160
15974	8	4	160
15975	8	5	160
15976	8	6	160
15977	8	7	160
15978	8	8	160
15979	8	9	160
15980	8	10	160
15981	9	1	160
15982	9	2	160
15983	9	3	160
15984	9	4	160
15985	9	5	160
15986	9	6	160
15987	9	7	160
15988	9	8	160
15989	9	9	160
15990	9	10	160
15991	10	1	160
15992	10	2	160
15993	10	3	160
15994	10	4	160
15995	10	5	160
15996	10	6	160
15997	10	7	160
15998	10	8	160
15999	10	9	160
16000	10	10	160
16001	1	1	161
16002	1	2	161
16003	1	3	161
16004	1	4	161
16005	1	5	161
16006	1	6	161
16007	1	7	161
16008	1	8	161
16009	1	9	161
16010	1	10	161
16011	2	1	161
16012	2	2	161
16013	2	3	161
16014	2	4	161
16015	2	5	161
16016	2	6	161
16017	2	7	161
16018	2	8	161
16019	2	9	161
16020	2	10	161
16021	3	1	161
16022	3	2	161
16023	3	3	161
16024	3	4	161
16025	3	5	161
16026	3	6	161
16027	3	7	161
16028	3	8	161
16029	3	9	161
16030	3	10	161
16031	4	1	161
16032	4	2	161
16033	4	3	161
16034	4	4	161
16035	4	5	161
16036	4	6	161
16037	4	7	161
16038	4	8	161
16039	4	9	161
16040	4	10	161
16041	5	1	161
16042	5	2	161
16043	5	3	161
16044	5	4	161
16045	5	5	161
16046	5	6	161
16047	5	7	161
16048	5	8	161
16049	5	9	161
16050	5	10	161
16051	6	1	161
16052	6	2	161
16053	6	3	161
16054	6	4	161
16055	6	5	161
16056	6	6	161
16057	6	7	161
16058	6	8	161
16059	6	9	161
16060	6	10	161
16061	7	1	161
16062	7	2	161
16063	7	3	161
16064	7	4	161
16065	7	5	161
16066	7	6	161
16067	7	7	161
16068	7	8	161
16069	7	9	161
16070	7	10	161
16071	8	1	161
16072	8	2	161
16073	8	3	161
16074	8	4	161
16075	8	5	161
16076	8	6	161
16077	8	7	161
16078	8	8	161
16079	8	9	161
16080	8	10	161
16081	9	1	161
16082	9	2	161
16083	9	3	161
16084	9	4	161
16085	9	5	161
16086	9	6	161
16087	9	7	161
16088	9	8	161
16089	9	9	161
16090	9	10	161
16091	10	1	161
16092	10	2	161
16093	10	3	161
16094	10	4	161
16095	10	5	161
16096	10	6	161
16097	10	7	161
16098	10	8	161
16099	10	9	161
16100	10	10	161
16101	1	1	162
16102	1	2	162
16103	1	3	162
16104	1	4	162
16105	1	5	162
16106	1	6	162
16107	1	7	162
16108	1	8	162
16109	1	9	162
16110	1	10	162
16111	2	1	162
16112	2	2	162
16113	2	3	162
16114	2	4	162
16115	2	5	162
16116	2	6	162
16117	2	7	162
16118	2	8	162
16119	2	9	162
16120	2	10	162
16121	3	1	162
16122	3	2	162
16123	3	3	162
16124	3	4	162
16125	3	5	162
16126	3	6	162
16127	3	7	162
16128	3	8	162
16129	3	9	162
16130	3	10	162
16131	4	1	162
16132	4	2	162
16133	4	3	162
16134	4	4	162
16135	4	5	162
16136	4	6	162
16137	4	7	162
16138	4	8	162
16139	4	9	162
16140	4	10	162
16141	5	1	162
16142	5	2	162
16143	5	3	162
16144	5	4	162
16145	5	5	162
16146	5	6	162
16147	5	7	162
16148	5	8	162
16149	5	9	162
16150	5	10	162
16151	6	1	162
16152	6	2	162
16153	6	3	162
16154	6	4	162
16155	6	5	162
16156	6	6	162
16157	6	7	162
16158	6	8	162
16159	6	9	162
16160	6	10	162
16161	7	1	162
16162	7	2	162
16163	7	3	162
16164	7	4	162
16165	7	5	162
16166	7	6	162
16167	7	7	162
16168	7	8	162
16169	7	9	162
16170	7	10	162
16171	8	1	162
16172	8	2	162
16173	8	3	162
16174	8	4	162
16175	8	5	162
16176	8	6	162
16177	8	7	162
16178	8	8	162
16179	8	9	162
16180	8	10	162
16181	9	1	162
16182	9	2	162
16183	9	3	162
16184	9	4	162
16185	9	5	162
16186	9	6	162
16187	9	7	162
16188	9	8	162
16189	9	9	162
16190	9	10	162
16191	10	1	162
16192	10	2	162
16193	10	3	162
16194	10	4	162
16195	10	5	162
16196	10	6	162
16197	10	7	162
16198	10	8	162
16199	10	9	162
16200	10	10	162
16201	1	1	163
16202	1	2	163
16203	1	3	163
16204	1	4	163
16205	1	5	163
16206	1	6	163
16207	1	7	163
16208	1	8	163
16209	1	9	163
16210	1	10	163
16211	2	1	163
16212	2	2	163
16213	2	3	163
16214	2	4	163
16215	2	5	163
16216	2	6	163
16217	2	7	163
16218	2	8	163
16219	2	9	163
16220	2	10	163
16221	3	1	163
16222	3	2	163
16223	3	3	163
16224	3	4	163
16225	3	5	163
16226	3	6	163
16227	3	7	163
16228	3	8	163
16229	3	9	163
16230	3	10	163
16231	4	1	163
16232	4	2	163
16233	4	3	163
16234	4	4	163
16235	4	5	163
16236	4	6	163
16237	4	7	163
16238	4	8	163
16239	4	9	163
16240	4	10	163
16241	5	1	163
16242	5	2	163
16243	5	3	163
16244	5	4	163
16245	5	5	163
16246	5	6	163
16247	5	7	163
16248	5	8	163
16249	5	9	163
16250	5	10	163
16251	6	1	163
16252	6	2	163
16253	6	3	163
16254	6	4	163
16255	6	5	163
16256	6	6	163
16257	6	7	163
16258	6	8	163
16259	6	9	163
16260	6	10	163
16261	7	1	163
16262	7	2	163
16263	7	3	163
16264	7	4	163
16265	7	5	163
16266	7	6	163
16267	7	7	163
16268	7	8	163
16269	7	9	163
16270	7	10	163
16271	8	1	163
16272	8	2	163
16273	8	3	163
16274	8	4	163
16275	8	5	163
16276	8	6	163
16277	8	7	163
16278	8	8	163
16279	8	9	163
16280	8	10	163
16281	9	1	163
16282	9	2	163
16283	9	3	163
16284	9	4	163
16285	9	5	163
16286	9	6	163
16287	9	7	163
16288	9	8	163
16289	9	9	163
16290	9	10	163
16291	10	1	163
16292	10	2	163
16293	10	3	163
16294	10	4	163
16295	10	5	163
16296	10	6	163
16297	10	7	163
16298	10	8	163
16299	10	9	163
16300	10	10	163
16301	1	1	164
16302	1	2	164
16303	1	3	164
16304	1	4	164
16305	1	5	164
16306	1	6	164
16307	1	7	164
16308	1	8	164
16309	1	9	164
16310	1	10	164
16311	2	1	164
16312	2	2	164
16313	2	3	164
16314	2	4	164
16315	2	5	164
16316	2	6	164
16317	2	7	164
16318	2	8	164
16319	2	9	164
16320	2	10	164
16321	3	1	164
16322	3	2	164
16323	3	3	164
16324	3	4	164
16325	3	5	164
16326	3	6	164
16327	3	7	164
16328	3	8	164
16329	3	9	164
16330	3	10	164
16331	4	1	164
16332	4	2	164
16333	4	3	164
16334	4	4	164
16335	4	5	164
16336	4	6	164
16337	4	7	164
16338	4	8	164
16339	4	9	164
16340	4	10	164
16341	5	1	164
16342	5	2	164
16343	5	3	164
16344	5	4	164
16345	5	5	164
16346	5	6	164
16347	5	7	164
16348	5	8	164
16349	5	9	164
16350	5	10	164
16351	6	1	164
16352	6	2	164
16353	6	3	164
16354	6	4	164
16355	6	5	164
16356	6	6	164
16357	6	7	164
16358	6	8	164
16359	6	9	164
16360	6	10	164
16361	7	1	164
16362	7	2	164
16363	7	3	164
16364	7	4	164
16365	7	5	164
16366	7	6	164
16367	7	7	164
16368	7	8	164
16369	7	9	164
16370	7	10	164
16371	8	1	164
16372	8	2	164
16373	8	3	164
16374	8	4	164
16375	8	5	164
16376	8	6	164
16377	8	7	164
16378	8	8	164
16379	8	9	164
16380	8	10	164
16381	9	1	164
16382	9	2	164
16383	9	3	164
16384	9	4	164
16385	9	5	164
16386	9	6	164
16387	9	7	164
16388	9	8	164
16389	9	9	164
16390	9	10	164
16391	10	1	164
16392	10	2	164
16393	10	3	164
16394	10	4	164
16395	10	5	164
16396	10	6	164
16397	10	7	164
16398	10	8	164
16399	10	9	164
16400	10	10	164
16401	1	1	165
16402	1	2	165
16403	1	3	165
16404	1	4	165
16405	1	5	165
16406	1	6	165
16407	1	7	165
16408	1	8	165
16409	1	9	165
16410	1	10	165
16411	2	1	165
16412	2	2	165
16413	2	3	165
16414	2	4	165
16415	2	5	165
16416	2	6	165
16417	2	7	165
16418	2	8	165
16419	2	9	165
16420	2	10	165
16421	3	1	165
16422	3	2	165
16423	3	3	165
16424	3	4	165
16425	3	5	165
16426	3	6	165
16427	3	7	165
16428	3	8	165
16429	3	9	165
16430	3	10	165
16431	4	1	165
16432	4	2	165
16433	4	3	165
16434	4	4	165
16435	4	5	165
16436	4	6	165
16437	4	7	165
16438	4	8	165
16439	4	9	165
16440	4	10	165
16441	5	1	165
16442	5	2	165
16443	5	3	165
16444	5	4	165
16445	5	5	165
16446	5	6	165
16447	5	7	165
16448	5	8	165
16449	5	9	165
16450	5	10	165
16451	6	1	165
16452	6	2	165
16453	6	3	165
16454	6	4	165
16455	6	5	165
16456	6	6	165
16457	6	7	165
16458	6	8	165
16459	6	9	165
16460	6	10	165
16461	7	1	165
16462	7	2	165
16463	7	3	165
16464	7	4	165
16465	7	5	165
16466	7	6	165
16467	7	7	165
16468	7	8	165
16469	7	9	165
16470	7	10	165
16471	8	1	165
16472	8	2	165
16473	8	3	165
16474	8	4	165
16475	8	5	165
16476	8	6	165
16477	8	7	165
16478	8	8	165
16479	8	9	165
16480	8	10	165
16481	9	1	165
16482	9	2	165
16483	9	3	165
16484	9	4	165
16485	9	5	165
16486	9	6	165
16487	9	7	165
16488	9	8	165
16489	9	9	165
16490	9	10	165
16491	10	1	165
16492	10	2	165
16493	10	3	165
16494	10	4	165
16495	10	5	165
16496	10	6	165
16497	10	7	165
16498	10	8	165
16499	10	9	165
16500	10	10	165
16501	1	1	166
16502	1	2	166
16503	1	3	166
16504	1	4	166
16505	1	5	166
16506	1	6	166
16507	1	7	166
16508	1	8	166
16509	1	9	166
16510	1	10	166
16511	2	1	166
16512	2	2	166
16513	2	3	166
16514	2	4	166
16515	2	5	166
16516	2	6	166
16517	2	7	166
16518	2	8	166
16519	2	9	166
16520	2	10	166
16521	3	1	166
16522	3	2	166
16523	3	3	166
16524	3	4	166
16525	3	5	166
16526	3	6	166
16527	3	7	166
16528	3	8	166
16529	3	9	166
16530	3	10	166
16531	4	1	166
16532	4	2	166
16533	4	3	166
16534	4	4	166
16535	4	5	166
16536	4	6	166
16537	4	7	166
16538	4	8	166
16539	4	9	166
16540	4	10	166
16541	5	1	166
16542	5	2	166
16543	5	3	166
16544	5	4	166
16545	5	5	166
16546	5	6	166
16547	5	7	166
16548	5	8	166
16549	5	9	166
16550	5	10	166
16551	6	1	166
16552	6	2	166
16553	6	3	166
16554	6	4	166
16555	6	5	166
16556	6	6	166
16557	6	7	166
16558	6	8	166
16559	6	9	166
16560	6	10	166
16561	7	1	166
16562	7	2	166
16563	7	3	166
16564	7	4	166
16565	7	5	166
16566	7	6	166
16567	7	7	166
16568	7	8	166
16569	7	9	166
16570	7	10	166
16571	8	1	166
16572	8	2	166
16573	8	3	166
16574	8	4	166
16575	8	5	166
16576	8	6	166
16577	8	7	166
16578	8	8	166
16579	8	9	166
16580	8	10	166
16581	9	1	166
16582	9	2	166
16583	9	3	166
16584	9	4	166
16585	9	5	166
16586	9	6	166
16587	9	7	166
16588	9	8	166
16589	9	9	166
16590	9	10	166
16591	10	1	166
16592	10	2	166
16593	10	3	166
16594	10	4	166
16595	10	5	166
16596	10	6	166
16597	10	7	166
16598	10	8	166
16599	10	9	166
16600	10	10	166
16601	1	1	167
16602	1	2	167
16603	1	3	167
16604	1	4	167
16605	1	5	167
16606	1	6	167
16607	1	7	167
16608	1	8	167
16609	1	9	167
16610	1	10	167
16611	2	1	167
16612	2	2	167
16613	2	3	167
16614	2	4	167
16615	2	5	167
16616	2	6	167
16617	2	7	167
16618	2	8	167
16619	2	9	167
16620	2	10	167
16621	3	1	167
16622	3	2	167
16623	3	3	167
16624	3	4	167
16625	3	5	167
16626	3	6	167
16627	3	7	167
16628	3	8	167
16629	3	9	167
16630	3	10	167
16631	4	1	167
16632	4	2	167
16633	4	3	167
16634	4	4	167
16635	4	5	167
16636	4	6	167
16637	4	7	167
16638	4	8	167
16639	4	9	167
16640	4	10	167
16641	5	1	167
16642	5	2	167
16643	5	3	167
16644	5	4	167
16645	5	5	167
16646	5	6	167
16647	5	7	167
16648	5	8	167
16649	5	9	167
16650	5	10	167
16651	6	1	167
16652	6	2	167
16653	6	3	167
16654	6	4	167
16655	6	5	167
16656	6	6	167
16657	6	7	167
16658	6	8	167
16659	6	9	167
16660	6	10	167
16661	7	1	167
16662	7	2	167
16663	7	3	167
16664	7	4	167
16665	7	5	167
16666	7	6	167
16667	7	7	167
16668	7	8	167
16669	7	9	167
16670	7	10	167
16671	8	1	167
16672	8	2	167
16673	8	3	167
16674	8	4	167
16675	8	5	167
16676	8	6	167
16677	8	7	167
16678	8	8	167
16679	8	9	167
16680	8	10	167
16681	9	1	167
16682	9	2	167
16683	9	3	167
16684	9	4	167
16685	9	5	167
16686	9	6	167
16687	9	7	167
16688	9	8	167
16689	9	9	167
16690	9	10	167
16691	10	1	167
16692	10	2	167
16693	10	3	167
16694	10	4	167
16695	10	5	167
16696	10	6	167
16697	10	7	167
16698	10	8	167
16699	10	9	167
16700	10	10	167
16701	1	1	168
16702	1	2	168
16703	1	3	168
16704	1	4	168
16705	1	5	168
16706	1	6	168
16707	1	7	168
16708	1	8	168
16709	1	9	168
16710	1	10	168
16711	2	1	168
16712	2	2	168
16713	2	3	168
16714	2	4	168
16715	2	5	168
16716	2	6	168
16717	2	7	168
16718	2	8	168
16719	2	9	168
16720	2	10	168
16721	3	1	168
16722	3	2	168
16723	3	3	168
16724	3	4	168
16725	3	5	168
16726	3	6	168
16727	3	7	168
16728	3	8	168
16729	3	9	168
16730	3	10	168
16731	4	1	168
16732	4	2	168
16733	4	3	168
16734	4	4	168
16735	4	5	168
16736	4	6	168
16737	4	7	168
16738	4	8	168
16739	4	9	168
16740	4	10	168
16741	5	1	168
16742	5	2	168
16743	5	3	168
16744	5	4	168
16745	5	5	168
16746	5	6	168
16747	5	7	168
16748	5	8	168
16749	5	9	168
16750	5	10	168
16751	6	1	168
16752	6	2	168
16753	6	3	168
16754	6	4	168
16755	6	5	168
16756	6	6	168
16757	6	7	168
16758	6	8	168
16759	6	9	168
16760	6	10	168
16761	7	1	168
16762	7	2	168
16763	7	3	168
16764	7	4	168
16765	7	5	168
16766	7	6	168
16767	7	7	168
16768	7	8	168
16769	7	9	168
16770	7	10	168
16771	8	1	168
16772	8	2	168
16773	8	3	168
16774	8	4	168
16775	8	5	168
16776	8	6	168
16777	8	7	168
16778	8	8	168
16779	8	9	168
16780	8	10	168
16781	9	1	168
16782	9	2	168
16783	9	3	168
16784	9	4	168
16785	9	5	168
16786	9	6	168
16787	9	7	168
16788	9	8	168
16789	9	9	168
16790	9	10	168
16791	10	1	168
16792	10	2	168
16793	10	3	168
16794	10	4	168
16795	10	5	168
16796	10	6	168
16797	10	7	168
16798	10	8	168
16799	10	9	168
16800	10	10	168
16801	1	1	169
16802	1	2	169
16803	1	3	169
16804	1	4	169
16805	1	5	169
16806	1	6	169
16807	1	7	169
16808	1	8	169
16809	1	9	169
16810	1	10	169
16811	2	1	169
16812	2	2	169
16813	2	3	169
16814	2	4	169
16815	2	5	169
16816	2	6	169
16817	2	7	169
16818	2	8	169
16819	2	9	169
16820	2	10	169
16821	3	1	169
16822	3	2	169
16823	3	3	169
16824	3	4	169
16825	3	5	169
16826	3	6	169
16827	3	7	169
16828	3	8	169
16829	3	9	169
16830	3	10	169
16831	4	1	169
16832	4	2	169
16833	4	3	169
16834	4	4	169
16835	4	5	169
16836	4	6	169
16837	4	7	169
16838	4	8	169
16839	4	9	169
16840	4	10	169
16841	5	1	169
16842	5	2	169
16843	5	3	169
16844	5	4	169
16845	5	5	169
16846	5	6	169
16847	5	7	169
16848	5	8	169
16849	5	9	169
16850	5	10	169
16851	6	1	169
16852	6	2	169
16853	6	3	169
16854	6	4	169
16855	6	5	169
16856	6	6	169
16857	6	7	169
16858	6	8	169
16859	6	9	169
16860	6	10	169
16861	7	1	169
16862	7	2	169
16863	7	3	169
16864	7	4	169
16865	7	5	169
16866	7	6	169
16867	7	7	169
16868	7	8	169
16869	7	9	169
16870	7	10	169
16871	8	1	169
16872	8	2	169
16873	8	3	169
16874	8	4	169
16875	8	5	169
16876	8	6	169
16877	8	7	169
16878	8	8	169
16879	8	9	169
16880	8	10	169
16881	9	1	169
16882	9	2	169
16883	9	3	169
16884	9	4	169
16885	9	5	169
16886	9	6	169
16887	9	7	169
16888	9	8	169
16889	9	9	169
16890	9	10	169
16891	10	1	169
16892	10	2	169
16893	10	3	169
16894	10	4	169
16895	10	5	169
16896	10	6	169
16897	10	7	169
16898	10	8	169
16899	10	9	169
16900	10	10	169
16901	1	1	170
16902	1	2	170
16903	1	3	170
16904	1	4	170
16905	1	5	170
16906	1	6	170
16907	1	7	170
16908	1	8	170
16909	1	9	170
16910	1	10	170
16911	2	1	170
16912	2	2	170
16913	2	3	170
16914	2	4	170
16915	2	5	170
16916	2	6	170
16917	2	7	170
16918	2	8	170
16919	2	9	170
16920	2	10	170
16921	3	1	170
16922	3	2	170
16923	3	3	170
16924	3	4	170
16925	3	5	170
16926	3	6	170
16927	3	7	170
16928	3	8	170
16929	3	9	170
16930	3	10	170
16931	4	1	170
16932	4	2	170
16933	4	3	170
16934	4	4	170
16935	4	5	170
16936	4	6	170
16937	4	7	170
16938	4	8	170
16939	4	9	170
16940	4	10	170
16941	5	1	170
16942	5	2	170
16943	5	3	170
16944	5	4	170
16945	5	5	170
16946	5	6	170
16947	5	7	170
16948	5	8	170
16949	5	9	170
16950	5	10	170
16951	6	1	170
16952	6	2	170
16953	6	3	170
16954	6	4	170
16955	6	5	170
16956	6	6	170
16957	6	7	170
16958	6	8	170
16959	6	9	170
16960	6	10	170
16961	7	1	170
16962	7	2	170
16963	7	3	170
16964	7	4	170
16965	7	5	170
16966	7	6	170
16967	7	7	170
16968	7	8	170
16969	7	9	170
16970	7	10	170
16971	8	1	170
16972	8	2	170
16973	8	3	170
16974	8	4	170
16975	8	5	170
16976	8	6	170
16977	8	7	170
16978	8	8	170
16979	8	9	170
16980	8	10	170
16981	9	1	170
16982	9	2	170
16983	9	3	170
16984	9	4	170
16985	9	5	170
16986	9	6	170
16987	9	7	170
16988	9	8	170
16989	9	9	170
16990	9	10	170
16991	10	1	170
16992	10	2	170
16993	10	3	170
16994	10	4	170
16995	10	5	170
16996	10	6	170
16997	10	7	170
16998	10	8	170
16999	10	9	170
17000	10	10	170
17001	1	1	171
17002	1	2	171
17003	1	3	171
17004	1	4	171
17005	1	5	171
17006	1	6	171
17007	1	7	171
17008	1	8	171
17009	1	9	171
17010	1	10	171
17011	2	1	171
17012	2	2	171
17013	2	3	171
17014	2	4	171
17015	2	5	171
17016	2	6	171
17017	2	7	171
17018	2	8	171
17019	2	9	171
17020	2	10	171
17021	3	1	171
17022	3	2	171
17023	3	3	171
17024	3	4	171
17025	3	5	171
17026	3	6	171
17027	3	7	171
17028	3	8	171
17029	3	9	171
17030	3	10	171
17031	4	1	171
17032	4	2	171
17033	4	3	171
17034	4	4	171
17035	4	5	171
17036	4	6	171
17037	4	7	171
17038	4	8	171
17039	4	9	171
17040	4	10	171
17041	5	1	171
17042	5	2	171
17043	5	3	171
17044	5	4	171
17045	5	5	171
17046	5	6	171
17047	5	7	171
17048	5	8	171
17049	5	9	171
17050	5	10	171
17051	6	1	171
17052	6	2	171
17053	6	3	171
17054	6	4	171
17055	6	5	171
17056	6	6	171
17057	6	7	171
17058	6	8	171
17059	6	9	171
17060	6	10	171
17061	7	1	171
17062	7	2	171
17063	7	3	171
17064	7	4	171
17065	7	5	171
17066	7	6	171
17067	7	7	171
17068	7	8	171
17069	7	9	171
17070	7	10	171
17071	8	1	171
17072	8	2	171
17073	8	3	171
17074	8	4	171
17075	8	5	171
17076	8	6	171
17077	8	7	171
17078	8	8	171
17079	8	9	171
17080	8	10	171
17081	9	1	171
17082	9	2	171
17083	9	3	171
17084	9	4	171
17085	9	5	171
17086	9	6	171
17087	9	7	171
17088	9	8	171
17089	9	9	171
17090	9	10	171
17091	10	1	171
17092	10	2	171
17093	10	3	171
17094	10	4	171
17095	10	5	171
17096	10	6	171
17097	10	7	171
17098	10	8	171
17099	10	9	171
17100	10	10	171
17101	1	1	172
17102	1	2	172
17103	1	3	172
17104	1	4	172
17105	1	5	172
17106	1	6	172
17107	1	7	172
17108	1	8	172
17109	1	9	172
17110	1	10	172
17111	2	1	172
17112	2	2	172
17113	2	3	172
17114	2	4	172
17115	2	5	172
17116	2	6	172
17117	2	7	172
17118	2	8	172
17119	2	9	172
17120	2	10	172
17121	3	1	172
17122	3	2	172
17123	3	3	172
17124	3	4	172
17125	3	5	172
17126	3	6	172
17127	3	7	172
17128	3	8	172
17129	3	9	172
17130	3	10	172
17131	4	1	172
17132	4	2	172
17133	4	3	172
17134	4	4	172
17135	4	5	172
17136	4	6	172
17137	4	7	172
17138	4	8	172
17139	4	9	172
17140	4	10	172
17141	5	1	172
17142	5	2	172
17143	5	3	172
17144	5	4	172
17145	5	5	172
17146	5	6	172
17147	5	7	172
17148	5	8	172
17149	5	9	172
17150	5	10	172
17151	6	1	172
17152	6	2	172
17153	6	3	172
17154	6	4	172
17155	6	5	172
17156	6	6	172
17157	6	7	172
17158	6	8	172
17159	6	9	172
17160	6	10	172
17161	7	1	172
17162	7	2	172
17163	7	3	172
17164	7	4	172
17165	7	5	172
17166	7	6	172
17167	7	7	172
17168	7	8	172
17169	7	9	172
17170	7	10	172
17171	8	1	172
17172	8	2	172
17173	8	3	172
17174	8	4	172
17175	8	5	172
17176	8	6	172
17177	8	7	172
17178	8	8	172
17179	8	9	172
17180	8	10	172
17181	9	1	172
17182	9	2	172
17183	9	3	172
17184	9	4	172
17185	9	5	172
17186	9	6	172
17187	9	7	172
17188	9	8	172
17189	9	9	172
17190	9	10	172
17191	10	1	172
17192	10	2	172
17193	10	3	172
17194	10	4	172
17195	10	5	172
17196	10	6	172
17197	10	7	172
17198	10	8	172
17199	10	9	172
17200	10	10	172
17201	1	1	173
17202	1	2	173
17203	1	3	173
17204	1	4	173
17205	1	5	173
17206	1	6	173
17207	1	7	173
17208	1	8	173
17209	1	9	173
17210	1	10	173
17211	2	1	173
17212	2	2	173
17213	2	3	173
17214	2	4	173
17215	2	5	173
17216	2	6	173
17217	2	7	173
17218	2	8	173
17219	2	9	173
17220	2	10	173
17221	3	1	173
17222	3	2	173
17223	3	3	173
17224	3	4	173
17225	3	5	173
17226	3	6	173
17227	3	7	173
17228	3	8	173
17229	3	9	173
17230	3	10	173
17231	4	1	173
17232	4	2	173
17233	4	3	173
17234	4	4	173
17235	4	5	173
17236	4	6	173
17237	4	7	173
17238	4	8	173
17239	4	9	173
17240	4	10	173
17241	5	1	173
17242	5	2	173
17243	5	3	173
17244	5	4	173
17245	5	5	173
17246	5	6	173
17247	5	7	173
17248	5	8	173
17249	5	9	173
17250	5	10	173
17251	6	1	173
17252	6	2	173
17253	6	3	173
17254	6	4	173
17255	6	5	173
17256	6	6	173
17257	6	7	173
17258	6	8	173
17259	6	9	173
17260	6	10	173
17261	7	1	173
17262	7	2	173
17263	7	3	173
17264	7	4	173
17265	7	5	173
17266	7	6	173
17267	7	7	173
17268	7	8	173
17269	7	9	173
17270	7	10	173
17271	8	1	173
17272	8	2	173
17273	8	3	173
17274	8	4	173
17275	8	5	173
17276	8	6	173
17277	8	7	173
17278	8	8	173
17279	8	9	173
17280	8	10	173
17281	9	1	173
17282	9	2	173
17283	9	3	173
17284	9	4	173
17285	9	5	173
17286	9	6	173
17287	9	7	173
17288	9	8	173
17289	9	9	173
17290	9	10	173
17291	10	1	173
17292	10	2	173
17293	10	3	173
17294	10	4	173
17295	10	5	173
17296	10	6	173
17297	10	7	173
17298	10	8	173
17299	10	9	173
17300	10	10	173
17301	1	1	174
17302	1	2	174
17303	1	3	174
17304	1	4	174
17305	1	5	174
17306	1	6	174
17307	1	7	174
17308	1	8	174
17309	1	9	174
17310	1	10	174
17311	2	1	174
17312	2	2	174
17313	2	3	174
17314	2	4	174
17315	2	5	174
17316	2	6	174
17317	2	7	174
17318	2	8	174
17319	2	9	174
17320	2	10	174
17321	3	1	174
17322	3	2	174
17323	3	3	174
17324	3	4	174
17325	3	5	174
17326	3	6	174
17327	3	7	174
17328	3	8	174
17329	3	9	174
17330	3	10	174
17331	4	1	174
17332	4	2	174
17333	4	3	174
17334	4	4	174
17335	4	5	174
17336	4	6	174
17337	4	7	174
17338	4	8	174
17339	4	9	174
17340	4	10	174
17341	5	1	174
17342	5	2	174
17343	5	3	174
17344	5	4	174
17345	5	5	174
17346	5	6	174
17347	5	7	174
17348	5	8	174
17349	5	9	174
17350	5	10	174
17351	6	1	174
17352	6	2	174
17353	6	3	174
17354	6	4	174
17355	6	5	174
17356	6	6	174
17357	6	7	174
17358	6	8	174
17359	6	9	174
17360	6	10	174
17361	7	1	174
17362	7	2	174
17363	7	3	174
17364	7	4	174
17365	7	5	174
17366	7	6	174
17367	7	7	174
17368	7	8	174
17369	7	9	174
17370	7	10	174
17371	8	1	174
17372	8	2	174
17373	8	3	174
17374	8	4	174
17375	8	5	174
17376	8	6	174
17377	8	7	174
17378	8	8	174
17379	8	9	174
17380	8	10	174
17381	9	1	174
17382	9	2	174
17383	9	3	174
17384	9	4	174
17385	9	5	174
17386	9	6	174
17387	9	7	174
17388	9	8	174
17389	9	9	174
17390	9	10	174
17391	10	1	174
17392	10	2	174
17393	10	3	174
17394	10	4	174
17395	10	5	174
17396	10	6	174
17397	10	7	174
17398	10	8	174
17399	10	9	174
17400	10	10	174
17401	1	1	175
17402	1	2	175
17403	1	3	175
17404	1	4	175
17405	1	5	175
17406	1	6	175
17407	1	7	175
17408	1	8	175
17409	1	9	175
17410	1	10	175
17411	2	1	175
17412	2	2	175
17413	2	3	175
17414	2	4	175
17415	2	5	175
17416	2	6	175
17417	2	7	175
17418	2	8	175
17419	2	9	175
17420	2	10	175
17421	3	1	175
17422	3	2	175
17423	3	3	175
17424	3	4	175
17425	3	5	175
17426	3	6	175
17427	3	7	175
17428	3	8	175
17429	3	9	175
17430	3	10	175
17431	4	1	175
17432	4	2	175
17433	4	3	175
17434	4	4	175
17435	4	5	175
17436	4	6	175
17437	4	7	175
17438	4	8	175
17439	4	9	175
17440	4	10	175
17441	5	1	175
17442	5	2	175
17443	5	3	175
17444	5	4	175
17445	5	5	175
17446	5	6	175
17447	5	7	175
17448	5	8	175
17449	5	9	175
17450	5	10	175
17451	6	1	175
17452	6	2	175
17453	6	3	175
17454	6	4	175
17455	6	5	175
17456	6	6	175
17457	6	7	175
17458	6	8	175
17459	6	9	175
17460	6	10	175
17461	7	1	175
17462	7	2	175
17463	7	3	175
17464	7	4	175
17465	7	5	175
17466	7	6	175
17467	7	7	175
17468	7	8	175
17469	7	9	175
17470	7	10	175
17471	8	1	175
17472	8	2	175
17473	8	3	175
17474	8	4	175
17475	8	5	175
17476	8	6	175
17477	8	7	175
17478	8	8	175
17479	8	9	175
17480	8	10	175
17481	9	1	175
17482	9	2	175
17483	9	3	175
17484	9	4	175
17485	9	5	175
17486	9	6	175
17487	9	7	175
17488	9	8	175
17489	9	9	175
17490	9	10	175
17491	10	1	175
17492	10	2	175
17493	10	3	175
17494	10	4	175
17495	10	5	175
17496	10	6	175
17497	10	7	175
17498	10	8	175
17499	10	9	175
17500	10	10	175
17501	1	1	176
17502	1	2	176
17503	1	3	176
17504	1	4	176
17505	1	5	176
17506	1	6	176
17507	1	7	176
17508	1	8	176
17509	1	9	176
17510	1	10	176
17511	2	1	176
17512	2	2	176
17513	2	3	176
17514	2	4	176
17515	2	5	176
17516	2	6	176
17517	2	7	176
17518	2	8	176
17519	2	9	176
17520	2	10	176
17521	3	1	176
17522	3	2	176
17523	3	3	176
17524	3	4	176
17525	3	5	176
17526	3	6	176
17527	3	7	176
17528	3	8	176
17529	3	9	176
17530	3	10	176
17531	4	1	176
17532	4	2	176
17533	4	3	176
17534	4	4	176
17535	4	5	176
17536	4	6	176
17537	4	7	176
17538	4	8	176
17539	4	9	176
17540	4	10	176
17541	5	1	176
17542	5	2	176
17543	5	3	176
17544	5	4	176
17545	5	5	176
17546	5	6	176
17547	5	7	176
17548	5	8	176
17549	5	9	176
17550	5	10	176
17551	6	1	176
17552	6	2	176
17553	6	3	176
17554	6	4	176
17555	6	5	176
17556	6	6	176
17557	6	7	176
17558	6	8	176
17559	6	9	176
17560	6	10	176
17561	7	1	176
17562	7	2	176
17563	7	3	176
17564	7	4	176
17565	7	5	176
17566	7	6	176
17567	7	7	176
17568	7	8	176
17569	7	9	176
17570	7	10	176
17571	8	1	176
17572	8	2	176
17573	8	3	176
17574	8	4	176
17575	8	5	176
17576	8	6	176
17577	8	7	176
17578	8	8	176
17579	8	9	176
17580	8	10	176
17581	9	1	176
17582	9	2	176
17583	9	3	176
17584	9	4	176
17585	9	5	176
17586	9	6	176
17587	9	7	176
17588	9	8	176
17589	9	9	176
17590	9	10	176
17591	10	1	176
17592	10	2	176
17593	10	3	176
17594	10	4	176
17595	10	5	176
17596	10	6	176
17597	10	7	176
17598	10	8	176
17599	10	9	176
17600	10	10	176
17601	1	1	177
17602	1	2	177
17603	1	3	177
17604	1	4	177
17605	1	5	177
17606	1	6	177
17607	1	7	177
17608	1	8	177
17609	1	9	177
17610	1	10	177
17611	2	1	177
17612	2	2	177
17613	2	3	177
17614	2	4	177
17615	2	5	177
17616	2	6	177
17617	2	7	177
17618	2	8	177
17619	2	9	177
17620	2	10	177
17621	3	1	177
17622	3	2	177
17623	3	3	177
17624	3	4	177
17625	3	5	177
17626	3	6	177
17627	3	7	177
17628	3	8	177
17629	3	9	177
17630	3	10	177
17631	4	1	177
17632	4	2	177
17633	4	3	177
17634	4	4	177
17635	4	5	177
17636	4	6	177
17637	4	7	177
17638	4	8	177
17639	4	9	177
17640	4	10	177
17641	5	1	177
17642	5	2	177
17643	5	3	177
17644	5	4	177
17645	5	5	177
17646	5	6	177
17647	5	7	177
17648	5	8	177
17649	5	9	177
17650	5	10	177
17651	6	1	177
17652	6	2	177
17653	6	3	177
17654	6	4	177
17655	6	5	177
17656	6	6	177
17657	6	7	177
17658	6	8	177
17659	6	9	177
17660	6	10	177
17661	7	1	177
17662	7	2	177
17663	7	3	177
17664	7	4	177
17665	7	5	177
17666	7	6	177
17667	7	7	177
17668	7	8	177
17669	7	9	177
17670	7	10	177
17671	8	1	177
17672	8	2	177
17673	8	3	177
17674	8	4	177
17675	8	5	177
17676	8	6	177
17677	8	7	177
17678	8	8	177
17679	8	9	177
17680	8	10	177
17681	9	1	177
17682	9	2	177
17683	9	3	177
17684	9	4	177
17685	9	5	177
17686	9	6	177
17687	9	7	177
17688	9	8	177
17689	9	9	177
17690	9	10	177
17691	10	1	177
17692	10	2	177
17693	10	3	177
17694	10	4	177
17695	10	5	177
17696	10	6	177
17697	10	7	177
17698	10	8	177
17699	10	9	177
17700	10	10	177
17701	1	1	178
17702	1	2	178
17703	1	3	178
17704	1	4	178
17705	1	5	178
17706	1	6	178
17707	1	7	178
17708	1	8	178
17709	1	9	178
17710	1	10	178
17711	2	1	178
17712	2	2	178
17713	2	3	178
17714	2	4	178
17715	2	5	178
17716	2	6	178
17717	2	7	178
17718	2	8	178
17719	2	9	178
17720	2	10	178
17721	3	1	178
17722	3	2	178
17723	3	3	178
17724	3	4	178
17725	3	5	178
17726	3	6	178
17727	3	7	178
17728	3	8	178
17729	3	9	178
17730	3	10	178
17731	4	1	178
17732	4	2	178
17733	4	3	178
17734	4	4	178
17735	4	5	178
17736	4	6	178
17737	4	7	178
17738	4	8	178
17739	4	9	178
17740	4	10	178
17741	5	1	178
17742	5	2	178
17743	5	3	178
17744	5	4	178
17745	5	5	178
17746	5	6	178
17747	5	7	178
17748	5	8	178
17749	5	9	178
17750	5	10	178
17751	6	1	178
17752	6	2	178
17753	6	3	178
17754	6	4	178
17755	6	5	178
17756	6	6	178
17757	6	7	178
17758	6	8	178
17759	6	9	178
17760	6	10	178
17761	7	1	178
17762	7	2	178
17763	7	3	178
17764	7	4	178
17765	7	5	178
17766	7	6	178
17767	7	7	178
17768	7	8	178
17769	7	9	178
17770	7	10	178
17771	8	1	178
17772	8	2	178
17773	8	3	178
17774	8	4	178
17775	8	5	178
17776	8	6	178
17777	8	7	178
17778	8	8	178
17779	8	9	178
17780	8	10	178
17781	9	1	178
17782	9	2	178
17783	9	3	178
17784	9	4	178
17785	9	5	178
17786	9	6	178
17787	9	7	178
17788	9	8	178
17789	9	9	178
17790	9	10	178
17791	10	1	178
17792	10	2	178
17793	10	3	178
17794	10	4	178
17795	10	5	178
17796	10	6	178
17797	10	7	178
17798	10	8	178
17799	10	9	178
17800	10	10	178
17801	1	1	179
17802	1	2	179
17803	1	3	179
17804	1	4	179
17805	1	5	179
17806	1	6	179
17807	1	7	179
17808	1	8	179
17809	1	9	179
17810	1	10	179
17811	2	1	179
17812	2	2	179
17813	2	3	179
17814	2	4	179
17815	2	5	179
17816	2	6	179
17817	2	7	179
17818	2	8	179
17819	2	9	179
17820	2	10	179
17821	3	1	179
17822	3	2	179
17823	3	3	179
17824	3	4	179
17825	3	5	179
17826	3	6	179
17827	3	7	179
17828	3	8	179
17829	3	9	179
17830	3	10	179
17831	4	1	179
17832	4	2	179
17833	4	3	179
17834	4	4	179
17835	4	5	179
17836	4	6	179
17837	4	7	179
17838	4	8	179
17839	4	9	179
17840	4	10	179
17841	5	1	179
17842	5	2	179
17843	5	3	179
17844	5	4	179
17845	5	5	179
17846	5	6	179
17847	5	7	179
17848	5	8	179
17849	5	9	179
17850	5	10	179
17851	6	1	179
17852	6	2	179
17853	6	3	179
17854	6	4	179
17855	6	5	179
17856	6	6	179
17857	6	7	179
17858	6	8	179
17859	6	9	179
17860	6	10	179
17861	7	1	179
17862	7	2	179
17863	7	3	179
17864	7	4	179
17865	7	5	179
17866	7	6	179
17867	7	7	179
17868	7	8	179
17869	7	9	179
17870	7	10	179
17871	8	1	179
17872	8	2	179
17873	8	3	179
17874	8	4	179
17875	8	5	179
17876	8	6	179
17877	8	7	179
17878	8	8	179
17879	8	9	179
17880	8	10	179
17881	9	1	179
17882	9	2	179
17883	9	3	179
17884	9	4	179
17885	9	5	179
17886	9	6	179
17887	9	7	179
17888	9	8	179
17889	9	9	179
17890	9	10	179
17891	10	1	179
17892	10	2	179
17893	10	3	179
17894	10	4	179
17895	10	5	179
17896	10	6	179
17897	10	7	179
17898	10	8	179
17899	10	9	179
17900	10	10	179
17901	1	1	180
17902	1	2	180
17903	1	3	180
17904	1	4	180
17905	1	5	180
17906	1	6	180
17907	1	7	180
17908	1	8	180
17909	1	9	180
17910	1	10	180
17911	2	1	180
17912	2	2	180
17913	2	3	180
17914	2	4	180
17915	2	5	180
17916	2	6	180
17917	2	7	180
17918	2	8	180
17919	2	9	180
17920	2	10	180
17921	3	1	180
17922	3	2	180
17923	3	3	180
17924	3	4	180
17925	3	5	180
17926	3	6	180
17927	3	7	180
17928	3	8	180
17929	3	9	180
17930	3	10	180
17931	4	1	180
17932	4	2	180
17933	4	3	180
17934	4	4	180
17935	4	5	180
17936	4	6	180
17937	4	7	180
17938	4	8	180
17939	4	9	180
17940	4	10	180
17941	5	1	180
17942	5	2	180
17943	5	3	180
17944	5	4	180
17945	5	5	180
17946	5	6	180
17947	5	7	180
17948	5	8	180
17949	5	9	180
17950	5	10	180
17951	6	1	180
17952	6	2	180
17953	6	3	180
17954	6	4	180
17955	6	5	180
17956	6	6	180
17957	6	7	180
17958	6	8	180
17959	6	9	180
17960	6	10	180
17961	7	1	180
17962	7	2	180
17963	7	3	180
17964	7	4	180
17965	7	5	180
17966	7	6	180
17967	7	7	180
17968	7	8	180
17969	7	9	180
17970	7	10	180
17971	8	1	180
17972	8	2	180
17973	8	3	180
17974	8	4	180
17975	8	5	180
17976	8	6	180
17977	8	7	180
17978	8	8	180
17979	8	9	180
17980	8	10	180
17981	9	1	180
17982	9	2	180
17983	9	3	180
17984	9	4	180
17985	9	5	180
17986	9	6	180
17987	9	7	180
17988	9	8	180
17989	9	9	180
17990	9	10	180
17991	10	1	180
17992	10	2	180
17993	10	3	180
17994	10	4	180
17995	10	5	180
17996	10	6	180
17997	10	7	180
17998	10	8	180
17999	10	9	180
18000	10	10	180
18001	1	1	181
18002	1	2	181
18003	1	3	181
18004	1	4	181
18005	1	5	181
18006	1	6	181
18007	1	7	181
18008	1	8	181
18009	1	9	181
18010	1	10	181
18011	2	1	181
18012	2	2	181
18013	2	3	181
18014	2	4	181
18015	2	5	181
18016	2	6	181
18017	2	7	181
18018	2	8	181
18019	2	9	181
18020	2	10	181
18021	3	1	181
18022	3	2	181
18023	3	3	181
18024	3	4	181
18025	3	5	181
18026	3	6	181
18027	3	7	181
18028	3	8	181
18029	3	9	181
18030	3	10	181
18031	4	1	181
18032	4	2	181
18033	4	3	181
18034	4	4	181
18035	4	5	181
18036	4	6	181
18037	4	7	181
18038	4	8	181
18039	4	9	181
18040	4	10	181
18041	5	1	181
18042	5	2	181
18043	5	3	181
18044	5	4	181
18045	5	5	181
18046	5	6	181
18047	5	7	181
18048	5	8	181
18049	5	9	181
18050	5	10	181
18051	6	1	181
18052	6	2	181
18053	6	3	181
18054	6	4	181
18055	6	5	181
18056	6	6	181
18057	6	7	181
18058	6	8	181
18059	6	9	181
18060	6	10	181
18061	7	1	181
18062	7	2	181
18063	7	3	181
18064	7	4	181
18065	7	5	181
18066	7	6	181
18067	7	7	181
18068	7	8	181
18069	7	9	181
18070	7	10	181
18071	8	1	181
18072	8	2	181
18073	8	3	181
18074	8	4	181
18075	8	5	181
18076	8	6	181
18077	8	7	181
18078	8	8	181
18079	8	9	181
18080	8	10	181
18081	9	1	181
18082	9	2	181
18083	9	3	181
18084	9	4	181
18085	9	5	181
18086	9	6	181
18087	9	7	181
18088	9	8	181
18089	9	9	181
18090	9	10	181
18091	10	1	181
18092	10	2	181
18093	10	3	181
18094	10	4	181
18095	10	5	181
18096	10	6	181
18097	10	7	181
18098	10	8	181
18099	10	9	181
18100	10	10	181
18101	1	1	182
18102	1	2	182
18103	1	3	182
18104	1	4	182
18105	1	5	182
18106	1	6	182
18107	1	7	182
18108	1	8	182
18109	1	9	182
18110	1	10	182
18111	2	1	182
18112	2	2	182
18113	2	3	182
18114	2	4	182
18115	2	5	182
18116	2	6	182
18117	2	7	182
18118	2	8	182
18119	2	9	182
18120	2	10	182
18121	3	1	182
18122	3	2	182
18123	3	3	182
18124	3	4	182
18125	3	5	182
18126	3	6	182
18127	3	7	182
18128	3	8	182
18129	3	9	182
18130	3	10	182
18131	4	1	182
18132	4	2	182
18133	4	3	182
18134	4	4	182
18135	4	5	182
18136	4	6	182
18137	4	7	182
18138	4	8	182
18139	4	9	182
18140	4	10	182
18141	5	1	182
18142	5	2	182
18143	5	3	182
18144	5	4	182
18145	5	5	182
18146	5	6	182
18147	5	7	182
18148	5	8	182
18149	5	9	182
18150	5	10	182
18151	6	1	182
18152	6	2	182
18153	6	3	182
18154	6	4	182
18155	6	5	182
18156	6	6	182
18157	6	7	182
18158	6	8	182
18159	6	9	182
18160	6	10	182
18161	7	1	182
18162	7	2	182
18163	7	3	182
18164	7	4	182
18165	7	5	182
18166	7	6	182
18167	7	7	182
18168	7	8	182
18169	7	9	182
18170	7	10	182
18171	8	1	182
18172	8	2	182
18173	8	3	182
18174	8	4	182
18175	8	5	182
18176	8	6	182
18177	8	7	182
18178	8	8	182
18179	8	9	182
18180	8	10	182
18181	9	1	182
18182	9	2	182
18183	9	3	182
18184	9	4	182
18185	9	5	182
18186	9	6	182
18187	9	7	182
18188	9	8	182
18189	9	9	182
18190	9	10	182
18191	10	1	182
18192	10	2	182
18193	10	3	182
18194	10	4	182
18195	10	5	182
18196	10	6	182
18197	10	7	182
18198	10	8	182
18199	10	9	182
18200	10	10	182
18201	1	1	183
18202	1	2	183
18203	1	3	183
18204	1	4	183
18205	1	5	183
18206	1	6	183
18207	1	7	183
18208	1	8	183
18209	1	9	183
18210	1	10	183
18211	2	1	183
18212	2	2	183
18213	2	3	183
18214	2	4	183
18215	2	5	183
18216	2	6	183
18217	2	7	183
18218	2	8	183
18219	2	9	183
18220	2	10	183
18221	3	1	183
18222	3	2	183
18223	3	3	183
18224	3	4	183
18225	3	5	183
18226	3	6	183
18227	3	7	183
18228	3	8	183
18229	3	9	183
18230	3	10	183
18231	4	1	183
18232	4	2	183
18233	4	3	183
18234	4	4	183
18235	4	5	183
18236	4	6	183
18237	4	7	183
18238	4	8	183
18239	4	9	183
18240	4	10	183
18241	5	1	183
18242	5	2	183
18243	5	3	183
18244	5	4	183
18245	5	5	183
18246	5	6	183
18247	5	7	183
18248	5	8	183
18249	5	9	183
18250	5	10	183
18251	6	1	183
18252	6	2	183
18253	6	3	183
18254	6	4	183
18255	6	5	183
18256	6	6	183
18257	6	7	183
18258	6	8	183
18259	6	9	183
18260	6	10	183
18261	7	1	183
18262	7	2	183
18263	7	3	183
18264	7	4	183
18265	7	5	183
18266	7	6	183
18267	7	7	183
18268	7	8	183
18269	7	9	183
18270	7	10	183
18271	8	1	183
18272	8	2	183
18273	8	3	183
18274	8	4	183
18275	8	5	183
18276	8	6	183
18277	8	7	183
18278	8	8	183
18279	8	9	183
18280	8	10	183
18281	9	1	183
18282	9	2	183
18283	9	3	183
18284	9	4	183
18285	9	5	183
18286	9	6	183
18287	9	7	183
18288	9	8	183
18289	9	9	183
18290	9	10	183
18291	10	1	183
18292	10	2	183
18293	10	3	183
18294	10	4	183
18295	10	5	183
18296	10	6	183
18297	10	7	183
18298	10	8	183
18299	10	9	183
18300	10	10	183
18301	1	1	184
18302	1	2	184
18303	1	3	184
18304	1	4	184
18305	1	5	184
18306	1	6	184
18307	1	7	184
18308	1	8	184
18309	1	9	184
18310	1	10	184
18311	2	1	184
18312	2	2	184
18313	2	3	184
18314	2	4	184
18315	2	5	184
18316	2	6	184
18317	2	7	184
18318	2	8	184
18319	2	9	184
18320	2	10	184
18321	3	1	184
18322	3	2	184
18323	3	3	184
18324	3	4	184
18325	3	5	184
18326	3	6	184
18327	3	7	184
18328	3	8	184
18329	3	9	184
18330	3	10	184
18331	4	1	184
18332	4	2	184
18333	4	3	184
18334	4	4	184
18335	4	5	184
18336	4	6	184
18337	4	7	184
18338	4	8	184
18339	4	9	184
18340	4	10	184
18341	5	1	184
18342	5	2	184
18343	5	3	184
18344	5	4	184
18345	5	5	184
18346	5	6	184
18347	5	7	184
18348	5	8	184
18349	5	9	184
18350	5	10	184
18351	6	1	184
18352	6	2	184
18353	6	3	184
18354	6	4	184
18355	6	5	184
18356	6	6	184
18357	6	7	184
18358	6	8	184
18359	6	9	184
18360	6	10	184
18361	7	1	184
18362	7	2	184
18363	7	3	184
18364	7	4	184
18365	7	5	184
18366	7	6	184
18367	7	7	184
18368	7	8	184
18369	7	9	184
18370	7	10	184
18371	8	1	184
18372	8	2	184
18373	8	3	184
18374	8	4	184
18375	8	5	184
18376	8	6	184
18377	8	7	184
18378	8	8	184
18379	8	9	184
18380	8	10	184
18381	9	1	184
18382	9	2	184
18383	9	3	184
18384	9	4	184
18385	9	5	184
18386	9	6	184
18387	9	7	184
18388	9	8	184
18389	9	9	184
18390	9	10	184
18391	10	1	184
18392	10	2	184
18393	10	3	184
18394	10	4	184
18395	10	5	184
18396	10	6	184
18397	10	7	184
18398	10	8	184
18399	10	9	184
18400	10	10	184
18401	1	1	185
18402	1	2	185
18403	1	3	185
18404	1	4	185
18405	1	5	185
18406	1	6	185
18407	1	7	185
18408	1	8	185
18409	1	9	185
18410	1	10	185
18411	2	1	185
18412	2	2	185
18413	2	3	185
18414	2	4	185
18415	2	5	185
18416	2	6	185
18417	2	7	185
18418	2	8	185
18419	2	9	185
18420	2	10	185
18421	3	1	185
18422	3	2	185
18423	3	3	185
18424	3	4	185
18425	3	5	185
18426	3	6	185
18427	3	7	185
18428	3	8	185
18429	3	9	185
18430	3	10	185
18431	4	1	185
18432	4	2	185
18433	4	3	185
18434	4	4	185
18435	4	5	185
18436	4	6	185
18437	4	7	185
18438	4	8	185
18439	4	9	185
18440	4	10	185
18441	5	1	185
18442	5	2	185
18443	5	3	185
18444	5	4	185
18445	5	5	185
18446	5	6	185
18447	5	7	185
18448	5	8	185
18449	5	9	185
18450	5	10	185
18451	6	1	185
18452	6	2	185
18453	6	3	185
18454	6	4	185
18455	6	5	185
18456	6	6	185
18457	6	7	185
18458	6	8	185
18459	6	9	185
18460	6	10	185
18461	7	1	185
18462	7	2	185
18463	7	3	185
18464	7	4	185
18465	7	5	185
18466	7	6	185
18467	7	7	185
18468	7	8	185
18469	7	9	185
18470	7	10	185
18471	8	1	185
18472	8	2	185
18473	8	3	185
18474	8	4	185
18475	8	5	185
18476	8	6	185
18477	8	7	185
18478	8	8	185
18479	8	9	185
18480	8	10	185
18481	9	1	185
18482	9	2	185
18483	9	3	185
18484	9	4	185
18485	9	5	185
18486	9	6	185
18487	9	7	185
18488	9	8	185
18489	9	9	185
18490	9	10	185
18491	10	1	185
18492	10	2	185
18493	10	3	185
18494	10	4	185
18495	10	5	185
18496	10	6	185
18497	10	7	185
18498	10	8	185
18499	10	9	185
18500	10	10	185
18501	1	1	186
18502	1	2	186
18503	1	3	186
18504	1	4	186
18505	1	5	186
18506	1	6	186
18507	1	7	186
18508	1	8	186
18509	1	9	186
18510	1	10	186
18511	2	1	186
18512	2	2	186
18513	2	3	186
18514	2	4	186
18515	2	5	186
18516	2	6	186
18517	2	7	186
18518	2	8	186
18519	2	9	186
18520	2	10	186
18521	3	1	186
18522	3	2	186
18523	3	3	186
18524	3	4	186
18525	3	5	186
18526	3	6	186
18527	3	7	186
18528	3	8	186
18529	3	9	186
18530	3	10	186
18531	4	1	186
18532	4	2	186
18533	4	3	186
18534	4	4	186
18535	4	5	186
18536	4	6	186
18537	4	7	186
18538	4	8	186
18539	4	9	186
18540	4	10	186
18541	5	1	186
18542	5	2	186
18543	5	3	186
18544	5	4	186
18545	5	5	186
18546	5	6	186
18547	5	7	186
18548	5	8	186
18549	5	9	186
18550	5	10	186
18551	6	1	186
18552	6	2	186
18553	6	3	186
18554	6	4	186
18555	6	5	186
18556	6	6	186
18557	6	7	186
18558	6	8	186
18559	6	9	186
18560	6	10	186
18561	7	1	186
18562	7	2	186
18563	7	3	186
18564	7	4	186
18565	7	5	186
18566	7	6	186
18567	7	7	186
18568	7	8	186
18569	7	9	186
18570	7	10	186
18571	8	1	186
18572	8	2	186
18573	8	3	186
18574	8	4	186
18575	8	5	186
18576	8	6	186
18577	8	7	186
18578	8	8	186
18579	8	9	186
18580	8	10	186
18581	9	1	186
18582	9	2	186
18583	9	3	186
18584	9	4	186
18585	9	5	186
18586	9	6	186
18587	9	7	186
18588	9	8	186
18589	9	9	186
18590	9	10	186
18591	10	1	186
18592	10	2	186
18593	10	3	186
18594	10	4	186
18595	10	5	186
18596	10	6	186
18597	10	7	186
18598	10	8	186
18599	10	9	186
18600	10	10	186
18601	1	1	187
18602	1	2	187
18603	1	3	187
18604	1	4	187
18605	1	5	187
18606	1	6	187
18607	1	7	187
18608	1	8	187
18609	1	9	187
18610	1	10	187
18611	2	1	187
18612	2	2	187
18613	2	3	187
18614	2	4	187
18615	2	5	187
18616	2	6	187
18617	2	7	187
18618	2	8	187
18619	2	9	187
18620	2	10	187
18621	3	1	187
18622	3	2	187
18623	3	3	187
18624	3	4	187
18625	3	5	187
18626	3	6	187
18627	3	7	187
18628	3	8	187
18629	3	9	187
18630	3	10	187
18631	4	1	187
18632	4	2	187
18633	4	3	187
18634	4	4	187
18635	4	5	187
18636	4	6	187
18637	4	7	187
18638	4	8	187
18639	4	9	187
18640	4	10	187
18641	5	1	187
18642	5	2	187
18643	5	3	187
18644	5	4	187
18645	5	5	187
18646	5	6	187
18647	5	7	187
18648	5	8	187
18649	5	9	187
18650	5	10	187
18651	6	1	187
18652	6	2	187
18653	6	3	187
18654	6	4	187
18655	6	5	187
18656	6	6	187
18657	6	7	187
18658	6	8	187
18659	6	9	187
18660	6	10	187
18661	7	1	187
18662	7	2	187
18663	7	3	187
18664	7	4	187
18665	7	5	187
18666	7	6	187
18667	7	7	187
18668	7	8	187
18669	7	9	187
18670	7	10	187
18671	8	1	187
18672	8	2	187
18673	8	3	187
18674	8	4	187
18675	8	5	187
18676	8	6	187
18677	8	7	187
18678	8	8	187
18679	8	9	187
18680	8	10	187
18681	9	1	187
18682	9	2	187
18683	9	3	187
18684	9	4	187
18685	9	5	187
18686	9	6	187
18687	9	7	187
18688	9	8	187
18689	9	9	187
18690	9	10	187
18691	10	1	187
18692	10	2	187
18693	10	3	187
18694	10	4	187
18695	10	5	187
18696	10	6	187
18697	10	7	187
18698	10	8	187
18699	10	9	187
18700	10	10	187
18701	1	1	188
18702	1	2	188
18703	1	3	188
18704	1	4	188
18705	1	5	188
18706	1	6	188
18707	1	7	188
18708	1	8	188
18709	1	9	188
18710	1	10	188
18711	2	1	188
18712	2	2	188
18713	2	3	188
18714	2	4	188
18715	2	5	188
18716	2	6	188
18717	2	7	188
18718	2	8	188
18719	2	9	188
18720	2	10	188
18721	3	1	188
18722	3	2	188
18723	3	3	188
18724	3	4	188
18725	3	5	188
18726	3	6	188
18727	3	7	188
18728	3	8	188
18729	3	9	188
18730	3	10	188
18731	4	1	188
18732	4	2	188
18733	4	3	188
18734	4	4	188
18735	4	5	188
18736	4	6	188
18737	4	7	188
18738	4	8	188
18739	4	9	188
18740	4	10	188
18741	5	1	188
18742	5	2	188
18743	5	3	188
18744	5	4	188
18745	5	5	188
18746	5	6	188
18747	5	7	188
18748	5	8	188
18749	5	9	188
18750	5	10	188
18751	6	1	188
18752	6	2	188
18753	6	3	188
18754	6	4	188
18755	6	5	188
18756	6	6	188
18757	6	7	188
18758	6	8	188
18759	6	9	188
18760	6	10	188
18761	7	1	188
18762	7	2	188
18763	7	3	188
18764	7	4	188
18765	7	5	188
18766	7	6	188
18767	7	7	188
18768	7	8	188
18769	7	9	188
18770	7	10	188
18771	8	1	188
18772	8	2	188
18773	8	3	188
18774	8	4	188
18775	8	5	188
18776	8	6	188
18777	8	7	188
18778	8	8	188
18779	8	9	188
18780	8	10	188
18781	9	1	188
18782	9	2	188
18783	9	3	188
18784	9	4	188
18785	9	5	188
18786	9	6	188
18787	9	7	188
18788	9	8	188
18789	9	9	188
18790	9	10	188
18791	10	1	188
18792	10	2	188
18793	10	3	188
18794	10	4	188
18795	10	5	188
18796	10	6	188
18797	10	7	188
18798	10	8	188
18799	10	9	188
18800	10	10	188
18801	1	1	189
18802	1	2	189
18803	1	3	189
18804	1	4	189
18805	1	5	189
18806	1	6	189
18807	1	7	189
18808	1	8	189
18809	1	9	189
18810	1	10	189
18811	2	1	189
18812	2	2	189
18813	2	3	189
18814	2	4	189
18815	2	5	189
18816	2	6	189
18817	2	7	189
18818	2	8	189
18819	2	9	189
18820	2	10	189
18821	3	1	189
18822	3	2	189
18823	3	3	189
18824	3	4	189
18825	3	5	189
18826	3	6	189
18827	3	7	189
18828	3	8	189
18829	3	9	189
18830	3	10	189
18831	4	1	189
18832	4	2	189
18833	4	3	189
18834	4	4	189
18835	4	5	189
18836	4	6	189
18837	4	7	189
18838	4	8	189
18839	4	9	189
18840	4	10	189
18841	5	1	189
18842	5	2	189
18843	5	3	189
18844	5	4	189
18845	5	5	189
18846	5	6	189
18847	5	7	189
18848	5	8	189
18849	5	9	189
18850	5	10	189
18851	6	1	189
18852	6	2	189
18853	6	3	189
18854	6	4	189
18855	6	5	189
18856	6	6	189
18857	6	7	189
18858	6	8	189
18859	6	9	189
18860	6	10	189
18861	7	1	189
18862	7	2	189
18863	7	3	189
18864	7	4	189
18865	7	5	189
18866	7	6	189
18867	7	7	189
18868	7	8	189
18869	7	9	189
18870	7	10	189
18871	8	1	189
18872	8	2	189
18873	8	3	189
18874	8	4	189
18875	8	5	189
18876	8	6	189
18877	8	7	189
18878	8	8	189
18879	8	9	189
18880	8	10	189
18881	9	1	189
18882	9	2	189
18883	9	3	189
18884	9	4	189
18885	9	5	189
18886	9	6	189
18887	9	7	189
18888	9	8	189
18889	9	9	189
18890	9	10	189
18891	10	1	189
18892	10	2	189
18893	10	3	189
18894	10	4	189
18895	10	5	189
18896	10	6	189
18897	10	7	189
18898	10	8	189
18899	10	9	189
18900	10	10	189
18901	1	1	190
18902	1	2	190
18903	1	3	190
18904	1	4	190
18905	1	5	190
18906	1	6	190
18907	1	7	190
18908	1	8	190
18909	1	9	190
18910	1	10	190
18911	2	1	190
18912	2	2	190
18913	2	3	190
18914	2	4	190
18915	2	5	190
18916	2	6	190
18917	2	7	190
18918	2	8	190
18919	2	9	190
18920	2	10	190
18921	3	1	190
18922	3	2	190
18923	3	3	190
18924	3	4	190
18925	3	5	190
18926	3	6	190
18927	3	7	190
18928	3	8	190
18929	3	9	190
18930	3	10	190
18931	4	1	190
18932	4	2	190
18933	4	3	190
18934	4	4	190
18935	4	5	190
18936	4	6	190
18937	4	7	190
18938	4	8	190
18939	4	9	190
18940	4	10	190
18941	5	1	190
18942	5	2	190
18943	5	3	190
18944	5	4	190
18945	5	5	190
18946	5	6	190
18947	5	7	190
18948	5	8	190
18949	5	9	190
18950	5	10	190
18951	6	1	190
18952	6	2	190
18953	6	3	190
18954	6	4	190
18955	6	5	190
18956	6	6	190
18957	6	7	190
18958	6	8	190
18959	6	9	190
18960	6	10	190
18961	7	1	190
18962	7	2	190
18963	7	3	190
18964	7	4	190
18965	7	5	190
18966	7	6	190
18967	7	7	190
18968	7	8	190
18969	7	9	190
18970	7	10	190
18971	8	1	190
18972	8	2	190
18973	8	3	190
18974	8	4	190
18975	8	5	190
18976	8	6	190
18977	8	7	190
18978	8	8	190
18979	8	9	190
18980	8	10	190
18981	9	1	190
18982	9	2	190
18983	9	3	190
18984	9	4	190
18985	9	5	190
18986	9	6	190
18987	9	7	190
18988	9	8	190
18989	9	9	190
18990	9	10	190
18991	10	1	190
18992	10	2	190
18993	10	3	190
18994	10	4	190
18995	10	5	190
18996	10	6	190
18997	10	7	190
18998	10	8	190
18999	10	9	190
19000	10	10	190
19001	1	1	191
19002	1	2	191
19003	1	3	191
19004	1	4	191
19005	1	5	191
19006	1	6	191
19007	1	7	191
19008	1	8	191
19009	1	9	191
19010	1	10	191
19011	2	1	191
19012	2	2	191
19013	2	3	191
19014	2	4	191
19015	2	5	191
19016	2	6	191
19017	2	7	191
19018	2	8	191
19019	2	9	191
19020	2	10	191
19021	3	1	191
19022	3	2	191
19023	3	3	191
19024	3	4	191
19025	3	5	191
19026	3	6	191
19027	3	7	191
19028	3	8	191
19029	3	9	191
19030	3	10	191
19031	4	1	191
19032	4	2	191
19033	4	3	191
19034	4	4	191
19035	4	5	191
19036	4	6	191
19037	4	7	191
19038	4	8	191
19039	4	9	191
19040	4	10	191
19041	5	1	191
19042	5	2	191
19043	5	3	191
19044	5	4	191
19045	5	5	191
19046	5	6	191
19047	5	7	191
19048	5	8	191
19049	5	9	191
19050	5	10	191
19051	6	1	191
19052	6	2	191
19053	6	3	191
19054	6	4	191
19055	6	5	191
19056	6	6	191
19057	6	7	191
19058	6	8	191
19059	6	9	191
19060	6	10	191
19061	7	1	191
19062	7	2	191
19063	7	3	191
19064	7	4	191
19065	7	5	191
19066	7	6	191
19067	7	7	191
19068	7	8	191
19069	7	9	191
19070	7	10	191
19071	8	1	191
19072	8	2	191
19073	8	3	191
19074	8	4	191
19075	8	5	191
19076	8	6	191
19077	8	7	191
19078	8	8	191
19079	8	9	191
19080	8	10	191
19081	9	1	191
19082	9	2	191
19083	9	3	191
19084	9	4	191
19085	9	5	191
19086	9	6	191
19087	9	7	191
19088	9	8	191
19089	9	9	191
19090	9	10	191
19091	10	1	191
19092	10	2	191
19093	10	3	191
19094	10	4	191
19095	10	5	191
19096	10	6	191
19097	10	7	191
19098	10	8	191
19099	10	9	191
19100	10	10	191
19101	1	1	192
19102	1	2	192
19103	1	3	192
19104	1	4	192
19105	1	5	192
19106	1	6	192
19107	1	7	192
19108	1	8	192
19109	1	9	192
19110	1	10	192
19111	2	1	192
19112	2	2	192
19113	2	3	192
19114	2	4	192
19115	2	5	192
19116	2	6	192
19117	2	7	192
19118	2	8	192
19119	2	9	192
19120	2	10	192
19121	3	1	192
19122	3	2	192
19123	3	3	192
19124	3	4	192
19125	3	5	192
19126	3	6	192
19127	3	7	192
19128	3	8	192
19129	3	9	192
19130	3	10	192
19131	4	1	192
19132	4	2	192
19133	4	3	192
19134	4	4	192
19135	4	5	192
19136	4	6	192
19137	4	7	192
19138	4	8	192
19139	4	9	192
19140	4	10	192
19141	5	1	192
19142	5	2	192
19143	5	3	192
19144	5	4	192
19145	5	5	192
19146	5	6	192
19147	5	7	192
19148	5	8	192
19149	5	9	192
19150	5	10	192
19151	6	1	192
19152	6	2	192
19153	6	3	192
19154	6	4	192
19155	6	5	192
19156	6	6	192
19157	6	7	192
19158	6	8	192
19159	6	9	192
19160	6	10	192
19161	7	1	192
19162	7	2	192
19163	7	3	192
19164	7	4	192
19165	7	5	192
19166	7	6	192
19167	7	7	192
19168	7	8	192
19169	7	9	192
19170	7	10	192
19171	8	1	192
19172	8	2	192
19173	8	3	192
19174	8	4	192
19175	8	5	192
19176	8	6	192
19177	8	7	192
19178	8	8	192
19179	8	9	192
19180	8	10	192
19181	9	1	192
19182	9	2	192
19183	9	3	192
19184	9	4	192
19185	9	5	192
19186	9	6	192
19187	9	7	192
19188	9	8	192
19189	9	9	192
19190	9	10	192
19191	10	1	192
19192	10	2	192
19193	10	3	192
19194	10	4	192
19195	10	5	192
19196	10	6	192
19197	10	7	192
19198	10	8	192
19199	10	9	192
19200	10	10	192
19201	1	1	193
19202	1	2	193
19203	1	3	193
19204	1	4	193
19205	1	5	193
19206	1	6	193
19207	1	7	193
19208	1	8	193
19209	1	9	193
19210	1	10	193
19211	2	1	193
19212	2	2	193
19213	2	3	193
19214	2	4	193
19215	2	5	193
19216	2	6	193
19217	2	7	193
19218	2	8	193
19219	2	9	193
19220	2	10	193
19221	3	1	193
19222	3	2	193
19223	3	3	193
19224	3	4	193
19225	3	5	193
19226	3	6	193
19227	3	7	193
19228	3	8	193
19229	3	9	193
19230	3	10	193
19231	4	1	193
19232	4	2	193
19233	4	3	193
19234	4	4	193
19235	4	5	193
19236	4	6	193
19237	4	7	193
19238	4	8	193
19239	4	9	193
19240	4	10	193
19241	5	1	193
19242	5	2	193
19243	5	3	193
19244	5	4	193
19245	5	5	193
19246	5	6	193
19247	5	7	193
19248	5	8	193
19249	5	9	193
19250	5	10	193
19251	6	1	193
19252	6	2	193
19253	6	3	193
19254	6	4	193
19255	6	5	193
19256	6	6	193
19257	6	7	193
19258	6	8	193
19259	6	9	193
19260	6	10	193
19261	7	1	193
19262	7	2	193
19263	7	3	193
19264	7	4	193
19265	7	5	193
19266	7	6	193
19267	7	7	193
19268	7	8	193
19269	7	9	193
19270	7	10	193
19271	8	1	193
19272	8	2	193
19273	8	3	193
19274	8	4	193
19275	8	5	193
19276	8	6	193
19277	8	7	193
19278	8	8	193
19279	8	9	193
19280	8	10	193
19281	9	1	193
19282	9	2	193
19283	9	3	193
19284	9	4	193
19285	9	5	193
19286	9	6	193
19287	9	7	193
19288	9	8	193
19289	9	9	193
19290	9	10	193
19291	10	1	193
19292	10	2	193
19293	10	3	193
19294	10	4	193
19295	10	5	193
19296	10	6	193
19297	10	7	193
19298	10	8	193
19299	10	9	193
19300	10	10	193
19301	1	1	194
19302	1	2	194
19303	1	3	194
19304	1	4	194
19305	1	5	194
19306	1	6	194
19307	1	7	194
19308	1	8	194
19309	1	9	194
19310	1	10	194
19311	2	1	194
19312	2	2	194
19313	2	3	194
19314	2	4	194
19315	2	5	194
19316	2	6	194
19317	2	7	194
19318	2	8	194
19319	2	9	194
19320	2	10	194
19321	3	1	194
19322	3	2	194
19323	3	3	194
19324	3	4	194
19325	3	5	194
19326	3	6	194
19327	3	7	194
19328	3	8	194
19329	3	9	194
19330	3	10	194
19331	4	1	194
19332	4	2	194
19333	4	3	194
19334	4	4	194
19335	4	5	194
19336	4	6	194
19337	4	7	194
19338	4	8	194
19339	4	9	194
19340	4	10	194
19341	5	1	194
19342	5	2	194
19343	5	3	194
19344	5	4	194
19345	5	5	194
19346	5	6	194
19347	5	7	194
19348	5	8	194
19349	5	9	194
19350	5	10	194
19351	6	1	194
19352	6	2	194
19353	6	3	194
19354	6	4	194
19355	6	5	194
19356	6	6	194
19357	6	7	194
19358	6	8	194
19359	6	9	194
19360	6	10	194
19361	7	1	194
19362	7	2	194
19363	7	3	194
19364	7	4	194
19365	7	5	194
19366	7	6	194
19367	7	7	194
19368	7	8	194
19369	7	9	194
19370	7	10	194
19371	8	1	194
19372	8	2	194
19373	8	3	194
19374	8	4	194
19375	8	5	194
19376	8	6	194
19377	8	7	194
19378	8	8	194
19379	8	9	194
19380	8	10	194
19381	9	1	194
19382	9	2	194
19383	9	3	194
19384	9	4	194
19385	9	5	194
19386	9	6	194
19387	9	7	194
19388	9	8	194
19389	9	9	194
19390	9	10	194
19391	10	1	194
19392	10	2	194
19393	10	3	194
19394	10	4	194
19395	10	5	194
19396	10	6	194
19397	10	7	194
19398	10	8	194
19399	10	9	194
19400	10	10	194
19401	1	1	195
19402	1	2	195
19403	1	3	195
19404	1	4	195
19405	1	5	195
19406	1	6	195
19407	1	7	195
19408	1	8	195
19409	1	9	195
19410	1	10	195
19411	2	1	195
19412	2	2	195
19413	2	3	195
19414	2	4	195
19415	2	5	195
19416	2	6	195
19417	2	7	195
19418	2	8	195
19419	2	9	195
19420	2	10	195
19421	3	1	195
19422	3	2	195
19423	3	3	195
19424	3	4	195
19425	3	5	195
19426	3	6	195
19427	3	7	195
19428	3	8	195
19429	3	9	195
19430	3	10	195
19431	4	1	195
19432	4	2	195
19433	4	3	195
19434	4	4	195
19435	4	5	195
19436	4	6	195
19437	4	7	195
19438	4	8	195
19439	4	9	195
19440	4	10	195
19441	5	1	195
19442	5	2	195
19443	5	3	195
19444	5	4	195
19445	5	5	195
19446	5	6	195
19447	5	7	195
19448	5	8	195
19449	5	9	195
19450	5	10	195
19451	6	1	195
19452	6	2	195
19453	6	3	195
19454	6	4	195
19455	6	5	195
19456	6	6	195
19457	6	7	195
19458	6	8	195
19459	6	9	195
19460	6	10	195
19461	7	1	195
19462	7	2	195
19463	7	3	195
19464	7	4	195
19465	7	5	195
19466	7	6	195
19467	7	7	195
19468	7	8	195
19469	7	9	195
19470	7	10	195
19471	8	1	195
19472	8	2	195
19473	8	3	195
19474	8	4	195
19475	8	5	195
19476	8	6	195
19477	8	7	195
19478	8	8	195
19479	8	9	195
19480	8	10	195
19481	9	1	195
19482	9	2	195
19483	9	3	195
19484	9	4	195
19485	9	5	195
19486	9	6	195
19487	9	7	195
19488	9	8	195
19489	9	9	195
19490	9	10	195
19491	10	1	195
19492	10	2	195
19493	10	3	195
19494	10	4	195
19495	10	5	195
19496	10	6	195
19497	10	7	195
19498	10	8	195
19499	10	9	195
19500	10	10	195
19501	1	1	196
19502	1	2	196
19503	1	3	196
19504	1	4	196
19505	1	5	196
19506	1	6	196
19507	1	7	196
19508	1	8	196
19509	1	9	196
19510	1	10	196
19511	2	1	196
19512	2	2	196
19513	2	3	196
19514	2	4	196
19515	2	5	196
19516	2	6	196
19517	2	7	196
19518	2	8	196
19519	2	9	196
19520	2	10	196
19521	3	1	196
19522	3	2	196
19523	3	3	196
19524	3	4	196
19525	3	5	196
19526	3	6	196
19527	3	7	196
19528	3	8	196
19529	3	9	196
19530	3	10	196
19531	4	1	196
19532	4	2	196
19533	4	3	196
19534	4	4	196
19535	4	5	196
19536	4	6	196
19537	4	7	196
19538	4	8	196
19539	4	9	196
19540	4	10	196
19541	5	1	196
19542	5	2	196
19543	5	3	196
19544	5	4	196
19545	5	5	196
19546	5	6	196
19547	5	7	196
19548	5	8	196
19549	5	9	196
19550	5	10	196
19551	6	1	196
19552	6	2	196
19553	6	3	196
19554	6	4	196
19555	6	5	196
19556	6	6	196
19557	6	7	196
19558	6	8	196
19559	6	9	196
19560	6	10	196
19561	7	1	196
19562	7	2	196
19563	7	3	196
19564	7	4	196
19565	7	5	196
19566	7	6	196
19567	7	7	196
19568	7	8	196
19569	7	9	196
19570	7	10	196
19571	8	1	196
19572	8	2	196
19573	8	3	196
19574	8	4	196
19575	8	5	196
19576	8	6	196
19577	8	7	196
19578	8	8	196
19579	8	9	196
19580	8	10	196
19581	9	1	196
19582	9	2	196
19583	9	3	196
19584	9	4	196
19585	9	5	196
19586	9	6	196
19587	9	7	196
19588	9	8	196
19589	9	9	196
19590	9	10	196
19591	10	1	196
19592	10	2	196
19593	10	3	196
19594	10	4	196
19595	10	5	196
19596	10	6	196
19597	10	7	196
19598	10	8	196
19599	10	9	196
19600	10	10	196
19601	1	1	197
19602	1	2	197
19603	1	3	197
19604	1	4	197
19605	1	5	197
19606	1	6	197
19607	1	7	197
19608	1	8	197
19609	1	9	197
19610	1	10	197
19611	2	1	197
19612	2	2	197
19613	2	3	197
19614	2	4	197
19615	2	5	197
19616	2	6	197
19617	2	7	197
19618	2	8	197
19619	2	9	197
19620	2	10	197
19621	3	1	197
19622	3	2	197
19623	3	3	197
19624	3	4	197
19625	3	5	197
19626	3	6	197
19627	3	7	197
19628	3	8	197
19629	3	9	197
19630	3	10	197
19631	4	1	197
19632	4	2	197
19633	4	3	197
19634	4	4	197
19635	4	5	197
19636	4	6	197
19637	4	7	197
19638	4	8	197
19639	4	9	197
19640	4	10	197
19641	5	1	197
19642	5	2	197
19643	5	3	197
19644	5	4	197
19645	5	5	197
19646	5	6	197
19647	5	7	197
19648	5	8	197
19649	5	9	197
19650	5	10	197
19651	6	1	197
19652	6	2	197
19653	6	3	197
19654	6	4	197
19655	6	5	197
19656	6	6	197
19657	6	7	197
19658	6	8	197
19659	6	9	197
19660	6	10	197
19661	7	1	197
19662	7	2	197
19663	7	3	197
19664	7	4	197
19665	7	5	197
19666	7	6	197
19667	7	7	197
19668	7	8	197
19669	7	9	197
19670	7	10	197
19671	8	1	197
19672	8	2	197
19673	8	3	197
19674	8	4	197
19675	8	5	197
19676	8	6	197
19677	8	7	197
19678	8	8	197
19679	8	9	197
19680	8	10	197
19681	9	1	197
19682	9	2	197
19683	9	3	197
19684	9	4	197
19685	9	5	197
19686	9	6	197
19687	9	7	197
19688	9	8	197
19689	9	9	197
19690	9	10	197
19691	10	1	197
19692	10	2	197
19693	10	3	197
19694	10	4	197
19695	10	5	197
19696	10	6	197
19697	10	7	197
19698	10	8	197
19699	10	9	197
19700	10	10	197
19701	1	1	198
19702	1	2	198
19703	1	3	198
19704	1	4	198
19705	1	5	198
19706	1	6	198
19707	1	7	198
19708	1	8	198
19709	1	9	198
19710	1	10	198
19711	2	1	198
19712	2	2	198
19713	2	3	198
19714	2	4	198
19715	2	5	198
19716	2	6	198
19717	2	7	198
19718	2	8	198
19719	2	9	198
19720	2	10	198
19721	3	1	198
19722	3	2	198
19723	3	3	198
19724	3	4	198
19725	3	5	198
19726	3	6	198
19727	3	7	198
19728	3	8	198
19729	3	9	198
19730	3	10	198
19731	4	1	198
19732	4	2	198
19733	4	3	198
19734	4	4	198
19735	4	5	198
19736	4	6	198
19737	4	7	198
19738	4	8	198
19739	4	9	198
19740	4	10	198
19741	5	1	198
19742	5	2	198
19743	5	3	198
19744	5	4	198
19745	5	5	198
19746	5	6	198
19747	5	7	198
19748	5	8	198
19749	5	9	198
19750	5	10	198
19751	6	1	198
19752	6	2	198
19753	6	3	198
19754	6	4	198
19755	6	5	198
19756	6	6	198
19757	6	7	198
19758	6	8	198
19759	6	9	198
19760	6	10	198
19761	7	1	198
19762	7	2	198
19763	7	3	198
19764	7	4	198
19765	7	5	198
19766	7	6	198
19767	7	7	198
19768	7	8	198
19769	7	9	198
19770	7	10	198
19771	8	1	198
19772	8	2	198
19773	8	3	198
19774	8	4	198
19775	8	5	198
19776	8	6	198
19777	8	7	198
19778	8	8	198
19779	8	9	198
19780	8	10	198
19781	9	1	198
19782	9	2	198
19783	9	3	198
19784	9	4	198
19785	9	5	198
19786	9	6	198
19787	9	7	198
19788	9	8	198
19789	9	9	198
19790	9	10	198
19791	10	1	198
19792	10	2	198
19793	10	3	198
19794	10	4	198
19795	10	5	198
19796	10	6	198
19797	10	7	198
19798	10	8	198
19799	10	9	198
19800	10	10	198
19801	1	1	199
19802	1	2	199
19803	1	3	199
19804	1	4	199
19805	1	5	199
19806	1	6	199
19807	1	7	199
19808	1	8	199
19809	1	9	199
19810	1	10	199
19811	2	1	199
19812	2	2	199
19813	2	3	199
19814	2	4	199
19815	2	5	199
19816	2	6	199
19817	2	7	199
19818	2	8	199
19819	2	9	199
19820	2	10	199
19821	3	1	199
19822	3	2	199
19823	3	3	199
19824	3	4	199
19825	3	5	199
19826	3	6	199
19827	3	7	199
19828	3	8	199
19829	3	9	199
19830	3	10	199
19831	4	1	199
19832	4	2	199
19833	4	3	199
19834	4	4	199
19835	4	5	199
19836	4	6	199
19837	4	7	199
19838	4	8	199
19839	4	9	199
19840	4	10	199
19841	5	1	199
19842	5	2	199
19843	5	3	199
19844	5	4	199
19845	5	5	199
19846	5	6	199
19847	5	7	199
19848	5	8	199
19849	5	9	199
19850	5	10	199
19851	6	1	199
19852	6	2	199
19853	6	3	199
19854	6	4	199
19855	6	5	199
19856	6	6	199
19857	6	7	199
19858	6	8	199
19859	6	9	199
19860	6	10	199
19861	7	1	199
19862	7	2	199
19863	7	3	199
19864	7	4	199
19865	7	5	199
19866	7	6	199
19867	7	7	199
19868	7	8	199
19869	7	9	199
19870	7	10	199
19871	8	1	199
19872	8	2	199
19873	8	3	199
19874	8	4	199
19875	8	5	199
19876	8	6	199
19877	8	7	199
19878	8	8	199
19879	8	9	199
19880	8	10	199
19881	9	1	199
19882	9	2	199
19883	9	3	199
19884	9	4	199
19885	9	5	199
19886	9	6	199
19887	9	7	199
19888	9	8	199
19889	9	9	199
19890	9	10	199
19891	10	1	199
19892	10	2	199
19893	10	3	199
19894	10	4	199
19895	10	5	199
19896	10	6	199
19897	10	7	199
19898	10	8	199
19899	10	9	199
19900	10	10	199
19901	1	1	200
19902	1	2	200
19903	1	3	200
19904	1	4	200
19905	1	5	200
19906	1	6	200
19907	1	7	200
19908	1	8	200
19909	1	9	200
19910	1	10	200
19911	2	1	200
19912	2	2	200
19913	2	3	200
19914	2	4	200
19915	2	5	200
19916	2	6	200
19917	2	7	200
19918	2	8	200
19919	2	9	200
19920	2	10	200
19921	3	1	200
19922	3	2	200
19923	3	3	200
19924	3	4	200
19925	3	5	200
19926	3	6	200
19927	3	7	200
19928	3	8	200
19929	3	9	200
19930	3	10	200
19931	4	1	200
19932	4	2	200
19933	4	3	200
19934	4	4	200
19935	4	5	200
19936	4	6	200
19937	4	7	200
19938	4	8	200
19939	4	9	200
19940	4	10	200
19941	5	1	200
19942	5	2	200
19943	5	3	200
19944	5	4	200
19945	5	5	200
19946	5	6	200
19947	5	7	200
19948	5	8	200
19949	5	9	200
19950	5	10	200
19951	6	1	200
19952	6	2	200
19953	6	3	200
19954	6	4	200
19955	6	5	200
19956	6	6	200
19957	6	7	200
19958	6	8	200
19959	6	9	200
19960	6	10	200
19961	7	1	200
19962	7	2	200
19963	7	3	200
19964	7	4	200
19965	7	5	200
19966	7	6	200
19967	7	7	200
19968	7	8	200
19969	7	9	200
19970	7	10	200
19971	8	1	200
19972	8	2	200
19973	8	3	200
19974	8	4	200
19975	8	5	200
19976	8	6	200
19977	8	7	200
19978	8	8	200
19979	8	9	200
19980	8	10	200
19981	9	1	200
19982	9	2	200
19983	9	3	200
19984	9	4	200
19985	9	5	200
19986	9	6	200
19987	9	7	200
19988	9	8	200
19989	9	9	200
19990	9	10	200
19991	10	1	200
19992	10	2	200
19993	10	3	200
19994	10	4	200
19995	10	5	200
19996	10	6	200
19997	10	7	200
19998	10	8	200
19999	10	9	200
20000	10	10	200
20001	1	1	201
20002	1	2	201
20003	1	3	201
20004	1	4	201
20005	1	5	201
20006	1	6	201
20007	1	7	201
20008	1	8	201
20009	1	9	201
20010	1	10	201
20011	2	1	201
20012	2	2	201
20013	2	3	201
20014	2	4	201
20015	2	5	201
20016	2	6	201
20017	2	7	201
20018	2	8	201
20019	2	9	201
20020	2	10	201
20021	3	1	201
20022	3	2	201
20023	3	3	201
20024	3	4	201
20025	3	5	201
20026	3	6	201
20027	3	7	201
20028	3	8	201
20029	3	9	201
20030	3	10	201
20031	4	1	201
20032	4	2	201
20033	4	3	201
20034	4	4	201
20035	4	5	201
20036	4	6	201
20037	4	7	201
20038	4	8	201
20039	4	9	201
20040	4	10	201
20041	5	1	201
20042	5	2	201
20043	5	3	201
20044	5	4	201
20045	5	5	201
20046	5	6	201
20047	5	7	201
20048	5	8	201
20049	5	9	201
20050	5	10	201
20051	6	1	201
20052	6	2	201
20053	6	3	201
20054	6	4	201
20055	6	5	201
20056	6	6	201
20057	6	7	201
20058	6	8	201
20059	6	9	201
20060	6	10	201
20061	7	1	201
20062	7	2	201
20063	7	3	201
20064	7	4	201
20065	7	5	201
20066	7	6	201
20067	7	7	201
20068	7	8	201
20069	7	9	201
20070	7	10	201
20071	8	1	201
20072	8	2	201
20073	8	3	201
20074	8	4	201
20075	8	5	201
20076	8	6	201
20077	8	7	201
20078	8	8	201
20079	8	9	201
20080	8	10	201
20081	9	1	201
20082	9	2	201
20083	9	3	201
20084	9	4	201
20085	9	5	201
20086	9	6	201
20087	9	7	201
20088	9	8	201
20089	9	9	201
20090	9	10	201
20091	10	1	201
20092	10	2	201
20093	10	3	201
20094	10	4	201
20095	10	5	201
20096	10	6	201
20097	10	7	201
20098	10	8	201
20099	10	9	201
20100	10	10	201
20101	1	1	202
20102	1	2	202
20103	1	3	202
20104	1	4	202
20105	1	5	202
20106	1	6	202
20107	1	7	202
20108	1	8	202
20109	1	9	202
20110	1	10	202
20111	2	1	202
20112	2	2	202
20113	2	3	202
20114	2	4	202
20115	2	5	202
20116	2	6	202
20117	2	7	202
20118	2	8	202
20119	2	9	202
20120	2	10	202
20121	3	1	202
20122	3	2	202
20123	3	3	202
20124	3	4	202
20125	3	5	202
20126	3	6	202
20127	3	7	202
20128	3	8	202
20129	3	9	202
20130	3	10	202
20131	4	1	202
20132	4	2	202
20133	4	3	202
20134	4	4	202
20135	4	5	202
20136	4	6	202
20137	4	7	202
20138	4	8	202
20139	4	9	202
20140	4	10	202
20141	5	1	202
20142	5	2	202
20143	5	3	202
20144	5	4	202
20145	5	5	202
20146	5	6	202
20147	5	7	202
20148	5	8	202
20149	5	9	202
20150	5	10	202
20151	6	1	202
20152	6	2	202
20153	6	3	202
20154	6	4	202
20155	6	5	202
20156	6	6	202
20157	6	7	202
20158	6	8	202
20159	6	9	202
20160	6	10	202
20161	7	1	202
20162	7	2	202
20163	7	3	202
20164	7	4	202
20165	7	5	202
20166	7	6	202
20167	7	7	202
20168	7	8	202
20169	7	9	202
20170	7	10	202
20171	8	1	202
20172	8	2	202
20173	8	3	202
20174	8	4	202
20175	8	5	202
20176	8	6	202
20177	8	7	202
20178	8	8	202
20179	8	9	202
20180	8	10	202
20181	9	1	202
20182	9	2	202
20183	9	3	202
20184	9	4	202
20185	9	5	202
20186	9	6	202
20187	9	7	202
20188	9	8	202
20189	9	9	202
20190	9	10	202
20191	10	1	202
20192	10	2	202
20193	10	3	202
20194	10	4	202
20195	10	5	202
20196	10	6	202
20197	10	7	202
20198	10	8	202
20199	10	9	202
20200	10	10	202
20201	1	1	203
20202	1	2	203
20203	1	3	203
20204	1	4	203
20205	1	5	203
20206	1	6	203
20207	1	7	203
20208	1	8	203
20209	1	9	203
20210	1	10	203
20211	2	1	203
20212	2	2	203
20213	2	3	203
20214	2	4	203
20215	2	5	203
20216	2	6	203
20217	2	7	203
20218	2	8	203
20219	2	9	203
20220	2	10	203
20221	3	1	203
20222	3	2	203
20223	3	3	203
20224	3	4	203
20225	3	5	203
20226	3	6	203
20227	3	7	203
20228	3	8	203
20229	3	9	203
20230	3	10	203
20231	4	1	203
20232	4	2	203
20233	4	3	203
20234	4	4	203
20235	4	5	203
20236	4	6	203
20237	4	7	203
20238	4	8	203
20239	4	9	203
20240	4	10	203
20241	5	1	203
20242	5	2	203
20243	5	3	203
20244	5	4	203
20245	5	5	203
20246	5	6	203
20247	5	7	203
20248	5	8	203
20249	5	9	203
20250	5	10	203
20251	6	1	203
20252	6	2	203
20253	6	3	203
20254	6	4	203
20255	6	5	203
20256	6	6	203
20257	6	7	203
20258	6	8	203
20259	6	9	203
20260	6	10	203
20261	7	1	203
20262	7	2	203
20263	7	3	203
20264	7	4	203
20265	7	5	203
20266	7	6	203
20267	7	7	203
20268	7	8	203
20269	7	9	203
20270	7	10	203
20271	8	1	203
20272	8	2	203
20273	8	3	203
20274	8	4	203
20275	8	5	203
20276	8	6	203
20277	8	7	203
20278	8	8	203
20279	8	9	203
20280	8	10	203
20281	9	1	203
20282	9	2	203
20283	9	3	203
20284	9	4	203
20285	9	5	203
20286	9	6	203
20287	9	7	203
20288	9	8	203
20289	9	9	203
20290	9	10	203
20291	10	1	203
20292	10	2	203
20293	10	3	203
20294	10	4	203
20295	10	5	203
20296	10	6	203
20297	10	7	203
20298	10	8	203
20299	10	9	203
20300	10	10	203
20301	1	1	204
20302	1	2	204
20303	1	3	204
20304	1	4	204
20305	1	5	204
20306	1	6	204
20307	1	7	204
20308	1	8	204
20309	1	9	204
20310	1	10	204
20311	2	1	204
20312	2	2	204
20313	2	3	204
20314	2	4	204
20315	2	5	204
20316	2	6	204
20317	2	7	204
20318	2	8	204
20319	2	9	204
20320	2	10	204
20321	3	1	204
20322	3	2	204
20323	3	3	204
20324	3	4	204
20325	3	5	204
20326	3	6	204
20327	3	7	204
20328	3	8	204
20329	3	9	204
20330	3	10	204
20331	4	1	204
20332	4	2	204
20333	4	3	204
20334	4	4	204
20335	4	5	204
20336	4	6	204
20337	4	7	204
20338	4	8	204
20339	4	9	204
20340	4	10	204
20341	5	1	204
20342	5	2	204
20343	5	3	204
20344	5	4	204
20345	5	5	204
20346	5	6	204
20347	5	7	204
20348	5	8	204
20349	5	9	204
20350	5	10	204
20351	6	1	204
20352	6	2	204
20353	6	3	204
20354	6	4	204
20355	6	5	204
20356	6	6	204
20357	6	7	204
20358	6	8	204
20359	6	9	204
20360	6	10	204
20361	7	1	204
20362	7	2	204
20363	7	3	204
20364	7	4	204
20365	7	5	204
20366	7	6	204
20367	7	7	204
20368	7	8	204
20369	7	9	204
20370	7	10	204
20371	8	1	204
20372	8	2	204
20373	8	3	204
20374	8	4	204
20375	8	5	204
20376	8	6	204
20377	8	7	204
20378	8	8	204
20379	8	9	204
20380	8	10	204
20381	9	1	204
20382	9	2	204
20383	9	3	204
20384	9	4	204
20385	9	5	204
20386	9	6	204
20387	9	7	204
20388	9	8	204
20389	9	9	204
20390	9	10	204
20391	10	1	204
20392	10	2	204
20393	10	3	204
20394	10	4	204
20395	10	5	204
20396	10	6	204
20397	10	7	204
20398	10	8	204
20399	10	9	204
20400	10	10	204
20401	1	1	205
20402	1	2	205
20403	1	3	205
20404	1	4	205
20405	1	5	205
20406	1	6	205
20407	1	7	205
20408	1	8	205
20409	1	9	205
20410	1	10	205
20411	2	1	205
20412	2	2	205
20413	2	3	205
20414	2	4	205
20415	2	5	205
20416	2	6	205
20417	2	7	205
20418	2	8	205
20419	2	9	205
20420	2	10	205
20421	3	1	205
20422	3	2	205
20423	3	3	205
20424	3	4	205
20425	3	5	205
20426	3	6	205
20427	3	7	205
20428	3	8	205
20429	3	9	205
20430	3	10	205
20431	4	1	205
20432	4	2	205
20433	4	3	205
20434	4	4	205
20435	4	5	205
20436	4	6	205
20437	4	7	205
20438	4	8	205
20439	4	9	205
20440	4	10	205
20441	5	1	205
20442	5	2	205
20443	5	3	205
20444	5	4	205
20445	5	5	205
20446	5	6	205
20447	5	7	205
20448	5	8	205
20449	5	9	205
20450	5	10	205
20451	6	1	205
20452	6	2	205
20453	6	3	205
20454	6	4	205
20455	6	5	205
20456	6	6	205
20457	6	7	205
20458	6	8	205
20459	6	9	205
20460	6	10	205
20461	7	1	205
20462	7	2	205
20463	7	3	205
20464	7	4	205
20465	7	5	205
20466	7	6	205
20467	7	7	205
20468	7	8	205
20469	7	9	205
20470	7	10	205
20471	8	1	205
20472	8	2	205
20473	8	3	205
20474	8	4	205
20475	8	5	205
20476	8	6	205
20477	8	7	205
20478	8	8	205
20479	8	9	205
20480	8	10	205
20481	9	1	205
20482	9	2	205
20483	9	3	205
20484	9	4	205
20485	9	5	205
20486	9	6	205
20487	9	7	205
20488	9	8	205
20489	9	9	205
20490	9	10	205
20491	10	1	205
20492	10	2	205
20493	10	3	205
20494	10	4	205
20495	10	5	205
20496	10	6	205
20497	10	7	205
20498	10	8	205
20499	10	9	205
20500	10	10	205
20501	1	1	206
20502	1	2	206
20503	1	3	206
20504	1	4	206
20505	1	5	206
20506	1	6	206
20507	1	7	206
20508	1	8	206
20509	1	9	206
20510	1	10	206
20511	2	1	206
20512	2	2	206
20513	2	3	206
20514	2	4	206
20515	2	5	206
20516	2	6	206
20517	2	7	206
20518	2	8	206
20519	2	9	206
20520	2	10	206
20521	3	1	206
20522	3	2	206
20523	3	3	206
20524	3	4	206
20525	3	5	206
20526	3	6	206
20527	3	7	206
20528	3	8	206
20529	3	9	206
20530	3	10	206
20531	4	1	206
20532	4	2	206
20533	4	3	206
20534	4	4	206
20535	4	5	206
20536	4	6	206
20537	4	7	206
20538	4	8	206
20539	4	9	206
20540	4	10	206
20541	5	1	206
20542	5	2	206
20543	5	3	206
20544	5	4	206
20545	5	5	206
20546	5	6	206
20547	5	7	206
20548	5	8	206
20549	5	9	206
20550	5	10	206
20551	6	1	206
20552	6	2	206
20553	6	3	206
20554	6	4	206
20555	6	5	206
20556	6	6	206
20557	6	7	206
20558	6	8	206
20559	6	9	206
20560	6	10	206
20561	7	1	206
20562	7	2	206
20563	7	3	206
20564	7	4	206
20565	7	5	206
20566	7	6	206
20567	7	7	206
20568	7	8	206
20569	7	9	206
20570	7	10	206
20571	8	1	206
20572	8	2	206
20573	8	3	206
20574	8	4	206
20575	8	5	206
20576	8	6	206
20577	8	7	206
20578	8	8	206
20579	8	9	206
20580	8	10	206
20581	9	1	206
20582	9	2	206
20583	9	3	206
20584	9	4	206
20585	9	5	206
20586	9	6	206
20587	9	7	206
20588	9	8	206
20589	9	9	206
20590	9	10	206
20591	10	1	206
20592	10	2	206
20593	10	3	206
20594	10	4	206
20595	10	5	206
20596	10	6	206
20597	10	7	206
20598	10	8	206
20599	10	9	206
20600	10	10	206
20601	1	1	207
20602	1	2	207
20603	1	3	207
20604	1	4	207
20605	1	5	207
20606	1	6	207
20607	1	7	207
20608	1	8	207
20609	1	9	207
20610	1	10	207
20611	2	1	207
20612	2	2	207
20613	2	3	207
20614	2	4	207
20615	2	5	207
20616	2	6	207
20617	2	7	207
20618	2	8	207
20619	2	9	207
20620	2	10	207
20621	3	1	207
20622	3	2	207
20623	3	3	207
20624	3	4	207
20625	3	5	207
20626	3	6	207
20627	3	7	207
20628	3	8	207
20629	3	9	207
20630	3	10	207
20631	4	1	207
20632	4	2	207
20633	4	3	207
20634	4	4	207
20635	4	5	207
20636	4	6	207
20637	4	7	207
20638	4	8	207
20639	4	9	207
20640	4	10	207
20641	5	1	207
20642	5	2	207
20643	5	3	207
20644	5	4	207
20645	5	5	207
20646	5	6	207
20647	5	7	207
20648	5	8	207
20649	5	9	207
20650	5	10	207
20651	6	1	207
20652	6	2	207
20653	6	3	207
20654	6	4	207
20655	6	5	207
20656	6	6	207
20657	6	7	207
20658	6	8	207
20659	6	9	207
20660	6	10	207
20661	7	1	207
20662	7	2	207
20663	7	3	207
20664	7	4	207
20665	7	5	207
20666	7	6	207
20667	7	7	207
20668	7	8	207
20669	7	9	207
20670	7	10	207
20671	8	1	207
20672	8	2	207
20673	8	3	207
20674	8	4	207
20675	8	5	207
20676	8	6	207
20677	8	7	207
20678	8	8	207
20679	8	9	207
20680	8	10	207
20681	9	1	207
20682	9	2	207
20683	9	3	207
20684	9	4	207
20685	9	5	207
20686	9	6	207
20687	9	7	207
20688	9	8	207
20689	9	9	207
20690	9	10	207
20691	10	1	207
20692	10	2	207
20693	10	3	207
20694	10	4	207
20695	10	5	207
20696	10	6	207
20697	10	7	207
20698	10	8	207
20699	10	9	207
20700	10	10	207
20701	1	1	208
20702	1	2	208
20703	1	3	208
20704	1	4	208
20705	1	5	208
20706	1	6	208
20707	1	7	208
20708	1	8	208
20709	1	9	208
20710	1	10	208
20711	2	1	208
20712	2	2	208
20713	2	3	208
20714	2	4	208
20715	2	5	208
20716	2	6	208
20717	2	7	208
20718	2	8	208
20719	2	9	208
20720	2	10	208
20721	3	1	208
20722	3	2	208
20723	3	3	208
20724	3	4	208
20725	3	5	208
20726	3	6	208
20727	3	7	208
20728	3	8	208
20729	3	9	208
20730	3	10	208
20731	4	1	208
20732	4	2	208
20733	4	3	208
20734	4	4	208
20735	4	5	208
20736	4	6	208
20737	4	7	208
20738	4	8	208
20739	4	9	208
20740	4	10	208
20741	5	1	208
20742	5	2	208
20743	5	3	208
20744	5	4	208
20745	5	5	208
20746	5	6	208
20747	5	7	208
20748	5	8	208
20749	5	9	208
20750	5	10	208
20751	6	1	208
20752	6	2	208
20753	6	3	208
20754	6	4	208
20755	6	5	208
20756	6	6	208
20757	6	7	208
20758	6	8	208
20759	6	9	208
20760	6	10	208
20761	7	1	208
20762	7	2	208
20763	7	3	208
20764	7	4	208
20765	7	5	208
20766	7	6	208
20767	7	7	208
20768	7	8	208
20769	7	9	208
20770	7	10	208
20771	8	1	208
20772	8	2	208
20773	8	3	208
20774	8	4	208
20775	8	5	208
20776	8	6	208
20777	8	7	208
20778	8	8	208
20779	8	9	208
20780	8	10	208
20781	9	1	208
20782	9	2	208
20783	9	3	208
20784	9	4	208
20785	9	5	208
20786	9	6	208
20787	9	7	208
20788	9	8	208
20789	9	9	208
20790	9	10	208
20791	10	1	208
20792	10	2	208
20793	10	3	208
20794	10	4	208
20795	10	5	208
20796	10	6	208
20797	10	7	208
20798	10	8	208
20799	10	9	208
20800	10	10	208
20801	1	1	209
20802	1	2	209
20803	1	3	209
20804	1	4	209
20805	1	5	209
20806	1	6	209
20807	1	7	209
20808	1	8	209
20809	1	9	209
20810	1	10	209
20811	2	1	209
20812	2	2	209
20813	2	3	209
20814	2	4	209
20815	2	5	209
20816	2	6	209
20817	2	7	209
20818	2	8	209
20819	2	9	209
20820	2	10	209
20821	3	1	209
20822	3	2	209
20823	3	3	209
20824	3	4	209
20825	3	5	209
20826	3	6	209
20827	3	7	209
20828	3	8	209
20829	3	9	209
20830	3	10	209
20831	4	1	209
20832	4	2	209
20833	4	3	209
20834	4	4	209
20835	4	5	209
20836	4	6	209
20837	4	7	209
20838	4	8	209
20839	4	9	209
20840	4	10	209
20841	5	1	209
20842	5	2	209
20843	5	3	209
20844	5	4	209
20845	5	5	209
20846	5	6	209
20847	5	7	209
20848	5	8	209
20849	5	9	209
20850	5	10	209
20851	6	1	209
20852	6	2	209
20853	6	3	209
20854	6	4	209
20855	6	5	209
20856	6	6	209
20857	6	7	209
20858	6	8	209
20859	6	9	209
20860	6	10	209
20861	7	1	209
20862	7	2	209
20863	7	3	209
20864	7	4	209
20865	7	5	209
20866	7	6	209
20867	7	7	209
20868	7	8	209
20869	7	9	209
20870	7	10	209
20871	8	1	209
20872	8	2	209
20873	8	3	209
20874	8	4	209
20875	8	5	209
20876	8	6	209
20877	8	7	209
20878	8	8	209
20879	8	9	209
20880	8	10	209
20881	9	1	209
20882	9	2	209
20883	9	3	209
20884	9	4	209
20885	9	5	209
20886	9	6	209
20887	9	7	209
20888	9	8	209
20889	9	9	209
20890	9	10	209
20891	10	1	209
20892	10	2	209
20893	10	3	209
20894	10	4	209
20895	10	5	209
20896	10	6	209
20897	10	7	209
20898	10	8	209
20899	10	9	209
20900	10	10	209
20901	1	1	210
20902	1	2	210
20903	1	3	210
20904	1	4	210
20905	1	5	210
20906	1	6	210
20907	1	7	210
20908	1	8	210
20909	1	9	210
20910	1	10	210
20911	2	1	210
20912	2	2	210
20913	2	3	210
20914	2	4	210
20915	2	5	210
20916	2	6	210
20917	2	7	210
20918	2	8	210
20919	2	9	210
20920	2	10	210
20921	3	1	210
20922	3	2	210
20923	3	3	210
20924	3	4	210
20925	3	5	210
20926	3	6	210
20927	3	7	210
20928	3	8	210
20929	3	9	210
20930	3	10	210
20931	4	1	210
20932	4	2	210
20933	4	3	210
20934	4	4	210
20935	4	5	210
20936	4	6	210
20937	4	7	210
20938	4	8	210
20939	4	9	210
20940	4	10	210
20941	5	1	210
20942	5	2	210
20943	5	3	210
20944	5	4	210
20945	5	5	210
20946	5	6	210
20947	5	7	210
20948	5	8	210
20949	5	9	210
20950	5	10	210
20951	6	1	210
20952	6	2	210
20953	6	3	210
20954	6	4	210
20955	6	5	210
20956	6	6	210
20957	6	7	210
20958	6	8	210
20959	6	9	210
20960	6	10	210
20961	7	1	210
20962	7	2	210
20963	7	3	210
20964	7	4	210
20965	7	5	210
20966	7	6	210
20967	7	7	210
20968	7	8	210
20969	7	9	210
20970	7	10	210
20971	8	1	210
20972	8	2	210
20973	8	3	210
20974	8	4	210
20975	8	5	210
20976	8	6	210
20977	8	7	210
20978	8	8	210
20979	8	9	210
20980	8	10	210
20981	9	1	210
20982	9	2	210
20983	9	3	210
20984	9	4	210
20985	9	5	210
20986	9	6	210
20987	9	7	210
20988	9	8	210
20989	9	9	210
20990	9	10	210
20991	10	1	210
20992	10	2	210
20993	10	3	210
20994	10	4	210
20995	10	5	210
20996	10	6	210
20997	10	7	210
20998	10	8	210
20999	10	9	210
21000	10	10	210
21001	1	1	211
21002	1	2	211
21003	1	3	211
21004	1	4	211
21005	1	5	211
21006	1	6	211
21007	1	7	211
21008	1	8	211
21009	1	9	211
21010	1	10	211
21011	2	1	211
21012	2	2	211
21013	2	3	211
21014	2	4	211
21015	2	5	211
21016	2	6	211
21017	2	7	211
21018	2	8	211
21019	2	9	211
21020	2	10	211
21021	3	1	211
21022	3	2	211
21023	3	3	211
21024	3	4	211
21025	3	5	211
21026	3	6	211
21027	3	7	211
21028	3	8	211
21029	3	9	211
21030	3	10	211
21031	4	1	211
21032	4	2	211
21033	4	3	211
21034	4	4	211
21035	4	5	211
21036	4	6	211
21037	4	7	211
21038	4	8	211
21039	4	9	211
21040	4	10	211
21041	5	1	211
21042	5	2	211
21043	5	3	211
21044	5	4	211
21045	5	5	211
21046	5	6	211
21047	5	7	211
21048	5	8	211
21049	5	9	211
21050	5	10	211
21051	6	1	211
21052	6	2	211
21053	6	3	211
21054	6	4	211
21055	6	5	211
21056	6	6	211
21057	6	7	211
21058	6	8	211
21059	6	9	211
21060	6	10	211
21061	7	1	211
21062	7	2	211
21063	7	3	211
21064	7	4	211
21065	7	5	211
21066	7	6	211
21067	7	7	211
21068	7	8	211
21069	7	9	211
21070	7	10	211
21071	8	1	211
21072	8	2	211
21073	8	3	211
21074	8	4	211
21075	8	5	211
21076	8	6	211
21077	8	7	211
21078	8	8	211
21079	8	9	211
21080	8	10	211
21081	9	1	211
21082	9	2	211
21083	9	3	211
21084	9	4	211
21085	9	5	211
21086	9	6	211
21087	9	7	211
21088	9	8	211
21089	9	9	211
21090	9	10	211
21091	10	1	211
21092	10	2	211
21093	10	3	211
21094	10	4	211
21095	10	5	211
21096	10	6	211
21097	10	7	211
21098	10	8	211
21099	10	9	211
21100	10	10	211
21101	1	1	212
21102	1	2	212
21103	1	3	212
21104	1	4	212
21105	1	5	212
21106	1	6	212
21107	1	7	212
21108	1	8	212
21109	1	9	212
21110	1	10	212
21111	2	1	212
21112	2	2	212
21113	2	3	212
21114	2	4	212
21115	2	5	212
21116	2	6	212
21117	2	7	212
21118	2	8	212
21119	2	9	212
21120	2	10	212
21121	3	1	212
21122	3	2	212
21123	3	3	212
21124	3	4	212
21125	3	5	212
21126	3	6	212
21127	3	7	212
21128	3	8	212
21129	3	9	212
21130	3	10	212
21131	4	1	212
21132	4	2	212
21133	4	3	212
21134	4	4	212
21135	4	5	212
21136	4	6	212
21137	4	7	212
21138	4	8	212
21139	4	9	212
21140	4	10	212
21141	5	1	212
21142	5	2	212
21143	5	3	212
21144	5	4	212
21145	5	5	212
21146	5	6	212
21147	5	7	212
21148	5	8	212
21149	5	9	212
21150	5	10	212
21151	6	1	212
21152	6	2	212
21153	6	3	212
21154	6	4	212
21155	6	5	212
21156	6	6	212
21157	6	7	212
21158	6	8	212
21159	6	9	212
21160	6	10	212
21161	7	1	212
21162	7	2	212
21163	7	3	212
21164	7	4	212
21165	7	5	212
21166	7	6	212
21167	7	7	212
21168	7	8	212
21169	7	9	212
21170	7	10	212
21171	8	1	212
21172	8	2	212
21173	8	3	212
21174	8	4	212
21175	8	5	212
21176	8	6	212
21177	8	7	212
21178	8	8	212
21179	8	9	212
21180	8	10	212
21181	9	1	212
21182	9	2	212
21183	9	3	212
21184	9	4	212
21185	9	5	212
21186	9	6	212
21187	9	7	212
21188	9	8	212
21189	9	9	212
21190	9	10	212
21191	10	1	212
21192	10	2	212
21193	10	3	212
21194	10	4	212
21195	10	5	212
21196	10	6	212
21197	10	7	212
21198	10	8	212
21199	10	9	212
21200	10	10	212
21201	1	1	213
21202	1	2	213
21203	1	3	213
21204	1	4	213
21205	1	5	213
21206	1	6	213
21207	1	7	213
21208	1	8	213
21209	1	9	213
21210	1	10	213
21211	2	1	213
21212	2	2	213
21213	2	3	213
21214	2	4	213
21215	2	5	213
21216	2	6	213
21217	2	7	213
21218	2	8	213
21219	2	9	213
21220	2	10	213
21221	3	1	213
21222	3	2	213
21223	3	3	213
21224	3	4	213
21225	3	5	213
21226	3	6	213
21227	3	7	213
21228	3	8	213
21229	3	9	213
21230	3	10	213
21231	4	1	213
21232	4	2	213
21233	4	3	213
21234	4	4	213
21235	4	5	213
21236	4	6	213
21237	4	7	213
21238	4	8	213
21239	4	9	213
21240	4	10	213
21241	5	1	213
21242	5	2	213
21243	5	3	213
21244	5	4	213
21245	5	5	213
21246	5	6	213
21247	5	7	213
21248	5	8	213
21249	5	9	213
21250	5	10	213
21251	6	1	213
21252	6	2	213
21253	6	3	213
21254	6	4	213
21255	6	5	213
21256	6	6	213
21257	6	7	213
21258	6	8	213
21259	6	9	213
21260	6	10	213
21261	7	1	213
21262	7	2	213
21263	7	3	213
21264	7	4	213
21265	7	5	213
21266	7	6	213
21267	7	7	213
21268	7	8	213
21269	7	9	213
21270	7	10	213
21271	8	1	213
21272	8	2	213
21273	8	3	213
21274	8	4	213
21275	8	5	213
21276	8	6	213
21277	8	7	213
21278	8	8	213
21279	8	9	213
21280	8	10	213
21281	9	1	213
21282	9	2	213
21283	9	3	213
21284	9	4	213
21285	9	5	213
21286	9	6	213
21287	9	7	213
21288	9	8	213
21289	9	9	213
21290	9	10	213
21291	10	1	213
21292	10	2	213
21293	10	3	213
21294	10	4	213
21295	10	5	213
21296	10	6	213
21297	10	7	213
21298	10	8	213
21299	10	9	213
21300	10	10	213
21301	1	1	214
21302	1	2	214
21303	1	3	214
21304	1	4	214
21305	1	5	214
21306	1	6	214
21307	1	7	214
21308	1	8	214
21309	1	9	214
21310	1	10	214
21311	2	1	214
21312	2	2	214
21313	2	3	214
21314	2	4	214
21315	2	5	214
21316	2	6	214
21317	2	7	214
21318	2	8	214
21319	2	9	214
21320	2	10	214
21321	3	1	214
21322	3	2	214
21323	3	3	214
21324	3	4	214
21325	3	5	214
21326	3	6	214
21327	3	7	214
21328	3	8	214
21329	3	9	214
21330	3	10	214
21331	4	1	214
21332	4	2	214
21333	4	3	214
21334	4	4	214
21335	4	5	214
21336	4	6	214
21337	4	7	214
21338	4	8	214
21339	4	9	214
21340	4	10	214
21341	5	1	214
21342	5	2	214
21343	5	3	214
21344	5	4	214
21345	5	5	214
21346	5	6	214
21347	5	7	214
21348	5	8	214
21349	5	9	214
21350	5	10	214
21351	6	1	214
21352	6	2	214
21353	6	3	214
21354	6	4	214
21355	6	5	214
21356	6	6	214
21357	6	7	214
21358	6	8	214
21359	6	9	214
21360	6	10	214
21361	7	1	214
21362	7	2	214
21363	7	3	214
21364	7	4	214
21365	7	5	214
21366	7	6	214
21367	7	7	214
21368	7	8	214
21369	7	9	214
21370	7	10	214
21371	8	1	214
21372	8	2	214
21373	8	3	214
21374	8	4	214
21375	8	5	214
21376	8	6	214
21377	8	7	214
21378	8	8	214
21379	8	9	214
21380	8	10	214
21381	9	1	214
21382	9	2	214
21383	9	3	214
21384	9	4	214
21385	9	5	214
21386	9	6	214
21387	9	7	214
21388	9	8	214
21389	9	9	214
21390	9	10	214
21391	10	1	214
21392	10	2	214
21393	10	3	214
21394	10	4	214
21395	10	5	214
21396	10	6	214
21397	10	7	214
21398	10	8	214
21399	10	9	214
21400	10	10	214
21401	1	1	215
21402	1	2	215
21403	1	3	215
21404	1	4	215
21405	1	5	215
21406	1	6	215
21407	1	7	215
21408	1	8	215
21409	1	9	215
21410	1	10	215
21411	2	1	215
21412	2	2	215
21413	2	3	215
21414	2	4	215
21415	2	5	215
21416	2	6	215
21417	2	7	215
21418	2	8	215
21419	2	9	215
21420	2	10	215
21421	3	1	215
21422	3	2	215
21423	3	3	215
21424	3	4	215
21425	3	5	215
21426	3	6	215
21427	3	7	215
21428	3	8	215
21429	3	9	215
21430	3	10	215
21431	4	1	215
21432	4	2	215
21433	4	3	215
21434	4	4	215
21435	4	5	215
21436	4	6	215
21437	4	7	215
21438	4	8	215
21439	4	9	215
21440	4	10	215
21441	5	1	215
21442	5	2	215
21443	5	3	215
21444	5	4	215
21445	5	5	215
21446	5	6	215
21447	5	7	215
21448	5	8	215
21449	5	9	215
21450	5	10	215
21451	6	1	215
21452	6	2	215
21453	6	3	215
21454	6	4	215
21455	6	5	215
21456	6	6	215
21457	6	7	215
21458	6	8	215
21459	6	9	215
21460	6	10	215
21461	7	1	215
21462	7	2	215
21463	7	3	215
21464	7	4	215
21465	7	5	215
21466	7	6	215
21467	7	7	215
21468	7	8	215
21469	7	9	215
21470	7	10	215
21471	8	1	215
21472	8	2	215
21473	8	3	215
21474	8	4	215
21475	8	5	215
21476	8	6	215
21477	8	7	215
21478	8	8	215
21479	8	9	215
21480	8	10	215
21481	9	1	215
21482	9	2	215
21483	9	3	215
21484	9	4	215
21485	9	5	215
21486	9	6	215
21487	9	7	215
21488	9	8	215
21489	9	9	215
21490	9	10	215
21491	10	1	215
21492	10	2	215
21493	10	3	215
21494	10	4	215
21495	10	5	215
21496	10	6	215
21497	10	7	215
21498	10	8	215
21499	10	9	215
21500	10	10	215
21501	1	1	216
21502	1	2	216
21503	1	3	216
21504	1	4	216
21505	1	5	216
21506	1	6	216
21507	1	7	216
21508	1	8	216
21509	1	9	216
21510	1	10	216
21511	2	1	216
21512	2	2	216
21513	2	3	216
21514	2	4	216
21515	2	5	216
21516	2	6	216
21517	2	7	216
21518	2	8	216
21519	2	9	216
21520	2	10	216
21521	3	1	216
21522	3	2	216
21523	3	3	216
21524	3	4	216
21525	3	5	216
21526	3	6	216
21527	3	7	216
21528	3	8	216
21529	3	9	216
21530	3	10	216
21531	4	1	216
21532	4	2	216
21533	4	3	216
21534	4	4	216
21535	4	5	216
21536	4	6	216
21537	4	7	216
21538	4	8	216
21539	4	9	216
21540	4	10	216
21541	5	1	216
21542	5	2	216
21543	5	3	216
21544	5	4	216
21545	5	5	216
21546	5	6	216
21547	5	7	216
21548	5	8	216
21549	5	9	216
21550	5	10	216
21551	6	1	216
21552	6	2	216
21553	6	3	216
21554	6	4	216
21555	6	5	216
21556	6	6	216
21557	6	7	216
21558	6	8	216
21559	6	9	216
21560	6	10	216
21561	7	1	216
21562	7	2	216
21563	7	3	216
21564	7	4	216
21565	7	5	216
21566	7	6	216
21567	7	7	216
21568	7	8	216
21569	7	9	216
21570	7	10	216
21571	8	1	216
21572	8	2	216
21573	8	3	216
21574	8	4	216
21575	8	5	216
21576	8	6	216
21577	8	7	216
21578	8	8	216
21579	8	9	216
21580	8	10	216
21581	9	1	216
21582	9	2	216
21583	9	3	216
21584	9	4	216
21585	9	5	216
21586	9	6	216
21587	9	7	216
21588	9	8	216
21589	9	9	216
21590	9	10	216
21591	10	1	216
21592	10	2	216
21593	10	3	216
21594	10	4	216
21595	10	5	216
21596	10	6	216
21597	10	7	216
21598	10	8	216
21599	10	9	216
21600	10	10	216
21601	1	1	217
21602	1	2	217
21603	1	3	217
21604	1	4	217
21605	1	5	217
21606	1	6	217
21607	1	7	217
21608	1	8	217
21609	1	9	217
21610	1	10	217
21611	2	1	217
21612	2	2	217
21613	2	3	217
21614	2	4	217
21615	2	5	217
21616	2	6	217
21617	2	7	217
21618	2	8	217
21619	2	9	217
21620	2	10	217
21621	3	1	217
21622	3	2	217
21623	3	3	217
21624	3	4	217
21625	3	5	217
21626	3	6	217
21627	3	7	217
21628	3	8	217
21629	3	9	217
21630	3	10	217
21631	4	1	217
21632	4	2	217
21633	4	3	217
21634	4	4	217
21635	4	5	217
21636	4	6	217
21637	4	7	217
21638	4	8	217
21639	4	9	217
21640	4	10	217
21641	5	1	217
21642	5	2	217
21643	5	3	217
21644	5	4	217
21645	5	5	217
21646	5	6	217
21647	5	7	217
21648	5	8	217
21649	5	9	217
21650	5	10	217
21651	6	1	217
21652	6	2	217
21653	6	3	217
21654	6	4	217
21655	6	5	217
21656	6	6	217
21657	6	7	217
21658	6	8	217
21659	6	9	217
21660	6	10	217
21661	7	1	217
21662	7	2	217
21663	7	3	217
21664	7	4	217
21665	7	5	217
21666	7	6	217
21667	7	7	217
21668	7	8	217
21669	7	9	217
21670	7	10	217
21671	8	1	217
21672	8	2	217
21673	8	3	217
21674	8	4	217
21675	8	5	217
21676	8	6	217
21677	8	7	217
21678	8	8	217
21679	8	9	217
21680	8	10	217
21681	9	1	217
21682	9	2	217
21683	9	3	217
21684	9	4	217
21685	9	5	217
21686	9	6	217
21687	9	7	217
21688	9	8	217
21689	9	9	217
21690	9	10	217
21691	10	1	217
21692	10	2	217
21693	10	3	217
21694	10	4	217
21695	10	5	217
21696	10	6	217
21697	10	7	217
21698	10	8	217
21699	10	9	217
21700	10	10	217
21701	1	1	218
21702	1	2	218
21703	1	3	218
21704	1	4	218
21705	1	5	218
21706	1	6	218
21707	1	7	218
21708	1	8	218
21709	1	9	218
21710	1	10	218
21711	2	1	218
21712	2	2	218
21713	2	3	218
21714	2	4	218
21715	2	5	218
21716	2	6	218
21717	2	7	218
21718	2	8	218
21719	2	9	218
21720	2	10	218
21721	3	1	218
21722	3	2	218
21723	3	3	218
21724	3	4	218
21725	3	5	218
21726	3	6	218
21727	3	7	218
21728	3	8	218
21729	3	9	218
21730	3	10	218
21731	4	1	218
21732	4	2	218
21733	4	3	218
21734	4	4	218
21735	4	5	218
21736	4	6	218
21737	4	7	218
21738	4	8	218
21739	4	9	218
21740	4	10	218
21741	5	1	218
21742	5	2	218
21743	5	3	218
21744	5	4	218
21745	5	5	218
21746	5	6	218
21747	5	7	218
21748	5	8	218
21749	5	9	218
21750	5	10	218
21751	6	1	218
21752	6	2	218
21753	6	3	218
21754	6	4	218
21755	6	5	218
21756	6	6	218
21757	6	7	218
21758	6	8	218
21759	6	9	218
21760	6	10	218
21761	7	1	218
21762	7	2	218
21763	7	3	218
21764	7	4	218
21765	7	5	218
21766	7	6	218
21767	7	7	218
21768	7	8	218
21769	7	9	218
21770	7	10	218
21771	8	1	218
21772	8	2	218
21773	8	3	218
21774	8	4	218
21775	8	5	218
21776	8	6	218
21777	8	7	218
21778	8	8	218
21779	8	9	218
21780	8	10	218
21781	9	1	218
21782	9	2	218
21783	9	3	218
21784	9	4	218
21785	9	5	218
21786	9	6	218
21787	9	7	218
21788	9	8	218
21789	9	9	218
21790	9	10	218
21791	10	1	218
21792	10	2	218
21793	10	3	218
21794	10	4	218
21795	10	5	218
21796	10	6	218
21797	10	7	218
21798	10	8	218
21799	10	9	218
21800	10	10	218
21801	1	1	219
21802	1	2	219
21803	1	3	219
21804	1	4	219
21805	1	5	219
21806	1	6	219
21807	1	7	219
21808	1	8	219
21809	1	9	219
21810	1	10	219
21811	2	1	219
21812	2	2	219
21813	2	3	219
21814	2	4	219
21815	2	5	219
21816	2	6	219
21817	2	7	219
21818	2	8	219
21819	2	9	219
21820	2	10	219
21821	3	1	219
21822	3	2	219
21823	3	3	219
21824	3	4	219
21825	3	5	219
21826	3	6	219
21827	3	7	219
21828	3	8	219
21829	3	9	219
21830	3	10	219
21831	4	1	219
21832	4	2	219
21833	4	3	219
21834	4	4	219
21835	4	5	219
21836	4	6	219
21837	4	7	219
21838	4	8	219
21839	4	9	219
21840	4	10	219
21841	5	1	219
21842	5	2	219
21843	5	3	219
21844	5	4	219
21845	5	5	219
21846	5	6	219
21847	5	7	219
21848	5	8	219
21849	5	9	219
21850	5	10	219
21851	6	1	219
21852	6	2	219
21853	6	3	219
21854	6	4	219
21855	6	5	219
21856	6	6	219
21857	6	7	219
21858	6	8	219
21859	6	9	219
21860	6	10	219
21861	7	1	219
21862	7	2	219
21863	7	3	219
21864	7	4	219
21865	7	5	219
21866	7	6	219
21867	7	7	219
21868	7	8	219
21869	7	9	219
21870	7	10	219
21871	8	1	219
21872	8	2	219
21873	8	3	219
21874	8	4	219
21875	8	5	219
21876	8	6	219
21877	8	7	219
21878	8	8	219
21879	8	9	219
21880	8	10	219
21881	9	1	219
21882	9	2	219
21883	9	3	219
21884	9	4	219
21885	9	5	219
21886	9	6	219
21887	9	7	219
21888	9	8	219
21889	9	9	219
21890	9	10	219
21891	10	1	219
21892	10	2	219
21893	10	3	219
21894	10	4	219
21895	10	5	219
21896	10	6	219
21897	10	7	219
21898	10	8	219
21899	10	9	219
21900	10	10	219
21901	1	1	220
21902	1	2	220
21903	1	3	220
21904	1	4	220
21905	1	5	220
21906	1	6	220
21907	1	7	220
21908	1	8	220
21909	1	9	220
21910	1	10	220
21911	2	1	220
21912	2	2	220
21913	2	3	220
21914	2	4	220
21915	2	5	220
21916	2	6	220
21917	2	7	220
21918	2	8	220
21919	2	9	220
21920	2	10	220
21921	3	1	220
21922	3	2	220
21923	3	3	220
21924	3	4	220
21925	3	5	220
21926	3	6	220
21927	3	7	220
21928	3	8	220
21929	3	9	220
21930	3	10	220
21931	4	1	220
21932	4	2	220
21933	4	3	220
21934	4	4	220
21935	4	5	220
21936	4	6	220
21937	4	7	220
21938	4	8	220
21939	4	9	220
21940	4	10	220
21941	5	1	220
21942	5	2	220
21943	5	3	220
21944	5	4	220
21945	5	5	220
21946	5	6	220
21947	5	7	220
21948	5	8	220
21949	5	9	220
21950	5	10	220
21951	6	1	220
21952	6	2	220
21953	6	3	220
21954	6	4	220
21955	6	5	220
21956	6	6	220
21957	6	7	220
21958	6	8	220
21959	6	9	220
21960	6	10	220
21961	7	1	220
21962	7	2	220
21963	7	3	220
21964	7	4	220
21965	7	5	220
21966	7	6	220
21967	7	7	220
21968	7	8	220
21969	7	9	220
21970	7	10	220
21971	8	1	220
21972	8	2	220
21973	8	3	220
21974	8	4	220
21975	8	5	220
21976	8	6	220
21977	8	7	220
21978	8	8	220
21979	8	9	220
21980	8	10	220
21981	9	1	220
21982	9	2	220
21983	9	3	220
21984	9	4	220
21985	9	5	220
21986	9	6	220
21987	9	7	220
21988	9	8	220
21989	9	9	220
21990	9	10	220
21991	10	1	220
21992	10	2	220
21993	10	3	220
21994	10	4	220
21995	10	5	220
21996	10	6	220
21997	10	7	220
21998	10	8	220
21999	10	9	220
22000	10	10	220
22001	1	1	221
22002	1	2	221
22003	1	3	221
22004	1	4	221
22005	1	5	221
22006	1	6	221
22007	1	7	221
22008	1	8	221
22009	1	9	221
22010	1	10	221
22011	2	1	221
22012	2	2	221
22013	2	3	221
22014	2	4	221
22015	2	5	221
22016	2	6	221
22017	2	7	221
22018	2	8	221
22019	2	9	221
22020	2	10	221
22021	3	1	221
22022	3	2	221
22023	3	3	221
22024	3	4	221
22025	3	5	221
22026	3	6	221
22027	3	7	221
22028	3	8	221
22029	3	9	221
22030	3	10	221
22031	4	1	221
22032	4	2	221
22033	4	3	221
22034	4	4	221
22035	4	5	221
22036	4	6	221
22037	4	7	221
22038	4	8	221
22039	4	9	221
22040	4	10	221
22041	5	1	221
22042	5	2	221
22043	5	3	221
22044	5	4	221
22045	5	5	221
22046	5	6	221
22047	5	7	221
22048	5	8	221
22049	5	9	221
22050	5	10	221
22051	6	1	221
22052	6	2	221
22053	6	3	221
22054	6	4	221
22055	6	5	221
22056	6	6	221
22057	6	7	221
22058	6	8	221
22059	6	9	221
22060	6	10	221
22061	7	1	221
22062	7	2	221
22063	7	3	221
22064	7	4	221
22065	7	5	221
22066	7	6	221
22067	7	7	221
22068	7	8	221
22069	7	9	221
22070	7	10	221
22071	8	1	221
22072	8	2	221
22073	8	3	221
22074	8	4	221
22075	8	5	221
22076	8	6	221
22077	8	7	221
22078	8	8	221
22079	8	9	221
22080	8	10	221
22081	9	1	221
22082	9	2	221
22083	9	3	221
22084	9	4	221
22085	9	5	221
22086	9	6	221
22087	9	7	221
22088	9	8	221
22089	9	9	221
22090	9	10	221
22091	10	1	221
22092	10	2	221
22093	10	3	221
22094	10	4	221
22095	10	5	221
22096	10	6	221
22097	10	7	221
22098	10	8	221
22099	10	9	221
22100	10	10	221
22101	1	1	222
22102	1	2	222
22103	1	3	222
22104	1	4	222
22105	1	5	222
22106	1	6	222
22107	1	7	222
22108	1	8	222
22109	1	9	222
22110	1	10	222
22111	2	1	222
22112	2	2	222
22113	2	3	222
22114	2	4	222
22115	2	5	222
22116	2	6	222
22117	2	7	222
22118	2	8	222
22119	2	9	222
22120	2	10	222
22121	3	1	222
22122	3	2	222
22123	3	3	222
22124	3	4	222
22125	3	5	222
22126	3	6	222
22127	3	7	222
22128	3	8	222
22129	3	9	222
22130	3	10	222
22131	4	1	222
22132	4	2	222
22133	4	3	222
22134	4	4	222
22135	4	5	222
22136	4	6	222
22137	4	7	222
22138	4	8	222
22139	4	9	222
22140	4	10	222
22141	5	1	222
22142	5	2	222
22143	5	3	222
22144	5	4	222
22145	5	5	222
22146	5	6	222
22147	5	7	222
22148	5	8	222
22149	5	9	222
22150	5	10	222
22151	6	1	222
22152	6	2	222
22153	6	3	222
22154	6	4	222
22155	6	5	222
22156	6	6	222
22157	6	7	222
22158	6	8	222
22159	6	9	222
22160	6	10	222
22161	7	1	222
22162	7	2	222
22163	7	3	222
22164	7	4	222
22165	7	5	222
22166	7	6	222
22167	7	7	222
22168	7	8	222
22169	7	9	222
22170	7	10	222
22171	8	1	222
22172	8	2	222
22173	8	3	222
22174	8	4	222
22175	8	5	222
22176	8	6	222
22177	8	7	222
22178	8	8	222
22179	8	9	222
22180	8	10	222
22181	9	1	222
22182	9	2	222
22183	9	3	222
22184	9	4	222
22185	9	5	222
22186	9	6	222
22187	9	7	222
22188	9	8	222
22189	9	9	222
22190	9	10	222
22191	10	1	222
22192	10	2	222
22193	10	3	222
22194	10	4	222
22195	10	5	222
22196	10	6	222
22197	10	7	222
22198	10	8	222
22199	10	9	222
22200	10	10	222
22201	1	1	223
22202	1	2	223
22203	1	3	223
22204	1	4	223
22205	1	5	223
22206	1	6	223
22207	1	7	223
22208	1	8	223
22209	1	9	223
22210	1	10	223
22211	2	1	223
22212	2	2	223
22213	2	3	223
22214	2	4	223
22215	2	5	223
22216	2	6	223
22217	2	7	223
22218	2	8	223
22219	2	9	223
22220	2	10	223
22221	3	1	223
22222	3	2	223
22223	3	3	223
22224	3	4	223
22225	3	5	223
22226	3	6	223
22227	3	7	223
22228	3	8	223
22229	3	9	223
22230	3	10	223
22231	4	1	223
22232	4	2	223
22233	4	3	223
22234	4	4	223
22235	4	5	223
22236	4	6	223
22237	4	7	223
22238	4	8	223
22239	4	9	223
22240	4	10	223
22241	5	1	223
22242	5	2	223
22243	5	3	223
22244	5	4	223
22245	5	5	223
22246	5	6	223
22247	5	7	223
22248	5	8	223
22249	5	9	223
22250	5	10	223
22251	6	1	223
22252	6	2	223
22253	6	3	223
22254	6	4	223
22255	6	5	223
22256	6	6	223
22257	6	7	223
22258	6	8	223
22259	6	9	223
22260	6	10	223
22261	7	1	223
22262	7	2	223
22263	7	3	223
22264	7	4	223
22265	7	5	223
22266	7	6	223
22267	7	7	223
22268	7	8	223
22269	7	9	223
22270	7	10	223
22271	8	1	223
22272	8	2	223
22273	8	3	223
22274	8	4	223
22275	8	5	223
22276	8	6	223
22277	8	7	223
22278	8	8	223
22279	8	9	223
22280	8	10	223
22281	9	1	223
22282	9	2	223
22283	9	3	223
22284	9	4	223
22285	9	5	223
22286	9	6	223
22287	9	7	223
22288	9	8	223
22289	9	9	223
22290	9	10	223
22291	10	1	223
22292	10	2	223
22293	10	3	223
22294	10	4	223
22295	10	5	223
22296	10	6	223
22297	10	7	223
22298	10	8	223
22299	10	9	223
22300	10	10	223
22301	1	1	224
22302	1	2	224
22303	1	3	224
22304	1	4	224
22305	1	5	224
22306	1	6	224
22307	1	7	224
22308	1	8	224
22309	1	9	224
22310	1	10	224
22311	2	1	224
22312	2	2	224
22313	2	3	224
22314	2	4	224
22315	2	5	224
22316	2	6	224
22317	2	7	224
22318	2	8	224
22319	2	9	224
22320	2	10	224
22321	3	1	224
22322	3	2	224
22323	3	3	224
22324	3	4	224
22325	3	5	224
22326	3	6	224
22327	3	7	224
22328	3	8	224
22329	3	9	224
22330	3	10	224
22331	4	1	224
22332	4	2	224
22333	4	3	224
22334	4	4	224
22335	4	5	224
22336	4	6	224
22337	4	7	224
22338	4	8	224
22339	4	9	224
22340	4	10	224
22341	5	1	224
22342	5	2	224
22343	5	3	224
22344	5	4	224
22345	5	5	224
22346	5	6	224
22347	5	7	224
22348	5	8	224
22349	5	9	224
22350	5	10	224
22351	6	1	224
22352	6	2	224
22353	6	3	224
22354	6	4	224
22355	6	5	224
22356	6	6	224
22357	6	7	224
22358	6	8	224
22359	6	9	224
22360	6	10	224
22361	7	1	224
22362	7	2	224
22363	7	3	224
22364	7	4	224
22365	7	5	224
22366	7	6	224
22367	7	7	224
22368	7	8	224
22369	7	9	224
22370	7	10	224
22371	8	1	224
22372	8	2	224
22373	8	3	224
22374	8	4	224
22375	8	5	224
22376	8	6	224
22377	8	7	224
22378	8	8	224
22379	8	9	224
22380	8	10	224
22381	9	1	224
22382	9	2	224
22383	9	3	224
22384	9	4	224
22385	9	5	224
22386	9	6	224
22387	9	7	224
22388	9	8	224
22389	9	9	224
22390	9	10	224
22391	10	1	224
22392	10	2	224
22393	10	3	224
22394	10	4	224
22395	10	5	224
22396	10	6	224
22397	10	7	224
22398	10	8	224
22399	10	9	224
22400	10	10	224
22401	1	1	225
22402	1	2	225
22403	1	3	225
22404	1	4	225
22405	1	5	225
22406	1	6	225
22407	1	7	225
22408	1	8	225
22409	1	9	225
22410	1	10	225
22411	2	1	225
22412	2	2	225
22413	2	3	225
22414	2	4	225
22415	2	5	225
22416	2	6	225
22417	2	7	225
22418	2	8	225
22419	2	9	225
22420	2	10	225
22421	3	1	225
22422	3	2	225
22423	3	3	225
22424	3	4	225
22425	3	5	225
22426	3	6	225
22427	3	7	225
22428	3	8	225
22429	3	9	225
22430	3	10	225
22431	4	1	225
22432	4	2	225
22433	4	3	225
22434	4	4	225
22435	4	5	225
22436	4	6	225
22437	4	7	225
22438	4	8	225
22439	4	9	225
22440	4	10	225
22441	5	1	225
22442	5	2	225
22443	5	3	225
22444	5	4	225
22445	5	5	225
22446	5	6	225
22447	5	7	225
22448	5	8	225
22449	5	9	225
22450	5	10	225
22451	6	1	225
22452	6	2	225
22453	6	3	225
22454	6	4	225
22455	6	5	225
22456	6	6	225
22457	6	7	225
22458	6	8	225
22459	6	9	225
22460	6	10	225
22461	7	1	225
22462	7	2	225
22463	7	3	225
22464	7	4	225
22465	7	5	225
22466	7	6	225
22467	7	7	225
22468	7	8	225
22469	7	9	225
22470	7	10	225
22471	8	1	225
22472	8	2	225
22473	8	3	225
22474	8	4	225
22475	8	5	225
22476	8	6	225
22477	8	7	225
22478	8	8	225
22479	8	9	225
22480	8	10	225
22481	9	1	225
22482	9	2	225
22483	9	3	225
22484	9	4	225
22485	9	5	225
22486	9	6	225
22487	9	7	225
22488	9	8	225
22489	9	9	225
22490	9	10	225
22491	10	1	225
22492	10	2	225
22493	10	3	225
22494	10	4	225
22495	10	5	225
22496	10	6	225
22497	10	7	225
22498	10	8	225
22499	10	9	225
22500	10	10	225
22501	1	1	226
22502	1	2	226
22503	1	3	226
22504	1	4	226
22505	1	5	226
22506	1	6	226
22507	1	7	226
22508	1	8	226
22509	1	9	226
22510	1	10	226
22511	2	1	226
22512	2	2	226
22513	2	3	226
22514	2	4	226
22515	2	5	226
22516	2	6	226
22517	2	7	226
22518	2	8	226
22519	2	9	226
22520	2	10	226
22521	3	1	226
22522	3	2	226
22523	3	3	226
22524	3	4	226
22525	3	5	226
22526	3	6	226
22527	3	7	226
22528	3	8	226
22529	3	9	226
22530	3	10	226
22531	4	1	226
22532	4	2	226
22533	4	3	226
22534	4	4	226
22535	4	5	226
22536	4	6	226
22537	4	7	226
22538	4	8	226
22539	4	9	226
22540	4	10	226
22541	5	1	226
22542	5	2	226
22543	5	3	226
22544	5	4	226
22545	5	5	226
22546	5	6	226
22547	5	7	226
22548	5	8	226
22549	5	9	226
22550	5	10	226
22551	6	1	226
22552	6	2	226
22553	6	3	226
22554	6	4	226
22555	6	5	226
22556	6	6	226
22557	6	7	226
22558	6	8	226
22559	6	9	226
22560	6	10	226
22561	7	1	226
22562	7	2	226
22563	7	3	226
22564	7	4	226
22565	7	5	226
22566	7	6	226
22567	7	7	226
22568	7	8	226
22569	7	9	226
22570	7	10	226
22571	8	1	226
22572	8	2	226
22573	8	3	226
22574	8	4	226
22575	8	5	226
22576	8	6	226
22577	8	7	226
22578	8	8	226
22579	8	9	226
22580	8	10	226
22581	9	1	226
22582	9	2	226
22583	9	3	226
22584	9	4	226
22585	9	5	226
22586	9	6	226
22587	9	7	226
22588	9	8	226
22589	9	9	226
22590	9	10	226
22591	10	1	226
22592	10	2	226
22593	10	3	226
22594	10	4	226
22595	10	5	226
22596	10	6	226
22597	10	7	226
22598	10	8	226
22599	10	9	226
22600	10	10	226
22601	1	1	227
22602	1	2	227
22603	1	3	227
22604	1	4	227
22605	1	5	227
22606	1	6	227
22607	1	7	227
22608	1	8	227
22609	1	9	227
22610	1	10	227
22611	2	1	227
22612	2	2	227
22613	2	3	227
22614	2	4	227
22615	2	5	227
22616	2	6	227
22617	2	7	227
22618	2	8	227
22619	2	9	227
22620	2	10	227
22621	3	1	227
22622	3	2	227
22623	3	3	227
22624	3	4	227
22625	3	5	227
22626	3	6	227
22627	3	7	227
22628	3	8	227
22629	3	9	227
22630	3	10	227
22631	4	1	227
22632	4	2	227
22633	4	3	227
22634	4	4	227
22635	4	5	227
22636	4	6	227
22637	4	7	227
22638	4	8	227
22639	4	9	227
22640	4	10	227
22641	5	1	227
22642	5	2	227
22643	5	3	227
22644	5	4	227
22645	5	5	227
22646	5	6	227
22647	5	7	227
22648	5	8	227
22649	5	9	227
22650	5	10	227
22651	6	1	227
22652	6	2	227
22653	6	3	227
22654	6	4	227
22655	6	5	227
22656	6	6	227
22657	6	7	227
22658	6	8	227
22659	6	9	227
22660	6	10	227
22661	7	1	227
22662	7	2	227
22663	7	3	227
22664	7	4	227
22665	7	5	227
22666	7	6	227
22667	7	7	227
22668	7	8	227
22669	7	9	227
22670	7	10	227
22671	8	1	227
22672	8	2	227
22673	8	3	227
22674	8	4	227
22675	8	5	227
22676	8	6	227
22677	8	7	227
22678	8	8	227
22679	8	9	227
22680	8	10	227
22681	9	1	227
22682	9	2	227
22683	9	3	227
22684	9	4	227
22685	9	5	227
22686	9	6	227
22687	9	7	227
22688	9	8	227
22689	9	9	227
22690	9	10	227
22691	10	1	227
22692	10	2	227
22693	10	3	227
22694	10	4	227
22695	10	5	227
22696	10	6	227
22697	10	7	227
22698	10	8	227
22699	10	9	227
22700	10	10	227
22701	1	1	228
22702	1	2	228
22703	1	3	228
22704	1	4	228
22705	1	5	228
22706	1	6	228
22707	1	7	228
22708	1	8	228
22709	1	9	228
22710	1	10	228
22711	2	1	228
22712	2	2	228
22713	2	3	228
22714	2	4	228
22715	2	5	228
22716	2	6	228
22717	2	7	228
22718	2	8	228
22719	2	9	228
22720	2	10	228
22721	3	1	228
22722	3	2	228
22723	3	3	228
22724	3	4	228
22725	3	5	228
22726	3	6	228
22727	3	7	228
22728	3	8	228
22729	3	9	228
22730	3	10	228
22731	4	1	228
22732	4	2	228
22733	4	3	228
22734	4	4	228
22735	4	5	228
22736	4	6	228
22737	4	7	228
22738	4	8	228
22739	4	9	228
22740	4	10	228
22741	5	1	228
22742	5	2	228
22743	5	3	228
22744	5	4	228
22745	5	5	228
22746	5	6	228
22747	5	7	228
22748	5	8	228
22749	5	9	228
22750	5	10	228
22751	6	1	228
22752	6	2	228
22753	6	3	228
22754	6	4	228
22755	6	5	228
22756	6	6	228
22757	6	7	228
22758	6	8	228
22759	6	9	228
22760	6	10	228
22761	7	1	228
22762	7	2	228
22763	7	3	228
22764	7	4	228
22765	7	5	228
22766	7	6	228
22767	7	7	228
22768	7	8	228
22769	7	9	228
22770	7	10	228
22771	8	1	228
22772	8	2	228
22773	8	3	228
22774	8	4	228
22775	8	5	228
22776	8	6	228
22777	8	7	228
22778	8	8	228
22779	8	9	228
22780	8	10	228
22781	9	1	228
22782	9	2	228
22783	9	3	228
22784	9	4	228
22785	9	5	228
22786	9	6	228
22787	9	7	228
22788	9	8	228
22789	9	9	228
22790	9	10	228
22791	10	1	228
22792	10	2	228
22793	10	3	228
22794	10	4	228
22795	10	5	228
22796	10	6	228
22797	10	7	228
22798	10	8	228
22799	10	9	228
22800	10	10	228
22801	1	1	229
22802	1	2	229
22803	1	3	229
22804	1	4	229
22805	1	5	229
22806	1	6	229
22807	1	7	229
22808	1	8	229
22809	1	9	229
22810	1	10	229
22811	2	1	229
22812	2	2	229
22813	2	3	229
22814	2	4	229
22815	2	5	229
22816	2	6	229
22817	2	7	229
22818	2	8	229
22819	2	9	229
22820	2	10	229
22821	3	1	229
22822	3	2	229
22823	3	3	229
22824	3	4	229
22825	3	5	229
22826	3	6	229
22827	3	7	229
22828	3	8	229
22829	3	9	229
22830	3	10	229
22831	4	1	229
22832	4	2	229
22833	4	3	229
22834	4	4	229
22835	4	5	229
22836	4	6	229
22837	4	7	229
22838	4	8	229
22839	4	9	229
22840	4	10	229
22841	5	1	229
22842	5	2	229
22843	5	3	229
22844	5	4	229
22845	5	5	229
22846	5	6	229
22847	5	7	229
22848	5	8	229
22849	5	9	229
22850	5	10	229
22851	6	1	229
22852	6	2	229
22853	6	3	229
22854	6	4	229
22855	6	5	229
22856	6	6	229
22857	6	7	229
22858	6	8	229
22859	6	9	229
22860	6	10	229
22861	7	1	229
22862	7	2	229
22863	7	3	229
22864	7	4	229
22865	7	5	229
22866	7	6	229
22867	7	7	229
22868	7	8	229
22869	7	9	229
22870	7	10	229
22871	8	1	229
22872	8	2	229
22873	8	3	229
22874	8	4	229
22875	8	5	229
22876	8	6	229
22877	8	7	229
22878	8	8	229
22879	8	9	229
22880	8	10	229
22881	9	1	229
22882	9	2	229
22883	9	3	229
22884	9	4	229
22885	9	5	229
22886	9	6	229
22887	9	7	229
22888	9	8	229
22889	9	9	229
22890	9	10	229
22891	10	1	229
22892	10	2	229
22893	10	3	229
22894	10	4	229
22895	10	5	229
22896	10	6	229
22897	10	7	229
22898	10	8	229
22899	10	9	229
22900	10	10	229
22901	1	1	230
22902	1	2	230
22903	1	3	230
22904	1	4	230
22905	1	5	230
22906	1	6	230
22907	1	7	230
22908	1	8	230
22909	1	9	230
22910	1	10	230
22911	2	1	230
22912	2	2	230
22913	2	3	230
22914	2	4	230
22915	2	5	230
22916	2	6	230
22917	2	7	230
22918	2	8	230
22919	2	9	230
22920	2	10	230
22921	3	1	230
22922	3	2	230
22923	3	3	230
22924	3	4	230
22925	3	5	230
22926	3	6	230
22927	3	7	230
22928	3	8	230
22929	3	9	230
22930	3	10	230
22931	4	1	230
22932	4	2	230
22933	4	3	230
22934	4	4	230
22935	4	5	230
22936	4	6	230
22937	4	7	230
22938	4	8	230
22939	4	9	230
22940	4	10	230
22941	5	1	230
22942	5	2	230
22943	5	3	230
22944	5	4	230
22945	5	5	230
22946	5	6	230
22947	5	7	230
22948	5	8	230
22949	5	9	230
22950	5	10	230
22951	6	1	230
22952	6	2	230
22953	6	3	230
22954	6	4	230
22955	6	5	230
22956	6	6	230
22957	6	7	230
22958	6	8	230
22959	6	9	230
22960	6	10	230
22961	7	1	230
22962	7	2	230
22963	7	3	230
22964	7	4	230
22965	7	5	230
22966	7	6	230
22967	7	7	230
22968	7	8	230
22969	7	9	230
22970	7	10	230
22971	8	1	230
22972	8	2	230
22973	8	3	230
22974	8	4	230
22975	8	5	230
22976	8	6	230
22977	8	7	230
22978	8	8	230
22979	8	9	230
22980	8	10	230
22981	9	1	230
22982	9	2	230
22983	9	3	230
22984	9	4	230
22985	9	5	230
22986	9	6	230
22987	9	7	230
22988	9	8	230
22989	9	9	230
22990	9	10	230
22991	10	1	230
22992	10	2	230
22993	10	3	230
22994	10	4	230
22995	10	5	230
22996	10	6	230
22997	10	7	230
22998	10	8	230
22999	10	9	230
23000	10	10	230
23001	1	1	231
23002	1	2	231
23003	1	3	231
23004	1	4	231
23005	1	5	231
23006	1	6	231
23007	1	7	231
23008	1	8	231
23009	1	9	231
23010	1	10	231
23011	2	1	231
23012	2	2	231
23013	2	3	231
23014	2	4	231
23015	2	5	231
23016	2	6	231
23017	2	7	231
23018	2	8	231
23019	2	9	231
23020	2	10	231
23021	3	1	231
23022	3	2	231
23023	3	3	231
23024	3	4	231
23025	3	5	231
23026	3	6	231
23027	3	7	231
23028	3	8	231
23029	3	9	231
23030	3	10	231
23031	4	1	231
23032	4	2	231
23033	4	3	231
23034	4	4	231
23035	4	5	231
23036	4	6	231
23037	4	7	231
23038	4	8	231
23039	4	9	231
23040	4	10	231
23041	5	1	231
23042	5	2	231
23043	5	3	231
23044	5	4	231
23045	5	5	231
23046	5	6	231
23047	5	7	231
23048	5	8	231
23049	5	9	231
23050	5	10	231
23051	6	1	231
23052	6	2	231
23053	6	3	231
23054	6	4	231
23055	6	5	231
23056	6	6	231
23057	6	7	231
23058	6	8	231
23059	6	9	231
23060	6	10	231
23061	7	1	231
23062	7	2	231
23063	7	3	231
23064	7	4	231
23065	7	5	231
23066	7	6	231
23067	7	7	231
23068	7	8	231
23069	7	9	231
23070	7	10	231
23071	8	1	231
23072	8	2	231
23073	8	3	231
23074	8	4	231
23075	8	5	231
23076	8	6	231
23077	8	7	231
23078	8	8	231
23079	8	9	231
23080	8	10	231
23081	9	1	231
23082	9	2	231
23083	9	3	231
23084	9	4	231
23085	9	5	231
23086	9	6	231
23087	9	7	231
23088	9	8	231
23089	9	9	231
23090	9	10	231
23091	10	1	231
23092	10	2	231
23093	10	3	231
23094	10	4	231
23095	10	5	231
23096	10	6	231
23097	10	7	231
23098	10	8	231
23099	10	9	231
23100	10	10	231
23101	1	1	232
23102	1	2	232
23103	1	3	232
23104	1	4	232
23105	1	5	232
23106	1	6	232
23107	1	7	232
23108	1	8	232
23109	1	9	232
23110	1	10	232
23111	2	1	232
23112	2	2	232
23113	2	3	232
23114	2	4	232
23115	2	5	232
23116	2	6	232
23117	2	7	232
23118	2	8	232
23119	2	9	232
23120	2	10	232
23121	3	1	232
23122	3	2	232
23123	3	3	232
23124	3	4	232
23125	3	5	232
23126	3	6	232
23127	3	7	232
23128	3	8	232
23129	3	9	232
23130	3	10	232
23131	4	1	232
23132	4	2	232
23133	4	3	232
23134	4	4	232
23135	4	5	232
23136	4	6	232
23137	4	7	232
23138	4	8	232
23139	4	9	232
23140	4	10	232
23141	5	1	232
23142	5	2	232
23143	5	3	232
23144	5	4	232
23145	5	5	232
23146	5	6	232
23147	5	7	232
23148	5	8	232
23149	5	9	232
23150	5	10	232
23151	6	1	232
23152	6	2	232
23153	6	3	232
23154	6	4	232
23155	6	5	232
23156	6	6	232
23157	6	7	232
23158	6	8	232
23159	6	9	232
23160	6	10	232
23161	7	1	232
23162	7	2	232
23163	7	3	232
23164	7	4	232
23165	7	5	232
23166	7	6	232
23167	7	7	232
23168	7	8	232
23169	7	9	232
23170	7	10	232
23171	8	1	232
23172	8	2	232
23173	8	3	232
23174	8	4	232
23175	8	5	232
23176	8	6	232
23177	8	7	232
23178	8	8	232
23179	8	9	232
23180	8	10	232
23181	9	1	232
23182	9	2	232
23183	9	3	232
23184	9	4	232
23185	9	5	232
23186	9	6	232
23187	9	7	232
23188	9	8	232
23189	9	9	232
23190	9	10	232
23191	10	1	232
23192	10	2	232
23193	10	3	232
23194	10	4	232
23195	10	5	232
23196	10	6	232
23197	10	7	232
23198	10	8	232
23199	10	9	232
23200	10	10	232
23201	1	1	233
23202	1	2	233
23203	1	3	233
23204	1	4	233
23205	1	5	233
23206	1	6	233
23207	1	7	233
23208	1	8	233
23209	1	9	233
23210	1	10	233
23211	2	1	233
23212	2	2	233
23213	2	3	233
23214	2	4	233
23215	2	5	233
23216	2	6	233
23217	2	7	233
23218	2	8	233
23219	2	9	233
23220	2	10	233
23221	3	1	233
23222	3	2	233
23223	3	3	233
23224	3	4	233
23225	3	5	233
23226	3	6	233
23227	3	7	233
23228	3	8	233
23229	3	9	233
23230	3	10	233
23231	4	1	233
23232	4	2	233
23233	4	3	233
23234	4	4	233
23235	4	5	233
23236	4	6	233
23237	4	7	233
23238	4	8	233
23239	4	9	233
23240	4	10	233
23241	5	1	233
23242	5	2	233
23243	5	3	233
23244	5	4	233
23245	5	5	233
23246	5	6	233
23247	5	7	233
23248	5	8	233
23249	5	9	233
23250	5	10	233
23251	6	1	233
23252	6	2	233
23253	6	3	233
23254	6	4	233
23255	6	5	233
23256	6	6	233
23257	6	7	233
23258	6	8	233
23259	6	9	233
23260	6	10	233
23261	7	1	233
23262	7	2	233
23263	7	3	233
23264	7	4	233
23265	7	5	233
23266	7	6	233
23267	7	7	233
23268	7	8	233
23269	7	9	233
23270	7	10	233
23271	8	1	233
23272	8	2	233
23273	8	3	233
23274	8	4	233
23275	8	5	233
23276	8	6	233
23277	8	7	233
23278	8	8	233
23279	8	9	233
23280	8	10	233
23281	9	1	233
23282	9	2	233
23283	9	3	233
23284	9	4	233
23285	9	5	233
23286	9	6	233
23287	9	7	233
23288	9	8	233
23289	9	9	233
23290	9	10	233
23291	10	1	233
23292	10	2	233
23293	10	3	233
23294	10	4	233
23295	10	5	233
23296	10	6	233
23297	10	7	233
23298	10	8	233
23299	10	9	233
23300	10	10	233
23301	1	1	234
23302	1	2	234
23303	1	3	234
23304	1	4	234
23305	1	5	234
23306	1	6	234
23307	1	7	234
23308	1	8	234
23309	1	9	234
23310	1	10	234
23311	2	1	234
23312	2	2	234
23313	2	3	234
23314	2	4	234
23315	2	5	234
23316	2	6	234
23317	2	7	234
23318	2	8	234
23319	2	9	234
23320	2	10	234
23321	3	1	234
23322	3	2	234
23323	3	3	234
23324	3	4	234
23325	3	5	234
23326	3	6	234
23327	3	7	234
23328	3	8	234
23329	3	9	234
23330	3	10	234
23331	4	1	234
23332	4	2	234
23333	4	3	234
23334	4	4	234
23335	4	5	234
23336	4	6	234
23337	4	7	234
23338	4	8	234
23339	4	9	234
23340	4	10	234
23341	5	1	234
23342	5	2	234
23343	5	3	234
23344	5	4	234
23345	5	5	234
23346	5	6	234
23347	5	7	234
23348	5	8	234
23349	5	9	234
23350	5	10	234
23351	6	1	234
23352	6	2	234
23353	6	3	234
23354	6	4	234
23355	6	5	234
23356	6	6	234
23357	6	7	234
23358	6	8	234
23359	6	9	234
23360	6	10	234
23361	7	1	234
23362	7	2	234
23363	7	3	234
23364	7	4	234
23365	7	5	234
23366	7	6	234
23367	7	7	234
23368	7	8	234
23369	7	9	234
23370	7	10	234
23371	8	1	234
23372	8	2	234
23373	8	3	234
23374	8	4	234
23375	8	5	234
23376	8	6	234
23377	8	7	234
23378	8	8	234
23379	8	9	234
23380	8	10	234
23381	9	1	234
23382	9	2	234
23383	9	3	234
23384	9	4	234
23385	9	5	234
23386	9	6	234
23387	9	7	234
23388	9	8	234
23389	9	9	234
23390	9	10	234
23391	10	1	234
23392	10	2	234
23393	10	3	234
23394	10	4	234
23395	10	5	234
23396	10	6	234
23397	10	7	234
23398	10	8	234
23399	10	9	234
23400	10	10	234
23401	1	1	235
23402	1	2	235
23403	1	3	235
23404	1	4	235
23405	1	5	235
23406	1	6	235
23407	1	7	235
23408	1	8	235
23409	1	9	235
23410	1	10	235
23411	2	1	235
23412	2	2	235
23413	2	3	235
23414	2	4	235
23415	2	5	235
23416	2	6	235
23417	2	7	235
23418	2	8	235
23419	2	9	235
23420	2	10	235
23421	3	1	235
23422	3	2	235
23423	3	3	235
23424	3	4	235
23425	3	5	235
23426	3	6	235
23427	3	7	235
23428	3	8	235
23429	3	9	235
23430	3	10	235
23431	4	1	235
23432	4	2	235
23433	4	3	235
23434	4	4	235
23435	4	5	235
23436	4	6	235
23437	4	7	235
23438	4	8	235
23439	4	9	235
23440	4	10	235
23441	5	1	235
23442	5	2	235
23443	5	3	235
23444	5	4	235
23445	5	5	235
23446	5	6	235
23447	5	7	235
23448	5	8	235
23449	5	9	235
23450	5	10	235
23451	6	1	235
23452	6	2	235
23453	6	3	235
23454	6	4	235
23455	6	5	235
23456	6	6	235
23457	6	7	235
23458	6	8	235
23459	6	9	235
23460	6	10	235
23461	7	1	235
23462	7	2	235
23463	7	3	235
23464	7	4	235
23465	7	5	235
23466	7	6	235
23467	7	7	235
23468	7	8	235
23469	7	9	235
23470	7	10	235
23471	8	1	235
23472	8	2	235
23473	8	3	235
23474	8	4	235
23475	8	5	235
23476	8	6	235
23477	8	7	235
23478	8	8	235
23479	8	9	235
23480	8	10	235
23481	9	1	235
23482	9	2	235
23483	9	3	235
23484	9	4	235
23485	9	5	235
23486	9	6	235
23487	9	7	235
23488	9	8	235
23489	9	9	235
23490	9	10	235
23491	10	1	235
23492	10	2	235
23493	10	3	235
23494	10	4	235
23495	10	5	235
23496	10	6	235
23497	10	7	235
23498	10	8	235
23499	10	9	235
23500	10	10	235
23501	1	1	236
23502	1	2	236
23503	1	3	236
23504	1	4	236
23505	1	5	236
23506	1	6	236
23507	1	7	236
23508	1	8	236
23509	1	9	236
23510	1	10	236
23511	2	1	236
23512	2	2	236
23513	2	3	236
23514	2	4	236
23515	2	5	236
23516	2	6	236
23517	2	7	236
23518	2	8	236
23519	2	9	236
23520	2	10	236
23521	3	1	236
23522	3	2	236
23523	3	3	236
23524	3	4	236
23525	3	5	236
23526	3	6	236
23527	3	7	236
23528	3	8	236
23529	3	9	236
23530	3	10	236
23531	4	1	236
23532	4	2	236
23533	4	3	236
23534	4	4	236
23535	4	5	236
23536	4	6	236
23537	4	7	236
23538	4	8	236
23539	4	9	236
23540	4	10	236
23541	5	1	236
23542	5	2	236
23543	5	3	236
23544	5	4	236
23545	5	5	236
23546	5	6	236
23547	5	7	236
23548	5	8	236
23549	5	9	236
23550	5	10	236
23551	6	1	236
23552	6	2	236
23553	6	3	236
23554	6	4	236
23555	6	5	236
23556	6	6	236
23557	6	7	236
23558	6	8	236
23559	6	9	236
23560	6	10	236
23561	7	1	236
23562	7	2	236
23563	7	3	236
23564	7	4	236
23565	7	5	236
23566	7	6	236
23567	7	7	236
23568	7	8	236
23569	7	9	236
23570	7	10	236
23571	8	1	236
23572	8	2	236
23573	8	3	236
23574	8	4	236
23575	8	5	236
23576	8	6	236
23577	8	7	236
23578	8	8	236
23579	8	9	236
23580	8	10	236
23581	9	1	236
23582	9	2	236
23583	9	3	236
23584	9	4	236
23585	9	5	236
23586	9	6	236
23587	9	7	236
23588	9	8	236
23589	9	9	236
23590	9	10	236
23591	10	1	236
23592	10	2	236
23593	10	3	236
23594	10	4	236
23595	10	5	236
23596	10	6	236
23597	10	7	236
23598	10	8	236
23599	10	9	236
23600	10	10	236
23601	1	1	237
23602	1	2	237
23603	1	3	237
23604	1	4	237
23605	1	5	237
23606	1	6	237
23607	1	7	237
23608	1	8	237
23609	1	9	237
23610	1	10	237
23611	2	1	237
23612	2	2	237
23613	2	3	237
23614	2	4	237
23615	2	5	237
23616	2	6	237
23617	2	7	237
23618	2	8	237
23619	2	9	237
23620	2	10	237
23621	3	1	237
23622	3	2	237
23623	3	3	237
23624	3	4	237
23625	3	5	237
23626	3	6	237
23627	3	7	237
23628	3	8	237
23629	3	9	237
23630	3	10	237
23631	4	1	237
23632	4	2	237
23633	4	3	237
23634	4	4	237
23635	4	5	237
23636	4	6	237
23637	4	7	237
23638	4	8	237
23639	4	9	237
23640	4	10	237
23641	5	1	237
23642	5	2	237
23643	5	3	237
23644	5	4	237
23645	5	5	237
23646	5	6	237
23647	5	7	237
23648	5	8	237
23649	5	9	237
23650	5	10	237
23651	6	1	237
23652	6	2	237
23653	6	3	237
23654	6	4	237
23655	6	5	237
23656	6	6	237
23657	6	7	237
23658	6	8	237
23659	6	9	237
23660	6	10	237
23661	7	1	237
23662	7	2	237
23663	7	3	237
23664	7	4	237
23665	7	5	237
23666	7	6	237
23667	7	7	237
23668	7	8	237
23669	7	9	237
23670	7	10	237
23671	8	1	237
23672	8	2	237
23673	8	3	237
23674	8	4	237
23675	8	5	237
23676	8	6	237
23677	8	7	237
23678	8	8	237
23679	8	9	237
23680	8	10	237
23681	9	1	237
23682	9	2	237
23683	9	3	237
23684	9	4	237
23685	9	5	237
23686	9	6	237
23687	9	7	237
23688	9	8	237
23689	9	9	237
23690	9	10	237
23691	10	1	237
23692	10	2	237
23693	10	3	237
23694	10	4	237
23695	10	5	237
23696	10	6	237
23697	10	7	237
23698	10	8	237
23699	10	9	237
23700	10	10	237
23701	1	1	238
23702	1	2	238
23703	1	3	238
23704	1	4	238
23705	1	5	238
23706	1	6	238
23707	1	7	238
23708	1	8	238
23709	1	9	238
23710	1	10	238
23711	2	1	238
23712	2	2	238
23713	2	3	238
23714	2	4	238
23715	2	5	238
23716	2	6	238
23717	2	7	238
23718	2	8	238
23719	2	9	238
23720	2	10	238
23721	3	1	238
23722	3	2	238
23723	3	3	238
23724	3	4	238
23725	3	5	238
23726	3	6	238
23727	3	7	238
23728	3	8	238
23729	3	9	238
23730	3	10	238
23731	4	1	238
23732	4	2	238
23733	4	3	238
23734	4	4	238
23735	4	5	238
23736	4	6	238
23737	4	7	238
23738	4	8	238
23739	4	9	238
23740	4	10	238
23741	5	1	238
23742	5	2	238
23743	5	3	238
23744	5	4	238
23745	5	5	238
23746	5	6	238
23747	5	7	238
23748	5	8	238
23749	5	9	238
23750	5	10	238
23751	6	1	238
23752	6	2	238
23753	6	3	238
23754	6	4	238
23755	6	5	238
23756	6	6	238
23757	6	7	238
23758	6	8	238
23759	6	9	238
23760	6	10	238
23761	7	1	238
23762	7	2	238
23763	7	3	238
23764	7	4	238
23765	7	5	238
23766	7	6	238
23767	7	7	238
23768	7	8	238
23769	7	9	238
23770	7	10	238
23771	8	1	238
23772	8	2	238
23773	8	3	238
23774	8	4	238
23775	8	5	238
23776	8	6	238
23777	8	7	238
23778	8	8	238
23779	8	9	238
23780	8	10	238
23781	9	1	238
23782	9	2	238
23783	9	3	238
23784	9	4	238
23785	9	5	238
23786	9	6	238
23787	9	7	238
23788	9	8	238
23789	9	9	238
23790	9	10	238
23791	10	1	238
23792	10	2	238
23793	10	3	238
23794	10	4	238
23795	10	5	238
23796	10	6	238
23797	10	7	238
23798	10	8	238
23799	10	9	238
23800	10	10	238
23801	1	1	239
23802	1	2	239
23803	1	3	239
23804	1	4	239
23805	1	5	239
23806	1	6	239
23807	1	7	239
23808	1	8	239
23809	1	9	239
23810	1	10	239
23811	2	1	239
23812	2	2	239
23813	2	3	239
23814	2	4	239
23815	2	5	239
23816	2	6	239
23817	2	7	239
23818	2	8	239
23819	2	9	239
23820	2	10	239
23821	3	1	239
23822	3	2	239
23823	3	3	239
23824	3	4	239
23825	3	5	239
23826	3	6	239
23827	3	7	239
23828	3	8	239
23829	3	9	239
23830	3	10	239
23831	4	1	239
23832	4	2	239
23833	4	3	239
23834	4	4	239
23835	4	5	239
23836	4	6	239
23837	4	7	239
23838	4	8	239
23839	4	9	239
23840	4	10	239
23841	5	1	239
23842	5	2	239
23843	5	3	239
23844	5	4	239
23845	5	5	239
23846	5	6	239
23847	5	7	239
23848	5	8	239
23849	5	9	239
23850	5	10	239
23851	6	1	239
23852	6	2	239
23853	6	3	239
23854	6	4	239
23855	6	5	239
23856	6	6	239
23857	6	7	239
23858	6	8	239
23859	6	9	239
23860	6	10	239
23861	7	1	239
23862	7	2	239
23863	7	3	239
23864	7	4	239
23865	7	5	239
23866	7	6	239
23867	7	7	239
23868	7	8	239
23869	7	9	239
23870	7	10	239
23871	8	1	239
23872	8	2	239
23873	8	3	239
23874	8	4	239
23875	8	5	239
23876	8	6	239
23877	8	7	239
23878	8	8	239
23879	8	9	239
23880	8	10	239
23881	9	1	239
23882	9	2	239
23883	9	3	239
23884	9	4	239
23885	9	5	239
23886	9	6	239
23887	9	7	239
23888	9	8	239
23889	9	9	239
23890	9	10	239
23891	10	1	239
23892	10	2	239
23893	10	3	239
23894	10	4	239
23895	10	5	239
23896	10	6	239
23897	10	7	239
23898	10	8	239
23899	10	9	239
23900	10	10	239
23901	1	1	240
23902	1	2	240
23903	1	3	240
23904	1	4	240
23905	1	5	240
23906	1	6	240
23907	1	7	240
23908	1	8	240
23909	1	9	240
23910	1	10	240
23911	2	1	240
23912	2	2	240
23913	2	3	240
23914	2	4	240
23915	2	5	240
23916	2	6	240
23917	2	7	240
23918	2	8	240
23919	2	9	240
23920	2	10	240
23921	3	1	240
23922	3	2	240
23923	3	3	240
23924	3	4	240
23925	3	5	240
23926	3	6	240
23927	3	7	240
23928	3	8	240
23929	3	9	240
23930	3	10	240
23931	4	1	240
23932	4	2	240
23933	4	3	240
23934	4	4	240
23935	4	5	240
23936	4	6	240
23937	4	7	240
23938	4	8	240
23939	4	9	240
23940	4	10	240
23941	5	1	240
23942	5	2	240
23943	5	3	240
23944	5	4	240
23945	5	5	240
23946	5	6	240
23947	5	7	240
23948	5	8	240
23949	5	9	240
23950	5	10	240
23951	6	1	240
23952	6	2	240
23953	6	3	240
23954	6	4	240
23955	6	5	240
23956	6	6	240
23957	6	7	240
23958	6	8	240
23959	6	9	240
23960	6	10	240
23961	7	1	240
23962	7	2	240
23963	7	3	240
23964	7	4	240
23965	7	5	240
23966	7	6	240
23967	7	7	240
23968	7	8	240
23969	7	9	240
23970	7	10	240
23971	8	1	240
23972	8	2	240
23973	8	3	240
23974	8	4	240
23975	8	5	240
23976	8	6	240
23977	8	7	240
23978	8	8	240
23979	8	9	240
23980	8	10	240
23981	9	1	240
23982	9	2	240
23983	9	3	240
23984	9	4	240
23985	9	5	240
23986	9	6	240
23987	9	7	240
23988	9	8	240
23989	9	9	240
23990	9	10	240
23991	10	1	240
23992	10	2	240
23993	10	3	240
23994	10	4	240
23995	10	5	240
23996	10	6	240
23997	10	7	240
23998	10	8	240
23999	10	9	240
24000	10	10	240
24001	1	1	241
24002	1	2	241
24003	1	3	241
24004	1	4	241
24005	1	5	241
24006	1	6	241
24007	1	7	241
24008	1	8	241
24009	1	9	241
24010	1	10	241
24011	2	1	241
24012	2	2	241
24013	2	3	241
24014	2	4	241
24015	2	5	241
24016	2	6	241
24017	2	7	241
24018	2	8	241
24019	2	9	241
24020	2	10	241
24021	3	1	241
24022	3	2	241
24023	3	3	241
24024	3	4	241
24025	3	5	241
24026	3	6	241
24027	3	7	241
24028	3	8	241
24029	3	9	241
24030	3	10	241
24031	4	1	241
24032	4	2	241
24033	4	3	241
24034	4	4	241
24035	4	5	241
24036	4	6	241
24037	4	7	241
24038	4	8	241
24039	4	9	241
24040	4	10	241
24041	5	1	241
24042	5	2	241
24043	5	3	241
24044	5	4	241
24045	5	5	241
24046	5	6	241
24047	5	7	241
24048	5	8	241
24049	5	9	241
24050	5	10	241
24051	6	1	241
24052	6	2	241
24053	6	3	241
24054	6	4	241
24055	6	5	241
24056	6	6	241
24057	6	7	241
24058	6	8	241
24059	6	9	241
24060	6	10	241
24061	7	1	241
24062	7	2	241
24063	7	3	241
24064	7	4	241
24065	7	5	241
24066	7	6	241
24067	7	7	241
24068	7	8	241
24069	7	9	241
24070	7	10	241
24071	8	1	241
24072	8	2	241
24073	8	3	241
24074	8	4	241
24075	8	5	241
24076	8	6	241
24077	8	7	241
24078	8	8	241
24079	8	9	241
24080	8	10	241
24081	9	1	241
24082	9	2	241
24083	9	3	241
24084	9	4	241
24085	9	5	241
24086	9	6	241
24087	9	7	241
24088	9	8	241
24089	9	9	241
24090	9	10	241
24091	10	1	241
24092	10	2	241
24093	10	3	241
24094	10	4	241
24095	10	5	241
24096	10	6	241
24097	10	7	241
24098	10	8	241
24099	10	9	241
24100	10	10	241
24101	1	1	242
24102	1	2	242
24103	1	3	242
24104	1	4	242
24105	1	5	242
24106	1	6	242
24107	1	7	242
24108	1	8	242
24109	1	9	242
24110	1	10	242
24111	2	1	242
24112	2	2	242
24113	2	3	242
24114	2	4	242
24115	2	5	242
24116	2	6	242
24117	2	7	242
24118	2	8	242
24119	2	9	242
24120	2	10	242
24121	3	1	242
24122	3	2	242
24123	3	3	242
24124	3	4	242
24125	3	5	242
24126	3	6	242
24127	3	7	242
24128	3	8	242
24129	3	9	242
24130	3	10	242
24131	4	1	242
24132	4	2	242
24133	4	3	242
24134	4	4	242
24135	4	5	242
24136	4	6	242
24137	4	7	242
24138	4	8	242
24139	4	9	242
24140	4	10	242
24141	5	1	242
24142	5	2	242
24143	5	3	242
24144	5	4	242
24145	5	5	242
24146	5	6	242
24147	5	7	242
24148	5	8	242
24149	5	9	242
24150	5	10	242
24151	6	1	242
24152	6	2	242
24153	6	3	242
24154	6	4	242
24155	6	5	242
24156	6	6	242
24157	6	7	242
24158	6	8	242
24159	6	9	242
24160	6	10	242
24161	7	1	242
24162	7	2	242
24163	7	3	242
24164	7	4	242
24165	7	5	242
24166	7	6	242
24167	7	7	242
24168	7	8	242
24169	7	9	242
24170	7	10	242
24171	8	1	242
24172	8	2	242
24173	8	3	242
24174	8	4	242
24175	8	5	242
24176	8	6	242
24177	8	7	242
24178	8	8	242
24179	8	9	242
24180	8	10	242
24181	9	1	242
24182	9	2	242
24183	9	3	242
24184	9	4	242
24185	9	5	242
24186	9	6	242
24187	9	7	242
24188	9	8	242
24189	9	9	242
24190	9	10	242
24191	10	1	242
24192	10	2	242
24193	10	3	242
24194	10	4	242
24195	10	5	242
24196	10	6	242
24197	10	7	242
24198	10	8	242
24199	10	9	242
24200	10	10	242
24201	1	1	243
24202	1	2	243
24203	1	3	243
24204	1	4	243
24205	1	5	243
24206	1	6	243
24207	1	7	243
24208	1	8	243
24209	1	9	243
24210	1	10	243
24211	2	1	243
24212	2	2	243
24213	2	3	243
24214	2	4	243
24215	2	5	243
24216	2	6	243
24217	2	7	243
24218	2	8	243
24219	2	9	243
24220	2	10	243
24221	3	1	243
24222	3	2	243
24223	3	3	243
24224	3	4	243
24225	3	5	243
24226	3	6	243
24227	3	7	243
24228	3	8	243
24229	3	9	243
24230	3	10	243
24231	4	1	243
24232	4	2	243
24233	4	3	243
24234	4	4	243
24235	4	5	243
24236	4	6	243
24237	4	7	243
24238	4	8	243
24239	4	9	243
24240	4	10	243
24241	5	1	243
24242	5	2	243
24243	5	3	243
24244	5	4	243
24245	5	5	243
24246	5	6	243
24247	5	7	243
24248	5	8	243
24249	5	9	243
24250	5	10	243
24251	6	1	243
24252	6	2	243
24253	6	3	243
24254	6	4	243
24255	6	5	243
24256	6	6	243
24257	6	7	243
24258	6	8	243
24259	6	9	243
24260	6	10	243
24261	7	1	243
24262	7	2	243
24263	7	3	243
24264	7	4	243
24265	7	5	243
24266	7	6	243
24267	7	7	243
24268	7	8	243
24269	7	9	243
24270	7	10	243
24271	8	1	243
24272	8	2	243
24273	8	3	243
24274	8	4	243
24275	8	5	243
24276	8	6	243
24277	8	7	243
24278	8	8	243
24279	8	9	243
24280	8	10	243
24281	9	1	243
24282	9	2	243
24283	9	3	243
24284	9	4	243
24285	9	5	243
24286	9	6	243
24287	9	7	243
24288	9	8	243
24289	9	9	243
24290	9	10	243
24291	10	1	243
24292	10	2	243
24293	10	3	243
24294	10	4	243
24295	10	5	243
24296	10	6	243
24297	10	7	243
24298	10	8	243
24299	10	9	243
24300	10	10	243
24301	1	1	244
24302	1	2	244
24303	1	3	244
24304	1	4	244
24305	1	5	244
24306	1	6	244
24307	1	7	244
24308	1	8	244
24309	1	9	244
24310	1	10	244
24311	2	1	244
24312	2	2	244
24313	2	3	244
24314	2	4	244
24315	2	5	244
24316	2	6	244
24317	2	7	244
24318	2	8	244
24319	2	9	244
24320	2	10	244
24321	3	1	244
24322	3	2	244
24323	3	3	244
24324	3	4	244
24325	3	5	244
24326	3	6	244
24327	3	7	244
24328	3	8	244
24329	3	9	244
24330	3	10	244
24331	4	1	244
24332	4	2	244
24333	4	3	244
24334	4	4	244
24335	4	5	244
24336	4	6	244
24337	4	7	244
24338	4	8	244
24339	4	9	244
24340	4	10	244
24341	5	1	244
24342	5	2	244
24343	5	3	244
24344	5	4	244
24345	5	5	244
24346	5	6	244
24347	5	7	244
24348	5	8	244
24349	5	9	244
24350	5	10	244
24351	6	1	244
24352	6	2	244
24353	6	3	244
24354	6	4	244
24355	6	5	244
24356	6	6	244
24357	6	7	244
24358	6	8	244
24359	6	9	244
24360	6	10	244
24361	7	1	244
24362	7	2	244
24363	7	3	244
24364	7	4	244
24365	7	5	244
24366	7	6	244
24367	7	7	244
24368	7	8	244
24369	7	9	244
24370	7	10	244
24371	8	1	244
24372	8	2	244
24373	8	3	244
24374	8	4	244
24375	8	5	244
24376	8	6	244
24377	8	7	244
24378	8	8	244
24379	8	9	244
24380	8	10	244
24381	9	1	244
24382	9	2	244
24383	9	3	244
24384	9	4	244
24385	9	5	244
24386	9	6	244
24387	9	7	244
24388	9	8	244
24389	9	9	244
24390	9	10	244
24391	10	1	244
24392	10	2	244
24393	10	3	244
24394	10	4	244
24395	10	5	244
24396	10	6	244
24397	10	7	244
24398	10	8	244
24399	10	9	244
24400	10	10	244
24401	1	1	245
24402	1	2	245
24403	1	3	245
24404	1	4	245
24405	1	5	245
24406	1	6	245
24407	1	7	245
24408	1	8	245
24409	1	9	245
24410	1	10	245
24411	2	1	245
24412	2	2	245
24413	2	3	245
24414	2	4	245
24415	2	5	245
24416	2	6	245
24417	2	7	245
24418	2	8	245
24419	2	9	245
24420	2	10	245
24421	3	1	245
24422	3	2	245
24423	3	3	245
24424	3	4	245
24425	3	5	245
24426	3	6	245
24427	3	7	245
24428	3	8	245
24429	3	9	245
24430	3	10	245
24431	4	1	245
24432	4	2	245
24433	4	3	245
24434	4	4	245
24435	4	5	245
24436	4	6	245
24437	4	7	245
24438	4	8	245
24439	4	9	245
24440	4	10	245
24441	5	1	245
24442	5	2	245
24443	5	3	245
24444	5	4	245
24445	5	5	245
24446	5	6	245
24447	5	7	245
24448	5	8	245
24449	5	9	245
24450	5	10	245
24451	6	1	245
24452	6	2	245
24453	6	3	245
24454	6	4	245
24455	6	5	245
24456	6	6	245
24457	6	7	245
24458	6	8	245
24459	6	9	245
24460	6	10	245
24461	7	1	245
24462	7	2	245
24463	7	3	245
24464	7	4	245
24465	7	5	245
24466	7	6	245
24467	7	7	245
24468	7	8	245
24469	7	9	245
24470	7	10	245
24471	8	1	245
24472	8	2	245
24473	8	3	245
24474	8	4	245
24475	8	5	245
24476	8	6	245
24477	8	7	245
24478	8	8	245
24479	8	9	245
24480	8	10	245
24481	9	1	245
24482	9	2	245
24483	9	3	245
24484	9	4	245
24485	9	5	245
24486	9	6	245
24487	9	7	245
24488	9	8	245
24489	9	9	245
24490	9	10	245
24491	10	1	245
24492	10	2	245
24493	10	3	245
24494	10	4	245
24495	10	5	245
24496	10	6	245
24497	10	7	245
24498	10	8	245
24499	10	9	245
24500	10	10	245
24501	1	1	246
24502	1	2	246
24503	1	3	246
24504	1	4	246
24505	1	5	246
24506	1	6	246
24507	1	7	246
24508	1	8	246
24509	1	9	246
24510	1	10	246
24511	2	1	246
24512	2	2	246
24513	2	3	246
24514	2	4	246
24515	2	5	246
24516	2	6	246
24517	2	7	246
24518	2	8	246
24519	2	9	246
24520	2	10	246
24521	3	1	246
24522	3	2	246
24523	3	3	246
24524	3	4	246
24525	3	5	246
24526	3	6	246
24527	3	7	246
24528	3	8	246
24529	3	9	246
24530	3	10	246
24531	4	1	246
24532	4	2	246
24533	4	3	246
24534	4	4	246
24535	4	5	246
24536	4	6	246
24537	4	7	246
24538	4	8	246
24539	4	9	246
24540	4	10	246
24541	5	1	246
24542	5	2	246
24543	5	3	246
24544	5	4	246
24545	5	5	246
24546	5	6	246
24547	5	7	246
24548	5	8	246
24549	5	9	246
24550	5	10	246
24551	6	1	246
24552	6	2	246
24553	6	3	246
24554	6	4	246
24555	6	5	246
24556	6	6	246
24557	6	7	246
24558	6	8	246
24559	6	9	246
24560	6	10	246
24561	7	1	246
24562	7	2	246
24563	7	3	246
24564	7	4	246
24565	7	5	246
24566	7	6	246
24567	7	7	246
24568	7	8	246
24569	7	9	246
24570	7	10	246
24571	8	1	246
24572	8	2	246
24573	8	3	246
24574	8	4	246
24575	8	5	246
24576	8	6	246
24577	8	7	246
24578	8	8	246
24579	8	9	246
24580	8	10	246
24581	9	1	246
24582	9	2	246
24583	9	3	246
24584	9	4	246
24585	9	5	246
24586	9	6	246
24587	9	7	246
24588	9	8	246
24589	9	9	246
24590	9	10	246
24591	10	1	246
24592	10	2	246
24593	10	3	246
24594	10	4	246
24595	10	5	246
24596	10	6	246
24597	10	7	246
24598	10	8	246
24599	10	9	246
24600	10	10	246
24601	1	1	247
24602	1	2	247
24603	1	3	247
24604	1	4	247
24605	1	5	247
24606	1	6	247
24607	1	7	247
24608	1	8	247
24609	1	9	247
24610	1	10	247
24611	2	1	247
24612	2	2	247
24613	2	3	247
24614	2	4	247
24615	2	5	247
24616	2	6	247
24617	2	7	247
24618	2	8	247
24619	2	9	247
24620	2	10	247
24621	3	1	247
24622	3	2	247
24623	3	3	247
24624	3	4	247
24625	3	5	247
24626	3	6	247
24627	3	7	247
24628	3	8	247
24629	3	9	247
24630	3	10	247
24631	4	1	247
24632	4	2	247
24633	4	3	247
24634	4	4	247
24635	4	5	247
24636	4	6	247
24637	4	7	247
24638	4	8	247
24639	4	9	247
24640	4	10	247
24641	5	1	247
24642	5	2	247
24643	5	3	247
24644	5	4	247
24645	5	5	247
24646	5	6	247
24647	5	7	247
24648	5	8	247
24649	5	9	247
24650	5	10	247
24651	6	1	247
24652	6	2	247
24653	6	3	247
24654	6	4	247
24655	6	5	247
24656	6	6	247
24657	6	7	247
24658	6	8	247
24659	6	9	247
24660	6	10	247
24661	7	1	247
24662	7	2	247
24663	7	3	247
24664	7	4	247
24665	7	5	247
24666	7	6	247
24667	7	7	247
24668	7	8	247
24669	7	9	247
24670	7	10	247
24671	8	1	247
24672	8	2	247
24673	8	3	247
24674	8	4	247
24675	8	5	247
24676	8	6	247
24677	8	7	247
24678	8	8	247
24679	8	9	247
24680	8	10	247
24681	9	1	247
24682	9	2	247
24683	9	3	247
24684	9	4	247
24685	9	5	247
24686	9	6	247
24687	9	7	247
24688	9	8	247
24689	9	9	247
24690	9	10	247
24691	10	1	247
24692	10	2	247
24693	10	3	247
24694	10	4	247
24695	10	5	247
24696	10	6	247
24697	10	7	247
24698	10	8	247
24699	10	9	247
24700	10	10	247
24701	1	1	248
24702	1	2	248
24703	1	3	248
24704	1	4	248
24705	1	5	248
24706	1	6	248
24707	1	7	248
24708	1	8	248
24709	1	9	248
24710	1	10	248
24711	2	1	248
24712	2	2	248
24713	2	3	248
24714	2	4	248
24715	2	5	248
24716	2	6	248
24717	2	7	248
24718	2	8	248
24719	2	9	248
24720	2	10	248
24721	3	1	248
24722	3	2	248
24723	3	3	248
24724	3	4	248
24725	3	5	248
24726	3	6	248
24727	3	7	248
24728	3	8	248
24729	3	9	248
24730	3	10	248
24731	4	1	248
24732	4	2	248
24733	4	3	248
24734	4	4	248
24735	4	5	248
24736	4	6	248
24737	4	7	248
24738	4	8	248
24739	4	9	248
24740	4	10	248
24741	5	1	248
24742	5	2	248
24743	5	3	248
24744	5	4	248
24745	5	5	248
24746	5	6	248
24747	5	7	248
24748	5	8	248
24749	5	9	248
24750	5	10	248
24751	6	1	248
24752	6	2	248
24753	6	3	248
24754	6	4	248
24755	6	5	248
24756	6	6	248
24757	6	7	248
24758	6	8	248
24759	6	9	248
24760	6	10	248
24761	7	1	248
24762	7	2	248
24763	7	3	248
24764	7	4	248
24765	7	5	248
24766	7	6	248
24767	7	7	248
24768	7	8	248
24769	7	9	248
24770	7	10	248
24771	8	1	248
24772	8	2	248
24773	8	3	248
24774	8	4	248
24775	8	5	248
24776	8	6	248
24777	8	7	248
24778	8	8	248
24779	8	9	248
24780	8	10	248
24781	9	1	248
24782	9	2	248
24783	9	3	248
24784	9	4	248
24785	9	5	248
24786	9	6	248
24787	9	7	248
24788	9	8	248
24789	9	9	248
24790	9	10	248
24791	10	1	248
24792	10	2	248
24793	10	3	248
24794	10	4	248
24795	10	5	248
24796	10	6	248
24797	10	7	248
24798	10	8	248
24799	10	9	248
24800	10	10	248
24801	1	1	249
24802	1	2	249
24803	1	3	249
24804	1	4	249
24805	1	5	249
24806	1	6	249
24807	1	7	249
24808	1	8	249
24809	1	9	249
24810	1	10	249
24811	2	1	249
24812	2	2	249
24813	2	3	249
24814	2	4	249
24815	2	5	249
24816	2	6	249
24817	2	7	249
24818	2	8	249
24819	2	9	249
24820	2	10	249
24821	3	1	249
24822	3	2	249
24823	3	3	249
24824	3	4	249
24825	3	5	249
24826	3	6	249
24827	3	7	249
24828	3	8	249
24829	3	9	249
24830	3	10	249
24831	4	1	249
24832	4	2	249
24833	4	3	249
24834	4	4	249
24835	4	5	249
24836	4	6	249
24837	4	7	249
24838	4	8	249
24839	4	9	249
24840	4	10	249
24841	5	1	249
24842	5	2	249
24843	5	3	249
24844	5	4	249
24845	5	5	249
24846	5	6	249
24847	5	7	249
24848	5	8	249
24849	5	9	249
24850	5	10	249
24851	6	1	249
24852	6	2	249
24853	6	3	249
24854	6	4	249
24855	6	5	249
24856	6	6	249
24857	6	7	249
24858	6	8	249
24859	6	9	249
24860	6	10	249
24861	7	1	249
24862	7	2	249
24863	7	3	249
24864	7	4	249
24865	7	5	249
24866	7	6	249
24867	7	7	249
24868	7	8	249
24869	7	9	249
24870	7	10	249
24871	8	1	249
24872	8	2	249
24873	8	3	249
24874	8	4	249
24875	8	5	249
24876	8	6	249
24877	8	7	249
24878	8	8	249
24879	8	9	249
24880	8	10	249
24881	9	1	249
24882	9	2	249
24883	9	3	249
24884	9	4	249
24885	9	5	249
24886	9	6	249
24887	9	7	249
24888	9	8	249
24889	9	9	249
24890	9	10	249
24891	10	1	249
24892	10	2	249
24893	10	3	249
24894	10	4	249
24895	10	5	249
24896	10	6	249
24897	10	7	249
24898	10	8	249
24899	10	9	249
24900	10	10	249
24901	1	1	250
24902	1	2	250
24903	1	3	250
24904	1	4	250
24905	1	5	250
24906	1	6	250
24907	1	7	250
24908	1	8	250
24909	1	9	250
24910	1	10	250
24911	2	1	250
24912	2	2	250
24913	2	3	250
24914	2	4	250
24915	2	5	250
24916	2	6	250
24917	2	7	250
24918	2	8	250
24919	2	9	250
24920	2	10	250
24921	3	1	250
24922	3	2	250
24923	3	3	250
24924	3	4	250
24925	3	5	250
24926	3	6	250
24927	3	7	250
24928	3	8	250
24929	3	9	250
24930	3	10	250
24931	4	1	250
24932	4	2	250
24933	4	3	250
24934	4	4	250
24935	4	5	250
24936	4	6	250
24937	4	7	250
24938	4	8	250
24939	4	9	250
24940	4	10	250
24941	5	1	250
24942	5	2	250
24943	5	3	250
24944	5	4	250
24945	5	5	250
24946	5	6	250
24947	5	7	250
24948	5	8	250
24949	5	9	250
24950	5	10	250
24951	6	1	250
24952	6	2	250
24953	6	3	250
24954	6	4	250
24955	6	5	250
24956	6	6	250
24957	6	7	250
24958	6	8	250
24959	6	9	250
24960	6	10	250
24961	7	1	250
24962	7	2	250
24963	7	3	250
24964	7	4	250
24965	7	5	250
24966	7	6	250
24967	7	7	250
24968	7	8	250
24969	7	9	250
24970	7	10	250
24971	8	1	250
24972	8	2	250
24973	8	3	250
24974	8	4	250
24975	8	5	250
24976	8	6	250
24977	8	7	250
24978	8	8	250
24979	8	9	250
24980	8	10	250
24981	9	1	250
24982	9	2	250
24983	9	3	250
24984	9	4	250
24985	9	5	250
24986	9	6	250
24987	9	7	250
24988	9	8	250
24989	9	9	250
24990	9	10	250
24991	10	1	250
24992	10	2	250
24993	10	3	250
24994	10	4	250
24995	10	5	250
24996	10	6	250
24997	10	7	250
24998	10	8	250
24999	10	9	250
25000	10	10	250
25001	1	1	251
25002	1	2	251
25003	1	3	251
25004	1	4	251
25005	1	5	251
25006	1	6	251
25007	1	7	251
25008	1	8	251
25009	1	9	251
25010	1	10	251
25011	2	1	251
25012	2	2	251
25013	2	3	251
25014	2	4	251
25015	2	5	251
25016	2	6	251
25017	2	7	251
25018	2	8	251
25019	2	9	251
25020	2	10	251
25021	3	1	251
25022	3	2	251
25023	3	3	251
25024	3	4	251
25025	3	5	251
25026	3	6	251
25027	3	7	251
25028	3	8	251
25029	3	9	251
25030	3	10	251
25031	4	1	251
25032	4	2	251
25033	4	3	251
25034	4	4	251
25035	4	5	251
25036	4	6	251
25037	4	7	251
25038	4	8	251
25039	4	9	251
25040	4	10	251
25041	5	1	251
25042	5	2	251
25043	5	3	251
25044	5	4	251
25045	5	5	251
25046	5	6	251
25047	5	7	251
25048	5	8	251
25049	5	9	251
25050	5	10	251
25051	6	1	251
25052	6	2	251
25053	6	3	251
25054	6	4	251
25055	6	5	251
25056	6	6	251
25057	6	7	251
25058	6	8	251
25059	6	9	251
25060	6	10	251
25061	7	1	251
25062	7	2	251
25063	7	3	251
25064	7	4	251
25065	7	5	251
25066	7	6	251
25067	7	7	251
25068	7	8	251
25069	7	9	251
25070	7	10	251
25071	8	1	251
25072	8	2	251
25073	8	3	251
25074	8	4	251
25075	8	5	251
25076	8	6	251
25077	8	7	251
25078	8	8	251
25079	8	9	251
25080	8	10	251
25081	9	1	251
25082	9	2	251
25083	9	3	251
25084	9	4	251
25085	9	5	251
25086	9	6	251
25087	9	7	251
25088	9	8	251
25089	9	9	251
25090	9	10	251
25091	10	1	251
25092	10	2	251
25093	10	3	251
25094	10	4	251
25095	10	5	251
25096	10	6	251
25097	10	7	251
25098	10	8	251
25099	10	9	251
25100	10	10	251
25101	1	1	252
25102	1	2	252
25103	1	3	252
25104	1	4	252
25105	1	5	252
25106	1	6	252
25107	1	7	252
25108	1	8	252
25109	1	9	252
25110	1	10	252
25111	2	1	252
25112	2	2	252
25113	2	3	252
25114	2	4	252
25115	2	5	252
25116	2	6	252
25117	2	7	252
25118	2	8	252
25119	2	9	252
25120	2	10	252
25121	3	1	252
25122	3	2	252
25123	3	3	252
25124	3	4	252
25125	3	5	252
25126	3	6	252
25127	3	7	252
25128	3	8	252
25129	3	9	252
25130	3	10	252
25131	4	1	252
25132	4	2	252
25133	4	3	252
25134	4	4	252
25135	4	5	252
25136	4	6	252
25137	4	7	252
25138	4	8	252
25139	4	9	252
25140	4	10	252
25141	5	1	252
25142	5	2	252
25143	5	3	252
25144	5	4	252
25145	5	5	252
25146	5	6	252
25147	5	7	252
25148	5	8	252
25149	5	9	252
25150	5	10	252
25151	6	1	252
25152	6	2	252
25153	6	3	252
25154	6	4	252
25155	6	5	252
25156	6	6	252
25157	6	7	252
25158	6	8	252
25159	6	9	252
25160	6	10	252
25161	7	1	252
25162	7	2	252
25163	7	3	252
25164	7	4	252
25165	7	5	252
25166	7	6	252
25167	7	7	252
25168	7	8	252
25169	7	9	252
25170	7	10	252
25171	8	1	252
25172	8	2	252
25173	8	3	252
25174	8	4	252
25175	8	5	252
25176	8	6	252
25177	8	7	252
25178	8	8	252
25179	8	9	252
25180	8	10	252
25181	9	1	252
25182	9	2	252
25183	9	3	252
25184	9	4	252
25185	9	5	252
25186	9	6	252
25187	9	7	252
25188	9	8	252
25189	9	9	252
25190	9	10	252
25191	10	1	252
25192	10	2	252
25193	10	3	252
25194	10	4	252
25195	10	5	252
25196	10	6	252
25197	10	7	252
25198	10	8	252
25199	10	9	252
25200	10	10	252
25201	1	1	253
25202	1	2	253
25203	1	3	253
25204	1	4	253
25205	1	5	253
25206	1	6	253
25207	1	7	253
25208	1	8	253
25209	1	9	253
25210	1	10	253
25211	2	1	253
25212	2	2	253
25213	2	3	253
25214	2	4	253
25215	2	5	253
25216	2	6	253
25217	2	7	253
25218	2	8	253
25219	2	9	253
25220	2	10	253
25221	3	1	253
25222	3	2	253
25223	3	3	253
25224	3	4	253
25225	3	5	253
25226	3	6	253
25227	3	7	253
25228	3	8	253
25229	3	9	253
25230	3	10	253
25231	4	1	253
25232	4	2	253
25233	4	3	253
25234	4	4	253
25235	4	5	253
25236	4	6	253
25237	4	7	253
25238	4	8	253
25239	4	9	253
25240	4	10	253
25241	5	1	253
25242	5	2	253
25243	5	3	253
25244	5	4	253
25245	5	5	253
25246	5	6	253
25247	5	7	253
25248	5	8	253
25249	5	9	253
25250	5	10	253
25251	6	1	253
25252	6	2	253
25253	6	3	253
25254	6	4	253
25255	6	5	253
25256	6	6	253
25257	6	7	253
25258	6	8	253
25259	6	9	253
25260	6	10	253
25261	7	1	253
25262	7	2	253
25263	7	3	253
25264	7	4	253
25265	7	5	253
25266	7	6	253
25267	7	7	253
25268	7	8	253
25269	7	9	253
25270	7	10	253
25271	8	1	253
25272	8	2	253
25273	8	3	253
25274	8	4	253
25275	8	5	253
25276	8	6	253
25277	8	7	253
25278	8	8	253
25279	8	9	253
25280	8	10	253
25281	9	1	253
25282	9	2	253
25283	9	3	253
25284	9	4	253
25285	9	5	253
25286	9	6	253
25287	9	7	253
25288	9	8	253
25289	9	9	253
25290	9	10	253
25291	10	1	253
25292	10	2	253
25293	10	3	253
25294	10	4	253
25295	10	5	253
25296	10	6	253
25297	10	7	253
25298	10	8	253
25299	10	9	253
25300	10	10	253
25301	1	1	254
25302	1	2	254
25303	1	3	254
25304	1	4	254
25305	1	5	254
25306	1	6	254
25307	1	7	254
25308	1	8	254
25309	1	9	254
25310	1	10	254
25311	2	1	254
25312	2	2	254
25313	2	3	254
25314	2	4	254
25315	2	5	254
25316	2	6	254
25317	2	7	254
25318	2	8	254
25319	2	9	254
25320	2	10	254
25321	3	1	254
25322	3	2	254
25323	3	3	254
25324	3	4	254
25325	3	5	254
25326	3	6	254
25327	3	7	254
25328	3	8	254
25329	3	9	254
25330	3	10	254
25331	4	1	254
25332	4	2	254
25333	4	3	254
25334	4	4	254
25335	4	5	254
25336	4	6	254
25337	4	7	254
25338	4	8	254
25339	4	9	254
25340	4	10	254
25341	5	1	254
25342	5	2	254
25343	5	3	254
25344	5	4	254
25345	5	5	254
25346	5	6	254
25347	5	7	254
25348	5	8	254
25349	5	9	254
25350	5	10	254
25351	6	1	254
25352	6	2	254
25353	6	3	254
25354	6	4	254
25355	6	5	254
25356	6	6	254
25357	6	7	254
25358	6	8	254
25359	6	9	254
25360	6	10	254
25361	7	1	254
25362	7	2	254
25363	7	3	254
25364	7	4	254
25365	7	5	254
25366	7	6	254
25367	7	7	254
25368	7	8	254
25369	7	9	254
25370	7	10	254
25371	8	1	254
25372	8	2	254
25373	8	3	254
25374	8	4	254
25375	8	5	254
25376	8	6	254
25377	8	7	254
25378	8	8	254
25379	8	9	254
25380	8	10	254
25381	9	1	254
25382	9	2	254
25383	9	3	254
25384	9	4	254
25385	9	5	254
25386	9	6	254
25387	9	7	254
25388	9	8	254
25389	9	9	254
25390	9	10	254
25391	10	1	254
25392	10	2	254
25393	10	3	254
25394	10	4	254
25395	10	5	254
25396	10	6	254
25397	10	7	254
25398	10	8	254
25399	10	9	254
25400	10	10	254
25401	1	1	255
25402	1	2	255
25403	1	3	255
25404	1	4	255
25405	1	5	255
25406	1	6	255
25407	1	7	255
25408	1	8	255
25409	1	9	255
25410	1	10	255
25411	2	1	255
25412	2	2	255
25413	2	3	255
25414	2	4	255
25415	2	5	255
25416	2	6	255
25417	2	7	255
25418	2	8	255
25419	2	9	255
25420	2	10	255
25421	3	1	255
25422	3	2	255
25423	3	3	255
25424	3	4	255
25425	3	5	255
25426	3	6	255
25427	3	7	255
25428	3	8	255
25429	3	9	255
25430	3	10	255
25431	4	1	255
25432	4	2	255
25433	4	3	255
25434	4	4	255
25435	4	5	255
25436	4	6	255
25437	4	7	255
25438	4	8	255
25439	4	9	255
25440	4	10	255
25441	5	1	255
25442	5	2	255
25443	5	3	255
25444	5	4	255
25445	5	5	255
25446	5	6	255
25447	5	7	255
25448	5	8	255
25449	5	9	255
25450	5	10	255
25451	6	1	255
25452	6	2	255
25453	6	3	255
25454	6	4	255
25455	6	5	255
25456	6	6	255
25457	6	7	255
25458	6	8	255
25459	6	9	255
25460	6	10	255
25461	7	1	255
25462	7	2	255
25463	7	3	255
25464	7	4	255
25465	7	5	255
25466	7	6	255
25467	7	7	255
25468	7	8	255
25469	7	9	255
25470	7	10	255
25471	8	1	255
25472	8	2	255
25473	8	3	255
25474	8	4	255
25475	8	5	255
25476	8	6	255
25477	8	7	255
25478	8	8	255
25479	8	9	255
25480	8	10	255
25481	9	1	255
25482	9	2	255
25483	9	3	255
25484	9	4	255
25485	9	5	255
25486	9	6	255
25487	9	7	255
25488	9	8	255
25489	9	9	255
25490	9	10	255
25491	10	1	255
25492	10	2	255
25493	10	3	255
25494	10	4	255
25495	10	5	255
25496	10	6	255
25497	10	7	255
25498	10	8	255
25499	10	9	255
25500	10	10	255
25501	1	1	256
25502	1	2	256
25503	1	3	256
25504	1	4	256
25505	1	5	256
25506	1	6	256
25507	1	7	256
25508	1	8	256
25509	1	9	256
25510	1	10	256
25511	2	1	256
25512	2	2	256
25513	2	3	256
25514	2	4	256
25515	2	5	256
25516	2	6	256
25517	2	7	256
25518	2	8	256
25519	2	9	256
25520	2	10	256
25521	3	1	256
25522	3	2	256
25523	3	3	256
25524	3	4	256
25525	3	5	256
25526	3	6	256
25527	3	7	256
25528	3	8	256
25529	3	9	256
25530	3	10	256
25531	4	1	256
25532	4	2	256
25533	4	3	256
25534	4	4	256
25535	4	5	256
25536	4	6	256
25537	4	7	256
25538	4	8	256
25539	4	9	256
25540	4	10	256
25541	5	1	256
25542	5	2	256
25543	5	3	256
25544	5	4	256
25545	5	5	256
25546	5	6	256
25547	5	7	256
25548	5	8	256
25549	5	9	256
25550	5	10	256
25551	6	1	256
25552	6	2	256
25553	6	3	256
25554	6	4	256
25555	6	5	256
25556	6	6	256
25557	6	7	256
25558	6	8	256
25559	6	9	256
25560	6	10	256
25561	7	1	256
25562	7	2	256
25563	7	3	256
25564	7	4	256
25565	7	5	256
25566	7	6	256
25567	7	7	256
25568	7	8	256
25569	7	9	256
25570	7	10	256
25571	8	1	256
25572	8	2	256
25573	8	3	256
25574	8	4	256
25575	8	5	256
25576	8	6	256
25577	8	7	256
25578	8	8	256
25579	8	9	256
25580	8	10	256
25581	9	1	256
25582	9	2	256
25583	9	3	256
25584	9	4	256
25585	9	5	256
25586	9	6	256
25587	9	7	256
25588	9	8	256
25589	9	9	256
25590	9	10	256
25591	10	1	256
25592	10	2	256
25593	10	3	256
25594	10	4	256
25595	10	5	256
25596	10	6	256
25597	10	7	256
25598	10	8	256
25599	10	9	256
25600	10	10	256
25601	1	1	257
25602	1	2	257
25603	1	3	257
25604	1	4	257
25605	1	5	257
25606	1	6	257
25607	1	7	257
25608	1	8	257
25609	1	9	257
25610	1	10	257
25611	2	1	257
25612	2	2	257
25613	2	3	257
25614	2	4	257
25615	2	5	257
25616	2	6	257
25617	2	7	257
25618	2	8	257
25619	2	9	257
25620	2	10	257
25621	3	1	257
25622	3	2	257
25623	3	3	257
25624	3	4	257
25625	3	5	257
25626	3	6	257
25627	3	7	257
25628	3	8	257
25629	3	9	257
25630	3	10	257
25631	4	1	257
25632	4	2	257
25633	4	3	257
25634	4	4	257
25635	4	5	257
25636	4	6	257
25637	4	7	257
25638	4	8	257
25639	4	9	257
25640	4	10	257
25641	5	1	257
25642	5	2	257
25643	5	3	257
25644	5	4	257
25645	5	5	257
25646	5	6	257
25647	5	7	257
25648	5	8	257
25649	5	9	257
25650	5	10	257
25651	6	1	257
25652	6	2	257
25653	6	3	257
25654	6	4	257
25655	6	5	257
25656	6	6	257
25657	6	7	257
25658	6	8	257
25659	6	9	257
25660	6	10	257
25661	7	1	257
25662	7	2	257
25663	7	3	257
25664	7	4	257
25665	7	5	257
25666	7	6	257
25667	7	7	257
25668	7	8	257
25669	7	9	257
25670	7	10	257
25671	8	1	257
25672	8	2	257
25673	8	3	257
25674	8	4	257
25675	8	5	257
25676	8	6	257
25677	8	7	257
25678	8	8	257
25679	8	9	257
25680	8	10	257
25681	9	1	257
25682	9	2	257
25683	9	3	257
25684	9	4	257
25685	9	5	257
25686	9	6	257
25687	9	7	257
25688	9	8	257
25689	9	9	257
25690	9	10	257
25691	10	1	257
25692	10	2	257
25693	10	3	257
25694	10	4	257
25695	10	5	257
25696	10	6	257
25697	10	7	257
25698	10	8	257
25699	10	9	257
25700	10	10	257
25701	1	1	258
25702	1	2	258
25703	1	3	258
25704	1	4	258
25705	1	5	258
25706	1	6	258
25707	1	7	258
25708	1	8	258
25709	1	9	258
25710	1	10	258
25711	2	1	258
25712	2	2	258
25713	2	3	258
25714	2	4	258
25715	2	5	258
25716	2	6	258
25717	2	7	258
25718	2	8	258
25719	2	9	258
25720	2	10	258
25721	3	1	258
25722	3	2	258
25723	3	3	258
25724	3	4	258
25725	3	5	258
25726	3	6	258
25727	3	7	258
25728	3	8	258
25729	3	9	258
25730	3	10	258
25731	4	1	258
25732	4	2	258
25733	4	3	258
25734	4	4	258
25735	4	5	258
25736	4	6	258
25737	4	7	258
25738	4	8	258
25739	4	9	258
25740	4	10	258
25741	5	1	258
25742	5	2	258
25743	5	3	258
25744	5	4	258
25745	5	5	258
25746	5	6	258
25747	5	7	258
25748	5	8	258
25749	5	9	258
25750	5	10	258
25751	6	1	258
25752	6	2	258
25753	6	3	258
25754	6	4	258
25755	6	5	258
25756	6	6	258
25757	6	7	258
25758	6	8	258
25759	6	9	258
25760	6	10	258
25761	7	1	258
25762	7	2	258
25763	7	3	258
25764	7	4	258
25765	7	5	258
25766	7	6	258
25767	7	7	258
25768	7	8	258
25769	7	9	258
25770	7	10	258
25771	8	1	258
25772	8	2	258
25773	8	3	258
25774	8	4	258
25775	8	5	258
25776	8	6	258
25777	8	7	258
25778	8	8	258
25779	8	9	258
25780	8	10	258
25781	9	1	258
25782	9	2	258
25783	9	3	258
25784	9	4	258
25785	9	5	258
25786	9	6	258
25787	9	7	258
25788	9	8	258
25789	9	9	258
25790	9	10	258
25791	10	1	258
25792	10	2	258
25793	10	3	258
25794	10	4	258
25795	10	5	258
25796	10	6	258
25797	10	7	258
25798	10	8	258
25799	10	9	258
25800	10	10	258
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.tickets (id, transactionurl, viewerid, sessionid, spotid) FROM stdin;
20408	https://transaction.rufa79326efbf7f863ffbb01ba90d15c0a	246	32	1
20409	https://transaction.rua41f295ca07e0ab5691d182dc3f94514	170	30	1
20410	https://transaction.rua7143b873fae60ef364dc85cecf917ba	292	34	1
20411	https://transaction.ru2d1b232fad44e2bbc83d5ad525fb922c	91	30	2
20412	https://transaction.ru15687eccc7b6cd766759c800650b3374	220	31	2
20413	https://transaction.ru6c0b57576889d4bd1695d30365d7b535	88	31	3
20414	https://transaction.ruf6b2e4ab36bb249b34669c5c17ccd935	266	30	4
20415	https://transaction.rud4e06a2632276e65a66392b19847fac7	190	32	5
20416	https://transaction.ruab35df3525c4a810690896dd7d25cff8	180	33	6
20417	https://transaction.ru8284c2a9820ee341a7c96a5cd1a68827	197	34	7
20418	https://transaction.rud3cd62550e5c266deaf7d6925a21d1c2	9	33	7
20419	https://transaction.ru835ba8cee92cbc8639c9c2288bc4c940	233	31	7
20420	https://transaction.ruadbdd5431a962282afda4c6897843c78	251	30	7
20421	https://transaction.ru94ad60031fbd7594fc85bdf3397e0bf0	283	32	7
20422	https://transaction.ru7c74c970a5db3a859d2943efaac86956	137	32	8
20423	https://transaction.ruf7898aca8f3ab8d5aede5b6d1dba61aa	122	31	9
20424	https://transaction.ru8d7b3b38f97a15cf342f29002b3d2956	86	30	9
20425	https://transaction.ru191511aba2982eef0e3668da2b9cb130	59	33	10
20426	https://transaction.rub0c133d6124042b09d41b8633dd2e9d0	203	34	13
20427	https://transaction.rub00bbf8478c165b315a146683ed4d0d4	158	33	13
20428	https://transaction.rue41f5a1281289cd1a049d985977141ae	6	30	13
20429	https://transaction.ruabdc9821b8ad02b7a7cbbd9729aa7d5b	239	32	14
20430	https://transaction.ru9b62039fb79c91541ac15d37fc3a9f56	115	30	14
20431	https://transaction.ru29701b2a311e49efb54340186022558f	299	33	14
20432	https://transaction.ru598ca69f3415fda5f68387c0ec67a753	200	34	14
20433	https://transaction.rufc4a0c176cd7207a70c71dea16498af3	195	31	15
20434	https://transaction.ruca5e9c7fe4ba2457d6da5b2bfcecb0f4	243	32	15
20435	https://transaction.ru72bd2b719153e77168340889d6ec7e5b	212	32	16
20436	https://transaction.ru6219bf4102242a07bd1f7688ce097b14	155	31	17
20437	https://transaction.ru59cf6b30215ebe87a5b5d747ed061eb7	169	32	18
20438	https://transaction.ru100753d0d8b4b42ab41266140b9dc742	276	31	18
20439	https://transaction.ru135f0934352b9574907e278e0687ff36	111	30	18
20440	https://transaction.rue5b431bdce34f662c94d3feda506bad3	257	30	19
20441	https://transaction.ru9977944ab2c185e1377f8925373cd3c9	246	33	19
20442	https://transaction.ru2a1f3306ffd69301da32a98461a06020	119	34	19
20443	https://transaction.ru91feb1c8067353944d41cb02d0fa8455	228	34	20
20444	https://transaction.ruffed1dfb3f479efae11b32df527ce4f8	185	33	20
20445	https://transaction.ru13c5761fbc4d10bc361221c281f84190	240	32	20
20446	https://transaction.ru52f89ffc6704ecc920e0a3e8575b425d	245	30	22
20447	https://transaction.ru693ba9a344f3e2a5be083e7a99f1ebee	180	33	22
20448	https://transaction.ru5c55124f7525574c6c41fa655e5bab33	95	34	23
20449	https://transaction.ru525bbcb891d6152b37d2f5af20498c24	45	31	23
20450	https://transaction.ru0790a189e9528b70e04acf22e57e3505	231	33	24
20451	https://transaction.ru8ef0230cb81976460e6b89f1157a98ae	208	34	25
20452	https://transaction.ru1c42d12485b34884e466a83b26099387	289	30	25
20453	https://transaction.rub5896801253e7837edc50b1ae9c8da7e	201	30	28
20454	https://transaction.rube21772c33e390834c3304027ba8652f	37	31	28
20455	https://transaction.ru5ccc5b78e7cacfbbb79aa31defeb05db	131	30	29
20456	https://transaction.ru5437cf5be7a8ebee29272f2f3a2800f9	200	32	30
20457	https://transaction.rueea36dec8510b4993f7a55c5adf25465	216	34	30
20458	https://transaction.ru3ae04cd9569705cc18fd51df7e870279	274	34	31
20459	https://transaction.ru05f37187ef42823caacb3df940a4bddb	96	33	31
20460	https://transaction.ru5cc3e3da89ec8603bace363593d2bf6e	16	34	32
20461	https://transaction.ruc1981372e820494b18a4508f50ffc41a	251	34	33
20462	https://transaction.ruae183deab29abf38d2c512ecd2d9102b	158	32	33
20463	https://transaction.rub2831dc3c58a1344cacd61e218f81644	273	30	34
20464	https://transaction.ruc65b683de1f7ff56525356e99dae1f11	6	31	35
20465	https://transaction.ru242042cd09eec2aa2770a7ba2a3cd2e8	77	33	35
20466	https://transaction.ruc8a37de5e6b57277dead3b5c895f64f7	288	34	35
20467	https://transaction.ru2f205fce80848c922997ba61d2ee2207	111	34	36
20468	https://transaction.rud5934a945fe77b7c540eeb8921eb78f3	113	30	36
20469	https://transaction.ru45bf3d5c56fa0ce1ed7720b687dabf3b	96	34	37
20470	https://transaction.ru00671cf14141e9c6c6c601554efcb624	100	33	38
20471	https://transaction.ru3dc0f3b0f192a9b28bd0200340357a85	68	31	38
20472	https://transaction.ru3c95c92bf942238eacfd17749bc8a341	244	30	38
20473	https://transaction.ru05d4c2d1e4082eb3888e23b892e4b08b	232	30	39
20474	https://transaction.ru7f8439b158dc5c2f5b90c5020ee616d1	86	32	39
20475	https://transaction.ru1eaee6d29a9fb3179389e713ada487b3	55	31	40
20476	https://transaction.ruc9fd67f035c18baf50e27028635bdcf2	297	30	40
20477	https://transaction.ru49a823699f68fa890fec71e06a40a49a	12	30	41
20478	https://transaction.rufedb96a83cd5808d674627934d09ea1e	20	33	41
20479	https://transaction.ru3f5e40dd697274a9fe9157ca2358edd6	204	34	42
20480	https://transaction.ru3530a006d73b6853c79655b71a682194	30	32	42
20481	https://transaction.ru9244f3900c0ed3c2dad5d456a6d33fd6	159	31	42
20482	https://transaction.ru73298abdee505b72c873780c1058c939	127	31	43
20483	https://transaction.ru1c901825df193dc6da078e1df51a7f28	170	32	44
20484	https://transaction.ruda8e3b402992820600758376153d4df2	77	31	44
20485	https://transaction.rubfdb9334dd12811c4177bbb07d9c1818	24	32	45
20486	https://transaction.ru169815f02f64c27892abeff570581011	208	34	45
20487	https://transaction.rue88fd9689001965d3a92867a6962900b	8	33	46
20488	https://transaction.ru8c4252b4d0ad7a498133e7b76a1c954c	64	33	47
20489	https://transaction.rucee41580a494ecb3db7947968fe4f7cf	254	32	47
20490	https://transaction.ru8f7f39ef6ebe3ffe473a8f090c3e8517	90	30	47
20491	https://transaction.ru793bd4a1d9f372abcf4a82c70997f5fc	2	30	48
20492	https://transaction.rub420a0f33cad260de706b3725064d7a5	219	34	48
20493	https://transaction.ru56ddcd7fbf91004eb096013b37dc39df	291	33	49
20494	https://transaction.ru0833ac55e5faeebf93380eb9eefc9e6f	194	34	49
20495	https://transaction.ru9d89ffc2e0bf12a507b5efbadf353248	238	32	49
20496	https://transaction.ru2add55db12a2b3dc83595b7ca4356815	255	31	49
20497	https://transaction.ru5f7e394195bd3720b178bc741e7bfff1	174	30	50
20498	https://transaction.ruf74e1b3afff9684263d43e126f962d9d	211	30	51
20499	https://transaction.rue5e9192a5658fc12e1d1dd838936eb4d	248	32	51
20500	https://transaction.ruec337f29099895f06c7f312ad4fea863	56	33	51
20501	https://transaction.ru5d1e56f935fcb6e5ee964d32a10ab538	229	34	52
20502	https://transaction.ru22d6686fe2eefadc94407e740fb600dd	180	31	52
20503	https://transaction.rub412347c78ebfd6f45811c790b096b63	77	32	53
20504	https://transaction.ru25d3d187c229b97df0f8afdbdae57f83	112	33	53
20505	https://transaction.ru35e1773e8b243d5e1288050cd8bd9805	53	32	54
20506	https://transaction.rua2bbd2f3a6e64c9e2c564e0d99a6d09a	241	30	54
20507	https://transaction.ru53c1d7638dc1f999927a88a4b28449c7	100	32	56
20508	https://transaction.ru2104418742bef0f789cd918461ce8c08	268	32	58
20509	https://transaction.ru4d62cfb8f8e7d5e4d21bb53f74120df5	225	30	59
20510	https://transaction.ru2d49c7156014bcfab634d9ce4344c457	208	34	60
20511	https://transaction.ru7ff67120156bd4a048934b96d42033f4	75	34	61
20512	https://transaction.rue40c0bf72dedca87506270e419729629	293	30	61
20513	https://transaction.ru22c949d8becbc6f7743d28bbc96675a3	46	30	62
20514	https://transaction.rua1e8d34db014d0d22419e43dd12f9980	60	30	63
20515	https://transaction.ru38862237f701dd26bc89bb7906950b3a	116	32	63
20516	https://transaction.rua13f46ffe49d7886bb1268db66cf22f4	38	34	63
20517	https://transaction.ru01e3dd6edd7f45f0db255080dd82d6fb	61	33	63
20518	https://transaction.ru3bb132b29eda450fc830763b4687f7d7	199	30	64
20519	https://transaction.ru03ae9e2efc1c9f1502053e3a76ae05e7	85	31	64
20520	https://transaction.ru5a0f6213323c151819268b061450dc21	151	31	65
20521	https://transaction.ru86151b263565b45bd3b7a4912dbde35d	55	32	66
20522	https://transaction.rua717a5e750dcb2be7b48358179e55093	295	34	66
20523	https://transaction.ru9d0b61068b72b58f1bbae7c6c9ade8d2	116	34	67
20524	https://transaction.ru973a0378f07d46b0bd6eedc8226ebd39	59	30	67
20525	https://transaction.ru50b235652b90d5ab1aad336eaf4e9ba9	191	31	68
20526	https://transaction.rufd50070a6b07d58c9379aee6cb8ba4bd	202	32	68
20527	https://transaction.rudd116e5cd407aea885be4e1d25d65fc0	58	33	68
20528	https://transaction.rua46a1fe5a99617c49d3f6de9885b7170	106	34	69
20529	https://transaction.ruc72ac2e229d19f06cae764acabd5604b	151	32	69
20530	https://transaction.ru6ec0a334a7f50d8e9b4e3ed62d0ff058	125	32	71
20531	https://transaction.ru02c39253335b8ab31df1ea9f4f34389b	276	30	72
20532	https://transaction.ruc7ca7564eb5b2dd4635c6300cd795bf1	254	32	72
20533	https://transaction.ruf5a89b935404ec960f664d712b8d3b59	170	33	72
20534	https://transaction.ru296aeeaeaeb8ef7b7ea2bb5894968e6b	23	34	73
20535	https://transaction.ru6c3d69a598c90c0fedb5eca274c6a6d2	287	33	73
20536	https://transaction.ru53a738beb939fde01527390d0111a747	148	30	73
20537	https://transaction.ru941ce9a425b5d2af8cfde7ab0de58a6b	28	31	74
20538	https://transaction.ru852b313b9fcdc48344ae05e69d9c7e54	177	32	74
20539	https://transaction.rue9e12e102091001d2940432e9ab8d399	197	33	74
20540	https://transaction.ru74382b603df4a14cc8dc4ea375ddbc64	218	34	74
20541	https://transaction.ru84752d9be2ef85143e182d5c6b0f31f3	185	33	75
20542	https://transaction.ru0918a94f9c2e4fc713a5fb8cf01706d2	130	30	75
20543	https://transaction.rucc00acf0ed037aa542ee00204b2f1c45	241	30	76
20544	https://transaction.ru401b8685dfbd960da3c892ef9fe1a872	117	32	76
20545	https://transaction.ru65fd217409c28bf13b2580f38cee3d09	278	33	76
20546	https://transaction.ru614ecbcd5a0e7bace7a3682c01daa461	182	34	77
20547	https://transaction.rufd69e8ae4fe8f57604a90343f31d6a86	151	30	77
20548	https://transaction.ruf8556d25bafb2e19434c8e031bbb940b	240	32	77
20549	https://transaction.ru6b56fd85ce983cb9b46298d161c78b42	138	32	78
20550	https://transaction.rub7d7ca20edf0ade0bfecf17de82f10cf	261	32	79
20551	https://transaction.ru7920f7fa5a0bbec8e87499445610bccb	56	30	80
20552	https://transaction.ru9d3daf0ab9462e42d6a538aa20039521	224	32	80
20553	https://transaction.ru49e43899659f174e0fd46798c5e30910	183	31	80
20554	https://transaction.ru43a221e6d99453608fa3cede8b093df4	83	32	81
20555	https://transaction.ru53426a2b7ec517a7d19df404c00d049c	142	30	82
20556	https://transaction.ru24ce751285fdb3c25439e5e10303599f	223	32	82
20557	https://transaction.ru906b2226735091a2bfa213c1e158c579	15	30	84
20558	https://transaction.ru1f625ae59d2f786d5b0167734f4754d1	53	34	84
20559	https://transaction.ruface19f8c3d41b9a113e751fcb9c4600	224	33	84
20560	https://transaction.ru34b01f046b284891ab3bf311cb2dfafe	220	34	85
20561	https://transaction.rub51f3eefdd1e7e05d285e3e6de40f68a	294	31	86
20562	https://transaction.rua27308056dfff885d68312c1a942974f	31	31	87
20563	https://transaction.ru27af3bde50054c550055a9ac677112bf	213	32	87
20564	https://transaction.ru060291d2caedaad87d564857dd01765d	203	32	88
20565	https://transaction.rub949810dd2653389b2943da9d3cfc552	283	31	89
20566	https://transaction.ru1c11a5c3526781436bbd7854d3247e6f	97	32	89
20567	https://transaction.ru274a156434afcb6a0161dc4c6f1aa751	154	33	89
20568	https://transaction.rudfc0ddf31f87eeef737ffb16705467b5	277	30	90
20569	https://transaction.rueb8e8a4a6f7285089d66178e84875eb8	106	30	91
20570	https://transaction.ru385aacdd9058c468e8c8907191bb7bbc	135	32	92
20571	https://transaction.rue5a16b82f210bd7c50e0a26b487453f3	183	33	94
20572	https://transaction.ru36bad1bb2f897124beba50247b6d4191	57	34	94
20573	https://transaction.ru2ed268e36a53e8220332119cf51ec051	54	33	96
20574	https://transaction.ru3d8ade16737dd854575361248dd43717	33	34	96
20575	https://transaction.ru6115d9ff50acec95c6f19e39ebbde6f0	129	33	97
20576	https://transaction.ru46652bb381fe7ab60912e0a397c87453	157	32	97
20577	https://transaction.ru66249864753a3e0dfde95e0cbc00250b	260	30	97
20578	https://transaction.ru4a65fd714997aaca6455b8d338cc61c6	255	32	98
20579	https://transaction.ruf52b2657c9fdfc0dec6ffda4a90ecad3	92	33	98
20580	https://transaction.ru3d0474526885eb1524a49e813d6fa777	165	34	98
20581	https://transaction.rua1aebecaac213fe0c55a58f03f6e8d9f	117	32	99
20582	https://transaction.rue86431c2b537d4d54cfcd70807327c29	162	34	100
20583	https://transaction.rub950f5e63610afad7bf8b2bd8f67e788	248	89	101
20584	https://transaction.ru99c8e67ed2bd530ba32352c0a6debb33	37	58	101
20585	https://transaction.ru3a4730d703392b801a7f44e2ebef318f	49	60	101
20586	https://transaction.rud0c202f3730176da5acd26eb8c719773	138	59	101
20587	https://transaction.ru440db60529c932b2ad32801a88c28876	214	87	101
20588	https://transaction.ru1ae97d3f26fafeb9f868da675959cdb2	6	86	101
20589	https://transaction.rua5524c559203f8f2ba9bd02d164a65ce	234	90	102
20590	https://transaction.ru2addb94f4b990cd83e1eb4f637b3471c	298	89	102
20591	https://transaction.ruefe83ab6c31d94d20e38adb7cb543d77	54	60	102
20592	https://transaction.ru458c125715f356765114e94ebd458835	149	60	103
20593	https://transaction.ru3dc0d2030da1f2043f7ce1d7bba163b9	112	90	103
20594	https://transaction.rucf99574ef0a72cf3d0fae491fe541f57	113	58	104
20595	https://transaction.ru7872eafa74b9bebcf6ac945ff4259f61	95	62	104
20596	https://transaction.ru8a23c66f21891c19a495aa19302ad788	185	90	105
20597	https://transaction.ru0ed91d98241239178228e67c04cbae46	286	89	105
20598	https://transaction.ruff5f107472041a3873a04e5450779cd9	34	89	106
20599	https://transaction.ru1af42c7784afcb514c42fd99250d25ef	232	62	106
20600	https://transaction.ru0ea5accb8b01c89c1982f120b313750a	19	61	106
20601	https://transaction.ru06b954527a4d49125816f8511a97a259	212	59	106
20602	https://transaction.ru6153eea6bc043ac25078d150f38d3282	273	61	107
20603	https://transaction.rub29b75f745f793ac21cd296569dfc9dd	166	87	107
20604	https://transaction.ru285068b06b888af8653cd79e5d0e5c7b	9	88	107
20605	https://transaction.ru88d935b0c93146a93fb7a0dc591843e3	73	86	107
20606	https://transaction.ru1385df561fca25a0cd495a9019957e16	53	89	107
20607	https://transaction.ru7587baa95dd1563efb0e25125297854c	10	61	108
20608	https://transaction.ru688fcc7ad281e00e4616032b289f5961	264	58	108
20609	https://transaction.ru585dc7fb614faec3542cf47141fb6c65	292	59	108
20610	https://transaction.rubc3520d7a63dcebaa57d71f910ae9943	183	60	108
20611	https://transaction.ru496eaafee914925ccef0f27503d793cb	167	86	108
20612	https://transaction.ru446efc69ea11cc1902fa2a7dde263e29	4	87	108
20613	https://transaction.ruc29d5527c2d88217f2df7f27897fdb66	78	86	109
20614	https://transaction.rue99329b32b5e4e49587129d077292aad	20	60	109
20615	https://transaction.ru3bbc2ab545c9c61504869bff96379dcd	219	62	109
20616	https://transaction.ru9503192e2499ddb5942d6745984929eb	299	61	110
20617	https://transaction.ru8f3bba58fd7d162427109df9f46be0b6	21	89	110
20618	https://transaction.ruf85b12311b0e177e365cff02b4e3212f	143	62	111
20619	https://transaction.ru289de59cbe1e0645f279ac6fba645ef8	212	59	111
20620	https://transaction.ru76ac58ae86b50cb1f6e4f32820ecea99	281	87	111
20621	https://transaction.ru002fa3ea426849f0d8cca60d2bd799b4	245	88	111
20622	https://transaction.ru835df310a95cf1f556a856fb0601178a	75	88	112
20623	https://transaction.rua593b1306c7c0ea643dca783c76fec98	153	87	112
20624	https://transaction.ru3620edae3c76c1a6b4f9641f783f0a1c	124	86	112
20625	https://transaction.rub7d5f65abe3b82498cdc4a9d0cb814ac	279	89	112
20626	https://transaction.ru8c633d8b746caf0bc9455252d21dd7f5	104	60	112
20627	https://transaction.ru1274512fa56c67771b69edce2693f92f	145	59	112
20628	https://transaction.rud46e587c040ca191b4336f45c31e9559	80	62	112
20629	https://transaction.ru708f3f3f023ada8bd6bc92d0dce41b62	105	62	113
20630	https://transaction.ru5ce252244204e330dedd4ff788801133	186	60	113
20631	https://transaction.ru8984a64fbc627c40afc2008ea27f7317	192	58	113
20632	https://transaction.ru6c011283b0a5ec44316dd10124564c2c	114	59	113
20633	https://transaction.rud06d2f9701f31c7521709621e9717f0a	53	87	113
20634	https://transaction.ru4aa95d3c2c4780e9480c939903daf68b	202	86	113
20635	https://transaction.ru38c660c74f82a216b75167debab770ed	44	89	113
20636	https://transaction.ru5a1d690f1b7956c15dcbf0a8c2a9b401	262	89	114
20637	https://transaction.ru914c62e1f3e9d41149e1acd112fb66ce	300	60	114
20638	https://transaction.rua65d3bac2d287d16d3cb71f22aaf9ff3	206	60	115
20639	https://transaction.ru70835397095594b69560950bb719079d	124	62	115
20640	https://transaction.ru3ccd67e63d028ad6630e6a18179f702f	14	88	115
20641	https://transaction.ru5daf303a0086f505754f10c95b27c7a4	68	87	116
20642	https://transaction.ru144f47da0e2ceaa3bcbaf033dd83d4ba	179	59	116
20643	https://transaction.ru180cc1fcb7ca10f07b89f970f07eb9db	11	59	117
20644	https://transaction.ru6034ca801fed5f56c2a3eaa97ec4bacc	97	58	117
20645	https://transaction.ruc547ec15e2b8a355b9fcee1b06ca83f2	182	61	117
20646	https://transaction.ruf4df82d1a53dbb497fd2258866eeede3	101	62	117
20647	https://transaction.ru0ed6172dce805dc06a38563e95837070	155	89	117
20648	https://transaction.ruaa02ce7964ac9645c41ac347387c56c4	215	89	118
20649	https://transaction.ru798ca8e08a3b6ee20e4bcfec047b34a6	176	61	118
20650	https://transaction.rue2cc2216734e38aa8e97ad9937489082	179	61	119
20651	https://transaction.rub206345c0c2998c5e9915dbc177746da	279	58	119
20652	https://transaction.ru980a8c90582002c16a0d9af460329dac	44	60	119
20653	https://transaction.ru2297b7268fac98344b6e29427c858d78	53	90	119
20654	https://transaction.ruabbcf60674d48894b8ea294e4f23b41e	183	86	119
20655	https://transaction.ru3ff517edb9a16cf68f116f68a1d4ecae	227	87	119
20656	https://transaction.ru2ea20932f97b3edcf08d3d53b7b7b54a	285	86	120
20657	https://transaction.ru9cb9461f4a7b831337f66b91361479a0	246	60	120
20658	https://transaction.rudb91a44a8a38cc549da55f235f745882	86	59	120
20659	https://transaction.ru8766531e180aa306ac524d2721bf18e8	66	88	121
20660	https://transaction.ru9909696e26cfceea778a371a4ea91fe5	102	89	121
20661	https://transaction.ru5cbc889e5f0e5d9e66ab47404550a76a	9	89	122
20662	https://transaction.ru7f55ed08312dec7f6ab110f24164cf2e	120	61	122
20663	https://transaction.ruf8020c0c71c1aeab57fdc228ed8013cc	73	62	122
20664	https://transaction.ru97bfad4237ac824a2f1cdc60c6f13ed7	248	87	122
20665	https://transaction.ru993f046901ad02a7ae4000c41cad86c8	297	89	123
20666	https://transaction.ru6de80893f9886067dc618b92d1232292	152	58	123
20667	https://transaction.ruf536f78a990416ac246ef7c966f105dd	81	58	124
20668	https://transaction.ru1c5c1d5858d260d80c8fc760bbb2438b	100	62	124
20669	https://transaction.rucf6dddc20c149a90990cfa3a35613673	49	88	124
20670	https://transaction.ru8c256541f7ba796f7b6532d394d4ea7e	282	87	125
20671	https://transaction.ru14241be5ff616fa043df63b87ad1a8ee	27	60	125
20672	https://transaction.ru72ab0b628f249bde72b15d432487d309	14	58	125
20673	https://transaction.ru66f38c005b90323e9d50c56f79eb6754	65	89	125
20674	https://transaction.ru8f83ced3768aca3b42048a6634cf321b	246	90	125
20675	https://transaction.ru4efef1753c5ada147be9f0b3d2dc4712	288	88	126
20676	https://transaction.rub3c164f720095d930d6acd5473eb526f	134	58	126
20677	https://transaction.ruc0fdd33b613baaf57944fc77d2861073	210	61	126
20678	https://transaction.rucc2198d63db3b23b065ccbac0bf82712	164	62	127
20679	https://transaction.ru0f72b30df424e75a3f5647cb1a18b0d1	84	58	127
20680	https://transaction.ru1b571bd6a0cccda01768ae4f4e93967b	63	59	128
20681	https://transaction.rucc57a63c3b21c47782553b3ff7a627ff	91	62	128
20682	https://transaction.ru137115144886fc43a9f314db0646f4ba	30	86	128
20683	https://transaction.ru6e120d27fcb417e22bfc40ca8b9d3cc1	67	88	128
20684	https://transaction.ru7bb5bfc62e14f13a78660c8377dae37b	179	88	129
20685	https://transaction.ru0b436eb3e5f95aa3f036f3b4a1aba700	126	89	129
20686	https://transaction.ru415370f7c91419e17c291e31d7bb43a0	170	62	129
20687	https://transaction.rua7c122c9473f4ebc79676c05644a3f17	40	58	129
20688	https://transaction.ru254a5946e0b3850e33532a4f18fd9bee	21	61	130
20689	https://transaction.rub8da756e2aaa88521851ba4ca0713911	138	86	130
20690	https://transaction.ru4cc7e99d4dd2443217b0a3fa25387704	156	88	130
20691	https://transaction.ruf51f6d9168f47abcd7ad25afe829c0c7	84	90	130
20692	https://transaction.ru799673d385b4e99d4f31b462c4199122	146	89	131
20693	https://transaction.ru4881a62bbd63ed58fab0ff6b0757bf36	175	62	131
20694	https://transaction.ru8ce1f3d805926eec3ea4b786073fabc0	282	58	131
20695	https://transaction.ru65980063d9a31178184db9ef41795e49	41	59	131
20696	https://transaction.ru773174d8aa4207fd2edf6c85a4e0964b	222	60	131
20697	https://transaction.ru6f163b6d6b5eb081683c141289a4574a	294	86	131
20698	https://transaction.ru972c14c0ecf8751c961d1ccd5100a594	192	88	132
20699	https://transaction.ru74d49c1a8dfd273a7fefc248d6609f71	108	90	132
20700	https://transaction.ru1d22f882570a6cd22cef84917f3592d6	53	58	132
20701	https://transaction.ru8657b860c613419be9f33f23aea62a48	19	59	132
20702	https://transaction.rucc7428bf03f111da073a0fd056730b7f	53	58	133
20703	https://transaction.ru06de2617b93e79ceea4db4a22dab82da	288	60	133
20704	https://transaction.ru522f639590b803621916b76d300800ef	70	88	133
20705	https://transaction.ru1a267f243f6115378b4f53596e285eb2	285	87	133
20706	https://transaction.ru7b6451f7bf52a633116c9b45e7bdf78c	192	59	134
20707	https://transaction.ruabb2e494d8466016a029303922ed70b8	153	90	134
20708	https://transaction.ru524d41876c594273fb98a02d0de4809d	284	89	134
20709	https://transaction.ruadb558186f26fd904f790a212650496f	142	59	135
20710	https://transaction.ru96d8d543e2d80a96aa08b6e9fbc6ea02	111	58	135
20711	https://transaction.ru1dbc6e3dc33d6ad7c7bfa219346e921f	274	61	136
20712	https://transaction.rudd59961a83efe08fc69c71ca8ab849e3	65	89	136
20713	https://transaction.ruc09768097dbe96009eea17e85da496f2	298	90	136
20714	https://transaction.ru51f4542e91b3da7f6c8f2d04881ae5e3	212	58	137
20715	https://transaction.rubab87dbde6135aa1d65388d983584420	194	58	138
20716	https://transaction.rue9fc3b6e6641e69fb8cfbdfac48709ae	190	59	138
20717	https://transaction.ruc1e95b2a226774a2e7229f3418529fef	224	62	138
20718	https://transaction.ru8a005b6bbfa78c441688ee23f5756e04	231	89	138
20719	https://transaction.ru67ad4113ae200c56e74d7177b37d9469	124	90	138
20720	https://transaction.rue8e98025305be35bfdbea13282b28aac	203	87	139
20721	https://transaction.ru65085c59ceb1020e53925f001bd4b8d4	226	58	139
20722	https://transaction.ru6320a9ce0e20c3b938ea3089ea17b28f	134	60	139
20723	https://transaction.ru9af50c5396fd1267fd85c034ecaa1429	202	60	140
20724	https://transaction.ru58e186dd21d3b77debd420a8ab720ffd	23	59	140
20725	https://transaction.ru4f02cebf5673725a4ef1b1f2f9a95080	95	61	140
20726	https://transaction.ru6049f2a52a257a9273aacfe9d93726d4	181	89	140
20727	https://transaction.ru0017da7b67c1bd6d668761686f2b5d9b	152	86	140
20728	https://transaction.ru9c78a1ce36cf29e1e9c2fc5ee3641f74	219	88	141
20729	https://transaction.ru6cbd6a9c2a295e8d5d6aeb666000b209	282	61	141
20730	https://transaction.ru1d3e544a967aa50d57d5956af7e243d3	150	60	141
20731	https://transaction.ru752ba8d260ada9009b453859f93db91b	168	59	141
20732	https://transaction.ru1f637b7bea1efe5fb5052bce680c90c6	72	58	142
20733	https://transaction.rub061a55a72d78fea9080580ce58e3289	16	60	143
20734	https://transaction.ru84dc2edc1109ef72fdb4c5be9d9a81eb	173	62	143
20735	https://transaction.ruc3d5968d455c61b8928b0a99c0d2ca18	115	87	143
20736	https://transaction.ru8f036543f5c0f42cf7daf9032e235215	54	88	143
20737	https://transaction.ru387da113ebb5d6f03dd8be47b7f9d170	200	89	143
20738	https://transaction.ruc916fb94d3ba280fd115efd1fa4326b2	74	88	144
20739	https://transaction.rud9751401ae568f79761a426426a8e857	79	87	144
20740	https://transaction.ruac6850cedc0f5f551500cb1cc38fdeaa	45	87	145
20741	https://transaction.ru563335e70679ab8d696742c3fdb7a6ea	184	88	145
20742	https://transaction.ruc12d93731acc08cfe711373f7182047c	141	62	145
20743	https://transaction.ru506e017e2ba79c46361626e21825e1ee	58	61	145
20744	https://transaction.rud65ce43dcd93494327c0635544c74776	14	60	145
20745	https://transaction.ru50c18ac2dcdaab584ae0bf533e4364d5	223	90	145
20746	https://transaction.ruffb85931ecc60c85cad897a9198bc38d	119	89	146
20747	https://transaction.rucb876850f545f58197181c7141638dd7	243	88	146
20748	https://transaction.ruc4750bf5852b2d2dde0280637fd868cf	233	58	146
20749	https://transaction.rua1f0757b89097f3ef1950deaf137d995	3	60	146
20750	https://transaction.ru9906e28c02ea1df6f2b9ca5c24aafccf	136	62	147
20751	https://transaction.ru9103c8c82514f39d8360c7430c4ee557	3	88	147
20752	https://transaction.rue0089129a96f85b9ee134c072684cdc8	103	86	148
20753	https://transaction.ru61375eac4b5aa9697ff7cf0e96cb7ac1	256	88	148
20754	https://transaction.ru207af74d3e6a09bd1e910f8738cddf1a	208	89	148
20755	https://transaction.ru18fa59f655b6ef2b4f9892237812b9cd	298	88	149
20756	https://transaction.ru1fef4bd7e3d7e901e8f7db6382d39e19	10	58	149
20757	https://transaction.ru6b85c455cb83e57c7cefc366d1ff3b7f	135	59	150
20758	https://transaction.ruf43cdc3b81b020f24c3250939bf73a1d	96	62	150
20759	https://transaction.rueff9d42f78255157c0cf279ca8b32f77	132	61	150
20760	https://transaction.ruf676492f69e3157808822fb11d39027b	243	88	150
20761	https://transaction.ru099682086d358f6ee4b41c665484b678	297	86	151
20762	https://transaction.ru23bc34476acfe6f4966dabdd91db47c9	132	58	151
20763	https://transaction.ru9a84a4beaf072827eb857233d9c6fd26	243	60	151
20764	https://transaction.ru265716f8e306a0df178119849803930a	283	59	152
20765	https://transaction.ru9dff83ac7d30817761a410aa4b5612a1	76	61	152
20766	https://transaction.rubabe8aa6e29a842a0b77d24153176ee9	75	61	153
20767	https://transaction.ru46b688c0e5c710de9dab384aaf34e601	35	58	153
20768	https://transaction.ru386a182c435d09b50d4987376785f78a	295	89	153
20769	https://transaction.ru705c4c35ebdb20280bf276ad85ecbf6d	210	88	153
20770	https://transaction.ruda4c9ff11a8bf4db96837ac50d17757c	239	86	153
20771	https://transaction.ru08fc9639833c8273eaefb1c488e12d9a	295	86	154
20772	https://transaction.ru17639c2cbd6f1a4502f5a59b53add038	226	61	154
20773	https://transaction.rub3a9a7c320a088817a7580a8a4468548	78	62	154
20774	https://transaction.rub59867ffa3ab0787fe3904e927858be7	168	90	155
20775	https://transaction.rufae2ac1e79b26ebd2bd1a9145debc538	11	89	155
20776	https://transaction.rub6d7044f51097af805a29408ab2aa895	288	88	156
20777	https://transaction.rubf11429b4887aeab728344265a3987cc	244	62	156
20778	https://transaction.ru5adaddc68ceff03f90c79016f449c880	32	60	156
20779	https://transaction.rua75276ea6c472a4d5d3aeb44e2356c21	2	58	156
20780	https://transaction.ru6712be163b81620f77285e047f70dc75	214	89	157
20781	https://transaction.ru452fcbe71990c9d4149e2638f9e06957	225	89	158
20782	https://transaction.ru6205293d381b6b46d6aa9790d2b0ab1f	176	61	158
20783	https://transaction.rua9fa15de10aee5e931a4e1e17d486a1f	140	61	159
20784	https://transaction.ru2e400a73fc6ec8cf7ac47e37888f8feb	266	58	159
20785	https://transaction.ru7d5f4515dd1979ae41f8916c9f80a312	128	90	159
20786	https://transaction.rue2233bfcd540207429071492eadfc095	261	89	159
20787	https://transaction.ru34038770a719759946839e5543ed4405	182	88	159
20788	https://transaction.ru77e89911aa0979716a349b2d5b96e2db	147	88	160
20789	https://transaction.ru73c2612c06fa472bb96479c7e2cd09b1	138	87	160
20790	https://transaction.ru37b5d349ad2e0a74faeae25b46feca49	23	58	160
20791	https://transaction.ru442f5b465d9e8cc7807e96fd4c4daef0	197	61	160
20792	https://transaction.rub3e792080027b4972ef7be65d792443a	180	90	160
20793	https://transaction.ru7aedfedce107c9c336e118da77ca3a4c	281	89	160
20794	https://transaction.ru5c2cc02f7ddd7b53400b087db0e8cffb	290	89	161
20795	https://transaction.rudc2d4c1a38e82b9feb427b4f40e057f3	167	86	161
20796	https://transaction.ru8b7a455db2f3257d5cc7e222f5bcd75d	21	87	161
20797	https://transaction.ru33c4a04447916d38b74ae72b9e42e024	211	58	162
20798	https://transaction.ru9e4627947e48bf98edba4078b3a9856b	21	59	162
20799	https://transaction.ru9286323c820f3b6a42ba23c4b90fe618	45	60	163
20800	https://transaction.ru0ff9386bc20d467f78719fb9a589b21d	288	62	163
20801	https://transaction.rubbabaddade82aade657681b63523f969	168	62	164
20802	https://transaction.ru9f3ea4adb0b13ee0ea482ff65fad761a	294	60	164
20803	https://transaction.rua6ea8471c120fe8cc35a2954c9b9c595	66	58	165
20804	https://transaction.ru75512b7e317e33cf9f4d3d0b12123f70	261	62	165
20805	https://transaction.rueac680db3e8df1a0d0d36b7f9ccd547c	243	87	165
20806	https://transaction.ru089e39e8ae1cd97ac58015060d4a4c74	22	88	166
20807	https://transaction.rub6da641bc479d5fd1ce814253de5a2a3	138	89	166
20808	https://transaction.ru5ae1ed8c3d1845cdba6c8462300f1e13	85	90	166
20809	https://transaction.ruaf8a21fbcf1b41816302c111f8019764	156	86	167
20810	https://transaction.ruf0456a85c358d619fda597ca4cb060ad	141	59	167
20811	https://transaction.ru6850dd6a578a967b1fc023840bf67672	288	60	167
20812	https://transaction.ru37e81c9fb4cf88782e764f430f7f89ec	88	58	168
20813	https://transaction.ru8aa886963fb5b5663dcba4d340b1522c	217	62	168
20814	https://transaction.ru3d54fd87aaa6c16c242f1ae27e99f095	272	88	168
20815	https://transaction.ru3cceab11e53d2c67745c223efd9aca64	33	87	168
20816	https://transaction.ru5985e72b3752e4749926885db1b45be4	79	87	169
20817	https://transaction.rubb2f165ad86c773d63ec98c142382b29	267	88	170
20818	https://transaction.ru44de9c977e0e2a1d07995ecc0d0ec8f4	26	90	171
20819	https://transaction.ru65fd8062caeabc6086e05b046c1c7405	199	62	171
20820	https://transaction.ru8c2f64f08271fc4e4351c12acee2a932	254	58	171
20821	https://transaction.ru60e0dbe6faaf520132424dfb27ed196d	281	59	171
20822	https://transaction.ru9590a3606e33b6bb22f021bbb588207b	107	60	172
20823	https://transaction.ru760230e76536eeb700f31ef575df243d	228	61	172
20824	https://transaction.ru0e13700c581a35615eeb63ad376910b0	267	87	172
20825	https://transaction.ru72c534ff50b53ca17c37b6a3d479c9c1	156	87	173
20826	https://transaction.ru98d5d2cdf96edd7a7402cfd99aeaa1f8	219	59	173
20827	https://transaction.rue33d0213ad49e67adb29bca5a38f14eb	204	89	173
20828	https://transaction.ruffbd30e5576f6ace3f3157a04891f03c	38	59	174
20829	https://transaction.ru24ff34ed18a082f93e81b3caa624b65c	192	58	175
20830	https://transaction.ru3c7097670a25a7a20935e799409ed887	34	62	175
20831	https://transaction.rua8e6ec0631f652f593e8bcf20625c298	195	59	176
20832	https://transaction.ruad99140ea7a41bf67a8db8c15328d7f4	116	87	176
20833	https://transaction.rubbecf15cf7fb6133f4bf164accb73b84	221	86	176
20834	https://transaction.ru7bed0df646b2834768284532475e68c0	130	86	177
20835	https://transaction.ru9536d7d68936c2bf48e3df93bbdd42bc	41	88	177
20836	https://transaction.ru14cf307e20ae75f0ed57dc754f83b64f	60	87	177
20837	https://transaction.ru869fa2fdcf99f5e2917e462178be8016	37	59	177
20838	https://transaction.ru6975b234598eb32cf2bb540afa968cf8	219	62	177
20839	https://transaction.ru18b0ad2e92c278e9f6f4d23bfe8d9c77	279	89	177
20840	https://transaction.rufd14cec1bf13f07ad674bd624b82c3ff	83	89	178
20841	https://transaction.rufb7381e489925d705568679154e1b9bf	144	88	178
20842	https://transaction.ru32a4660d091fe051901ed469f83e3352	4	62	178
20843	https://transaction.rua7ba65648cb8149bfcd5e6be448f1f6c	65	59	179
20844	https://transaction.rud43ec839a158dc7efa4cf0520781925b	41	88	179
20845	https://transaction.ru877a25d2c99432772b7e2139731e2fd0	237	87	180
20846	https://transaction.ru301c4f58017c2419ff854c10662be4f1	13	86	180
20847	https://transaction.ru7fdc6975b1f556824b579c2c283e5fc7	34	90	180
20848	https://transaction.rub19863258263d90b8e86588422d57e98	277	58	180
20849	https://transaction.ru3f71ea9d43c85727bb9d513689116d4e	143	60	180
20850	https://transaction.ru84ac69eb4138b96eeb2242fea0d6d9b0	267	60	181
20851	https://transaction.ru12fcf4c37589becf40a33765468dd7a5	56	61	181
20852	https://transaction.ruf499d34bd87b42948b3960b8f6b82e74	252	62	181
20853	https://transaction.ru0f1ee77127ead08e8fd27225c77444ef	280	88	181
20854	https://transaction.ru52b4d18da1e03d00a2563b3165e730f3	263	86	181
20855	https://transaction.ru88255446e9afeb90be21aa3ee9e7bd7d	162	89	181
20856	https://transaction.ru43a21f922492bf51959384478b08a9e3	24	90	181
20857	https://transaction.ru35e1bd4961d74f12ed2e2399f219aaa9	53	89	182
20858	https://transaction.ru9562795748a9c70de6a0b6069f02f06c	210	90	182
20859	https://transaction.ru394f5ce6d44514e2f440cead80df7c05	102	62	182
20860	https://transaction.ru596b3841a82e2a4988e1471632ac1a3f	63	87	182
20861	https://transaction.rub29d160afbfb902569ec9127b2224a8c	173	88	182
20862	https://transaction.ru7ea4166215075c0c71c8542ba4215d3a	257	86	183
20863	https://transaction.rub4a12cbcd48529901343570a3a3c325c	151	61	183
20864	https://transaction.ruf0aed743c6ad4370bfe3c3a94d150adf	256	61	184
20865	https://transaction.ru09998e3d1f488b4ccfc8be226e4e2f57	237	62	184
20866	https://transaction.rub6da931fe8f42475de19df070e5a11ff	188	60	184
20867	https://transaction.ru57d5fb2f8b0821b591db6842e553b8e7	271	59	184
20868	https://transaction.ruf583d969de13c4d98604563b6536f4dd	57	89	184
20869	https://transaction.ru8e8db38e3aa191df96a6cdc0b81991dc	177	59	185
20870	https://transaction.ru687bf02cf5c3039687cbc624d8c44e95	90	62	185
20871	https://transaction.rue82d86130cd55c79d02a8122dcb0569e	155	88	185
20872	https://transaction.ruc9956f6a33ca8447220e8dcb9b97d5cd	235	88	186
20873	https://transaction.ru79d75fe8db2d00b046f1329183590dac	248	86	186
20874	https://transaction.ru83942554922d41a2b959904de6fb3597	246	90	186
20875	https://transaction.ru6aa8bbfa0f2606de7aa4eb314d88b76d	127	89	186
20876	https://transaction.ru9db95bed7fecf8c4305252a4f6e12411	258	90	187
20877	https://transaction.ru4d01bcb16bc248cebc94e866369cb96f	234	88	187
20878	https://transaction.ru240109642387a3f3a737be9439542438	5	62	187
20879	https://transaction.ru1e2677482998439ed77e51580e7a8efa	177	58	187
20880	https://transaction.ru1990c733525c398a9226e73dcd23b0d4	18	62	188
20881	https://transaction.ru5d294e21f037350e878033ede923fafc	65	90	188
20882	https://transaction.ru8c8595b39d994ce9f78bb55ba7e94d6e	134	88	188
20883	https://transaction.ru24bc0a1296eecf2aac1fb9e8b12e56c0	6	61	189
20884	https://transaction.rue31e350c2cfaeea8cb3bc1d29082d75f	72	62	189
20885	https://transaction.ru22f5321cd8965dfd6888d8176595efe7	138	90	189
20886	https://transaction.ru27494938b09220f0026822cb2f583e79	151	89	190
20887	https://transaction.ruf4843f082dfa143ff26c814c95fc0da0	28	87	190
20888	https://transaction.rua826a1ae0cb2a91abac97a36c0d5e5b4	13	62	190
20889	https://transaction.ru629ca55f3cb7ebd6de55f3e18a563df1	227	58	190
20890	https://transaction.ru86e5ced38272116888647894dc659032	153	62	191
20891	https://transaction.ru9cb7b5ea641f6919eec4a49c7957c6e0	33	90	191
20892	https://transaction.rucf208d1814f0d0648efe5b788bb2e692	154	86	191
20893	https://transaction.rubf89370b145f926c03bf988ef5646d1e	96	88	192
20894	https://transaction.rub6fd1c15335f7bc93e3ce2ee3ff746e2	286	87	192
20895	https://transaction.ru1142fa7fec6ff2e2997f8322f9905152	258	61	192
20896	https://transaction.ru6a4932d3f2787d25a04b758ba68e9db2	31	58	192
20897	https://transaction.ru3a779183ceb2af909792c63d44872958	41	58	193
20898	https://transaction.rufb40090101863f3caf92269eb0f60475	81	62	193
20899	https://transaction.ru576f480491e255a81f35622807254ee7	19	88	193
20900	https://transaction.ruf6bb9cb21c712d7863a8593f639748a6	43	86	194
20901	https://transaction.ru69f1a329d06801fc5fb1fb49f0f4b06f	121	62	194
20902	https://transaction.ru05901fdf55b7b54574449cbd7ad4e337	115	59	194
20903	https://transaction.ru629b5bb00786a796fa5e276b4d5d3ad2	259	62	195
20904	https://transaction.ru1854d8953f09fb4ecc755290befc336e	65	88	195
20905	https://transaction.ru38fc5ca03fcabcb3ab14cdbb2310e28b	63	86	196
20906	https://transaction.rue613590a522ff5312bd23be8a3f1d3a8	87	61	196
20907	https://transaction.ru54462b3b0511d7ea97c8ca054e3625a7	247	62	196
20908	https://transaction.ru34ff462c2eca7365339aa7b238a9c143	78	61	197
20909	https://transaction.ru6ecbbfe760250131e535df352263fcba	287	59	197
20910	https://transaction.ruf0c5f631f2d80ea4bd026a554e5191e6	156	90	197
20911	https://transaction.ru7ce8f85e01fd3c23b6e6aa205351cf21	52	89	197
20912	https://transaction.ru007810d17b35dc7cfde2bda21f7081e2	2	89	198
20913	https://transaction.ru530e8a60f2cd6bffe4c02720da0d3d8a	109	90	198
20914	https://transaction.ru2bf95df3c8a906461171366bbbecc64b	233	86	198
20915	https://transaction.rucd80cb78d11a3aa18b68425dce4290fc	52	88	198
20916	https://transaction.ru6037a14f0a292eb9e1d489dd2a6546a9	165	61	198
20917	https://transaction.rufce9fc270dd1aa06158ed80314d97b84	251	58	199
20918	https://transaction.ru268ab11c6a3eb1c875dc7642af25055c	62	87	199
20919	https://transaction.ru1d53845743b6023f48538cb81783be02	290	88	199
20920	https://transaction.ru900b3f3a10b42acb4fe84a48e04d22fa	66	87	200
20921	https://transaction.rua0943dd63e42e9e441bab11ef905ab3d	269	86	200
20922	https://transaction.rue2e77b3a24a703e2c9835263540aefdc	192	88	200
20923	https://transaction.ru534749157d8d60076c5b40e6886c65ae	227	59	200
20924	https://transaction.ru97ccda529d31d1ed0f4e16e0f020dd56	185	61	200
20925	https://transaction.ru06652742a3f8a31acde21f44b2cfa0f2	88	95	4501
20926	https://transaction.ru1402499d834ec4b97866d1360fa76460	271	93	4501
20927	https://transaction.ru5bb5f47e81b1b6993e1e1cde23d0a11e	288	64	4501
20928	https://transaction.ruc343ad6508b1a2a4c0c8800c0dd34d8d	159	36	4501
20929	https://transaction.ru2478f263ea867250ce8fcbfd57c06fe4	276	92	4501
20930	https://transaction.ru8f3de9fc66b348bded0bf5d33344e543	147	94	4502
20931	https://transaction.ru7296e2d2f3c92451fd3878e05f8bcb81	19	65	4502
20932	https://transaction.ru263a663aecba2e8b8aa271d6e7b72c79	132	64	4502
20933	https://transaction.ru20bea4600893b47e34ff4877c34e80ad	40	35	4503
20934	https://transaction.ru5dfa3988e58c5c1628af0284c0f33cd1	263	67	4503
20935	https://transaction.ru28cb22746edad4c2f5a3a4856e79a27a	288	38	4503
20936	https://transaction.ru7325c9f708394e877b44c9934bf8c68c	44	91	4503
20937	https://transaction.rua661b7a3f1027037c752a001b7328d41	233	92	4503
20938	https://transaction.ruc5ea54ab0b9f0c0087714ba528bee08f	208	91	4504
20939	https://transaction.ru6096ac0e2e636e01fb814a5ca06a4b81	11	37	4504
20940	https://transaction.ru331a414da4e5c4e20cf7de4b481b5806	188	67	4505
20941	https://transaction.ru5b7a641afa8f65aff84c847a7d70c94a	254	91	4505
20942	https://transaction.ru3b2e053ab5cb511b2fa48a5dfbe39c34	23	93	4505
20943	https://transaction.ru884b30767823c0ef07b0a21ee9ce5511	270	95	4506
20944	https://transaction.rudf9f792c5e0d058314cc356c9017d02a	289	93	4506
20945	https://transaction.rua7367534192fac119541079b5512c441	264	67	4506
20946	https://transaction.ru62cb618fb91c3ea8608e808905abf176	247	35	4506
20947	https://transaction.ru00e71fa1a94269bb93176ca5701fc867	132	65	4506
20948	https://transaction.ru09fd465e4a25d92a834dd2e08e358fc2	193	63	4506
20949	https://transaction.ru93d960b55d9a1f67c1f351e46c7e332e	169	91	4506
20950	https://transaction.ru24fbb461686af2baddd769bd3e28620f	11	92	4506
20951	https://transaction.ruc6bf3c175cbb359af328ee8121e1f58f	296	91	4507
20952	https://transaction.ruea240cb555700dc0c552fede3db2f757	74	93	4507
20953	https://transaction.rubb03c21e275ea5f38ba01de825ca6409	24	95	4507
20954	https://transaction.ru12ac9fc277be70e4d56a4ddf26a6dda3	147	65	4507
20955	https://transaction.rube1b5fa0845dba58b1ed13c0e43fb52d	237	67	4507
20956	https://transaction.ru79f4a8252d40c4eaaa4e15c211b000d3	239	66	4507
20957	https://transaction.rue909266c6c2c9dc5d78c99da554db585	255	37	4507
20958	https://transaction.ru772149ea6b99342f8a0d792f53dbd5d3	239	37	4508
20959	https://transaction.rudfee2fa72abc7ae7ee8275a2a6123972	185	65	4508
20960	https://transaction.ruc63e1afdcf2e1c73d2ce024c3880ee77	219	66	4508
20961	https://transaction.ru4126ccb34a0c8fdae6612251ea6a4298	270	94	4508
20962	https://transaction.rub4ed71f9558ece5011c54704204713c6	50	91	4509
20963	https://transaction.ru48505df61fda658eefe967eaae0d449a	104	37	4509
20964	https://transaction.ru076f09ae37bc8febe2b318bad4f73314	172	63	4509
20965	https://transaction.rub77a38c4114d88314d5450ace742784d	23	39	4509
20966	https://transaction.ru21fb5969ee2cad7ad380be1266199bd0	17	67	4510
20967	https://transaction.rud753bb5713010d9c6d59de0050ccfbb5	209	64	4510
20968	https://transaction.rufd41fbcf4c2eb82f14a55df0abece8d5	167	92	4510
20969	https://transaction.ruc7a14e2a5a3dab5e3a8d1fac71ba9bf2	100	91	4510
20970	https://transaction.ru4effe4212a4eecd38c77f494f3b415ad	196	91	4511
20971	https://transaction.ruf5780af21ccf1e70449303846e4685c1	168	94	4511
20972	https://transaction.ru906ffbd65c8def152784cb6d2cb3bb79	194	38	4511
20973	https://transaction.rud883fbbbaa6f2fe920c8473cff098041	256	37	4511
20974	https://transaction.ru9900a03b2987a918a6fbf3a8ee631879	28	39	4512
20975	https://transaction.ru9b20bf671d3c3e03efa0193c5520f425	157	66	4512
20976	https://transaction.ru254822a9f10ff622df3a75ee08715946	54	91	4512
20977	https://transaction.ru918c41a9e89d653596efd5df9c35b90b	105	95	4512
20978	https://transaction.ru100735e5ecc7d75ab4db44c9ac45e4ea	23	95	4513
20979	https://transaction.ruc8db92b89d16eb27d56e4de41eac7a89	230	94	4513
20980	https://transaction.ru7c3e21d794be403d838d20f2fde9f262	233	35	4513
20981	https://transaction.ru5315a719894d89d0d5ebfadbcdd33e28	191	38	4513
20982	https://transaction.rua2350805dfd3f474896c843a836656a9	223	66	4514
20983	https://transaction.rubf8ab9cbee8064eee6a2d996b67f6350	223	64	4514
20984	https://transaction.ru05dc7413af46f363d5cb804c8877c902	136	65	4514
20985	https://transaction.ru2fd819aedb8a8ea84c8ec52b004e013d	290	35	4514
20986	https://transaction.ru735e7ebb3489251d2ddeca6a0b5d69d4	39	37	4514
20987	https://transaction.rua2726375ba3281674e7ac24236baf56b	246	36	4514
20988	https://transaction.ru307bd34c343595bb92124627df76d18e	281	93	4514
20989	https://transaction.ru4198fe61cf98f67cc4a202334d9c7942	116	94	4514
20990	https://transaction.ru8366833421695ddad120977272357496	23	91	4514
20991	https://transaction.ruc7627370966909d9e0b814ec843d0ec9	218	92	4515
20992	https://transaction.rudfb35e0678252675cdfd3e4f7cc45806	109	67	4515
20993	https://transaction.ru8c4f0458bae2bba10afa183316e07223	42	66	4515
20994	https://transaction.ru4c75e09b8c4f17af332616db7ae80ec6	186	64	4515
20995	https://transaction.ruad1288236b3a6b1d28115a1f92ab8bb6	73	65	4515
20996	https://transaction.ruf810756034b182f2e79af23e793d8b55	136	63	4515
20997	https://transaction.rudc42dc50fbffacbf52b2adb7354c5ebd	167	36	4516
20998	https://transaction.ruf9ff5c19148cd06c59b41cc053f546c9	139	92	4516
20999	https://transaction.ru207d8fbedc3066adb5e19419ecd689d3	87	94	4516
21000	https://transaction.ruc923779568484926964dfda82c6d8288	142	93	4517
21001	https://transaction.ru79974991721b1e24fdb58309863107fe	279	36	4517
21002	https://transaction.ruce4ec37a2d47faded0fe3e9848d1eeb6	233	65	4517
21003	https://transaction.rufcd01ec348bd27ad69d5eeaf7969e792	156	64	4517
21004	https://transaction.ru35e1105867bf24bee31f6344a1251d87	284	38	4517
21005	https://transaction.ru9a1b6f435407a76635b2145acc1bdf82	293	39	4517
21006	https://transaction.ru5191ce1ef83604760b7a5c24084c2260	152	67	4517
21007	https://transaction.ru22d2704810ddbde029baf00b4bd00092	12	91	4517
21008	https://transaction.ru00a0ce862e3c8be8cb0e9208735116b0	201	92	4517
21009	https://transaction.ru76dd6a4d77fac3809a54c77c2ec2e3bd	255	91	4518
21010	https://transaction.ru1e1aba8ee01c58aee75e099c8782888b	195	92	4518
21011	https://transaction.ru31d49a1af6eec541333c7db965b33611	58	66	4518
21012	https://transaction.rua705ac8e909bd4653ccc308be78c7868	15	64	4518
21013	https://transaction.ruaa7de37b1d94ec47fe1060cd0f90913a	135	37	4518
21014	https://transaction.ru6e66663a20834a2c2c4466ed4642ab3c	268	64	4519
21015	https://transaction.ruebb8f45efb4eed40b63077fc4ea5bcde	81	39	4519
21016	https://transaction.ru57d6ee15abb47713c723c10d53b621ea	100	94	4519
21017	https://transaction.ru9cf21471cd975b9b4edad34bae70580e	122	95	4520
21018	https://transaction.ru43e3f815cf7fe4dc813ba16eef04e1da	90	94	4520
21019	https://transaction.ru1dd43ec7b5997626da00f97228d6f61e	77	37	4520
21020	https://transaction.ru45ffa6a94664d9fa5d6fb70f8c55cc07	31	67	4520
21021	https://transaction.ruc018a0ed0ed3f66862e3bfdd3400ebd8	182	63	4520
21022	https://transaction.ru807c476b74620093f8e2bf5969ead3e7	253	35	4520
21023	https://transaction.ru05fbcf69728a5540a2f3830372a0bddb	294	35	4521
21024	https://transaction.rubb8e85b7678ee455d1a18d12540bd1cf	254	38	4521
21025	https://transaction.ru611cde46b84d34080e7fe2fb77a43b95	288	39	4521
21026	https://transaction.ruaeb9424233d6a603ea79e5b05e402ff3	139	67	4521
21027	https://transaction.ru31ffa5d0c5b3f1c0f36c5e8e13b2b4c3	285	95	4521
21028	https://transaction.ruc902a146273aeaa1415fb97eec5c1220	116	93	4522
21029	https://transaction.rua36b47b998e497be6989ddbc7a1489fb	221	66	4522
21030	https://transaction.ru450f4dfa2bddf885ae12481212225ddd	129	36	4522
21031	https://transaction.ru2b8d6da33a47a723a914076bec5ad5d8	177	39	4522
21032	https://transaction.ru9a6b65aedf8177783035f3a53ca21ed1	273	38	4522
21033	https://transaction.rub3b9655b36937f564a797c6c35532e62	224	63	4522
21034	https://transaction.ruc0e47e177c49edf8610960a3ac898701	221	65	4522
21035	https://transaction.ru02095a32ba032edf62f36460c177ed13	258	64	4522
21036	https://transaction.ru7666c7b80e32857c03d0f271b9a2f1bd	294	92	4522
21037	https://transaction.ruf5b497d462b3262ec4b87be2d0285667	221	91	4523
21038	https://transaction.ru8dd832d9ec165f0414f2bf20d6243270	287	95	4523
21039	https://transaction.rucabc65628cbaa603dc2eac9efdef4df1	94	94	4523
21040	https://transaction.ru5cbcc6e0c2ef2c866baac46ef3886552	130	67	4523
21041	https://transaction.ru78fac338e4d6c509350ab986ddd9ba66	299	66	4523
21042	https://transaction.ru8c00e4eb3e220d8fdf281de739c39728	170	67	4524
21043	https://transaction.ru545824d40a2f346edbc77bce836192ab	185	66	4524
21044	https://transaction.ru489557d98683f98dc1b5f98d81f572c0	97	35	4524
21045	https://transaction.rub965e152d5f25108de7ef336024ab5db	192	93	4524
21046	https://transaction.ruae9d3ac1527e1d2979fbe0b8b5e392d9	92	94	4525
21047	https://transaction.ru100aafcacf67f71245e900cd917a302d	244	91	4525
21048	https://transaction.rucec635e58838ff3c8907acbe1bda1191	123	35	4525
21049	https://transaction.ruf62c40f26bcced088c8cccbc587e2ba2	31	39	4525
21050	https://transaction.ru86a0dd511243c51e212d4c81eeeb7924	102	38	4525
21051	https://transaction.ruae59fec5d87073805edab4e7c979971b	239	38	4526
21052	https://transaction.ru81d113245d62480f540f14339aba0447	253	67	4526
21053	https://transaction.ru4ecc5d2184a85b42b8e7fd469be3bda3	62	65	4526
21054	https://transaction.ru7c05df7aca714e85c4c980454760e90f	204	36	4526
21055	https://transaction.ru6324df21bf0bc8a33bd09f4f3c7624b7	120	94	4526
21056	https://transaction.ru4966c05495cd15b828f6c64358f2d685	268	92	4526
21057	https://transaction.ru0750aeef55b5583461d100d5aba8a2d0	50	92	4527
21058	https://transaction.rufc6a92ff093c3b5b9c1f7192373a3887	174	91	4527
21059	https://transaction.ru7f4fe79cdeb2af2eef760862d364c7b0	78	37	4527
21060	https://transaction.ru4b507970109e8d7e4c1c105cfb556b0a	226	67	4527
21061	https://transaction.ru567e61545801a4a8ee2e6301453e3c26	293	64	4527
21062	https://transaction.rue4d4bc5b74947b6a00dcfd35b5d1c943	95	35	4527
21063	https://transaction.ru0ff1784a3b5295df89dde138fed3082f	224	95	4527
21064	https://transaction.ru6c14a05e0c5ece61bd6547bff4d5d3be	38	94	4527
21065	https://transaction.rub43ffbc847b13b695d2972fb364dc2ca	105	95	4528
21066	https://transaction.ruc3420bfbd159b546b7ac7f38c6f7fa55	10	91	4528
21067	https://transaction.ru2fe8e83da6cc1e550b72947af7a18838	57	37	4528
21068	https://transaction.ru5942aee7804e91cfa9849ddb5ec2a03b	269	39	4528
21069	https://transaction.ru5ce40b2ea4cb47090c0595eded8a203b	196	67	4528
21070	https://transaction.ru5326692c76f29966f59f34376e5a6a1e	125	66	4528
21071	https://transaction.ru6e46596c15adafa086d52b957ba46c8b	151	66	4529
21072	https://transaction.ru7632cbc01dfc1763adea4fb6110ecb14	225	67	4529
21073	https://transaction.ru2ab8a5973655b20ccc60fbb09e2dd47c	104	36	4529
21074	https://transaction.rue9e818a563605fa9c5bc58f62e4828ed	151	35	4529
21075	https://transaction.rud5e390212ea61535b492b740102df78a	273	63	4529
21076	https://transaction.ru22ff6c3362a4efef011d7afac1ccb367	203	94	4529
21077	https://transaction.ru3e83b1fc7b749cef96f56766536d7f07	139	91	4529
21078	https://transaction.ru0c3fdb624d5f4f16bb9fe097e016cd7c	41	92	4529
21079	https://transaction.ru009f9d520ce74c111927eeeedb3587da	76	65	4530
21080	https://transaction.ru6a1ee3f23287b452bfc735ea0381ddc5	152	37	4530
21081	https://transaction.ruda594689350ea3be7c1722cca4ca2674	101	35	4530
21082	https://transaction.rua2a4ccc247ec39fa31d2498da7744ede	16	95	4530
21083	https://transaction.ru57ba1fe32d738b0557239d151923b260	64	94	4531
21084	https://transaction.rua7e54a1e9b6be172d4258e1b424f3378	96	95	4531
21085	https://transaction.ru4e8d841cfc2a682ff117c57be895baba	212	91	4531
21086	https://transaction.ruac0de4a97796f4261a491bd3c7edf6bc	281	92	4531
21087	https://transaction.rue3e80831411596185e98ca1e0779975e	4	35	4531
21088	https://transaction.ru96d018ba0b8b74e6858048c71692077b	220	64	4531
21089	https://transaction.ru0b34b5899ab539ad16694a78057c2a3b	223	37	4531
21090	https://transaction.rud57148da6bcac649995167405154000d	84	66	4532
21091	https://transaction.ru4ef2a509bed80408b45a2821d89d4724	103	39	4532
21092	https://transaction.ru1aa2e91b77ea85e1c8846c89ee6e874d	269	38	4532
21093	https://transaction.rucd77a015e40a180feb4a22b3027532d3	185	94	4532
21094	https://transaction.ru2632574638a2cb462061d67165638004	228	93	4533
21095	https://transaction.ruf3c98039e702c99acddeb152c53491fc	103	95	4533
21096	https://transaction.ruef29543fa9a4d23955dd1b091f1b2b05	236	66	4533
21097	https://transaction.ru521ecbb1312ba7da134270ba094da8b1	57	91	4533
21098	https://transaction.ru5cd4d33b8d5602446ff96a43ff7d3a50	54	91	4534
21099	https://transaction.rud569d23bda797e57be71a8fa6a1964eb	190	93	4534
21100	https://transaction.ru1c82321a68886d94c5227c465d30c28f	43	95	4534
21101	https://transaction.ruee20217200feadf4a89e24e9054c592f	137	67	4534
21102	https://transaction.ruc810a16dd2440728efa8a8d45a7660f4	46	35	4534
21103	https://transaction.ruee0fe8739468fb6e0214b071feb09590	185	65	4534
21104	https://transaction.ru1ce0b2592c99604e29ad9fd723f1260c	186	64	4535
21105	https://transaction.ru559e9c5dd3bef7494c7a98c314a9bcfc	67	63	4535
21106	https://transaction.rudde51e17b1452bb2658234e915099ea9	122	66	4535
21107	https://transaction.ru62dd6b861d8e8c2688538a8348904580	248	37	4535
21108	https://transaction.ru41145e363965ff4d72dde55b1f4610bf	250	92	4535
21109	https://transaction.rucb6ae433fee60e40b5019312ea7d4679	211	91	4535
21110	https://transaction.ru1c1888e8d5f3ec633fe3bafae8e0cc39	122	95	4535
21111	https://transaction.ru0accd393bdff55c586a0cbea7d12a99f	74	95	4536
21112	https://transaction.ruf084bf0ed419b8ff5f6473592eac4ac8	235	36	4536
21113	https://transaction.ru7b2d4740644d124d192676715bd1b5b5	13	66	4536
21114	https://transaction.rudbd71f238536c9106ca1d152dde3ff26	120	64	4536
21115	https://transaction.ru797523e00cae232100cf07023491b085	140	35	4536
21116	https://transaction.rua9e46f989ec01c01d2caddf1c889342a	90	39	4536
21117	https://transaction.ru9e447e569935faa29d23733541186ecb	49	67	4537
21118	https://transaction.ru776a5f588853a7e645378cd5a7156b2f	7	35	4537
21119	https://transaction.ru9a810cd5c2517cee54dae5d9dd884d7b	120	36	4537
21120	https://transaction.ru0f71b7f2e3ff1aa728d5f684bad4a45f	148	65	4537
21121	https://transaction.ru73a396e60e6a41458d73318b0c4691c4	131	63	4537
21122	https://transaction.ru6d1e7499b4528aa4c744215c310a95b5	129	95	4537
21123	https://transaction.ru6503f01753939e1d052ecc51ebcf8979	288	94	4538
21124	https://transaction.ru1f7b8cd715625aa330acc3902bff2df9	105	93	4538
21125	https://transaction.ru98fea99aafdeaf301e69d074e0b9775c	198	66	4538
21126	https://transaction.ru44181b2cabedffb1e4b0b1a1a9c415a4	189	38	4538
21127	https://transaction.ru76943da59eb733aa33855cb813f32aff	252	39	4538
21128	https://transaction.ru3d06e7a18381fec8234895b0f38bad27	298	35	4538
21129	https://transaction.rue5fa6a8101687b1afdfba62da6f34705	79	37	4538
21130	https://transaction.ru686fc3ad95061693f636de76fb673ddb	196	36	4538
21131	https://transaction.ru64506bb89283635386d4ab81bb8a8dd7	191	92	4538
21132	https://transaction.ru37e024d7d112a666bceb36b761309211	231	91	4539
21133	https://transaction.ru882d8b9a5dbca71bab135a85e6c1fde5	156	36	4539
21134	https://transaction.ru8f5ddf05383ab2df79e59ddbf47a047c	160	38	4539
21135	https://transaction.rueab178338e3268cd2db82a5af0e77936	272	39	4539
21136	https://transaction.rufe8432a1eb765a779a9d688338814e1a	82	38	4540
21137	https://transaction.ru6d0a18e729c23dcb49d34c57f4d662e5	110	66	4540
21138	https://transaction.ru30c52229efe182ea9a1857c1ae8ad647	156	37	4540
21139	https://transaction.ru776cde5755089ca9cf8039ad43f93812	268	93	4540
21140	https://transaction.ru26caefbe918a7fd863e8e43caf9642c1	249	95	4540
21141	https://transaction.ru8aa885e4f40ab78adbd319f24bc6e1e2	172	92	4540
21142	https://transaction.rucb049b58cfcff5ee7068d578b83eafd4	73	91	4541
21143	https://transaction.ru815742464797de72700f7d82ef84dbb8	165	35	4541
21144	https://transaction.rub4106553978ab5ecce01d944c3f49931	85	36	4541
21145	https://transaction.rua5842d713ac6880c218a484f77ec3457	146	38	4541
21146	https://transaction.ru9b9882d456c86d0336c3c2d44b89f5ff	268	39	4541
21147	https://transaction.ru456729d64b3afbfe8627a928be3d0808	171	65	4541
21148	https://transaction.ruc19316e7be0bb7ee83ab5737bbf14150	150	94	4541
21149	https://transaction.rub0bd1744d5d619bf48d0e2e81b336c9e	108	95	4541
21150	https://transaction.ru1b093c13b5e6e65c22ba7eb09260837c	180	93	4541
21151	https://transaction.ru5eb70e60f73d3ad08b8b61e130442b90	218	91	4542
21152	https://transaction.ru9d2cce2b31ddde6bb96b0e75cb3b741d	20	92	4542
21153	https://transaction.ruacf96f71413806050233bebaa6a332b8	245	38	4542
21154	https://transaction.rubcd1978a39e2ef8178788802694c0073	10	39	4542
21155	https://transaction.rub0f314c4f400cbdb1bb774b8b968c006	295	36	4542
21156	https://transaction.rue7fb77f8418707d9d6f4170fc30914e2	207	37	4542
21157	https://transaction.ru47d8b9402a98908e87fb2f2fa1a21906	254	67	4542
21158	https://transaction.rua7fcfc37e5d55dfb218312264ea999ac	215	67	4543
21159	https://transaction.ruc0b257595f91e934bda24d2ec81874c0	294	63	4543
21160	https://transaction.ru29dc5318cc3425aa0526937592a4e672	101	64	4543
21161	https://transaction.rube5fc1224cbdabb5d0a44ecdec263984	143	35	4543
21162	https://transaction.rubf516d41729f63f335de35bbaa6d1ea5	179	37	4543
21163	https://transaction.ru78891672c7ee9c4b60817bb2caa7f0dc	190	36	4544
21164	https://transaction.ru090f81dd98e6aa5b13add03c991c1bd6	45	66	4544
21165	https://transaction.ru5cd0697560a354109a57a68b0e54a0c4	106	38	4544
21166	https://transaction.rufd7c49500274fe31e3b63ad82e4c79e8	232	65	4544
21167	https://transaction.ru9a0055763314d5c87ef5797572160171	289	93	4544
21168	https://transaction.ruff38fb604883e9edc1f2496ac8e812b1	200	91	4544
21169	https://transaction.ru00612c5beee8a8a4adf6fe64f19080ae	272	35	4545
21170	https://transaction.ru0ec21ab0585c91eece89dd36ed162b4b	175	38	4545
21171	https://transaction.ru397c7cf299e15c61b88da0be23ab1897	248	94	4545
21172	https://transaction.ru19c14905deddaca95ba878e30b818e00	87	95	4546
21173	https://transaction.ru7ea375cbf793a3e2ac59ee664e91a166	273	92	4546
21174	https://transaction.ruc706c2ec1c2d50d5ea2382392dbe1b4b	97	38	4546
21175	https://transaction.ru1d78c1bba28a427561a16fd71aa3ec54	274	39	4546
21176	https://transaction.rufb96ccc255816159b8c5bd92989138f0	124	64	4546
21177	https://transaction.ru2df45244f09369e16ea3f9117ca45157	286	63	4546
21178	https://transaction.rude37950060f4463899c0299efd55d340	50	67	4546
21179	https://transaction.ru29b852f4b040b92f3131a7a6459cc5ee	159	35	4546
21180	https://transaction.ru8c27efb28743f03f2be70e01e6136cfe	277	35	4547
21181	https://transaction.ru334f125cf00274e92560e6229b4657f2	107	64	4547
21182	https://transaction.rub6e2463a141b2406b0af5fd77c2d3e57	292	65	4547
21183	https://transaction.ru797ac7c94950128f8bc1e86d9e60fc86	7	66	4547
21184	https://transaction.ru90f6be9a5e2a607d03db953c5a6b4874	236	95	4547
21185	https://transaction.ru6c20e2fbdd7f6c2d1f4c0f47052db64c	220	92	4547
21186	https://transaction.ru7dacae71b125a379c635bddeb04e2b2b	132	92	4548
21187	https://transaction.rue9196499a3cf02b40c533d66c37525d7	195	67	4548
21188	https://transaction.rue4ab2a522e901766a70ab99750fba3df	5	63	4548
21189	https://transaction.rudb59f84086b6f5ebff672c9e572f41e7	198	64	4548
21190	https://transaction.ru0feed448a99b73030a529dc96b32fea5	201	93	4548
21191	https://transaction.ru4242b724485fbf253039d55a4ff10893	190	64	4549
21192	https://transaction.ru012e5362b66bde05581b5c925cb214d7	134	66	4549
21193	https://transaction.rua88cbc70befd66ada304bf05a527b802	237	67	4550
21194	https://transaction.ru8def8f2fc2e68db133d043cbbc16a4bf	266	36	4550
21195	https://transaction.ru1d0b036561656ffb1e7a21c78625e414	10	64	4550
21196	https://transaction.ru9e96d422fba85185a33829439f5df09d	172	65	4550
21197	https://transaction.rue82223c0256b6126a177ae8ed6955ceb	280	63	4550
21198	https://transaction.ru9ecffde4f6222c18456ef0fdd6e5247a	245	91	4550
21199	https://transaction.rud9777d8f10507ba973890c1cef864e60	152	92	4550
21200	https://transaction.ru8c6883dccf708d874a324dc762133c1d	64	93	4550
21201	https://transaction.ru8b960b2a03887652db1c4888ede46e7e	79	95	4550
21202	https://transaction.rue3ecb60335dc8aaf4df20404e4fbc77a	118	94	4551
21203	https://transaction.ru0cfedf2c1cdc91d88fc4a591450661f1	179	93	4551
21204	https://transaction.ruead2e355eeb32486604c422df9ea2dd2	254	63	4551
21205	https://transaction.ru3dbc6e22cfcb9acc96ab7ef25206ad20	182	38	4551
21206	https://transaction.ru077ea6fd6736af65751c93a9283bedb5	17	37	4551
21207	https://transaction.ru74a63a9ef951106c7838d22b6a61040f	2	35	4551
21208	https://transaction.rubb46ce9b5f7a1c3d61fd92ed92c1f1b9	184	36	4551
21209	https://transaction.rud16300728e96862a86d29c2086634853	257	91	4551
21210	https://transaction.ru2c7eceecfe1e850f5613f8a8a6b18b49	132	95	4552
21211	https://transaction.ru871e5d9adc201e656f234a2867111e78	294	67	4552
21212	https://transaction.ruab0e31aac988ca7551095fe189beb663	78	67	4553
21213	https://transaction.ru00063ece2e68a8847f228e8fd922f851	114	36	4553
21214	https://transaction.rufed441a3dc2860969fafb5d5ce3f740f	6	65	4553
21215	https://transaction.ru88e95be4b9db2a86bf93f5841393822f	157	65	4554
21216	https://transaction.ru2cf0b84422decf26768f1a52607d4e7a	174	36	4554
21217	https://transaction.rue7e95115d379c22ce30f8a1998c831cf	292	35	4554
21218	https://transaction.rub7867fbad55d9d53cdb949d8dcefd361	128	66	4554
21219	https://transaction.rucbf1e6ea6e245ef174945f83e601a540	54	67	4554
21220	https://transaction.ru47db93bccb52a63d5da2e2f7460173d4	53	92	4554
21221	https://transaction.rubd9608e1ddec819d2c0b377b2991852b	11	93	4554
21222	https://transaction.ru59452e6789f08e0b8be597887ee8260b	200	95	4555
21223	https://transaction.ru34f710ec4736170bd08dacea9be6a7ca	282	37	4555
21224	https://transaction.ru546c56fb12dbb025081f4ebdad98fc1f	172	38	4555
21225	https://transaction.ruc59b469d724f7919b7d35514184fdc0f	126	91	4555
21226	https://transaction.ru41898ffac058123ba56fc2fcb75f57e7	186	91	4556
21227	https://transaction.ru2fe19a9f65a57f9717e619f339217837	99	95	4556
21228	https://transaction.rua96ae0fae881c5c7a51a02c2a06cc9d2	98	67	4556
21229	https://transaction.ruea6bd0d70fa527701ab0a0958ce33dc9	299	35	4556
21230	https://transaction.rua0f13bc8e2cd7a8e6c1662aa2bb317e9	230	35	4557
21231	https://transaction.ruc7ecae463b4f3d49f7a4ef3eea76bd4e	80	37	4557
21232	https://transaction.rude11adb2f1ce533eb0ddc6d763629151	247	63	4557
21233	https://transaction.ru7b91b97825330ff231c93ddb7bae8135	287	65	4557
21234	https://transaction.ru809b4e8a1d5c31966caa6065ec59296b	43	92	4557
21235	https://transaction.ru8f3f1c4fdb388f06021da38a610999b6	238	93	4557
21236	https://transaction.rua79d74a8e9e8def8ee0348a5aaa607e0	295	94	4557
21237	https://transaction.ru4bfee1008a917956a514a37cd8f77378	152	36	4558
21238	https://transaction.rub29d3c21387891c26ac03a7e77606c69	295	67	4558
21239	https://transaction.ru9c858174fdf32a7ef7c8de95a16569d1	112	91	4558
21240	https://transaction.ru2366459010c3857dad15159c86168943	20	95	4559
21241	https://transaction.ruac65bf756a4508e3798235547a07bfab	117	93	4559
21242	https://transaction.rudfdae1867127d678322670d5b23d48f5	186	66	4559
21243	https://transaction.rudfaad9f1c5a8192ee2d64ed2c7599b8b	181	67	4559
21244	https://transaction.rudda20d73344217635fa7bf565e054373	297	64	4559
21245	https://transaction.ruaa697d2ad515a0be62b8068ba34233fc	32	63	4559
21246	https://transaction.ru89eb571c57ce12db75ec6214a5e41aed	70	37	4559
21247	https://transaction.rub875b2a3fa860c94b5d47481d675c592	227	36	4560
21248	https://transaction.ru8cdf7f7cda1b1be84b14191ede363b9a	180	37	4560
21249	https://transaction.rub461df8295abae1c6715d4094589289f	105	64	4560
21250	https://transaction.ruac99c6134cf75b4c3e5f63cbb1a149ee	162	94	4560
21251	https://transaction.ru8ba87c7f22c8379ecec0dcad5e44c301	192	93	4561
21252	https://transaction.rub816b863746933a3945a9e6db5412148	236	91	4561
21253	https://transaction.ru961c45b3f7f515f9d4959f91283c12d1	38	92	4561
21254	https://transaction.rue8600824cf242fb1f68712d78b073dc0	152	63	4561
21255	https://transaction.ru0a4f6dbfb855b850a9791f871f05cde7	2	66	4561
21256	https://transaction.ru2e80b428b8923de6efd1b3592ddb498b	259	67	4561
21257	https://transaction.ru3d091beec152ef4d5d1b39c733189828	161	67	4562
21258	https://transaction.ruc4b4f68d920ab728e3ceef942fbcef40	17	63	4562
21259	https://transaction.ru2092ff3080bdca591a8158758d6e799f	151	38	4562
21260	https://transaction.rubcf637c4d1fc11300d8157d6c354c278	189	36	4562
21261	https://transaction.rue3e0612ed26c0208d56787b07d655d2a	136	93	4562
21262	https://transaction.ru690a9d93bbe1ce95ad00c45f16ebce36	201	91	4562
21263	https://transaction.ru302b0652a25b6dd7530fc4bb029be24f	256	91	4563
21264	https://transaction.ru35161776126bf17fecdcfe5cac82f7d3	100	67	4563
21265	https://transaction.ru216ed7260d59b3ddb99118303230a7ee	27	67	4564
21266	https://transaction.rud8956fae49c4580a7282770b0000e42a	200	66	4564
21267	https://transaction.ru6a77e8036b662c60703ab2015e8ee85c	109	36	4564
21268	https://transaction.ru10c69ced8819f630f04916b28912d392	18	38	4564
21269	https://transaction.rubfdeb1c74f28c8f314c37ffac31a01e5	11	39	4564
21270	https://transaction.ru44b39d08c6f634375dac4f0f9a7da7d5	273	91	4564
21271	https://transaction.rud2f377a97f37990b696904d6f1239430	21	92	4564
21272	https://transaction.ru73e5ffc5fa175af8b15ed0a5c124b489	107	93	4564
21273	https://transaction.rud5f798b04546fcb91e979c87658a541a	58	94	4565
21274	https://transaction.ru9af677717abd347644bdb79e9cd2c185	166	67	4565
21275	https://transaction.ru8bc10b43202bae7e419c7dcd229a404f	44	65	4565
21276	https://transaction.ruef2ad3f39f208506c94cdd3e28839667	145	91	4565
21277	https://transaction.ru77f7325fff3a6c913f4fada151d1f514	137	93	4566
21278	https://transaction.ru20b4a95465aa9b89c9d5a0609ff5a81a	284	67	4566
21279	https://transaction.rua5cebe8a723a68e02d82a719013e44e7	139	38	4566
21280	https://transaction.ru6b73e3e68e1204087db8f566beb01d57	126	35	4566
21281	https://transaction.ru455ea3ac5a5e5e948a46582c5f3a7b1b	28	37	4566
21282	https://transaction.rud23a43b42982fb7ba24ca81f38cac114	213	66	4567
21283	https://transaction.ru082fbc7a4e0e398da76eff62960178a7	238	38	4567
21284	https://transaction.ruf4dddbf833c1080b39fd2e5fc5fc7b37	8	91	4567
21285	https://transaction.rua537aae41b03cf7f39872da6c46161b7	170	92	4567
21286	https://transaction.ru412e892a9571bca40a1b7b736d4c2b5a	2	95	4567
21287	https://transaction.rubf68da28917190b16e51a1a905f8e240	93	93	4567
21288	https://transaction.ru99709d43c60597cfe01d7d959fc166b1	222	93	4568
21289	https://transaction.ru0262d03b54d2d760e14ee3c98213ea05	4	95	4568
21290	https://transaction.ru8c6e886d5ea79bfd10f10ff584b14465	273	94	4568
21291	https://transaction.ru0449b763c82d32e821d447a34aea2643	19	37	4568
21292	https://transaction.ru58c58f9c6366538eaa0dde3624592b81	15	37	4569
21293	https://transaction.ru403ad871084fe4a743c6525a8d021b0d	74	39	4569
21294	https://transaction.rue6e0814a0df9f9e6bd73aac4cead46de	20	38	4569
21295	https://transaction.ru613ab2aff3562bf499b7d2c876cfbf7a	124	65	4569
21296	https://transaction.rub523f2328fd75b66f513b5dd6861706c	148	93	4569
21297	https://transaction.ru6b813d1f12287e926f690712db0d00d3	5	93	4570
21298	https://transaction.rudffd2d6600e0c4436809b3839de2d8cd	8	94	4570
21299	https://transaction.ru15104bbb3bb6e5998c773044fb4b9f3c	244	95	4570
21300	https://transaction.rua456e3aa3c4eabc5db513f2eba293f7c	236	65	4570
21301	https://transaction.ru44c30517f3cdab1c266a1c94fdd46c25	53	38	4570
21302	https://transaction.ru4e70d34b2cfa00dcd3a46e893fa920ee	131	37	4570
21303	https://transaction.ruc81ec2df5858cd953a9fb3f44da84158	172	35	4570
21304	https://transaction.rud806b9665cc4fe3ec70d88ac8c95a208	166	67	4570
21305	https://transaction.ru8cab2d9b5ae69244aee4000b4150a75f	111	92	4570
21306	https://transaction.ru64e0b8016b523d945c52ca0c3ea8b514	234	91	4570
21307	https://transaction.ru1d1a3e9af1f48eb647f9171f493d9549	169	91	4571
21308	https://transaction.ru06b9edf54065fefa915e8e64f063d42f	232	92	4571
21309	https://transaction.ru84f689d6541ccd45e061a777f3a69592	212	67	4571
21310	https://transaction.ru786a88b528ab6aff8ca45c21505bc4cd	88	63	4571
21311	https://transaction.rud4ffc6afc5fd51a03afb4f0ff96c3d87	219	64	4571
21312	https://transaction.ru5277183f29d2eca8ae21f806298601ec	251	65	4571
21313	https://transaction.ruea9ad495e4a4ff573fc40fcb85ad0f0e	87	67	4572
21314	https://transaction.ru9b584b93fa0d9e0eb420d5492e503be8	20	39	4572
21315	https://transaction.ru42347af613cd2380c7f1c889c386f17a	200	35	4572
21316	https://transaction.ru435caa044b0db1a43fe6b302d7fa9403	67	93	4572
21317	https://transaction.ru8d38fc2ce95438192005bb826e736f13	231	91	4572
21318	https://transaction.ru6ff24ef6fc6639abcccccf5ce17b1a60	296	92	4572
21319	https://transaction.ru3e4bbcb06510976f990a69a5f7398f36	25	92	4573
21320	https://transaction.rufbc1f49ea90c2a9bd01b31506668a812	238	35	4573
21321	https://transaction.rue56752bb4e5249fb58683c6f14b8a982	59	37	4573
21322	https://transaction.rubb086401010497628aca7631857a204d	105	66	4573
21323	https://transaction.rud170028eae3f2b6aea82a5a70d4d5889	209	67	4573
21324	https://transaction.ru6fc57899cb4e2ee1ad1d1642da20ed74	210	64	4573
21325	https://transaction.ru9fdddb5f3831dae178548439396a2caf	156	95	4573
21326	https://transaction.ru4911e76da0916e3b23a40456e0a4af6d	283	94	4573
21327	https://transaction.ru7dd1ed894ddcae378cd84b09cbe1be6b	104	91	4574
21328	https://transaction.ru5106cad7cd382c408b75bd4f634d0f7c	264	38	4574
21329	https://transaction.ruc7d830edc4a6aeedf2cb507fef77ec8d	224	36	4575
21330	https://transaction.ru65b7c631c2bc2aa6bec65b87dbb80863	211	64	4575
21331	https://transaction.ru64c3b14aed6f180eed6d3c8f23407256	32	94	4575
21332	https://transaction.ru10705c89a58f3598cd41ca616eafe575	96	95	4575
21333	https://transaction.ru4e57ea5bcab05ae405eb38825c8cfcaf	274	92	4575
21334	https://transaction.ru6d4cc130a6ebd3de7b61f67f5c06c8e7	94	91	4576
21335	https://transaction.ruaba49ef7f600daa236f39c9bd5442aec	200	64	4576
21336	https://transaction.ruc3e3c11738ddefa23f9c4a192391b26a	148	66	4576
21337	https://transaction.rub40e84ba099b33edade1ea43fd2007d0	72	93	4576
21338	https://transaction.ru2ec6baa380835889a02cf54de9b06c1a	87	93	4577
21339	https://transaction.rubb307d9f2ea797eb5055b33ef321a64a	32	92	4577
21340	https://transaction.rud0311b2818be4fb21e8cc1ba10daa894	152	67	4577
21341	https://transaction.ru4a3cce87a14deb5fd80e293fef015c2a	292	66	4577
21342	https://transaction.rub3201c5180f0350704b27fdf8c88ac48	112	64	4577
21343	https://transaction.ruaa9ec9c5ff8512780442373003097d7d	288	38	4577
21344	https://transaction.ru601fca976da7285ee707df0b8f6dfdf0	261	35	4577
21345	https://transaction.rua77c813f8be4d826ae091e1ceb46a128	54	35	4578
21346	https://transaction.ruc985ca3fdbde913d6f80abc82bc28746	57	94	4578
21347	https://transaction.ru3a5c1f07249ad6e3b8487e995049006e	29	91	4578
21348	https://transaction.ru91088d00485468bc015b71087d37aeda	77	35	4579
21349	https://transaction.rubfd9d2980bf192859049f3cdbde115f0	97	63	4579
21350	https://transaction.rufdb96a95133b9da5e5e093111e5ee393	79	64	4579
21351	https://transaction.ruc1cd342061ee0785efae43e360cad1ab	226	67	4579
21352	https://transaction.ru1a819f7f77cdcc95b835afb6b0d6e7ea	22	66	4579
21353	https://transaction.ru21dd61a9c7122cdbd7a67db0af1f58a5	139	39	4579
21354	https://transaction.ru2915834e65ecc9e94caf8e632337cf78	253	39	4580
21355	https://transaction.ruab7763128c3b395717e0a0697b140610	260	64	4580
21356	https://transaction.ru84fe60d2caecbdbd04ad9a1abaac4689	119	35	4580
21357	https://transaction.ru46b124ef765fc6df52cc48f444814522	67	66	4580
21358	https://transaction.rubd498fdef3693cee6940c1ecb41603f8	264	91	4580
21359	https://transaction.ru073433af2ec33cc118636befdc547008	301	94	4580
21360	https://transaction.ru12c7092edfab74f5f069145c18805667	185	94	4581
21361	https://transaction.ru9ea948b88ad04eccc76d7b58f14eb147	247	66	4581
21362	https://transaction.ru100e7843850b82e5523bc88960f6b673	160	63	4581
21363	https://transaction.ru27d72ff41dd46dd82b492721deaf94df	26	39	4581
21364	https://transaction.ru6b1cdc873489cbb2ad6380cb49e7f112	242	35	4581
21365	https://transaction.ruacbec77b7bdff61be426de70434a02d7	78	37	4581
21366	https://transaction.ru90e898a2cca903a99c2775ad65168664	144	92	4581
21367	https://transaction.rub742eda233018b8fb797b9ede818c741	120	35	4582
21368	https://transaction.ru572f98a82e176cc671739a566a0a5b9a	123	37	4582
21369	https://transaction.ru7251b31fd9483644590b054dd3117d43	127	64	4583
21370	https://transaction.ru2b045be49a5041d6970d485f529a8aab	71	66	4583
21371	https://transaction.ru6767063cf0569c31899f00fe2cbf2c28	289	95	4583
21372	https://transaction.ru94d8c3bdf0faa5f451dc806107cf486d	93	93	4583
21373	https://transaction.ru57e25964548ebd9fc5b64059afa1ffb3	209	67	4584
21374	https://transaction.rufe55cc86e152677497cc39c24107fd66	122	66	4584
21375	https://transaction.ru946465ea172b4202aaef0df92ee92836	131	92	4584
21376	https://transaction.ru18926ceff2a3506fc643f616c7d2167b	260	91	4585
21377	https://transaction.ru34a0eb4bc9edfdd4e7ea34bf1045e438	131	94	4585
21378	https://transaction.ru85e865fb4676c85cc89787dbcff0f717	172	67	4585
21379	https://transaction.ru04aa67e05a1ea3591959ec953f959235	82	65	4585
21380	https://transaction.ru16ba1aae317ef88cd19e3a659b7c8b3e	106	63	4585
21381	https://transaction.ruc0df816317ac78e799f289ec666021c3	43	35	4585
21382	https://transaction.ru32ff4aeba8e5de16bfe5eb846429ff5f	290	36	4586
21383	https://transaction.rufa8853a607695e938bbcad1e5e9f7076	269	67	4586
21384	https://transaction.ru4d0d3acf6bc4d8f28d53f73a2879dc3e	88	66	4586
21385	https://transaction.ruc1425c3388a8828773bd175dd871d86a	49	39	4586
21386	https://transaction.rucbf387c4b62e2f27d6e6d3add84c8837	278	92	4586
21387	https://transaction.rucfc61b7435b25620dea6a3bc3b73634d	31	91	4586
21388	https://transaction.ru6fc916e2b6d219c84cbf7f66c95ecb3f	153	92	4587
21389	https://transaction.ru4d4b73d7665fd0822297f454ef02a2e3	162	39	4587
21390	https://transaction.ru43fce5f7cac2d618cb79beb9220ea679	156	63	4587
21391	https://transaction.ru05f86a375df4a49e08de90e28bcf8d52	98	64	4587
21392	https://transaction.ru4f112f8e41b6a0f38a0fc005ddb354e2	69	63	4588
21393	https://transaction.rud40b3fdd1ba0ec5d78ce9cb6411a3ee8	299	65	4588
21394	https://transaction.ru6be9403e4b31f94b053a081dbd960fd0	79	36	4588
21395	https://transaction.rue53f485a1323f43c4053cb2690d85ffa	148	93	4588
21396	https://transaction.ru8cb4975885e4f982444b7fb6626bb6a2	195	94	4588
21397	https://transaction.ru23467f33bb93e548cb6d8263400af080	264	93	4589
21398	https://transaction.ru8ad887ba559eb7c4dbeaf0bf2f32fb26	29	94	4589
21399	https://transaction.rub67542c64b198fec0d0bc017c0771a55	117	91	4589
21400	https://transaction.rudb267dd574510af863aa246a705c969a	201	35	4589
21401	https://transaction.ruf08f86e95c9d083c89f058285f9ff636	193	36	4589
21402	https://transaction.rub2910a339a5aaf31cac7fe1176d826bf	195	63	4589
21403	https://transaction.ru348591c93bfa5a250012d0c64689d37e	24	38	4589
21404	https://transaction.ru871bab5bd0f13e8c04a0e6d53e005ab7	256	66	4589
21405	https://transaction.rubf8ee0cede518a30141aecd359f227fa	82	67	4589
21406	https://transaction.ru89f162ac8c9b11c224577c3f24334406	49	64	4590
21407	https://transaction.ru37cfd6318ec77207edcc70bb957c0ae1	278	39	4590
21408	https://transaction.rua269ef5c1e7623a02a651fad5f2b8905	216	38	4590
21409	https://transaction.ru9b3afe5609c66924aca67479764977e8	172	94	4590
21410	https://transaction.rue7448eb8c453666057843dbaff6738ea	273	95	4590
21411	https://transaction.ru3af90680c209dc069df8755fe0881c92	280	93	4590
21412	https://transaction.rue741f9b6bea8ba544f9f759873f4020f	247	91	4590
21413	https://transaction.ru580bb2189ae01e66b257e9e631c8613c	21	92	4590
21414	https://transaction.ru7ed182eb9806a1f3b7a3065d9f3ca969	198	92	4591
21415	https://transaction.rueec61f1aea307e7c1aff84d8b7223248	265	38	4591
21416	https://transaction.ru30c9e234d6f129b1d2ec688ced6dfc54	70	35	4591
21417	https://transaction.ru633394d6821de6b9b3b353e7adec86d9	243	63	4591
21418	https://transaction.rua31a02dcbf10e7696c8de228b7a23a4f	86	94	4591
21419	https://transaction.ru592f410fefcbf9b877bc2451ffc71a1b	244	95	4592
21420	https://transaction.ru30fa928a004cbcc76888ddcba1cfcf1f	10	91	4592
21421	https://transaction.rubb46c0badb95f1bfe94ac88be9333a17	301	92	4592
21422	https://transaction.ru330671103d4be2bf266f714e49f8579b	258	63	4592
21423	https://transaction.rubbcbad280e1bd8a20dd0e6c834a1abc4	58	35	4592
21424	https://transaction.ruc1421e851b189235f0f819fe584665e4	267	36	4592
21425	https://transaction.ru727c1ba07e377c484ae6d0005da1c2a5	252	37	4593
21426	https://transaction.ru60b997fd68261ce70cadaf6c8226c042	206	35	4593
21427	https://transaction.ruc1adc7e5ae982a010af2eb442b583640	149	39	4593
21428	https://transaction.ruf040d6f35ebba6302718b8502f65f3e7	119	67	4593
21429	https://transaction.ru644189fdc1ec6209a67f49571c6d4a8c	82	63	4593
21430	https://transaction.ru72fa37fd2b943a04281c2f0cf48efadd	251	93	4593
21431	https://transaction.ru240ef48120ebe306a229f99e53be6a67	222	91	4593
21432	https://transaction.rub928ee5eb9b4044341840d5b2c9a1e96	221	92	4594
21433	https://transaction.ru31a30fbdcfb1fdf1d0b2f8e4a95ab5c1	199	64	4594
21434	https://transaction.ru44e0f1663f2b1cc73471912180db790c	260	65	4594
21435	https://transaction.rufa74b5841b90da9e99931229c443aeb4	170	38	4594
21436	https://transaction.ru0bb27a4b17c777a530d7e1de3de7f677	204	37	4594
21437	https://transaction.ru59463a8f847d6ad1f6af3f5b577e421d	255	36	4594
21438	https://transaction.ru5b7440c483621e25644a0e12e31e9dcf	200	35	4595
21439	https://transaction.ru962ff77fea6616d146fe35fd19fdf560	37	36	4595
21440	https://transaction.ru2680c4a058392246955c266709b5504b	38	38	4595
21441	https://transaction.ru54d711911cfe6b3c57e8f4347dea95ac	36	67	4595
21442	https://transaction.ru3bdbd566a1f72223acfcac1cad630a83	173	91	4595
21443	https://transaction.ru61d944f1f4cea3f84d9278ec688c3bc8	222	93	4595
21444	https://transaction.ru01c908bec1c662044330ee8dfad37386	119	95	4595
21445	https://transaction.ru864b2e82af1c9cd3a129536508a5ca1b	160	95	4596
21446	https://transaction.ru13c7e9211675f732141e7ce3407ab1b8	293	94	4596
21447	https://transaction.ru95bd9704faeb1d4db018dbde4ce653f5	201	36	4596
21448	https://transaction.ru9abccd0ac5283822d18e8229b600ec34	274	35	4596
21449	https://transaction.ru6e421441ae35b6ed2e53706c635a991f	284	37	4596
21450	https://transaction.ru5fd8136737bc8ff561cfb78e7fd3d512	194	65	4596
21451	https://transaction.ruee958ecef4852753c540410399313b1a	196	63	4597
21452	https://transaction.ru147fcae9dcdbfb1ab41e127fe45b4abc	112	64	4597
21453	https://transaction.ru3da8d679d249eb06d5dcd1ed11f70781	285	36	4597
21454	https://transaction.ru870786a9519eeaad04f82ac160352983	50	66	4597
21455	https://transaction.ru4ae87244e946f4d120af7a956e5f11bf	73	39	4597
21456	https://transaction.rufc717a9a2e7148fb2fee2d1a59f7cb22	185	93	4597
21457	https://transaction.rud9a149fb57b5890fa225fe42c37520ad	180	95	4598
21458	https://transaction.ruef697a65efeb9a9e99204d37e78344a6	278	93	4598
21459	https://transaction.ru8a2f51b70179bfcb3f1932675a957461	42	66	4598
21460	https://transaction.ru96f956ed63d9436e32ae1d2ac25f7742	179	67	4598
21461	https://transaction.rud1358d260a6edf1bbb6f460c9cb7cf14	292	37	4599
21462	https://transaction.ru4dd2b437e868011af1ca375c58a2edd4	264	65	4599
21463	https://transaction.ru382dc68d8862c9708d3c3e8ba37fd6a6	105	64	4599
21464	https://transaction.ruf3462425a98239d5ccd78bc4d9854927	92	63	4599
21465	https://transaction.rud81843b678d249d12e6c1b9de548aa79	59	39	4599
21466	https://transaction.rud69177eca42a7dc310a4e53a34aadfa8	221	38	4599
21467	https://transaction.ru431393e862a8ba6fe1f99161821d930c	214	94	4599
21468	https://transaction.ru16df9b10cd736963a7248c52c7f05a92	173	95	4599
21469	https://transaction.rucf4c98ca050fcd91ae7a5645c2e7f071	256	93	4600
21470	https://transaction.ru488040152f19c89d31c689e54c091f5c	160	36	4600
21471	https://transaction.ruad50d8444b40d8ea92cc0536e51aa560	51	66	4600
21472	https://transaction.rudc903b3bc369885e35286473441df72b	143	67	4600
21473	https://transaction.ru5b051ad2f5b63a80614382e202ebb15f	290	64	4600
21474	https://transaction.ruc5c5dc738a25fc6d7d4bb4fc38895b34	27	71	9801
21475	https://transaction.ru08b80460a3e6de86c01fe0af2643e2a2	278	72	9801
21476	https://transaction.ru5490e51a82dfa6dba6714fb160088cfe	268	68	9801
21477	https://transaction.ru11572e4be95b85039b0c0dddacc48d34	95	43	9801
21478	https://transaction.ruf27f0110e73f3838e9142805d43dae74	232	97	9801
21479	https://transaction.ru9308ae60ca8bca61de079ff875a40b97	139	41	9801
21480	https://transaction.ru80a43146a79d38835b1170ead2376390	7	41	9802
21481	https://transaction.ru5dd78039e1fc2f889932c9016b0c8a6b	179	43	9802
21482	https://transaction.ru938f36f1ab33b47ce8542381d1f6b84c	291	72	9802
21483	https://transaction.ru87882f687b8de4cc256af5db6e53674f	236	70	9802
21484	https://transaction.ru3ace2a04745a955ee84e34f043e3e958	288	96	9802
21485	https://transaction.rue992df7ff71643227aacbabe37cd055d	86	100	9802
21486	https://transaction.ru3bcc33cb3efd2715c03f16b6d1054be8	79	98	9803
21487	https://transaction.ru3b6cdaefb4c91507719b0b91e1b75daa	241	41	9803
21488	https://transaction.ru7f9ebfdb05e5bacbbe53f843de125807	224	40	9803
21489	https://transaction.ru2be3f86d40cb64e9eb413ac307906d08	204	96	9803
21490	https://transaction.ru625025e9f4a3eade947f06ec4cef4698	301	97	9803
21491	https://transaction.rud9118270637719c7d59571931841f871	113	70	9803
21492	https://transaction.ru998681b3d0e5deb9f6ff316245c2037b	278	68	9803
21493	https://transaction.ru6b14c4c44921c6d13e918ee2746b038e	135	43	9803
21494	https://transaction.ruf4472ff28c08e51a243e76476fc886d7	127	72	9803
21495	https://transaction.ru7e23471cf84b44e03dd358ec390d4aa2	255	70	9804
21496	https://transaction.rua86b3e0c385fcf80e0ec0b5f0473d3e7	84	99	9804
21497	https://transaction.ru5938b4d054136e5d59ada6ec9c295d7a	222	98	9804
21498	https://transaction.rud52dc3ebe66981b91cfeb9c5030f01e8	228	97	9804
21499	https://transaction.rub8fff68444b3c8daa356028d7af38742	213	96	9804
21500	https://transaction.ruc4938de3ddfe219b74ab46b1f0a6e5ec	139	97	9805
21501	https://transaction.ru2835acf1b5aaa6ade0d10b4c977e912a	274	96	9805
21502	https://transaction.ruc0688661d64661291c74b04060585994	222	100	9805
21503	https://transaction.ruac406a4abe1fbc5a651bc62a4b5b6017	129	98	9805
21504	https://transaction.ru05f6019b311c09e256c82126a917cd61	123	42	9805
21505	https://transaction.rueca5ac9ce9d9ca5b86f28d3a4e5c144d	41	40	9805
21506	https://transaction.ru60525be3f97761d240676c5a2ffc40da	243	70	9806
21507	https://transaction.ruda95d09903a32ef12f8fc5430b3927d4	256	69	9806
21508	https://transaction.ru6576cde9d889bc957204712c270e0e3f	161	68	9806
21509	https://transaction.ru7551493a92df702053dc220f1b3a5fdc	27	71	9806
21510	https://transaction.ru73fd0d0b966fcd110f527161831301d1	243	98	9806
21511	https://transaction.ru1e88fb882d94aad1e5c8c2ad1b6e14eb	33	96	9806
21512	https://transaction.ru779f17c15922a8121e2fa511a5342fa4	195	97	9807
21513	https://transaction.ru072da48545209ced853c8d62e932c923	54	42	9807
21514	https://transaction.ru168a8986f6a6f0b3c4ef222fa7e15f83	246	100	9807
21515	https://transaction.ruc53d09812755f3754f9c236d70e739f1	149	99	9807
21516	https://transaction.ru71d6f5293a8f215c8db64ffda3bfb6e5	138	71	9807
21517	https://transaction.rua88813ba089c9d6b06032bca1eb2c2e5	301	69	9807
21518	https://transaction.ruf676bdb8ccb4c2947a12b2361b6a073e	188	68	9807
21519	https://transaction.ruc54296b63319dcee1b23209ea2ed83c0	68	43	9807
21520	https://transaction.ru23eb3ce8bbeedd7ca05d4d6eed49d6ee	27	43	9808
21521	https://transaction.ru799e119ac305a81f66cc31836898b439	135	96	9808
21522	https://transaction.ru87d588cd8b3f1429f66ed829eb07a257	81	99	9808
21523	https://transaction.rud251257dfefc4289a470bd529b981a73	131	100	9808
21524	https://transaction.rue02388a6be2e69323497ec3348392111	260	98	9808
21525	https://transaction.ru8d825c38c64960821189fd36686b869a	247	100	9809
21526	https://transaction.ru762cca808f20de58a3455e75a6992e8e	77	44	9809
21527	https://transaction.ru1c66f01d4de39f1a42ba215d576a8783	53	72	9809
21528	https://transaction.ru1d7f494973a37c70739f5132071452c5	115	97	9809
21529	https://transaction.ru9b489ce5f6f859532cc408b5131650c1	125	42	9809
21530	https://transaction.ruf592e24991b1c01c4f19d980f289a9e2	161	41	9809
21531	https://transaction.ruf7c8341f803f60753469464cf8d68444	48	41	9810
21532	https://transaction.ru4e2ddc7c34e588485fe603ff87564718	159	100	9810
21533	https://transaction.ru61d01e2d42fa9d3186415dc8d358b283	265	98	9810
21534	https://transaction.ru03e68135e0895efe7ac9d0abac64f8a0	193	97	9810
21535	https://transaction.ru7d2232c2d7f36f8e275dbd19db2571c9	174	71	9810
21536	https://transaction.ru70cf4e10b85d7f7111af4d62ac669c03	167	72	9810
21537	https://transaction.ruafe17994cfd38e5b4327f6f3b159d3d0	92	69	9810
21538	https://transaction.ruf45ea30cb4c06e432e46c70cd656a3b4	127	71	9811
21539	https://transaction.ruc2993ad1f84393e3306522f6c144a318	83	96	9811
21540	https://transaction.ru088335a5b0f79bc6b89394920e63097d	130	97	9812
21541	https://transaction.rud50024a382b0bbae0ba02d1ef479b927	28	42	9812
21542	https://transaction.rue0ad41defc682134c972c6f99ffa7fcb	223	40	9812
21543	https://transaction.ruabe34624f55b6c79b99fb0cbba9251c4	138	71	9812
21544	https://transaction.ru919e4928832c5a094926a255e8e30c16	275	72	9813
21545	https://transaction.ru1a0cc3985c4002c0a1469f6a5bab700f	64	70	9813
21546	https://transaction.ruc2fbeb26277f363974af1f22005850c0	40	42	9813
21547	https://transaction.ru125f3434aff11d1275ddbe708c988b9c	21	41	9813
21548	https://transaction.ru77b1932b3eec9f094a2b103001f0dff1	216	40	9813
21549	https://transaction.ru0cd271140547e4037c586f6563da236f	106	99	9813
21550	https://transaction.ru2430ded463515d1ce4bd4456f5929825	144	98	9814
21551	https://transaction.rua078444f644eb191b758665a7ab0fb6a	144	97	9814
21552	https://transaction.ruf3da7cde149a694abf307bea4b2bf04d	214	69	9814
21553	https://transaction.ruc9f7fb34b31c1e46ac50a36f86beeca4	40	68	9814
21554	https://transaction.rub9bf637b7cea67f508407de20d2c802c	39	43	9814
21555	https://transaction.ru0315243c468b238bf15c230c774c9791	150	44	9814
21556	https://transaction.rue745b08b5a4a65f7350c64d6baf366a3	88	72	9814
21557	https://transaction.ru24d3b0e9e51e4db6681ba1bfa54483a7	272	71	9814
21558	https://transaction.ru0356dd6052d6b34320da2475ef109d39	267	70	9815
21559	https://transaction.ru8e07cfbb82d111d3bb7b50a007610a25	85	100	9815
21560	https://transaction.ruadfcd147a76d26c6f1b59de19953a095	130	99	9815
21561	https://transaction.ru9957e1c95790759cb6697c44d29cc076	296	97	9815
21562	https://transaction.ru6cb9502f3c511aa5f5ddcaf8cfa56f7c	176	40	9815
21563	https://transaction.rud7cc1cf0123824fdffbd4086868e675c	132	69	9816
21564	https://transaction.ru96932cc8b9cdb6181882fba82e818519	31	72	9816
21565	https://transaction.ru641cb4c10510019b8982adc6c8925d5d	245	44	9816
21566	https://transaction.ru6b2a6e5491bc29cc6352a83f25ab0349	135	97	9816
21567	https://transaction.ru89537fda9c4c072277eeecfd32965906	261	96	9817
21568	https://transaction.ru249539228bc5935183d630f22b807e32	20	42	9817
21569	https://transaction.ru9ece0636726ae1fd207f50120b7affed	115	99	9817
21570	https://transaction.rua4b789cb213701d841243b1e02b6aa20	161	100	9818
21571	https://transaction.ru5a2fcd6917fc4492c94091a6570d9aa8	13	97	9818
21572	https://transaction.ru06f6961516260faafbbc804dacb6b7c2	131	40	9818
21573	https://transaction.ruaae8dbd2131dfe3eab75465b13d099e7	25	42	9818
21574	https://transaction.ru4c467ab0bd0476998484e3715e4010dd	207	43	9818
21575	https://transaction.ru51d5feb218865c92737aa214c6e0a45c	262	72	9818
21576	https://transaction.ru40b8222872ef3df35a1a43dba260c1ba	31	72	9819
21577	https://transaction.ru6bf2e83f19b86db162739344e6b189a2	12	40	9819
21578	https://transaction.rude8d70c837e1a47e83bae6d38899c12a	178	42	9819
21579	https://transaction.ru6c787340ac02d4c5ee334f2042b1d431	137	42	9820
21580	https://transaction.ru7330e3c4483214f1b819190d18a7c45a	240	100	9820
21581	https://transaction.ruf348e8fd25f00a03096ea145ae5ac04e	74	44	9820
21582	https://transaction.ru962adcaf9aa0ce8e3b17c21d23891abf	89	70	9821
21583	https://transaction.ru33979061433c450ebe44c3ab75319ed6	159	40	9821
21584	https://transaction.rua1569176832e1972601525c35e1db3b8	161	41	9821
21585	https://transaction.ruebd9629fc3ae5e9f6611e2ee05a31cef	286	99	9821
21586	https://transaction.ru33120ddef3bb9dab8a2af7bc38c1c70c	272	97	9821
21587	https://transaction.rua197c9c33e1a7fc077c5cb829887bc67	159	70	9822
21588	https://transaction.rufa662998c35d483d61e2c9f6e578ea77	15	69	9822
21589	https://transaction.ru06435792ad8bd608c8ddb178f5643aeb	70	72	9822
21590	https://transaction.ru459321e0f5af04a6aa842c9b2d01d132	262	98	9822
21591	https://transaction.ru94761462a9eb2ae71013eb76034c8fdf	111	42	9822
21592	https://transaction.ruca8f1f2f6dca2f828c3aa7a02a5397fd	166	41	9823
21593	https://transaction.ru077c3f6912e1f5f39d8decac22e78050	91	42	9823
21594	https://transaction.ru8e57d58f9d887ec2dffa1f72d7d6aa14	232	97	9823
21595	https://transaction.rubf1944355a1fa841a97ce4c53a2d08dd	141	44	9823
21596	https://transaction.ru94f72bddadb9584ec1e0c04ad558246f	54	70	9823
21597	https://transaction.ru605dca368f0500b327bc645f2a8081e0	140	69	9823
21598	https://transaction.ruc99f2d4f5645608ea4de2534f0a16a5a	226	68	9824
21599	https://transaction.rub2b4b6d09ffddde69dc4d009bd5d5eb7	109	69	9824
21600	https://transaction.ruecc63deecec609482911c7e614a83e87	40	71	9824
21601	https://transaction.ru5d6716f901db22a9a8d9dab1ad17e4a9	19	100	9824
21602	https://transaction.ru0021a9a08c31c28e487b5168d347c202	42	99	9825
21603	https://transaction.ru7aec519a851e5786d7e13d88361f519a	57	42	9825
21604	https://transaction.ru22a20049e29ee774433863f598cf2ea4	252	71	9825
21605	https://transaction.rub5b2ba7bf099ac28d64f06ffe24e347a	280	70	9825
21606	https://transaction.rua41c202fe759a7f4ae1666328669166e	73	43	9825
21607	https://transaction.ru9fcf363dc529f6683db2877e5064ca8a	23	44	9826
21608	https://transaction.ru3513668a4e7046cb87f09789a49e92b3	208	43	9826
21609	https://transaction.ru5951c179de43573583e7d4281df3f495	124	68	9826
21610	https://transaction.ruddbbbffe31c7ea437d0e83af9abc9db4	282	99	9826
21611	https://transaction.ru31073475fc4fe0f27c6b876472f0888e	174	41	9826
21612	https://transaction.rub9469e86568318bcb2b825c4ccb105a7	174	40	9826
21613	https://transaction.ruaba953fbe62116d5bd59f1409522aa74	46	40	9827
21614	https://transaction.ruac8d3ab0ba6cc42fda13ebfb0fbd6ea7	151	69	9827
21615	https://transaction.ru8166c97315a1cbb44f422e7b2ce69505	283	43	9827
21616	https://transaction.ru1d971eb3ba4f14c10bd64455b86b89aa	293	99	9827
21617	https://transaction.ruc21270a73dcb49051f3d6f91086453d0	209	98	9828
21618	https://transaction.ruc8aa48a3667e7a29486f3f978b0e0279	56	42	9828
21619	https://transaction.rub598af7304e8b93f4374556b702dd279	268	41	9828
21620	https://transaction.rue68b395b860629ede5393a5643f4352d	274	44	9828
21621	https://transaction.ru5e39470d72f8ca88f478add811dfa121	118	72	9828
21622	https://transaction.ru051e4e127b92f5d98d3c79b195f2b291	93	71	9828
21623	https://transaction.ru9556337cd1af4cbc989fb895153822ed	52	44	9829
21624	https://transaction.ru58f9f240a36bbbb5fd081e81ed637686	159	43	9829
21625	https://transaction.ru9abafe751b94168d89448debccb454e9	283	100	9829
21626	https://transaction.ru66bc21611348425d6b4e68aa194c7df4	130	98	9829
21627	https://transaction.ru6f6a926ddcdd49f40b34904001dd90be	271	42	9829
21628	https://transaction.rue534228b26ba368471fbaedf787477b4	204	97	9829
21629	https://transaction.ru175e8a4f9e4da225b17699693cbffa0d	107	96	9830
21630	https://transaction.rue01528aed8809fb2949b8a07a45686c1	215	72	9830
21631	https://transaction.rub3881d3883bcc055e72be84c970126a7	6	98	9830
21632	https://transaction.ru53fac39cf4be8bccfaff7c41a9b82f82	136	100	9830
21633	https://transaction.ru5e43459fbfc8d48e5c4421cf79356804	65	97	9831
21634	https://transaction.ru603c6b451f52b8138f42010a39153127	262	43	9831
21635	https://transaction.ruf2150937c3901b89a9d73338bca09a26	54	68	9831
21636	https://transaction.rua1874dbddeb3e1463225cdc1a50e9b2f	88	69	9831
21637	https://transaction.ru5e030604b75bcfcf3aeb98d4deaab276	23	40	9831
21638	https://transaction.ruf48cd9f82c04f146b5168144df03da27	115	40	9832
21639	https://transaction.rua85f2aa270d748f285e0c58680bff44a	103	42	9832
21640	https://transaction.rufb077cb275c56ce85dfd44ed082e7d46	12	98	9832
21641	https://transaction.rufff6b0bf8804dd797018719c920ff0b3	218	70	9832
21642	https://transaction.ruecb8b0ea7431b7f4f88a7fa18fc4c018	275	69	9832
21643	https://transaction.ruc8a0c4dbfe13409025c1166b312c2a13	17	71	9832
21644	https://transaction.ru126802a3ab60ae8cf17f5ceee84fa147	44	96	9832
21645	https://transaction.ruea9b9d7b0b8b125eff4a9d5ff7ea7a37	10	40	9833
21646	https://transaction.rud6c96c203534c4dfae74d62872fc8676	2	68	9833
21647	https://transaction.ruafb8414f1b8fe9370f58ea1cdbf63d60	267	98	9833
21648	https://transaction.ru5b33c4d9f5ce3128e58db5ff76ca4c70	164	99	9834
21649	https://transaction.ruf531cbc67b7a0301349c238159f13ddc	191	98	9834
21650	https://transaction.ru112535e64885730bfcc3b8c9d133669c	120	100	9834
21651	https://transaction.ru45f619db5434c15bdfb03503048a2ead	243	69	9834
21652	https://transaction.ru15c6a881d691f35267ec316050b3c21d	118	68	9834
21653	https://transaction.ru36f1f187493730c4ab7fcb40f085810f	92	71	9834
21654	https://transaction.ru39806f1cc3d8be191d6eaeb665eac675	148	43	9834
21655	https://transaction.ruff0cfee14809ccec770a78e0e23d0a6c	25	43	9835
21656	https://transaction.ruc843bd9262a7db4767485d787d9c2653	33	44	9835
21657	https://transaction.ruaffb250415c4cac35167a669eefdf525	191	72	9835
21658	https://transaction.rued98cb0f2a374d7946726d70a53e62a9	162	71	9835
21659	https://transaction.ru40964490d23bded195fc616e3a03c45b	268	97	9835
21660	https://transaction.rub3ff1ba3daa4e2197738ef6940d90113	185	96	9835
21661	https://transaction.rudf7e1de23b6e8c68863e49e03d05ef0e	295	99	9835
21662	https://transaction.ru84b7f44a11c89e3c151463f7411a7a91	196	98	9835
21663	https://transaction.ru1ffa55867647ce90e14e739a0d6a0bfe	273	100	9835
21664	https://transaction.ru097d2d47884cf9976abf54cd413de322	204	98	9836
21665	https://transaction.ru0e175dc2f28833885f62e7345addff03	260	100	9836
21666	https://transaction.ru7a776ddb3d2a19cb3b8dea3add863f29	167	99	9836
21667	https://transaction.rud1a655f1d00bb968c17c977439f13d95	277	44	9836
21668	https://transaction.ru1f716d4bc9c66e6a89aba143d9819ce0	70	43	9836
21669	https://transaction.ru2ebf715f84fc466ca10a541bfa71cada	23	42	9836
21670	https://transaction.ru46b3becc1e90af632133bf95d4a34328	114	40	9836
21671	https://transaction.ruee01782374608713ce0728343b2eb4f1	164	41	9836
21672	https://transaction.ru08dac6c0f58ff3fc756c0bc02292b53a	160	98	9837
21673	https://transaction.ru9f7972e9d6d202eb9070e4a0fe2c6cb9	283	100	9837
21674	https://transaction.ru32f6fed5f1345a6bc71f8e88b7ea83e0	104	44	9837
21675	https://transaction.ru5eb2225e91cf51c8e32e8d0fad3c2306	18	71	9837
21676	https://transaction.ru924ee34a8bf0a6b2fba975617f6fc3fc	78	68	9838
21677	https://transaction.ru323bfdd67e145a053abbc41e8a1d80fa	209	70	9838
21678	https://transaction.ru9df2b23f433206570d6844406f6d21cc	281	43	9838
21679	https://transaction.ru57c4545d784142d74a318a62127abeff	187	100	9838
21680	https://transaction.ru0db7f0d63a17e1d9040e9f879f8030fe	185	99	9838
21681	https://transaction.ru7d0837a229309259cab2b522de8af25a	119	96	9838
21682	https://transaction.rue735c5d94edacbce67969d2188ba5b00	190	97	9838
21683	https://transaction.rufcd02c650d38271cd2f71b60c7a705b4	187	96	9839
21684	https://transaction.rua8b7271aaf63d5b434ac58d601e9586d	48	42	9839
21685	https://transaction.ru402abd6c2b8834676eac95f3a437055d	46	98	9839
21686	https://transaction.ru31290423f1cb31a8cfd0b18f84938f44	189	99	9839
21687	https://transaction.ru85329295c01b8b0de1327c0e8c6131c3	82	43	9839
21688	https://transaction.ru821ea721408852e7772480c023a2d0e1	227	44	9839
21689	https://transaction.ru6bcd48976745b1de9ac6e37b0d194e00	90	72	9839
21690	https://transaction.ru45f6d0e07d7a1bbf04568d728006aae6	235	44	9840
21691	https://transaction.ru273f77e61fbd5b19efee6343838fd019	154	97	9840
21692	https://transaction.ru41df22b8c6045da99dcc58812af36c88	223	100	9840
21693	https://transaction.rudd53208905ccbb5e6c3b4f3bec7bb10c	169	98	9840
21694	https://transaction.ru3e9530b677ebdab487c2ef84c8c45589	176	41	9840
21695	https://transaction.ru8dd14fb9fca052d960d5b9b281cacdbd	214	41	9841
21696	https://transaction.ru0c3958119bf7c98717325b0f7cef177b	283	42	9841
21697	https://transaction.ru58f1f592b41a43dcdc0db9228d0b6263	293	70	9841
21698	https://transaction.ru90039746682b8bece140e1b912a6999f	92	98	9841
21699	https://transaction.rucb9de284b65fcb1e4680fa1e9b814d1f	291	99	9841
21700	https://transaction.rud2db572c5dea4331681076691a13feb9	16	100	9842
21701	https://transaction.ruf560d3af728987bab518ee9181b46231	120	40	9842
21702	https://transaction.ru30993c7afb34233408bd3952bd401305	104	71	9842
21703	https://transaction.rub615c13ed08b4d30aac70e52aad89925	5	96	9842
21704	https://transaction.rue0c6c3ff23233270b717d79621564e8e	99	97	9842
21705	https://transaction.rud7382f5641a6f043e0323c4a5dc32840	41	96	9843
21706	https://transaction.ru867a3f97fdf556bccb5286aceeb2cd27	204	98	9843
21707	https://transaction.ru6ada26fc4b72906a0b4118ffcfb4afde	103	72	9843
21708	https://transaction.ru917a321f7572681e9bad728a5eb9bbfb	12	70	9843
21709	https://transaction.ru024786dca2d3ca17cdadc4042f894994	204	68	9843
21710	https://transaction.rue7fed71b03eefb86a2f0f2402a91182e	297	40	9843
21711	https://transaction.ru0038d1bcbbb76870733e9f2ae0739faa	170	41	9844
21712	https://transaction.ruf6eb81eb645c4ae49d4f10b298516780	193	69	9844
21713	https://transaction.ru22317f5abdc5bdbc08d2827113b0b10c	246	70	9844
21714	https://transaction.rud1292451bba5395f71ecc2a2be10a0e2	133	68	9845
21715	https://transaction.ru5f81c720a8a3c6625901275cc96b224a	134	72	9845
21716	https://transaction.ru1c54abd419e4f817d0eb2f88fa4a3103	260	44	9845
21717	https://transaction.ru884a60f9f3a3913c80f98ac7997b8f81	257	100	9845
21718	https://transaction.rud24a814e796534d25f7b93a5f2411c66	295	99	9845
21719	https://transaction.rufcd6590f9a416024e92f701824f7232c	244	100	9846
21720	https://transaction.ru83832dee2a442b8c77a157873c22439f	114	99	9846
21721	https://transaction.rue6b3511c4dbe58d2145206f3e9a51488	212	98	9846
21722	https://transaction.ruac55aa6ac0891230f7835c721134313d	20	97	9846
21723	https://transaction.ruf7411247b92b5898a10b848b7c74687b	29	44	9846
21724	https://transaction.ru566494279ebf1b892bcd4b2ee0c9e3f6	61	69	9846
21725	https://transaction.ru19088c04bf33296167d7b6093d2957c3	22	70	9846
21726	https://transaction.rufd25658a16641b9e9b161c73d2cb2aa6	300	68	9846
21727	https://transaction.ru028ea9560f1383e8c4df808781faabe6	233	68	9847
21728	https://transaction.rucb251e6f29baeb1edefcd7353bf67aa1	255	69	9847
21729	https://transaction.ru03abf228e4cadcab8e2123d86eea761f	106	44	9847
21730	https://transaction.ru5a030f2ee75dbd84de06566e3ea0bfd0	182	43	9847
21731	https://transaction.ru4dc6aded2fbbbd44b30607dd275439f1	280	72	9847
21732	https://transaction.rub778dcc1315e09f14832af91e76a250c	235	100	9847
21733	https://transaction.rua20993c023f2d7547d12fbffdf0a45aa	187	96	9847
21734	https://transaction.ru6774380bbaaeb13061e26f0261ca4799	105	40	9847
21735	https://transaction.ru3c4e2c8503b8d61485df0ad672ee8f88	223	41	9847
21736	https://transaction.ru1153305fcb61a03004034d8a4fdce882	151	42	9847
21737	https://transaction.ru4530430a7a733b29c95dbf5dd4a5c4f2	258	42	9848
21738	https://transaction.ru3e30af83de061b13fe1d87471b979d0b	193	40	9848
21739	https://transaction.ruc1efb218329e5aba0896676f9f3b994f	29	70	9848
21740	https://transaction.ru30c9e62ce1f7ce7dd4000f3986653680	77	44	9848
21741	https://transaction.ruca441205747665cd85f0d368e143613a	134	97	9848
21742	https://transaction.ru61599999515151f4243e72be2b32d4a2	145	100	9848
21743	https://transaction.ruee1ab09eca9e8a8f94c75f2b62f4522f	45	44	9849
21744	https://transaction.ru8e05f7b3a5c0f1a6a90cd919b6ffe540	63	72	9849
21745	https://transaction.ruf612bd276a5384e4a352c47d05a9059b	155	70	9849
21746	https://transaction.ru9bb087eecf659e32b8deee61d0a5e25b	109	69	9849
21747	https://transaction.ruaa0710cd9e15c15748e4f5e1f7ae15f4	174	69	9850
21748	https://transaction.ru1a093a1ed6b559a338508ae1b07c684d	55	71	9850
21749	https://transaction.ru71b58ef02c2158058665fbc2ac4a63ff	21	42	9850
21750	https://transaction.ru4a5a442a8b04e53dac48cebb9972b00f	132	100	9850
21751	https://transaction.rud686d1e2bd0f89c33f97894de630c2af	201	99	9850
21752	https://transaction.ru68fb9f2947a7f5f13b7752a1d51c2470	100	72	9851
21753	https://transaction.rua0709a1dd42c561e2a5a4989d73367fb	32	70	9851
21754	https://transaction.ru23ea76bd66492db3875849c5ba2cd74e	203	41	9851
21755	https://transaction.ru626035669207a4e760957ac83a201ffe	183	41	9852
21756	https://transaction.ru406fe98ae331fb97300a9aa82b8a2b4d	83	99	9852
21757	https://transaction.ru2d901fbf3ddb7a72096139f3bd3e1048	165	44	9852
21758	https://transaction.ruad4bd720854d3c4b5796819bb9173fc6	28	97	9852
21759	https://transaction.ru201d6e21e24645a2f735248a92f351d8	156	40	9853
21760	https://transaction.rubcccd4220e6d33efa94f08a16e5d06dc	113	44	9853
21761	https://transaction.ru5fe54a77bf817e5dbb5a9d8f52ef7d16	177	69	9853
21762	https://transaction.ruf6245d05f05b4123b992a6f1d9046c9e	85	71	9853
21763	https://transaction.ru295de1aefc8071d13aecb0b5af3538eb	229	98	9853
21764	https://transaction.ru79ccaf2326390a53a0532328326aec38	222	100	9853
21765	https://transaction.ru051b37ac0b41de7e87884eefe4e69d31	116	98	9854
21766	https://transaction.rucc7987101f7a66d43489ee2ff40e26e6	74	72	9854
21767	https://transaction.ru1773b723a0cd48567df0c4ba59a790f7	290	43	9854
21768	https://transaction.ru83460213a00f4d1dcffe9648f7ba5c7c	131	70	9854
21769	https://transaction.rubcc24a271f74baf4a149afd3e54671ec	183	69	9854
21770	https://transaction.ru710f6998e5d397f383f84198eb319964	174	40	9854
21771	https://transaction.ru6dec903a71d30ff5ceda9008b61db7c5	200	97	9855
21772	https://transaction.ru01b5fd25c8ece06daa6e33da9a3e999f	227	68	9855
21773	https://transaction.rub09e021e815170347bb93868d8948e65	280	69	9855
21774	https://transaction.ru191eaaf42f75a605b7761cd6998cb9a0	275	44	9855
21775	https://transaction.ruc45e2741f9e68d4330b0ef1228ba4976	101	72	9856
21776	https://transaction.ru77499dd24c8d405f6f7704c4353f9148	75	69	9856
21777	https://transaction.ru24c68b28768eb30f2fdf15e2e5d128f4	217	70	9856
21778	https://transaction.ru455d2494cf3dfebd4e54cd4b21bb2fa0	105	42	9856
21779	https://transaction.ru1b21dd74fb0bcabc5abdbb09b118ef5a	220	40	9856
21780	https://transaction.rud9bb41ac1451d78985f541201c26ab1e	132	100	9856
21781	https://transaction.ru5b73b763ad3f2ab5753264cee9debf88	8	99	9856
21782	https://transaction.rub2963eeb98272ae0bd98f70c80eb1c18	128	98	9857
21783	https://transaction.rua81fd14f84d7df07fbc3c49bcd9e705f	48	70	9857
21784	https://transaction.ru91be2a74dce26a87ba9f8ce13564234a	283	44	9857
21785	https://transaction.rud596b0716f31b09a2cb04044cafa0f60	182	43	9857
21786	https://transaction.rufb0e83b60f9414f50d5ea586a21e3207	199	42	9857
21787	https://transaction.rud53c7d8544b4f47cdcf3ebd51fbb44ee	126	97	9857
21788	https://transaction.rub5fcea21ad55a899cb105d9359b7ab3d	176	96	9857
21789	https://transaction.ru1017e3c45b6f356fb48ddf05f9229deb	7	97	9858
21790	https://transaction.ru21d24e71ba600fdf3ea5d16b07f0c860	216	100	9858
21791	https://transaction.ru67319e72ae02f35deda2ad248393c0f2	75	99	9858
21792	https://transaction.ru1add68194dba982fb477bc4ac46697de	216	98	9858
21793	https://transaction.rueeb57c36455e343cd204cb698a6e8079	196	40	9858
21794	https://transaction.ru18b99bc2230551d9a055ce50b505e016	252	44	9858
21795	https://transaction.ru6cc48eb1828b69dba20af63405ac5718	55	43	9858
21796	https://transaction.ru96a8bc570250ad68e76c1230eb0b9d1a	56	70	9858
21797	https://transaction.ru266266ab9c473caae9954959b94f89e1	66	71	9858
21798	https://transaction.rub3487307064be7185f7fc6c4a8f450ca	104	72	9859
21799	https://transaction.rud170d90b404d92f3a303cd851d6b1888	96	43	9859
21800	https://transaction.ru15e6e68928e7c4627e02e3b8264777da	301	42	9859
21801	https://transaction.rua4f638836589d52f4ed7636bfd6d5218	277	98	9859
21802	https://transaction.ru7d3e03376a72f1967791b4f7320f18b7	277	99	9860
21803	https://transaction.ru371bce7dc83817b7893bcdeed13799b5	295	100	9860
21804	https://transaction.rubf60ec3bcc0f32b48d58be891d86b2ad	256	44	9860
21805	https://transaction.ru1418c4f68b7325463fcc70f2d941b4a2	200	72	9860
21806	https://transaction.ru4a6f353d5fa037c244dd10e5734a1194	297	71	9861
21807	https://transaction.rub3d2dfa5981b3c0fb0c86b19464397d3	201	69	9861
21808	https://transaction.ru3ce3a7de84ef6e99612d073ea189db88	202	96	9861
21809	https://transaction.rube45c278fa67f6129085c4c25e10ca93	216	42	9861
21810	https://transaction.rubf0f93b3228db98db6bebeb412858cb1	39	40	9861
21811	https://transaction.rudeeb057f2bfa1e5e5a957cc6b3051268	89	40	9862
21812	https://transaction.ru45bb78f24bb81a5caa4f771d47d786e5	229	42	9862
21813	https://transaction.rud39f9c0d3dbd84756dbfaaf65adc6b66	110	70	9862
21814	https://transaction.ru5027bd83437bfc9939ea48d77327b229	115	69	9862
21815	https://transaction.rub43d65e85178cf1a13642f94836bc68b	244	68	9862
21816	https://transaction.ru3377ec9c655841041c34bec210df6743	125	43	9862
21817	https://transaction.ruaa6118d178fa3e061f9c53e9c47d40fa	33	71	9862
21818	https://transaction.ru8e1b6031314d35dffa354563befb9f70	46	44	9863
21819	https://transaction.ru5c8778b09f455d3814c244365b20bde6	38	43	9863
21820	https://transaction.ru4e7726656cd719c282ef485e2ae2d8cd	92	41	9863
21821	https://transaction.ru930a96bd1711898088ddc1b6d85b514c	187	98	9863
21822	https://transaction.ru97128bb465a02daea9fbee853f14f513	130	99	9864
21823	https://transaction.ru9708003f47a30f3aa313f0f9781a4895	72	100	9864
21824	https://transaction.rua66e1f7eeb140d345342849d918f63f2	179	98	9864
21825	https://transaction.rubb5391929d3a4ac7dc47552ad0256f93	177	44	9864
21826	https://transaction.ruf6ef34566ec8c0701eb0c58868a97c7d	137	43	9864
21827	https://transaction.ruf313a347b430b215abe0aaf72a6fe05d	89	70	9864
21828	https://transaction.rue373b95c15b8f6b236f00df9166d7c4d	244	68	9864
21829	https://transaction.ru5b3743f01cf8934ac4bf963bb088178b	104	40	9864
21830	https://transaction.ru46f75a1e82a67e5fb9e6175199dd0701	118	42	9865
21831	https://transaction.rua0410510dfc702b6593298f2d3adfd8f	288	41	9865
21832	https://transaction.rue4adac0568300c628703a99f195f6a5e	60	72	9865
21833	https://transaction.ru566af681700932bbb66ba4d3ec93b60b	42	96	9865
21834	https://transaction.rucba484207eea13814caf5964d9488afc	156	97	9866
21835	https://transaction.ruff9bdbd8953df53983e4c3673c238522	193	96	9866
21836	https://transaction.rua7f5df180278b7a7783592e2b19f9447	18	69	9866
21837	https://transaction.ruf889fb1a3185ffbb3f75889c8c37150b	139	42	9866
21838	https://transaction.ru65c7c4b5516a94c21aef9e85fc2f7c4e	195	40	9866
21839	https://transaction.ru8241e21fec85ed46f3c2464b941b5cb9	235	41	9867
21840	https://transaction.ru502975f6ce77f3c1f8d5880b4a823d65	263	40	9867
21841	https://transaction.ru3f5cb943b45c02c48478eaa458ff6401	282	42	9867
21842	https://transaction.rua588327d4bbaa552b4ed4d0d6608944f	19	99	9867
21843	https://transaction.ru558f0526f4aea92d063aa2fcf2477172	55	100	9867
21844	https://transaction.ru0871be7b81234c657e07d9971c1b21dd	181	98	9867
21845	https://transaction.ru116d21a91bbcf2561e254e36769300ae	49	70	9867
21846	https://transaction.ruaf225b290f99d2ef640dcf85d14d2330	201	68	9867
21847	https://transaction.ru52e1250aed4b0d8ba5e1e1b38ff9de8b	61	69	9867
21848	https://transaction.ruc9270b9bb57292b5115b8e1aefb289ae	129	72	9867
21849	https://transaction.rufdaada3cf0244e7b7e0c49a83b87feff	10	97	9867
21850	https://transaction.ru7310877f94b3420bc247aed6c4d44bba	80	96	9867
21851	https://transaction.ruf52115f1b57f758457f87b574657f978	292	72	9868
21852	https://transaction.ru429be53185d62d6d41561471fdd129a1	291	43	9868
21853	https://transaction.ru19fa7de7038497527f6a88cf1629251d	142	44	9868
21854	https://transaction.rufa53302515e2a8842dc96d23817c20dd	286	69	9868
21855	https://transaction.ru10c8df3a2b50d4f29ec5ac35bafb41ff	213	98	9868
21856	https://transaction.rua399e184d78576be5b6fe7ffdfd4e0dd	243	100	9869
21857	https://transaction.ru38ed75d554647d89ce37850e24620ca5	109	42	9869
21858	https://transaction.ru96310d27b1bab9894e95a1b41999070b	33	69	9869
21859	https://transaction.ruf493b86ef5a1f0cee9dd64ba5abd12c1	181	44	9869
21860	https://transaction.rubd40cc1fed396db7c897e2f4a373270c	140	72	9870
21861	https://transaction.ru6a3996a2a4d8988ea31e5d07c66d79b3	164	70	9870
21862	https://transaction.ru47f4ba94554dc7504bb7b976bbeec841	236	98	9870
21863	https://transaction.ru18bf1df33a61e1882f9c37ac9a47b188	204	99	9870
21864	https://transaction.ru94a273fae133ac7835195aa60753b9f0	198	41	9870
21865	https://transaction.rub0cd94cb3d9980f4d67a2cec8c46b5a4	171	42	9870
21866	https://transaction.rued6916d9c12d87ad309d18621cb1f87e	293	69	9871
21867	https://transaction.ru3c5ab0776d902302cbc6c37e0355050f	38	44	9871
21868	https://transaction.rufbec9ca852baa63abe0ad422f95b79b7	119	72	9871
21869	https://transaction.ru74edfb683c558a4dbd5aeb91c75aaf8b	119	68	9872
21870	https://transaction.ru037016252f00015b37e82dd153a03d92	202	42	9872
21871	https://transaction.ru8d8105b2e3bff4e7300092640df71f1f	219	98	9872
21872	https://transaction.ru804f3c5196c058de3c1ce58624b69f63	133	97	9872
21873	https://transaction.ru1016525395a57d3582edf0b6402ff848	208	96	9873
21874	https://transaction.ru93b19f90d55930c298d732434f65f31e	7	69	9873
21875	https://transaction.ru42ade44eee59461666650ec671fc4557	22	68	9873
21876	https://transaction.rub45ef9e688feb38b769681df032a628d	73	70	9873
21877	https://transaction.ruc2642e781e07a51e779c62ee00bab576	256	72	9873
21878	https://transaction.ru85b1c650ddf11edef75a86f9264f96fc	211	43	9873
21879	https://transaction.rud02c228aa76bf4d4eaa90161beb88bd0	214	98	9873
21880	https://transaction.ruaa1a291ca297cdd51380f14acd55433d	45	42	9873
21881	https://transaction.ru237a9835eef5f0b5ecb52e9f26368bda	24	40	9874
21882	https://transaction.ruab591bb9f572dfd278b658af110773b9	26	96	9874
21883	https://transaction.rubc3c7f5feeff345b96bd8028eeab567e	181	98	9874
21884	https://transaction.ru3de26308c98175146aa03f2dfafe6cfa	108	44	9874
21885	https://transaction.ru0e198cc854fb1246f7a79ab18a799098	243	68	9875
21886	https://transaction.rub89daf03fedc3b61251238b939969099	242	70	9875
21887	https://transaction.ru424436f34ffa0b20fb9e1126de7e8824	300	71	9875
21888	https://transaction.ru070e70f1d636c0666046bc9f157a6ddf	237	72	9875
21889	https://transaction.ru5a674372bb781fc497f2b913ae0e57ae	59	41	9875
21890	https://transaction.ru179ed325cc4f147f2308d3ff6a2f724d	290	100	9875
21891	https://transaction.ru87cc369564a60ac2a2c2d7cfeb4e12f4	77	99	9875
21892	https://transaction.rua198c129efa115cd7325d8cd758025f5	233	96	9875
21893	https://transaction.ru31dfe766723764a8c4fe44636b5e9e08	130	97	9876
21894	https://transaction.rud72ee3f1f854d7bc4b9fe4781e6c1198	124	71	9876
21895	https://transaction.ru01b8f8642def1cdbc3b916318105fdfd	6	44	9876
21896	https://transaction.rua914b1e71e6e3bd7726013f2c18dd500	137	43	9876
21897	https://transaction.ru221b2141d836c811418b82ecc29a7b8c	191	68	9876
21898	https://transaction.rue75863c51a45b61c40d2fcab3c36aeea	81	100	9876
21899	https://transaction.ruc98391d17284329180be2b2b2da3455f	229	98	9876
21900	https://transaction.ru09180fa6e43c3e7465d9bfc29ebf67ad	136	42	9876
21901	https://transaction.ru6cf821bc98b2d343170185bb3de84cc4	285	40	9877
21902	https://transaction.ruceef3f283d198385e06a475c87baed46	26	41	9877
21903	https://transaction.ruc8a0398711930cdf1a2b6d91c9a001e9	25	97	9877
21904	https://transaction.ru37c627b1554b587488791706c7304e83	242	100	9877
21905	https://transaction.ru1a7bc1b26ccdb680924e06bffbb498b1	141	98	9878
21906	https://transaction.ru12cd9ff647b8b8a1428050fcb380d9f1	53	99	9878
21907	https://transaction.rudb7f50b6cec5f88db93ff29f581ee8bd	266	42	9878
21908	https://transaction.ru9795a5eea2b32f0e455c6da43d4a2208	228	69	9878
21909	https://transaction.ru3a5a9c64786ffb47f970ef5a5ae02659	94	43	9878
21910	https://transaction.ru4fa1aa2dcfc6489caca8b96b4c3c0aa1	211	43	9879
21911	https://transaction.rufdd76d4e4becd019a1c16937ba4b508b	271	71	9879
21912	https://transaction.rub2458e57e254f54afafe192f60c16c44	111	68	9879
21913	https://transaction.ruf5f80dd41edf086d662f1271baa2f097	171	100	9879
21914	https://transaction.ru076185943bef700a201fb504a90d1c86	41	40	9879
21915	https://transaction.ru0bb60790ad63952de2abc23cc1c23473	47	41	9879
21916	https://transaction.ruf696d0cd4df2c8a8e1afc96e1001eb46	161	96	9879
21917	https://transaction.ruf1069383b6b5aab8ca543a35e9c65c87	231	96	9880
21918	https://transaction.rubd639b876c6a37363c08ea18cbcfe0c4	138	97	9880
21919	https://transaction.rua26290aef7c86d1cf694915cf3dc8e75	134	43	9880
21920	https://transaction.ru88c393f434c95df954488da286bdbb45	188	72	9880
21921	https://transaction.rua6db262e4058a514f2d8afaa021387a3	216	40	9880
21922	https://transaction.ru1a94ef9cdf51683835327d86418651d8	66	41	9880
21923	https://transaction.ru34a15277feaa53af2e225ffd8986c21c	91	100	9880
21924	https://transaction.ru74389493dc5821bcc6634a759db12b1d	183	99	9880
21925	https://transaction.rub265ff8279f74fba7aabd612927b6da2	105	100	9881
21926	https://transaction.ru9dfb506263a6092f6653350b7e2770bf	272	42	9881
21927	https://transaction.ru958c41a497fb4371c612c6db7c590288	77	44	9881
21928	https://transaction.ru9c052db0352f42a4ff05fe6ab072c56b	246	43	9881
21929	https://transaction.ru2180269ec5409c525ea00f70e58fe655	46	44	9882
21930	https://transaction.ru8e75bcd864634bdc3e03488f87cf5d42	107	68	9882
21931	https://transaction.ru549bb2c7d692199584d7437b737e2b55	105	69	9882
21932	https://transaction.ru52a2e34b5860c1a92f768ac33259f373	53	72	9882
21933	https://transaction.ru053a4fb18d8f882de807caa4f82c4fe2	75	41	9882
21934	https://transaction.ru30d360af4a815edd418e636f0f32ce3f	26	99	9882
21935	https://transaction.ruc14b482b981e64f062d237b6e828e16b	117	98	9883
21936	https://transaction.ru707c4288942f05f716f2576a5cda26ee	69	96	9883
21937	https://transaction.ru8c29714f5411f85b415c1c7939a0967a	165	41	9883
21938	https://transaction.ruca3586daa401f02f695234ee80c16341	60	72	9883
21939	https://transaction.ruf3daf33ead84c02b32d673addce28321	44	69	9883
21940	https://transaction.rufb483075aca516b640d8c2fc0303b2b6	224	43	9884
21941	https://transaction.ru135ab2fba50189f5d970f8de687c6310	230	44	9884
21942	https://transaction.ruf75824332de2b6db003932b3e3cd7065	268	71	9884
21943	https://transaction.ru468898bc9af2d64733c15ca01adf8dab	277	72	9884
21944	https://transaction.ru51b15ec622904898d54e72762451b832	201	99	9884
21945	https://transaction.rud7ed3d28183f11102daa5fc64a1e4231	6	98	9885
21946	https://transaction.ru0a049edd6f4651fe2c31c9ff1679bd5d	234	99	9885
21947	https://transaction.rub593631ca1703c6c7c3b711dc97b5e4b	123	44	9885
21948	https://transaction.ru23c22c9b85af6817b76de27ffa6ebc76	28	42	9885
21949	https://transaction.ru5551db0e22a5158c43b834d2360726d6	95	40	9885
21950	https://transaction.rub011be2606e484dcf2d317fa396143c2	213	97	9885
21951	https://transaction.rub84bf81da03ba08cb13e209aedc11675	63	40	9886
21952	https://transaction.ru82006dfb06360eb001d72650ba5fd45e	190	43	9886
21953	https://transaction.ruf33c080804efcbb069d3a191b92fcff8	164	69	9886
21954	https://transaction.ru92274034b1d28d1c457a14aebae4666f	151	68	9886
21955	https://transaction.ru4754db65f0c8154a775ddfbb5849bc6a	278	69	9887
21956	https://transaction.ru652ccea0e50cba467584537f418204e1	220	68	9887
21957	https://transaction.ru4b20667781dc247ea82542cc7b4934f1	135	43	9887
21958	https://transaction.ru700afbe3731d189d39d08c18e9d5d33d	20	44	9887
21959	https://transaction.ru6099abdf02d02db21ade638f69318c82	173	100	9887
21960	https://transaction.rub55cf862c0afc9bdc58ce8d2dd9c31b2	41	40	9887
21961	https://transaction.ru3b3389c0af8e4fb2bae4a429d8846ee0	116	97	9887
21962	https://transaction.rudef12fdd488c21f3aafada39668cd766	134	97	9888
21963	https://transaction.ruf22add054f171404dbf5023646ea7216	72	69	9888
21964	https://transaction.rue94da54bbccb16de51b540b516f28bca	83	70	9888
21965	https://transaction.rub524dfacd78bb1a6b8bd5fb7738a6845	145	71	9888
21966	https://transaction.ru9e1ed9c5420805ce217680914202e11b	246	41	9888
21967	https://transaction.ru3aadc78106e09c44728f01ead5bcde2b	50	40	9888
21968	https://transaction.rudf35839c6658f096c565adf7822bbbe9	238	98	9888
21969	https://transaction.rue8343347d242e99075e50bc7b4dbbd9c	33	96	9889
21970	https://transaction.ru9746795d2abd5900ecc1819e6cbce93f	275	97	9889
21971	https://transaction.ru94bab79614710e0186f16ccf26a746d1	127	41	9889
21972	https://transaction.ru52a2a8dffb4ea40ed592a5560f7b09dc	301	40	9889
21973	https://transaction.ru570fade30196f007000bb637567f9c37	77	68	9889
21974	https://transaction.rue1ce92433bd62dd29fdebbb8cd98a242	42	68	9890
21975	https://transaction.ru5dcb556e376c252b416301b493f4fdc1	117	69	9890
21976	https://transaction.ru407e1e059385631b21dfe2aa9a2796bd	152	70	9890
21977	https://transaction.ruc316fdacd1cf81be45a422ed3300a53c	8	43	9890
21978	https://transaction.ru173457b4ca101285a9a0a6d4520e3259	118	72	9890
21979	https://transaction.ruc24714fedce27a5bc8b49d446f3337ef	200	98	9890
21980	https://transaction.ru3362dcf146d16ddfee80107abeb4e2b2	206	99	9890
21981	https://transaction.ru76f709fd4a3bb531fe0e5876b5fbb0e5	89	40	9890
21982	https://transaction.rue6b252ebf7e01e4acacd3bcf0339cc8b	126	97	9890
21983	https://transaction.ru2387c48be980d093fab2b151732c2716	187	97	9891
21984	https://transaction.rub1ea4668603c98f396326a8931543d8c	191	72	9891
21985	https://transaction.ru2f2695b17b5dec1302e3b8518554d1c5	228	68	9891
21986	https://transaction.rua8251666bfbb9b876aead3fb54eacbc7	295	40	9891
21987	https://transaction.ru7575cd2ae57fb11e47033bd9728f7b8a	117	96	9892
21988	https://transaction.ru8f4919da2ad8519e74530c8db8b113a8	78	69	9892
21989	https://transaction.rub1571ce863a702414e8552b593c1742d	204	72	9892
21990	https://transaction.ru1d76ffc82aa2886416809b12d5e65f5b	239	71	9892
21991	https://transaction.ru09e8fa89a4cf7579a7a0b698c74125f1	291	44	9892
21992	https://transaction.ru14baface490758522a1f859c0acc9ec4	110	44	9893
21993	https://transaction.ru32a7af70898c9a229aca4f6e9739cedd	265	72	9893
21994	https://transaction.rub1dcfd1b9e5a174bdac8d6320b210a8e	125	68	9894
21995	https://transaction.ru64ced376b827fbc6b211834928467005	263	70	9894
21996	https://transaction.ru33c91699c1849207f81bf13a7210a5ec	91	43	9894
21997	https://transaction.ruc8f7812dd3b514f659209e1c46506f1a	32	44	9894
21998	https://transaction.ruf13cfb12b1ec8274c966e0895ae0dc9e	17	97	9894
21999	https://transaction.rudc038f7227acbe45e946659b9e936acd	124	98	9894
22000	https://transaction.ru5ea3a0ada7fdee2297fd3ee831a0aa5f	95	100	9895
22001	https://transaction.ruba30b40075f1b6b4cfb4cbd0b5881fb6	175	40	9895
22002	https://transaction.ru704182f68e85d5752a8212fef416bc15	8	44	9895
22003	https://transaction.rua956dcd628633b238c40a76cdf15c6a1	78	68	9895
22004	https://transaction.ruea9fc210e57e16424acea6e5552c3218	176	70	9895
22005	https://transaction.ru583ca753a766f4b3a89a26a6ae7901aa	224	71	9896
22006	https://transaction.ru5d9e3762617c3c7fccc74bb36d383977	265	40	9896
22007	https://transaction.ru80f3c819575dd8a32dafd9aabe9f238a	77	42	9896
22008	https://transaction.ru0c2b2b6321b364c6941555cecc5392a9	69	41	9896
22009	https://transaction.ru4e5c3edca0fbdfd79df268c4dcd9cb87	107	97	9896
22010	https://transaction.ru9e8b37313336ac21d647e429a423d7d5	45	96	9897
22011	https://transaction.rue8f7a6595d896560e04791ac6a026ee8	206	42	9897
22012	https://transaction.ruda1f434b1575e967cbb2088c6b33ea83	34	72	9897
22013	https://transaction.rub1410b1709c7112ab6fe2a53bafe143f	63	71	9897
22014	https://transaction.ru0154e4d770e2e6fdae9ed314cec76a71	5	68	9897
22015	https://transaction.ru22aa641a8d6cd0ae046f3b81bd07ee7f	176	43	9897
22016	https://transaction.ruf9f2d9efe158910f250cc7cf76470b7e	79	42	9898
22017	https://transaction.ru4350b8db554200c7e7f425e674e53f92	188	97	9898
22018	https://transaction.ru2d058f84c8bd50ca5144a936d35b3713	179	97	9899
22019	https://transaction.ru0a502861ae0aff4b1d473b29b9a9d40b	149	98	9899
22020	https://transaction.ru7b6ca4465d618e034d7a1096bcb89ed1	182	100	9899
22021	https://transaction.ru3c3fafa50deb0a41c8b7bfb055ca8dea	224	41	9899
22022	https://transaction.ru8b8931eff8b23ef67334f3e2cb283a94	171	42	9899
22023	https://transaction.rua69be1267597ec9a25e7edf7fdd790da	143	43	9899
22024	https://transaction.ruccf3fa9c7bc7626472746836fb71c451	65	44	9899
22025	https://transaction.ru5e1a230d59b84db6b7d31570ed860dd4	79	72	9899
22026	https://transaction.ru17616e5836968dd63320acd12d0a21ba	217	68	9899
22027	https://transaction.ru62ff6be991b344d46cbcecd83bef1490	33	68	9900
22028	https://transaction.ru342d6764561170ce12b700c582328c36	104	70	9900
22029	https://transaction.ruddb892b15830a659eb8cc732772bf72c	96	43	9900
22030	https://transaction.ru7207dfccbaa69b2eeaac692d49a58e14	92	71	9900
22031	https://transaction.ru481e360e5771191f19bc2b9c8966d1e4	35	42	9900
22032	https://transaction.rua7831cf1711477a0cf4e05413ab080fd	44	100	9900
22033	https://transaction.ru09def3ebbc44ff3426b28fcd88c83554	34	104	14901
22034	https://transaction.rube4b2db3b734bd0795c7c81daf261a35	261	105	14901
22035	https://transaction.rudc3dd518079ec2bb2095eb0f00a6f8be	242	76	14901
22036	https://transaction.rub6f48b34ec7c002fe39800f067977ecf	185	75	14901
22037	https://transaction.ru018cb0261a67353cd52dc42a1038af23	284	47	14901
22038	https://transaction.ru21ad1ab81ab86bc1f0a28494155ca096	214	102	14901
22039	https://transaction.ruacc3635f2ac08f0336ff7575c4463e17	294	48	14901
22040	https://transaction.rufaecbe4a4c506035a644be0259f905d6	111	47	14902
22041	https://transaction.ru07eaa80f2d1bd2a424798fc7e7bb45ab	227	73	14902
22042	https://transaction.ru6ce567b8cd2c13eba7111631c16824c4	258	78	14902
22043	https://transaction.ru5178db2466fc5ad9f0f2354a3f504d82	22	103	14902
22044	https://transaction.ru877f8395efda54ec44a890080c4e4fc0	33	106	14902
22045	https://transaction.ru407bf4cd3b2b82b384da8821e8bdd032	222	106	14903
22046	https://transaction.rud48b3a5572b706c5eab0b3e32f54ecad	216	78	14903
22047	https://transaction.ru31f1bd8a5b8ed7a33833866edc1f24b7	74	46	14903
22048	https://transaction.rub25c70686eb0d4c54ce9e9dec422e615	280	45	14903
22049	https://transaction.ru392ef92ab77d5b5ed7e8fb423c7f82d7	146	77	14903
22050	https://transaction.ru86e95f8473ac4b13db9f9f9b138dcab9	133	50	14903
22051	https://transaction.ru9975e86d1979d9493d71afc07058a2f0	256	101	14903
22052	https://transaction.ru04b255b79a35784fcbe883bca5a9c6de	140	102	14904
22053	https://transaction.ru77b276cc38da28fc7e8ff4eb65080938	82	101	14904
22054	https://transaction.ru6b1e04562adc2dd88bb4fcd2802e86ee	237	45	14904
22055	https://transaction.ru3d56839419f7394c1696a7cabc1d47dc	296	49	14904
22056	https://transaction.rudde2f48271413b212263fba116af0cd8	209	48	14904
22057	https://transaction.ruc8e74ee1a070396e83e9ca3f1cd868e9	99	50	14904
22058	https://transaction.rufd3513550c3ecdfd8fe7c00a164e8be7	199	73	14904
22059	https://transaction.ruae8a146930567d915565e6c15d1afd4b	234	74	14905
22060	https://transaction.rua96114cdac6fe98ac4ea7c0fea7b2a99	270	46	14905
22061	https://transaction.ru830429c229ddfb8131ef4680d1bc2dc9	78	75	14905
22062	https://transaction.ruf1cf8f0b859aff0d214008e65bf4d043	31	78	14905
22063	https://transaction.ru19d71a5f9ae8e5248b7c30f7f6b6698c	289	102	14905
22064	https://transaction.ru7640f82d6c9978d3f51f27d454ca2791	126	106	14905
22065	https://transaction.rua6e64002590615274598defcdf9e7163	182	101	14906
22066	https://transaction.rub7f0ddeb60d196ecc52cb96ab2982a06	238	78	14906
22067	https://transaction.ruc4a45eec1f9e9035dff93648ecb28f11	196	47	14906
22068	https://transaction.ru3a7e3251e8285102079d4561ae7ec771	139	45	14906
22069	https://transaction.ru6c33bab09ffbf368f42bc5735a13ad28	131	74	14906
22070	https://transaction.ru522fa781b28bb159775fb201d0057043	153	75	14906
22071	https://transaction.rue034a602fea2d41949b80b7013bc62b9	182	50	14906
22072	https://transaction.ru218b1a439465c11359f3dd2871fce750	289	48	14906
22073	https://transaction.ru9117a47742d87b8929f47eac8bc12924	215	104	14906
22074	https://transaction.ruac7a146a3ef0d0b644a723ad8c4a784f	59	105	14906
22075	https://transaction.rub59f5f841a0b24358a0527c0472c2665	44	103	14907
22076	https://transaction.rufe177cf1988f9447efe921a156f9ca87	76	74	14907
22077	https://transaction.ru9fcd0529be25351c6e0be0344765d16e	150	101	14907
22078	https://transaction.ru52012d28d631ee433533c0bb4260b475	232	46	14907
22079	https://transaction.ruc77c86ca9582f22d509c7bc277c5b742	238	50	14907
22080	https://transaction.rue1c327ecc957dffb8f1d8aa134a15afe	193	50	14908
22081	https://transaction.rufd88061d45b2446f61ac447f3a908f5e	122	47	14908
22082	https://transaction.rufe1257b5c834b7f13f17d0a043a9762d	223	77	14908
22083	https://transaction.rue1d3af3aacca3d75b6f2b2b2bd6f155c	31	104	14908
22084	https://transaction.ru4d587e5f37e0aa6cfe7362c6beb061dc	213	103	14908
22085	https://transaction.ru7f55132ae44ba21448a1a87050ac8f55	28	105	14909
22086	https://transaction.rud5c21bcdcffa3583e6ddb01465b82113	126	76	14909
22087	https://transaction.ru3f5e9d5deed823e98a9460fc7b56a2a0	28	102	14909
22088	https://transaction.rue823b120370e2beb644cca013a573985	128	101	14909
22089	https://transaction.rube610d8829279e65808b97b59d86d1cb	226	73	14909
22090	https://transaction.ru67ecd716063a1af00302b761c0c9c756	107	46	14909
22091	https://transaction.ru121d3a5f8e01b13f8f48f9cf7bdfe22b	63	50	14909
22092	https://transaction.rua375940d926e14c53eb8aad5265df545	247	101	14910
22093	https://transaction.ruff294b4c4aabcd845a77de57e60f0c01	93	102	14910
22094	https://transaction.ru9ecc9245f078af53f2702f17f5501c44	55	78	14910
22095	https://transaction.ru980aa783dfc2ac5400083740b051ecd7	287	76	14910
22096	https://transaction.ru00fcba87813c30f9b1dc01978d689c2e	17	45	14910
22097	https://transaction.ru9e1e5804ad9d8479e74583341af79c17	102	46	14910
22098	https://transaction.rudc5b54013e7a4b5b135ec9a671cba90c	116	104	14910
22099	https://transaction.rue256fd167da87d172effb29afae99baf	234	103	14910
22100	https://transaction.rufa03318ad9aeaedaac4cc232b95dca7c	97	105	14911
22101	https://transaction.rufa4e4fd87fb8467bbd9392d54dd7412e	281	46	14911
22102	https://transaction.ru58ca2faa889d8a0edcc58dbd5f190af7	171	78	14911
22103	https://transaction.ru0d42847a59bed031e4a39a2f5f010260	99	50	14911
22104	https://transaction.rub9e8173de3900a8394933f91d99ddea8	121	48	14911
22105	https://transaction.ru686fa78f7e89dd6cb6e81dd46c7393a9	40	75	14911
22106	https://transaction.ru92f78e7ce54fcc4b6b58821e69468cb0	39	73	14911
22107	https://transaction.ruad8539caf4cfaded172f5416f8b979bf	58	73	14912
22108	https://transaction.rue10ff3b121dfe36fc1c306d97bfc08a4	215	46	14912
22109	https://transaction.ruca145b2c942c3f26eb5fee1297dfdc7a	142	47	14912
22110	https://transaction.ru62b3b5d2bc683ac94a8dd71269a79a26	264	102	14912
22111	https://transaction.ru86158a6b3924670a32dad65bbc41bd95	82	76	14912
22112	https://transaction.ru8df41dd62dafe03e0533a6d8e69a6ff8	295	104	14912
22113	https://transaction.ru8aeafed905e27816c2289f8de48f87fd	16	103	14912
22114	https://transaction.rua96ae67fd6324bc8a07c0a23d264cf2f	77	105	14913
22115	https://transaction.rub6982bc0ebfc56dc006aca57aa5ae048	203	77	14913
22116	https://transaction.ru07d92d515ccd9d4b6ed71e12bdb7cf65	198	50	14913
22117	https://transaction.ru27506e60ce11cadef1f95724b56fd356	63	102	14913
22118	https://transaction.ru49643c673ab407380f0478c33e45a293	41	102	14914
22119	https://transaction.ruc3cca5b901eb36818bad6a6ff7c2835f	142	76	14914
22120	https://transaction.ru39526acce189237afe0105fb8aa755a8	212	77	14914
22121	https://transaction.rudea4e2001750c937ad310c6797cf674c	199	46	14914
22122	https://transaction.ru96f813ee4388f99469c8df6fedbaef90	104	47	14914
22123	https://transaction.ru8a8dd476957b8757d70b0661ef0b97e5	112	78	14914
22124	https://transaction.ru99651e765e3557b930e88abae7995702	97	73	14914
22125	https://transaction.rufda289097c4c98ee0e8cbfa52b265615	94	103	14914
22126	https://transaction.rue67bc69198ed2f65c0d6b86540a0c494	124	106	14914
22127	https://transaction.rufeae70a2315d0096785a2d58b7ec54ef	108	103	14915
22128	https://transaction.rua37d6e73c8bfa0f89b412df4880c4d6f	129	78	14915
22129	https://transaction.ruca6b2d6edfce9579802a5e0d4d052048	209	101	14915
22130	https://transaction.ru5c7b65545dfb440271b81f1b22288a63	179	102	14915
22131	https://transaction.ru634c5e09bf0fe0115c5d44951cd88be6	294	49	14915
22132	https://transaction.ru68b2e4115beb6914e8dde4c8aa578790	75	74	14916
22133	https://transaction.ruc5d07aa9bd8b3c771dd8923d13ac0597	104	76	14916
22134	https://transaction.ru8088b0e3136c64fbc3efd596d93274da	192	77	14916
22135	https://transaction.ru08bff3552a4c3ed8d6948172bf45e8fa	222	46	14916
22136	https://transaction.ru41877b7db7bd3b4ce518a41631554524	26	45	14916
22137	https://transaction.ru128177c22b3c74d77453a43fd787afca	202	101	14916
22138	https://transaction.ru5f51e2da8bd4528a8c21895ecd7a2c20	31	50	14916
22139	https://transaction.ru6dfe220c50de94ec57920b15024ba162	258	104	14916
22140	https://transaction.rub5c9f5c1f9a9484854800c6b953b49b3	231	103	14916
22141	https://transaction.ru498cb285ae44f07f9211e67be4da5836	179	103	14917
22142	https://transaction.ruc2fa6a33214be13cfbc2150b1e1f018a	261	77	14917
22143	https://transaction.rueee880a0ef81328672e8b9886012f966	225	48	14917
22144	https://transaction.ru74a0c0985eb694105d464b6276e0ab9b	192	74	14917
22145	https://transaction.rub4dc2836dad0f0a98f3083e3ba185384	58	73	14917
22146	https://transaction.ru0aec985fc8b4cad82ac9050e259d2d80	277	47	14917
22147	https://transaction.rub9389f355a1a8b42d23cd2da29676b6d	226	47	14918
22148	https://transaction.ru85fae5b5a1a55ca0105ecac39c0d1ffd	281	48	14918
22149	https://transaction.rue2423b6bba4d194ac454491d52eae261	44	78	14918
22150	https://transaction.ru21993f0e240be6533d3f445307d51767	207	77	14918
22151	https://transaction.ru249576bbe1f8a1a584acac4e9fea0732	83	76	14918
22152	https://transaction.ru71aadf9553c194a615876257556882ee	301	73	14918
22153	https://transaction.ru06a4d3c5964e7fc146e6086fd7ef4920	123	102	14918
22154	https://transaction.ru4c4983d4b1ff0ac50e9efac83f2e6e72	224	101	14918
22155	https://transaction.ru256d5c7e1c3cfa72420899e4debaf687	220	103	14918
22156	https://transaction.rud35e0540c292dd7a36241c233b120fad	232	104	14918
22157	https://transaction.ruabf8d689759d755f092b8981603e0582	118	102	14919
22158	https://transaction.ru22a03dc9819ac7ea1e259e5954f60167	278	78	14919
22159	https://transaction.ru0c3e640ab55b9e01fee7fdaadc163f0e	93	45	14919
22160	https://transaction.ru2710d35334e7b60fdf381bec1becea53	112	47	14919
22161	https://transaction.ruae6def2080f965c0702547b1ae6d9338	80	48	14919
22162	https://transaction.ru9850e647637448b130813c1501b1a8a3	98	74	14919
22163	https://transaction.ru5aa7de51316c404a48677b590bd3b85a	30	73	14919
22164	https://transaction.rud4baec084705618dd6e5fc3c6db1ec1b	297	76	14919
22165	https://transaction.ruc3c158f0a76a7194c76954485871e9c2	24	46	14920
22166	https://transaction.ru2a3dcfb76d15ebae46021a6daece5c80	247	102	14920
22167	https://transaction.ru96ecbfadac55a39b8909822f91399f00	253	101	14920
22168	https://transaction.ru2bc83dd5f9bc32d393e9f5547ef10b5b	133	49	14920
22169	https://transaction.ru1aea34486aea8681d1ced38c21810763	163	103	14920
22170	https://transaction.rub58f2fc36f60133ac117ac659bfe8cd5	86	104	14920
22171	https://transaction.ru49e08a32481b6d7055541cc1cad1b080	194	105	14920
22172	https://transaction.ru0eb699c1f55d4630ce58e97fc4e4f1a7	101	106	14920
22173	https://transaction.ru2de757de71a95613377e1a0250b2f627	285	104	14921
22174	https://transaction.rufa0bfbd71a40d52b4ed185f230f64fbb	76	103	14921
22175	https://transaction.rudd7746551e1dc7134e1a443e0bbd4cf5	59	49	14921
22176	https://transaction.ru89acc0164f4ffd77e6d88ad4e309f675	82	75	14921
22177	https://transaction.rue10ff85ae770065d07be2af33dcb3676	2	76	14921
22178	https://transaction.ruda4ae48ff74101053f5421873cf0d9bd	300	101	14921
22179	https://transaction.rue6467fee60101393a9ea9cab562a22a2	2	48	14922
22180	https://transaction.ru9ef7b47973f058a185b1960636532f09	40	47	14922
22181	https://transaction.ru2380c3c921a390e15a276060ef556d18	61	77	14922
22182	https://transaction.ru0422931f29fabb6b2f6cf4fbffad26b6	71	75	14922
22183	https://transaction.rud67dd90ffa6b2e4e3951d17f33371aec	290	74	14922
22184	https://transaction.rubc7ff2a11783e93177f028dd7c2da22e	30	105	14922
22185	https://transaction.rud6abd44caf3226a8bf21875b2db2808c	116	103	14922
22186	https://transaction.ru2418a49e39f5d907a0e976602ba15bf2	237	103	14923
22187	https://transaction.ru7f848746fe2599dc199a75f0d02fc3d6	98	104	14923
22188	https://transaction.rudc1eaac39bff232ff4f409adbb04b2ab	193	74	14923
22189	https://transaction.rubbe55680f70abe2cb7144974806445d4	152	101	14923
22190	https://transaction.ru238ed6d6cab0d2048c2fff996544b4f9	36	75	14923
22191	https://transaction.ru32f8f82319ab81844460ab1d00cb1160	84	77	14923
22192	https://transaction.rubd87e73436bd523047de955ea46fe9fa	232	48	14924
22193	https://transaction.rude76baa21d4d16b54c0c087d9fb550d7	241	46	14924
22194	https://transaction.ru7ed0aa10fcfcea8a714a8817ae4e8c46	290	104	14924
22195	https://transaction.rua5898fcff14bf53e61772bf5aadb6441	191	103	14924
22196	https://transaction.rucae4ef6ab52e80148e97a6df5759d387	203	103	14925
22197	https://transaction.ru442d325eb463c714c3e2e86b438ed742	132	47	14925
22198	https://transaction.rua5e3f5f4d7482cb9e3f0d56ac590012f	150	75	14925
22199	https://transaction.rua4ca7ffa6645a2d2cbbeab4680ac174b	123	77	14925
22200	https://transaction.ru49f78b2d13202e476db679ffe2ce0bd2	272	73	14925
22201	https://transaction.ru5eeac6e4633be07c9e2d0a6e6350e226	148	74	14925
22202	https://transaction.rue9fe6b75fee1d1d165034d402da24fe7	103	48	14925
22203	https://transaction.ru0959e2b33dfed3f0d3708eb7fce05e26	99	102	14925
22204	https://transaction.ru994b40e0e33c978911dfe615d1baeaed	291	106	14925
22205	https://transaction.ru740985d3ebb91ca39e803a9157d98d64	34	106	14926
22206	https://transaction.ru309cc432bebfe81b99ab22db630cf3a3	125	101	14926
22207	https://transaction.rua76fb40509d2f9bc7e8dce2e03588727	16	77	14926
22208	https://transaction.ru5101c33641a48bcc4b72e9a8c8b622fc	141	46	14926
22209	https://transaction.ru6116f37cf69f1b5daad4429f35c8a5ea	64	50	14926
22210	https://transaction.ru2537709cf72fd67f30940a166d7507f8	213	49	14926
22211	https://transaction.ru15a137c6d78c818c6fce421f3d9894df	121	104	14926
22212	https://transaction.ru4f967fa596476e423c2b3cdb343688c6	123	104	14927
22213	https://transaction.rub9b21333e2f17ac511e2d32e8761a574	292	49	14927
22214	https://transaction.ru4835876b2dc2b4962882d3f81e705d19	263	45	14927
22215	https://transaction.rudf79af289011cfa45ae20a9dfc698136	60	77	14927
22216	https://transaction.ruf54539fa0138f481183aa9feca1e0fc0	232	75	14927
22217	https://transaction.rue6411474dac918daad0e39f4e194d19f	145	106	14927
22218	https://transaction.ruae24a79986ca490672dc36a5b7fc1cbc	103	46	14928
22219	https://transaction.rua787f02ed34fd886eb6d49e60d9c9120	246	45	14928
22220	https://transaction.ru992efc215c802d02d3d3215159cd8418	58	49	14928
22221	https://transaction.ru8a9c8ac001d3ef9e4ce39b1177295e03	125	48	14928
22222	https://transaction.ru97952f85531ebf55b01f6826c59c2199	12	102	14928
22223	https://transaction.rub9640cca21af7a692a86bad3928ad323	26	78	14928
22224	https://transaction.rudded98215c586ad5cd9569aac90eada7	59	74	14928
22225	https://transaction.ru5387913650ad7fc0b5871a29f334d3e7	148	102	14929
22226	https://transaction.ru6b154dcc41cbde45320b4b91351fe10a	258	78	14929
22227	https://transaction.rua6d232cd7ce2b0fb9d31e9bcd1771afd	255	50	14929
22228	https://transaction.rub039257d8f0b44e89835ce9ed43b1f5d	202	74	14930
22229	https://transaction.ru8f15f831721491a119a0fc9e3855049f	45	73	14930
22230	https://transaction.ruef6f575ae15867012fb9e63276949653	249	46	14930
22231	https://transaction.rufd5d4e01625b6db3f516e2277b5028c7	289	47	14930
22232	https://transaction.ru1e303db8995af1239419a51f397cd727	83	76	14930
22233	https://transaction.ru28f0b864598a1291557bed248a998d4e	239	75	14930
22234	https://transaction.rub72a47e83332d0fa83156c345d3edb30	259	48	14930
22235	https://transaction.ru4492f5462adc2ada762c5dfa6c8331b4	240	78	14930
22236	https://transaction.rue92bcbb1f27a10ddb3fefc53249dd1fa	154	101	14930
22237	https://transaction.ru44e6f40aa63bb863d663159663ef5986	5	104	14930
22238	https://transaction.rub56e60bc5752e84c2172d12c3159bafc	251	103	14930
22239	https://transaction.ru16bde84f3d18b118778ef3df8087e476	211	103	14931
22240	https://transaction.ru03d6251008953f7c73272cb88a87c700	108	101	14931
22241	https://transaction.ru1077fb83fd410457927efb52a0b32c56	84	102	14931
22242	https://transaction.ruda926d557c754de3f5d42b26415f5c5e	186	76	14931
22243	https://transaction.ruca2ad13d85290826b16632b1eff44b28	279	75	14931
22244	https://transaction.ru6dba620e7c4ce0c4d66192fd48eb9ff0	47	49	14931
22245	https://transaction.ru42eedc5dc230c568bd2b033d3e75d05b	245	101	14932
22246	https://transaction.ru49d7b1d4a81e28aa55388343e1d2f009	291	47	14932
22247	https://transaction.ru374246797b3aef72e59bcf0fd5e4ee63	170	75	14932
22248	https://transaction.ru195704d42ca54b9b5438856244f7ad95	84	76	14932
22249	https://transaction.ru98aee7b2ed22eecf7ac0f35f08b310f4	30	78	14932
22250	https://transaction.rua45796062c43c976ad4e89884dea7497	110	103	14932
22251	https://transaction.ru16dca050edee1cf8e7e075a65337d170	112	104	14932
22252	https://transaction.rua55f476226e726393acbfa3a52b7800d	12	105	14933
22253	https://transaction.rue9f0107ee6edb239a552c4e1c2451a5c	41	103	14933
22254	https://transaction.ru7a88a544081cc41dd6b7ba0cbf9de42d	118	101	14933
22255	https://transaction.ru246f2c5632ae550c2d0b15dd6e0cfe46	62	74	14933
22256	https://transaction.ru31bec4b8c79d6d6cb7a21e7dc18030aa	238	77	14933
22257	https://transaction.rua73d18446f20a30be28c26ab513da8d8	217	45	14933
22258	https://transaction.ru42bf277438d06aeee5e6c7d600dd6a77	126	47	14933
22259	https://transaction.ru5479b642968c670c21367b502dc28751	65	106	14933
22260	https://transaction.ru1aeb6d76623bcda1c3ddefd96d816719	193	106	14934
22261	https://transaction.rue32dd8278276eb3af4d42dcffcbed95a	19	47	14934
22262	https://transaction.ru0002ac0d783338cfeab0b2bdbd872cda	169	45	14934
22263	https://transaction.ru5cb84c7fc32f6f000d984cc5431794c2	114	49	14934
22264	https://transaction.rufd2e50eb378a6dd31e9130653dab98ce	123	48	14934
22265	https://transaction.rue7ff72052c6b4048d30c982515821475	282	77	14934
22266	https://transaction.ru92ccbeb6df1579362f7fe815259195e3	141	76	14935
22267	https://transaction.ru0633b59b948c703e15cc105e8187f18c	180	77	14935
22268	https://transaction.ru2b18c9d1438cd20d50ab4867b027f613	53	101	14935
22269	https://transaction.ruaa261e7d8be67cd5c9b2abaf51d9ccb8	70	49	14935
22270	https://transaction.ru283d07a56eab0dffb0be774e5d40f569	67	48	14935
22271	https://transaction.rubdb6ed1654c6d7d44796d850ca3013e5	294	73	14935
22272	https://transaction.ru93750adef256f4276aee7e01c00ea737	187	104	14935
22273	https://transaction.ru013ff5500acf74536340da1adbc027b9	235	103	14936
22274	https://transaction.ru4b462fc9877e5446209cb45a07d0a043	255	75	14936
22275	https://transaction.ru86c0a35c667b1314f397131bcb535c87	39	102	14936
22276	https://transaction.ru57dc8c153bbb35ccee542cf777a52208	229	74	14937
22277	https://transaction.ru38564a962dc62dcff61cd333d7e14d1a	256	78	14937
22278	https://transaction.rufe83e7232a142b400b81374f5e3591f8	287	45	14937
22279	https://transaction.ru91ccf793fff06e6e1c2b556c3c0effb9	138	76	14937
22280	https://transaction.ru52b7981ab64dc076191c0524ad6041e4	38	104	14937
22281	https://transaction.rud2093598e3babd6de5b9912472fb42e4	291	103	14938
22282	https://transaction.ru0fe46ab155c0766beedf34424155d989	144	77	14938
22283	https://transaction.ru70012f3dafe7a2915b6fe372cfc651e9	28	75	14938
22284	https://transaction.ru8cbaec8e903a2a9fb130bff3aea09b43	192	78	14938
22285	https://transaction.ru67282a304f2072c4994b0e8383ce6a9d	77	74	14938
22286	https://transaction.ru1f4cba038d97dfa6a3e8da9d4b8a8857	171	45	14938
22287	https://transaction.rua256bceff6440828ea3c033a11be9e7d	235	48	14938
22288	https://transaction.ruf0682ea2f69f2d5f172cc7ef557395c3	192	49	14939
22289	https://transaction.rue3cb0afe3dbb0c8e27ff88a8af23e725	118	78	14939
22290	https://transaction.ru2160d325374c26d4d3e8cfd010dd5506	85	102	14939
22291	https://transaction.ru26bce3abcd2c3d9601c507e273d781d3	27	50	14939
22292	https://transaction.rue20585cef40884737cc1646b20c3d5b8	41	76	14939
22293	https://transaction.ru7a610c2f4ec3068061e04d978c8b446c	18	47	14939
22294	https://transaction.ru6f7dd5012c802c3572b245afc6263322	163	103	14939
22295	https://transaction.ruac11d0d53a6eb3abb44f886810043c23	183	47	14940
22296	https://transaction.rue6bf14308290314af7694a75e47c7e12	167	45	14940
22297	https://transaction.ru5695bc7448c7ff7dc9fe886c0559c08b	24	46	14940
22298	https://transaction.ru28e6bdae7d7163196dfc7ff4c979adec	85	50	14940
22299	https://transaction.ru0fa82e2129285e2027c92f14e4cd7cd0	193	76	14940
22300	https://transaction.rudd0a97590cb69800b8bcfeee650fc004	123	73	14940
22301	https://transaction.ru88059058ba56daa4bf889eb6cdf2e6c1	39	74	14940
22302	https://transaction.ru572e25db1143b5225f5c58c57b5c9bdb	281	73	14941
22303	https://transaction.ru06ccc6fac98a777fce43a972eaca83df	256	47	14941
22304	https://transaction.ru9db254b29e0dea589dff5d0d216c4240	127	78	14941
22305	https://transaction.rue0ec2032320db3e2ec47315eb5eefaac	85	49	14941
22306	https://transaction.rub83847c38f3852c830cdd33228539469	243	77	14941
22307	https://transaction.ruf8be956148a06e392edfa1f9ce099839	288	75	14941
22308	https://transaction.rua9fac65d3775a4e1d61e07cffed036d6	63	103	14941
22309	https://transaction.rub25cc0b31b67ee2185fdcd79c8284e7c	194	105	14941
22310	https://transaction.rub7d85c6ff56e723d5438de2042885c04	105	104	14941
22311	https://transaction.ru3a5a96df1b9987ed7e51af69b7280131	202	105	14942
22312	https://transaction.ru9c3c078685f4fd125a643743fb57ca45	215	75	14942
22313	https://transaction.ru0691bcdc10f2a95e8b7d4c5e42a0e8dd	9	47	14942
22314	https://transaction.ru59c48bf47ad501846ae49d3baa06a9f2	162	45	14942
22315	https://transaction.ru56c726557cb428373fcc270349ce4e7b	227	73	14942
22316	https://transaction.ru2b83775c28f7a287cc34efc8b34a2219	258	101	14942
22317	https://transaction.rud7f436be259c3e433e70e8638bcfb373	94	50	14942
22318	https://transaction.ruf69a463359a6ac817b08739bff5da0b5	233	106	14942
22319	https://transaction.rua4c75d5b96019277c8528e8829cbae8e	229	106	14943
22320	https://transaction.rufb0c36c7115879aa704299d72657b889	8	74	14943
22321	https://transaction.ruee92abb95ea4f981646a874c53308cf3	300	46	14943
22322	https://transaction.ru33a1e31da366e25de0bcf6d5ebd81951	118	47	14943
22323	https://transaction.ru89bbab125cb72e9ad0a199edbdfcdc7c	15	101	14943
22324	https://transaction.rue2e1e4edb5548c90a5498bf2ff7d11e6	131	49	14943
22325	https://transaction.ruc1ba696ff1eacd95514733265020a822	157	103	14943
22326	https://transaction.ru2c0b63339e4be15a64989cfe1e362bb3	124	49	14944
22327	https://transaction.ru9a56456d5f604316bc58b97001818d51	82	73	14944
22328	https://transaction.rufc331c8c68eb8d58312e59c0ecde7128	20	74	14944
22329	https://transaction.ru86a22ab2cf7cf79c78e4a4a2d2baaa6e	151	75	14944
22330	https://transaction.rua6c0db0c12decf7c4eb57f932dd10b32	151	78	14944
22331	https://transaction.ruf17295b4094d7dd995c484ca7659d493	7	50	14944
22332	https://transaction.ru85048c169f5529928a150a3f7bacc11c	62	47	14944
22333	https://transaction.ru098e5a91bb323ca6fa65b7727dd19a40	252	45	14945
22334	https://transaction.ru2d54edb960a0f5a9280e5e92fd3665c3	241	47	14945
22335	https://transaction.ru431a9859d954ab13630fe65b59febbab	112	46	14945
22336	https://transaction.ru5a9e8f0086b8ae36e646dd83ad2474bd	200	78	14945
22337	https://transaction.ruc0b5dac5ee95e297f3604ebed1c2a63e	123	102	14945
22338	https://transaction.rue1011fa80a317dcdcbadceb4d6ab4707	32	101	14945
22339	https://transaction.rub5330f0a18c54be65f6a7d4a926d65c2	140	103	14945
22340	https://transaction.ru6959d90e82e532bc039bb2df86ab796b	73	105	14945
22341	https://transaction.ru99bf70c420b0dd463ab1b1761616edbe	159	102	14946
22342	https://transaction.ru745d5fb3d38a0be8fb83ab4e37831a1d	64	101	14946
22343	https://transaction.ru2d12729c665a9c1c3bda27ba1273154c	58	46	14946
22344	https://transaction.ru8f747546b4485e874d9348d97d554287	231	77	14946
22345	https://transaction.ru0c0b3f7479c52a51173e9ddbaa0badd0	292	75	14946
22346	https://transaction.ruf56e62d30711f4a1c3a121c763196ace	133	78	14946
22347	https://transaction.ru681bc59b81cc0b21571721ffe7d90467	261	106	14946
22348	https://transaction.ruc143e6e4130d92cee80611cea22fa185	41	106	14947
22349	https://transaction.rub96c47c59b2a21684dc83037f9721d64	136	46	14947
22350	https://transaction.ru87ff6c9fd50d469ac429e432e5fa4b12	290	73	14947
22351	https://transaction.rudf0093406b80eecd8ae7f3588dd3e313	206	74	14947
22352	https://transaction.rub689b85e68fdcaeab271717aabccefcb	292	49	14947
22353	https://transaction.ru2f7b8032a92f6690b5317bd0e9e0561c	255	102	14947
22354	https://transaction.rudfa92d8f817e5b08fcaafb50d03763cf	294	101	14947
22355	https://transaction.rud01713a4928cc0bd26129bceb58285d7	128	75	14947
22356	https://transaction.ru5e33f97addb2122d0f3cae50f9868f6c	97	103	14947
22357	https://transaction.ru3005fea4c5cbffe61970c4132127fd8e	246	104	14947
22358	https://transaction.ru4b356396e896771a5200d5b2080b2aec	288	104	14948
22359	https://transaction.rudb79cdc98ff47a7d7cfb4172b321c04a	78	78	14948
22360	https://transaction.ru0b74eb6cc0e4ef10576ffcf4cd32a05f	15	78	14949
22361	https://transaction.ru1e7d539f93c8b2c9e36f9cdee1a08ff1	184	75	14949
22362	https://transaction.ru1c0414c0d32e16fe225cd77f128a0355	164	77	14949
22363	https://transaction.ru25c2461fcae953a177ef2c87e2623481	13	48	14949
22364	https://transaction.ruffea6d6e8b8e96a24d395782a1bb0ebb	203	49	14949
22365	https://transaction.ru5f38d272706503da15c64fb43dbf8155	93	47	14949
22366	https://transaction.ru3b378a2c69c1832453f6b419da1d247e	191	45	14949
22367	https://transaction.ru6d48dfa9fa7de7487728cedddd1c0d8e	231	46	14949
22368	https://transaction.ru4a5bd6dde068ea725b2de52868fa1ae6	251	74	14949
22369	https://transaction.ruaeeff75c11076130d7dd456cc32fbcb9	87	103	14949
22370	https://transaction.ru4d2072de5cdda9605cda431fdedcad24	154	104	14950
22371	https://transaction.rudec0c2c2f8b1d6a28105e1709b048161	195	46	14950
22372	https://transaction.ruec169a34f974ccb7e834fbfc88d61ff3	3	77	14950
22373	https://transaction.rud9be06060dd26dab70816594d31e341c	138	45	14951
22374	https://transaction.rua686fe77ffbce07ddcb003a0c518b7df	6	74	14951
22375	https://transaction.ruc52478ead80d883d7791e33dec94391c	202	48	14951
22376	https://transaction.ruf9763c7c46bcdab3814e1707c7fe2c73	41	49	14951
22377	https://transaction.ru038c54b8a09fa8991a84c29e9d87ac78	209	101	14951
22378	https://transaction.ruc9a301400b88ab913ac2602aaad74406	89	103	14951
22379	https://transaction.ru39a152acff89e0f3a498cff57deb4aa4	150	103	14952
22380	https://transaction.ru427c3381a0f93b18ff12f111b965ecfc	155	104	14952
22381	https://transaction.ruf223be652d366ba1d6cbcce473b5a3e3	144	77	14952
22382	https://transaction.ruf1c8f64227690c2c88c48b74551d0420	19	46	14952
22383	https://transaction.rue82a88d937e60267fd2c866b01131ada	286	47	14953
22384	https://transaction.ruc3f44d0eefe9006ed9dce1253510842e	64	74	14953
22385	https://transaction.ru59ff57994911132254e9bb70c87f3d11	285	102	14953
22386	https://transaction.ru3d653d32337a2b37a73ada79408db0c5	217	105	14953
22387	https://transaction.ruc7577b4c658873e93eb34368405964cb	131	104	14953
22388	https://transaction.ru8ddfdfb18f81e441848af50c049325d9	90	104	14954
22389	https://transaction.ruc24a65a29014c0943a63a45508d8bc38	26	74	14954
22390	https://transaction.ru21c22eeca3fcb1c69935ecf52ab82905	285	75	14954
22391	https://transaction.rucea538269d3ddf9565999b5ebb0d0cb6	26	77	14954
22392	https://transaction.ru2e941052c8a72bfa63809a1fc6aafdda	279	78	14954
22393	https://transaction.ru1db92e07bcbde6f6b61f1d9ced351fb1	165	47	14954
22394	https://transaction.ru642232b6e733c7bccc2f094cf45d2bb9	265	45	14954
22395	https://transaction.ru7a280c66e23440322a49ee66dd31f8a0	182	49	14954
22396	https://transaction.rua94ff7b9d81529a5b17b4cf3c136a9ef	140	50	14954
22397	https://transaction.ruc12ffa295ce6cca710827052f25f0eca	295	50	14955
22398	https://transaction.ru55635ab18d4cd07e8828b3915af46b87	77	73	14955
22399	https://transaction.rue545a4761069384e78d91f0c50d9e61c	126	76	14955
22400	https://transaction.ru585e272bf2d6f9ac1ac03b6cd4470b4f	236	77	14955
22401	https://transaction.ru559daebb4471c955e5f38267464000b8	132	49	14955
22402	https://transaction.rub9373a323dc6185127365636c7ef12ee	296	103	14955
22403	https://transaction.ruc5132218b76b273d9445aec2a71b82eb	89	105	14955
22404	https://transaction.ru87675b4048f1952ce908c7b7384578c5	234	106	14955
22405	https://transaction.ruafa759b5008244048b2e9114e378dd0b	251	103	14956
22406	https://transaction.rub26501cbe72a43309848793bd3e0bb1c	203	45	14956
22407	https://transaction.ruad58b23d52b82a02c73b27a14c4d79b7	229	47	14956
22408	https://transaction.ru90973e8d8b5fd2d419b7187a1dbdc083	122	45	14957
22409	https://transaction.ru9a4fc8cc1f7185d30d5654b0bf33c9e8	71	77	14957
22410	https://transaction.ru5d73c5fc7d1eb93c1cb5f766d3b34c42	179	76	14957
22411	https://transaction.rua2b45e7eaa7a1376c3fb1b13fd31620b	261	104	14957
22412	https://transaction.ru98029e602042437f35d7def2c08472fa	256	103	14957
22413	https://transaction.ruf4b78ee287f6140a58c8a44341809b80	97	106	14957
22414	https://transaction.ru55dc44f459bbda38b6148caaf07ac8cc	165	106	14958
22415	https://transaction.ru834247ac1e070d548703ba8b9270f925	177	104	14958
22416	https://transaction.ru6298ccd05ebec6281bbb56f704df238e	212	103	14958
22417	https://transaction.ru5017eb062275954c64041ffb7afb5b0f	219	105	14958
22418	https://transaction.ru4709650fb69e8637310fe975ae2f4361	282	77	14958
22419	https://transaction.ru1a29758f6570b204c74413a708fc8211	186	73	14958
22420	https://transaction.ru7f2c5a6136d65141f9315c447cf2587c	168	101	14958
22421	https://transaction.ru02823bd982d4812b5bc3703e43e042f4	158	50	14958
22422	https://transaction.ru7c0d2acde6082f93267fe43b7e7e39f1	214	46	14958
22423	https://transaction.ru4683d24585278571c1d7b15fdf24377e	205	49	14958
22424	https://transaction.rucfda9c4924e1ab06eb1bb3bb20b827b1	124	48	14959
22425	https://transaction.ru6f87f617901d4a5e1a3da79b1e2cbbea	4	101	14959
22426	https://transaction.ru827cbae1c9dcb8b0d2a25f2e8003a53d	77	77	14959
22427	https://transaction.ruc90fff65609a8e24015f10145388930c	224	74	14959
22428	https://transaction.ru09cc81573173c8a5edd42cb46120493e	24	47	14959
22429	https://transaction.rua14f14ae725e9312128c44b7986f2b61	215	46	14959
22430	https://transaction.ru50c59a545dec989f0414512cc8a75f24	192	105	14959
22431	https://transaction.ru2e801098c1bf56adb3dd2df49483e755	180	103	14959
22432	https://transaction.ru97686bb4266843fb1b33a4c14d442e4d	23	106	14959
22433	https://transaction.ru813da0d0c34b6ec73d36a60f87842232	280	105	14960
22434	https://transaction.ru243d353b44e167073a40f8bf33a02adb	72	103	14960
22435	https://transaction.ru490120ce0ccf7a44a9ea68c1bafe66a0	213	47	14960
22436	https://transaction.ruc81ef80ecde3d941d129c74e91d91d0b	280	75	14960
22437	https://transaction.ruc42623bce877fefe6d5f306b56b81ed9	202	73	14960
22438	https://transaction.ruc272236e6746984c9b3171fbbb5b0876	161	73	14961
22439	https://transaction.ru8297cd71f7258747c8bd65b2382a02a8	71	48	14961
22440	https://transaction.rucb99c021d78dfebe2ffe444b4c82fd77	66	78	14961
22441	https://transaction.ru9f691d757cc0383069bfe96196add746	146	102	14961
22442	https://transaction.ruf739a0dbbf1b745f16ecffcf4642a00b	297	76	14961
22443	https://transaction.ru9c6050a4b56856fc319e25f2eeafcc64	62	75	14961
22444	https://transaction.ru09dfb3d3b778f74f51fe6c193bd62c27	267	104	14961
22445	https://transaction.ru871af90a67f708856205f91d81b35d8b	55	105	14961
22446	https://transaction.ru27f6ea90dc1974a552fd8c9fbc02798e	98	103	14961
22447	https://transaction.ru0da1777641703c9d902e3060294f4350	242	105	14962
22448	https://transaction.ru9f051d1aefc9846d29476e316b06138b	177	104	14962
22449	https://transaction.ru5e0fefa1176304e38a5a07f2290ed58b	173	46	14962
22450	https://transaction.ruf25a8258bf85d1263a645e64b23e29d6	284	106	14962
22451	https://transaction.ruec222198040692f276c7128d6a361b8b	175	45	14963
22452	https://transaction.ru7e537a04335622e13198b6fb1f67ecbc	174	46	14963
22453	https://transaction.ru4821e73e58c158f558e8d39954b31120	120	76	14963
22454	https://transaction.ru6f1046e4cf56d909517c488f1a5e4a23	299	78	14963
22455	https://transaction.ru4ad4168f717c53e39b1f4ee68c3a2256	183	50	14963
22456	https://transaction.ru677857aea6dcbbeb618372901a81598a	283	105	14963
22457	https://transaction.rub288a686fec441fe006997e677a15825	149	105	14964
22458	https://transaction.rue422cd2f33cac24244cb94e180c48957	176	104	14964
22459	https://transaction.rudd0682a34159a74aeab250db3ddf7a81	161	75	14964
22460	https://transaction.rufe299dec2b22528c1de6fad6aef7bf63	26	46	14964
22461	https://transaction.ru8907bdedb77ce978cde43c2d8f537e9e	123	45	14965
22462	https://transaction.ru9860c029232233ba16f6b5d4d9df4a3b	137	46	14965
22463	https://transaction.ruce5cb64825b6cfbf102979a3459e5cba	244	47	14965
22464	https://transaction.rub8bd371590c1746d40738282ab023bce	294	76	14965
22465	https://transaction.ru4d9326bc27f7352ee004193029d160c0	55	48	14965
22466	https://transaction.ru83fa7f6838694617522e298f50656960	88	101	14965
22467	https://transaction.rucad4c8ed0d6932380fe81a00e07d7421	16	105	14965
22468	https://transaction.ru65c7be386f18e259627f9a87fcc00d12	166	106	14965
22469	https://transaction.ruab7d19e82cc921e91e92dd470f68d47f	12	103	14966
22470	https://transaction.ruadf61026b4605902a60153a9d3141e79	123	104	14966
22471	https://transaction.ru6a90c7ab723273d40e9a8ef11444ed5c	18	76	14966
22472	https://transaction.ru7709a257f7b09a041ef7e02fd45a824f	292	73	14966
22473	https://transaction.ru0043b22e222b2d60e267536d195d4f1b	240	46	14966
22474	https://transaction.ru934131ba20b15b38ef64243f03042f0c	121	49	14966
22475	https://transaction.rub714a4d76a7509b3136852f478365b1f	116	78	14966
22476	https://transaction.rufddfd6f1faddcfc5a0a01d172ff38131	84	78	14967
22477	https://transaction.ru500208700bcb9fcd6866764d2dfbb832	34	50	14967
22478	https://transaction.ru576c88df9e53ae9ee2d0461217328799	199	75	14967
22479	https://transaction.ru9ce050e2f8b9a793dbe3777b394500ad	216	77	14967
22480	https://transaction.ru4cd8773e5cdfe7e17255e90d2424758a	25	49	14967
22481	https://transaction.rucbd56389b54c91ef838097a45115ca69	156	45	14967
22482	https://transaction.ru74c6de8d24d6fb8ad708ee015ff28a19	92	46	14967
22483	https://transaction.ru0bc26b3e56178bffed03e9f5924eaa6a	67	46	14968
22484	https://transaction.rubfbe0dd801156aadecd891495b9d396e	118	74	14968
22485	https://transaction.ru3799209d72c0255ade6f7bc5b904a044	52	49	14968
22486	https://transaction.ruca67b3220f5d52c3a358eda18776c51c	183	75	14968
22487	https://transaction.ruad8de469bbdfec8f0206f70e7ab546bb	71	104	14968
22488	https://transaction.ru4f761c2430e38e7f58061f3b6b003a27	217	106	14968
22489	https://transaction.rucd09c84d63506d6c3beed3f18b2e0176	143	103	14969
22490	https://transaction.ruf165024f816bd38891e7380201cdf7e4	193	104	14969
22491	https://transaction.ru474c04005b680d99f2cc3b94109eb333	278	77	14969
22492	https://transaction.rud37ce3b1d1795cee995530a0dd3d59a0	176	50	14969
22493	https://transaction.rua12beaec1f96a9bef29e0cb4f5690d72	162	101	14969
22494	https://transaction.ru2d29c67561a33afa8a24be37909dca89	212	101	14970
22495	https://transaction.ruc8ddf6aaf9df7c4815b5ec31d0605693	34	77	14970
22496	https://transaction.ru1a74322d3606acccf993ac4ea3b53cf2	135	76	14970
22497	https://transaction.rue0c7429db8b5fe3fcdc96c57897d8725	42	46	14970
22498	https://transaction.ru556dd6e75400f8f61f8e864ebef83147	37	45	14970
22499	https://transaction.ru5e614a11a083181506cfc68f2918e3bb	236	104	14970
22500	https://transaction.ruc571736fb09f3ee7e2c147cff40327e5	80	104	14971
22501	https://transaction.ru5f21facf06a0f658abbc4b7631708b3f	267	46	14971
22502	https://transaction.ru3b1db1873d9402c039bb30c6f1e08eab	178	77	14971
22503	https://transaction.ru519ed5f273af363302be90a9dfc355df	218	76	14971
22504	https://transaction.ru6aaeaccd09d2760215ff197a3a01565e	151	101	14971
22505	https://transaction.rua7d168e1680f9a6f1117d83481afb82e	113	102	14971
22506	https://transaction.ru0d145d69b1a02409f6858bb82366ef88	12	48	14971
22507	https://transaction.ru1fa24f269d38a8468033491a77f156ac	200	73	14971
22508	https://transaction.ru115a44d0ab65cbc8e2bf839908a21ef3	208	74	14971
22509	https://transaction.ru404a8b3fd49b857ad4fd6f2757e7d41a	258	74	14972
22510	https://transaction.ruc717cac701d47e5f280367cfc5ce279e	77	76	14972
22511	https://transaction.rua79ad948911f003b08290e1515433a79	152	45	14972
22512	https://transaction.ru35efb547c1dd3e34decec4dcf8a89ec2	120	48	14972
22513	https://transaction.rua078e8b2fe4c844e24f59c73ee6e7a4a	109	102	14972
22514	https://transaction.ruc4840c8bd5dec2617c77a2d3589ca928	108	104	14972
22515	https://transaction.ru2ef71cbbdf71f4b87711026b12e879da	82	103	14973
22516	https://transaction.rua0b3831c84440510ced12c46a2838500	141	104	14973
22517	https://transaction.rua680796a45c8d0772385aab3195b5304	172	101	14973
22518	https://transaction.rue14122cd6a12903e0fed829048b1769e	208	102	14973
22519	https://transaction.rud9106553cc5dcab924a87b57eb707fdd	143	50	14973
22520	https://transaction.ru03afcc66a335aedd07630bd999d2c8fd	149	47	14973
22521	https://transaction.rubc7b19b235b1b1910c1927df93a6e4fd	188	45	14973
22522	https://transaction.ru2c73468059a48516f87a983c648855df	195	47	14974
22523	https://transaction.ru4bfe448cf50ae6cdeff1137256d02135	120	46	14974
22524	https://transaction.rud203a8d00dbb9f465ecb3deda8c7cc6b	23	74	14974
22525	https://transaction.rue4bb4751286d1511e9ec4030a50d6fab	18	73	14974
22526	https://transaction.ruf2e61cfcc152fc5e34c02f8c87f266c2	22	48	14974
22527	https://transaction.ru6519cfa21b0df9df66bfdc794cd223a1	255	106	14974
22528	https://transaction.ru74194397652b6edd4c070a87ee2f90a4	157	106	14975
22529	https://transaction.ru188a02f3e82636b576993bff4c8501f4	104	75	14975
22530	https://transaction.ru3d059c6932915555ce541991c4d4c605	160	76	14975
22531	https://transaction.ruadc8e5d4a3ad165b4a4322fe43889e07	118	73	14975
22532	https://transaction.ru99d7288a6e9a5ce6088f776b6688685b	272	103	14975
22533	https://transaction.rud69030fed0e082d5fb28a78897aeb7bc	246	105	14976
22534	https://transaction.ru476512d0af97ce6b9e7c0a04a622cd13	142	103	14976
22535	https://transaction.ru709684d6c675788aa732b168f5bce553	165	48	14976
22536	https://transaction.rud12bfafae6cf6568bf0b0cb522bac431	10	47	14976
22537	https://transaction.ru505a8a67f4fbee0ef14c4834a6765db5	288	78	14976
22538	https://transaction.ru86a0f4e0b1059e9bf485ad53bea16b23	3	77	14976
22539	https://transaction.ru05b887035fc89a5ff631dde37a8e2c2d	10	76	14976
22540	https://transaction.ruf0c51f6c4e6adeeca4a2920803c33072	65	50	14976
22541	https://transaction.rucd7bb1c870d6c43c38fde42ec0fc291b	253	46	14977
22542	https://transaction.ru94f19a09e17bad497ef1b4a0992c1d56	251	101	14977
22543	https://transaction.ru49dc4b08602142dcb71060a4ae3c62e8	200	49	14977
22544	https://transaction.ruc96eca8ba5d55dbf5d5044dc1f5d5bf4	125	78	14977
22545	https://transaction.ru3f1c7321af0047f6d744c7a69a01c3ab	188	104	14977
22546	https://transaction.ru45cdb55866bcdb7caac8f7e643856747	264	105	14978
22547	https://transaction.ru3c79ea80ed31b264d647f9039d1be05b	196	101	14978
22548	https://transaction.ru5a534612f7c36aefbc4e815a381e308a	290	46	14978
22549	https://transaction.ru03a395449ba1e34fedfda7d928a0815b	198	47	14978
22550	https://transaction.ruaf77d6d388c70a4ee3d2e986f77de0c0	274	75	14978
22551	https://transaction.ru72938417820eb53facfb0e29299ac333	41	77	14978
22552	https://transaction.ru97933cfc9c49d400ac7ad6d9a6e918f3	82	76	14979
22553	https://transaction.ru13c1b37418aeba4d4ef675ad7f09fb2a	252	77	14979
22554	https://transaction.rue25e70266bef92feeef9b98ede022a70	129	75	14979
22555	https://transaction.ru5ee1b8574e2fefa3d2e873224d259795	148	101	14979
22556	https://transaction.ru37ccb07767d30e10f88c87f849c222cb	144	50	14979
22557	https://transaction.ru295193214080af8c41ede9c9526a423d	284	101	14980
22558	https://transaction.rucd3cac87ad47f9202623ca3edae3e6a3	243	102	14980
22559	https://transaction.ru2580087a760de9220ef0c2eaff756ec5	159	46	14980
22560	https://transaction.ru97edf9ab46f76de90611acbb5c451134	249	49	14980
22561	https://transaction.ru7c42478604edec00caad68e6003bc0db	11	48	14980
22562	https://transaction.ruf9d796f1ba02bc4fa724dd56bac4a3a0	287	103	14980
22563	https://transaction.ruf3388a12a9fb2b4c38adfb2b32a19afd	153	105	14981
22564	https://transaction.rufcfa953ef01b8909174e37690d523135	262	104	14981
22565	https://transaction.ruc83672b405108aa3bccc9e3d6692ba05	126	77	14981
22566	https://transaction.ru1c9feb4dcb1fb6610e60e3e1e926b0f9	217	76	14981
22567	https://transaction.ru2aaa9a7808139d2c5b3d8ee1b519f31a	71	74	14981
22568	https://transaction.ru1b9b427a991b29675d079b207cd32f8d	120	46	14981
22569	https://transaction.ru66bacdc5bbb562cb48c32288ba034575	245	106	14981
22570	https://transaction.rua796c2e10835c6e41a8084bd24ce1020	50	106	14982
22571	https://transaction.ru2cd1322e8cf6898cb8057e1e37f6f311	79	46	14982
22572	https://transaction.rub3c8a786180720293b3e22d2fb71ae1b	131	77	14982
22573	https://transaction.ru30693c4d708e0ac4dc7e813cf4b09597	61	49	14982
22574	https://transaction.ru9ce4075e3f5e88ec86cf4c51a08cdf93	187	50	14982
22575	https://transaction.rudf610af70f04907973495ea19de56df3	70	78	14982
22576	https://transaction.ru6cea8413217ef530228c89b10bf15a34	206	73	14982
22577	https://transaction.rub0cb2c59e7648dede80b2b2605ae6701	300	74	14982
22578	https://transaction.ru452cc7718d2d224c582f6f2b8d5b3d30	248	102	14982
22579	https://transaction.ru33462afd1f5a5d3d0ae082398cf8ad91	250	103	14982
22580	https://transaction.ru850a40f2ba21fec8567a3769263d1c5c	146	104	14982
22581	https://transaction.ru2d0e2af1c5b60359f9ea5f944d19ed65	284	105	14983
22582	https://transaction.ru251d480de4d28f35d249166cff9ca4b7	200	102	14983
22583	https://transaction.ruad77e7bbd7914dd7018203b05bde16a9	123	75	14983
22584	https://transaction.ru9c896f424d544b562b80d852f0ae3f98	126	45	14983
22585	https://transaction.ru2103f7d3bce0a72e60bfb0eb47e03b37	258	46	14983
22586	https://transaction.ru5d66e8ccdcdeade5f60edf6b2e5ff369	194	49	14983
22587	https://transaction.ruc67ee7951c1aff01a2750b7e60a9fe4f	117	73	14983
22588	https://transaction.ru93e945e8b59a0584f538037d4816e11e	239	74	14983
22589	https://transaction.ru95f53691c21cae7ee3c87c54601c9d0d	113	106	14983
22590	https://transaction.rub6e5ce2cb5b7033a4385d0e31438d998	78	102	14984
22591	https://transaction.ruda7cdf04ad12160cbf56b11f4ae38f0d	259	75	14984
22592	https://transaction.ru8f38a29d2a2d3593e953799c8ecdc180	56	49	14984
22593	https://transaction.rua5e226b39b5cea9fbc2ad7890d3ce0ea	197	105	14984
22594	https://transaction.ru7ac6928eca02dc66b177f6f69b396430	188	48	14985
22595	https://transaction.ruc78f6550afbd3b3d9560a34220c22d5e	98	46	14985
22596	https://transaction.ru1f77d9ca85b582535ee7dd759ee8f7b8	46	73	14985
22597	https://transaction.ru6543deb0668c820c10c959822ffd43c3	9	45	14986
22598	https://transaction.ruf1b51a1d76676dd1145b7dcbc718e8f4	58	102	14986
22599	https://transaction.ruf84a62a0a2d48aa2fb23a9c55f6e0fca	155	48	14986
22600	https://transaction.rue55b275db500acb840d92add5b519580	180	49	14986
22601	https://transaction.ru8466db91ab7227148d64a4c0383cf667	66	75	14986
22602	https://transaction.ruc14d241acbc5861cfb8bd95cf2535812	273	103	14986
22603	https://transaction.ru0935ef6e7764033ec95cf8b939901f15	113	76	14987
22604	https://transaction.rua369468266fdd81807512a5221b53b73	279	46	14987
22605	https://transaction.ru1d4a0b6a326786e337031947dad0bd0a	18	45	14987
22606	https://transaction.rudd7235bb50ae9108893455953e53811e	82	45	14988
22607	https://transaction.ru612ad34f88e19cc7e8f1391b409d5be9	218	77	14988
22608	https://transaction.ru751ea78947755d8a04b259e34cbe8d40	68	101	14988
22609	https://transaction.ru964da5bbe0969e28f910da762e528ddb	58	48	14988
22610	https://transaction.ru5ec18bcd547ead122cdf43a13ebb0441	244	103	14988
22611	https://transaction.rue763eba2a6c1cda79e64f7b058c4c48c	267	104	14988
22612	https://transaction.ru6e9fb4677976eb4222716d71126b02db	191	104	14989
22613	https://transaction.rufc67516a37ad1f536d814a19ff68fadb	36	103	14989
22614	https://transaction.ruec6e411553d04950c3225c1fbdc8d116	244	49	14989
22615	https://transaction.rub9990778312620a17e2fa3803bad5496	174	75	14989
22616	https://transaction.rub503bef8cdd5c7b0e2d437bd9d9b5807	164	74	14989
22617	https://transaction.rub5898665edc3c7299b72106acc8b14a5	16	46	14989
22618	https://transaction.rue65408ef50a790e300bd98ae473a748c	277	47	14989
22619	https://transaction.rufde29c7fa08783493fc9f1fa8b5eb903	90	101	14989
22620	https://transaction.ruc37419c3eb757d778817731cb09b681a	209	78	14989
22621	https://transaction.rue84f172b14e522543b87d6201224283b	237	78	14990
22622	https://transaction.rub5d3dd0276d0d054a07adc24a7cf1f50	93	50	14990
22623	https://transaction.rub5191679b26d0202c9b0221ae88599d5	16	77	14990
22624	https://transaction.ru58c3de48eae0b521bb727d23794f88dc	63	45	14990
22625	https://transaction.ru0fe4b329695b61dbac5d53e67d195739	70	46	14990
22626	https://transaction.ru4b01c9783e41c24921f80012978ed36d	63	105	14990
22627	https://transaction.ru554fefe32f50caff91e8fddc70c59d00	251	45	14991
22628	https://transaction.rue1a9fa972cb778d60bd9703d787503aa	250	47	14991
22629	https://transaction.rubdfcb66b4009b51869ea9ecc5760c4e4	188	46	14991
22630	https://transaction.ru0d6139fdbc7238dbf14cc1997b83ce58	236	50	14991
22631	https://transaction.ru45af7faf205ebb7504926541221497e7	107	73	14991
22632	https://transaction.ru3fd777d7d7f349da6cc06252a9dc6b43	168	77	14991
22633	https://transaction.ruc1fe4e32589c9d10ef8a9b8b0a908970	180	48	14992
22634	https://transaction.ru148ef63bea993c17867ded5b2bffd7c2	78	74	14992
22635	https://transaction.ru6e1dd87ba78b6526143e51558eb13690	145	101	14992
22636	https://transaction.ru8062fe16c5b1bb02c68e15aa71fe0e27	59	105	14992
22637	https://transaction.rufd488ab630ab23a868f975f2bc247891	102	104	14993
22638	https://transaction.ru08afa190751ae96261f93c392469a459	130	77	14993
22639	https://transaction.ru0df1a43eda65219ae0e75ec583b36d47	285	50	14993
22640	https://transaction.ru2654d0b7f352636bf9ca464fe819cbe0	47	47	14993
22641	https://transaction.ru976286ee50fdf28f72d0192f7a3ab6e6	91	106	14993
22642	https://transaction.ru187e7d29aece96108476452a20732d97	26	75	14994
22643	https://transaction.ru6b72dd1a40d856ed118dc8be0383e5ab	253	76	14994
22644	https://transaction.ru66889ab459f3d2cc131cb35d1d8714d1	242	78	14994
22645	https://transaction.rud0226db8bc06f4b61680904c20ed271b	216	73	14994
22646	https://transaction.ru1b75b29ad9ab01787ff9141174d90a73	103	48	14994
22647	https://transaction.ru9e6e65fab2f66cb6f758102e231a198e	172	104	14994
22648	https://transaction.ru41a902776052fb9185788cdddfb957c2	191	77	14995
22649	https://transaction.ru55b53a4c96ff5304d396a30a77982e32	35	46	14995
22650	https://transaction.rua3ec6dd8d538712a581e5b24726ce062	72	74	14995
22651	https://transaction.ru47e4cd665c88f767ff40368b8de87b87	24	73	14996
22652	https://transaction.ruc3edd5776997b18709e1d48032a220e3	270	101	14996
22653	https://transaction.ru4565099b9e2d623494e2fdd27f214d56	220	47	14996
22654	https://transaction.rub28355ee4d5ea3052c225da1be3dd3ee	46	46	14996
22655	https://transaction.ru7965dad9222c59ee4f13732c37e87608	192	103	14996
22656	https://transaction.rucb470c1c866f7560888069530d44b1a3	252	105	14996
22657	https://transaction.rubaa8f2b83fe4e6af69cf61c905b3ec84	237	103	14997
22658	https://transaction.rud6a7a158ed62bdb99ce90b88adbe7e0a	247	104	14997
22659	https://transaction.ru46e1b1d5939aff8b0dc24a1a85c5f41a	257	73	14997
22660	https://transaction.rue6b25341dc10ee27c7a3f84e77541317	246	75	14997
22661	https://transaction.ru3c3865edb8b014481daba81c542c1ccc	16	77	14997
22662	https://transaction.rucb6087de708c85b99ddccea7660b7d53	229	76	14997
22663	https://transaction.rucd88d92a9b64b17c88d229976a8178fc	257	48	14997
22664	https://transaction.rua094cd641b307154760d15520fa64047	199	77	14998
22665	https://transaction.ru49eaec28f4900fa5af48bc8d1961b071	223	75	14998
22666	https://transaction.ru147f1bd51c2d1d33ae2b88f22d936288	37	102	14998
22667	https://transaction.rue43d49a50c08819b4f9c1b3aa8c244d0	167	101	14998
22668	https://transaction.rub95b90d399d50553828766f74b15fa51	57	106	14998
22669	https://transaction.ru5724f4dda9063a3562f787d8f9ea1194	173	101	14999
22670	https://transaction.ru3381294afe5973d75687e1db220d74de	102	102	14999
22671	https://transaction.ru327af0f71f7acdfd882774225f04775f	266	48	14999
22672	https://transaction.ruc3b54cba87e5341d2fd095f805b861af	126	49	14999
22673	https://transaction.ru7206d1af464f880847f04745d8144b38	282	46	14999
22674	https://transaction.ru2023795449777e56147fd1001bec2ac6	248	104	14999
22675	https://transaction.ru4d0357e14f8acd8710baa2cec421acef	5	103	15000
22676	https://transaction.ru7495684a603ffbac7d824efc69be6eb9	17	105	15000
22677	https://transaction.ru03141a70e286642e8f1f301a25e23cb4	141	104	15000
22678	https://transaction.rue02634888b8a3d9dc0a976d141474951	150	46	15000
22679	https://transaction.ru0e70e7f6d4c91900d6ed0933d8a89521	199	45	15000
22680	https://transaction.ruc89589f2f813c54a8bee078edd549f56	271	74	15000
22681	https://transaction.ru18301e80a6f88ceb77843492a6669407	82	76	15000
22682	https://transaction.ruc7c1fdf1e0fd551b67b75c97aa8a104f	237	75	15000
22683	https://transaction.rua7c08b1b5f2edacea6c6bdb52353784a	70	78	15000
22684	https://transaction.ru1e58b46d2f569f337f4cd45fa85580c5	179	111	19701
22685	https://transaction.rufa8ca1bdbe815cff5e4e45de9f950e21	64	53	19701
22686	https://transaction.ru710c3ca2a92a68424462dccdef854cbc	264	54	19701
22687	https://transaction.ru97620e8a768f5f40d2b05459d4c6f29e	224	79	19701
22688	https://transaction.ru1b808d74334db957a108380a5a4318a4	131	56	19701
22689	https://transaction.ru05ecd3720afab3fb24200582b2a85697	224	108	19701
22690	https://transaction.rucac62865cddfb8e55140254d04c1173e	78	107	19701
22691	https://transaction.ru986b0ac843b6909522bd6d10b1f2e2d0	93	80	19701
22692	https://transaction.ru2878afef7a3d591562f512a47412b217	261	81	19701
22693	https://transaction.ru964873d623675aea3ddb601a72027095	36	83	19701
22694	https://transaction.ru216595ec56fcfc637de86594e1c1578b	211	108	19702
22695	https://transaction.ru293dc36ecb4bfa3a29b44cf254ee22f5	25	56	19702
22696	https://transaction.rub0bb0992e23691a492309e61509fc167	252	55	19702
22697	https://transaction.ru44efe1e3886f63843582e352c3bfec0e	168	54	19702
22698	https://transaction.ruf696b601aaf65b172094b0ff7b231d4e	94	52	19702
22699	https://transaction.rudf374596b21fff9bcb4ab478f48e5d99	144	51	19702
22700	https://transaction.rucc1683fd90cf975864ec0d202b588877	208	79	19702
22701	https://transaction.ru552cdc4c2ecde9454c03bb8482200bc9	169	111	19702
22702	https://transaction.ruebdfa1533f75f24a1305e6f5d0bd09b1	89	80	19702
22703	https://transaction.ru3401d92e13aa4a378455cfe27b9dd604	282	81	19702
22704	https://transaction.rue2c91ce0e0aa42b9d265395a192e033a	274	82	19703
22705	https://transaction.ru41396874ff988010795af7032eb31d5a	283	57	19703
22706	https://transaction.ruc92b69497ed31cb3d689b21158158d3e	236	51	19703
22707	https://transaction.ru65b3d63e49eb8e16db4313306f0155cb	173	108	19703
22708	https://transaction.ru6646ef54659f3460a18da98114416ec3	177	84	19703
22709	https://transaction.rud5fe0eff6e4e9b7b8bb3c85ead67171f	217	112	19703
22710	https://transaction.ru5fc85b18dabd1efb3a401aca77f83459	151	111	19703
22711	https://transaction.ru0ae4b363e75cafcf413e479dabf994f9	116	113	19703
22712	https://transaction.rucd0d3644bad027859b1ec6128a36a974	281	109	19704
22713	https://transaction.ru5048c7d71e48ba9868e7cb51a0372cdd	118	108	19704
22714	https://transaction.ru77d51151b884ad3ff45714ec42c3dba8	271	53	19704
22715	https://transaction.rud979c6b9505f55f29948079c9e4e21ab	271	54	19704
22716	https://transaction.ru74ea005b80397b35a8846d1d8cb314bf	265	56	19704
22717	https://transaction.rua6a9cbf260ad036e9ca2d5f651604d66	245	81	19704
22718	https://transaction.ru59de94177efe9971d4ba96beb172f985	2	80	19704
22719	https://transaction.ru79e61e60dd63ed268851c669c826f43d	34	82	19704
22720	https://transaction.rufcf81415a0fe85c4eeda3713df2f34a1	116	85	19704
22721	https://transaction.rub94cb07ad952c77f20d6827e6f405dab	15	83	19704
22722	https://transaction.ru3fcd7ca552e9c3ef15399a2cb14860d6	19	83	19705
22723	https://transaction.rueb52e1142cd17c244991014fde6fa30a	60	80	19705
22724	https://transaction.rue60b3e71b1f2ade15852eacefa0d02a8	78	81	19705
22725	https://transaction.ru62504de384b50db8eaebd3882da68b61	260	110	19705
22726	https://transaction.ru25fac99a7e76310b5286a9df9c3839a1	273	57	19705
22727	https://transaction.ru23da5d0b7c9300ec812d69fa63d7761c	237	56	19705
22728	https://transaction.ru67a1ba4a554a1177b80031b6182eacc4	238	79	19705
22729	https://transaction.rue5fb4c8a0221ae2e50d3efdbc5a991c3	287	112	19705
22730	https://transaction.ru061ede0cc76094c99bdbee2cb93436df	146	110	19706
22731	https://transaction.ru94bc0fac2bb9a05f685192daebca6472	200	113	19706
22732	https://transaction.ru34e4267f2443113efe5fa455c100fd78	180	81	19706
22733	https://transaction.ru3d40dc877e06bc4dc71553e9152cbef7	97	55	19706
22734	https://transaction.ru4a47d2983c8bd392b120b627e0e1cab4	62	52	19706
22735	https://transaction.ruf059de47eaed84913f5562c643429e64	238	51	19706
22736	https://transaction.rue6ae4729a44ccfe78a11edc5cb69f55d	299	85	19706
22737	https://transaction.ruf99538ee8cae8dfff6d3997208c76e3a	2	84	19707
22738	https://transaction.ru6e1e8b46e74f60025f37545fe8070f49	19	83	19707
22739	https://transaction.ru90f51e880a894d50f771c32bba1055e9	95	110	19707
22740	https://transaction.ru3026ecf28baac2afff23d382d16a4331	16	109	19707
22741	https://transaction.ru8b0e3e98ff5ed5d18461f8479dda0d16	7	51	19707
22742	https://transaction.ru51cf4faf3b8b705fbfa6d97bd1597b7f	167	57	19707
22743	https://transaction.ru2b9b4ffe0370e7668e16e16958433095	86	55	19707
22744	https://transaction.ru876318dfc7c01d5606706ceb11e53bc2	195	82	19707
22745	https://transaction.rucce0dcdc8c68acea2aff2b8c6f1223e7	301	80	19707
22746	https://transaction.rub61f754046c4fc486faad1dda494820c	84	107	19707
22747	https://transaction.ru0dfb578656dc7430b29f5933a8eda515	259	107	19708
22748	https://transaction.ru43e6f702e6cff467e8e58a2def2e7fb9	143	113	19708
22749	https://transaction.rudad81ad8753b183d74e9a42800b299c8	87	110	19708
22750	https://transaction.rub4d51a7475d94a1a510a3e9cbb9033fe	55	53	19708
22751	https://transaction.ru562b6ccbb76ec800f49cbfdb850e1a24	24	54	19709
22752	https://transaction.ru17b5b576f6fa9170d1ef9df0cfc23fce	183	53	19709
22753	https://transaction.ruf61eb6f61191e768aca136998696ba11	81	52	19709
22754	https://transaction.rua2e7f07a68d5d494124b2ba7bfa91fe2	296	79	19709
22755	https://transaction.ru8429a55ac64074c78f3779e7e0cc7695	124	57	19709
22756	https://transaction.ru7d75c4ac203305dff29778642f8d7cad	80	84	19709
22757	https://transaction.ru8257a3cf4de4023e2141546062df4619	69	111	19709
22758	https://transaction.ru120c074b1376cffa1867ac25acf1f3ba	116	112	19710
22759	https://transaction.ru9cdc97552d042efb5b025ad5e50c258b	25	111	19710
22760	https://transaction.ru5eab398d6168823ed14fc5040d25db81	109	107	19710
22761	https://transaction.rubc055c24490c94360a425958159b03ee	201	110	19710
22762	https://transaction.ru9fc67cdb9f073749b84c362ac163a299	113	82	19710
22763	https://transaction.ru5d670eb5d5cfc67dadd9605f884368d6	48	80	19710
22764	https://transaction.ru5e77ca3697ddd290236c324dfe0f5c29	167	111	19711
22765	https://transaction.rub505a6accc00a5b8d3000cb9edcc4da2	184	52	19711
22766	https://transaction.rud02e9bdc27a894e882fa0c9055c99722	50	54	19711
22767	https://transaction.rue5df1b50336b2ef119e4d755683b44d3	36	57	19712
22768	https://transaction.ru0e73a073a5d29487a44bd0aaf2532b5a	17	112	19712
22769	https://transaction.ru4a6718180452495a25ddf317e0b73e59	187	111	19712
22770	https://transaction.ruaad16c2c5002904c3973194b1bbe63ac	52	82	19712
22771	https://transaction.rucf9341b8b77a2164f5639a082bf1f05e	61	81	19712
22772	https://transaction.ru0c1e1499322205d6283afeb73fa39d2b	22	83	19712
22773	https://transaction.ru1a013c3a104139455c3bf8b3f67c18f5	293	109	19712
22774	https://transaction.ru8ce521c168843b564cd9891979a8f25f	48	110	19712
22775	https://transaction.ruc5b4fdf29e6c681e815a75361c0d441d	215	108	19712
22776	https://transaction.rua3a106a12388113a90b6d16c585cef27	66	107	19712
22777	https://transaction.rube5c445524d4f4caf83d1061ec8dcff5	270	81	19713
22778	https://transaction.ruffe7a019bc8c991d28b894b9aaac2ff7	38	112	19713
22779	https://transaction.rub03bc27e7f19820f1517f04f4d5e3db6	279	55	19713
22780	https://transaction.rudf637272a458255bb27a8d675c7fefef	89	54	19713
22781	https://transaction.ru4496b60039d604ac51f6eee2e3ddc2ad	72	53	19713
22782	https://transaction.ru1bc44d7dea46a1507980e7439300d78a	120	79	19713
22783	https://transaction.ru47b161f27f3b4aa3b2930ac85a7c73be	49	110	19713
22784	https://transaction.ru714a519d0dcb0e8b09aa01277fa05be8	259	84	19713
22785	https://transaction.ru75a54ce41d757c37bb447dec14ecb680	187	113	19713
22786	https://transaction.ru05011d366325ab87128c9854a10f223d	133	112	19714
22787	https://transaction.rua32559b62cc64def5faab7f62e9bebb9	8	80	19714
22788	https://transaction.ru36807065413956dfe8e969f6c481ed2f	162	82	19714
22789	https://transaction.ru80418001510e5d6a67444be132565715	142	85	19714
22790	https://transaction.rud6d05d1c65fdc5bee4c556bcfb2e96b7	179	57	19714
22791	https://transaction.ru65897dd6d50a55eed56448ae66d34f23	170	54	19714
22792	https://transaction.rue4b5ee676fed4de6c6a1f410b9cbd971	177	53	19714
22793	https://transaction.ru3040d266519e1719deb33cf2f9b3d7e5	113	53	19715
22794	https://transaction.ru34ecb95c91d8ffd6ea4631891b718095	200	52	19715
22795	https://transaction.ru3b89858ace7366b01cc9f9e92ca41df3	286	51	19715
22796	https://transaction.ru63f797b958330e6d3e7bf175ff62c6fe	172	56	19715
22797	https://transaction.rua692bc917bfc7714c00d7578513eaba8	267	82	19715
22798	https://transaction.ruea086a9b80201e9be9ac6dbc261c5b21	214	83	19715
22799	https://transaction.ru35a2c2380447363c2d5a9ae2797eef27	178	84	19715
22800	https://transaction.rue957dc396dddc2b971a5efa49cc9cbe3	114	57	19716
22801	https://transaction.rucc4fbd9d4916f7c46dbc5d0c7e5a2cfc	66	56	19716
22802	https://transaction.rub90efaf9e67a825afcdeb8408e785530	171	53	19716
22803	https://transaction.ru8706940f27f66822eb2721c59f4fda9a	183	79	19716
22804	https://transaction.ru7d85d6142f24821e2cd01b23c52536f1	33	112	19716
22805	https://transaction.ru70511774a5ebef510ae7404853a12177	293	111	19717
22806	https://transaction.rue7180ac23ce5ac6519250ce3f33abf75	3	53	19717
22807	https://transaction.rufb44ecd088af7df2a0b3bd5ddf1d9189	118	55	19717
22808	https://transaction.rube1901490fec6cc51684061778c6c2b6	64	107	19717
22809	https://transaction.ru38a676682a12666811529c37100fcde9	154	84	19717
22810	https://transaction.rue76723e4b29dc17fe16eda6393aabeab	2	81	19717
22811	https://transaction.ru4fc9e8ea72e583109156b0b4b5f07d41	266	82	19717
22812	https://transaction.ru72ba91b6ea6f98f8404bc892fb0954a8	177	85	19717
22813	https://transaction.ruf34e86627ca25e2a6bd41570633b9e5e	227	109	19717
22814	https://transaction.ru871cc4c57f21320216fd23b2b5d83eb9	164	109	19718
22815	https://transaction.ru205a968ca937f18f61c14aefff4f8d78	18	107	19718
22816	https://transaction.ru922327cb874a3020f5140ea54e0c4345	126	111	19718
22817	https://transaction.ru1866de0effcbafe7198398d8392c317f	226	56	19718
22818	https://transaction.ru9783c57d9b87958a382fe0cd33f56acf	115	55	19718
22819	https://transaction.ru715ae832afe204daf1e24c00aafd5418	166	54	19718
22820	https://transaction.rud71dbb07c6bd67efc5ad964ed5d94f8e	19	53	19718
22821	https://transaction.ru3b133525dd452cb159d3397d627cecbb	57	52	19718
22822	https://transaction.ru26179ca0f5ce5f21dc1530c93bbe7ee4	167	80	19718
22823	https://transaction.ru75a7d81b8ca35cc42842b3e8c4eacbcd	64	81	19719
22824	https://transaction.rufd67702fbe10d237a52d3bbc94fa61dc	19	80	19719
22825	https://transaction.ruada86cf330046b3829a7a5c539f3ea7b	4	110	19719
22826	https://transaction.ru45c10129bab48dd053aa6a2e0280b426	265	79	19719
22827	https://transaction.rub0d1509f25eb20c19ac21fffc3b8c8a9	151	83	19719
22828	https://transaction.ruefbcc162418978c044d1a0af1c41d218	32	83	19720
22829	https://transaction.rub15f0c68d60b0436ea6309bb21e48d57	73	81	19720
22830	https://transaction.ru8f3478446fe5aa0daf37b84bb64ba2c1	60	82	19720
22831	https://transaction.ruee83ef10964357acdfad10eec3522dd6	153	113	19720
22832	https://transaction.rud9c9cb2018bcee922c7c679094304232	22	107	19720
22833	https://transaction.rufeecf4141a3ad311f1d8adb456c7c249	43	79	19720
22834	https://transaction.ru6384b5d5e6dde2ca9f1fb38bff19e132	132	51	19720
22835	https://transaction.rua620e276459db74474fded07176577db	171	52	19720
22836	https://transaction.ru3ddf91e98de65c1abf0843761246c28e	196	56	19720
22837	https://transaction.ruad85eca06b734228252d22c70a44e03c	138	54	19720
22838	https://transaction.rudc5ca0461598dc73a27f420683b64bb6	183	53	19720
22839	https://transaction.ru0bd80cdf369efff5b88294ed9edca0a0	64	54	19721
22840	https://transaction.ru6714527e3379a63b8a5356a4e57955f0	69	56	19721
22841	https://transaction.ru71824259e7c83ca329cde2f58ac003fe	149	82	19721
22842	https://transaction.ru5892e302aebd356f9f423e53d336a7e0	236	107	19721
22843	https://transaction.ru76f6d738f4b168f147a79ebff5ddfdf3	186	108	19721
22844	https://transaction.ru6c46ee9e9486ba851ed386e1a09ddeb8	301	110	19722
22845	https://transaction.ru0f5aa9689a58a6fdb9b9775899d9b864	142	108	19722
22846	https://transaction.rucfd7a084b5ca29561ac5b03b33af1932	163	56	19722
22847	https://transaction.ru42ca572d69736e756a8ca38d5bc82010	59	51	19722
22848	https://transaction.ru2444031c3240e3b55d3b9f2c3f0d0ae8	136	53	19722
22849	https://transaction.ruc4772b44fb9faecc1673a164b30644cc	221	113	19722
22850	https://transaction.ruc2d6b13f5bc40aa2ae4296a921c1fb6c	40	81	19722
22851	https://transaction.rua825dae6541507f729ffc1863472576d	91	80	19722
22852	https://transaction.ru7ac5f05a685ce85579a5305d20fca60b	177	82	19722
22853	https://transaction.rubb5905f8172cc584f1fdd07e876cc104	94	81	19723
22854	https://transaction.ruc050c0d2cf7d555489139478cfbaf589	47	54	19723
22855	https://transaction.ru453bccc5590ec244cd5ba2c50b8039e4	101	56	19723
22856	https://transaction.rud9706a16190e7ae86294d36541f9d878	28	83	19723
22857	https://transaction.ru03aa92ff6da163474ff707332b2bd9e6	22	112	19723
22858	https://transaction.ru066705d02acb0c978dee1dbf89f235dd	27	111	19723
22859	https://transaction.ru4570901975a4b1047f37372ea6a5d10c	238	113	19723
22860	https://transaction.ru6ee80fe70e4a47a0e28c92bb3f7f5fd7	114	107	19723
22861	https://transaction.rua58f93b82fdb82037f6827a7bb966734	254	107	19724
22862	https://transaction.rucbc435bbac0fdcd2d4856f5c778420e8	105	84	19724
22863	https://transaction.ru41c622d2b57bb8cd60a7f4cf7bd68f1b	17	57	19724
22864	https://transaction.ruad31a778780659b94d9eb3304f239ad7	148	55	19724
22865	https://transaction.ru9602a2cee62ec6ac4824246d46bfe355	105	53	19724
22866	https://transaction.ru0b62a3b4a8646c7fb1ef5d4d27d59c27	178	79	19724
22867	https://transaction.ru2c16d70134e25b13cb0ac98a29980496	158	51	19724
22868	https://transaction.ru37a4cac8d94ca7eca4baa61ddc6b7ccd	156	110	19724
22869	https://transaction.ru16105fb9cc614fc29e1bda00dab60d41	130	108	19724
22870	https://transaction.ruf54278221f72a887f95547ed5e8b9c73	48	109	19724
22871	https://transaction.rudc607511475bd3473d8c56315df74798	111	112	19724
22872	https://transaction.ru671399f9559f00d512c77f2f34859a4f	263	111	19724
22873	https://transaction.ruaec6dc28a42bfc412467ff220b18cdd2	248	52	19725
22874	https://transaction.ru4a5d431022b8f13d29358899d5abc254	254	51	19725
22875	https://transaction.rudb4bfffd49ceeb0adf712aa2ab081f52	147	57	19725
22876	https://transaction.rucd9ccc6acecd4631720b56592b7c60d1	190	56	19725
22877	https://transaction.ru590bec800df36a1be38324ccd6bb7644	287	79	19725
22878	https://transaction.ru4903312b9ec8244ca349b35b0f3c5167	96	107	19725
22879	https://transaction.ru6e8c3d00c32bd3a1ddef50c7750625d6	127	82	19725
22880	https://transaction.rua8e5ff26e40c9767928925647bdf55ee	298	81	19725
22881	https://transaction.ru0a39c2b34f83cfe1c0b81519f64279ee	277	113	19725
22882	https://transaction.ru4efdc51884312e1e6cdeeb5916720b29	31	113	19726
22883	https://transaction.ru1eabb25abd48d3b8c46fa913f02486a5	84	54	19726
22884	https://transaction.ru0f6ddb2a283a68a72f8043454ea2fc59	228	111	19726
22885	https://transaction.rub87d58c5864d00bad1380559eb8ac768	208	109	19726
22886	https://transaction.ru5d1bb4daf1408faf1312b445c4acfbb6	77	85	19726
22887	https://transaction.ru0ed5c53bc0892f2b4e129d773c415172	65	110	19727
22888	https://transaction.ru7c09ff32bbd22d7d509f51da1b980629	32	81	19727
22889	https://transaction.ruadaa3188fe9caf6714d102b72e1817a4	18	80	19727
22890	https://transaction.ru41cf9e09e0e744dc57de53a497e190fc	300	82	19728
22891	https://transaction.ru3ba16baaf2dce151de7f875b900d7d6f	162	54	19728
22892	https://transaction.rucd1c6258749590b1973714930a863c49	296	56	19728
22893	https://transaction.ru288b82d3b69194738d471a9b6e2d0e27	81	57	19728
22894	https://transaction.ru61da5f8f02af7c4cf530df82eabc9672	175	113	19728
22895	https://transaction.rud2d0bee93a5fca9f56a17403abeeee7f	195	84	19728
22896	https://transaction.ruffa247ae4a097dc6a7e45ed492a5f069	155	109	19728
22897	https://transaction.rucfe020ec5094847fd07cc90c283c9008	265	85	19728
22898	https://transaction.ru15408a7637320ef384c462fd8d707afa	7	111	19728
22899	https://transaction.ru879ec1920d858a65a8e4a0cd444aa9f6	224	112	19729
22900	https://transaction.ruc2dc3236935141da4b6015f7114b992d	16	113	19729
22901	https://transaction.ru1df0c6e16cb16a29b3a29cf20d8fe510	180	81	19729
22902	https://transaction.rude939daa942cc59c3a7c418c705c37cf	237	82	19729
22903	https://transaction.rucb51090e9c10cda176f81a7fa92c3dfc	295	57	19729
22904	https://transaction.ru3d96a03e368563d9a18aa0073f7f5c8b	190	54	19729
22905	https://transaction.rucaa492731ce1941c6be926e4c970c8aa	157	84	19729
22906	https://transaction.rubd48f59a9f04aefd7708058b717453af	51	110	19729
22907	https://transaction.rua7f4160de4e07e123da067a53ef50e05	115	109	19729
22908	https://transaction.ru4ac754923c4d9f0db6e4f54954d26c0a	265	109	19730
22909	https://transaction.ruf34c1905054917687a5c5c508beab447	127	108	19730
22910	https://transaction.ru98b8a7832eac7f8243c369e2b72036f4	122	80	19730
22911	https://transaction.ru00afb001d1072e57f9a488c65e5b1947	188	107	19730
22912	https://transaction.ru644d1403a48129b67a5df00de38ee08d	53	84	19730
22913	https://transaction.ru7a3b5010297e1713c515cfaf09769440	129	83	19730
22914	https://transaction.ru84adbb3bdbce9f9fe62834d708151add	84	85	19730
22915	https://transaction.ru096d0f0e7f1ca12c53f05835e58d70bc	89	79	19730
22916	https://transaction.ru1102164941082158291eab173acbdfee	194	51	19730
22917	https://transaction.rucaf58cd775a27bf8b9ee340079a29cc0	145	51	19731
22918	https://transaction.ru52f48953cc1bf54687c0d4ef44657b8d	292	52	19731
22919	https://transaction.ru2f43e70331a5ad49e06fb345e489a6aa	289	53	19731
22920	https://transaction.ru54c8c4ea51bed5171b7a6906bf582f3b	294	55	19731
22921	https://transaction.ru0504b3f1ca5994854e8718b2090ab098	207	56	19731
22922	https://transaction.rub83de6d1a18580c7bc72787c44f70a0c	275	109	19731
22923	https://transaction.rueb2c3ed9c4b36b8c2c453f90a34bfeb2	174	110	19731
22924	https://transaction.ruf7fd64ab15e9c1a93a2fe67c8ca43980	290	108	19731
22925	https://transaction.rudf5a8496d643f00a5e98a1822d4d7673	214	83	19731
22926	https://transaction.ru57d9c1d4399d0c1f5b51118adca2ccdd	135	83	19732
22927	https://transaction.ru55af71342650bcd279adfb19c6a8d722	13	57	19732
22928	https://transaction.ru9a0f32d968cd6aa11022c4bd9cfaa009	180	56	19732
22929	https://transaction.ru3b82b32103c58f0368088c3cd2bceef8	81	79	19732
22930	https://transaction.ru71fb3cccf3ec4a7abadab4809168d11b	283	54	19732
22931	https://transaction.ru00e9804ec40b7294c196a2549c8e535e	265	110	19732
22932	https://transaction.ru3f81af8a1ea96579f1064a31090741df	177	109	19733
22933	https://transaction.ru1d97465737cd8e157936736d01611ac3	70	108	19733
22934	https://transaction.ru1a2d3d688840cb40f19af3657dc9ce89	19	83	19733
22935	https://transaction.ru8694bf352a9c1615c64a92767b743789	268	82	19733
22936	https://transaction.ru715d29dd92dcb93fbb64da8756e60a22	106	56	19733
22937	https://transaction.ru0fcf6a2ba39f58cc279f95df07716eab	286	52	19733
22938	https://transaction.ruf8c5207559a8c3601d6bc4aa35e0e350	271	79	19733
22939	https://transaction.ru824d3453b56df254d20767d97023c1b5	169	57	19734
22940	https://transaction.ru0e3b4335558c84ab78e7eee7c8dfcfd7	219	53	19734
22941	https://transaction.ru136cf5cfc704cc00d1f71e447607f999	191	112	19734
22942	https://transaction.ru980e53490d84e1ca5adde4e5df380df1	196	113	19734
22943	https://transaction.ru706b9e39dd3ca40669b5f5c74bfebeb8	199	83	19735
22944	https://transaction.ru2139d2f2653558ea533ffe608e7b35f5	134	108	19735
22945	https://transaction.ru16027c9f54c2ac3e7fa0da84dbdabbac	225	109	19735
22946	https://transaction.ruc359ddb56c13f6bbbcf01e42e72cd070	73	55	19735
22947	https://transaction.rudf9c3c95e80f130af365bd1236da26da	70	51	19735
22948	https://transaction.ruf15fd2a068886a820086ca0cb4e0d789	183	82	19735
22949	https://transaction.ru1b34d47c57a081fbfeec93a1065e69bd	170	109	19736
22950	https://transaction.ruc05b048a99b492871132a39a828f218d	125	108	19736
22951	https://transaction.ru647ccf9ed178d1b3e97bf7a03e9c8388	120	51	19736
22952	https://transaction.ru51c475fd760d0c216b8d8ef570e1bfb4	139	54	19736
22953	https://transaction.ru33e1767c477475470493571cfe22fd3a	176	79	19736
22954	https://transaction.rubed5749e0a58a828d14ecdbb15b0e94b	211	55	19736
22955	https://transaction.ru93d25f808cd71d10ea7e7878ebe91dfb	95	107	19736
22956	https://transaction.ru9f3360be53144db9bcb281e9b75584da	42	107	19737
22957	https://transaction.ru486cee42914266433c8d1673dea762d1	239	56	19737
22958	https://transaction.ruf7ed73fc1cc688fc356f54214147111e	285	57	19737
22959	https://transaction.rube602431608bd333c53d5b7c98df16da	243	55	19737
22960	https://transaction.rub34171ba068e066857d03e090fcd795d	193	54	19737
22961	https://transaction.rubcca49edd9f9cd08a3310382122040c9	52	79	19737
22962	https://transaction.rub5ab799d8d858a0ea73ac65a0fbdf059	88	110	19737
22963	https://transaction.ruca1bb0bba9e7ef219ca087f59d1b042c	224	108	19738
22964	https://transaction.rufe460f98a3aa2e8eff66a7a03799fcdb	25	81	19738
22965	https://transaction.ruf3e940e2bff39df6e5affe77054bdaad	44	80	19738
22966	https://transaction.ru534345ffbb29478b3fce2db5de81be6f	195	111	19738
22967	https://transaction.ru067dd151d15782b75bab063a6f3d5c4e	275	112	19738
22968	https://transaction.ru09321f8309f4e0ae06954fb5022f416d	106	84	19738
22969	https://transaction.ruaa94393c352a4e0f80a50b59eb13a02d	234	57	19738
22970	https://transaction.ru2ab4eee48fbd35a85e9ca83288ea8ada	216	52	19738
22971	https://transaction.ru00a6b8560ba509f8ca05d4373efb0e9d	82	53	19738
22972	https://transaction.rufbb37dc212dcbfbbfdbe8a81fc2e9b6e	259	107	19738
22973	https://transaction.ru6e083f5ee5abe05088fa85a66de0b882	203	111	19739
22974	https://transaction.ru71a2757cf24c56cc603fd9297e8dd536	75	112	19739
22975	https://transaction.ru6798196719109118ee5e4256511f3e64	6	113	19739
22976	https://transaction.ru5e79dbd6728f50a3ff7d11c07305fe2e	216	80	19739
22977	https://transaction.ru4a8c00c81ba210712634b54c7227ffcf	85	53	19739
22978	https://transaction.ru8a08a8763a6dc62ea5bd121d57bbf757	61	52	19739
22979	https://transaction.ruc57e20896bc8f0bb9995f27fd6a15e78	159	84	19739
22980	https://transaction.ru4d5d66fb7438f442525da5a6c06be5b0	62	107	19740
22981	https://transaction.ru36e1922e6990621813d391061b57ba83	176	52	19740
22982	https://transaction.ru1226a3a47a08010c18160680cdbc0604	289	51	19740
22983	https://transaction.ru1234c8f574fd4996a18f9c7efb308075	74	54	19740
22984	https://transaction.rudb1a5780818e9cded1ef9da8b76049e8	276	81	19740
22985	https://transaction.ru3b26ae2104e0d215d47b974c2c61c83d	190	85	19740
22986	https://transaction.ru953745027c70d228d6297b06eac2d3f4	96	85	19741
22987	https://transaction.ruf07e144e27f99523cc5c0afe9b1c7df9	59	83	19741
22988	https://transaction.ru2380b4ab3faa336df1335c4197c45afd	17	110	19741
22989	https://transaction.ru80f139575ccccf1778773ad3b4ddbb0c	46	109	19741
22990	https://transaction.rucd67dba9d2ddc87e3e4e16226f691dcd	265	112	19741
22991	https://transaction.ru7bcc3a90bf50ba74b06f3fa6798e3249	238	80	19741
22992	https://transaction.ru8ebd63fc73533f37ec9b2bc9fbad8345	81	81	19741
22993	https://transaction.ru62faf5a4fee52f5a6721ab2124bc436b	206	107	19741
22994	https://transaction.rud5ccdbbe80bec680efebc72c2ed2c922	261	54	19741
22995	https://transaction.rua5802e3d7c1874dca4a65be8d1accd10	190	57	19741
22996	https://transaction.ru0a3842cab44806ba0fecd62f8dc931d7	182	51	19741
22997	https://transaction.ru9ccb4c69e45a58436ea5db9ace720324	34	51	19742
22998	https://transaction.ru78f5cca686037c306ca9c870a7660130	270	53	19742
22999	https://transaction.rucc6b894fd97a22e1c79da7d71e36c20e	71	55	19742
23000	https://transaction.ru47af10edfc4c96329531345635a4baa9	246	56	19742
23001	https://transaction.rud62cf4360c144b00fbc9a0ff352a09d8	268	108	19742
23002	https://transaction.ru7e7640c4d966d80ee35d736fde763ab0	36	110	19742
23003	https://transaction.ruf7f9d1be24f42a0c98f83572733da426	215	85	19742
23004	https://transaction.rub760a026dfdfadb5c7f4a62d1259ac5f	86	113	19742
23005	https://transaction.ruf0ab4c1519b0ee26507405b7d055cfa0	135	84	19742
23006	https://transaction.ru1de6a6f96a763635b5fb216036492907	262	111	19742
23007	https://transaction.ru51410d5fb5f2b55820968931f29f70a5	227	80	19742
23008	https://transaction.ru6809ac49c646771d9269aa4861dacf47	269	82	19743
23009	https://transaction.ru88c9af1f516e5880d3f722a21ade1dec	265	55	19743
23010	https://transaction.ruce2aac12fadb8d2760dd911be04496ad	47	52	19743
23011	https://transaction.ru265d5b46e24a5401cfa255463546ab72	150	79	19743
23012	https://transaction.ruef5d7542cb0ece2f0cbbee9a7bb43c9a	173	53	19743
23013	https://transaction.ru07cceabb0ec3508723d92ce656eca5b3	137	83	19743
23014	https://transaction.ru037e3cf6df51ae898becd6b966c7ffa1	249	83	19744
23015	https://transaction.rud78e588c86c6d60733d798ca143f78a5	49	82	19744
23016	https://transaction.ru8837f4cd821ac70307efba1fa3195241	240	81	19744
23017	https://transaction.ru96d09981887b7fefa7bf020d4a129469	244	52	19744
23018	https://transaction.rud5f225acabe30ae69732a101b0b2851c	120	56	19744
23019	https://transaction.ruabf701ab2b5a6187745b3ac630a4e32f	65	57	19744
23020	https://transaction.ru94c26651454702089c6bc87e24a67445	63	51	19745
23021	https://transaction.ru9a6425cb36dd69d7db5d71a90194436f	193	52	19745
23022	https://transaction.rudbc94bb24eeec1a073fddd09f66c4cbb	156	84	19745
23023	https://transaction.ru0566d98576447ea1c37d335d95078085	121	108	19745
23024	https://transaction.ru4bf1f9c47c09b802e9d9b3599ea7d8f1	15	110	19745
23025	https://transaction.ru899d0fdf3553b1986aa53a88f7c214e0	81	80	19745
23026	https://transaction.ru8425c98aebba11c4ab0757e956febeb3	276	81	19746
23027	https://transaction.ru12ed72515c84fcfbb0b26b51f54f4f54	50	82	19746
23028	https://transaction.ruc791c3f725370c17b1d6cd5804290554	188	57	19746
23029	https://transaction.ru6008a044bdb2d4c63c1e9fd0eed6e906	163	53	19746
23030	https://transaction.rue669fe24bf4b06761d8e93fa2ea0d74d	255	79	19746
23031	https://transaction.ruc6cd248fa9efdc0d1748535847d13fbf	253	109	19746
23032	https://transaction.ru74e2e59d5d704cf412e4260baf0c49f4	41	107	19746
23033	https://transaction.ru0a01dd245f3e7186ebcefaa7cf7a29e4	193	113	19747
23034	https://transaction.ru0d8635347f039f586f8a7b62cf1540b5	212	52	19747
23035	https://transaction.ru7846ffdb0487bc2f0f8d175fda34d347	240	54	19747
23036	https://transaction.ru7364449dcf7bcca0b3e5dda206943dc7	108	112	19747
23037	https://transaction.ru66afb8581c8e46c52cd1fcf5fd4689af	227	111	19747
23038	https://transaction.rubf2bf5d6c7570613423774728327a75a	22	112	19748
23039	https://transaction.ru356d7792e39f7a165559aa098a1ecc59	2	84	19748
23040	https://transaction.ru0b55b77c4327283b263ac6285c37b56d	234	79	19748
23041	https://transaction.ru58d93a316539a81b44536a889ab2a86a	275	110	19748
23042	https://transaction.ru2baed2ab43723f5b43d41f03ba694f3b	206	107	19749
23043	https://transaction.ruc71a4d4fb1e8b1dbdb7146b44f82ee45	7	82	19749
23044	https://transaction.rua699488e441b1157941cb31b1c5e4b28	259	81	19749
23045	https://transaction.ruad10101fc2f9e3a260647e009c65f630	296	85	19749
23046	https://transaction.ruaff2f425d53c11aca6821650acd6289d	238	57	19749
23047	https://transaction.ruf8c2509856aded9b1e9ee19e48a2f694	107	84	19749
23048	https://transaction.rueadc04f48f6e1043b7372d5ae069e6a0	108	83	19750
23049	https://transaction.ruf3dfbf3d608761ba209cadf2aa376126	86	109	19750
23050	https://transaction.ruce72be14026228e6dd59f738615e2b24	140	110	19750
23051	https://transaction.rue84293c5767600a59c2dbadb2015c550	117	52	19750
23052	https://transaction.ru7c5f57a2a2b274478cd0a9ed4622d34e	233	85	19750
23053	https://transaction.ruaf762480f9f0c87935e010cbf8cbcdb1	143	84	19751
23054	https://transaction.ruaaab51bf65c6a69f2cf1738b4bcb63b4	31	52	19751
23055	https://transaction.ru7d879052c08b7956ef73fdad212b3f49	72	51	19751
23056	https://transaction.rufc054fe800bc911296f3bd3ca7b8116f	79	53	19751
23057	https://transaction.ru5436f95aa16ac72c74d94111b747cc7a	122	57	19751
23058	https://transaction.ru87c1c62abedfff71a8fb8130385f5631	232	108	19751
23059	https://transaction.rue031a976d7624859c52de19ec1441d28	197	109	19751
23060	https://transaction.ru42118602ef9623c957e562bfd2659d94	119	80	19752
23061	https://transaction.rubb938053194c181df7cc7c4a96d46747	185	82	19752
23062	https://transaction.rudac96a67cef8725f31e58a4dcdf7e950	233	81	19752
23063	https://transaction.rud3635b07dc3d11d018d94dce40ba210c	274	57	19752
23064	https://transaction.ruc37d79c75c5801fcf79625023d93b9af	102	51	19752
23065	https://transaction.ru828f847c2ca44bef21cd8263a3f634e9	50	54	19752
23066	https://transaction.ru50e1978d9c0a81db3a0173979a3be33c	4	56	19753
23067	https://transaction.ru8dde7028caeafba08ba67215117e3469	154	57	19753
23068	https://transaction.ru71284dd8fc7a75d33feef95a459ba70f	84	110	19753
23069	https://transaction.ru459b90384115db4a6da549b700e083d5	19	108	19754
23070	https://transaction.rud1798d0ef5a4feab03731774fba7db34	216	110	19754
23071	https://transaction.rud6e93018813a99781b61c1106d60fc9b	194	55	19754
23072	https://transaction.ru3649a6a2557a26ada5a5751518e711f7	190	54	19754
23073	https://transaction.ru5d4745082328f3c6cb0930ee958f2e17	283	52	19754
23074	https://transaction.rue9f9d97fc742953f14a3d146d1ae2217	119	111	19754
23075	https://transaction.rub341d7b44746540d64c052876578db7b	115	81	19754
23076	https://transaction.ru39f1efe347e996ac5847f519d182ffdd	171	84	19754
23077	https://transaction.ru9524b31f07f55e27f732ce44040c1934	170	83	19755
23078	https://transaction.ru92bbb6e070bd945ac8178de8f7ac220e	2	51	19755
23079	https://transaction.rub23253041ece3a1d092228b2d72415e5	229	55	19755
23080	https://transaction.ru541a6d10f67dbe788c764524bef6fe6c	253	79	19755
23081	https://transaction.ru61619b12309977baadb803f270477e22	299	53	19755
23082	https://transaction.rub5934ae42c1201dec09317db8bd11d54	218	54	19755
23083	https://transaction.ruc8ebf259e0cf03ed7fda26924cab4acb	186	109	19755
23084	https://transaction.rufcc4103fcaf40d4720096ea4ed0fa2a7	69	107	19755
23085	https://transaction.ruf61da53b2aa4f57d38024a4216e1be2c	29	112	19755
23086	https://transaction.ru2a47b1488b5ae49e4fbbc70abfe38815	39	113	19755
23087	https://transaction.ru2c9e201c54649d0a71b9ec065032080b	275	84	19756
23088	https://transaction.ru554d977f680d6324bed352e1028dbcb8	260	55	19756
23089	https://transaction.ru62cdae72e4286ee1bdcbd21ada96bbd1	50	52	19756
23090	https://transaction.ru5090c989ca62861fbb14d96552ca5a9a	261	111	19756
23091	https://transaction.ru321af9e729a694aab3d4c76b546b4b95	159	112	19756
23092	https://transaction.ru30e6a8df72ed3ec64a93c6e89ac8f634	258	81	19756
23093	https://transaction.ru11d2bcb1e57183c928c12843159e40f5	186	80	19756
23094	https://transaction.ru62b96ea23ebf14eac4998ed26c3bdd3a	141	107	19756
23095	https://transaction.ruef0f98e96627aab0ab90d09cb7aced3d	68	109	19757
23096	https://transaction.ru6ca769b2c3028ce0d7729669a4c5234f	202	81	19757
23097	https://transaction.rudc91cc1be732458b56b3266ce93a00b7	106	51	19757
23098	https://transaction.ru012b5c63f06424e2dc1c82ac6a7554d2	6	52	19757
23099	https://transaction.ru4d3bb08d67cc0e395be8d125f76b22c6	230	56	19757
23100	https://transaction.rub9de2bfc258d217ce7bdee862ee8a238	175	112	19757
23101	https://transaction.rubf2e01487c50929ce4aa5d178d56bcd9	159	112	19758
23102	https://transaction.ru76ab959b15a17f04553501e4e42dd515	117	54	19758
23103	https://transaction.ruf93c871cdcf92b0802e7cac88b34414c	100	53	19758
23104	https://transaction.ru320ed58b88c68c9e7c49c4195ad2bae5	123	80	19758
23105	https://transaction.ru0b0cc17e7d90de85af15234d4b342524	93	82	19758
23106	https://transaction.rua9653aa47c55398db858506371f08bd2	245	85	19759
23107	https://transaction.ru7f1bc9253987e9405bd99af68a53cc40	214	113	19759
23108	https://transaction.rud889963ef52acfded4c5bca685762460	100	55	19759
23109	https://transaction.ru0083a03798f30f16b2eccdcb2a27a0a1	279	56	19759
23110	https://transaction.ru94f0b2bbbfb12af82df094d4061d427f	2	79	19759
23111	https://transaction.ru0f9be923b3848b2e1c7284bfb0ef2ab9	76	110	19759
23112	https://transaction.ru5dfad6b77fc4c2e6bb7981536e0a27fa	45	109	19759
23113	https://transaction.ru7c67fc630279b0b017433f6462034502	226	108	19760
23114	https://transaction.rud523139185ac02e7ad5738c60723cceb	268	85	19760
23115	https://transaction.ru75c29ee64502c26c89759ae727e5ca1a	63	84	19760
23116	https://transaction.ru1d09952c471efc335762cef4672fdcb2	201	56	19760
23117	https://transaction.ru88e5526fe04cd58b48ace8d81746be48	14	111	19760
23118	https://transaction.ruf73eed447c13ddeaff16b1b89323f18b	172	85	19761
23119	https://transaction.ru944d752056ee1922951457f8feabe09d	265	108	19761
23120	https://transaction.ru075f1c0e874bc4fe2d64aed9df67cde6	230	57	19761
23121	https://transaction.ru809666357213a6ee54aa73344b3c6b76	54	55	19761
23122	https://transaction.ru1a3faba71b36fdf41c9c2303e8bc679f	7	56	19761
23123	https://transaction.ru6c72946ea0aace616dcc96f76361f719	282	53	19761
23124	https://transaction.ru3ed6e4dd91ea0b410c57a7b663e4d205	115	54	19762
23125	https://transaction.ru6f6a9f007a9770253a41d2899407b8bd	176	57	19762
23126	https://transaction.ru2c7ba2d58c0bfbe71f46035e02df5dd4	89	55	19762
23127	https://transaction.ruf251ecfa5420c010d44c542ec4dc4fc0	125	52	19762
23128	https://transaction.rucf0782fc0d453ea0f21cd5d2dc21defe	228	79	19762
23129	https://transaction.rud40d821da59bb2923b5efa5ec71c20cb	95	111	19762
23130	https://transaction.ruce8b4c5de9799bd50f27bd7909350c86	181	82	19762
23131	https://transaction.rua8fcb406c88e3b7915865c82db018e24	201	83	19762
23132	https://transaction.ru80b87a48d413d65927562c3521a1b6a1	85	107	19763
23133	https://transaction.ru9974528d972f674b442a0486bceb33b5	203	79	19763
23134	https://transaction.ru6d02cb78e86f60b14820fba3a5e71cc7	71	56	19763
23135	https://transaction.rud9c7639d286e9e615e48fedee031212f	294	80	19763
23136	https://transaction.rue02d0f7893908565abd8252785242c30	229	113	19763
23137	https://transaction.rub4cf0b4d24639c3ad10616ccd69fe782	280	109	19763
23138	https://transaction.rub90510a6ad93ef8af036ae0a8ab5c021	204	109	19764
23139	https://transaction.ru77bbd869a49eb40d05b563a07de9a042	64	107	19764
23140	https://transaction.ru987e2326b2fa54e45cabe914fee3e94a	249	84	19764
23141	https://transaction.ru632352f3811a0afef59dafd78ec6c85f	267	113	19764
23142	https://transaction.ru2a27dac6b172dc79c7c7db7ca8552920	268	55	19764
23143	https://transaction.ru21ba9335316c9d8e54f2395b38636778	170	56	19764
23144	https://transaction.ruf36b5f58229b4315c86b5067efdea93c	128	79	19764
23145	https://transaction.ru6e7883bed54a28adb6dca0992ebb4e50	144	54	19764
23146	https://transaction.ru54b0d753fa0c8ae3f0f69c5170e7c2be	136	52	19764
23147	https://transaction.ru45ed9044137f0e5142dc46c0cd148024	56	51	19764
23148	https://transaction.ru373590403f80d686f78b18a45ddd22ef	27	82	19764
23149	https://transaction.ruf94503de77decb5eacb62fc8871de686	243	81	19764
23150	https://transaction.ru7f017175f202c666d345cd758b5f5b98	96	112	19765
23151	https://transaction.ru63872132321e354b3cf4125670d67395	111	85	19765
23152	https://transaction.ru17e0ce48c87a8885fe8b82c21cb17ecf	260	51	19765
23153	https://transaction.rudefb593e12067f333ce4d77b24be7c40	110	55	19765
23154	https://transaction.rud6055de68dad5a21a33d640118198c98	224	56	19765
23155	https://transaction.rua60a40060f7a984e457a9c9b67c725ff	289	113	19765
23156	https://transaction.ru0b4dd53f8f269528dd0320e343b6bb79	75	111	19766
23157	https://transaction.ru4480881657d9140320aa603a87fb5405	177	81	19766
23158	https://transaction.ru155bd09e436a308568024faea9394cc1	2	108	19766
23159	https://transaction.ru36adad451566a9d8f0a9cd1ff06b8e3a	39	109	19766
23160	https://transaction.ru4817550ba632ac27acd1f98fc4816fc6	18	110	19766
23161	https://transaction.rudfa3deacbed1a5cb88e87305694068fd	253	55	19766
23162	https://transaction.rub8a91a04e2acfd1121ee3fa699bcc12e	182	56	19766
23163	https://transaction.rud11d81bfb1eb7cd45cb7ccdc47fc191a	7	52	19766
23164	https://transaction.ruf1814fc15f3ed2da36e29c2dbef6b01e	68	79	19766
23165	https://transaction.ru445a6c8384ce7023d16c0131aecbf344	53	83	19766
23166	https://transaction.ru2defa0c94e4f29a7ff9d7e4a3afaa6f7	215	84	19766
23167	https://transaction.rud4545ca068d03bd10375984dd09af0d0	281	81	19767
23168	https://transaction.ruabbff16d39fa81a32b56d801cae0a14a	163	112	19767
23169	https://transaction.ru4c8e3dd932db78e0df6d190818124b4a	122	52	19767
23170	https://transaction.rue747515c98ebeb65457927aa8c766037	130	53	19767
23171	https://transaction.ruc656ba8f11f879dda496f7fe382c9d18	266	109	19767
23172	https://transaction.ru86a17793e30d17575e46e983ffa72234	49	110	19768
23173	https://transaction.ru0b3b39f76e74f85e7832d7684a20baf5	47	108	19768
23174	https://transaction.ru7ebc1392a3a35cf6120ba898eb0df02d	167	81	19768
23175	https://transaction.ru58ecd623583cee16cba88dee2b70893e	42	82	19768
23176	https://transaction.ru22bc985c82f7e52cde99ac80997c1633	163	57	19768
23177	https://transaction.ru82aa105255909a3fc232c2a53821ebd2	272	56	19768
23178	https://transaction.ru0ee5815fd7ad36a1496f30cb9be4c135	156	112	19768
23179	https://transaction.ru6dfaefaf64051f39e2bf1c6d065af61f	97	85	19768
23180	https://transaction.ru8e7ad59c34c97e5c30750ff7bcda0473	30	108	19769
23181	https://transaction.ru30d67d89b49dcedfa74afa28a28c710e	264	110	19769
23182	https://transaction.ru2fa1f49e50e91200c6728d73ee214a4f	214	109	19769
23183	https://transaction.rue609ce83792eb4893e072939931b9a18	115	113	19769
23184	https://transaction.ru859c6838736bc30c98279ed45d7fd70a	225	107	19769
23185	https://transaction.ruf3bdbf76890cff2f05be94da0913e929	136	83	19769
23186	https://transaction.ruac732e96708564547026622e4e07a01f	285	82	19769
23187	https://transaction.ru7600266448de6b081413702eafcc3ca2	37	80	19769
23188	https://transaction.ru027ffb1a498bae0859d90d343ccb721f	234	81	19769
23189	https://transaction.ru312a63b64ca5aca2935491526220cecb	21	57	19769
23190	https://transaction.ru8bc95eb10ca3339f65aa5a1785b36c57	100	56	19769
23191	https://transaction.ru6394090a222e15443a35ac2f81ef2f01	94	53	19769
23192	https://transaction.ruf065cdefd3ae4ede9405759dda2ffdf3	187	79	19769
23193	https://transaction.rub1dccd03e4efbc1412dee16da021c42e	259	51	19769
23194	https://transaction.ruf363d4130a0909dd0dbf72e06ce02610	119	56	19770
23195	https://transaction.ru7de32d229db6f76ddc32e50802ff34f4	172	55	19770
23196	https://transaction.ru19269bf987de73f57f5c69de9ad848bb	170	79	19770
23197	https://transaction.rudee51e625d049dc749f22883b602e487	58	107	19770
23198	https://transaction.ru71256d8d83bbc6a37422c0c62609455d	51	55	19771
23199	https://transaction.ru3aca7c4840bac9c1bbd6baa7e3083e73	155	85	19771
23200	https://transaction.ru55ae5e0bb5b78d59d086d2ed3a62e74c	51	112	19771
23201	https://transaction.ruf204b35f8e7b3cbe33628a401da26796	286	112	19772
23202	https://transaction.ru02ae6a786bbf135d3d223cbc0e770b6e	78	57	19772
23203	https://transaction.ru2c75cf2681788adaca63aa95ae028b22	222	52	19772
23204	https://transaction.ru700f97c4c7ce1bbbbe1400b2598488d1	39	53	19772
23205	https://transaction.ru184d842fc61096b8982fb9334e674abf	90	54	19772
23206	https://transaction.ru912d23f4377610aa2be78d9440543394	198	107	19772
23207	https://transaction.ru9e16b2fdfb93bcb94f336fcf8f709261	222	110	19772
23208	https://transaction.ru37e620fb736e9761fd6fe4b2b3aace8d	118	109	19772
23209	https://transaction.rubcd0d91492d8b252720f7015db658b5c	273	113	19772
23210	https://transaction.ru95fffeb8611cbe525a14324e7c5ee557	174	82	19772
23211	https://transaction.ru1667e9cd896448a43c0f44b210bf71f9	241	80	19772
23212	https://transaction.rudb130fbef530f2a6d2b28dd886f21c83	141	81	19772
23213	https://transaction.rucae9169a5c680004faa164faad4e6848	149	80	19773
23214	https://transaction.rua1186bec45d1d7821aed110ab49d978a	204	109	19773
23215	https://transaction.rubebf45dc85003d57bc793779a1db9e40	172	54	19773
23216	https://transaction.ruc1e9a74f1f4b2bf9dc55314c9ec6eec4	62	53	19773
23217	https://transaction.ru83bba24fbaa06ce06524ba3ba853711f	167	55	19773
23218	https://transaction.ru8f6a7528fad6ba315b7f4a0459f66023	258	79	19773
23219	https://transaction.rubd8b3c019f9ec25d162597a0cc3cc42e	188	113	19773
23220	https://transaction.rudaaff569565aa7e1626f48c2fe04a6bc	153	85	19773
23221	https://transaction.rua4ce1215166c95077ecd63e15f3ba6ae	142	84	19773
23222	https://transaction.ru9e61d0374c2bc18335b0d5fdb07a605b	248	109	19774
23223	https://transaction.rue19463a238679064676628ced0b84675	150	82	19774
23224	https://transaction.ru092e9c75b6d721231d7a3b23bfbc88fd	299	112	19774
23225	https://transaction.rued6df309547d106232a7e4ea12953b4c	242	52	19774
23226	https://transaction.ru91bdd530f3471322e8ae7959e436bd6b	156	51	19774
23227	https://transaction.ru6687296fe3d74413b9bffaf95b1d91d1	241	56	19774
23228	https://transaction.ru69b652fe7aa349e307f920e54b335637	221	55	19774
23229	https://transaction.ruba61ab7dab67e0845c2e530ba9fd5c2c	280	56	19775
23230	https://transaction.ru6e581a8cf486e208eb1eb0867b80d230	111	52	19775
23231	https://transaction.rua6075da10bfc63d3896adccb21b6736d	150	51	19775
23232	https://transaction.ru1bdd1e5d330ef83496ef4cd27e461b95	32	80	19775
23233	https://transaction.ru43a06745f5576da6e9c834c27a99cf23	66	107	19775
23234	https://transaction.rub137fdd1f79d56c7edf3365fea7520f2	285	112	19775
23235	https://transaction.rueb639bddc7934b4a8c510dc9f7f509e1	242	82	19776
23236	https://transaction.rue63ce140178f38d2ff01b76ecaabc7be	106	80	19776
23237	https://transaction.ru0814d629f12472c41573787c4829c49c	89	108	19776
23238	https://transaction.ru2fdedfe5f26e59775b55fb09b60a88b8	113	109	19776
23239	https://transaction.rua6bd5c5f00781209142ff6412b540174	4	84	19776
23240	https://transaction.ru5a805833b71d3dbc9d8b0519abf7cce2	96	51	19776
23241	https://transaction.rue6a6e90027ff26ac9d7c1f1d36b939de	95	79	19776
23242	https://transaction.ru467b1c406cf739590ed7daad030874bf	213	54	19776
23243	https://transaction.ru0f2f914b6c09a6cfacea22ceb7f4d5c2	198	56	19776
23244	https://transaction.ruf2a3c63362792801616ad28f1cbd0037	172	56	19777
23245	https://transaction.ruc3424b7ffaf02091069a338baad8d7c3	93	53	19777
23246	https://transaction.ru17bfa733f4eb58c8c9d3a2cf0ff03541	280	80	19777
23247	https://transaction.ru70fea742efbd792854fa56b926ea1039	135	81	19777
23248	https://transaction.ru027c0f44d7c9a3a858d49332e4f4e483	28	108	19777
23249	https://transaction.ru5b531b8a1c09974145ad5a420edede38	259	85	19777
23250	https://transaction.ru7f055b8fff98fb4af4c06edf9a6c1613	134	80	19778
23251	https://transaction.ru3bca13bb2a8cf3dab497837400a3e7be	69	111	19778
23252	https://transaction.rufea942a3e8ec0b2339954589b1731be3	35	53	19778
23253	https://transaction.ru23a7495e73318114ab8ddb3e71e919bc	86	79	19778
23254	https://transaction.ru37563f059c2d815bf5fc637cb88e1df3	204	51	19778
23255	https://transaction.rufe0181fa11124a8385473ce0f639460a	26	56	19778
23256	https://transaction.rub6bb867b7a0dc9e749eb90c14d47bd59	291	57	19778
23257	https://transaction.ru361e09f324d9874b8173b26279e35307	207	108	19778
23258	https://transaction.ruae15c1828369d59edca1c3de910af401	125	113	19778
23259	https://transaction.ruf0ff6a6ed5127a1ab6817f3f38f9ebdc	267	112	19779
23260	https://transaction.ru028317b204a2c6dc0fb9a9357ec4a246	113	111	19779
23261	https://transaction.ru9222c99ae1ef8cd41b41276d9c7a0405	213	85	19779
23262	https://transaction.rue73b04578cae9ad34b98a7aeebe3ad0a	78	82	19779
23263	https://transaction.ru42a5dfc78ce2766f8716c7c57905a008	71	107	19779
23264	https://transaction.ru1330164bbca93372cc5c7d0ee4eb5eda	44	57	19779
23265	https://transaction.ru67fcc31c35bb77916a2af5cca53b4925	275	52	19779
23266	https://transaction.ru01c7e763c9bba8936c9e13274e86f9ad	55	79	19780
23267	https://transaction.ruf19a5667abe88ddd99b8754304737b73	258	55	19780
23268	https://transaction.ru7efecfec628c87c67931da7e5fba8cdb	91	85	19780
23269	https://transaction.rude04062742fe37708e0502590fde7746	261	113	19780
23270	https://transaction.ruf9181703961e521e08f2bbfbb8c94955	141	84	19780
23271	https://transaction.ru9e9d1994e1f66f4fb9072fa035a19080	76	83	19780
23272	https://transaction.ru3499ff579a15ffbf778a6356eb578b6f	247	112	19780
23273	https://transaction.ru8d8366199b64eb4d899a8724662ef2f4	143	107	19780
23274	https://transaction.ru745229c79c4923647d970c186d319772	22	109	19780
23275	https://transaction.rua7355b4a4d0ffdfbf853def9bcf3f8e1	183	108	19780
23276	https://transaction.rudee51ca9db9ed306e9a9f5b9e4b819f2	160	110	19780
23277	https://transaction.ru64adeed60a32ee925bf8901185a7bf57	288	84	19781
23278	https://transaction.rubf1c7122f19d67f701a726f6a7aa3acd	265	57	19781
23279	https://transaction.rufd8604e206bde6ba1e420e22cecef0d4	236	52	19781
23280	https://transaction.ru2b836dc9c31fd0ab7624c8e3e615924c	232	79	19781
23281	https://transaction.rub880b19efa5150dd39fe64277c611ff6	173	81	19781
23282	https://transaction.ru57619e0d41d45f9a905d76291584b9cf	31	80	19781
23283	https://transaction.ru2a433f253be061b7025443092dccc543	250	80	19782
23284	https://transaction.ru7ad947ad2e30da756c33da960444ef07	188	84	19782
23285	https://transaction.ru61ed97f0005da897fb6ed4613c587e8a	128	85	19782
23286	https://transaction.rue6740e98f3cc885b10369f5bfc67bb25	148	113	19782
23287	https://transaction.ru0952a07473371be2f6062158a24fcd5c	138	55	19782
23288	https://transaction.ru73e851623a29f26b1b8dea99c21ee9d9	269	56	19782
23289	https://transaction.ru232b680f5a9931a0da32c38e84ebdf34	272	53	19782
23290	https://transaction.ruaefd71ca1250f5a29de5f681d3207f1e	16	54	19782
23291	https://transaction.ru2a7ad7b10432d19b8a7a4a9eb9801f51	6	52	19782
23292	https://transaction.ru83cdfe7bf2ac9e0129e8083399066147	56	51	19782
23293	https://transaction.ru4baf8a5da4ead707946692cd3845d8d5	195	111	19782
23294	https://transaction.ru45550d8e218001c34f85b414283b8ebb	240	107	19782
23295	https://transaction.rue78e5fa25bdca49eb56ad51de0d19678	139	107	19783
23296	https://transaction.ru0fda218d7850aeda99937bf1b21ac715	43	85	19783
23297	https://transaction.rue7bc748af3d4d0e83254fa51d4d3ad1e	36	82	19783
23298	https://transaction.ru761317eb4d6d6aeda90b122e6223e15a	42	80	19783
23299	https://transaction.ru5ef5d7bb1fceca82a18d5ac8313dd8f5	156	81	19783
23300	https://transaction.ru40334323919f1d46089bc1bc3cf07c84	28	108	19783
23301	https://transaction.ru4b778a10f1eb0ec69bc05d9dff0fdcc6	259	109	19783
23302	https://transaction.ru7ef8e364099066b9746e6d9d14632ec6	62	83	19783
23303	https://transaction.ru1b0abecd19a26064e6cc7883b0584555	289	113	19783
23304	https://transaction.rua9a0bc684f8aa0984a3e0c15131842a8	216	55	19783
23305	https://transaction.ru8cc82c3bd72324f5d5a9593a44dc37c8	204	54	19784
23306	https://transaction.ru8df14d8fb050eb34bf50e9d87c108a50	159	107	19784
23307	https://transaction.ru622daffbc45c08210b6a253390576f15	274	113	19784
23308	https://transaction.ru8c55d22b3b4e4d9ca6d20f7f93411e2c	139	111	19784
23309	https://transaction.ru1a1a462d09234d61d0b11c494fbf0396	263	83	19784
23310	https://transaction.ru451b33a71e83bd130f3a96cec0fdc070	80	52	19785
23311	https://transaction.ruf2148338e797ff2b934b7dc5c386734f	266	57	19785
23312	https://transaction.rued2c1d4432dd218042f511f699d8deee	253	85	19785
23313	https://transaction.rud30e6bd7364c61105fa14e46e4198ca8	267	80	19785
23314	https://transaction.ru17beb02828b982f7ab646a93726a343b	276	82	19785
23315	https://transaction.ru0d6bbb748c773a7bf046455a6e54561a	47	111	19785
23316	https://transaction.ruee44473546bd68a1270123de9f6d3b27	3	107	19785
23317	https://transaction.ru214b393787fb4387626b5e381fa24e1d	224	113	19785
23318	https://transaction.ru6ae7bc2e5f400e03331f39a22c1346a5	140	113	19786
23319	https://transaction.ru16f9359f17f8b2e521ad58064eb0bf98	121	85	19786
23320	https://transaction.ru3601496036f341db5e77dc004df29eb0	217	83	19786
23321	https://transaction.ruef8b8275bd0aa36ec4a3a6002ac7a729	60	84	19786
23322	https://transaction.rud86112de2280c6a67cf7be89ee080346	266	57	19786
23323	https://transaction.ru54773f9a3a4a7820e01cd803e995ded6	240	56	19786
23324	https://transaction.ru7cd4f9b2236cfec7344d6b590387995c	106	54	19786
23325	https://transaction.rue44e67da42d69ec1b3458c13b12eee55	113	79	19786
23326	https://transaction.ru6c1d69dd61b4192c8ef551e5a5d6a873	133	52	19786
23327	https://transaction.ru52842ee4bbbc20d3998b0d060866aa06	86	107	19786
23328	https://transaction.ru9fcf40cdab4267b366a0dba5e9eb5471	18	107	19787
23329	https://transaction.ru685161be7782fad56395888ec89cfcdb	222	83	19787
23330	https://transaction.ru4d10bddaa4199192479d32e530da3d90	178	110	19787
23331	https://transaction.ru7d8572515571d45df12f960fa91cf3a3	281	51	19787
23332	https://transaction.rub07147b3b9b06eed4541448211230d80	94	56	19787
23333	https://transaction.ruc6f6975ef08e6f2cc2118b7a7de7b242	234	79	19787
23334	https://transaction.ru29654addd27a15518d5a88632ad3433b	52	79	19788
23335	https://transaction.ru2bd877b395487d7ec92ff0ef996db684	62	51	19788
23336	https://transaction.rud0cf53110cfb758f54827ba4f625ef62	247	107	19788
23337	https://transaction.ru6af372925dee4b675a32d87ae1bc7c0c	125	85	19788
23338	https://transaction.ru788097090614450872427337cc6f229a	48	80	19788
23339	https://transaction.ru3add49db204105c8a3dd87b9cdf62ab6	64	112	19788
23340	https://transaction.ru9ac83a46973c27d17a943605f71c8844	97	111	19789
23341	https://transaction.ruba94864e28bb20cc8d853b6044126470	120	84	19789
23342	https://transaction.rube8529cfd6e37c9f1d95a0e74476cf7c	11	51	19789
23343	https://transaction.ru116129c62451dc23a7ae21a9d35b387d	265	52	19789
23344	https://transaction.ru4b4af755f00e549f4aa337b34afc111a	264	53	19789
23345	https://transaction.ru35fb3be959544f000302245893774506	41	54	19789
23346	https://transaction.rue5b5e7cee1eb18b6f3cb40a9f8a661ad	66	57	19789
23347	https://transaction.ru84e67d82ab145fe7cca9bcbb2fa0500d	3	80	19789
23348	https://transaction.ruc08aee6099b86e2e26c2c547ccc4d15a	33	107	19790
23349	https://transaction.ruec3afa919ec7331e91c462f93608e0da	22	111	19790
23350	https://transaction.ru5ac4d48e997f6aa8dce38f60e703fe1c	139	55	19790
23351	https://transaction.ru5bc7b1f3cfcbce523e3b95ebd720b282	179	52	19790
23352	https://transaction.ruf22bf3b9f858d8667f6b2474334dd824	300	53	19790
23353	https://transaction.ruddc45e5b21b737b406752329e9b28516	122	109	19790
23354	https://transaction.ru4964effb8c41a9ee3c58ad573ebcb278	139	108	19790
23355	https://transaction.rua5fde3042934b11782af9d542db71fd4	280	108	19791
23356	https://transaction.ruf934ad043971ed0fef10b202d07487f6	152	83	19791
23357	https://transaction.ru541a67a5f9e879c125d018348ac5afb8	61	113	19791
23358	https://transaction.ru1c255a8bdbf3a61495fd5514c4e0c8ee	111	80	19791
23359	https://transaction.ru9c05530b8dcb90944d6decf8be44cb5d	297	53	19791
23360	https://transaction.ru9cc5812e86482df21132b0baaaf85100	141	56	19791
23361	https://transaction.ruad7a56645fcfda9b3436271850604962	245	79	19791
23362	https://transaction.rube252868593b1e8c2ce93b09cb2f42d5	222	51	19791
23363	https://transaction.rudc944c514f12836ab4daa73164f77e20	207	112	19791
23364	https://transaction.ru0b007e63ef097cd47d6bc60b58379103	163	110	19792
23365	https://transaction.rubf8b8102f0c5370113960177dc584daf	281	108	19792
23366	https://transaction.ru10321fdecd9fae9b62cac2dcac6483ac	291	84	19792
23367	https://transaction.ru63ec051cc6a330ba64fb634f1122cd0d	108	51	19792
23368	https://transaction.ru1edda9e5c2b8f517904071c7ccbf0860	65	56	19792
23369	https://transaction.ru20511e28f984a6b85c032e5ca37f575e	287	80	19792
23370	https://transaction.ru5e257d5f58c448a2b1e377ed03f46f00	208	81	19792
23371	https://transaction.ru892dbf44627a2f0e22fa3fcfa826bca8	91	85	19792
23372	https://transaction.rub3f8f23c67988f1d4f507a11b1442cc0	300	81	19793
23373	https://transaction.rud867935f3f65d1e19ce18d0508e326b2	192	80	19793
23374	https://transaction.ru3032076ec7593966d99a40168aee0a34	281	57	19793
23375	https://transaction.ru9d5439f808fc0f48abee4c43bed07026	123	56	19793
23376	https://transaction.ru79ba07c4178943cda807240857c4e737	74	51	19793
23377	https://transaction.ru6a13c3b443199a6ac7df2624e88f5e92	107	54	19793
23378	https://transaction.ru922cb99bb5e6c79bbd068dc03561a56e	184	53	19793
23379	https://transaction.rube982e21eb0711bd2d6226796193c640	191	79	19793
23380	https://transaction.ru0ef6e49951bb2ef21c685b9b72f03abd	33	52	19794
23381	https://transaction.ru069dc39062cef94dad0f9bfca5e9d9db	161	51	19794
23382	https://transaction.ru688c25bcdefcb9b4ecf2bb116d6c7f1c	38	55	19794
23383	https://transaction.ru23e2c67cebbd15349db8510336a622c4	36	57	19794
23384	https://transaction.rufa9b0040850dddf4eb5b7a3d0b1d0583	38	109	19794
23385	https://transaction.ru43171ac9cece88b3f79b54bf7ce881b9	184	113	19794
23386	https://transaction.ru73204b55e5342952eb9cfe48eb92c934	70	107	19794
23387	https://transaction.ru7ead01804e12206224cd952cae1c71ca	192	112	19794
23388	https://transaction.ru4fc92e33a5630bf99d87b9ad7e335d9d	114	82	19794
23389	https://transaction.ru8ad7788e1639b371227f6f38ecd66e58	142	80	19794
23390	https://transaction.rub8a5158580f3d8ac7b24a8b730a41b8a	58	84	19794
23391	https://transaction.rud2dc6a96f5eafe17f799fbd515e7073f	75	85	19794
23392	https://transaction.ru85f12b1a3155e0fb2ef9a44708f27e08	51	110	19795
23393	https://transaction.ru6a35995fbd5399ab131b89623c344782	113	112	19795
23394	https://transaction.rua2e683d022e9fc7b6d17611f0b2e9ae1	109	80	19795
23395	https://transaction.ru4f0a165fbe45b61e78bbc8f45e787048	100	82	19796
23396	https://transaction.ru458750664fc01ea88ff9574cb50563e2	127	81	19796
23397	https://transaction.rua33456c6b9ad11ca4a007360576b4ef3	223	80	19796
23398	https://transaction.ruc7405161ad160cbc567c6c1ae3f1f8e3	61	57	19796
23399	https://transaction.ruea8b087b430f8fb6d3fbac69bfdaddf0	181	55	19796
23400	https://transaction.rua3365de0b17e80c984e09d0af3892088	191	51	19796
23401	https://transaction.ruc3cdd7ceb96464b3a98189f79c84a28d	82	52	19796
23402	https://transaction.ruec49e5ad761d1fef16cf05e64b429224	253	54	19796
23403	https://transaction.rub708a45f07438bf7048fc3448882d1f5	17	113	19796
23404	https://transaction.ru6a2e3e65d5a22a88712c4c3619fc8c3a	51	112	19796
23405	https://transaction.ru5d672c25f2560d458b96fba44dcc5a67	257	83	19796
23406	https://transaction.ru77d8b70fb58fc0ecb490fa85b80305a4	74	109	19796
23407	https://transaction.ru0a0221a6625bae7944338caeae8a9c03	21	110	19796
23408	https://transaction.ru625f1674d17e2a7ce4cbfdeb8e8fc786	204	108	19797
23409	https://transaction.rua7ed973bbac3ddd2d557665d3bedd4d8	89	80	19797
23410	https://transaction.rud0a9ab5f1f039fc0b75df846494fc72a	87	112	19797
23411	https://transaction.ru9a981dce8f81ada744337a6dc7637ae6	280	107	19798
23412	https://transaction.ru945163942ddea24f3cf3d00d7251a565	129	56	19798
23413	https://transaction.ru723394d002ef824c10ab6e9786ebacab	17	55	19798
23414	https://transaction.ru423cfc8fc007ecdef7153d21e24a2079	224	57	19798
23415	https://transaction.ru2da9d5ca05f6c39f9301cfa40c8cbf3e	34	83	19798
23416	https://transaction.ru519cc9cd62f0b06cffb92f2bb7587b64	131	107	19799
23417	https://transaction.ru05ae0b0f0b78559132fb058def9b66e2	188	108	19799
23418	https://transaction.rua90dfb90a3b8877714dd8f0caa756ec6	270	109	19799
23419	https://transaction.ru70132e4215b3a044e8f7769a8d6bde08	177	111	19799
23420	https://transaction.ru8e72b971675aa423ee21bfc0ab158bdd	178	112	19799
23421	https://transaction.ru4b07c3e0d7b52f436aba7c07bb3638a5	33	56	19799
23422	https://transaction.ruf081e9a2dfddf924c6323ee7e2784f88	290	55	19799
23423	https://transaction.rud0573f32b931cce35febebf70c5310b4	131	54	19799
23424	https://transaction.ru8108e7580d35a6df529b4cd78137c5aa	160	53	19799
23425	https://transaction.ruc067a6c658d041f02c29519004593cb2	54	53	19800
23426	https://transaction.ru1fd3b109321e7d1a99dd4cb213d3abb8	285	57	19800
23427	https://transaction.ru71df288596b1b2e256fda1f061fb9589	150	55	19800
23428	https://transaction.ru27da0c0f79c9cc56408f982112114ba0	119	52	19800
23429	https://transaction.rue5c1ba3843783b4d308d79cf5bd3f582	80	51	19800
23430	https://transaction.rue1997038611bd09a908978596adadf88	21	110	19800
23431	https://transaction.ruef659a95ce78d71e16872768a49315e0	38	109	19800
23432	https://transaction.ru03592fc460081ef7f83039204f9222c1	259	85	19800
23433	https://transaction.rua8383f0ce06d9a54f10af1404dc3bb50	63	107	19800
23434	https://transaction.ru6f48915bfa5b7d43fe2cb663d14b29bc	145	113	19800
23435	https://transaction.ru722d382ebeaca450f81607caa7c45275	108	80	19800
23436	https://transaction.ru2567650abef7eb45f9c4b7f0d7307937	180	81	19800
23437	https://transaction.ru45ac3236c158a3c88c17676cf5f82263	159	82	19800
23438	https://transaction.ru26c54a2f32bbcb643b72bb885f7177df	263	164	101
23439	https://transaction.ru76aae31fc2adf00e1ff2d8b8e12b6a5f	163	167	102
23440	https://transaction.ru0b82c72fe9dbb33cedf0fc32c0065590	50	203	102
23441	https://transaction.rua5e9eeab9a92ab47c09a40ee4e5b299e	160	164	103
23442	https://transaction.ru7b39def54d23bd116bea20bb5db296ab	254	166	104
23443	https://transaction.ru7f132c59a2ded03874e7e1d5800af35a	151	204	104
23444	https://transaction.ru519975c3e309922df92f045efd3fc867	285	201	104
23445	https://transaction.ruea343c8d558a6f8800d8b6710d2ab184	84	203	105
23446	https://transaction.ruaa7d456849392d2cd9556b105404f6fd	215	201	105
23447	https://transaction.rufe040debc8e7ab70d15805dc752499ee	101	202	105
23448	https://transaction.ru11f7f3378cd4b2aeab8df1b5b4b8ac03	224	164	105
23449	https://transaction.ru858e47701162578e5e627cd93ab0938a	159	200	106
23450	https://transaction.rue4abdc375ea57c2a86ba22a11f885a9d	57	203	107
23451	https://transaction.rudba2660fb302d58323c1f20ca0613e9d	208	168	107
23452	https://transaction.ru7839a539755e35dc00b94115f3402515	253	167	108
23453	https://transaction.ru43fb0d1b6231cacc1d8962ad9cfcbb93	118	164	108
23454	https://transaction.rubbe1db1fe0a667244d5efb61837938c4	200	203	108
23455	https://transaction.ru226ac6e6f900737ecd225d555480945e	73	168	109
23456	https://transaction.rue48bd20919a8c97b92c14dbb51ce53a1	276	167	111
23457	https://transaction.ru74eac8d802a9557e5268bf522684dbd2	55	165	111
23458	https://transaction.ruea0a2a4f2f1f4c4b7b10937ce0ce6395	263	164	111
23459	https://transaction.ru2ec3cd009543405af108ad67980c69e3	63	164	112
23460	https://transaction.rud82f71b0e30a5470f2bf4b062f942c98	143	166	112
23461	https://transaction.ru5f99bb3c605e606c2ffea4463e897614	37	168	112
23462	https://transaction.ru45fb753c38eaf1d31333c6ed010b9bfa	190	166	113
23463	https://transaction.ru446d0b7c5f8bd34762b02d28ca6dacc3	167	164	113
23464	https://transaction.ru5be8de4be5b67f47ecfc6aff1bc7f797	232	200	113
23465	https://transaction.rua0b2d587a1dcacb6a6038d6669cc9eda	121	203	113
23466	https://transaction.ru766c60934a2a27936776e74ba247863d	294	203	114
23467	https://transaction.ru2ee45cde6d359ed42980063a236f7d45	300	167	114
23468	https://transaction.ru7dc43f6c0539e911d7b5d6eecdedec9e	86	168	114
23469	https://transaction.ru0f18e4824fc601cd270a4d31b084bb5d	179	204	114
23470	https://transaction.ru66799d8a2ab74c58e4d812c571b4df09	154	202	115
23471	https://transaction.ru28689f39401b4eaa9fc79efde978ca11	67	201	116
23472	https://transaction.ru9f557b09733c4c47085493a7f8ce10c7	141	200	118
23473	https://transaction.ru08d6ccdc76b7e2d3463b743d0167853a	217	168	118
23474	https://transaction.ru1ca43cceffde49d116e8b60e416e3521	88	204	119
23475	https://transaction.ru8c6804aaf6f55c5bc8cd8983513a46dc	207	203	120
23476	https://transaction.rue06bf8749a8cdde93c99febc4436ec9e	65	202	120
23477	https://transaction.ru6cb248d3a8cc1d6648ab1086bdcbd20d	249	168	121
23478	https://transaction.rue1f2ac105fe69fda74a58f7fcc697c0e	37	166	122
23479	https://transaction.ru3d4ee28567a2c87f808ca4a253262ef9	97	200	122
23480	https://transaction.ruc5b4b3f53723416c63b4bfe32f34291c	54	200	123
23481	https://transaction.ru4ce5611a3f4012f5c201c5e894d721bf	299	201	123
23482	https://transaction.ru6bb1d1037f92e6150096f1d87ec03cc6	127	164	123
23483	https://transaction.ru8ff30ddf7bebcadce007d44d28e52a7c	70	202	124
23484	https://transaction.rued46eb84daf5edfde9ec3111677da19a	170	168	125
23485	https://transaction.ru8922c647e7f610c2a9502a25ad4fcebe	98	166	126
23486	https://transaction.ruc93aa674e8a0cdf6c56ea8111fd75226	46	165	126
23487	https://transaction.ru46514b56c99751f4dfee8a45ed09d08a	181	202	126
23488	https://transaction.ru103eb0d0631a664ff9ecba9b9a8a8dc9	65	201	127
23489	https://transaction.ru1dfcff13ed012f9154418a9f4abf5a51	156	166	127
23490	https://transaction.ru556dcc16324226ceab421cef11e732e5	175	165	127
23491	https://transaction.ru55d14ee5d23a67a8869a348933899128	41	167	127
23492	https://transaction.ru326ad2cc310e7809a6cd8a2929b4730a	147	203	128
23493	https://transaction.rub3715f68f98f7f475e8a63598b748fec	99	201	128
23494	https://transaction.ru28ddf2478818e9e7d91a8d86e6a4d14b	109	202	129
23495	https://transaction.ru6fdd919ad0630cefe48722536183b6b0	29	166	129
23496	https://transaction.ru62dee803f4071bd95a11e66e9b8324a7	219	167	129
23497	https://transaction.rucdc2b426416a0d31dd4b8b1033357c67	135	167	130
23498	https://transaction.ruff4b570b364a9f8bb0ecb0abd5bc4c58	62	165	131
23499	https://transaction.ruebbcc7dbe884424ddbb99c5c3f17724b	55	168	131
23500	https://transaction.ru3b08b955eabb6f5aaaae71600f21b7a0	85	167	131
23501	https://transaction.ru136889e224ea0f8d30baa569dc77cadc	251	204	131
23502	https://transaction.ru3cd64438a49fa691d630a82160cad319	171	200	131
23503	https://transaction.ru42e477e850c3d95a3db6d15f34c20c01	11	200	132
23504	https://transaction.ru5c850c39627e11ba4cba38cf16695714	102	168	132
23505	https://transaction.ru5bb0c5793546d2cff42baa440690b6d6	6	167	133
23506	https://transaction.rud0d2c22f4836520fe28c3c406cd13461	275	168	133
23507	https://transaction.ru75dcada5439d1aaebe7e51ccaa4fc7d5	234	166	135
23508	https://transaction.ru82e741c3dc70752caadc0e81b23af388	181	167	135
23509	https://transaction.rufff574293a6252f4029a9413f364b2e6	61	202	135
23510	https://transaction.ru538a8d95b3f73ccc4f9c70b0d4fd5b06	189	200	135
23511	https://transaction.ru3f0086613ff2c2552aabfe23081418f9	190	200	137
23512	https://transaction.ru4baf8a5da4ead707946692cd3845d8d5	136	201	137
23513	https://transaction.ru9aaf119b31e8b96a315b6623dbfdcf77	270	204	137
23514	https://transaction.ru296edf6a6664e9f6ce2aa756bb37a106	82	166	138
23515	https://transaction.rue5e5fd977b1c5fb44b44d8941a83ad63	60	165	138
23516	https://transaction.ruea78aa5d77f150df5d2bc198f9159993	112	202	139
23517	https://transaction.ru0c314b1bbb0e9354a72753a479e196e3	69	203	139
23518	https://transaction.ru23d2018fbeae92114a4f4ff189549215	97	200	140
23519	https://transaction.ru919a716eedf29bec50572fd2419ddb42	71	167	140
23520	https://transaction.ru8bc760592458a63d0f098ab126963d0a	41	203	141
23521	https://transaction.ru3b985b0a0c85f4406903b6c7a34b0162	274	202	142
23522	https://transaction.ru91caf8baf768a5cc1a69f73a26e173dd	158	200	143
23523	https://transaction.ru202e71505625a2dfe85568033b0618eb	233	200	144
23524	https://transaction.rub2458150520527b28db55d518fc2ce46	171	201	144
23525	https://transaction.rub9636f63cfdc1cf96813aa2690527afc	146	165	144
23526	https://transaction.ru73aa958d3a6bcbcadd45ba08b1ed937b	150	164	144
23527	https://transaction.ru2aa0943f5628920ecc3cc008ba147302	125	203	145
23528	https://transaction.ru2f88d23e18b9c290f92240a327d865e8	253	201	146
23529	https://transaction.ru269d6e74d300993b801416d4d3bb70c9	205	203	146
23530	https://transaction.rubf1d571a3e89d37aa61bbd41a6650011	172	203	147
23531	https://transaction.ru5f1e1ebbd53fac029e31da5f3c090683	10	203	148
23532	https://transaction.ru3ef08038549f7967bd238717afda95ed	153	164	148
23533	https://transaction.ru4d6844230fab05417329379005fcc647	47	166	148
23534	https://transaction.ru3f0131c8f4b97b7ab5f93b97cf64248b	43	165	148
23535	https://transaction.ru10420b8b941d950a223d13702c26f842	245	204	149
23536	https://transaction.rufb4dc1e2862d746384b5338148c5bc58	145	202	149
23537	https://transaction.ru22b8372a37b2818e494fd9b18c25290d	140	204	150
23538	https://transaction.ru245ae6b7ca32b2c2b8b3b46ec7fa6ac8	48	166	150
23539	https://transaction.rue7fb06cddaa35adfeca9afd3924affcb	184	167	151
23540	https://transaction.ru5f774bc5f54feecf28e9cc745af55218	215	201	151
23541	https://transaction.ru2beda50f5a812d4f46d96564dd2318ec	133	202	151
23542	https://transaction.ru1a7fd2fd6810d57a56c0f15a22a4ccc3	288	204	152
23543	https://transaction.ru6fb41c898918ad5a0df0e50f3790f057	39	166	153
23544	https://transaction.ru9fbbff93804bbc32981513c673149fbd	88	201	153
23545	https://transaction.ru175bfaeb2df3ef7a0707a2e734ea1fc3	118	200	153
23546	https://transaction.ruccdb20608270033d9d434cf1c470f3c9	45	203	154
23547	https://transaction.ruf27e8c527d4838330926541202c29ccc	162	166	154
23548	https://transaction.rub227d9fd59cf556a7fe81c89ca5a87e9	223	203	155
23549	https://transaction.ru2dba684a149a7b66b5fcefdd4ddb57e1	16	200	156
23550	https://transaction.rubf5da0b59d123eef0d180eca5535ca9b	148	201	156
23551	https://transaction.ru67b4c26bbdd9afff93032f82b31dd3c0	53	165	156
23552	https://transaction.rud5fd2454a13f2804322bf8fbc3dfbe08	6	165	157
23553	https://transaction.rud65633126a14af87176713d1f3e58afc	243	204	157
23554	https://transaction.rub18c34b5ad0657311540efe90e4ed299	77	164	157
23555	https://transaction.ruea5ddea21b309b814b792b36c3cc595c	208	203	157
23556	https://transaction.ru1ea56ed5e3f31e6d3a0248c32c6b0c94	157	200	157
23557	https://transaction.rubf247cd65d4f8d2038f5081c37968a6b	211	201	157
23558	https://transaction.ru340be9d07195168848dd6af0e13cede7	27	202	158
23559	https://transaction.ru43da9e7fefa8edf60cdaf2d31293b633	266	164	158
23560	https://transaction.ru8f00d2f049c415df713df8bdb194e75d	38	168	158
23561	https://transaction.rubbc0bcb4d4489c434b6466cf11399724	91	204	159
23562	https://transaction.ru4bc8b947bc37e307d814061fefd6af41	299	201	159
23563	https://transaction.rud52fb9ba46bed38c94a319bcd6df32b7	241	200	160
23564	https://transaction.ru49d9a40d7e55c5a283a2910fd7a171af	191	166	160
23565	https://transaction.ru15a86b672075fab097a0949b09fa6c88	185	165	160
23566	https://transaction.ru7fe3fe3425617e6425e0ccf34e8f781e	16	167	161
23567	https://transaction.ru86318f557a35c4c4232ef79ba561e373	291	204	162
23568	https://transaction.ru4d69ba2565581ebaa09a64efa7db29e7	97	202	162
23569	https://transaction.ru16aa68d82d2a082f273772990fd7eb1a	75	201	163
23570	https://transaction.ru4ca461163895236e8fe6dbc467b8dec1	243	165	163
23571	https://transaction.ru0125b4dc689d3a4becc3208197e2f9c5	283	167	163
23572	https://transaction.ru0dee07eeab84b54c07b55f831f07135a	204	168	164
23573	https://transaction.ru5f0fd490a69898f5979f9b642c629c6a	299	202	164
23574	https://transaction.ruf2258de6a8485783e9c8ccd6e62379b8	75	168	165
23575	https://transaction.ru295193214080af8c41ede9c9526a423d	101	165	165
23576	https://transaction.rue2ffe6e3efad872631508762c767e73b	235	204	165
23577	https://transaction.rubb836c01cdc9120a9c984c525e4b1a4a	246	165	166
23578	https://transaction.ru87c3eb681ed98b59648bfab27b4d1aed	51	200	166
23579	https://transaction.rua1d67c08c0a0609623e61d5528a59b7d	172	202	167
23580	https://transaction.rue642a30187ddab6dd39f08d0850a2805	253	167	167
23581	https://transaction.ru8b210f33a5de91c9c294a126afc60c8f	232	166	167
23582	https://transaction.ru36f1f8c3ac881582f0ea1325a510e3ba	113	167	168
23583	https://transaction.ruc06cc173c81181e9e9fc786c5bac24a4	124	164	168
23584	https://transaction.ru9b3d616efffb52751fd968db82ece52a	210	203	168
23585	https://transaction.ru89356fb159934edc63c2520ff8776bdc	94	203	169
23586	https://transaction.rub72a28f24379f820a29df534a93a88b4	36	164	169
23587	https://transaction.rua8b180f1ab3edb0b2bf8df7c60918e8e	56	165	170
23588	https://transaction.ru44c998b3b5abbb018923b242f5f30f14	174	168	170
23589	https://transaction.ru91f49525f66661de4bfe16c51ebf73ca	153	164	171
23590	https://transaction.ru680dbcc9c9ec493d850625a5da9c4c95	226	202	171
23591	https://transaction.ru3a56052479e52ccefc8fb0ab91a2b464	169	168	172
23592	https://transaction.rucc763aee48842ccc8e772b57784b6e6a	36	168	173
23593	https://transaction.rud8da27464ea40801f9a62e94e377a36c	27	164	173
23594	https://transaction.ru140237ed9a710f6c09e200dbc0fa51d5	151	204	173
23595	https://transaction.ru1b3b6b54f5544748d141deacbb108209	288	200	173
23596	https://transaction.ru77256941b3376311cc84c9d1a169c3c6	198	203	173
23597	https://transaction.ru51b9e3eb05f6f8ebccc0d80a1c606498	100	201	174
23598	https://transaction.ru14136668949bf40ebaae0ba46afb0212	134	166	174
23599	https://transaction.rue09c983a032ccfd2c6fd1e9e96d78a47	290	168	176
23600	https://transaction.ru048bfd443563e3548244d3461166792c	222	204	176
23601	https://transaction.ru649f7e2bf4d7efb62d56f6090cf943eb	29	167	177
23602	https://transaction.rue7675c98f47fae9a75566f3b7c34dee0	134	164	177
23603	https://transaction.ru1a657fcd3af435f854805aa3eac6d4dc	251	166	178
23604	https://transaction.ruf22991cbc7408eb7b6f3cb30537db309	86	200	178
23605	https://transaction.ru3a119d1a455f1d679c3b379747acacc1	194	202	178
23606	https://transaction.rua6837ee9f89127dd74263aaa81b11719	127	202	179
23607	https://transaction.ru7ffe7113e626549cd7c13cc93245ed67	290	166	179
23608	https://transaction.ru6fb17788e2a50d1a43d0c9a860e51420	297	164	179
23609	https://transaction.ruc27729ae9fe0f87402801c6cbaa424c0	169	204	180
23610	https://transaction.ru407c399d19bfc3ec0f704d998bddb4f4	139	168	181
23611	https://transaction.ruec9a0138740439615c451dd066257e8f	212	201	181
23612	https://transaction.ru29c7db7884059fad864c6a6566463faf	63	200	181
23613	https://transaction.ru6ae91bf19ec37a9f17466e8ff0820b19	185	203	181
23614	https://transaction.ru9313eaee8b7b7bdadc3696a34d2c5921	176	203	182
23615	https://transaction.rud1cb735819ebfeb6c938fde4cbddf628	115	168	182
23616	https://transaction.ru7d185dea2b933d0584320a6c719149bf	37	166	182
23617	https://transaction.rud04d17ae3db435a3d4263a7a613bf11e	53	168	183
23618	https://transaction.rue0b10f3e0ead892690b2f6b1de2acf40	128	167	184
23619	https://transaction.ru6cc1e2d7145f8451971ea97494bcf131	149	165	184
23620	https://transaction.rub6954e65b96bcc39c936868faca9a034	239	200	184
23621	https://transaction.rua9553cfcbc49f90b78e2aa9f9562ffcb	88	203	184
23622	https://transaction.ru448399a510ab511a724ec89e4cb28e45	213	200	185
23623	https://transaction.rua9b8b79a4b28b9be0372c9c464435b5c	115	203	186
23624	https://transaction.ru8bfc910c4aca42dc7f461fe1615c798c	228	201	186
23625	https://transaction.rubbf6676795e1578351c407423574d75a	13	167	186
23626	https://transaction.ru72cb5a941819ddd7f314ed136f54e66c	7	167	188
23627	https://transaction.ruc3e170c56d0591e643393edca29425ed	130	202	188
23628	https://transaction.rud4adea10706d632712b4c4e0a218694f	106	201	188
23629	https://transaction.rucd7ace3b71312fef9068b50a86d2fcd8	56	166	190
23630	https://transaction.rua8a2c515c4d1b9bdfcd1dec178c5e192	96	164	190
23631	https://transaction.ru8a8f857aa710f20cadf9d24b4f4ef838	51	164	191
23632	https://transaction.ru05ddeae0b6bccad34befefeb7e1102e1	186	168	191
23633	https://transaction.ru1c12465be6af235c8f653ac7a86f3c40	250	201	191
23634	https://transaction.ru08f7ef97efa376f0598c7dae67b46333	283	167	192
23635	https://transaction.ru38d7cdcc7517d0b58786cbb7c656bed5	294	168	192
23636	https://transaction.ruec7198139a9c777b24d6114b54d9fd98	204	164	193
23637	https://transaction.ruf8af75267b2b8f13651fbef541778ed2	248	202	193
23638	https://transaction.rueea3d811806bdec98aae37ad6b574561	278	203	194
23639	https://transaction.ru6a88aa35b1b928a548802f09b9adf632	266	202	194
23640	https://transaction.ru9ae0490f0330088e3fdae360e31208e4	167	168	194
23641	https://transaction.ru1610e83e676d7864749817e301683d65	266	164	195
23642	https://transaction.ru032bb3beacbdd14f42e663e3b3c7c989	121	204	195
23643	https://transaction.ru60fc3c434b27a791e7fb6511585caf00	261	200	195
23644	https://transaction.ru66c925506b1cc4a88ad2f78d690a671d	119	164	196
23645	https://transaction.ru5171728d2ef1561cbc68254f6510ed3e	194	168	196
23646	https://transaction.rudd0ef7611f87e5f3cda10f61ca2c8334	72	164	197
23647	https://transaction.rubb81747d267b2b0d276fb6b333a89f1f	126	201	197
23648	https://transaction.ruf0a13e9065b4d31fda4920299ed9919c	219	203	197
23649	https://transaction.ru3f5ec6ee8074638904cb7f569d9aff94	228	202	198
23650	https://transaction.ru0484b6842ac16d11b42a7de9b210f376	221	201	198
23651	https://transaction.ruddcc4b83f3b8ad445f9c18a3328b5988	106	164	198
23652	https://transaction.ru4ab20d4aa2896a64d1231a968b8f1dbd	112	166	198
23653	https://transaction.ru7565125ea65e5f0ade6df9cdef1461ce	199	203	199
23654	https://transaction.ru12fe83a1dfe328faed356dfae15d896f	70	200	200
23655	https://transaction.ru6ceda1162113b4ce843bcb035bcecf93	232	204	200
23656	https://transaction.ruf9b50ee5332e851b0b3227b3f3040c67	75	132	4501
23657	https://transaction.rud7356ee6b978dc7a7e9f51eae974e1f5	285	134	4501
23658	https://transaction.rue809301733d0ba9749c3e9ce38bbfafa	263	135	4501
23659	https://transaction.ru01566fd19ad7b9a7f332be2d283046c7	291	170	4501
23660	https://transaction.rue457aff4c9589417c53b9200c55f5354	269	169	4502
23661	https://transaction.ru7349662f5cc8f9e5005dc121824adce4	88	171	4503
23662	https://transaction.ru2fd1343ec54e174a724fc2be07aba98e	180	172	4503
23663	https://transaction.rued69f3d734f84ce3599faba3b2e9b106	203	132	4503
23664	https://transaction.ruf65127945e9bdfe4b0fc3b3242aadfbb	84	173	4503
23665	https://transaction.rub5460d090c1ff62896daf979f0b4b618	216	206	4504
23666	https://transaction.ru1b8c0f6143e9afdd79139d4fd825d11c	178	207	4504
23667	https://transaction.rua33799eb3c64247357f9ab77c7e5e0be	239	207	4505
23668	https://transaction.ru17f8d7556a684359a394c2612fed53db	166	206	4505
23669	https://transaction.rucb5453f15cad4e1e9ed39205e6ae67a6	59	133	4505
23670	https://transaction.rubd86596b7551b8eed153fc5b76cfc1d5	262	171	4505
23671	https://transaction.rue11c2632595b08af68449f30bd8ca3bd	263	173	4505
23672	https://transaction.ru2404c19883027dc4378b7057227bcf13	233	173	4506
23673	https://transaction.ru541a12442fe96790bf6dd445e55452e4	65	131	4506
23674	https://transaction.rud5e0e38e03ff60c2157634c8225691b7	247	207	4506
23675	https://transaction.ru61f3a6dbc9120ea78ef75544826c814e	127	206	4506
23676	https://transaction.ruee5e5fc6049d3fd50f50625214277589	24	209	4506
23677	https://transaction.rud0cb32df432d97abfda1f167d597fe75	122	134	4507
23678	https://transaction.ruf84e516814072473a09ebbfde7759e36	131	172	4507
23679	https://transaction.ru2959f773937bc03403a78462d79a456c	159	171	4508
23680	https://transaction.rud93fc8d8e12f03883ca9d7fb69d60890	259	132	4508
23681	https://transaction.rub63f73301fe289a7c258eb2e3f4986ce	123	133	4508
23682	https://transaction.ru7b5a76e67c16bcd2ea535b2d35592b5f	221	132	4509
23683	https://transaction.ru933e02678cfa0ad61c6fcb918c91e0b3	126	131	4510
23684	https://transaction.ru16ecd25fd866ec382b288ee8698e1f9e	236	134	4510
23685	https://transaction.ruc739ec166907570f3bda7b58022447e6	99	206	4510
23686	https://transaction.ruca5696251f0c8cbfab498ea262a66cf1	123	207	4511
23687	https://transaction.ru94cbfd54b262bae21ddeb6947d370996	134	135	4511
23688	https://transaction.ru3954f5368843c608cb64da76c90df7bc	83	169	4511
23689	https://transaction.ru071d6b5710f978235f32bd3c33bf442c	244	171	4511
23690	https://transaction.ru9cbba5c660c958a1cc8f50be625e7e9a	278	208	4511
23691	https://transaction.ru6ab4b37a76a56392a50cdc158c1d73cd	161	209	4511
23692	https://transaction.ru5df762f3729d5d43a2cec0530f07b926	264	208	4512
23693	https://transaction.rub35f7402f2564edd38a5489d4e10da6b	164	172	4512
23694	https://transaction.ruf5b974a2bf8a78872e0b9302e685cd40	272	169	4512
23695	https://transaction.ru5a8fa69d3ec4332701df336a41d4f20a	166	169	4513
23696	https://transaction.ruca8d67af76808800cfe9182a3510f86c	205	134	4513
23697	https://transaction.ru2f3dc9420ab512a02fc9bb58f24e63c0	87	133	4513
23698	https://transaction.rud3fa1de61442cda4bb4d855fd8bcdbef	87	133	4514
23699	https://transaction.ru1fe34934f5ca1aee9ddac292da7d4357	32	169	4514
23700	https://transaction.ruecbad702955123762b44b39c61cee1c7	89	170	4514
23701	https://transaction.rue0c082bdcbcf050ff454698580c89289	109	206	4514
23702	https://transaction.ru0c186ef3f13356a6e82e64675790baf4	224	209	4514
23703	https://transaction.ru6967a5fb05106806a40c6917a18023df	281	208	4515
23704	https://transaction.rub3c00c7f3639fe3d7952183622ae1fb7	235	172	4515
23705	https://transaction.ruaba80e2e4979ed9d4787c7fc550634f1	261	170	4515
23706	https://transaction.ru7da5bc4daadb3f9012e7d1144a303fb6	27	171	4515
23707	https://transaction.ru72f2b2ba4ab3e42b06f6776f78dd990c	236	173	4515
23708	https://transaction.ru104fc218e11705937042d944e90d2ac8	10	206	4516
23709	https://transaction.ru2ce6356a393f57fb33dbe716002b405f	183	209	4516
23710	https://transaction.rufd35b1366a0b6266b94a90cc5fae5d30	83	206	4517
23711	https://transaction.rub44153e1752836cd2c03e9a343f32927	278	207	4517
23712	https://transaction.ru1038773d844fcb750b20d5b514a99b2f	94	172	4517
23713	https://transaction.ru6c887eef7dacddc4b07ea5a5f1c07d24	218	132	4517
23714	https://transaction.rub925c22fdb94aceac7ed2eedd3aee35c	85	133	4517
23715	https://transaction.ru1e26297aaa0a9a5e7e3ff43c86303ce7	209	206	4518
23716	https://transaction.ru4e631fda7a54afb051c1fcb57d9e592a	19	208	4518
23717	https://transaction.rud72487f9d144cfd5ea62a54dbf3e7b6b	152	208	4519
23718	https://transaction.ruced61d23757911ea0213a2bed09762b4	58	171	4519
23719	https://transaction.ru86e325c6b29ee6d5faff7480ac243f2c	106	135	4519
23720	https://transaction.rud5b93e87ecdc02e1db8bd6edcd0d05fb	22	173	4520
23721	https://transaction.rue6b89c4e943bfeaa6887c150bac97b5d	182	171	4520
23722	https://transaction.ru1f9b13245823c49d386318f04a8f46fe	291	170	4521
23723	https://transaction.ruc8d64a7b268bcbb8299062b47428870b	301	133	4521
23724	https://transaction.ru7d20873b83b3ced2f2cb365a616b6709	24	131	4521
23725	https://transaction.ru04930d00fbff812a0390c8173aa92faa	118	173	4521
23726	https://transaction.ru548a19852737934485a2fdabce2efbfa	19	208	4521
23727	https://transaction.ru93ec215839f8edb8172283176fd22c90	43	209	4521
23728	https://transaction.ru6e2e4234731a0a67a0e39ca6ebcbd3f7	94	209	4522
23729	https://transaction.ru259cc3066d31934f2bbbfd4480d0b5c9	117	208	4522
23730	https://transaction.ru948c4470f23416a3d4b8ac41fc961507	22	207	4522
23731	https://transaction.ru8187f65ab99ece1dae6618726495a177	49	205	4522
23732	https://transaction.ru4f5868303580dd8b34952648fe54f94c	174	134	4522
23733	https://transaction.ru83a2c6b97c77da38756d2deba38461c0	98	131	4522
23734	https://transaction.ru4ff72fd52fa01fecdc4505b5fb5718c9	195	171	4523
23735	https://transaction.ru1b8613a4b017407b0926b7dcef74740b	20	206	4523
23736	https://transaction.ru5602c207033cc58e1887a724268c8d6e	111	209	4523
23737	https://transaction.rud4619874b001dd3873b262e4f78c9a5a	288	208	4524
23738	https://transaction.ru2303fb81d39eaa86eb6c643c658759d9	117	205	4524
23739	https://transaction.ru48e6a542ebe5325bdaab452f3d2f38dc	195	206	4524
23740	https://transaction.ru03586f45ceda0996b7584076c1b4fd5e	286	134	4524
23741	https://transaction.ru7fe00f88adbcf32896b850390e3b2166	254	135	4524
23742	https://transaction.ru20c81cf7177415524610208073e75d40	60	169	4524
23743	https://transaction.ru33eb130cae0f9acb876e07a0d9594568	79	172	4524
23744	https://transaction.rua393a7a634091f7cb0f2c753e48fc0e7	46	172	4525
23745	https://transaction.ru831a7cbed36d4a102279d76ff1b76745	160	171	4525
23746	https://transaction.rudaedbccc0a0070174732f5b82fe02343	29	134	4525
23747	https://transaction.ru975b8740d52cfd2277bbe372ba4ae0dc	182	131	4525
23748	https://transaction.ru97630c351cefa3de62df5cb6f0dbc033	132	133	4525
23749	https://transaction.ru8c65e32e70b95a6be936893d80c63547	268	205	4525
23750	https://transaction.ruf4ef9e092ae1fac11498ad73ec07b2c7	95	208	4525
23751	https://transaction.ru3670a52c72e5cbe6a0e26e9bc51e9f50	60	170	4526
23752	https://transaction.ruc20c46885d2528beeaec60fffcbc8b1a	2	171	4526
23753	https://transaction.ru0c88b44d11d67935878e6ac8e43a4750	9	170	4527
23754	https://transaction.ru6f0cf94206018505b14bcc8e9925ae20	147	169	4527
23755	https://transaction.ru8e00be16462c18c5428861964af08403	179	206	4528
23756	https://transaction.ru84f6859f3ba78d5bca6d40b2bb877562	126	133	4528
23757	https://transaction.ru88337b2fd27a1edda017c0f6e2bad0ad	12	131	4528
23758	https://transaction.ru029f85e308661cc1611ca6c444a77bab	71	132	4528
23759	https://transaction.ru9378e5661b50a790b3ef993dfa3f9c60	43	209	4528
23760	https://transaction.ru1049a396fc9872d90803b711b88d9e64	269	209	4529
23761	https://transaction.ru0eb5bc60f4f25cae55f16ceaea305a01	274	207	4529
23762	https://transaction.rud532d34b5ebff9e71fba8a588abf189a	193	205	4530
23763	https://transaction.rua06d340bcc6861d0a4049ba99407f1a5	68	207	4530
23764	https://transaction.ruff6512c32c712ce20d8c68353b27ac0b	212	133	4530
23765	https://transaction.ru8cd5dd2689f8cc8e18a9efb2aad68502	179	131	4530
23766	https://transaction.ru227599caba3c931ef80cfa30355be06b	188	169	4530
23767	https://transaction.rucfe166a1821d02fcc4e191bfa951da0c	185	208	4530
23768	https://transaction.ru6e40bb76aed065932b7314cf7ea9629b	282	209	4530
23769	https://transaction.ru13bf5fbda7f4df95e7735cac00b8fd7b	280	172	4531
23770	https://transaction.rufded373b0e601c57b0106eefe44da171	279	134	4531
23771	https://transaction.ru292eb591d4845f8a075060f6b2839de6	98	207	4531
23772	https://transaction.rua6e2a3c39a4029e77d2cbab488b8aa16	126	135	4531
23773	https://transaction.ru6286e05f6472064c677261315232867d	39	133	4532
23774	https://transaction.rub436ea177a62dc95c6422d89b6b603c2	32	132	4532
23775	https://transaction.ru10d66d3106dc075f1ca1842b3c6dd7d4	118	171	4532
23776	https://transaction.ru71735fbd796ae9e347ad82f208f1232b	183	169	4532
23777	https://transaction.ruac2987798dedb0aba802ba170a7ae3cc	67	170	4532
23778	https://transaction.rub3f6423a58cc1c308fbb65b7738f5629	285	207	4532
23779	https://transaction.ru2dccf0ba73481a971303ec8bd3892826	224	205	4532
23780	https://transaction.ru998351892c0f50fe67da7a4b4b3cf40d	16	206	4532
23781	https://transaction.ru016d21c65cc580f482f40205ac3e3971	59	208	4532
23782	https://transaction.ru980910a0b4eaf4f770e4adc02ab9b30b	72	208	4533
23783	https://transaction.ru21b30185d1c173321091e9d2bd56f0d6	59	206	4533
23784	https://transaction.ru616862507de1fd734b79fd6588cad2c1	75	173	4533
23785	https://transaction.ru4b4f68eb18a23e0580280a26825c6f0e	196	169	4533
23786	https://transaction.rua296f8dd1ca5786cadaefff4d03d356d	219	207	4534
23787	https://transaction.rufa1d8e17e60815a2e8c09ba733a34e22	144	206	4534
23788	https://transaction.rue2004f0e86cd60c1b3f9d25c86caa67a	285	131	4534
23789	https://transaction.ru94c697f92f634a8adc511e662c2deb76	214	133	4534
23790	https://transaction.rua2dd218e7f489ce48cefcecbc6bea20d	246	134	4535
23791	https://transaction.ru47e13dc51cfca5f8fa79507583d2f1c3	117	132	4535
23792	https://transaction.ru4de72ea3c29fd5b60b5b95627242871a	38	205	4535
23793	https://transaction.rucc84915c46f935a183c68ff1e007cdf0	212	169	4535
23794	https://transaction.rued89c19647f094a6475d300cb61ffdfc	105	173	4535
23795	https://transaction.ru02163397aced4a2ec4ae71c6c39a16b7	95	205	4536
23796	https://transaction.rubc5bb82324d4419ecc64b21b2b1b17e1	160	134	4536
23797	https://transaction.ru8dcf2420e78a64333a59674678fb283b	274	171	4536
23798	https://transaction.ru83676ff9ed36facfff31f054d8e98ff1	273	208	4536
23799	https://transaction.ruee2b32446003e721c409a97715fe9a2d	207	208	4538
23800	https://transaction.ru587d1c8357c7de2559b412bc14ab398e	172	169	4538
23801	https://transaction.ru87600699700f9bd878fc82dd3496ebde	242	207	4538
23802	https://transaction.ru1bf0af7bc4262094b48b83ea123da9ec	22	205	4538
23803	https://transaction.rudc910111ecdbf3167bbb1d5489bf7a60	165	173	4538
23804	https://transaction.rufa850ba060f8e88bf1395b7cb4f88d4c	96	133	4538
23805	https://transaction.ru0debb0996b15425e12308be88149031e	232	207	4539
23806	https://transaction.ru4c778ae0e7ce4284df80447e62255be2	157	206	4539
23807	https://transaction.ru094b357e71f0ab2ef8f8c8489abe3d6d	135	135	4539
23808	https://transaction.ru089186d2a7749cab56814ae9e5040c82	261	133	4540
23809	https://transaction.rubd629a7f8f435308c3fad1da179daf92	39	173	4540
23810	https://transaction.ru58b7a65d37c2049f1f6fbe363ca6fbf0	299	171	4541
23811	https://transaction.rua0a2c17b4a857ae6f8b01ec57256f095	71	131	4541
23812	https://transaction.ru75db9e242d2b2f05a258b168a0a18e47	126	173	4542
23813	https://transaction.ruad0022078aac0ed5835f15ab872ebca8	19	207	4542
23814	https://transaction.ru57e780ac5bd4110e6e7d6b8d9a90814e	183	205	4542
23815	https://transaction.rub5cfb8dc662e749efc66ceaa84de6a9b	87	171	4542
23816	https://transaction.ru48e83574d1a8c086c9ea27f3d71b8c17	121	170	4542
23817	https://transaction.ru997984d8961a9d0d3a89b73bc94804f4	204	171	4543
23818	https://transaction.ru845e5176d7a03ccccffc61f4173fee67	224	170	4543
23819	https://transaction.ruf60fa86f8635a008047881b19c356084	73	131	4543
23820	https://transaction.ru8c8bd461d3f8b40d0cc0750b8a3ae4ea	67	134	4543
23821	https://transaction.ru143596296616e6a2ffd853a486724837	137	209	4543
23822	https://transaction.rude8e5e84dd453855119e4c74f4540495	121	208	4543
23823	https://transaction.ru8ee6cbd04e6f15b42367eb8dff2b7c06	53	133	4544
23824	https://transaction.ru6b46e629140b99a84c4b2d5108b88142	36	134	4544
23825	https://transaction.ru0b888acd25022d2cd9ad71df9810b246	23	169	4544
23826	https://transaction.ru970c9bf0709e25eee760ea49c6f50632	44	131	4545
23827	https://transaction.ruf760960bab162dedda5aa22b027a1d99	167	173	4545
23828	https://transaction.ru856c19fb0385798efbfd4ed8fd4501d1	195	173	4546
23829	https://transaction.ru2bf0cbca06c8e8a89918c642b42dbb8d	257	132	4546
23830	https://transaction.ru8224fec53561cbc822929169486a959e	128	170	4546
23831	https://transaction.rub5e651818b35b20316f1d8e83b253ba8	108	169	4546
23832	https://transaction.ruc7f7e994e34b7d6de1317f3701203907	285	169	4547
23833	https://transaction.ru41afb4923f6cb4fc046fe7a12f30c4f5	126	209	4547
23834	https://transaction.rub67eaf366b1cb4db771463d7044b7ffc	168	131	4548
23835	https://transaction.ru2bd1a4af527225b52d196ebc36f47f89	158	133	4548
23836	https://transaction.rudb17ecfa4d539e5b102ebca0e649dbc6	32	135	4548
23837	https://transaction.rud47e462e90aff650a7857e1c77e055f8	103	206	4548
23838	https://transaction.ru3638a2669b23dbddb6f03ffbb069977a	141	134	4549
23839	https://transaction.ru2bb2413d5cbfe92998ae53460e513156	32	209	4549
23840	https://transaction.rud3b1617e070492237783fa3bea071b85	77	208	4550
23841	https://transaction.ru8aaa77c112709016dc216539204b6a2b	16	131	4550
23842	https://transaction.ru384f7c49e186d6850b9f051b3071f023	282	173	4550
23843	https://transaction.ru82b363b6f9c442367a1160b64cd4fc94	204	131	4551
23844	https://transaction.ru8ac4fdeb61ec5f50bb973c7e44143205	291	170	4551
23845	https://transaction.ru1fe6ebbd7d718fc2a8010756ede5ce8a	255	208	4551
23846	https://transaction.rufef9904af76de3e169d287589e6b3bac	206	171	4552
23847	https://transaction.rud05da67f60538b78b37052aee3b26257	253	172	4553
23848	https://transaction.ruda1d5235f37bd1a21703b022f98915cb	257	171	4553
23849	https://transaction.ru3930fd50d70d5c2b3ec09a08e2370851	229	170	4553
23850	https://transaction.ruc985ffc17aa6d462044d650d57ac95fd	233	206	4553
23851	https://transaction.rudf372100c1c9260788e7dec3cc18f2f9	194	135	4553
23852	https://transaction.ru58e451c3c5c1c969a99a870984faf665	202	208	4553
23853	https://transaction.ru1cdbc566ab18141dbf2586d9707cdfdc	77	172	4554
23854	https://transaction.ru988d62aed8989449e54fa33d1879db76	7	132	4554
23855	https://transaction.ru507d5d22886d156042bf1c0dff4a68c0	239	132	4555
23856	https://transaction.ruc4e65d98b85a706a76eac4ed1fcf3008	5	135	4555
23857	https://transaction.rud31ca42bef8caac3c5c1bf09c5eabd17	48	205	4555
23858	https://transaction.ru7d072201c9c1b011c747849230b9a537	103	207	4556
23859	https://transaction.ru374207d8ae81b9cba95c6bf8864ed4c8	28	131	4556
23860	https://transaction.ru4d999856bd76cfeb8a968260d2b4aae5	144	132	4557
23861	https://transaction.ru430579c489bddb6b10e67206face1d18	116	206	4557
23862	https://transaction.ru16aa4322a7cd34832b7fa8d43b36fe54	179	132	4558
23863	https://transaction.ru9b6eb532f3b03aa7bbc5b30de4336d16	26	170	4558
23864	https://transaction.ruc3e1ef8bbde538a81b4134d60988c2e3	73	171	4558
23865	https://transaction.ruc3db0eccf2c514420cdb901fd8c00753	222	169	4558
23866	https://transaction.ru76abfc8949d10c5eb3527b3217b6c2b8	297	169	4559
23867	https://transaction.ru59e5e37d42f6c195faa7bb4ee90941e1	200	134	4559
23868	https://transaction.rub72cf0a9d249980c313835ad40d6c1c0	126	209	4559
23869	https://transaction.ru05151757a7ba6d0f965d1a2b5f20943c	102	208	4560
23870	https://transaction.ruf41f18467b83a1bf6abfeee6e652bcc7	215	209	4560
23871	https://transaction.rud642dda5f0e5425fa42367ae5c2870b7	266	133	4560
23872	https://transaction.rubac26283fbe9f5947628e197830336da	21	131	4560
23873	https://transaction.ru1d77320784863054c79e273e1a03c52f	67	207	4560
23874	https://transaction.ru95ec14d6939579cdb9740ebf5b73ad95	77	131	4561
23875	https://transaction.rue30a7e875207aaea83e5a4c51ca69fa6	290	132	4561
23876	https://transaction.ru8575e1d583be672492de59aece0ec63e	83	173	4561
23877	https://transaction.ruae68abdec2eebfbbe3944e5cd725724a	44	208	4561
23878	https://transaction.ru0b846aa584f7004bab6e57a10a9c39f1	44	173	4562
23879	https://transaction.ru6cb754c29e8b16857a9aba1e8be84fb9	261	206	4562
23880	https://transaction.rufc26e3d7f01c73794b09ee3a7edbf31b	285	205	4562
23881	https://transaction.ru187764d6ee30b53b949810285b92a96b	55	169	4562
23882	https://transaction.rua68b5109e0dbbf33e5e702737ed92631	203	135	4562
23883	https://transaction.ruf9d3c1cd84fe3ca6d9e769009ddea248	122	135	4563
23884	https://transaction.ru00630233712348c9dcd4dc200911572f	4	207	4563
23885	https://transaction.rua260b17d2e102f35f63fe9e00c7c88ca	169	132	4563
23886	https://transaction.rufe6ac53b5736582bf5a801423df85a5d	35	134	4563
23887	https://transaction.rue0fba04fbd0ac90622d4e0ba3ec46a5a	96	131	4563
23888	https://transaction.ru69bbfc451adde98e2720ea06d3452a8e	42	171	4563
23889	https://transaction.ru2acb3374193eacfdc8c704b0faab6fee	284	208	4563
23890	https://transaction.ru7bef45f0267355036e7a7c91bd375292	122	208	4564
23891	https://transaction.rua02b94b14d8655b6ed9c4f9b1a20f1cf	29	209	4564
23892	https://transaction.ru315c28e89007ee350945951fd373fa01	2	207	4564
23893	https://transaction.ru230872c79ad7ce6db1a12740a143b29e	223	133	4564
23894	https://transaction.ruca1b6fe9b08b5dfcb15af51916def04a	90	205	4565
23895	https://transaction.ru658e48e5ab01f51e33ddf1f54ac60bc9	201	208	4565
23896	https://transaction.ru16ddcb4418e54e852a10e63f19744057	43	206	4566
23897	https://transaction.ru309d426f91033fccd9d0808809f3b50d	165	207	4566
23898	https://transaction.ru2e8c782e6e44d0dd6c161d2889d13a96	10	205	4566
23899	https://transaction.ru6ec0036c43212b19d4361d4f409ac9b4	128	169	4566
23900	https://transaction.rubb597418495f220395192db2d22d6e27	65	133	4566
23901	https://transaction.ru292b186b4872beabb9243568afa6f016	226	133	4567
23902	https://transaction.ru98795443cdbf0375dd946728e2f4e51a	25	208	4567
23903	https://transaction.ruac4169fa04de8c50eea6036188fd709e	268	209	4567
23904	https://transaction.ru0c5e01d3a0c1a4654ad65519374ddb00	152	133	4568
23905	https://transaction.ru13d54d0fcd867a4807f5502a726dd227	151	207	4568
23906	https://transaction.ru4ff2f1807c689ad4eac2cc6f14556226	87	170	4568
23907	https://transaction.ru0929bebd72cfcd477a4d3a6af2246e40	212	172	4568
23908	https://transaction.ru822831c83acb492594b9d9f86bbb8ca2	275	170	4569
23909	https://transaction.ru62e888c946065141dd60e95961065521	190	169	4569
23910	https://transaction.ru36846d990143c65d96c44ac4b41d1fe7	177	135	4569
23911	https://transaction.ru2be9a3917253374c94197fda8ed1c499	166	205	4569
23912	https://transaction.ru39d2c57813c1f4522285f4854eca25d0	274	172	4570
23913	https://transaction.ru755eb001687853889fd9ef27dfc77945	282	131	4570
23914	https://transaction.ru78569d1e296fb1ac8aad86e91d3ad3a3	185	134	4570
23915	https://transaction.ru0fd9a285bc80ca84675d8708f7adafb7	106	135	4570
23916	https://transaction.ru9edbac0e558877a5c597f69e37fa696c	106	170	4571
23917	https://transaction.ru9179e2d96deff715fc5445328eeb116c	272	172	4571
23918	https://transaction.ru0c3b9c2c66ac96cf11e0dc755136b872	84	205	4571
23919	https://transaction.ru344a716d2ab4d184cad8d9cf39c54a0a	204	131	4571
23920	https://transaction.ruff37f3dcf25b63a928e2694495850fca	192	209	4571
23921	https://transaction.rued441ecb6c4e44e24b53605deb08ccaf	88	209	4572
23922	https://transaction.ru742b0180f106b5f8e26c0f87733a8385	9	135	4572
23923	https://transaction.ruc67ee7951c1aff01a2750b7e60a9fe4f	38	134	4573
23924	https://transaction.ru46ab94cb20491ecd683267fedeb20fce	256	169	4573
23925	https://transaction.ru4188b0a0664f7e7fe0735615e00ae818	286	170	4573
23926	https://transaction.ruad0cb903053ea88697227d16d33d7012	28	205	4573
23927	https://transaction.ru39e59d177d8cf617e176938af3508ff7	152	207	4574
23928	https://transaction.rud36588560849b5331b607fb56cb9da6d	163	205	4574
23929	https://transaction.ru90b499d2d76e9eab8ef47a550dfd2c34	64	132	4574
23930	https://transaction.ruf209bac7c5b77679d4250969fc45054f	78	169	4574
23931	https://transaction.rudfacc97c3c0265a04e04221e293469d2	212	209	4574
23932	https://transaction.ruabdb569d6e0aa9c4d082451405ca3084	52	209	4575
23933	https://transaction.ru1a5572f880db6f3f8ca9ea1c8364991a	134	131	4575
23934	https://transaction.ru296b2c26dadf607f77849540b0899bb8	22	132	4576
23935	https://transaction.ru4dc76f25f2dd1ac25ddd8145bd619462	142	205	4576
23936	https://transaction.ru583b87c930d69c600ce6371831ce484c	295	135	4576
23937	https://transaction.ru8d078de85ef723b35ff42de2a378061d	101	209	4576
23938	https://transaction.ru9c3e12dd939ac156d3e1c5eaff64ff37	207	134	4577
23939	https://transaction.ru8d9cab252ee2a6416080738e2af38964	123	133	4577
23940	https://transaction.ruf27e6ec426ae2be606c2210e072701c6	290	173	4577
23941	https://transaction.ruea161c9fd48d0f9d8136addf125bd843	198	172	4577
23942	https://transaction.ruca535a5cff15691d81ce832bafb7655f	250	169	4578
23943	https://transaction.ru273e6665d6cda7e921a5b0084e99ef24	130	134	4578
23944	https://transaction.ru6dfda3be9502b7060ed6b834d5616eae	252	205	4578
23945	https://transaction.ru244e6b76cb404f1e057b6417e1c7eab5	128	207	4578
23946	https://transaction.ru47127899938d25d616ec304375ef71db	84	208	4578
23947	https://transaction.ru50e1456e5d78d328176654a5ef92e984	171	208	4579
23948	https://transaction.rua1a13f67aa0ecf1712647d82771004f0	283	171	4579
23949	https://transaction.ruaaacec5c875b45a6eecb07044cd9962e	152	170	4579
23950	https://transaction.ru0b37354e8046d235c36ceb34b8d3754c	225	135	4579
23951	https://transaction.ru54b281c69b79d03fdaf0b71f3ec0e1aa	88	173	4579
23952	https://transaction.ru4323e308ab7c741a9a12a5ec55c31d8b	280	170	4580
23953	https://transaction.ru0683b4c15a88d6cedce5cd1a41928366	276	133	4580
23954	https://transaction.ru6e4afea24819893f730380a049fda0cb	202	131	4580
23955	https://transaction.ruce0ae90eb004776c620e2552f2bfa31a	27	134	4581
23956	https://transaction.ru672561d1b5ed4cb8710f243709268e2c	126	170	4581
23957	https://transaction.ru1f77e0414aeb5c32395ded72c27c6ea2	226	135	4581
23958	https://transaction.rua6306f534925153e95d93d1ae289ac68	161	135	4582
23959	https://transaction.ru4f325be274cf1a96e88e0495e99d84bb	131	133	4582
23960	https://transaction.ru2335dc2ad8a393bb6a05d9d395981d1e	224	132	4582
23961	https://transaction.ru32f600105de03a0c9f6e4655b6d80a2f	149	206	4582
23962	https://transaction.ru955fb9ee9d56d2953a8939da2d5c38d6	200	205	4582
23963	https://transaction.ru5aad38004a6546b2382974698dbcb264	41	205	4583
23964	https://transaction.ru49c99e21c70b5835245d666520754387	96	133	4583
23965	https://transaction.ru0143cf6dad582bf63b85bb5eaeddfbd1	261	169	4583
23966	https://transaction.ru1e46e0572b7a337f429453ca4c288a96	102	208	4583
23967	https://transaction.ru7b65d2d2503ea30734920143f1c33319	138	208	4584
23968	https://transaction.ru5da67c87b9c187ae6b4dc7610947527d	63	170	4584
23969	https://transaction.ru65103d19e80178d90edf29995680c106	153	171	4584
23970	https://transaction.ru84c62bc5b6f1dab11a1ca3d8d7a5e29e	266	172	4584
23971	https://transaction.ru11a6b8dcc85ae8b2b5c5038659359fb1	183	170	4585
23972	https://transaction.ru7229d5fe7155bc97d403cc0cead2fcd7	282	133	4585
23973	https://transaction.ru63e287144971ecb3701ccc1b54f50c2c	20	134	4585
23974	https://transaction.ru4f8fcbea590ef10c2a304210724cf7b0	157	206	4586
23975	https://transaction.ru17af22929d694ba500acc7709c2b6075	164	169	4586
23976	https://transaction.ru535c03e6a4f5f264a6603d39760a31f1	183	209	4586
23977	https://transaction.ru6bc485617ad21d5cec33a01187c2b1ca	253	173	4587
23978	https://transaction.rufb2dd9efc99d91f25d26f4be3102ccc3	15	172	4588
23979	https://transaction.ru79935b6f51082c1b6e09ae8c1dd46b81	155	205	4589
23980	https://transaction.ru6d44978002901492c42831baf8bedde0	164	173	4590
23981	https://transaction.rubc6982b057a41620c87863a581d302ae	58	134	4590
23982	https://transaction.ru215caa49849303677cb28d3a2791e158	118	132	4590
23983	https://transaction.ru4c41707617f9706da738d36f755b9a8d	298	131	4590
23984	https://transaction.ruf53b5a5eb470f87921b5ff3d6a61cda6	213	135	4590
23985	https://transaction.ruce156299af8752333b27057ca66b6978	188	171	4590
23986	https://transaction.ru6e9d746a7e6cf4e045bbfc8f8594b2c7	248	172	4590
23987	https://transaction.ruf8e520ed7ba261b40e599d9f04c03d5c	205	209	4590
23988	https://transaction.rud345bf8661aee30b85d018c44fa86ec2	13	171	4591
23989	https://transaction.ru30837cb4268196a152ce8e57b0a785ee	245	132	4591
23990	https://transaction.ru165f25ea07b9754645973570d7d3c8a4	176	134	4591
23991	https://transaction.ruecb9fe21d268edcb41ecd7d87981e1be	179	173	4591
23992	https://transaction.ru6514b7d7a6e6daf1cd72f4aa20afde19	63	135	4591
23993	https://transaction.ru74ec021139aacf1115cff4a9d1dff115	193	171	4592
23994	https://transaction.ruca4bad89b21533903a47866e21459010	228	207	4592
23995	https://transaction.ru4bd883ef2cce4dac528c6f58fbca9f77	299	173	4592
23996	https://transaction.ru11f1c752c87d9b31d7e943633908ed7f	84	134	4593
23997	https://transaction.ru9ccb9c8ff975226be3be83c4b09be52f	67	207	4593
23998	https://transaction.ru3183ad7c462623ace302b0b46e378c5e	131	205	4593
23999	https://transaction.ru2b00d67a016fc41802fd4a23ab9cc43a	199	208	4593
24000	https://transaction.rueed91aceca67e6a2343759db7d7724d8	193	173	4594
24001	https://transaction.ru213511da1dac4b65f7dcffafce5db0cd	175	172	4594
24002	https://transaction.rube4864ebd7e5c6b2c604f0b181ddd9d7	181	135	4594
24003	https://transaction.ru682a71f837e9006c471f9351ecd7823f	143	134	4594
24004	https://transaction.ru56e421575126bfe4c0592353bab5cfe6	265	133	4595
24005	https://transaction.ru310725177c5713e52f6c217c09f7ac86	101	134	4596
24006	https://transaction.ruecaeafc0832340d4da28bd0370c03094	116	171	4596
24007	https://transaction.ru50aebffda89ca1c16412083847412620	80	207	4596
24008	https://transaction.ruf6ce380bdf17ac1411ed7b13bee948e3	156	205	4596
24009	https://transaction.ru9466e40a4a6208766276ec9d1a70aa70	140	209	4596
24010	https://transaction.ru25d8031dd8e1bf2e98e20997f147d319	292	208	4597
24011	https://transaction.ru14e85b887395d927b3ad57bfbca72140	44	209	4597
24012	https://transaction.ru2d82f40919b92de932fef16017838d31	60	209	4598
24013	https://transaction.ruf5b5a51230813645323296c24f4e80e8	113	169	4598
24014	https://transaction.ru92d637e9be3598a734767878220f74a1	267	132	4598
24015	https://transaction.ru0838c70e6aae1f73bb03acfe2783e20d	187	133	4599
24016	https://transaction.rufd00ff6f4eb4bdb4b6d705123c31bbb2	158	131	4599
24017	https://transaction.ru0a70ded1363427ebf0ffd8911d32dbad	119	170	4599
24018	https://transaction.ru121a8fa990428e63ef770c4b64f8aa2a	101	172	4599
24019	https://transaction.rubf9505517b0da9230809cfaab262b257	208	169	4599
24020	https://transaction.ruad75be5798c96604287438c2cad20dbd	66	205	4599
24021	https://transaction.ru71c4fd940f0cae42a2c7ed6c0482caec	109	135	4599
24022	https://transaction.ru9eb971678279bc1628e604f28c5b585e	210	208	4599
24023	https://transaction.ruffc0978c507577f2e1d0e7c17fd7457b	65	169	4600
24024	https://transaction.rue9caa6cfeebed95575fcf26855c93b4c	116	131	4600
24025	https://transaction.ru07fe856e7278328beffd06aa5c0b8ba5	12	132	4600
24026	https://transaction.rudbeb601183548ed796f9b4a99ecaa150	181	173	4600
24027	https://transaction.rue2cd680f371db6259fd578a48044893f	291	206	4600
24028	https://transaction.ru581b41df0cd50ace849e061ef74827fc	3	137	9801
24029	https://transaction.ruf1ee743dc0a992a08cf2e192c586168c	40	136	9801
24030	https://transaction.ru2c79f31c16b6a22d58d6dcb27cdd9155	196	178	9801
24031	https://transaction.rub8f38dc58e978b4ce98e641061355d7f	100	265	9801
24032	https://transaction.ru20a736126d768fdaff286e1f3173bd9b	83	264	9802
24033	https://transaction.ruee133c9b2ffc7293e7c3d138728b6de1	230	211	9802
24034	https://transaction.ruaf49f6af817d1e71a98ec5b375a035d4	133	213	9802
24035	https://transaction.ru77b4574c8de7f5543c6f84aedaf36075	195	212	9802
24036	https://transaction.ru310fe817b0ae4ee1165ce1a72db00031	45	214	9803
24037	https://transaction.ru6839b966cd65ff2ce687157a6f550b34	294	262	9803
24038	https://transaction.ru3d1c016901678819c11214c1006ccb11	241	261	9803
24039	https://transaction.ru41b9afd19dbb79a24459202a0a696e9c	263	263	9804
24040	https://transaction.rufcf083b42144215069547b626f694a6a	19	271	9804
24041	https://transaction.ru431cfe4bd4a84b68398e14af4be0bdc3	16	266	9804
24042	https://transaction.ru1543c5bc507f1a3931bd936f99e2c8be	254	265	9804
24043	https://transaction.ru2d1cf27d2cbda587136fe8950d4b9fca	140	265	9805
24044	https://transaction.ruf1558e79c0736bcc9770373fdf03dccb	189	272	9805
24045	https://transaction.ruc879e3bf89e32b31a776addbac9cca20	296	211	9805
24046	https://transaction.ru18ee880ed744a03fc508027903a08315	241	210	9805
24047	https://transaction.ruc3f6dd930403f4fe6db730a8af2b3df7	30	262	9805
24048	https://transaction.ruaadb52f9100e0d31264fb3ce9e3d2536	217	261	9805
24049	https://transaction.rua51fb975227d6640e4fe47854476d133	138	177	9805
24050	https://transaction.rua6ad0220e3fbf53f59e9beb42ca146c6	200	176	9805
24051	https://transaction.rudb01d3d39a2e52324cd9ffacb725b9ea	3	140	9805
24052	https://transaction.ru4b2ec13ea7f8d5c17e7c7aab8215bce0	188	137	9805
24053	https://transaction.ru594c1512e94e40eec7c90b556368f290	6	174	9805
24054	https://transaction.ru23e2d183584f052931d390182334f3ac	119	175	9805
24055	https://transaction.ru940e54a252d92a6d61ca7886eeeb32d0	138	178	9806
24056	https://transaction.ru581d47d6fc04f66ffcbb8bbf0ef98b3e	36	176	9806
24057	https://transaction.ru1292e5b9689d1e616e2034b44e1e701a	206	138	9806
24058	https://transaction.rubeb3c62d94e8b04602cf23d97f82e449	2	140	9806
24059	https://transaction.ruf94696d87cb5bb799bc01d610f88af44	136	265	9806
24060	https://transaction.ru522eee65c4838eb8569649790d8b0cd1	234	210	9806
24061	https://transaction.ru2110e8b06e7482590f1d75f6f42f6579	71	269	9806
24062	https://transaction.rue41e939eddf201ba4afd0f89813951fb	20	214	9806
24063	https://transaction.ruf4ee86383be862bd2e5f71c62135dd44	156	212	9806
24064	https://transaction.ru4dae657921f9ad75e7bf21204ef77862	176	213	9807
24065	https://transaction.ru57732194dd1ff604034818efa5a9c2e7	202	214	9807
24066	https://transaction.ru39b414a3849351c2d993e5c7badc924b	277	210	9807
24067	https://transaction.ru4955f2fd694bfb6e5d178fe9092408d0	97	261	9807
24068	https://transaction.ru1860718f9506cf6ad7f5790bcaa25061	85	267	9807
24069	https://transaction.ru245adf1f35c6991b6ec10a9e4efaadff	263	139	9807
24070	https://transaction.ru2456f25c9d1fb6aa87d4602a819a0e27	286	176	9807
24071	https://transaction.rucbd50b8d57e93b522e55b9e08eea5eaf	105	178	9808
24072	https://transaction.ru3f1618e4bf7ef357bd51d8206465ff3e	198	177	9808
24073	https://transaction.ru365814d9c311d7fb0b0b7c45b8a5dad8	124	264	9808
24074	https://transaction.rub388f4015107b6987198fb2b63112a65	116	213	9808
24075	https://transaction.ru8d1257af699b1ea2049c891e200aab46	77	212	9808
24076	https://transaction.rud33947f3918283abac0732d8cc67e875	155	262	9808
24077	https://transaction.rubeba1e4711e4abea205908d680e801f3	33	271	9808
24078	https://transaction.rua665c9a0b802c8331153cddbd750c17b	9	213	9809
24079	https://transaction.ru296dceab3649d27d52c83c03a234a453	142	176	9809
24080	https://transaction.ruc6697a6496dd1bc428e00bec7f0e650d	96	177	9809
24081	https://transaction.ruaf07bfdec2edc7b6ed30598c6bb33a4d	31	136	9809
24082	https://transaction.rue43388c382627f3b2d319176e82701ca	103	266	9809
24083	https://transaction.ruc52cc8a6af794144a6de44a332b76f33	192	267	9809
24084	https://transaction.ru393184c7d182ce39e11713f929e115cc	10	261	9809
24085	https://transaction.rue29e030ade17028f91139f36f21afb29	127	138	9810
24086	https://transaction.rudfa2e77eca59b011dd1d5305413a16cc	182	136	9810
24087	https://transaction.rubb9faf9a1b065490519786aa3e095903	226	177	9810
24088	https://transaction.ru878d0a37c164dd17674790dee7001b60	279	270	9810
24089	https://transaction.ru7ff65b523d136691c1093abb73a42e68	52	214	9810
24090	https://transaction.ru3332778481e1c05833b953ffedd1b054	110	211	9810
24091	https://transaction.ruc8f184f2859193aaff6e888e929433ab	140	210	9811
24092	https://transaction.ruc08900a0a67df97c4ba781663b836763	257	213	9811
24093	https://transaction.ru7f1a9c7130571b909dfe7af290056a5d	189	270	9811
24094	https://transaction.ru4140e459d7a19475f6547eb0f618202c	280	176	9811
24095	https://transaction.ru5a5a0c51835acbba27b48cdf23f1cdef	256	177	9812
24096	https://transaction.ru4a53ff96ca7a7cd2c233d79397fc18b1	131	176	9812
24097	https://transaction.ruf4566cdc041a0a5bc4f9c332840caa0c	72	175	9812
24098	https://transaction.ru35cdf0f176a45003ec27d7ab818646be	64	271	9812
24099	https://transaction.ru0c89b1f004c70f0b7036cc7a1de9014f	262	269	9812
24100	https://transaction.ru024a41e3d01760f5798cadb34afca96a	74	261	9812
24101	https://transaction.ru55b574651fcae74b0a9f1cf9c8d7c93a	277	212	9812
24102	https://transaction.ru168be2e4655b8c7201d2bc6ab211214d	151	210	9812
24103	https://transaction.rucacac6459bd7cf4a241f63661006036f	95	211	9812
24104	https://transaction.rudd5080f555e344fd1ac1a8d816b8a366	56	210	9813
24105	https://transaction.ru8c138cde18189e94b3651bf4fd18977d	258	211	9813
24106	https://transaction.rua2f325757544f0a4da53c04b939239cb	151	213	9813
24107	https://transaction.ru6506c199dc47de0f46109226f281275b	252	175	9813
24108	https://transaction.rueecd9e2b1e514d40d48a48ff45cd7b72	135	140	9813
24109	https://transaction.ru6135cf0b0db9f063460e383374cf933e	197	270	9813
24110	https://transaction.ru0d86871e55597b56bcc2b076a6122e0b	137	264	9813
24111	https://transaction.rua2fe4d276d8e1ff1ddc2adc473a653ce	263	139	9814
24112	https://transaction.ru4528e7c223f39e11405a30e18cbdc1d1	130	177	9814
24113	https://transaction.ru2af7ac10b0b96eb5757defbb65e21b99	57	178	9814
24114	https://transaction.ru5d1758c30e51415637ca25c0ce1e1c5a	153	136	9814
24115	https://transaction.ruf64adcce265eba939eaf758116a5194e	252	138	9814
24116	https://transaction.ru6009b2256313dc5e7363baba7911f683	246	261	9814
24117	https://transaction.ru80c25414589c79707dad6e780dee654d	208	136	9815
24118	https://transaction.rue760ebd193aaec6c0d4acb9c22275277	301	140	9815
24119	https://transaction.ruc211e971801cfa4a7e91f91f92f2ba02	193	177	9815
24120	https://transaction.ru356e011e17768b0c33f4c5150718ec5c	278	211	9815
24121	https://transaction.rua4bc4f2ca738fc2d5377a713c2ea5cec	7	210	9815
24122	https://transaction.ru5002f7b218e5b854d5dedb63ae7ab220	256	210	9816
24123	https://transaction.ru1d040b208847c931fe05714e600af4f0	57	176	9816
24124	https://transaction.rubff047be82ee9c60f7bd09c7c86799b4	26	138	9816
24125	https://transaction.rufa1f1583ace6520b75b956405a62f014	228	262	9816
24126	https://transaction.rudf37f514bb79d8b01471bcaa79fe6745	27	214	9816
24127	https://transaction.ruaa722ac3f1a04f07c2088819c734f85b	277	214	9817
24128	https://transaction.ruc2f0ffc98e55292653a6a2ff1ed3b06e	122	176	9817
24129	https://transaction.ru148d146af1bbe17b119cf1e6e19b318d	64	265	9817
24130	https://transaction.ru91b9bc44382d78572b4756831dad75a8	212	270	9817
24131	https://transaction.ruc8978d6213bc5eace917bbfbb220cae7	288	178	9818
24132	https://transaction.ru861771f24543eab4b20bd2e057a44c39	149	140	9818
24133	https://transaction.ru3c5cc8ad3418cb975099770ebcad747b	166	211	9818
24134	https://transaction.rub0aa7dd42cb2dc6100d002d54d344fb0	226	210	9818
24135	https://transaction.ru56e53b8e61edffc43c79f747ceecb90f	56	264	9818
24136	https://transaction.ru81e9b7d4e94b62a86be54150e19fd72b	11	267	9819
24137	https://transaction.ru7be1b2c3efde654f5b8acd7cae396650	13	265	9819
24138	https://transaction.ru1a0aade1d17b4f80422f6231dca125c6	209	140	9819
24139	https://transaction.ru958d90646399df9729c847074131b85f	11	138	9819
24140	https://transaction.ru403041ed3e1ce9a772502749384235f2	8	174	9819
24141	https://transaction.ru974201b98e4174357a4c56b9d3dbe43c	278	175	9819
24142	https://transaction.rudfe88f60e511e7f546927caf469fbcd3	247	272	9819
24143	https://transaction.ru1a9063fb39efe43a8d0c153812d072f3	72	271	9819
24144	https://transaction.ru8d34201a5b85900908db6cae92723617	202	214	9819
24145	https://transaction.ru89939cc97d7f6e1a7ed508e592ba544a	140	213	9819
24146	https://transaction.ru65d6e6d1f209525f1455ea215b32c380	245	262	9819
24147	https://transaction.ru9e9fda3f17fcd9ac169a4bc60bc59ee7	163	211	9819
24148	https://transaction.ru8d71cf7f906556fe8580772a21814762	144	211	9820
24149	https://transaction.ruba8aa0d530f3e9fe35d0d6850b32feff	21	212	9820
24150	https://transaction.ru939fcb9d27a84812d4c281cab648cb50	253	265	9820
24151	https://transaction.ru685a0bcda5ff0af8b1bf228ed4a52f22	79	271	9820
24152	https://transaction.ru9c184120aa403f5e5228d62d20acceee	279	139	9820
24153	https://transaction.ru03a3e66b10ea88daaeed3e9cf27a61e3	275	176	9820
24154	https://transaction.rub226bd08f412012a62e8a5897d9100c7	179	262	9820
24155	https://transaction.ru5bd88b4fa191fafb45d7f03b58ec69aa	278	261	9820
24156	https://transaction.rub6597b9f616c71b1e39215a654d654ed	116	213	9821
24157	https://transaction.ruf536c8bd94fdd9ce73262d2e842e4a41	168	214	9821
24158	https://transaction.ru614dd68d39916419abec3b749fb33398	61	178	9821
24159	https://transaction.ru7d9a0fd812b7f034ac52ad83523a5d1d	146	177	9821
24160	https://transaction.rudb9312bfb9614790588e158d83e93bdb	54	136	9822
24161	https://transaction.ruc08f13adeae2464c3836cb91c6db3320	219	266	9822
24162	https://transaction.ruc6546a6e2e204d831d6dccf56270bbec	182	266	9823
24163	https://transaction.ru0fa75580bc6e41974e429daacb59ad29	59	265	9823
24164	https://transaction.rud0fa3baf616c90fbf7c16b9615cbdc30	277	174	9823
24165	https://transaction.ru4df489c1698d281e78944cdc86449863	68	175	9823
24166	https://transaction.rub5e0add6635ab67ebbce309786cb4970	69	140	9823
24167	https://transaction.ru0c74884e550248e9d71fd895111d9d87	137	176	9824
24168	https://transaction.rud7fccae416f3c1b2c89e2bc07f401bec	232	272	9824
24169	https://transaction.ru794bfd4d548f208098ca3de5c8e5925e	119	272	9825
24170	https://transaction.ru6af651ab06f704369ac1222e37659810	191	269	9825
24171	https://transaction.ru9d4bedea62420265af8f20305f655546	293	271	9825
24172	https://transaction.ru97375f390cfd8d9b47fe7e3384c5f525	257	136	9825
24173	https://transaction.ru9f3058b5c92b5a7d0addb415aacd3412	185	174	9825
24174	https://transaction.ru1ac9360c74102de3badf01048b1dc47a	273	138	9826
24175	https://transaction.rue77c4b37e306f74ab9b7457d893a96a2	272	136	9826
24176	https://transaction.ru69b764ef15e0bbb3342b156de1d9aceb	174	272	9826
24177	https://transaction.ru9b43b208f852d08fa32bff4a5f0e81a3	65	266	9826
24178	https://transaction.ru7f2b82eb3e87ca505b6da1df9609d05d	71	267	9826
24179	https://transaction.ru527a0c92175bef1410e351da8faa569a	146	214	9826
24180	https://transaction.ru8fd67f6517ba75e90f1491c11b758a77	60	212	9826
24181	https://transaction.ru095822bbc9ea91bdc2a2e5b6c0b50977	21	270	9827
24182	https://transaction.rubdca24c3986b93b4155fc2cec038cdae	241	211	9827
24183	https://transaction.ru60e773a67f3a5c4e788a8a109d44ad5a	180	136	9827
24184	https://transaction.ru2b612c4aa55cd85fc94186224b78f734	55	174	9827
24185	https://transaction.ru71a50fa689a8050328706b1f9bc54c43	239	175	9827
24186	https://transaction.ru4dd650a88eeed2c86c758ffe6ea3ea99	264	139	9827
24187	https://transaction.ru921823bee0baaa89751c970c605c3555	171	265	9827
24188	https://transaction.rue1ef8f527604b4f88be1294ca11c2b9c	292	210	9828
24189	https://transaction.ru067fb49b312287a8b0d75dfca5989f90	292	214	9828
24190	https://transaction.rue5c862e53ae8506d14003d6f9ad9e95a	124	212	9828
24191	https://transaction.ru308c647c0068d3d19bb3733eda1b17f3	109	270	9828
24192	https://transaction.ruc642b39ec817bae41827bf23a880bfbd	277	271	9828
24193	https://transaction.ru11df21b57f71afd38581e0fe37c6a971	138	269	9828
24194	https://transaction.ru3b3c9d9d9b5385e4d22e764e2b5a4c4b	8	263	9828
24195	https://transaction.ru097219a8debd09cb7c99428372e95cdf	227	262	9828
24196	https://transaction.ru9bc222d6e979f2299d45175876f1c016	51	137	9828
24197	https://transaction.ru71fc38002adbeb202480cdd3fdd0c880	224	136	9828
24198	https://transaction.ru739fda5714329ba3745bedba92b8a397	214	138	9829
24199	https://transaction.ru827a1fd7a77a96b4c3a3cd36b431f878	37	178	9829
24200	https://transaction.rudc8350d694b7530c341709079e69ad89	40	177	9829
24201	https://transaction.rua5ffae8ce4b1e79ffa832192abf4c8d9	175	175	9829
24202	https://transaction.ru624b5ead5708c4bb9d1fa1fc711025a2	82	272	9829
24203	https://transaction.ruc7a69088ec39611dd075cc85b70f032f	239	270	9829
24204	https://transaction.ru92bbb6e070bd945ac8178de8f7ac220e	258	266	9829
24205	https://transaction.ru2ba5f86a7a186f7c6512e0fc5a87e62f	233	213	9829
24206	https://transaction.ru94f014869602ce358f36c24570cf328c	143	212	9829
24207	https://transaction.ru90c887a9ccdb85e4833157a04a66e562	38	262	9829
24208	https://transaction.ru0f6be2aadd7f623c6571caacba4a3d70	101	263	9830
24209	https://transaction.ru926610c1bc4f924c1e38b96009a61e28	27	265	9830
24210	https://transaction.ru11b465eaf4a22936bb9ab2ce39324e45	174	139	9830
24211	https://transaction.ru76ff8f6d40bfbf5eb44f0390d37e69b7	95	269	9830
24212	https://transaction.ru5cbdbc741c95ff5b0f06c111198fc7db	129	272	9830
24213	https://transaction.ru1e500fb0c78a4ce7b62de1841251e25f	197	212	9830
24214	https://transaction.ru18532f046f03fcf17351902096a5f907	16	213	9830
24215	https://transaction.ru56bf59e1123167b1807f54647f062f59	101	136	9831
24216	https://transaction.rud680485ba7c028d78154156dca946c5a	117	137	9831
24217	https://transaction.ru730fafc0ba2462fc111dab3c0ce4daf0	149	263	9831
24218	https://transaction.ru33e048a6719c68f4c543408511dd7092	97	261	9831
24219	https://transaction.ru3779d535a96a2e721a8e1ba97f90ff50	19	264	9831
24220	https://transaction.ru750ea34a95ba5370ae5036bcf95c9e10	114	261	9832
24221	https://transaction.rub24e07f5738298013345a0f6feb92fa7	168	263	9832
24222	https://transaction.ru1180777060691d7c9eacb7b97f6c86e5	45	214	9832
24223	https://transaction.ru707f15a3a626c98428247c365adce433	278	174	9832
24224	https://transaction.rub2cade9fa2438300660a5f15239f0d7a	173	178	9832
24225	https://transaction.rua4be190fe87da4660188dd93f26b15f4	19	176	9832
24226	https://transaction.rudd1c820b9d389feebabbe80133a8bac9	248	271	9832
24227	https://transaction.ru97e847db589607a465fcf66d96b3a612	66	272	9832
24228	https://transaction.ruec2fcfa4249c02b88d0cf15ccf9caf95	7	269	9833
24229	https://transaction.rue819d98e4b21b8adf484197155dc82d9	89	213	9833
24230	https://transaction.ruc9aabf40d8f0b0c8a39fc4b35ddb0ff7	59	214	9833
24231	https://transaction.ru2682a6538b60079a79991be711d07c8b	227	267	9833
24232	https://transaction.ru85517436af61ca8dce4c680445b44003	83	262	9833
24233	https://transaction.ru0fd647fd782d2c6c3f144a3537918b2b	25	176	9833
24234	https://transaction.ru638bcacb723d9aa2d54a07ff398f2bb5	239	178	9833
24235	https://transaction.rue734a339258d7d261e6581825ed5ac2f	119	139	9833
24236	https://transaction.ru9f50f455d0f696d840939e9e8acd8524	171	174	9833
24237	https://transaction.ru1529b69136d9bb132506c19f94dd51d5	72	136	9833
24238	https://transaction.rubf36be3e4e0e38f77f7521451f12798b	228	176	9834
24239	https://transaction.ru1047507184a995496a8f12f9e8a90e97	274	265	9834
24240	https://transaction.ru0bb5a6a103bf8df367ac779c49a13543	253	212	9834
24241	https://transaction.rua86222a028240bbf0e21786883c6c58a	263	211	9834
24242	https://transaction.rue2c6a666c2e9319dd069a09cfd64fee7	42	210	9834
24243	https://transaction.ruc62f4ba179ca667e0eee661bafa0823e	208	262	9834
24244	https://transaction.rua43a123c36298332d386c9b2b3907617	219	213	9835
24245	https://transaction.ru10d6e247fcc75cdc935eea529fdceb39	41	265	9835
24246	https://transaction.ru9f56b0fe66a9cb8bb4f66e6bb9044206	269	178	9835
24247	https://transaction.ru9c44e71fdfdfd920d70896bf13ae5072	227	138	9835
24248	https://transaction.rud1ed62d3acf97bfcae707aef8ada5f44	75	136	9835
24249	https://transaction.ruf3948e90a9360e14207f719bd11ac325	173	136	9836
24250	https://transaction.ru5809f29a20622f378106f12c337b843a	105	138	9836
24251	https://transaction.ru615db293c5814278a7bc8d06fae33ac6	68	176	9836
24252	https://transaction.rud863d5ec458b0dc3b46cba96d9d49ac3	220	265	9836
24253	https://transaction.ru35d48c2b234acc687498585ac2e76165	189	176	9837
24254	https://transaction.ru092111cc2ff717593489583f6321326b	218	271	9837
24255	https://transaction.ru09d4264fa1c4fd3cc01c6abfcd2de9a7	54	272	9837
24256	https://transaction.ruc00b1031295a24ebcde93ece083df6d0	50	212	9837
24257	https://transaction.ruae33f505ff86e69972eac820274a60c0	173	211	9837
24258	https://transaction.ru84404bf0b73a6aa7d14fc5a3e8824c57	23	210	9838
24259	https://transaction.rua26dbde10a8c1c957fdf1c9608c4e977	252	271	9838
24260	https://transaction.ru96e0106daa2e129cd76fc35f57b06a15	163	264	9838
24261	https://transaction.ru125a45a5b6f92225bc9ab9e6568647fc	34	267	9838
24262	https://transaction.ru63b8e21255124577f16b9fef197b5cb9	301	265	9838
24263	https://transaction.ru4b440313d7f8dfa0629155da8af59613	223	178	9838
24264	https://transaction.ru27d67e368efd1f876c16d548345ab047	220	137	9838
24265	https://transaction.ruda94c9204075122d59a8da9abde03ae8	132	174	9838
24266	https://transaction.ru684759829ef4cc467d767855841f67f6	19	178	9839
24267	https://transaction.ru6fcd632d278babceca01666c91bb0a2b	139	177	9839
24268	https://transaction.ru96a52a5e104c275aeece0a5593906a14	259	137	9839
24269	https://transaction.ruca84e5c4b3170ac70298a3a1ba214e8b	185	140	9839
24270	https://transaction.ru7aab6f0c04f1699ad01238f608a7a4b6	159	139	9839
24271	https://transaction.rud0d18953b98a0fe80260272f90a8de46	19	211	9839
24272	https://transaction.rube52c754ceaeb847ce00dee251c723e5	282	262	9839
24273	https://transaction.ru49f7dcdfd343ce13d25afa15573cbec5	56	214	9839
24274	https://transaction.ru73ae5ae5f8e0080a039cbb9c8af45736	127	213	9839
24275	https://transaction.ruf0cc3fa9594a444ed8ff3da98e4b938b	237	214	9840
24276	https://transaction.rud87b0465869bf8a64f542cb0afd3dd51	221	140	9840
24277	https://transaction.ru5e2ecfaa862552c8ca51d6f4655ce1d3	196	136	9840
24278	https://transaction.ru496680b052462468f519660932f81b0d	291	177	9840
24279	https://transaction.rua910a024e62592d33e338f884b801b5a	245	271	9840
24280	https://transaction.ruba316490b47d713dbdc1159caa6df45f	225	177	9841
24281	https://transaction.ru0f5db75a90ef37cbbfe46104e1a839c7	209	137	9841
24282	https://transaction.ru0b4b24bad3d47a0da742930e4fa41c12	157	139	9841
24283	https://transaction.rudd39b21327e0d1ec9db7804c880dfaf7	88	266	9841
24284	https://transaction.ruac9c2530a48aa86e6b2c47f196da7e2d	233	211	9841
24285	https://transaction.rua8e198a457b44f7f2b5fbd12225616b9	132	174	9842
24286	https://transaction.ruc521a5becb750bb01928e97f4e5ccd29	231	137	9842
24287	https://transaction.ruff8dee2afb89cd326c05c6f14ada7b27	300	261	9842
24288	https://transaction.ru4c3f567af5cc96fa6f80cb6d1d1ca2d0	47	263	9842
24289	https://transaction.ru2a1b2179f709dc95fb4d819a8f3eb80d	89	262	9842
24290	https://transaction.ru4767b751259fdb332d33318973a95584	132	210	9843
24291	https://transaction.ru131c0d4b4d3bdfe336d27cf998757394	58	265	9843
24292	https://transaction.ru9db3ff97d282c177b1d6622186b43819	10	137	9843
24293	https://transaction.ru1582b40c34f6a2ea0ec28136f9d25952	58	136	9843
24294	https://transaction.ru1f50d5b201dbeff9a4d6b3e09efde106	17	178	9843
24295	https://transaction.ru7430b7ddf990c31c81469f788b692010	8	176	9843
24296	https://transaction.rubd498e8e658a307bcd6f7a6897f6df14	300	176	9844
24297	https://transaction.ru85ffb08f91a83b6566467b942828a560	66	139	9844
24298	https://transaction.ru757d04921ff024de153f3c7f345c24f0	242	174	9844
24299	https://transaction.ru01f8c6ec14e733b56e9383262df197db	167	210	9844
24300	https://transaction.ru901114c445ab8c623cafb4eeb2d00c1a	59	272	9844
24301	https://transaction.ru1dd1a69e09e8e9420956e2176984a2de	84	213	9844
24302	https://transaction.ru4b6bf28fc43a052516de2571589ccb95	274	272	9845
24303	https://transaction.ru62586ca388f16e0f0cfd4d3eb975b07f	168	264	9845
24304	https://transaction.rub77f7fe069f025c4f58d85023dd75e3c	203	266	9845
24305	https://transaction.ru234833147b97bb6aed53a8f4f1c7a7d8	208	264	9846
24306	https://transaction.ru5b85ee48a8aa4e3d7930ba8db2c0ede8	17	214	9846
24307	https://transaction.rue1d20600c16f06a8ab0ada6ff0ec50fb	113	212	9846
24308	https://transaction.ru97513ed75d4ee0b49977540cc28adeea	48	175	9846
24309	https://transaction.ru2adca5809de4fff538de42cace4ee7d6	72	176	9846
24310	https://transaction.ru07d8124ba110a5ed11260cdac4fa2022	130	138	9846
24311	https://transaction.ru3f5bc737ea837398eecdc038d68852b5	59	210	9846
24312	https://transaction.ruc000fce72894aa41f39dcad0313ceb0a	77	261	9846
24313	https://transaction.rudb9b1ced1636d2d8612c3f5e9b7cb939	88	263	9846
24314	https://transaction.rua601a4c700484b25b71d4c50712558fa	193	261	9847
24315	https://transaction.ru2fb9374ea385d281ab80bed962c4df29	148	265	9847
24316	https://transaction.rud79ac2392145ba85a2890c1834f18558	265	137	9847
24317	https://transaction.rua47ee274be38348ddb5a30769497147b	231	174	9847
24318	https://transaction.ru9ae8a8f33c6dad6142d4e4c630c2338b	6	177	9847
24319	https://transaction.ru7db5a0f43662d231e611ca187ded6b3b	122	176	9847
24320	https://transaction.rubd6d8277a198359674cea810a4703369	272	269	9847
24321	https://transaction.rud94e6cd8cf7e612bd8fd4096156eab2f	208	269	9848
24322	https://transaction.ru1fd2c5b00a936929698d38e0f7263a65	109	211	9848
24323	https://transaction.rud667fea4ec12c16ab47be52af17637fa	44	136	9848
24324	https://transaction.ru3b011552430115b27c70ed2d44e8af40	249	138	9849
24325	https://transaction.ru2eda0993db9bf94c2465aae9632da313	222	136	9849
24326	https://transaction.rue77716f701452b971d0fc9c4bddcc23d	104	178	9849
24327	https://transaction.rue3b4798f91ffd9cdf65299727167e854	80	174	9849
24328	https://transaction.ru78ee4e45b5a5a3ea5862fdbbd7f0f33c	180	272	9849
24329	https://transaction.ru7c9c91549db01dade28af2b8d897536a	241	265	9849
24330	https://transaction.ruf98ee9230052795d407669b8adc567a2	268	212	9849
24331	https://transaction.ru5c2e5e557351439b750759375af71495	99	213	9849
24332	https://transaction.ru86d8ed5762fce07b901d7cb112d461e2	109	210	9849
24333	https://transaction.ru14553eed6ae802daf3f8e8c10b1961f0	119	264	9850
24334	https://transaction.ruc7e26a64f3f245e38ed660b842727843	268	175	9850
24335	https://transaction.ru4c8f39546695c1e1608256e804e804b8	229	270	9850
24336	https://transaction.ruc7988ba09e705778d960d818f2fac424	269	272	9850
24337	https://transaction.ru863def6f4c3cc895f2dc94eb7308e38c	170	263	9850
24338	https://transaction.ru51df5c7a7442fd0df7c21af1c692328b	135	212	9850
24339	https://transaction.ru2d2eb04bbce2f2c040e07cd283a7571c	93	270	9851
24340	https://transaction.rub55d2194f81e062c42da6deba1c48295	23	176	9851
24341	https://transaction.rub8ec097008139b2e6a9a597d640a50f5	294	265	9851
24342	https://transaction.ru131d590594f89e5fef852bb0e04d7e41	163	261	9851
24343	https://transaction.ru13953d28c56c431012b22c97db84ec88	79	138	9852
24344	https://transaction.ru77a4e2b46279eab97c08db960a9c8cc1	227	174	9852
24345	https://transaction.ru6119e2e8016c2a7a288eb3884b4ce03b	111	175	9852
24346	https://transaction.ru1dc7f3464a4839e6009992502eabb7a1	10	214	9852
24347	https://transaction.ru5b66853512aa97f406ab93972c2a9e24	217	266	9852
24348	https://transaction.rue3eb2d514b333574a8b25898a2577f73	139	267	9852
24349	https://transaction.ru3cf211a877aac68ddc5a0629a714c80d	196	176	9853
24350	https://transaction.rud3727cb37aec87f4303de5bbd58580c5	132	271	9853
24351	https://transaction.ru40d8ea24a9ebb38c541e6d83b7623c8b	98	214	9853
24352	https://transaction.ru6f05fb18bfe9a5c6e23d1a882390434e	98	178	9854
24353	https://transaction.rua0842bef88e1fec3484c64fc38c87319	147	175	9854
24354	https://transaction.ru4f66177e329526d9451f2103b2a6a413	258	137	9854
24355	https://transaction.ru045bf3aeeb94352ce0cc120e9baa6501	89	138	9854
24356	https://transaction.ru31c4bf4323ee12bb8a9feaeda55b2590	164	211	9854
24357	https://transaction.ru76eb96b334c74fd72f0128c1c760d8c2	217	262	9854
24358	https://transaction.ruec2058856f2e5ce62bc02567b9339b7e	52	211	9855
24359	https://transaction.ru0ec8f30c6d6508ce1d90d5305044d683	215	138	9855
24360	https://transaction.ruc4909a5ca0ffaa3ffe4c00b0d1e10ac4	15	137	9855
24361	https://transaction.ru0bbf15ddfb7e47a5c6fc762ec9872dc9	245	178	9855
24362	https://transaction.ru604561ef4fbf661fe27fc4bc9f7baa88	164	177	9855
24363	https://transaction.ruc1e67054932d2e6187bcd162560381f1	25	175	9855
24364	https://transaction.ruf77aac381faab028672ee9bdf4d98fa6	54	139	9855
24365	https://transaction.ru05d3e1700c798603acc05efa08868c4a	233	140	9855
24366	https://transaction.rud1ad1d5eaafa1e87ecb9efb86120f313	290	266	9855
24367	https://transaction.ru39bacbdef69e76eab49827c267a5b9d2	86	269	9855
24368	https://transaction.ru93c5a8c2b89026c6d7ee354503432ad7	262	271	9855
24369	https://transaction.ru891f042178c5d6c0c760d27a59b66531	103	271	9856
24370	https://transaction.ru325fbf06fb683ed397a21285629d37f1	276	137	9856
24371	https://transaction.ru4357c8f22b269c8ac9c9fb45f413efd2	159	174	9856
24372	https://transaction.rua45016c0dadd9a58319ad7c345e19fc9	222	213	9856
24373	https://transaction.rufb9c1da726c975386088b7bae92677e0	299	263	9856
24374	https://transaction.rud45876a9f32b7b0403ab64ded43225e5	3	264	9856
24375	https://transaction.ru76495da1fc7e916bd723714961ddab93	300	264	9857
24376	https://transaction.rubc9f473f97e06f2c99433d97f4b33cd3	215	272	9857
24377	https://transaction.rud268d4936042c69de0a6569d355f6526	25	175	9857
24378	https://transaction.ru6d5de998a5b2fd1106a685cca6f95626	132	139	9857
24379	https://transaction.ru3c0689cc25c9e8df7a5943e8c40a9725	193	137	9857
24380	https://transaction.ru9e9509d25e33502447b2409429434e8c	112	178	9857
24381	https://transaction.ru4c49062ffa0dd8b3af03f0c19c234a9e	155	178	9858
24382	https://transaction.ruc8b7c02a30789206f27428f8a1ed7330	301	177	9858
24383	https://transaction.ru348e3607ef181902f05ab6d0f58e2166	285	176	9858
24384	https://transaction.ru89f3f80570f5bb8ec31f95520e5b2ca5	66	139	9858
24385	https://transaction.ru16828a666dd002577ee7d839ac413134	4	272	9858
24386	https://transaction.ruf175baef7b945baad52ca2109c71e65e	176	269	9858
24387	https://transaction.ru5ae8b55c6c9f63e79747e2a4eb01b4fb	110	270	9858
24388	https://transaction.rub6c521f6f9281c9480df90f9249f1212	209	261	9858
24389	https://transaction.rua29bfc68f0babbfc3e283b85068b17d9	22	263	9859
24390	https://transaction.ru8143d6e8d726c42bfe788d2928199112	128	176	9859
24391	https://transaction.ru6d68005c76bfd42c292b5750015e6778	195	136	9859
24392	https://transaction.ru0dcb5edbebcd89ab3f62dff48a99055f	99	212	9859
24393	https://transaction.ru98febf16837adc55a0280a0f2262cf22	97	214	9860
24394	https://transaction.ru271a1ef3782555977c85c6bd4f698d7c	182	174	9860
24395	https://transaction.ru6aa60d2a8890de71da28c465d46992ad	241	139	9860
24396	https://transaction.ru7a98c9563887d8d1a8ec19829c132a15	34	261	9860
24397	https://transaction.ru09d67b2953940c10533159744caf87aa	300	267	9860
24398	https://transaction.rud8cc78da8e14ba864947cfcd29e17b0f	85	267	9861
24399	https://transaction.ru22f4c86b7bf05b9a299d046e8c66c2b4	130	265	9861
24400	https://transaction.ru1bcbbaa263f444c17a2a1c30abbb4288	297	264	9861
24401	https://transaction.rue1f30837b5bc98a45e61fde0284e0711	21	263	9861
24402	https://transaction.rue7bcde85ce8c1ec08ce4e4430c55165d	201	212	9861
24403	https://transaction.ru9b847388967e8f7987af55f408f819d0	61	214	9861
24404	https://transaction.rud9dffd07014e2061f0b0262ed88e3dc4	6	136	9861
24405	https://transaction.ru2dfec891630397d0e7f88df10e536e27	181	177	9862
24406	https://transaction.ruae3d70f8acb8c1dff362f79f002f62bc	127	212	9862
24407	https://transaction.ru7e2bf41addf592141ba602d0241d878d	81	265	9862
24408	https://transaction.ru34cf71048d7afee28cc9ad221c943af8	24	267	9862
24409	https://transaction.ru256b9b5417a694714ca2a768a6af5487	185	261	9862
24410	https://transaction.ru10886fae4572420e6ed90de2c9ab39ee	83	271	9862
24411	https://transaction.ru07106f89f68e96ad479af822a87c4c3c	258	177	9863
24412	https://transaction.rufe5e83b3ac57c803f1cd30e0106299b8	5	176	9863
24413	https://transaction.ru1e52f423a2f1c7fe3ca0e2b9e010e0c6	94	178	9863
24414	https://transaction.ruff8c704ce4c380bf464c2231d4b4af87	226	178	9864
24415	https://transaction.ru43a55bb9daba99acf89851657cab4d9e	12	269	9864
24416	https://transaction.ru44bb9e10c5440fbd456279b2dadb8db1	49	214	9864
24417	https://transaction.rue21865e70916981c5c4304c975d8bd2c	206	213	9864
24418	https://transaction.ru276ec27ec2bca2f47b50881ce9495392	283	266	9865
24419	https://transaction.ru9baf82afda5f7d560678a1cc313189ba	222	177	9865
24420	https://transaction.ru236f709e30f33b3e009fdde4d2a3fddf	265	178	9865
24421	https://transaction.rudf3bae493e3cf0dd85bc73fc69f9df72	161	140	9865
24422	https://transaction.ruc152d9e6537e138b5409bd9427cdbfe7	64	139	9865
24423	https://transaction.rufec0935bd0640b089188022c15d8fd7f	93	137	9865
24424	https://transaction.ru2a0974a1e69a6582869569f839edf350	56	174	9865
24425	https://transaction.ru5f723239c54d71e48d01a4f43d6030cd	23	175	9865
24426	https://transaction.ru4bf5afd5fc8cf4c0d9cd673620189b7f	261	211	9865
24427	https://transaction.ru730937fd5bac159b4bbe5e2f065bdb6e	167	210	9866
24428	https://transaction.ru3010e8c3ebf777d669cfea3cf3cfb2e9	30	175	9866
24429	https://transaction.ru51683453baf419bf8f889a3c847a772c	74	139	9866
24430	https://transaction.ru8e4e960f86e0fff332108599ef0ef4e7	239	269	9866
24431	https://transaction.ru44cff6d738239294e5b1fdcda8a31da2	266	270	9866
24432	https://transaction.ru12f3f56b39e33618968b17318c322a52	185	271	9866
24433	https://transaction.ru6dacf258d38f4b5f05ff7f53eaa287c3	229	267	9866
24434	https://transaction.ruf3fa6042ca1c10985b486c57a8790d0c	94	264	9866
24435	https://transaction.ruf51197569e111c10b8f769caf065f266	36	261	9866
24436	https://transaction.ru514f042401b7284f380e4dc84cdf07ed	213	263	9867
24437	https://transaction.ru2d31866ab084e2ad763a942210b2acc3	206	178	9867
24438	https://transaction.ru3b247d892477546f83980c789bfb091d	107	177	9867
24439	https://transaction.rue8b508a0b0316d01e9d47495aad4a597	262	175	9867
24440	https://transaction.ru5f2a2c691d440ef63a7a3c32352aa182	259	137	9867
24441	https://transaction.ru2f1e5b6d8302bc90aad02db513175308	129	213	9867
24442	https://transaction.ru1f2e5ddf6b1ad11157245af1a7018dc8	127	214	9867
24443	https://transaction.ru88a74f1c19b5706482de126b504c7f76	240	212	9867
24444	https://transaction.ru02e42c803d647d613501efa93a41643e	55	267	9867
24445	https://transaction.ru205a17fe784f0ce1582922fae67a101c	102	136	9868
24446	https://transaction.ruc09db952151ad9feccc8c0b14464b566	3	138	9868
24447	https://transaction.ru20a1f94e0e45384e8e08872de5a5e545	100	174	9868
24448	https://transaction.ru1380a5397d5bc7801368bc6b03fea735	243	175	9868
24449	https://transaction.ruf4011b7e909e212cb0f888c9539a301a	56	271	9868
24450	https://transaction.ru6b79078635ee384da2c05817fe71db30	207	270	9869
24451	https://transaction.ru7da40ff2a805afdf21de807946db633e	255	272	9869
24452	https://transaction.ru58025eea1760188f039f2c3b039203b1	129	139	9869
24453	https://transaction.ru123784900f612b8bbbea74f5798ae713	79	138	9869
24454	https://transaction.ru8c3dc0d06ed931a3767b77f0a3472a32	30	136	9869
24455	https://transaction.ru5e7921713be72e40d9d9f2efd685142c	151	177	9869
24456	https://transaction.ru5c475a09c3553135966b1807187e0fda	20	264	9869
24457	https://transaction.ruec168422b92aa6cfb5211bda5ebb23cf	123	265	9870
24458	https://transaction.ru95e65a0bf0117b89c92688ceedc0d3ff	50	266	9870
24459	https://transaction.ru9e6abd1d0e86f9cd5ea5648faf9a8486	217	178	9870
24460	https://transaction.ru0b6daa49bb086f2ada183b4e2a05e529	69	177	9870
24461	https://transaction.ru8ee77d1346531ce3960fd63093550d3e	60	176	9870
24462	https://transaction.ru1e817e4c9b38b764a8c6d0f958eae79c	221	139	9870
24463	https://transaction.ruaf87567e6b0bca0388c53627b23c59ec	224	210	9870
24464	https://transaction.ru65719263bbf5589f8f727d38606c1416	23	212	9870
24465	https://transaction.ruf0f21f1ef2c66a9e231185323335f2e8	157	214	9871
24466	https://transaction.ru30c49d4280a073020daeec457464c668	29	266	9871
24467	https://transaction.rud4047eac7232b028a30a03660dbc1117	160	270	9871
24468	https://transaction.ru57943a527e9c2393d0462d96eaeb6be2	77	262	9871
24469	https://transaction.ru8073bd4ed0fe0c330290c58056a2cd5e	17	263	9872
24470	https://transaction.ru00ef068128beae3bc21bc9a6fd9c0aa6	129	271	9872
24471	https://transaction.ru283796907dafeeba7e7921f188f58620	114	272	9872
24472	https://transaction.ru57d161d9814704f8d66bbc4dfcfa7f55	32	140	9872
24473	https://transaction.ru5ad3ee6b87c0184843f6d72078c72944	201	177	9872
24474	https://transaction.ru468251838a4753fe3194f65f554378f2	225	138	9872
24475	https://transaction.rubf5a58236171ff9cd721675dd8774e0d	139	264	9872
24476	https://transaction.ru5452845ecd6bc1c9c3f53d162e3934b8	249	266	9873
24477	https://transaction.ru834059d5bf08501adecf56fc4a92a3c3	272	264	9873
24478	https://transaction.ru6d61876216b2f57d4c9976bfe5503da7	90	265	9873
24479	https://transaction.rue1f84eec7c6093ff55332b9e73c189b1	69	137	9873
24480	https://transaction.ru9381251a7fdc250a2f1632114ba96681	242	136	9873
24481	https://transaction.ru598de65f9fbb49fc1f1cd41c76ee0c60	242	262	9873
24482	https://transaction.ruf62df0a71a3514ca88473beb77d74c55	86	214	9873
24483	https://transaction.ru1500113a62640bda47dfba52f5b1f040	96	210	9873
24484	https://transaction.ruf31157df0634f40a0334f3877dfc4309	215	263	9874
24485	https://transaction.rue5410c077c88e310d472efe79aa3ff66	125	261	9874
24486	https://transaction.ruc79645ccdb29eeb8e1791e6d9db96d2b	66	265	9874
24487	https://transaction.ru11d853bf85f830711e8a3cd774a42361	263	137	9874
24488	https://transaction.ru387b128a605429bd9be84cdbd40b7f12	90	176	9874
24489	https://transaction.ru41f2b6d56f30e60bc1e60c01e677246c	197	140	9874
24490	https://transaction.rua4863738bd87d94b707faa886fc868a2	195	140	9875
24491	https://transaction.ru32c11b5714c9332c8e3ab942f949d1e9	299	176	9875
24492	https://transaction.ru97ebdb10228cdd18d3c56c75bdca89df	25	211	9875
24493	https://transaction.rue4b14160c364fcab323f06d6c912a9eb	258	210	9875
24494	https://transaction.ru1a412f41a07bb24bfcbcc862cd6d9583	38	213	9875
24495	https://transaction.ru303d4c9f002accf52adb3e063fdd7196	281	212	9875
24496	https://transaction.ru396611b4961e670693dbd21d2b6f4e65	60	213	9876
24497	https://transaction.rueccd9f7dc92858b741132fda313130cf	294	176	9876
24498	https://transaction.ru8e95a0ceb2114214e4e89bb5e5374102	191	178	9876
24499	https://transaction.ruab39c7255b0cb66c6fc2be08d7a0da4a	84	174	9876
24500	https://transaction.rucfa5301358b9fcbe7aa45b1ceea088c6	157	136	9876
24501	https://transaction.ru61469647a76323eb8c260d24d70d0b14	13	261	9876
24502	https://transaction.rud6f6b4b6f5524a6b74031e2601a27d53	133	271	9876
24503	https://transaction.ru48d7946db8f2f98b5de6872562caf21d	2	272	9876
24504	https://transaction.rucf5917adca696018c1962e3c6bded197	169	269	9877
24505	https://transaction.ru348fbdd35022b4e24d1bc5c1600c70f7	284	261	9877
24506	https://transaction.ru3c80f81c51150399a3f5e931b620a433	41	263	9877
24507	https://transaction.ruae5008a288130e47441018014f6ed7c9	67	178	9877
24508	https://transaction.rue6a74fe3aaccb2f8fdd0c5e99bd647e3	87	139	9877
24509	https://transaction.rud65b0a929d2c015bbc2fa21e5aad2b86	190	138	9878
24510	https://transaction.rud89ddc708a2274481b8161c52a517ec9	248	178	9878
24511	https://transaction.ru76c8728a28730560980e9dc1bdd91ff4	4	265	9878
24512	https://transaction.ruab1fb53d3b76da2305c34a32d676e9ca	130	266	9878
24513	https://transaction.ruf567f8d5db61d62ef08e811676fd8430	235	213	9878
24514	https://transaction.ru1e902274eb7ff42155acdaf3dac27dbd	45	211	9878
24515	https://transaction.rud2bf6b41ae5ad6afb43d9850d9ed89fb	168	266	9879
24516	https://transaction.ru45e0f0d91eb87a71812d4060b66cd113	32	177	9879
24517	https://transaction.ru4828abc74bfb92dac20fbdb85994571c	55	176	9879
24518	https://transaction.ru84b184211c5d929d9435a371eb505cad	6	136	9879
24519	https://transaction.ru6feb6811cb5d6c1a3cf73857fd088975	116	138	9879
24520	https://transaction.ruc3065fdd901c5b626cc85b79c5c8d0ca	277	270	9879
24521	https://transaction.ru51fac53981b2c43ebe1066404da661ca	151	212	9879
24522	https://transaction.ru14dde6b36cf4c8e4cdfa4531fc407506	75	214	9880
24523	https://transaction.rud8cacad501c78bc6beaa8fe7360eebcc	180	213	9880
24524	https://transaction.ru3a8f2a2454bf90324b239b885d37a213	189	178	9880
24525	https://transaction.ru51b115312728e6e2d33ae2d4be1b7376	231	174	9880
24526	https://transaction.ru9813960d51c2a74d1a4146b88b2cd900	91	262	9880
24527	https://transaction.ru33b5ea07008866d4e8b878d283500c31	224	267	9880
24528	https://transaction.ruce020ab04052fabe43572f38c8d9bb91	60	269	9880
24529	https://transaction.ru1ec5fcfe9bb1352390b9c82beafa8bf8	107	272	9880
24530	https://transaction.ru390730928f96c355842f654a45c81876	171	271	9881
24531	https://transaction.ruc6ade0f97f8e141e4050e65b84ecaf1e	194	139	9881
24532	https://transaction.ru5208181067cc6edd90f6b91ec3bc1e99	15	138	9881
24533	https://transaction.ru26d1325f1302ec5a24fdb09b69b8f6b1	180	265	9881
24534	https://transaction.rua93adcdeca1c6256f291c217c9e47096	157	261	9882
24535	https://transaction.ru67968af79a4fafec766aed5d7043942c	290	137	9882
24536	https://transaction.rudf141a135bf1b105284be9a87800dac2	22	175	9882
24537	https://transaction.ru52320ccf53a21dbbbef433410939f4ad	50	178	9882
24538	https://transaction.ru15443d5850922cacb546c2639c96dd56	22	176	9882
24539	https://transaction.ruc2795499408d0a69d691906b196659ea	225	137	9883
24540	https://transaction.rucc5cd1379c6c1e7a2558fde4dba311bb	24	138	9883
24541	https://transaction.ru499b16d52e8a21f85740dbbb2744cdf0	217	174	9883
24542	https://transaction.ru0a7681bb731845955ee6f86772fcb59c	31	175	9883
24543	https://transaction.ru43457393682c1c6b37f68475b3db7cec	282	213	9883
24544	https://transaction.ruad5ffbb666cfa7988c4ddb1197d3a410	107	269	9883
24545	https://transaction.ru8272619d8e2a3e50054079bee126c43f	164	271	9883
24546	https://transaction.ruda0b74bc350466a16709b35e7782e5bc	168	262	9883
24547	https://transaction.ru4ce5c089f29c4cb7ec42f02fe244bf43	172	263	9884
24548	https://transaction.rua34f7a182e69d69fdfdb65c44b99ca64	51	261	9884
24549	https://transaction.ru4fcb8b69e5991eb8cdab2d26fd9ae9f0	263	212	9884
24550	https://transaction.ru8e5515780ae27bba04b44c94826f4d9c	248	139	9884
24551	https://transaction.rufc08c4d30bd18080031dc84e22821556	36	269	9884
24552	https://transaction.ru5d4b17dba3396c8117845ec545642201	122	270	9885
24553	https://transaction.ru4aea9843ca695798fa661d88e311e58d	275	213	9885
24554	https://transaction.ru0512a32ee6c37c313aa635c7ea809b64	73	211	9885
24555	https://transaction.ru240bafcb74ba2f78b02f578c4989103b	238	140	9885
24556	https://transaction.ru7219c971cfe6a9c3079ba37c19cb00f4	197	139	9885
24557	https://transaction.ruf0a2b57e6e2b15c52032cf6fb8179b67	61	178	9885
24558	https://transaction.ru7a444569f967895d95a13f8716a354f6	38	136	9885
24559	https://transaction.ru6385a7c08391192f73c46946baabf58a	24	138	9886
24560	https://transaction.ru7a35d671d3f3314ba80cc0da662ab703	76	176	9886
24561	https://transaction.ru173d1bbfab0df53e6a077d58c44fea5b	57	177	9886
24562	https://transaction.ru081e76e24d48d67ee7c7e60ddfcf869a	139	178	9886
24563	https://transaction.ru1a509db8e680de2e4fe500e9e590fd0d	24	175	9886
24564	https://transaction.ru5446088d2307e70a3ccce897ba68ffdd	236	174	9886
24565	https://transaction.rud263f6a2d48375b51afce7062f201c2c	107	265	9886
24566	https://transaction.ru4a8d8c6b0ecdcd85298b7515503fffe5	264	269	9886
24567	https://transaction.ruc2760fd9f128ed229d7a29543740ad3a	172	263	9886
24568	https://transaction.ru7d0798435b8b1b25d518c0a0b5679879	200	270	9887
24569	https://transaction.ru3da089542e135608354424726c99956f	143	266	9887
24570	https://transaction.rue4faf4a9dc30c60a91500900fb4e38dc	78	264	9887
24571	https://transaction.ru31c16c91ed552ef4eb9b02b9cadfd5f2	257	267	9887
24572	https://transaction.ruf376d751942dfd829b7be1ff2aedfb0a	12	176	9887
24573	https://transaction.ru3cc99f77ef9d3ff8ba8d259f1ca0253b	60	138	9887
24574	https://transaction.ru796e657775d54106a0276bf0b475aacd	287	211	9887
24575	https://transaction.ru86397d3766f505239702f8f827d1417c	64	213	9888
24576	https://transaction.ru2007cf7f3a1f2cbbc4513eaef0e05b0c	91	270	9888
24577	https://transaction.rub9edde14eeda32ac85582421fe80573f	196	261	9888
24578	https://transaction.ru0f8bf55867eb528b85348a5bb4e37d3b	265	138	9888
24579	https://transaction.rufe6f39edd348629e003a165b11c6c8cc	181	136	9888
24580	https://transaction.ruade08e34f83daf752ff1a9f0d3a38c57	163	139	9888
24581	https://transaction.ru22f7403c3642b7bb644d7b601f5ce9cf	219	176	9888
24582	https://transaction.ru030e61770947a9d2b25cef6be9ba04ef	44	178	9888
24583	https://transaction.ru6738da4075782891c8174784272321fc	267	137	9889
24584	https://transaction.ru65a060816aebed3ba5deaad4c2d5bbb1	124	140	9889
24585	https://transaction.ru6b61d55fe1ab49c86322f90c9e32c70d	253	272	9889
24586	https://transaction.ru2f270f73e3ac578a917a86d39f3c2e59	261	271	9889
24587	https://transaction.rufd3dc48552d822f855b8893d3c7e7b06	94	267	9889
24588	https://transaction.ruf12eacbeff499625fab8e9cfaf872f81	52	213	9889
24589	https://transaction.ru9a7c23b4afb55806a45f8907a1745e22	37	213	9890
24590	https://transaction.ruc5fd71f219d10952c58e02ec1c49ed53	217	267	9890
24591	https://transaction.ru4f1a50c3d4716f7d43f156a27fc713a3	164	140	9890
24592	https://transaction.ru96729ef7540bb7f7e0c0e0ed97489090	297	178	9890
24593	https://transaction.rudcd3f83c96576c0fd437286a1ff6f1f0	24	262	9890
24594	https://transaction.ru97a6838d90d1d77db48c34fcda30f3b0	18	261	9890
24595	https://transaction.ru84f6177ddb0a7a2fa69bbcfbaac7fe70	112	270	9891
24596	https://transaction.ruc80eb23934ed81ca9cec516df5a153d1	244	210	9891
24597	https://transaction.ru7ae3b6e27befaba342db36d838720f6b	2	178	9891
24598	https://transaction.ru3db11d259a9db7fb8965bdf25ec850b9	222	177	9891
24599	https://transaction.ruf38c4a43328cd4ae19648c9a3872b02a	68	139	9891
24600	https://transaction.ru640537014fd714245712c3559909e743	249	138	9891
24601	https://transaction.ru72ebde1219552f85b099b080f0508bd3	57	138	9892
24602	https://transaction.ru138aff98e2437fefc5d145ba82f3a5b4	165	178	9892
24603	https://transaction.ru9dd3511bd3b2e44ed5cf4bdbaf485d60	106	140	9892
24604	https://transaction.ru2c8c0a0ab1c54aec1d750aff4affbbac	273	174	9892
24605	https://transaction.ru597091c7094a27f199fe706caf12ed75	147	214	9892
24606	https://transaction.rucd2abc3b85488b39f9e4fb416d9b4bcb	23	136	9893
24607	https://transaction.ruabdc98a3a432bdcb72ab3a1ce203e879	29	261	9893
24608	https://transaction.ru98352546cdf02dbb71a820d00c950df5	113	262	9894
24609	https://transaction.rube75de3512baf208062b5cfe13803247	257	137	9894
24610	https://transaction.rud605e5c7e76171b84424788a0875b299	14	136	9894
24611	https://transaction.ru730fe6b23d42c8f1c697a0fedc1e8286	197	174	9894
24612	https://transaction.ruf68f2ec1147f93f159208c8232e9527a	95	269	9894
24613	https://transaction.rubf487ca3e186551fbcde6066910c984d	171	272	9894
24614	https://transaction.ru41fbbc33ee9376b64336a6ceb21ec76b	66	139	9895
24615	https://transaction.ru9a4c58b857ff9b62af48ad11a09b3e12	246	262	9895
24616	https://transaction.rudb354bf540d6536b8838db3504a7dd53	275	266	9895
24617	https://transaction.ruf0fe5100dec11731f180e950bab026d6	218	264	9895
24618	https://transaction.rua4712d934b6cbffb0157e0b6b4d5c2cb	299	211	9895
24619	https://transaction.ru1642b665d4b143b9e0d56e457a8dd7e6	222	136	9896
24620	https://transaction.ruf90077ea9b0f23489123ede7de7c8742	34	214	9896
24621	https://transaction.ru0ba52312852e2f08eba168db8b9f121c	226	266	9896
24622	https://transaction.ru3f9c0909871e7cf32a056e74a3bdc943	29	264	9896
24623	https://transaction.ruaf4234e4c76aead5b44be412b6cc0895	97	265	9897
24624	https://transaction.ruc8b1fd35f9681473ea859281be90b3d2	210	140	9897
24625	https://transaction.ru87b45082de7ad88dc18a27a7380b142a	207	174	9897
24626	https://transaction.ru145e94eccee244c35efe54a1088fbf0b	244	270	9897
24627	https://transaction.ru01c324d17fa5f39f5199aee7d18fece7	219	263	9897
24628	https://transaction.ru9063abbb1fdf601ab7084411d7698053	79	262	9898
24629	https://transaction.ru281370889281f2ae0e6989fa14ffb071	190	261	9898
24630	https://transaction.ruf473b43234f8f8b5e3ef53cef5d800a0	255	265	9898
24631	https://transaction.ru38db005cd088239393f1363aae2e36e7	283	138	9898
24632	https://transaction.ru96370eb75a54e1dc6d542e567cac362d	82	140	9898
24633	https://transaction.ru299fd40d3456e0e440e7b313f50f501f	285	177	9898
24634	https://transaction.ruc5b50cc4736464b07091eb5b85243b73	286	210	9898
24635	https://transaction.ru47b87a8f55563826f3cef7af83fa9972	91	213	9898
24636	https://transaction.ru367ba06bc45da934ef9f4c5e459f0be6	85	212	9899
24637	https://transaction.ruf7a757617553bc2df26c782f2de42a97	121	178	9899
24638	https://transaction.ru8385478b5f6e3971728fe1df5a6e70e9	157	175	9899
24639	https://transaction.ru364150ab5f84aeb3a6955d6f5eaa6dcb	178	140	9899
24640	https://transaction.ru50c52bf5f14d2c3e1a81192a8bc4fa0c	206	136	9899
24641	https://transaction.ruaee2a94185e4c1798fa42b3a0459376b	273	269	9899
24642	https://transaction.ruffb6f2dbef68308f56356d33e2b005d0	191	261	9899
24643	https://transaction.rub9ed69defdb4eae4c002b513e4948fd5	16	263	9900
24644	https://transaction.ru5b923571f4e25ee7c81d1525c5b27af8	115	269	9900
24645	https://transaction.ru1aa2858ce9d02f1f8c0fbdbe58cd94d3	22	271	9900
24646	https://transaction.rub09cae78dc6c38609b2e96bb11afe7c8	67	213	9900
24647	https://transaction.ru7b3cc3c724386d020f7532323f682c36	141	212	9900
24648	https://transaction.ru9d0cc167b66fbf6492293a2cebfa2661	59	139	9900
24649	https://transaction.ru056f61a0698b4419fa4a3c36dce776ec	111	140	9900
24650	https://transaction.ru56fd1d238eaa535dda732a2ac9083bde	87	175	9900
24651	https://transaction.ru5dc2970ffebb6690aa584014cb6fa79a	230	267	9900
24652	https://transaction.ru4fbdcd00a4b33ba495f1fb3e45ffd956	133	230	14901
24653	https://transaction.ru075647d73efd90ca8bce86297c93e106	17	259	14901
24654	https://transaction.ru15d8ff7b4fd0ae363dc511a5029e8599	166	154	14902
24655	https://transaction.ru9dc854814eefc811ef7e4b299d3599d4	68	156	14902
24656	https://transaction.ru9f5747e5836fe4dcaf49d464f7c92d58	223	230	14902
24657	https://transaction.ru446867d8ca0100ce82cdc8207434c7c5	120	233	14902
24658	https://transaction.rua0a85bd7641187560d0dbcecef95e38f	300	256	14903
24659	https://transaction.ru57061a9d313bba668cce9cd22965cec7	36	154	14903
24660	https://transaction.rue28355787033ebb4eb3528923a0fbb5c	116	188	14903
24661	https://transaction.ru7e0742327a1011792aef02e8ebe4a28b	152	187	14903
24662	https://transaction.rudd6298e7c9a2c63b6ab43846ddd7ddbe	165	186	14903
24663	https://transaction.rua90044fae6859c2b008e6359ff1671f8	279	186	14904
24664	https://transaction.ruf52754b5c11fe123f234bf1857160003	187	155	14904
24665	https://transaction.ru80073dd54087c4e4efa02e9e18d8c750	170	257	14904
24666	https://transaction.rua4916a29f73fe39395d6c49bc11aef17	15	232	14904
24667	https://transaction.rucae10ca01d19f3a13ba1b831fb09354e	71	229	14904
24668	https://transaction.ru2e5bd953e536cc1d8a9253216d9b38a1	232	231	14905
24669	https://transaction.rua04fc6bbbde5dd778f694be38b9617a4	142	229	14905
24670	https://transaction.ru45eae5dfccfec80f8a97e393cd271fd0	25	256	14905
24671	https://transaction.ruba221f1007ad256868c1c2e8c2194b0c	185	258	14905
24672	https://transaction.rue9e6949faca210537992fcdb73dfc14b	256	188	14905
24673	https://transaction.ru0c26ed91b372264da97470be51b0e13a	195	186	14905
24674	https://transaction.rud967e84c8b555de0ff640460aba2721d	298	152	14905
24675	https://transaction.rueba279cb2b7a1064b6c7d7c8435231d5	109	185	14906
24676	https://transaction.ru581748d5276c24dc0e66e54d9c3d06d3	294	234	14906
24677	https://transaction.ruc1dd046b704051d1df19126ce6115d9e	183	260	14906
24678	https://transaction.ruba2a1b320b3d81a9b8e69134b4ced573	44	259	14906
24679	https://transaction.rue1fe1b02448cfaf55331da135a0b8c0f	48	257	14906
24680	https://transaction.ru9746fea2965d50cfb4079085601b9c9a	172	230	14906
24681	https://transaction.ru3f480e073ebe3f12e5dc55e5a99dc9f0	95	229	14907
24682	https://transaction.ru63cd4f66785cda9c8dc9b75689ed782d	106	155	14907
24683	https://transaction.rudec103bdd9542840ba90bca9408b1c73	187	151	14907
24684	https://transaction.ru47e9e116b0f57e67755afde0fce6e5d3	183	187	14907
24685	https://transaction.ru07d387f250cbc1447fd02676d615ade2	192	186	14907
24686	https://transaction.rue2e18d9106ddc3015e88d573b9e79971	17	260	14907
24687	https://transaction.ru67a68acad0b74cf764dc6cf09d4c600e	71	233	14908
24688	https://transaction.rud31ee4362a691a94519464a33e57d746	5	186	14908
24689	https://transaction.ru8f1fbb64831031e3dac857e2d47a1a97	267	185	14908
24690	https://transaction.ruf2fc717cb1d7916c05d04b8eb6340c2f	279	152	14908
24691	https://transaction.ru2bf53e36c6a9745049ed8a6ff3bfbfc0	206	151	14908
24692	https://transaction.ruc249179af1b1ae1049ed12ff0e11e84c	39	154	14908
24693	https://transaction.ru10e60fa84b4c7c8d1f0c166bd731058a	220	257	14908
24694	https://transaction.rub29bb58d376b9368bd3ccea1f09842be	301	258	14908
24695	https://transaction.rud73267c1e70caa229b6b53055699e686	227	257	14909
24696	https://transaction.ru450fe93978ffaee1694a54641089119c	144	156	14909
24697	https://transaction.rue65c3a56d054685db9e0a21fc617ebcc	51	186	14909
24698	https://transaction.ru073af0e7692af7670bac230ee283ca74	148	151	14909
24699	https://transaction.rua76ac7a567c81e3cace19fb0b9e6582d	277	152	14910
24700	https://transaction.ru58df0d81d2c9ff92adbad1ac7a9b3097	293	154	14910
24701	https://transaction.ru8202ce876a7756dd55f390e82b18c4ae	75	153	14910
24702	https://transaction.ru62913eaa9565ca65fea2ef48c835ba2c	67	185	14910
24703	https://transaction.ru3f529cc2d09d45f6c542935d69da77e4	196	260	14910
24704	https://transaction.ruf7d14370aa1ba7bb2922c3656e0ba63a	288	258	14910
24705	https://transaction.ru3ccca7699c0b844b76dacf27a1077302	198	257	14911
24706	https://transaction.ru55be09e7e47067df4c7a6302fc1787e5	118	156	14911
24707	https://transaction.ruf5b45d17f507bc4b7dc22c3ac4fc25df	232	188	14911
24708	https://transaction.ruf520a40aed089d28c1675cf198d5eee5	27	230	14911
24709	https://transaction.ru70f807c336998a9566a4e0041bec12b7	294	229	14912
24710	https://transaction.ru7f03c939844ed6c9e7dd563f7e6f3423	283	187	14912
24711	https://transaction.rud81c628630ead8eb911a7a8050c1029c	72	156	14912
24712	https://transaction.ru2d3b94603219bb737ef499a120741306	78	153	14912
24713	https://transaction.rue1ac4ee1472a4f78d1fb0f404f74c661	269	155	14912
24714	https://transaction.ru3884ba83f1fa179075f7e127c5d2d3af	284	257	14912
24715	https://transaction.ruf91f6545bd201548e7bbcf3f0eca8511	10	259	14913
24716	https://transaction.ru18e770d6d7d3a383871c98417f02cb35	279	186	14913
24717	https://transaction.ruea35e2c358495e42deba57438d38842d	206	187	14913
24718	https://transaction.ru432d63dae73d2ee2d3f9d5d6b272ffed	227	231	14913
24719	https://transaction.rub79c9fe4a470c7e831b0fd0beb81b379	89	260	14913
24720	https://transaction.ruac57558531e12a5b335d1adce56f2361	6	233	14913
24721	https://transaction.rufe889ef9868cd69081eaa8c5cf47542e	9	189	14914
24722	https://transaction.ru0bf1ace74c80d5a941676918831d37e9	151	187	14914
24723	https://transaction.rucc7b92bea292db540a1643d20fdefaba	42	259	14914
24724	https://transaction.ru38c99dc9731c4e1098d329f9943ab80a	14	260	14914
24725	https://transaction.ru141e4a2dca6e269dd8d7f0e8f3669ae2	17	232	14914
24726	https://transaction.ru7274d3e939e2cecab22a4fa71a80ba3f	215	229	14914
24727	https://transaction.ru8933b4c6ae53f8a3baa36ea352470cd6	154	231	14915
24728	https://transaction.ruc41f59ac111220d4644c94c836421cf7	144	188	14915
24729	https://transaction.ru39aed5745e58da589754617512f6a27f	287	151	14915
24730	https://transaction.ru0f57ecc713c1e86e50a6118dd8912738	126	154	14915
24731	https://transaction.ruffff4411b9813c7eae546b32ce1017b2	69	260	14915
24732	https://transaction.ru52b06563c80917b6e71a360ed08a8a70	23	256	14915
24733	https://transaction.ru351fb54227445e89470df8a294f74fde	118	257	14916
24734	https://transaction.ruf711b4870ad13181acb218f8fd0622f2	293	188	14916
24735	https://transaction.ruac333ef61de0dad4fe665504b298402c	244	187	14916
24736	https://transaction.rude1afd4fba3938e7f7aa555743712de8	79	152	14916
24737	https://transaction.ru40e9cbefc900be5ad3a7f372b8718784	261	185	14916
24738	https://transaction.ruc95194d2a96734ba5051f0cf99f7fc3e	102	151	14917
24739	https://transaction.rue4f13ffe472cb84c019250bd53fa5e9b	136	232	14917
24740	https://transaction.ru3e2d30097eada659b6526e8c85fec70f	95	233	14917
24741	https://transaction.rueb28f503e27cb19253fa2c575d76a422	160	234	14917
24742	https://transaction.rube6b3944229cdbfbe28b2e0f46205268	202	257	14917
24743	https://transaction.ru2ad4ea2752a832345c35edbd267018fb	66	229	14918
24744	https://transaction.ruf31337a1bc9916c490468be37f602cd0	291	230	14918
24745	https://transaction.ru53e6b615a6b574943fe8ea2e32fe9b34	171	151	14918
24746	https://transaction.ru2308917bd96e698b6853b33490bed98e	121	185	14918
24747	https://transaction.rud1d7f61ae73d8ef018993b4c9ae67298	132	189	14918
24748	https://transaction.ru53d03f4b3f6a2b4e8cb76cfff58a546b	134	188	14918
24749	https://transaction.ru0c45a0dbc5a0f7d815d9a78717459162	266	233	14918
24750	https://transaction.rude7b267c6c9cd2cc7ce9d71d2b59cfa0	115	234	14918
24751	https://transaction.ru4542d91c9aecc5b71f67b09852e7b2b0	68	234	14919
24752	https://transaction.ruf53db47f2417e1fb423e590d997884a9	207	258	14919
24753	https://transaction.ru1a3e2655d1848c3b912bccca32c7199d	107	188	14919
24754	https://transaction.ruec719a206500100a493a75c02e4ff2c5	127	187	14920
24755	https://transaction.ru103fa0237ad2299cd0358b66e021679f	230	186	14920
24756	https://transaction.ru83a0e931b6cb156ebe910e07116e42ec	126	154	14920
24757	https://transaction.ru1ae816429e3eb9b80089bd7b60f4a975	23	190	14920
24758	https://transaction.ru00a9daca3a67b784465c11a4a600749b	141	185	14920
24759	https://transaction.ru493f59c668af2d1517a217ecce92df3b	243	152	14920
24760	https://transaction.rucfb8543a953958a2201df00c3bc836d6	206	189	14921
24761	https://transaction.ru32751f52654697daf3d49e70b33d268f	15	190	14921
24762	https://transaction.ru352ca2080bcde5804d445579a23e2be3	106	234	14921
24763	https://transaction.ru7fa5b3757333184e5724ae27e0b734aa	213	230	14921
24764	https://transaction.rua045b876a546bdef9b8745ba04bcc555	3	257	14922
24765	https://transaction.rubf12785d9287e70e2f129f19b3dc325f	260	260	14922
24766	https://transaction.ru636fb08bcb25216517402a7f63a55ba9	41	186	14923
24767	https://transaction.ru56379eac3f78ed890d76028baf75b7c8	118	185	14923
24768	https://transaction.ru5048333c47e88fbf03e87f85779d4267	23	259	14923
24769	https://transaction.ru805d67ac639ebeeeb156fb78d9839243	226	258	14924
24770	https://transaction.ru89148fe8800f34ec77be57ee1c295575	281	256	14924
24771	https://transaction.ru39a63103f36d1280272aedc17b1267cf	245	259	14924
24772	https://transaction.rube8db4ad36dd8641f14712c9aa7317c2	229	260	14924
24773	https://transaction.ru13e3d7507eda818491cb905af887ec9b	199	151	14924
24774	https://transaction.ruf1651783c4bd44c9fc75b2e7adf81511	116	189	14924
24775	https://transaction.rudb2e5fd045cf5709b2305d9d7d1bafdb	10	186	14924
24776	https://transaction.ru5a1d406f604c8b1f0d2c90cb8dd2ead8	150	190	14924
24777	https://transaction.ru1dca84cad9a7652ac87bf2ad9357ceec	99	185	14925
24778	https://transaction.ru17010ec5dfd3d4c2f9772fc18d5cc685	25	188	14925
24779	https://transaction.ru5053f99d12400ffb9eebe6992bf56e82	91	259	14925
24780	https://transaction.rua26b1b5392deb6130be118ad8c7ce9b1	257	258	14925
24781	https://transaction.ru26f2bc38b059e918733f80bf0f890ccf	123	233	14925
24782	https://transaction.ru22efb63da18e9eece08551398df558bc	242	188	14926
24783	https://transaction.ru91b13f81fa52b4074ee1e0f67634f298	222	152	14926
24784	https://transaction.ru9034777ceb4595f5fc68d9f489a75e15	279	260	14926
24785	https://transaction.ru8e63c753046a6f621adc0b300c5360ac	154	259	14927
24786	https://transaction.ruea0c0454920456b79a9c27e26c5f9944	180	153	14927
24787	https://transaction.ru298123aa5d71182df233840db719583e	263	188	14927
24788	https://transaction.ru3d8a7bf0e0715ecb96898b236fea668c	142	230	14927
24789	https://transaction.ru6f3b1f3513ebb868249bdbbc5c0cc23b	67	229	14928
24790	https://transaction.ru638ed28baf8b937661fcf9682fad41c6	151	188	14928
24791	https://transaction.rue9d263317fecea7eb5bce9173339ad0a	187	190	14928
24792	https://transaction.ru86cadb816b3e2df8fc69cb774c4858bf	71	153	14928
24793	https://transaction.rud87e5764cf889782bc8233fe94a1f8c3	142	256	14928
24794	https://transaction.ru87dba06f24cab10a8b17af2c611d9a86	34	257	14928
24795	https://transaction.ruf648329552fcc61e53cf5a48bd40fbc3	124	258	14929
24796	https://transaction.rub664188354b647337679fecbd3f5ac2b	21	153	14929
24797	https://transaction.ruefd428f15b54f993ef0e7c461f831e3a	255	155	14929
24798	https://transaction.rucea171c9be46bc17344e2478cdcd505d	262	187	14929
24799	https://transaction.rubdc46e2c6d40a03d5e2535c9b44ec8bb	199	151	14929
24800	https://transaction.ru7858825720c5c319f455b057941b09c8	48	185	14929
24801	https://transaction.ru9b5cccda2e7df730754dbb4164e1b17a	83	185	14930
24802	https://transaction.ru7a2f199a2530f7e9875e5e39fa57e140	125	156	14930
24803	https://transaction.ru7a70a9fd1f57f0bd70faccd2125ceefe	296	260	14930
24804	https://transaction.ru02567a75a638348f39a76f008167efdd	78	234	14930
24805	https://transaction.ru50ea484264f4deb14034a8a2563454c4	116	259	14930
24806	https://transaction.ru839573529f0543e9466b3d4897026b63	227	257	14930
24807	https://transaction.ru2ae099e72bd2a9b0dd9b67188cda4961	44	229	14930
24808	https://transaction.ru098b0c3fd82c1e87eeaca414aa8777ea	211	232	14931
24809	https://transaction.ru4dc5dc7fbff01369ca295ad0357cb267	273	230	14931
24810	https://transaction.rudaa89081e4df30077766dff36e646157	43	154	14931
24811	https://transaction.rue1c32d66a72db9e2608a215dc2293933	195	153	14931
24812	https://transaction.ru32529da4974961ed8d02f5489f9cdbb4	12	189	14931
24813	https://transaction.ru8003c8cdbcb8ca55652d4b2c5569d748	232	256	14931
24814	https://transaction.rufa8323d910736f5aeb823a1ba7e8fd3c	27	257	14931
24815	https://transaction.rude6a1bfab37523a2e9668dfc6e9cdea7	249	256	14932
24816	https://transaction.ru16b5e4303140cbd2e7a373b400712c5c	46	231	14932
24817	https://transaction.ru446b93d045c28cbb643d7699ffeeeeab	277	230	14932
24818	https://transaction.ru2f443ec228df7a6ceff7a76ad4826205	201	232	14932
24819	https://transaction.ru87776bb11934472910c19b29fdd38e83	40	260	14932
24820	https://transaction.rua573a62e07a9c70ff47e0624b8b43339	202	156	14932
24821	https://transaction.ruba14d312a76096cfc4852e6ff6a2f771	185	152	14932
24822	https://transaction.ru3c13b54db21952663b5775d142be0ed2	217	185	14933
24823	https://transaction.ru85da88c0ff72d571771d8e3098cc34b4	200	155	14933
24824	https://transaction.ru0fd2aa653d00f848d82afe27000fe007	87	190	14933
24825	https://transaction.ru08fbb717c5cb6bf4c29467993eec3f3e	261	232	14933
24826	https://transaction.ru2718eb3c1db89807b14d977ea7572b2f	209	258	14933
24827	https://transaction.ru886d87c57d3d4981ea76d938bf88b148	168	259	14934
24828	https://transaction.rua3efa3bdd188054bbb6ed25ba2132b6f	242	229	14934
24829	https://transaction.ruf4cc16664cf3a1dd131ba3c37515844f	73	230	14934
24830	https://transaction.ru56035cf887fd6e1b5d6d78148eb5c02e	243	232	14934
24831	https://transaction.rub98c5673bbcc5911b78c5d01620caa4c	251	153	14934
24832	https://transaction.ru02cf5c98cb68ad3f38db5f92e0ed1a88	10	185	14934
24833	https://transaction.rubb21b2173b88792bd8c1465349c7696a	248	151	14935
24834	https://transaction.ru2cbbcdcd77db351103a9c0dc599b5f7a	90	187	14935
24835	https://transaction.ru3fa8502ffeb11e407c06cee72b58398f	268	153	14935
24836	https://transaction.ru8000a4dcca65c960592427fce12e9f12	146	229	14935
24837	https://transaction.rudf1a6f90efdb3e0b8efcf4e284ad836a	19	259	14935
24838	https://transaction.rub50550db65337d60fa60e1cf770969cc	16	234	14935
24839	https://transaction.ruf1eff193aed4758d645683b0de8acd6a	102	233	14936
24840	https://transaction.ru0c61788262064c67da55cef61f9f3b48	102	229	14936
24841	https://transaction.rue31fa5974c1779d017af97c2af5a6ed9	8	153	14936
24842	https://transaction.ru32b3dccc797467d59a167ff3323e6bde	265	152	14936
24843	https://transaction.rud05d3cdd58acbf2dd76b811354611c34	231	185	14936
24844	https://transaction.ru36930cfb272b0f4d89622048bba7d37d	131	256	14936
24845	https://transaction.ru836ef8af94744ed17a63d3ce3dc3f8f9	232	259	14936
24846	https://transaction.ru8372a1299b71269bbbbb5e3517ef5b02	148	259	14937
24847	https://transaction.ru070f72bd34744632cd479b8d4d3da857	280	257	14937
24848	https://transaction.ruf903dc21a8a0dda25903bbe2ddda9ba2	98	260	14937
24849	https://transaction.ru5ecef471f9f221f220c9b8aa795667f1	16	229	14938
24850	https://transaction.ruc51aecfa6e07a0758e8bc397c56be9e6	141	152	14938
24851	https://transaction.ru449b649a08169894f6aa877bd6cdbbaa	244	151	14938
24852	https://transaction.rua0c565fdbb204375640ada6ec54855ae	123	153	14938
24853	https://transaction.ru8dc1ba0d42bebc4fa075608b3525bb8c	104	189	14938
24854	https://transaction.ruc52b9bfa3ef6b9c50212fcb508d3807e	252	187	14939
24855	https://transaction.ru287f6168ec126b5ff4f3e53f0e501693	297	188	14939
24856	https://transaction.rue3acd20006ea20150601b784cb4ec53e	132	190	14939
24857	https://transaction.ruf222ed4faa50887934c61007efc5ba8a	93	190	14940
24858	https://transaction.ru2ffc298f0ee58536c92fc5cc8a0c22da	97	152	14940
24859	https://transaction.ruea3be1a50c84a14973ef45e4b50ced89	157	188	14940
24860	https://transaction.ru2ddd0f862c15408e29f2a7c0a597f5be	53	186	14940
24861	https://transaction.ruae8e20f2c7accb995afbe0f507856c17	296	260	14940
24862	https://transaction.ru9b420b19b9a48aade8fd6449f524f906	211	234	14940
24863	https://transaction.ru275644d7db55f24c63a9323862903a7a	259	229	14940
24864	https://transaction.ru07ef692e23b31fa6b2084f0af9c20af8	227	256	14940
24865	https://transaction.ru0ef52e39ca4d5bc4448efadf04aa140d	248	256	14941
24866	https://transaction.ru35d58f24d7a7701719c983a1ef1979b1	3	229	14941
24867	https://transaction.ru0271db521e7a177b82d5d71c8ef9c7ce	182	230	14941
24868	https://transaction.ru43545d13aff8185b03f6c2cdba051d1d	77	233	14941
24869	https://transaction.rudf11c023e522f309229e387600eac7ad	267	234	14942
24870	https://transaction.ru9885d988aa30879a3ba0c54450332d05	158	233	14942
24871	https://transaction.ru448a88639b3aab975be7dba6bb742ba3	289	185	14942
24872	https://transaction.ru37985129d9864cc9567b61a24a7aab43	281	153	14942
24873	https://transaction.ru8bbd6ed02e5b1387ac5e61e03b1608fb	272	232	14942
24874	https://transaction.rueb3d4085a0efb38e6b837646337a374d	113	231	14942
24875	https://transaction.ru06f8140be1cd7c31eabfd2dda8d21d81	57	229	14942
24876	https://transaction.rud4c6fe28140d2e206186bfd92335be3e	53	234	14943
24877	https://transaction.rue2efe989ba4dac701e2044e3323f925b	268	260	14943
24878	https://transaction.ru3b74da63095a3804c10ce5e85235e23c	97	153	14943
24879	https://transaction.ruad23a8ac3c902145ffe05df05812b1f0	222	186	14943
24880	https://transaction.ru9582c512b76a89a5e188270ae59f6ff2	102	188	14943
24881	https://transaction.ru2b0fbcf94f9f33b75156fc5393745698	197	185	14943
24882	https://transaction.rud8b92e1f4d61b9c85958ae5d0df71e6d	153	151	14943
24883	https://transaction.rudc369f38c0ac8273dc5efb365182138a	238	152	14943
24884	https://transaction.ru55daa32ddd2f392da5f4092e0dba4320	232	151	14944
24885	https://transaction.ru28d7f95b770c7afa95e36882b4797c14	155	154	14944
24886	https://transaction.ru43cad6812c52d8b1bf182625e3944225	81	189	14944
24887	https://transaction.ruef4ac048ab5b64bdaa064a47bfaf726a	60	229	14944
24888	https://transaction.ruafef6111d7e66b8fe9be8a7fe2ee0069	85	259	14944
24889	https://transaction.ru1bfd7696fad8a0601ac0f15c5c4eb6a9	123	257	14945
24890	https://transaction.ruae2023499711f8baa6211eae8ae8c294	203	186	14945
24891	https://transaction.ru34a6fd5be29ff9cd2fb626618be1c7ac	68	187	14946
24892	https://transaction.rub73e9d44300a560f4eefe93e2ff25a4a	230	186	14946
24893	https://transaction.ru8a3150dc62fcb95f309ee021e3a2d4f2	160	190	14946
24894	https://transaction.ru230f75585a3be7ce1a53513531a09b74	258	185	14946
24895	https://transaction.ru5b1db3880ca7c3b90e4a6919adb596ac	274	258	14946
24896	https://transaction.ru25802468eda2d11d7264a7975b5dd8f1	54	230	14946
24897	https://transaction.ru13de03bec50bea10849bff1ca58b881d	155	232	14947
24898	https://transaction.ru9db12c7bbee5458016fddd7e6bbf1b32	231	185	14947
24899	https://transaction.ru54302b20ba542508e4e1dd7291ff6824	238	186	14947
24900	https://transaction.ru9b5b2258c05760c209341a4c39269249	220	188	14947
24901	https://transaction.ru5b2fb2f1ae61cc2a98098b3628ad2e00	167	234	14947
24902	https://transaction.ruf9738bd1d391ade03ac7df8572dcaf8e	129	259	14947
24903	https://transaction.ru5a5d4057010068034fdf8b5caf4ba076	221	188	14948
24904	https://transaction.ru83117e9120bce3b5f12224c53d4394ae	232	187	14948
24905	https://transaction.ru8058fff6ec1fc84c3a99bf7e8dd7389b	287	186	14948
24906	https://transaction.ru3a80cc5eac6035cc35d3f34d768dfbc3	129	152	14948
24907	https://transaction.ru5def29f7bde81a75f2e1093fd5adf8a7	218	156	14948
24908	https://transaction.ru22f5903d9c6c970dc4b81eff9d960153	201	153	14948
24909	https://transaction.ruaf18b59337fa57463c76e78681e10066	283	233	14948
24910	https://transaction.ru3829aa286c8ee684ee58d9dea2f931d4	185	229	14949
24911	https://transaction.ruf12c4047d1f8e0c404847442c49ead4b	155	185	14949
24912	https://transaction.rufee8945059ca2647234a60a572c7d054	92	151	14949
24913	https://transaction.ru83672563a735a0e086c45ca392adf13f	103	152	14949
24914	https://transaction.ru32eb6cf2e763ccb3b10e20be56f696f1	274	260	14949
24915	https://transaction.ru39f87272188e4329a31e40c115f42b79	15	233	14950
24916	https://transaction.ru0aca771464122a614da0fb4ad0defc02	129	152	14950
24917	https://transaction.ru0558bbe76402b52d03ebbff47dfbb2e4	129	189	14950
24918	https://transaction.ru5816c1af8314ea3be8fd90d1ffe94211	252	190	14950
24919	https://transaction.ru1942aa44687797fc73ae5a7913d7fc9d	228	231	14950
24920	https://transaction.ru5523a033e1dcf7b5a7d221bba8c6d695	56	230	14951
24921	https://transaction.ru641fe83fa55f9fedf5f7ab9818cf8511	43	229	14951
24922	https://transaction.ru336fd95d2fd675836a5b72a581072934	81	232	14951
24923	https://transaction.ru1a0ef9c0263b24c6462e060025315804	162	155	14951
24924	https://transaction.ru53fdd79ee9474522bc92aea410b7d11d	94	153	14951
24925	https://transaction.ruc3c82d8e316890f69af51a3b9b541c39	164	186	14951
24926	https://transaction.rucf33956383adaf54f857b5e5c98faa4d	185	189	14952
24927	https://transaction.ru3b3908600ed6e8fc64febeb595be24dc	138	186	14952
24928	https://transaction.ru97c09ccb12ce63f93c06e858b14c53e6	78	190	14952
24929	https://transaction.ru777d507edf29d82605c3f695407c681f	121	256	14952
24930	https://transaction.ru247c2f9ce50900ffe79b1568f42cf7c5	168	258	14952
24931	https://transaction.rube689bcc06cf7a19030c200bcea95110	146	258	14953
24932	https://transaction.ru43c30db49ea05a2226bc2cf309efdc33	63	257	14953
24933	https://transaction.ru92784024e74dcb2d3f26a0d44fb41470	220	189	14953
24934	https://transaction.ru600ade85ab8d19863d296bbd6d3c8047	187	153	14953
24935	https://transaction.ru1c0d1a681a3e362a23e9bb393b0bcea8	207	155	14953
24936	https://transaction.ruc5a8e22f315fc9bf0326514371979b3f	267	154	14953
24937	https://transaction.rue155bb28c503c4d2093eb5fce68c3743	145	156	14954
24938	https://transaction.ru0d74bc7304d637ef9aa7d710c81cdd8e	108	152	14954
24939	https://transaction.ru192fe353deb295456dcfc64ccc5bfa81	232	189	14954
24940	https://transaction.ru6ccdf20ecd61d591ced28db9240afcd6	186	257	14954
24941	https://transaction.rud7001a2c53193f66609fbbe2c387dada	264	231	14954
24942	https://transaction.rue5eb2ecf1d723426cdd4e40be1f3b8e2	11	233	14954
24943	https://transaction.rub98c532a20237dd8bf27ba261a9eab0e	196	234	14955
24944	https://transaction.ru5735438d64589c7672b1b246cc3b2b24	251	186	14955
24945	https://transaction.ru72fe77bf88b0f8e56b1d31cd6da0c1dd	253	154	14955
24946	https://transaction.ru8184aea5f26b5ad1ebd388c6e3a69cdb	231	230	14955
24947	https://transaction.ru8f0fcae811cfbfabf93901185944c055	291	257	14955
24948	https://transaction.ru481c8cb8a1bd6fe0cd40f8db282476ea	137	259	14956
24949	https://transaction.ru8fb1495ee305bd70077fa7e7f9cc0cc0	31	230	14956
24950	https://transaction.ru02967ac59bb88120131fbdbed29c388e	31	189	14956
24951	https://transaction.ru6322e58d8b5404a2b4167fa2493ba118	2	185	14956
24952	https://transaction.ru37f0537bdae7ac60a15cb4742aadc7fa	180	154	14957
24953	https://transaction.ruff058f44f1a29b0f4fe27ab1dcd6b0a9	277	187	14957
24954	https://transaction.ru4c19dd7e9ec9cd1f4c03cd2912b2fa2c	31	257	14957
24955	https://transaction.ru3ac36b81d276478b8354e8c199d7de05	273	256	14958
24956	https://transaction.ru195c94b8e232da2da39573cce4f010ca	205	259	14958
24957	https://transaction.ru16a08d9ed7c68bcaa7f54e52470a5f16	203	234	14958
24958	https://transaction.ru98330d042c5d291c2e10eca09571d13e	66	185	14958
24959	https://transaction.ru320e213ab0659ffbbf495f6aa2967e8b	43	190	14958
24960	https://transaction.ruf39c600d3d8414b3a7bd057498e97ede	135	156	14958
24961	https://transaction.rueeaa5d7027a2a798fdce79375aa81ffd	178	154	14958
24962	https://transaction.ruf30f3e1e51e783ecf5dc65d8841786ea	62	232	14958
24963	https://transaction.ru83d53270d11404365da7fce61041da17	84	229	14959
24964	https://transaction.ru4220fb688c5263d747c4226dbe55e929	86	257	14959
24965	https://transaction.ruf4adb9bad6e78eabaefbc5c80a0f04fd	106	256	14959
24966	https://transaction.ru5000d4f3f9c256c39f7241a00be93243	283	155	14959
24967	https://transaction.ru0c6ffae27da52a247c4e3842869c3d86	185	188	14959
24968	https://transaction.ruabe09aef7462666729b17a9e54efdb08	140	187	14959
24969	https://transaction.ru70f53fb668eecf5e63984c6027526b24	221	233	14959
24970	https://transaction.rubbf5c2ef24ef06c6f3384e55917b5194	193	234	14960
24971	https://transaction.rua0b19d4bc1e76914f363346d470cf279	94	230	14960
24972	https://transaction.rubc21682753d798bdd65d6b0584deb2b7	235	156	14960
24973	https://transaction.ru09662c3dd2ef3654c2a3cb89e6056e3d	44	185	14960
24974	https://transaction.ru48a7b274e97fc161c6cbe18e1f0427c3	65	258	14960
24975	https://transaction.ruee747fb8ead4ffd91ecbfd0708d73a5e	227	259	14961
24976	https://transaction.ruf8ee849ef774e74875067b89cd000e97	216	234	14961
24977	https://transaction.ruda4ed9ec1877794b62af77057dd884af	10	155	14961
24978	https://transaction.rud628f4a2079fdcebaf32ab21bdf0fc85	280	153	14961
24979	https://transaction.ru9da3bef5c0126258f91a4c12cad9294e	287	189	14961
24980	https://transaction.ru3953630da28e5181cffca1278517e3cf	106	186	14961
24981	https://transaction.ru224bb7bd1bf9d48b139304d4fc87902a	257	190	14961
24982	https://transaction.rucbe914ef6923b58ae0a42186cde73c97	156	231	14961
24983	https://transaction.ru00dbda6093affe5ecbc9a4d71531fdef	43	259	14962
24984	https://transaction.ru0f504ffc4ff68684c5b644c6912639b4	297	190	14962
24985	https://transaction.ru79a766a25a65f3cb6d7fd5a321cf3190	211	189	14962
24986	https://transaction.ru4c77dd6a194f48b429da36b045b65d18	12	234	14962
24987	https://transaction.rudf3839eb9d6dfdfa5df977440e50bd81	12	232	14963
24988	https://transaction.ru28334c011c1ac5c64fe6fb94f02bcb1d	143	231	14963
24989	https://transaction.ru341ce736141baab777d907fc0ff133f3	47	187	14963
24990	https://transaction.ruab350915b790622b9d48f0d79fbc0bec	167	185	14963
24991	https://transaction.ru5cd0697560a354109a57a68b0e54a0c4	119	259	14963
24992	https://transaction.ru7c84e2c91d61b287e99e6915f4daa68d	284	258	14963
24993	https://transaction.rub59ae3380133bb9cc6740f207f66e398	292	258	14964
24994	https://transaction.ru6f817bb978f4e54af97ca2d134acc9a6	215	155	14964
24995	https://transaction.rucb20715b73c6bc7661942164f6af8c76	204	156	14964
24996	https://transaction.ru50d2b3198a3dda4cc7c8ece9a92004d5	255	229	14964
24997	https://transaction.ru5e7346d7dbfcd658bebebc6ff9cbb037	147	232	14965
24998	https://transaction.ru094cadd61688f3a39c5df36022b9f110	288	229	14965
24999	https://transaction.ru53a66ab0c4cc987e33bcef8f63a89f78	251	233	14965
25000	https://transaction.rubdc48f6612bdfebb9b845e4c87f89d5c	133	156	14965
25001	https://transaction.rube298ff9fe83060addb75f35c7c8a5c0	138	152	14965
25002	https://transaction.rub774c20b78f0a3d2ea849a202f898416	114	259	14965
25003	https://transaction.ru52776f2dc9a0f8553bcbe0b7564df2a6	208	151	14966
25004	https://transaction.rub1101bc7b6ba009186086fdda09abd44	82	188	14966
25005	https://transaction.rud23b8d31960ed81cb8efa31bc2cedc37	153	186	14966
25006	https://transaction.ruff88eeac17d05e51ef6c1f3140b68080	133	155	14966
25007	https://transaction.ru4f8bfe1d57f5c305c083e5ab7f4ab0bf	28	154	14966
25008	https://transaction.ru2dfbc289916dc2103c7feb2a96b9789e	297	234	14966
25009	https://transaction.ruf8fc7f56c07d1cc86183c329ef3df0f4	194	231	14967
25010	https://transaction.ru890cb87b0a5c0980ed92a89fc24e92fd	247	153	14967
25011	https://transaction.ru46ee3a2e6b8fe1c4f02aa191b21f84cb	23	152	14967
25012	https://transaction.ru13917013261d132cec59f885256145f5	298	188	14967
25013	https://transaction.ru698516bf51a25ea7187a0e26b1af2669	245	256	14967
25014	https://transaction.rubfcf34049eab5e75968a110e3bff7b22	281	234	14968
25015	https://transaction.ruf5799d8222694b2c64a5152b193b455f	56	231	14968
25016	https://transaction.ru0b5ad4aceef5331e09a13378e91c52c0	23	257	14969
25017	https://transaction.ru327970f6a1a727c1c34c703d00b6c695	210	155	14969
25018	https://transaction.rueec5c7bb5128dd696c7dc42ba1cea3e8	46	153	14969
25019	https://transaction.ru1609ad166521a0b790e85cb1bf8807bc	29	151	14969
25020	https://transaction.ru5abb654d777c163b9bc17d8a95eaafe9	231	187	14970
25021	https://transaction.ruc3a8cab0f72e545c8cd9081674b6ea3c	193	188	14970
25022	https://transaction.ru27906f6dfb40ec2467a035fff50c794f	119	155	14970
25023	https://transaction.rud8255d0bedf89246aea047f44006c4a9	299	234	14970
25024	https://transaction.ruc7db7785f5a6b5319509a85c118867eb	57	229	14971
25025	https://transaction.ru523c1cadde38414b944dd4b10a001636	135	260	14971
25026	https://transaction.ru0c95e4a579307c6cf93f139e12d62022	118	154	14971
25027	https://transaction.ruf042474cfb9b3fc10ca015577cac0f55	189	151	14971
25028	https://transaction.ru30f71d698309bd3bfe7dab4ce021547c	230	257	14971
25029	https://transaction.rud36a2273de3037f79cafa9c70a15aec6	4	258	14972
25030	https://transaction.ru1ac4dbd83735534bcebc28c845dafccd	11	256	14972
25031	https://transaction.ru7d9b976bc54c92359b6036cd2edf6f69	167	257	14972
25032	https://transaction.ru19589cc7c902f6a1127052cdb4bd0be7	152	185	14972
25033	https://transaction.ru5d0ad64711c6138b1e9f668184ead266	126	189	14972
25034	https://transaction.rub0a44d71dfe9e24bcbe516ed53921b32	180	190	14972
25035	https://transaction.rucff07160f340276d761d7628e0beb3c2	16	229	14973
25036	https://transaction.ru83f16d5b8916b5044aedf1403dc9bc81	285	232	14973
25037	https://transaction.ru1e71ac540adb4e3039fdf1a5751b270f	59	234	14973
25038	https://transaction.ru71df8782d05e24b5095354bd5aa76f19	114	151	14974
25039	https://transaction.ru3260fa3c767639221b686ec9eca2654c	246	153	14974
25040	https://transaction.ru8c29de35b14c6992d64e22bc8386ba9b	49	188	14974
25041	https://transaction.ru1a3190edf2ea23fc26ac88b867102b60	176	185	14974
25042	https://transaction.ru5c4de37f25871ec7ffdff6a1baa012ab	236	258	14974
25043	https://transaction.rudad00da48323d69bfe17eba0d27dc905	32	260	14974
25044	https://transaction.ruc10c6a81b958472ca96561ba0d29d49c	29	260	14975
25045	https://transaction.rub64e1bae0d302451f8c3e706f0efc656	60	234	14975
25046	https://transaction.ru8f9eebd45eceee424ee5e64c5fb7b0af	78	229	14975
25047	https://transaction.ru4bf14db6f12176bb2ab9f374fd69d422	52	257	14975
25048	https://transaction.rub60c1aac0ddbdfd54c3f261123b5f6b3	194	256	14975
25049	https://transaction.ruccc9cf13eb8051e467e13ec74373010e	115	190	14975
25050	https://transaction.ru447b499a58a864ab8d4154c6d0128e0d	46	189	14975
25051	https://transaction.ru0e36c530f5334533cb138559eab39155	54	188	14975
25052	https://transaction.ru139d49444f0febc3bedb854c8b992f4f	135	186	14976
25053	https://transaction.ru561abb177528d5bf95d40838809a7cf6	266	190	14976
25054	https://transaction.ru6d7e9392111a0861d13d92fd2d7faeac	156	153	14976
25055	https://transaction.ru8ff05dcf1560740b28f49573a0389d8f	86	156	14976
25056	https://transaction.ru058b0e88a7b81c512b4eedbd0a5425c4	76	155	14976
25057	https://transaction.ruadbb86c76345393d842803079e957d75	26	233	14976
25058	https://transaction.ru27fbf4eb220bce7984c2b6332def972a	144	233	14977
25059	https://transaction.ru375db1c0f6ce1a16d91d6306269fc58e	29	155	14977
25060	https://transaction.ru02ce996f908f19c0d003b522827eec0f	9	156	14977
25061	https://transaction.ru9890ff7b579c8f32fa38d446c371312c	26	190	14977
25062	https://transaction.rub5919143803fc8f4824434807380c1e3	275	189	14977
25063	https://transaction.rub0dedfd6d3e8e28e042ca4a1ae95c2ce	179	256	14977
25064	https://transaction.rub10958f4acd48eecec91541a7803157a	191	231	14977
25065	https://transaction.ruf5fee8f7da74f4887f5bcae2bafb6dd6	6	229	14978
25066	https://transaction.rud63492fa84b16d580ae0759ab7502550	277	234	14978
25067	https://transaction.ru512977257ffd1c55b6757847785322f3	299	233	14978
25068	https://transaction.ru7cf0bf8dcbc88790ea36b18cad405f8b	225	258	14978
25069	https://transaction.ru2d6ef10b3f6df5824f1d5e0d10cc70b2	14	187	14978
25070	https://transaction.ru87ac24146c9aec07ec732e5faa868577	229	151	14978
25071	https://transaction.ruf28411763f159f5597e06d57b6905a01	101	156	14978
25072	https://transaction.ru72e34cac2bdeddb747cf9406123c6752	199	154	14978
25073	https://transaction.rud18a6195ef9a4d256b2cfad6aa68e3f7	300	153	14978
25074	https://transaction.ru6d21ee8fc413d59ca94df40ae2ebe2c9	280	155	14979
25075	https://transaction.ru7655ae7360990af10f8e6fb9d452129c	227	154	14979
25076	https://transaction.ruff1845cbda426801a5bb2b7c3e22f755	203	187	14979
25077	https://transaction.ru7ead8f442c2a56b063edc586b2a3f2d3	141	188	14979
25078	https://transaction.ru28d760f52ad1ab2f3a82cb5c7ed4139b	78	231	14979
25079	https://transaction.rub0d6aefdde95c9d48deb97cbdc0fe30a	235	233	14979
25080	https://transaction.rua4b0afad2ff9a31f889597f30e1f7942	133	186	14980
25081	https://transaction.ru8b75b7913054a938d2950e29cd397608	92	187	14980
25082	https://transaction.ru67c5e197589b56db69688c069914d991	125	154	14980
25083	https://transaction.ru74db7c1b0096ac91252db4570534d863	32	152	14980
25084	https://transaction.ru57e31b786d5fe0d1ba23fc213404ea59	258	232	14980
25085	https://transaction.ruc059f858f82f19769f24c0ea0b8ee2b1	296	230	14980
25086	https://transaction.ru3a749352ef1293490298f6151d0a9f04	70	256	14980
25087	https://transaction.ruc337d9afdd36b2cc615db5ff0d1e2bb0	219	259	14981
25088	https://transaction.ru1cf00c6746b2452b240516b018cbf6f7	80	257	14981
25089	https://transaction.ru0e2931beac4e9c2ce52cd747e51897fd	49	151	14981
25090	https://transaction.rue935d56c38a10c0c203fc419cb378a23	224	152	14981
25091	https://transaction.rua8add88ee03308ca5d1c6bb7e798494a	201	186	14981
25092	https://transaction.ru7e824584e9377de6dad3721cd5af80ba	24	153	14981
25093	https://transaction.rub52da167b8e46e40d7d7a5a1858b918d	151	188	14982
25094	https://transaction.rub698d35ec8fefdfeb547388c8eedbc80	34	189	14982
25095	https://transaction.ru745bb1ef36da1ffd479d7a088018e568	211	233	14982
25096	https://transaction.ru2219f11cebc5d98ab9e732a904cec38c	152	257	14982
25097	https://transaction.ru2070c0b8cf02639f22e039b6d85a6934	169	256	14982
25098	https://transaction.ruc68d508189cd52b3645d1c750322a199	182	231	14982
25099	https://transaction.ru8600069d2875f61163ad015cca90f615	294	231	14983
25100	https://transaction.ru93f6c03854f8e6ccc722ae5422993605	296	189	14983
25101	https://transaction.ru2e7d6000c18e220d5fb5391aec0cf4a7	186	260	14983
25102	https://transaction.rue01d92bb936cf77e9b537f904fd29a4b	189	259	14983
25103	https://transaction.ru06abb96c38b692dfc258c2001f18f200	75	185	14984
25104	https://transaction.rua9c67d472f4e958b2f7f8d73692845c6	39	154	14984
25105	https://transaction.rub4d23658ec9b6d5be0a677d0c6b5c45c	197	260	14984
25106	https://transaction.ru1b31a4f23c784d5b162a3066fa9aaf4f	293	233	14984
25107	https://transaction.ru310e03a0e32f3bb75e68d19a24e8d102	135	234	14985
25108	https://transaction.ru151ea8c2d98ce89c2336324c11b1e107	31	256	14985
25109	https://transaction.ru67d67b422a02f423ae87d204b693da50	161	231	14985
25110	https://transaction.rua684ed38dbe9dc8f0051fb40ebc5384b	178	232	14985
25111	https://transaction.rua4a001f7fd50492e8e29fb3f28c0c835	70	153	14985
25112	https://transaction.ruaf53eca99a06f841ce943c5c50b0e1b1	61	155	14985
25113	https://transaction.ru2f75773d1495f9aa120eb60ca29aaaff	102	187	14985
25114	https://transaction.ruf7eab4bee0d93c24affbc17e4e62e7c5	11	152	14985
25115	https://transaction.ru88c9320ecf572bf0e9cc8ec9ccc61749	208	190	14985
25116	https://transaction.ru9fde96d4bfb3026d27f448d20e1c917c	50	189	14986
25117	https://transaction.ru4a5b1eb29f25baa99a6741f6b5ee882e	9	153	14986
25118	https://transaction.ru394e5fd437de35af605aa59b3eb616e6	218	155	14986
25119	https://transaction.ru6d7e9eebc641e88b0f96ca6a6407f90c	206	154	14986
25120	https://transaction.ru069dd8ec4de7cd2b8b08dc69047afb7d	11	230	14986
25121	https://transaction.ruce729b75e82a7ed56ce97976a83fddba	115	232	14987
25122	https://transaction.ru7bb37d500b58dca31306aa1ff19ab78a	297	258	14987
25123	https://transaction.rue83b6d5c5b7b585014baa1d8835a3ea6	294	189	14987
25124	https://transaction.rub985e44ae2d53804a3c2210a4c217249	98	186	14988
25125	https://transaction.ru6de5931cdd4ad96979cd1554bb2df0e4	122	190	14988
25126	https://transaction.ru1925b21d69c46f2247edff503b47ef1f	17	185	14988
25127	https://transaction.rueb32893b968128a478263ec8fc69d80e	97	231	14988
25128	https://transaction.ru81b26dc872d8d63b5399cd60e7ba8bf5	20	234	14988
25129	https://transaction.rue9ea74d8a66f0bf1ee34e8d1a298d070	296	256	14988
25130	https://transaction.ru4396d16836921dad65dfa15728dae941	181	259	14988
25131	https://transaction.ru4404220b8b0595d79bcce23636193144	264	229	14989
25132	https://transaction.ru0278ca142117ad0b44275109dde6245c	277	185	14989
25133	https://transaction.ru4a05e5717cba3b61031a87890c99d66e	232	154	14989
25134	https://transaction.ru1dd36cdfc60c5637a1fd26ff740d6774	101	152	14989
25135	https://transaction.ru1da5ca963ae4930bda1e0a19cc88ae87	172	233	14989
25136	https://transaction.rub26f60aaf9868cde477e63dd317c85cb	42	234	14990
25137	https://transaction.ru098136507455fceb53502ea536f93990	143	232	14990
25138	https://transaction.ru83549170d8d7bb8d153ebaed9f4d2e76	12	230	14990
25139	https://transaction.ru4cadbbfeb9c8fe5cbab7dfba6b1b909b	266	229	14990
25140	https://transaction.ruca7a8ba51d9c98ac5609aa9138f444da	243	186	14990
25141	https://transaction.ru420a513af8b0f75bee17414b085cddb0	207	186	14991
25142	https://transaction.rue8f611cdcf1b171d8380293acf4dcfdd	141	189	14991
25143	https://transaction.rua950e618c0fe1d798d936a582b3bdf7b	19	187	14991
25144	https://transaction.ru3ed304a448828ee2ca0405997a37521d	205	152	14991
25145	https://transaction.ru221dcd033e3623c5549b7fc3ea8df5be	103	154	14991
25146	https://transaction.rufa81a314f61bf074bc736fdb90d8b414	198	153	14991
25147	https://transaction.rue684d9d7c186def19b47142b41d0daf3	34	233	14991
25148	https://transaction.ru1d35206329dbddc86e4b5d43127b1e36	293	257	14991
25149	https://transaction.ru6ebbaf1382e9248f15c07017538bbb46	294	260	14991
25150	https://transaction.rucbacfb4a9494c9cb369cf4855ee1beea	267	234	14992
25151	https://transaction.ruf9424ec6e981fc6fd241b4d221bf3df0	233	189	14992
25152	https://transaction.rua3c95a45d62d447a0413e33bb74911c0	267	188	14992
25153	https://transaction.rua8fcb406c88e3b7915865c82db018e24	11	185	14992
25154	https://transaction.ru74959d6b628fab0423d51e683790de48	199	257	14992
25155	https://transaction.ru8c5f590a82a0201312573e333cb3b482	72	230	14992
25156	https://transaction.ru44fd6fd3bc224014b6279236cda91a70	212	230	14993
25157	https://transaction.ru9140c645a86223792ea72c73197b132c	9	229	14993
25158	https://transaction.ru2bbc90dc61c00cf1dfa2148d86716cee	72	185	14993
25159	https://transaction.ru8d4eadd3ef860106996a64d85b86bf8f	115	154	14993
25160	https://transaction.ru9dfe54cc59b45418e7dd48672658d0bf	120	153	14993
25161	https://transaction.ru208fe089ab72bfffb2f732dd7306950f	113	155	14993
25162	https://transaction.ru120efd9c1fccfad0e0d62303d633a037	99	153	14994
25163	https://transaction.ru19f59064291ed0341ae3765060cc4ad7	100	156	14994
25164	https://transaction.ru817805c0905e1a87866b23c11136a0a7	197	154	14994
25165	https://transaction.ru5a8533aa9a2a473b136f3a169601059c	158	189	14994
25166	https://transaction.rud9dc2d2ee601696336914b2df1980fbc	292	151	14994
25167	https://transaction.ruf3a65a6c62ff942c8b791cbbb5787908	128	190	14994
25168	https://transaction.ru0283edb42838b576372b858707035c51	175	230	14994
25169	https://transaction.ru69743e47d34dfdf228e7d96d179f8149	73	259	14994
25170	https://transaction.ru9627d82c591812aae9ab119b34de83b0	235	257	14995
25171	https://transaction.rub30d504e38cdbba4eb539d49871196ea	98	234	14995
25172	https://transaction.ru399caf077338d1f8a72699be0668f84e	225	233	14995
25173	https://transaction.ru0116d20e9106ed0a25483358d60e2688	246	154	14995
25174	https://transaction.ru04f337d8c97716abd9c74d5d5370cfee	41	185	14995
25175	https://transaction.rufeed563580b7830d4532b55b593aba3c	209	186	14995
25176	https://transaction.rudcbaa08281c193848dd44f982d75dc8f	282	188	14996
25177	https://transaction.ruf96c03e7acb65f9976416d306be20d55	116	186	14996
25178	https://transaction.rubd590ca36fbb221b3df7a27af9157c90	227	156	14996
25179	https://transaction.ruf7d6a4c966cfc43d99a8a25fe33481ff	207	155	14996
25180	https://transaction.rua45915edc451bcb5a1d12ef52ec4af87	232	151	14996
25181	https://transaction.rub41d42a6226a05078a837079a43d27f7	89	259	14996
25182	https://transaction.ru261710cb7f78aef23e73205c15c49e72	141	229	14996
25183	https://transaction.ru37e6614af1245f5f283c0801ba5d9795	231	186	14997
25184	https://transaction.ru2bc384dae4cdff9e22e84aa900e2e9ba	270	190	14997
25185	https://transaction.rub7a39ec4342f26feb1d26457bc01d712	275	154	14997
25186	https://transaction.ru1b73e6fb71812662449d96638c0b0072	284	155	14997
25187	https://transaction.ru084a4a4570b630cce26722d97130eee0	173	156	14997
25188	https://transaction.rubf16595063d9b9a48947e6f13e073cd4	286	256	14997
25189	https://transaction.ru23a160300b208c60dc374d8e4f8c6d4a	288	258	14997
25190	https://transaction.ruab50547906a32e4e0afdb069ddb7fe1c	163	259	14997
25191	https://transaction.ru0b6be77cbb6409b0f3f491ec38cfad13	282	233	14997
25192	https://transaction.rub699556d36dd386da7c02d83f28686fb	158	234	14997
25193	https://transaction.ru0fca23676ae3be3967ae7508e93df2b9	99	230	14998
25194	https://transaction.ru64ece6f38db1d749192edda96f60c4c4	106	229	14998
25195	https://transaction.ruaffbf6f6b18b071199f7459d8dcc3ad9	22	257	14998
25196	https://transaction.ru2b1fb439252db915dd67f95cfd33e3f1	62	189	14998
25197	https://transaction.ru8545ec6e1574aa26f97ef784fd8da75b	26	186	14999
25198	https://transaction.ru625f4c74343e2c969fec36c86559a0b8	278	151	14999
25199	https://transaction.rue7e58bbbd12180687e7e7811953bcdd3	158	190	14999
25200	https://transaction.ru51796963cf3979b30da45b7e466203e2	230	185	14999
25201	https://transaction.ruc594e7732f9cfa484f9417c4afd924af	141	234	14999
25202	https://transaction.rud65d1c68270feae9bacb1b806f42e633	72	233	14999
25203	https://transaction.ru35bd2b87efbc2d3f864c5e09fc35ba27	169	259	14999
25204	https://transaction.ruc800ee11a8d9f4e27dd6297b5996e677	118	232	14999
25205	https://transaction.ruc4f5e3dac2379007a063f3763acc9a5e	97	230	14999
25206	https://transaction.rua7eb1dfa78e088282e4a818b80512215	173	185	15000
25207	https://transaction.ru5bd756e7ef1019f5b5836aeebdb88c8b	60	153	15000
25208	https://transaction.ru5174b2cbdca2b1353501e76fed5b83bd	41	190	15000
25209	https://transaction.ru8519874eb55f491375b581bc1c166029	71	152	15000
25210	https://transaction.ru0b43184a0b7b0d15373b06318e4d9c13	180	259	15000
25211	https://transaction.ruc2b6a7440849e1fc0cb91fb39e931903	157	161	19701
25212	https://transaction.ru20dd4cde4ef566b0b6756dbbcb6cebc9	15	197	19701
25213	https://transaction.ru3d17827970dea2662b5972b8668ca755	261	193	19702
25214	https://transaction.ru93e22947c477da3c9c1ce739a4faaee5	223	195	19702
25215	https://transaction.ru88dad19ee0e1cebd4b575852ab1dac3d	2	245	19702
25216	https://transaction.ru9afeb5a03232c6a078838f3c0974182a	16	241	19702
25217	https://transaction.rud71c7a5aa9b07317cff1b74872bc06c7	282	240	19702
25218	https://transaction.rubf4967b8911b6d5100915f7f863bb7f1	47	237	19702
25219	https://transaction.ru4401cced628260c2142950786c1b11a3	281	239	19702
25220	https://transaction.ru4df82364649a1fa8b9ecd289cde8cc4f	245	249	19702
25221	https://transaction.rubf49261bc39bceca77de9c1532f750d1	222	249	19703
25222	https://transaction.rua3dff91abd664256e4e850b9b0e78245	219	159	19703
25223	https://transaction.ru1e44a3241d0c8d208b285d6f1a31b243	145	236	19703
25224	https://transaction.ru1dfaa9aeae87cf09a0dfe93b91a6cd25	191	197	19703
25225	https://transaction.ru64157a370a2257ee6c20f26f14ba3583	146	239	19703
25226	https://transaction.ru267f59186dfc4b9259759c51d3e15bf3	246	245	19703
25227	https://transaction.rubeb9f7c7b817621d42dee22f6c5129bb	194	241	19704
25228	https://transaction.ru0bb755e4b3d7d1c7af539ab2150ff49f	144	245	19704
25229	https://transaction.ruceb76af227435c8235fe2062d3fcba37	132	236	19704
25230	https://transaction.ruf6cced5cd8ade3de995b277f25350804	55	246	19704
25231	https://transaction.ru47d40055e811156bb249056fca51288c	93	193	19704
25232	https://transaction.ru85162b08ab1c51bd79d01492bd745d83	110	238	19704
25233	https://transaction.rud438e82edbbc2dc1984117e71c10e145	173	235	19705
25234	https://transaction.rue71d1601425407d5ba87f990cac7956f	8	195	19705
25235	https://transaction.ru2d9e6f13fd708b61d764c8c9f2fab087	18	159	19705
25236	https://transaction.ru34dd936a2fea0a113d0ff267fc2b56a6	221	157	19705
25237	https://transaction.ru1c6a949304fd7655cc0fef5c733b92f8	6	199	19705
25238	https://transaction.ru763f5b316f0e7f25619341ef1305fd71	93	197	19706
25239	https://transaction.ruaea8950f5887f0ac50164c285f11f0b7	274	196	19706
25240	https://transaction.ru4c995bfed07d43f568f36ddaf12edebe	243	243	19706
25241	https://transaction.ru8de86d3d46519f380a2c1b81b988c3c1	130	247	19706
25242	https://transaction.ruebda40b69e1f553fae96054bd34472ae	25	159	19706
25243	https://transaction.ru523f07e36890c6db7cb750bea21e3c69	233	162	19706
25244	https://transaction.ru68d76e7dd33760f8f96f0658b1222112	223	194	19706
25245	https://transaction.rueb86c78dc5082aaf0fcac275173cb57b	266	195	19707
25246	https://transaction.rub5df52e4e1722ea6fbaf346366456e71	86	245	19707
25247	https://transaction.ru7cb9eacc4a5470bb1dda21999dd785d8	77	239	19707
25248	https://transaction.rua9c5c4e4ca656161c22f31c71879e581	197	240	19707
25249	https://transaction.ru7ce623a5609ebde34b950c94b148251e	122	198	19707
25250	https://transaction.rud2926739cef5ccec5a4a76a576b4221b	200	247	19707
25251	https://transaction.ru1b499e90f699ca94052068646d8d1638	261	249	19707
25252	https://transaction.ru65d6b3b69c9122e98cfb9c6487f8438c	251	235	19707
25253	https://transaction.rud66f41eb4ea8f28b4094328f027d5e89	169	236	19708
25254	https://transaction.ru311f0dd76129203a6f3bc023ff03c5fe	112	239	19708
25255	https://transaction.ru3df957ba4928b954b29c025dfc01f315	111	238	19708
25256	https://transaction.ru61491a7560f0e44bbbab8211689371f1	296	237	19708
25257	https://transaction.rub264a5b0eab9be85612d32f8b84f1ebb	80	194	19708
25258	https://transaction.rufee327d4c7df515bc97278d358b838f1	100	163	19708
25259	https://transaction.ru1409f069e91546b27956a32bd0c2b0f5	242	246	19708
25260	https://transaction.rudcb2b7945cf67b1bdb679dd13ac5adf9	187	198	19708
25261	https://transaction.rue954f226ce94f365d747d1d7b6de3492	8	239	19709
25262	https://transaction.rud134b112c62887530ba5d03a977cdfaa	105	238	19709
25263	https://transaction.rue820a6fe625cf46ec43cc3a2d2ff8a27	275	245	19709
25264	https://transaction.ruf34b531880c2cb3ecb6dc07768762c09	26	160	19709
25265	https://transaction.ru34395d6f2933b1aeb23eb6c7ccd38c63	40	158	19709
25266	https://transaction.ru64785bbb34301209d902b079419a2c57	199	194	19709
25267	https://transaction.rufe17842988e583e6588ad4f9e675152c	51	160	19710
25268	https://transaction.ruefa9bf1d02c44d73104537edd9bd96f0	61	163	19710
25269	https://transaction.ru977fd24655f7eb335449e50c55835353	81	161	19710
25270	https://transaction.ru28b13d6f111c55524ace50c4ef529119	64	159	19710
25271	https://transaction.ru3244e879e2f6e91f368fa6b5d8c8914c	55	196	19710
25272	https://transaction.ru35c13118f5be908c0dcca1464bd9106e	16	241	19710
25273	https://transaction.ru68c8ca7688071d89efeaa2079b2ef661	245	249	19710
25274	https://transaction.ru08d3dba25528364eaa292d3ceb1f1d74	207	162	19711
25275	https://transaction.ru2a3066b759bcb962009bb840c2ca0f25	254	236	19711
25276	https://transaction.rubf4cefd39228b65153ed356af6c15a4f	168	238	19711
25277	https://transaction.ru6a418d238249b07ab97932cb71b6fc4f	242	244	19711
25278	https://transaction.ru0288cc4248df131fa033a8efdb15a1c5	218	245	19712
25279	https://transaction.ru22102353e61366a000e4cd9652600236	259	248	19712
25280	https://transaction.ru3f7f053ad3eb9a3763ad9021c7500d14	94	247	19712
25281	https://transaction.ru72d941cfe5a5c51dc065414a5e335e30	42	163	19712
25282	https://transaction.rub4a838746cd48e1dc641163cb33cc368	142	161	19712
25283	https://transaction.ru18c4368bf33e491a9aea4bd7a0ae95cf	262	195	19712
25284	https://transaction.ruca2ad0c9dc748232b08f674180a3a545	301	159	19712
25285	https://transaction.ruca0b381966d709105fe6bf5af533e381	99	199	19712
25286	https://transaction.ru12a97d16aeef1650e23c3be6bb1684d1	100	247	19713
25287	https://transaction.rue861996d962cceca6de4e0b4de8e1a86	214	248	19713
25288	https://transaction.ru23e5b17883c38eeb6da6416e7de48044	200	236	19713
25289	https://transaction.ru7e41ff99360fb20709f4f8110fc95988	130	235	19713
25290	https://transaction.ru5f6097935c93bf23bd2dfffbf65be43c	257	244	19713
25291	https://transaction.ru7afba8ec2fde1fb499b1f5ca28c4567d	283	160	19713
25292	https://transaction.rue09e582bef268062f0b7214080438c1c	300	238	19713
25293	https://transaction.ruf8f590da0dcbfa4fef0c5c21a2929e9b	221	235	19714
25294	https://transaction.rue774866277b69ee92ca3e44bc92db9cc	221	197	19714
25295	https://transaction.ru96683356202070905abce8e7d6e89d8d	219	249	19714
25296	https://transaction.ru78ce205d4c400cfbd2da8e639116f191	278	195	19714
25297	https://transaction.ru1445d722d8c74628a02d3a47b20fe0ac	124	245	19714
25298	https://transaction.ru495780d0e6573649413fba8ad38abb7c	74	245	19715
25299	https://transaction.ruc29b1b52eff6e361eb82461ed12eb729	48	162	19715
25300	https://transaction.ruce79cb5857a92c25b7f7d4f783500401	105	248	19715
25301	https://transaction.ruebf599ed514bb6c73d4ff13211492ba4	30	247	19716
25302	https://transaction.ru7725adb3b3f1e053fd38cc7a9f0c8355	67	199	19716
25303	https://transaction.ru6e3931664ea7df6502de8badd4b227dd	198	194	19716
25304	https://transaction.ru129e6ad859edaa753cb9ab050b8766e1	246	245	19716
25305	https://transaction.rua85491ce213eb6d81bf238a86015ef2e	155	243	19717
25306	https://transaction.ruc619f64033206f7ca3edba3943aef345	222	249	19717
25307	https://transaction.ru6a62192986548e5efb824247a7b1ffc5	166	239	19717
25308	https://transaction.ru740a7d1b3b607bf8ca1d56ab72bf8c60	103	236	19717
25309	https://transaction.ru7f1b9db130407e2a76d6d49da0d8e869	209	195	19717
25310	https://transaction.ruc5f71c94ac080f626ce7265924ed0f52	101	158	19717
25311	https://transaction.ru23dfe7958f2d1b719a87d3d914310678	83	161	19717
25312	https://transaction.rue189347272033f52398443365c28a0c1	185	196	19717
25313	https://transaction.ruf887f72282a0613e16f59df6de29efc2	86	197	19718
25314	https://transaction.ru54169e4632c40cbd8d38f1e84a6952e7	258	198	19718
25315	https://transaction.ru76ba76fce479e8351309e15047b3fb55	19	196	19718
25316	https://transaction.ru2bc89f96d5af36cd7c598b934297491f	139	244	19718
25317	https://transaction.rucfb5349f77a34eeb3a1ba898bb6439c1	157	248	19718
25318	https://transaction.rua71f2d357d471758fa1e9603b11876fc	104	161	19718
25319	https://transaction.rued168e53e90b554b0070a7c933b24528	294	163	19718
25320	https://transaction.ru8614af15fb44064aef685a057aecded8	188	160	19718
25321	https://transaction.ru30e58b4dd09befdd9c579dd155717f27	98	158	19718
25322	https://transaction.ruaa5a6fe2377f08ac0982fe3867d8a7f5	39	243	19719
25323	https://transaction.ru2e40ae8085f17ac4433687e1e7389e0f	162	244	19719
25324	https://transaction.ru4c77567c3540be1a093082a95ccd4e0b	53	240	19719
25325	https://transaction.ru8acd091f4397079480730b183863f2be	242	237	19719
25326	https://transaction.ru0d03d77a17301d4606dfe494a0b5c516	275	197	19719
25327	https://transaction.ru31877f582e3919b904dacb0bb73e5fa1	56	247	19719
25328	https://transaction.ru745285e3c22eba16ea631d3214ff1792	99	235	19719
25329	https://transaction.ru067df70f4270b0ada87e34ba0c573098	227	159	19720
25330	https://transaction.ru5144962274f8eece6372c5b373bda7ca	104	195	19720
25331	https://transaction.ru846a69802d4e9bac5f514f9192f6add2	5	162	19720
25332	https://transaction.ru4ee7de1301701dcd5a57aafdee82e174	86	163	19720
25333	https://transaction.ru24e248ed64cfeaf14c68c03827b4e4ca	177	245	19720
25334	https://transaction.ru81468e550c34d7907b0990116f14caf0	173	247	19720
25335	https://transaction.ru5752606f55215fe07260c09ca6273b69	79	196	19720
25336	https://transaction.rudcf350d7742a77820af79e69b381f887	155	197	19720
25337	https://transaction.ru498117d4e8a99c80184ea5318f58d93c	13	199	19720
25338	https://transaction.rud7bbb5b1a351b9e880f99125083b8327	278	199	19721
25339	https://transaction.rua2c65db5793b79b84cee12f0a6e85405	224	158	19721
25340	https://transaction.ruc7a4c0b6ffd7f8192940ebd20ae4b360	156	157	19721
25341	https://transaction.ru54cde9d072ccb17a2f5b9d13465b2dc6	270	194	19721
25342	https://transaction.ru4bc5638b5219728efb93a6edc7f53ad6	245	195	19721
25343	https://transaction.ruc96ba5ff37706a030597d7b081090995	270	249	19721
25344	https://transaction.ruaef62c0f4f48ffeaaa28441e89c27ce5	135	244	19721
25345	https://transaction.ruf3b756bd983fcc62ee27b90254e3c594	297	244	19722
25346	https://transaction.rucfbf4fce3ca59ea61dec7dd060fea510	9	197	19722
25347	https://transaction.ru29afcd737556812a9ee9125f6b0b7c1c	220	198	19722
25348	https://transaction.rua61637ee2972373d653d7c1fdf5dd632	254	237	19722
25349	https://transaction.ru934acafe69411b44f5eea35ea90b543d	181	237	19723
25350	https://transaction.ruee19d6863c3a9c8babd3bf3166322876	282	240	19723
25351	https://transaction.rub6bb0cf0ce5d701e2205fc99a6bab670	221	197	19723
25352	https://transaction.ru2cca536ad88bf0ff20b95fc037a406d1	228	196	19723
25353	https://transaction.rub4ac909ef35ca8b70f9cb6c95725af4d	69	236	19723
25354	https://transaction.ru8d0d3720bdec8abd01a1716dea0bd57d	118	235	19723
25355	https://transaction.rue73725a9db435ed708a9029be7660bbf	236	249	19723
25356	https://transaction.ru95c9b0d7620667876fe1d6898ee8631f	151	194	19723
25357	https://transaction.rud04b229c8479c2843771479e612a6963	276	193	19723
25358	https://transaction.rucb4f4c21b8543945f0bf7aa84908bfd4	234	159	19723
25359	https://transaction.ruc5607c5d0e093167a8120ca08eadd413	279	161	19724
25360	https://transaction.ru34c120cbc4ad4c712e6fbcd9ff0dae79	155	243	19724
25361	https://transaction.ruac77eb986c2185103c568b1a6ee4b2bc	82	241	19724
25362	https://transaction.ruc393d977783fa188016230b86ed1d4c0	181	244	19724
25363	https://transaction.ru6daf50311b9e3f5d4b5f0eb2adfc1dda	269	239	19724
25364	https://transaction.ru06a3041df8e8d13a4d7af15f310b992d	201	238	19724
25365	https://transaction.ruc1b6b586784191ee3d846b56d9714ac6	287	240	19725
25366	https://transaction.rua7fcaece738720d68969a6b4c7b2fedf	162	238	19725
25367	https://transaction.ru30e9db9fe0419d769c123dc13126cfba	15	245	19725
25368	https://transaction.ru9fc49ae3d85462442efd35828fe647f6	250	244	19725
25369	https://transaction.rud6cdb62727dddb33eec5855c7c96db24	30	196	19725
25370	https://transaction.ru0be120e85b6413bc286b6d8ab8de47ca	185	162	19725
25371	https://transaction.ru19774a84a8e1a591358bd67a071d3984	290	157	19725
25372	https://transaction.ru68257c253080699b123d77a505726e12	70	248	19725
25373	https://transaction.ru45cff9293e039a886ea606fb0c2d4bd6	106	235	19725
25374	https://transaction.ru7d02700a9af2e8d8e30cf064abd81ac0	278	199	19726
25375	https://transaction.ru02f67f20d3e7cfb0ab7f15df72c65a9a	14	238	19726
25376	https://transaction.ru89b297156b1cdc6482e0c7e1296bf9dd	6	249	19726
25377	https://transaction.ru63d7c62f9799fc7ca455babe9f2d65d3	57	244	19727
25378	https://transaction.ruc6378076446888935e4aa6f0c6f05293	199	241	19727
25379	https://transaction.ruc6aba0cea9e6a377c1920df2df3411b6	269	245	19727
25380	https://transaction.ruf3b1d01fa556dce0d570e4eaeabb11d0	140	237	19727
25381	https://transaction.rue863e61a39e954aaf3d06c1134176c80	171	159	19727
25382	https://transaction.ru6673602b91ce92d17d3e3aad1e14bdff	143	162	19727
25383	https://transaction.rucb1573bae1b08da6e634905c371a14c6	156	194	19728
25384	https://transaction.ru29859ab96f2ec29fa3648e8e8e537f1e	214	248	19728
25385	https://transaction.ru3bb2911851ce250c36b73562487027ba	226	199	19728
25386	https://transaction.ru876a4ffcc19e7ed6c278704731a94517	20	197	19728
25387	https://transaction.rue007b88b177b521a6879cfcc807ac91b	197	243	19728
25388	https://transaction.ru71ff49458ce845644262ef9f5595f5a3	91	243	19729
25389	https://transaction.ru10b708fbb611378a4d799620df9498c2	114	194	19729
25390	https://transaction.ru9b8e694f86a8520408564c522c294b37	32	159	19729
25391	https://transaction.ru3a6af972b85c225902eccbbba7aed3bd	3	163	19729
25392	https://transaction.ru5c67693a6485d32f264b342178bad49d	73	160	19729
25393	https://transaction.ru5e2cd9ab6b6c790c8a2551cded78dc4c	214	160	19730
25394	https://transaction.rufa5739b0a82f56a52dbdf64e32a969c4	191	195	19730
25395	https://transaction.ru707ae7a0a246ff4c1d1d5fdf3935ad90	204	235	19730
25396	https://transaction.rua5489c02d2f98ffb52b8171ab01c61c7	292	236	19730
25397	https://transaction.ru44c1b114609c95e5bd01ecbe0198b943	76	247	19730
25398	https://transaction.ru3d78a64bd504ee89441809126e5fa3da	283	249	19730
25399	https://transaction.ruff490e37def26df104646c7936b9b5c1	196	248	19731
25400	https://transaction.ru9978713f6215c46b97e2e78c352fe117	77	247	19731
25401	https://transaction.ru11070873d79e3bc5782082a0307ea963	108	236	19731
25402	https://transaction.ru4e5c08120f2d49c71f44f06faec69b8f	202	243	19731
25403	https://transaction.ru12d7ad4f9cf38b6af12498f8bead534d	170	245	19731
25404	https://transaction.ruf29e14a5204af91df2fcffbdfd58bbda	144	195	19731
25405	https://transaction.ru8969dfbc3770723768a350f6c3515730	154	161	19731
25406	https://transaction.rufee6f8c8f438e62f34980a7d001cf335	266	197	19731
25407	https://transaction.ru115312a816fb8e30efaedf0b27522a33	152	239	19731
25408	https://transaction.rueb26d2bfc3a0228592aa83b51724fb8b	249	240	19732
25409	https://transaction.ru8c9074dbd9873c926f757bd947817643	139	248	19732
25410	https://transaction.rub2cc9f95a70b680e5842509fe10215e9	157	246	19732
25411	https://transaction.rueb3592a4754d87106e1fd687b717cfb5	18	247	19732
25412	https://transaction.ru64a5a9d33f8b4adc2ce34343c5c151b0	222	198	19732
25413	https://transaction.ru8ab52fe86cac0e298bdb85af9fd290af	256	199	19732
25414	https://transaction.rudefb1bd75257117e08bd923835afbfd9	179	197	19732
25415	https://transaction.ruc7ba22a82df0898fe723ff767cb00142	169	199	19733
25416	https://transaction.ru2bd72dd3d3fa6a4ef3755f505b7122d1	14	243	19733
25417	https://transaction.ru9c7e896054e80b835f84837b259d7d08	49	235	19733
25418	https://transaction.ru5f76d2beaeb2db0aa3aebc776c956e31	157	195	19733
25419	https://transaction.rua4ad5d70bc391d6693c753c058ebaea2	102	194	19733
25420	https://transaction.ru20ee9c5910e4fd4f185a510684559f6f	286	157	19733
25421	https://transaction.ru5d94b164cb07023cc9e4003866dbd157	141	162	19734
25422	https://transaction.ru44d618aa1f2f96e82b687e476bf3576a	161	195	19734
25423	https://transaction.rubad7b9e150a892fb24337bbdedb8a3c0	5	193	19734
25424	https://transaction.rubd7af0f276a5dfa97539dbb2d104cfb4	287	243	19734
25425	https://transaction.rucbd06a86bc057c3f4b7eac11c5e760d1	50	241	19734
25426	https://transaction.ruada5499fde73b45216942bc600bf21d2	178	236	19734
25427	https://transaction.ru62d8a6fff3475fd74435aef54d9b96c8	245	235	19735
25428	https://transaction.ru500619c19c7f4f933dc7ac8b5132e54e	25	157	19735
25429	https://transaction.ru1749c32bca93874dfb2f59835f65bf6c	177	238	19735
25430	https://transaction.rufd85e397bf43c9267fb5c60cd4c32a1e	297	199	19735
25431	https://transaction.ru2287e01b77af95606fbd3b8ce2bb5bf8	260	246	19735
25432	https://transaction.ru4f911574cbe461c29f46b7bc8dce8313	265	249	19735
25433	https://transaction.ru98a56fa537c0bc63dfc12c5bd92387d2	215	237	19736
25434	https://transaction.ru30fe8374da489369ece2943b5ec7fb64	122	235	19736
25435	https://transaction.ru641df1165e88fa69156e0b5111a80eb4	98	236	19736
25436	https://transaction.rua5633c3dced3aea219db54cc5648fe80	171	158	19736
25437	https://transaction.rue966786f8a63a2a308e82c2d038cf5ec	238	194	19736
25438	https://transaction.ruc906edd15725954808b920f6ce52ce65	138	161	19736
25439	https://transaction.ru7b6e3742792c1e9460c4d70a5bb873b7	86	199	19736
25440	https://transaction.ru2e577395f009a278eb3aaf5ff35537da	162	197	19736
25441	https://transaction.ru1753c9eaa1f6facd35adf671345b6600	200	235	19737
25442	https://transaction.ruedf90b9d4efccfc851bd2f8c850b5d57	167	246	19737
25443	https://transaction.ru54e901adc63ece59b9ba40284eb50547	255	247	19737
25444	https://transaction.ru9d17ea20a2b197a074266ea44179507a	36	249	19737
25445	https://transaction.rubc691954be9c18643443cdd7244279f4	138	160	19737
25446	https://transaction.ru44323088fafc85ef472d8ee61d89b5f6	271	161	19737
25447	https://transaction.rucb98dbb0836b1670c0ee4a85c3aac17f	219	157	19737
25448	https://transaction.ru78baf4c69a6be93b8f603cd3a0cf563b	301	159	19737
25449	https://transaction.ru44d66b61d11ef6cb9d5ddbf514635732	256	193	19737
25450	https://transaction.ru044fbffe929d28e20909c054621c63c4	45	241	19737
25451	https://transaction.ruaf295bb2b358b2ebdb6db04505a54772	97	244	19738
25452	https://transaction.ru0b9f166f1f75217d3a28dc96e53eecfb	160	236	19738
25453	https://transaction.ru29b7e14fe94b4b651bbb54070080131a	109	197	19738
25454	https://transaction.ru09f53f4626da422fe2efc53e62beafae	58	196	19738
25455	https://transaction.rubae654088e39e1dc6681dd1f8d44df65	265	161	19738
25456	https://transaction.ru201562d4dad52cc799e3add2391fac56	282	163	19738
25457	https://transaction.ru8973e9a8f5bf6c1db8a2a485412803a1	232	158	19738
25458	https://transaction.ru4961b083580862072ad928fa72d2ca58	250	248	19738
25459	https://transaction.ru32d77d5d4199876fa73fc7f2933e0f64	98	249	19739
25460	https://transaction.ru0fffed00e0046ab1db4cd85895efe614	131	235	19739
25461	https://transaction.ru4d7a50e825c65a5ab9bf740492f8abec	36	241	19739
25462	https://transaction.ru92862163706f3d1c175cd8e7a8959bd4	90	158	19739
25463	https://transaction.ru6808c26c766085f167afdcd67cb57657	51	162	19739
25464	https://transaction.rue719500957a51d9d77fd7ac38016ec76	56	160	19739
25465	https://transaction.ru03d60dc39f898f18ede840a645518545	165	199	19739
25466	https://transaction.ru90f9ca7bfda8e36b91723a1e6045ae33	54	197	19740
25467	https://transaction.ru0186bbdb80ee0cfe364ab3659d06b5b9	262	236	19740
25468	https://transaction.rua38fb516ba29004f95cdabbbdeda34ea	201	248	19740
25469	https://transaction.rucf6602f98cc8492b5eb959ad2b2c5709	20	238	19740
25470	https://transaction.ru6abcfb0581bb766fe50332af95482de1	146	240	19740
25471	https://transaction.ru5bdbfef0e824d8cedb8c5da424f4bbac	171	163	19740
25472	https://transaction.ruc4997cce2b177bb208096fc63678375c	139	193	19740
25473	https://transaction.rub0cd9c9188dd69c20e458d686e0827e0	99	159	19740
25474	https://transaction.rua3aa1bf6225a8ce666810210568e2286	56	243	19740
25475	https://transaction.ru9f3c93db69ff9d2386483ea4c9a72b48	171	244	19741
25476	https://transaction.rua45958517604f5cd90d6ee51ad9cfdb6	138	245	19741
25477	https://transaction.ru6dd149c07a65922f985725310ccec232	14	241	19741
25478	https://transaction.ru4458ce2218db105a8fa93dc9f34516d8	228	163	19741
25479	https://transaction.ru5cc50e60c87a9c718d8c8b85919331a9	289	160	19741
25480	https://transaction.ruf2acb4c6a25fadb58168e16921d40e88	167	239	19741
25481	https://transaction.rubac4973afe4c1b8d0d3d51ab0b9743bd	237	196	19742
25482	https://transaction.rue89b834159071e69bc8430231a388ab3	16	236	19742
25483	https://transaction.ru532ebc3543bb61ab59156bcb5d73bdf5	136	158	19742
25484	https://transaction.ru466f2b10141aa2f307dc935992067e77	99	244	19742
25485	https://transaction.ru43138625349c6c7b5049cb18eee37337	123	199	19743
25486	https://transaction.ruc32ab87ac92b5e97477dd2817aaa3078	265	198	19743
25487	https://transaction.rudecc7b709e00cf289cd1dad6000cb02c	135	249	19743
25488	https://transaction.rucbb4a07e4eda09a8522dc930af164afe	120	159	19743
25489	https://transaction.rubfeb001eb5a0b3162d945f1b9cdcb912	228	235	19743
25490	https://transaction.rubc39648d03d80db1a0d8ccc58a5b2f7f	224	244	19744
25491	https://transaction.ru599f03c90e2a15d1c0700643b8169dd9	26	243	19744
25492	https://transaction.ru99533b732b38e19b6f846a2ee35a4601	36	245	19744
25493	https://transaction.ru490d5f9266cb2db871a471d19c20ea65	214	241	19744
25494	https://transaction.rua5c3d981f695a7deb8b59795bd3ac511	285	238	19744
25495	https://transaction.ruf92fe4fdc7d0afd14e51db91225aef74	78	249	19744
25496	https://transaction.rub4242420b8fed26f9b24600685f64114	179	248	19744
25497	https://transaction.ru38f128dd5254e9a5b8f58e371bc55e69	275	198	19745
25498	https://transaction.rucef4cfdf4de9583de839180eec0de3e4	37	197	19745
25499	https://transaction.ru6a027378e914be61314fc164022be710	136	239	19745
25500	https://transaction.rue08ba866feb2b987bd677b864bf938bd	40	157	19745
25501	https://transaction.ruaf95cfa33d508c01d31fe66236485e37	160	160	19745
25502	https://transaction.ru97194d08565841c08a6d1ce3c82da0b3	66	193	19745
25503	https://transaction.ru5bd9b1f7d79f2e91c873e7e41ef0446a	176	195	19746
25504	https://transaction.ru95a450fa6f6240f789fd83a04bbfe9a0	46	157	19746
25505	https://transaction.ru519a3b6ae0acef477701af81e088bf22	119	161	19746
25506	https://transaction.rude99e7fcb253f22464216a905e289024	206	249	19746
25507	https://transaction.ru06aea62d8dd9f9e3da7f4f000d25876b	250	248	19746
25508	https://transaction.ru5f11ba80baaf5ab393cb3d9deb6ddc98	281	236	19746
25509	https://transaction.ru1c4432afacfa2301369a5625795031b8	269	239	19746
25510	https://transaction.rua731a5a45140b18f68641f8def995e76	127	238	19746
25511	https://transaction.ru5db6a42099a907b1feb373b42f27e24d	99	196	19746
25512	https://transaction.ruf591bdf730dca2f1c3c318d7901433d9	39	197	19746
25513	https://transaction.ru5f3d05e1b241f2aae44bdeee3579942d	161	197	19747
25514	https://transaction.ru58c00956063a169911ca6c23d815fbfe	196	249	19747
25515	https://transaction.rub2f29c7e94fef1bf5efd09d2c6405e2b	93	162	19747
25516	https://transaction.rud3d4bc527e3b9e9f778e06dfd3966374	164	159	19747
25517	https://transaction.rud65197fc19ffde778497dc2e51ff28d9	248	157	19747
25518	https://transaction.rue3c8f55e7d661cd992d15f365b6e4b1b	238	237	19747
25519	https://transaction.rud44cd88f9c7de22d2579c1700db9dc63	32	238	19747
25520	https://transaction.rubc1a307bf97eb17921b23331dd18471d	273	235	19747
25521	https://transaction.ru8e8b5aaacf98bbff3e39dc69f2814d36	216	246	19748
25522	https://transaction.ru759dbb1426ce9e8036c27194d46bda7d	145	247	19748
25523	https://transaction.rud278d40a541043c0add55b7433503dc3	299	245	19748
25524	https://transaction.rub5922d0af05d643f92c770818c1b6b92	43	199	19748
25525	https://transaction.ruca05214cf3bad8711534f92686aaf54e	267	198	19748
25526	https://transaction.ru79124100c8678265f73cb1c72a7b7b63	298	197	19748
25527	https://transaction.ru5c7fee52ce115b1368e6012d3cbb713b	227	237	19748
25528	https://transaction.ru3557e4cc4ada794ef3c331b7e9213fef	151	195	19748
25529	https://transaction.ru06ebf1dc66b262793c5a093274ef210c	266	158	19749
25530	https://transaction.ru55aa26d5eacf6488f9dcc6541498e6ea	44	162	19749
25531	https://transaction.ru85c99f381b2d3df4b33a5d96c2007df2	58	243	19749
25532	https://transaction.ru78cba486049b9522d556899edb9f10bd	168	241	19749
25533	https://transaction.ru777647f8abb6fccb27f45db57e030212	9	244	19749
25534	https://transaction.ru2d2e3e04872413899a12b739ac599122	180	236	19749
25535	https://transaction.rubc643bde169316eddd77258668842cfe	268	238	19749
25536	https://transaction.ru3a9a0a7040902e325b601650e886b010	148	199	19749
25537	https://transaction.ru8c99e21e17d04f1de2cba6c75f0982ff	192	199	19750
25538	https://transaction.ru052760bd8e212726717fe6d070748880	157	245	19750
25539	https://transaction.ruc98c9a007214971f974b8358d5c7136f	224	244	19750
25540	https://transaction.ru37736b17959bb3363eba80b58b080c3e	23	161	19750
25541	https://transaction.ru506a11102417d91022272924316a6d0e	48	157	19750
25542	https://transaction.ruc00e300d85cc5e5f0d11a782da9bf045	8	248	19750
25543	https://transaction.rud0153b43c220ebc9bff8235295796fa1	149	237	19750
25544	https://transaction.rud8577e594a9997adcba61f43026396d4	290	235	19750
25545	https://transaction.ru9120a25cb4c1fe2029160721a82060fe	96	194	19751
25546	https://transaction.ru943789602bd4237f7581645b01edab50	265	244	19751
25547	https://transaction.ru7a821a91289963fabd253569e834c12f	163	245	19751
25548	https://transaction.ru614fed3c2d56704df860b3b01823bc8a	258	240	19751
25549	https://transaction.rudb52f4f617014503b2d8d3fc17d5fc0f	11	249	19751
25550	https://transaction.ru40cb76ed7064202a5b8a5ce9cbfb1de4	279	246	19751
25551	https://transaction.rua3efb98822777de56766f50b73f62682	281	247	19752
25552	https://transaction.ru899e5b70d0ad9dd9aef2224cf79488c8	278	248	19752
25553	https://transaction.ru4929cea47f3826ece740953beafd29f0	198	194	19752
25554	https://transaction.ru585d3739de53c32962ed1e6a3263bbf4	236	157	19752
25555	https://transaction.ru9aea036dc9b4f798da56cd02115a4079	84	160	19752
25556	https://transaction.ruc265d807c85bdf9ba1ddda9ef1bbc1fe	80	198	19752
25557	https://transaction.rubca2e3179a514312d7d1e6f79bc68f41	250	197	19752
25558	https://transaction.ru885feaa40db957fb7839cc332184a8ad	18	240	19752
25559	https://transaction.ru3a3c2106d710c9bc46be3a4f547dae86	123	238	19752
25560	https://transaction.rueb6b66d69d1ec76c645d42fcca1d64fa	262	240	19753
25561	https://transaction.ru219de57d5d22d4680157265842f66e5e	177	161	19753
25562	https://transaction.ru1c8d30ab844cadcc65b16736ec380ee9	219	162	19753
25563	https://transaction.rue7adcadf700b1bebcd620a64ff70b50e	149	163	19753
25564	https://transaction.ru2f10f82b2939f2706a132e561ee1e6dc	124	194	19753
25565	https://transaction.ru35498c8f4ff8092c2c74d224aac6e141	201	195	19753
25566	https://transaction.ru1b95c098dfc073465e2c86706271fe67	124	157	19753
25567	https://transaction.rub90f8a80dfa65967b7551b61cb4d1c51	88	241	19753
25568	https://transaction.ru5f6b5a9ed647e0c905024005f802cdef	252	241	19754
25569	https://transaction.ru7f9c9a97edf87e2c0e48bc50002070a6	207	243	19754
25570	https://transaction.rucbc1964aea1f8f827ec0a9f5e28915cc	195	239	19754
25571	https://transaction.rufe448868e32c068f95f56e6460b9ec65	266	248	19754
25572	https://transaction.ruec5de3e8dc6bd121a79794021bf20cb1	275	247	19754
25573	https://transaction.ru5305b2b058eca6149da6c593c6c30c0f	26	194	19754
25574	https://transaction.ru6835d32cd7c53b4255e18c4d8c3eb64b	168	193	19754
25575	https://transaction.ru9c9b99ca6d934d5f49a87743a2178453	118	194	19755
25576	https://transaction.ru4c9b876affaf7f115d9312201aa8cfc7	96	193	19755
25577	https://transaction.ru0567fd5dca02e5b24ba36f0a8f1b28fa	162	195	19755
25578	https://transaction.ru4a95fbf6f8019328c6b43059edb288c9	109	159	19755
25579	https://transaction.ru956837c6a884406772387865a3471fc3	72	240	19755
25580	https://transaction.rud749d0b67ad63cd0b51b761a33e94d1e	131	245	19755
25581	https://transaction.ruc40f6331a9bb2a832f1e0de3d11e4920	115	235	19755
25582	https://transaction.ru508e144fc8e50a11c17d765b91c66da4	107	236	19755
25583	https://transaction.ru2f0676b3473b14e7d2e09283e123da30	184	248	19755
25584	https://transaction.rub208a378b0d22fb4656f96cf9f2a9011	219	197	19755
25585	https://transaction.ru5fd048c18741153003929d65f18e55b3	159	196	19756
25586	https://transaction.rubf3c81428767d81d5d6907315cb587ee	204	245	19756
25587	https://transaction.rufe4763885f07908d06c6f18c7c58d5c6	38	159	19756
25588	https://transaction.ru5234f096fa24b618aa7118ed84733eaa	246	160	19756
25589	https://transaction.ru0496946e7208884b3cfebeca7868a50d	146	162	19756
25590	https://transaction.ru48685a3e6d4604c2d932263da8416d1d	195	163	19756
25591	https://transaction.ru8810cf7e51e449d268cabc3bedcb7764	227	240	19756
25592	https://transaction.ru6efb0052694a5280b3ceb96e232c5ebb	35	158	19757
25593	https://transaction.ru1e8ca836c962598551882e689265c1c5	273	193	19757
25594	https://transaction.ru4e9101a27e90ccf06980744e76749c2c	247	197	19757
25595	https://transaction.ru49dbbd3b54a851bfd141b341204de13a	15	199	19757
25596	https://transaction.ru199009772e4ca19f56558310f10ec666	174	236	19757
25597	https://transaction.ru923313fc85c919f33a07daa5ea9eb367	42	236	19758
25598	https://transaction.ru123650dd0560587918b3d771cf0c0171	128	195	19758
25599	https://transaction.rua74f46e7c441a4ec4567b131b8486a38	232	194	19758
25600	https://transaction.ru318bdd35ad06e9b6d3b3facc23624b4a	151	158	19758
25601	https://transaction.ru13b78fdbd9b406c40959611b276d3546	33	198	19758
25602	https://transaction.ru659778036b51553634994651ce5e5e05	221	249	19758
25603	https://transaction.ru26407a97936cbc5db3008a8a92ee9cce	234	249	19759
25604	https://transaction.rued0af692974563112d716586c8f925e8	111	196	19759
25605	https://transaction.ru61a0931435aa19a325fa236f01330b76	210	199	19759
25606	https://transaction.ru81e79037f4aa5119167d121c9b8d7c59	221	158	19759
25607	https://transaction.ru6acaed7c793deb62b9214738f60079fd	123	195	19760
25608	https://transaction.rue9244417163ef659b2b41038366bbff8	28	243	19760
25609	https://transaction.rueb4cf0d572fdb9a9db7d2d1ea6b66857	152	198	19760
25610	https://transaction.ru15efaf7617633e0aefe1de1c5c12e35c	222	197	19760
25611	https://transaction.ru69dc265d6c5eda5cda25c1fe3d49972e	155	199	19761
25612	https://transaction.ru870773fe31ffd974fa72fab63effe9d0	230	197	19761
25613	https://transaction.ru18295c622647c5f8291f47cee94a517a	227	193	19761
25614	https://transaction.ru325a09bfc61a2bf28c271d89bf6a5d7d	116	194	19761
25615	https://transaction.rube2522585d4ebecd844ec079f2ea9cc4	211	236	19761
25616	https://transaction.ru0fce0f7ddbdbfeb968f4e2f1e3f86744	124	241	19761
25617	https://transaction.ru7bad09e8a4e3d4998a1f1ad7ef69b22c	185	247	19761
25618	https://transaction.ru3a94e666a4189c1d79d8c56ae07715fb	172	248	19761
25619	https://transaction.ru1ea8d8a504af7dcfd781f96b99e3987c	117	247	19762
25620	https://transaction.ru9c1d6eea6b1ef5e60279d4a70e303d32	165	246	19762
25621	https://transaction.rucafc82d3fa352ddce28f5cd874c57cdf	61	195	19762
25622	https://transaction.ru406f4c4ad120d0b0198cbeb11075d314	10	163	19762
25623	https://transaction.ruaa0f9de3c3f38177051c3c8741dac037	82	157	19762
25624	https://transaction.ru2af77062e89d177ad17ebfb7139ea69d	231	241	19762
25625	https://transaction.ru2ab162f387328b4648ea0a317f030200	210	244	19762
25626	https://transaction.ru7a16e0fbe75622dfb2ceabfb1db85980	140	243	19763
25627	https://transaction.ruc222c24c57cce8db255bd4cd0ba1497a	73	247	19763
25628	https://transaction.ru4b5c3939c79dcec4e477a14c4e343a66	91	239	19763
25629	https://transaction.ru04ca8a5f9561a18e453124c7de8cd6b3	30	193	19763
25630	https://transaction.ru6b262cb1334161cc6e3530042b7c70c2	284	163	19763
25631	https://transaction.ruef3dcf69d5859af6a5be1fe14917b47f	146	235	19763
25632	https://transaction.ru26fd3193cb98cc7e80da4e39201e108a	133	247	19764
25633	https://transaction.ru60cb87c3d9b787eeeb7669eecb8fa615	165	244	19764
25634	https://transaction.ru26d5d3b9e735d4ffdb27116705c4ddf4	17	196	19764
25635	https://transaction.ru8d9ae7772914ec9336a739531c880672	107	198	19764
25636	https://transaction.ru2bc5a465db62a5affd73ac03e8411bd8	202	163	19764
25637	https://transaction.ru89daa89c41ffb71f97a15ad3ae830a06	122	157	19764
25638	https://transaction.ru68d4a9714f26b0a164af29ce8540e462	53	158	19765
25639	https://transaction.rud00c52e11e94281b08a0b7bd1c7509bf	9	162	19765
25640	https://transaction.ru8f725bcbbadaf3cbd1dfffe3fdd0e3e6	177	194	19765
25641	https://transaction.ru130ff6c737da473fd297985dfd6925e0	138	195	19765
25642	https://transaction.rub3ec53dc623a049b938d33d78373b747	126	235	19765
25643	https://transaction.rub7a12089bb311fc94dcad4ed8ce8ac5b	230	247	19765
25644	https://transaction.ruadaa37668efad0ffc3217b611f95428f	12	197	19765
25645	https://transaction.rudb6661c7ac08218f7d6df880231a987f	3	240	19765
25646	https://transaction.ru09b19fc8b6adbec272aafa78e5a18392	126	235	19766
25647	https://transaction.ru487ead4e3251a9a206a76d6463c8bf5a	191	236	19766
25648	https://transaction.ru15c60e45c4498d98541fa6e7e8cd7a8e	182	243	19766
25649	https://transaction.ru00b0611966f9ba6a606a7c97ac0604c9	240	195	19766
25650	https://transaction.ru0e653541513f3075b53e978c872b80cc	173	197	19766
25651	https://transaction.rue8a974ba55538cb8a6e90eb2845e2a26	266	249	19766
25652	https://transaction.ru94263036f25a1ad6ec65e2d518e5dd50	147	245	19767
25653	https://transaction.ru963fb49c639393386a3db9f1912849a9	104	243	19767
25654	https://transaction.rua690da0e25abcaa2cb52d3f9756b60ed	301	238	19767
25655	https://transaction.ru7ec0dbeee45813422897e04ad8424a5e	241	196	19767
25656	https://transaction.ruccc08dad82190e0bc76891ef5c230e21	82	157	19767
25657	https://transaction.ru3195d90e81265c827960f0c5b7496e5f	157	162	19767
25658	https://transaction.ru74b8eff80876102c66f2d261cf67a461	61	160	19768
25659	https://transaction.ru94af8252ecc535e590086e2530afc4f1	157	157	19768
25660	https://transaction.rub4e4be8702050479dce364e0bf9018af	130	243	19768
25661	https://transaction.ru7c1700abc941d316a827325c1dfa3fc4	113	248	19768
25662	https://transaction.ruf4c1d2e2afbebf65cbdd56531805d575	30	199	19768
25663	https://transaction.ru832903af29e72a733ffd18d5959fcae3	25	240	19768
25664	https://transaction.ru279d54ce3499da1b17f46576daf93ebc	120	240	19769
25665	https://transaction.ruc16e0a90a03d9c8f0ddcfc2ac3d3cd48	229	245	19769
25666	https://transaction.ruc7889b06e78e86de0cbf525c31290c44	96	159	19769
25667	https://transaction.ru0da3f0938c9eff40cb188a6a6e66d065	11	196	19769
25668	https://transaction.ruc4f2d27748af132c32b35e08531b5800	246	248	19769
25669	https://transaction.rub53b0f7ffd43b1af3b87c75c048b83d0	67	246	19770
25670	https://transaction.ru818e7f0dab23b2e1ec34cab83e82c05f	25	249	19770
25671	https://transaction.rucafa4e2314cad6f9ce07f2f73e1c0ee4	236	248	19770
25672	https://transaction.ru6dcdd2a686735279ff58d0b2221fee13	252	245	19770
25673	https://transaction.ru745deb27908e12d6e7b9ca4c0c8f3695	84	237	19770
25674	https://transaction.ru7c8b8e75238160b1d40aa6873dea6671	278	236	19770
25675	https://transaction.ruaeb2fb7f71042b3f42eb6f30914d5808	55	194	19770
25676	https://transaction.ru67a6e3cd62f6c158d99c923334e6ec8a	97	162	19770
25677	https://transaction.ruddb421e0eb54754bcc77609cbce22843	145	249	19771
25678	https://transaction.ru0c3a8cacdece1d93c23d9289fdf9ab1d	70	248	19771
25679	https://transaction.rue6f95a25d939b430ef7bdbdea51e60e3	74	241	19771
25680	https://transaction.rudef5bec8443e5efd2872ea37be2a8a9a	88	196	19771
25681	https://transaction.ruad4eb8cf34bb6ddb46242b42c96cc125	161	237	19772
25682	https://transaction.ru409ad83a0aafa812f4be5fe545e65530	82	238	19772
25683	https://transaction.ruf6e70a00952dd0ce1f513fe4aa5d27d4	12	160	19772
25684	https://transaction.ru549fbcedc81aeae88e6f566545d7baf3	222	195	19772
25685	https://transaction.ru47521e2263b131bbd9e105387126b200	166	236	19772
25686	https://transaction.ruc0723244c13e198cf2e3afe89c95ff58	124	239	19773
25687	https://transaction.ruf57394fcc93af5ef8928ab9b85b02506	136	246	19773
25688	https://transaction.ru7cf0ce3b423659f8c013f132aa47c577	256	248	19773
25689	https://transaction.rud1c1cfb2dfbe725a4f1e1ca4f3440fe1	281	199	19773
25690	https://transaction.ruf7fd901cc85263e980f75654b1e7b91c	149	198	19773
25691	https://transaction.rue628120e76df7f75da47544e1c0a93a3	12	193	19773
25692	https://transaction.ru9fc139220152a28613f39cc3d6d3c379	88	195	19773
25693	https://transaction.ru4456aad7272a7a3cbd67c58b00981fac	37	194	19773
25694	https://transaction.ruccb6670be2b4249b99d3ff3bceaa6a38	127	163	19773
25695	https://transaction.ru834dc4cae405cbf0480c2df69f9a8fc3	79	161	19773
25696	https://transaction.rucc5e179d8d1fcf1bcbc37c644933d351	40	241	19773
25697	https://transaction.ru77d6683f50825f81e9307c6a3f6ef6b2	190	240	19774
25698	https://transaction.rud1eb1e979a96aedcc27e9635fff99c35	255	238	19774
25699	https://transaction.ru7e55187885051f6d8193f8216a614d42	187	160	19774
25700	https://transaction.rudfe8c76c72bd59f3035a45b804337e4d	180	162	19774
25701	https://transaction.ru19e0f1849813c7480a1e8f9c1f67ee69	180	157	19774
25702	https://transaction.ru904c18a30c371ad6d720d649de858b6d	259	159	19774
25703	https://transaction.rue84925bc21765e40f2420fa1d16446ef	115	163	19775
25704	https://transaction.ru4b51fc800c53eeef770b0d8bcdd17976	24	243	19775
25705	https://transaction.ru3189389ea103db3991bd7cbfe3ff787d	252	161	19776
25706	https://transaction.rucfff8c76832c56d2f1a048c08203472a	299	235	19776
25707	https://transaction.rubcaa914fcd2042185ce0f1f67403f237	241	238	19776
25708	https://transaction.ru88c60f5177326ffb34351e0944af1916	72	198	19776
25709	https://transaction.rue5ae5b34f10806a84047f22aeea97fbc	281	197	19776
25710	https://transaction.ru0679030439b0fe342c6b043cd7c6cd34	130	243	19777
25711	https://transaction.rudc297495e322672482ae5268e3536cda	44	241	19777
25712	https://transaction.ru2ebd7b2a288e26a2219c57e71b659098	238	248	19777
25713	https://transaction.ru67c9851b0100e3bae408fb8525ce0935	273	240	19777
25714	https://transaction.rucf419b6242ecd663a3d2f6f2b1b7d0c0	47	236	19777
25715	https://transaction.ruca313d46f3d80c44a9ad570b8d4cc1e9	275	243	19778
25716	https://transaction.ru22c89ccf05308dd3be6eb90f940b0041	200	161	19778
25717	https://transaction.ru7c65b6f69c42bbf1e9b6b55e8ba6822c	217	163	19778
25718	https://transaction.ru82a736232a6f81e7014395018c6e672f	96	193	19778
25719	https://transaction.rua3ac08e3bf82755dcc12faf0b0d5f11f	277	194	19778
25720	https://transaction.rud97c6a476870b151c113b6661cb30407	100	238	19778
25721	https://transaction.ru969aaa41a73416d44cad9a41e0a18001	126	246	19778
25722	https://transaction.ru7d024badb32c67d46407382b151e07c0	210	247	19779
25723	https://transaction.ruf35d2ebad72de23e570c4f749d4f62c2	287	245	19779
25724	https://transaction.ru9a6e42f55e5017447a1d697114cb3279	242	244	19779
25725	https://transaction.ru7351b92504265e6f17fa0fd927478224	237	236	19779
25726	https://transaction.rud395e2654e26d95535881b562e39749a	290	197	19779
25727	https://transaction.ru4e346c57985674edd36831cbd29fc940	147	159	19779
25728	https://transaction.ru6df182582740607da754e4515b70e32d	140	163	19779
25729	https://transaction.ru9ae0a55d7719a08457c5086c4f4a8377	11	161	19780
25730	https://transaction.rua32b8a8771e55024b1107c42d25cc372	81	163	19780
25731	https://transaction.ru5fab33209dc5e9c256a0f23c0cc405b5	145	193	19780
25732	https://transaction.ru03c93afdabfcdf32a15f6f058c993163	70	158	19780
25733	https://transaction.ru9b636a0b014d877c3bcea00942d358d3	48	241	19780
25734	https://transaction.ru6733a6cfa952e637e886d8041fba79ce	137	239	19780
25735	https://transaction.rue4e2602e040333a9d03277cf9312e1a7	18	240	19781
25736	https://transaction.ru19f98fdf93f4aff42c16b73391644df2	239	158	19781
25737	https://transaction.ru735f8e8663134be02cca5e56f788477a	208	247	19781
25738	https://transaction.ruc240f03eebfc972a09dd76c604bd1213	251	236	19781
25739	https://transaction.ru8639da06a4dfd017d7c1fb523c13d5e4	173	197	19781
25740	https://transaction.rud722c144fe3a47f84726d9568917420e	131	237	19782
25741	https://transaction.rueb5249560c04cfe0e13282feca730a0a	183	239	19782
25742	https://transaction.ru1e4261f0fb4e37420a79d14bfad0e2af	251	195	19782
25743	https://transaction.ru4094ecc82760d1e872a19705ac9aebd4	231	235	19782
25744	https://transaction.ru28c9e0b168538f9dea25f0ecdce748be	74	244	19782
25745	https://transaction.rue438d6d82090158d615accbf0e8179d1	161	245	19783
25746	https://transaction.ru39a07030761de22ae5f0deb40e7513c7	96	248	19783
25747	https://transaction.rucb8abfdcfd5c73721ccbb7bcedfc84c3	211	199	19783
25748	https://transaction.ru39d838ada94bc7416ea65dff9d4c4371	70	194	19783
25749	https://transaction.rue6e4223421e4e4021aa3d7fa7925cebf	243	163	19783
25750	https://transaction.rucc7146d26842552ef3ae620e96a796ec	79	158	19783
25751	https://transaction.ru9448268a327b7ea44c4202857d437b68	298	157	19784
25752	https://transaction.rua9f1991ea3f1cfb626e02cb9e229c882	29	194	19784
25753	https://transaction.ruf5ea1409a059f913f1eb69f73e0b25d4	202	161	19784
25754	https://transaction.ruc0000f804842e446e38169e6df11cf4f	165	249	19784
25755	https://transaction.ru013d341a8d77ab1008f3f404ad9d38e7	299	247	19784
25756	https://transaction.ru5dd1add52b86c05bf4a632267495ddae	250	243	19784
25757	https://transaction.ru86c4916ae17ea790f61ea47a99052e15	169	244	19784
25758	https://transaction.ru7a4c5a9f74746dd355d73ddc8a64c8da	286	236	19784
25759	https://transaction.ruab57f88f849d0f5f185d70303f1904cd	29	236	19785
25760	https://transaction.ru59dc98428cdf433114340123d003b236	107	246	19785
25761	https://transaction.ru57dc01e2597d1c4a006e2fbe14c32099	95	239	19785
25762	https://transaction.ru781626812ee0c887494317aaa310e543	99	163	19785
25763	https://transaction.rub276cfc0a56dcc98d582690014a1584d	251	162	19785
25764	https://transaction.rua12067bd8bc09dd2748e8620759da0f6	142	160	19785
25765	https://transaction.ru21d13e77ab1952a2c83d6ad04e68a3a1	292	159	19785
25766	https://transaction.ruce8e8c458e5bcf27cc78686d07506d6b	59	158	19785
25767	https://transaction.ru3e73ca9e9f05919c568f4d9444280a21	17	199	19785
25768	https://transaction.ruce59f47e212c0757d5acd6824dfd75f2	152	246	19786
25769	https://transaction.ru0467100d7d62bdf9322de278cffc0483	129	163	19786
25770	https://transaction.ru762f9a311d368ba6b2d4786c2d62d5b5	70	193	19786
25771	https://transaction.ru8e9cfb13c0426a18f0459d0aa5873ca2	242	245	19786
25772	https://transaction.rufffa70968422d2ef6243be1127fe1e40	194	199	19787
25773	https://transaction.ru6be40e0bcc7f772b137925c0632aec8f	134	235	19787
25774	https://transaction.ru8ee52e47d91e74efe4d208bdb2995cfd	133	236	19787
25775	https://transaction.ruf1471eafcaa1911b343e9afb3c024c9f	257	163	19787
25776	https://transaction.ru04e3068982b951f35edf9f51872b1774	70	161	19787
25777	https://transaction.ru3a2a9a0037784123a78da2a737f11682	132	160	19787
25778	https://transaction.rube7a4d24171db56519e2d801453157a9	66	196	19788
25779	https://transaction.rud2d76281d6fba903cfef5831752d2fb2	31	199	19788
25780	https://transaction.ru6df9765fd939c9ae66cff618fd169f4d	233	244	19788
25781	https://transaction.ru1fe5acca41a4ec4d5c38d8be78ef3af0	264	238	19788
25782	https://transaction.ru9bb386bcefddac734684b9eda72d5f01	195	240	19788
25783	https://transaction.ru0d28318cff9c8627923bb7d1e2297812	151	240	19789
25784	https://transaction.ru6cbf49cb9b4fb3e37c8ad9de307a3cfa	158	237	19789
25785	https://transaction.ru6533f6c730bfff49fceaa421df2976c1	107	241	19789
25786	https://transaction.rud762b798545c475a6f14343e206a0436	85	163	19789
25787	https://transaction.rub9d1b8ef3ef33aa0b7d80d33ebd7a958	73	157	19789
25788	https://transaction.ruc6977bec0c6192af6ea77c9c0c66cb0d	65	158	19789
25789	https://transaction.ru038b522d0462d80137a0fc2aabeba2d8	256	194	19789
25790	https://transaction.rud17ece9cef9faaf0c5818e3b974272e2	42	197	19789
25791	https://transaction.rucd075968c4d5b5f1c075de4854535ec6	25	249	19789
25792	https://transaction.ru168df5a5dcb818735de51477525f6f5c	91	246	19790
25793	https://transaction.ru7a5f41757b109246f3f9fb4527464aac	179	194	19790
25794	https://transaction.ru1eaf2e946e827c710a4e4e108f4565fd	274	193	19790
25795	https://transaction.ru2ca2fd7260f2a7e311090609bae58808	165	161	19790
25796	https://transaction.ru14154f9a75ed2e2a11dbb223ad10525d	104	158	19790
25797	https://transaction.ru5e96e337f822682a0cafebb812b3e5aa	273	240	19790
25798	https://transaction.ru3e7406bd68c52fa64d5892c30281c532	286	241	19790
25799	https://transaction.ru1fb7dad83b2245be35f0ae4805b5a30f	65	235	19790
25800	https://transaction.ru3d8f6434efa84941548f041b6c3d68f1	76	236	19790
25801	https://transaction.ru1bbdfc07f3c5385211d61845d1da439d	269	249	19791
25802	https://transaction.rueac20c4710cd4c6c495d6feb75efd1d2	281	247	19791
25803	https://transaction.ruf477b67aa245cd946a60d9880cc1656e	257	158	19791
25804	https://transaction.ru0c53909b308e80cd6b0fd94a4796e1c0	296	193	19791
25805	https://transaction.ru05364104b5b8965d36b009ab184aba3f	147	162	19791
25806	https://transaction.ru2a2452cc7b1050af2f8e460fdff708d3	20	161	19792
25807	https://transaction.rua3590023df66ac92ae35e3316026d17d	153	160	19792
25808	https://transaction.ru4b8068e769fd0d8cb246e1d0dc1c3dc9	99	158	19792
25809	https://transaction.ru6e4e1981c2cb89f1c4eda1aea8bee13f	100	238	19792
25810	https://transaction.rue44f8cf63970db5c2df0a18153bcdf49	295	235	19792
25811	https://transaction.ru6bd24c31eae0186fb2f7aaf015a462e3	299	244	19792
25812	https://transaction.rubc8a182feca92a2d5f92c286ee6bc133	120	199	19792
25813	https://transaction.ru11857f1f1f2cb0aa20958acc450e0cc3	257	197	19792
25814	https://transaction.ru73384be5609e2ebf41af6c58fd289349	121	240	19793
25815	https://transaction.rua8f9e7ba9797db780c6e8dedf9eb46ca	116	239	19793
25816	https://transaction.ruc2c81289eb5d4963ca15ef3e5ec9ca0c	165	238	19793
25817	https://transaction.ru4dad26de916a6570f06503163a4ab660	182	158	19793
25818	https://transaction.ru9f29636a291793d0e51230f60687eea8	157	162	19793
25819	https://transaction.ru5d2e71310575bb99fa40a0e57c204af5	82	161	19793
25820	https://transaction.rub3ef01fe927354c6801e5899c0de5aad	283	195	19793
25821	https://transaction.ru8a675ddedd719b13c12f2954886ab6b2	109	193	19793
25822	https://transaction.ruba2fd310dcaa8781a9a652a31baf3c68	161	241	19793
25823	https://transaction.rue61782b67d4b3cf3649fd0562d0dc66a	186	245	19794
25824	https://transaction.rufb43c4ae671af6a6e15c8522028e6dce	230	244	19794
25825	https://transaction.ru8710956effa3f2fd99210a0097f3f881	269	196	19794
25826	https://transaction.ru82d7fe01553a8e6cf905a3eac3e73c05	151	193	19794
25827	https://transaction.ru887838ad12fa30cea255061127fdbb37	107	157	19794
25828	https://transaction.ru6303491a99fb8cc79911fd5fedb9fffa	123	161	19794
25829	https://transaction.rud0c797d0216457bc3ca5e3c929af48eb	77	161	19795
25830	https://transaction.rua12cae985754ca9c949b7f751a59a411	107	163	19795
25831	https://transaction.ru83a2952083608705393381709d58cbe8	2	159	19795
25832	https://transaction.ru9b9bcad7c75e9f113854982193795705	237	241	19795
25833	https://transaction.ruce8c1a5a3861fc5f2074c88736060e88	214	248	19795
25834	https://transaction.ru06c18b3b6efcda74c9893bb840acd28e	140	235	19795
25835	https://transaction.ru36806d2e0516d75d3d5d53b6d0eef5d7	298	236	19796
25836	https://transaction.ru6e20ada710d10bfbda3d1d5dedf466d9	243	245	19796
25837	https://transaction.rubf5b30d27c05dbceaae7e54731f823ec	224	157	19796
25838	https://transaction.rucddb91e2bcd1b3e9d27c6033fa4e7db5	281	163	19796
25839	https://transaction.ru4d451b12b4a18c0dded2ba0979b1d3b7	86	237	19796
25840	https://transaction.rud95c83b7ab165c49ae4289eaffec531f	47	197	19796
25841	https://transaction.ru63c0bafc8a9732ad9776a53ea5bb474f	90	198	19797
25842	https://transaction.rua14b3a3c4ef758781b4deddcc2e3128e	254	196	19797
25843	https://transaction.rud4c45698a946146c0f7297a6906a7192	41	159	19797
25844	https://transaction.rufd680885d3556063ac9bb1de9139aabd	22	157	19797
25845	https://transaction.ru4aad45520e90413356ab8e3604e68c5e	181	158	19797
25846	https://transaction.ru2a20f6cbeb75ec02130d5c2d52857c54	299	235	19797
25847	https://transaction.rue4f86d6f503509a2acff4e6198ecd202	213	236	19797
25848	https://transaction.ru5013464979fc99f8bc735c9bf94e0561	48	247	19797
25849	https://transaction.ruba01dce02a217f7f5dc91987ecf7b4ad	233	248	19797
25850	https://transaction.ruc087ebfea6a872186c5ed113519b1c0b	286	199	19798
25851	https://transaction.rucb4d06fb9e320f0aaac8d7379b08616f	154	197	19798
25852	https://transaction.ru838885be793017f922855cef3db44b2c	18	245	19798
25853	https://transaction.ru993deba152c4303b109fe75bd6095d6d	288	244	19799
25854	https://transaction.ru37b2c7f51d1e00e8527739c37103ed79	280	246	19799
25855	https://transaction.ru6f46db1451d72951fa6eec0e1cccd6bf	239	247	19799
25856	https://transaction.ru15a14528f3012dadff9f586eb04bd147	63	240	19799
25857	https://transaction.ru59e0187bfcb0ef760335871e5cfeadd7	272	239	19800
25858	https://transaction.ru808520f36f6d5856b09c4d42f0f7f062	132	238	19800
25859	https://transaction.ru60454931a60de4d8ef412b9f663fa3de	221	159	19800
25860	https://transaction.ru8a0a14f79b719e64537b060d71e691c8	113	247	19800
\.


--
-- Data for Name: viewers; Type: TABLE DATA; Schema: public; Owner: sergey
--

COPY public.viewers (id, login, password, name, surname, patronymic) FROM stdin;
2	32a8216baa0bbcfbe47d35cbeb734643	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Кузьмин	Виталиевич
3	11861fca003eac39d43d9671e4cf0905	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Хижняк	Анатолиевич
4	0be7d9fa86c7107d8a75ae815444d08d	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Морозов	Максимович
5	b232a1390a9e8e4326dbbb195e079370	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Фокин	Эдуардович
6	26c33683d59cbd94b288ff1e1ff550c4	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Силин	Виталиевич
7	0aa4301a402d65b8e8b8e04330ab08d1	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Медяник	Михайлович
8	be028a263690e51aef8b8dccb1e4aaef	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Николаев	Васильевич
9	2a5ee05ee23a033b87e3cb0122ea1677	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Авдеев	Богданович
10	d0b82e5557b252f81f8f43041784a525	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Королёв	Борисович
11	8fe507a41ea8bbb92ba77cb8f26fb603	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Некрасов	Александрович
12	456e77aa29135dc3607ec7c148a5a122	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Петровский	Леонидович
13	93b3dc9c0cb1ea06a4e0359a801311dd	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Агафонов	Станиславович
14	192232ec4f75d822e291332c35f07c1b	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Трублаевский	Борисович
15	9a2ca6701a032efdf795f08bba7e978b	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Захаров	Александрович
16	0154a6e4e63e3cd15e3acbe15273a0c2	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Тягай	Дмитриевич
17	06c83b46a4db9fe40270faefb7e58726	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Андрухович	Борисович
18	30caa2b6efc3af6114b56bac59e1ff21	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Макаров	Вадимович
19	1835ed2656a3c7c174acb7d452022dd7	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Белозёров	Максимович
20	875d259ed18e3b4e6aef39380bf3a415	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Терещенко	Артёмович
21	2e33815c43d468dda6e9c9749c9a658e	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Ковалёв	\N
22	909f71a47a61df7dca0e173b8abf6dca	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Кузьмин	Виталиевич
23	1c0bf563d7312bd7dc1bc7cded1bae59	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Хижняк	Анатолиевич
24	473ae7cd74313f5ed76ad9493b0ababa	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Морозов	Максимович
25	000842ab87c4cd7256d449549ec2a85e	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Фокин	Эдуардович
26	26ec1284fdd6f7ae8fb4fb84d152bf88	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Силин	Виталиевич
27	5e85ba23f98f58edacddae73222498c1	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Медяник	Михайлович
28	92a5584501c2ef0823eca5181bfcc385	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Николаев	Васильевич
29	63df414205109f4778f9edbeed07d44d	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Авдеев	Богданович
30	4cf2e12fff8254fed057f0c64f92cbf4	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Королёв	Борисович
31	cdf209c5899009ffd46db48720ced86d	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Некрасов	Александрович
32	9a29ec8e27ae6b0b7edf9a4abd742039	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Петровский	Леонидович
33	2905a7b1fa5a427f2232cf0c9bafdb69	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Агафонов	Станиславович
34	a4d3d485e4208393789c2afd064e6d9d	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Трублаевский	Борисович
35	ba7eb68ec6f5710da42772d5028549ea	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Захаров	Александрович
36	b288eb1a4e0480714e8afeab477e57b4	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Тягай	Дмитриевич
37	3c56b9742ae46f54aab409363d3ad231	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Андрухович	Борисович
38	9886268ff6fd9c07315e8d55543e147f	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Макаров	Вадимович
39	44c9bb05c71b2983764b81c1468188c1	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Белозёров	Максимович
40	b6c302e9e92cbf1a96441ccb3649d3d7	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Терещенко	Артёмович
41	424151bca522c9f7ff942f9fba4518d7	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Ковалёв	\N
42	3f6a804f71ff64b04b6c3d8d5fd37294	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Кузьмин	Виталиевич
43	8f35617ef46d67640bfa164295fe1bff	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Хижняк	Анатолиевич
44	2b0b92ac4f513145238625022b6022da	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Морозов	Максимович
45	d6955b490816d74d67f5d8346ef793a1	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Фокин	Эдуардович
46	c6a84dfee239d21d542c46ae3b75293c	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Силин	Виталиевич
47	73866d204449dbde12d0765d8516b8da	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Медяник	Михайлович
48	682fc5023c8b90d2e156defac5b47844	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Николаев	Васильевич
49	f18689327e9ecf8186e0a163c01e4c31	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Авдеев	Богданович
50	a9cc76d78dfe23f787cc95f4418db090	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Королёв	Борисович
51	6600b7396f965bdb049043e9e10c9f8b	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Некрасов	Александрович
52	023b2a9da7b2a52439bccfc3bd772e15	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Петровский	Леонидович
53	0f8f24504aaa6d2c98d55e582c6d083c	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Агафонов	Станиславович
54	65ec0f58fdacccd39de5ca0f919a6382	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Трублаевский	Борисович
55	3b7212e32784ec967135524fbecc258d	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Захаров	Александрович
56	f3afe9647e058b5e85f0bfafb3f6a026	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Тягай	Дмитриевич
57	f506490e58d73c411ada5ab8db9d3633	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Андрухович	Борисович
58	69975496609f817fecabb71cf4b9280b	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Макаров	Вадимович
59	a69dabc5f9e3a5fff86a10b64ee64c1a	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Белозёров	Максимович
60	8f749fb6bd2d167577d37c6b1f829d6f	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Терещенко	Артёмович
61	b1087566a0df452c35b728e7d19b1222	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Ковалёв	\N
62	d78ffd3a495db7b259f937e62c2d8698	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Кузьмин	Виталиевич
63	d4847f2f5cbe78de1da230d3aabd5420	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Хижняк	Анатолиевич
64	34d0916eac37ec785414938380d6fc87	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Морозов	Максимович
65	9d2014c39349009f85bd310461a78dbc	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Фокин	Эдуардович
66	84601a3ec2ef17e43169a77e3a9805aa	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Силин	Виталиевич
67	6be1e362649e94f385de4187b29a7939	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Медяник	Михайлович
68	c32fbe54f004036dc2628763d11c8590	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Николаев	Васильевич
69	7d8af3e890b7e0fed479ec1df8e1fd11	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Авдеев	Богданович
70	411238ef0447f3d950ed86da7a5bf7b2	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Королёв	Борисович
71	2e529315356ebcbc88c13d5b163b2ee8	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Некрасов	Александрович
72	c17e1992342eaf81a12241be1b9144ad	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Петровский	Леонидович
73	3be3a1ec5d97077134cb7fd2ad264d73	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Агафонов	Станиславович
74	d1f6f6cc7c5a83f4351eebb1cfbf9a08	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Трублаевский	Борисович
75	23843f347616cf11ba6c5983fe1ae1c3	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Захаров	Александрович
76	fefc5be88799f1a376335969391f4136	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Тягай	Дмитриевич
77	211dd63fa05ea4555defbc73b249b2fb	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Андрухович	Борисович
78	1c9fcf73fe551a1b1fc102eed6405b7c	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Макаров	Вадимович
79	e78a0d8a19100ae113413292d5c3f019	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Белозёров	Максимович
80	3776310234d886be4a016a447665f2bf	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Терещенко	Артёмович
81	dca99d913ebb7153ac220d5fe4c43c81	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Ковалёв	\N
82	4b0a1cbed5b22c86a314fcd8a229a886	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Кузьмин	Виталиевич
83	1d67c3bb237a6a2f09aeb8527a01356c	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Хижняк	Анатолиевич
84	ffce9d49c5d3150c19cca4281fcae707	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Морозов	Максимович
85	7b9747f7797028ca07952c7c91b31021	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Фокин	Эдуардович
86	e00e5aaa33349c564060ca790a68384d	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Силин	Виталиевич
87	47e98d4bacf1a5236a557a594d3cd1c5	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Медяник	Михайлович
88	d53d05577c36639d34256108fa6d7ccd	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Николаев	Васильевич
89	94dbc3eacf62c2c6ad6665a218515511	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Авдеев	Богданович
90	c2b8fd174eba6d9dd39539d28f397785	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Королёв	Борисович
91	52333e4d6b0f5e38ffcc0f0944f28be7	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Некрасов	Александрович
92	1bbd6399203efee334d06d23602abfea	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Петровский	Леонидович
93	e870e3318db039b3f69265a122289daa	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Агафонов	Станиславович
94	978a4e74e9e9db234fa291c971bc8098	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Трублаевский	Борисович
95	085aa8f63019e9241739cad921189c8e	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Захаров	Александрович
96	17de2b8456f191765ca9d0524b9772f7	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Тягай	Дмитриевич
97	5476688171de3e92c6c16147e70422f4	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Андрухович	Борисович
98	d42ae47dbbb5c32715510b0afaec9d23	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Макаров	Вадимович
99	c3cff2b0a6ecad7ca49a0722cba8641b	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Белозёров	Максимович
100	51cbbbd24dab69942aeb68066561d4f5	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Терещенко	Артёмович
101	323f5aa94f952b2ed18749c33db1cc67	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Ковалёв	\N
102	2137e9e173fb556a3c7261498f365780	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Кузьмин	Виталиевич
103	658d6f936470e931ce854a8fb0bcc930	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Хижняк	Анатолиевич
104	f9e29339785824823c8e7277114b4d27	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Морозов	Максимович
105	deab5b98b7fa11bd5e4f9e9eb27124b6	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Фокин	Эдуардович
106	422fbc50fe07f0ea58132377ad550b36	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Силин	Виталиевич
107	49f13e117fa438abd850dca6395e1ba3	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Медяник	Михайлович
108	0ab970740efe70c9607de83014163a8e	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Николаев	Васильевич
109	5afa9e649f6bdffcc2251bac2eaedca4	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Авдеев	Богданович
110	62ae76ae530c4b1830398287fcb5edd4	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Королёв	Борисович
111	d3b086b49bef4836ffedad7a6a802317	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Некрасов	Александрович
112	858f776e6a39b76bbe17669bf38241d2	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Петровский	Леонидович
113	695d2bff5c5c29a02008c7d3db5e3f23	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Агафонов	Станиславович
114	a5ac38cefda23699f40a47c5ce6a3c35	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Трублаевский	Борисович
115	4de0af4074aa4d1a7b3cdd3cdbafba00	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Захаров	Александрович
116	962124ffac2b1ad2b79a59b8e8f90783	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Тягай	Дмитриевич
117	1edac59e5a8aa9440159df4a2065aa0b	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Андрухович	Борисович
118	7741e468a0416c9f7a36d2adf315ef06	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Макаров	Вадимович
119	2cb51d72adb8c9135e893ec8a994a1d8	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Белозёров	Максимович
120	10dcca6418c107044f4ff8a6da7d5e5a	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Терещенко	Артёмович
121	d318dbf6d71dd0b79b2a790398817189	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Ковалёв	\N
122	cafed68bf2b258336111dc24d9daea67	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Кузьмин	Виталиевич
123	db8dae5425796e2e8649150328bbaeb2	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Хижняк	Анатолиевич
124	4d6341896a313c02d55a86eaaa8126b4	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Морозов	Максимович
125	aacc3cb06878a3c1733a4d1303947dc5	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Фокин	Эдуардович
126	6043f068c909e41458b28e8862c60d02	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Силин	Виталиевич
127	54357177727d4d8780cef734c1132019	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Медяник	Михайлович
128	942bbf553f9ef149e2a1684d76aefc1c	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Николаев	Васильевич
129	5ef3df2cfaef2204baefd70bf9bf1363	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Авдеев	Богданович
130	5a659d6aded7b7cf085001c5b619fa3c	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Королёв	Борисович
131	764a98ce696ae7b163ee32302516053a	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Некрасов	Александрович
132	24e29144f145e2acf93e79e030617f78	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Петровский	Леонидович
133	059798b6c08a814a08c6de1b66cbb9da	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Агафонов	Станиславович
134	1cfe4a3546af1f89dfd8ec52b15ddb2a	5f4dcc3b5aa765d61d8327deb882cf99	Эдият	Трублаевский	Борисович
135	b222105c4382068046f6f51147190d37	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонд	Захаров	Александрович
136	2590f660331fb828b703fbbaf4860b67	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонт	Тягай	Дмитриевич
137	c1731bbf93e5d07983d109106506b20d	5f4dcc3b5aa765d61d8327deb882cf99	Эдмонтис	Андрухович	Борисович
138	5d22859387cf08bf789dd439d1c7c2cb	5f4dcc3b5aa765d61d8327deb882cf99	Эдмунд	Макаров	Вадимович
139	d3aecbfccbf0783e9108b313bf210b92	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундас	Белозёров	Максимович
140	1de8667e8693dfcda5d6849a4b4e1d65	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундо	Терещенко	Артёмович
141	628a73cf5f2682e2ecf2ec63eae8a17b	5f4dcc3b5aa765d61d8327deb882cf99	Эдмундс	Ковалёв	\N
142	1d1d105ac549f605db2b90edd9ac0e8f	5f4dcc3b5aa765d61d8327deb882cf99	Эдуард	Кузьмин	Виталиевич
143	90f8ec777abc9642b6d02f98fe1da075	5f4dcc3b5aa765d61d8327deb882cf99	Эдуардас	Хижняк	Анатолиевич
144	7707d75ea439c7c99fc29089edc84a14	5f4dcc3b5aa765d61d8327deb882cf99	Эждер	Морозов	Максимович
145	6199f9a244128a27ce7dc353ef3c34f0	5f4dcc3b5aa765d61d8327deb882cf99	Эдгар	Фокин	Эдуардович
146	1109bb314822802a1e3f4e786e3bdc43	5f4dcc3b5aa765d61d8327deb882cf99	Эдгард	Силин	Виталиевич
147	5a9b83aae3bcb72346fb9b2998a91005	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарс	Медяник	Михайлович
148	553ff248f7470d34d32e5326bafdf8f1	5f4dcc3b5aa765d61d8327deb882cf99	Эдгарт	Николаев	Васильевич
149	e4d96bdcdd1e2c05ffc59248bd16c8b2	5f4dcc3b5aa765d61d8327deb882cf99	Эдди	Авдеев	Богданович
150	bb916693198a59872e5897a92744af75	5f4dcc3b5aa765d61d8327deb882cf99	Эдем	Королёв	Борисович
151	b5912228ef604de583552bd52a16f378	5f4dcc3b5aa765d61d8327deb882cf99	Эдиян	Некрасов	Александрович
152	72b4c19a6820782ca829b4f9b4222502	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
153	c7d5db76d49efe6d1b8514936bb66a7b	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
154	3c769af5831ab4785f6ebac3f57c40e5	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
155	dbd0a6e691d4bd7e14a65d8c69e3f56d	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
156	ab46c8481318891ce56665725149b248	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
157	fd4b38ea4a98497dc7a6b6f88e2a081c	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
158	6917798ce7f423cb25db6282c1bc38ac	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
159	2cbea9582ee330c64a15a95907524b69	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
160	c7ed5a2f55245d3c0a7e2073f7b5d2d2	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
161	c133aa543c680ca38a134a043349c2bf	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
162	690c3a84d3a41bf2d7e77c2ebd103b8c	5f4dcc3b5aa765d61d8327deb882cf99	Мария	Тарасова	Владимировна
163	d20329dd2621a6451ddc47cd27c624ea	5f4dcc3b5aa765d61d8327deb882cf99	Татьяна	Рымар	Артёмовна
164	f5538f06e99afd56486722e3a022e917	5f4dcc3b5aa765d61d8327deb882cf99	Антонина	Чухрай	Брониславовна
165	13cb829fe1e7e208c965c75ce4fbf25b	5f4dcc3b5aa765d61d8327deb882cf99	Юлия	Лихачёва	Юхимовна
166	b1736583a68c0485e7988bfe41dfb2ef	5f4dcc3b5aa765d61d8327deb882cf99	Оксана	Рожкова	Владимировна
167	c43eb19642235fc018a7438c22c103b3	5f4dcc3b5aa765d61d8327deb882cf99	Ягетта	Сазонова	Григорьевна
168	6083e85c9427862d0d9f14acb536190f	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Ершова	Дмитриевна
169	f65c769474b363d9cab9ed9cf7472ca1	5f4dcc3b5aa765d61d8327deb882cf99	Регина	Толочко	Алексеевна
170	393199c17784c898294cea4010caccc3	5f4dcc3b5aa765d61d8327deb882cf99	Йолана	Барановска	Виталиевна
171	1f13100c108954c15c92909f2284f95f	5f4dcc3b5aa765d61d8327deb882cf99	Мальвина	Галкина	\N
172	63e12c2cf6f1ff5fd41857cd8565e320	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
173	347835ac2be5ae436bdbc01d1a2bc2bf	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
174	906fa7cc7a944fa5f5c67f9fabaebb41	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
175	00b91063ccafb4cb58bc0388878850a6	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
176	d0206162d406a4b07e5410b6531c5823	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
177	465bed135e6f84c4de5d79771255fa11	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
178	7f32cfe1f9591c8762e70fa23c21fa86	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
179	a808050242356cc1d3c04d75952069ca	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
180	bf533a7132df42bfc8ca6d40ecf5438d	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
181	49f9de27b46388f26592673debc32d7a	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
182	ce8c6dd3130c3ab0b29e1831423df95d	5f4dcc3b5aa765d61d8327deb882cf99	Мария	Тарасова	Владимировна
183	4d40bfc22ffc33ce8ab2e7787bc06446	5f4dcc3b5aa765d61d8327deb882cf99	Татьяна	Рымар	Артёмовна
184	43ad409b31e7a071121ef5cee4f51eab	5f4dcc3b5aa765d61d8327deb882cf99	Антонина	Чухрай	Брониславовна
185	d8e45fe2ca4fb7fffc4c1fd58db5169a	5f4dcc3b5aa765d61d8327deb882cf99	Юлия	Лихачёва	Юхимовна
186	bda2665839e093f96e107108570a1123	5f4dcc3b5aa765d61d8327deb882cf99	Оксана	Рожкова	Владимировна
187	bb2087ef20f30a2648ca5b018cb838c7	5f4dcc3b5aa765d61d8327deb882cf99	Ягетта	Сазонова	Григорьевна
188	cdb46682c7f8825f8d3379e01881cb1b	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Ершова	Дмитриевна
189	e253875e8c8b45e3124f7d382f9b8741	5f4dcc3b5aa765d61d8327deb882cf99	Регина	Толочко	Алексеевна
190	c2a4e9e2e4e2feb2f87b80ecf6aa3ca6	5f4dcc3b5aa765d61d8327deb882cf99	Йолана	Барановска	Виталиевна
191	495f176662c1ef6e00c9198d0cbe6ab5	5f4dcc3b5aa765d61d8327deb882cf99	Мальвина	Галкина	\N
192	1df5744625d39a556f76a5aa452b2433	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
193	69d99cbe87f57fe5b69c34119eb791db	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
194	0f06923e250ddbc3813464fc4a824116	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
195	eefe49467a35a49f34257e5e72999715	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
196	0fe1d6f28280b63d65faa1767e972a32	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
197	a9ffb149ef71e6bcd8076c590b5ad35b	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
198	7ecdb0e11e0d7a2a18993b16db0f3ca0	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
199	fe0c47a43a7cd8c01715ba1ddadeac8c	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
200	ef29d6db8278a305d431a91dd04e4465	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
201	bc64601bbd8d18e5fe3bfa574b4e18dc	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
202	d31a182d18e70ac98b81e8bf1c8d6dd7	5f4dcc3b5aa765d61d8327deb882cf99	Мария	Тарасова	Владимировна
203	de58e5f942e869120258e6cfa614b3dd	5f4dcc3b5aa765d61d8327deb882cf99	Татьяна	Рымар	Артёмовна
204	57f45aaf6fc4763e4c2f1e1819719e0e	5f4dcc3b5aa765d61d8327deb882cf99	Антонина	Чухрай	Брониславовна
205	723350e2f87735f82c3807b2b6d46ed4	5f4dcc3b5aa765d61d8327deb882cf99	Юлия	Лихачёва	Юхимовна
206	4aca7d36903fe364d24f2c789b9e9fb7	5f4dcc3b5aa765d61d8327deb882cf99	Оксана	Рожкова	Владимировна
207	66601206ae2ca27e37d7dade7f5a127b	5f4dcc3b5aa765d61d8327deb882cf99	Ягетта	Сазонова	Григорьевна
208	26a97dc57c20c2ea812c3f0257eef989	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Ершова	Дмитриевна
209	5b9c3791c925a9d4e1c2fac7d6a8bfa2	5f4dcc3b5aa765d61d8327deb882cf99	Регина	Толочко	Алексеевна
210	fd7913ed35108d7545a815bc3846972e	5f4dcc3b5aa765d61d8327deb882cf99	Йолана	Барановска	Виталиевна
211	4c660742840a4b775a8fdf0e1a7f9684	5f4dcc3b5aa765d61d8327deb882cf99	Мальвина	Галкина	\N
212	d42bc8313ec1c52a1bfdd83689c73fa2	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
213	94e76be5337f191c9e03c33704fd2c65	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
214	c195249f1a334783457775ebea473327	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
215	015125b8abed385ec4731e3f10b5cc17	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
216	dae57d63965fbec49e03abca84c6488a	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
217	77b58f9bd80bc5cb62a6fbb4cb70f182	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
218	4b9a73909f549e5951517d5d6c178d4d	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
219	6f136b296039bf689f162c446528fdf1	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
220	2d8b4e8fff0364ca262ebb478406cd3b	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
221	325f885632a171a66f4d8ec13e41652c	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
222	4fdb9dd9277ed6216781ad7427964b54	5f4dcc3b5aa765d61d8327deb882cf99	Мария	Тарасова	Владимировна
223	928bf6a4de6a564545defac09412d9da	5f4dcc3b5aa765d61d8327deb882cf99	Татьяна	Рымар	Артёмовна
224	e9a373af2f0a56b5c745d49392cc0e7a	5f4dcc3b5aa765d61d8327deb882cf99	Антонина	Чухрай	Брониславовна
225	2788753b3a4698649054098cd8467d8d	5f4dcc3b5aa765d61d8327deb882cf99	Юлия	Лихачёва	Юхимовна
226	8ec9eb5b7a2702c8f8e0310daa08bdcb	5f4dcc3b5aa765d61d8327deb882cf99	Оксана	Рожкова	Владимировна
227	8b8de18027ef9e95888e89b27987db87	5f4dcc3b5aa765d61d8327deb882cf99	Ягетта	Сазонова	Григорьевна
228	1388026754c69a68e341bab6b1c3bcae	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Ершова	Дмитриевна
229	7e29b91ae999f8f9b7872cd808c071aa	5f4dcc3b5aa765d61d8327deb882cf99	Регина	Толочко	Алексеевна
230	ceae1c917391f59a6c8273996a311a25	5f4dcc3b5aa765d61d8327deb882cf99	Йолана	Барановска	Виталиевна
231	71b71da5caab381d6f8a98bc2b6f35b5	5f4dcc3b5aa765d61d8327deb882cf99	Мальвина	Галкина	\N
232	cc05af4832d18a7f8e7d5f97ab780478	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
233	f4ed6d06ac5f005ed6d1581039b8c119	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
234	777b27735783a8646aadc65e0b72c915	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
235	0db9e520e16aa1bce7a074021ac642fe	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
236	1d36c367e84e5607e720f14c9b6acb56	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
237	ea796bb443fae604c6405c1e60779b6a	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
238	9d6e7abe66c76b9d20e1d84a06a26447	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
239	3319f77666232a29c42366df4a559db4	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
240	fbadc23d6c6d490be9029533b64838a9	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
241	675d5ed51555be2b5b2066dcf316279d	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
242	856526245738ee328b137eacfee69115	5f4dcc3b5aa765d61d8327deb882cf99	Мария	Тарасова	Владимировна
243	335193b41a7f4fa8b63b35a2fde0e95a	5f4dcc3b5aa765d61d8327deb882cf99	Татьяна	Рымар	Артёмовна
244	9fc1ed16752e931f0295e82ced2b53e6	5f4dcc3b5aa765d61d8327deb882cf99	Антонина	Чухрай	Брониславовна
245	12dbdd88dd06b47c6dad3af9d4fe9f40	5f4dcc3b5aa765d61d8327deb882cf99	Юлия	Лихачёва	Юхимовна
246	c93386cd5a0ae8624c2e61bc2d7a0e89	5f4dcc3b5aa765d61d8327deb882cf99	Оксана	Рожкова	Владимировна
247	99b56c7c69ffc6b58c7d05c80e45edd1	5f4dcc3b5aa765d61d8327deb882cf99	Ягетта	Сазонова	Григорьевна
248	de1f3b4091d15e911a52eba6afb541b4	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Ершова	Дмитриевна
249	f6fb6ac7b8a5c84d277a05df56b414bd	5f4dcc3b5aa765d61d8327deb882cf99	Регина	Толочко	Алексеевна
250	00999852e404982029890113bd364914	5f4dcc3b5aa765d61d8327deb882cf99	Йолана	Барановска	Виталиевна
251	f63153ef14a834bc002b7b4de87a38e7	5f4dcc3b5aa765d61d8327deb882cf99	Мальвина	Галкина	\N
252	a6e3cd8524c2e482b10f03cd0dd04ce7	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
253	d716cbe45d59c69be620b1782b1e4c96	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
254	cff0bf4cd5a39557e8240aee2e65e5f2	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
255	2a3fa3a6f5800f92bea066b36b15e2c0	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
256	a6d1861bd0a9037990a51e3d0128bb25	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
257	7d4d8a1cc67bb7727fdc933760cec777	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
258	cc23ebbe3e691603973a6c152c96d737	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
259	3b25a18c4ddbe9ecc2a4e5c9adbf35e2	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
260	553d634d1779549bdecd948ea4c709d4	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
261	ed9ac28962d609da5d984c2eb3b6a710	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
262	c2f65dc1eaf6bc69c088c60f6afb6ee6	5f4dcc3b5aa765d61d8327deb882cf99	Мария	Тарасова	Владимировна
263	5c656eb3f64a09038d49be572c8419e4	5f4dcc3b5aa765d61d8327deb882cf99	Татьяна	Рымар	Артёмовна
264	fe1403c9f441026ba3b63fdb97234da0	5f4dcc3b5aa765d61d8327deb882cf99	Антонина	Чухрай	Брониславовна
265	57c86279a8156e95118f570987bc6dcc	5f4dcc3b5aa765d61d8327deb882cf99	Юлия	Лихачёва	Юхимовна
266	62f65578615c66c08ddf98bbcae24df8	5f4dcc3b5aa765d61d8327deb882cf99	Оксана	Рожкова	Владимировна
267	793fd3aa94adef6b8f90cdccfdf9ee5c	5f4dcc3b5aa765d61d8327deb882cf99	Ягетта	Сазонова	Григорьевна
268	290d7808d62c3e2c7edc4e04f48be16a	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Ершова	Дмитриевна
269	1b8ada1f80bee2e97c3121c5e70574a0	5f4dcc3b5aa765d61d8327deb882cf99	Регина	Толочко	Алексеевна
270	fbf395c9661b5e47476350e82ae543a6	5f4dcc3b5aa765d61d8327deb882cf99	Йолана	Барановска	Виталиевна
271	55f7f03e66ef831a8a15fa769c2125ee	5f4dcc3b5aa765d61d8327deb882cf99	Мальвина	Галкина	\N
272	066ad2148bf71a694ad25080a7b4c16e	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
273	0d4adcb6aa94189f36c3778cf4f70f3a	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
274	9adca91176886ca1af00a70223fc33ae	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
275	7d4eeddbb85597e53f504ae779cba27e	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
276	c370d84ca443bd45568bc2add15cb973	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
277	9a2ca3e39e4a74b455ce258badbaccec	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
278	6a26ee9eb8603b90285f5c1a7ca6ef16	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
279	4823b200b133a5100c68e346b7f7e166	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
280	34357d249148092b117dff0c526abd4e	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
281	9b5c4ee5877356a3ae54cf0c67b012a2	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
282	007bdf586e48a8b43ab588ea71763a73	5f4dcc3b5aa765d61d8327deb882cf99	Мария	Тарасова	Владимировна
283	4dd0e91b7220afdc84b8cdc631146842	5f4dcc3b5aa765d61d8327deb882cf99	Татьяна	Рымар	Артёмовна
284	18852240d5795c239c2ae8d2941f19b1	5f4dcc3b5aa765d61d8327deb882cf99	Антонина	Чухрай	Брониславовна
285	5b8d3d80f693d0629e6d4c99deb9be49	5f4dcc3b5aa765d61d8327deb882cf99	Юлия	Лихачёва	Юхимовна
286	dc14aaaada2049425c7426dda8577f13	5f4dcc3b5aa765d61d8327deb882cf99	Оксана	Рожкова	Владимировна
287	40de8c479fc8f8496343fb38f7c423ca	5f4dcc3b5aa765d61d8327deb882cf99	Ягетта	Сазонова	Григорьевна
288	af721134524c3d7fa9e87324093b2d69	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Ершова	Дмитриевна
289	790faf286f55da5059bc3f38191811ee	5f4dcc3b5aa765d61d8327deb882cf99	Регина	Толочко	Алексеевна
290	55a9d33b7e24ebe53ee04319194667e8	5f4dcc3b5aa765d61d8327deb882cf99	Йолана	Барановска	Виталиевна
291	fd26ba31166b9a4f0d133412dc29a65c	5f4dcc3b5aa765d61d8327deb882cf99	Мальвина	Галкина	\N
292	3aade941d540b438f09d615383b52734	5f4dcc3b5aa765d61d8327deb882cf99	Чара	Рожкова	Платоновна
293	f48da4a6a9aca7290f305beb1383cb01	5f4dcc3b5aa765d61d8327deb882cf99	Лидия	Недбайло	Владимировна
294	a1edbffbdbf0fb2c9e9e5a1be63d4540	5f4dcc3b5aa765d61d8327deb882cf99	Федосья	Червона	Вадимовна
295	ecb8b08b634c938334345f5061e94ad3	5f4dcc3b5aa765d61d8327deb882cf99	Жанна	Шкраба	Станиславовна
296	866519e9d1846f4299dbb024cc064009	5f4dcc3b5aa765d61d8327deb882cf99	Харитина	Бирюкова	Брониславовна
297	6ae45746e0231996190f0ad4d41fcc64	5f4dcc3b5aa765d61d8327deb882cf99	Белла	Бобылёва	Анатолиевна
298	7c6648752c086c0cf7f3a49c215850be	5f4dcc3b5aa765d61d8327deb882cf99	Лариса	Данилова	Вадимовна
299	81d658b9c5740d56759f1f211992c221	5f4dcc3b5aa765d61d8327deb882cf99	Людмила	Тягай	Ивановна
300	d6b50ecb714d388d9bc872fda0127f8a	5f4dcc3b5aa765d61d8327deb882cf99	Фаина	Беспалова	Алексеевна
301	2516620410b8562522fc6b5d8b1b717d	5f4dcc3b5aa765d61d8327deb882cf99	Ева	Барановска	Дмитриевна
\.


--
-- Name: administrators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.administrators_id_seq', 15, true);


--
-- Name: cinemachains_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.cinemachains_id_seq', 5, true);


--
-- Name: cinemas_chainid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.cinemas_chainid_seq', 1, false);


--
-- Name: cinemas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.cinemas_id_seq', 47, true);


--
-- Name: favourites_cinemaid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.favourites_cinemaid_seq', 1, false);


--
-- Name: favourites_viewerid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.favourites_viewerid_seq', 1, false);


--
-- Name: films_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.films_id_seq', 21, true);


--
-- Name: halls_cinemaid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.halls_cinemaid_seq', 15, true);


--
-- Name: halls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.halls_id_seq', 258, true);


--
-- Name: paymentinfo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.paymentinfo_id_seq', 1000, true);


--
-- Name: paymentinfo_paymentsystemid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.paymentinfo_paymentsystemid_seq', 1, false);


--
-- Name: paymentinfo_viewerid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.paymentinfo_viewerid_seq', 1, false);


--
-- Name: paymentsystems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.paymentsystems_id_seq', 3, true);


--
-- Name: resposibles_administratorid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.resposibles_administratorid_seq', 1, false);


--
-- Name: resposibles_cinemaid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.resposibles_cinemaid_seq', 1, false);


--
-- Name: reviews_filmid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.reviews_filmid_seq', 1, false);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.reviews_id_seq', 323, true);


--
-- Name: reviews_viewerid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.reviews_viewerid_seq', 1, false);


--
-- Name: sessions_filmid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.sessions_filmid_seq', 1, false);


--
-- Name: sessions_hallid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.sessions_hallid_seq', 1, false);


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.sessions_id_seq', 273, true);


--
-- Name: spots_hallid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.spots_hallid_seq', 1, false);


--
-- Name: spots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.spots_id_seq', 25800, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.tickets_id_seq', 25860, true);


--
-- Name: tickets_sessionid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.tickets_sessionid_seq', 1, false);


--
-- Name: tickets_spotid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.tickets_spotid_seq', 10, true);


--
-- Name: tickets_viewerid_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.tickets_viewerid_seq', 1, false);


--
-- Name: viewers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sergey
--

SELECT pg_catalog.setval('public.viewers_id_seq', 301, true);


--
-- Name: administrators administrators_login_key; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.administrators
    ADD CONSTRAINT administrators_login_key UNIQUE (login);


--
-- Name: administrators administrators_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.administrators
    ADD CONSTRAINT administrators_pkey PRIMARY KEY (id);


--
-- Name: cinemachains cinemachains_name_key; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.cinemachains
    ADD CONSTRAINT cinemachains_name_key UNIQUE (name);


--
-- Name: cinemachains cinemachains_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.cinemachains
    ADD CONSTRAINT cinemachains_pkey PRIMARY KEY (id);


--
-- Name: cinemas cinemas_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.cinemas
    ADD CONSTRAINT cinemas_pkey PRIMARY KEY (id);


--
-- Name: favourites favourites_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT favourites_pkey PRIMARY KEY (viewerid, cinemaid);


--
-- Name: films films_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.films
    ADD CONSTRAINT films_pkey PRIMARY KEY (id);


--
-- Name: halls halls_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.halls
    ADD CONSTRAINT halls_pkey PRIMARY KEY (id);


--
-- Name: paymentinfo paymentinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentinfo
    ADD CONSTRAINT paymentinfo_pkey PRIMARY KEY (id);


--
-- Name: paymentsystems paymentsystems_name_key; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentsystems
    ADD CONSTRAINT paymentsystems_name_key UNIQUE (name);


--
-- Name: paymentsystems paymentsystems_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentsystems
    ADD CONSTRAINT paymentsystems_pkey PRIMARY KEY (id);


--
-- Name: resposibles resposibles_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.resposibles
    ADD CONSTRAINT resposibles_pkey PRIMARY KEY (administratorid, cinemaid);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: spots spots_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.spots
    ADD CONSTRAINT spots_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: viewers viewers_login_key; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.viewers
    ADD CONSTRAINT viewers_login_key UNIQUE (login);


--
-- Name: viewers viewers_pkey; Type: CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.viewers
    ADD CONSTRAINT viewers_pkey PRIMARY KEY (id);


--
-- Name: administrators_logins; Type: INDEX; Schema: public; Owner: sergey
--

CREATE UNIQUE INDEX administrators_logins ON public.administrators USING btree (login);


--
-- Name: films_names; Type: INDEX; Schema: public; Owner: sergey
--

CREATE INDEX films_names ON public.films USING btree (name);


--
-- Name: reviews_scores; Type: INDEX; Schema: public; Owner: sergey
--

CREATE INDEX reviews_scores ON public.reviews USING btree (score);


--
-- Name: sessions_dates; Type: INDEX; Schema: public; Owner: sergey
--

CREATE UNIQUE INDEX sessions_dates ON public.sessions USING btree (date, hallid);


--
-- Name: spots_hall; Type: INDEX; Schema: public; Owner: sergey
--

CREATE UNIQUE INDEX spots_hall ON public.spots USING btree ("row", number, hallid);


--
-- Name: spots_places; Type: INDEX; Schema: public; Owner: sergey
--

CREATE INDEX spots_places ON public.spots USING btree ("row") INCLUDE (number);


--
-- Name: viewers_fullnames; Type: INDEX; Schema: public; Owner: sergey
--

CREATE INDEX viewers_fullnames ON public.viewers USING btree (name, surname, patronymic);


--
-- Name: viewers_logins; Type: INDEX; Schema: public; Owner: sergey
--

CREATE UNIQUE INDEX viewers_logins ON public.viewers USING btree (login);


--
-- Name: sessions session_date_check; Type: TRIGGER; Schema: public; Owner: sergey
--

CREATE TRIGGER session_date_check BEFORE INSERT OR UPDATE ON public.sessions FOR EACH ROW EXECUTE FUNCTION public.check_session_date();


--
-- Name: cinemas cinemas_chainid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.cinemas
    ADD CONSTRAINT cinemas_chainid_fkey FOREIGN KEY (chainid) REFERENCES public.cinemachains(id) ON DELETE SET DEFAULT;


--
-- Name: favourites favourites_cinemaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT favourites_cinemaid_fkey FOREIGN KEY (cinemaid) REFERENCES public.cinemas(id) ON DELETE CASCADE;


--
-- Name: favourites favourites_viewerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT favourites_viewerid_fkey FOREIGN KEY (viewerid) REFERENCES public.viewers(id) ON DELETE CASCADE;


--
-- Name: halls halls_cinemaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.halls
    ADD CONSTRAINT halls_cinemaid_fkey FOREIGN KEY (cinemaid) REFERENCES public.cinemas(id) ON DELETE CASCADE;


--
-- Name: paymentinfo paymentinfo_paymentsystemid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentinfo
    ADD CONSTRAINT paymentinfo_paymentsystemid_fkey FOREIGN KEY (paymentsystemid) REFERENCES public.paymentsystems(id) ON DELETE SET DEFAULT;


--
-- Name: paymentinfo paymentinfo_viewerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.paymentinfo
    ADD CONSTRAINT paymentinfo_viewerid_fkey FOREIGN KEY (viewerid) REFERENCES public.viewers(id) ON DELETE CASCADE;


--
-- Name: resposibles resposibles_administratorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.resposibles
    ADD CONSTRAINT resposibles_administratorid_fkey FOREIGN KEY (administratorid) REFERENCES public.administrators(id) ON DELETE CASCADE;


--
-- Name: resposibles resposibles_cinemaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.resposibles
    ADD CONSTRAINT resposibles_cinemaid_fkey FOREIGN KEY (cinemaid) REFERENCES public.cinemas(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_filmid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_filmid_fkey FOREIGN KEY (filmid) REFERENCES public.films(id) ON DELETE SET DEFAULT;


--
-- Name: reviews reviews_viewerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_viewerid_fkey FOREIGN KEY (viewerid) REFERENCES public.viewers(id) ON DELETE SET DEFAULT;


--
-- Name: sessions sessions_filmid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_filmid_fkey FOREIGN KEY (filmid) REFERENCES public.films(id) ON DELETE SET DEFAULT;


--
-- Name: sessions sessions_hallid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_hallid_fkey FOREIGN KEY (hallid) REFERENCES public.halls(id) ON DELETE SET DEFAULT;


--
-- Name: spots spots_hallid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.spots
    ADD CONSTRAINT spots_hallid_fkey FOREIGN KEY (hallid) REFERENCES public.halls(id) ON DELETE CASCADE;


--
-- Name: tickets tickets_sessionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_sessionid_fkey FOREIGN KEY (sessionid) REFERENCES public.sessions(id) ON DELETE SET DEFAULT;


--
-- Name: tickets tickets_spotid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_spotid_fkey FOREIGN KEY (spotid) REFERENCES public.spots(id);


--
-- Name: tickets tickets_viewerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sergey
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_viewerid_fkey FOREIGN KEY (viewerid) REFERENCES public.viewers(id) ON DELETE SET DEFAULT;


--
-- PostgreSQL database dump complete
--


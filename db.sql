--
-- PostgreSQL database dump
--

-- Dumped from database version 12.6 (Ubuntu 12.6-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.6 (Ubuntu 12.6-0ubuntu0.20.04.1)

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
-- Name: broadcast; Type: DATABASE; Schema: -; Owner: admin
--

CREATE DATABASE broadcast WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE broadcast OWNER TO admin;

\connect broadcast

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
-- Name: notify_row(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.notify_row() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM pg_notify(TG_ARGV[0], NEW.content);
	RETURN NULL;
END;
$$;


ALTER FUNCTION public.notify_row() OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.messages (
    content text NOT NULL
);


ALTER TABLE public.messages OWNER TO admin;

--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.messages (content) FROM stdin;
Hello
Hello World
Hello Wts
WATT
Change requests user
Exit in circle
May
\.


--
-- Name: messages messages_notify_new; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER messages_notify_new AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.notify_row('foo');


--
-- PostgreSQL database dump complete
--


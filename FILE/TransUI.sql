--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 15.2

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
-- Name: avail; Type: TYPE; Schema: public; Owner: rezkimuhammad60
--

CREATE TYPE public.avail AS ENUM (
    'Used',
    'Available',
    'Charging',
    'Broken'
);


ALTER TYPE public.avail OWNER TO rezkimuhammad60;

--
-- Name: facility; Type: TYPE; Schema: public; Owner: rezkimuhammad60
--

CREATE TYPE public.facility AS ENUM (
    'Charge Point',
    'Park',
    'Bus Stop'
);


ALTER TYPE public.facility OWNER TO rezkimuhammad60;

--
-- Name: role; Type: TYPE; Schema: public; Owner: rezkimuhammad60
--

CREATE TYPE public.role AS ENUM (
    'REGULER',
    'PARTNER',
    'MAHASISWA'
);


ALTER TYPE public.role OWNER TO rezkimuhammad60;

--
-- Name: status; Type: TYPE; Schema: public; Owner: rezkimuhammad60
--

CREATE TYPE public.status AS ENUM (
    'Menunggu',
    'Selesai',
    'Dibatalkan'
);


ALTER TYPE public.status OWNER TO rezkimuhammad60;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Partner; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public."Partner" (
    "PARTNER_ID" character varying(10) NOT NULL,
    "Nama" character varying(20) NOT NULL,
    "LICENSE" character(12) NOT NULL
);


ALTER TABLE public."Partner" OWNER TO rezkimuhammad60;

--
-- Name: drop_point; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.drop_point (
    "Drop_ID" integer NOT NULL,
    "Location" character varying(20) NOT NULL,
    "Charger_point" boolean NOT NULL,
    "Park_point" boolean NOT NULL,
    "Bus_Stop" boolean NOT NULL
);


ALTER TABLE public.drop_point OWNER TO rezkimuhammad60;

--
-- Name: drop_point_Drop_ID_seq; Type: SEQUENCE; Schema: public; Owner: rezkimuhammad60
--

CREATE SEQUENCE public."drop_point_Drop_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."drop_point_Drop_ID_seq" OWNER TO rezkimuhammad60;

--
-- Name: drop_point_Drop_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rezkimuhammad60
--

ALTER SEQUENCE public."drop_point_Drop_ID_seq" OWNED BY public.drop_point."Drop_ID";


--
-- Name: partner_table; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.partner_table (
    "PARTNER_ID" character varying(10) NOT NULL,
    "Nama" character varying(20) NOT NULL,
    "LICENSE" character(12) NOT NULL
);


ALTER TABLE public.partner_table OWNER TO rezkimuhammad60;

--
-- Name: payment_history; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.payment_history (
    "TRANS_ID" character varying(10) NOT NULL,
    "PAYMENT" bigint NOT NULL,
    "STATUS" public.status NOT NULL,
    "DATE" date DEFAULT now() NOT NULL,
    "TIME" time without time zone DEFAULT now() NOT NULL,
    "ORDER_ID" integer NOT NULL
);


ALTER TABLE public.payment_history OWNER TO rezkimuhammad60;

--
-- Name: payment_history_ORDER_ID_seq; Type: SEQUENCE; Schema: public; Owner: rezkimuhammad60
--

CREATE SEQUENCE public."payment_history_ORDER_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."payment_history_ORDER_ID_seq" OWNER TO rezkimuhammad60;

--
-- Name: payment_history_ORDER_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rezkimuhammad60
--

ALTER SEQUENCE public."payment_history_ORDER_ID_seq" OWNED BY public.payment_history."ORDER_ID";


--
-- Name: ride_history; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.ride_history (
    username character varying(20) NOT NULL,
    "Spekun_ID" character varying(20) NOT NULL,
    "DATE" date NOT NULL,
    "From" character varying(20) NOT NULL,
    "Destination" character varying(20) NOT NULL,
    "Duration" timestamp without time zone NOT NULL
);


ALTER TABLE public.ride_history OWNER TO rezkimuhammad60;

--
-- Name: sched_bikun; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.sched_bikun (
    "Plat_nomor" character(4),
    "Waktu_berangkat" text,
    "Jalur" text
);


ALTER TABLE public.sched_bikun OWNER TO rezkimuhammad60;

--
-- Name: sched_krl; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.sched_krl (
    "Kode_kereta" character(4),
    "Jam_tiba" text,
    "Stamformasi" integer,
    "Tujuan" text
);


ALTER TABLE public.sched_krl OWNER TO rezkimuhammad60;

--
-- Name: spekun; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.spekun (
    "Spekun_ID" character varying(20) NOT NULL,
    "Rider" character varying(20),
    "Drop_loc" character varying(20),
    "Fuel" integer NOT NULL,
    "Status" public.avail NOT NULL
);


ALTER TABLE public.spekun OWNER TO rezkimuhammad60;

--
-- Name: user; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public."user" (
    "USER_ID" character varying(10) NOT NULL,
    "Password" text NOT NULL,
    "Email" text NOT NULL,
    "NAME" character varying(20) DEFAULT NULL::character varying,
    "Username" character varying(20) NOT NULL,
    "PARTNER_ID" character(10) DEFAULT NULL::bpchar,
    "NPM" character(10) DEFAULT NULL::bpchar,
    "ADDRESS" text,
    "Balance" bigint,
    "ROLE" character varying(20) NOT NULL
);


ALTER TABLE public."user" OWNER TO rezkimuhammad60;

--
-- Name: user_table; Type: TABLE; Schema: public; Owner: rezkimuhammad60
--

CREATE TABLE public.user_table (
    user_id character varying(10) NOT NULL,
    password text NOT NULL,
    email text NOT NULL,
    name character varying(20) DEFAULT NULL::character varying,
    username character varying(20) NOT NULL,
    "PARTNER_ID" character(10) DEFAULT NULL::bpchar,
    "NPM" character(10) DEFAULT NULL::bpchar,
    "ADDRESS" text,
    "Balance" bigint,
    role character varying(20) NOT NULL,
    phone_number character(12) DEFAULT NULL::bpchar
);


ALTER TABLE public.user_table OWNER TO rezkimuhammad60;

--
-- Name: drop_point Drop_ID; Type: DEFAULT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.drop_point ALTER COLUMN "Drop_ID" SET DEFAULT nextval('public."drop_point_Drop_ID_seq"'::regclass);


--
-- Name: payment_history ORDER_ID; Type: DEFAULT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.payment_history ALTER COLUMN "ORDER_ID" SET DEFAULT nextval('public."payment_history_ORDER_ID_seq"'::regclass);


--
-- Data for Name: Partner; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public."Partner" ("PARTNER_ID", "Nama", "LICENSE") FROM stdin;
\.


--
-- Data for Name: drop_point; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.drop_point ("Drop_ID", "Location", "Charger_point", "Park_point", "Bus_Stop") FROM stdin;
\.


--
-- Data for Name: partner_table; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.partner_table ("PARTNER_ID", "Nama", "LICENSE") FROM stdin;
\.


--
-- Data for Name: payment_history; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.payment_history ("TRANS_ID", "PAYMENT", "STATUS", "DATE", "TIME", "ORDER_ID") FROM stdin;
\.


--
-- Data for Name: ride_history; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.ride_history (username, "Spekun_ID", "DATE", "From", "Destination", "Duration") FROM stdin;
\.


--
-- Data for Name: sched_bikun; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.sched_bikun ("Plat_nomor", "Waktu_berangkat", "Jalur") FROM stdin;
6504	06:50	Merah
6961	06:55	Merah
7547	07:00	Biru
3328	07:05	Merah
8057	07:10	Biru
5661	07:15	Merah
9038	07:20	Merah
3502	07:25	Merah
4727	07:30	Biru
9160	07:35	Merah
5148	07:40	Merah
9594	07:45	Merah
2502	07:50	Merah
6564	07:55	Biru
5276	08:00	Merah
3503	08:05	Merah
3907	08:10	Merah
8997	08:15	Biru
2513	08:20	Merah
1720	08:25	Merah
5076	08:30	Biru
5124	08:35	Biru
4841	08:40	Merah
8163	08:45	Merah
6384	08:50	Biru
3118	08:55	Biru
2453	09:00	Merah
1970	09:05	Merah
7581	09:10	Biru
3790	09:15	Biru
6411	09:20	Biru
8067	09:25	Biru
5714	09:30	Merah
9533	09:35	Merah
4464	09:40	Merah
7496	09:45	Merah
4956	09:50	Biru
3526	09:55	Biru
2505	10:00	Biru
9183	10:05	Biru
2857	10:10	Merah
6897	10:15	Merah
1479	10:20	Biru
1865	10:25	Biru
9668	10:30	Merah
9665	10:35	Merah
7273	10:40	Biru
6005	10:45	Merah
8742	10:50	Merah
6045	10:55	Biru
4662	11:00	Merah
5782	11:05	Biru
4009	11:10	Merah
3529	11:15	Merah
5792	11:20	Merah
2538	11:25	Merah
3314	11:30	Biru
8325	11:35	Merah
5835	11:40	Biru
6817	11:45	Biru
7254	11:50	Biru
6682	11:55	Merah
3788	12:00	Merah
8600	12:05	Merah
2918	12:10	Biru
7872	12:15	Biru
7588	12:20	Merah
6815	12:25	Merah
6127	12:30	Merah
3299	12:35	Biru
1583	12:40	Merah
9780	12:45	Biru
6944	12:50	Merah
3174	12:55	Biru
7443	13:00	Biru
2386	13:05	Merah
1452	13:10	Biru
6367	13:15	Merah
8257	13:20	Biru
1789	13:25	Biru
5998	13:30	Merah
8742	13:35	Merah
4183	13:40	Merah
2167	13:45	Merah
2393	13:50	Biru
6366	13:55	Biru
6267	14:00	Merah
8224	14:05	Biru
7219	14:10	Biru
5769	14:15	Biru
9607	14:20	Merah
6905	14:25	Merah
4839	14:30	Biru
1358	14:35	Biru
8936	14:40	Biru
4913	14:45	Biru
3672	14:50	Merah
9882	14:55	Merah
3752	15:00	Merah
3108	15:05	Biru
7726	15:10	Merah
5321	15:15	Merah
6094	15:20	Merah
1951	15:25	Merah
3282	15:30	Merah
8314	15:35	Merah
9366	15:40	Biru
8354	15:45	Biru
6229	15:50	Merah
5685	15:55	Merah
3775	16:00	Biru
8264	16:05	Merah
9519	16:10	Biru
3012	16:15	Biru
3151	16:20	Biru
3205	16:25	Merah
3702	16:30	Merah
3485	16:35	Biru
1302	16:40	Merah
7052	16:45	Biru
1288	16:50	Merah
8944	16:55	Biru
7275	17:00	Biru
6542	17:05	Merah
7588	17:10	Biru
6302	17:15	Biru
2909	17:20	Merah
6629	17:25	Biru
7313	17:30	Merah
5928	17:35	Merah
4132	17:40	Merah
4503	17:45	Merah
6328	17:50	Biru
9224	17:55	Merah
1520	18:00	Merah
9298	18:05	Biru
9587	18:10	Merah
6752	18:15	Merah
5094	18:20	Biru
4036	18:25	Merah
4502	18:30	Biru
6931	18:35	Merah
9493	18:40	Merah
3778	18:45	Biru
3280	18:50	Merah
9121	18:55	Merah
7419	19:00	Merah
9267	19:05	Merah
7991	19:10	Biru
3515	19:15	Merah
5021	19:20	Biru
9280	19:25	Biru
2697	19:30	Merah
6970	19:35	Merah
2756	19:40	Merah
3475	19:45	Merah
9429	19:50	Merah
1762	19:55	Merah
2684	20:00	Biru
9546	20:05	Merah
7039	20:10	Biru
6575	20:15	Merah
3023	20:20	Biru
9301	20:25	Merah
5391	20:30	Biru
2003	20:35	Merah
2780	20:40	Biru
7826	20:45	Biru
8524	20:50	Merah
2604	20:55	Merah
\.


--
-- Data for Name: sched_krl; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.sched_krl ("Kode_kereta", "Jam_tiba", "Stamformasi", "Tujuan") FROM stdin;
1365	04:16	12	Jakarta Kota
1210	04:31	8	Bogor
1086	04:46	12	Manggarai
1163	05:01	12	Bogor
1436	05:16	10	Manggarai
1397	05:31	8	Manggarai
1099	05:46	12	Bogor
1068	06:01	10	Bogor
1406	06:16	12	Manggarai
1330	06:31	12	Manggarai
1103	06:46	10	Manggarai
1215	07:01	12	Bogor
1278	07:16	10	Bogor
1165	07:31	10	Manggarai
1293	07:46	12	Bogor
1293	08:01	12	Manggarai
1330	08:16	8	Manggarai
1213	08:31	8	Bogor
1077	08:46	10	Manggarai
1072	09:01	8	Jakarta Kota
1397	09:16	12	Manggarai
1243	09:31	8	Manggarai
1068	09:46	12	Manggarai
1263	10:01	10	Manggarai
1396	10:16	8	Manggarai
1401	10:31	10	Bogor
1397	10:46	10	Bogor
1201	11:01	12	Jakarta Kota
1129	11:16	8	Bogor
1072	11:31	8	Bogor
1068	11:46	8	Manggarai
1430	12:01	10	Bogor
1163	12:16	10	Jakarta Kota
1329	12:31	10	Bogor
1387	12:46	8	Jakarta Kota
1400	13:01	10	Jakarta Kota
1438	13:16	10	Bogor
1396	13:31	10	Manggarai
1222	13:46	12	Jakarta Kota
1334	14:01	12	Bogor
1242	14:16	10	Bogor
1068	14:31	12	Manggarai
1163	14:46	10	Bogor
1377	15:01	8	Bogor
1189	15:16	8	Jakarta Kota
1327	15:31	12	Jakarta Kota
1208	15:46	12	Bogor
1208	16:01	12	Jakarta Kota
1142	16:16	10	Jakarta Kota
1208	16:31	10	Jakarta Kota
1314	16:46	8	Bogor
1437	17:01	8	Manggarai
1390	17:16	12	Bogor
1210	17:31	8	Bogor
1163	17:46	12	Jakarta Kota
1387	18:01	10	Jakarta Kota
1172	18:16	10	Bogor
1213	18:31	8	Bogor
1342	18:46	8	Bogor
1092	19:01	8	Manggarai
1201	19:16	8	Manggarai
1049	19:31	8	Bogor
1340	19:46	10	Jakarta Kota
1086	20:01	12	Bogor
1312	20:16	8	Manggarai
1172	20:31	8	Bogor
1223	20:46	10	Manggarai
1414	21:01	8	Manggarai
1132	21:16	12	Manggarai
1163	21:31	10	Jakarta Kota
1222	21:46	10	Manggarai
1330	22:01	12	Manggarai
1350	22:16	12	Jakarta Kota
1340	22:31	8	Bogor
1312	22:46	8	Bogor
1086	23:01	8	Bogor
1059	23:16	8	Jakarta Kota
1243	23:31	10	Bogor
\.


--
-- Data for Name: spekun; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.spekun ("Spekun_ID", "Rider", "Drop_loc", "Fuel", "Status") FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public."user" ("USER_ID", "Password", "Email", "NAME", "Username", "PARTNER_ID", "NPM", "ADDRESS", "Balance", "ROLE") FROM stdin;
\.


--
-- Data for Name: user_table; Type: TABLE DATA; Schema: public; Owner: rezkimuhammad60
--

COPY public.user_table (user_id, password, email, name, username, "PARTNER_ID", "NPM", "ADDRESS", "Balance", role, phone_number) FROM stdin;
2023000001	12345678	rezki@transui.com	\N	Rezki	\N	\N	\N	\N	partner	\N
2023000002	1234678	bombom@transui.com	\N	bombom	\N	\N	\N	\N	partner	\N
2023000003	hubungkan	aliefya@transui.com	\N	aliefya	\N	\N	\N	\N	mahasiswa	\N
\.


--
-- Name: drop_point_Drop_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: rezkimuhammad60
--

SELECT pg_catalog.setval('public."drop_point_Drop_ID_seq"', 1, false);


--
-- Name: payment_history_ORDER_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: rezkimuhammad60
--

SELECT pg_catalog.setval('public."payment_history_ORDER_ID_seq"', 1, false);


--
-- Name: Partner Partner_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public."Partner"
    ADD CONSTRAINT "Partner_pkey" PRIMARY KEY ("PARTNER_ID");


--
-- Name: drop_point drop_point_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.drop_point
    ADD CONSTRAINT drop_point_pkey PRIMARY KEY ("Drop_ID");


--
-- Name: partner_table partner_table_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.partner_table
    ADD CONSTRAINT partner_table_pkey PRIMARY KEY ("PARTNER_ID");


--
-- Name: payment_history payment_history_ORDER_ID_key; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT "payment_history_ORDER_ID_key" UNIQUE ("ORDER_ID");


--
-- Name: payment_history payment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_pkey PRIMARY KEY ("TRANS_ID");


--
-- Name: ride_history ride_history_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.ride_history
    ADD CONSTRAINT ride_history_pkey PRIMARY KEY (username);


--
-- Name: spekun spekun_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.spekun
    ADD CONSTRAINT spekun_pkey PRIMARY KEY ("Spekun_ID");


--
-- Name: user user_Email_key; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "user_Email_key" UNIQUE ("Email");


--
-- Name: user user_Username_key; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "user_Username_key" UNIQUE ("Username");


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY ("USER_ID");


--
-- Name: user_table user_table_email_key; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.user_table
    ADD CONSTRAINT user_table_email_key UNIQUE (email);


--
-- Name: user_table user_table_pkey; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.user_table
    ADD CONSTRAINT user_table_pkey PRIMARY KEY (user_id);


--
-- Name: user_table user_table_username_key; Type: CONSTRAINT; Schema: public; Owner: rezkimuhammad60
--

ALTER TABLE ONLY public.user_table
    ADD CONSTRAINT user_table_username_key UNIQUE (username);


--
-- PostgreSQL database dump complete
--


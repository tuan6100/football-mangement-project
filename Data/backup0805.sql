--
-- PostgreSQL database dump
--

-- Dumped from database version 12.18 (Ubuntu 12.18-1.pgdg22.04+1)
-- Dumped by pg_dump version 12.18 (Ubuntu 12.18-1.pgdg22.04+1)

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
-- Name: calculate_ball_possession(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_ball_possession() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.ball_possession = 100 - (SELECT ball_possession FROM home WHERE home.match_id = NEW.match_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_ball_possession() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: away; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.away (
    match_id character varying(20) NOT NULL,
    club_id character varying(3) NOT NULL,
    ball_possession integer NOT NULL,
    num_of_goals integer NOT NULL,
    total_shots integer NOT NULL,
    shots_on_target integer NOT NULL,
    corner_kicks integer NOT NULL,
    offsides integer NOT NULL,
    fouls integer NOT NULL,
    penalties integer
);


ALTER TABLE public.away OWNER TO postgres;

--
-- Name: bundesliga; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.bundesliga AS
SELECT
    NULL::character varying(3) AS club_id,
    NULL::character varying(255) AS club_name,
    NULL::bigint AS point,
    NULL::bigint AS goal_diff,
    NULL::bigint AS total_goals;


ALTER TABLE public.bundesliga OWNER TO postgres;

--
-- Name: bundesliga_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.bundesliga_ranking AS
 SELECT bundesliga.club_id,
    rank() OVER (ORDER BY bundesliga.point DESC, bundesliga.goal_diff DESC, bundesliga.total_goals DESC) AS ranking
   FROM public.bundesliga;


ALTER TABLE public.bundesliga_ranking OWNER TO postgres;

--
-- Name: club; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.club (
    club_id character varying(3) NOT NULL,
    club_name character varying(255) NOT NULL,
    home_kit character varying(255) NOT NULL,
    away_kit character varying(255) NOT NULL,
    website character varying(255) NOT NULL
);


ALTER TABLE public.club OWNER TO postgres;

--
-- Name: coaching; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coaching (
    match_id character varying(20) NOT NULL,
    manager_id character varying(20) NOT NULL,
    yellow_cards integer,
    red_card integer
);


ALTER TABLE public.coaching OWNER TO postgres;

--
-- Name: home; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.home (
    match_id character varying(20) NOT NULL,
    club_id character varying(3) NOT NULL,
    ball_possession integer NOT NULL,
    num_of_goals integer NOT NULL,
    total_shots integer NOT NULL,
    shots_on_target integer NOT NULL,
    corner_kicks integer NOT NULL,
    offsides integer NOT NULL,
    fouls integer NOT NULL,
    penalties integer
);


ALTER TABLE public.home OWNER TO postgres;

--
-- Name: laliga; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.laliga AS
SELECT
    NULL::character varying(3) AS club_id,
    NULL::character varying(255) AS club_name,
    NULL::bigint AS point,
    NULL::bigint AS goal_diff,
    NULL::bigint AS total_goals;


ALTER TABLE public.laliga OWNER TO postgres;

--
-- Name: laliga_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.laliga_ranking AS
 SELECT laliga.club_id,
    rank() OVER (ORDER BY laliga.point DESC, laliga.goal_diff DESC, laliga.total_goals DESC) AS ranking
   FROM public.laliga;


ALTER TABLE public.laliga_ranking OWNER TO postgres;

--
-- Name: league; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.league (
    league_id character varying(6) NOT NULL,
    league_name character varying(255) NOT NULL,
    formula character varying(255) NOT NULL,
    website character varying(255),
    nation_id character varying(6)
);


ALTER TABLE public.league OWNER TO postgres;

--
-- Name: management; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.management (
    club_id character varying(3) NOT NULL,
    manager_id character varying(20) NOT NULL,
    year integer NOT NULL
);


ALTER TABLE public.management OWNER TO postgres;

--
-- Name: manager; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manager (
    manager_id character varying(20) NOT NULL,
    manager_name character varying(255) NOT NULL,
    age integer NOT NULL
);


ALTER TABLE public.manager OWNER TO postgres;

--
-- Name: match; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match (
    match_id character varying(20) NOT NULL,
    league_id character varying(6),
    round character varying(255),
    date_of_match date NOT NULL,
    stadium character varying(255) NOT NULL,
    referee character varying(255) NOT NULL
);


ALTER TABLE public.match OWNER TO postgres;

--
-- Name: nation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nation (
    nation_id character varying(6) NOT NULL,
    nation_name character varying(255) NOT NULL,
    continent character varying(255) NOT NULL,
    organization character varying
);


ALTER TABLE public.nation OWNER TO postgres;

--
-- Name: participation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.participation (
    parti_id character varying(20) NOT NULL,
    league_id character varying(6),
    club_id character varying(3),
    state text
);


ALTER TABLE public.participation OWNER TO postgres;

--
-- Name: player_honours; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_honours (
    player_id character varying(20) NOT NULL,
    league_id character varying(6) NOT NULL,
    year integer NOT NULL,
    honours text
);


ALTER TABLE public.player_honours OWNER TO postgres;

--
-- Name: player_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_profile (
    player_id character varying(6) NOT NULL,
    player_name character varying(255) NOT NULL,
    date_of_birth date NOT NULL,
    nation_id character varying(6),
    height integer NOT NULL,
    freferred_foot character(1) NOT NULL,
    CONSTRAINT player_profile_freferred_foot_check CHECK ((freferred_foot = ANY (ARRAY['L'::bpchar, 'R'::bpchar])))
);


ALTER TABLE public.player_profile OWNER TO postgres;

--
-- Name: player_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_role (
    transfer_id character varying(6) NOT NULL,
    player_id character varying(6),
    club_id character varying(3),
    shirt_number integer NOT NULL,
    "position" character varying(3) NOT NULL,
    transfer_date date,
    contract_duration integer,
    salary integer
);


ALTER TABLE public.player_role OWNER TO postgres;

--
-- Name: player_statistic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_statistic (
    player_id character varying(20) NOT NULL,
    match_id character varying(20) NOT NULL,
    rating double precision,
    score integer,
    assist integer,
    yellow_cards integer,
    red_cards integer,
    CONSTRAINT player_statistic_rating_check CHECK ((rating <= (10)::double precision)),
    CONSTRAINT player_statistic_red_cards_check CHECK ((red_cards <= 1)),
    CONSTRAINT player_statistic_yellow_cards_check CHECK ((yellow_cards <= 1))
);


ALTER TABLE public.player_statistic OWNER TO postgres;

--
-- Name: premierleague; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.premierleague AS
SELECT
    NULL::character varying(3) AS club_id,
    NULL::character varying(255) AS club_name,
    NULL::bigint AS point,
    NULL::bigint AS goal_diff,
    NULL::bigint AS total_goals;


ALTER TABLE public.premierleague OWNER TO postgres;

--
-- Name: premierleague_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.premierleague_ranking AS
 SELECT premierleague.club_id,
    rank() OVER (ORDER BY premierleague.point DESC, premierleague.goal_diff DESC, premierleague.total_goals DESC) AS ranking
   FROM public.premierleague;


ALTER TABLE public.premierleague_ranking OWNER TO postgres;

--
-- Name: seria; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.seria AS
SELECT
    NULL::character varying(3) AS club_id,
    NULL::character varying(255) AS club_name,
    NULL::bigint AS point,
    NULL::bigint AS goal_diff,
    NULL::bigint AS total_goals;


ALTER TABLE public.seria OWNER TO postgres;

--
-- Name: seria_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.seria_ranking AS
 SELECT seria.club_id,
    rank() OVER (ORDER BY seria.point DESC, seria.goal_diff DESC, seria.total_goals DESC) AS ranking
   FROM public.seria;


ALTER TABLE public.seria_ranking OWNER TO postgres;

--
-- Data for Name: away; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.away (match_id, club_id, ball_possession, num_of_goals, total_shots, shots_on_target, corner_kicks, offsides, fouls, penalties) FROM stdin;
#MUNLIV240407	LIV	62	2	28	7	11	2	10	\N
#MCIARS240331	ARS	27	0	6	2	4	1	20	\N
#LIVMCI240310	MCI	47	1	10	6	4	1	10	\N
#MCIMUN240303	MUN	27	1	3	1	2	1	10	\N
#MCICHE240218	CHE	29	1	9	6	1	5	12	\N
#ARSLIV240204	LIV	58	1	10	1	4	1	11	\N
#LIVMUN231217	MUN	31	0	6	1	0	2	6	\N
#MCITOT231203	TOT	45	3	8	4	8	2	14	\N
#MCILIV231125	LIV	40	1	8	3	6	4	11	\N
#CHEMCI231112	MCI	55	4	15	10	3	0	15	\N
#TOTCHE231107	CHE	62	4	17	8	6	7	21	\N
#MUNMCI231029	MCI	61	3	21	10	12	0	5	\N
#ARSMCI231008	MCI	51	0	4	2	4	2	7	\N
#TOTLIV230930	LIV	35	1	12	4	5	1	17	\N
#ARSTOT230924	TOT	54	2	13	5	4	3	19	\N
#ARSMUN230903	MUN	45	1	10	2	3	2	8	\N
#MUNLIV240317	LIV	59	3	25	11	8	4	12	\N
#MCICHE240420	CHE	37	0	10	5	4	2	11	\N
#CHELIV230813	LIV	35	1	13	1	4	5	13	\N
#RMABAR240422	BAR	54	2	15	6	8	2	12	\N
#ATMBAR240318	BAR	60	3	9	5	3	3	9	\N
#RMAATM240205	ATM	45	1	10	5	8	1	15	\N
#BARRMA231028	RMA	48	2	13	4	3	0	15	\N
#LEVBAY240211	BAY	61	0	9	1	6	1	13	\N
#BAYDOR240331	DOR	39	2	11	5	7	2	7	\N
#DORLEV20240421	LEV	52	1	13	3	2	0	11	\N
#ARSCHE24/4/24	CHE	56	0	7	1	2	0	11	\N
#LIVCHE240201	CHE	49	1	4	3	1	3	16	\N
\.


--
-- Data for Name: club; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.club (club_id, club_name, home_kit, away_kit, website) FROM stdin;
ARS	Arsenal	Đỏ	Vàng đen	https://www.arsenal.com/
CHE	Chelsea	Xanh đậm	Xanh đen	https://www.chelseafc.com
LIV	Liverpool	Đỏ	Trắng	https://www.liverpoolfc.com/
MCI	Manchester City	Xanh nhạt	Xanh đậm	https://www.mancity.com/
MUN	Manchester United	Đỏ	Trắng	https://www.manutd.com/
TOT	Tottenham Hospur	Trắng	Xám nâu	https://www.tottenhamhotspur.com/
RMA	Real Madrid	Trắng	Xanh đậm	https://www.realmadrid.com/en-US/football/first-team/home
BAR	Barcelona	Xanh đỏ	Vàng đen	https://www.fcbarcelona.com/en/
ATM	Atletico Madrid	Đỏ trắng	Xanh trắng	https://en.atleticodemadrid.com/
BAY	Bayern Munich	Đỏ	Đen	https://fcbayern.com/en
DOR	Dortmund	Vàng  đen	Vàng	https://www.bvb.de/eng
LEV	Bayer Leverkusen	Đen	Trắng	https://www.bayer04.de/en-us
JUV	Juventus	Trắng đen	Trắng 	https://www.juventus.com/en/
INT	Inter Milan	Xanh đen	Xanh	https://www.inter.it/it
MIL	AC Milan	Đỏ đen	Đỏ	https://www.acmilan.com/en
ROM	AS Roma	Đỏ	Đỏ	https://www.asroma.com/en
NAP	SSC Napoli	Xanh nhạt	Xanh	https://sscnapoli.it/en/
PSG	Paris Saint-Germain	Xanh đậm	Trắng 	https://en.psg.fr/
\.


--
-- Data for Name: coaching; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coaching (match_id, manager_id, yellow_cards, red_card) FROM stdin;
\.


--
-- Data for Name: home; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.home (match_id, club_id, ball_possession, num_of_goals, total_shots, shots_on_target, corner_kicks, offsides, fouls, penalties) FROM stdin;
#LIVCHE240201	LIV	51	4	28	13	8	3	15	\N
#MUNLIV240407	MUN	38	2	9	5	6	3	9	\N
#MCIARS240331	MCI	73	0	12	1	7	2	9	\N
#LIVMCI240310	LIV	53	1	19	6	7	6	6	\N
#MCIMUN240303	MCI	73	3	27	8	15	0	5	\N
#MCICHE240218	MCI	71	1	31	5	12	0	7	\N
#ARSLIV240204	ARS	42	3	15	7	2	3	11	\N
#LIVMUN231217	LIV	69	0	34	8	12	4	13	\N
#MCITOT231203	MCI	55	3	17	4	10	2	14	\N
#MCILIV231125	MCI	60	1	16	5	9	3	9	\N
#CHEMCI231112	CHE	45	4	17	9	3	1	13	\N
#TOTCHE231107	TOT	38	1	8	5	1	3	12	\N
#MUNMCI231029	MUN	39	0	7	3	7	4	9	\N
#ARSMCI231008	ARS	49	1	12	2	5	2	8	\N
#TOTLIV230930	TOT	65	2	24	8	11	4	11	\N
#ARSTOT230924	ARS	46	2	13	6	11	2	12	\N
#ARSMUN230903	ARS	55	3	17	5	12	2	8	\N
#MUNLIV240317	MUN	41	4	28	11	5	3	11	\N
#MCICHE240420	MCI	63	1	14	3	8	3	9	\N
#CHELIV230813	CHE	65	1	10	4	4	3	5	\N
#RMABAR240422	RMA	46	3	14	8	2	1	11	\N
#ATMBAR240318	ATM	40	0	13	3	7	8	15	\N
#RMAATM240205	RMA	55	1	17	4	2	2	6	\N
#BARRMA231028	BAR	52	1	15	3	6	1	15	\N
#LEVBAY240211	LEV	39	3	14	8	4	3	13	\N
#BAYDOR240331	BAY	61	0	17	2	7	2	7	\N
#DORLEV20240421	DOR	48	1	8	2	2	0	14	\N
#ARSCHE24/4/24	ARS	44	5	27	10	4	3	12	\N
\.


--
-- Data for Name: league; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.league (league_id, league_name, formula, website, nation_id) FROM stdin;
EL0001	Premier League	Đấu vòng tròn\t	\N	ENG
EL0002	FA Cup	Đấu cup\t	\N	ENG
EL0003	League Cup	Đấu cúp \t	\N	ENG
SL0001	Laliga	Đấu vòng tròn\t	\N	ESP
SL0002	La Copa del Rey	Đấu cúp\t	\N	ESP
IL0001	Serie A	Đâu vòng tròn\t	\N	ITA
GL0001	Bundesliga	Đấu vòng tròn\t	\N	GER
FL0001	 Ligue 1	Đấu vòng tròn\t	\N	FRA
\.


--
-- Data for Name: management; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.management (club_id, manager_id, year) FROM stdin;
ARS	ESP004	2019
CHE	ARG002	2023
LIV	GER001	2015
MCI	ESP001	2016
MUN	DUT001	2022
TOT	AUS001	2023
RMA	ITA001	2021
BAR	ESP003	2021
ATM	ARG001	2011
BAY	GER002	2023
DOR	GER003	2022
LEV	ESP004	2022
JUV	ITA002	2021
INT	ITA003	2020
MIL	ITA004	2021
ROM	ITA005	2024
NAP	ITA006	2021
PSG	ESP002	2023
\.


--
-- Data for Name: manager; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.manager (manager_id, manager_name, age) FROM stdin;
ITA001	Carlo Ancelotti	64
ESP001	Pep Guardiola	53
ARG001	Diego Simeone	53
ARG002	Mauricio Pochettino	52
GER001	Jurgen Klopp	56
DUT001	Erik Ten Hag	54
AUS001	Ange Postecoglou	58
ESP003	Xavier Hernandez	44
GER002	Thomas Tuchel	50
GER003	Edin Terzic	41
ESP004	Xabier Alonso	42
ITA002	Massimiliano Allegri	56
ITA003	Simeone Inzaghi	48
ITA004	Stefano Pioli	58
ITA005	Daniele De Rossi	40
ITA006	Francesco Calzona	55
ESP002	Luis Enrique	53
ESP005	Mikel Arteta	42
\.


--
-- Data for Name: match; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.match (match_id, league_id, round, date_of_match, stadium, referee) FROM stdin;
#MUNLIV240407	EL0001	32	2024-04-07	Old Trafford	Anthony Taylor\t
#MCIARS240331	EL0001	30	2024-03-31	Etihad Stadium	Anthony Taylor\t
#LIVMCI240310	EL0001	28	2024-03-10	Anfield	Michael Oliver\t
#MCIMUN240303	EL0001	27	2024-03-03	Etihad Stadium	Andy Madley\t
#MCICHE240218	EL0001	25	2024-02-18	Etihad Stadium	Andy Madley\t
#ARSLIV240204	EL0001	23	2024-02-04	Emirates Stadium	Anthony Taylor\t
#LIVMUN231217	EL0001	17	2023-12-17	Anfield	Michael Oliver\t
#MCITOT231203	EL0001	14	2023-12-03	Etihad Stadium	Simon Hooper\t
#MCILIV231125	EL0001	13	2023-11-23	Etihad Stadium	Chris Kavanagh\t
#CHEMCI231112	EL0001	12	2023-11-12	Stamford Bridge	Anthony Taylor\t
#TOTCHE231107	EL0001	11	2023-11-07	Tottenham Stadium	Michael Oliver\t
#MUNMCI231029	EL0001	10	2023-10-29	Old Trafford	Paul Tierney\t
#ARSMCI231008	EL0001	8	2023-10-08	Emirates Stadium	Michael Oliver\t
#TOTLIV230930	EL0001	7	2023-09-30	Tottenham Stadium	Simon Hooper\t
#ARSTOT230924	EL0001	6	2023-09-24	Emirates Stadium	Robert Jones\t
#ARSMUN230903	EL0001	4	2023-09-03	Emirates Stadium	Anthony Taylor\t
#CHELIV230813	EL0001	1	2023-08-13	Stamford Bridge	Anthony Taylor\t
#MUNLIV240317	EL0002	Tứ kết	2024-03-17	Old Trafford	John Brooks\t
#MCICHE240420	EL0002	Bán kết 	2024-04-20	Wembley	Michael Oliver\t
#CHELIV240225	EL0003	Chung kết	2024-02-25	Wembley	Chris Kavanagh\t
#RMABAR240422	SL0001	32	2024-04-22	Santiago Bernabéu	Cesar Soto Grado\t
#ATMBAR240318	SL0001	29	2024-03-18	Citivas Metropolitano	Jose Martinez\t
#RMAATM240205	SL0001	23	2024-02-05	Santiago Bernabéu	Jose Martinez\t
#BARRMA231028	SL0001	11	2023-10-28	Estadi Olimpic Lluis Companys	Jesus Manzano\t
#LEVBAY240211	GL0001	21	2024-02-21	BayArena	Felix Zwayer\t
#BAYDOR240331	GL0001	27	2024-03-31	Allianz Arena	Harm Osmers\t
#DORLEV20240421	GL0001	30	2024-04-21	Signal Iduna Park	Daniel Siebert\t
#ARSCHE24/4/24	EL0001	29	2024-04-24	Emirates Stadium	Simon Hooper\t
#LIVCHE240201	EL0001	22	2024-01-02	Anfield	Michael Oliver
\.


--
-- Data for Name: nation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nation (nation_id, nation_name, continent, organization) FROM stdin;
ESP	Tây Ban Nha	Châu Âu	\N
FRA	Pháp	Châu Âu	\N
BRA	Brazil	Nam Mỹ	\N
JAP	Nhật Bản	Châu Á	\N
UKR	Đức	Châu Âu	\N
ENG	Anh	Châu Âu	\N
ITA	Ý	Châu Âu	\N
GHA	Ghân	Châu Phi	\N
GER	Đức	Châu Âu	\N
NOR	Na Uy	Châu Âu	\N
BEL	Bỉ	Châu Âu	\N
SRB	Serbia	Châu ÂU	\N
ARG	Argentina	Nam Mỹ	\N
ECU	Ecuado 	Nam Mỹ	\N
SEN	Senegal	Châu Phi	\N
NED	Hà Lan	Châu Âu	\N
SCO	Scotland	Châu ÂU	\N
KOR	Hàn Quốc	Châu Á	\N
COL	Colombia	Nam Mỹ	\N
POR	Bồ Đào Nha	Châu Âu	\N
EGY	Hy Lạp	Châu Phi	\N
HUN	Hungary	Châu Âu	\N
URU	Uruguay	Nam Mỹ	\N
SUI	Thụy Sỹ	Châu ÂU	\N
CRO	Croatia	Châu Âu	\N
CMR	Camerun	Châu Phi	\N
DEN	Đan Mạch	Châu Âu	\N
SWE	Thụy Điển	Châu Âu	\N
WAL	Xứ Wales	Châu Âu	\N
AUT	Áo	Châu Âu	\N
POL	Bồ Đào Nha	Châu Âu	\N
SLO	Slovenia	Châu Âu	\N
MNE	Montenegro	Châu Âu	\N
CAN	Canada	Bắc Mỹ	\N
BUR	Burundi	Châu Phi	\N
MAR	Morocoo	Châu Phi	\N
TUR	Thổ Nhĩ Kỳ	Châu Âu	\N
CHI	Chile	Nam Mỹ	\N
SVK	Slovakia	Châu Âu	\N
\.


--
-- Data for Name: participation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.participation (parti_id, league_id, club_id, state) FROM stdin;
\.


--
-- Data for Name: player_honours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_honours (player_id, league_id, year, honours) FROM stdin;
\.


--
-- Data for Name: player_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_profile (player_id, player_name, date_of_birth, nation_id, height, freferred_foot) FROM stdin;
esp000	David Raya	1995-09-15	ESP	183	R
fra000	William Saliba	2001-03-24	FRA	193	R
bra000	Gabriel Magalhaes	1997-12-19	BRA	190	L
jap000	Takehiro Tomiyasu	1998-11-05	JAP	188	R
ukr000	Oleksandr Zinchenko	1996-12-15	UKR	175	L
eng000	Declan Rice	1999-01-14	ENG	188	R
ita000	Jorginho	1991-12-20	ITA	180	R
gha000	Thomas Partey	1993-06-13	GHA	185	R
ger000	Kai Havertz	1999-06-11	GER	193	L
nor000	Martin Odegaard	1998-12-17	NOR	178	L
bel000	Leandro Trossard	1994-12-04	BEL	172	R
bra001	Gabriel Martinelli	2001-06-18	BRA	180	R
eng001	Bukayo Saka	2001-09-05	ENG	178	L
bra002	Gabriel Jesus	1997-04-03	BRA	175	R
eng002	Benjamin White	1997-10-08	ENG	186	R
srb000	Dorde Petrovic	1999-10-08	SRB	194	R
bra003	Thiago Silva	1984-09-22	BRA	181	R
eng003	Trevoh Chalobah	1999-07-05	ENG	190	R
esp001	Marc Cucurella	1998-07-22	ESP	175	L
eng004	Ben Chiwell	1996-09-21	ENG	178	L
eng005	Reece James	1999-12-08	ENG	180	R
arg000	Enzo Fernandez	2001-01-17	ARG	177	R
ecu000	Moises Caicedo	2001-11-02	ECU	178	R
eng006	Cole Palmer	2002-05-06	ENG	188	L
eng007	Raheem Sterling	1994-12-08	ENG	170	R
eng008	Conor Gallagher	2000-02-06	ENG	182	R
ukr001	Mykhaylo Mudryk	2001-01-05	UKR	175	R
sen000	Nicolas Jackson	2001-06-20	SEN	186	R
bra004	Alisson	1992-10-02	BRA	191	R
ned000	Virgil van Dijk	1991-07-08	NED	193	R
eng009	Trent Alexander-Arnold	1998-10-07	ENG	180	R
sco000	Andrew Robertson	1994-03-11	SCO	178	L
kor000	Wataru Endo	1993-02-09	KOR	178	R
arg001	Alexis Mac Allister	1998-12-24	ARG	176	R
col000	Luis Diaz	1997-01-13	COL	178	R
por000	Diogo Jota	1996-12-04	POR	178	R
egy000	Mohamed Salah	1992-06-15	EGY	175	L
ned001	Cody Gakpo	1999-05-07	NED	193	R
hun000	Dominik Szoboszlai	2000-10-25	HUN	187	R
eng010	Harvey Ellioot	2003-04-04	ENG	170	L
eng011	Curtis Jones	2001-01-30	ENG	185	R
uru000	Darwin Nunez	1999-06-24	URU	188	R
bra005	Ederson Moraes	1993-08-17	BRA	188	L
por001	Rúben Dias	1997-05-14	POR	188	R
eng012	Kyle Walker	1990-05-28	ENG	183	R
sui000	Manuel Akanji	1995-07-19	SUI	187	R
eng013	John Stones	1994-05-28	ENG	188	R
ned002	Nathan Aké	1995-02-18	NED	180	L
cro000	Josko Gvardiol	2002-01-23	CRO	186	L
esp002	Rodri	1996-06-22	ESP	191	R
por002	Bernardo Silva	1994-08-10	POR	173	L
bel001	Kevin de Bruyne	1991-06-28	BEL	181	R
eng014	Phil Foden	2000-05-28	ENG	171	L
eng015	Jack Grealish	1995-09-10	ENG	180	R
bel002	Jérémy Doku	2002-05-27	BEL	173	R
arg002	Julian Alvarez	2000-01-31	ARG	170	R
nor001	Erling Haaland	2000-07-21	NOR	194	L
cmr000	André Onana	1996-04-02	CMR	190	R
eng016	Harry Maguire	1993-03-05	ENG	194	R
fra001	Raphael Varane	1993-04-25	FRA	191	R
eng017	Luke Shaw	1995-07-12	ENG	178	L
arg003	Lisandro Martinez	1998-01-18	ARG	175	L
bra006	Casemiro	1992-02-23	BRA	185	R
eng018	Mason Mount	1999-01-10	ENG	178	R
por003	Bruno Fernandes	1994-09-08	POR	179	R
arg004	Alejandro Garnacho	2004-07-01	ARG	180	R
eng019	Marcus Rashford	1997-10-31	ENG	187	R
den000	Rasmus Hojlund	2003-02-04	DEN	191	L
eng020	Kobbie Mainoo	2005-04-19	ENG	183	R
eng021	Aaron Wan-Bissaka	1997-11-26	ENG	183	R
ita001	Guglielmo Vicario	1996-10-07	ITA	194	R
arg005	Cristian Romero	1998-04-27	ARG	185	R
bra007	Emeson Royal	1999-01-14	BRA	183	R
swe000	Dejan Kulusevsky	2000-04-25	SWE	186	L
eng022	James Maddison	1996-11-23	ENG	175	R
bra008	Richarlison	1997-05-10	BRA	184	R
jap001	Heung-min Son	1992-07-08	JAP	184	L
ger001	Timo Werner	1996-03-06	GER	180	R
arg006	Giovani Lo Celso	1996-04-09	ARG	177	L
uru001	Rodrigo Bentancur	1997-06-25	URU	187	R
wal000	Ben Davies	1993-04-24	WAL	181	L
ukr002	Andry Lunin	1999-02-11	UKR	191	R
ger002	Antonio Rudiger	1993-03-03	GER	191	R
fra002	Ferland Mendy	2995-06-08	FRA	178	L
esp003	Daniel Cavajal	1992-01-11	ESP	173	R
fra003	Eduardo Canavinga	2002-11-10	FRA	182	L
fra004	Aurélien Tchouaméni	2000-01-27	FRA	188	R
uru002	Federico Valverde	1998-07-22	URU	181	R
ger003	Toni Kroos	1990-01-04	GER	183	R
eng023	Jude Bellingham	2003-06-25	ENG	188	R
cro001	Luka Modric	1985-09-09	CRO	173	R
bra009	Vinicius Junior	2000-07-12	BRA	176	R
bra010	Rodrygo	2001-01-09	BRA	174	R
bra011	Éder Militão	1998-01-18	BRA	186	R
aut000	David Alaba	1992-06-24	AUT	180	L
ger004	Marc-André ter Stegen	1992-04-30	GER	187	R
esp004	Sergi Roberto	1992-02-07	ESP	178	R
uru003	Ronald Araujo	1999-03-07	URU	191	R
fra005	Jules Koundé	1998-11-12	FRA	180	R
por004	João Cancelo	1994-05-27	POR	182	R
ger005	Ilkey Gundogan	1990-10-24	GER	180	R
esp005	Gavi	2004-08-05	ESP	173	R
esp006	Pedri	2002-11-25	ESP	174	R
por005	João Felix	1999-11-10	POR	181	R
ned003	Frenkie de Jong	1997-05-12	NED	180	R
bra012	Raphinha	1996-12-14	BRA	176	L
esp007	Lamine Yamal	2007-07-13	ESP	180	L
pol000	Robert Lewandowski	1988-08-21	POL	184	R
slo000	Jan Oblak	1993-01-07	SLO	189	R
esp008	César Azpilicueta	1989-06-28	ESP	178	R
uru004	José Giménez	1995-01-20	URU	185	R
uru005	Mario Hermoso	1995-06-18	URU	184	L
mne000	Stefan Savic	1991-01-08	MNE	186	R
arg007	Rodrigo de Paul	1994-05-24	ARG	180	R
esp009	Marcos Llorente	1995-01-30	ESP	184	R
esp010	Saul Niguez	1994-11-21	ESP	184	L
esp011	Koke	1992-01-08	ESP	177	R
fra006	Antoine Griezmann	1991-03-21	FRA	176	L
esp012	Ávaro Morata	1992-10-23	ESP	189	R
ned004	Memphis Depay	1994-02-13	NED	176	R
arg008	Ángel Correa	1995-03-09	ARG	171	R
ger006	Manuel Neuer	1986-03-27	GER	193	R
fra007	Dayot Upamecano	1998-10-27	FRA	185	R
kor001	Min-Jae Kim	1996-11-15	KOR	190	R
ned005	Matthijs de Ligt	1999-08-12	NED	188	R
eng024	Eric Dier	1994-01-16	ENG	191	R
can000	Alphonso Davies	2000-11-02	CAN	183	L
ger007	Joshua Kimmich	1995-02-08	GER	176	R
ger008	Leon Goretzka	1995-02-06	GER	189	R
aut001	Konrad Laimer	1997-05-27	AUT	180	R
ger009	Jamal Musiala	2003-02-26	GER	184	R
ger010	Thomas Muller	1989-09-13	GER	186	R
ger011	Leroy Sané	1996-01-11	GER	184	L
ger012	Serge Gnabry	1995-07-14	GER	176	R
fra008	Kingsley Coman	1996-06-13	FRA	178	R
eng025	Harry Kane	1993-06-25	ENG	188	R
sui001	Gregor Kobel	1997-12-06	SUI	193	R
ger013	Niklas Sule	1995-09-03	GER	195	R
ger014	Mats Hummels	1988-12-16	GER	191	R
ned006	Ian Maatsem	2002-03-10	NED	178	L
ger015	Marius Wofl	1995-04-27	GER	187	R
aut002	Marcel Sabitzer	1994-03-17	AUT	177	R
eng026	Jadon Sancho	2000-03-25	ENG	180	R
ger016	Erme Can	1994-01-12	GER	186	R
ger017	Julian Brandt	1996-05-02	GER	186	R
ger018	Marco Reus	1989-05-31	GER	180	R
ger019	Niclas Fullkrug	1993-02-09	GER	188	R
ger020	Matej Kovar	2000-05-17	GER	196	R
ger021	Jonathan Tah	1996-02-11	GER	194	R
bur000	Edmond Tapsoba	1999-02-02	BUR	193	R
ecu001	Piero Hincapie	2002-01-09	ECU	181	L
sui002	Granit Xhaka	1992-09-27	SUI	185	L
esp013	Alejandro Grimaldo	1995-09-20	ESP	171	L
ned007	Jeremie Frimpong	2000-12-10	NED	171	R
ger022	Robert Andrich	1994-09-22	GER	189	R
cro002	Josip Stanisic	2000-04-02	CRO	186	R
ger023	Florian Wirtz	2003-05-03	GER	175	R
mar000	Amine Adli	2000-05-10	MAR	174	L
sui003	Yann Sommer	1988-12-17	SUI	183	R
fra009	Benjamin Pavard	1996-03-28	FRA	186	R
ita002	Alessandro Bastoni	1999-06-30	ITA	190	L
ned008	Stefan de Vrij	1992-12-05	NED	188	R
tur000	Hakan Çalhanoglu	1994-02-08	TUR	178	R
col001	Juan Cuadrado 	1988-05-26	COL	179	R
ned009	Denzel Dumfries	1996-04-18	NED	189	R
ita003	Federico Dimarco	1997-11-10	ITA	174	L
ita004	Nicolo Barella	1997-02-07	ITA	175	R
bra013	Carlos Augusto	1999-01-07	BRA	184	L
ita005	Davide Frattesi	1999-09-22	ITA	178	R
fra010	Marcus Thuram	1997-08-06	FRA	192	R
chi000	Alexis Sanchez	1988-12-19	CHI	169	R
arg009	Lautaro Martínez	1997-08-22	ARG	175	R
ita006	Gianluigi Donnarumma	1999-02-25	ITA	196	R
mar001	Achraf Hakimi	1998-11-04	MAR	181	R
fra011	Lucas Hernández	1996-02-14	FRA	183	L
svk000	Milan Skriniar	1995-02-11	SVK	187	R
bra014	Marquinhos	1994-05-14	BRA	183	R
por006	Nuno Mendes	2002-06-19	POR	183	L
por007	Danilo Pereira	1991-09-09	POR	187	R
kor002	Kang-in Lee	2001-02-19	KOR	173	L
por008	Vitinha	2000-02-11	POR	172	R
fra012	Kylian Mbappé	1998-12-20	FRA	178	R
fra013	Ousmane dembélé	1997-05-15	FRA	178	L
esp014	Fabian Ruiz	1996-04-03	ESP	189	L
uru006	Manuel Ugarte	2001-04-11	URU	182	R
esp015	Marco Asensio	1996-01-21	ESP	182	L
por009	Gonçalo Ramos	2001-06-20	POR	185	R
\.


--
-- Data for Name: player_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_role (transfer_id, player_id, club_id, shirt_number, "position", transfer_date, contract_duration, salary) FROM stdin;
ARS001	esp000	ARS	22	GK	\N	\N	\N
ARS002	fra000	ARS	2	CB	\N	\N	\N
ARS003	bra000	ARS	6	CB	\N	\N	\N
ARS004	jap000	ARS	18	RB	\N	\N	\N
ARS005	ukr000	ARS	35	LB	\N	\N	\N
ARS006	eng000	ARS	41	DM	\N	\N	\N
ARS007	ita000	ARS	20	CM	\N	\N	\N
ARS008	gha000	ARS	5	DM	\N	\N	\N
ARS009	ger000	ARS	29	AM	\N	\N	\N
ARS010	nor000	ARS	8	AM	\N	\N	\N
ARS011	bel000	ARS	19	LW	\N	\N	\N
ARS012	bra001	ARS	11	LW	\N	\N	\N
ARS013	eng001	ARS	7	RW	\N	\N	\N
ARS014	bra002	ARS	9	ST	\N	\N	\N
ARS015	eng002	ARS	4	CB	\N	\N	\N
CHE001	srb000	CHE	28	GK	\N	\N	\N
CHE002	bra003	CHE	6	CB	\N	\N	\N
CHE003	eng003	CHE	14	CB	\N	\N	\N
CHE004	esp001	CHE	3	CB	\N	\N	\N
CHE005	eng004	CHE	21	LB	\N	\N	\N
CHE006	eng005	CHE	24	RB	\N	\N	\N
CHE009	arg000	CHE	8	CM	\N	\N	\N
CHE010	ecu000	CHE	25	DM	\N	\N	\N
CHE011	eng006	CHE	20	AM	\N	\N	\N
CHE012	eng007	CHE	7	LW	\N	\N	\N
CHE013	sen000	CHE	15	ST	\N	\N	\N
LIV001	bra004	LIV	1	GK	\N	\N	\N
LIV002	ned000	LIV	4	CB	\N	\N	\N
LIV003	eng008	LIV	66	RB	\N	\N	\N
LIV004	sco000	LIV	26	LB	\N	\N	\N
LIV005	kor000	LIV	3	DM	\N	\N	\N
LIV006	arg001	LIV	10	CM	\N	\N	\N
LIV007	col000	LIV	7	LW	\N	\N	\N
LIV008	por000	LIV	20	LW	\N	\N	\N
LIV009	egy000	LIV	11	RW	\N	\N	\N
LIV010	ned001	LIV	18	ST	\N	\N	\N
LIV012	hun000	LIV	8	CM	\N	\N	\N
LIV013	eng009	LIV	19	CM	\N	\N	\N
LIV014	eng010	LIV	17	CM	\N	\N	\N
LIV011	uru000	LIV	9	ST	\N	\N	\N
MCI001	bra005	MCI	31	GK	\N	\N	\N
MCI002	por001	MCI	3	CB	\N	\N	\N
MCI003	eng011	MCI	2	RB	\N	\N	\N
MCI004	sui000	MCI	25	CB	\N	\N	\N
MCI005	eng012	MCI	5	CB	\N	\N	\N
MCI006	ned002	MCI	6	CB	\N	\N	\N
MCI007	cro000	MCI	24	LB	\N	\N	\N
MCI008	esp002	MCI	16	DM	\N	\N	\N
MCI009	por002	MCI	20	AM	\N	\N	\N
MCI010	bel001	MCI	17	AM	\N	\N	\N
MCI011	eng013	MCI	47	RW	\N	\N	\N
MCI012	eng014	MCI	10	LW	\N	\N	\N
MCI013	bel002	MCI	11	LW	\N	\N	\N
MCI014	arg002	MCI	19	ST	\N	\N	\N
MCI015	nor001	MCI	9	ST	\N	\N	\N
MUN001	cmr000	MUN	24	GK	\N	\N	\N
MUN002	eng015	MUN	5	CB	\N	\N	\N
MUN003	fra001	MUN	19	CB	\N	\N	\N
MUN004	eng016	MUN	23	LB	\N	\N	\N
MUN005	arg003	MUN	6	CB	\N	\N	\N
MUN006	bra006	MUN	18	DM	\N	\N	\N
MUN007	eng017	MUN	7	AM	\N	\N	\N
MUN008	por003	MUN	8	AM	\N	\N	\N
MUN009	arg004	MUN	17	LW	\N	\N	\N
MUN010	eng018	MUN	10	LW	\N	\N	\N
MUN011	den000	MUN	11	ST	\N	\N	\N
MUN012	eng019	MUN	37	CM	\N	\N	\N
MUN013	eng020	MUN	29	RB	\N	\N	\N
TOT001	ita001	TOT	13	GK	\N	\N	\N
TOT002	arg005	TOT	17	CB	\N	\N	\N
TOT003	bra007	TOT	12	RB	\N	\N	\N
TOT004	swe000	TOT	21	RW	\N	\N	\N
TOT005	eng021	TOT	10	AM	\N	\N	\N
TOT006	bra008	TOT	9	ST	\N	\N	\N
TOT007	jap001	TOT	7	LW	\N	\N	\N
TOT008	ger001	TOT	16	ST	\N	\N	\N
TOT009	arg006	TOT	18	CM	\N	\N	\N
TOT010	uru001	TOT	30	CM	\N	\N	\N
TOT011	wal000	TOT	33	CB	\N	\N	\N
RMA001	ukr001	RMA	13	GK	\N	\N	\N
RMA002	ger002	RMA	22	CB	\N	\N	\N
RMA003	fra002	RMA	23	LB	\N	\N	\N
RMA004	esp003	RMA	32	RB	\N	\N	\N
RMA005	fra003	RMA	12	DM	\N	\N	\N
RMA006	fra004	RMA	18	DM	\N	\N	\N
RMA007	uru002	RMA	15	CM	\N	\N	\N
RMA008	ger003	RMA	8	CM	\N	\N	\N
RMA009	eng022	RMA	5	AM	\N	\N	\N
RMA010	cro001	RMA	10	CM	\N	\N	\N
RMA011	bra009	RMA	7	LW	\N	\N	\N
RMA012	bra010	RMA	11	LW	\N	\N	\N
RMA013	bra011	RMA	26	CB	\N	\N	\N
RMA014	aut000	RMA	4	CB	\N	\N	\N
BAR001	ger004	BAR	1	GK	\N	\N	\N
BAR002	esp004	BAR	20	RB	\N	\N	\N
BAR003	uru003	BAR	23	CB	\N	\N	\N
BAR004	fra005	BAR	4	CB	\N	\N	\N
BAR005	por004	BAR	2	LB	\N	\N	\N
BAR006	ger005	BAR	22	CM	\N	\N	\N
BAR007	esp005	BAR	6	CM	\N	\N	\N
BAR008	esp006	BAR	7	AM	\N	\N	\N
BAR009	por005	BAR	14	LW	\N	\N	\N
BAR010	ned003	BAR	21	CM	\N	\N	\N
BAR011	bra012	BAR	11	RW	\N	\N	\N
BAR012	esp007	BAR	27	RW	\N	\N	\N
BAR013	pol000	BAR	9	ST	\N	\N	\N
ATM001	slo000	ATM	13	GK	\N	\N	\N
ATM002	esp008	ATM	3	RB	\N	\N	\N
ATM003	uru004	ATM	2	CB	\N	\N	\N
ATM004	uru005	ATM	22	CB	\N	\N	\N
ATM005	mne000	ATM	15	CB	\N	\N	\N
ATM006	arg007	ATM	5	DM	\N	\N	\N
ATM007	esp009	ATM	5	RW	\N	\N	\N
ATM008	esp010	ATM	8	CM	\N	\N	\N
ATM009	esp011	ATM	6	CM	\N	\N	\N
ATM010	fra006	ATM	7	AM	\N	\N	\N
ATM011	esp012	ATM	19	ST	\N	\N	\N
ATM012	ned004	ATM	9	ST	\N	\N	\N
ATM013	arg008	ATM	10	LW	\N	\N	\N
BAY001	ger006	BAY	1	GK	\N	\N	\N
BAY002	fra007	BAY	2	CB	\N	\N	\N
BAY003	kor001	BAY	3	CB	\N	\N	\N
BAY004	ned005	BAY	4	CB	\N	\N	\N
BAY005	eng023	BAY	15	CB	\N	\N	\N
BAY006	can000	BAY	19	LB	\N	\N	\N
BAY007	ger007	BAY	6	DM	\N	\N	\N
BAY008	ger008	BAY	8	CM	\N	\N	\N
BAY009	aut001	BAY	27	DM	\N	\N	\N
BAY010	ger009	BAY	42	AM	\N	\N	\N
BAY011	ger010	BAY	25	ST	\N	\N	\N
BAY012	ger011	BAY	10	LW	\N	\N	\N
BAY013	ger012	BAY	7	RW	\N	\N	\N
BAY014	fra008	BAY	11	LW	\N	\N	\N
BAY015	eng025	BAY	9	ST	\N	\N	\N
DOR001	sui001	DOR	1	GK	\N	\N	\N
DOR002	ger013	DOR	25	CB	\N	\N	\N
DOR003	ger014	DOR	15	CB	\N	\N	\N
DOR004	ned006	DOR	22	LB	\N	\N	\N
DOR005	ger015	DOR	17	RB	\N	\N	\N
DOR006	aut002	DOR	20	CM	\N	\N	\N
DOR007	eng026	DOR	10	LW	\N	\N	\N
DOR008	ger016	DOR	23	DM	\N	\N	\N
DOR009	ger017	DOR	19	AM	\N	\N	\N
DOR010	ger018	DOR	11	AM	\N	\N	\N
DOR011	ger019	DOR	14	ST	\N	\N	\N
LEV001	ger020	LEV	17	GK	\N	\N	\N
LEV002	ger021	LEV	4	CM	\N	\N	\N
LEV003	bur000	LEV	12	CB	\N	\N	\N
LEV004	ecu001	LEV	3	CB	\N	\N	\N
LEV005	sui002	LEV	34	DM	\N	\N	\N
LEV006	esp013	LEV	20	LB	\N	\N	\N
LEV007	ned007	LEV	30	RM	\N	\N	\N
LEV008	ger022	LEV	8	DM	\N	\N	\N
LEV009	cro002	LEV	2	CB	\N	\N	\N
LEV010	ger023	LEV	10	AM	\N	\N	\N
LEV011	mar000	LEV	21	LW	\N	\N	\N
INT001	sui003	INT	1	GK	\N	\N	\N
INT002	fra009	INT	21	CB	\N	\N	\N
INT003	ita002	INT	95	CB	\N	\N	\N
INT004	ned008	INT	6	CB	\N	\N	\N
INT005	tur000	INT	20	DM	\N	\N	\N
INT006	col001	INT	7	CM	\N	\N	\N
INT007	ned009	INT	2	DM	\N	\N	\N
INT008	ita003	INT	32	LB	\N	\N	\N
INT009	ita004	INT	23	CM	\N	\N	\N
INT010	bra013	INT	30	CM	\N	\N	\N
INT011	ita005	INT	16	CM	\N	\N	\N
INT012	fra010	INT	9	ST	\N	\N	\N
INT013	chi000	INT	70	ST	\N	\N	\N
INT014	arg009	INT	10	CF	\N	\N	\N
PSG001	ita006	PSG	99	GK	\N	\N	\N
PSG002	mar001	PSG	2	RB	\N	\N	\N
PSG003	fra011	PSG	21	LB	\N	\N	\N
PSG004	svk000	PSG	37	CB	\N	\N	\N
PSG005	bra014	PSG	5	CB	\N	\N	\N
PSG006	por006	PSG	25	LB	\N	\N	\N
PSG007	por007	PSG	15	DM	\N	\N	\N
PSG008	kor002	PSG	19	AM	\N	\N	\N
PSG009	por008	PSG	17	CM	\N	\N	\N
PSG010	fra012	PSG	7	LW	\N	\N	\N
PSG011	fra013	PSG	10	RW	\N	\N	\N
PSG012	esp014	PSG	8	CM	\N	\N	\N
PSG013	uru006	PSG	4	DM	\N	\N	\N
PSG014	esp015	PSG	11	RW	\N	\N	\N
PSG015	por009	PSG	9	ST	\N	\N	\N
\.


--
-- Data for Name: player_statistic; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_statistic (player_id, match_id, rating, score, assist, yellow_cards, red_cards) FROM stdin;
cmr000	#MUNLIV240407	\N	0	0	1	0
eng015	#MUNLIV240407	\N	0	0	0	0
fra001	#MUNLIV240407	\N	0	0	0	0
eng019	#MUNLIV240407	\N	1	0	0	0
arg003	#MUNLIV240407	\N	0	0	0	0
bra006	#MUNLIV240407	\N	0	0	1	0
eng020	#MUNLIV240407	\N	0	1	0	0
por003	#MUNLIV240407	\N	1	0	0	0
arg004	#MUNLIV240407	\N	0	0	0	0
eng018	#MUNLIV240407	\N	0	0	1	0
den000	#MUNLIV240407	\N	0	0	0	0
bra004	#MUNLIV240407	\N	0	0	0	0
ned000	#MUNLIV240407	\N	0	0	0	0
eng008	#MUNLIV240407	\N	0	0	0	0
sco000	#MUNLIV240407	\N	0	0	0	0
kor000	#MUNLIV240407	\N	0	0	0	0
arg001	#MUNLIV240407	\N	0	0	0	0
col000	#MUNLIV240407	\N	1	0	0	0
por000	#MUNLIV240407	\N	0	0	0	0
egy000	#MUNLIV240407	\N	1	0	0	0
ned001	#MUNLIV240407	\N	0	0	0	0
hun000	#MUNLIV240407	\N	0	0	0	0
eng009	#MUNLIV240407	\N	0	0	0	0
eng010	#MUNLIV240407	\N	0	0	0	0
uru000	#MUNLIV240407	\N	0	1	0	0
bra004	#LIVMCI240310	\N	0	0	0	0
ned000	#LIVMCI240310	\N	0	0	0	0
eng008	#LIVMCI240310	\N	0	0	0	0
sco000	#LIVMCI240310	\N	0	0	0	0
kor000	#LIVMCI240310	\N	0	0	0	0
arg001	#LIVMCI240310	\N	1	0	0	0
col000	#LIVMCI240310	\N	0	0	0	0
por000	#LIVMCI240310	\N	0	0	0	0
egy000	#LIVMCI240310	\N	0	0	0	0
ned001	#LIVMCI240310	\N	0	0	0	0
hun000	#LIVMCI240310	\N	0	0	0	0
eng009	#LIVMCI240310	\N	0	0	0	0
eng010	#LIVMCI240310	\N	0	0	0	0
uru000	#LIVMCI240310	\N	0	0	0	0
bra005	#LIVMCI240310	\N	0	0	1	0
por001	#LIVMCI240310	\N	0	0	0	0
eng011	#LIVMCI240310	\N	0	0	0	0
sui000	#LIVMCI240310	\N	0	0	0	0
eng012	#LIVMCI240310	\N	1	0	0	0
esp002	#LIVMCI240310	\N	0	0	1	0
por002	#LIVMCI240310	\N	0	1	1	0
bel001	#LIVMCI240310	\N	0	0	0	0
eng013	#LIVMCI240310	\N	0	0	0	0
eng014	#LIVMCI240310	\N	0	0	0	0
bel002	#LIVMCI240310	\N	0	0	0	0
arg002	#LIVMCI240310	\N	0	0	0	0
nor001	#LIVMCI240310	\N	0	0	0	0
bra005	#MCIMUN240303	\N	0	0	0	0
por001	#MCIMUN240303	\N	0	0	0	0
eng011	#MCIMUN240303	\N	0	0	0	0
sui000	#MCIMUN240303	\N	0	0	0	0
eng012	#MCIMUN240303	\N	0	0	0	0
ned002	#MCIMUN240303	\N	0	0	0	0
cro000	#MCIMUN240303	\N	0	0	0	0
esp002	#MCIMUN240303	\N	0	2	0	0
por002	#MCIMUN240303	\N	0	0	0	0
bel001	#MCIMUN240303	\N	0	0	0	0
eng013	#MCIMUN240303	\N	2	0	0	0
eng014	#MCIMUN240303	\N	0	0	0	0
bel002	#MCIMUN240303	\N	0	0	0	0
arg002	#MCIMUN240303	\N	0	1	0	0
nor001	#MCIMUN240303	\N	1	0	0	0
cmr000	#MCIMUN240303	\N	0	0	0	0
eng015	#MCIMUN240303	\N	0	0	0	0
fra001	#MCIMUN240303	\N	0	0	1	0
eng016	#MCIMUN240303	\N	0	0	0	0
arg003	#MCIMUN240303	\N	0	0	0	0
bra006	#MCIMUN240303	\N	0	0	0	0
eng017	#MCIMUN240303	\N	0	0	0	0
por003	#MCIMUN240303	\N	0	1	0	0
arg004	#MCIMUN240303	\N	0	0	0	0
eng018	#MCIMUN240303	\N	1	0	0	0
den000	#MCIMUN240303	\N	0	0	0	0
eng019	#MCIMUN240303	\N	0	0	0	0
eng020	#MCIMUN240303	\N	0	0	0	0
esp000	#ARSLIV240204	\N	0	0	\N	0
fra000	#ARSLIV240204	\N	0	0	1	0
bra000	#ARSLIV240204	\N	-1	0	1	0
jap000	#ARSLIV240204	\N	0	0	0	0
ukr000	#ARSLIV240204	\N	0	0	0	0
eng000	#ARSLIV240204	\N	0	0	1	0
ita000	#ARSLIV240204	\N	0	0	0	0
gha000	#ARSLIV240204	\N	0	0	0	0
ger000	#ARSLIV240204	\N	0	0	1	0
nor000	#ARSLIV240204	\N	0	0	0	0
bel000	#ARSLIV240204	\N	1	0	0	0
bra001	#ARSLIV240204	\N	1	0	0	0
eng001	#ARSLIV240204	\N	1	0	0	0
bra002	#ARSLIV240204	\N	0	0	0	0
eng002	#ARSLIV240204	\N	0	0	1	0
bra004	#ARSLIV240204	\N	0	0	0	0
ned000	#ARSLIV240204	\N	0	0	0	0
eng008	#ARSLIV240204	\N	0	0	0	0
sco000	#ARSLIV240204	\N	0	0	0	0
kor000	#ARSLIV240204	\N	0	0	0	0
arg001	#ARSLIV240204	\N	0	0	0	0
col000	#ARSLIV240204	\N	0	0	0	0
por000	#ARSLIV240204	\N	0	0	0	0
egy000	#ARSLIV240204	\N	0	0	0	0
ned001	#ARSLIV240204	\N	0	0	0	0
hun000	#ARSLIV240204	\N	0	0	0	0
eng009	#ARSLIV240204	\N	0	0	0	0
eng010	#ARSLIV240204	\N	0	0	0	0
uru000	#ARSLIV240204	\N	0	0	1	\N
esp000	#ARSCHE24/4/24	\N	0	0	0	0
fra000	#ARSCHE24/4/24	\N	0	0	0	0
bra000	#ARSCHE24/4/24	\N	0	0	0	0
jap000	#ARSCHE24/4/24	\N	0	0	0	0
ukr000	#ARSCHE24/4/24	\N	2	0	0	0
eng000	#ARSCHE24/4/24	\N	0	1	0	0
ita000	#ARSCHE24/4/24	\N	0	0	0	0
gha000	#ARSCHE24/4/24	\N	0	0	0	0
ger000	#ARSCHE24/4/24	\N	2	0	0	0
nor000	#ARSCHE24/4/24	\N	0	2	0	0
bel000	#ARSCHE24/4/24	\N	1	0	1	0
bra001	#ARSCHE24/4/24	\N	0	0	0	0
eng001	#ARSCHE24/4/24	\N	0	1	0	0
bra002	#ARSCHE24/4/24	\N	0	0	0	0
eng002	#ARSCHE24/4/24	\N	2	0	1	0
srb000	#ARSCHE24/4/24	\N	0	0	0	0
bra003	#ARSCHE24/4/24	\N	0	0	0	0
eng003	#ARSCHE24/4/24	\N	0	0	0	0
esp001	#ARSCHE24/4/24	\N	0	0	1	0
eng004	#ARSCHE24/4/24	\N	0	0	0	0
eng005	#ARSCHE24/4/24	\N	0	0	0	0
arg000	#ARSCHE24/4/24	\N	0	0	0	0
ecu000	#ARSCHE24/4/24	\N	0	0	0	0
eng006	#ARSCHE24/4/24	\N	0	0	0	0
eng007	#ARSCHE24/4/24	\N	0	0	0	0
sen000	#ARSCHE24/4/24	\N	0	0	0	0
\.


--
-- Name: away away_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.away
    ADD CONSTRAINT away_pkey PRIMARY KEY (match_id, club_id);


--
-- Name: club club_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club
    ADD CONSTRAINT club_pkey PRIMARY KEY (club_id);


--
-- Name: coaching coaching_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaching
    ADD CONSTRAINT coaching_pkey PRIMARY KEY (match_id, manager_id);


--
-- Name: home home_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home
    ADD CONSTRAINT home_pkey PRIMARY KEY (match_id, club_id);


--
-- Name: league league_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.league
    ADD CONSTRAINT league_pkey PRIMARY KEY (league_id);


--
-- Name: management management_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management
    ADD CONSTRAINT management_pkey PRIMARY KEY (club_id, manager_id);


--
-- Name: manager manager_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manager
    ADD CONSTRAINT manager_pkey PRIMARY KEY (manager_id);


--
-- Name: match match_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_pkey PRIMARY KEY (match_id);


--
-- Name: nation nation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nation
    ADD CONSTRAINT nation_pkey PRIMARY KEY (nation_id);


--
-- Name: participation participation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participation
    ADD CONSTRAINT participation_pkey PRIMARY KEY (parti_id);


--
-- Name: player_honours player_honours_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_honours
    ADD CONSTRAINT player_honours_pkey PRIMARY KEY (player_id, league_id);


--
-- Name: player_profile player_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_profile
    ADD CONSTRAINT player_profile_pkey PRIMARY KEY (player_id);


--
-- Name: player_role player_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_role
    ADD CONSTRAINT player_role_pkey PRIMARY KEY (transfer_id);


--
-- Name: player_statistic player_statistic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_statistic
    ADD CONSTRAINT player_statistic_pkey PRIMARY KEY (player_id, match_id);


--
-- Name: premierleague _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.premierleague AS
 SELECT club.club_id,
    club.club_name,
    sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END) AS point,
    (sum(home.num_of_goals) - sum(away.num_of_goals)) AS goal_diff,
    sum(home.num_of_goals) AS total_goals
   FROM (((public.match
     JOIN public.home ON (((match.match_id)::text = (home.match_id)::text)))
     JOIN public.away ON (((match.match_id)::text = (away.match_id)::text)))
     JOIN public.club ON (((club.club_id)::text = (home.club_id)::text)))
  WHERE ((match.league_id)::text = 'EL0001'::text)
  GROUP BY club.club_id
  ORDER BY (sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END)) DESC, (sum(home.num_of_goals) - sum(away.num_of_goals)) DESC, (sum(home.num_of_goals)) DESC;


--
-- Name: laliga _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.laliga AS
 SELECT club.club_id,
    club.club_name,
    sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END) AS point,
    (sum(home.num_of_goals) - sum(away.num_of_goals)) AS goal_diff,
    sum(home.num_of_goals) AS total_goals
   FROM (((public.match
     JOIN public.home ON (((match.match_id)::text = (home.match_id)::text)))
     JOIN public.away ON (((match.match_id)::text = (away.match_id)::text)))
     JOIN public.club ON (((club.club_id)::text = (home.club_id)::text)))
  WHERE ((match.league_id)::text = 'SL0001'::text)
  GROUP BY club.club_id
  ORDER BY (sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END)) DESC, (sum(home.num_of_goals) - sum(away.num_of_goals)) DESC, (sum(home.num_of_goals)) DESC;


--
-- Name: seria _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.seria AS
 SELECT club.club_id,
    club.club_name,
    sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END) AS point,
    (sum(home.num_of_goals) - sum(away.num_of_goals)) AS goal_diff,
    sum(home.num_of_goals) AS total_goals
   FROM (((public.match
     JOIN public.home ON (((match.match_id)::text = (home.match_id)::text)))
     JOIN public.away ON (((match.match_id)::text = (away.match_id)::text)))
     JOIN public.club ON (((club.club_id)::text = (home.club_id)::text)))
  WHERE ((match.league_id)::text = 'IL0001'::text)
  GROUP BY club.club_id
  ORDER BY (sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END)) DESC, (sum(home.num_of_goals) - sum(away.num_of_goals)) DESC, (sum(home.num_of_goals)) DESC;


--
-- Name: bundesliga _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.bundesliga AS
 SELECT club.club_id,
    club.club_name,
    sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END) AS point,
    (sum(home.num_of_goals) - sum(away.num_of_goals)) AS goal_diff,
    sum(home.num_of_goals) AS total_goals
   FROM (((public.match
     JOIN public.home ON (((match.match_id)::text = (home.match_id)::text)))
     JOIN public.away ON (((match.match_id)::text = (away.match_id)::text)))
     JOIN public.club ON (((club.club_id)::text = (home.club_id)::text)))
  WHERE ((match.league_id)::text = 'GL0001'::text)
  GROUP BY club.club_id
  ORDER BY (sum(
        CASE
            WHEN (home.num_of_goals > away.num_of_goals) THEN 3
            WHEN (home.num_of_goals = away.num_of_goals) THEN 1
            ELSE 0
        END)) DESC, (sum(home.num_of_goals) - sum(away.num_of_goals)) DESC, (sum(home.num_of_goals)) DESC;


--
-- Name: away trigger_calculate_ball_possession; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_calculate_ball_possession BEFORE INSERT ON public.away FOR EACH ROW EXECUTE FUNCTION public.calculate_ball_possession();


--
-- Name: away away_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.away
    ADD CONSTRAINT away_club_id_fkey FOREIGN KEY (club_id) REFERENCES public.club(club_id);


--
-- Name: away away_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.away
    ADD CONSTRAINT away_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id);


--
-- Name: coaching coaching_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaching
    ADD CONSTRAINT coaching_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.manager(manager_id);


--
-- Name: coaching coaching_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaching
    ADD CONSTRAINT coaching_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id);


--
-- Name: home home_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home
    ADD CONSTRAINT home_club_id_fkey FOREIGN KEY (club_id) REFERENCES public.club(club_id);


--
-- Name: home home_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home
    ADD CONSTRAINT home_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id);


--
-- Name: league league_nation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.league
    ADD CONSTRAINT league_nation_id_fkey FOREIGN KEY (nation_id) REFERENCES public.nation(nation_id);


--
-- Name: management management_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management
    ADD CONSTRAINT management_club_id_fkey FOREIGN KEY (club_id) REFERENCES public.club(club_id);


--
-- Name: management management_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management
    ADD CONSTRAINT management_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.manager(manager_id);


--
-- Name: match match_league_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.league(league_id);


--
-- Name: participation participation_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participation
    ADD CONSTRAINT participation_club_id_fkey FOREIGN KEY (club_id) REFERENCES public.club(club_id);


--
-- Name: participation participation_league_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participation
    ADD CONSTRAINT participation_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.league(league_id);


--
-- Name: player_honours player_honours_league_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_honours
    ADD CONSTRAINT player_honours_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.league(league_id);


--
-- Name: player_honours player_honours_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_honours
    ADD CONSTRAINT player_honours_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player_profile(player_id);


--
-- Name: player_profile player_profile_nation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_profile
    ADD CONSTRAINT player_profile_nation_id_fkey FOREIGN KEY (nation_id) REFERENCES public.nation(nation_id);


--
-- Name: player_role player_role_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_role
    ADD CONSTRAINT player_role_club_id_fkey FOREIGN KEY (club_id) REFERENCES public.club(club_id);


--
-- Name: player_role player_role_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_role
    ADD CONSTRAINT player_role_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player_profile(player_id);


--
-- Name: player_statistic player_statistic_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_statistic
    ADD CONSTRAINT player_statistic_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id);


--
-- Name: player_statistic player_statistic_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_statistic
    ADD CONSTRAINT player_statistic_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player_profile(player_id);


--
-- PostgreSQL database dump complete
--


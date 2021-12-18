CREATE TABLE viewers (
	id         serial       PRIMARY KEY,
	login      varchar(30)  NOT NULL UNIQUE CHECK(char_length(login) >= 3),
	password   varchar(256) NOT NULL CHECK(char_length(password) >= 10),,
	name       varchar(40)  NOT NULL CHECK(char_length(name) >= 1),     ,
	surname    varchar(40)  NOT NULL CHECK(char_length(surname) >= 1),  ,
	patronymic varchar(40)  NULL     CHECK(char_length(patronymic) >= 1)
);

CREATE UNIQUE INDEX viewers_logins ON viewers(login);
CREATE INDEX viewers_fullNames     ON viewers(name, surname, patronymic);


CREATE TABLE administrators (
	id         serial PRIMARY KEY,
	login      varchar(30)  NOT NULL UNIQUE CHECK(char_length(login) >= 3),
	password   varchar(256) NOT NULL CHECK(char_length(password) >= 10),
	name       varchar(40)  NOT NULL CHECK(char_length(name) >= 1),
	surname    varchar(40)  NOT NULL CHECK(char_length(surname) >= 1),
	patronymic varchar(40)  NULL     CHECK(char_length(patronymic) >= 1)
);

CREATE UNIQUE INDEX administrators_logins ON administrators (login);


CREATE TABLE paymentSystems (
	id   serial      PRIMARY KEY,
	name varchar(50) NOT NULL UNIQUE CHECK(char_length(name) >= 1)
);


CREATE TABLE paymentInfo (
	id         serial PRIMARY KEY,
	cardNumber bigint NOT NULL CHECK(cardNumber > 999999999999999 AND cardNumber <= 9999999999999999),

	viewerId        serial REFERENCES viewers(id)        ON DELETE CASCADE,
	paymentSystemId serial REFERENCES paymentSystems(id) ON DELETE SET DEFAULT
);


CREATE TABLE cinemaChains (
	id   serial      PRIMARY KEY,
	name varchar(50) NOT NULL UNIQUE CHECK(char_length(name) >= 3)
);


CREATE TABLE cinemas (
	id        serial PRIMARY KEY,
	name      varchar(50) NOT NULL CHECK(char_length(name) >= 1),
	telephone char(11)    NOT NULL CHECK(char_length(telephone) = 11),
	city      varchar(50) NOT NULL CHECK(char_length(city) >= 1),
	street    varchar(50) NOT NULL CHECK(char_length(street) >= 1),
	metro     varchar(50) NULL     CHECK(char_length(metro) >= 1),
	house     int         NOT NULL CHECK(house > 0),
	housing   int         NULL     CHECK(housing > 0),

	chainId serial REFERENCES cinemaChains(id) ON DELETE SET DEFAULT
);


CREATE TABLE favourites (
	viewerId serial REFERENCES viewers(id) ON DELETE CASCADE,
	cinemaId serial REFERENCES cinemas(id) ON DELETE CASCADE,

	PRIMARY KEY (viewerId, cinemaId)
);


CREATE TABLE resposibles (
	administratorId serial REFERENCES administrators(id) ON DELETE CASCADE,
	cinemaId        serial REFERENCES cinemas(id)        ON DELETE CASCADE,

	PRIMARY KEY (administratorId, cinemaId)
);


CREATE TABLE halls (
	id     serial   PRIMARY KEY,
	number smallint NOT NULL CHECK(number > 0),

	cinemaId serial REFERENCES cinemas(id) ON DELETE CASCADE
);


CREATE TABLE spots (
	id     serial PRIMARY KEY,
	row    int    NOT NULL CHECK(row > 0),
	number int    NOT NULL CHECK(number > 0),

	hallId serial REFERENCES halls(id) ON DELETE CASCADE
);

CREATE INDEX spots_places ON spots(row) INCLUDE(number);
CREATE UNIQUE INDEX spots_hall ON spots(row, number, hallId);


CREATE TABLE films (
	id          serial      PRIMARY KEY,
	name        varchar(40) NOT NULL CHECK(char_length(name) >= 1),
	description text        NOT NULL CHECK(char_length(description) >= 1),
	duration    interval    NULL     CHECK(duration > interval '30 minutes'),
	ageLimit    smallint    NULL     CHECK(ageLimit >= 0 AND ageLimit <= 150),
	releaseDate timestamptz NULL
);

CREATE INDEX films_names ON films(name);


CREATE TABLE sessions (
	id   serial      PRIMARY KEY,
	date timestamptz NOT NULL,
	cost int         NOT NULL CHECK(cost > 0),

	filmId serial REFERENCES films(id) ON DELETE SET DEFAULT,
	hallId serial REFERENCES halls(id) ON DELETE SET DEFAULT
);

CREATE UNIQUE INDEX sessions_dates ON sessions(date, hallId);
CREATE INDEX sessions_dates ON sessions(date) INCLUDE (duration);

CREATE FUNCTION check_session_date() RETURNS trigger AS $session_date_check$
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
$session_date_check$ LANGUAGE plpgsql;

CREATE TRIGGER session_date_check BEFORE INSERT OR UPDATE ON sessions
	FOR EACH ROW EXECUTE FUNCTION check_session_date();


CREATE TABLE tickets (
	id             serial PRIMARY KEY,
	transactionURL text   NOT NULL CHECK(char_length(transactionURL) >= 7),

	viewerId  serial REFERENCES viewers(id)  ON DELETE SET DEFAULT,
	sessionId serial REFERENCES sessions(id) ON DELETE SET DEFAULT,
	spotId    serial REFERENCES spots(id)    ON DELETE SET DEFAULT
);

CREATE UNIQUE INDEX users_tickets ON tickets(sessionId, spotId);

CREATE FUNCTION check_spot_availability() RETURNS trigger AS $spot_availability$
DECLARE
	sessions_count boolean;
BEGIN
	IF TG_OP = 'UPDATE' AND OLD.spotid = NEW.spotid AND OLD.sessionId = NEW.sessionId THEN
		RETURN NEW;
	END IF;

	SELECT FROM tickets WHERE tickets.spotid = NEW.spotid AND tickets.sessionid = NEW.sessionid;
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
$spot_availability$ LANGUAGE plpgsql;

CREATE TRIGGER spot_availability BEFORE INSERT OR UPDATE ON tickets
	FOR EACH ROW EXECUTE FUNCTION check_spot_availability();


CREATE TABLE reviews (
	id          serial PRIMARY KEY,
	title       varchar(50) NOT NULL CHECK(char_length(title) >= 3),
	description text        NOT NULL CHECK(char_length(description) >= 5),
	score       SMALLINT    NOT NULL CHECK(score > 0 AND score <= 10),

	viewerId serial REFERENCES viewers(id) ON DELETE SET DEFAULT,
	filmId   serial REFERENCES films(id)   ON DELETE SET DEFAULT
);

CREATE INDEX reviews_scores ON reviews(score);

/* first */
WITH sessions_cinemas AS (SELECT sessions.id AS sessionid, cost, chainid
	FROM sessions, halls, cinemas
    WHERE sessions.hallId = halls.id AND halls.cinemaid = cinemas.id AND 
        DATE AT TIME ZONE 'utc' BETWEEN '2021.12.28 00:00:00' AND '2021.12.28 23:59:59'),
sessions_chains AS (SELECT sessionid, cost, cinemachains.id AS chainid, cinemachains.name AS chainname
	FROM sessions_cinemas
    RIGHT JOIN cinemachains
	ON sessions_cinemas.chainid = cinemachains.id)
SELECT COUNT(tickets.id) ticketscount, SUM(cost) AS costSum, chainname
	FROM sessions_chains, tickets
	WHERE sessions_chains.sessionid = tickets.sessionid
	GROUP BY chainname
	ORDER BY costSum DESC;
/* first */


/* second */
WITH user_session AS (SELECT DISTINCT viewerId, sessionid FROM tickets),
viewer_cinema AS (SELECT viewers.login, cinemas.name, count(user_session.sessionid)
	FROM user_session, sessions, halls, cinemas, favourites, viewers
	WHERE user_session.sessionId = sessions.id AND sessions.hallid = halls.id AND halls.cinemaid = cinemas.id AND user_session.viewerId = favourites.viewerId AND cinemas.id = favourites.cinemaid AND viewers.id = favourites.viewerid
	GROUP BY viewers.login, cinemas.name)
SELECT login, name, count FROM viewer_cinema
	WHERE (login, count) IN (
		SELECT login, max(count) max_count
		FROM viewer_cinema
		GROUP BY login
	)
	ORDER BY count DESC;
/* second */


/* third */
WITH film_avg AS (SELECT filmid, floor(avg(score)) AS mark FROM reviews GROUP BY filmId),
more_than_4 AS (SELECT filmId, name, mark FROM film_avg, films WHERE film_avg.filmid = films.id AND mark >= 5),
film_sessions AS (SELECT name, hallid, mark, date FROM more_than_4, sessions WHERE more_than_4.filmId = sessions.filmId AND sessions.date AT TIME ZONE 'utc' > now())
SELECT film_sessions.name, mark, date, cinemas.name AS cinemaName, number
	FROM film_sessions, halls, cinemas
	WHERE film_sessions.hallid = halls.id AND halls.cinemaid = cinemas.id AND cinemas.city = 'Москва';
	ORDER BY name, date ASC;
/* third */


/* fourth */
WITH film AS (SELECT id FROM films WHERE name = 'Человек-паук: Нет пути домой'),
film_sessions AS (SELECT sessions.id, date, hallid
	FROM sessions, film
	WHERE sessions.filmid = film.id AND date AT TIME ZONE 'utc' > now() AT TIME ZONE 'utc'),
sess_spot_count AS (SELECT count(tickets.id), film_sessions.id, date, film_sessions.hallid
	FROM film_sessions
	LEFT JOIN tickets
	ON tickets.sessionid = film_sessions.id
	GROUP BY film_sessions.id, date, film_sessions.hallid),
spots_count AS (SELECT halls.id AS hallid, count(spots.id), halls.number AS hallnumber, cinemas.name AS cinemaname
	FROM spots, halls, cinemas
	WHERE spots.hallid = halls.id AND halls.cinemaid = cinemas.id
	GROUP BY halls.id, cinemas.name)
SELECT date, hallnumber, cinemaname, spots_count.count - sess_spot_count.count AS left FROM sess_spot_count, spots_count
	WHERE spots_count.count - sess_spot_count.count > 67 AND sess_spot_count.hallid = spots_count.hallid
	ORDER BY spots_count.count;
/* fourth */


/* fifth */
WITH reviewed_films AS (SELECT filmid FROM reviews WHERE viewerid = 80),
unwatch_films AS (SELECT id, name FROM films WHERE id NOT IN (SELECT filmid FROM reviewed_films))
SELECT unwatch_films.name, sessions.date, halls.number, cinemas.name
	FROM unwatch_films, sessions, halls, cinemas
	WHERE unwatch_films.id = sessions.filmid AND sessions.hallid = halls.id AND halls.cinemaid = cinemas.id
	ORDER BY sessions.date, unwatch_films.name;
/* fifth */

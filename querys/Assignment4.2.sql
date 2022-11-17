ALTER TABLE movies
ADD CONSTRAINT premiere_date CHECK (premiere_date > '1895-12-28');

INSERT INTO country
VALUES
(DEFAULT, 'USA', DEFAULT),
(DEFAULT, 'South Korea', 'Korean' );

INSERT INTO movies
VALUES
(DEFAULT, 'Fight Club', '7', '1999-09-10', 'www.kinopoisk.ru/lists/movies/genre--thriller/', '29'),
(DEFAULT, 'Serbuan maut', '8', '2011-09-08', 'www.kinopoisk.ru/lists/movies/genre--action/', '19'),
(DEFAULT, 'Shutter Island', '7', '2010-02-13', 'www.kinopoisk.ru/lists/movies/genre--mystery/', '39');

UPDATE movies
	SET price = price + 30;
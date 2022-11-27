-- 1)все книги 2004 года, сортировка по названию
select * from book where book_rel_date=2004
ORDER BY book_title ASC;
-- 2)все книги на русском
select * from book where book_lang='RU';
-- 3)все isbn книг Хэмингуэя. Т.к оригинальный язык автора английский,
-- то имя автора изначально записано на английском, поэтому ищем по имени оригинала
select book_isbn from book
where book_author_id in
	(select author_id from author
	where author_lname='Hemingway' or
	author_original_id = (select author_id from author
	where author_lname='Hemingway'));
-- 4)все книги Стейнбека на русском. Т.к. в требованиях к одному из заданий требуется записывать 
-- по умолчанию переведенные данные, то в таблице будет русское имя автора, а если у 
-- зарубежного автора имя на русском, то и книги будут на русском.
select * from book
where book_author_id in
	(select author_id from author
	where author_lname='Стейнбек'
	);
-- 5)все категории книги Programming .NET Web Services
select genre_title from genre_annotation
where genre_id in 
	(select genre_id from book_genre
	where book_isbn in (select book_isbn from book
	where book_title='Programming .NET Web Services'));
-- 6)на скольки языках издана каждая книга
select distinct book_title, count(distinct book_lang)as "lang_count"
from book
group by book_title;
-- 7)количество книг для каждого издательства
select author_publisher, count(author_publisher)as "books_count"
from 
	(select author_publisher from book 
	full join author on author_id = book_author_id
	where book_author_id in
		(select author_id from author
		where author_publisher is not NULL))subquer
group by author_publisher;
-- 8)книги на языке оригинала
select * from book where book_original_lang is null;

--insert into book
--values
--(9780140187434,'Cup of Gold',1929,null,'EN',null,13,null);
-- 9)книги по категориям
select book_genre.genre_id, genre_title, count(book_genre.genre_id)as "genres_count"
from book
full join book_genre on book_genre.book_isbn = book.book_isbn
full join genre_annotation on genre_annotation.genre_id = book_genre.genre_id
group by book_genre.genre_id,genre_title;
-- 10)книги вышедшие от издательств по категориям
select book_genre.genre_id, genre_title, count(book_genre.genre_id)as "genres_count"
from book
full join book_genre on book_genre.book_isbn = book.book_isbn
full join genre_annotation on genre_annotation.genre_id = book_genre.genre_id
where book.book_isbn in
	(select book_isbn from book 
	full join author on author_id = book_author_id
	where book_author_id in
			(select author_id from author
			where author_publisher is not NULL))
group by book_genre.genre_id,genre_title;


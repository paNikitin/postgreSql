CREATE OR REPLACE FUNCTION AppendBook
(   
	AuthorLname VARCHAR(50),
	AuthorFname VARCHAR(50),
	AuthorMname VARCHAR(50),
	AuthorLang VARCHAR(50),
	AuthorPublisher VARCHAR(50),
	BookIsbn bigint,
	--CHECK (BookIsbn < 10000000000000),
	BookTitle VARCHAR(50),
	BookRelDate int,
	--CHECK (BookRelDate < 2023),
	BookVolume int,
	BookLang VARCHAR(50),
	BookAnnotation VARCHAR(1000),
	GenreTitle VARCHAR(50)
) 
RETURNS  TABLE (AddedRecordIterator int)
AS   
$$
declare 
AuthorId int;
GenreId int;
BEGIN  
-- если автора нет, добавляем. сохраняем айди автора для дальнейшей работы
	if not exists(select * from author
	where author_lname=AuthorLname) then
		insert into author
		values
			(default,AuthorLang,AuthorLname,null,AuthorFname,AuthorMname,AuthorPublisher);
		AuthorId:=
			(select author_id from author
			where author_lname=AuthorLname);
	else
		AuthorId:=
			(select author_id from author
			where author_lname=AuthorLname);
	end if;
-- если язык автора	не тот же, что и у книги, значит книга переиздается
	if AuthorLang!=BookLang then
		insert into book
		values
			(BookIsbn,BookTitle,BookRelDate,BookVolume,BookLang,AuthorLang,AuthorId,BookAnnotation);
	else
		insert into book
		values
			(BookIsbn,BookTitle,BookRelDate,BookVolume,BookLang,null,AuthorId,BookAnnotation);
	end if;
-- проверяем, есть ли задданный жанр, сохраняем его айди	
	if GenreTitle in (select genre_title from genre_annotation) then
		GenreId:=
			(select genre_id from genre_annotation
			where genre_title=GenreTitle);
	else 
		insert into genre_annotation
		values
			(default,null,GenreTitle);
		GenreId:=
			(select genre_id from genre_annotation
			where genre_title=GenreTitle);
	end if;
-- добавляем отношение айди книги к ее жанру	
	insert into book_genre
	values
		(default,BookIsbn,GenreId);
-- возвращаем айди отношения
	return query select genre_relation from book_genre
	where book_isbn=BookIsbn and genre_id=GenreId;
END ;
$$
LANGUAGE plpgsql;
-- пример вызова
--select * from AppendBook('Hesse','Hermann',null,'DE','Publishd',0000008975480,'Das Glasperlenspiel',1943,null::int,'DE','Das Glasperlenspiel. Versuch einer Lebensbeschreibung des Magister Ludi Josef Knecht samt Knechts hinterlassenen Schriften ist der letzte und zugleich umfangreichste Roman von Hermann Hesse, erstmals 1943 in zwei Bänden veröffentlicht.','Fiction');

create or replace procedure FindLoops()
language plpgsql as  
$$  
declare
len int;
looped int[];
ind int;
ids int[] = array(select genre_id from genre_annotation
			where genre_id in
			(select root_genre_id from genre_annotation) and root_genre_id is not null);
root_ids int[] = array(select root_genre_id from genre_annotation
				where genre_id in
				(select root_genre_id from genre_annotation) and root_genre_id is not null);
begin
	--количество зацикленных записей
	len := (select count(root_genre_id) from genre_annotation
			where genre_id in
			(select root_genre_id from genre_annotation) and root_genre_id is not null);
	for iter1 in 1..len loop
		for iter2 in 1..len loop
			if ids[iter1]=root_ids[iter2] then 
			looped := array[ids[iter1],ids[iter2]];
			ind := (select max(x) from unnest(looped) x);
			update genre_annotation set root_genre_id=null
			where genre_id = ind;
			end if;
   		end loop;
   	end loop;
END;$$;
-- пример вызова
-- call FindLoops();

CREATE OR REPLACE FUNCTION BookCategories
(   
	BookIsbn bigint
) 
RETURNS  TABLE (genre_id int,genre_title VARCHAR(50))
AS   
$$
declare
ids int[] := array(select genre_annotation.genre_id from book_genre
				full join genre_annotation on genre_annotation.genre_id = book_genre.genre_id
				where book_isbn = BookIsbn);
root_ids int[] := array(select genre_annotation.root_genre_id from genre_annotation
				where genre_annotation.genre_id in
					(select genre_annotation.genre_id from book_genre
					full join genre_annotation on genre_annotation.genre_id = book_genre.genre_id
					where book_isbn = BookIsbn) and root_genre_id is not null);
len int;
begin
	create temp table temps1 
	(
	   genre_id int
	);
	--обработка прямых категорий
	len := (select count(genre_annotation.genre_id) from book_genre
			full join genre_annotation on genre_annotation.genre_id = book_genre.genre_id
			where book_isbn = BookIsbn);
	for iter in 1..len loop
		insert into temps1
		values(ids[iter]);
   	end loop;
	--обработка косвенных категорий
	len := (select count(root_genre_id) from genre_annotation
			where genre_annotation.genre_id in
				(select genre_annotation.genre_id from book_genre
				full join genre_annotation on genre_annotation.genre_id = book_genre.genre_id
				where book_isbn = BookIsbn) and root_genre_id is not null);
	for iter in 1..len loop
		insert into temps1
		values(root_ids[iter]);
   	end loop;

	return query 
	select genre_annotation.genre_id,genre_annotation.genre_title from book_genre
					full join genre_annotation on genre_annotation.genre_id = book_genre.genre_id
					where genre_annotation.genre_id in (select temps1.genre_id from temps1)
					and book_isbn = BookIsbn
					order by genre_id asc;
	drop table temps1;
END ;
$$
LANGUAGE plpgsql;

-- пример вызова select * from BookCategories(213123123::bigint);

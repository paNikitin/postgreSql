CREATE OR REPLACE FUNCTION DeleteAudition() RETURNS TRIGGER AS $delete_audit$
	declare
	RootId int;
    BEGIN
        IF (TG_OP = 'DELETE') THEN
			-- проверка на коренную категорию
			-- если ссылок на корневую категорию нет, то категория корневая
			if (select root_genre_id from genre_annotation where genre_id = old.genre_id) is null then--корневая
				if (select genre_id from book_genre where genre_id is null) then
					update genre_annotation
					set root_genre_id = null
					where genre_id = old.genre_id;
				else	
					raise exception 'Ошибка: %', 'На категорию есть ссылки';
				end if;
			else --не корневая
				RootId := (select root_genre_id from genre_annotation where genre_id = old.genre_id);
				update book_genre
				set genre_id = RootId
				where genre_id = old.genre_id;
			end if;
		RETURN old;
        END IF;
    END;
$delete_audit$ LANGUAGE plpgsql;

CREATE or replace TRIGGER delete_audit
BEFORE DELETE ON genre_annotation
    FOR EACH ROW EXECUTE FUNCTION DeleteAudition();
	
CREATE OR REPLACE FUNCTION PublishAudition() RETURNS TRIGGER AS $publish_audit$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
			if (new.book_rel_date is null) then
				new.book_rel_date := (select extract(year from current_date));
			end if;
			if (new.book_annotation is null) then
				new.book_annotation := (select book_annotation from book
				where book_author_id = (select author_id from author 
									where author_id = (select author_original_id from author
									full join book on book.book_author_id = author.author_id
									where author_id = new.book_author_id
									limit 1))
				and
									(book_title = new.book_title));
			end if;
			
			if (new.book_lang is null) then
				new.book_lang := (select author_lang from author where author_id = new.book_author_id);
			end if;
			
			if (new.book_original_lang is null) then
				new.book_original_lang := (select book_lang from book
				where book_author_id = (select author_id from author 
									where author_id = (select author_original_id from author
									full join book on book.book_author_id = author.author_id
									where author_id = new.book_author_id
									limit 1))
				and
									(book_title = new.book_title));
			end if;
		RETURN new;
        END IF;
    END;
$publish_audit$ LANGUAGE plpgsql;

CREATE or replace TRIGGER publish_audit
BEFORE insert ON book
	FOR EACH ROW EXECUTE FUNCTION PublishAudition();
-- пример	
-- insert into book
-- values
-- (9785171364947,'Истребитель',null,null,null,null,20);
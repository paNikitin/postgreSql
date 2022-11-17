create or replace procedure SetGenre 
(    
    MovTitle varchar(50),
	GenTitle varchar(50)
)  
language plpgsql as  
$$  
declare 
id_finder int;
MovId int;
begin
	select max(genres.gen_id) into id_finder from genres ;
	id_finder := id_finder + 1;
 	insert into genres (gen_id, gen_title) values   
    ( 	id_finder,
		GenTitle
    );
	MovId := (select movie.mov_id from movie
	where movie.mov_title = MovTitle);
	insert into movie_genres (mov_id, gen_id) values   
    ( 	MovId,
		id_finder
    );
end  
$$;

create or replace procedure AddReview 
(   MovId int,
	RevId int,
	RevStars numeric
)  
language plpgsql as  
$$  
declare 
rating_finder int;
begin
	rating_finder := (select rating.num_o_ratings from rating
	where rating.mov_id = MovId
	fetch first row only);
	insert into rating (mov_id, rev_id, rev_stars) values   
    ( 	MovId,
		RevId,
	 	RevStars
    );
	rating_finder := rating_finder + 1;
	update rating set
	num_o_ratings = rating_finder
	where rating.mov_id = MovId;
end  
$$;

CREATE OR REPLACE FUNCTION FilmByYear
(   MovYear int,
	MovRelCountry character(5)
) 
RETURNS  TABLE (counter bigint)
AS   
$$  
BEGIN  
	return query (select count(mov_id) from 
				(select * from movie
			where mov_year = MovYear and mov_rel_country = MovRelCountry)subquer);
END;  
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION StarryDirectors
(   
	ThresHold numeric
) 
RETURNS  TABLE (dir_id int, dir_fname character(20), dir_lname character(20),avg_rev_stars numeric)
AS   
$$
BEGIN  
	return query select distinct director.dir_id, director.dir_fname, director.dir_lname, subquery.average
	from director
	full join movie_direction on movie_direction.dir_id = director.dir_id
	full join rating on rating.mov_id = movie_direction.mov_id
	full join (select mov_id, average
		from (SELECT
		  mov_id, avg(rev_stars) AS average
		FROM
		  rating 
		GROUP BY
		  mov_id)subquer
		where (average > ThresHold))as subquery
	on rating.mov_id = subquery.mov_id
	where rating.mov_id in 
		(select mov_id
		from (SELECT
		  mov_id, avg(rev_stars) AS average
		FROM
		  rating 
		GROUP BY
		  mov_id)subquer
		where (average > ThresHold));
END;  
$$
LANGUAGE plpgsql;

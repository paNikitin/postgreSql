select mov_title
from movie
where mov_lang = 'Japanese';

select rev_name
from reviewer
join rating
ON reviewer.rev_id = rating.rev_id
where rating.rev_stars is null
group by 
	reviewer.rev_name;

create view Actresses as
select act_fname, act_lname
from actor
full join movie_cast ON movie_cast.act_id = actor.act_id
full join movie ON movie.mov_id = movie_cast.mov_id
full join rating ON rating.mov_id = movie.mov_id
where actor.act_gender = 'F' and rating.rev_stars > 8
group by 
	actor.act_fname,
	actor.act_lname;

select movie.mov_title, actor.act_fname, actor.act_lname, movie.mov_dt_rel, movie_cast.role, genres.gen_title, director.dir_fname, director.dir_lname, movie.mov_year, rating.rev_stars
from actor
full join movie_cast ON movie_cast.act_id = actor.act_id
full join movie ON movie.mov_id = movie_cast.mov_id
full join rating ON rating.mov_id = movie.mov_id
full join movie_direction ON movie_direction.mov_id = movie.mov_id 
full join director ON director.dir_id = movie_direction.dir_id
full join movie_genres ON movie_genres.mov_id = movie.mov_id
full join genres ON genres.gen_id = movie_genres.gen_id
where actor.act_gender = 'F'
group by 
	movie.mov_title,
	actor.act_fname,
	actor.act_lname,
	movie.mov_dt_rel,
	movie_cast.role,
	genres.gen_title,
	director.dir_fname,
	director.dir_lname,
	movie.mov_year,
	rating.rev_stars;
	
/*insert into movie
values
('171', 'Primal Fear', '1996', '130', 'English', '1995-01-01', 'USA');
insert into movie_genres
values
('171', '1007');*/

create view MostDramas as
select movie.mov_title, movie.mov_year, movie.mov_rel_country
from movie
where movie.mov_year in 
	(select mov_year
	from (select mov_year, count(mov_year)
from 
	(select movie_genres.gen_id, movie_genres.mov_id, movie.mov_title, movie.mov_year, movie.mov_rel_country
	from movie_genres
	full join movie ON movie.mov_id = movie_genres.mov_id
	where gen_id = '1007'
	group by 
		movie_genres.mov_id,
		movie_genres.gen_id,
		movie.mov_title,
		movie.mov_rel_country,
		movie.mov_year) as SortedList
group by
	mov_year
having 
	count (mov_year)=(
	select max(occurence_count)
	from 
		(select mov_year, count(mov_year) occurence_count
		from 
			(select movie_genres.gen_id, movie_genres.mov_id, movie.mov_title, movie.mov_year, movie.mov_rel_country
			from movie_genres
			full join movie ON movie.mov_id = movie_genres.mov_id
			where gen_id = '1007'
			group by 
				movie_genres.mov_id,
				movie_genres.gen_id,
				movie.mov_title,
				movie.mov_rel_country,
				movie.mov_year) as SortedList
			group by mov_year) subquery))subquer)
order by movie.mov_year;
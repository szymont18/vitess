create table if not exists pokemon_seq(id int, next_id bigint, cache bigint, primary key(id)) comment 'vitess_sequence';
insert into pokemon_seq(id, next_id, cache) values(0, 1000, 100);
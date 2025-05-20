create table if not exists pokemon(
  pokemon_id bigint not null auto_increment,
  name varchar(128),
  type varchar(64),
  level int,
  primary key(pokemon_id)
) ENGINE=InnoDB;

create table if not exists trainer(
  trainer_id bigint not null auto_increment,
  name varchar(128),
  region varchar(128),
  primary key(trainer_id)
) ENGINE=InnoDB;

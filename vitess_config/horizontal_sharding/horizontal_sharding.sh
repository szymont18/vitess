vtctldclient ApplySchema --sql="$(cat vitess_config/sqls/pokemon_seq.sql)" trainers
vtctldclient ApplyVSchema --vschema="$(cat vitess_config/sqls/horizontal_vschema.json)" trainers
vtctldclient ApplySchema --sql="$(cat pokemon_sharded.sql)" pokemondB
vtctldclient ApplyVSchema --vschema="$(cat pokemon_sharded.json)" pokemondB
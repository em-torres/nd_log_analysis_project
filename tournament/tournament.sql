-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- Creating table Players
CREATE TABLE players (
    id        serial PRIMARY KEY,
    name      text,
);

-- Creating table Matches
CREATE TABLE matches (
    id      serial PRIMARY KEY,
    winner  integer REFERENCES players(id),
    loser   integer REFERENCES players(id),
);

-- Creating View for Player Standings
CREATE OR REPLACE VIEW player_standings AS
  SELECT
    players.id,
    players.name,
    COUNT(matches.winner) AS wins,
    COALESCE(
      (SELECT COUNT(*) FROM matches WHERE winner=players.id OR loser=players.id GROUP BY players.id), 0
    ) as matches
  FROM
    (players LEFT JOIN matches ON winner = players.id)
  GROUP BY
    players.id
  ORDER BY
    wins DESC;

-- Creating View for Even Player Standings
CREATE OR REPLACE VIEW even_player_standings AS
  SELECT id, name, rn
  FROM
    (SELECT id, name, wins, ROW_NUMBER() OVER() rn FROM player_standings) as even
  WHERE MOD(rn, 2) = 0;

-- Creating View for Uneven Player Standings
CREATE OR REPLACE VIEW uneven_player_standings AS
  SELECT id, name, rn
  FROM
    (SELECT id, name, wins, ROW_NUMBER() OVER() rn FROM player_standings) as uneven
  WHERE MOD(rn, 2) <> 0;

-- Creating View for Players Pairs Standings
CREATE OR REPLACE VIEW pl_pairs AS
  SELECT
    uneven.id AS id1,
    uneven.name AS name1,
    even.id AS id2,
    even.name AS name2
  FROM
    even_player_standings AS even JOIN uneven_player_standings AS uneven
  ON uneven.rn = (even.rn-1);

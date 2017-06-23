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
    players.id;

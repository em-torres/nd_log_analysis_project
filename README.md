# Tournament Project (Log Analysis)
Full Stack Web Developer Nano Degree Log Analysis Project

## Installation:
1. Clone Repository
2. Install [Vagrant](https://www.vagrantup.com/)
3. Enter Bash or CMD in the folder and run `vagrant up` command
4. Wait for process to finish
5. After finished, Run `vagrant ssh` command to enter the Virtual Machine
6. In the Bash Console input `cd /vagrant/tournament`
7. Run the `python tournament_test.py` command
8. If everything goes well a Script will run with the approval of the tests

## Notes:
This project use [Python](https://www.python.org/), [Vagrant](https://www.vagrantup.com/) and
[PostgreSQL](https://www.postgresql.org/) as its core.

Also, we implement the use of **[VIEWS](https://www.w3schools.com/sql/sql_view.asp)**. We've added the main queries and
Initial project database Structure in the
[tournament.sql](https://github.com/em-torres/nd_log_analysis_project/blob/master/tournament/tournament.sql).
If for any cause the project doesn't run, feel free to contact us at **kdgpro15@gmail.com**.

Also, we will leave the main Queries and Views used in the project for user convenience.

## Queries and Views:
### Table definitions for the tournament project.
* Creating table Players
```mysql
CREATE TABLE players (
    id        serial PRIMARY KEY,
    name      text
);
```

* Creating table Matches
```mysql
CREATE TABLE matches (
    id      serial PRIMARY KEY,
    winner  integer REFERENCES players(id),
    loser   integer REFERENCES players(id)
);
```

* Creating Player Standings View
```mysql
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
```

* Creating Even Player Standings View
```mysql
CREATE OR REPLACE VIEW even_player_standings AS
  SELECT id, name, rn
  FROM
    (SELECT id, name, wins, ROW_NUMBER() OVER() rn FROM player_standings) as even
  WHERE MOD(rn, 2) = 0;
```

* Creating View for Uneven Player Standings
```mysql
CREATE OR REPLACE VIEW uneven_player_standings AS
  SELECT id, name, rn
  FROM
    (SELECT id, name, wins, ROW_NUMBER() OVER() rn FROM player_standings) as uneven
  WHERE MOD(rn, 2) <> 0;
```

* Creating View for Players Pairs Standings
```mysql
CREATE OR REPLACE VIEW pl_pairs AS
  SELECT
    uneven.id AS id1,
    uneven.name AS name1,
    even.id AS id2,
    even.name AS name2
  FROM
    even_player_standings AS even JOIN uneven_player_standings AS uneven
  ON uneven.rn = (even.rn-1);
```

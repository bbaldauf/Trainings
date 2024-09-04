#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate teams, games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  if [[ $YEAR != 'year' ]]
  then
    # get team_id
    WINNER_TEAM_ID=$($PSQL "Select team_id from teams where name = '$WINNER'")

    # if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
    # insert team
    INSERT_WINNER_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_TEAM_RESULT == 'INSERT 0 1' ]]
      then
      echo Inserted into teams, $WINNER
      fi
    # get new team_id
    WINNER_TEAM_ID=$($PSQL "Select team_id from teams where name = '$WINNER'")
    fi
    # get opponent team_id
    OPPONENT_TEAM_ID=$($PSQL "Select team_id from teams where name = '$OPPONENT'")
    # if not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
    # insert team
    INSERT_OPPONENT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
      echo Inserted into teams, $OPPONENT
      fi
    # get new opponent team_id
    OPPONENT_TEAM_ID=$($PSQL "Select team_id from teams where name = '$OPPONENT'")
    fi   



  # insert game
INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games
(year, round, winner_goals, opponent_goals, winner_id, opponent_id) 
VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID)")
      if [[ $INSERT_GAMES_RESULT == 'INSERT 0 1' ]]
      then
      echo Inserted into games, $YEAR - $ROUND: WINNER: $WINNER_TEAM_ID OPPONENT: $OPPONENT_TEAM_ID
      fi


  fi
done
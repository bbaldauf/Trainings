#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

MAIN_MENU(){
N=$(( RANDOM % 1001 ))
NUM_OF_GAMES=0

echo -e "\nEnter your username:"
read USERNAME_INPUT
USER=$($PSQL "SELECT * FROM users where username='$USERNAME_INPUT'")
if [[ -z $USER ]]
then
USER_INSERT=$($PSQL "insert into users(username, games_played, best_game) values ('$USERNAME_INPUT',0,1000)")
echo Welcome, $USERNAME_INPUT! It looks like this is your first time here.
else
echo "$USER" | while read USER_ID BAR USER_NAME BAR GAMES_PLAYED BAR BEST_GAME
do
echo Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
done
fi
echo "Guess the secret number between 1 and 1000:"
CORRECT="false"
NUM_OF_GAMES=$((GAMES_PLAYED+1))
NUM_OF_GUESSES=0
until [[ $CORRECT == "true" ]]
do
  read GUESS
 NUM_OF_GUESSES=$((NUM_OF_GUESSES+1))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"

  else
   if [[ $GUESS == $N ]]
   then
    echo You guessed it in $NUM_OF_GUESSES tries. The secret number was $N. Nice job!
    CORRECT="true"
    elif [[ $GUESS > $N ]]
    then
    echo "It's lower than that, guess again:"
    else
    echo "It's higher than that, guess again:"
   fi
  fi
done
GAMES_UPDATE=$($PSQL "update users set games_played = $NUM_OF_GAMES where username = '$USERNAME_INPUT'")
BEST_UPDATE=$($PSQL "update users set best_game = $NUM_OF_GUESSES where username = '$USERNAME_INPUT'")
}

MAIN_MENU


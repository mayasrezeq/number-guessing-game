#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

# توليد رقم عشوائي بين 1 و 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# طلب اسم المستخدم
echo "Enter your username:"
read USERNAME

# البحث عن المستخدم
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  # مستخدم جديد
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # مستخدم موجود
  echo "$USER_INFO" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
fi

# بدء اللعبة
echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  ((TRIES++))
done

echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

# تحديث إحصائيات المستخدم
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
UPDATE_GAMES=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'")

BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ -z $BEST || $TRIES -lt $BEST ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$TRIES WHERE username='$USERNAME'")
fi

#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ ! $1 ]]
then
echo Please provide an element as an argument.

else
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
      ELEMENT_RETURN=$($PSQL "select atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements inner join properties using (atomic_number) inner join types using (type_id) where name ='$1' or symbol ='$1'")
  else
      ELEMENT_RETURN=$($PSQL "select atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements inner join properties using (atomic_number) inner join types using (type_id) where atomic_number ='$1'")
      fi
  if [[ -z $ELEMENT_RETURN ]]
  then  
  echo I could not find that element in the database.
  else
    echo "$ELEMENT_RETURN" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR ATOMIC_MASS BAR MELTING_POINT_CELSIUS BAR BOILING_POINT_CELSIUS BAR TYPE
  do
  echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  done
  fi
fi
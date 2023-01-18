#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
#If argument is not empty
if [[ ! -z $1 ]]
then
  #Check for atomic number
  #This check for number format is to prevent PSQL error messages
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1;")
  fi
  if [[ ! -z $NUMBER ]]
  then
    #Get element name and symbol
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $1;")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $1;")
  #if it's not a number
  else
    #check for symbol
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1';")
    #if it is a symbol
    if [[ ! -z $SYMBOL ]]
    then
      #get element number and name
      NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1';")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$1';")
    
    #if it's not a symbol
    else
      #check for name
      NAME=$($PSQL "SELECT name FROM elements WHERE name = '$1';")
      #if it is a name
      if [[ ! -z $NAME ]]
      then
        #get element number and symbol
        NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1';")
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$1';")
      fi
    fi
  fi

  #check that the element has been found
  if [[ -z $NUMBER || -z $NAME || -z $SYMBOL ]]
  then
    echo "I could not find that element in the database."
  else
    #get properties info
    TYPE=$($PSQL "SELECT type FROM properties FULL JOIN types USING (type_id) WHERE atomic_number = $NUMBER;")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = '$NUMBER';")
    MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = '$NUMBER';")
    BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = '$NUMBER';")

    #get full info
    INFO="The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."

    #output well formatted info
    echo $INFO |sed "s/ +/\s/g; s/( /(/" 
  fi

  

else
  echo "Please provide an element as an argument."
fi
#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon ~~~~~\n"
MAIN_MENU(){
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
  echo How may I help you? 
  
  SERVICES=$($PSQL "SELECT service_id, name from services order by service_id")


echo "$SERVICES" | while read SERVICE_ID BAR NAME 
do
echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
if [[ $SERVICE_ID_SELECTED > 4 ]]
then
MAIN_MENU "Please enter a valid option."
else
MAKE_APPOINTMENT $SERVICE_ID_SELECTED
fi

}
MAKE_APPOINTMENT(){
  if [[ $1 ]]
  then
  SERVICE_ID_SELECTED=$1
  fi
SERVICE_NAME=$($PSQL "SELECT name from services where service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "Select name from customers where phone = '$CUSTOMER_PHONE' ")
# if customer doesn't exist
if [[ -z $CUSTOMER_NAME ]]
then
# get new customer name
echo -e "\nWhat's your name?"
read CUSTOMER_NAME

# insert new customer
INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
fi
# get customer_id
CUSTOMER_ID=$($PSQL "select customer_id from customers where phone ='$CUSTOMER_PHONE'")

echo -e "\nWhat time for your appointment?"
read SERVICE_TIME

INSERT_RENTAL_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
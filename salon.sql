#!/bin/bash
#Salon apointments

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Services ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #Display services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo -e "\nHow may I help you?\n" 
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME SERVICE_PRICE
  do
    echo -e "$(echo $SERVICE_ID | sed -r 's/^ *| *$//g')) $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')"
  done
  echo -e ""
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ $SERVICE_ID_SELECTED > 3 ]] #not easily scalable, only works for simple examples with no missing values.
  then
    MAIN_MENU "Please enter a valid option."
  else 
    echo "enter phone number"
    echo -e "\nPlease enter your phone number.\n"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if new customer
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nPlease enter your name.\n"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    else
      echo -e "\nWelcome back, $CUSTOMER_NAME"
    fi
    echo -e "\nPlease enter the desired time.\n"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi
}

MAIN_MENU

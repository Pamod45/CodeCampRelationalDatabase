#!/bin/bash

# Set the PSQL variable to use the appropriate database
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display services
display_services() {
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to get customer ID by phone number
get_customer_id_by_phone() {
  local PHONE=$1
  echo "$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE'")"
}

# Function to add a new customer
add_customer() {
  local PHONE=$1
  local NAME=$2
  echo "$($PSQL "INSERT INTO customers (phone, name) VALUES ('$PHONE', '$NAME')")"
}

# Function to add a new appointment
add_appointment() {
  local CUSTOMER_ID=$1
  local SERVICE_ID=$2
  local TIME=$3
  echo "$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$TIME')")"
}

# Main program
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# Display services
display_services

# Read user input for service ID
read SERVICE_ID_SELECTED

# Validate service ID
SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
while [[ -z $SERVICE_NAME ]]; do
  echo -e "\nI could not find that service. What would you like today?"
  display_services
  read SERVICE_ID_SELECTED
  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
done

# Read user input for phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Get customer ID by phone
CUSTOMER_ID=$(get_customer_id_by_phone $CUSTOMER_PHONE)

# If customer does not exist, add new customer
if [[ -z $CUSTOMER_ID ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  add_customer $CUSTOMER_PHONE $CUSTOMER_NAME
  CUSTOMER_ID=$(get_customer_id_by_phone $CUSTOMER_PHONE)
else
  CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")"
fi

# Read user input for appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Add the appointment
add_appointment $CUSTOMER_ID $SERVICE_ID_SELECTED $SERVICE_TIME

# Confirm the appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

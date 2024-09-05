#!/bin/bash

# Print a message indicating the start of command checks
echo "Check required commands: "

# Function: Check if a command is installed
installed() {
  COMMAND="$1"
  if ! command -v "$COMMAND" &> /dev/null ; then
    return 1
  fi
}

# Initialize a variable to store commands that are not installed
NOT_INSTALLED_COMMANDS_RAW=""

# Loop through a list of required commands
for COMMAND in gcloud aws terraform jq ; do
  if installed "$COMMAND" ; then
    echo -e "- \033[1;32m$COMMAND\033[0m is installed."
  else
    echo -e "- \033[1;31m$COMMAND\033[0m is not installed."
    NOT_INSTALLED_COMMANDS_RAW+="\033[1;31m$COMMAND\033[0m, "
  fi
done

# Remove the trailing comma and space from the list of missing commands
NOT_INSTALLED_COMMANDS=$(echo "$NOT_INSTALLED_COMMANDS_RAW" | sed 's/, $//')

# If there are any missing commands, print an error message and exit with an error code
if [ -n "$NOT_INSTALLED_COMMANDS" ] ; then
  echo -e "\033[1;31mERROR:\033[0m The following commands are not installed: $NOT_INSTALLED_COMMANDS"
  exit 1
else
  echo ""
fi

ACCESS_TOKEN=$(gcloud auth application-default print-access-token 2> /dev/null)
ORIGINAL_ACCOUNT_EMAIL=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://www.googleapis.com/oauth2/v3/userinfo | jq -r '.email')
if [ "$ORIGINAL_ACCOUNT_EMAIL" == null ] ; then
  gcloud auth application-default login
  ACCESS_TOKEN=$(gcloud auth application-default print-access-token 2> /dev/null)
  ACCOUNT_EMAIL=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://www.googleapis.com/oauth2/v3/userinfo | jq -r '.email')
else
  echo -e "The pre-configured account of gcloud: \033[1;31m$ORIGINAL_ACCOUNT_EMAIL\033[0m"
  read -p "Is this correct? (y/n): " CONFIRMATION_RAW
  CONFIRMATION=$(echo "$CONFIRMATION_RAW" | tr '[:upper:]' '[:lower:]')
  if [ "$CONFIRMATION" == "y" ] || [ "$CONFIRMATION" == "yes" ] ; then
    ACCOUNT_EMAIL="$ORIGINAL_ACCOUNT_EMAIL"
  else
    while true ; do
      read -p "Enter the account: " ACCOUNT_EMAIL
      read -p "Is this correct? (y/n): " CONFIRMATION_RAW
      if [ "$CONFIRMATION" == "y" ] || [ "$CONFIRMATION" == "yes" ] ; then
        break
      fi
    done
  fi
fi

ORGANIZATIONS_JSON=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://cloudresourcemanager.googleapis.com/v1beta1/organizations)
COUNT_ORGANIZATION_NAMES=$(echo "$ORGANIZATIONS_JSON" | jq -r '[.organizations[] | select(.displayName != null)] | length')
if [ "$COUNT_ORGANIZATION_IDS" -eq 1 ] ; then
  ORGANIZATION_ID=$(echo "$ORGANIZATIONS_JSON" | jq -r '.organizations[] | .displayName')


COUNT_ORGANIZATION_IDS=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://cloudresourcemanager.googleapis.com/v1beta1/organizations | jq '[.organizations[] | select(.displayName != null)] | length')
if [ "$COUNT_ORGANIZATION_IDS" -eq 1 ] ; then



echo -e "\nDomain: 




while true ; do
  read -p "Enter the domain: " ORGANIZATION_NAME
  read -p "Enter the account ID: " ACCOUNT_ID
  echo -e "\nThe information entered is as follows:"
  echo -e "- Domain: \033[1;33m$ORGANIZATION_NAME\033[0m"
  echo -e "- Account ID: \033[1;33m$ACCOUNT_ID\033[0m (email: \033[1;33m$ACCOUNT_ID@$ORGANIZATION_NAME\033[0m)"
  read -p "Is this information correct? (y/n): " CONFIRMATION_RAW
  CONFIRMATION=$(echo "$CONFIRMATION_RAW" | tr '[:upper:]' '[:lower:]')
  if [ "$CONFIRMATION" == "y" ] || [ "$CONFIRMATION" == "yes" ] ; then
    ACCOUNT_EMAIL="$ACCOUNT_ID@$ORGANIZATION_NAME"
    break
  fi
done

ACCESS_TOKEN=$(gcloud auth application-default print-access-token 2> /dev/null)
ORIGINAL_ACCOUNT_EMAIL=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://www.googleapis.com/oauth2/v3/userinfo | jq -r '.email')
if [ "$ORIGINAL_ACCOUNT_EMAIL" != "$ACCOUNT_EMAIL" ] ; then
  gcloud auth application-default login
fi

ORGANIZATION_ID=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://cloudresourcemanager.googleapis.com/v1beta1/organizations | jq -r ".organizations[] | select(.displayName == \"$ORGANIZATION_NAME\") | .organizationId")



curl -H "Authorization: Bearer $ACCESS_TOKEN" https://cloudresourcemanager.googleapis.com/v1beta1/organizations


# GCLOUD_CONFIG_DIR=$(gcloud info --format json | jq -r '.config.paths.global_config_dir')
# GCLOUD_ADC_JSON="$GCLOUD_CONFIG_DIR/application_default_credentials.json"
# rm -f "$GCLOUD_ADC_JSON"








# read -p "Enter the teIAM user name: " IAM_USER_NAME
# read -sp "Enter the access key: " ACCESS_KEY
# echo
# read -sp "Enter the access secret: " ACCESS_SECRET
# echo


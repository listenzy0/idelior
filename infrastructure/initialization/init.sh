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
    echo -e "- '\033[1;32m$COMMAND\033[0m' is installed."
  else
    echo -e "- '\033[1;31m$COMMAND\033[0m' is not installed."
    NOT_INSTALLED_COMMANDS_RAW+="\033[1;31m$COMMAND\033[0m, "
  fi
done

# Remove the trailing comma and space from the list of missing commands
NOT_INSTALLED_COMMANDS=$(echo "$NOT_INSTALLED_COMMANDS_RAW" | sed 's/, $//')

# If there are any missing commands, print an error message and exit with an error code
if [ -n "$NOT_INSTALLED_COMMANDS" ] ; then
  echo -e "\n\033[1;31mERROR:\033[0m The following commands are not installed: $NOT_INSTALLED_COMMANDS"
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
  echo -e "The pre-configured account: \033[1;33m$ORIGINAL_ACCOUNT_EMAIL\033[0m"
  read -p "- Is this correct? (y/n): " CONFIRMATION_RAW
  CONFIRMATION=$(echo "$CONFIRMATION_RAW" | tr '[:upper:]' '[:lower:]')
  if [ "$CONFIRMATION" == "y" ] || [ "$CONFIRMATION" == "yes" ] ; then
    ACCOUNT_EMAIL="$ORIGINAL_ACCOUNT_EMAIL"
  else
    while true ; do
      gcloud auth application-default login
      ACCESS_TOKEN=$(gcloud auth application-default print-access-token 2> /dev/null)
      ACCOUNT_EMAIL=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://www.googleapis.com/oauth2/v3/userinfo | jq -r '.email')
      echo -e "The configured account: \033[1;33m$ACCOUNT_EMAIL\033[0m"
      read -p "- Is this correct? (y/n): " CONFIRMATION_RAW
      CONFIRMATION=$(echo "$CONFIRMATION_RAW" | tr '[:upper:]' '[:lower:]')
      if [ "$CONFIRMATION" == "y" ] || [ "$CONFIRMATION" == "yes" ] ; then
        break
      fi
    done
  fi
fi
echo -e "\nAccount: \033[1;32m$ACCOUNT_EMAIL\033[0m"

ORGANIZATIONS=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" https://cloudresourcemanager.googleapis.com/v1beta1/organizations)
COUNT_ORGANIZATION_NAMES=$(echo "$ORGANIZATIONS" | jq -r '[.organizations[] | select(.displayName != null)] | length')
if [ -z "$COUNT_ORGANIZATION_NAMES" ] ; then
  echo -e "\n\033[1;31mERROR:\033[0m Unable to retrieve organization information."
  exit 1
elif [ "$COUNT_ORGANIZATION_NAMES" -eq 1 ] ; then
  ORGANIZATION_NAME=$(echo "$ORGANIZATIONS" | jq -r '.organizations[] | .displayName')
  echo -e "\nOrganization: \033[1;33m$ORGANIZATION_NAME\033[0m"
  read -p "- Is this correct? (y/n): " CONFIRMATION_RAW
  CONFIRMATION=$(echo "$CONFIRMATION_RAW" | tr '[:upper:]' '[:lower:]')
  if [ "$CONFIRMATION" != "y" ] && [ "$CONFIRMATION" != "yes" ] ; then
    echo -e "\n\033[1;31mERROR:\033[0m The '$ORGANIZATION_NAME' organization is not the correct target organization."
    exit 1
  fi
else
  echo -e "\nThe following organizations were found:"
  echo "$ORGANIZATIONS" | jq -r '.organizations[] | .displayName' | awk '{printf "- \033[1;33m%d\033[0m. %s\n", NR, $0}'
  while true ; do
    echo ""
    read -p "Please select the organization by number: " SELECT
    if [[ "$SELECT" =~ ^[0-9]+$ ]] && [ "$SELECT" -ge 1 ] && [ "$SELECT" -le "$COUNT_ORGANIZATION_NAMES" ] ; then
      ORGANIZATION_NAME=$(echo "$ORGANIZATIONS" | jq -r ".organizations[$((SELECT - 1))] | .displayName")
      echo -e "\nOrganization: \033[1;33m$ORGANIZATION_NAME\033[0m"
      read -p "- Is this correct? (y/n): " CONFIRMATION_RAW
      CONFIRMATION=$(echo "$CONFIRMATION_RAW" | tr '[:upper:]' '[:lower:]')
      if [ "$CONFIRMATION" != "y" ] && [ "$CONFIRMATION" != "yes" ]; then
        echo ""
        echo "$ORGANIZATIONS" | jq -r '.organizations[] | .displayName' | awk '{printf "\033[1;33m%d\033[0m. %s\n", NR, $0}'
      else
        break
      fi
    else
      echo -e "\n\033[1;33mWARNING:\033[0m Invalid selection.\n"
      echo "$ORGANIZATIONS" | jq -r '.organizations[] | .displayName' | awk '{printf "\033[1;33m%d\033[0m. %s\n", NR, $0}'
    fi
  done
fi
ORGANIZATION_ID=$(echo "$ORGANIZATIONS" | jq -r ".organizations[] | select(.displayName == \"$ORGANIZATION_NAME\") | .organizationId")
CUSTOMER_ID=$(echo "$ORGANIZATIONS" | jq -r ".organizations[] | select(.displayName == \"$ORGANIZATION_NAME\") | .owner.directoryCustomerId")
echo -e "\nOrganization: \033[1;32m$ORGANIZATION_NAME\033[0m"



while 
SESSION_TOKEN=$(aws sts get-session-token 2> /dev/null)
ORIGINAL_ACCOUNT_ID=$(aws sts get-caller-identity 2> /dev/null | jq -r '.Account')
if [ -z "$ORIGINAL_ACCOUNT_ID" ] ; then
  while true ; do
    read -p "Enter the access key ID: " ACCESS_KEY_ID
    read -sp "Enter the secret access key: " SECRET_ACCESS_KEY
    read -p "- Is this correct? (y/n): " CONFIRMATION_RAW
    CONFIRMATION=$(echo "$CONFIRMATION_RAW" | tr '[:upper:]' '[:lower:]')CONFIRMATION" == "y" ] || [ "$CONFIRMATION" == "yes" ] ; then
      aws configure set aws_access_key_id "$ACCESS_KEY_ID"
      export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
      aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY"
      export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"
      SESSION_TOKEN=$(aws sts get-session-token 2> /dev/null)
      ORIGINAL_ACCOUNT_ID=$(aws sts get-caller-identity 2> /dev/null | jq -r '.Account')

      break
    fi
  done



  while true ; do
    read -p "Enter the access key ID: " ACCESS_KEY_ID
    
  
  read -p "Enter the temporary AWS IAM user's access key ID:


  aws configure set aws_access_key_id  
















echo -e "\nCheck required pre-configurations: "
ORGANIZATION_IAM_POLICY=$(curl -X POST -s -H "Authorization: Bearer $ACCESS_TOKEN" "https://cloudresourcemanager.googleapis.com/v1/organizations/$ORGANIZATION_ID:getIamPolicy")
ORGANIZATION_IAM_ASSIGNED_ROLES=$(echo "$ORGANIZATION_IAM_POLICY" | jq -r ".bindings[] | select(.members[] | contains(\"user:$ACCOUNT_EMAIL\")) | .role")
if ! echo "$ORGANIZATION_IAM_ASSIGNED_ROLES" | grep -q "roles/resourcemanager.organizationAdmin" ; then
  echo -e "\n\033[1;31mERROR:\033[0m The '$ACCOUNT_EMAIL' account has not been granted the 'Organization Administrator' role in the '$ORGANIZATION_NAME' organization."
  exit 1
else
  echo -e "- '\033[1;32mGoogle Cloud IAM\033[0m' has been set."
  if ! echo "$ORGANIZATION_IAM_ASSIGNED_ROLES" | grep -q "roles/orgpolicy.policyAdmin" ; then
    ORGANIZATION_ORIGINAL_IAM_BINDINGS=$(echo "$ORGANIZATION_IAM_POLICY" | jq -r '.bindings')
  else
    ORGANIZATION_ORIGINAL_IAM_BINDINGS=''
  fi
fi

SESSION_TOKEN=$(aws sts get-session-token)



# ORGANIZATION_IAM_BINDINGS=$(echo "$ORGANIZATION_ORIGINAL_IAM_BINDINGS" | jq --arg member "user:$ACCOUNT_EMAIL" --arg role "roles/orgpolicy.policyAdmin" '
#       if any(.[]; .role == $role) then
#         map(if .role == $role then .members += [$member] else . end)
#       else
#         . += [{"role": $role, "members": [$member]}]
#       end
#     ')
#     ORGANIZATION_BINDING_DATA="{\"policy\": {\"bindings\": $ORGANIZATION_IAM_BINDINGS}}"
#     curl -X POST -s -H "Authorization: Bearer $ACCESS_TOKEN" -H 'Content-Type: application/json' "https://cloudresourcemanager.googleapis.com/v1/organizations/$ORGANIZATION_ID:setIamPolicy" --data "$ORGANIZATION_BINDING_DATA" &> /dev/null




# if [ -n "$ORGANIZATION_ORIGINAL_IAM_BINDINGS" ] ; then
#   ORGANIZATION_ORIGINAL_BINDING_DATA="{\"policy\": {\"bindings\": $ORGANIZATION_ORIGINAL_IAM_BINDINGS}}"
#   curl -X POST -s -H "Authorization: Bearer $ACCESS_TOKEN" -H 'Content-Type: application/json' "https://cloudresourcemanager.googleapis.com/v1/organizations/$ORGANIZATION_ID:setIamPolicy" --data "$ORGANIZATION_ORIGINAL_BINDING_DATA" &> /dev/null
# fi

if [ "$ORIGINAL_ACCOUNT_EMAIL" != "$ACCOUNT_EMAIL" ] ; then
  GCLOUD_CONFIG_DIR=$(gcloud info --format json | jq -r '.config.paths.global_config_dir')
  GCLOUD_ADC_JSON="$GCLOUD_CONFIG_DIR/application_default_credentials.json"
  rm -f "$GCLOUD_ADC_JSON"
fi







# read -p "Enter the teIAM user name: " IAM_USER_NAME
# read -sp "Enter the access key: " ACCESS_KEY
# echo
# read -sp "Enter the access secret: " ACCESS_SECRET
# echo


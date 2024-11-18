#!/usr/bin/env bash

# Shell Name
SHELL_NAME=$(basename $SHELL)

# Shell RC
if [ "$SHELL_NAME" = "bash" ]; then
  SHELL_RC="$HOME/.bashrc"
elif [ "$SHELL_NAME" = "zsh" ]; then
  SHELL_RC="$HOME/.zshrc"
else
  echo "Unsupported Shell: $SHELL_NAME"
  exit 1
fi

# Identifier
IDENTIFIER_START="### Quoridouble-BE Environment Variables ###"
IDENTIFIER_END="### End Quoridouble-BE Environment Variables ###"

# Functions
setup_environment() {
  # Remove Old Environment Variables
  sed -i.bak "/$IDENTIFIER_START/,/$IDENTIFIER_END/d" $SHELL_RC

  # Add Identifier Start
  echo -e "\n$IDENTIFIER_START" >> $SHELL_RC

  # Project Directory path
  PROJECT_DIR=$(dirname "$0")

  # Environment files
  ENV_FILES=(
      "$PROJECT_DIR/.envs/.env"
      "$PROJECT_DIR/.envs/.env."*
  )

  # Add Environment Variables
  for ENV_FILE in "${ENV_FILES[@]}"; do
    if [[ -f $ENV_FILE ]]; then
      FILE_NAME=$(basename $ENV_FILE)
      echo -e "\n# $FILE_NAME" >> $SHELL_RC
      while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ ! "$line" =~ ^#.*$ ]] && [[ -n "$line" ]]; then
          key=$(echo $line | cut -d'=' -f1 | tr -d ' ')
          value=$(echo $line | cut -d'=' -f2- | tr -d ' ')
          echo "export $key=\"$value\"" >> $SHELL_RC
        fi
      done < $ENV_FILE
    fi
  done

  # Add Identifier End
  echo -e "\n$IDENTIFIER_END" >> $SHELL_RC

  # Source Shell RC
  if [ "$SHELL_NAME" = "bash" ]; then
    source $SHELL_RC
  elif [ "$SHELL_NAME" = "zsh" ]; then
    zsh -c "source $SHELL_RC"
  fi

  echo "Setup Environment variables successfully."
}

remove_environment() {
  # Remove Old Environment Variables
  sed -i.bak "/$IDENTIFIER_START/,/$IDENTIFIER_END/d" $SHELL_RC

  # Source Shell RC
  if [ "$SHELL_NAME" = "bash" ]; then
    source $SHELL_RC
  elif [ "$SHELL_NAME" = "zsh" ]; then
    zsh -c "source $SHELL_RC"
  fi

  echo "Remove Environment variables successfully."
}

# Main menu
while true; do
  echo "============================================="
  echo "     Quoridouble-BE Environment Manager      "
  echo "============================================="
  echo "[1] Setup Environment"
  echo "[2] Remove Environment"
  echo "[3] Exit"
  echo "============================================="
    
  read -p "Select an option (1-3): " choice
  
  case $choice in
    1)
      setup_environment
      ;;
    2)
      read -p "Are you sure you want to remove the environment variables? (y/n): " confirm
      if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
          remove_environment
      else
          echo "Operation cancelled."
      fi
      ;;
    3)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option. Please select 1-3."
      ;;
  esac
  
  echo
  read -p "Press Enter to continue..."
  clear
done
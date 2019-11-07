#!/bin/sh

set -e

export HOME="/github/workspace"
export NVM_DIR="/github/workspace/nvm"
export WRANGLER_HOME="/github/workspace"

# h/t https://github.com/elgohr/Publish-Docker-Github-Action
sanitize() {
  if [ -z "${1}" ]
  then
    >&2 echo "Unable to find ${2}. Did you add a GitHub secret called key ${2}, and pass in secrets.${2} in your workflow?"
    exit 1
  fi
}

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

mkdir -p "$HOME/.wrangler"
chmod -R 770 "$HOME/.wrangler"

sanitize "${INPUT_EMAIL}" "email"
sanitize "${INPUT_APIKEY}" "apiKey"

export CF_EMAIL="$INPUT_EMAIL"
export CF_API_KEY="$INPUT_APIKEY"

npm i @cloudflare/wrangler -g

if ! [ -z "$INPUT_WORKINGDIRECTORY" ]
then
  cd $INPUT_WORKINGDIRECTORY
fi

if [ -z "$INPUT_ENVIRONMENT" ]
then
  wrangler publish
else
  wrangler publish -e "$INPUT_ENVIRONMENT"
fi

if ! [ -z "$INPUT_WORKINGDIRECTORY" ]
then
  cd $HOME
fi

# cody

## Usage

```
git clone https://github.com/zaru/google-apps-group-manager-slackbot.git
cd google-apps-group-manager-slackbot
HUBOT_SLACK_TOKEN=... ./bin/hubot -a slack
```

### set env

```
export APIKEY=...
export ACCESS_TOKEN=...
```

### Get Google OAuth2 AccessToken

```
CLIENT_ID=...
CLIENT_SECRET=...
REDIRECT_URI=...
SCOPE=https://www.googleapis.com/auth/admin.directory.group

echo "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&scope=$SCOPE&access_type=offline"

AUTHORIZATION_CODE=...

curl --data "code=$AUTHORIZATION_CODE" --data "client_id=$CLIENT_ID" --data "client_secret=$CLIENT_SECRET" --data "redirect_uri=$REDIRECT_URI" --data "grant_type=authorization_code" --data "access_type=offline" https://www.googleapis.com/oauth2/v4/token

REFRESH_TOKEN=...

curl --data "refresh_token=$REFRESH_TOKEN" --data "client_id=$CLIENT_ID" --data "client_secret=$CLIENT_SECRET" --data "grant_type=refresh_token" https://www.googleapis.com/oauth2/v4/token
```

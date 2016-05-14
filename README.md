# cody

cody is GoogleApps Group (MailingLists) manager slack bot.

## Usage

```
$ git clone https://github.com/zaru/google-apps-group-manager-slackbot.git
$ cd google-apps-group-manager-slackbot
$ HUBOT_SLACK_TOKEN=... ./bin/hubot -a slack
```

### set env

write `~/.bash_profile`.

```
export CODY_CLIENT_ID=...
export CODY_CLIENT_SECRET=...
export CODY_APIKEY=...
export CODY_REFRESH_TOKEN=...
export CODY_DOMAIN=...
```

### Get Google OAuth2 REFRESH_TOKEN

Access token will expire. To get the refresh token, you need to update the access token.

```
CLIENT_ID=...
CLIENT_SECRET=...
REDIRECT_URI=...
SCOPE=https://www.googleapis.com/auth/admin.directory.group

echo "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&scope=$SCOPE&access_type=offline"

AUTHORIZATION_CODE=...

curl --data "code=$AUTHORIZATION_CODE" --data "client_id=$CLIENT_ID" --data "client_secret=$CLIENT_SECRET" --data "redirect_uri=$REDIRECT_URI" --data "grant_type=authorization_code" --data "access_type=offline" https://www.googleapis.com/oauth2/v4/token

REFRESH_TOKEN=...

# The following command is not required. This is a sample.
curl --data "refresh_token=$REFRESH_TOKEN" --data "client_id=$CLIENT_ID" --data "client_secret=$CLIENT_SECRET" --data "grant_type=refresh_token" https://www.googleapis.com/oauth2/v4/token
```

### Use PM2

PM2 is a production process manager for Node.js.

```
$ npm install pm2 -g
```

#### app.json

```
{
    "apps":[
        {
            "name"             : "cody",
            "args"             : ["-a", "slack"],
            "script"           : "./bin/hubot",
            "exec_mode"        : "fork",
            "exec_interpreter" : "bash",
            "autorestart"      : true,
            "env": {
                "NODE_ENV"           : "production",
                "PORT"               : "8080",
                "HUBOT_SLACK_TOKEN"  : "..."
            }
        }
    ]
}
```

```
$ pm2 start app.json
$ pm2 list
┌──────────┬────┬──────┬──────┬────────┬─────────┬────────┬─────────────┬──────────┐
│ App name │ id │ mode │ pid  │ status │ restart │ uptime │ memory      │ watching │
├──────────┼────┼──────┼──────┼────────┼─────────┼────────┼─────────────┼──────────┤
│ cody     │ 0  │ fork │ 2692 │ online │ 0       │ 2m     │ 85.441 MB   │ disabled │
└──────────┴────┴──────┴──────┴────────┴─────────┴────────┴─────────────┴──────────┘
```

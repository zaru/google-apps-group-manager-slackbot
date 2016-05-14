# Description:
#   management google apps group
#
# Configuration:
#   CLIENT_ID
#   CLIENT_SECRET
#   APIKEY
#   REFRESH_TOKEN
#
# Commands:
#   hubot lists - List all mailing lists
#   hubot <mailing list> - Show mailing list registered e-mails
#   hubot <mailing list> add <email> - Add e-mail to mailing list
#   hubot <mailing list> rm <email> - Remove e-mail to mailing list
#
# Author:
#   zaru
module.exports = (robot) ->
  request = require('request')
  fs = require('fs')
  google_api_request = (url, callback) ->
    access_token = get_access_token()
    options = {
      url: url + '&key=' + process.env.APIKEY,
      headers: {"Authorization": "Bearer " + access_token},
      json: true
    }
    request.get(options, (error, response, body) ->
      if !error && response.statusCode == 200
        callback(body)
      else
        refresh_access_token(google_api_request, url, callback)
    )
  get_access_token = () ->
    return fs.readFileSync('.access_token', 'utf8')
  refresh_access_token = (callback, url, callback2) ->
    options = {
      url: "https://www.googleapis.com/oauth2/v4/token",
      form: {
        refresh_token: process.env.REFRESH_TOKEN,
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        grant_type: "refresh_token"
      },
      json: true
    }
    request.post(options, (error, response, body) ->
      if !error && response.statusCode == 200
        fs.writeFileSync('.access_token', body.access_token)
        callback(url, callback2)
      else
        console.log('error: '+ response.statusCode)
    )
  robot.respond /members (.+@basicinc\.jp)/i, (msg) ->
    url = 'https://www.googleapis.com/admin/directory/v1/groups/' + encodeURIComponent(msg["match"][1].trim()) + '/members?'
    google_api_request(url, (data) ->
      output = ""
      data.members.forEach((g) ->
        output += g.email + "\n"
      )
      msg.send output
    )
  robot.respond /lists$/i, (msg) ->
    url = 'https://www.googleapis.com/admin/directory/v1/groups?domain=basicinc.jp'
    google_api_request(url, (data) ->
      output = ""
      data.groups.forEach((g) ->
        output += g.name + " / " + g.email + "\n"
      )
      msg.send output
    )

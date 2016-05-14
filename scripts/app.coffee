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
  google_api_get_request = (url, params, callback) ->
    access_token = get_access_token()
    qs = params
    qs["key"] = process.env.APIKEY
    options = {
      url: url,
      headers: {"Authorization": "Bearer " + access_token},
      qs: qs,
      json: true
    }
    request.get(options, (error, response, body) ->
      if !error && response.statusCode == 200
        callback(body)
      else
        refresh_access_token(google_api_get_request, url, params, callback)
    )
  google_api_post_request = (url, params, callback) ->
    access_token = get_access_token()
    qs = { key: process.env.APIKEY }
    options = {
      url: url,
      headers: {"Authorization": "Bearer " + access_token, 'Content-type': 'application/json'},
      qs: qs
      body: params,
      json: true
    }
    request.post(options, (error, response, body) ->
      if !error && response.statusCode == 200
        callback(body)
      else
        if response.statusCode == 409
          callback(false)
        else
          refresh_access_token(google_api_post_request, url, params, callback)
    )
  google_api_delete_request = (url, params, callback) ->
    access_token = get_access_token()
    qs = params
    qs["key"] = process.env.APIKEY
    options = {
      url: url,
      headers: {"Authorization": "Bearer " + access_token},
      qs: qs,
      json: true
    }
    console.log(options)
    request.delete(options, (error, response, body) ->
      if !error && (response.statusCode == 200 || response.statusCode == 204)
        callback(body)
      else
        if response.statusCode == 404
          callback(false)
        else
          refresh_access_token(google_api_get_request, url, params, callback)
    )
  get_access_token = () ->
    return fs.readFileSync('.access_token', 'utf8')
  refresh_access_token = (callback, url, params, callback2) ->
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
        callback(url, params, callback2)
      else
        console.log('error: '+ response.statusCode)
    )
  robot.respond /(\S+@basicinc\.jp)$/i, (msg) ->
    url = 'https://www.googleapis.com/admin/directory/v1/groups/' + encodeURIComponent(msg["match"][1].trim()) + '/members'
    google_api_get_request(url, {}, (data) ->
      output = ""
      data.members.forEach((g) ->
        output += g.email + "\n"
      )
      msg.send output
    )
  robot.respond /lists$/i, (msg) ->
    url = 'https://www.googleapis.com/admin/directory/v1/groups'
    google_api_get_request(url, { domain: 'basicinc.jp' }, (data) ->
      output = ""
      data.groups.forEach((g) ->
        output += g.name + " / " + g.email + "\n"
      )
      msg.send output
    )
  robot.respond /(\S+@basicinc\.jp)\s+add\s(\S+@.+\..+)$/i, (msg) ->
    mailing_lists = msg["match"][1].trim()
    email = msg["match"][2].trim()
    url = 'https://www.googleapis.com/admin/directory/v1/groups/' + encodeURIComponent(mailing_lists.trim()) + '/members'
    google_api_post_request(url, { email: email, role: 'MEMBER' }, (data) ->
      if false == data
        msg.send 'Member already exists.'
      else
        msg.send 'Added!'
    )
  robot.respond /(\S+@basicinc\.jp)\s+rm\s(\S+@.+\..+)$/i, (msg) ->
    mailing_lists = msg["match"][1].trim()
    email = msg["match"][2].trim()
    url = 'https://www.googleapis.com/admin/directory/v1/groups/' + encodeURIComponent(mailing_lists.trim()) + '/members/' + encodeURIComponent(email.trim())
    google_api_delete_request(url, {}, (data) ->
      if false == data
        msg.send 'Member not exists.'
      else
        msg.send 'Removed!'
    )
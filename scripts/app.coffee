module.exports = (robot) ->
  request = require('request')
  google_api_request = (url, callback) ->
    options = {
      url: url + '&key=' + process.env.APIKEY,
      headers: {"Authorization": "Bearer " + process.env.ACCESS_TOKEN},
      json: true
    }
    console.log(options)
    request.get(options, (error, response, body) ->
      if !error && response.statusCode == 200
        callback(body)
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

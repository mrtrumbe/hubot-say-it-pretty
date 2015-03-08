# Description:
#   Post
#   This script listens for things to say via http at path 
#   /hubot/sayitpretty/. Payload should be a json object, format 
#   described below.
#   
#   This is intended to be used with other processes, which should submit 
#   an http request at the above path to say things via hubot.
#
#   This script also registers for event sayitpretty, which takes 
#   (command, successCallback, errorCallback). Just emit sayitpretty with 
#   a command matching the payload definition below and it will be said, 
#   prettily.
#
#   The format of the said messages follows the simple formatting options 
#   of slack, skype, and Google Talk. See this for more info: 
#   https://slack.zendesk.com/hc/en-us/articles/202288908-How-can-I-add-formatting-to-my-messages-
#
# Dependencies:
#   None
#
# Commands:
#   None
#
# Notes:
#   The properties that can be included in the json object payload are:
#   
#   room - The room name to post to. This is required and if the room doesn't exist, nothing will be said.
#   title - The title to say. Optional. Titles are at the top and are bolded.
#   head - The head of the thing to say. Optional. Heads are just below the title and are italicized.
#   message - The message to say. Optional. Messages are just below the head.
#   indent - Whether to indent the message. Defaults to false.
#   compact - Whether the message should be compact. Defaults to true.
#   format - Whether the message should be formatted with bold, italics, etc. Defaults to true.
#   text - Forget about all the other properties and just post this formatted text. Should be formatted according to: https://slack.zendesk.com/hc/en-us/articles/202288908-How-can-I-add-formatting-to-my-messages-
#
# Author:
#   mrtrumbe

TextMessage = require('hubot').TextMessage

module.exports = (robot)->
  _do_success = (msg, callback) ->
    if callback
      try
        callback(msg)
      catch e
        robot.logger.error "sayitpretty success callback threw an error. eating it. error: " + e


  _do_error = (msg, err, callback) ->
    robot.logger.error "tried to say it pretty. it did not go well. " + msg
    if callback
      try
        callback(msg, err)
      catch e
        robot.logger.error "sayitpretty error callback threw an error. eating it. error: " + e


  robot.on "sayitpretty", (command, success, error) ->
    try
      room = command.room
      unless room
        _do_error "no room provided.", null, error
        return

      user = robot.brain.userForId 'broadcast'
      user.room = room
      user.type = 'groupchat'

      if command.text
        robot.send user, command.text
        _do_success "said your text.", success
        return

      compact = true
      if command.compact?
        compact = command.compact

      format = true
      if command.format?
        format = command.format

      msg = ''
      existing = false
      if command.title
        if format
          msg = msg + '*' + command.title + '*'
        else
          msg = msg + command.title
        existing = true

      if command.head
        if existing
          if compact
            msg = msg + ' '
          else
            msg = msg + '\n'
        if format
          msg = msg + '_' + command.head + '_'
        else
          msg = msg + command.head

      indent = false
      if command.indent?
        indent = command.indent

      if command.message
        if existing
          msg = msg + '\n'

        if indent and format
          msg = msg + '>>>' + command.message
        else
          msg = msg + command.message

      robot.send user, msg
      _do_success "said your message.", success

    catch err
      emsg = "error: " + err
      _do_error emsg, err, error


  robot.router.post "/hubot/sayitpretty/", (req, res)->
    success = (msg) ->
      res.end msg

    error = (msg, err) ->
      res.end msg

    robot.emit "sayitpretty", req.body, success, error

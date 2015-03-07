# Description:
#   Post
#   This script listens for things to say via http at path /hubot/sayitpretty/. Payload should be a json object, format described below.
#   
#   This is intended to be used with other processes, which should submit an http request at the above path to say things via hubot.
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
#   text - Forget about all the other properties and just post this formatted text. Should be formatted according to: https://slack.zendesk.com/hc/en-us/articles/202288908-How-can-I-add-formatting-to-my-messages-
#
# Author:
#   mrtrumbe

TextMessage = require('hubot').TextMessage

module.exports = (robot)->
  robot.router.post "/hubot/sayitpretty/", (req, res)->
    room = req.body.room
    unless room
      res.end "no room. stopping."
      return

    user = robot.brain.userForId 'broadcast'
    user.room = room
    user.type = 'groupchat'

    if req.body.text
      robot.send user, req.body.text
      res.end "said your text."
      return
      
    msg = ''
    existing = false
    if req.body.title
      msg = msg + '*' + req.body.title + '*'
      existing = true
      
    if req.body.head
      if existing
        msg = msg + '\n'
      msg = msg + '_' + req.body.head + '_'
      
    indent = false
    if req.body.indent
      indent = req.body.indent
      
    if req.body.message
      if existing
        msg = msg + '\n'
        
      if indent
        msg = msg + '>>>' + req.body.message
      else
        msg + msg + req.body.message

    robot.send user, "#{build.message} and ran on agent:#{build.agentName}"

    robot.send user, msg
    res.end "said your message."

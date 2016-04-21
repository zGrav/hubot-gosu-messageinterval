# Description:
#   Send message to channel under a specific interval
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot list messsage interval - Lists all messages with interval set to channels
#   hubot add message interval <message> <interval> (in seconds) - Add message with interval to channel
#   hubot remove message interval <id> - Removes message with interval from channel
#

module.exports = (robot) ->

    robot.hear /list message interval/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user,'admin') or robot.auth.hasRole(msg.envelope.user,'messageinterval')
            msg.reply "todo"
        else
            msg.reply "Sorry, but you don't have permission to run this command."

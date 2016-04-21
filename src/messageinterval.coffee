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
#   hubot add message interval <message> <interval> (in minutes) - Add message with interval to channel
#   hubot remove message interval <id> - Removes message with interval from channel
#

module.exports = (robot) ->
    arr = robot.brain.data["GOSU_messageinterval"]
    arr = [] if !arr?

    intervals = []

    robot.hear /list message interval/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user,'admin') or robot.auth.hasRole(msg.envelope.user,'messageinterval')
            if arr.length > 0
                i = 0

                while i < arr.length
                    msg.reply "Message Interval: \n
                    -----------------------------------------------------\n
                    ID: #{arr[i].id}\n
                    Message: #{arr[i].message}\n
                    Channel: #{arr[i].channel}\n
                    Interval: #{arr[i].interval}"
                    i++
            else
                msg.reply "No message intervals to list."
        else
            msg.reply "Sorry, but you don't have permission to run this command."

    robot.hear /add message interval (.*?) (.*?)$/i, (msg) ->
        message = msg.match[1]
        interval = msg.match[2]

        if robot.auth.hasRole(msg.envelope.user,'admin') or robot.auth.hasRole(msg.envelope.user,'messageinterval')
            if interval == "0"
                msg.reply "Message interval cannot be 0."
                return

            id = arr.length + 1
            arr.push({id: id, message: message, channel: msg.envelope.room, interval: interval})
            intervals.push({id: id, intervalid: null})

            robot.brain.data["GOSU_messageinterval"] = arr
            robot.brain.save()

            doIntervalTask(id, interval)

            if interval == "1"
                msg.reply "Message #{message} will be sent to channel #{msg.envelope.room} every minute."
            else
                msg.reply "Message #{message} will be sent to channel #{msg.envelope.room} every #{interval} minutes."
        else
            msg.reply "Sorry, but you don't have permission to run this command."

    robot.hear /remove message interval (.*)/i, (msg) ->
        id = msg.match[1]
        idarr = id - 1

        if arr.length > 0
            if robot.auth.hasRole(msg.envelope.user,'admin') or robot.auth.hasRole(msg.envelope.user,'messageinterval')
                removeIntervalTask(idarr)

                msg.reply "ID #{id} which contained message #{arr[idarr].message} to channel #{arr[idarr].channel} has been deleted."

                arr.splice(idarr, 1)

                robot.brain.data["GOSU_messageinterval"] = arr
                robot.brain.save()
            else
                msg.reply "No message intervals to remove."
        else
            msg.reply "Sorry, but you don't have permission to run this command."

    doIntervalTask = (id, interval) ->
        idarr = id - 1
        ms = interval * 60 * 1000

        intervals[idarr].intervalid = setInterval () ->
            response = new robot.Response(robot, {room: arr[idarr].channel})
            response.send arr[idarr].message
        , ms

    removeIntervalTask = (idarr) ->
        clearInterval(intervals[idarr].intervalid)
        intervals.splice(idarr, 1)

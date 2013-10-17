watch = require 'watch'
nconf = require 'nconf'
client = require './client'
async = require 'async'
_ = require 'underscore'

options = 'ignoreDotFiles': true

nconf.file({ file: "./config.json" })

trelloClient = client.trelloClient(nconf)
dropboxClient = client.dropboxClient(nconf)

class DropboxWatcher
  parsePath: (path) ->
    splittedPath = path.split('/')
    rootFileIndex = _.indexOf(splittedPath, "TrelloBox")
    splittedPathLength = splittedPath.length

    unless splittedPathLength - (rootFileIndex + 1) > 2
      directory: splittedPath[splittedPathLength - 2]  # get the last two componentsl
      file: splittedPath[splittedPathLength - 1]



  handleFileEvent: (parsedPath, eventName) ->
    listName = parsedPath['directory']
    cardName = parsedPath['file']

    #use this if the event is to create a new file
    if eventName is "created"
      if listName isnt undefined 

        async.waterfall [
          (callback) ->
            trelloClient.get "/1/boards/523f93696306ccfc7a003d18/lists", (err, lists) ->
              list = _.find(lists, (list) -> list.name is listName)
              if list isnt undefined
                console.log("#{listName} already exists")
              else
                trelloClient.post "/1/boards/523f93696306ccfc7a003d18/lists?name=#{listName}", (err, list) ->
                  if err
                    console.log(err)
                    return
                  
                  console.log("#{listName} has been created")
              
              callback(err, list)

          (list, callback) ->
            if cardName isnt undefined
              console.log("Now creating #{cardName}")
              trelloClient.post "/1/lists/#{list.id}/cards?name=#{cardName}", (err, response) ->
                if err
                  console.log(err)
                  return

                console.log("#{cardName} has been created")
                callback(err)
        ]
    

      
  startWatching: ->
    watch.watchTree "/Users/jaychae/Dropbox/TrelloBox/", (f, curr, prev) ->
      if typeof f is "object" and prev is null and curr is null

      
      # Finished walking the tree
      else if prev is null
        console.log("created")
        console.log(f)
      
      # f is a new file
      else if curr.nlink is 0

        console.log("removed")
        console.log(f)
      
      # f was removed
      else
        console.log("changed")
        console.log(f)
      

        # f was changed

    # watch.createMonitor '/Users/jaychae/Dropbox/TrelloBox/', options, (monitor) =>
    #   monitor.on "created", (f, stat) =>
    #     # console.log("created")
    #     # parsedPath = @parsePath(f)
    #     # @handleFileEvent(parsedPath, "created")
    #     console.log(stat)
    #     console.log(f)

    #   monitor.on "changed", (f, curr, prev) ->
    #     console.log("changed")
    #     console.log(f)

    #   monitor.on "removed", (f, stat) ->
    #     console.log("removed")
    #     console.log(f)


if require.main is module
  (new DropboxWatcher()).startWatching()

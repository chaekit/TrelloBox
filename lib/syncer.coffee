require 'coffee-trace'

nconf             = require('nconf').file({ file: "./config.json" })
apiClient         = require("../client")
async             = require 'async'
redisClient       = require './redisClient'
dropboxClient     = apiClient.dropboxClient(nconf)
trelloClient      = apiClient.trelloClient(nconf)
_                 = require 'underscore'
config            = require '../config'
rootName          = config.trelloBoxName
boardId           = config.boardId

class Syncer
  @dropboxClient: null
  @trelloClient: null

  @mapDropbox: (dirName, callback) ->
    console.log('calling mapDropbox')
    @dropboxClient.readdir "/#{rootName}", (err, contents) =>
      if err then return callback(err)

      # console.log('TrelloBox contents ', contents.json().contents)
      console.log('TrelloBox contents ', contents)
      directories = _.filter contents, (content) -> 
        content.split(".").length is 1


      processDir = (dir, callback) =>
        redisClient.sadd("#{rootName}:dropboxDirList", dir)
        @dropboxClient.readdir "/#{rootName}/#{dir}", (err, files) ->
          return callback(err) if err
          for file in files
            redisClient.hset("#{rootName}:files:#{file}", "dropboxDirName", dir)
            redisClient.sadd("#{rootName}:global:files", file) if file.split(".").length is 2
            console.log(file)
          callback(err)

      async.each directories, processDir, (err) ->
        callback(err, contents)


  @mapTrello: (boardName, callback) ->
    console.log('calling mapTrello')
    @trelloClient.get "/1/boards/#{boardId}/lists", (err, lists) =>
      if err then return callback(err, undefined)

      processList = (list, callback) =>
        console.log(list)
        redisClient.sadd("#{rootName}:trelloListList", list.name)
        redisClient.set("#{rootName}:trelloListIdIndex:#{list.name}", list.id)

        @trelloClient.get "/1/lists/#{list.id}/cards", (err, cards) ->
          return callback(err, undefined) if err
          for card in cards
            redisClient.hset("#{rootName}:files:#{card.name}", "trelloListName", list.name)
            redisClient.hset("#{rootName}:files:#{card.name}", "trelloListId", list.id)
            redisClient.hset("#{rootName}:files:#{card.name}", "trelloCardId", card.id)
            redisClient.sadd("#{rootName}:global:files", card.name)
          callback(null, lists)

      async.each lists, processList, (err) ->
        callback(err, lists)


  @mapTrelloAndDropbox: (callback) ->
    async.parallel [
      (callback) =>
        @mapDropbox rootName, (err, dirs) -> callback(err, dirs)
      ,
      (callback) =>
        @mapTrello rootName, (err, lists) -> callback(err, lists)
    ],
    (err, results) ->
      console.log(results)
      callback(err,results)


  @syncNewDropboxDirs: (callback) ->
    redisClient.sdiff "#{rootName}:dropboxDirList", "#{rootName}:trelloListList", (err, newDropboxDirs) =>
      return callback(err) if err

      createNewList = (listName, callback) =>
        @trelloClient.post "/1/boards/#{boardId}/lists?name=#{listName}", (err, list) ->
          if err then return callback(err) 
          console.log("#{listName} has been created")
          redisClient.set("#{rootName}:trelloListIdIndex:#{list.name}", list.id)
          callback(null)
       
      async.each newDropboxDirs, createNewList, (err) ->
        callback(err) 


  @syncFiles: (callback) ->
    redisClient.smembers "#{rootName}:global:files", (err, files) =>
      syncFile = (file, callback) =>
        console.log(file)
        redisClient.hgetall "#{rootName}:files:#{file}", (err, contents) =>
          dropboxDirName = contents.dropboxDirName
          trelloListName = contents.trelloListName
          trelloCardId = contents.trelloCardId
          trelloListId = contents.trelloListId

          if dropboxDirName is undefined and trelloListName isnt undefined
            @trelloClient.put "/1/cards/#{trelloCardId}/closed?value=true", (err) ->
              console.log("removed") 
          else if dropboxDirName isnt undefined and trelloListName is undefined
            redisClient.get "#{rootName}:trelloListIdIndex:#{dropboxDirName}", (err, listId) =>
              @trelloClient.post "/1/lists/#{listId}/cards?name=#{file}", (err) ->
                console.log("created") 
          else if dropboxDirName isnt undefined and trelloListName isnt undefined
            if dropboxDirName isnt trelloListName
              redisClient.get "#{rootName}:trelloListIdIndex:#{dropboxDirName}", (err, listId) =>
                @trelloClient.put "/1/cards/#{trelloCardId}?idList=#{listId}", (err) ->
                  console.log("moved") 
            else
              console.log("don't do shit")
          else
            console.log("wtf")

      async.each files, syncFile, (err) ->
        return callback(err) 


  @syncDropboxToTrello: (callback) ->
    async.series [
      (callback) =>
        @syncNewDropboxDirs (err) -> callback(err, "done")
      ,
      (callback) =>
        @syncFiles (err) -> callback(err, "done")
    ],
    (err, results) ->
      callback(err, results)


  @flushRedis: (callback) ->
    async.waterfall [
      (callback) ->
        redisClient.keys "*TrelloBox*", (err, matchingKeys) ->
          callback(err, matchingKeys)
      ,
      (keys, callback) ->
        console.log(keys)
        async.each keys, redisClient.del.bind(redisClient), (err) ->
          callback(err, "done") 
    ],
    (err, results) ->
      callback(err, results) 
     

  @manualSync: (callback) ->
    async.series [
      (callback) =>
        @flushRedis (err) -> callback(err, "Done flushing Redis")
      ,
      (callback) =>
        @mapTrelloAndDropbox (err) -> callback(err, "Done mapping Trello and Dropbox") 
      ,
      (callback) =>
        @syncDropboxToTrello (err) -> callback(err, "Done syncing contents") 
    ],
    (err, results) ->
      console.log(err, results) 


module.exports = Syncer

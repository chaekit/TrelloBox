TBModel = require './models'
client = require './client'
nconf = require 'nconf'
request = require 'request'


#setup models
TBRoot = TBModel.TBRoot

nconf.file({ file: "./config.json" })

#setup clients
trelloClient = client.trelloClient(nconf)
dropboxClient = client.dropboxClient(nconf)


task "sync:trello", "Maps Dropboxfiles to Trello", ->
  tbRoot = new TBRoot("TrelloBox")
  tbRoot.dropboxClient = dropboxClient
  tbRoot.trelloClient = trelloClient
  tbRoot.syncTrello() 


task "sync:dropbox", "Maps Dropboxfiles to Trello", ->
  tbRoot = new TBRoot("TrelloBox")
  tbRoot.dropboxClient = dropboxClient
  tbRoot.trelloClient = trelloClient
  tbRoot.syncDropbox() 


task "getBoardId", "retreives boardId", ->
  tbRoot = new TBRoot("TrelloBox")
  tbRoot.trelloClient = trelloClient
  tbRoot.initTrelloBoardObject (err, board) ->
    console.log board.id


task "webhook:setup", "Set up Trello webhook for the board", ->
  tbRoot = new TBRoot("TrelloBox")
  tbRoot.trelloClient = trelloClient
  tbRoot.initTrelloBoardObject (err, board) ->
    console.log board.id
    authToken = nconf.get("TRELLO_TOKEN")
    appKey = nconf.get("TRELLO_APP_KEY")
    url = "https://trello.com/1/tokens/#{authToken}/webhooks/?key=#{appKey}"
    form = 
      idModel: board.id
      callbackURL: nconf.get("WEBHOOK_CALLBACK_URL")
      description: 'webhook for TrellBox'
    req = 
      url: url
      form: form

    request.post req, (err, response, body) ->
      if err
        console.log(err)
        return

      console.log(body) 

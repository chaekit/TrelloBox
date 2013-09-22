TBModel = require './models'
client = require './client'
nconf = require 'nconf'

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

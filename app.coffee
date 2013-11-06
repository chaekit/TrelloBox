express         = require("express")
http            = require("http")
path            = require("path")
nconf           = require "nconf"
crypto          = require 'crypto'
Syncer          = require './lib/syncer'
Trello          = require "node-trello"
Dropbox         = require "dropbox"


nconf.file({ file: './config.json' })
trelloClient = new Trello(nconf.get("TRELLO_APP_KEY"), nconf.get("TRELLO_APP_SECRET"))
 
dropboxClient = new Dropbox.Client
  key: nconf.get("DROPBOX_APP_KEY")
  secret: nconf.get("DROPBOX_APP_SECRET")
  token: nconf.get("DROPBOX_TOKEN")

Syncer.trelloClient = trelloClient
Syncer.dropboxClient = dropboxClient

app = express()

# all environments
app.set "port",  3000
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

# development only
app.use express.errorHandler()  if "development" is app.get("env")

app.get '/trellowebhook', (req, res)->
  console.log(req)
  res.send 200


app.post '/trellowebhook', (req, res)->
  if req.headers['x-trello-webhook'] isnt undefined
    hash = crypto.createHmac('sha1', TRELLO_APP_SECRET).
      update(req.body + WEBHOOK_CALLBACK_URL)

    trelloAction = req.body.action.data
    oldDir = trelloAction["listBefore"]["name"]
    newDir = trelloAction["listAfter"]["name"]
    fileName = trelloAction["card"]["name"]

    # if oldDir isnt undefined and newDir isnt undefined
    #   tbRoot.moveDropboxFile fileName, oldDir, newDir, (err, stat) ->
    #     if err then return console.log(err)

    #     console.log(stat)
    res.send 200
  else
    res.send 403

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


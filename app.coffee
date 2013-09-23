express = require("express")
http = require("http")
path = require("path")
nconf = require "nconf"
Trello = require "node-trello"
Dropbox = require "dropbox"


TBModel = require "./models"
TBRoot = TBModel.TBRoot

if process.env.NODE_ENV is "production"
  TRELLO_APP_KEY = process.env.TRELLO_APP_KEY
  TRELLO_APP_SECRET = process.env.TRELLO_APP_SECRET
  DROPBOX_APP_KEY = process.env.DROPBOX_APP_KEY
  DROPBOX_APP_SECRET = process.env.DROPBOX_APP_SECRET
  DROPBOX_TOKEN = process.env.DROPBOX_TOKEN
else
  nconf.file({ file: "./config.json" })
  TRELLO_APP_KEY = nconf.get("TRELLO_APP_KEY")
  TRELLO_APP_SECRET = nconf.get("TRELLO_APP_SECRET")  
  DROPBOX_APP_KEY = nconf.get("DROPBOX_APP_KEY")  
  DROPBOX_APP_SECRET = nconf.get("DROPBOX_APP_SECRET")
  DROPBOX_TOKEN = nconf.get("DROPBOX_TOKEN")


trelloClient = new Trello(TRELLO_APP_KEY, TRELLO_APP_SECRET)
 
dropboxClient = new Dropbox.Client(
  key: DROPBOX_APP_KEY
  secret: DROPBOX_APP_SECRET
  token: DROPBOX_TOKEN
)


trelloClient = new Trello(nconf.get("TRELLO_APP_KEY"), nconf.get("TRELLO_APP_SECRET"))
 
dropboxClient = new Dropbox.Client(
  key: nconf.get("DROPBOX_APP_KEY")
  secret: nconf.get("DROPBOX_APP_SECRET")
  token: nconf.get("DROPBOX_TOKEN")
)



tbRoot = new TBRoot("TrelloBox")
tbRoot.trelloClient = trelloClient
tbRoot.dropboxClient = dropboxClient

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
  trelloAction = req.body.action.data
  oldDir = trelloAction["listBefore"]["name"]
  newDir = trelloAction["listAfter"]["name"]
  fileName = trelloAction["card"]["name"]
  if oldDir isnt undefined and newDir isnt undefined
    tbRoot.moveDropboxFile fileName, oldDir, newDir, (err, stat) ->
      if err
        return console.log(err)

      console.log(stat)
  res.send 200

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


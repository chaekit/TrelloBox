express = require("express")
http = require("http")
path = require("path")
nconf = require "nconf"
Trello = require "node-trello"
Dropbox = require "dropbox"


TBModel = require "./models"
TBRoot = TBModel.TBRoot


nconf.file({ file: "./config.json" })

trelloClient = new Trello(nconf.get("TRELLO_APP_KEY"), nconf.get("TRELLO_APP_SECRET"))
 
dropboxClient = new Dropbox.Client(
  key: nconf.get("DROPBOX_APP_KEY")
  secret: nconf.get("DROPBOX_APP_SECRET")
  token: nconf.get("DROPBOX_TOKEN")
)
 

@tbRoot = new TBRoot("TrelloBox")
@tbRoot.trelloClient = trelloClient
@tbRoot.dropboxClient = dropboxClient


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
  trelloAction = req.body.action
  console.log(trelloAction.data)
  res.send 200

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


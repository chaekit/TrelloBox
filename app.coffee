Trello = require "node-trello"
Dropbox = require "dropbox"
nconf = require "nconf"
TBModel = require "./models"
TBRoot = TBModel.TBRoot


nconf.file({ file: "./config.json" })

trelloClient = new Trello(nconf.get("TRELLO_APP_KEY"), nconf.get("TRELLO_APP_SECRET"))

dropboxClient = new Dropbox.Client(
  key: nconf.get("DROPBOX_APP_KEY")
  secret: nconf.get("DROPBOX_APP_SECRET")
  token: nconf.get("DROPBOX_TOKEN")
)


root = new TBRoot("TrelloBox")
root.syncTrelloToDropbox()


# express = require("express")
# # routes = require("./routes")
# # user = require("./routes/user")
# http = require("http")
# path = require("path")
# app = express()
# 
# # all environments
# app.set "port",  3000
# app.use express.logger("dev")
# app.use express.bodyParser()
# app.use express.methodOverride()
# app.use app.router
# 
# # development only
# app.use express.errorHandler()  if "development" is app.get("env")
# # app.get "/", routes.index
# # app.get "/users", user.list
# http.createServer(app).listen app.get("port"), ->
#   console.log "Express server listening on port " + app.get("port")
# 

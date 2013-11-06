Dropbox = require "dropbox" 
Trello = require "node-trello"

exports.dropboxClient = (nconfig) ->
  new Dropbox.Client(
    key: nconfig.get("DROPBOX_APP_KEY")
    secret: nconfig.get("DROPBOX_APP_SECRET")
    token: nconfig.get("DROPBOX_TOKEN")
  )

exports.trelloClient = (nconfig) ->
  new Trello(nconfig.get("TRELLO_APP_KEY"), nconfig.get("TRELLO_APP_SECRET"))

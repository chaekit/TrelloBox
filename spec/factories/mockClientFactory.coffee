nodemock = require 'nodemock'

class TrelloMockClient
  @getAllBoards: (callbackParams) ->
    return nodemock.mock("get").
          takes("/1/members/chaebacca/boards", ->).
          calls(1, [undefined, callbackParams])

class DropboxMockClient
  @readDirFor: (dirPath, callbackParams) ->
    return nodemock.mock("readdir").
      takes(dirPath, ->).
      calls(1, [undefined, callbackParams])  

exports.TrelloMockClient = TrelloMockClient
exports.DropboxMockClient = DropboxMockClient

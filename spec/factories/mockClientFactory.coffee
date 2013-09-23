nodemock = require 'nodemock'

class TrelloMockClient
  @getAllBoards: (callbackParams) ->
    return nodemock.mock("get").
          takes("/1/members/chaebacca/boards", ->).
          calls(1, [undefined, callbackParams])


  @getAllLists: (boardId, callbackParams) ->
    return nodemock.mock("get").
          takes("/1/boards/#{boardId}/lists", ->).
          calls(1, [undefined, callbackParams])


  @postNewList: (boardId, listName, callbackParams) ->
    return nodemock.mock("post").
          takes("/1/boards/#{boardId}/lists?name=#{listName}", ->).
          calls(1, [undefined, callbackParams])


class DropboxMockClient
  @readDirFor: (dirPath, callbackParams) ->
    return nodemock.mock("readdir").
      takes(dirPath, ->).
      calls(1, [undefined, callbackParams])  


  @moveFile: (oldPath, newPath, callbackParam) ->
    return nodemock.mock("move").
      takes(oldPath, newPath, ->).
      calls(2, [undefined, callbackParam])

exports.TrelloMockClient = TrelloMockClient
exports.DropboxMockClient = DropboxMockClient

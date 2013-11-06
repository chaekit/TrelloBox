nodemock = require 'nodemock'

class TrelloMockClient
  @getAllBoards: (callbackParams) ->
    return nodemock.mock("get").
          takes("/1/members/chaebacca/boards", ->).
          calls(1, [undefined, callbackParams])

  @getAllCards: (boardId, callbackParams) ->
    return nodemock.mock("get").
          takes("/1/boards/#{boardId}/cards", ->).
          calls(1, [undefined, callbackParams])

  @getAllLists: (boardId, callbackParams) ->
    return nodemock.mock("get").
          takes("/1/boards/#{boardId}/lists", ->).
          calls(1, [undefined, callbackParams])


  @postNewList: (boardId, listName, callbackParams) ->
    return nodemock.mock("post").
          takes("/1/boards/#{boardId}/lists?name=#{listName}", ->).
          calls(2, [undefined, callbackParams])

  @postGetNewList: (boardId, listName, callbackParams) ->
    mocker = nodemock.mock("get").
      takes("/1/boards/#{boardId}/lists", ->).
      calls(1, [undefined, callbackParams])
    mocker.mock("post").
      takes("/1/boards/#{boardId}/lists?name=#{listName}", ->).
      calls(1, [undefined, callbackParams])
    return mocker




class DropboxMockClient
  @stat: (path, callbackParams) ->
    return nodemock.mock("stat").
      takes(path, { readDir: true }, ->).
      calls(2, [undefined, callbackParams])  


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

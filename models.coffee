nconf = require('nconf').file({ file: "./config.json" })
apiClient = require("./client")
async = require 'async'

if process.env.PROJECT_ENV is "TEST"
  dropboxClient = apiClient.mockDropboxClient()
else
  dropboxClient =  apiClient.dropboxClient(nconf)
  trelloClient = apiClient.trelloClient(nconf)

class TBFile
  constructor: (tbDirectory, fileName) ->
    @fileName = fileName
    @tbDirectory = tbDirectory

    @trelloCardObject = null
    @dropboxFileObject = null

  initTrelloCard: ->
    trelloClient.get("/1/lists/#{@tbDirectory.trelloListObject.id}/cards", (err, cards) =>
      matchingCard = card for card in cards when card.name is @fileName

      if matchingCard isnt undefined
        console.log("there is an existing card. not creating a duplicate") 
        @trelloCardObject = matchingCard
        return

      trelloClient.post("/1/lists/#{@tbDirectory.trelloListObject.id}/cards?name=#{@fileName}", (err, response) =>
        if err
          console.log(err)
          return

        console.log(response)
        @trelloCardObject = matchingCard
      )
    )


class TBDirectory
  constructor: (tbRoot, directoryName) ->
    @tbRoot = tbRoot
    @directoryName = directoryName
    @tbFiles = []
    @trelloListObject = null
    @dropboxDirObject = null

  path: ->
    return "/#{@tbRoot.rootName}/#{@directoryName}"

  mapDropboxFiles: ->
    dropboxClient.readdir(@path(), (err, files) =>
      for file in files
        dropboxClient.stat(@pathForFile(file), (err, metadata) =>
          if metadata.isFile
            tbFile = new TBFile(this, metadata.name)
            tbFile.initTrelloCard()
            @tbFiles.push(tbFile)
        )
    )

  initTrelloList: ->
    trelloClient.get("/1/boards/#{@tbRoot.trelloBoardObject.id}/lists", (err, lists) =>
      matchingFile = list for list in lists when list.name is @directoryName

      if matchingFile isnt undefined
        console.log("#{matchingFile.name} alreday exits on Trello. not creating a duplicate")
        @trelloListObject = matchingFile
        @mapDropboxFiles()
        return

      trelloClient.post("/1/boards/#{@tbRoot.trelloBoardObject.id}/lists?name=#{@directoryName}", (err, list) =>
        if err
          console.log(err)
          return

        console.log(list)
        @trelloListObject = list
        @mapDropboxFiles()
      )
    )


  pathForFile: (fileName) ->
    return "#{this.path()}/#{fileName}"

class TBRoot
  constructor: (rootName) ->
    @rootName = rootName
    @tbDirs = []
    @tbFiles = []
    @dropboxRootDirObject = null
    @trelloBoardObject = null

    @trelloLists = null

    @trelloListIndex = new Array()
    @dropboxFileIndex = new Array()

    @dropboxDirCount = 0
    @_indexedDropboxCount = 0

    @dropboxClient = null
    @trelloClient = null

  initTrelloBoardObject: (callback) ->
    @trelloClient.get("/1/members/chaebacca/boards", (err, boards) =>
      boardsWithMatchingName = boards.filter (board) => 
        board.name is "#{@rootName}" and board.closed is false

      if boardsWithMatchingName.length == 0
        return callback(new Error "No matching board found!", null)
      else if boardsWithMatchingName.length > 1
        return callback(new Error "More than one matching board found!", null)
      else
        console.log("Found Trello Board #{@rootName}")

      matchingBoard = boardsWithMatchingName[0] 
     
      @trelloBoardObject = matchingBoard
      callback undefined, matchingBoard
    )



  mapDropboxRoot: (callback) ->
    @dropboxClient.readdir("/#{@rootName}", (err, contents) =>
      for content in contents
        splitCount = content.split(".").length
        if splitCount is 1
          tbDir = new TBDirectory(this, content)
          tbDir.initTrelloList()
          @tbDirs.push tbDir
        else
          @tbFiles.push new TBFile(content)

      callback err, @tbDirs, @tbFiles
    )



  allTrelloLists: (boardId, callback) ->
    @trelloClient.get("/1/boards/#{boardId}/lists", (err, lists) =>
      if err
        console.log(err)
        return

      @trelloLists = lists
      callback err, lists
    )



  initReservedTrelloList: (listName, boardId, callback) ->
    if @trelloLists is undefined
      throw new Error "@trelloLists is not defined"
      return

    matchingList = list for list in @trelloLists when list.name is listName

    if matchingList isnt undefined
      console.log("Reserved Trello List #{matchingList} already exists!")
      return
    else
      @trelloClient.post("/1/boards/#{@trelloBoardObject.id}/lists?name=#{listName}", (err, list) =>
        if err
          console.log(err)
          return
        
        console.log("#{listName} has been created")
        callback err
      )


  indexDropboxDirs: (callback) ->
    @dropboxClient.readdir "/#{@rootName}", (err, entries) =>
      dirs = entries.filter (e) -> e.split(".").length == 1
      @dropboxDirCount = dirs.length

      callback err, dirs
    



  indexSingleDropboxDir: (dirName, callback) ->
    @dropboxClient.readdir("/#{@rootName}/#{dirName}", (err, entries) =>
      files = entries.filter (e) -> e.split(".").length == 2
      for file in files
        @dropboxFileIndex[file] = dirName
        fileIndexSize = Object.keys(@dropboxFileIndex).length

      @_indexedDropboxCount += 1
      callback(err) if @dropboxDirCount is @_indexedDropboxCount
    )
        


  indexTrelloLists: (callback, lists) ->
    @trelloClient.get("/1/boards/#{@trelloBoardObject.id}/lists", (err, lists) =>
      for list in lists
        @trelloListIndex[list.id] = list.name

      callback err, lists
    )



  processTrelloCards: (callback) ->
    @trelloClient.get("/1/boards/#{@trelloBoardObject.id}/cards", (err, cards) =>

      for tbfile in cards
        tbFileListName = @trelloListIndex[tbfile.idList]
        tbFileDropboxDirName = @dropboxFileIndex[tbfile.name]

        if tbFileListName isnt tbFileDropboxDirName and tbFileDropboxDirName isnt undefined
          oldDropboxPath = "/TrelloBox/#{tbFileDropboxDirName}/#{tbfile.name}"
          newDropboxPath = "/TrelloBox/#{tbFileListName}/#{tbfile.name}"
          dropboxClient.move(oldDropboxPath, newDropboxPath, (err, stat)->
            if err
              console.log(err)
              return

            console.log(stat)
          )
    )


  mapAllTBFiles: ->
    @trelloClient.get("/1/boards/#{@trelloBoardObject.id}/cards", (err, cards) =>
      for tbfile in cards
        tbFileListName = @trelloListIndex[tbfile.idList]
        tbFileDropboxDirName = @dropboxFileIndex[tbfile.name]

        if tbFileListName isnt tbFileDropboxDirName and tbFileDropboxDirName isnt undefined
          oldDropboxPath = "/TrelloBox/#{tbFileDropboxDirName}/#{tbfile.name}"
          newDropboxPath = "/TrelloBox/#{tbFileListName}/#{tbfile.name}"

          dropboxClient.move(oldDropboxPath, newDropboxPath, (err, stat)->
            console.log(stat)
          )
    )


  syncTrello: ->
    @initTrelloBoardObject((err, boardObject) =>
      @mapDropboxRoot((err, tbDirs, tbFiles) =>)

      @allTrelloLists(boardObject.id, (err, lists) =>
        @initReservedTrelloList("Reading List", boardObject.id, (err) ->)
        @initReservedTrelloList("Favorites", boardObject.id, (err) ->)
      )
    )

    
  syncDropbox: ->
    @initTrelloBoardObject((err, boardObject) =>
      @indexTrelloLists((err, lists) =>
        @indexDropboxDirs((err, directories) =>
          for dir in directories
            @indexSingleDropboxDir(dir, (err) =>
              @mapAllTBFiles()
            )
        )
      )
    )

exports.TBRoot = TBRoot
exports.TBFile = TBFile
exports.TBDirectory = TBDirectory

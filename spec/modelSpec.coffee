TBModel = require('../models')
TBFile = TBModel.TBFile
TBRoot = TBModel.TBRoot
TBDirectory = TBModel.TBDirectory

SpecFactory = require './factories/dropboxFactory'
DropboxFactory = SpecFactory.DropboxFactory
TrelloFactory = SpecFactory.TrelloFactory

MockClientFactory = require './factories/mockClientFactory'
TrelloMockClient = MockClientFactory.TrelloMockClient
DropboxMockClient = MockClientFactory.DropboxMockClient

nock = require 'nock'
nodemock = require 'nodemock'


describe "TBRoot",  ->

  beforeEach ->
    @tbRoot = new TBRoot("FooBox")
  
  describe "instance methods", ->

    describe "#mapDropboxRoot", ->
      describe "fills tbDirs and tbFiles", ->
        beforeEach ->
          dirWithFileAndDir = DropboxFactory.dirWithFileAndDir() 
          @tbRoot.dropboxClient = DropboxMockClient.readDirFor("/#{@tbRoot.rootName}", dirWithFileAndDir)
          
        it "should fill @tbDirs if there are files inside the root", (done) ->
          @tbRoot.mapDropboxRoot (err, dirs, files) =>
            expect(@tbRoot.tbDirs.length).toEqual(2)
            done()


        it "should fill @tbFiles if there are files inside the root", (done) ->
          @tbRoot.mapDropboxRoot (err, dirs, files) =>
            expect(@tbRoot.tbFiles.length).toEqual(2)
            done()



    describe "#indexDropboxDirs", ->
      it "should set @dropboxDirCount", (done) ->
        dirWithAllDirs = DropboxFactory.dirWithAllDirs()
        @tbRoot.dropboxClient = DropboxMockClient.readDirFor("/FooBox", dirWithAllDirs)
        @tbRoot.indexDropboxDirs (err,dirs) =>
          numDirs = dirWithAllDirs.length
          expect(@tbRoot.dropboxDirCount).toEqual(numDirs)
          done()



    describe "#indexSingleDropboxDir", ->
      beforeEach ->
        dirWithAllFiles = DropboxFactory.dirWithAllFiles() # ["abc.txt", "this.js", "ruby.rb", "python.py"]
        @tbRoot.dropboxClient = DropboxMockClient.readDirFor("/FooBox/SubFoo1", dirWithAllFiles)
        @tbRoot.dropboxDirCount = 1

      it "should @dropboxFileIndex", (done) ->
        @tbRoot.indexSingleDropboxDir "SubFoo1", (err) =>
          expect(@tbRoot._indexedDropboxCount).toEqual(1)
          done()


      it "should index @dropboxFileIndex", (done) ->
        @tbRoot.indexSingleDropboxDir "SubFoo1", (err) =>
          dbFileIndex = @tbRoot.dropboxFileIndex
          expect(dbFileIndex["abc.txt"]).toEqual("SubFoo1")
          expect(dbFileIndex["this.js"]).toEqual("SubFoo1")
          done()




    describe "#initTrelloBoardObject", ->
      it "should set the error if there are duplicate boards", (done) ->
        board = 
          name: "FooBox"
          closed: false
        @tbRoot.trelloClient = TrelloMockClient.getAllBoards([board, board])
        @tbRoot.initTrelloBoardObject (err, board) =>
          expect(err).not.toBeNull()
          expect(err.message).toEqual("More than one matching board found!")
          done()


      it "should set the error if there is no matching board", (done) ->
        @tbRoot.trelloClient = TrelloMockClient.getAllBoards(["lolcat", "hi"])
        @tbRoot.initTrelloBoardObject (err, board) =>
          expect(err).not.toBeNull()
          expect(err.message).toEqual("No matching board found!")
          done()
   

    describe "#indexTrelloLists", ->
      it "should fill out @trelloListIndex", (done) ->
        trelloLists = TrelloFactory.standardLists()
        @tbRoot.trelloBoardObject = TrelloFactory.boardObject()
        boardId = @tbRoot.trelloBoardObject.id

        @tbRoot.trelloClient = TrelloMockClient.getAllLists(boardId, trelloLists)
        @tbRoot.indexTrelloLists (err, lists) =>
          listIndex = @tbRoot.trelloListIndex
          expect(listIndex["abcdef"]).toEqual("ToDo")
          expect(listIndex["ghijk"]).toEqual("JS")
          done()


    describe "#initReservedTrelloList", ->
      it "should not create a list if there is an existing one", (done) ->
        @tbRoot.trelloLists = TrelloFactory.standardLists()
        @tbRoot.trelloClient = TrelloMockClient.postNewList("abc", "ToDo", null)
        spyOn(@tbRoot.trelloClient, 'post')
        @tbRoot.initReservedTrelloList "ToDo", "", (err) =>
          expect(@tbRoot.trelloClient.post).not.toHaveBeenCalled()
          done()
      
    






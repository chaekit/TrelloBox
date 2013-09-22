TBModel = require('../models')
TBFile = TBModel.TBFile
TBRoot = TBModel.TBRoot
TBDirectory = TBModel.TBDirectory

SpecFactory = require './factories/dropboxFactory'
DropboxFactory = SpecFactory.DropboxFactory

MockClientFactory = require './factories/mockClientFactory'
TrelloMockClient = MockClientFactory.TrelloMockClient
DropboxMockClient = MockClientFactory.DropboxMockClient

nock = require 'nock'
nodemock = require 'nodemock'


describe "TBRoot",  ->

  beforeEach ->
    @tbRoot = new TBRoot("FooBox")
  
  describe "instance methods", ->

    describe "#indexDropboxDirs", ->
      it "should set @dropboxDirCount", (done) ->
        dirWithAllDirs = DropboxFactory.dirWithAllDirs()
        @tbRoot.dbClient = DropboxMockClient.readDirFor("/FooBox", dirWithAllDirs)
        @tbRoot.indexDropboxDirs (err,dirs) =>
          numDirs = dirWithAllDirs.length
          expect(@tbRoot.dropboxDirCount).toEqual(numDirs)
          done()



    describe "#indexSingleDropboxDir", ->
      beforeEach ->
        dirWithAllFiles = DropboxFactory.dirWithAllFiles() # ["abc.txt", "this.js", "ruby.rb", "python.py"]
        @tbRoot.dbClient = DropboxMockClient.readDirFor("/FooBox/SubFoo1", dirWithAllFiles)
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
    

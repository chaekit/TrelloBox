SpecFactory           = require './factories/dropboxFactory'
DropboxFactory        = SpecFactory.DropboxFactory
TrelloFactory         = SpecFactory.TrelloFactory

MockClientFactory     = require './factories/mockClientFactory'
TrelloMockClient      = MockClientFactory.TrelloMockClient
DropboxMockClient     = MockClientFactory.DropboxMockClient

Syncer                = require '../lib/syncer'
redisClient           = require '../lib/redisClient'
nodemock              = require 'nodemock'

context = describe

describe "Syncer", ->
  beforeEach ->
    @syncer = Syncer

  describe "mapDropbox", ->
    beforeEach ->
      fooBoxContents = [{ name: "Javascript", isFolder: true, isFile: false }]
      mockDropboxClient =  nodemock.mock("stat").
        takes("/TrelloBox", { readDir: true }, ->).
        calls(2, [undefined, fooBoxContents])  

      jsContents = [{ name: 'learnjs.pdf', isFile: true, isFolder: false }]
      mockDropboxClient.mock("stat").
        takes("/TrelloBox/Javascript", { readDir: true }, ->).
        calls(2, [undefined, jsContents])  

      @syncer.dropboxClient = mockDropboxClient

    it "should add directories to TrelloBox:dropboxDirList set to redis", (done)->
      @syncer.mapDropbox "TrelloBox", (err) ->
        redisClient.sismember "TrelloBox:dropboxDirList", "Javascript", (err, isMember) ->
          expect(isMember).toEqual(1)
          done()
    
    it "should set files' dropboxDirNames in redis", (done)->
      @syncer.mapDropbox "TrelloBox", (err) ->
        redisClient.hget "TrelloBox:files:learnjs.pdf", "dropboxDirName", (err, value) ->
          expect(value).toEqual("Javascript")
          done()

    it "should add files to TrelloBox:global:files set data structure", (done) ->
      @syncer.mapDropbox "TrelloBox", (err) ->
        redisClient.sismember "TrelloBox:global:files", "learnjs.pdf", (err, isMember) ->
          expect(isMember).toEqual(1)
          done()


  describe "mapTrello", ->
    beforeEach ->
      mockTrelloLists = [{ name: 'JS', id: 'abc' }]
      mockTrelloClient = nodemock.mock("get").
          takes("/1/boards/abc/lists", ->).
          calls(1, [undefined, mockTrelloLists])

      mockTrelloCards = [{ name: 'learnjs.pdf', idList: 'abc', id: 'def'}]
      mockTrelloClient.mock("get").
          takes("/1/lists/abc/cards", ->).
          calls(1, [undefined, mockTrelloCards])

      @syncer.trelloClient = mockTrelloClient

    it "should add lists to TrelloBox:trelloListList set to redis", (done)->
      @syncer.mapTrello "TrelloBox", (err) ->
        redisClient.sismember "TrelloBox:trelloListList", "JS", (err, isMember) ->
          expect(isMember).toEqual(1)
          done()

    it "should add the file to the TrelloBox:global:files", (done) ->
      @syncer.mapTrello "TrelloBox", (err) ->
        redisClient.sismember "TrelloBox:global:files", "learnjs.pdf", (err, isMember) ->
          expect(isMember).toEqual(1)
          done()

     
    

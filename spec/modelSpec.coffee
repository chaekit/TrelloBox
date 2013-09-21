TBModel = require '../models'
TBFile = TBModel.TBFile
TBRoot = TBModel.TBRoot
TBDirectory = TBModel.TBDirectory

nock = require 'nock'

describe("TBRoot",  ->
  beforeEach( ->
    @tbRoot = new TBRoot("FooBox")
  )

  it("should be awesome", ->
    expect(@tbRoot.rootName).toEqual("FooBox")
  ) 

  describe("instance methods", ->
    describe("#initTrelloBoardObject", ->
      flag = false
      
      it("should set @trelloBoardObject", ->
        runs(->
          flag = false
          setTimeout((->
            flag = true
          ), 500)
        )

        waitsFor((->
          @tbRoot.initTrelloBoardObject()
          return flag
        ), "wait", 500)

        runs(->
          expect(@tbRoot.trelloBoardObject).not.toBeNull()
        )
      )
    )
  )
)


describe("TBDirectory", ->
  beforeEach( ->
    @tbRoot = new TBRoot("FooBox")
    @tbDirectory = new TBDirectory(@tbRoot, "lolcat")
    @tbRoot.trelloBoardObject = 
      id: "lol"
    spyOn(@tbRoot.trelloBoardObject, 'id').andReturn("abcde")
  )


  describe("#initTrelloList", ->
    it("should send a request to Trello API", ->
      initTrelloRequest = nock("https://api.trello.com")
                              .post("/1/boards/abcde/lists")
                              .reply(200, "wtf")
      
      waitsFor(=>
        @tbDirectory.initTrelloList()
      )
      initTrelloRequest.isDone()
    )
  )

  describe("#mapDropboxFiles", ->
    it("should send a request to Dropbox API", ->
      spyOn(@tbDirectory)
      waitsFor(=>
        @tbDirectory.mapDropboxFiles()
      )
      expect(@tbDirectory.tbFiles.length()).toEqual(3)
    )
  )
)

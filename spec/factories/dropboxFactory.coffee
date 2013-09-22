class DropboxFactory
  @dirWithAllFiles: ->
    return [
      "abc.txt",
      "this.js",
      "ruby.rb",
      "python.py",
    ]

  @dirWithAllDirs: ->
    return [
      "Javascripts",
      "Ruby",
      "Hello World"
    ]
  
  @dirWithFileAndDir: ->
    return [
      "abc.txt",
      "this.js",
      "ruby",
      "python"
    ]

  @rootDirEntries: -> 
    return [
      "SubFoo 1",
      "SubFoo 2",
      "SubFoo 3"
    ]

class TrelloFactory
  @boardEntries: ->
    board1 =
      name: "ToDo"
      closed: false
    board2 = 
      name: "spec_file.rb"
      closed: false
    return [ board1, board2 ]

  @standardLists: ->
    list1 =
      name: "ToDo"
      id: "abcdef"
    list2 =
      name: "JS"
      id: "ghijk"
     
    return [list1, list2]
  
  @boardObject: ->
    board =
      id: "abc"
      closed: "false"

    return board

exports.DropboxFactory = DropboxFactory
exports.TrelloFactory = TrelloFactory

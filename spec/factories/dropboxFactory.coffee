class DropboxFactory
  @dirWithAllFiles: ->
    return [
      {
        name: "abc.txt",
        isFile: true
        isFolder: false
      },

      {
        name: "this.js",
        isFile: true
        isFolder: false
      },
      {
        name: 'python.py'
        isFile: true
        isFolder: false
      },
      {
        name: 'ruby.rb'
        isFile: true
        isFolder: false
      },

    ]

  @dirWithAllDirs: ->
    return [
      "Javascripts",
      "Ruby",
      "Hello World"
    ]
  
  @dirWithFileAndDir: ->
    return [
      {
        name: "abc.txt"
        isFile: true
        isFolder: false
      },
      {
        name: "this.js"
        isFile: true
        isFolder: false
      },
      {
        name: "ruby"
        isFile: false
        isFolder: true
      },
      {
        name: "python"
        isFile: false
        isFolder: true
      },
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
    list3 =
      name: 'ruby'
      id: 'rubyid'
     
    return [list1, list2, list3]
  
  @allCards: ->
    card1 =
      name: 'Learning JS'
      idList: 'abcdef'
    card2 =
      name: 'Learning RUby'
      idList: 'ghijk'
    card3 =
      name: 'Learning Python'
      idList: 'rubyid'
    return [card1, card2, card3]
  
  @boardObject: ->
    board =
      id: "abc"
      closed: "false"

    return board

exports.DropboxFactory = DropboxFactory
exports.TrelloFactory = TrelloFactory

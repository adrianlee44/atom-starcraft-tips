module.exports =
  activate: ->
    StarcraftTipsView = require './starcraft-tips-view'
    @starcraftTipsView = new StarcraftTipsView()

  deactivate: ->
    @starcraftTipsView.destroy()

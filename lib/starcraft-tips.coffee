StarcraftTipsView = require './starcraft-tips-view'

module.exports =
  configDefaults:
    startDelay:      1000
    displayDuration: 10000
    fadeDuration:    300

  starcraftTipsView: null

  activate: (state) ->
    @starcraftTipsView = new StarcraftTipsView()

  deactivate: ->
    @starcraftTipsView.remove()

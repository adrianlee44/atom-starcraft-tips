{View} = require 'atom'
tips   = require './tips'

module.exports =
class StarcraftTipsView extends View
  @content: ->
    @ul class: 'background-tips centered background-message', =>
      @li outlet: 'message'

  initialize: ->
    # Randomize initial starting index
    len    = tips.length
    @index = Math.round(Math.random() * len) % len

    atom.workspaceView.on "pane-container:active-pane-item-changed pane:attached pane:removed", =>
      @updateVisibility()
    setTimeout @start, atom.config.get("starcraft-tips.startDelay")

  attach: ->
    paneView = atom.workspaceView.getActivePaneView()
    top      = paneView.children(".item-views").position()?.top or 0
    @css "top", top
    paneView.append this

  updateVisibility: ->
    if @shouldBeAttached() then @start() else @stop()

  shouldBeAttached: ->
    atom.workspaceView.getPaneViews().length is 1 and not atom.workspace.getActivePaneItem()?

  start: =>
    return if not @shouldBeAttached() or @interval?

    @message.hide()
    @attach()
    @showNextTip()

    displayDuration = atom.config.get("starcraft-tips.displayDuration")
    @interval       = setInterval(@showNextTip, displayDuration)

  stop: =>
    @detach()
    clearInterval @interval if @interval?
    @interval = null

  showNextTip: =>
    @index       = ++@index % tips.length
    fadeDuration = atom.config.get("starcraft-tips.fadeDuration")
    @message.fadeOut(fadeDuration, =>
      @message.html tips[@index]
      @message.fadeIn fadeDuration
    )

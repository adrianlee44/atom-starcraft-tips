{CompositeDisposable} = require 'atom'
tips   = require './tips'

template = """
  <ul class="centered background-message">
    <li class="message"></li>
  </ul>
"""

module.exports =
class StarcraftTipsElement extends HTMLElement
  StartDelay:      1000
  DisplayDuration: 10000
  FadeDuration:    300

  createdCallback: ->
    @index = -1

    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.onDidAddPane => @updateVisibility()
    @disposables.add atom.workspace.onDidDestroyPane => @updateVisibility()
    @disposables.add atom.workspace.onDidChangeActivePaneItem => @updateVisibility()

    @startTimeout = setTimeout((=> @start()), @StartDelay)

  attachedCallback: ->
    @innerHTML = template
    @message = @querySelector('.message')

  destroy: ->
    @stop()
    @disposables.dispose()
    @destroyed = true

  attach: ->
    paneView   = atom.views.getView(atom.workspace.getActivePane())
    top        = paneView.querySelector('.item-views')?.offsetTop or 0
    @style.top = top + 'px'
    paneView.appendChild this

  detach: ->
    @remove()

  updateVisibility: ->
    if @shouldBeAttached() then @start() else @stop()

  shouldBeAttached: ->
    atom.workspace.getPanes().length is 1 and not atom.workspace.getActivePaneItem()?

  start: =>
    return if not @shouldBeAttached() or @interval?

    len = tips.length
    @index = Math.round(Math.random() * len) % len

    @attach()
    @showNextTip()

    @interval = setInterval((=> @showNextTip()), @DisplayDuration)

  stop: =>
    @detach()
    clearInterval(@interval) if @interval?
    clearTimeout(@startTimeout)
    clearTimeout(@nextTipTimeout)
    @interval = null

  showNextTip: ->
    @index = ++@index % tips.length
    @message.classList.remove 'fade-in'
    @nextTipTimeout = setTimeout =>
      @message.innerHTML = tips[@index]
      @message.classList.remove 'fade-out'
      @message.classList.add 'fade-in'
    , @FadeDuration

module.exports = document.registerElement 'starcraft-tips', {
  prototype: StarcraftTipsElement.prototype
}

# Mostly taken from atom/background-tips

{WorkspaceView, $} = require 'atom'
StarcraftTipsView  = require '../lib/starcraft-tips-view'

describe "StarcraftTips", ->
  [starcraftTips, starcraftTipsView] = []

  beforeEach ->
    atom.config.set "starcraft-tips.displayDuration", 50
    atom.config.set "starcraft-tips.fadeDuration", 1

  activatePackage = (callback) ->
    waitsForPromise ->
      atom.packages.activatePackage('starcraft-tips').then ({mainModule}) ->
        {starcraftTipsView} = mainModule

    runs -> callback()

  describe "when the package is activated when there is only one pane", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      expect(atom.workspaceView.getPaneViews().length).toBe 1

    describe "when the pane is empty", ->
      it "attaches the view after a delay", ->
        expect(atom.workspaceView.getActivePaneView().getItems().length).toBe 0

        activatePackage ->
          expect(starcraftTipsView.parent()).not.toExist()
          advanceClock 1001
          expect(starcraftTipsView.parent()).toExist()

    describe "when the pane is not empty", ->
      it "does not attach the view", ->
        atom.workspaceView.getActivePaneView().activateItem $("item")
        activatePackage ->
          advanceClock 1001
          expect(starcraftTipsView.parent()).not.toExist()

    describe "when a second pane is created", ->
      it "detaches the view", ->
        activatePackage ->
          advanceClock 1001
          expect(starcraftTipsView.parent()).toExist()

          atom.workspaceView.getActivePaneView().splitRight()
          expect(starcraftTipsView.parent()).not.toExist()

  describe "when the package is activated when there are multiple panes", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      atom.workspaceView.getActivePaneView().splitRight()
      expect(atom.workspaceView.getPaneViews().length).toBe 2

    it "does not attach the view", ->
      activatePackage ->
        advanceClock 1001
        expect(starcraftTipsView.parent()).not.toExist()


    describe "when all but the last pane is destroyed", ->
      it "attaches the view", ->
        activatePackage ->
          atom.workspaceView.getActivePaneView().remove()
          advanceClock 1001
          expect(starcraftTipsView.parent()).toExist()

  describe "when the view is attached", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      expect(atom.workspaceView.getPaneViews().length).toBe 1
      activatePackage ->
        advanceClock 1001

    it "has text in the message", ->
      expect(starcraftTipsView.message.text()).toBeTruthy()

    it "changes text in the message", ->
      oldText = starcraftTipsView.message.text()

      waits 100
      runs ->
        expect(starcraftTipsView.message.text()).not.toEqual oldText

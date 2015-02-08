# Spec taken from atom/background-tips, https://github.com/atom/background-tips

StarcraftTipsViews = require '../lib/starcraft-tips-view'

describe "StarcraftTips", ->
  [workspaceElement, starcraftTipsViews] = []

  StarcraftTipsViews::DisplayDuration = 5
  StarcraftTipsViews::FadeDuration = 1

  activatePackage = (callback) ->
    waitsForPromise ->
      atom.packages.activatePackage('starcraft-tips').then ({mainModule}) ->
        {starcraftTipsViews} = mainModule

    runs ->
      callback()

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)

  describe "when the package is activated when there is only one pane", ->
    beforeEach ->
      expect(atom.workspace.getPanes().length).toBe 1

    describe "when the pane is empty", ->
      it "attaches the view after a delay", ->
        expect(atom.workspace.getActivePane().getItems().length).toBe 0

        activatePackage ->
          expect(starcraftTipsViews.parentNode).toBeFalsy()
          advanceClock StarcraftTipsViews::StartDelay + 1
          expect(starcraftTipsViews.parentNode).toBeTruthy()

    describe "when the pane is not empty", ->
      it "does not attach the view", ->
        waitsForPromise -> atom.workspace.open()

        activatePackage ->
          advanceClock StarcraftTipsViews::StartDelay + 1
          expect(starcraftTipsViews.parentNode).toBeFalsy()

    describe "when a second pane is created", ->
      it "detaches the view", ->
        activatePackage ->
          advanceClock StarcraftTipsViews::StartDelay + 1
          expect(starcraftTipsViews.parentNode).toBeTruthy()

          atom.workspace.getActivePane().splitRight()
          expect(starcraftTipsViews.parentNode).toBeFalsy()

  describe "when the package is activated when there are multiple panes", ->
    beforeEach ->
      atom.workspace.getActivePane().splitRight()
      expect(atom.workspace.getPanes().length).toBe 2

    it "does not attach the view", ->
      activatePackage ->
        advanceClock StarcraftTipsViews::StartDelay + 1
        expect(starcraftTipsViews.parentNode).toBeFalsy()

    describe "when all but the last pane is destroyed", ->
      it "attaches the view", ->
        activatePackage ->
          atom.workspace.getActivePane().destroy()
          advanceClock StarcraftTipsViews::StartDelay + 1
          expect(starcraftTipsViews.parentNode).toBeTruthy()

          atom.workspace.getActivePane().splitRight()
          expect(starcraftTipsViews.parentNode).toBeFalsy()

          atom.workspace.getActivePane().destroy()
          expect(starcraftTipsViews.parentNode).toBeTruthy()

  describe "when the view is attached", ->
    beforeEach ->
      expect(atom.workspace.getPanes().length).toBe 1

      activatePackage ->
        advanceClock StarcraftTipsViews::StartDelay
        advanceClock StarcraftTipsViews::FadeDuration

    it "has text in the message", ->
      expect(starcraftTipsViews.parentNode).toBeTruthy()
      expect(starcraftTipsViews.message.textContent).toBeTruthy()

    it "changes text in the message", ->
      oldText = starcraftTipsViews.message.textContent
      waits StarcraftTipsViews::DisplayDuration + StarcraftTipsViews::FadeDuration
      runs ->
        advanceClock StarcraftTipsViews::FadeDuration
        expect(starcraftTipsViews.message.textContent).not.toEqual(oldText)

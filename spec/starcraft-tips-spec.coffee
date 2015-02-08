# Spec taken from atom/background-tips, https://github.com/atom/background-tips

StarcraftTipsView = require '../lib/starcraft-tips-view'

describe "StarcraftTips", ->
  [workspaceElement, starcraftTipsView] = []

  StarcraftTipsView::DisplayDuration = 5
  StarcraftTipsView::FadeDuration = 1

  activatePackage = (callback) ->
    waitsForPromise ->
      atom.packages.activatePackage('starcraft-tips').then ({mainModule}) ->
        {starcraftTipsView} = mainModule

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
          expect(starcraftTipsView.parentNode).toBeFalsy()
          advanceClock StarcraftTipsView::StartDelay + 1
          expect(starcraftTipsView.parentNode).toBeTruthy()

    describe "when the pane is not empty", ->
      it "does not attach the view", ->
        waitsForPromise -> atom.workspace.open()

        activatePackage ->
          advanceClock StarcraftTipsView::StartDelay + 1
          expect(starcraftTipsView.parentNode).toBeFalsy()

    describe "when a second pane is created", ->
      it "detaches the view", ->
        activatePackage ->
          advanceClock StarcraftTipsView::StartDelay + 1
          expect(starcraftTipsView.parentNode).toBeTruthy()

          atom.workspace.getActivePane().splitRight()
          expect(starcraftTipsView.parentNode).toBeFalsy()

  describe "when the package is activated when there are multiple panes", ->
    beforeEach ->
      atom.workspace.getActivePane().splitRight()
      expect(atom.workspace.getPanes().length).toBe 2

    it "does not attach the view", ->
      activatePackage ->
        advanceClock StarcraftTipsView::StartDelay + 1
        expect(starcraftTipsView.parentNode).toBeFalsy()

    describe "when all but the last pane is destroyed", ->
      it "attaches the view", ->
        activatePackage ->
          atom.workspace.getActivePane().destroy()
          advanceClock StarcraftTipsView::StartDelay + 1
          expect(starcraftTipsView.parentNode).toBeTruthy()

          atom.workspace.getActivePane().splitRight()
          expect(starcraftTipsView.parentNode).toBeFalsy()

          atom.workspace.getActivePane().destroy()
          expect(starcraftTipsView.parentNode).toBeTruthy()

  describe "when the view is attached", ->
    beforeEach ->
      expect(atom.workspace.getPanes().length).toBe 1

      activatePackage ->
        advanceClock StarcraftTipsView::StartDelay
        advanceClock StarcraftTipsView::FadeDuration

    it "has text in the message", ->
      expect(starcraftTipsView.parentNode).toBeTruthy()
      expect(starcraftTipsView.message.textContent).toBeTruthy()

    it "changes text in the message", ->
      oldText = starcraftTipsView.message.textContent
      waits StarcraftTipsView::DisplayDuration + StarcraftTipsView::FadeDuration
      runs ->
        advanceClock StarcraftTipsView::FadeDuration
        expect(starcraftTipsView.message.textContent).not.toEqual(oldText)

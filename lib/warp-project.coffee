InputDialog = require '@aki77/atom-input-dialog'
{CompositeDisposable} = require 'atom'
os = require 'os'
fs = require 'fs'

module.exports = WarpProject =
  subscriptions: null
  wdContent: null

  activate: (state) ->
    @wdContent = @loadConfigFilePromise()
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'warp-project:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    warpProjectViewState: @dialog.serialize()

  toggle: ->
    @wdContent.then =>
      if !@dialog
        @dialog = new InputDialog({
          callback: this.projectSelected.bind(this),
          detached: () =>
            @dialog = undefined;
        })
        @dialog.attach()

  loadConfigFilePromise: ->
    return new Promise (resolve, reject) =>
      fileName = os.homedir() + "/.warprc"
      fs.readFile fileName, 'utf8', (err, data) =>
        if (err)
          reject(err)

        content = {}
        data.split("\n").forEach (str) =>
          if str
            splitLine = str.split(":")
            content[splitLine.shift()] = splitLine.join(":")
        resolve(content)

  projectSelected: (text) ->
    @wdContent.then (warps) =>
      if warps != undefined && warps[text]
        atom.open({
          pathsToOpen: warps[text],
          newWindow: true
        })

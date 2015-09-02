# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
path = require 'path'
# An example hack to log to the console when each text editor is saved.
#
# atom.workspace.observeTextEditors (editor) ->
#   editor.onDidSave ->
#     console.log "Saved! #{editor.getPath()}"

atom.commands.add 'atom-workspace', 'dot-atom:demo', ->
  console.log "Hello from dot-atom:demo"

# Drafts commands
# meetings
atom.commands.add 'atom-workspace',
  'Drafts:open-meetings': ->
    meetingList = path.join(process.env.HOME, 'Dropbox/Drafts/Meetings.md')
    atom.workspace.open(meetingList)

# todo
atom.commands.add 'atom-workspace',
  'Drafts:open-todo': ->
    meetingList = path.join(process.env.HOME, 'Dropbox/Drafts/Todo.md')
    atom.workspace.open(todoList)

# https://discuss.atom.io/t/close-all-other-panes/9993/9
# Close all *other* panes
atom.commands.add 'atom-workspace',
  'custom:close-panes': ->
    panes = atom.workspace.getPaneItems()
    activePane = atom.workspace.getActivePaneItem()
    for pane in panes
      pane.destroy() if activePane isnt pane

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
  'blackwater park:open-meetings': ->
    meetingList = path.join(process.env.HOME, 'Dropbox/Drafts/Meetings.md')
    if !meetingList?
      alert 'No Meetings Notes! '
    else
      atom.workspace.open(meetingList)


# ideas
atom.commands.add 'atom-workspace',
  'blackwater park:open-ideas': ->
    todoList = path.join(process.env.HOME, 'Dropbox/Drafts/Ideas.md')
    if !todoList?
      alert 'No Ideas! Enjoy your day... '
    else
      atom.workspace.open(todoList)

# https://discuss.atom.io/t/close-all-other-panes/9993/9
# Close all *other* panes
atom.commands.add 'atom-workspace',
  'custom:close-panes': ->
    panes = atom.workspace.getPaneItems()
    activePane = atom.workspace.getActivePaneItem()
    for pane in panes
      pane.destroy() if activePane isnt pane

# backlog
atom.commands.add 'atom-workspace',
  'blackwater park:open-backlog': ->
    todoList = path.join(process.env.HOME, 'Dropbox/ops/backlogs/Backlog.md')
    if !todoList?
      alert 'No Backlog! Something went wrong... '
    else
      atom.workspace.open(todoList)

# release-calendar
atom.commands.add 'atom-workspace',
  'blackwater park:open-release-calendar': ->
    todoList = path.join(process.env.HOME, 'Dropbox/ops/release-calendar.md')
    if !todoList?
      alert 'No Release Calendar! Something went wrong... '
    else
      atom.workspace.open(todoList)

# master taskpaper
atom.commands.add 'atom-workspace',
  'blackwater park:open-master-taskpaper': ->
    taskList = path.join(process.env.HOME, 'Dropbox/ops/master.taskpaper')
    if !taskList?
      alert 'No Master TaskPaper! Something went wrong... '
    else
      atom.workspace.open(taskList)

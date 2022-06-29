from ranger.api.commands import Command
class move_to_icloud_archive(Command):
    """
    :move_to_icloud_archive
    Move file to iCloud archive directory
    """
    def execute(self):
        import shutil # for shutil.copy, os.rename works fine too
        shutil.move(self.fm.thisfile.path, "/Users/krishna/Library/Mobile Documents/com~apple~CloudDocs/Documents/all/Archive/" + self.fm.thisfile.basename)

class move_to_digital_archive(Command):
    """
    :move_to_digital_archive
    Move file to iCloud digitalarchive directory
    """
    def execute(self):
        import shutil # for shutil.copy, os.rename works fine too
        shutil.move(self.fm.thisfile.path, "/Users/krishna/Library/Mobile Documents/com~apple~CloudDocs/Documents/all/Archive/digitalarchive/" + self.fm.thisfile.basename)

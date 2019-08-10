def msgRcv (timestamp, source, groupID, message, attachments):
   contact = signal.getContactName(source)
   if (not contact):
      contact = source
   if (groupID):
      print (contact + ", in group " + signal.getGroupName(groupID) + ": " + message)
   elif(attachments):
      print (attachments)
   else :
      print (contact + ": " + message)
   return

from pydbus import SystemBus
from gi.repository import GLib

bus = SystemBus()
loop = GLib.MainLoop()

signal = bus.get('org.asamk.Signal')
signal.onMessageReceived = msgRcv
#print(signal)
#help(signal)
loop.run()

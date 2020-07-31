def msgRcv (timestamp, source, groupID, message, attachments):
   
   contact = signal.getContactName(source)
   if (not contact):
      if (source):
         contact = source
      else:
         contact = "Unknown"
      
   if (groupID):
      print (contact + ", in group " + signal.getGroupName(groupID) + ": " + message)
   elif(attachments):
      print (attachments)
   else :
      print (contact + ": " + message)
   return

def recRcv(timestamp, source):
   contact = signal.getContactName(source)
   if (not contact):
      if (source):
         contact = source
      else:
         contact = "Unknown"
   
from pydbus import SystemBus
from gi.repository import GLib

bus = SystemBus()
loop = GLib.MainLoop()

signal = bus.get('org.asamk.Signal')
signal.onMessageReceived = msgRcv
signal.onReceiptReceived = recRcv
#print(signal)
#help(signal)
loop.run()

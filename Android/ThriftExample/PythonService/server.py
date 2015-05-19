# -*- coding: utf-8 -*- 
import sys
sys.path.append('service')
import dropbox

from MultiCloudService import *
 
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer
 
import socket

class MultiCloudServiceHandler:
  def __init__(self):
    self.log = {}
    self.client = dropbox.client.DropboxClient("your_access_token")
 
  def ping(self):
    print "ping()"

  def addAccount(self, account):
  	print "addAccount()"
  	return True

  def getUserInfo(self):
  	print "getUserInfo( )"
  	user = UserInfo()
  	user.name = ""
  	user.id = ""
  	user.accounts = []
  	return user

  def createUserByAccount(self, account):
  	print "createUserByToken()"
  	return ""

  def getImagePaths(self):
  	print "getImagePaths()"
  	folder_metadata = self.client.metadata('/')
	names = []
	contents = folder_metadata['contents']
	for f in contents:
		if (f['is_dir'] == False) and ('image' in f['mime_type']):
			names += [f['path']]
	print names
  	return names

  def getAllImages(self):
  	print "getAllImages( )"
  	return []

  def imageByPath(self, path):
  	print "imageByPath( , ", path, ")"
	f = self.client.get_file(path)
  	return f.read()
 
handler = MultiCloudServiceHandler()
processor = Processor(handler)
transport = TSocket.TServerSocket(port='your_port',host="your_host")
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()
 
server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)
 
print "Starting python server..."
server.serve()
print "done!"

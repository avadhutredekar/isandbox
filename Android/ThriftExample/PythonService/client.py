import sys
sys.path.append('service')

from MultiCloudService import *

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol

try:

  # Make socket
  transport = TSocket.TSocket('your_ip', 'your_port')

  # Buffering is critical. Raw sockets are very slow
  transport = TTransport.TBufferedTransport(transport)

  # Wrap in a protocol
  protocol = TBinaryProtocol.TBinaryProtocol(transport)

  # Create a client to use the protocol encoder
  client = Client(protocol)

  # Connect!
  transport.open()

  product = client.ping()
  print 'message'

  # Close!
  transport.close()

except Thrift.TException, tx:
  print '%s' % (tx.message)
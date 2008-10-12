CREATE OR REPLACE FUNCTION golconde.add_queue_static_statement(IN tablename text, IN statement text) RETURNS bool AS
$$
# @summary Golconde Function to insert statement into a queue using a statically defined connect string.  Change it if you need it to connect somewhere else.
# @since 2008-09-15
# @author: Gavin M. Roy <gmr@myyearbook.com>

import stomp

# Statically set MQ Server - Change if you want to use static connections
server = '127.0.0.1'
port = 61613

# Connect to the server
connection = stomp.Connection([(server, port)])
connection.start()
connection.connect()

# Define the queue 
queue = '/queue/Golconde.%s' % tablename

# Send the statement to the queue
connection.send(destination=queue, message=statement)

#Tidy up and return true
connection.disconnect()
return 't';
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION golconde.add_topic_static_statement(IN tablename text, IN statement text) RETURNS bool AS
$$
# @summary Golconde Function to insert statement into a topic using a statically defined connect string.  Change it if you need it to connect somewhere else.
# @since 2008-09-15
# @author: Gavin M. Roy <gmr@myyearbook.com>
import stomp

# Statically set MQ Server - Change if you want to use static connections
server = '127.0.0.1'
port = 61613

# Connect to the server
connection = stomp.Connection([(server, port)])
connection.start()
connection.connect()

# Define the queue 
topic = '/topic/Golconde.%s' % tablename

# Send the statement to the queue
connection.send(destination=topic, message=statement)

#Tidy up and return true
connection.disconnect()

return 't';
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION golconde.add_queue_dynamic_statement(IN tablename text, IN statement text) RETURNS bool AS
$$
# @summary Golconde  Golconde Function to insert statement into a queue using a table stored connect string.
# Renamed from golconde.addstatement(IN statement text)
# @since 2008-08-31
# @author: Gavin M. Roy <gmr@myyearbook.com>

import pyactivemq
from pyactivemq import ActiveMQConnectionFactory

# Get our connection string
result = plpy.execute("SELECT value FROM golconde.settings WHERE setting = 'mqConnectString';");

# Create our factory, connection, session, queue and producer
factory = ActiveMQConnectionFactory(result[0]["value"])
connection = factory.createConnection()
session = connection.createSession()
queue = session.createQueue('Golconde.%s' % tablename)
producer = session.createProducer(queue)

# Create the message and send it
message = session.createTextMessage()
message.text = statement
producer.send(message)

#Tidy up and return true
connection.close()
return 't';
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION golconde.add_topic_dynamic_statement(IN tablename text, IN statement text) RETURNS bool AS
$$
# @summary Golconde  Golconde Function to insert statement into a topic using a table stored connect string.
# @since 2008-09-15
# @author: Gavin M. Roy <gmr@myyearbook.com>

import pyactivemq
from pyactivemq import ActiveMQConnectionFactory

# Get our connection string
result = plpy.execute("SELECT value FROM golconde.settings WHERE setting = 'mqConnectString';");

# Create our factory, connection, session, queue and producer
factory = ActiveMQConnectionFactory(result[0]["value"])
connection = factory.createConnection()
session = connection.createSession()
topic = session.createTopic('Golconde.%s' % tablename)
producer = session.createProducer(topic)

# Create the message and send it
message = session.createTextMessage()
message.text = statement
producer.send(message)

#Tidy up and return true
connection.close()
return 't';
$$ LANGUAGE plpythonu;


import mysql.connector
import base64

connection = mysql.connector.connect(
  host="localhost",
  user="root",
  password="123",
  database="test"
)

mycursor = connection.cursor()

query = "INSERT INTO data25 (name, data) VALUES (%s, %s)"
with open('25mb.epub', 'rb') as testfile:
    testdata = base64.b64encode(testfile.read())
values = ("25mb", testdata)
try:
    mycursor.execute(query, values)
    connection.commit()

except mysql.connector.Error as err:
    print("Something went wrong: {}".format(err))
else:
    print("Inserting 25mb file was successful")
    

query = "INSERT INTO data1 (name, data) VALUES (%s, %s)"
with open('1mb.pdf', 'rb') as testfile:
    testdata = base64.b64encode(testfile.read())
values = ("1mb", testdata)
try:
    mycursor.execute(query, values)
    connection.commit()

except mysql.connector.Error as err:
    print("Something went wrong: {}".format(err))
else:
    print("Inserting 1mb file was successful")


query = "INSERT INTO data0 (name, data) VALUES (%s, %s)"
with open('0mb.txt', 'rb') as testfile:
    testdata = base64.b64encode(testfile.read())
values = ("0mb", testdata)
try:
    mycursor.execute(query, values)
    connection.commit()
except mysql.connector.Error as err:
    print("Something went wrong: {}".format(err))
else:
    print("Inserting 0mb file was successful")

    
query = "INSERT INTO data50 (name, data) VALUES (%s, %s)"
with open('50mb.txt', 'rb') as testfile:
    testdata = base64.b64encode(testfile.read())
values = ("50mb", testdata)
try:
    mycursor.execute(query, values)
    connection.commit()
    connection.close()

except mysql.connector.Error as err:
    print("Something went wrong: {}".format(err))
else:
    print("Inserting 50mb file was successful")

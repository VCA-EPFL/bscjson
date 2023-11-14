import pymongo
import json
import os

client = pymongo.MongoClient("mongodb://localhost:27017/") 

db = client["bsv_values"]
collection = db["json_data"]

fifo_path ='/tmp/data.json'

if os.path.exists(fifo_path):
    os.remove(fifo_path)

try:
    if not os.path.exists(fifo_path):
        os.mkfifo(fifo_path)
        print(f"OK: Named pipe created at {fifo_path}")
except OSError as e:
    print(f"Error: {e}")
    exit(1)

with open(fifo_path, 'r') as pipe_file:
    for line in pipe_file:
        json_data = json.loads(line)
        collection.insert_one(json_data)

client.close()
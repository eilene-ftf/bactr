from hashmap import *
from decode_chunks import *

def event_loop() -> IO(u24):
  with IO:
    # read chunk from file
    stream <- IO/FS/read_file("/tmp/api_outbox")
    # decode to chunk
    chunk = chunk_from_stream(stream)
    # match on chunk
    # retrieve associated function
    # call function, it returns a new chunk
    # write chunk to /tmp/api_inbox
    return event_loop()

def main() -> IO(u24):
  with IO:
    * <- event_loop()
    return wrap(0)

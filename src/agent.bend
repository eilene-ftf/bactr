from hashmap import *
from decode_chunks import *
from matching import *

# a chunk is of type HashMap(u24, u24)

############### MATCHING RULES
# Matching rules should return Maybe(String) where the string is the key bound to your function
# Template:
#{
def rule_a(chunk:HashMap(u24, u24)) -> Maybe(String):
  # do something with the hash
  # if you want to return a value, return Maybe/Some(value)
  return Maybe/None
#}

############### PRODUCTIONS
# All productions should return a chunk
# Template:
#{
def production_a(chunk:HashMap(u24, u24)) -> HashMap(u24, u24):
  # Do something here
  return chunk
#}

def event_loop() -> IO(u24):
  ###### DECLARE PRODUCTIONS HERE
  pairs = [] # declare your productions (tuple of key-value pairs, where the value is a function)
  rules = [] # declare your matching rules, just a list of functions
  ###### END PRODUCTION DECLARATION
  productions = HashMap/from_string_keys(pairs)
  with IO:
    # read chunk from file
    stream <- IO/FS/read_file("/tmp/api_outbox")
    # decode to chunk
    chunk = chunk_from_stream(stream)
    # match on chunk
    results = match_all(chunk, rules)
    # matches is a list, we need to consolidate to a single value
    (matches, len) = consolidate(results)
    key <- select(matches, len) # this is a Maybe(String)
    # retrieve associated function
    production = retrieve(key, productions)
    # call function, it returns a new chunk
    update = (production)(chunk)
    # write chunk to /tmp/api_inbox
    * <- IO/FS/write_file("/tmp/api_inbox", String/encode_utf8(encode_chunk(update)))
    return event_loop()

def main() -> IO(u24):
  with IO:
    * <- event_loop()
    return wrap(0)

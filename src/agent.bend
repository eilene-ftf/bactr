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
#

# matching rules should return Maybe/Some with a key when they match, and otherwise Maybe/None
def when_to_go(hm:HashMap(u24, u24)) -> Maybe(String):
  if HashMap/get("example_slot", hm) > 10:
    return Maybe/Some("WALK")
  else:
    return Maybe/None

# These are defined as to be exhaustive and mutually exclusive, it's a little cumbersome but it makes the production logic cleanerdef when_to_stop(hm:HashMap(u24, u24)) -> Maybe(String)):
def when_to_stop(hm:HashMap(u24, u24)) -> Maybe(String):
  if HashMap/get("example_slot", hm) <= 10:
    return Maybe/Some("STOP")
  else:
    return Maybe/None

############### PRODUCTIONS
# All productions should return a chunk
# Template:
#{
def production_a(chunk:HashMap(u24, u24)) -> HashMap(u24, u24):
  # write some production here
#}
#

def default(hm:HashMap(u24, u24)) -> HashMap(u24, u24):
  open HashMap: hm
  return build_svc([("step_len", 3),("lateral", 0),("yaw", 0),("velocity", 10),("go_stop", 1)])

def event_loop(productions:HashMap(u24, (HashMap(u24, u24) -> HashMap(u24, u24))), rules:List((HashMap(u24, u24)) -> Maybe(String))) -> IO(u24):
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
    return event_loop(productions, rules)

def main() -> IO(u24):
  productions = [("WALK", default)] # declare your productions (tuple of key-value pairs, where the value is a function)
  rules = [when_to_go, when_to_stop] # declare your matching rules, just a list of functions
  with IO:
    * <- event_loop(build_svc(productions), rules)
    return wrap(0)

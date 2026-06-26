object HashMap(u24, U) { keys: List(List(u24)), map: Map(U) }

def HashMap/new(pairs: List((List(u24), U))) -> HashMap(u24, U):
  (k, m) = HashMap/build(pairs, [], {})
  return HashMap { keys: k, map: m}

def HashMap/build(pairs: List((List(u24), U)), keys:List(List(u24)), map: Map(U)) -> (List(List(u24)), Map(U)):
  match pairs:
    case List/Cons:
      (k, v) = pairs.head
      return HashMap/build(pairs.tail, List/Cons(k, keys), Map/set(map, HashMap/hash(k), v))
    case List/Nil:
      return (keys, map)

def HashMap/get_check(key: List(u24), hashmap: HashMap(u24, U)) -> (HashMap(u24, U), Maybe(U)):
  open HashMap: hashmap
  (result, new_map) = Map/get_check(hashmap.map, HashMap/hash(key))
  return (HashMap { keys: hashmap.keys, map: new_map }, result)

def HashMap/get(key: List(u24), hashmap: HashMap(u24, U)) -> U:
  (new_hm, result) = HashMap/get_check(key, hashmap)
  return Maybe/unwrap(result)

def HashMap/hash_steps(l:List(u24), hash:u24, prime:u24) -> u24:
  match l:
    case List/Cons:
      return HashMap/hash_steps(l.tail, (l.head ^ hash) * prime, prime)
    case List/Nil:
      return hash

def HashMap/hash(l:List(u24)) -> u24:
  basis = 0x1c9dc5
  prime = 0x000193
  return HashMap/hash_steps(l, basis, prime)
  
def address ():
  return "test.txt"

def float():
  return 0.5

def loop():
  with IO:
    op <- IO/FS/open(address, "r+")
    outputlist <- IO/FS/read_file(address)
    * <- IO/print((String/decode_utf8(outputlist)))
    * <- IO/print("\n")
    * <- IO/FS/write_file(address,float)
    * <- IO/FS/close(Result/unwrap(op))
    * <- IO/print (u24/to_string(f24/to_u24(outputlist)))
    return wrap(0) 

def main ():
  fiveal = HashMap/new ([("a", 1),("b", 2),("c", 3),("d",4),("e", 5)])
  intscrap = HashMap/new ([([1,1],10),([1,2],20),([1,3],30)])
  #return hash2string (intscrap, 1) 
  return loop
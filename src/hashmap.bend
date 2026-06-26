object HashMap(u24, U) { keys: List(List(u24)), map: Map(U) }

def HashMap/from_string_keys(pairs:List((String, U))) -> HashMap(u24, U):
  return HashMap/new(HashMap/from_string_keys.go(pairs))
  
def HashMap/from_string_keys.go(pairs:List((String, U))) -> List((List(u24), U)):
  match pairs:
    case List/Cons:
      (key, value) = pairs.head
      return List/Cons((String/encode_utf8(key), value), HashMap/from_string_keys.go(pairs.tail))
    case List/Nil:
      return []

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
  match result:
    case Maybe/Some:
      return result.value
    case None:
      return unreachable()

def HashMap/get_string(key: String, hashmap: HashMap(u24, U)) -> U:
  return HashMap/get(String/encode_utf8(key), hashmap)

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


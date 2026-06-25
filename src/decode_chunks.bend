from hashmap import *

strip(s:String): (String)
strip(String/Cons 10 xs) = String/Nil
strip(String/Cons x xs) = (String/Cons x (strip xs))
strip(String/Nil) = String/Nil

def String/to_u24(s: String) -> u24:
  fold s with acc=0:
    case String/Nil:
      return acc
    case String/Cons:
      return s.tail((acc * 10) + (s.head - '0'))

def encode_digits(x:u24) -> List(u24):
  if x > 0:
    return List/Cons((x % 10) + '0', encode_digits(x / 10))
  else:
    return []

def String/from_u24(x:u24) -> String:
  return String/decode_utf8(List/reverse(encode_digits(x)))

def build_svc(s:String) -> HashMap(u24, u24):
  return HashMap/new(make_pairs(s))

def make_pairs(s:String) -> List((List(u24), u24)):
  chunk = String/split(s, ' ')
  fold chunk with pairs = []:
    case List/Nil:
      return pairs
    case List/Cons:
      pair_str = String/split(chunk.head, ':')
      match pair_str:
        case List/Cons:
          match pair_str.tail:
            case List/Cons:
              pair = (String/encode_utf8(pair_str.tail.head), String/to_u24(pair_str.head))
            case List/Nil:
              pair = (String/encode_utf8(""), String/to_u24(pair_str.head))
        case List/Nil:
          pair = (String/encode_utf8(""), String/to_u24(""))
              
      return chunk.tail(List/Cons(pair, pairs))

def encode_chunk(hashmap:HashMap(u24, u24)) -> String:
  open HashMap: hashmap
  bytes = encode_chunk.go(hashmap.keys, hashmap.map)
  return String/decode_utf8(List/concat(bytes, ['\n']))

def encode_chunk.go(keys: List(List(u24)), map: Map(u24)) -> List(u24):
  (acc, *) = encode_chunk.go.fold(keys, [], map)
  return acc

def encode_chunk.go.fold(keys: List(List(u24)), acc: List(u24), map: Map(u24)) -> (List(u24), Map(u24)):
  match keys:
    case List/Nil:
      return (acc, map)
    case List/Cons:
      key = keys.head
      h = HashMap/hash(key)
      (value, *) = Map/get(map, h)
      sv = List/concat(key, List/concat([':'], List/reverse(encode_digits(value))))
      return encode_chunk.go.fold(keys.tail, List/concat(acc, List/concat(sv, [' '])), map)

def print_pairs(strings:List((List(u24), u24))) -> IO(u24):
  with IO:
    match strings:
      case List/Cons:
        (l, r) = strings.head
        * <- IO/print(String/decode_utf8(l))
        * <- IO/print("::")
        * <- IO/print(String/from_u24(r))
        * <- IO/print("\n")
        return print_pairs(strings.tail)
      case List/Nil:
        return wrap(0)

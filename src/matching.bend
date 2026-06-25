from hashmap import *

def retrieve(key: Maybe(String), productions: HashMap(u24, (HashMap(u24, u24) -> HashMap(u24, u24)))) -> (HashMap(u24, u24) -> HashMap(u24, u24)):
  match key:
    case Maybe/Some:
      return HashMap/get(String/encode_utf8(key.value), productions)
    case Maybe/None:
      return (lambda chunk: HashMap/new([]))
  

def match_all(chunk: HashMap(u24, u24), rules:List((HashMap(u24, u24) -> Maybe(String)))) -> List(Maybe(String)):
  match rules:
    case List/Nil:
      return []
    case List/Cons:
      return List/Cons((rules.head)(chunk), match_all(chunk, rules.tail))

def consolidate(results:List(Maybe(String))) -> (List(Maybe(String)), u24):
  return consolidate.go((results, 0, []))

def consolidate.go(res: (List(Maybe(String)), u24, List(Maybe(String)))) -> (List(Maybe(String)), u24):
  (results, len, acc) = res
  match results:
    case List/Nil:
      return (acc, len)
    case List/Cons:
      match results.head:
        case Maybe/None:
          return consolidate.go((results.tail, len, acc))
        case Maybe/Some:
          return consolidate.go((results.tail, len + 1, List/Cons(results.head, acc)))

def select(results:List(Maybe(String)), len:u24) -> IO(Maybe(String)):
  with IO:
    rand <- IO/random_u24()
    match rand:
      case Result/Ok:
        i = rand.val
        return wrap(select.go(results, len, i))
      case Result/Err:
        i = 0
        return wrap(select.go(results, len, i))

def select.go(results:List(Maybe(String)), len:u24, i:u24) -> Maybe(String):
  match results:
    case List/Cons:
      if len >= i:
        return results.head
      else:
        return select.go(results.tail, (len - 1), i)
    case List/Nil:
      return Maybe/None

def IO/random_u24() -> IO(Result(u24, u24)):
  with IO:
    res_fd <- IO/FS/open("/dev/random", "r")
    match res_fd:
      case Result/Ok:
        fd = res_fd.val
        res_bytes <- IO/FS/read(fd, 3)
        * <- IO/FS/close(fd)
        match res_bytes:
          case Result/Ok:
            bytes = res_bytes.val
            return wrap(Result/Ok(bytes_to_u24(bytes)))
          case Result/Err:
            return wrap(Result/Err(res_bytes.val))
      case Result/Err:
        return wrap(Result/Err(res_fd.val))

def bytes_to_u24(bytes: List(u24)) -> u24:
  match bytes:
    case List/Cons:
      b0 = bytes.head
      match bytes.tail:
        case List/Cons:
          b1 = bytes.tail.head
          match bytes.tail.tail:
            case List/Cons:
              b2 = bytes.tail.tail.head
              return (b0 * 65536) + (b1 * 256) + b2
            case List/Nil:
              return 0
        case List/Nil:
          return 0
    case List/Nil:
      return 0

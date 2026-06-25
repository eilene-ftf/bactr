def event_loop() -> IO(u24):
  with IO:
    return event_loop()

def main() -> IO(u24):
  with IO:
    * <- event_loop()
    return wrap(0)

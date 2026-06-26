# spot_strafe.bend
# Run: bend run spot_strafe.bend
# Requires API_server_d.py and API_client_d.py running first.

def emit(cmd: String, ticks: u24) -> IO(u24):
  if ticks == 0:
    with IO:
      return wrap(0)
  else:
    with IO:
      * <- IO/FS/write_file("/tmp/api_inbox", String/encode_utf8(cmd))
      return emit(cmd, ticks - 1)

def strafe_left(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:0 lateral_fraction:1000 step_velocity:600\n", ticks)

def strafe_right(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:0 lateral_fraction:-1000 step_velocity:600\n", ticks)

def strafe() -> IO(u24):
  with IO:
    * <- strafe_left(180)
    * <- strafe_right(180)
    return strafe()

def main() -> IO(u24):
  return strafe()

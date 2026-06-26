# spot_dance.bend
# Run: bend run spot_dance.bend
# Requires API_server_d.py and API_client_d.py running first.

def emit(cmd: String, ticks: u24) -> IO(u24):
  if ticks == 0:
    with IO:
      return wrap(0)
  else:
    with IO:
      * <- IO/FS/write_file("/tmp/api_inbox", String/encode_utf8(cmd))
      return emit(cmd, ticks - 1)

def move_forward(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:60 step_velocity:600\n", ticks)

def spin_left(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:0 yaw_rate:900 step_velocity:600\n", ticks)

def spin_right(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:0 yaw_rate:-900 step_velocity:600\n", ticks)

def strafe_left(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:0 lateral_fraction:1000 step_velocity:600\n", ticks)

def strafe_right(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:0 lateral_fraction:-1000 step_velocity:600\n", ticks)

def circle_left(ticks: u24) -> IO(u24):
  return emit("go:1 step_length:50 yaw_rate:500 step_velocity:600\n", ticks)

def pause(ticks: u24) -> IO(u24):
  return emit("go:0\n", ticks)

def dance() -> IO(u24):
  with IO:
    * <- move_forward(150)
    * <- spin_left(150)
    * <- spin_right(150)
    * <- strafe_left(150)
    * <- strafe_right(150)
    * <- circle_left(300)
    * <- pause(80)
    return dance()

def main() -> IO(u24):
  return dance()

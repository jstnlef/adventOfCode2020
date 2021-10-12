use "debug"
use "files"


actor Main
  new create(env: Env) =>
    let instructions = try
      parse_input(env.root as AmbientAuth)
    else
      env.err.print("Unable to parse input!")
      return
    end

    try
      let boat = DirectMovementBoat
      boat.perform(instructions)?
      env.out.print("Manhattan distance of DirectMovementBoat: " + boat.position().manhattan_distance().string())
    else
      env.err.print("Error running DirectMovementBoat simulation")
    end

    try
      let waypoint_boat = WaypointBoat
      waypoint_boat.perform(instructions)?
      env.out.print("Manhattan distance of WaypointBoat: " + waypoint_boat.position().manhattan_distance().string())
    else
      env.err.print("Error running WaypointBoat simulation")
    end

  fun parse_input(auth: AmbientAuth): Array[Instruction] =>
    let instructions = Array[Instruction](760)
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        instructions.push(Instruction(consume line))
      end
    end
    instructions


class Instruction
  let itype: String
  let value: ISize

  new create(line: String iso) =>
    (let itype_s, let value_s) = (consume line).chop(1)
    itype = consume itype_s
    value = try
      (consume value_s).isize()?
    else
      0
    end


class WaypointBoat is Boat
  var waypoint: Vector = Vector(10, 1)
  var my_pos: Vector = Vector(0, 0)

  new create() => None

  fun position(): this->Vector => my_pos

  fun ref _process_direction(dir_or_forward: (Direction | Forward), amount: ISize) =>
    match dir_or_forward
      | let dir: Forward => my_pos = my_pos + (waypoint * amount)
      | let dir: Direction => waypoint = waypoint + (dir.unit_vec() * amount)
    end

  fun ref _process_rotation(degrees: ISize)? =>
    waypoint = match degrees
      | 0 => Vector(waypoint.x, waypoint.y)
      | 90 | -270 => Vector(waypoint.y, -waypoint.x)
      | 180 | -180 => Vector(-waypoint.x, -waypoint.y)
      | 270 | -90 => Vector(-waypoint.y, waypoint.x)
      else error
    end

  fun string(): String =>
    "Boat(pos: " + position().string() + ", waypoint: " + waypoint.string() + ")"


class DirectMovementBoat is Boat
  let max_degrees: ISize = 360

  var my_pos: Vector = Vector(0, 0)
  var my_dir: Direction = East

  new create() => None

  fun position(): this->Vector => my_pos

  fun direction(): Direction => my_dir

  fun ref _process_direction(dir_or_forward: (Direction | Forward), amount: ISize) =>
    let dir = match dir_or_forward
      | Forward => my_dir
      | let d: Direction => d
    end

    my_pos = my_pos + (dir.unit_vec() * amount)

  fun ref _process_rotation(degrees: ISize)? =>
    // XXX: Ew. Really wish this worked more like python's mod
    let new_dir = (((direction().degrees() + degrees) % max_degrees) + max_degrees) % max_degrees
    my_dir = match new_dir
      | 0 => East
      | 90 => South
      | 180 => West
      | 270 => North
      else
        Debug.out("Direction not covered...")
        error
    end

  fun string(): String =>
    "Boat(pos: " + position().string() + ", dir: " + direction().string() + ")"


trait Boat
  fun ref perform(instructions: Seq[Instruction])? =>
    for instruction in instructions.values() do
      this(instruction)?
    end

  fun ref apply(instruction: Instruction)? =>
    match instruction.itype
      | "N" => _process_direction(North, instruction.value)
      | "S" => _process_direction(South, instruction.value)
      | "E" => _process_direction(East, instruction.value)
      | "W" => _process_direction(West, instruction.value)
      | "L" => _process_rotation(-instruction.value)?
      | "R" => _process_rotation(instruction.value)?
      | "F" => _process_direction(Forward, instruction.value)
    end

  fun position(): this->Vector

  fun ref _process_direction(dir: (Direction | Forward), amount: ISize)

  fun ref _process_rotation(degrees: ISize)?


primitive Forward

primitive North
  fun degrees(): ISize => 270
  fun string(): String => "North"
  fun unit_vec(): Vector => Vector(0, 1)

primitive South
  fun degrees(): ISize => 90
  fun string(): String => "South"
  fun unit_vec(): Vector => Vector(0, -1)

primitive East
  fun degrees(): ISize => 0
  fun string(): String => "East"
  fun unit_vec(): Vector => Vector(1, 0)

primitive West
  fun degrees(): ISize => 180
  fun string(): String => "West"
  fun unit_vec(): Vector => Vector(-1, 0)

type Direction is (North | South | East | West)


class Vector
  let x: ISize
  let y: ISize

  new create(_x: ISize, _y: ISize) =>
    x = _x
    y = _y

  fun add(other: Vector): Vector =>
    Vector(x + other.x, y + other.y)

  fun mul(other: ISize): Vector =>
    Vector(x * other, y * other)

  fun manhattan_distance(): USize =>
    x.abs() + y.abs()

  fun string(): String =>
    "Vector(" + x.string() + ", " + y.string() + ")"


use "debug"
use "files"


actor Main
  new create(env: Env) =>
    try
      let instructions = parse_input(env.root as AmbientAuth)
      let boat = Boat
      Debug.out("0 " + boat.string())
      var i: USize = 1
      for instruction in instructions.values() do
        boat(instruction)?
        Debug.out(i.string() + " " + boat.string())
        i = i + 1
      end
      env.out.print("Manhattan distance: " + boat.position.manhattan_distance().string())
    end

  fun parse_input(auth: AmbientAuth): Array[Instruction] =>
    let instructions = Array[Instruction](760)
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          instructions.push(Instruction(consume line))
        end
      end
      instructions
    else
      instructions
    end


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


class Boat
  var position: Vector = Vector(0, 0)
  var direction: Direction = East

  new create() =>
    None

  fun ref apply(instruction: Instruction)? =>
    match instruction.itype
      | "N" => _move(North, instruction.value)
      | "S" => _move(South, instruction.value)
      | "E" => _move(East, instruction.value)
      | "W" => _move(West, instruction.value)
      | "L" => _turn(-instruction.value)?
      | "R" => _turn(instruction.value)?
      | "F" => _move(direction, instruction.value)
    end

  fun ref _move(dir: Direction, amount: ISize) =>
    position = match dir
      | North => position + (Vector(0, 1) * amount)
      | South => position + (Vector(0, -1) * amount)
      | East => position + (Vector(1, 0) * amount)
      | West => position + (Vector(-1, 0) * amount)
    end

  fun ref _turn(degrees: ISize)? =>
    let max_degrees: ISize = 360
    let new_dir = (((direction.degrees() + degrees) % max_degrees) + max_degrees) % max_degrees
    direction = match new_dir
      | 0 => East
      | 90 => South
      | 180 => West
      | 270 => North
      else
        Debug.out("Direction not covered...")
        error
    end

  fun string(): String =>
    "Boat(pos: " + position.string() + ", dir: " + direction.string() + ")"


primitive North
  fun degrees(): ISize => 270
  fun string(): String => "North"
primitive South
  fun degrees(): ISize => 90
  fun string(): String => "South"
primitive East
  fun degrees(): ISize => 0
  fun string(): String => "East"
primitive West
  fun degrees(): ISize => 180
  fun string(): String => "West"

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


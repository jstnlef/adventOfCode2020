use "collections"
use "debug"
use "files"
use "itertools"


actor Main
  new create(env: Env) =>
    try
      let input = parse_input(env.root as AmbientAuth)
      let seat_ids = Iter[SeatAssignment](input.values())
        .map[USize]({ (assignment) => assignment.seat_id() })
        .collect(Array[USize](input.size()))

      let sorted = Sort[Array[USize], USize](seat_ids)

      var max = find_max_assignment(sorted)?
      env.out.print("Max: " + max.string())

      var my_seat = find_my_seat(sorted)?
      env.out.print("My Seat: " + my_seat.string())
    end

  fun parse_input(auth: AmbientAuth): Array[SeatAssignment] =>
    let input = Array[SeatAssignment]
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        input.push(SeatAssignment(consume line))
      end
    end
    input

  fun find_max_assignment(sorted_input: Array[USize]): USize? =>
    sorted_input(sorted_input.size() - 1)?

  fun find_my_seat(sorted_input: Array[USize]): USize? =>
    var expected_seat: USize = sorted_input(0)?
    for seat_id in sorted_input.values() do
      if seat_id != expected_seat then
        break
      end
      expected_seat = expected_seat + 1
    end
    expected_seat


class SeatAssignment
  let _max_seats: USize = 8
  let row: USize
  let seat: USize

  new create(line: String iso) =>
    (let row_encoding, let seat_encoding) = (consume line).chop(7)
    row = _calc_row(consume row_encoding)
    seat = _calc_seat(consume seat_encoding)

  fun seat_id(): USize => (row * _max_seats) + seat

  fun tag _calc_row(encoded: String iso): USize =>
    var low: USize = 0
    var high: USize = 127

    for char in (consume encoded).iso_array().values() do
      match char
        | 66 => low = (low + ((high - low) / 2)) + 1
        | 70 => high = (high - ((high - low) / 2)) - 1
      end
    end
    high

  fun tag _calc_seat(encoded: String iso): USize =>
    var low: USize = 0
    var high: USize = 7

    for char in (consume encoded).iso_array().values() do
      match char
        | 82 => low = (low + ((high - low) / 2)) + 1
        | 76 => high = (high - ((high - low) / 2)) - 1
      end
    end
    high


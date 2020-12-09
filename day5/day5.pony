use "debug"
use "files"
use "itertools"


actor Main
  new create(env: Env) =>
    try
      let input = parse_input(env.root as AmbientAuth)

      var max: USize = 0
      for assignment in input.values() do
        let seat_id = assignment.seat_id()
        if seat_id > max then
          max = seat_id
        end
      end

      env.out.print(max.string())
    end

  fun parse_input(auth: AmbientAuth): Array[SeatAssignment] =>
    let input = Array[SeatAssignment]
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          input.push(SeatAssignment(consume line))
        end
      end
      input
    else
      input
    end


class SeatAssignment
  let _max_rows: USize = 128
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


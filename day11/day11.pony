use "collections"
use "debug"
use "files"


actor Main
  new create(env: Env) =>
    try
      let waiting_area = parse_input(env.root as AmbientAuth)
      waiting_area.simulate_until_stable()

      env.out.print("Occupied seats: " + waiting_area.count_occupied_seats().string())
    end

  fun parse_input(auth: AmbientAuth): WaitingArea =>
    let waiting_area = WaitingArea
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          waiting_area.add_row(consume line)
        end
      end
      waiting_area
    else
      waiting_area
    end


class WaitingArea
  var inner: Array[Array[SeatState]] = Array[Array[SeatState]](91)
  var stable: Bool = false

  fun ref add_row(line: String) =>
    let row = Array[SeatState](line.size())
    for c in StringBytes(consume line) do
      let state = match c
        | 76 => Empty
        | 35 => Occupied
        else Floor
      end
      row.push(state)
    end
    inner.push(row)

  fun ref simulate_until_stable() =>
    while not stable do
      _run_next_step()
    end

  fun count_occupied_seats(): USize =>
    var count: USize = 0
    for row in inner.values() do
      for seat in row.values() do
        match seat
          | Occupied => count = count + 1
        end
      end
    end
    count

  fun ref _run_next_step() =>
    let future = clone_seats(inner)
    try
      for i in Range(0, inner.size()) do
        let row = inner(i)?
        for j in Range(0, row.size()) do
          let seat = row(j)?
          let num_occupied = _count_occupied_neighbors(i, j)

          // Apply rules
          let updated = match seat
            | let s: Empty if num_occupied == 0 => Occupied
            | let s: Occupied if num_occupied >= 4 => Empty
            else seat
          end

          future(i)?.update(j, updated)?
        end
      end

      _check_if_future_is_equal(future)?
      inner = future
    end

  fun _count_occupied_neighbors(i: USize, j: USize): USize =>
    var count: USize = 0

    for l in Range[ISize](-1, 2) do
      for m in Range[ISize](-1, 2) do
        if (l == 0) and (m == 0) then
          continue
        end
        try
          let neighbor = inner(i + l.usize())?(j + m.usize())?
          match neighbor
            | let n: Occupied => count = count + 1
          end
        end
      end
    end

    count

  fun ref _check_if_future_is_equal(future: Array[Array[SeatState]])? =>
    for i in Range(0, future.size()) do
      let row = inner(i)?
      for j in Range(0, row.size()) do
        let seat = row(j)?
        let future_seat = future(i)?(j)?
        if seat != future_seat then
          return
        end
      end
    end
    // If we're here, they must be equal!
    stable = true

  fun clone_seats(seats: Array[Array[SeatState]]): Array[Array[SeatState]] =>
    let new_seats = Array[Array[SeatState]](seats.size())
    for row in seats.values() do
      new_seats.push(row.clone())
    end
    new_seats


primitive Floor is Equatable[SeatState]
  fun string(): String => "Floor"
primitive Empty is Equatable[SeatState]
  fun string(): String => "Empty"
primitive Occupied is Equatable[SeatState]
  fun string(): String => "Occupied"

type SeatState is (Floor | Empty | Occupied)

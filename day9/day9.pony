use "collections"
use "debug"
use "files"

actor Main
  new create(env: Env) =>
    try
      let input = parse_input(env.root as AmbientAuth)

      let first_invalid = XMAS.find_first_invalid(input)
      env.out.print(first_invalid.string())
    end

  fun parse_input(auth: AmbientAuth): Array[USize] =>
    let input = Array[USize]
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          input.push((consume line).usize()?)
        end
      end
      input
    else
      input
    end

primitive XMAS
  fun find_first_invalid(numbers: Array[USize], preamble_size: USize = 25): USize =>
    var lower: USize = 0
    var higher: USize = preamble_size
    for (i, number) in numbers.pairs() do
      // First number shoud be at index "preamble_size"
      if i < higher then
        continue
      end

      if not _number_is_valid(numbers, number, lower, higher) then
        return number
      end

      // Slide the window up by 1 each
      lower = lower + 1
      higher = higher + 1
    end
    0

  fun _number_is_valid(
    numbers: Array[USize],
    number: USize,
    lower_index: USize,
    higher_index: USize
  ): Bool =>
    Debug.out("Checking " + number.string() + " is valid. Window: [" + lower_index.string() + "-" + higher_index.string() + "]")
    try
      for i in Range(lower_index, higher_index) do
        for j in Range(i, higher_index) do
          let n1 = numbers(i)?
          let n2 = numbers(j)?
          if (i == j) or (n1 == n2) then
            continue
          end
          if (n1 + n2) == number then
            return true
          end
        end
      end
    end
    false

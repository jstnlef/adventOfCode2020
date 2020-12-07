use "collections"
use "files"
use "itertools"

actor Main
  new create(env: Env) =>
    try
      let input = parse_input(env.root as AmbientAuth)
      let num_valid = Iter[PasswordRequirements](input.values())
        // .filter({ (req) => req.part1_is_valid() })
        .filter({ (req) => req.part2_is_valid() })
        .count()
      env.out.print(num_valid.string())
    end

  fun parse_input(auth: AmbientAuth): Array[PasswordRequirements] =>
    let input_array = Array[PasswordRequirements]()
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          input_array.push(PasswordRequirements(consume line))
        end
      end
      input_array
    else
      input_array
    end


class PasswordRequirements
  let min: USize
  let max: USize
  let char: String
  let password: String

  new create(line: String) =>
    // XXX: Gross parsing code
    let split_line = line.split(" ")

    (min, max) = try
      let range_s = split_line(0)?
      let split_range = range_s.split("-")
      (split_range(0)?.usize()?, split_range(1)?.usize()?)
    else
      (0, 1)
    end

    char = try
      let char_s = split_line(1)?
      char_s.substring(0, 1)
    else
      ""
    end

    password = try
      split_line(2)?.trim()
    else
      ""
    end

  fun part1_is_valid(): Bool =>
    let num_chars = password.count(char)
    (min <= num_chars) and (num_chars <= max)

  fun part2_is_valid(): Bool =>
    let char1 = password.substring(min.isize() - 1, min.isize())
    let char2 = password.substring(max.isize() - 1, max.isize())

    (char1 == char) xor (char2 == char)




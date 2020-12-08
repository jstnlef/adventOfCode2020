use "files"
use "itertools"
use "regex"


actor Main
  new create(env: Env) =>
    try
      let input = parse_passports(env.root as AmbientAuth)
      let num_valid = Iter[Passport](input.values())
        .filter({ (req) => req.part2_is_valid() })
        .count()
      env.out.print(num_valid.string())
    end

  fun parse_passports(auth: AmbientAuth): Array[Passport] =>
    let passports = Array[Passport]
    try
      let path = FilePath(auth, "input.txt")?
      var buffer = ""
      with file = File(path) do
        for line in file.lines() do
          if line == "" then
            passports.push(Passport(buffer.clone()))
            buffer = ""
          else
            buffer = buffer + " " + consume line
          end
        else
          // Ensure that whatever is left in the buffer is parsed as a passport
          let passport = Passport(buffer.clone())
          passports.push(Passport(buffer.clone()))
          buffer = ""
        end
      end
      passports
    else
      passports
    end


class Passport
  var byr: (String | None) = None
  var iyr: (String | None) = None
  var eyr: (String | None) = None
  var hgt: (String | None) = None
  var hcl: (String | None) = None
  var ecl: (String | None) = None
  var pid: (String | None) = None
  var cid: (String | None) = None

  new create(passport_data: String iso) =>
    let split_data = passport_data.split(" ")
    for prop in (consume split_data).values() do
      try
        let key_and_val = prop.split(":")
        let key = key_and_val(0)?
        let value = key_and_val(1)?
        match key
         | "byr" => byr = value
         | "iyr" => iyr = value
         | "eyr" => eyr = value
         | "hgt" => hgt = value
         | "hcl" => hcl = value
         | "ecl" => ecl = value
         | "pid" => pid = value
         | "cid" => cid = value
        end
      end
    end

  fun part1_is_valid(): Bool =>
    // cid is optional here
    (
      (byr isnt None) and
      (iyr isnt None) and
      (eyr isnt None) and
      (hgt isnt None) and
      (hcl isnt None) and
      (ecl isnt None) and
      (pid isnt None)
    )

  fun part2_is_valid(): Bool =>
    (
      validate_byr() and
      validate_iyr() and
      validate_eyr() and
      validate_hgt() and
      validate_hcl() and
      validate_ecl() and
      validate_pid()
    )

  fun validate_hgt(): Bool =>
    match hgt
      | None => false
      | let s: String =>
        try
          let r = Regex("^(\\d+)(cm|in)$")?
          let matched = r(s)?
          let n = matched(1)?.usize()?
          let unit = matched(2)?
          match (consume unit)
            | "cm" => (150 <= n) and (n <= 193)
            | "in" => (59 <= n) and (n <= 76)
            else false
          end
        else
          false
        end
    end

  fun validate_hcl(): Bool =>
    _validate_regex(hcl, "^#[0-9a-fA-F]{6}$")

  fun validate_ecl(): Bool =>
    _validate_regex(ecl, "^(amb|blu|brn|gry|grn|hzl|oth)$")

  fun validate_pid(): Bool =>
    _validate_regex(pid, "^\\d{9}$")

  fun _validate_regex(prop: (String | None), regex: String): Bool =>
    match prop
      | None => false
      | let s: String =>
        try
          let r = Regex(regex)?
          r == s
        else
          false
        end
    end

  fun validate_byr(): Bool =>
    _validate_year(byr, 1920, 2002)

  fun validate_iyr(): Bool =>
    _validate_year(iyr, 2010, 2020)

  fun validate_eyr(): Bool =>
    _validate_year(eyr, 2020, 2030)

  fun _validate_year(prop: (String | None), min: USize, max: USize): Bool =>
    match prop
     | None => false
     | let s: String =>
      try
        let n = s.usize()?
        (min <= n) and (n <= max)
      else
        false
      end
    end

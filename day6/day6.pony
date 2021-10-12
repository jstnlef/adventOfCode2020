use "collections"
use "debug"
use "files"
use "itertools"

actor Main
  new create(env: Env) =>
    try
      let input = parse_groups(env.root as AmbientAuth)

      env.out.print("Any answered yes: " + any_answered_yes(input)?.string())
      env.out.print("All answered yes: " + all_answered_yes(input)?.string())
    end

  fun any_answered_yes(groups: Array[Group]): USize? =>
    var sum: USize = 0
    for group in groups.values() do
      sum = sum + group.union_of_yes()?
    end
    sum

  fun all_answered_yes(groups: Array[Group]): USize? =>
    var sum: USize = 0
    for group in groups.values() do
      sum = sum + group.intersection_of_yes()?
    end
    sum

  fun parse_groups(auth: AmbientAuth): Array[Group] =>
    let groups = Array[Group]
    let path = FilePath(auth, "input.txt")
    var buffer = ""
    with file = File(path) do
      for line in file.lines() do
        if line == "" then
          groups.push(Group(buffer.clone()))
          buffer = ""
        else
          buffer = buffer + "\n" + consume line
        end
      else
        // Ensure that whatever is left in the buffer is parsed as a passport
        let group = Group(buffer.clone())
        groups.push(Group(buffer.clone()))
        buffer = ""
      end
    end
    groups



class Group
  var answers_per_person: Array[Set[U8]]

  new create(line: String iso) =>
    answers_per_person = Array[Set[U8]]
    let people = line.split("\n")
    for person in (consume people).values() do
      if person == "" then
        continue
      end
      var answers_set = Set[U8]
      for char in person.values() do
        answers_set = answers_set.add(char)
      end
      answers_per_person.push(answers_set)
    end

  fun union_of_yes(): USize? =>
    var union = answers_per_person(0)?.clone()
    for answers in answers_per_person.values() do
      union.union(answers.values())
    end
    union.size()

  fun intersection_of_yes(): USize? =>
    var union = answers_per_person(0)?.clone()
    for answers in answers_per_person.values() do
      union.intersect(answers.clone())
    end
    union.size()

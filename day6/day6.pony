use "collections"
use "debug"
use "files"

actor Main
  new create(env: Env) =>
    try
      let input = parse_groups(env.root as AmbientAuth)
      // let s = recover String end
      // s.append("n\ngn\nn")
      // let group = Group(consume s)
      let sum = add_group_questions(input)
      env.out.print(sum.string())
    end

  fun add_group_questions(groups: Array[Group]): USize =>
    var sum: USize = 0
    for group in groups.values() do
      sum = sum + group.answered_yes()
    end
    sum

  fun parse_groups(auth: AmbientAuth): Array[Group] =>
    let groups = Array[Group]
    try
      let path = FilePath(auth, "input.txt")?
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
    else
      groups
    end



class Group
  var questions: Set[U8]

  new create(line: String iso) =>
    questions = Set[U8]
    let people = line.split("\n")
    for person in (consume people).values() do
      for char in StringBytes(person) do
        Debug.out(char.string())
        questions = questions.add(char)
      end
    end

  fun answered_yes(): USize =>
    questions.size()

use "files"


actor Main
  new create(env: Env) =>
    try
      let forest = parse_forest(env.root as AmbientAuth)

      let count = (
        forest.count_trees(1, 1) *
        forest.count_trees(3, 1) *
        forest.count_trees(5, 1) *
        forest.count_trees(7, 1) *
        forest.count_trees(1, 2)
      )

      env.out.print(count.string())
    end

  fun parse_forest(auth: AmbientAuth): Forest =>
    let forest = Forest
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          forest.push(consume line)
        end
      end
      forest
    else
      forest
    end


class Forest
  let row_width: USize = 32
  let inner: Array[Array[Terrain]] = Array[Array[Terrain]](350)
  fun ref push(line: String iso) =>
    let row = Array[Terrain](row_width)
    for c in StringBytes(consume line) do
      let terrain = match c
        | 35 => Tree
        else Clearing
        end
      row.push(terrain)
    end
    inner.push(row)

  fun count_trees(horizontal: USize, vertical: USize): USize =>
    var count: USize = 0

    // Starting at the top left
    var x: USize = 0
    var y: USize = 0

    while y <= inner.size() do
      try
        let terrain = inner(y)?(x % (row_width - 1))?
        match terrain
          | Tree => count = count + 1
        end
      end

      x = x + horizontal
      y = y + vertical
    end

    count


primitive Tree
primitive Clearing

type Terrain is (Tree | Clearing)

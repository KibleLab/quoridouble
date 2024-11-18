class DFSPathFinder {
  List<List<bool>> visited;
  List<dynamic> path = [];
  List<List<int>> matrix;

  DFSPathFinder(this.matrix)
      : visited = List.generate(matrix.length,
            (i) => List.generate(matrix[0].length, (j) => false));

  bool dfs(int x, int y, int endX, int endY) {
    if (x < 0 ||
        y < 0 ||
        x >= matrix[0].length ||
        y >= matrix.length ||
        matrix[y][x] == 1 ||
        visited[y][x]) {
      return false;
    }

    if (x == endX && y == endY) {
      path.add([y, x]);
      return true;
    }

    visited[y][x] = true;

    List<List<int>> directions = [
      [0, 1], // 아래
      [1, 0], // 오른쪽
      [0, -1], // 위
      [-1, 0] // 왼쪽
    ];

    for (List<int> dir in directions) {
      int newX = x + dir[0];
      int newY = y + dir[1];
      if (dfs(newX, newY, endX, endY)) {
        path.add([y, x]);
        return true;
      }
    }

    return false;
  }

  List<dynamic> findPath(int startX, int startY, int endX, int endY) {
    path.clear();
    dfs(startX, startY, endX, endY);
    return path.reversed.toList();
  }
}

void main() {
  List<List<int>> mat = [
    [0, 0, 0, 0, 1],
    [1, 1, 0, 1, 0],
    [0, 0, 0, 0, 0],
    [0, 1, 1, 1, 1],
    [0, 0, 0, 0, 0],
  ];

  // start와 end의 값 설정 예시
  List<int> start = [0, 0]; // 시작 좌표
  List<int> endArray = [4, 4]; // 목적지 좌표

  DFSPathFinder dfsFinder = DFSPathFinder(mat);

  // DFSPathFinder로 경로를 찾음
  List<dynamic> path =
      dfsFinder.findPath(start[1], start[0], endArray[1], endArray[0]);

  print(path); // 경로 출력
}

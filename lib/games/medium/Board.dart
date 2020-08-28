import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import 'PredefinedBoards.dart';

class Board {
  static final int boardBase = 9;
  static final int boardBaseBlock = 3;
  List<List<Field>> fields;

  Board.empty() {
    clear();
  }

  Board.modify(int seed){
    var rnd = Random(seed);

    clear();
    var toCopy = MediumPredefinedBoards
        .boards[rnd.nextInt(MediumPredefinedBoards.boards.length)].fields;
    for (int y = 0; y < boardBase; y++) {
      for (int x = 0; x < boardBase; x++) {
        fields[y][x] = Field.of(toCopy[y][x]);
      }
    }

    print("shuffle board $seed");
    shuffle(rnd);
  }

  Board.of(List<Field> fields) {
    clear();
    fields.forEach((f) {
      var field = this.fields[f.y][f.x];
      field.number = f.number;
      field.initial = true;
    });
  }

  clear() {
    fields = List<List<Field>>();
    for (int y = 0; y < boardBase; y++) {
      var innerList = List<Field>();
      for (int x = 0; x < boardBase; x++) {
        innerList.add(Field(x, y));
      }
      fields.add(innerList);
    }
  }

  bool hasEmpty() {
    for (int y = 0; y < boardBase; y++)
      for (int x = 0; x < boardBase; x++)
        if (fields[y][x].number == null) return true;
    return false;
  }

  // returns true when the board has be solved
  bool checkBoard() {
    bool ret = true;
    for (int y = 0; y < boardBase; y++) {
      for (int x = 0; x < boardBase; x++) {
        int number = fields[y][x].number;
        if (number == null) {
          fields[y][x].valid = true;
          ret = false; // was not solved
          continue;
        }

        int countRow = 0, countColumn = 0, countBlock = 0;

        for (int i = 0; i < boardBase; i++) {
          if (fields[y][i].number == number) countRow++;
        }
        for (int i = 0; i < boardBase; i++) {
          if (fields[i][x].number == number) countColumn++;
        }

        int blockOffsetX = x ~/ boardBaseBlock,
            blockOffsetY = y ~/ boardBaseBlock;
        for (int y2 = 0; y2 < boardBaseBlock; y2++) {
          for (int x2 = 0; x2 < boardBaseBlock; x2++) {
            if (fields[blockOffsetY * boardBaseBlock + y2]
                        [blockOffsetX * boardBaseBlock + x2]
                    .number ==
                number) countBlock++;
          }
        }

        bool valid = countRow == 1 && countColumn == 1 && countBlock == 1;
        fields[y][x].valid = valid;
        if (!valid) ret = false;
      }
    }
    return ret;
  }

  void shuffle(Random rnd) {
    callWith3Permutation(swapRowBlock, rnd.nextInt(6));
    callWith3Permutation(swapColumnBlock, rnd.nextInt(6));

    callWith3Permutation((f, s) => swapRows(0, f, s), rnd.nextInt(6));
    callWith3Permutation((f, s) => swapRows(1, f, s), rnd.nextInt(6));
    callWith3Permutation((f, s) => swapRows(2, f, s), rnd.nextInt(6));
    callWith3Permutation((f, s) => swapColumns(0, f, s), rnd.nextInt(6));
    callWith3Permutation((f, s) => swapColumns(1, f, s), rnd.nextInt(6));
    callWith3Permutation((f, s) => swapColumns(2, f, s), rnd.nextInt(6));

    permutateNumbers(rnd.nextInt(362880));

    updateIndices();
  }

  void swapRowBlock(int first, int second) {
    var swapList = List<Field>();

    // store first & overwrite
    for (int y = 0; y < boardBaseBlock; y++) {
      for (int x = 0; x < boardBase; x++) {
        swapList.add(fields[y + first * boardBaseBlock][x]);
        fields[y + first * boardBaseBlock][x] =
            fields[y + second * boardBaseBlock][x];
      }
    }

    // store second
    for (int y = 0; y < boardBaseBlock; y++) {
      for (int x = 0; x < boardBase; x++) {
        fields[y + second * boardBaseBlock][x] = swapList[y * boardBase + x];
      }
    }
  }

  void swapColumnBlock(int first, int second) {
    var swapList = List<Field>();

    // store first & overwrite
    for (int y = 0; y < boardBase; y++) {
      for (int x = 0; x < boardBaseBlock; x++) {
        swapList.add(fields[y][x + first * boardBaseBlock]);
        fields[y][x + first * boardBaseBlock] =
            fields[y][x + second * boardBaseBlock];
      }
    }

    // store second
    for (int y = 0; y < boardBase; y++) {
      for (int x = 0; x < boardBaseBlock; x++) {
        fields[y][x + second * boardBaseBlock] =
            swapList[y * boardBaseBlock + x];
      }
    }
  }

  void swapRows(int block, int first, int second) {
    var swapList = List<Field>();

    // store first & overwrite
    for (int x = 0; x < boardBase; x++) {
      swapList.add(fields[block * boardBaseBlock + first][x]);
      fields[block * boardBaseBlock + first][x] =
          fields[block * boardBaseBlock + second][x];
    }

    // store second
    for (int x = 0; x < boardBase; x++) {
      fields[block * boardBaseBlock + second][x] = swapList[x];
    }
  }

  void swapColumns(int block, int first, int second) {
    var swapList = List<Field>();

    // store first & overwrite
    for (int y = 0; y < boardBase; y++) {
      swapList.add(fields[y][block * boardBaseBlock + first]);
      fields[y][block * boardBaseBlock + first] =
          fields[y][block * boardBaseBlock + second];
    }

    // store second
    for (int y = 0; y < boardBase; y++) {
      fields[y][block * boardBaseBlock + second] = swapList[y];
    }
  }

  /// [permutationNr] should be in 0..362880
  void permutateNumbers(int permutationNr) {
    permutationNr %= 362880;
    var perm = List<int>();

    // Create permutation
    {
      var initSet = List.generate(boardBase, (i) => i);
      int rem = permutationNr;
      int div = boardBase;

      while (div > 0) {
        int index = rem % div;
        rem ~/= div;
        div--;
        perm.add(initSet[index]);
        initSet.removeAt(index);
      }
    }
    print("perm $permutationNr: $perm");

    // apply permutation
    for (int y = 0; y < boardBase; y++) {
      for (int x = 0; x < boardBase; x++) {
        var n = fields[y][x].number;
        if (n != null) fields[y][x].number = perm[n - 1] + 1;
      }
    }
  }

  /// Call a function with a permutation of 3 integers. [permNr] defines which permutation to choose (0..6)
  void callWith3Permutation(void Function(int, int) fn, int permNr) {
    // 0 == identity
    if (permNr == 1) {
      fn(1, 2);
    } else if (permNr == 2) {
      fn(0, 1);
    } else if (permNr == 3) {
      fn(0, 1);
      fn(1, 2);
    } else if (permNr == 4) {
      fn(0, 1);
      fn(0, 2);
    } else if (permNr == 5) {
      fn(0, 2);
    }
  }

  void updateIndices() {
    for (int y = 0; y < boardBase; y++) {
      for (int x = 0; x < boardBase; x++) {
        fields[y][x].x = x;
        fields[y][x].y = y;
      }
    }
  }

  void save() async {
    var _sourceDir = Directory((await getApplicationDocumentsDirectory()).path);
    var file = new File('${_sourceDir.path}/medium.dat');
    if (!await file.exists()) await file.create(recursive: true);
    String str = "";

    String sep = ";";

    str += fields.length.toString() + sep;
    for (var list in fields) {
      str += list.length.toString() + sep;
      for (var f in list) {
        str += f.initial ? 't' : 'f';
        str += f.valid ? 't' : 'f';
        if (f.number != null) str += f.number.toString();
        str += sep;
      }
    }

    file.writeAsString(str);
  }

  /// Returns true when the board was loaded
  Future<bool> load() async {
    clear();

    var _sourceDir = Directory((await getApplicationDocumentsDirectory()).path);
    var file = new File('${_sourceDir.path}/medium.dat');
    if (await file.exists()) {
      var newFields = List<List<Field>>();
      var str = await file.readAsString();
      var itr = str.split(";").iterator;
      itr.moveNext();

      int size = int.parse(itr.current);
      itr.moveNext();
      for (int y = 0; y < size; y++) {
        var list = List<Field>();
        int subSize = int.parse(itr.current);
        itr.moveNext();
        for (int x = 0; x < subSize; x++) {
          var f = new Field(x, y);
          f.initial = itr.current[0] != 'f';
          f.valid = itr.current[1] != 'f';
          if (itr.current.length > 2)
            f.number = int.parse(itr.current.substring(2));
          list.add(f);
          itr.moveNext();
        }
        newFields.add(list);
      }

      fields = newFields;
      return true;
    } else
      return false;
  }

  void removeFile() async {
    var _sourceDir = Directory((await getApplicationDocumentsDirectory()).path);
    var file = new File('${_sourceDir.path}/medium.dat');
    file.delete();
  }
}

class Field {
  int x, y;
  int number;
  bool initial;
  bool valid = true;
  bool lightened=false;
  bool selection=false;
  List<int> hitnts=[0,0,0,0,0,0,0,0,0];

  Field(this.x, this.y, {this.number, this.initial = false});
  Field.of(Field other) {
    this.x = other.x;
    this.y = other.y;
    this.number = other.number;
    this.initial = other.initial;
    this.valid = other.valid;
  }
}

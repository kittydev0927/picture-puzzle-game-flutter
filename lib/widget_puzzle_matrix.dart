import 'dart:async';
import "dart:math";
import "dart:math" as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'module_puzzle_piece.dart';

class PuzzleMatrixWidget extends StatefulWidget {
  @override
  State<PuzzleMatrixWidget> createState() => _PuzzleMatrixWidgetState();
}

class _PuzzleMatrixWidgetState extends State<PuzzleMatrixWidget> {
  int matrix = 4;
  int level = 2;
  late PuzzlePiece emptyPuzzlePiece;
  List<PuzzlePiece> puzzlePieces = [];
  List<PuzzlePiece> oriPuzzlePieces = [];
  bool gameIsOver = false;
  bool autoRun = false;
  int moves = 0;
  List<PuzzlePiece> moveRecords = [];

  @override
  initState() {
    super.initState();
    initGame();
  }

  initGame() {
    puzzlePieces = List.generate(matrix * matrix, (index) => PuzzlePiece(matrix: matrix, number: index)).toList();
    emptyPuzzlePiece = puzzlePieces.last;
    // puzzlePieces.shuffle();
    settingPuzzlePiecesShuffleAndRecords();
  }

  getCanMovePositions() {
    return [
      [emptyPuzzlePiece.currentPosition[0] - 1, emptyPuzzlePiece.currentPosition[1]].toString(),
      [emptyPuzzlePiece.currentPosition[0] + 1, emptyPuzzlePiece.currentPosition[1]].toString(),
      [emptyPuzzlePiece.currentPosition[0], emptyPuzzlePiece.currentPosition[1] - 1].toString(),
      [emptyPuzzlePiece.currentPosition[0], emptyPuzzlePiece.currentPosition[1] + 1].toString(),
    ];
  }

  settingPuzzlePiecesShuffleAndRecords() {
    moveRecords = [];

    while (moveRecords.length < math.pow(matrix, level)) {
      final List<String> canMovePositions = getCanMovePositions();

      final canMovePuzzlePieces = puzzlePieces.where((element) => canMovePositions.contains(element.currentPosition.toString())).toList();
      final randomPiece = canMovePuzzlePieces[Random().nextInt(canMovePuzzlePieces.length)];
      moveRecords.add(randomPiece);
      final clickPuzzlePieceIndex = randomPiece.getCurrentIndex();
      final emptyPuzzlePieceIndex = emptyPuzzlePiece.getCurrentIndex();
      randomPiece.setCurrentIndex(emptyPuzzlePieceIndex);
      emptyPuzzlePiece.setCurrentIndex(clickPuzzlePieceIndex);
      final _temList = puzzlePieces;
      _temList[clickPuzzlePieceIndex] = emptyPuzzlePiece;
      _temList[emptyPuzzlePieceIndex] = randomPiece;
      puzzlePieces = _temList;
    }

    oriPuzzlePieces = puzzlePieces.map((e) => e).toList();

    setState(() {
      gameIsOver = false;
      moves = 0;
      puzzlePieces;
    });
  }

  Widget _generateCell(PuzzlePiece puzzlePiece, {bool visible = true}) {
    return GestureDetector(
      onTap: () {
        print('tap');

        if (puzzlePiece == emptyPuzzlePiece || gameIsOver) {
          print('click empty cell');
          return;
        }
        changePuzzlePiece(puzzlePiece);
      },
      child: !visible
          ? Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(4),
              width: 50,
              height: 50,
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: puzzlePiece.isEmptyCell ? Colors.transparent : Theme.of(context).backgroundColor,
              ),
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(4),
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fill,
                child: puzzlePiece.isEmptyCell
                    ? AnimatedOpacity(
                        opacity: gameIsOver ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          gameIsOver ? puzzlePiece.buttonText : ' ',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Text(
                        puzzlePiece.buttonText,
                        style: const TextStyle(fontSize: 30),
                      ),
              ),
            ),
    );
  }

  Widget _generateRowCell(List<PuzzlePiece> puzzlePieces) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: puzzlePieces.map((puzzlePiece) => _generateCell(puzzlePiece, visible: false)).toList(),
    );
  }

  Widget _generateMatrixWidget(List<PuzzlePiece> puzzlePieces) {
    final List<List<PuzzlePiece>> puzzlePiecesMatrix = [];

    int rowIndex = 0;
    List<PuzzlePiece> rowPuzzlePieces = [];
    puzzlePieces.asMap().forEach((index, puzzlePiece) {
      final _cellX = index ~/ matrix;
      final _cellY = index % matrix;
      puzzlePiece.currentPosition = [_cellX, _cellY];
      puzzlePiece.setCurrentIndex(index);
      if (index == puzzlePieces.length - 1) {
        rowPuzzlePieces.add(puzzlePiece);
        puzzlePiecesMatrix.add(rowPuzzlePieces);
      } else if (_cellX <= rowIndex) {
        rowPuzzlePieces.add(puzzlePiece);
      } else {
        puzzlePiecesMatrix.add(rowPuzzlePieces);
        rowIndex = _cellX;
        rowPuzzlePieces = [puzzlePiece];
      }
    });

    final _matrixWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: puzzlePiecesMatrix.map((rowPuzzlePieces) => _generateRowCell(rowPuzzlePieces)).toList(),
    );

    final List<Widget> list = [_matrixWidget];
    final positionedWidgets = _generatePositionedWidget();
    positionedWidgets.forEach((element) {
      list.add(element);
    });

    return Visibility(
      child: Container(
        padding: EdgeInsets.all(4),
        child: Stack(
          children: list,
        ),
      ),
    );
  }

  List<Widget> _generatePositionedWidget() {
    final List<Widget> _widget = [];

    oriPuzzlePieces.asMap().forEach((index, puzzlePiece) {
      _widget.add(Container(
        child: AnimatedPositioned(
          width: 58,
          height: 58,
          left: oriPuzzlePieces[index].piecePosition.positionY * 58.0,
          top: oriPuzzlePieces[index].piecePosition.positionX * 58.0,
          duration: Duration(milliseconds: autoRun ? 100 : 500),
          curve: Curves.fastOutSlowIn,
          child: GestureDetector(
            onTap: () {
              if (puzzlePiece == emptyPuzzlePiece || gameIsOver) {
                print('click empty cell');
                return;
              }
              changePuzzlePiece(puzzlePiece);
            },
            child: Container(
              margin: EdgeInsets.all(4),
              child: _generateCell(puzzlePiece),
            ),
          ),
        ),
      ));
    });

    // final _temList = oriPuzzlePieces.map((e) => e).toList();
    // setState(() {
    //   moves += 1;
    //   oriPuzzlePieces = _temList;
    // });

    return _widget;

    // return Container(
    //   color: Colors.black12,
    //   height: 200,
    //   width: 200,
    //   padding: EdgeInsets.all(4),
    //   child: Stack(children: _widget),
    // );
  }

  portraitWidget() {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Spacer(),
              Text('Matrix Size: $matrix'),
              Slider(
                  max: 7,
                  min: 2,
                  divisions: 5,
                  label: matrix.round().toString(),
                  value: matrix.toDouble(),
                  onChanged: (double changeValue) {
                    print('changeValue: ${changeValue}');
                    if (matrix != changeValue.round()) {
                      matrix = changeValue.round();
                      initGame();
                    }
                  }),
              SizedBox(height: 20),
              Text('Shuffle Level: $level'),
              Slider(
                  max: 4,
                  min: 1,
                  divisions: 3,
                  label: level.round().toString(),
                  value: level.toDouble(),
                  onChanged: (double changeValue) {
                    if (kDebugMode) {
                      print('changeValue: ${changeValue}');
                    }
                    if (level != changeValue.round()) {
                      level = changeValue.round();
                      initGame();
                    }
                  }),
              Spacer(),
              Text('Moves: $moves'),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                // color: gameIsOver ? Colors.green : Colors.orange,
                child: puzzlePieces.isEmpty ? const CircularProgressIndicator() : FittedBox(child: _generateMatrixWidget(puzzlePieces)),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      initGame();
                    },
                    child: FittedBox(child: Text('Refresh')),
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      autoChange();
                    },
                    child: FittedBox(
                      child: Text('Auto'),
                    ),
                  ),
                ),
              ],),
              Spacer(),
            ],
          ),
        ),
        autoRun
            ? Container(
          padding: EdgeInsets.all(20),
          color: Colors.black12,
          child: const CircularProgressIndicator.adaptive(),
          alignment: Alignment.center,
        )
            : Container(),
      ],
    );
  }

  landscapeWidget() {
    return Stack(
      children: [
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  Spacer(),
                  Text('Matrix Size: $matrix'),
                  Slider(
                      max: 7,
                      min: 2,
                      divisions: 5,
                      label: matrix.round().toString(),
                      value: matrix.toDouble(),
                      onChanged: (double changeValue) {
                        print('changeValue: ${changeValue}');
                        if (matrix != changeValue.round()) {
                          matrix = changeValue.round();
                          initGame();
                        }
                      }),
                  SizedBox(height: 20),
                  Text('Shuffle Level: $level'),
                  Slider(
                      max: 4,
                      min: 1,
                      divisions: 3,
                      label: level.round().toString(),
                      value: level.toDouble(),
                      onChanged: (double changeValue) {
                        if (kDebugMode) {
                          print('changeValue: ${changeValue}');
                        }
                        if (level != changeValue.round()) {
                          level = changeValue.round();
                          initGame();
                        }
                      }),
                  Spacer(),
                ],
              ),
              Container(
                child: puzzlePieces.isEmpty
                    ? const CircularProgressIndicator()
                    : Container(
                  margin: const EdgeInsets.all(16),
                  // color: gameIsOver ? Colors.green : Colors.orange,
                  child: FittedBox(child: _generateMatrixWidget(puzzlePieces)),
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Flexible(child: Text('Moves: $moves')),
                    Spacer(),
                    FittedBox(
                      child: ElevatedButton(
                        onPressed: () {
                          initGame();
                        },
                        child: Text('Refresh'),
                      ),
                    ),
                    Spacer(),
                    FittedBox(
                      child: ElevatedButton(

                        onPressed: () {
                          autoChange();
                        },
                        child: Text('AutoMove'),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
        autoRun
            ? Container(
          padding: EdgeInsets.all(20),
          color: Colors.black12,
          child: const CircularProgressIndicator.adaptive(),
          alignment: Alignment.center,
        )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        return portraitWidget();
      } else {
        return landscapeWidget();
      }
    });
  }

  changePuzzlePiece(PuzzlePiece puzzlePiece, {bool isAutoMode = false}) {
    // 根據目前空白格的位置計算出可以移動的方格位置列表
    // 只有空白格的上下左右方格可移動
    final List<String> canMovePositions = getCanMovePositions();

    // 只有在可以移動的位置的方格才執行位置交換
    if (canMovePositions.contains(puzzlePiece.currentPosition.toString())) {
      if (!isAutoMode) moveRecords.add(puzzlePiece);

      final clickPuzzlePieceIndex = puzzlePiece.getCurrentIndex();
      final emptyPuzzlePieceIndex = emptyPuzzlePiece.getCurrentIndex();
      puzzlePiece.setCurrentIndex(emptyPuzzlePieceIndex);
      emptyPuzzlePiece.setCurrentIndex(clickPuzzlePieceIndex);
      final _temList = puzzlePieces;
      _temList[clickPuzzlePieceIndex] = emptyPuzzlePiece;
      _temList[emptyPuzzlePieceIndex] = puzzlePiece;

      setState(() {
        moves += 1;
        puzzlePieces = _temList;
      });

      // setState(() {
      //   print('setState changed');
      //   moves += 1;
      // puzzlePieces = _temList;
      // print('${oriPuzzlePieces.map((e) => e.buttonText)}');
      // emptyPuzzlePiece;
      // });
      checkGameIsOver();
    } else {
      print('can not move');
    }
  }

  changePositionedPuzzlePiece(PuzzlePiece puzzlePiece) {
    // final _positionedTemList = oriPuzzlePieces;
    // _positionedTemList[clickPuzzlePieceIndex].piecePosition = emptyPuzzlePiece.piecePosition;
    // _positionedTemList[emptyPuzzlePieceIndex].piecePosition = puzzlePiece.piecePosition;
  }

  autoChange() async {
    if (gameIsOver) return;
    setState(() {
      autoRun = true;
    });
    for (final record in moveRecords.reversed) {
      if (gameIsOver) break;
      changePuzzlePiece(record, isAutoMode: true);
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  checkGameIsOver() {
    bool isOver = true;
    for (final puzzlePiece in puzzlePieces) {
      if (puzzlePiece.originalPosition.toString() != puzzlePiece.currentPosition.toString()) {
        isOver = false;
        break;
      }
    }

    if (isOver) {
      setState(() {
        autoRun = false;
        gameIsOver = isOver;
      });
    }
  }
}

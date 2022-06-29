class PuzzlePiece {
  final int matrix;
  final int number;
  late String buttonText;
  late List<int> originalPosition;
  late List<int> currentPosition;
  late int _currentIndex;
  late bool isEmptyCell;
  late PiecePosition piecePosition;

  PuzzlePiece({required this.matrix, required this.number}) {
    final positionX = number ~/ matrix;
    final positionY = number % matrix;
    originalPosition = [positionX, positionY];
    currentPosition = originalPosition;
    isEmptyCell = number == matrix * matrix - 1;
    buttonText = isEmptyCell ? 'Finish' : '${number + 1}';
    _currentIndex = number;
    piecePosition = PiecePosition(positionX: positionX, positionY: positionY);
  }

  setCurrentIndex(int currentIndex) {
    _currentIndex = currentIndex;
    final positionX = currentIndex ~/ matrix;
    final positionY = currentIndex % matrix;
    currentPosition = [positionX, positionY];
    piecePosition.positionX = positionX;
    piecePosition.positionY = positionY;
  }

  getCurrentIndex() {
    return _currentIndex;
  }
}

class PiecePosition {
  int positionX;
  int positionY;

  PiecePosition({required this.positionX, required this.positionY});

  comparePosition(PiecePosition piecePosition) {
    return piecePosition.positionX == positionX && piecePosition.positionY == positionY;
  }
}
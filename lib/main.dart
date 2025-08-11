// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:chess/chess.dart' as chess;
//
// void main() => runApp(const ChessApp());
//
// class ChessApp extends StatelessWidget {
//   const ChessApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Chess - Drag & Tap',
//       home: const ChessHomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class ChessHomePage extends StatefulWidget {
//   const ChessHomePage({super.key});
//   @override
//   State<ChessHomePage> createState() => _ChessHomePageState();
// }
//
// class _ChessHomePageState extends State<ChessHomePage> {
//   final chess.Chess _game = chess.Chess();
//   String? _selectedSquare;
//   List<String> _legalMovesForSelected = [];
//
//   // Helper: translate chess.Piece -> a unicode symbol
//   String _symbolFor(chess.Piece? p) {
//     if (p == null) return '';
//     final isWhite = p.color == chess.Color.WHITE;
//     switch (p.type) {
//       case chess.PieceType.PAWN:
//         return isWhite ? '♙' : '♟';
//       case chess.PieceType.KNIGHT:
//         return isWhite ? '♘' : '♞';
//       case chess.PieceType.BISHOP:
//         return isWhite ? '♗' : '♝';
//       case chess.PieceType.ROOK:
//         return isWhite ? '♖' : '♜';
//       case chess.PieceType.QUEEN:
//         return isWhite ? '♕' : '♛';
//       case chess.PieceType.KING:
//         return isWhite ? '♔' : '♚';
//       default:
//         return '';
//     }
//   }
//
//   void _selectSquare(String square) {
//     final piece = _game.get(square);
//     if (piece == null) {
//       setState(() {
//         _selectedSquare = null;
//         _legalMovesForSelected = [];
//       });
//       return;
//     }
//     final turn = _game.turn; // 'w' or 'b'
//     final isWhitePiece = piece.color == chess.Color.WHITE;
//     if ((turn == 'w' && isWhitePiece) || (turn == 'b' && !isWhitePiece)) {
//       setState(() {
//         _selectedSquare = square;
//         _legalMovesForSelected = _game
//             .moves({'square': square, 'verbose': true})
//             .map<String>((m) => m['to'] as String)
//             .toList();
//       });
//     } else {
//       // not your piece: clear selection
//       setState(() {
//         _selectedSquare = null;
//         _legalMovesForSelected = [];
//       });
//     }
//   }
//
//   void _tryMove(String from, String to) {
//     // check promotion (auto-queen)
//     final movingPiece = _game.get(from);
//     String? promotion;
//     if (movingPiece != null && movingPiece.type == chess.PieceType.PAWN) {
//       final toRank = int.parse(to[1]);
//       if ((movingPiece.color == chess.Color.WHITE && toRank == 8) ||
//           (movingPiece.color == chess.Color.BLACK && toRank == 1)) {
//         promotion = 'q';
//       }
//     }
//
//     final move = _game.move({
//       'from': from,
//       'to': to,
//       if (promotion != null) 'promotion': promotion,
//     });
//     if (move != null) {
//       setState(() {
//         _selectedSquare = null;
//         _legalMovesForSelected = [];
//       });
//     } else {
//       // illegal move (shouldn't happen if we validated before)
//       setState(() {
//         _selectedSquare = null;
//         _legalMovesForSelected = [];
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Illegal move')),
//       );
//     }
//   }
//
//   Widget _buildSquare(int rankIndex, int fileIndex) {
//     // rankIndex 0 is top (rank 8), fileIndex 0 is 'a'
//     final rank = 8 - rankIndex; // 8..1
//     final file = String.fromCharCode('a'.codeUnitAt(0) + fileIndex); // a..h
//     final square = '$file$rank';
//     final piece = _game.get(square);
//     final isLight = (rankIndex + fileIndex) % 2 == 0;
//     final isSelected = _selectedSquare == square;
//     final isLegalMove = _legalMovesForSelected.contains(square);
//
//     final baseColor = isLight ? const Color(0xFFEEEED2) : const Color(0xFF769656);
//
//     // The piece widget is draggable if there's a piece on this square.
//     final pieceWidget = piece != null
//         ? Draggable<String>(
//       data: square,
//       feedback: Material(
//         color: Colors.transparent,
//         child: SizedBox(
//           width: 48,
//           height: 48,
//           child: Center(
//             child: Text(
//               _symbolFor(piece),
//               style: const TextStyle(fontSize: 36),
//             ),
//           ),
//         ),
//       ),
//       childWhenDragging: const SizedBox.shrink(),
//       onDragStarted: () {
//         // show legal moves while dragging
//         _selectSquare(square);
//       },
//       onDraggableCanceled: (_, __) {
//         setState(() {
//           _selectedSquare = null;
//           _legalMovesForSelected = [];
//         });
//       },
//       child: Center(
//         child: Text(
//           _symbolFor(piece),
//           style: const TextStyle(fontSize: 32),
//         ),
//       ),
//     )
//         : const SizedBox.shrink();
//
//     return DragTarget<String>(
//       onWillAccept: (fromSquare) {
//         if (fromSquare == null) return false;
//         // Accept only if it's a legal move from 'fromSquare' to this 'square'
//         final moves = _game.moves({'square': fromSquare, 'verbose': true});
//         return moves.any((m) => m['to'] == square);
//       },
//       onAccept: (fromSquare) {
//         _tryMove(fromSquare, square);
//       },
//       builder: (context, candidateData, rejectedData) {
//         return GestureDetector(
//           onTap: () {
//             // Tap: select piece or move if a selected piece and this is legal
//             if (_selectedSquare == null) {
//               _selectSquare(square);
//             } else {
//               if (_legalMovesForSelected.contains(square)) {
//                 _tryMove(_selectedSquare!, square);
//               } else {
//                 // maybe select a different piece
//                 _selectSquare(square);
//               }
//             }
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: baseColor,
//               border: isSelected ? Border.all(color: Colors.yellowAccent, width: 3) : null,
//             ),
//             child: Stack(
//               children: [
//                 // piece (draggable)
//                 Positioned.fill(child: pieceWidget),
//                 // legal move dot
//                 if (isLegalMove)
//                   const Positioned(
//                     right: 6,
//                     bottom: 6,
//                     child: SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: DecoratedBox(
//                         decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
//                       ),
//                     ),
//                   ),
//                 // highlight when drag is over this square (candidate)
//                 if (candidateData.isNotEmpty)
//                   Positioned.fill(
//                     child: Container(
//                       color: Colors.yellow.withOpacity(0.15),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   String _turnText() {
//     if (_game.in_checkmate) return 'Checkmate — ${_game.turn == 'w' ? 'Black' : 'White'} wins';
//     if (_game.in_draw) return 'Draw';
//     if (_game.in_check) return 'Check — ${_game.turn == 'w' ? 'White' : 'Black'} to move';
//     return '${_game.turn == 'w' ? 'White' : 'Black'} to move';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Chess — Drag & Tap'),
//         actions: [
//           IconButton(
//             tooltip: 'Reset',
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 _game.reset();
//                 _selectedSquare = null;
//                 _legalMovesForSelected = [];
//               });
//             },
//           ),
//           IconButton(
//             tooltip: 'Undo',
//             icon: const Icon(Icons.undo),
//             onPressed: () {
//               // chess package method name may vary; try common ones
//               setState(() {
//                 try {
//                   _game.undo_move(); // older naming
//                 } catch (_) {
//                   try {
//                     _game.undo(); // some libs use undo()
//                   } catch (_) {
//                     // If neither exists, simply reset (fallback)
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Undo not supported by chess lib version')),
//                     );
//                   }
//                 }
//                 _selectedSquare = null;
//                 _legalMovesForSelected = [];
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(_turnText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           ),
//           Expanded(
//             flex: 6,
//             child: AspectRatio(
//               aspectRatio: 1.0,
//               child: GridView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
//                 itemCount: 64,
//                 itemBuilder: (context, index) {
//                   final rankIndex = index ~/ 8; // 0..7
//                   final fileIndex = index % 8; // 0..7
//                   return _buildSquare(rankIndex, fileIndex);
//                 },
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(8),
//               color: Colors.grey.shade100,
//               child: SingleChildScrollView(
//                 child: Text(_game.history.join(' ')),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }











// lib/main.dart
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;

void main() => runApp(const ChessApp());

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chess - Drag & Tap',
      home: const ChessHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChessHomePage extends StatefulWidget {
  const ChessHomePage({super.key});
  @override
  State<ChessHomePage> createState() => _ChessHomePageState();
}

class _ChessHomePageState extends State<ChessHomePage> {
  final chess.Chess _game = chess.Chess();
  String? _selectedSquare;
  List<String> _legalMovesForSelected = [];

  int _whiteCapturedCount = 0;
  int _blackCapturedCount = 0;

  // NEW: Lists to store captured pieces
  final List<String> _whiteCapturedPieces = [];
  final List<String> _blackCapturedPieces = [];

  String? _winner; // null until game ends

  String _symbolFor(chess.Piece? p) {
    if (p == null) return '';
    final isWhite = p.color == chess.Color.WHITE;
    switch (p.type) {
      case chess.PieceType.PAWN:
        return isWhite ? '♙' : '♟';
      case chess.PieceType.KNIGHT:
        return isWhite ? '♘' : '♞';
      case chess.PieceType.BISHOP:
        return isWhite ? '♗' : '♝';
      case chess.PieceType.ROOK:
        return isWhite ? '♖' : '♜';
      case chess.PieceType.QUEEN:
        return isWhite ? '♕' : '♛';
      case chess.PieceType.KING:
        return isWhite ? '♔' : '♚';
      default:
        return '';
    }
  }

  void _selectSquare(String square) {
    final piece = _game.get(square);
    if (piece == null) {
      setState(() {
        _selectedSquare = null;
        _legalMovesForSelected = [];
      });
      return;
    }
    final turn = _game.turn;
    final isWhitePiece = piece.color == chess.Color.WHITE;
    if ((turn == 'w' && isWhitePiece) || (turn == 'b' && !isWhitePiece)) {
      setState(() {
        _selectedSquare = square;
        _legalMovesForSelected = _game
            .moves({'square': square, 'verbose': true})
            .map<String>((m) => m['to'] as String)
            .toList();
      });
    } else {
      setState(() {
        _selectedSquare = null;
        _legalMovesForSelected = [];
      });
    }
  }

  void _tryMove(String from, String to) {
    final movingPiece = _game.get(from);
    final targetPiece = _game.get(to); // for capture tracking

    String? promotion;
    if (movingPiece != null && movingPiece.type == chess.PieceType.PAWN) {
      final toRank = int.parse(to[1]);
      if ((movingPiece.color == chess.Color.WHITE && toRank == 8) ||
          (movingPiece.color == chess.Color.BLACK && toRank == 1)) {
        promotion = 'q';
      }
    }

    final move = _game.move({
      'from': from,
      'to': to,
      if (promotion != null) 'promotion': promotion,
    });

    if (move != null) {
      // Track captures
      if (targetPiece != null) {
        final symbol = _symbolFor(targetPiece);
        if (movingPiece!.color == chess.Color.WHITE) {
          _whiteCapturedCount++;
          _whiteCapturedPieces.add(symbol);
        } else {
          _blackCapturedCount++;
          _blackCapturedPieces.add(symbol);
        }
      }

      // Check for game end
      if (_game.in_checkmate) {
        _winner = _game.turn == 'w' ? 'Black' : 'White';
      } else if (_game.in_draw) {
        _winner = 'Draw';
      }

      setState(() {
        _selectedSquare = null;
        _legalMovesForSelected = [];
      });
    } else {
      setState(() {
        _selectedSquare = null;
        _legalMovesForSelected = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Illegal move')),
      );
    }
  }

  Widget _buildSquare(int rankIndex, int fileIndex) {
    final rank = 8 - rankIndex;
    final file = String.fromCharCode('a'.codeUnitAt(0) + fileIndex);
    final square = '$file$rank';
    final piece = _game.get(square);
    final isLight = (rankIndex + fileIndex) % 2 == 0;
    final isSelected = _selectedSquare == square;
    final isLegalMove = _legalMovesForSelected.contains(square);

    final baseColor = isLight ? const Color(0xFFEEEED2) : const Color(0xFF769656);

    final pieceWidget = piece != null
        ? Draggable<String>(
      data: square,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(
              _symbolFor(piece),
              style: const TextStyle(fontSize: 36),
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        _selectSquare(square);
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _selectedSquare = null;
          _legalMovesForSelected = [];
        });
      },
      child: Center(
        child: Text(
          _symbolFor(piece),
          style: const TextStyle(fontSize: 32),
        ),
      ),
    )
        : const SizedBox.shrink();

    return DragTarget<String>(
      onWillAccept: (fromSquare) {
        if (fromSquare == null) return false;
        final moves = _game.moves({'square': fromSquare, 'verbose': true});
        return moves.any((m) => m['to'] == square);
      },
      onAccept: (fromSquare) {
        _tryMove(fromSquare, square);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            if (_selectedSquare == null) {
              _selectSquare(square);
            } else {
              if (_legalMovesForSelected.contains(square)) {
                _tryMove(_selectedSquare!, square);
              } else {
                _selectSquare(square);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: baseColor,
              border: isSelected
                  ? Border.all(color: Colors.yellowAccent, width: 3)
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(child: pieceWidget),
                if (isLegalMove)
                  const Positioned(
                    right: 6,
                    bottom: 6,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                if (candidateData.isNotEmpty)
                  Positioned.fill(
                    child: Container(
                      color: Colors.yellow.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _turnText() {
    if (_winner != null) return _winner == 'Draw' ? 'Draw' : 'Winner: $_winner';
    if (_game.in_check) {
      return 'Check — ${_game.turn == 'w' ? 'White' : 'Black'} to move';
    }
    return '${_game.turn == 'w' ? 'White' : 'Black'} to move';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chess — Drag & Tap'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _game.reset();
                _selectedSquare = null;
                _legalMovesForSelected = [];
                _whiteCapturedCount = 0;
                _blackCapturedCount = 0;
                _whiteCapturedPieces.clear();
                _blackCapturedPieces.clear();
                _winner = null;
              });
            },
          ),
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: () {
              setState(() {
                try {
                  _game.undo_move();
                } catch (_) {
                  try {
                    _game.undo();
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Undo not supported by chess lib version'),
                      ),
                    );
                  }
                }
                _selectedSquare = null;
                _legalMovesForSelected = [];
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _turnText(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Captured pieces info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('White captured ($_whiteCapturedCount): ${_whiteCapturedPieces.join(' ')}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  Text('Black captured ($_blackCapturedCount): ${_blackCapturedPieces.join(' ')}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          Expanded(
            flex: 6,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final rankIndex = index ~/ 8;
                  final fileIndex = index % 8;
                  return _buildSquare(rankIndex, fileIndex);
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: SingleChildScrollView(
                child: Text(_game.history.join(' ')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  static const String routeName = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const trumpShapeOrder = ['S', 'D', 'C', 'H'];

  String firstShape = '';

  int decideWinner(String trumpShape, List<String> cardsPlayed) {
    final String firstCardShape = cardsPlayed[0].substring(1);

    final List<String> trumpShapeCards =
        cardsPlayed.where((card) => card.substring(1) == trumpShape).toList();

    final List<String> firstCardShapeCards = cardsPlayed
        .where((card) => card.substring(1) == firstCardShape)
        .toList();

    if (trumpShapeCards.isNotEmpty) {
      final String highestTrumpShapeCard = trumpShapeCards.reduce((a, b) {
        if (a.contains('A')) return a;
        if (b.contains('A')) return b;
        if (playingCards.indexOf(a) > playingCards.indexOf(b)) {
          return a;
        } else {
          return b;
        }
      });
      return cardsPlayed.indexOf(highestTrumpShapeCard) + 1;
    } else {
      final String highestFirstCardShapeCard =
          firstCardShapeCards.reduce((a, b) {
        if (a.contains('A')) return a;
        if (b.contains('A')) return b;
        if (playingCards.indexOf(a) > playingCards.indexOf(b)) {
          return a;
        } else {
          return b;
        }
      });
      return cardsPlayed.indexOf(highestFirstCardShapeCard) + 1;
    }
  }

  bool isValidMove(
    String playedCard,
    String firstMoveShape,
    List<String> playerCards,
  ) {
    if (currentRoundCards.isEmpty) {
      return true;
    }
    if (playedCard.contains(firstMoveShape)) {
      return true;
    }
    if (playerCards.any((card) => card.contains(firstMoveShape))) {
      return false;
    }
    return true;
  }

  static const playingCards = [
    'AC',
    '2C',
    '3C',
    '4C',
    '5C',
    '6C',
    '7C',
    '8C',
    '9C',
    '10C',
    'JC',
    'QC',
    'KC',
    'AD',
    '2D',
    '3D',
    '4D',
    '5D',
    '6D',
    '7D',
    '8D',
    '9D',
    '10D',
    'JD',
    'QD',
    'KD',
    'AH',
    '2H',
    '3H',
    '4H',
    '5H',
    '6H',
    '7H',
    '8H',
    '9H',
    '10H',
    'JH',
    'QH',
    'KH',
    'AS',
    '2S',
    '3S',
    '4S',
    '5S',
    '6S',
    '7S',
    '8S',
    '9S',
    '10S',
    'JS',
    'QS',
    'KS',
  ];

  static const noOfRounds = 13;
  List<dynamic> roundResults = [];
  List<String> currentRoundCards = [];
  int currentPlayer = 0;
  int rounds = 0;

  // need to distribute the cards randomly to 4 players
  final List<List<String>> distributedCards = [];
  void distributeCards() {
    final List<String> tempPlayingCards = List.from(playingCards);
    for (var i = 0; i < 4; i++) {
      distributedCards.add([]);
      for (var j = 0; j < 13; j++) {
        final randomIndex = Random().nextInt(tempPlayingCards.length);
        distributedCards[i].add(tempPlayingCards[randomIndex]);
        tempPlayingCards.removeAt(randomIndex);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    roundResults.clear();
    currentRoundCards.clear();
    currentPlayer = 0;
    rounds = 0;
    distributeCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Game Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // need to display the round results in a modal
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: roundResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          roundResults[index]['cards'].join(' '),
                        ),
                        subtitle: Text(
                          'Winner: ${roundResults[index]['winner']}',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        child: const Icon(Icons.view_array),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Text to display first shape
          Text(
            firstShape.isEmpty
                ? 'First Shape: Not Played'
                : 'First Shape: $firstShape',
          ),

          // Display current round's trump shape
          Text(
            'Trump Shape: ${trumpShapeOrder[rounds % 4]}',
          ),

          // Display the cards played in the current round
          Text(
            'Cards Played: ${currentRoundCards.join(' ')}',
          ),
          rounds != noOfRounds
              ? Expanded(
                  child: ListView.builder(
                    itemCount: distributedCards[currentPlayer].length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              String playedCard =
                                  distributedCards[currentPlayer][index];

                              if (!isValidMove(playedCard, firstShape,
                                  distributedCards[currentPlayer])) {
                                // show some alert
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Invalid Move'),
                                      content: const Text(
                                          'You must play the same shape as the first card played'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }

                              distributedCards[currentPlayer].removeAt(index);

                              currentRoundCards.add(playedCard);

                              if (firstShape.isEmpty) {
                                firstShape = playedCard.substring(1, 2);
                              }

                              if (currentRoundCards.length == 4) {
                                int roundWinner = decideWinner(
                                  trumpShapeOrder[rounds % 4],
                                  List.from(currentRoundCards),
                                );

                                roundResults.add({
                                  'cards': List.from(currentRoundCards),
                                  'winner': roundWinner,
                                });

                                currentRoundCards.clear();
                                firstShape = '';
                                rounds++;
                              }

                              // Move to the next player
                              currentPlayer = (currentPlayer + 1) % 4;
                            });
                          },
                          title: Text(distributedCards[currentPlayer][index]),
                        ),
                      );
                    },
                  ),
                )
              : const Text('Game Over'),
        ],
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(const MainApp());
// }

// class MainApp extends StatefulWidget {
//   const MainApp({Key? key}) : super(key: key);

//   @override
//   _MainAppState createState() => _MainAppState();
// }

// class _MainAppState extends State<MainApp> {
//   List<String> selectedItems = []; // List to store selected game keys
//   List<String> gameList = []; // List to store game names
//   Map<String, String> gameMap = {}; // Map to store game key-value pairs
//   String dropdownValue = 'Choose a game';
//   bool isLoading = false;

//   late GlobalKey<NavigatorState> navigatorKey;

//   @override
//   void initState() {
//     super.initState();
//     navigatorKey = GlobalKey<NavigatorState>();
//     loadGameList();
//   }

//   Future<void> loadGameList() async {
//     final jsonString = await rootBundle.loadString('assets/games.json');
//     final Map<String, dynamic> gamesData = json.decode(jsonString);
//     gamesData.forEach((key, value) {
//       final gameKey = key; // Create unique identifiers for each game
//       gameList.add(value);
//       gameMap[gameKey] = value;
//     });
//     setState(() {});
//   }

//   Future<void> makePostRequest() async {
//     setState(() {
//       isLoading = true;
//     });

//     final url = Uri.parse('http://172.20.208.1:8000/predict');
//     final headers = {'Content-Type': 'application/json'};
//     final body = jsonEncode({
//       'games_list': selectedItems,
//     });

//     final response = await http.post(url, headers: headers, body: body);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print(data);

//       navigatorKey.currentState?.push(
//         MaterialPageRoute(
//           builder: (context) => ResultScreen(
//             selectedGames: selectedItems,
//             predictedGames: data['prediction']['games'].cast<String>(),
//             scores: data['prediction']['scores'].cast<double>(),
//           ),
//         ),
//       );
//     } else {
//       print('Request failed with status: ${response.statusCode}.');
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<DropdownMenuItem<String>> dropdownItems = gameList.map((String value) {
//       String truncatedValue =
//           value.length > 30 ? value.substring(0, 30) + "..." : value;

//       return DropdownMenuItem<String>(
//         value: value,
//         child: Text(truncatedValue, maxLines: 1),
//       );
//     }).toList();

//     return MaterialApp(
//       navigatorKey: navigatorKey, // Provide the navigatorKey to MaterialApp
//       home: Scaffold(
//         body: SafeArea(
//           child: Column(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.only(top: 16.0),
//                 child: CircleAvatar(
//                   radius: 50.0,
//                   // You can use a default user image or customize it
//                   backgroundImage: AssetImage('assets/user.png'),
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   'Choose a game that you are interested in!',
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//               Row(
//                 children: [
//                   const SizedBox(width: 16.0),
//                   Flexible(
//                     child: DropdownButtonFormField<String>(
//                       value: dropdownValue,
//                       icon: const Icon(Icons.arrow_drop_down),
//                       iconSize: 24,
//                       elevation: 16,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           dropdownValue = newValue!;
//                           if (newValue != 'Choose a game') {
//                             final selectedKey = gameMap.keys.firstWhere(
//                               (key) => gameMap[key] == newValue,
//                             );
//                             if (selectedItems.contains(selectedKey)) {
//                               selectedItems.remove(selectedKey);
//                             } else {
//                               selectedItems.add(selectedKey);
//                               selectedItems.sort();
//                             }
//                           }
//                         });
//                       },
//                       items: [
//                         const DropdownMenuItem<String>(
//                           value: 'Choose a game',
//                           child: Text('Choose a game'),
//                         ),
//                         ...dropdownItems,
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16.0),
//                 ],
//               ),
//               const SizedBox(height: 16.0),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: selectedItems.length,
//                   itemBuilder: (context, index) {
//                     final gameKey = selectedItems[index];
//                     final gameName = gameMap[gameKey]!;
//                     return ListTile(
//                       title: Text(gameName),
//                       leading: Checkbox(
//                         value: true,
//                         onChanged: (value) {
//                           setState(() {
//                             if (value == false) {
//                               selectedItems.remove(gameKey);
//                             }
//                           });
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed:
//                     selectedItems.isEmpty || isLoading ? null : makePostRequest,
//                 child: isLoading
//                     ? const CircularProgressIndicator()
//                     : const Text('Predict'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ResultScreen extends StatelessWidget {
//   final List<String> selectedGames;
//   final List<String> predictedGames;
//   final List<double> scores;

//   const ResultScreen({
//     Key? key,
//     required this.selectedGames,
//     required this.predictedGames,
//     required this.scores,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Prediction Result'),
//       ),
//       body: ListView.builder(
//         itemCount: predictedGames.length,
//         itemBuilder: (context, index) {
//           final selectedGame = predictedGames[index];
//           final predictedGame = predictedGames[index];
//           final score = scores[index];

//           return ListTile(
//             title: Text('Selected Game: ${(index + 1)}'),
//             subtitle: Text('Predicted Game: $predictedGame'),
//             trailing: Text('Matching: ${(score * 100).toStringAsFixed(2)}%'),
//           );
//         },
//       ),
//     );
//   }
// }

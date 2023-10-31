import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(236, 64, 122, 1)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favourites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void addFavourites() {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    print(favourites);
    notifyListeners();
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPage) {
      case 0:
        page = NameGeneratorPage();
        break;
      case 1:
        page = NameList();
        break;
      default:
        throw UnimplementedError('no widget for $selectedPage');
    }
    return Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: true,
                selectedIndex: selectedPage,
                destinations: [
                  NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text("Homepage")),
                  NavigationRailDestination(
                      icon: Icon(Icons.favorite), label: Text("Favourites"))
                ],
                onDestinationSelected: (value) {
                  setState(() {
                    selectedPage = value;
                  });
                },
              ),
            ),
            Expanded(
                child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page))
          ],
        ));
  }
}

class NameList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favourites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('No favourites Yet')],
        ),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text("YOU HAVE " "${appState.favourites.length} favourites:"),
        ),
        for (var pair in appState.favourites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asPascalCase),
          )
      ],
    );
  }
}

class NameGeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    Icon icon;
    if (appState.favourites.contains(appState.current)) {
      icon = Icon(
        Icons.favorite,
        color: Colors.white,
        size: 15.0,
      );
    } else {
      icon = Icon(
        Icons.favorite_border,
        color: Colors.white,
        size: 15.0,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(
            height: 10,
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyButton(
                  "Next Name",
                  appState.getNext,
                  Icon(
                    Icons.sailing,
                    color: Colors.white,
                    size: 15.0,
                  )),
              SizedBox(
                width: 5,
              ),
              MyButton("Favourites", appState.addFavourites, icon),
            ],
          ),
        ],
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton(this.text, this.callback, [this.icon]);
  final VoidCallback callback;
  final String text;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink[400],
      ),
      onPressed: () {
        callback();
      },
      label: ButtonText(text),
      icon: icon ?? SizedBox.shrink(),
    );
  }
}

class ButtonText extends StatelessWidget {
  const ButtonText(
    this.text,
  ) : super();

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.white,
          fontFamily: 'Raleway',
          fontSize: 15,
          fontWeight: FontWeight.bold),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

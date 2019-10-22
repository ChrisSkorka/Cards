import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cards/CardImage.dart';
import 'package:cards/BottomMenu.dart';

//void main() => runApp(new MyApp());
void main(){
  //SystemChrome.setEnabledSystemUIOverlays([])
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(new MyApp());
}

final Key key1 = new GlobalKey<CardImageState>();
final Key key2 = new GlobalKey<CardImageState>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cards',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.red,
      ),
      home: new CardsPage(title: 'Cards'),
    );
  }
}

class CardsPage extends StatefulWidget {
  CardsPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CardsPageState createState() => new _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  int _counter = 0;
  
  List<String> cards = [
    'clubs_2',
    'clubs_3',
    'clubs_4',
    'clubs_5',
    'clubs_6',
    'clubs_7',
    'clubs_8',
    'clubs_9',
    'clubs_10',
    'clubs_ace',
    'clubs_jack',
    'clubs_king',
    'clubs_queen',
    'diamond_2',
    'diamond_3',
    'diamond_4',
    'diamond_5',
    'diamond_6',
    'diamond_7',
    'diamond_8',
    'diamond_9',
    'diamond_10',
    'diamond_ace',
    'diamond_jack',
    'diamond_king',
    'diamond_queen',
    'heart_2',
    'heart_3',
    'heart_4',
    'heart_5',
    'heart_6',
    'heart_7',
    'heart_8',
    'heart_9',
    'heart_10',
    'heart_ace',
    'heart_jack',
    'heart_king',
    'heart_queen',
    'spades_2',
    'spades_3',
    'spades_4',
    'spades_5',
    'spades_6',
    'spades_7',
    'spades_8',
    'spades_9',
    'spades_10',
    'spades_ace',
    'spades_jack',
    'spades_king',
    'spades_queen',
  ];

  List<String> flippedCards = [];
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    cards.shuffle();
  }

  void showOptions(){

  }

  void onCardRemoved(){
    print("remove card");
    print(cards.length);
    setState((){
      flippedCards.insert(0, cards.removeLast());
    });
  }

  void reset(){
    setState((){
      cards.addAll(flippedCards);
      flippedCards.clear();
      cards.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stackItems = <Widget>[
      new Center(
        child: new Text(
          "That's it", 
          style: new TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      )
    ];

    // add background facedown card
    if(cards.length > 1){
      stackItems.add(
        new CardImage(
          key: key1,
          image: 'back_blue',
          constant: true,
        ),
      );
    }

    // add current card
    if(cards.length > 0){
      stackItems.add(
        new CardImage(
          key: key2,
          image: cards.last,
          onRemove: onCardRemoved,
        ),
      );
    }

    // add options
    stackItems.add(
      new Align(
        alignment: Alignment.bottomCenter,
        child: new BottomMenu(
          flippedCards: flippedCards,
          resetCallback: reset,
        ),
      ),
    );

    // // add options
    // stackItems.add(
    //   new Align(
    //     alignment: Alignment.bottomCenter,
    //     child: new IconButton(
    //       icon: new Icon(Icons.expand_less),
    //       color: Colors.grey,
    //       tooltip: 'Options',
    //       padding: new EdgeInsets.all(25.0),
    //       onPressed: showOptions,
    //     ),
    //   ),
    // );

    // build
    return new Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomPadding: false,
      body: new Stack(
        children: stackItems
      ),
    );
  }
}

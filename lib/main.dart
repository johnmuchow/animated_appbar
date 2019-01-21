import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

void main() => runApp(AppHome());

class AppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.grey[200],
      ),
      home: AppHomePage(title: 'Appbar Animation'),
    );
  }
}

class AppHomePage extends StatefulWidget {
  AppHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  AppBarView appBarView = AppBarView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                appBarView.appBarViewState.handleTap(); 
              })
        ],
      ),
      backgroundColor: Colors.lightBlue[50],

      //------------------------------------------------------
      // UI consists of Container with text and a
      // Container with the animated appbar.
      //------------------------------------------------------
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('CurvedAnimation and ClipPath',
                    style: TextStyle(fontSize: 24.0, color: Colors.indigo)),
              ],
            ),
          ),
          Container(
            child: Column(children: <Widget>[appBarView]),
          ),
        ],
      ),
    );
  }
}

class AppBarView extends StatefulWidget {
  _AppBarViewState appBarViewState = _AppBarViewState();

  @override
  _AppBarViewState createState() => appBarViewState;
}

class _AppBarViewState extends State<AppBarView> with SingleTickerProviderStateMixin {
  //------------------------------------------------------
  // The tween value will be the height of the appbar.
  // See the height parameter in the build() method.
  //------------------------------------------------------
  AnimationController _animationController;
  Animation<double> _animation;
  bool _isViewOpen = false;
  final _tweenMax = 250.0;

  @override
  void initState() {
    super.initState();

    //------------------------------------------------------
    // Animation is for .5 seconds, tween range is between
    // 0 and 250, linear curve animation.
    //------------------------------------------------------
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: _tweenMax).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    if (_animationController != null) _animationController.dispose();
    super.dispose();
  }

  void handleTap() {
    if (!_isViewOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isViewOpen = !_isViewOpen;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Material(
        color: Colors.transparent,
        child: ClipPath(
          clipper: ClipAppBar(),

          //------------------------------------------------------
          // Container includes a BoxDecoration (the animated appbar)
          // and the child is the animated logo and text.
          // Notice how the _animation.value is used to control the
          // height of the container as well as size of the logo
          // and the fontsize.
          //------------------------------------------------------
          child: Container(
            // Animate height, target 250 (_tweenMax)
            height: _animation.value,
            decoration: BoxDecoration(
              color: Colors.green[400],
              gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green[400], Colors.cyan],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Animate size, target size is 130
                  Icon(Icons.local_drink,
                  size: (_animation.value / _tweenMax) * 130),
                  Container(
                    child: Text(
                      'For a quart of Ale is a dish for a king.',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          // Animate size, target size is 20
                          fontSize: (_animation.value / _tweenMax) * 20.0,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        handleTap();
      },
    );
  }
}

class ClipAppBar extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    var path = Path();

    // Down left side of view
    path.lineTo(0.0, size.height - 35);

    // First control point is 1/4 of way into view size
    var firstControlPoint = Offset(size.width * .25, size.height);

    // Curve from current point (left side of view),
    // through control point, to middle of view
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, size.width / 2, size.height);

    // Second control point is 3/4 of way into view
    var secondControlPoint = Offset(size.width * .75, size.height);

    // Curve from current point (middle of view),
    // through control point, to right side of view
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, size.width, size.height - 35);

    // Up right side of view
    path.lineTo(size.width, 0.0);

    // Back to the starting point
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

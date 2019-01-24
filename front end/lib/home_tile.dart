import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {

  HomeTile({Key key, this.title, this.icon, this.route}) : super(key: key);

  final String title;
  final IconData icon;
  final Widget route;

  final tileSize = 150.0;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route)),
      child: SizedBox(
          width: tileSize,
          height: tileSize,
          child: new Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(title, style: TextStyle(fontSize: tileSize/6.25, color: Color.fromRGBO(70, 68, 71, 1), fontWeight: FontWeight.bold),),
                SizedBox(height: 10.0),
                Icon(icon, size: tileSize/2.69, color: Color.fromRGBO(70, 68, 71, 1),)
              ],
            ),)
      ),
    );
  }
}

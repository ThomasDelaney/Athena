import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {

  HomeTile({Key key, this.title, this.icon, this.route}) : super(key: key);

  final String title;
  final IconData icon;
  final Widget route;

  final tileSize = 170.0;

  @override
  Widget build(BuildContext context) {

    double scaleFactor = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;

    return new GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route)),
      child: SizedBox(
          width: tileSize * scaleFactor,
          height: tileSize * scaleFactor,
          child: new Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(title, style: TextStyle(fontSize: 24*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1), fontWeight: FontWeight.bold),),
                SizedBox(height: 10.0),
                Icon(icon, size: 55.7*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1),)
              ],
            ),)
      ),
    );
  }
}

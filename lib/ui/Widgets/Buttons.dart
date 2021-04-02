import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';


class MyButton extends StatefulWidget {
  int color;
  VoidCallback method;
  Icon myicon;
  Text mytext;
  String tag;
  MyButton({this.color,this.method,this.mytext,this.myicon,this.tag});
  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {

  final tween = MultiTrackTween([
    Track("color1").add(Duration(seconds: 4),
        ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
    Track("color2").add(Duration(seconds: 4),
        ColorTween(begin: Colors.redAccent, end: Colors.blue.shade600))
  ]);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.method!=null?widget.method:(){},
      child: ControlledAnimation(
          playback: Playback.MIRROR,
          tween: tween,
          duration: tween.duration,
          builder: (context,animation){
            return Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (){
                    if(widget.color==1 || widget.color==null){
                      return animation['color1'];
                    }
                    else {
                      return animation['color2'];
                    }
                  }()
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      widget.myicon!=null?widget.myicon:Container(height: 0,width: 0,),
                      SizedBox(width: 15,),
                      widget.mytext!=null?widget.mytext:Container(height: 0,width: 0,),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

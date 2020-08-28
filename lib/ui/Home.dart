
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';
import 'package:sudokutable/games/easy/GameMenu.dart';
import 'package:sudokutable/games/medium/GameMenu.dart';
import 'package:sudokutable/ui/Widgets/Buttons.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: Scaffold(
        body:Container(
             height: MediaQuery.of(context).size.height,
             alignment: Alignment.topCenter,
             padding: EdgeInsets.all(40),
             child:Column(
               mainAxisSize: MainAxisSize.max,
               mainAxisAlignment: MainAxisAlignment.end,
               children: <Widget>[
                 Text("Sudoku" ,style: GoogleFonts.muli(color: Colors.limeAccent,fontWeight: FontWeight.w300,
                 fontSize: 35,letterSpacing: 2
                 ),),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   mainAxisSize: MainAxisSize.max,
                   children: <Widget>[
                     SizedBox(height: 60,),
                     MyButton(
                       tag:"easy",
                       color: 1,
                       mytext: Text("Easy",style: GoogleFonts.lato(fontSize: 30),),
                       myicon: Icon(FontAwesomeIcons.playstation),
                       method: (){

                         Navigator.push(context, MaterialPageRoute(
                             builder: (context){
                               return GameMenuEasy();
                             }
                         ));
                       },
                     ),
                     SizedBox(height: 30,),
                     MyButton(
                       tag:"hard",
                       color: 2,
                       mytext: Text("Hard",style: GoogleFonts.lato(fontSize: 30),),
                       myicon: Icon(FontAwesomeIcons.playstation),
                       method: (){

                         Navigator.push(context, MaterialPageRoute(
                             builder: (context){
                               return GameMenuMedium();
                             }
                         ));
                       },
                     )
                   ],
                 ),
                 Container(
                   height: MediaQuery.of(context).size.height/5,
                   width: MediaQuery.of(context).size.width,
                   alignment: Alignment.bottomCenter,
                   child: Text("From XYZ  Softwares Ltd.",style: GoogleFonts.muli(color:
                   Colors.white
                   ),),
                 )
               ],
             ),
             decoration: BoxDecoration(
                color: Colors.grey[400]
             ),
           )
      ),
    );
  }

}

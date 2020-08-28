import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';
import 'package:sudokutable/colors.dart';
import 'package:vibration/vibration.dart';

import 'Board.dart';

class GameMenuEasy extends StatefulWidget {
  final double fieldSize = 40;
  final Color borderColor = Colors.grey;

  @override
  State<StatefulWidget> createState() => _GameMenuEasyState();
}

class _GameMenuEasyState extends State<GameMenuEasy> {

  Color bgcolor=Colors.lightBlue.shade900;
  Board board = Board.empty();
  Field focussed;
  bool win = false;
  bool finished = false;
  bool note;
  int hr=0;
  int min=0;
  int sec=0;

  void changeColor(Color color) {
    setState(() => bgcolor = color);
  }

  final tween = MultiTrackTween([
    Track("color1").add(Duration(seconds: 4),
        ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
    Track("color2").add(Duration(seconds: 4),
        ColorTween(begin: Color(0xffA83279), end: Colors.blue.shade600))
  ]);
  @override
  void initState() {

    board.load().then((loaded) {
      if(loaded){_settimer();}
      setState(() {
        if (!loaded) createNewBoard();
      });
      WidgetsBinding.instance.addObserver(LifecycleHandler(
          suspendingCallBack: () async {
            if (!win)
            {
              _savetimer();
              board.save();
            }
            else
            {board.removeFile();}
          },
          resumeCallBack: () {
            _startTimer();
          }));
      _startTimer();
    });
    note=false;
    // TODO: implement initState
    super.initState();
  }

  void createNewBoard(){
_createtimer();
    board = Board.modify(Random().nextInt(1 << 32));
    focussed = null;
    win = false;
    finished = false;
  }

  void checkBoard() {
    if (!board.hasEmpty() || finished) {
      finished = true;
      if (board.checkBoard()) {
        setState(() {
          win = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        _savetimer();
        board.save();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: black,
        body: ControlledAnimation(
          playback: Playback.MIRROR,
          tween: tween,
          duration: tween.duration,
          builder: (context,animation){
            return Container(
              decoration: BoxDecoration(
                  color: bgcolor),
              child: Stack(children: <Widget>[

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _unlightup();
                  setState(() {
                    focussed = null;
                  });
                },
              ),
              // Title
              Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(!win ? "Sudoku Cash" : "Congratulations, you won!",
                          style: GoogleFonts.lato(
                              fontSize: 25, color: win ? Colors.green : grey),
                ), Text("  Easy",
                          style: GoogleFonts.lato(
                              fontSize: 10, color: white),
                ),
                    ],
                  ))
              ]),
              // Reload button

              // Game board
              Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: board.fields
                          .map(
                            (list) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: list
                                    .map(
                                      (field) => Container(
                                        padding: EdgeInsets.all(0),
                                          child: InkWell(
                                            onTap: () {
                                              Vibration.vibrate(amplitude: 10,duration: 50);
                                              setState(() {
                                                if (focussed == field ||
                                                    field.initial)
                                                  {
                                                    _unlightup();
                                                    focussed = null;

                                                  }
                                                else
                                                  {
                                                    _lightup(field.x, field.y);
                                                    setState(() {
                                                      focussed=field;
                                                    });
                                                  }
                                              });
                                              _ligthano(field);
                                            },
                                            child: Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    (field.number!=null)?Text(
                                                      field.number == null
                                                          ? ""
                                                          : field.number.toString(),
                                                      style: GoogleFonts.lato(
                                                          fontSize: 25,
                                                          color: field.initial
                                                              ? Colors.lime                                                              : white),
                                                    ):Container(height: 0,width: 0,),


                                                    (field.initial ||  field.hitnts[0]==0)?Container(height: 1,width: 1,):Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Text(
                                                          field.hitnts[0]==0
                                                              ? ""
                                                              : field.hitnts[0].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),Text(
                                                          field.hitnts[1]==0
                                                              ? ""
                                                              : field.hitnts[1].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),Text(
                                                          field.hitnts[2]==0
                                                              ? ""
                                                              : field.hitnts[2].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),
                                                      ],
                                                    ),



                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        (field.initial ||  field.hitnts[3]==0)?Container(height: 1,width: 1,):Text(
                                                          field.hitnts[3]==0
                                                              ? ""
                                                              : field.hitnts[3].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),


                                                        (field.initial ||  field.hitnts[4]==0)?Container(height: 1,width: 1,):Text(
                                                          field.hitnts[4]==0
                                                              ? ""
                                                              : field.hitnts[4].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),
                                                        (field.initial ||  field.hitnts[5]==0)?Container(height: 1,width: 1,):Text(
                                                          field.hitnts[5]==0
                                                              ? ""
                                                              : field.hitnts[5].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    (field.initial ||  field.hitnts[6]==0)?Container(height: 1,width: 1,):Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Text(
                                                          field.hitnts[6]==0
                                                              ? ""
                                                              : field.hitnts[6].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),Text(
                                                          field.hitnts[7]==0
                                                              ? ""
                                                              : field.hitnts[7].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),Text(
                                                          field.hitnts[8]==0
                                                              ? ""
                                                              : field.hitnts[8].toString(),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: field.initial
                                                                  ? grey
                                                                  : Colors.white
                                                          ),
                                                        ),
                                                      ],
                                                    ),


                                                  ],
                                                )),
                                          ),
                                          width: widget.fieldSize,
                                          height: widget.fieldSize,
                                          decoration: BoxDecoration(
                                            color: () {
                                              if(field.selection==true){
                                                  return Colors.blueAccent.shade700;
                                              }
                                              else {if(focussed == field) {
                                              return grey.withOpacity(0.7);
                                              }
                                              else if(field.lightened){
                                                return white.withOpacity(0.4);
                                              }
                                              else {
                                                if (!field.valid) {
                                                  if (field.initial) {
                                                    return Colors.yellow;
                                                  } else {
                                                    return Colors.red;
                                                  }
                                                } else
                                                  return white.withOpacity(0.2);
                                              }}
                                            }(),
                                            border: Border(
                                                left: BorderSide(
                                                    color: bgcolor,
                                                    width:
                                                        field.x % 3 == 0 ? 3 : 0),
                                                right: BorderSide(
                                                    color: bgcolor,
                                                    width: field.x ==
                                                            Board.boardBase - 1
                                                        ? 2
                                                        : 0),
                                                top: BorderSide(
                                                    color: bgcolor,
                                                    width:
                                                        field.y % 3 == 0 ? 2 : 0),
                                                bottom: BorderSide(
                                                    color:bgcolor,
                                                    width: field.y ==
                                                            Board.boardBase - 1
                                                        ? 2
                                                        : 0)),
                                          )),
                                    )
                                    .toList()),
                          )
                          .toList())),
              // Number pad

                  Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                          Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0,right: 8,left: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),
                                    child: Container(
                                      color: white.withOpacity(0.3),
                                      child: GridView.builder(
                                  gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 6,
                                            childAspectRatio: 1.6,
                                            crossAxisSpacing: 3,
                                            mainAxisSpacing: 3),
                                  itemCount: Board.boardBase + 3,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(1),
                                  itemBuilder: (context, i) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color:(){
                                            if(i==Board.boardBase+1)
                                              {
                                                if(note){
                                                  return Colors.blueAccent.shade700;
                                                }
                                                else{
                                                  return  grey.withOpacity(0.3);
                                                }
                                              }
                                            else if(i==Board.boardBase){
                                              return grey.withOpacity(0.3);
                                            }
                                            else if(i==Board.boardBase+2){
                                              return grey.withOpacity(0.3);
                                            }
                                            else
                                         {
                                           return  Colors.transparent;
                                         }
                                            }(),
                                          borderRadius: BorderRadius.circular(25)
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 2.0),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                Vibration.vibrate(
                                                    amplitude: 10, duration: 50);
                                                if(i==Board.boardBase+2){
                                                  _resetboard();
                                                  return;
                                                }
                                                if (note) {
                                                  if(focussed==null) return;
                                                  if (i == Board.boardBase) {
                                                    setState(() {
                                                      removehint(focussed);
                                                    });
                                                  }
                                                  else if (i == Board.boardBase + 1) {
                                                    setState(() {
                                                      note = false;
                                                    });
                                                  }
                                                  else {
                                                    setState(() {
                                                      addtohint(focussed, i + 1);
                                                    });
                                                  }
                                                }
                                                else {
                                                  if (i == Board.boardBase) {
                                                    setState(() {
                                                      focussed.number = null;
                                                    });
                                                    _unlightano();
                                                  }
                                                  else if (i == Board.boardBase + 1) {
                                                    setState(() {
                                                      note = note ? false : true;
                                                    });
                                                  }
                                                  else {

                                                    setState(() {
                                                      if(focussed.hitnts.isNotEmpty){
                                                        for(int m=0;m<focussed.hitnts.length;m++){
                                                          focussed.hitnts[m]=0;
                                                        }
                                                      }
                                                      focussed.number = i + 1;
                                                      checkBoard();
                                                    });
                                                    _unlightano();
                                                    _ligthano(focussed);
                                                  }
                                                }
                                              },
                                              child: Center(
                                                child:(){
                                                  if(i == Board.boardBase)
                                                    {return Icon(Icons.delete,color: white,);}
                                                    else if(i==Board.boardBase+1){return Icon(Icons.edit,color: white,);}
                                                    else if(i==Board.boardBase+2){return Icon(Icons.refresh,color: white,);}
                                                    else {
                                                    return Text(
                                                        (i + 1).toString(),
                                                        style: GoogleFonts.lato(color: white,fontSize: 25),
                                                      );}
                                                }()
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                  },
                            ),
                                    ),
                                  ),
                                ),
                              ))
                        ]),

                Align(
                  alignment: Alignment.topCenter,
                  child:  Hero(
                    tag:"easy",
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                              begin:Alignment.topLeft ,
                              end: Alignment.bottomRight,
                              colors: [ animation["color2"],animation["color1"],animation["color2"],])),
                          child: Text("${(hr.toString().length==1?0:"")}${hr}:${(min.toString().length==1?0:"")}${min}:${(sec.toString().length==1?0:"")}${sec}",
                            style: GoogleFonts.lato(
                                fontSize: 15, color: white),
                          ),
                        ),
                      ),
                    ),
                  )
                ),
                Align(
                  alignment: Alignment.topRight,
                  child:  Padding(
                    padding: const EdgeInsets.only(top:30),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),),
                       child: IconButton(
                         icon: Icon(Icons.color_lens,size: 30,color: white,),
                         onPressed: (){
                           showDialog(context: context,
                           builder: (context){
                             return AlertDialog(
                               backgroundColor: Colors.transparent,
                               title: ColorPicker(
                                 pickerColor: bgcolor,
                                 onColorChanged: changeColor,
                                 showLabel: true,
                                 pickerAreaHeightPercent: 0.8,
                               ),
                             );
                           }
                           );
                         },
                       )
                    ),
                  )
                )  ,
                Align(
                  alignment: Alignment.topLeft,
                  child:  Padding(
                    padding: const EdgeInsets.only(top:40,left: 10),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text("New Game",style: TextStyle(fontSize: 10),),
                      onPressed: (){
                        createNewBoard();
                      },
                    ),
                  )
                )
          ]),
            );},
        ),
      ),
    );
  }


  _lightup(x,y){
    _unlightup();

        for(int z=0;z<9;z++)
          {
            setState(() {
              board.fields[z][x].lightened=true;
            });
          }
        for(int z=0;z<9;z++)
          {
            setState(() {
              board.fields[y][z].lightened=true;
            });
          }

        int n=x;
        while(n%3!=0){
          n=n-1;
        }

    int m;

       for(int i=n;i<n+3;i++){

         m=y;

   //for upper cells

    while(m%3!=0){
          setState(() {
            board.fields[m][i].lightened=true;
          });
          m=m-1;
        }
    setState(() {
      board.fields[m][i].lightened=true;
    });

    //for lower cell
     m=y;

    //for upper cells

    while((m+1)%3!=0){
      setState(() {
        board.fields[m][i].lightened=true;
      });
      m=m+1;
    }
    setState(() {
      board.fields[m][i].lightened=true;
    });
        }


        }
        _unlightup(){
    _unlightano();
        for(int z=0;z<9;z++)
          {
            for(int a=0;a<9;a++)
              {
                setState(() {
                  board.fields[z][a].lightened=false;
                });
              }

          }

        }

  void removehint(Field field) {
    if(field==null){return;}
    int index;
    if(field.hitnts.contains(0))
    {
      for(int i=0;i<field.hitnts.length;i++)
      {
        if(field.hitnts[i]==0){
          if(index!=null)
            {
              board.fields[field.y][field.x].hitnts[index]=0;
            }else{
            return;
          }
        }
        else{
          index=i;
        }
      }}
    else{
      field.hitnts[8]=0;
    }
  }

  void addtohint(Field field, int i) {

    setState(() {
      field.number=null;
    });
    if(field.hitnts.contains(0)){
      for(int a=0;a<9;a++){
        if(field.hitnts[a]==0){
          field.hitnts[a]=i;
          return;
        }
      }
    }else{
      field.hitnts[8]=i;
    }
  }


  _ligthano(Field field){
    if(field.number==null){
      return;
    }
    else{
      for(int a=0;a<Board.boardBase;a++){
        for(int b=0;b<Board.boardBase;b++){
         if(board.fields[a][b].number!=null){
           if(board.fields[a][b].number==field.number){
            setState(() {
              board.fields[a][b].selection=true;
            });
          }
         }
        }
      }
    }
  }

 _unlightano(){
    for(int a=0;a<Board.boardBase;a++){
        for(int b=0;b<Board.boardBase;b++){
            setState(() {
              board.fields[a][b].selection=false;
            });

        }
      }

  }

  void _resetboard() {
    _unlightup();
    for(int i=0;i<Board.boardBase;i++){
      for(int j=0;j<Board.boardBase;j++){
        if(!board.fields[i][j].initial){
          board.fields[i][j].number=null;
          for(int k=0;k<9;k++){
            board.fields[i][j].hitnts[k]=0;
          }
        }
      }
    }
    setState(() {
      board=board;
      focussed=null;
      hr=0;
      min=0;
      sec=0;
    });
  }

  void _createtimer() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
      prefs.setInt('hr', 0);
      prefs.setInt('min', 0);
      prefs.setInt('sec', 0);

      setState(() {
        min=0;
        hr=0;
        sec=0;
      });


  }
  void _settimer() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
      if(prefs.containsKey('hr')){

        setState(() {
          min=prefs.getInt('min');
          hr=prefs.getInt('hr');
          sec=prefs.getInt('sec');
        });

      }else{
        _createtimer();
      }

  }

  _savetimer()async{
    _timer.cancel();
    SharedPreferences prefs= await SharedPreferences.getInstance();
    prefs.setInt('hr', hr);
    prefs.setInt('min', min);
    prefs.setInt('sec', sec);
  }

  Timer _timer;
  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec, (Timer timer){
        if(!mounted) return;
        setState(() {
          sec=sec+1;
          if(sec==60){
            min=min+1;
            if(min==60){
              hr=hr+1;
              min=0;
            }
            sec=0;
          }

        },);},
    );
  }

  @override
  void dispose() {
    if(_timer!=null){
      _timer.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }

}

class LifecycleHandler extends WidgetsBindingObserver {
  LifecycleHandler({this.resumeCallBack, this.suspendingCallBack});

  final void Function() resumeCallBack;
  final void Function() suspendingCallBack;

//  @override
//  Future<bool> didPopRoute()

//  @override
//  void didHaveMemoryPressure()

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack();
        break;
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
  }

//  @override
//  void didChangeLocale(Locale locale)

//  @override
//  void didChangeTextScaleFactor()

//  @override
//  void didChangeMetrics();

//  @override
//  Future<bool> didPushRoute(String route)
}

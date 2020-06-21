import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:launcher_assist/launcher_assist.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var numberOfInstalledApps;
  var installedApps;
  var wallpaper;
  bool accessStorage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    accessStorage = false;

    // Get all apps
    LauncherAssist.getAllApps().then((apps) {
      setState(() {
        numberOfInstalledApps = apps.length;
        installedApps = apps;
      });
    });

    _handlePermissions().then((Map<Permission, PermissionStatus> value) {
      if (value[Permission.storage].isGranted) {
        // Get wallpaper as binary data
        LauncherAssist.getWallpaper().then((imageData) {
          setState(() {
            wallpaper = imageData;
            accessStorage = !accessStorage;
          });
        });
      } else {
        if (value[Permission.storage].isDenied) {
          //do something here
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (accessStorage) {
      setState(() {});
      print("set state called");
    }
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Launcher Assist'),
      ),
      body: WillPopScope(
        onWillPop: () => Future(() => false), //make back button disabled
        child: Stack(
          children: <Widget>[
            WallPaperContainer(wallpaper: wallpaper),
            installedApps != null
                ? ForeGroundWidget(installedApps: installedApps)
                : Container(),
          ],
        ),
      ),
    );
  }
}

class ForeGroundWidget extends StatefulWidget {
  final installedApps;

  ForeGroundWidget({this.installedApps});

  @override
  _ForeGroundWidgetState createState() => _ForeGroundWidgetState();
}

class _ForeGroundWidgetState extends State<ForeGroundWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> opacity;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    opacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FadeTransition(
      opacity: opacity,
      child: Container(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 0),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 40,
          physics: BouncingScrollPhysics(),
          children: List.generate(
            widget.installedApps != null ? widget.installedApps.length : 0,
            (index) {
              return GestureDetector(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      iconContain(index),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.installedApps[index]["label"],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                onTap: () {
                  LauncherAssist.launchApp(
                      widget.installedApps[index]["package"]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget iconContain(index) {
    try {
      return Image.memory(
        widget.installedApps[index]["icon"] != null
            ? widget.installedApps[index]["icon"]
            : Uint8List(0),
        width: 50.0,
        height: 50.0,
      );
    } catch (e) {
      return Container();
    }
  }
}

class WallPaperContainer extends StatelessWidget {
  final wallpaper;

  WallPaperContainer({this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Image.memory(
        wallpaper ?? Uint8List(0),
        fit: BoxFit.cover,
      ),
    );
  }
}

Future<Map<Permission, PermissionStatus>> _handlePermissions() async {
  // single permissions
//  if (await Permission.storage.request().isGranted) {
//    // Either the permission was already granted before or the user just granted it.
//    print("hello");
//  }
  //for multiple permissions
  Map<Permission, PermissionStatus> statuses = await [
//    Permission.location,
    Permission.storage,
  ].request();
  return statuses;
}

/*
new Column(
        children: <Widget>[
          new Text("Found $numberOfInstalledApps apps installed"),
          new RaisedButton(
              child: new Text("Launch Something"),
              onPressed: () {
                // Launch the first app available
                LauncherAssist.launchApp(installedApps[0]["package"]);
              }),
          wallpaper != null
              ? new Image.memory(wallpaper, fit: BoxFit.scaleDown)
              : new Center()
        ],
      ),
 */

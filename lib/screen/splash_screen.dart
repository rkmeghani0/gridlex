import 'package:flutter/material.dart';
import 'package:gridlex/main_old.dart';
import 'package:gridlex/util/color_resource.dart';
import 'package:gridlex/widget/app_logo.dart';
import 'package:gridlex/widget/custom_scaffold.dart';
import 'package:gridlex/widget/loading_animation.dart';
// import 'package:workmanager/workmanager.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    //_socketInitialize();

    // Workmanager().registerPeriodicTask(
    //   "1",
    //   myTask,
    //   frequency: Duration(minutes: 15),
    //   constraints: Constraints(
    //     networkType: NetworkType.connected,
    //   ),

    // );
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: ColorResource.PRIMARY,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: ColorResource.BACKGROUND_WHITE,
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              AppLogo(
                height: 300,
                width: 300,
              ),
              Spacer(),
              SizedBox(
                height: 50,
              ),
              LoadingAnimationIndicator(),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gridlex/authentication/authentication_bloc.dart';
import 'package:gridlex/authentication/authentication_state.dart';
import 'package:gridlex/screen/medical_form/bloc/medical_form_bloc.dart';
import 'package:gridlex/screen/medical_form/bloc/medical_form_event.dart';
import 'package:gridlex/screen/medical_form/medical_form.dart';
import 'package:gridlex/screen/splash_screen.dart';
import 'package:gridlex/util/color_resource.dart';
import 'package:gridlex/util/route_aware_widget.dart';

class AppRoutes {
  static const String SPLASH_SCREEN = "splash_screen";
  static const String MEDICAL_FORM_SCREEN = "medical_form_screen";
}

Route<dynamic>? getRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.SPLASH_SCREEN:
      return buildSplashScreen(settings);
    case AppRoutes.MEDICAL_FORM_SCREEN:
      return buildMedicalFormScreen(settings);
  }
  return null;
}

Route buildSplashScreen(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) =>
        addAuthBloc(context, PageBuilder.buildSplashScreen(settings)),
  );
}

Route buildMedicalFormScreen(RouteSettings settings) {
  return MaterialPageRoute(
    settings: RouteSettings(name: AppRoutes.MEDICAL_FORM_SCREEN),
    builder: (context) =>
        addAuthBloc(context, PageBuilder.buildMedicalFormScreen(settings)),
  );
}

class PageBuilder {
  static Widget buildSplashScreen(RouteSettings settings) {
    return SplashScreen();
  }

  static Widget buildMedicalFormScreen(RouteSettings settings) {
    return BlocProvider<MedicalFormBloc>(
      create: (context) {
        // MainUtils().dynamicLinkHelper.link_listener(context);
        return MedicalFormBloc(BlocProvider.of<AuthenticationBloc>(context))
          ..add(MedicalFormInitialEvent());
      },
      child: RouteAwareWidget(AppRoutes.MEDICAL_FORM_SCREEN,
          child: MedicalFormScreen()),
    );
  }
}

addAuthBloc(BuildContext context, Widget widget) {
  return BlocListener<AuthenticationBloc, AuthenticationState>(
    bloc: BlocProvider.of<AuthenticationBloc>(context),
    listener: (BuildContext context, AuthenticationState state) {
      if (state is AuthenticationSplashScreen) {
        Navigator.pushReplacementNamed(context, AppRoutes.SPLASH_SCREEN);
      }
      if (state is AuthenticationMedicalScreenSate) {
        Navigator.pushReplacementNamed(context, AppRoutes.MEDICAL_FORM_SCREEN);
      }
    },
    child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
      bloc: BlocProvider.of<AuthenticationBloc>(context),
      builder: (context, state) {
        if (state is AuthenticationUninitializedState ||
            state is AuthenticationLoadingState) {
          return Container(color: ColorResource.BACKGROUND_WHITE);
        } else {
          return widget;
        }
      },
    ),
  );
}

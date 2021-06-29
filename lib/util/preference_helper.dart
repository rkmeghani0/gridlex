import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  // get a current user token
  static Future<String?> getToken() async {
    String? value;
    SharedPreferences pref = await SharedPreferences.getInstance();
    value = pref.get("token") as String?;
    if (value?.isEmpty ?? true) {
      return null;
    } else {
      return value;
    }
  }

  // save current user token
  static saveToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (token == null) return;
    pref.setString("token", token);
  }

  // // save current user
  // static saveUser(User user) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   if (user != null) {
  //     String userObj = jsonEncode(user.toJson());
  //     pref.setString("User", userObj);
  //   }
  // }

  // //Save Company Data
  // static saveCompany(Company company) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   if (company != null) {
  //     String userObj = jsonEncode(company.toJson());
  //     pref.setString("Company", userObj);
  //   }
  // }

  // Clear a storage
  static clearStorage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    await pref.clear();
  }

  // Clear previous user history
  static clearPreviousUserHistory() async {
    //SharedPreferences pref = await SharedPreferences.getInstance();
    //await pref.clear();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("previousUserToken", "");
    pref.setString("previousUser", "");
  }

  static Map<String, dynamic> _parseAndDecode(String response) {
    return jsonDecode(response);
  }

  static Future<Map<String, dynamic>> _parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  static Future prefSetInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  static Future<int?> prefGetInt(String key, int intDef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt(key) != null) {
      return prefs.getInt(key);
    } else {
      return intDef;
    }
  }

  //bool
  static Future prefSetBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<bool?> prefGetBool(String key, bool boolDef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(key) != null) {
      return prefs.getBool(key);
    } else {
      return boolDef;
    }
  }

  //String
  static Future prefSetString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String?> prefGetString(String key, String strDef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) != null) {
      return prefs.getString(key);
    } else {
      return strDef;
    }
  }

  //Double
  static Future prefSetDouble(String key, double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }

  static Future<double?> prefGetDouble(String key, double douDef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble(key) != null) {
      return prefs.getDouble(key);
    } else {
      return douDef;
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gridlex/authentication/authentication_bloc.dart';
import 'package:gridlex/screen/medical_form/bloc/medical_form_event.dart';
import 'package:gridlex/screen/medical_form/bloc/medical_form_state.dart';
import 'package:gridlex/util/string_resource.dart';
import 'package:gridlex/util/validator.dart';
import 'package:hand_signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalFormBloc extends Bloc<MedicalFormEvent, MedicalFormState> {
  AuthenticationBloc authBloc;
  TextEditingController txtFirstNameEditingController = TextEditingController();
  TextEditingController txtLastNameEditingController = TextEditingController();
  TextEditingController txtInstituteEditingController = TextEditingController();
  TextEditingController txtDepartmentEditingController =
      TextEditingController();
  TextEditingController txtInstituteAdd1EditingController =
      TextEditingController();
  TextEditingController txtInstituteAdd2EditingController =
      TextEditingController();
  TextEditingController txtCityEditingController = TextEditingController();
  TextEditingController txtZipcodeEditingController = TextEditingController();
  TextEditingController txtPhoneEditingController = TextEditingController();
  TextEditingController txtFaxEditingController = TextEditingController();
  TextEditingController txtEmailEditingController = TextEditingController();
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode instituteFocusNode = FocusNode();
  FocusNode departmentFocusNode = FocusNode();
  FocusNode add1FocusNode = FocusNode();
  FocusNode add2FocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode zipFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode faxFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  String? firstNameErrorText;
  String? lastNameErrorText;
  String? instituteErrorText;
  String? departmentErrorText;
  String? add1ErrorText;
  String? add2ErrorText;
  String? cityErrorText;
  String? zipErrorText;
  String? phoneErrorText;
  String? faxErrorText;
  String? emailErrorText;
  String dessignationType = "MD";
  String selectedState = "Test1";
  List<String> lstState = ["Test1", "Test2", "Test3"];

  bool? mg10Roszet = false;
  bool? mg20Roszet = false;
  TextEditingController txtReqDescEditingController = TextEditingController();
  TextEditingController txtPatientEditingController = TextEditingController();
  FocusNode reqDescFocusNode = FocusNode();
  FocusNode patientFocusNode = FocusNode();
  String? reqDescErrorText;
  String? patientErrorText;
  DateTime? selectedDateofrequest = DateTime.now();
  DateTime? selectedDateofBirth;
  String? rdbEventExp;
  String? rdbGender;
  bool chkMethodResFax = false;
  bool chkMethodResMail = false;
  bool chkMethodResEmail = false;
  bool chkMethodResPhone = false;
  File? fileSignature;

  TextEditingController txtRepNameEditingController = TextEditingController();
  TextEditingController txtRepTypeEditingController = TextEditingController();
  TextEditingController txtRepTerriotoryEditingController =
      TextEditingController();
  TextEditingController txtRepTeleNumbEditingController =
      TextEditingController();
  FocusNode repNameFocusNode = FocusNode();
  FocusNode repTypeFocusNode = FocusNode();
  FocusNode repTerriotoryFocusNode = FocusNode();
  FocusNode repTeleNumbFocusNode = FocusNode();
  String? repNameErrorText;
  String? repTypeErrorText;
  String? repTerriotoryErrorText;
  String? repTeleNumbErrorText;
  String selectedCountryCode = "+1";
  List<String> lstCountryCode = ["+1", "+91", "+443"];
  String? designationErrorText;
  String? productErrorText;
  String? dobErrorText;
  String? genderErrorText;
  String? dateOfRequestErrorText;
  String? signatureErrorText;
  HandSignatureControl handSignatureControl = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  final DateFormat onlyDateformatter = DateFormat('dd-MM-yyyy');
  MedicalFormBloc(this.authBloc) : super(MedicalFormInitialState());
  File? tempFile;
  @override
  Stream<MedicalFormState> mapEventToState(MedicalFormEvent event) async* {
    if (event is MedicalFormInitialEvent) {
      resetAllErrorText();

      yield MedicalFormInitialState();
    }
    if (event is DesignationChooseEvent) {
      dessignationType = event.value;
      yield MedicalFormInitialState();
    }
    if (event is StateClickEvent) {
      selectedState = event.value;
      yield MedicalFormInitialState();
    }
    if (event is ScreenUiChangeEvent) {
      yield MedicalFormInitialState();
    }
    if (event is DateofBirthUpdateEvent) {
      selectedDateofBirth = event.datetime;
      yield MedicalFormInitialState();
    }
    if (event is DateofRequestUpdateEvent) {
      selectedDateofrequest = event.datetime;
      yield MedicalFormInitialState();
    }
    if (event is AdverseEventExpChangeEvent) {
      rdbEventExp = event.value;
      yield MedicalFormInitialState();
    }
    if (event is GenderChangeEvent) {
      rdbGender = event.value;
      yield MedicalFormInitialState();
    }
    if (event is CountryCodeClickEvent) {
      selectedCountryCode = event.value;
      yield MedicalFormInitialState();
    }
    if (event is FormSaveButtonPressedEvent) {
      yield MedicalFormLoadingState();
      resetAllErrorText();
      var state = Validator.validate(txtFirstNameEditingController.text,
          rules: ["required"]);
      if (!state.status) {
        firstNameErrorText =
            StringResource.REQUESTOR_FIRST_NAME + " " + state.error!;
        yield MedicalFormInitialState(error: firstNameErrorText);
        return;
      }
      state = Validator.validate(txtLastNameEditingController.text,
          rules: ["required"]);
      if (!state.status) {
        lastNameErrorText =
            StringResource.REQUESTOR_LAST_NAME + " " + state.error!;
        yield MedicalFormInitialState(error: lastNameErrorText);
        return;
      }
      // if (dessignationType == null) {
      //   designationErrorText =
      //       StringResource.DESIGNATION + " " + StringResource.IS_REQUIRED;
      //   yield MedicalFormInitialState(error: designationErrorText);
      //   return;
      // } else if (dessignationType.isEmpty) {
      //   designationErrorText =
      //       StringResource.DESIGNATION + " " + StringResource.IS_REQUIRED;
      //   yield MedicalFormInitialState(error: designationErrorText);
      //   return;
      // }
      // state = Validator.validate(txtInstituteEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   instituteErrorText = StringResource.INSTITUTE + " " + state.error!;
      //   yield MedicalFormInitialState(error: lastNameErrorText);
      //   return;
      // }
      // state = Validator.validate(txtDepartmentEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   departmentErrorText = StringResource.DEPARTMENT + " " + state.error!;
      //   yield MedicalFormInitialState(error: departmentErrorText);
      //   return;
      // }
      // state = Validator.validate(txtInstituteAdd1EditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   add1ErrorText = StringResource.INSTITUTE_ADD_1 + " " + state.error!;
      //   yield MedicalFormInitialState(error: add1ErrorText);
      //   return;
      // }
      // state = Validator.validate(txtCityEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   cityErrorText = StringResource.CITY + " " + state.error!;
      //   yield MedicalFormInitialState(error: cityErrorText);
      //   return;
      // }
      // state = Validator.validate(txtZipcodeEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   zipErrorText = StringResource.ZIP + " " + state.error!;
      //   yield MedicalFormInitialState(error: zipErrorText);
      //   return;
      // }
      // if (mg10Roszet == false && mg20Roszet == false) {
      //   productErrorText =
      //       StringResource.CHOOSE_PRODUCTS + " " + StringResource.IS_REQUIRED;
      //   yield MedicalFormInitialState(error: productErrorText);
      //   return;
      // }
      // state = Validator.validate(txtPatientEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   patientErrorText = StringResource.PATIENT_NAME + " " + state.error!;
      //   yield MedicalFormInitialState(error: patientErrorText);
      //   return;
      // }
      // if (selectedDateofBirth == null) {
      //   dobErrorText = StringResource.DOB + " " + StringResource.IS_REQUIRED;
      //   yield MedicalFormInitialState(error: dobErrorText);
      //   return;
      // }
      // if (selectedDateofrequest == null) {
      //   dateOfRequestErrorText =
      //       StringResource.DATE_OF_REQUEST + " " + StringResource.IS_REQUIRED;
      //   yield MedicalFormInitialState(error: dateOfRequestErrorText);
      //   return;
      // }
      // state = Validator.validate(txtRepNameEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   repNameErrorText =
      //       StringResource.REPRESENTATIVE_NAME + " " + state.error!;
      //   yield MedicalFormInitialState(error: repNameErrorText);
      //   return;
      // }
      // state = Validator.validate(txtRepTypeEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   repTypeErrorText =
      //       StringResource.REPRESENTATIVE_TYPE + " " + state.error!;
      //   yield MedicalFormInitialState(error: repTypeErrorText);
      //   return;
      // }
      // state = Validator.validate(txtRepTerriotoryEditingController.text,
      //     rules: ["required"]);
      // if (!state.status) {
      //   repTerriotoryErrorText =
      //       StringResource.REPRESENTATIVE_TERRITORY_NUMBER + " " + state.error!;
      //   yield MedicalFormInitialState(error: repTerriotoryErrorText);
      //   return;
      // }
      // state =
      //     Validator.validate(txtEmailEditingController.text, rules: ["email"]);
      // if (!state.status) {
      //   emailErrorText = StringResource.EMAIL + " " + state.error!;
      //   yield MedicalFormInitialState(error: emailErrorText);
      //   return;
      // }
      //print(handSignatureControl.isFilled);
      String mainFilePath = '';
      String mainFileName = '';
      if (!handSignatureControl.isFilled) {
        signatureErrorText =
            StringResource.HEALTH_SIGNATURE + " " + StringResource.IS_REQUIRED;
        yield MedicalFormInitialState(error: signatureErrorText);
        return;
      } else {
        final directoryName = "Gridlex";

        Directory? directory = await getExternalStorageDirectory();
        String? path = directory?.path;
        await Directory('$path/$directoryName').create(recursive: true);
        var random = new Random();
        var filename = "gridlex_" + random.nextInt(100000).toString() + ".png";
        mainFileName = filename;
        ByteData? pngImage = await handSignatureControl.toImage();
        String filePath = '$path/$directoryName/' + filename;
        tempFile =
            await File(filePath).writeAsBytes(pngImage!.buffer.asUint8List());
        mainFilePath = filePath;
        // print(filePath);
      }
      var product = '';
      if (mg10Roszet!) {
        product = "mg10Roszet";
      }
      if (mg20Roszet!) {
        if (product.isNotEmpty) {
          product = ",";
        }
        product = "mg20Roszet";
      }
      var responsemethod = '';
      if (chkMethodResEmail) {
        responsemethod = 'Email';
      }
      if (chkMethodResFax) {
        if (responsemethod.isNotEmpty) {
          responsemethod = ',';
        }
        responsemethod = 'Fax';
      }
      if (chkMethodResMail) {
        if (responsemethod.isNotEmpty) {
          responsemethod = ',';
        }
        responsemethod = 'Mail';
      }
      if (chkMethodResPhone) {
        if (responsemethod.isNotEmpty) {
          responsemethod = ',';
        }
        responsemethod = 'Phone';
      }
      var mainFormData = {
        "add1": txtInstituteAdd1EditingController.text,
        "add2": txtInstituteAdd2EditingController.text,
        "adverse_exp": rdbEventExp,
        "city": txtCityEditingController.text,
        "date_of_request":
            onlyDateformatter.format(selectedDateofrequest ?? DateTime.now()),
        "datetime": DateTime.now().toString(),
        "department": txtDepartmentEditingController.text,
        "designation": dessignationType,
        "dob": onlyDateformatter.format(selectedDateofBirth ?? DateTime.now()),
        "email": txtEmailEditingController.text,
        "fax": txtFaxEditingController.text,
        "first_name": txtFirstNameEditingController.text,
        "gender": rdbGender,
        "institute": txtInstituteEditingController.text,
        "last_name": txtLastNameEditingController.text,
        "patient_name": txtPatientEditingController.text,
        "phone": txtPhoneEditingController.text,
        "product": product,
        "rep_country_code": selectedCountryCode,
        "rep_name": txtRepNameEditingController.text,
        "rep_tele_numb": txtRepTeleNumbEditingController.text,
        "rep_terriotory": txtRepTerriotoryEditingController.text,
        "rep_type": txtRepTypeEditingController.text,
        "response_method": responsemethod,
        "signature": mainFileName.isNotEmpty
            ? ("https://firebasestorage.googleapis.com/v0/b/gridlex-6e586.appspot.com/o/images%2F" +
                mainFileName)
            : "",
        "state": selectedState,
        "zip": txtZipcodeEditingController.text,
      };
      try {
        var isAvailable = await isInternetAvailable();
        if (isAvailable) {
          DocumentReference? ref = await FirebaseFirestore.instance
              .collection("medicalgridlex")
              .add(mainFormData);
          if (ref != null) {
            if (mainFilePath != null) {
              if (mainFilePath.isNotEmpty) {
                final _firebaseStorage = FirebaseStorage.instance;
                File fileTemp = await File(mainFilePath.toString()).create();
                // tempFile = fileTemp;
                var filename = mainFilePath.toString().split('/').last;
                var snapshot = await _firebaseStorage
                    .ref()
                    .child('images/' + filename)
                    .putFile(fileTemp);
              }
            }
            yield MedicalSuccessState("Form submitted Successfully");
          } else {
            yield MedicalFormInitialState(
                error: StringResource.SOMETHING_WENT_WRONG);
          }
        } else {
          mainFormData["image"] = mainFilePath;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (prefs.getString("lstFormData") != null) {
            print("Form Session ===>");
            var lstFormData = prefs.getString("lstFormData");
            List<dynamic> lstJsonData = jsonDecode(lstFormData ?? '');
            lstJsonData.add(jsonEncode(mainFormData));
            prefs.setString("lstFormData", jsonEncode(lstJsonData));
            print(jsonEncode(lstJsonData));
          } else {
            print("Not Form Session ===>");
            List<String> lstJsonData = [];
            lstJsonData.add(jsonEncode(mainFormData));
            print(jsonEncode(lstJsonData));
            prefs.setString("lstFormData", jsonEncode(lstJsonData));
          }
          yield MedicalSuccessState(
              "Form Successfully Saved Locally. Will Upload to the server once the internet connection is back.");
          print("Internet not Available");
        }
      } catch (e) {
        print(e);
        yield MedicalFormInitialState(error: e.toString());
      }
      yield MedicalFormInitialState();
    }
  }

  Future<bool> isInternetAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      return true;
    } else {
      return false;
    }
  }

  void resetAllErrorText() {
    repNameErrorText = null;
    repTypeErrorText = null;
    repTerriotoryErrorText = null;
    repTeleNumbErrorText = null;
    reqDescErrorText = null;
    patientErrorText = null;
    firstNameErrorText = null;
    lastNameErrorText = null;
    instituteErrorText = null;
    departmentErrorText = null;
    add1ErrorText = null;
    add2ErrorText = null;
    cityErrorText = null;
    zipErrorText = null;
    phoneErrorText = null;
    faxErrorText = null;
    emailErrorText = null;
    designationErrorText = null;
    productErrorText = null;
    dobErrorText = null;
    genderErrorText = null;
    dateOfRequestErrorText = null;
    signatureErrorText = null;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gridlex/main_old.dart';
import 'package:gridlex/screen/medical_form/bloc/medical_form_bloc.dart';
import 'package:gridlex/screen/medical_form/bloc/medical_form_event.dart';
import 'package:gridlex/screen/medical_form/bloc/medical_form_state.dart';
import 'package:gridlex/util/app_utils.dart';
import 'package:gridlex/util/color_resource.dart';
import 'package:gridlex/util/custom_button.dart';
import 'package:gridlex/util/font.dart';
import 'package:gridlex/util/string_resource.dart';
import 'package:gridlex/widget/common_widget.dart';
import 'package:gridlex/widget/custom_text.dart';
import 'package:gridlex/widget/loading_animation.dart';
import 'package:gridlex/widget/text_form_field.dart';
import 'package:hand_signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalFormScreen extends StatefulWidget {
  @override
  _MedicalFormScreenState createState() => _MedicalFormScreenState();
}

class _MedicalFormScreenState extends State<MedicalFormScreen> {
  MedicalFormBloc? medicalFormBloc;
  final DateFormat onlyDateformatter = DateFormat('dd-MM-yyyy');
  @override
  void initState() {
    super.initState();
    medicalFormBloc = BlocProvider.of<MedicalFormBloc>(context);
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => buildAfterComplete(context));
    // executePreviousForm();
  }

  // void executePreviousForm() async {
  //   // Step 1:  Configure BackgroundFetch as usual.
  //   int status = await BackgroundFetch.configure(
  //       BackgroundFetchConfig(minimumFetchInterval: 15), (String taskId) async {
  //     // <-- Event callback.
  //     // This is the fetch-event callback.
  //     print("[BackgroundFetch] taskId: $taskId");

  //     // Use a switch statement to route task-handling.
  //     switch (taskId) {
  //       case 'com.example.gridlex':
  //         print("Received custom task");
  //         break;
  //       default:
  //         print("Default fetch task");
  //     }
  //     // Finish, providing received taskId.
  //     BackgroundFetch.finish(taskId);
  //   }, (String taskId) async {
  //     // <-- Event timeout callback
  //     // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
  //     print("[BackgroundFetch] TIMEOUT taskId: $taskId");
  //     BackgroundFetch.finish(taskId);
  //   });

  //   print('[BackgroundFetch] configure success: $status');
  //   BackgroundFetch.scheduleTask(TaskConfig(
  //     taskId: "com.example.gridlex",
  //     delay: 150000,
  //     periodic: true,
  //   ));
  //   BackgroundFetch.start().then((int status) {
  //     print('[BackgroundFetch] start success: $status');
  //   }).catchError((e) {
  //     print('[BackgroundFetch] start FAILURE: $e');
  //   });
  // }

  buildAfterComplete(BuildContext context) {
    // executePreviousForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // backgroundColor: ColorResource.PRIMARY,
        child: Container(
          child: layout(),
          color: ColorResource.BACKGROUND_WHITE,
        ),
      ),
    );
  }

  Widget layout() {
    return BlocListener<MedicalFormBloc, MedicalFormState>(
      listener: (BuildContext context, MedicalFormState state) {
        if (state is MedicalFormInitialState) {
          if (state.error != null) {
            AppUtils.showToast(state.error!);
          }
        }
        if (state is MedicalSuccessState) {
          AppUtils.hideKeyBoard(context);
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: CustomText(
                "Success",
                fontSize: 17,
                textAlign: TextAlign.center,
                font: Font.SfUiSemibold,
              ),
              content: CustomText(
                state.msg,
                fontSize: 12,
                textAlign: TextAlign.center,
                font: Font.SfUiSemibold,
              ),
              actions: [
                CupertinoDialogAction(
                  child: CustomText(
                    "Close",
                    fontSize: 17,
                    font: Font.SfUiSemibold,
                    color: ColorResource.BRIGHT_BLUE_007AFF,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }
      },
      bloc: medicalFormBloc,
      child: BlocBuilder<MedicalFormBloc, MedicalFormState>(
        bloc: medicalFormBloc,
        builder: (BuildContext context, MedicalFormState state) {
          return AbsorbPointer(
            absorbing: state is MedicalFormLoadingState,
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (_) {
                    AppUtils.hideKeyBoard(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildAppBar(),
                      Expanded(
                        child: Container(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildContactInfo(),
                                  buildUnsolicitedInfo(),
                                  buildRepresentativeInfo(),
                                  buildSaveButton(),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is MedicalFormLoadingState)
                  LoadingAnimationIndicator()
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildContactInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        CustomText(
          "A. Healthcare Professional Contact Information:",
          fontSize: 16,
          font: Font.SfUiBold,
        ),
        Divider(),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: StringResource.REQUESTOR_FIRST_NAME,
          textEditingController: medicalFormBloc?.txtFirstNameEditingController,
          errorText: medicalFormBloc?.firstNameErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.firstNameFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: StringResource.REQUESTOR_LAST_NAME,
          textEditingController: medicalFormBloc?.txtLastNameEditingController,
          errorText: medicalFormBloc?.lastNameErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.lastNameFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildRadioDesignation(),
        SizedBox(
          height: 20,
        ),
        buildTextBox(
          fieldName: "Institution/Office",
          textEditingController: medicalFormBloc?.txtInstituteEditingController,
          errorText: medicalFormBloc?.instituteErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.instituteFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Department",
          textEditingController:
              medicalFormBloc?.txtDepartmentEditingController,
          errorText: medicalFormBloc?.departmentErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.departmentFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Institution/Office Address Line",
          textEditingController:
              medicalFormBloc?.txtInstituteAdd1EditingController,
          errorText: medicalFormBloc?.add1ErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.add1FocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Institution/Office Address Line 2",
          textEditingController:
              medicalFormBloc?.txtInstituteAdd2EditingController,
          errorText: medicalFormBloc?.add2ErrorText,
          isRequired: false,
          focusNode: medicalFormBloc?.add2FocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildState(),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "City",
          textEditingController: medicalFormBloc?.txtCityEditingController,
          errorText: medicalFormBloc?.cityErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.cityFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Zip",
          textEditingController: medicalFormBloc?.txtZipcodeEditingController,
          errorText: medicalFormBloc?.zipErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.zipFocusNode,
          isNumber: true,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Phone Number",
          textEditingController: medicalFormBloc?.txtPhoneEditingController,
          errorText: medicalFormBloc?.phoneErrorText,
          isRequired: false,
          focusNode: medicalFormBloc?.phoneFocusNode,
          isNumber: true,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Fax Number",
          textEditingController: medicalFormBloc?.txtFaxEditingController,
          errorText: medicalFormBloc?.faxErrorText,
          isRequired: false,
          focusNode: medicalFormBloc?.faxFocusNode,
          isNumber: true,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Email",
          textEditingController: medicalFormBloc?.txtEmailEditingController,
          errorText: medicalFormBloc?.emailErrorText,
          isRequired: false,
          focusNode: medicalFormBloc?.emailFocusNode,
          isEmail: true,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget buildState() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerTitle(
            title: "State:",
            isRequired: true,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: ColorResource.GREY_PALE_F2F4F8,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text("Select State"),
              value: medicalFormBloc?.selectedState,
              onChanged: (String? value) {
                medicalFormBloc?.add(StateClickEvent(value ?? ""));
              },
              underline: Container(),
              items: medicalFormBloc?.lstState.map((String user) {
                return DropdownMenuItem<String>(
                  value: user,
                  child: Text(
                    user,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.center,
        child: CustomButton(
          "Save",
          borderWidth: 1,
          buttonWidth: 150,
          borderColor: ColorResource.PRIMARY,
          borderRadius: 8,
          color: Colors.transparent,
          onPressed: onSaveButtonPressed,
          buttonTextColor: ColorResource.PRIMARY,
          buttonTextSize: 16,
          verticalPadding: 10,
          horizontalPadding: 50,
        ),
      ),
    );
  }

  onSaveButtonPressed() {
    medicalFormBloc?.add(FormSaveButtonPressedEvent());
  }

  Widget buildRadioDesignation() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(
            title: StringResource.DESIGNATION,
            isRequired: true,
          ),
          SizedBox(
            height: 30,
            child: ListTile(
              title: CustomText('MD'),
              leading: Radio(
                value: "MD",
                groupValue: medicalFormBloc?.dessignationType,
                onChanged: (String? value) {
                  if (value != null) {
                    medicalFormBloc?.add(DesignationChooseEvent(value));
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: ListTile(
              title: CustomText('DO'),
              leading: Radio(
                value: "DO",
                groupValue: medicalFormBloc?.dessignationType,
                onChanged: (String? value) {
                  if (value != null) {
                    medicalFormBloc?.add(DesignationChooseEvent(value));
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: ListTile(
              title: CustomText('NP'),
              leading: Radio(
                value: "NP",
                groupValue: medicalFormBloc?.dessignationType,
                onChanged: (String? value) {
                  if (value != null) {
                    medicalFormBloc?.add(DesignationChooseEvent(value));
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: ListTile(
              title: CustomText('PA'),
              leading: Radio(
                value: "PA",
                groupValue: medicalFormBloc?.dessignationType,
                onChanged: (String? value) {
                  if (value != null) {
                    medicalFormBloc?.add(DesignationChooseEvent(value));
                  }
                },
              ),
            ),
          ),
          if (medicalFormBloc?.designationErrorText != null)
            SizedBox(
              height: 10,
            ),
          if (medicalFormBloc?.designationErrorText != null)
            CustomText(
              medicalFormBloc?.designationErrorText ?? "",
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget buildTextBox({
    @required TextEditingController? textEditingController,
    @required String? fieldName,
    @required FocusNode? focusNode,
    FocusNode? nextFocusNode,
    bool isRequired = false,
    bool isNextDone = false,
    String? errorText,
    Function? onSubmitFunc,
    int? minLines,
    String? hintText,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerTitle(
          title: fieldName,
          isRequired: isRequired,
        ),
        SizedBox(
          height: 2,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: ColorResource.GREY_PALE_F2F4F8,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormFieldWidget(
            controller: textEditingController,
            hintText: hintText == null ? ("Enter a " + fieldName!) : hintText,
            textColor: ColorResource.PRIMARY,
            focusNode: focusNode,
            primaryColor: ColorResource.PRIMARY,
            textInputType: isEmail
                ? TextInputType.emailAddress
                : isNumber
                    ? TextInputType.number
                    : TextInputType.text,
            // textInputType: TextInputType.numberWithOptions(decimal: true),
            actionKeyboard:
                (isNextDone) ? TextInputAction.next : TextInputAction.done,
            enabledBorderColor: Colors.transparent,
            focusedBorderColor: Colors.transparent,
            lstTextInputFormatter: isNumber
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                    // LengthLimitingTextInputFormatter(5),
                  ]
                : null,
            onValueChanged: (value) {
              //addProductScreenBloc.add(AddDiscountValueChangeEvent(value));
            },
            borderUnderlineColor: Colors.transparent,
            hintTextSize: 14,
            inputTextSize: 14,
            minLines: minLines,
            onSubmitField: (value) {
              if (onSubmitFunc != null) onSubmitFunc();
            },
          ),
        ),
        SizedBox(
          height: 2,
        ),
        if (errorText != null)
          if (errorText.isNotEmpty)
            CustomText(
              errorText,
              color: Colors.red,
            ),
      ],
    );
  }

  Widget buildUnsolicitedInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        CustomText(
          "B. Unsolicited Information Request:",
          fontSize: 16,
          font: Font.SfUiBold,
        ),
        Divider(),
        SizedBox(
          height: 10,
        ),
        buildProductCheckBox(),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Request Description:",
          textEditingController: medicalFormBloc?.txtReqDescEditingController,
          errorText: medicalFormBloc?.reqDescErrorText,
          isRequired: false,
          minLines: 3,
          focusNode: medicalFormBloc?.reqDescFocusNode,
          hintText: "Description",
        ),
        Divider(),
        SizedBox(
          height: 10,
        ),
        buildRadioAdverseExp(),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Patient Name",
          textEditingController: medicalFormBloc?.txtPatientEditingController,
          errorText: medicalFormBloc?.patientErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.patientFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildDobDate(),
        SizedBox(
          height: 10,
        ),
        buildDateofRequestDate(),
        SizedBox(
          height: 10,
        ),
        buildRadioGender(),
        SizedBox(
          height: 10,
        ),
        buildMethodResponse(),
        SizedBox(
          height: 10,
        ),
        buildSignatureArea(),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget buildSignatureArea() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(
            title: "Health Care professional's Signature",
            isRequired: true,
          ),
          AspectRatio(
            aspectRatio: 2.0,
            child: Stack(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints.expand(),
                  color: Colors.grey[300],
                  child: HandSignaturePainterView(
                    control: medicalFormBloc?.handSignatureControl ??
                        HandSignatureControl(
                          threshold: 3.0,
                          smoothRatio: 0.65,
                          velocityRange: 2.0,
                        ),
                    type: SignatureDrawType.shape,
                  ),
                ),
                CustomPaint(
                  painter: DebugSignaturePainterCP(
                    control: medicalFormBloc?.handSignatureControl ??
                        HandSignatureControl(
                          threshold: 3.0,
                          smoothRatio: 0.65,
                          velocityRange: 2.0,
                        ),
                    cp: false,
                    cpStart: false,
                    cpEnd: false,
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   //constraints: BoxConstraints.expand(),
          //   width: MediaQuery.of(context).size.width,
          //   color: Colors.white,
          //   child: HandSignaturePainterView(
          //     control: medicalFormBloc?.handSignatureControl ??
          //         HandSignatureControl(
          //           threshold: 3.0,
          //           smoothRatio: 0.65,
          //           velocityRange: 2.0,
          //         ),
          //     color: Colors.black,
          //     width: 300.0,
          //     maxWidth: 300.0,
          //     type: SignatureDrawType.shape,
          //   ),
          // ),
          if (medicalFormBloc?.signatureErrorText != null)
            SizedBox(
              height: 10,
            ),
          if (medicalFormBloc?.signatureErrorText != null)
            CustomText(
              medicalFormBloc?.signatureErrorText ?? "",
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget buildMethodResponse() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(
            title: "Preferred Method of Response",
            isRequired: true,
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              checkbox(
                title: "Fax",
                value: medicalFormBloc?.chkMethodResFax,
                onClickListner: (bool? val) {
                  if (val != null) {
                    medicalFormBloc?.chkMethodResFax = val;
                    medicalFormBloc?.add(ScreenUiChangeEvent());
                  }
                },
              ),
              checkbox(
                title: "Mail",
                value: medicalFormBloc?.chkMethodResMail,
                onClickListner: (bool? val) {
                  if (val != null) {
                    medicalFormBloc?.chkMethodResMail = val;
                    medicalFormBloc?.add(ScreenUiChangeEvent());
                  }
                },
              ),
              checkbox(
                title: "Email",
                value: medicalFormBloc?.chkMethodResEmail,
                onClickListner: (bool? val) {
                  if (val != null) {
                    medicalFormBloc?.chkMethodResEmail = val;
                    medicalFormBloc?.add(ScreenUiChangeEvent());
                  }
                },
              ),
              checkbox(
                title: "Phone",
                value: medicalFormBloc?.chkMethodResPhone,
                onClickListner: (bool? val) {
                  if (val != null) {
                    medicalFormBloc?.chkMethodResPhone = val;
                    medicalFormBloc?.add(ScreenUiChangeEvent());
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildRadioGender() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(
            title: "Gender",
            isRequired: true,
          ),
          SizedBox(
            height: 10,
          ),
          radioButton(
            groupValue: medicalFormBloc?.rdbGender,
            value: "male",
            title: "Male",
            onClickListner: (val) {
              medicalFormBloc?.add(GenderChangeEvent(val.toString()));
            },
          ),
          SizedBox(
            height: 5,
          ),
          radioButton(
            groupValue: medicalFormBloc?.rdbGender,
            value: "female",
            title: "Female",
            onClickListner: (val) {
              medicalFormBloc?.add(GenderChangeEvent(val.toString()));
            },
          ),
          SizedBox(
            height: 5,
          ),
          radioButton(
            groupValue: medicalFormBloc?.rdbGender,
            value: "other",
            title: "Other",
            onClickListner: (val) {
              medicalFormBloc?.add(GenderChangeEvent(val.toString()));
            },
          ),
        ],
      ),
    );
  }

  Widget buildRadioAdverseExp() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(
            title: "Please Check One",
            isRequired: false,
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              medicalFormBloc?.add(DesignationChooseEvent("not"));
            },
            child: ListTile(
              title: CustomText(
                  'This inquiry does not represent an adverse event experienced by a patient'),
              leading: SizedBox(
                height: 20,
                width: 20,
                child: Radio(
                  value: "not",
                  groupValue: medicalFormBloc?.dessignationType,
                  onChanged: (String? value) {
                    if (value != null) {
                      medicalFormBloc?.add(DesignationChooseEvent(value));
                    }
                  },
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              medicalFormBloc?.add(DesignationChooseEvent("allow"));
            },
            child: ListTile(
              title: CustomText(
                  'This inquiry represent an adverse event experienced by a patient'),
              leading: SizedBox(
                height: 20,
                width: 20,
                child: Radio(
                  value: "allow",
                  groupValue: medicalFormBloc?.dessignationType,
                  onChanged: (String? value) {
                    if (value != null) {
                      medicalFormBloc?.add(DesignationChooseEvent(value));
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDobDate() {
    return InkWell(
      onTap: () {
        AppUtils.hideKeyBoard(context);
        showCupertinoModalPopup(
            context: context,
            builder: (ctx) => showDateTimePicker(
                isOnlyDate: true,
                context: ctx,
                mainTime: medicalFormBloc?.selectedDateofBirth))
          ..then((value) {
            setState(() {
              if (value != null) {
                if (value is DateTime) {
                  medicalFormBloc?.add(DateofBirthUpdateEvent(value));
                }
              }
            });
          });
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerTitle(
              title: "DOB",
              isRequired: true,
            ),
            SizedBox(
              height: 5,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: ColorResource.GREY_PALE_F2F4F8,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomText(medicalFormBloc?.selectedDateofBirth != null
                    ? onlyDateformatter.format(
                        medicalFormBloc?.selectedDateofBirth ?? DateTime.now())
                    : "dd/mm/yyyy")),
            if (medicalFormBloc?.dobErrorText != null)
              SizedBox(
                height: 10,
              ),
            if (medicalFormBloc?.dobErrorText != null)
              CustomText(
                medicalFormBloc?.dobErrorText ?? "",
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDateofRequestDate() {
    return InkWell(
      onTap: () {
        AppUtils.hideKeyBoard(context);
        showCupertinoModalPopup(
            context: context,
            builder: (ctx) => showDateTimePicker(
                isOnlyDate: true,
                context: ctx,
                mainTime: medicalFormBloc?.selectedDateofrequest))
          ..then((value) {
            setState(() {
              if (value != null) {
                if (value is DateTime) {
                  medicalFormBloc?.add(DateofRequestUpdateEvent(value));
                }
              }
            });
          });
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerTitle(
              title: "Date of Request",
              isRequired: true,
            ),
            SizedBox(
              height: 5,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: ColorResource.GREY_PALE_F2F4F8,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomText(medicalFormBloc?.selectedDateofrequest != null
                    ? onlyDateformatter.format(
                        medicalFormBloc?.selectedDateofrequest ??
                            DateTime.now())
                    : "dd/mm/yyyy")),
            if (medicalFormBloc?.dateOfRequestErrorText != null)
              SizedBox(
                height: 10,
              ),
            if (medicalFormBloc?.dateOfRequestErrorText != null)
              CustomText(
                medicalFormBloc?.dateOfRequestErrorText ?? "",
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget headerTitle({@required String? title, @required bool? isRequired}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              fontFamily: Font.SfUiMedium.value,
              color: Colors.black,
            ),
          ),
          if (isRequired!)
            TextSpan(
              text: "*",
              style: TextStyle(
                fontFamily: Font.SfUiBlack.value,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildProductCheckBox() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(
            title: "Choose Products",
            isRequired: true,
          ),
          SizedBox(
            height: 10,
          ),
          Wrap(
            children: [
              checkbox(
                title: "10 MG - Roszet",
                value: medicalFormBloc?.mg10Roszet,
                onClickListner: (bool? val) {
                  if (val != null) {
                    medicalFormBloc?.mg10Roszet = val;
                    medicalFormBloc?.add(ScreenUiChangeEvent());
                  }
                },
              ),
              checkbox(
                title: "20 MG - Roszet",
                value: medicalFormBloc?.mg20Roszet,
                onClickListner: (bool? val) {
                  if (val != null) {
                    medicalFormBloc?.mg20Roszet = val;
                    medicalFormBloc?.add(ScreenUiChangeEvent());
                  }
                },
              ),
            ],
          ),
          if (medicalFormBloc?.productErrorText != null)
            SizedBox(
              height: 10,
            ),
          if (medicalFormBloc?.productErrorText != null)
            CustomText(
              medicalFormBloc?.productErrorText ?? "",
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget checkbox({
    @required bool? value,
    @required String? title,
    @required Function(bool?)? onClickListner,
  }) {
    return InkWell(
      onTap: () {
        onClickListner!(!value!);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: value,
                      onChanged: onClickListner,
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: title,
                style: TextStyle(
                  fontFamily: Font.SfUiMedium.value,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget radioButton({
    @required String? value,
    @required String? groupValue,
    @required String? title,
    @required Function(Object?)? onClickListner,
  }) {
    return InkWell(
      onTap: () {
        onClickListner!(value!);
      },
      child: Container(
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Radio(
                      value: value ?? "",
                      groupValue: groupValue ?? "",
                      onChanged: (value) {
                        onClickListner!(value!);
                      },
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: title,
                style: TextStyle(
                  fontFamily: Font.SfUiMedium.value,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRepresentativeInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        CustomText(
          "C. Representative Contact Information: (To Be Completed By Representative)",
          fontSize: 16,
          font: Font.SfUiBold,
        ),
        Divider(),
        CustomText(
          "By Submitting this form, I certify that is request for information was initiated by Health Care Professional stated above, and was not solicited by me in any manner.",
          fontSize: 12,
          font: Font.SfUiMedium,
        ),
        Divider(),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Representative Name",
          textEditingController: medicalFormBloc?.txtRepNameEditingController,
          errorText: medicalFormBloc?.repNameErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.repNameFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Representative Type",
          textEditingController: medicalFormBloc?.txtRepTypeEditingController,
          errorText: medicalFormBloc?.repTypeErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.repTypeFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Representative Territory Number",
          textEditingController:
              medicalFormBloc?.txtRepTerriotoryEditingController,
          errorText: medicalFormBloc?.repTerriotoryErrorText,
          isRequired: true,
          focusNode: medicalFormBloc?.repTerriotoryFocusNode,
        ),
        SizedBox(
          height: 10,
        ),
        buildCountryCode(),
        SizedBox(
          height: 10,
        ),
        buildTextBox(
          fieldName: "Primary TelePhone Number",
          textEditingController:
              medicalFormBloc?.txtRepTeleNumbEditingController,
          errorText: medicalFormBloc?.repTeleNumbErrorText,
          isRequired: false,
          focusNode: medicalFormBloc?.repTeleNumbFocusNode,
          isNumber: true,
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget buildCountryCode() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerTitle(
            title: "Country Code",
            isRequired: false,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: ColorResource.GREY_PALE_F2F4F8,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text("Select Country Code "),
              value: medicalFormBloc?.selectedCountryCode,
              underline: Container(),
              onChanged: (String? value) {
                medicalFormBloc?.add(CountryCodeClickEvent(value ?? ""));
              },
              items: medicalFormBloc?.lstCountryCode.map((String user) {
                return DropdownMenuItem<String>(
                  value: user,
                  child: Text(
                    user,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

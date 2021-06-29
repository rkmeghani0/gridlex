import 'package:gridlex/util/base_equatable.dart';

class MedicalFormState extends BaseEquatable {}

class MedicalFormInitialState extends MedicalFormState {
  final String? error;
  MedicalFormInitialState({this.error});
  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) => false;
  @override
  String toString() {
    return 'MedicalFormInitialState';
  }
}

class MedicalFormLoadingState extends MedicalFormState {
  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) => false;
  @override
  String toString() {
    return "MedicalFormLoadingState";
  }
}

class MedicalSuccessState extends MedicalFormState {
  final String msg;
  MedicalSuccessState(this.msg);
  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) => false;
  @override
  String toString() {
    return "MedicalSuccessState";
  }
}

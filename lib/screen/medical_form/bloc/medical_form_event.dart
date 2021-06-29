import 'package:flutter/widgets.dart';
import 'package:gridlex/util/base_equatable.dart';

class MedicalFormEvent extends BaseEquatable {}

class MedicalFormInitialEvent extends MedicalFormEvent {
  @override
  String toString() {
    return "MedicalFormInitialEvent";
  }
}

class DesignationChooseEvent extends MedicalFormEvent {
  final String value;
  DesignationChooseEvent(this.value);
  @override
  String toString() {
    return "DesignationChooseEvent";
  }
}

class ProductClickEvent extends MedicalFormEvent {
  final BouncingScrollSimulation value;
  ProductClickEvent(this.value);
  @override
  String toString() {
    return "ProductClickEvent";
  }
}

class StateClickEvent extends MedicalFormEvent {
  final String value;
  StateClickEvent(this.value);
  @override
  String toString() {
    return "StateClickEvent";
  }
}

class ScreenUiChangeEvent extends MedicalFormEvent {
  @override
  String toString() {
    return "ScreenUiChangeEvent";
  }
}

class DateofBirthUpdateEvent extends MedicalFormEvent {
  final DateTime datetime;
  DateofBirthUpdateEvent(this.datetime);
  @override
  String toString() {
    return "DateofBirthUpdateEvent";
  }
}

class DateofRequestUpdateEvent extends MedicalFormEvent {
  final DateTime datetime;
  DateofRequestUpdateEvent(this.datetime);
  @override
  String toString() {
    return "DateofRequestUpdateEvent";
  }
}

class AdverseEventExpChangeEvent extends MedicalFormEvent {
  final String value;
  AdverseEventExpChangeEvent(this.value);
  @override
  String toString() {
    return "AdverseEventExpChangeEvent";
  }
}

class GenderChangeEvent extends MedicalFormEvent {
  final String value;
  GenderChangeEvent(this.value);
  @override
  String toString() {
    return "GenderChangeEvent";
  }
}

class CountryCodeClickEvent extends MedicalFormEvent {
  final String value;
  CountryCodeClickEvent(this.value);
  @override
  String toString() {
    return "CountryCodeClickEvent";
  }
}

class FormSaveButtonPressedEvent extends MedicalFormEvent {
  @override
  String toString() {
    return "FormSaveButtonPressedEvent";
  }
}

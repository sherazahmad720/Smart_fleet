import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_fleet/controllers/api_controller.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/models/trip_model.dart';

class TripController extends GetxController {
  ApiController apiController = Get.find();
  AuthController authController = Get.find();
  var tripFormkey = GlobalKey<FormState>();
  var activityFormkey = GlobalKey<FormState>();
  List<TripModel> alltrips = [];
  TripModel selectedTrip;
  TripActivitiesDto selectedActivity;
  // List<ActivityModel> activitesList = [];

/* --------------------------- variables for trips -------------------------- */

  String tripTitle, tripDescription, tripFrom, tripTo;
  double tripAmount;
  DateTime startDate = DateTime.now(), endData = DateTime.now();
  RefreshController activityRefreshController =
      RefreshController(initialRefresh: false);
  RefreshController tripRefreshController =
      RefreshController(initialRefresh: false);
  // ignore: missing_return
  //

/* ----------------------------variables for tripActivity ---------------------------- */
  String activityDescription;
  double activityAmount;
  String transactionType = 'Loan';
  DateTime activityDate = DateTime.now();

/* -------------------------- controller for trips -------------------------- */
  TextEditingController tripTitleController = TextEditingController();
  TextEditingController tripDescriptionController = TextEditingController();
  TextEditingController tripFromController = TextEditingController();
  TextEditingController tripToController = TextEditingController();
  TextEditingController tripAmountController = TextEditingController();

/* ---------------------- controller for activity page ---------------------- */
  TextEditingController activityDescriptionController = TextEditingController();
  TextEditingController activityAmountController = TextEditingController();

  // ignore: missing_return
  String validator(val) {
    if (val == '') {
      return 'Field Is Required';
    }
  }

  // ignore: missing_return
  String amountValidator(val) {
    if (val == '') {
      return 'Field Is Required';
    }
    if (double.tryParse(val) == null) {
      return 'Please Enter amount in double form';
    }
  }

  getTrips() {
    apiController.getAllTrips(authController.userModel,
        selectedUser: authController.selectedUser);
  }

  getActivities() {
    apiController.getAllActivites(authController.userModel, selectedTrip);
  }

  saveTrip() {
    if (tripFormkey.currentState.validate()) {
      tripFormkey.currentState.save();
      TripModel _tripModel = TripModel();
      _tripModel.description = tripDescription;
      _tripModel.title = tripTitle;
      _tripModel.amount = tripAmount;
      _tripModel.from = tripFrom;
      _tripModel.to = tripTo;
      _tripModel.startDate = startDate;
      _tripModel.endDate = endData;
      apiController.addTrip(authController.userModel, _tripModel);
    }
  }

  saveActivity() {
    if (activityFormkey.currentState.validate()) {
      activityFormkey.currentState.save();
      TripActivitiesDto _tripActivity = TripActivitiesDto();
      _tripActivity.price = activityAmount;
      _tripActivity.date = activityDate;
      _tripActivity.description = activityDescription;
      _tripActivity.transactionType = transactionType;
      _tripActivity.tripId = selectedTrip.id;
      apiController.addActivity(authController.userModel, _tripActivity);
    }
  }

  updateTrip() {
    if (tripFormkey.currentState.validate()) {
      tripFormkey.currentState.save();
      TripModel _tripModel = selectedTrip;
      _tripModel.description = tripDescription;
      _tripModel.title = tripTitle;
      _tripModel.amount = tripAmount;
      _tripModel.from = tripFrom;
      _tripModel.to = tripTo;
      _tripModel.startDate = startDate;
      _tripModel.endDate = endData;
      apiController.updateTrip(authController.userModel, _tripModel);
    }
  }

  getDataForEditTrip() {
    tripTitleController.text = selectedTrip.title;
    tripDescriptionController.text = selectedTrip.description;
    tripFromController.text = selectedTrip.from;
    tripAmountController.text = selectedTrip.amount.toString();
    tripToController.text = selectedTrip.to;
    startDate = selectedTrip.startDate ?? DateTime.now();
    // endData = selectedTrip.endDate is String
    //     ? DateTime.parse(selectedTrip.endDate)
    //     : selectedTrip.endDate ?? DateTime.now();
  }

  updateActivity() {
    if (activityFormkey.currentState.validate()) {
      activityFormkey.currentState.save();
      TripActivitiesDto _tripActivity = selectedActivity;
      _tripActivity.price = activityAmount;
      _tripActivity.date = activityDate;
      _tripActivity.description = activityDescription;
      _tripActivity.transactionType = transactionType;
      _tripActivity.tripId = selectedTrip.id;
      apiController.updateActivity(authController.userModel, _tripActivity);
    }
  }

  getDataForEditActivity() {
    activityAmountController.text = selectedActivity.price.toString();
    activityDescriptionController.text = selectedActivity.description;
    transactionType = selectedActivity.transactionType;
    activityDate = selectedActivity.date ?? DateTime.now();
  }

  deleteTrip() {
    apiController.deleteTrip(authController.userModel, selectedTrip);
  }

  deleteActivity() {
    apiController.deleteActivity(authController.userModel, selectedActivity);
  }

  clear() {
    endData = DateTime.now();
    startDate = DateTime.now();
    activityDate = DateTime.now();
    transactionType = 'Loan';
    tripTitleController.clear();
    tripDescriptionController.clear();
    tripFromController.clear();
    tripToController.clear();
    activityDescriptionController.clear();
    activityAmountController.clear();
    tripAmountController.clear();
  }
  // getTripsForUser() {
  //   apiController.getAllTripsForUser(authController.userModel);
  // }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/loading_controller.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/models/trip_model.dart';
import 'package:smart_fleet/models/user_model.dart';
import 'package:smart_fleet/pages/all_users.dart';
import 'package:smart_fleet/pages/home_page.dart';

class ApiController extends GetxController {
  LoadingController loadingController = Get.put(LoadingController());
  userLogin() async {
    loadingController.showLoading();

    dynamic response = await http
        .get('dis/dashboard/getDashboardList', headers: <String, String>{});
    loadingController.stopLoading();
    if (response.statusCode == 200) {}
    loadingController.stopLoading();
  }

/* ---------------------------- sign up for user ---------------------------- */

  signUp(UserModel userData) async {
    AuthController authController = Get.put(AuthController());
    loadingController.showLoading();

    dynamic response = await http.post(
        'https://smartfleets.azurewebsites.net/api/account/register',
        headers: <String, String>{
          // 'Authorization': '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData.toJson()));
    loadingController.stopLoading();
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      var data = jsonDecode(response.body);
      loadingController.stopLoading();
      if (data['responseCode'] == 400) {
        authController.errorList = data['error'];
        authController.update();
      } else if (data['responseCode'] == 200) {
        authController.errorList = [];
        authController.update();
        Get.snackbar('Success', data['responseMessage'],
            backgroundColor: Colors.green.withOpacity(0.4));
        login(userData);
      }
    } else if (response.statusCode == 400) {
      var data = jsonDecode(response.body);
      Get.snackbar('Success', data['responseMessage'] ?? '',
          backgroundColor: Colors.red.withOpacity(0.4));
      authController.errorList.add(data['responseMessage']);
      authController.update();
    }
  }

/* ----------------------------- login for user ----------------------------- */

  login(UserModel userData) async {
    AuthController authController = Get.put(AuthController());
    loadingController.showLoading();

    dynamic response = await http.post(
        'https://smartfleets.azurewebsites.net/api/account/login',
        headers: <String, String>{
          // 'Authorization': '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {'email': userData.email, 'password': userData.password}));
    loadingController.stopLoading();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      // var data = jsonDecode(response.body);
      loadingController.stopLoading();
      if (data['responseCode'] == 200) {
        userData = UserModel.fromJson(data['data']);
        userData.token = data['data']['bearerToken'];
        userData.expiredIn = data['data']['expiresIn'];
        authController.errorList = [];
        authController.userModel = userData;
        authController.update();
        print(userData.token);
        print(userData.userType);
        userData.userType == 'User'
            ? Get.off(HomePage())
            : Get.off(AllUserPage());
        Get.back();
        Get.snackbar('Success', data['responseMessage'],
            backgroundColor: Colors.green.withOpacity(0.4));
      } else if (data['responseCode'] == 400) {
        authController.errorList = [data['responseMessage']];
        authController.update();

        Get.snackbar('Success', data['responseMessage'],
            backgroundColor: Colors.green.withOpacity(0.4));
      }
    } else if (response.statusCode == 404) {
      Get.snackbar('Error found', data['responseMessage'] ?? '',
          backgroundColor: Colors.red.withOpacity(0.4));
      authController.errorList = [data['error']];
      authController.update();
    } else if (response.statusCode == 400) {
      authController.errorList = [data['responseMessage'] ?? data['title']];
      // authController.errorList = [data['responseMessage']];
      authController.update();
    }
  }

  getAllUser(UserModel userData) async {
    AuthController authController = Get.find();
    authController.allUserList.clear();
    update();
    authController.update();
    var url = 'https://smartfleets.azurewebsites.net/api/users';
    dynamic response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'bearer ' + "${userData.token}",
        // 'Authorization':
        //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
        'Content-Type': 'application/json',
      },
    );
    loadingController.stopLoading();
    authController.userRefreshController.refreshCompleted();
    // authController.tripRefreshController.refreshCompleted();

    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonData['responseCode'] == 200) {
        List listOfUser = jsonData['data'];
        // authController.allUserList.clear();
        listOfUser.forEach((element) {
          var _userData = UserModel.fromJson(element);
          authController.allUserList.add(_userData);
          // getAllActivites(userData, _tripModelData);
        });

        authController.update();
      }
    }
  }

/* ------------------------------ get all trips ----------------------------- */

  getAllTrips(UserModel userData, {UserModel selectedUser}) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    tripController.alltrips.clear();
    tripController.update();
    var url = userData.userType == 'User'
        ? 'https://smartfleets.azurewebsites.net/api/trip/user-trips'
        : 'https://smartfleets.azurewebsites.net/api/user-trips/${selectedUser.id}';
    dynamic response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'bearer ' + "${userData.token}",
        // 'Authorization':
        //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
        'Content-Type': 'application/json',
      },
    );
    loadingController.stopLoading();
    tripController.tripRefreshController.refreshCompleted();

    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonData['responseCode'] == 200) {
        List listOfTrips = jsonData['data'];
        tripController.alltrips.clear();
        listOfTrips.forEach((element) {
          var _tripModelData = TripModel.fromJson(element);
          tripController.alltrips.add(_tripModelData);
          // getAllActivites(userData, _tripModelData);
        });

        tripController.update();
      }
    }
  }

/* ------------------ get activity against a specific trip ------------------ */

  getAllActivites(UserModel userData, TripModel tripData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    tripData.tripActivitiesDto.clear();
    tripData.activitiesCosts.clear();
    tripController.update();
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    dynamic response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'bearer ' + "${userData.token}",
        'Content-Type': 'application/json',
      },
    );
    loadingController.stopLoading();
    tripController.activityRefreshController.refreshCompleted();

    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonData['responseCode'] == 200) {
        // tripData.amount = double.parse(jsonData['data']['amount'].toString());
        tripData.tripActivitiesDto = List<TripActivitiesDto>.from(
            jsonData['data']["tripActivitiesDto"]
                .map((x) => TripActivitiesDto.fromJson(x)));
        tripData.activitiesCosts = List<ActivitiesCost>.from(jsonData['data']
                ["activitiesCosts"]
            .map((x) => ActivitiesCost.fromJson(x)));
        tripController.update();
      }
    }
  }

  addTrip(UserModel userData, TripModel tripData) async {
    // final TripController tripController = Get.find();
    //
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip';
    dynamic response = await http.post(url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          // 'Authorization':
          //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tripData.toJson()));
    loadingController.stopLoading();
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Trip Added successfully',
          backgroundColor: Colors.green.withOpacity(0.7));
      getAllTrips(
        userData,
      );

      // tripController.update();
    } else if (response.statusCode == 400) {
      Get.snackbar('Error', jsonData['title'],
          backgroundColor: Colors.red.withOpacity(0.7));
    }
  }

  updateTrip(UserModel userData, TripModel tripData) async {
    AuthController authController = Get.find();

    // final TripController tripController = Get.find();
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    dynamic response = await http.put(url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          // 'Authorization':
          //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tripData.toJson()));
    loadingController.stopLoading();
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Trip Updated successfully',
          backgroundColor: Colors.green.withOpacity(0.7));
      getAllTrips(userData, selectedUser: authController.selectedUser);

      // tripController.update();
    } else if (response.statusCode == 400) {
      Get.snackbar('Error', jsonData['title'],
          backgroundColor: Colors.red.withOpacity(0.7));
    }
  }

  deleteTrip(UserModel userData, TripModel tripData) async {
    AuthController authController = Get.find();
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    dynamic response = await http.delete(
      url,
      headers: <String, String>{
        'Authorization': 'bearer ' + "${userData.token}",
        // 'Authorization':
        //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
        'Content-Type': 'application/json',
      },
    );
    loadingController.stopLoading();
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Trip Deleted successfully',
          backgroundColor: Colors.green.withOpacity(0.7));
      getAllTrips(userData, selectedUser: authController.selectedUser);

      // tripController.update();
    } else if (response.statusCode == 400) {
      Get.snackbar('Error', jsonData['title'],
          backgroundColor: Colors.red.withOpacity(0.7));
    }
  }

  addActivity(UserModel userData, TripActivitiesDto activityData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip-activity';
    dynamic response = await http.post(url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          // 'Authorization':
          //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(activityData.toJson()));
    loadingController.stopLoading();
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Activity Added successfully',
          backgroundColor: Colors.green.withOpacity(0.7));
      // tripController.selectedTrip.tripActivitiesDto.add(activityData);
      getAllActivites(userData, tripController.selectedTrip);
      // tripController.update();
      // getAllTrips(userData);

      // tripController.update();
    } else if (response.statusCode == 400) {
      Get.snackbar('Error', jsonData['title'],
          backgroundColor: Colors.red.withOpacity(0.7));
    }
  }

  updateActivity(UserModel userData, TripActivitiesDto activityData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    var url =
        'https://smartfleets.azurewebsites.net/api/trip-activity/${activityData.id}';
    dynamic response = await http.put(url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          // 'Authorization':
          //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(activityData.toJson()));
    loadingController.stopLoading();
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Activity Updated successfully',
          backgroundColor: Colors.green.withOpacity(0.7));
      // tripController.selectedTrip.tripActivitiesDto.add(activityData);
      getAllActivites(userData, tripController.selectedTrip);
      // tripController.update();
      // getAllTrips(userData);

      // tripController.update();
    } else if (response.statusCode == 400) {
      Get.snackbar('Error', jsonData['title'],
          backgroundColor: Colors.red.withOpacity(0.7));
    }
  }

  deleteActivity(UserModel userData, TripActivitiesDto activityData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    var url =
        'https://smartfleets.azurewebsites.net/api/trip-activity/${activityData.id}';
    dynamic response = await http.delete(
      url,
      headers: <String, String>{
        'Authorization': 'bearer ' + "${userData.token}",
        // 'Authorization':
        //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
        'Content-Type': 'application/json',
      },
    );
    loadingController.stopLoading();
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Activity Deleted successfully',
          backgroundColor: Colors.green.withOpacity(0.7));
      // getAllTrips(userData);
      getAllActivites(userData, tripController.selectedTrip);
      // tripController.update();
    } else if (response.statusCode == 400) {
      Get.snackbar('Error', jsonData['title'],
          backgroundColor: Colors.red.withOpacity(0.7));
    }
  }
}

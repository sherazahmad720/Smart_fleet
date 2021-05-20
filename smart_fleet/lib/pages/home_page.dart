import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_fleet/constants/constants.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/pages/login_screen.dart';
import 'package:smart_fleet/widgets/customAlerDialog.dart';
import 'package:smart_fleet/widgets/logout_dialog.dart';
import 'package:smart_fleet/widgets/trips_card.dart';

import 'activity_page.dart';
import 'add_trip_page.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TripController tripController = Get.put(TripController());
  @override
  Widget build(BuildContext context) {
    customContext = context;
    var f = NumberFormat("\u{020A6},###.##", "en_US");
    // if (authController.userModel.userType == 'Admin') {
    tripController.getTrips();
    // } else {
    //   tripController.getTripsForUser();
    // }

    return Scaffold(
        appBar: AppBar(
          title: Text('Smart Fleet'),
          backgroundColor: Color(0xff753a88),
          actions: [
            if (authController.userModel.userType == 'User')
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    tripController.clear();
                    Get.to(AddTripPage(
                      type: 'AddNew',
                    ));
                  }),
            if (authController.userModel.userType == 'User')
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    logoutDialog(logoutAction: () {
                      authController.clear();
                      Get.back();
                      Get.off(LoginPage(), preventDuplicates: false);
                    });
                  })
          ],
        ),
        body: GetBuilder<TripController>(
          builder: (_) {
            return Container(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SmartRefresher(
                      enablePullUp: false,
                      header: WaterDropHeader(
                        waterDropColor: Colors.deepPurpleAccent,
                      ),
                      controller: _.tripRefreshController,
                      onRefresh: () {
                        _.getTrips();
                      },
                      child: ListView.builder(
                          itemCount: _.alltrips.length,
                          itemBuilder: (ctx, index) {
                            var tripData = _.alltrips[index];
                            return InkWell(
                              onTap: () {
                                print('id is -->${tripData.id}');
                                _.selectedTrip = tripData;
                                _.getActivities();
                                Get.to(ActivityPage());
                              },
                              onLongPress: () {
                                _.selectedTrip = tripData;
                                // Get.dialog(customAlertDialog());
                                customAlertDialog(
                                    userType: authController.userModel.userType,
                                    editAction: () {
                                      _.getDataForEditTrip();
                                      Get.off(AddTripPage(
                                        type: 'Update',
                                      ));
                                    },
                                    deleteAction: () {
                                      _.deleteTrip();
                                    });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: tripsCard(
                                    isAdmin:
                                        authController.userModel.userType !=
                                            'User',
                                    amount: f.format(tripData.amount),
                                    description: tripData.description,
                                    email: tripData.appUserDto.email,
                                    endDate: tripData.endDate != null
                                        ? tripData.endDate is String
                                            ? DateFormat('dd MMM ,yyyy').format(
                                                DateTime.parse(
                                                    tripData.endDate))
                                            : DateFormat('dd MMM ,yyyy')
                                                .format(tripData.endDate)
                                        : 'No Date Added',
                                    from: tripData.from,
                                    phoneNo: tripData.appUserDto.phoneNumber,
                                    startDate: tripData.startDate != null
                                        ? DateFormat('dd MMM ,yyyy')
                                            .format(tripData.startDate)
                                        : 'No Date Added',
                                    title: tripData.title,
                                    to: tripData.to,
                                    userName: tripData.appUserDto.firstName +
                                        ' ' +
                                        tripData.appUserDto.lastName),
                              ),
                            );
                          }),
                    )));
          },
        ));
  }
}

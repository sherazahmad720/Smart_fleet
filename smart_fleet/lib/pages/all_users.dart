import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_fleet/constants/constants.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/pages/home_page.dart';
import 'package:smart_fleet/pages/login_screen.dart';
import 'package:smart_fleet/widgets/common_widgets.dart';
import 'package:smart_fleet/widgets/logout_dialog.dart';

class AllUserPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TripController tripController = Get.put(TripController());
  @override
  Widget build(BuildContext context) {
    customContext = context;
    authController.getAllUser();

    // var f = NumberFormat(",###.##\u{020A6}", "en_US");
    // if (authController.userModel.userType == 'Admin') {

    // } else {
    //   tripController.getTripsForUser();
    // }

    return Scaffold(
        appBar: AppBar(
          title: Text('Smart Fleet'),
          backgroundColor: Color(0xff753a88),
          actions: [
            if (authController.userModel.userType == 'Admin')
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
        body: GetBuilder<AuthController>(
          builder: (_) {
            return Container(
              child: SmartRefresher(
                controller: _.userRefreshController,
                header: WaterDropHeader(),
                onRefresh: () {
                  _.getAllUser();
                },
                child: ListView.builder(
                    itemCount: _.allUserList.length,
                    itemBuilder: (ctx, index) {
                      var userData = _.allUserList[index];
                      return userData.id != _.userModel.id
                          ? InkWell(
                              onTap: () {
                                _.selectedUser = _.allUserList[index];
                                // _.getTrips();
                                Get.to(HomePage());
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${userData.firstName} ${userData.lastName}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      space10,
                                      // Row(
                                      //   children: [
                                      //     Expanded(
                                      //       child: Text(
                                      //         'Email: ${userData ?? ''}',
                                      //         style: TextStyle(
                                      //           fontSize: 12,
                                      //         ),
                                      //       ),
                                      //     ),

                                      //   ],
                                      // ),
                                      // space10,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Email: ${userData.email ?? ''}',
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Phone No: ${userData.phoneNumber ?? ''}',
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox();
                    }),
              ),
            );
          },
        ));
  }
}

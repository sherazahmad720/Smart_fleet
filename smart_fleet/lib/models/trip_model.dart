// To parse this JSON data, do
//
//     final tripModel = tripModelFromJson(jsonString);

import 'dart:convert';

TripModel tripModelFromJson(String str) => TripModel.fromJson(json.decode(str));

String tripModelToJson(TripModel data) => json.encode(data.toJson());

class TripModel {
  TripModel(
      {this.id,
      this.title,
      this.description,
      this.from,
      this.to,
      this.amount,
      this.startDate,
      this.endDate,
      this.tripActivitiesDto,
      this.appUserDto,
      this.activitiesCosts});

  int id;
  String title;
  String description;
  String from;
  String to;
  double amount;
  DateTime startDate;
  dynamic endDate;
  List<TripActivitiesDto> tripActivitiesDto;
  AppUserDto appUserDto;
  List<ActivitiesCost> activitiesCosts;

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        from: json["from"],
        to: json["to"],
        amount: double.parse(json["amount"].toString()),
        startDate: DateTime.parse(json["startDate"]),
        endDate: json["endDate"],
        tripActivitiesDto: List<TripActivitiesDto>.from(
            json["tripActivitiesDto"]
                .map((x) => TripActivitiesDto.fromJson(x))),
        appUserDto: AppUserDto.fromJson(json["appUserDto"]),
        activitiesCosts: List<ActivitiesCost>.from(
            json["activitiesCosts"].map((x) => ActivitiesCost.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        // "id": id,
        "title": title,
        "description": description,
        "from": from,
        "to": to,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "amount": amount
        // "tripActivitiesDto":
        //     List<dynamic>.from(tripActivitiesDto.map((x) => x.toJson())),
        // "appUserDto": appUserDto.toJson(),
      };
}

class AppUserDto {
  AppUserDto({
    this.id,
    this.firstName,
    this.lastName,
    this.address,
    this.phoneNumber,
    this.email,
  });

  String id;
  String firstName;
  String lastName;
  dynamic address;
  String phoneNumber;
  String email;

  factory AppUserDto.fromJson(Map<String, dynamic> json) => AppUserDto(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        address: json["address"],
        phoneNumber: json["phoneNumber"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "address": address,
        "phoneNumber": phoneNumber,
        "email": email,
      };
}

class TripActivitiesDto {
  TripActivitiesDto({
    this.id,
    this.date,
    this.transactionType,
    this.price,
    this.tripId,
    this.appUserId,
    this.description,
  });

  int id;
  DateTime date;
  String transactionType;
  double price;
  int tripId;
  dynamic appUserId;
  String description;

  factory TripActivitiesDto.fromJson(Map<String, dynamic> json) =>
      TripActivitiesDto(
        id: json["id"],
        date: DateTime.parse(json["date"]),
        transactionType: json["transactionType"],
        price: double.parse(json["price"].toString()),
        tripId: json["tripId"],
        appUserId: json["appUserId"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        // "id": id,
        "date": date.toIso8601String(),
        "transactionType": transactionType,
        "price": price,
        "tripId": tripId,
        // "appUserId": appUserId,
        "description": description,
      };
}

class ActivitiesCost {
  ActivitiesCost({
    this.transactionType,
    this.cost,
  });

  String transactionType;
  double cost;

  factory ActivitiesCost.fromJson(Map<String, dynamic> json) => ActivitiesCost(
        transactionType: json["transactionType"],
        cost: json["cost"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "transactionType": transactionType,
        "cost": cost,
      };
}

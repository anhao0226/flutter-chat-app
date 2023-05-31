// https://developer.amap.com/api/webservice/guide/api/search#text

import 'package:flutter_chat_app/utils/index.dart';

class AMapPoi {
  AMapPoi({
    required this.id,
    required this.address,
    required this.distance,
    required this.pname,
    required this.cityname,
    required this.type,
    required this.typecode,
    required this.shopinfo,
    required this.adname,
    required this.name,
    required this.location,
  });

  late String id;
  late String address;
  late String distance;
  late String pname;
  late String cityname;
  late String type;
  late String typecode;
  late String shopinfo;
  late String adname;
  late String name;
  late String location;

  AMapPoi.fromJson(dynamic json) {
    logger.i(json['tel']);
    id = json['id'];
    name = json['name'];
    address = json['address'];
    distance = json['distance'];
    pname = json['pname'];
    cityname = json['cityname'];
    type = json['type'];
    typecode = json['typecode'];
    shopinfo = json['shopinfo'];
    adname = json['adname'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['address'] = address;
    map['distance'] = distance;
    map['pname'] = pname;
    map['cityname'] = cityname;
    map['type'] = type;
    map['typecode'] = typecode;
    map['shopinfo'] = shopinfo;
    map['adname'] = adname;
    map['name'] = name;
    map['location'] = location;
    return map;
  }
}


import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class Weight {
  Weight({this.id, this.weight, this.time});

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
    weight: json['weight'] as double,
    time: DateTime.parse(json['time'] as String),
    id: json['id'] as String,
  );

  String id;
  double weight;
  DateTime time;


  Map<String, dynamic> toJson() => <String, dynamic>{
    'weight': weight,
    'time': time.toIso8601String(),
    'id': id,
  };

}
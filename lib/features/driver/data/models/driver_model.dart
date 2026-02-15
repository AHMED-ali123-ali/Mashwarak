import '../../domain/entities/driver.dart';

class DriverModel extends Driver {
  DriverModel({
    required super.name,
    required super.phone,
    required super.price,
    required super.rating,
    required super.image,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      name: json['name'],
      phone: json['phone'],
      price: json['price'],
      rating: json['rating'],
      image: json['img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'price': price,
      'rating': rating,
      'img': image,
    };
  }
}

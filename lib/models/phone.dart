// lib/models/phone.dart
import 'package:flutter/foundation.dart';

class Phone {
  final int id;
  final String name;
  final String brand;
  final int price;
  final String specification;
  final String imgUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Phone({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.specification,
    required this.imgUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        debugPrint('Error parsing date: $dateString, error: $e');
        return null;
      }
    }

    return Phone(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Phone',
      brand: json['brand'] as String? ?? 'Unknown Brand',
      price: json['price'] as int? ?? 0,
      specification: json['specification'] as String? ?? 'No Specification',
      imgUrl: json['img_url'] as String? ?? '',
      createdAt: parseDate(
        json['createdAt']?.toString() ?? json['createdAd']?.toString(),
      ),
      updatedAt: parseDate(json['updatedAt']?.toString()),
    );
  }

  // Disesuaikan untuk mengirim field yang relevan untuk POST dan PUT
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'specification': specification,
      // img_url tidak dikirim karena di-random otomatis oleh API saat POST,
      // dan untuk PUT, kita asumsikan API tidak mengizinkan update img_url via body,
      // atau jika iya, perlu ditambahkan field 'img_url': imgUrl di sini.
      // Untuk kesederhanaan dan sesuai dokumentasi POST, kita tidak sertakan.
    };
  }
}

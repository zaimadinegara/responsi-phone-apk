// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/phone.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = 'https://resp-api-three.vercel.app';

  Future<List<Phone>> fetchPhones() async {
    debugPrint("ApiService: Attempting to fetch phones from $_baseUrl/phones");
    try {
      final response = await http.get(Uri.parse('$_baseUrl/phones'));
      debugPrint("ApiService: Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint(
          "ApiService: Response body: ${response.body.substring(0, (response.body.length > 500 ? 500 : response.body.length))}",
        ); // Print first 500 chars
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['status'] == 'success') {
          debugPrint("ApiService: API status is success.");
          if (responseBody['data'] is List) {
            List<dynamic> phoneData = responseBody['data'];
            debugPrint(
              "ApiService: Found ${phoneData.length} phone items in 'data' list.",
            );
            if (phoneData.isEmpty) {
              debugPrint("ApiService: 'data' list is empty.");
              return []; // Kembalikan list kosong jika data API kosong
            }
            List<Phone> phoneList = [];
            for (var item in phoneData) {
              try {
                phoneList.add(Phone.fromJson(item as Map<String, dynamic>));
              } catch (e) {
                debugPrint(
                  "ApiService: Error parsing individual phone item: $item, Error: $e",
                );
                // Lanjutkan parsing item lain, atau throw error jika satu item gagal dianggap fatal
              }
            }
            debugPrint(
              "ApiService: Successfully parsed ${phoneList.length} phone objects.",
            );
            return phoneList;
          } else {
            debugPrint(
              "ApiService: 'data' field is not a List. Actual type: ${responseBody['data'].runtimeType}",
            );
            throw Exception('Gagal mem-parse ponsel: Kunci "data" bukan List.');
          }
        } else {
          debugPrint(
            "ApiService: API status is not 'success'. Status: ${responseBody['status']}, Message: ${responseBody['message']}",
          );
          throw Exception(
            'Gagal mem-parse ponsel: API melaporkan status bukan success - ${responseBody['message']}',
          );
        }
      } else {
        debugPrint(
          'ApiService: Gagal memuat ponsel. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Gagal memuat ponsel (status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('ApiService: Error saat mengambil ponsel: $e');
      rethrow;
    }
  }

  // ... (metode fetchPhoneDetail, createPhone, updatePhone, deletePhone tetap sama seperti versi terakhir yang sudah dikoreksi pathnya)
  Future<Phone> fetchPhoneDetail(String id) async {
    debugPrint(
      "ApiService: Attempting to fetch phone detail for id $id from $_baseUrl/phone/$id",
    );
    try {
      final response = await http.get(Uri.parse('$_baseUrl/phone/$id'));
      debugPrint(
        "ApiService: Detail Response status code: ${response.statusCode}",
      );
      if (response.statusCode == 200) {
        // ... (sisa parsing sama)
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success' &&
            responseBody['data'] is Map) {
          return Phone.fromJson(responseBody['data'] as Map<String, dynamic>);
        } else {
          throw Exception(
            'Gagal mem-parse detail ponsel: ${responseBody['message']}',
          );
        }
      } else {
        throw Exception(
          'Gagal memuat detail ponsel untuk id $id (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error fetching phone detail for id $id: $e');
      rethrow;
    }
  }

  Future<void> createPhone(Phone phone) async {
    debugPrint("ApiService: Attempting to create phone: ${phone.name}");
    try {
      Map<String, dynamic> phoneData = phone.toJson();
      final response = await http.post(
        Uri.parse('$_baseUrl/phone'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(phoneData),
      );
      debugPrint(
        "ApiService: Create phone response status: ${response.statusCode}, Body: ${response.body}",
      );
      // ... (sisa parsing sama)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          debugPrint(
            'Ponsel berhasil dibuat. Pesan: ${responseBody['message']}',
          );
          return;
        } else {
          throw Exception(
            'Gagal membuat ponsel, API melaporkan: ${responseBody['message']}',
          );
        }
      } else {
        throw Exception(
          'Gagal membuat ponsel (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error saat membuat ponsel: $e');
      rethrow;
    }
  }

  Future<Phone> updatePhone(String id, Phone phone) async {
    debugPrint(
      "ApiService: Attempting to update phone id $id with name: ${phone.name}",
    );
    try {
      Map<String, dynamic> phoneData = phone.toJson();
      final response = await http.put(
        Uri.parse('$_baseUrl/phone/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(phoneData),
      );
      debugPrint(
        "ApiService: Update phone response status: ${response.statusCode}, Body: ${response.body}",
      );
      // ... (sisa parsing sama)
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success' &&
            responseBody['updatedPhone'] is Map) {
          return Phone.fromJson(
            responseBody['updatedPhone'] as Map<String, dynamic>,
          );
        } else {
          throw Exception(
            'Gagal mem-parse ponsel yang diupdate: ${responseBody['message']}',
          );
        }
      } else {
        throw Exception(
          'Gagal mengupdate ponsel (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error saat mengupdate ponsel $id: $e');
      rethrow;
    }
  }

  Future<bool> deletePhone(String id) async {
    debugPrint("ApiService: Attempting to delete phone id $id");
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/phone/$id'));
      debugPrint(
        "ApiService: Delete phone response status: ${response.statusCode}, Body: ${response.body}",
      );
      // ... (sisa parsing sama)
      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          return true;
        } else {
          throw Exception(
            'API melaporkan error saat menghapus: ${responseBody['message']}',
          );
        }
      } else {
        throw Exception(
          'Gagal menghapus ponsel (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error saat menghapus ponsel $id: $e');
      rethrow;
    }
  }
}

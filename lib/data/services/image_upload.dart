import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  final Dio _dio = Dio();

  Future<String> uploadImage(File imageFile) async {
    const String url =
        "https://cight-dot-compact-flash-379702.ue.r.appspot.com/api/image/describe-image";

    try {
      // Create multipart form-data
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: "image.png", // Ensure it's a PNG file
          contentType: MediaType("image", "png"),
        ),
      });

      // Send POST request
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      // Return response as string
      return response.data.toString();
    } catch (e) {
      print("Error uploading image: $e");
      return "Error: $e";
    }
  }
}

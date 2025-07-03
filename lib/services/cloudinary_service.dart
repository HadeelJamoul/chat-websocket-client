import 'dart:convert';

import 'package:chat_websocket_client/core/url.dart';
import 'package:chat_websocket_client/utils/app_picker.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String uploadPreset = 'chat-unsigned';

  static Future<String?> uploadImage() async {
    final uri = Uri.parse(Url.CLOUDINARY);
    final XFile? pickedImage = await AppPicker().pickGalleryImage();
    if (pickedImage == null) return null;

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', pickedImage.path),
          );

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      //* https
      return data['secure_url'];
    } else {
      print('Cloudinary upload failed: ${res.body}');
      return null;
    }
  }
}

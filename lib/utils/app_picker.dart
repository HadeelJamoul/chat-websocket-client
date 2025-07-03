import 'package:image_picker/image_picker.dart';

class AppPicker {
  static final AppPicker _instance = AppPicker._internal();
  factory AppPicker() => _instance;
  AppPicker._internal();

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }
}

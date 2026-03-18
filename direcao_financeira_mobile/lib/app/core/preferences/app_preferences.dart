import 'package:get_storage/get_storage.dart';

abstract class AppPreferences {
  bool? readBool(String key);
  Future<void> writeBool(String key, bool value);
}

class GetStorageAppPreferences implements AppPreferences {
  GetStorageAppPreferences({required this.storage});

  final GetStorage storage;

  @override
  bool? readBool(String key) => storage.read<bool>(key);

  @override
  Future<void> writeBool(String key, bool value) => storage.write(key, value);
}

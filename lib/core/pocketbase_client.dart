import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final PocketBase pb;

Future<void> initPocketBase() async {
  final prefs = await SharedPreferences.getInstance();

  pb = PocketBase(
    'http://10.0.2.2:8090',
    authStore: AsyncAuthStore(
      save: (String data) async => prefs.setString('pb_auth', data),
      initial: prefs.getString('pb_auth'),
      clear: () async => prefs.remove('pb_auth'),
    ),
  );
}

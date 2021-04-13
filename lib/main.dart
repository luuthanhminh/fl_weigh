import 'package:n7bluetooth/my_app.dart';
import 'package:n7bluetooth/utils/app_config.dart';

Future<void> main() async {
  /// Init dev config
  Config(environment: Env.dev());
  await myMain();
}

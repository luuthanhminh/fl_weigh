import 'package:flutter/material.dart';
import 'package:n7bluetooth/models/local/token.dart';
import 'package:n7bluetooth/services/local/credential.dart';
import 'package:n7bluetooth/services/remote/api_user.dart';

class HomeProvider with ChangeNotifier {
  HomeProvider(this._api, this._credential);

  //#region PRIVATE PROPERTIES
  // -----------------
  // Authentication api
  final ApiUser _api;

  // Credential
  final Credential _credential;

  //#endregion

  //#region PUBLIC PROPERTIES
  // -----------------
  // Get user info
  Token get token => _api.token;

  //#endregion

  //#region METHODS
  // -----------------
  /// Call logout
  Future<bool> logout() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    if (token == null) {
      return true;
    }

    // Save credential
    final bool saveRes = await _credential.storeCredential(null, cache: true);
    return saveRes;
  }

//#endregion
}

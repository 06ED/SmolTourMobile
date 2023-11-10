import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:smolaton/settings.dart';

class AuthHttpClient extends OAuth2Helper {
  static late AuthHttpClient _instance;

  AuthHttpClient(super.client) : super(clientId: "umom-client", scopes: ["openid", "profile"]) {
    _instance = this;
  }

  static AuthHttpClient get instance => _instance;

  @override
  Future<Response> get(String url, {Map<String, String>? headers, Client? httpClient}) {
    return super.get(kBaseUrl + url, headers: headers, httpClient: httpClient);
  }

  @override
  Future<Response> post(String url, {Map<String, String>? headers, body, Client? httpClient}) {
    return super.post(kBaseUrl + url, headers: headers, body:  body, httpClient: httpClient);
  }

  @override
  Future<Response> delete(String url, {Map<String, String>? headers, Client? httpClient}) {
    return super.delete(kBaseUrl + url, headers: headers, httpClient: httpClient);
  }
}

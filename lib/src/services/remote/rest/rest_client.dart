import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

import '../../../models/api/errors/failure.dart';
import 'http_client.dart';

abstract class RestClient {
  Map<String, String>? headers;

  Future<Either<Failure, http.Response>> get({required Uri uri});

  Future<Either<Failure, http.Response>> post(
      {required Uri uri, required Map<String, dynamic> data, int timeout});

  Future<Either<Failure, http.Response>> upload(
      {required Uri uri, required Map<String, dynamic> data, int timeout});
}

class RestClientImpl implements RestClient {
  Map<String, String>? headers = {'Content-Type': 'application/json'};
  final HttpClient client;

  @override
  RestClientImpl({Map<String, String>? headers, required this.client}) {
    client.setWithCredentials(true);
  }

  Future<Either<Failure, http.Response>> get({required Uri uri}) async {
    try {
      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(
          title: 'Connection Problems',
          details: '',
          name: ErrorHandler.timeoutError,
          message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, http.Response>> post(
      {required Uri uri,
      required Map<String, dynamic> data,
      int timeout = 10}) async {
    late bool isProd;

    if (!kIsWeb) {
      isProd = bool.fromEnvironment('PROD', defaultValue: false);
    } else {
      isProd = true;
    }

    if (data['forceNewSession'] != null && data['forceNewSession']) {
      headers?.clear();
      headers?['Content-Type'] = 'application/json';
    }

    try {
      if (!isProd) {
        log('HEADERS: $headers');
        log('REQUEST ${uri.path}: $data');
      }

      final response = await client
          .post(uri, body: json.encode(data), headers: headers)
          .timeout(Duration(seconds: timeout));

      return Right(response);
    } on TimeoutException {
      return Left(ServerFailure(
          title: 'Timeout Error',
          details: '',
          name: ErrorHandler.timeoutError,
          message:
              'Couldn\'t connect to the server! Timeout after $timeout seconds'));
    } on Exception {
      return Left(ServerFailure(
          title: 'Connection Error',
          details: '',
          name: ErrorHandler.serverError,
          message: 'An Error while sending the Request occured'));
    }
  }

  @override
  Future<Either<Failure, http.Response>> upload(
      {required Uri uri,
      required Map<String, dynamic> data,
      int timeout = 10}) async {
    try {
      var request = http.MultipartRequest("POST", uri);

      request.headers.addAll(headers!);

      request.fields['clientId'] = data['clientId'];
      request.fields['fileId'] = data['fileId'];

      File file = data['file'];

      request.files.add(http.MultipartFile.fromBytes(
          'data', file.readAsBytesSync(),
          filename: basename(file.path)));

      final streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse)
          .timeout(Duration(seconds: timeout));

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(
          title: 'Connection Problems',
          details: '',
          name: ErrorHandler.timeoutError,
          message: e.toString()));
    }
  }
}

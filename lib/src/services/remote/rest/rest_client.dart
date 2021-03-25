import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../../models/api/errors/failure.dart';
import 'http_client.dart';

abstract class RestClient {
  Map<String, String>? headers;

  Future<Either<Failure, Response>> get({required Uri uri});

  Future<Either<Failure, Response>> post(
      {required Uri uri, required Map<String, dynamic> data, int timeout});

  Future<Either<Failure, Response>> upload(
      {required Uri uri,
      required String fileName,
      required Map<String, dynamic> data});
}

class RestClientImpl implements RestClient {
  Map<String, String>? headers = {'Content-Type': 'application/json'};
  HttpClient client;

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
          name: 'message.error',
          message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, http.Response>> post(
      {required Uri uri,
      required Map<String, dynamic> data,
      int timeout = 10}) async {
    if (data['forceNewSession'] != null && data['forceNewSession']) {
      headers?.clear();
      headers?['Content-Type'] = 'application/json';
    }

    try {
      log('REQUEST: $data');

      final response = await client
          .post(uri, body: json.encode(data), headers: headers)
          .timeout(Duration(seconds: timeout));

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(
          title: 'Connection Problems',
          details: '',
          name: 'message.error',
          message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, http.Response>> upload(
      {required Uri uri,
      required String fileName,
      required Map<String, dynamic> data}) {
    // TODO: implement upload
    throw UnimplementedError();
  }
}

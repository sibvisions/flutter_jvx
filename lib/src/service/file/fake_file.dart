/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class FakeFile implements File {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Uint8List byteContent = Uint8List(0);

  final String _path;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FakeFile(String pPath) : _path = pPath;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  File get absolute => this;

  @override
  String get path => _path;

  @override
  Future<Uint8List> readAsBytes() async {
    return byteContent;
  }

  @override
  Uint8List readAsBytesSync() {
    return byteContent;
  }

  @override
  Future<File> writeAsBytes(List<int> bytes, {FileMode mode = FileMode.write, bool flush = false}) async {
    byteContent = Uint8List.fromList(bytes);
    return this;
  }

  @override
  void writeAsBytesSync(List<int> bytes, {FileMode mode = FileMode.write, bool flush = false}) {
    byteContent = Uint8List.fromList(bytes);
  }

  @override
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    byteContent = Uint8List.fromList(contents.runes.toList());
    return this;
  }

  @override
  void writeAsStringSync(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    byteContent = Uint8List.fromList(contents.runes.toList());
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return utf8.decode(byteContent);
  }

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    return utf8.decode(byteContent);
  }

  // ----------------------------------- NO IMPL -------------------------------

  @override
  Future<File> copy(String newPath) async {
    throw UnimplementedError("Fake File");
  }

  @override
  File copySync(String newPath) {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<File> create({bool recursive = false, bool exclusive = false}) async {
    throw UnimplementedError("Fake File");
  }

  @override
  void createSync({bool recursive = false, bool exclusive = false}) {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    throw UnimplementedError("Fake File");
  }

  @override
  void deleteSync({bool recursive = false}) {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<bool> exists() {
    throw UnimplementedError("Fake File");
  }

  @override
  bool existsSync() {
    throw UnimplementedError("Fake File");
  }

  @override
  bool get isAbsolute => throw UnimplementedError("Fake File");

  @override
  Future<DateTime> lastAccessed() {
    throw UnimplementedError("Fake File");
  }

  @override
  DateTime lastAccessedSync() {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<DateTime> lastModified() {
    throw UnimplementedError("Fake File");
  }

  @override
  DateTime lastModifiedSync() {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<int> length() async {
    return byteContent.lengthInBytes;
  }

  @override
  int lengthSync() {
    return byteContent.lengthInBytes;
  }

  @override
  Future<RandomAccessFile> open({FileMode mode = FileMode.read}) {
    throw UnimplementedError("Fake File");
  }

  @override
  Stream<List<int>> openRead([int? start, int? end]) {
    throw UnimplementedError("Fake File");
  }

  @override
  RandomAccessFile openSync({FileMode mode = FileMode.read}) {
    throw UnimplementedError("Fake File");
  }

  @override
  IOSink openWrite({FileMode mode = FileMode.write, Encoding encoding = utf8}) {
    throw UnimplementedError("Fake File");
  }

  @override
  Directory get parent => throw UnimplementedError("Fake File");

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) {
    throw UnimplementedError("Fake File");
  }

  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<File> rename(String newPath) {
    throw UnimplementedError("Fake File");
  }

  @override
  File renameSync(String newPath) {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<String> resolveSymbolicLinks() {
    throw UnimplementedError("Fake File");
  }

  @override
  String resolveSymbolicLinksSync() {
    throw UnimplementedError("Fake File");
  }

  @override
  Future setLastAccessed(DateTime time) {
    throw UnimplementedError("Fake File");
  }

  @override
  void setLastAccessedSync(DateTime time) {
    throw UnimplementedError("Fake File");
  }

  @override
  Future setLastModified(DateTime time) {
    throw UnimplementedError("Fake File");
  }

  @override
  void setLastModifiedSync(DateTime time) {
    throw UnimplementedError("Fake File");
  }

  @override
  Future<FileStat> stat() {
    throw UnimplementedError("Fake File");
  }

  @override
  FileStat statSync() {
    throw UnimplementedError("Fake File");
  }

  @override
  Uri get uri => throw UnimplementedError("Fake File");

  @override
  Stream<FileSystemEvent> watch({int events = FileSystemEvent.all, bool recursive = false}) {
    throw UnimplementedError("Fake File");
  }
}

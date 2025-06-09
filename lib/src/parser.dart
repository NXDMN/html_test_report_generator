import 'dart:convert';
import 'dart:io';

import 'package:html_test_report_generator/src/models.dart';

class Parser {
  final bool parseError;
  final bool parsePrint;

  Parser({
    this.parseError = false,
    this.parsePrint = false,
  });

  Map<int, TestSuite> testSuites = {};
  Map<int, TestGroup> testGroups = {};
  Map<int, TestResult> tests = {};

  void parseFile(String path) {
    File(path).readAsLinesSync().forEach(_parseLine);
  }

  void _parseLine(String jsonString) {
    Map<String, dynamic> line;
    try {
      line = jsonDecode(jsonString);
    } catch (e) {
      return;
    }

    switch (line['type']) {
      case 'suite':
        _parseTestSuite(line);
        break;
      case 'group':
        _parseTestGroup(line);
        break;
      case 'testStart':
        _parseTestStart(line);
        break;
      case 'testDone':
        _parseTestDone(line);
        break;
      case 'error':
        if (parseError) _parseTestError(line);
        break;
      case 'print':
        if (parsePrint) _parseTestPrint(line);
        break;
      default:
        break;
    }
  }

  void _parseTestSuite(Map<String, dynamic> line) {
    int id = line['suite']['id'];

    final testSuite = testSuites.putIfAbsent(id, () => TestSuite());
    testSuite.id = id;
    testSuite.path = line['suite']['path'];
  }

  void _parseTestGroup(Map<String, dynamic> line) {
    int id = line['group']['id'];

    final testGroup = testGroups.putIfAbsent(id, () => TestGroup());
    testGroup.id = id;
    testGroup.suiteID = line['group']['suiteID'];
    testGroup.parentID = line['group']['parentID'];
    testGroup.name = line['group']['name'];
    if (line['group']['metadata']['skip']) {
      testGroup.state = State.skipped;
      testGroup.skipReason = line['group']['metadata']['skipReason'];
    }
    testGroup.testCount = line['group']['testCount'];
    testGroup.url = line['group']['url'];
    testGroup.state = State.success;
  }

  void _parseTestStart(Map<String, dynamic> line) {
    int id = line['test']['id'];

    final model = tests.putIfAbsent(id, () => TestResult());
    model.id = id;
    model.name = line['test']['name'];
    model.suiteID = line['test']['suiteID'];
    model.groupIDs = (line['test']['groupIDs'] as List).cast<int>();
    if (line['test']['metadata']['skip']) {
      model.state = State.skipped;
      model.skipReason = line['test']['metadata']['skipReason'];
    }
    model.url = line['test']['url'];
    model.startTime = line['time'];
  }

  void _parseTestDone(Map<String, dynamic> line) {
    int id = line['testID'];

    final model = tests[id];
    if (model != null) {
      if (line['result'] == 'success') {
        model.state = State.success;
      } else {
        model.state = State.failure;
        if (model.groupIDs != null) {
          for (int groupID in model.groupIDs!) {
            if (testGroups.containsKey(groupID)) {
              testGroups[groupID]!.state = State.failure;
            }
          }
        }
      }
      model.hidden = line['hidden'];
      model.endTime = line['time'];
    }
  }

  void _parseTestError(Map<String, dynamic> line) {
    int id = line['testID'];

    final model = tests[id];
    if (model != null) {
      model.errorMessage = line['error'];
      model.stackTrace = line['stackTrace'];
    }
  }

  void _parseTestPrint(Map<String, dynamic> line) {
    int id = line['testID'];

    final model = tests[id];
    if (model != null) {
      model.printMessages ??= [];
      model.printMessages?.add(line['message']);
    }
  }
}

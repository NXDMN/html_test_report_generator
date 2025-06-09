import 'dart:io';

import 'package:html_test_report_generator/src/html_test_report_generator_base.dart';
import 'package:html_test_report_generator/src/models.dart';
import 'package:test/test.dart';

void main() {
  final outputPath = "test/test_report.html";
  final Map<int, TestSuite> mockTestSuites = {
    1: TestSuite()..id = 1,
  };
  final Map<int, TestGroup> mockTestGroups = {
    1: TestGroup()
      ..id = 1
      ..suiteID = 1
      ..name = "TestGroup 1"
      ..state = State.success
      ..testCount = 1,
    2: TestGroup()
      ..id = 2
      ..suiteID = 1
      ..parentID = 1
      ..name = "TestGroup 2"
      ..state = State.success
      ..testCount = 1,
    3: TestGroup()
      ..id = 3
      ..suiteID = 1
      ..name = "TestGroup 2"
      ..state = State.success
      ..testCount = 1,
    4: TestGroup()
      ..id = 4
      ..suiteID = 1
      ..parentID = 1
      ..name = "TestGroup 2"
      ..state = State.success
      ..testCount = 1
  };
  final Map<int, TestResult> mockTests = {
    1: TestResult()
      ..id = 1
      ..suiteID = 1
      ..groupIDs = []
      ..hidden = false
      ..errorMessage = "Error"
      ..printMessages = ["Print"]
      ..state = State.success
      ..startTime = 100
      ..endTime = 1,
    2: TestResult()
      ..id = 2
      ..suiteID = 1
      ..groupIDs = []
      ..hidden = false
      ..state = State.success
      ..startTime = 100
      ..endTime = 1,
    3: TestResult()
      ..id = 3
      ..suiteID = 1
      ..groupIDs = [1, 2, 3]
      ..hidden = false
      ..state = State.success
      ..startTime = 100
      ..endTime = 1,
    4: TestResult()
      ..id = 4
      ..suiteID = 1
      ..groupIDs = [1, 3]
      ..hidden = false
      ..state = State.success
      ..startTime = 100
      ..endTime = 1,
  };

  group('html_test_report_generator_base.dart', () {
    tearDown(() async {
      if (await File(outputPath).exists()) {
        await File(outputPath).delete();
      }
      suiteToGroupsMap = {};
      suiteToTestsMap = {};
      parentGroupToGroupsMap = {};
      groupToTestsMap = {};
    });

    test('run', () async {
      run("test/test_report.json", outputPath);
      final actual = await File(outputPath).exists();
      expect(actual, true);
    });

    test('groupAllTests', () {
      groupAllTests(mockTestSuites, mockTestGroups, mockTests);
      expect(suiteToGroupsMap, isNotEmpty);
      expect(suiteToTestsMap, isNotEmpty);
      expect(parentGroupToGroupsMap, isNotEmpty);
      expect(groupToTestsMap, isNotEmpty);
    });

    test('displayTestGroup', () {
      final text = displayTestGroup(mockTestGroups[1]!);
      expect(text, isNotEmpty);
    });

    test('displayTestResult', () {
      final text = displayTestResult(mockTests[1]!);
      expect(text, isNotEmpty);
    });
  });
}

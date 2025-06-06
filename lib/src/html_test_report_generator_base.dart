import 'dart:io';

import 'package:html_test_report_generator/src/models.dart';
import 'package:html_test_report_generator/src/parser.dart';

Map<int, List<TestGroup>> suiteToGroupsMap = {};
Map<int, List<TestResult>> suiteToTestsMap = {};
Map<int, List<TestGroup>> parentGroupToGroupsMap = {};
Map<int, List<TestResult>> groupToTestsMap = {};

void run(String filePath, String outputFilePath) async {
  final parser = Parser()..parseFile(filePath);

  groupAllTests(parser.testSuites, parser.testGroups, parser.tests);

  int totalTestCount = 0;
  int success = 0;
  int skipped = 0;
  int failure = 0;

  for (var test in parser.tests.values) {
    if (test.hidden == false) {
      totalTestCount++;
      switch (test.state) {
        case State.success:
          success++;
          break;
        case State.skipped:
          skipped++;
          break;
        case State.failure:
          failure++;
          break;
        default:
          break;
      }
    }
  }

  String htmlContent = "";
  for (var suiteID in parser.testSuites.keys) {
    htmlContent += "<div>";
    final suite = parser.testSuites[suiteID]!;
    htmlContent +=
        '''<h4 class="testSuite">${suite.path!.substring(suite.path!.lastIndexOf('/') + 1)}</h4>''';
    htmlContent += '''<div class="inner">''';
    final testGroups = suiteToGroupsMap[suiteID];
    if (testGroups != null) {
      htmlContent += testGroups.map((testGroup) {
        if (parentGroupToGroupsMap.containsKey(testGroup.id)) {
          String groupContent = displayTestGroup(testGroup);
          groupContent += '''<div class="inner">''';
          if (groupToTestsMap.containsKey(testGroup.id)) {
            List<TestResult> childTests = groupToTestsMap[testGroup.id]!;
            groupContent +=
                childTests.map((test) => displayTestResult(test)).join("\n");
          }
          List<TestGroup> childGroups = parentGroupToGroupsMap[testGroup.id]!;
          for (var childGroup in childGroups) {
            if (groupToTestsMap.containsKey(childGroup.id)) {
              List<TestResult> childTests = groupToTestsMap[childGroup.id]!;
              groupContent += '''
${displayTestGroup(childGroup)}
<div class="inner">
  ${childTests.map((test) => displayTestResult(test)).join("\n")}
</div>
        ''';
            } else {
              groupContent += displayTestGroup(childGroup);
            }
          }
          groupContent += "</div>";
          return groupContent;
        } else {
          if (groupToTestsMap.containsKey(testGroup.id)) {
            List<TestResult> children = groupToTestsMap[testGroup.id]!;
            return '''
${displayTestGroup(testGroup)}
<div class="inner">
  ${children.map((test) => displayTestResult(test)).join("\n")}
</div>
        ''';
          }
          return displayTestGroup(testGroup);
        }
      }).join("\n");
    }

    final testResults = suiteToTestsMap[suiteID];
    if (testResults != null) {
      htmlContent +=
          testResults.map((test) => displayTestResult(test)).join("\n");
    }

    htmlContent += "</div>";
    htmlContent += "</div>";
  }

  final file = File(outputFilePath).openWrite();
  file.write('''<!DOCTYPE html>
<html>
  <head>
    <title>Test Report</title>
    <style type="text/css">
      * {
        margin: 0;
        padding: 0;
      }
      html, body {
        height: 100%;
      }
      .header {
        background-color: lightsteelblue;
        padding: 20px 40px;
        font-size: 2em;
        font-weight: bold;
      }
      .content {
        padding: 50px;
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
      .testSuite {
        background-color: lightsteelblue;
        padding: 10px;
      }
      .testGroup {
        padding: 10px;
        border-left: 4px solid;
        display: flex;
        justify-content: space-between;
      }
      .testResult {
        padding: 10px;
        border-left: 4px solid;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      div.success {
        border-color: green;
      }
      div.skipped {
        border-color: gray;
      }
      div.failure {
        border-color: red;
      }
      .duration {
        display: inline-block;
        width: 4em;
        text-align: right;
      }
      .inner {
        margin-left: 20px;
      }
    </style>
  </head>
  <body>
    <div class="header">
      <span>All Tests:</span>&nbsp;
      <span>$totalTestCount total</span>&#44;&nbsp;
      <span style="color: green;">$success success</span>&#44;&nbsp;
      <span style="color: red;">$failure failed</span>&#44;&nbsp;
      <span style="color: gray;">$skipped skipped</span>
    </div>
    <div class="content">$htmlContent</div>
  </body>
</html>
  ''');
  await file.close();
}

void groupAllTests(
  Map<int, TestSuite> testSuites,
  Map<int, TestGroup> testGroups,
  Map<int, TestResult> tests,
) {
  for (var test in tests.values.toList()) {
    if (test.hidden == false) {
      if (test.suiteID != null &&
          (test.groupIDs == null || test.groupIDs!.isEmpty)) {
        if (suiteToTestsMap.containsKey(test.suiteID)) {
          suiteToTestsMap[test.suiteID]?.add(test);
        } else {
          suiteToTestsMap[test.suiteID!] = [test];
        }
      }

      if (test.groupIDs != null && test.groupIDs!.isNotEmpty) {
        List<int> ids = test.groupIDs!;
        for (var groupID in test.groupIDs!.toList()) {
          final group = testGroups[groupID]!;
          if (test.groupIDs!.contains(group.parentID)) {
            ids.remove(group.parentID);
          }
        }

        for (var id in ids) {
          final group = testGroups[id]!;
          if (group.name != null && group.name!.isNotEmpty) {
            test.name = test.name?.replaceAll(group.name!, "").trim();

            group.duration += (test.endTime! - test.startTime!);

            if (groupToTestsMap.containsKey(id)) {
              groupToTestsMap[id]?.add(test);
            } else {
              groupToTestsMap[id] = [test];
            }
          }
        }
      }
    }
  }

  for (var testGroup in testGroups.values.toList()) {
    if (testGroup.parentID != null) {
      final parent = testGroups[testGroup.parentID]!;
      if (parent.name != null && parent.name!.isNotEmpty) {
        testGroup.name = testGroup.name?.replaceAll(parent.name!, "").trim();

        parent.duration += testGroup.duration;

        if (parentGroupToGroupsMap.containsKey(testGroup.parentID)) {
          parentGroupToGroupsMap[testGroup.parentID]?.add(testGroup);
        } else {
          parentGroupToGroupsMap[testGroup.parentID!] = [testGroup];
        }
      }
    }
  }

  for (var testGroup in testGroups.values.toList()) {
    if (testGroup.suiteID != null) {
      if ((testGroup.parentID == null ||
              !parentGroupToGroupsMap.containsKey(testGroup.parentID)) &&
          testGroup.name != null &&
          testGroup.name!.isNotEmpty) {
        if (suiteToGroupsMap.containsKey(testGroup.suiteID)) {
          suiteToGroupsMap[testGroup.suiteID]?.add(testGroup);
        } else {
          suiteToGroupsMap[testGroup.suiteID!] = [testGroup];
        }
      }
    }
  }
}

String displayTestGroup(TestGroup group) {
  return '''
<div class="testGroup ${group.state?.name}">
  <span>Group: <b>${group.name}</b> (${group.testCount} test${(group.testCount ?? 0) > 1 ? "s" : ""})</span>
  <div style="min-width: 10%">
    <span style="color:${group.state?.color};">${group.state?.text}</span>
    <span class="duration">${group.durationText}</span>
  </div>
</div>
''';
}

String displayTestResult(TestResult test) {
  String errorDisplay = "";
  if (test.errorMessage != null) {
    errorDisplay = '''
<span style="font-weight: bold">Error:</span>
<span>${test.errorMessage}</span>
''';
  }

  return '''
<div class="testResult ${test.state?.name}">
  <div style="display: flex; flex-direction: column">
    <span>${test.name}</span>
    $errorDisplay
  </div>
  <div style="min-width: 10%">
    <span style="color:${test.state?.color};">${test.state?.text}</span>
    <span class="duration">${test.durationText}</span>
  </div>
</div>
''';
}

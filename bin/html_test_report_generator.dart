import 'dart:io';

import 'package:html_test_report_generator/html_test_report_generator.dart'
    as html_test_report_generator;

void main(List<String> args) {
  final usage =
      '''Usage: html_test_report_generator <test-result-file> [arguments]

Global options:
-h, --help        Print this usage information.
-o, --output      Specify the output html report file path.
-e, --error       Include exception error message.
-p, --print       Include system output message.
''';

  if (args.isEmpty || args.contains("-h") || args.contains("--help")) {
    stdout.writeln("Generate html report for flutter test results.\n");
    stdout.writeln(usage);
    exitCode = 0;
    return;
  }

  final filePath = args.first;

  if (!FileSystemEntity.isFileSync(filePath)) {
    stderr.writeln("\"$filePath\" is not a file.\n");
    stdout.writeln(usage);
    exitCode = 2;
    return;
  }

  String? outputFilePath;
  bool hasErrorMessage = false;
  bool hasPrintMessage = false;
  for (var i = 1; i < args.length; i++) {
    if (args[i] == "-o" || args[i] == "--output") {
      outputFilePath = args.elementAtOrNull(++i);
      if (outputFilePath == null) break;
    }

    if (args[i] == "-e" || args[i] == "--error") {
      hasErrorMessage = true;
    }

    if (args[i] == "-p" || args[i] == "--print") {
      hasPrintMessage = true;
    }
  }

  if (outputFilePath == null) {
    stderr.writeln(
        "Please specify the file path of generated html test report.\n");
    stdout.writeln(usage);
    exitCode = 2;
    return;
  }

  if (!outputFilePath.endsWith(".html")) {
    outputFilePath += ".html";
  }

  html_test_report_generator.run(
    filePath,
    outputFilePath,
    hasErrorMessage: hasErrorMessage,
    hasPrintMessage: hasPrintMessage,
  );
}

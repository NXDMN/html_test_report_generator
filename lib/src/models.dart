class TestSuite {
  int? id;
  String? path;
}

class TestGroup {
  int? id;
  int? suiteID;
  int? parentID;
  String? name;
  State? state;
  String? skipReason;
  int? testCount;
  String? url;
  int duration = 0;

  String get durationText {
    if (duration <= 0) return "";

    if (duration > 99) return "${(duration / 1000.0).toStringAsFixed(2)} s";

    return "$duration ms";
  }
}

class TestResult {
  int? id;
  String? name;
  int? suiteID;
  List<int>? groupIDs;
  State? state;
  String? skipReason;
  String? errorMessage;
  String? stackTrace;
  String? url;
  bool? hidden;
  int? startTime;
  int? endTime;

  String get durationText {
    final duration = endTime! - startTime!;
    if (duration <= 0) return "";

    if (duration > 99) return "${(duration / 1000.0).toStringAsFixed(2)} s";

    return "$duration ms";
  }
}

enum State {
  success("Success", "green"),
  skipped("Skipped", "gray"),
  failure("Failed", "red");

  const State(this.text, this.color);

  final String text;
  final String color;
}

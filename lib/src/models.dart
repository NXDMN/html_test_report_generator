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
}

class TestResult {
  int? id;
  String? name;
  int? suiteID;
  List<int>? groupIDs;
  State? state;
  String? skipReason;
  String? url;
  bool? hidden;
}

enum State {
  success("Success", "green"),
  skipped("Skipped", "gray"),
  failure("Failed", "red");

  const State(this.text, this.color);

  final String text;
  final String color;
}

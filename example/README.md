# Example

Generate json report from the tests
`flutter test --file-reporter json:test/test_report.json`

Pass in the generated json file as input
`dart run bin/html_test_report_generator.dart test_report.json -o test_report.html`

Run `dart run bin/html_test_report_generator.dart --help` for all supported command line flags.

import 'package:flutter_test/flutter_test.dart';
import 'package:route_rush/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const RouteRushApp());
    await tester.pump();
  });
}

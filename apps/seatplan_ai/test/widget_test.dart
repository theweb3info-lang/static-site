import 'package:flutter_test/flutter_test.dart';
import 'package:seatplan_ai/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const SeatPlanApp());
    expect(find.text('宾客管理'), findsOneWidget);
  });
}

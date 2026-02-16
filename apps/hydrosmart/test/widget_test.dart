import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrosmart/app/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HydroSmartApp()));
    expect(find.text('HydroSmart 💧'), findsOneWidget);
  });
}

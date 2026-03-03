import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krentals/main.dart';
import 'package:krentals/core/di/service_locator.dart';

void main() {
  testWidgets('App compiles and runs smoke test', (WidgetTester tester) async {
    ServiceLocator.setup();
    await tester.pumpWidget(const KRentalsApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

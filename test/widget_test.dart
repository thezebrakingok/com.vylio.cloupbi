import 'package:flutter_test/flutter_test.dart';

import 'package:cloupbi/main.dart';

void main() {
  testWidgets('muestra la pantalla inicial de CloUP BI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CloUpBiApp());
    await tester.pump();

    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Descubrir'), findsOneWidget);
  });
}

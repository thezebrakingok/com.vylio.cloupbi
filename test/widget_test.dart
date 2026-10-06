import 'package:flutter_test/flutter_test.dart';

import 'package:cloupbi/main.dart';

void main() {
  testWidgets('muestra el aviso de configuración inicial de CloUP BI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CloUpBiApp());
    await tester.pump();

    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.byType(ConfigurationNotice), findsOneWidget);
    expect(find.text('Falta configurar Supabase'), findsOneWidget);
  });
}

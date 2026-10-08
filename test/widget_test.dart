import 'package:flutter_test/flutter_test.dart';
import 'package:rushd/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('RUSHD launches', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RushdApp()));
    await tester.pump();
    expect(find.text('Assalamu Alaikum'), findsOneWidget);
  });
}

import 'package:erpnext_stock_mobile/src/core/search/search_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compareSearchRelevance prefers title match over subtitle match', () {
    final compare = compareSearchRelevance(
      query: 'xotlunch',
      leftPrimary: 'Banoffy',
      leftSecondary: const ['Xot Lanch • Banoffy'],
      rightPrimary: 'xot lanch sochnaya kuritsa 90gr',
      rightSecondary: const ['Saidamin • xot lanch sochnaya kuritsa 90gr'],
    );

    expect(compare, greaterThan(0));
  });

  test('compareSearchRelevance handles near-prefix fuzzy match', () {
    final compare = compareSearchRelevance(
      query: 'xotlunch',
      leftPrimary: 'xot lanch ostriy 90gr',
      rightPrimary: 'Banoffy',
    );

    expect(compare, lessThan(0));
  });
}

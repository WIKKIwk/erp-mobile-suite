import 'package:erpnext_stock_mobile/src/core/widgets/app_retry_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retry icon scales from phone width', () {
    expect(
      AppRetryState.retryIconSizeFor(const Size(390, 844)),
      closeTo(113.1, 0.1),
    );
  });

  test('retry icon grows on larger phones', () {
    expect(
      AppRetryState.retryIconSizeFor(const Size(430, 932)),
      closeTo(124.7, 0.1),
    );
  });

  test('top inset stays within stable bounds', () {
    expect(AppRetryState.topInsetFor(const Size(320, 568)), 140);
    expect(
      AppRetryState.topInsetFor(const Size(430, 932)),
      closeTo(186.4, 0.1),
    );
  });
}

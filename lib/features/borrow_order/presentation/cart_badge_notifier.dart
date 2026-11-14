import 'package:flutter/foundation.dart';

/// Signals that the draft borrow cart changed.
///
/// The cart is served by short-lived [BorrowOrderBloc] instances (one per
/// screen), so a cart badge on another screen cannot observe a mutation made by
/// the cart screen's bloc. Every mutation bumps this counter and all mounted
/// badges reload their own draft.
///
/// Keep this dependency light: it only exposes a [ValueNotifier] so it can be
/// used from blocs and widgets alike.
final ValueNotifier<int> cartRevision = ValueNotifier<int>(0);

/// Marks the draft cart as changed so badges refresh their item count.
void markCartChanged() => cartRevision.value++;

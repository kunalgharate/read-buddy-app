import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/contribute/data/money_donation_service.dart';

part 'contribute_state.dart';

class ContributeCubit extends Cubit<ContributeState> {
  final MoneyDonationService _moneyDonationService;

  ContributeCubit(this._moneyDonationService)
      : super(const ContributeInitial());

  Future<void> loadMoneyDonations() async {
    emit(const ContributeLoading());
    try {
      final donations = await _moneyDonationService.fetchMyMoneyDonations();
      final confirmed = donations.where((d) {
        final status = d.status.toLowerCase();
        return status == 'completed' ||
            status == 'success' ||
            status == 'received';
      }).toList();
      final totalAmount = confirmed.fold<int>(0, (sum, d) => sum + d.amount);
      emit(ContributeLoaded(
        moneyDonations: donations,
        totalMoneyDonated: totalAmount,
      ));
    } catch (e) {
      emit(ContributeError(e.toString()));
    }
  }
}

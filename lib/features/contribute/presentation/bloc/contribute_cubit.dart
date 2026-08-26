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
      final totalAmount = donations.fold<int>(0, (sum, d) => sum + d.amount);
      emit(ContributeLoaded(
        moneyDonations: donations,
        totalMoneyDonated: totalAmount,
      ));
    } catch (_) {
      emit(const ContributeLoaded(
        moneyDonations: [],
        totalMoneyDonated: 0,
      ));
    }
  }
}

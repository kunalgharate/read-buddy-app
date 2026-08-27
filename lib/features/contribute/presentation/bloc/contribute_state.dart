part of 'contribute_cubit.dart';

sealed class ContributeState extends Equatable {
  const ContributeState();

  @override
  List<Object?> get props => [];
}

class ContributeInitial extends ContributeState {
  const ContributeInitial();
}

class ContributeLoading extends ContributeState {
  const ContributeLoading();
}

class ContributeLoaded extends ContributeState {
  final List<MoneyDonationRecord> moneyDonations;
  final int totalMoneyDonated;

  const ContributeLoaded({
    required this.moneyDonations,
    required this.totalMoneyDonated,
  });

  @override
  List<Object?> get props => [moneyDonations, totalMoneyDonated];
}

class ContributeError extends ContributeState {
  final String message;

  const ContributeError(this.message);

  @override
  List<Object?> get props => [message];
}

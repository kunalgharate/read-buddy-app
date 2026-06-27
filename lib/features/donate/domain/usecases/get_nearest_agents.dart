import 'package:read_buddy_app/features/donate/domain/entities/agent.dart';
import 'package:read_buddy_app/features/donate/domain/repositories/donate_repository.dart';

class GetNearestAgents {
  final DonateRepository repository;

  GetNearestAgents({required this.repository});

  Future<List<Agent>> call() async {
    return await repository.getNearestAgents();
  }
}

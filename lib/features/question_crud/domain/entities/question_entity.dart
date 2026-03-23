import 'package:equatable/equatable.dart';

enum QuestionType { single, multiple }

class QuestionEntity extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final QuestionType type;

  const QuestionEntity({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
  });

  @override
  List<Object?> get props => [id, question, options, type];
}

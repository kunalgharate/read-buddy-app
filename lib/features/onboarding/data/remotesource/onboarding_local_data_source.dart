import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/onboarding_model.dart';

class OnboardingLocalDataSource {

// onboarding_local_data_source.dart
  Future<List<OnboardingQuestionModel>> getQuestions() async {
    final jsonString =
    await rootBundle.loadString('assets/mock/onboarding_question.json');

    final List<dynamic> data = jsonDecode(jsonString); // it's a List, not a Map

    return data.map((e) => OnboardingQuestionModel.fromJson(e)).toList();
  }
}
class SelectionStore {
  static final List<String> selectedAnswers = [];

  static void addAnswer(String answer) {
    if (!selectedAnswers.contains(answer)) {
      selectedAnswers.add(answer);
    }
  }

  static void removeAnswer(String answer) {
    selectedAnswers.remove(answer);
  }

  static void clearAnswers() {
    selectedAnswers.clear();
  }

  static List<String> getAnswers() => List.from(selectedAnswers);
}

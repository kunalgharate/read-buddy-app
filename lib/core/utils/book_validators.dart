// validator.dart
class BookFormValidators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? isNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? yearValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    final year = int.tryParse(value);
    if (year == null || year < 1000 || year > DateTime.now().year) {
      return 'Enter a valid year';
    }
    return null;
  }
}

class BookFormValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Book title is required';
    }
    return null;
  }

  static String? validateAuthor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Author name is required';
    }
    return null;
  }

  static String? validatePages(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Number of pages is required';
    }
    final pages = int.tryParse(value);
    if (pages == null || pages <= 0) {
      return 'Enter a valid number of pages';
    }
    return null;
  }

  static String? validateISBN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ISBN is required';
    }

    String isbn = value.replaceAll('-', '').replaceAll(' ', '');

    final isISBN10 = RegExp(r'^\d{9}[\dXx]$').hasMatch(isbn);
    final isISBN13 = RegExp(r'^\d{13}$').hasMatch(isbn);

    if (!isISBN10 && !isISBN13) {
      return 'Invalid ISBN format (should be ISBN-10 or ISBN-13)';
    }

    return null;
  }

  static String? validatePublisher(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Publisher is required';
    }
    return null;
  }

  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    final year = int.tryParse(value);
    if (year == null || year < 1000 || year > DateTime.now().year) {
      return 'Enter a valid year';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category is required';
    }
    return null;
  }

  static String? validateGenre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Genre is required';
    }
    return null;
  }

  static String? validateLanguage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Language is required';
    }
    return null;
  }

  static String? validateFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Book format is required';
    }
    return null;
  }

  // ====================== Condition & Description ======================
  static String? validateCondition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Condition is required';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Notes are required';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    return null;
  }

  // ====================== Owner Info ======================
  static String? validateOwnerId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner ID is required';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    return null;
  }

  // ====================== Media ======================
  static String? validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Image URL is required';
    }
    // Future: You can add URL pattern check here if needed
    return null;
  }

  static String? validateImages(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please upload at least one image';
    }
    return null;
  }

  // ====================== Tags ======================
  static String? validateTags(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tags are required';
    }
    return null;
  }

//=================Banner Type validations==================

  static String? validateBannerTypes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Banner type is required';
    }
    return null;
  }

  static String? validateBannerTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Banner Title is  required';
    }
    return null;
  }

  static String? validateBannerDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Banner Description is  required';
    }
    return null;
  }

  static String? validateBannerLink(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Banner Link is  required';
    }
    return null;
  }
}

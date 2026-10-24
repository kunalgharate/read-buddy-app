/// Centralised authorisation checks.
///
/// Roles are plain strings from the backend (`'user'`, `'librarian'`,
/// `'admin'`) — there is no enum and no capability map anywhere in the app.
/// Every UI/route gate that decides "can this user do X?" must use an
/// allow-list defined here so the checks cannot drift apart.
class AccessControl {
  /// Roles allowed behind "Manage Books": create / edit / publish / delete
  /// books, their variants, and their categories.
  ///
  /// * `admin` — Admin
  /// * `librarian` — Library Manager
  static const Set<String> bookManagerRoles = {'admin', 'librarian'};

  /// Whether [role] may access book-management functionality.
  ///
  /// Fails closed: `null`, empty, or unknown roles are denied.
  static bool canManageBooks(String? role) {
    if (role == null) return false;
    final normalised = role.trim().toLowerCase();
    if (normalised.isEmpty) return false;
    return bookManagerRoles.contains(normalised);
  }
}

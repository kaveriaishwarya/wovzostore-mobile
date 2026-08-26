/// User roles matching backend `AppRoles`.
enum AppRole {
  customer,
  storeManager,
  admin,
  superAdmin,
}

class AuthRoleHelper {
  static const allowedAnalyticsRoles = {
    AppRole.storeManager,
    AppRole.admin,
    AppRole.superAdmin,
  };

  /// Returns true if the provided role is authorized to view Analytics reports.
  static bool canAccessAnalytics(AppRole? role) {
    if (role == null) return false;
    return allowedAnalyticsRoles.contains(role);
  }

  /// Parses role string from JWT claims.
  static AppRole? fromClaim(String? claim) {
    if (claim == null) return null;
    switch (claim.toLowerCase()) {
      case 'superadmin':
        return AppRole.superAdmin;
      case 'admin':
        return AppRole.admin;
      case 'storemanager':
        return AppRole.storeManager;
      case 'customer':
        return AppRole.customer;
      default:
        return null;
    }
  }
}

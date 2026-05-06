class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String storageUrl = 'http://10.0.2.2:8000/storage';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // Dashboard
  static const String dashboardAdmin = '/dashboard/admin';
  static const String dashboardMember = '/dashboard/member';

  // Members
  static const String members = '/members';

  // Savings
  static const String savings = '/savings';
  static const String savingsDeposit = '/savings/deposit';
  static const String savingsWithdraw = '/savings/withdraw';
  static const String mandatorySavings = '/savings/mandatory';
  static const String payMandatory = '/savings/mandatory/pay';
  static const String principalSaving = '/savings/principal';

  // Financing
  static const String financings = '/financings';
  static const String financingSimulate = '/financings/simulate';

  // Products
  static const String categories = '/products/categories';
  static const String products = '/products';

  // Social Fund
  static const String socialFunds = '/social-funds';
  static const String socialFundApplications = '/social-funds/applications';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';

  // Reports
  static const String reportMembersPdf = '/reports/members/pdf';
  static const String reportMembersExcel = '/reports/members/excel';
  static const String reportSavingsPdf = '/reports/savings/pdf';
  static const String reportSavingsExcel = '/reports/savings/excel';
  static const String reportFinancingsPdf = '/reports/financings/pdf';
  static const String reportFinancingsExcel = '/reports/financings/excel';
  static const String reportSocialFundsPdf = '/reports/social-funds/pdf';
  static const String reportSocialFundsExcel = '/reports/social-funds/excel';
}

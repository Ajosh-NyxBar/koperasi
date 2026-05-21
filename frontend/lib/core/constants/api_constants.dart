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
  static const String deviceTokens = '/device-tokens';

  // Penalties
  static const String penaltyOverview = '/penalties/overview';
  static const String penaltySettings = '/penalties/settings';
  static const String penaltyWaivers = '/penalties/waivers';
  static String penaltyWaive(int installmentId) => '/penalties/installments/$installmentId/waive';

  // Reports
  static const String reportMembers = '/reports/members';
  static const String reportMembersPdf = '/reports/members';
  static const String reportMembersExcel = '/reports/members';
  static const String reportSavings = '/reports/savings';
  static const String reportSavingsPdf = '/reports/savings';
  static const String reportSavingsExcel = '/reports/savings';
  static const String reportFinancings = '/reports/financings';
  static const String reportFinancingsPdf = '/reports/financings';
  static const String reportFinancingsExcel = '/reports/financings';
  static const String reportSocialFunds = '/reports/social-funds';
  static const String reportSocialFundsPdf = '/reports/social-funds';
  static const String reportSocialFundsExcel = '/reports/social-funds';
}

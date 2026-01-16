class AppRoutes {
  static const splash = "/";
  static const auth = "/auth";

  static const ownerHome = ownerDashboard;
  // ✅ Owner sub routes (for tabs)
  static const ownerDashboard = "/owner/dashboard";
  static const ownerProjects = "/owner/projects";
  static const ownerApprovals = "/owner/approvals";
  static const ownerChat = "/owner/chat";
  static const ownerDocs = "/owner/docs";

  // Engineer deep routes
  static const engineerDashboard = "/engineer/dashboard";
  static const engineerProjects = "/engineer/projects";
  static const engineerTasks = "/engineer/tasks";
  static const engineerMaterialsFunds = "/engineer/materials-funds";
  static const engineerChat = "/engineer/chat";

// Default
  static const engineerHome = engineerDashboard;

  // ✅ Manager deep routes
  static const managerDashboard = "/manager/dashboard";
  static const managerProjects = "/manager/projects";
  static const managerTasks = "/manager/tasks";
  static const managerMaterialsFunds = "/manager/materials-funds";
  static const managerChat = "/manager/chat";

// Default
  static const managerHome = managerDashboard;

  // ✅ Client deep routes
  static const clientOverview = "/client/overview";
  static const clientSiteView = "/client/siteview";
  static const clientUpdates = "/client/updates";
  static const clientDocs = "/client/docs";
  static const clientChat = "/client/chat";

  // Client SiteView sub-pages
  static const clientMapView = "/client/siteview/map";
  static const client2DView = "/client/siteview/2d";
  static const client3DView = "/client/siteview/3d";
  static const clientCameraView = "/client/siteview/camera";

// Default
  static const clientHome = clientOverview;

  static const profile = "/profile";
  static const settings = "/settings";
  // settings sub-pages
  static const settingsGeneral = "/settings/general";
  static const settingsChats = "/settings/chats";
  static const settingsNotifications = "/settings/notifications";
  static const settingsAccessibility = "/settings/accessibility";
  static const settingsCalls = "/settings/calls";
  static const settingsAbout = "/settings/about";
  static const settingsHelp = "/settings/help";
  static const terms = "/settings/terms";
  static const supportFaq = "/settings/support/faq";
  static const supportChat = "/settings/support/chat";
  static const supportRaiseTicket = "/settings/support/raise-ticket";
  static const supportTrackTicket = "/settings/support/track-ticket";
  static const supportTutorials = "/settings/support/tutorials";
  static const supportReportProblem = "/settings/support/report-problem";
  static const supportFeedback = "/settings/support/feedback";

  //Docs
  static const ownerDocsProfileReport = "/owner/docs/profile-report";
  static const ownerDocsProposal = "/owner/docs/proposal";
  static const ownerDocsQuotation = "/owner/docs/quotation";
  static const ownerDocsPurchaseOrder = "/owner/docs/purchase-order";
  static const ownerDocsGstInvoice = "/owner/docs/gst-invoice";

  static const assistantChat = "/assistant/chat";

}

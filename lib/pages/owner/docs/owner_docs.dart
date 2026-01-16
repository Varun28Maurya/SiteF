import 'package:flutter/material.dart';

class OwnerDocsPage extends StatelessWidget {
  const OwnerDocsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        const Text(
          "Paperwork & Billing",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Manage all financial & compliance documents from one place",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 18),

        // GRID
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 720 ? 2 : 1,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.8,
            children: const [
              PaperCard(
                title: "Profile Report",
                desc: "Generate project & company profile report",
                icon: Icons.person,
                bg: Color(0xFFEFF6FF),
                fg: Color(0xFF2563EB),
                routeName: "/owner/docs/profile-report",
              ),
              PaperCard(
                title: "Proposal",
                desc: "Create proposal for client approval",
                icon: Icons.description_rounded,
                bg: Color(0xFFECFDF5),
                fg: Color(0xFF059669),
                routeName: "/owner/docs/proposal",
              ),
              PaperCard(
                title: "Quotation",
                desc: "Prepare cost estimates and quotations",
                icon: Icons.request_quote_rounded,
                bg: Color(0xFFFFFBEB),
                fg: Color(0xFFD97706),
                routeName: "/owner/docs/quotation",
              ),
              PaperCard(
                title: "Purchase Order",
                desc: "Approve and issue purchase orders",
                icon: Icons.shopping_cart_rounded,
                bg: Color(0xFFF0FDF4),
                fg: Color(0xFF16A34A),
                routeName: "/owner/docs/purchase-order",
              ),
              PaperCard(
                title: "GST Ready Invoicing",
                desc: "Generate GST-compliant invoices",
                icon: Icons.receipt_long_rounded,
                bg: Color(0xFFEEF2FF),
                fg: Color(0xFF4F46E5),
                routeName: "/owner/docs/gst-invoice",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// CARD COMPONENT (like React PaperCard)
/// ============================================================
class PaperCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final String routeName;

  final Color bg;
  final Color fg;

  const PaperCard({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.routeName,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON BOX
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: fg, size: 22),
              ),

              const SizedBox(height: 14),

              // TITLE
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 6),

              // DESC
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 14),


              // OPEN →
              Text(
                "Open →",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

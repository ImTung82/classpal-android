import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExpandableListWrapper extends StatefulWidget {
  final List<Widget> children;
  final int initialItems;
  final String seeMoreLabel;

  const ExpandableListWrapper({
    super.key,
    required this.children,
    this.initialItems = 5,
    this.seeMoreLabel = "mục khác",
  });

  @override
  State<ExpandableListWrapper> createState() => _ExpandableListWrapperState();
}

class _ExpandableListWrapperState extends State<ExpandableListWrapper> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool canExpand = widget.children.length > widget.initialItems;

    final displayList = isExpanded
        ? widget.children
        : widget.children.take(widget.initialItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayList,

        // Hiển thị nút bấm nếu danh sách dài hơn initialItems
        if (canExpand)
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded
                        ? "Thu gọn"
                        : "Xem thêm ${widget.children.length - widget.initialItems} ${widget.seeMoreLabel}",
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 16,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

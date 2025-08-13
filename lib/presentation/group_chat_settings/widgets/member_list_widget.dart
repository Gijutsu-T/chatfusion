import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MemberListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final bool isAdmin;
  final Function(Map<String, dynamic>) onMemberTap;
  final Function(Map<String, dynamic>) onMakeAdmin;
  final Function(Map<String, dynamic>) onRemoveMember;
  final Function(Map<String, dynamic>) onRestrictMember;

  const MemberListWidget({
    Key? key,
    required this.members,
    required this.isAdmin,
    required this.onMemberTap,
    required this.onMakeAdmin,
    required this.onRemoveMember,
    required this.onRestrictMember,
  }) : super(key: key);

  @override
  State<MemberListWidget> createState() => _MemberListWidgetState();
}

class _MemberListWidgetState extends State<MemberListWidget> {
  List<Map<String, dynamic>> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _filteredMembers = widget.members;
  }

  void _filterMembers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = widget.members;
      } else {
        _filteredMembers = widget.members.where((member) {
          final name = (member["name"] as String).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Members',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 2.h),
                    TextField(
                        onChanged: _filterMembers,
                        decoration: InputDecoration(
                            hintText: 'Search members...',
                            prefixIcon: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: CustomIconWidget(
                                    iconName: 'search',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    size: 5.w)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest)),
                  ])),
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredMembers.length,
              separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                return Dismissible(
                    key: Key(member["id"].toString()),
                    background: Container(
                        color: AppTheme.errorLight,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 4.w),
                        child: CustomIconWidget(
                            iconName: 'delete',
                            color: Colors.white,
                            size: 6.w)),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      widget.onRemoveMember(member);
                    },
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                        leading: Stack(children: [
                          CircleAvatar(
                              radius: 6.w,
                              child: ClipOval(
                                  child: CustomImageWidget(
                                      imageUrl: member["avatar"] as String,
                                      width: 12.w,
                                      height: 12.w,
                                      fit: BoxFit.cover))),
                          if (member["isOnline"] as bool)
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                    width: 3.w,
                                    height: 3.w,
                                    decoration: BoxDecoration(
                                        color: AppTheme.successLight,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            width: 1)))),
                        ]),
                        title: Row(children: [
                          Expanded(
                              child: Text(member["name"] as String,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                          if (member["isAdmin"] as bool)
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                    color: AppTheme.lightTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text('Admin',
                                    style: TextStyle(
                                        color: AppTheme.lightTheme.primaryColor,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500))),
                        ]),
                        subtitle: Text(member["lastSeen"] as String,
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing: widget.isAdmin && !(member["isAdmin"] as bool)
                            ? PopupMenuButton<String>(
                                icon: CustomIconWidget(
                                    iconName: 'more_vert',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    size: 5.w),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'make_admin':
                                      widget.onMakeAdmin(member);
                                      break;
                                    case 'remove':
                                      widget.onRemoveMember(member);
                                      break;
                                    case 'restrict':
                                      widget.onRestrictMember(member);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                          value: 'make_admin',
                                          child: Row(children: [
                                            CustomIconWidget(
                                                iconName:
                                                    'admin_panel_settings',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                size: 5.w),
                                            SizedBox(width: 3.w),
                                            Text('Make Admin'),
                                          ])),
                                      PopupMenuItem(
                                          value: 'restrict',
                                          child: Row(children: [
                                            CustomIconWidget(
                                                iconName: 'block',
                                                color: AppTheme.warningLight,
                                                size: 5.w),
                                            SizedBox(width: 3.w),
                                            Text('Restrict'),
                                          ])),
                                      PopupMenuItem(
                                          value: 'remove',
                                          child: Row(children: [
                                            CustomIconWidget(
                                                iconName: 'person_remove',
                                                color: AppTheme.errorLight,
                                                size: 5.w),
                                            SizedBox(width: 3.w),
                                            Text('Remove'),
                                          ])),
                                    ])
                            : null,
                        onTap: () => widget.onMemberTap(member)));
              }),
        ]));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../data/mock_feedback_repository.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/constants/app_spacing.dart';

class FacultyScreen extends ConsumerStatefulWidget {
  const FacultyScreen({super.key, required this.kind});

  final String kind;

  @override
  ConsumerState<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends ConsumerState<FacultyScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    const repository = MockFeedbackRepository();
    final faculties = repository.faculties
        .where(
          (faculty) =>
              faculty.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(title: strings.facultyReviews, canPop: true),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            sliver: SliverList.list(
              children: [
                SectionHeading(
                  title: strings.chooseFaculty,
                  subtitle: strings.chooseFacultySubtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: (val) => setState(() => _query = val),
                  decoration: InputDecoration(
                    hintText: strings.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...faculties.map(
                  (faculty) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SurfaceCard(
                      onTap: () {
                        if (widget.kind == 'teachers') {
                          context.push('/teachers/${faculty.id}');
                        } else {
                          context.push('/buildings/${faculty.id}');
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              faculty.icon,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faculty.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  faculty.type,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

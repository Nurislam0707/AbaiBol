import 'package:flutter/material.dart';

import '../../features/feedback/domain/models/review_target_kind.dart';

enum FeedbackDomain { teacher, subject, building, studentLife, club }

extension FeedbackDomainX on FeedbackDomain {
  ReviewTargetKind toReviewTargetKind() {
    switch (this) {
      case FeedbackDomain.teacher:
        return ReviewTargetKind.teacher;
      case FeedbackDomain.subject:
        return ReviewTargetKind.subject;
      case FeedbackDomain.building:
        return ReviewTargetKind.building;
      case FeedbackDomain.studentLife:
        return ReviewTargetKind.studentLife;
      case FeedbackDomain.club:
        return ReviewTargetKind.club;
    }
  }
}

class FeedbackCategory {
  const FeedbackCategory({
    required this.id,
    required this.title,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.domain,
  });

  final String id;
  final String title;
  final double rating;
  final String reviews;
  final String imageUrl;
  final FeedbackDomain domain;
}

class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.category,
    required this.time,
    required this.text,
    required this.isRating,
  });

  final String id;
  final String category;
  final String time;
  final String text;
  final bool isRating;
}

class FacultyItem {
  const FacultyItem({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  final String id;
  final String name;
  final String type;
  final IconData icon;
}

class ReviewTarget {
  const ReviewTarget({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    this.tag,
    this.description,
  });

  final String id;
  final String title;
  final String subtitle;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String? tag;
  final String? description;
}

class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.rating,
    required this.type,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final double rating;
  final FeedbackDomain type;
  final IconData icon;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.meta,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String meta;
  final double rating;
  final int reviews;
  final String imageUrl;
}

class QuickCategory {
  const QuickCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.tint,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color tint;
}

class CampusStory {
  const CampusStory({
    required this.id,
    required this.userInitial,
    required this.text,
    required this.timestamp,
    required this.color,
    this.isViewed = false,
  });

  final String id;
  final String userInitial;
  final String text;
  final String timestamp;
  final Color color;
  final bool isViewed;
}

enum CampusVibe {
  productive,
  coffee,
  exam,
  zen;
}

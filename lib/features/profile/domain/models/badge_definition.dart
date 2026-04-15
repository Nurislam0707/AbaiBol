import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';

enum BadgeId {
  firstReview,
  threeReview,
  tenReview,
  twentyReview,
  helpful5,
  helpful20,
}

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.icon,
    required this.color,
  });

  final BadgeId id;
  final IconData icon;
  final Color color;

  String getLabel(AppStrings strings) => strings.badgeLabel(id);
  String getDesc(AppStrings strings) => strings.badgeDesc(id);
}

const allBadges = [
  BadgeDefinition(
    id: BadgeId.firstReview,
    icon: Icons.create_rounded,
    color: Color(0xFF2563EB),
  ),
  BadgeDefinition(
    id: BadgeId.threeReview,
    icon: Icons.rate_review_rounded,
    color: Color(0xFF059669),
  ),
  BadgeDefinition(
    id: BadgeId.tenReview,
    icon: Icons.workspace_premium_rounded,
    color: Color(0xFFF59E0B),
  ),
  BadgeDefinition(
    id: BadgeId.twentyReview,
    icon: Icons.military_tech_rounded,
    color: Color(0xFF7C3AED),
  ),
  BadgeDefinition(
    id: BadgeId.helpful5,
    icon: Icons.thumb_up_rounded,
    color: Color(0xFFEC4899),
  ),
  BadgeDefinition(
    id: BadgeId.helpful20,
    icon: Icons.favorite_rounded,
    color: Color(0xFFEF4444),
  ),
];

List<BadgeDefinition> computeEarnedBadges(int reviewCount) {
  final earned = <BadgeDefinition>[];
  for (final badge in allBadges) {
    final unlocked = switch (badge.id) {
      BadgeId.firstReview  => reviewCount >= 1,
      BadgeId.threeReview  => reviewCount >= 3,
      BadgeId.tenReview    => reviewCount >= 10,
      BadgeId.twentyReview => reviewCount >= 20,
      BadgeId.helpful5     => false, // future: track from likes
      BadgeId.helpful20    => false,
    };
    if (unlocked) earned.add(badge);
  }
  return earned;
}

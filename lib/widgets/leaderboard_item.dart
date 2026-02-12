import 'package:flutter/material.dart';
import '../config/theme.dart';

class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String username;
  final int rating;
  final int wins;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.username,
    required this.rating,
    required this.wins,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.surfaceColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTopThree
                  ? rankColor.withOpacity(0.2)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: isTopThree
                  ? Icon(
                      Icons.emoji_events,
                      color: rankColor,
                      size: 18,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              username,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$rating',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
              Text(
                '$wins wins',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

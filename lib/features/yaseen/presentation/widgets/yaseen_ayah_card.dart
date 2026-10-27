import 'package:flutter/material.dart';

import '../../data/models/yaseen_ayah.dart';

class YaseenAyahCard extends StatelessWidget {
  final YaseenAyah ayah;
  final bool showEnglishTransliteration;
  final bool showMalayalamTransliteration;
  final bool showEnglishTranslation;
  final bool showMalayalamTranslation;
  final double arabicFontSize;
  final bool isBookmarked;
  final bool isSelected;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onTap;

  const YaseenAyahCard({
    super.key,
    required this.ayah,
    this.showEnglishTransliteration = true,
    this.showMalayalamTransliteration = true,
    this.showEnglishTranslation = true,
    this.showMalayalamTranslation = true,
    this.arabicFontSize = 34,
    this.isBookmarked = false,
    this.isSelected = false,
    this.onBookmarkTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const indigoColor = Color(0xFF6366F1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: indigoColor.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: isSelected ? 3 : 0,
        color: isSelected ? indigoColor.withOpacity(0.06) : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? indigoColor.withOpacity(0.6)
                : colorScheme.outlineVariant.withOpacity(0.55),
            width: isSelected ? 1.5 : 0.7,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 22),

                Text(
                  ayah.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: arabicFontSize,
                    height: 1.9,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),

                if (showEnglishTransliteration) ...[
                  const SizedBox(height: 18),
                  _buildTextSection(
                    context,
                    label: 'English transliteration',
                    text: ayah.englishTransliteration,
                  ),
                ],

                if (showMalayalamTransliteration) ...[
                  const SizedBox(height: 14),
                  _buildTextSection(
                    context,
                    label: 'Malayalam transliteration',
                    text: ayah.malayalamTransliteration,
                  ),
                ],

                if (showEnglishTranslation) ...[
                  const SizedBox(height: 14),
                  _buildTextSection(
                    context,
                    label: 'English translation',
                    text: ayah.englishTranslation,
                  ),
                ],

                if (showMalayalamTranslation) ...[
                  const SizedBox(height: 14),
                  _buildTextSection(
                    context,
                    label: 'Malayalam translation',
                    text: ayah.malayalamTranslation,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const indigoColor = Color(0xFF6366F1);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: indigoColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${ayah.ayahNumber}',
            style: const TextStyle(
              color: indigoColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.menu_book_rounded, color: indigoColor, size: 20),
          ),
        IconButton(
          tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark Ayah',
          onPressed: onBookmarkTap,
          icon: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: isBookmarked ? indigoColor : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTextSection(
    BuildContext context, {
    required String label,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const indigoColor = Color(0xFF6366F1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: indigoColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.65,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

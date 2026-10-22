import 'package:flutter/material.dart';

import '../../data/models/yaseen_ayah.dart';
import '../../data/repositories/yaseen_repository.dart';
import '../../domain/services/yaseen_bookmark_services.dart';
import '../widgets/yaseen_ayah_card.dart';

class YaseenBookmarksScreen extends StatefulWidget {
const YaseenBookmarksScreen({super.key});

@override
State<YaseenBookmarksScreen> createState() =>
_YaseenBookmarksScreenState();
}

class _YaseenBookmarksScreenState
extends State<YaseenBookmarksScreen> {
final YaseenRepository _repository = YaseenRepository();
final YaseenBookmarkService _bookmarkService =
YaseenBookmarkService();

List<YaseenAyah> _bookmarkedAyahs = [];
bool _isLoading = true;
String? _errorMessage;

@override
void initState() {
super.initState();
_loadBookmarks();
}

Future<void> _loadBookmarks() async {
try {
final bookmarks = await _bookmarkService.getBookmarks();
final allAyahs = await _repository.getAyahs();

if (!mounted) return;

setState(() {
_bookmarkedAyahs = allAyahs
    .where((ayah) => bookmarks.contains(ayah.ayahNumber))
    .toList();
_isLoading = false;
});
} catch (error) {
if (!mounted) return;

setState(() {
_errorMessage = 'Unable to load bookmarks.\n$error';
_isLoading = false;
});
}
}

Future<void> _removeBookmark(int ayahNumber) async {
try {
await _bookmarkService.removeBookmark(ayahNumber);

if (!mounted) return;

setState(() {
_bookmarkedAyahs.removeWhere(
(ayah) => ayah.ayahNumber == ayahNumber,
);
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Ayah $ayahNumber removed from bookmarks'),
action: SnackBarAction(
label: 'Undo',
onPressed: () async {
await _bookmarkService.addBookmark(ayahNumber);
if (!mounted) return;
await _loadBookmarks();
},
),
),
);
} catch (_) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Unable to remove bookmark.'),
),
);
}
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Scaffold(
appBar: AppBar(
title: const Text('Yaseen Bookmarks'),
),
body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : _errorMessage != null
? _buildErrorState()
    : _bookmarkedAyahs.isEmpty
? _buildEmptyState(context)
    : ListView.builder(
padding: const EdgeInsets.only(
top: 8,
bottom: 24,
),
itemCount: _bookmarkedAyahs.length,
itemBuilder: (context, index) {
final ayah = _bookmarkedAyahs[index];

return Dismissible(
key: ValueKey(ayah.ayahNumber),
direction: DismissDirection.endToStart,
background: Container(
margin: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 8,
),
padding: const EdgeInsets.symmetric(
horizontal: 24,
),
alignment: Alignment.centerRight,
decoration: BoxDecoration(
color: colorScheme.errorContainer,
borderRadius: BorderRadius.circular(20),
),
child: Icon(
Icons.delete_outline_rounded,
color: colorScheme.onErrorContainer,
),
),
onDismissed: (_) {
_removeBookmark(ayah.ayahNumber);
},
child: YaseenAyahCard(
ayah: ayah,
isBookmarked: true,
onBookmarkTap: () {
_removeBookmark(ayah.ayahNumber);
},
),
);
},
),
);
}

Widget _buildEmptyState(BuildContext context) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Center(
child: Padding(
padding: const EdgeInsets.all(32),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.bookmarks_outlined,
size: 64,
color: colorScheme.primary,
),
const SizedBox(height: 20),
Text(
'No bookmarks yet',
style: theme.textTheme.titleLarge,
),
const SizedBox(height: 8),
Text(
'Bookmark an Ayah while reading Surah Yaseen, '
'and it will appear here.',
textAlign: TextAlign.center,
style: theme.textTheme.bodyMedium?.copyWith(
color: colorScheme.onSurfaceVariant,
),
),
const SizedBox(height: 24),
FilledButton.icon(
onPressed: () => Navigator.of(context).pop(),
icon: const Icon(Icons.menu_book_rounded),
label: const Text('Back to reading'),
),
],
),
),
);
}

Widget _buildErrorState() {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.error_outline_rounded,
size: 48,
),
const SizedBox(height: 16),
Text(
_errorMessage!,
textAlign: TextAlign.center,
),
const SizedBox(height: 16),
FilledButton.icon(
onPressed: () {
setState(() {
_isLoading = true;
_errorMessage = null;
});
_loadBookmarks();
},
icon: const Icon(Icons.refresh_rounded),
label: const Text('Try again'),
),
],
),
),
);
}
}
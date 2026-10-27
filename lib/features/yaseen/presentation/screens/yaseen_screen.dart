import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:rushd/features/yaseen/presentation/screens/yaseen_bookmarks_screen.dart';

import '../../data/models/yaseen_ayah.dart';
import '../../data/repositories/yaseen_repository.dart';
import '../../domain/services/yaseen_bookmark_services.dart';
import '../../domain/services/yaseen_progress_service.dart';
import '../widgets/yaseen_ayah_card.dart';

class YaseenScreen extends StatefulWidget {
  const YaseenScreen({super.key});

  @override
  State<YaseenScreen> createState() => _YaseenScreenState();
}

class _YaseenScreenState extends State<YaseenScreen> {
  final YaseenRepository _repository = YaseenRepository();
  final YaseenBookmarkService _bookmarkService = YaseenBookmarkService();
  final YaseenProgressService _progressService = YaseenProgressService();

  final ItemScrollController _itemScrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<YaseenAyah> _ayahs = [];
  Set<int> _bookmarks = {};

  bool _isLoading = true;
  String? _errorMessage;

  bool _showEnglishTransliteration = true;
  bool _showMalayalamTransliteration = true;
  bool _showEnglishTranslation = true;
  bool _showMalayalamTranslation = true;

  double _arabicFontSize = 34;
  int _selectedAyah = 1;

  @override
  void initState() {
    super.initState();
    _loadReader();
    _itemPositionsListener.itemPositions.addListener(
      _updateSelectedAyahFromScroll,
    );
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(
      _updateSelectedAyahFromScroll,
    );
    super.dispose();
  }

  Future<void> _loadReader() async {
    try {
      final results = await Future.wait([
        _repository.getAyahs(),
        _bookmarkService.getBookmarks(),
        _progressService.getLastReadAyah(),
      ]);

      if (!mounted) return;

      setState(() {
        _ayahs = results[0] as List<YaseenAyah>;
        _bookmarks = (results[1] as List<int>).toSet();
        _selectedAyah = results[2] as int;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_itemScrollController.isAttached) return;

        // Index 0 is the Surah header card, so ayah 1 is at index 1, ayah n is at index n
        _itemScrollController.jumpTo(index: _selectedAyah, alignment: 0.0);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to load Surah Yaseen.\n$error';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProgress(int ayahNumber) async {
    _selectedAyah = ayahNumber;
    await _progressService.saveProgress(ayahNumber);
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final wasBookmarked = _bookmarks.contains(ayahNumber);

    setState(() {
      if (wasBookmarked) {
        _bookmarks.remove(ayahNumber);
      } else {
        _bookmarks.add(ayahNumber);
      }
    });

    try {
      if (wasBookmarked) {
        await _bookmarkService.removeBookmark(ayahNumber);
      } else {
        await _bookmarkService.addBookmark(ayahNumber);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        if (wasBookmarked) {
          _bookmarks.add(ayahNumber);
        } else {
          _bookmarks.remove(ayahNumber);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update bookmark.')),
      );
    }
  }

  Future<void> _openBookmarks() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const YaseenBookmarksScreen()),
    );

    if (!mounted) return;

    final bookmarks = await _bookmarkService.getBookmarks();

    setState(() {
      _bookmarks = bookmarks.toSet();
    });
  }

  void _showReadingSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded),
                      const SizedBox(width: 12),
                      Text(
                        'Reading Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildToggle(
                    'English transliteration',
                    _showEnglishTransliteration,
                    (value) {
                      setModalState(() => _showEnglishTransliteration = value);
                      setState(() {});
                    },
                  ),
                  _buildToggle(
                    'Malayalam transliteration',
                    _showMalayalamTransliteration,
                    (value) {
                      setModalState(
                        () => _showMalayalamTransliteration = value,
                      );
                      setState(() {});
                    },
                  ),
                  _buildToggle('English translation', _showEnglishTranslation, (
                    value,
                  ) {
                    setModalState(() => _showEnglishTranslation = value);
                    setState(() {});
                  }),
                  _buildToggle(
                    'Malayalam translation',
                    _showMalayalamTranslation,
                    (value) {
                      setModalState(() => _showMalayalamTranslation = value);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.text_fields_rounded),
                      const SizedBox(width: 12),
                      const Text('Arabic font size'),
                      const Spacer(),
                      Text(_arabicFontSize.round().toString()),
                    ],
                  ),
                  Slider(
                    min: 24,
                    max: 48,
                    divisions: 12,
                    value: _arabicFontSize,
                    label: _arabicFontSize.round().toString(),
                    onChanged: (value) {
                      setModalState(() => _arabicFontSize = value);
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surah Yaseen'),
        actions: [
          IconButton(
            tooltip: 'Reading settings',
            onPressed: _showReadingSettingsBottomSheet,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            onPressed: _openBookmarks,
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _buildUnifiedScrollableList(),
      bottomNavigationBar: !_isLoading && _errorMessage == null
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reading Ayah $_selectedAyah of 83',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (!_itemScrollController.isAttached) return;

                        _itemScrollController.scrollTo(
                          index: _selectedAyah,
                          alignment: 0.0,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Resume'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSurahHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF443BED), Color(0xFF6169BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'يس',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontSize: 42,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Yā-Sīn',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '83 Ayahs  •  Makki Surah',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedScrollableList() {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      initialScrollIndex: _selectedAyah,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _ayahs.length + 1, // +1 for the Surah header at index 0
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSurahHeader(context);
        }

        final ayah = _ayahs[index - 1];

        return YaseenAyahCard(
          key: ValueKey(ayah.ayahNumber),
          ayah: ayah,
          showEnglishTransliteration: _showEnglishTransliteration,
          showMalayalamTransliteration: _showMalayalamTransliteration,
          showEnglishTranslation: _showEnglishTranslation,
          showMalayalamTranslation: _showMalayalamTranslation,
          arabicFontSize: _arabicFontSize,
          isBookmarked: _bookmarks.contains(ayah.ayahNumber),
          isSelected: _selectedAyah == ayah.ayahNumber,
          onBookmarkTap: () => _toggleBookmark(ayah.ayahNumber),
          onTap: () => _saveProgress(ayah.ayahNumber),
        );
      },
    );
  }

  void _updateSelectedAyahFromScroll() {
    final positions = _itemPositionsListener.itemPositions.value;

    if (positions.isEmpty || _ayahs.isEmpty) return;

    final visiblePositions =
        positions
            .where(
              (position) =>
                  position.itemTrailingEdge > 0 &&
                  position.itemLeadingEdge < 1 &&
                  position.index > 0, // Ignore index 0 (Surah header card)
            )
            .toList()
          ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));

    if (visiblePositions.isEmpty) return;

    final ayahNumber = visiblePositions.first.index;

    if (ayahNumber != _selectedAyah &&
        ayahNumber >= 1 &&
        ayahNumber <= _ayahs.length) {
      setState(() => _selectedAyah = ayahNumber);
      _progressService.saveProgress(ayahNumber);
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadReader();
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

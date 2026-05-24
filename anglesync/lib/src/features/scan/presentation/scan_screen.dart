import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/service/exercise_service.dart';

import '../domain/exercise_item.dart';
import '../domain/exercise_detail.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<ExerciseItem> _allExercises = [];
  List<ExerciseItem> _filtered = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises =
          await ExerciseService.fetchExercises();

      setState(() {
        _allExercises = exercises;
        _filtered = exercises;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading exercises: $e');

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = _allExercises.where((e) {
        return e.title
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            e.category
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildAppBar(context),
            ),

            SliverToBoxAdapter(
              child: _buildHero(),
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmpty(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  32,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index.isOdd) {
                        return const SizedBox(height: 20);
                      }

                      return _ExerciseCard(
                        item: _filtered[index ~/ 2],
                      );
                    },
                    childCount:
                        _filtered.length * 2 - 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              CupertinoIcons.xmark,
              size: 22,
              color: AppTheme.textDark,
            ),
          ),

          const SizedBox(width: 14),

          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.sparkles,
                  size: 14,
                  color: AppTheme.green,
                ),

                SizedBox(width: 6),

                Text(
                  'AI posture coach',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Pick an exercise\nto scan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Tap any card to upload your video and get instant\njoint-by-joint feedback.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.04,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),

                Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: Colors.grey.shade400,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller:
                        _searchController,
                    onChanged: _onSearch,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search exercises...',
                      hintStyle: TextStyle(
                        color:
                            Colors.grey.shade400,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textDark,
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

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          'No exercises found',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseItem item;

  const _ExerciseCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.upload,
          arguments: ExerciseDetail(
            title: item.title,
            category: item.category,
            description: item.videoUrl,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      item.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                        return Container(
                          decoration:
                              BoxDecoration(
                            gradient:
                                LinearGradient(
                              begin:
                                  Alignment
                                      .topCenter,
                              end:
                                  Alignment
                                      .bottomCenter,
                              colors: [
                                Colors
                                    .grey
                                    .shade300,
                                Colors
                                    .grey
                                    .shade200,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppTheme.textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.play_fill,
                        color: AppTheme.green,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
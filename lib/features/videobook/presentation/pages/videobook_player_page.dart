import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_variant_entity.dart';

class VideobookPlayerPage extends StatefulWidget {
  final String bookTitle;
  final List<MediaPartEntity> parts;
  final int startPartIndex;

  const VideobookPlayerPage({
    super.key,
    required this.bookTitle,
    required this.parts,
    this.startPartIndex = 0,
  });

  @override
  State<VideobookPlayerPage> createState() => _VideobookPlayerPageState();
}

class _VideobookPlayerPageState extends State<VideobookPlayerPage> {
  late int _currentPartIndex;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentPartIndex = widget.startPartIndex;
    _initPlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    // Dispose previous controllers
    _chewieController?.dispose();
    await _videoController?.dispose();

    final part = widget.parts[_currentPartIndex];
    final url = part.videoUrl;

    if (url == null || url.isEmpty) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      return;
    }

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: AppColors.primary.withValues(alpha: 0.3),
          backgroundColor: Colors.grey.shade300,
        ),
        additionalOptions: (context) => [
          OptionItem(
            onTap: (_) => _showChapterList(context),
            iconData: Icons.list,
            title: 'Chapters',
          ),
        ],
      );

      // Auto-play next when video ends
      _videoController!.addListener(_onVideoProgress);

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  void _onVideoProgress() {
    if (_videoController == null) return;
    if (_videoController!.value.position >= _videoController!.value.duration &&
        _videoController!.value.duration > Duration.zero &&
        !_videoController!.value.isPlaying) {
      // Auto-play next chapter
      if (_currentPartIndex < widget.parts.length - 1) {
        _playPart(_currentPartIndex + 1);
      }
    }
  }

  void _playPart(int index) {
    if (index < 0 || index >= widget.parts.length) return;
    _videoController?.removeListener(_onVideoProgress);
    setState(() => _currentPartIndex = index);
    _initPlayer();
  }

  void _showChapterList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ChapterListSheet(
        parts: widget.parts,
        currentIndex: _currentPartIndex,
        onChapterTap: (index) {
          Navigator.pop(context);
          _playPart(index);
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentPart = widget.parts[_currentPartIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.bookTitle,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Chapters',
            onPressed: () => _showChapterList(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video player — takes available space
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              const Text(
                                'Failed to load video',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _initPlayer,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Chewie(controller: _chewieController!),
            ),

            // Chapter info + navigation
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current chapter title
                  Text(
                    'Chapter ${currentPart.partNumber}: ${currentPart.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (currentPart.duration > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(currentPart.duration),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Previous / Next buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentPartIndex > 0
                              ? () => _playPart(_currentPartIndex - 1)
                              : null,
                          icon: const Icon(Icons.skip_previous, size: 18),
                          label: const Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.05),
                            disabledForegroundColor: Colors.white24,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentPartIndex < widget.parts.length - 1
                              ? () => _playPart(_currentPartIndex + 1)
                              : null,
                          icon: const Icon(Icons.skip_next, size: 18),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.05),
                            disabledForegroundColor: Colors.white24,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chapter list
            Expanded(
              child: Container(
                color: const Color(0xFF121212),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.parts.length,
                  itemBuilder: (context, index) {
                    final part = widget.parts[index];
                    final isPlaying = index == _currentPartIndex;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            isPlaying ? AppColors.primary : Colors.white12,
                        child: isPlaying
                            ? const Icon(Icons.play_arrow,
                                color: Colors.white, size: 16)
                            : Text(
                                '${part.partNumber}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                      ),
                      title: Text(
                        part.title,
                        style: TextStyle(
                          color: isPlaying ? AppColors.primary : Colors.white,
                          fontWeight:
                              isPlaying ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        _formatDuration(part.duration),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      onTap: () => _playPart(index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterListSheet extends StatelessWidget {
  final List<MediaPartEntity> parts;
  final int currentIndex;
  final void Function(int index) onChapterTap;

  const _ChapterListSheet({
    required this.parts,
    required this.currentIndex,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.video_library, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Chapters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: parts.length,
              itemBuilder: (context, index) {
                final part = parts[index];
                final isPlaying = index == currentIndex;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: isPlaying
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      '${part.partNumber}',
                      style: TextStyle(
                        color: isPlaying ? Colors.white : AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    part.title,
                    style: TextStyle(
                      fontWeight:
                          isPlaying ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isPlaying ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isPlaying
                      ? const Icon(Icons.equalizer, color: AppColors.primary)
                      : null,
                  onTap: () => onChapterTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

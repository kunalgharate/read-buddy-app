import '../../domain/entities/audiobook.dart';

final List<AudioBook> dummyAudioBooks = [
  // Wings of Fire — English (8 parts)
  AudioBook(
    id: 'ab-1',
    title: 'Wings of Fire (English)',
    author: 'APJ Abdul Kalam',
    coverUrl: '',
    totalDuration: const Duration(hours: 3, minutes: 20),
    tracks: const [
      AudioBookTrack(
        id: 'ab-1-t-1',
        title: 'Part 1',
        trackNumber: 1,
        url: 'https://files.catbox.moe/k0zwg6.mp3',
        duration: Duration(minutes: 25),
      ),
      AudioBookTrack(
        id: 'ab-1-t-2',
        title: 'Part 2',
        trackNumber: 2,
        url: 'https://files.catbox.moe/580nqm.mp3',
        duration: Duration(minutes: 25),
      ),
      AudioBookTrack(
        id: 'ab-1-t-3',
        title: 'Part 3',
        trackNumber: 3,
        url: 'https://files.catbox.moe/eids17.mp3',
        duration: Duration(minutes: 25),
      ),
      AudioBookTrack(
        id: 'ab-1-t-4',
        title: 'Part 4',
        trackNumber: 4,
        url: 'https://files.catbox.moe/e5jlje.mp3',
        duration: Duration(minutes: 25),
      ),
      AudioBookTrack(
        id: 'ab-1-t-5',
        title: 'Part 5',
        trackNumber: 5,
        url: 'https://files.catbox.moe/st1qvf.mp3',
        duration: Duration(minutes: 25),
      ),
      AudioBookTrack(
        id: 'ab-1-t-6',
        title: 'Part 6',
        trackNumber: 6,
        url: 'https://files.catbox.moe/st1qvf.mp3',
        duration: Duration(minutes: 25),
      ),
      AudioBookTrack(
        id: 'ab-1-t-7',
        title: 'Part 7',
        trackNumber: 7,
        url: 'https://files.catbox.moe/st1qvf.mp3',
        duration: Duration(minutes: 25),
      ),
      AudioBookTrack(
        id: 'ab-1-t-8',
        title: 'Part 8',
        trackNumber: 8,
        url: 'https://files.catbox.moe/uy35ib.mp3',
        duration: Duration(minutes: 25),
      ),
    ],
  ),
  // Wings of Fire — Hindi (single file)
  AudioBook(
    id: 'ab-2',
    title: 'Wings of Fire (Hindi)',
    author: 'APJ Abdul Kalam',
    coverUrl: '',
    totalDuration: const Duration(hours: 2, minutes: 30),
    tracks: const [
      AudioBookTrack(
        id: 'ab-2-t-1',
        title: 'Wings of Fire - Full Audiobook',
        trackNumber: 1,
        url: 'https://files.catbox.moe/axio5j.mp3',
        duration: Duration(hours: 2, minutes: 30),
      ),
    ],
  ),
];

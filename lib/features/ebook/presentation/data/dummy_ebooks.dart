import '../../domain/entities/ebook.dart';

const _samplePdfUrl = 'https://files.catbox.moe/6sku0l.pdf';

const _sampleEpubUrl = 'https://files.catbox.moe/d8ejcq.epub';

const _langEn = EBookLanguage(code: 'en', name: 'English');
const _langHi = EBookLanguage(code: 'hi', name: 'Hindi');
const _langMr = EBookLanguage(code: 'mr', name: 'Marathi');

final List<EBook> dummyEBooks = [
  const EBook(
    id: 'eb-1',
    bookId: 'b-1',
    title: 'Wings of Fire',
    coverUrl: '',
    author: 'APJ Abdul Kalam',
    type: EBookType.single,
    availableLanguages: [_langEn, _langHi, _langMr],
    chapters: [
      EBookChapter(
        id: 'eb-1-ch-1',
        title: 'Wings of Fire',
        chapterNumber: 1,
        urlsByLanguage: {
          'en': _samplePdfUrl,
          'hi': _samplePdfUrl,
          'mr': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
    ],
  ),
  const EBook(
    id: 'eb-2',
    bookId: 'b-2',
    title: 'The Story of My Experiments with Truth',
    coverUrl: '',
    author: 'Mahatma Gandhi',
    type: EBookType.multiChapter,
    availableLanguages: [_langEn, _langHi, _langMr],
    chapters: [
      EBookChapter(
        id: 'eb-2-ch-1',
        title: 'Chapter 1: Birth and Parentage',
        chapterNumber: 1,
        urlsByLanguage: {
          'en': _samplePdfUrl,
          'hi': _samplePdfUrl,
          'mr': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
      EBookChapter(
        id: 'eb-2-ch-2',
        title: 'Chapter 2: Childhood',
        chapterNumber: 2,
        urlsByLanguage: {
          'en': _samplePdfUrl,
          'hi': _samplePdfUrl,
          'mr': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
      EBookChapter(
        id: 'eb-2-ch-3',
        title: 'Chapter 3: Child Marriage',
        chapterNumber: 3,
        urlsByLanguage: {
          'en': _samplePdfUrl,
          'hi': _samplePdfUrl,
          'mr': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
      EBookChapter(
        id: 'eb-2-ch-4',
        title: 'Chapter 4: Playing the Husband',
        chapterNumber: 4,
        urlsByLanguage: {
          'en': _samplePdfUrl,
          'hi': _samplePdfUrl,
          'mr': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
      EBookChapter(
        id: 'eb-2-ch-5',
        title: 'Chapter 5: At the High School',
        chapterNumber: 5,
        urlsByLanguage: {
          'en': _samplePdfUrl,
          'hi': _samplePdfUrl,
          'mr': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
    ],
  ),
  const EBook(
    id: 'eb-3',
    bookId: 'b-3',
    title: 'Shyamchi Aai',
    coverUrl: '',
    author: 'Sane Guruji',
    type: EBookType.single,
    availableLanguages: [_langMr],
    chapters: [
      EBookChapter(
        id: 'eb-3-ch-1',
        title: 'Shyamchi Aai',
        chapterNumber: 1,
        urlsByLanguage: {
          'mr': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
    ],
  ),
  const EBook(
    id: 'eb-4',
    bookId: 'b-4',
    title: 'Godan',
    coverUrl: '',
    author: 'Premchand',
    type: EBookType.multiChapter,
    availableLanguages: [_langHi, _langEn],
    chapters: [
      EBookChapter(
        id: 'eb-4-ch-1',
        title: 'Chapter 1: The Village',
        chapterNumber: 1,
        urlsByLanguage: {
          'hi': _samplePdfUrl,
          'en': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
      EBookChapter(
        id: 'eb-4-ch-2',
        title: 'Chapter 2: The Landlord',
        chapterNumber: 2,
        urlsByLanguage: {
          'hi': _samplePdfUrl,
          'en': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
      EBookChapter(
        id: 'eb-4-ch-3',
        title: 'Chapter 3: The Struggle',
        chapterNumber: 3,
        urlsByLanguage: {
          'hi': _samplePdfUrl,
          'en': _samplePdfUrl,
        },
        format: EBookFormat.pdf,
      ),
    ],
  ),
  const EBook(
    id: 'eb-5',
    bookId: 'b-5',
    title: "Alice's Adventures in Wonderland",
    coverUrl: '',
    author: 'Lewis Carroll',
    type: EBookType.single,
    availableLanguages: [_langEn],
    chapters: [
      EBookChapter(
        id: 'eb-5-ch-1',
        title: "Alice's Adventures in Wonderland",
        chapterNumber: 1,
        urlsByLanguage: {
          'en': _sampleEpubUrl,
        },
        format: EBookFormat.epub,
      ),
    ],
  ),
];

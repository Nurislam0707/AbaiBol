import 'package:flutter/material.dart';

import '../../../shared/models/feedback_models.dart';
import '../domain/models/review_catalog_item.dart';
import '../domain/models/review_catalog_summary.dart';
import '../domain/models/review_target_kind.dart';

class MockFeedbackRepository {
  const MockFeedbackRepository();

  List<CampusStory> get stories => const [
    CampusStory(
      id: 's1',
      userInitial: 'A',
      text: 'Кітапханада аздап салқын екен, курткамен келіңіздер 🧥',
      timestamp: '5 мин бұрын',
      color: Color(0xFF3B82F6),
    ),
    CampusStory(
      id: 's2',
      userInitial: 'M',
      text: 'ISE-де кезек өте көп, 15 минут күттім 😫',
      timestamp: '10 мин бұрын',
      color: Color(0xFFF59E0B),
    ),
    CampusStory(
      id: 's3',
      userInitial: 'B',
      text: 'Математика емтиханы аяқталды, еркіндік! 🥳',
      timestamp: '25 мин бұрын',
      color: Color(0xFF10B981),
    ),
    CampusStory(
      id: 's4',
      userInitial: 'D',
      text: 'Коворкингте орын жоқ, босқа келмеңіздер.',
      timestamp: '40 мин бұрын',
      color: Color(0xFFEF4444),
    ),
    CampusStory(
      id: 's5',
      userInitial: 'Z',
      text: 'Foundations сабағы өте қызықты өтті!',
      timestamp: '1 сағ бұрын',
      color: Color(0xFF8B5CF6),
    ),
  ];

  ReviewCatalogSummary get featuredSummary => const ReviewCatalogSummary(
    item: ReviewCatalogItem(
      id: 'teacher-1',
      name: 'Ахметова Гүлнар Саматқызы',
      targetKind: ReviewTargetKind.teacher,
      department: 'Қазақ әдебиеті кафедрасы',
      imageUrl: 'https://picsum.photos/seed/t1/400/400',
    ),
    averageRating: 4.9,
    totalReviews: 148,
  );

  Map<String, double> get trendingKeywords => const {
    'Регистрация': 1.0,
    'Кофе': 0.8,
    'Midterms': 0.9,
    'Спорт зал': 0.6,
    'Кітапхана': 0.7,
    'FOUNDATIONS': 0.5,
    'ISE': 0.95,
  };

  (ReviewCatalogSummary, String) get dailyMystery => (
    ReviewCatalogSummary(
      item: ReviewCatalogItem(
        id: 'subject-3',
        name: 'Педагогика',
        targetKind: ReviewTargetKind.subject,
        department: 'Білім беру',
        imageUrl: 'https://picsum.photos/seed/ped/400/400',
      ),
      averageRating: 4.7,
      totalReviews: 210,
    ),
    'Бұл пән студенттердің шығармашылық әлеуетін ашудағы "жасырын қазына" болып саналады. Мұғалімнің қолдауы өте жоғары!',
  );

  List<FeedbackCategory> get categories => const [
    FeedbackCategory(
      id: 'teachers',
      title: 'Мұғалімдер',
      rating: 4.8,
      reviews: '1.2k',
      imageUrl: 'assets/images/teachers.png',
      domain: FeedbackDomain.teacher,
    ),
    FeedbackCategory(
      id: 'subjects',
      title: 'Пәндер',
      rating: 4.5,
      reviews: '850',
      imageUrl: 'assets/images/subjects.png',
      domain: FeedbackDomain.subject,
    ),
    FeedbackCategory(
      id: 'buildings',
      title: 'Корпустар',
      rating: 4.2,
      reviews: '430',
      imageUrl: 'assets/images/buildings.png',
      domain: FeedbackDomain.building,
    ),
    FeedbackCategory(
      id: 'student-life',
      title: 'Студенттік өмір',
      rating: 4.9,
      reviews: '1.5k',
      imageUrl: 'assets/images/student_life.png',
      domain: FeedbackDomain.studentLife,
    ),
  ];

  List<ActivityFeedItem> get activityFeed => const [
    ActivityFeedItem(
      id: 'a1',
      category: 'Студенттік өмір',
      time: 'жаңа ғана',
      text: 'Кешегі концерт өте керемет болды. Ұйымдастырушыларға рақмет.',
      isRating: false,
    ),
    ActivityFeedItem(
      id: 'a2',
      category: 'Пәндер',
      time: '2 мин бұрын',
      text: 'Педагогика пәні өте қызықты өтті, практикалық жұмыстар көп болды.',
      isRating: false,
    ),
    ActivityFeedItem(
      id: 'a3',
      category: 'Мұғалімдер',
      time: '15 мин бұрын',
      text: 'Жаңа рейтинг жаңартылды. Үздік оқытушылар анықталды.',
      isRating: true,
    ),
  ];

  List<FacultyItem> get faculties => const [
    FacultyItem(
      id: 'pedagogy',
      name: 'Педагогика және психология',
      type: 'Институт',
      icon: Icons.psychology_rounded,
    ),
    FacultyItem(
      id: 'science',
      name: 'Жаратылыстану және география',
      type: 'Институт',
      icon: Icons.public_rounded,
    ),
    FacultyItem(
      id: 'math',
      name: 'Математика, физика және информатика',
      type: 'Институт',
      icon: Icons.functions_rounded,
    ),
    FacultyItem(
      id: 'philology',
      name: 'Филология',
      type: 'Институт',
      icon: Icons.translate_rounded,
    ),
    FacultyItem(
      id: 'art',
      name: 'Өнер, мәдениет және спорт',
      type: 'Институт',
      icon: Icons.palette_outlined,
    ),
    FacultyItem(
      id: 'history',
      name: 'Тарих және құқық',
      type: 'Институт',
      icon: Icons.balance_rounded,
    ),
  ];

  List<ReviewTarget> get teachers => const [
    ReviewTarget(
      id: 'teacher-1',
      title: 'Ахметова Гүлнар Саматқызы',
      subtitle: 'Қазақ әдебиеті кафедрасы',
      rating: 9.2,
      reviews: 148,
      imageUrl: 'https://picsum.photos/seed/t1/200/200',
      description: 'Түсіндіруі жүйелі, студентке жақын, кері байланысы нақты.',
    ),
    ReviewTarget(
      id: 'teacher-2',
      title: 'Оспанов Бауыржан Нұрланұлы',
      subtitle: 'Орыс тілі кафедрасы',
      rating: 8.7,
      reviews: 92,
      imageUrl: 'https://picsum.photos/seed/t2/200/200',
      description: 'Сабақты құрылымды өткізеді, талаптары анық.',
    ),
    ReviewTarget(
      id: 'teacher-3',
      title: 'Сүлейменова Әлия Мұратқызы',
      subtitle: 'Шетел тілдері кафедрасы',
      rating: 7.9,
      reviews: 56,
      imageUrl: 'https://picsum.photos/seed/t3/200/200',
      description: 'Практикаға бағытталған, интерактивті формат қолданады.',
    ),
  ];

  List<ReviewTarget> get subjects => const [
    ReviewTarget(
      id: 'subject-1',
      title: 'Қазақ тілі',
      subtitle: 'Филология институты',
      rating: 4.9,
      reviews: 320,
      imageUrl: 'https://picsum.photos/seed/kz/200/200',
      tag: 'Гуманитарлық',
    ),
    ReviewTarget(
      id: 'subject-2',
      title: 'Математикалық талдау',
      subtitle: 'Математика институты',
      rating: 4.2,
      reviews: 150,
      imageUrl: 'https://picsum.photos/seed/math/200/200',
      tag: 'Жаратылыстану',
    ),
    ReviewTarget(
      id: 'subject-3',
      title: 'Педагогика',
      subtitle: 'Білім беру',
      rating: 4.7,
      reviews: 210,
      imageUrl: 'https://picsum.photos/seed/ped/200/200',
      tag: 'Білім беру',
    ),
    ReviewTarget(
      id: 'subject-4',
      title: 'Психология',
      subtitle: 'Білім беру',
      rating: 4.8,
      reviews: 180,
      imageUrl: 'https://picsum.photos/seed/psy/200/200',
      tag: 'Білім беру',
    ),
  ];

  List<QuickCategory> get buildingCategories => const [
    QuickCategory(
      id: 'canteen',
      title: 'Асхана',
      icon: Icons.local_cafe_outlined,
      tint: Color(0xFFF97316),
    ),
    QuickCategory(
      id: 'toilet',
      title: 'Туалет',
      icon: Icons.delete_outline_rounded,
      tint: Color(0xFF2563EB),
    ),
    QuickCategory(
      id: 'library',
      title: 'Кітапхана',
      icon: Icons.menu_book_rounded,
      tint: Color(0xFF059669),
    ),
    QuickCategory(
      id: 'coworking',
      title: 'Коворкинг',
      icon: Icons.desktop_windows_outlined,
      tint: Color(0xFF7C3AED),
    ),
    QuickCategory(
      id: 'gym',
      title: 'Спорт зал',
      icon: Icons.fitness_center_rounded,
      tint: Color(0xFFE11D48),
    ),
  ];

  List<ReviewTarget> get studentLifeCategories => const [
    ReviewTarget(
      id: 'events',
      title: 'Іс-шаралар',
      subtitle: 'Орташа рейтинг 4.8',
      rating: 4.8,
      reviews: 1200,
      imageUrl: 'https://picsum.photos/seed/events/200/200',
    ),
    ReviewTarget(
      id: 'clubs',
      title: 'Клубтар',
      subtitle: 'Орташа рейтинг 4.5',
      rating: 4.5,
      reviews: 850,
      imageUrl: 'https://picsum.photos/seed/clubs/200/200',
    ),
    ReviewTarget(
      id: 'dorm',
      title: 'Жатақхана',
      subtitle: 'Орташа рейтинг 4.2',
      rating: 4.2,
      reviews: 600,
      imageUrl: 'https://picsum.photos/seed/dorm/200/200',
    ),
    ReviewTarget(
      id: 'atmos',
      title: 'Атмосфера',
      subtitle: 'Орташа рейтинг 4.9',
      rating: 4.9,
      reviews: 1500,
      imageUrl: 'https://picsum.photos/seed/atmos/200/200',
    ),
  ];

  List<ReviewTarget> get clubs => const [
    ReviewTarget(
      id: 'club-1',
      title: 'Дебат клубы',
      subtitle: 'Ғылым',
      rating: 4.8,
      reviews: 124,
      imageUrl: 'https://picsum.photos/seed/debate/200/200',
    ),
    ReviewTarget(
      id: 'club-2',
      title: 'Би үйірмесі',
      subtitle: 'Өнер',
      rating: 4.9,
      reviews: 86,
      imageUrl: 'https://picsum.photos/seed/dance/200/200',
    ),
    ReviewTarget(
      id: 'club-3',
      title: 'Волонтерлер ұйымы',
      subtitle: 'Әлеуметтік',
      rating: 5.0,
      reviews: 210,
      imageUrl: 'https://picsum.photos/seed/vol/200/200',
    ),
    ReviewTarget(
      id: 'club-4',
      title: 'Спорт секциялары',
      subtitle: 'Спорт',
      rating: 4.7,
      reviews: 156,
      imageUrl: 'https://picsum.photos/seed/sport/200/200',
    ),
  ];

  List<SearchResultItem> get searchResults => const [
    SearchResultItem(
      id: 's1',
      title: 'Ахметов Қанат Сабырұлы',
      subtitle: 'Оқытушы • Педагогика кафедрасы',
      description: 'Педагогика ғылымдарының докторы, 15 жылдық тәжірибесі бар.',
      rating: 4.9,
      type: FeedbackDomain.teacher,
      icon: Icons.school_rounded,
    ),
    SearchResultItem(
      id: 's2',
      title: 'Қазақ әдебиетінің тарихы',
      subtitle: 'Пән • Филология институты',
      description: 'Қазақ әдебиетінің даму кезеңдерін қамтитын пән.',
      rating: 4.7,
      type: FeedbackDomain.subject,
      icon: Icons.menu_book_rounded,
    ),
    SearchResultItem(
      id: 's3',
      title: 'Бас корпус №1',
      subtitle: 'Корпус • Достық даңғылы, 13',
      description: 'Университет әкімшілігі мен негізгі институттар орналасқан.',
      rating: 4.5,
      type: FeedbackDomain.building,
      icon: Icons.apartment_rounded,
    ),
  ];

  Map<FeedbackDomain, List<LeaderboardEntry>> get leaderboards => const {
    FeedbackDomain.teacher: [
      LeaderboardEntry(
        id: 'lt1',
        name: 'Ахметов Бауыржан',
        meta: 'Физика-математика факультеті',
        rating: 4.9,
        reviews: 128,
        imageUrl: 'https://picsum.photos/seed/b1/200/200',
      ),
      LeaderboardEntry(
        id: 'lt2',
        name: 'Сапарова Гүлнұр',
        meta: 'Филология факультеті',
        rating: 4.8,
        reviews: 86,
        imageUrl: 'https://picsum.photos/seed/b2/200/200',
      ),
      LeaderboardEntry(
        id: 'lt3',
        name: 'Омаров Дәурен',
        meta: 'Тарих және құқық факультеті',
        rating: 4.7,
        reviews: 74,
        imageUrl: 'https://picsum.photos/seed/b3/200/200',
      ),
    ],
    FeedbackDomain.subject: [
      LeaderboardEntry(
        id: 'ls1',
        name: 'Қазақ тілі',
        meta: 'Филология институты',
        rating: 4.9,
        reviews: 320,
        imageUrl: 'https://picsum.photos/seed/kz/200/200',
      ),
      LeaderboardEntry(
        id: 'ls2',
        name: 'Педагогика',
        meta: 'Педагогика институты',
        rating: 4.7,
        reviews: 210,
        imageUrl: 'https://picsum.photos/seed/ped/200/200',
      ),
      LeaderboardEntry(
        id: 'ls3',
        name: 'Психология',
        meta: 'Педагогика институты',
        rating: 4.8,
        reviews: 180,
        imageUrl: 'https://picsum.photos/seed/psy/200/200',
      ),
    ],
    FeedbackDomain.building: [
      LeaderboardEntry(
        id: 'lb1',
        name: 'Бас корпус №1',
        meta: 'Достық даңғылы, 13',
        rating: 4.5,
        reviews: 430,
        imageUrl: 'https://picsum.photos/seed/campus/200/200',
      ),
      LeaderboardEntry(
        id: 'lb2',
        name: 'Оқу ғимараты №2',
        meta: 'Қазыбек би көшесі, 30',
        rating: 4.3,
        reviews: 210,
        imageUrl: 'https://picsum.photos/seed/building2/200/200',
      ),
      LeaderboardEntry(
        id: 'lb3',
        name: 'Жатақхана №1',
        meta: 'Төле би көшесі, 86',
        rating: 4.1,
        reviews: 320,
        imageUrl: 'https://picsum.photos/seed/dorm3/200/200',
      ),
    ],
    FeedbackDomain.studentLife: [
      LeaderboardEntry(
        id: 'll1',
        name: 'Атмосфера',
        meta: 'Университет ортасы',
        rating: 4.9,
        reviews: 1500,
        imageUrl: 'https://picsum.photos/seed/atmos/200/200',
      ),
      LeaderboardEntry(
        id: 'll2',
        name: 'Іс-шаралар',
        meta: 'Мәдени өмір',
        rating: 4.8,
        reviews: 1200,
        imageUrl: 'https://picsum.photos/seed/events2/200/200',
      ),
      LeaderboardEntry(
        id: 'll3',
        name: 'Клубтар',
        meta: 'Студенттік ұйымдар',
        rating: 4.5,
        reviews: 850,
        imageUrl: 'https://picsum.photos/seed/clubs2/200/200',
      ),
    ],
  };
}

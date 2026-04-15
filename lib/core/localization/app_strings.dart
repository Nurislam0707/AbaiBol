import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/profile/domain/models/badge_definition.dart';
import 'app_language.dart';
import 'language_provider.dart';

final appStringsProvider = Provider<AppStrings>(
  (ref) => AppStrings(ref.watch(appLanguageProvider)),
);

class AppStrings {
  const AppStrings(this.currentLanguage);

  final AppLanguage currentLanguage;

  String _pick(String kk, String ru, String en) {
    switch (currentLanguage) {
      case AppLanguage.kk:
        return kk;
      case AppLanguage.ru:
        return ru;
      case AppLanguage.en:
        return en;
    }
  }

  String get appTitle => _pick('Nuris Feedback', 'Nuris Feedback', 'Nuris Feedback');
  String get home => _pick('Басты бет', 'Главная', 'Home');
  String get search => _pick('Іздеу', 'Поиск', 'Search');
  String get ranking => _pick('Рейтинг', 'Рейтинг', 'Ranking');
  String get profile => _pick('Профиль', 'Профиль', 'Profile');

  String get anonymousCampusReviews => _pick(
    'Анонимді кампус пікірлері',
    'Анонимные отзывы о кампусе',
    'Anonymous Campus Reviews',
  );
  String get shareFeedbackSafely => _pick(
    'Қауіпсіз түрде пікір қалдырыңыз',
    'Оставляйте отзывы безопасно',
    'Share feedback safely',
  );

  String get teacherReviews => _pick('Мұғалімдер', 'Преподаватели', 'Teachers');
  String get subjectReviews => _pick('Пәндер', 'Предметы', 'Subjects');
  String get buildingReviews => _pick('Корпустар', 'Корпуса', 'Buildings');
  String get studentLifeReviews => _pick('Студенттік өмір', 'Студенческая жизнь', 'Student Life');
  String get clubReviews => _pick('Клубтар', 'Клубы', 'Clubs');

  String get anonymousFeedbackForInstructors => _pick(
    'Оқытушыларға арналған анонимді пікірлер',
    'Анонимные отзывы о преподавателях',
    'Anonymous feedback for instructors',
  );
  String get anonymousFeedbackForSubjects => _pick(
    'Пәндерге арналған анонимді пікірлер',
    'Анонимные отзывы о предметах',
    'Course feedback shared anonymously',
  );
  String get anonymousFeedbackForBuildings => _pick(
    'Ғимараттар мен корпустарды бағалаңыз',
    'Оцените здания и корпуса',
    'Rate buildings and campus facilities',
  );
  String get anonymousFeedbackForStudentLife => _pick(
    'Студенттік өмір сапасын жақсартуға көмектесіңіз',
    'Помогите улучшить студенческую жизнь',
    'Help improve the quality of student life',
  );

  String get searchTeachersOrDepartments => _pick(
    'Оқытушыны немесе кафедраны іздеу',
    'Поиск преподавателя или кафедры',
    'Search teachers or departments',
  );
  String get searchSubjects => _pick('Пәндерді іздеу', 'Поиск предметов', 'Search subjects');
  String get searchBuildings => _pick('Корпустарды іздеу', 'Поиск корпусов', 'Search buildings');

  String teachersAvailable(int count) => _pick(
    '$count оқытушы қолжетімді',
    'Доступно преподавателей: $count',
    '$count teachers available',
  );
  String subjectsAvailable(int count) => _pick(
    '$count пән қолжетімді',
    'Доступно предметов: $count',
    '$count subjects available',
  );

  String get noTeachersFound => _pick('Оқытушылар табылмады', 'Преподаватели не найдены', 'No teachers found');
  String get noSubjectsFound => _pick('Пәндер табылмады', 'Предметы не найдены', 'No subjects found');

  String get emptyTeachersSubtitle => _pick(
    'Оқытушылар тізімі бос немесе іздеу бойынша ештеңе табылмады.',
    'Список преподавателей пуст или поиск не дал результатов.',
    'The teachers list is empty or your search returned no matches.',
  );
  String get emptySubjectsSubtitle => _pick(
    'Пәндер тізімі бос немесе іздеу бойынша ештеңе табылмады.',
    'Список предметов пуст или поиск не дал результатов.',
    'The subjects list is empty or your search returned no matches.',
  );

  String get unableToLoadTeachers => _pick('Оқытушылар жүктелмеді', 'Не удалось загрузить преподавателей', 'Unable to load teachers');
  String get unableToLoadSubjects => _pick('Пәндер жүктелмеді', 'Не удалось загрузить предметы', 'Unable to load subjects');

  String get anonymousReviews => _pick('Анонимді пікірлер', 'Анонимные отзывы', 'Anonymous Reviews');
  String get recentReviews => _pick('Соңғы пікірлер', 'Последние отзывы', 'Recent reviews');
  
  String anonymousReviewsCount(int count) => _pick(
    '$count анонимді пікір',
    '$count анонимных отзывов',
    '$count anonymous reviews',
  );

  String get leaveAnonymousReview => _pick(
    'Анонимді пікір қалдыру',
    'Оставить анонимный отзыв',
    'Leave an anonymous review',
  );
  String get reviewAlreadySubmitted => _pick(
    'Пікір жақында жіберілген',
    'Отзыв недавно отправлен',
    'Review recently submitted',
  );
  String get noReviewsYet => _pick('Әзірге пікір жоқ', 'Пока нет отзывов', 'No reviews yet');
  String get beFirstReviewer => _pick(
    'Алғашқы болып анонимді пікір қалдырыңыз.',
    'Станьте первым, кто оставит анонимный отзыв.',
    'Be the first student to leave anonymous feedback.',
  );

  String get anonymousStudent => _pick('Анонимді студент', 'Анонимный студент', 'Anonymous student');
  
  String get yourReviewExists => _pick(
    'Сіздің пікіріңіз жарияланды',
    'Ваш отзыв опубликован',
    'Your review is published',
  );
  
  String cooldownMessage(String target) => _pick(
    'Бір $target үшін аптасына тек бір рет пікір қалдыра аласыз.',
    'Для одного $target можно оставлять отзыв не чаще раза в неделю.',
    'You can submit feedback for one $target only once a week.',
  );

  String get teacher => _pick('Мұғалім', 'Преподаватель', 'Teacher');
  String get subject => _pick('Пән', 'Предмет', 'Subject');
  String get building => _pick('Корпус', 'Корпус', 'Building');
  String get studentLife => _pick('Студенттік өмір', 'Студенческая жизнь', 'Student Life');
  String get club => _pick('Клуб', 'Клуб', 'Club');
  String get yesterday => _pick('Кеше', 'Вчера', 'Yesterday');
  String get textlessReview => _pick('Мәтінсіз пікір', 'Отзыв без текста', 'No text review');
  String get swipeToManage => _pick('БАСҚАРУ ҮШІН СОЛҒА СВАЙП ЖАСАҢЫЗ', 'СВАЙПНИТЕ ВЛЕВО ДЛЯ УПРАВЛЕНИЯ', 'SWIPE LEFT TO MANAGE');

  String get searchByTeacherSubject => _pick(
    'Оқытушыны, кафедраны немесе пәнді іздеу...',
    'Поиск по преподавателю, кафедре или предмету...',
    'Search by teacher, department, or subject...',
  );

  String get view => _pick('Көру', 'Посмотреть', 'View');
  String get addReview => _pick('Пікір қосу', 'Добавить отзыв', 'Add Review');
  String get rating => _pick('Бағалау', 'Оценка', 'Rating');
  String get review => _pick('Пікір', 'Отзыв', 'Review');
  String get submitAnonymously => _pick('Анонимді жіберу', 'Отправить анонимно', 'Submit anonymously');
  String get submitting => _pick('Жіберілуде...', 'Отправка...', 'Submitting...');
  String get anonymousReviewSubmitted => _pick('Анонимді пікір жіберілді.', 'Анонимный отзыв отправлен.', 'Anonymous review submitted.');

  // Leaderboard & Real-time features
  String get topRated => _pick('Үздіктер', 'Топ рейтинг', 'Top Rated');
  String get mostReviewed => _pick('Көп пікірлер', 'Популярные', 'Most Reviewed');
  String get bottomRated => _pick('Төмен рейтинг', 'Низкий рейтинг', 'Bottom Rated');
  String get liveStatus => _pick('LIVE 📡', 'LIVE 📡', 'LIVE 📡');
  String get trending => _pick('TRENDING 🔥', 'В ТРЕНДЕ 🔥', 'TRENDING 🔥');
  String get noReviewsShort => _pick('Пікір жоқ', 'Нет отзывов', 'No reviews');
  String totalReviewsCount(int count) => _pick(
    'Жалпы: $count пікір',
    'Всего: $count отзывов',
    'Total: $count reviews',
  );
  String get searchPlaceholder => _pick('Іздеу...', 'Поиск...', 'Search...');
  String get currentRanking => _pick('Ағымдағы рейтинг', 'Текущий рейтинг', 'Current Ranking');
  String get scanQr => _pick('QR Сканер', 'QR Сканер', 'QR Scanner');
  String get scanSubtitle => _pick('Корпусты скан жаса', 'Сканируйте корпуса', 'Scan buildings');
  String get teacherOfTheWeek => _pick('АПТА МҰҒАЛІМІ', 'ПРЕПОДАВАТЕЛЬ НЕДЕЛИ', 'TEACHER OF THE WEEK');
  String get happiness => _pick('Бақыт деңгейі', 'Уровень счастья', 'Happiness');
  String get rankingSubtitle => _pick('Үздік тізімді ашу', 'Открыть список лучших', 'Open top rankings');
  String get all => _pick('Барлығы', 'Все', 'All');
  String get errorOccurred => _pick('Қате орын алды', 'Произошла ошибка', 'An error occurred');
  String get startSearching => _pick('Іздеуді бастаңыз', 'Начните поиск', 'Start searching');
  String get searchPrompt => _pick('Мұғалімнің атын немесе пәнді жазыңыз.', 'Введите имя преподавателя или предмет.', 'Enter teacher name or subject.');
  String get noResultsFound => _pick('Нәтиже табылмады', 'Результатов не найдено', 'No results found');
  String get tryOtherKeywords => _pick('Басқа сөздерді көріңіз.', 'Попробуйте другие ключевые слова.', 'Try other keywords.');
  String get searchTeacherOrSubject => _pick('Мұғалім немесе пәнді іздеу...', 'Поиск преподавателя или предмета...', 'Search teacher or subject...');

  // Reporting
  String get reportReview => _pick('Пікірге шағымдану', 'Пожаловаться на отзыв', 'Report review');
  String get whatIsWrong => _pick('Бұл пікірде не қате?', 'Что не так с этим отзывом?', 'What is wrong with this review?');
  String get reportSpam => _pick('Спам немесе жарнама', 'Спам или реклама', 'Spam or advertising');
  String get reportContent => _pick('Балағат сөздер/қорлау', 'Нецензурная лексика/оскорбления', 'Profanity/insults');
  String get reportFalseInfo => _pick('Жалған ақпарат', 'Ложная информация', 'False information');
  String get reportOther => _pick('Басқа себеп', 'Другая причина', 'Other reason');
  String get reportSubmitted => _pick('Шағымыңыз қабылданды. Рақмет!', 'Ваша жалоба принята. Спасибо!', 'Your report has been received. Thank you!');
  String get sentToModeration => _pick('Бұл пікір модерацияға жіберілді.', 'Этот отзыв отправлен на модерацию.', 'This review has been sent for moderation.');
  String helpfulCountLabel(int count) => _pick('$count пайдалы', '$count полезно', '$count helpful');

  // QR & Faculty
  String get scanQrInstruction => _pick('Корпус есігіндегі QR кодты сканерлеңіз', 'Отсканируйте QR-код на двери корпуса', 'Scan the QR code on the building door');
  String get autoRedirectNotice => _pick('Пікірлер бетіне автоматты өтесіз', 'Вы автоматически перейдете на страницу отзывов', 'You will automatically be redirected to the reviews page');
  String get chooseFaculty => _pick('Факультетті таңдаңыз', 'Выберите факультет', 'Choose Faculty');
  String get chooseFacultySubtitle => _pick('Пікір қалдыру үшін өз факультетіңізді көрсетіңіз.', 'Укажите свой факультет, чтобы оставить отзыв.', 'Indicate your faculty to leave a review.');

  String get share => _pick('Бөлісу', 'Поделиться', 'Share');
  String get shareSubtitle => _pick('Досыңа ұсын', 'Порекомендовать другу', 'Recommend to a friend');
  String get averageRating => _pick('Орташа баға', 'Средний балл', 'Average Rating');
  String get reviews => _pick('Пікірлер', 'Отзывы', 'Reviews');
  String get highlights => _pick('Ерекшеліктері', 'Особенности', 'Highlights');
  String get clearMaterial => _pick('Түсінікті материал', 'Понятный материал', 'Clear Material');
  String get fairGrading => _pick('Әділ бағалау', 'Честное оценивание', 'Fair Grading');
  String get fastResponse => _pick('Жедел жауап', 'Быстрый ответ', 'Fast Response');
  String get readReviews => _pick('Пікірлерді оқу', 'Читать отзывы', 'Read Reviews');
  String get teachers => _pick('Мұғалімдер', 'Преподаватели', 'Teachers');
  String get subjects => _pick('Пәндер', 'Предметы', 'Subjects');

  String get settings => _pick('Баптаулар', 'Настройки', 'Settings');
  String get language => _pick('Тіл', 'Язык', 'Language');
  String get darkMode => _pick('Қараңғы режим', 'Тёмная тема', 'Dark mode');
  String get lightMode => _pick('Жарық режим', 'Светлая тема', 'Light mode');
  String get edit => _pick('Өңдеу', 'Изменить', 'Edit');
  String get delete => _pick('Өшіру', 'Удалить', 'Delete');
  String get editName => _pick('Атыңызды өзгерту', 'Изменить имя', 'Edit name');
  String get save => _pick('Сақтау', 'Сохранить', 'Save');
  String get cancel => _pick('Бас тарту', 'Отмена', 'Cancel');
  String get displayName => _pick('Көрінетін есім', 'Отображаемое имя', 'Display name');
  String get enterDisplayName => _pick('Есіміңізді енгізіңіз', 'Введите имя', 'Enter your name');
  String get profileDescription => _pick('Анонимді аккаунт', 'Анонимный аккаунт', 'Anonymous account');
  String get reviewHistory => _pick('Пікірлер тарихы', 'История отзывов', 'Review history');
  String get helpAndSupport => _pick('Көмек және қолдау', 'Помощь и поддержка', 'Help and support');
  String get signedInAnonymously => _pick('Анонимді кіру орындалды', 'Вход выполнен анонимно', 'Signed in anonymously');

  String get editNameSubtitle => _pick('Профиль атыңызды өзгерту', 'Изменить имя профиля', 'Change your profile name');
  String get chooseLanguage => _pick('Тілді таңдаңыз', 'Выберите язык', 'Choose language');
  String get achievementLocked => _pick('Жұмбақ жетістік', 'Секретное достижение', 'Mystery achievement');
  String get achievementLockedDesc => _pick('Бұл жетістікті ашу үшін белсендірек болыңыз!', 'Будьте активнее, чтобы открыть это достижение!', 'Be more active to unlock this!');
  String get profileUpdated => _pick('Профиль сәтті жаңартылды!', 'Профиль успешно обновлен!', 'Profile updated successfully!');
  String get ok => _pick('Жақсы', 'Хорошо', 'OK');

  String get deleteReview => _pick('Пікірді өшіру', 'Удалить отзыв', 'Delete review');
  String get confirmDeleteReview => _pick('Сіз бұл пікірді өшіруді нақты қалайсыз ба?', 'Вы уверенны, что хотите удалить этот отзыв?', 'Are you sure you want to delete this review?');
  String get reviewDeleted => _pick('Пікір сәтті өшірілді', 'Отзыв успешно удален', 'Review deleted successfully');
  String get justNow => _pick('Жаңа ғана', 'Только что', 'Just now');

  String momentumIndicator(int count) => _pick(
    'ҚАЗІР ТАҒЫ $count СТУДЕНТ БАҒАЛАУ ҮСТІНДЕ',
    'СЕЙЧАС ЕЩЕ $count СТУДЕНТА ОЦЕНИВАЮТ',
    '$count OTHER STUDENTS ARE RATING NOW',
  );
  String get anonymousReview => _pick('Анонимді пікір', 'Анонимный отзыв', 'Anonymous review');
  String get shareSubjectsOpinion => _pick('Биылғы пәндер туралы ойыңызды бөлісіңіз.', 'Поделитесь мнением о предметах этого года.', 'Share your opinion about this year\'s subjects.');
  String get rateTeachersFairly => _pick('Мұғалімдерге әділ баға беріңіз.', 'Давайте честную оценку преподавателям.', 'Give fair ratings to your teachers.');
  String get anonymousAndSafe => _pick('АНОНИМДІ ӘРІ ҚАУІПСІЗ', 'АНОНИМНО И БЕЗОПАСНО', 'ANONYMOUS & SAFE');
  String get setScore => _pick('Ұпай қойыңыз', 'Поставьте оценку', 'Set a score');
  String get selectScorePrompt => _pick('Жылжытып таңдаңыз', 'Выберите, потянув', 'Slide to select');
  String get thisTeacherIs => _pick('Бұл мұғалім...', 'Этот преподаватель...', 'This teacher is...');
  String get theSubjectIs => _pick('Бұл пән...', 'Этот предмет...', 'This subject is...');
  String get shareExperience => _pick('Тәжірибеңізбен бөлісіңіз', 'Поделитесь опытом', 'Share your experience');
  String get writeDetailedReview => _pick(
    'Басқа студенттерге көмектесетін толық пікір жазыңыз...',
    'Напишите подробный отзыв, который поможет другим...',
    'Write a detailed review to help other students...',
  );
  String get qualityLevel => _pick('САПА ДЕҢГЕЙІ:', 'УРОВЕНЬ КАЧЕСТВА:', 'QUALITY LEVEL:');
  String get reviewSubmittedAnonymously => _pick(
    'Пікіріңіз анонимді түрде қабылданды!',
    'Ваш отзыв принят анонимно!',
    'Your review has been accepted anonymously!',
  );
  String get deletingReviewError => _pick('Пікірді өшіру мүмкін болмады.', 'Не удалось удалить отзыв.', 'Failed to delete review.');
  String get noReviewsWritten => _pick('Ешқандай пікір жазылмаған', 'Отзывов пока нет', 'No reviews written yet');
  String get allReviewsSafe => _pick('Сіз жазған барлық пікірлер осы жерде сақталады', 'Все ваши отзывы будут храниться здесь', 'All your reviews will be stored here');
  String get achievements => _pick('Жетістіктер', 'Достижения', 'Achievements');

  // Feedback Tags
  String get strict => _pick('Қатал', 'Строгий', 'Strict');
  String get interesting => _pick('Қызықты', 'Интересно', 'Interesting');
  String get experienced => _pick('Тәжірибелі', 'Опытный', 'Experienced');
  String get difficult => _pick('Қиын', 'Сложно', 'Difficult');
  String get useful => _pick('Пайдалы', 'Полезно', 'Useful');
  String get manyTasks => _pick('Көп тапсырма', 'Много заданий', 'Many tasks');
  String get necessary => _pick('Қажетті', 'Необходимо', 'Necessary');
  String get active => _pick('Белсенді', 'Активный', 'Active');
  String get friendly => _pick('Достық орта', 'Дружелюбная среда', 'Friendly');
  String get expensive => _pick('Қымбат', 'Дорого', 'Expensive');
  String get cleanliness => _pick('Тазалық', 'Чистота', 'Cleanliness');
  String get comfortable => _pick('Ыңғайлы', 'Удобно', 'Comfortable');
  String get cold => _pick('Суық', 'Холодно', 'Cold');
  String get new_ => _pick('Жаңа', 'Новое', 'New');
  String get crowded => _pick('Көп адам', 'Много людей', 'Crowded');

  String ratingLabel(int r) {
    if (r <= 2) return _pick('Көңілім толмайды ($r/5)', 'Я разочарован ($r/5)', 'Disappointed ($r/5)');
    if (r == 3) return _pick('Жақсы, орташа ($r/5)', 'Хорошо, средне ($r/5)', 'Good, average ($r/5)');
    return _pick('Керемет! Тамаша! (5/5)', 'Отлично! Прекрасно! (5/5)', 'Excellent! Perfect! (5/5)');
  }

  // Campus Vibe
  String get productiveTitle => _pick('Жұмыс қызып жатыр! 🚀', 'Работа кипит! 🚀', 'Work is in full swing! 🚀');
  String get coffeeTitle => _pick('Кофе қажет... ☕', 'Нужен кофе... ☕', 'Need coffee... ☕');
  String get examsTitle => _pick('Емтихандар жақында! 🔥', 'Скоро экзамены! 🔥', 'Exams are coming! 🔥');
  String get zenTitle => _pick('Зен', 'Зен', 'Zen');
  String get zenDesc => _pick('Кампуста тыныштық 🧘', 'В кампусе тишина 🧘', 'Peace in campus 🧘');

  // Badges
  String get badgeFirstReview => _pick('Алғашқы пікір', 'Первый отзыв', 'First Review');
  String get badgeFirstReviewDesc => _pick('Бірінші пікіріңізді жаздыңыз!', 'Вы написали первый отзыв!', 'You wrote your first review!');
  String get badgeActiveStudent => _pick('Белсенді студент', 'Активный студент', 'Active student');
  String get badgeActiveStudentDesc => _pick('3 пікір жаздыңыз', 'Написали 3 отзыва', 'Wrote 3 reviews');
  String get badgeExperienced => _pick('Тәжірибелі', 'Опытный', 'Experienced');
  String get badgeExperiencedDesc => _pick('10 пікір жаздыңыз', 'Написали 10 отзывов', 'Wrote 10 reviews');
  String get badgeExpert => _pick('Эксперт', 'Эксперт', 'Expert');
  String get badgeExpertDesc => _pick('20 пікір жаздыңыз', 'Написали 20 отзывов', 'Wrote 20 reviews');
  String get badgeHelpful => _pick('Пайдалы', 'Полезный', 'Helpful');
  String get badgeHelpfulDesc => _pick('5 лайк жинадыңыз', 'Собрали 5 лайков', 'Collected 5 likes');
  String get badgeInfluential => _pick('Ықпалды', 'Влиятельный', 'Influential');
  String get badgeInfluentialDesc => _pick('20 лайк жинадыңыз', 'Собрали 20 лайков', 'Collected 20 likes');

  String badgeLabel(BadgeId id) {
    return switch (id) {
      BadgeId.firstReview => badgeFirstReview,
      BadgeId.threeReview => badgeActiveStudent,
      BadgeId.tenReview => badgeExperienced,
      BadgeId.twentyReview => badgeExpert,
      BadgeId.helpful5 => badgeHelpful,
      BadgeId.helpful20 => badgeInfluential,
    };
  }

  String badgeDesc(BadgeId id) {
    return switch (id) {
      BadgeId.firstReview => badgeFirstReviewDesc,
      BadgeId.threeReview => badgeActiveStudentDesc,
      BadgeId.tenReview => badgeExperiencedDesc,
      BadgeId.twentyReview => badgeExpertDesc,
      BadgeId.helpful5 => badgeHelpfulDesc,
      BadgeId.helpful20 => badgeInfluentialDesc,
    };
  }

  String hoursAgo(int h) => _pick('$h сағ бұрын', '$h ч. назад', '$h h. ago');
  String daysAgo(int d) => _pick('$d күн бұрын', '$d дн. назад', '$d d. ago');

  String get report => _pick('Шағымдану', 'Пожаловаться', 'Report');
  String get privacyPolicy => _pick('Құпиялылық саясаты', 'Политика конфиденциальности', 'Privacy Policy');
  String get helpSubtitle => _pick('Жиі сұрақтар мен байланыс', 'Частые вопросы и связь', 'Help and support');
  String get privacySubtitle => _pick('Деректеріңіз қалай сақталады', 'Как хранятся ваши данные', 'Privacy policy');
  String get viewRanking => _pick('Рейтингті көру', 'Посмотреть рейтинг', 'View ranking');
  String get chooseCategory => _pick('Санатты таңдаңыз', 'Выберите категорию', 'Choose category');
  String get facultyReviews => _pick('Факультет пікірлері', 'Отзывы факультета', 'Faculty reviews');
  String get leaderboardSubtitle => _pick('Үздік оқытушылар мен пәндер', 'Лучшие преподаватели и предметы', 'Top teachers and subjects');
  String get recentActivity => _pick('Соңғы белсенділік', 'Последняя активность', 'Recent activity');
  String get helpImproveLife => _pick('Студенттік өмірді жақсартуға көмектесіңіз', 'Помогите улучшить студенческую жизнь', 'Help improve student life');
  String get anonymousExplanation => _pick('Пікіріңіз толығымен анонимді түрде жарияланады.', 'Ваш отзыв будет опубликован полностью анонимно.', 'Your feedback will be posted completely anonymously.');
  String get submit => _pick('Жіберу', 'Отправить', 'Submit');
  String get noReviews => _pick('Пікір жоқ', 'Нет отзывов', 'No reviews');
}

extension AppStringsBuildContextX on BuildContext {
  AppStrings get strings =>
      ProviderScope.containerOf(this).read(appStringsProvider);
}

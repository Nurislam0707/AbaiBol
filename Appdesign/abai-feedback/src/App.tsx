import React, { useState } from 'react';
import { 
  Home, 
  Search, 
  Star, 
  User, 
  Bell, 
  ChevronLeft, 
  ChevronRight, 
  Building2, 
  MessageSquare,
  MapPin,
  ShieldCheck,
  Trophy,
  LayoutGrid,
  Coffee,
  Trash2,
  Book,
  Monitor,
  Dumbbell,
  PartyPopper,
  Users2,
  Wind,
  TrendingUp,
  Calendar,
  GraduationCap,
  Settings,
  LogOut,
  Award,
  History,
  Moon,
  Sun,
  HelpCircle,
  CheckCircle2
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Screen, Category, Faculty, Teacher, Activity, SearchResult } from './types';

// --- Mock Data ---
const CATEGORIES: Category[] = [
  { id: '1', title: 'Мұғалімдер', rating: 4.8, reviews: '1.2k', image: 'https://picsum.photos/seed/prof/400/500', screen: 'faculties' },
  { id: '2', title: 'Пәндер', rating: 4.5, reviews: '850', image: 'https://picsum.photos/seed/books/400/500', screen: 'subject-rating' },
  { id: '3', title: 'Корпустар', rating: 4.2, reviews: '430', image: 'https://picsum.photos/seed/campus/400/500', screen: 'faculties' },
  { id: '4', title: 'Студенттік өмір', rating: 4.9, reviews: '1.5k', image: 'https://picsum.photos/seed/life/400/500', screen: 'student-life-rating' },
];

const FACULTIES: Faculty[] = [
  { id: '1', name: 'Педагогика және психология', type: 'Институт', icon: 'psychology' },
  { id: '2', name: 'Жаратылыстану және география', type: 'Институт', icon: 'public' },
  { id: '3', name: 'Математика, физика және информатика', type: 'Институт', icon: 'functions' },
  { id: '4', name: 'Филология', type: 'Институт', icon: 'translate' },
  { id: '5', name: 'Өнер, мәдениет және спорт', type: 'Институт', icon: 'palette' },
  { id: '6', name: 'Тарих және құқық', type: 'Институт', icon: 'balance' },
];

const TEACHERS: Teacher[] = [
  { id: '1', name: 'Ахметова Гүлнар Саматқызы', department: 'Қазақ әдебиеті кафедрасы', rating: 9.2, reviews: 148, image: 'https://picsum.photos/seed/t1/200/200' },
  { id: '2', name: 'Оспанов Бауыржан Нұрланұлы', department: 'Орыс тілі кафедрасы', rating: 8.7, reviews: 92, image: 'https://picsum.photos/seed/t2/200/200' },
  { id: '3', name: 'Сүлейменова Әлия Мұратқызы', department: 'Шетел тілдері кафедрасы', rating: 7.9, reviews: 56, image: 'https://picsum.photos/seed/t3/200/200' },
];

const ACTIVITIES: Activity[] = [
  { id: '1', category: 'Студенттік өмір', time: 'жаңа ғана', text: 'Кешегі өткен концерт өте керемет болды! Ұйымдастырушыларға рақмет.', type: 'comment' },
  { id: '2', category: 'Пәндер', time: '2 мин бұрын', text: 'Педагогика пәні өте қызықты өтуде, практикалық жұмыстар көп...', type: 'comment' },
  { id: '3', category: 'Мұғалімдер', time: '15 мин бұрын', text: 'Жаңа рейтинг жаңартылды. Үздік оқытушылар анықталды.', type: 'rating' },
];

const BUILDING_SUB_CATEGORIES = [
  { id: 'canteen', title: 'Асхана', icon: <Coffee />, color: 'bg-orange-100 text-orange-600' },
  { id: 'toilet', title: 'Туалет', icon: <Trash2 />, color: 'bg-blue-100 text-blue-600' },
  { id: 'library', title: 'Кітапхана', icon: <Book />, color: 'bg-emerald-100 text-emerald-600' },
  { id: 'coworking', title: 'Коворкинг', icon: <Monitor />, color: 'bg-purple-100 text-purple-600' },
  { id: 'gym', title: 'Спорт зал', icon: <Dumbbell />, color: 'bg-rose-100 text-rose-600' },
];

const STUDENT_LIFE_SUB_CATEGORIES = [
  { id: 'events', title: 'Іс-шаралар', rating: 4.8, icon: <PartyPopper />, image: 'https://picsum.photos/seed/events/200/200', screen: 'student-life-rating' },
  { id: 'clubs', title: 'Клубтар', rating: 4.5, icon: <Users2 />, image: 'https://picsum.photos/seed/clubs/200/200', screen: 'clubs-list' },
  { id: 'dorm', title: 'Жатақхана', rating: 4.2, icon: <Building2 />, image: 'https://picsum.photos/seed/dorm/200/200', screen: 'student-life-rating' },
  { id: 'atmos', title: 'Атмосфера', rating: 4.9, icon: <Wind />, image: 'https://picsum.photos/seed/atmos/200/200', screen: 'student-life-rating' },
];

const CLUBS = [
  { id: '1', title: 'Дебат клубы', rating: 4.8, reviews: 124, image: 'https://picsum.photos/seed/debate/200/200', category: 'Ғылым' },
  { id: '2', title: 'Би үйірмесі', rating: 4.9, reviews: 86, image: 'https://picsum.photos/seed/dance/200/200', category: 'Өнер' },
  { id: '3', title: 'Волонтерлер ұйымы', rating: 5.0, reviews: 210, image: 'https://picsum.photos/seed/vol/200/200', category: 'Әлеуметтік' },
  { id: '4', title: 'Спорт секциялары', rating: 4.7, reviews: 156, image: 'https://picsum.photos/seed/sport/200/200', category: 'Спорт' },
];

const SUBJECTS = [
  { id: '1', title: 'Қазақ тілі', rating: 4.9, reviews: 320, image: 'https://picsum.photos/seed/kz/200/200', category: 'Гуманитарлық' },
  { id: '2', title: 'Математикалық талдау', rating: 4.2, reviews: 150, image: 'https://picsum.photos/seed/math/200/200', category: 'Жаратылыстану' },
  { id: '3', title: 'Педагогика', rating: 4.7, reviews: 210, image: 'https://picsum.photos/seed/ped/200/200', category: 'Білім беру' },
  { id: '4', title: 'Психология', rating: 4.8, reviews: 180, image: 'https://picsum.photos/seed/psy/200/200', category: 'Білім беру' },
  { id: '5', title: 'Ақпараттық технологиялар', rating: 4.6, reviews: 240, image: 'https://picsum.photos/seed/it/200/200', category: 'Техникалық' },
  { id: '6', title: 'Дүниежүзі тарихы', rating: 4.5, reviews: 130, image: 'https://picsum.photos/seed/hist/200/200', category: 'Гуманитарлық' },
];

const SEARCH_RESULTS: SearchResult[] = [
  { id: '1', title: 'Ахметов Қанат Сабырұлы', rating: 4.9, type: 'teacher', subtitle: 'Оқытушы • Педагогика кафедрасы', description: 'Педагогика ғылымдарының докторы, 15 жылдық тәжірибесі бар...', icon: <GraduationCap size={20} /> },
  { id: '2', title: 'Қазақ әдебиетінің тарихы', rating: 4.7, type: 'subject', subtitle: 'Пән • Филология институты', description: 'Көне дәуірден бүгінгі күнге дейінгі қазақ әдебиетінің даму кезеңдерін...', icon: <Book size={20} /> },
  { id: '3', title: 'Бас корпус (№1)', rating: 4.5, type: 'building', subtitle: 'Корпус • Достық даңғылы, 13', description: 'Университет әкімшілігі мен тарих және құқық институты орналасқан...', icon: <Building2 size={20} /> },
  { id: '4', title: 'Смағұлова Әлия Нұрланқызы', rating: 4.8, type: 'teacher', subtitle: 'Оқытушы • Математика институты', description: 'Жоғары математика және ықтималдықтар теориясы бойынша...', icon: <GraduationCap size={20} /> },
];

const TOP_TEACHERS = [
  { id: '1', name: 'Ахметов Бауыржан', faculty: 'Физика-математика факультеті', rating: 4.9, reviews: 128, image: 'https://picsum.photos/seed/b1/200/200', trend: 'up' },
  { id: '2', name: 'Сапарова Гүлнұр', faculty: 'Филология факультеті', rating: 4.8, reviews: 86, image: 'https://picsum.photos/seed/b2/200/200', trend: 'up' },
  { id: '3', name: 'Омаров Дәурен', faculty: 'Тарих және құқық факультеті', rating: 4.7, reviews: 74, image: 'https://picsum.photos/seed/b3/200/200', trend: 'up' },
  { id: '4', name: 'Қасымова Әйгерім', faculty: 'Педагогика факультеті', rating: 4.6, reviews: 62, image: 'https://picsum.photos/seed/b4/200/200', trend: 'up' },
  { id: '5', name: 'Болатұлы Нұрлан', faculty: 'Өнер және спорт факультеті', rating: 4.5, reviews: 55, image: 'https://picsum.photos/seed/b5/200/200', trend: 'up' },
];

const TOP_SUBJECTS = [
  { id: '1', name: 'Қазақ тілі', faculty: 'Филология институты', rating: 4.9, reviews: 320, image: 'https://picsum.photos/seed/kz/200/200', trend: 'up' },
  { id: '2', name: 'Педагогика', faculty: 'Педагогика институты', rating: 4.7, reviews: 210, image: 'https://picsum.photos/seed/ped/200/200', trend: 'up' },
  { id: '3', name: 'Психология', faculty: 'Педагогика институты', rating: 4.8, reviews: 180, image: 'https://picsum.photos/seed/psy/200/200', trend: 'up' },
  { id: '4', name: 'Ақпараттық технологиялар', faculty: 'МФИ институты', rating: 4.6, reviews: 240, image: 'https://picsum.photos/seed/it/200/200', trend: 'up' },
  { id: '5', name: 'Дүниежүзі тарихы', faculty: 'Тарих және құқық институты', rating: 4.5, reviews: 130, image: 'https://picsum.photos/seed/hist/200/200', trend: 'up' },
];

const TOP_BUILDINGS = [
  { id: '1', name: 'Бас корпус (№1)', faculty: 'Достық даңғылы, 13', rating: 4.5, reviews: 430, image: 'https://picsum.photos/seed/campus/200/200', trend: 'up' },
  { id: '2', name: 'Оқу ғимараты №2', faculty: 'Қазыбек би көшесі, 30', rating: 4.3, reviews: 210, image: 'https://picsum.photos/seed/b2/200/200', trend: 'up' },
  { id: '3', name: 'Оқу ғимараты №5', faculty: 'Жамбыл көшесі, 25', rating: 4.2, reviews: 150, image: 'https://picsum.photos/seed/b5/200/200', trend: 'up' },
  { id: '4', name: 'Жатақхана №1', faculty: 'Төле би көшесі, 86', rating: 4.1, reviews: 320, image: 'https://picsum.photos/seed/dorm/200/200', trend: 'up' },
  { id: '5', name: 'Спорт кешені', faculty: 'Абай даңғылы, 56', rating: 4.0, reviews: 90, image: 'https://picsum.photos/seed/sport/200/200', trend: 'up' },
];

const TOP_STUDENT_LIFE = [
  { id: '1', name: 'Атмосфера', faculty: 'Университет ортасы', rating: 4.9, reviews: 1500, image: 'https://picsum.photos/seed/atmos/200/200', trend: 'up' },
  { id: '2', name: 'Іс-шаралар', faculty: 'Мәдени өмір', rating: 4.8, reviews: 1200, image: 'https://picsum.photos/seed/events/200/200', trend: 'up' },
  { id: '3', name: 'Клубтар', faculty: 'Студенттік ұйымдар', rating: 4.5, reviews: 850, image: 'https://picsum.photos/seed/clubs/200/200', trend: 'up' },
  { id: '4', name: 'Жатақхана жағдайы', faculty: 'Тұрмыстық жағдай', rating: 4.2, reviews: 600, image: 'https://picsum.photos/seed/dorm2/200/200', trend: 'up' },
  { id: '5', name: 'Асхана сапасы', faculty: 'Тамақтану', rating: 4.0, reviews: 430, image: 'https://picsum.photos/seed/food/200/200', trend: 'up' },
];

// --- Components ---

const BottomNav = ({ current, setScreen }: { current: Screen, setScreen: (s: Screen) => void }) => (
  <div className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md bg-white/80 backdrop-blur-md border-t border-slate-100 px-6 pb-8 pt-3 z-50 flex justify-between items-center">
    <button onClick={() => setScreen('home')} className={`flex flex-col items-center gap-1 ${current === 'home' ? 'text-primary' : 'text-slate-400'}`}>
      <Home size={24} fill={current === 'home' ? 'currentColor' : 'none'} />
      <span className="text-[10px] font-bold">Басты бет</span>
    </button>
    <button onClick={() => setScreen('search')} className={`flex flex-col items-center gap-1 ${current === 'search' ? 'text-primary' : 'text-slate-400'}`}>
      <Search size={24} />
      <span className="text-[10px] font-medium">Іздеу</span>
    </button>
    <button onClick={() => setScreen('rating-list')} className={`flex flex-col items-center gap-1 ${current === 'rating-list' ? 'text-primary' : 'text-slate-400'}`}>
      <Trophy size={24} />
      <span className="text-[10px] font-medium">Рейтинг</span>
    </button>
    <button onClick={() => setScreen('profile')} className={`flex flex-col items-center gap-1 ${current === 'profile' ? 'text-primary' : 'text-slate-400'}`}>
      <User size={24} fill={current === 'profile' ? 'currentColor' : 'none'} />
      <span className="text-[10px] font-medium">Профиль</span>
    </button>
  </div>
);

const Header = ({ title, onBack }: { title: string, onBack?: () => void }) => (
  <div className="sticky top-0 z-40 bg-white/80 backdrop-blur-md px-4 py-4 flex items-center justify-between border-b border-slate-50">
    <div className="flex items-center gap-3">
      {onBack && (
        <button onClick={onBack} className="p-2 -ml-2 rounded-full hover:bg-slate-100">
          <ChevronLeft size={24} className="text-primary" />
        </button>
      )}
      {!onBack && (
        <div className="size-10 rounded-full bg-primary/10 flex items-center justify-center border border-primary/20 overflow-hidden">
           <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuCtCYH967z7kfpW6tCYviK-FU0D-ip9zasb6uIdMey3fJ2D7rSvtDt20DU3RUY-Rf_v7XxPLMElpPekh_uJAzvq3HMh2elCy2M_QzSlSpsOfFUWyX4zoXHz7uzGGYdqaAITdCNoh4LcOIsdt42RvR2vhP_yRW1ZCL2noN_mIYV11VuNVZJhIEwZCzhdEryFIdOCkU-tahdOczFTsCHPegTS9k9sSCtV6yk2v0AidpBnTpvJiHr7CCN-pxm5V9tqvMWkXO2Jp_ABrvc" alt="Logo" className="w-full h-full object-cover" />
        </div>
      )}
      <div>
        {!onBack && <p className="text-[10px] font-bold text-primary uppercase tracking-wider leading-none">Abai University</p>}
        <h1 className="text-lg font-bold text-slate-900">{onBack ? title : 'Анонимді пікір'}</h1>
      </div>
    </div>
    <button className="p-2 rounded-full bg-slate-50 text-slate-600">
      <Bell size={20} />
    </button>
  </div>
);

// --- Screens ---

interface HomeScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
  setFacultyContext: (c: 'teachers' | 'buildings') => void;
}

const HomeScreen = ({ setScreen, setFacultyContext }: HomeScreenProps) => (
  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
    <Header title="Басты бет" />
    <div className="px-4 pt-6">
      <div className="bg-primary rounded-2xl p-6 text-white shadow-xl shadow-primary/20 relative overflow-hidden">
        <div className="relative z-10">
          <h3 className="text-2xl font-bold mb-2">Қош келдіңіз!</h3>
          <p className="text-white/80 text-sm leading-relaxed">Университет өмірін бірге жақсартайық. Сіздің пікіріңіз маңызды және толықтай анонимді.</p>
        </div>
        <Building2 className="absolute -right-6 -bottom-6 size-32 opacity-10" />
      </div>
    </div>

    <div className="px-4 pt-8 flex items-center justify-between">
      <h2 className="text-xl font-bold">Санатты таңдаңыз</h2>
      <button className="text-primary text-xs font-semibold">Барлығы</button>
    </div>

    <div className="grid grid-cols-2 gap-4 p-4">
      {CATEGORIES.map(cat => (
        <button 
          key={cat.id} 
          onClick={() => {
            if (cat.title === 'Корпустар') {
              setFacultyContext('buildings');
              setScreen('faculties');
            } else if (cat.title === 'Мұғалімдер') {
              setFacultyContext('teachers');
              setScreen('faculties');
            } else if (cat.title === 'Пәндер') {
              setScreen('subjects-list');
            } else if (cat.title === 'Студенттік өмір') {
              setScreen('student-life-categories');
            } else {
              setScreen(cat.screen);
            }
          }}
          className="bg-white rounded-2xl overflow-hidden shadow-sm border border-slate-100 flex flex-col aspect-[4/5] text-left active:scale-95 transition-transform"
        >
          <div className="h-3/5 relative">
            <img src={cat.image} alt={cat.title} className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
          </div>
          <div className="p-3 flex-1 flex flex-col justify-between">
            <p className="font-bold text-sm">{cat.title}</p>
            <div className="flex items-center gap-1">
              <Star size={12} className="text-secondary fill-secondary" />
              <span className="text-[10px] text-slate-500 font-medium">{cat.rating} ({cat.reviews} пікір)</span>
            </div>
          </div>
        </button>
      ))}
    </div>

    <h3 className="px-4 pt-6 pb-3 font-bold text-lg">Соңғы белсенділік</h3>
    <div className="px-4 space-y-3">
      {ACTIVITIES.map(act => (
        <div key={act.id} className="flex gap-3 p-4 bg-white rounded-xl border border-slate-50 shadow-sm">
          <div className={`size-10 rounded-full flex items-center justify-center shrink-0 ${act.type === 'comment' ? 'bg-primary/10 text-primary' : 'bg-secondary/20 text-yellow-600'}`}>
            {act.type === 'comment' ? <MessageSquare size={18} /> : <Star size={18} />}
          </div>
          <div className="flex-1">
            <div className="flex justify-between items-center mb-1">
              <span className={`text-[10px] font-bold uppercase tracking-wide ${act.type === 'comment' ? 'text-primary' : 'text-yellow-600'}`}>{act.category}</span>
              <span className="text-[10px] text-slate-400">{act.time}</span>
            </div>
            <p className="text-sm text-slate-600 italic leading-snug">"{act.text}"</p>
          </div>
        </div>
      ))}
    </div>
  </motion.div>
);

interface StudentLifeCategoriesScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
  setSelectedStudentLifeCategory: (c: string) => void;
}

const StudentLifeCategoriesScreen = ({ setScreen, setSelectedStudentLifeCategory }: StudentLifeCategoriesScreenProps) => (
  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
    <Header title="Студенттік өмір санаттары" onBack={() => setScreen('home')} />
    <div className="p-6">
      <h2 className="text-3xl font-bold tracking-tight">Санатты таңдаңыз</h2>
      <p className="text-slate-500 mt-2 text-sm">Абай атындағы университеттегі студенттік өмірдің барлық қырларын зерттеңіз</p>
    </div>

    <div className="px-4 space-y-4">
      {STUDENT_LIFE_SUB_CATEGORIES.map(cat => (
        <div key={cat.id} className="bg-white p-4 rounded-2xl border border-slate-50 shadow-sm flex items-center gap-4">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <span className="text-primary">{cat.icon}</span>
              <h3 className="font-bold text-slate-900">{cat.title}</h3>
            </div>
            <div className="flex items-center gap-1 mb-4">
              <Star size={12} className="text-secondary fill-secondary" />
              <span className="text-[10px] text-slate-400 font-medium">Орташа рейтинг: {cat.rating}</span>
            </div>
            <button 
              onClick={() => {
                setSelectedStudentLifeCategory(cat.title);
                setScreen(cat.screen as Screen);
              }}
              className="bg-primary text-white px-6 py-2 rounded-lg text-xs font-bold flex items-center gap-2 active:scale-95 transition-transform"
            >
              Көру <ChevronRight size={14} />
            </button>
          </div>
          <div className="size-24 rounded-xl overflow-hidden shrink-0">
            <img src={cat.image} alt={cat.title} className="w-full h-full object-cover" />
          </div>
        </div>
      ))}
    </div>
  </motion.div>
);

interface ClubsListScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
  setSelectedClub: (c: string) => void;
}

const ClubsListScreen = ({ setScreen, setSelectedClub }: ClubsListScreenProps) => (
  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
    <Header title="Студенттік өмір" onBack={() => setScreen('student-life-categories')} />
    <div className="p-6">
      <h2 className="text-3xl font-bold tracking-tight">Клубты таңдаңыз</h2>
      <p className="text-slate-500 mt-2 text-sm">Өзіңізге ұнайтын қауымдастықты табыңыз</p>
    </div>

    <div className="px-4 mb-4">
      <div className="relative mb-4">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
        <input className="w-full bg-slate-100 border-none rounded-xl py-3 pl-10 pr-4 focus:ring-2 focus:ring-primary text-sm" placeholder="Клубты іздеу..." type="text" />
      </div>
      <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
        {['Барлығы', 'Спорт', 'Өнер', 'Ғылым'].map((tag, i) => (
          <button key={tag} className={`px-5 py-2 rounded-full text-xs font-bold whitespace-nowrap transition-colors ${i === 0 ? 'bg-primary text-white' : 'bg-slate-100 text-slate-500'}`}>
            {tag}
          </button>
        ))}
      </div>
    </div>

    <div className="px-4 space-y-4">
      {CLUBS.map(club => (
        <div key={club.id} className="bg-white p-4 rounded-2xl border border-slate-50 shadow-sm flex items-center gap-4">
          <div className="flex-1">
            <h3 className="font-bold text-slate-900 mb-1">{club.title}</h3>
            <div className="flex items-center gap-1 mb-4">
              <Star size={12} className="text-secondary fill-secondary" />
              <span className="text-[10px] text-slate-400 font-medium">{club.rating} • ({club.reviews} пікір)</span>
            </div>
            <button 
              onClick={() => {
                setSelectedClub(club.title);
                setScreen('student-life-rating');
              }}
              className="bg-slate-50 text-slate-600 px-6 py-2 rounded-lg text-xs font-bold active:scale-95 transition-transform"
            >
              Толығырақ
            </button>
          </div>
          <div className="size-24 rounded-xl overflow-hidden shrink-0 bg-orange-100">
            <img src={club.image} alt={club.title} className="w-full h-full object-cover mix-blend-multiply opacity-80" />
          </div>
        </div>
      ))}
    </div>
  </motion.div>
);

interface FacultyScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
  context: 'teachers' | 'buildings';
  setSelectedFaculty: (f: string) => void;
}

const FacultyScreen = ({ setScreen, context, setSelectedFaculty }: FacultyScreenProps) => (
  <motion.div initial={{ x: 50, opacity: 0 }} animate={{ x: 0, opacity: 1 }} exit={{ x: -50, opacity: 0 }} className="pb-24">
    <Header title="Факультет" onBack={() => setScreen('home')} />
    <div className="p-6">
      <h2 className="text-3xl font-bold tracking-tight">Факультетті таңдаңыз</h2>
      <p className="text-slate-500 mt-2">Пікір қалдыру үшін өз факультетіңізді көрсетіңіз</p>
    </div>
    
    <div className="px-4 mb-6">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
        <input className="w-full bg-slate-100 border-none rounded-xl py-3 pl-10 pr-4 focus:ring-2 focus:ring-primary text-sm" placeholder="Іздеу..." type="text" />
      </div>
    </div>

    <div className="px-4 space-y-2">
      {FACULTIES.map(fac => (
        <button 
          key={fac.id} 
          onClick={() => {
            setSelectedFaculty(fac.name);
            setScreen(context === 'teachers' ? 'teachers' : 'building-categories');
          }} 
          className="w-full flex items-center gap-4 bg-white p-4 rounded-2xl shadow-sm border border-slate-50 active:scale-[0.98] transition-all text-left"
        >
          <div className="size-12 rounded-xl bg-primary/10 text-primary flex items-center justify-center">
             <LayoutGrid size={24} />
          </div>
          <div className="flex-1 min-w-0">
            <p className="font-bold text-slate-900 truncate">{fac.name}</p>
            <p className="text-xs text-slate-500">{fac.type}</p>
          </div>
          <ChevronRight size={20} className="text-slate-300" />
        </button>
      ))}
    </div>
  </motion.div>
);

interface BuildingCategoriesScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
  faculty: string;
  setSelectedBuildingCategory: (c: string) => void;
}

const BuildingCategoriesScreen = ({ setScreen, faculty, setSelectedBuildingCategory }: BuildingCategoriesScreenProps) => (
  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
    <Header title="Корпус санаттары" onBack={() => setScreen('faculties')} />
    <div className="p-6">
      <h2 className="text-2xl font-bold tracking-tight">{faculty}</h2>
      <p className="text-slate-500 mt-1">Осы корпустағы бағалағыңыз келетін санатты таңдаңыз</p>
    </div>

    <div className="px-4 grid grid-cols-1 gap-3">
      {BUILDING_SUB_CATEGORIES.map(cat => (
        <button 
          key={cat.id} 
          onClick={() => {
            setSelectedBuildingCategory(cat.title);
            setScreen('building-rating');
          }}
          className="flex items-center gap-4 bg-white p-5 rounded-2xl border border-slate-50 shadow-sm active:scale-[0.98] transition-all"
        >
          <div className={`size-12 rounded-xl flex items-center justify-center ${cat.color}`}>
            {cat.icon}
          </div>
          <div className="flex-1">
            <p className="font-bold text-slate-900">{cat.title}</p>
            <p className="text-xs text-slate-400">Бағалау және пікір қалдыру</p>
          </div>
          <ChevronRight size={20} className="text-slate-300" />
        </button>
      ))}
    </div>
  </motion.div>
);

interface SearchScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
}

const SearchScreen = ({ setScreen }: SearchScreenProps) => {
  const [activeFilter, setActiveFilter] = useState('Барлығы');
  
  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
      <Header title="Іздеу" onBack={() => setScreen('home')} />
      
      <div className="px-4 py-4 sticky top-[68px] bg-white/80 backdrop-blur-md z-30">
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input 
            className="w-full bg-slate-100 border-none rounded-xl py-3 pl-10 pr-4 focus:ring-2 focus:ring-primary text-sm" 
            placeholder="Абай университеті бойынша іздеу..." 
            type="text" 
          />
        </div>
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
          {['Барлығы', 'Оқытушылар', 'Пәндер', 'Корпустар'].map(filter => (
            <button 
              key={filter}
              onClick={() => setActiveFilter(filter)}
              className={`px-6 py-2 rounded-full text-xs font-bold whitespace-nowrap transition-colors ${activeFilter === filter ? 'bg-primary text-white' : 'bg-slate-100 text-slate-500'}`}
            >
              {filter}
            </button>
          ))}
        </div>
      </div>

      <div className="px-4 py-2">
        <h3 className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">ІЗДЕУ НӘТИЖЕЛЕРІ</h3>
      </div>

      <div className="px-4 space-y-3 mt-2">
        {SEARCH_RESULTS.map(res => (
          <div key={res.id} className="bg-white p-4 rounded-2xl border border-slate-50 shadow-sm flex gap-4 active:scale-[0.98] transition-all">
            <div className="size-14 rounded-xl bg-primary/5 text-primary flex items-center justify-center shrink-0">
              {res.icon}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex justify-between items-start mb-0.5">
                <h4 className="font-bold text-slate-900 truncate pr-2">{res.title}</h4>
                <div className="flex items-center gap-1 text-secondary shrink-0">
                  <Star size={12} fill="currentColor" />
                  <span className="text-xs font-bold">{res.rating}</span>
                </div>
              </div>
              <p className="text-[10px] font-bold text-primary uppercase tracking-tight mb-1">{res.subtitle}</p>
              <p className="text-[11px] text-slate-500 line-clamp-2 leading-relaxed">{res.description}</p>
            </div>
          </div>
        ))}
      </div>
    </motion.div>
  );
};

interface RatingListScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
  setFacultyContext: (c: 'teachers' | 'buildings') => void;
}

const RatingListScreen = ({ setScreen, setFacultyContext }: RatingListScreenProps) => {
  const [activeTab, setActiveTab] = useState('Оқытушылар');
  
  const getTopData = () => {
    switch (activeTab) {
      case 'Оқытушылар': return TOP_TEACHERS;
      case 'Пәндер': return TOP_SUBJECTS;
      case 'Корпустар': return TOP_BUILDINGS;
      case 'Студенттік өмір': return TOP_STUDENT_LIFE;
      default: return TOP_TEACHERS;
    }
  };

  const getTitle = () => {
    switch (activeTab) {
      case 'Оқытушылар': return 'Үздік 10 оқытушы';
      case 'Пәндер': return 'Үздік 10 пән';
      case 'Корпустар': return 'Үздік 10 корпус';
      case 'Студенттік өмір': return 'Үздік 10 санат';
      default: return 'Үздік 10 оқытушы';
    }
  };

  const getButtonText = () => {
    switch (activeTab) {
      case 'Оқытушылар': return 'Оқытушыларды бағалау арқылы университет сапасын жақсартуға үлес қосыңыз';
      case 'Пәндер': return 'Пәндерді бағалау арқылы оқу бағдарламасын жақсартуға үлес қосыңыз';
      case 'Корпустар': return 'Корпустарды бағалау арқылы университет жағдайын жақсартуға үлес қосыңыз';
      case 'Студенттік өмір': return 'Студенттік өмірді бағалау арқылы университет ортасын жақсартуға үлес қосыңыз';
      default: return 'Оқытушыларды бағалау арқылы университет сапасын жақсартуға үлес қосыңыз';
    }
  };

  const topData = getTopData();

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
      <Header title="Абай университеті" />
      
      <div className="px-4 sticky top-[68px] bg-white/80 backdrop-blur-md z-30 border-b border-slate-50">
        <div className="flex gap-6 overflow-x-auto no-scrollbar pt-2">
          {['Оқытушылар', 'Пәндер', 'Корпустар', 'Студенттік өмір'].map(tab => (
            <button 
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`pb-3 text-sm font-bold whitespace-nowrap transition-all relative ${activeTab === tab ? 'text-primary' : 'text-slate-400'}`}
            >
              {tab}
              {activeTab === tab && <motion.div layoutId="activeTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary rounded-full" />}
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 flex justify-between items-center">
        <h3 className="text-lg font-bold text-slate-900">{getTitle()}</h3>
        <span className="bg-primary/10 text-primary text-[10px] font-bold px-3 py-1 rounded-full uppercase tracking-wider">АПТАЛЫҚ РЕЙТИНГ</span>
      </div>

      <div className="px-4 space-y-3">
        {topData.map((t, idx) => (
          <div key={t.id} className={`bg-white rounded-2xl p-4 border border-slate-50 shadow-sm flex items-center gap-4 ${idx === 0 ? 'ring-2 ring-primary/10' : ''}`}>
            <div className="relative shrink-0">
              <img src={t.image} alt={t.name} className={`size-14 rounded-full object-cover ${idx === 0 ? 'border-2 border-primary/20' : ''}`} />
              <div className={`absolute -bottom-1 -right-1 size-6 rounded-full flex items-center justify-center text-[10px] font-bold border-2 border-white ${idx === 0 ? 'bg-secondary text-yellow-900' : 'bg-slate-100 text-slate-500'}`}>
                {idx + 1}
              </div>
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex justify-between items-start">
                <h4 className="font-bold text-slate-900 truncate pr-2">{t.name}</h4>
                {idx === 0 && <TrendingUp size={16} className="text-secondary" />}
              </div>
              <p className="text-[10px] text-slate-500 font-medium mb-1">{t.faculty}</p>
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-1 text-secondary">
                  <Star size={12} fill="currentColor" />
                  <span className="text-xs font-bold">{t.rating}</span>
                </div>
                <span className="text-[10px] text-slate-400 font-medium">{t.reviews} бағалау</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="px-4 mt-8 mb-6">
        <div className="bg-primary rounded-3xl p-8 text-white text-center shadow-xl shadow-primary/20">
          <h3 className="text-xl font-bold mb-2">Өз пікіріңізді қалдырыңыз</h3>
          <p className="text-white/70 text-sm mb-6 leading-relaxed">{getButtonText()}</p>
          <button 
            onClick={() => {
              if (activeTab === 'Оқытушылар') setScreen('faculties');
              else if (activeTab === 'Пәндер') setScreen('subjects-list');
              else if (activeTab === 'Корпустар') {
                setFacultyContext('buildings');
                setScreen('faculties');
              }
              else if (activeTab === 'Студенттік өмір') setScreen('student-life-categories');
            }}
            className="bg-white text-primary font-bold px-10 py-3 rounded-2xl active:scale-95 transition-transform"
          >
            Бағалау
          </button>
        </div>
      </div>
    </motion.div>
  );
};

interface ProfileScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
}

const ProfileScreen = ({ setScreen }: ProfileScreenProps) => {
  const [isDarkMode, setIsDarkMode] = useState(false);

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-32">
      <Header title="Менің профилім" />
      
      {/* Profile Info */}
      <div className="p-6 flex flex-col items-center">
        <div className="relative mb-4">
          <div className="size-24 rounded-full border-4 border-primary/10 overflow-hidden">
            <img src="https://picsum.photos/seed/user123/200/200" alt="User" className="w-full h-full object-cover" />
          </div>
          <div className="absolute -bottom-1 -right-1 bg-primary text-white p-1.5 rounded-full border-2 border-white">
            <Award size={14} />
          </div>
        </div>
        <div className="text-center">
          <h2 className="text-xl font-bold text-slate-900">Асқар Бексұлтан</h2>
          <p className="text-sm text-slate-500 font-medium">Студент • ID: 21B030456</p>
          <div className="mt-2 inline-flex items-center gap-1.5 bg-primary/5 text-primary px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider">
            <CheckCircle2 size={12} />
            Верификацияланған
          </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="px-4 grid grid-cols-3 gap-3 mb-8">
        <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex flex-col items-center">
          <span className="text-xl font-bold text-primary">24</span>
          <span className="text-[9px] font-bold text-slate-400 uppercase tracking-tight">Бағалаулар</span>
        </div>
        <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex flex-col items-center">
          <span className="text-xl font-bold text-primary">1,250</span>
          <span className="text-[9px] font-bold text-slate-400 uppercase tracking-tight">Ұпайлар</span>
        </div>
        <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex flex-col items-center">
          <span className="text-xl font-bold text-primary">#12</span>
          <span className="text-[9px] font-bold text-slate-400 uppercase tracking-tight">Рейтинг</span>
        </div>
      </div>

      {/* Achievements Section */}
      <div className="px-4 mb-8">
        <h3 className="text-sm font-bold text-slate-900 mb-4 flex items-center gap-2">
          <Award size={18} className="text-primary" />
          Жетістіктер
        </h3>
        <div className="flex gap-4 overflow-x-auto no-scrollbar pb-2">
          {[
            { title: 'Белсенді', icon: '🔥', color: 'bg-orange-100' },
            { title: 'Әділ сыншы', icon: '⚖️', color: 'bg-blue-100' },
            { title: 'Топ-100', icon: '🏆', color: 'bg-yellow-100' },
            { title: 'Алғашқы пікір', icon: '✨', color: 'bg-purple-100' },
          ].map((item, i) => (
            <div key={i} className="flex flex-col items-center shrink-0">
              <div className={`size-14 rounded-2xl ${item.color} flex items-center justify-center text-2xl mb-2 shadow-sm`}>
                {item.icon}
              </div>
              <span className="text-[10px] font-bold text-slate-600">{item.title}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Menu Options */}
      <div className="px-4 space-y-2">
        <h3 className="text-sm font-bold text-slate-900 mb-4 flex items-center gap-2">
          <Settings size={18} className="text-primary" />
          Баптаулар
        </h3>
        
        <div className="bg-white rounded-2xl border border-slate-50 shadow-sm overflow-hidden">
          <button className="w-full p-4 flex items-center justify-between hover:bg-slate-50 transition-colors border-b border-slate-50">
            <div className="flex items-center gap-3">
              <div className="size-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
                <History size={18} />
              </div>
              <span className="text-sm font-medium text-slate-700">Пікірлер тарихы</span>
            </div>
            <ChevronRight size={18} className="text-slate-300" />
          </button>

          <div className="w-full p-4 flex items-center justify-between border-b border-slate-50">
            <div className="flex items-center gap-3">
              <div className="size-8 rounded-lg bg-indigo-50 text-indigo-600 flex items-center justify-center">
                {isDarkMode ? <Moon size={18} /> : <Sun size={18} />}
              </div>
              <span className="text-sm font-medium text-slate-700">Түнгі режим</span>
            </div>
            <button 
              onClick={() => setIsDarkMode(!isDarkMode)}
              className={`w-10 h-6 rounded-full transition-colors relative ${isDarkMode ? 'bg-primary' : 'bg-slate-200'}`}
            >
              <div className={`absolute top-1 size-4 bg-white rounded-full transition-all ${isDarkMode ? 'right-1' : 'left-1'}`} />
            </button>
          </div>

          <button className="w-full p-4 flex items-center justify-between hover:bg-slate-50 transition-colors border-b border-slate-50">
            <div className="flex items-center gap-3">
              <div className="size-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <HelpCircle size={18} />
              </div>
              <span className="text-sm font-medium text-slate-700">Көмек және қолдау</span>
            </div>
            <ChevronRight size={18} className="text-slate-300" />
          </button>

          <button className="w-full p-4 flex items-center justify-between hover:bg-red-50 transition-colors group">
            <div className="flex items-center gap-3">
              <div className="size-8 rounded-lg bg-red-50 text-red-600 flex items-center justify-center group-hover:bg-red-100">
                <LogOut size={18} />
              </div>
              <span className="text-sm font-medium text-red-600">Шығу</span>
            </div>
          </button>
        </div>
      </div>

      {/* Footer Info */}
      <div className="mt-8 px-4 text-center">
        <p className="text-[10px] text-slate-400 font-medium uppercase tracking-widest">Abai Feedback App v1.2.4</p>
        <p className="text-[10px] text-slate-300 mt-1">© 2026 Abai University. Барлық құқықтар қорғалған.</p>
      </div>
    </motion.div>
  );
};

interface SubjectsListScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
  setSelectedSubject: (s: string) => void;
}

const SubjectsListScreen = ({ setScreen, setSelectedSubject }: SubjectsListScreenProps) => {
  const [searchQuery, setSearchQuery] = useState('');
  const filteredSubjects = SUBJECTS.filter(s => 
    s.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
    s.category.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
      <Header title="Пәндер" onBack={() => setScreen('home')} />
      <div className="p-6 pb-2">
        <h2 className="text-3xl font-bold tracking-tight">Пәндерді бағалау</h2>
        <p className="text-slate-500 mt-2 text-sm">Университеттегі оқу бағдарламасы мен пәндер сапасын бағалаңыз</p>
      </div>

      <div className="px-4 py-4 sticky top-[68px] bg-white/80 backdrop-blur-md z-30">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input 
            className="w-full bg-slate-100 border-none rounded-xl py-3 pl-10 pr-4 focus:ring-2 focus:ring-primary text-sm" 
            placeholder="Пән атауын іздеу..." 
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      <div className="px-4 space-y-4">
        {filteredSubjects.map(sub => (
          <div key={sub.id} className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-4">
            <div className="size-16 rounded-xl overflow-hidden shrink-0">
              <img src={sub.image} alt={sub.title} className="w-full h-full object-cover" />
            </div>
            <div className="flex-1">
              <h3 className="font-bold text-slate-900 leading-tight mb-1">{sub.title}</h3>
              <div className="flex items-center gap-2">
                <span className="text-[10px] bg-slate-100 text-slate-500 px-2 py-0.5 rounded font-bold uppercase">{sub.category}</span>
                <div className="flex items-center gap-1">
                  <Star size={10} className="text-secondary fill-secondary" />
                  <span className="text-[10px] text-slate-400 font-bold">{sub.rating}</span>
                </div>
              </div>
            </div>
            <button 
              onClick={() => {
                setSelectedSubject(sub.title);
                setScreen('subject-rating');
              }}
              className="bg-primary/10 text-primary px-4 py-2 rounded-lg text-xs font-bold active:scale-95 transition-transform"
            >
              Бағалау
            </button>
          </div>
        ))}
        {filteredSubjects.length === 0 && (
          <div className="py-12 text-center">
            <p className="text-slate-400">Ештеңе табылмады</p>
          </div>
        )}
      </div>
    </motion.div>
  );
};

interface TeachersScreenProps {
  key?: string;
  setScreen: (s: Screen) => void;
}

const TeachersScreen = ({ setScreen }: TeachersScreenProps) => {
  const [searchQuery, setSearchQuery] = useState('');
  const filteredTeachers = TEACHERS.filter(t => 
    t.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
    t.department.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pb-24">
      <Header title="Оқытушылар" onBack={() => setScreen('faculties')} />
      <div className="px-4 py-4 sticky top-[68px] bg-white/80 backdrop-blur-md z-30">
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input 
            className="w-full bg-slate-100 border-none rounded-xl py-3 pl-10 pr-4 focus:ring-2 focus:ring-primary text-sm" 
            placeholder="Оқытушының атын жазыңыз..." 
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
          <button className="px-4 py-2 bg-primary text-white rounded-full text-xs font-bold whitespace-nowrap">Филология факультеті</button>
          <button className="px-4 py-2 bg-slate-100 text-slate-600 rounded-full text-xs font-bold whitespace-nowrap">Математика</button>
          <button className="px-4 py-2 bg-slate-100 text-slate-600 rounded-full text-xs font-bold whitespace-nowrap">Тарих</button>
        </div>
      </div>

      <div className="px-4 py-2">
        <h3 className="font-bold text-lg">Нәтижелер</h3>
        <p className="text-xs text-slate-400">Барлығы {filteredTeachers.length} оқытушы табылды</p>
      </div>

      <div className="p-4 space-y-4">
        {filteredTeachers.map(t => (
          <div key={t.id} className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
            <div className="flex items-center gap-4">
              <img src={t.image} alt={t.name} className="size-16 rounded-full object-cover border-2 border-primary/10" />
              <div className="flex-1">
                <h4 className="font-bold text-slate-900">{t.name}</h4>
                <p className="text-xs text-slate-500">{t.department}</p>
              </div>
            </div>
            <div className="mt-4 pt-4 border-t border-slate-50 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="bg-secondary/10 text-yellow-700 px-2 py-1 rounded flex items-center gap-1">
                  <Star size={14} fill="currentColor" />
                  <span className="text-sm font-bold">{t.rating}</span>
                </div>
                <span className="text-xs text-slate-400">/ 10</span>
              </div>
              <span className="text-xs text-slate-500 font-medium">{t.reviews} пікір</span>
              <button onClick={() => setScreen('teacher-rating')} className="bg-primary/10 text-primary px-4 py-1.5 rounded-lg text-xs font-bold">Профиль</button>
            </div>
          </div>
        ))}
      </div>
    </motion.div>
  );
};

interface RatingScreenProps {
  key?: string;
  type: 'teacher' | 'subject' | 'building' | 'student-life';
  setScreen: (s: Screen) => void;
  faculty?: string;
  buildingCategory?: string;
  studentLifeCategory?: string;
  clubName?: string;
  subjectName?: string;
}

const RatingScreen = ({ type, setScreen, faculty, buildingCategory, studentLifeCategory, clubName, subjectName }: RatingScreenProps) => {
  const [rating, setRating] = useState(8);
  
  return (
    <motion.div initial={{ y: 50, opacity: 0 }} animate={{ y: 0, opacity: 1 }} exit={{ y: 50, opacity: 0 }} className="pb-32">
      <Header title="Бағалау" onBack={() => {
        if (type === 'building') setScreen('building-categories');
        else if (type === 'student-life' && clubName) setScreen('clubs-list');
        else if (type === 'student-life') setScreen('student-life-categories');
        else if (type === 'subject') setScreen('subjects-list');
        else setScreen('home');
      }} />
      
      {type === 'teacher' && (
        <div className="p-6 flex flex-col items-center">
          <img src="https://picsum.photos/seed/prof/200/200" alt="Prof" className="size-32 rounded-full border-4 border-primary/10 mb-4 object-cover" />
          <div className="text-center">
            <h2 className="text-2xl font-bold">Ахметов Бақытжан</h2>
            <p className="text-slate-500 font-medium">Филология факультеті</p>
            <p className="text-sm text-slate-400">Қазақ тілі мен әдебиеті кафедрасы</p>
          </div>
        </div>
      )}

      {type === 'building' && (
        <div className="p-6">
          <h3 className="text-2xl font-bold mb-1">{buildingCategory || 'Асхананы'} бағалау</h3>
          <p className="text-slate-500 text-sm flex items-center gap-1">
            <MapPin size={14} /> {faculty || 'Бас корпус'} • Институт
          </p>
        </div>
      )}

      {type === 'subject' && (
        <div className="p-6">
          <h3 className="text-2xl font-bold mb-1">{subjectName || 'Пәнді'} бағалау</h3>
          <p className="text-slate-500 text-sm">Оқу бағдарламасы мен оқыту сапасын бағалаңыз</p>
        </div>
      )}

      {type === 'student-life' && (
        <div className="p-6">
          <h3 className="text-2xl font-bold mb-1">{clubName || studentLifeCategory || 'Студенттік өмірді'} бағалау</h3>
          <p className="text-slate-500 text-sm">Университеттегі белсенділік пен жағдайды бағалаңыз</p>
        </div>
      )}

      {type === 'student-life' && (
        <div className="flex flex-wrap gap-x-8 gap-y-6 p-6 bg-slate-50 mb-6">
          <div className="flex flex-col gap-1">
            <p className="text-slate-900 text-5xl font-black tracking-tighter">4.5</p>
            <div className="flex gap-0.5 text-secondary">
              {[1, 2, 3, 4, 5].map(i => <Star key={i} size={18} fill={i <= 4 ? 'currentColor' : 'none'} className={i <= 4 ? '' : 'text-slate-300'} />)}
            </div>
            <p className="text-slate-500 text-sm font-medium mt-1">1,250 студент бағалады</p>
          </div>
          <div className="grid min-w-[140px] flex-1 grid-cols-[20px_1fr_40px] items-center gap-y-2">
            {[5, 4, 3].map(val => (
              <React.Fragment key={val}>
                <p className="text-slate-600 text-xs font-bold">{val}</p>
                <div className="flex h-1.5 flex-1 overflow-hidden rounded-full bg-slate-200">
                  <div className="rounded-full bg-primary" style={{ width: val === 5 ? '65%' : val === 4 ? '20%' : '10%' }}></div>
                </div>
                <p className="text-slate-500 text-xs font-normal text-right">{val === 5 ? '65%' : val === 4 ? '20%' : '10%'}</p>
              </React.Fragment>
            ))}
          </div>
        </div>
      )}

      {type !== 'student-life' && (
        <div className="px-4 grid grid-cols-2 gap-3 mb-8">
          <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex flex-col items-center">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Орташа баға</span>
            <div className="flex items-baseline gap-1">
              <span className="text-2xl font-bold text-primary">8.2</span>
              <span className="text-slate-400 text-sm">/10</span>
            </div>
          </div>
          <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex flex-col items-center">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Бағалау саны</span>
            <span className="text-2xl font-bold text-slate-900">124</span>
          </div>
        </div>
      )}

      <div className="px-4 mb-8">
        <div className="flex justify-between items-center mb-4">
          <h3 className="font-bold text-lg">Өз бағаңызды қойыңыз</h3>
          <span className="bg-primary text-white text-sm font-bold px-3 py-1 rounded-full">{rating}.0</span>
        </div>
        <input 
          type="range" min="1" max="10" value={rating} 
          onChange={(e) => setRating(parseInt(e.target.value))}
          className="w-full h-2 bg-slate-200 rounded-full appearance-none accent-primary cursor-pointer" 
        />
        <div className="flex justify-between mt-2 text-[10px] font-bold text-slate-300">
          <span>1</span><span>5</span><span>10</span>
        </div>
      </div>

      <div className="px-4 mb-8">
        <h3 className="font-bold text-lg mb-4">Кері байланыс</h3>
        <div className="flex flex-wrap gap-2">
          {['Түсінікті түсіндіреді', 'Қызықты өтеді', 'Өте қатал', 'Әділетсіз бағалайды', 'Тамақ дәмді', 'Тазалық'].map(tag => (
            <button key={tag} className="px-4 py-2 rounded-full border border-slate-200 text-slate-600 text-sm font-medium hover:bg-primary/10 hover:border-primary hover:text-primary transition-colors">
              {tag}
            </button>
          ))}
        </div>
      </div>

      <div className="px-4 mb-8">
        <h3 className="font-bold text-lg mb-4">Пікір (міндетті емес)</h3>
        <textarea className="w-full h-32 p-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-primary/20 text-sm" placeholder="Өз пікіріңізді осында қалдырыңыз..." />
      </div>

      <div className="fixed bottom-24 left-0 right-0 max-w-md mx-auto p-4">
        <button className="w-full bg-primary text-white font-bold py-4 rounded-2xl shadow-xl shadow-primary/20 flex items-center justify-center gap-2 active:scale-95 transition-transform">
          <ShieldCheck size={20} />
          Анонимді бағалау
        </button>
        <p className="text-center text-[10px] text-slate-400 mt-2 uppercase tracking-tighter">Сіздің жеке басыңыз құпия сақталады</p>
      </div>
    </motion.div>
  );
};

// --- Main App ---

export default function App() {
  const [screen, setScreen] = useState<Screen>('home');
  const [facultyContext, setFacultyContext] = useState<'teachers' | 'buildings'>('teachers');
  const [selectedFaculty, setSelectedFaculty] = useState<string>('');
  const [selectedBuildingCategory, setSelectedBuildingCategory] = useState<string>('');
  const [selectedStudentLifeCategory, setSelectedStudentLifeCategory] = useState<string>('');
  const [selectedClub, setSelectedClub] = useState<string>('');
  const [selectedSubject, setSelectedSubject] = useState<string>('');

  return (
    <div className="min-h-screen bg-bg-light flex justify-center">
      <div className="w-full max-w-md bg-white min-h-screen shadow-2xl relative overflow-x-hidden">
        <AnimatePresence mode="wait">
          {screen === 'home' && <HomeScreen key="home" setScreen={setScreen} setFacultyContext={setFacultyContext} />}
          {screen === 'search' && <SearchScreen key="search" setScreen={setScreen} />}
          {screen === 'rating-list' && <RatingListScreen key="rating-list" setScreen={setScreen} setFacultyContext={setFacultyContext} />}
          {screen === 'profile' && <ProfileScreen key="profile" setScreen={setScreen} />}
          {screen === 'faculties' && <FacultyScreen key="faculties" setScreen={setScreen} context={facultyContext} setSelectedFaculty={setSelectedFaculty} />}
          {screen === 'building-categories' && <BuildingCategoriesScreen key="building-categories" setScreen={setScreen} faculty={selectedFaculty} setSelectedBuildingCategory={setSelectedBuildingCategory} />}
          {screen === 'student-life-categories' && <StudentLifeCategoriesScreen key="student-life-categories" setScreen={setScreen} setSelectedStudentLifeCategory={setSelectedStudentLifeCategory} />}
          {screen === 'clubs-list' && <ClubsListScreen key="clubs-list" setScreen={setScreen} setSelectedClub={setSelectedClub} />}
          {screen === 'subjects-list' && <SubjectsListScreen key="subjects-list" setScreen={setScreen} setSelectedSubject={setSelectedSubject} />}
          {screen === 'teachers' && <TeachersScreen key="teachers" setScreen={setScreen} />}
          {screen === 'teacher-rating' && <RatingScreen key="t-rating" type="teacher" setScreen={setScreen} />}
          {screen === 'subject-rating' && <RatingScreen key="s-rating" type="subject" setScreen={setScreen} subjectName={selectedSubject} />}
          {screen === 'building-rating' && <RatingScreen key="b-rating" type="building" setScreen={setScreen} faculty={selectedFaculty} buildingCategory={selectedBuildingCategory} />}
          {screen === 'student-life-rating' && <RatingScreen key="sl-rating" type="student-life" setScreen={setScreen} studentLifeCategory={selectedStudentLifeCategory} clubName={selectedClub} />}
        </AnimatePresence>
        
        <BottomNav current={screen} setScreen={setScreen} />
      </div>

      {/* Background Decoration */}
      <div className="fixed inset-0 -z-10 opacity-5 pointer-events-none">
        <div className="absolute top-0 left-0 w-1/2 h-1/2 bg-primary blur-[120px] rounded-full" />
        <div className="absolute bottom-0 right-0 w-1/2 h-1/2 bg-secondary blur-[120px] rounded-full" />
      </div>
    </div>
  );
}

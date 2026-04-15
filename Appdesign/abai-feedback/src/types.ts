import React from 'react';

export type Screen = 'home' | 'search' | 'rating-list' | 'profile' | 'faculties' | 'teachers' | 'subjects-list' | 'building-categories' | 'student-life-categories' | 'clubs-list' | 'teacher-rating' | 'subject-rating' | 'building-rating' | 'student-life-rating';

export interface Category {
  id: string;
  title: string;
  rating: number;
  reviews: string;
  image: string;
  screen: Screen;
}

export interface Faculty {
  id: string;
  name: string;
  type: string;
  icon: string;
}

export interface Teacher {
  id: string;
  name: string;
  department: string;
  rating: number;
  reviews: number;
  image: string;
  description?: string;
}

export interface SearchResult {
  id: string;
  title: string;
  rating: number;
  type: 'teacher' | 'subject' | 'building';
  subtitle: string;
  description: string;
  icon: React.ReactNode;
}

export interface Activity {
  id: string;
  category: string;
  time: string;
  text: string;
  type: 'comment' | 'rating';
}

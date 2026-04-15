-- Seed Data for Buildings
INSERT INTO buildings (name, category, image_url)
VALUES 
    ('Бас корпус - Асхана', 'Food & Dining', 'https://picsum.photos/seed/canteen/200/200'),
    ('Бас корпус - Кітапхана', 'Study Space', 'https://picsum.photos/seed/library/200/200'),
    ('№1 Оқу ғимараты - Коворкинг', 'Study Space', 'https://picsum.photos/seed/cowork/200/200'),
    ('Спорт кешені - Жаттығу залы', 'Fitness', 'https://picsum.photos/seed/gym/200/200'),
    ('Бас корпус - Конференц-зал', 'Events', 'https://picsum.photos/seed/hall/200/200');

-- Seed Data for Student Life Items
INSERT INTO student_life_items (name, description, image_url)
VALUES 
    ('Іс-шаралар', 'University Cultural and Educational Events', 'https://picsum.photos/seed/events/200/200'),
    ('Жатақхана өмірі', 'Campus Dormitory Quality and Life', 'https://picsum.photos/seed/dorm/200/200'),
    ('Атмосфера', 'General Campus Vibe and Inclusion', 'https://picsum.photos/seed/atmos/200/200'),
    ('Студенттік жеңілдіктер', 'Local and Campus Discounts for Students', 'https://picsum.photos/seed/discounts/200/200');

-- Seed Data for Clubs
INSERT INTO clubs (name, category, image_url)
VALUES 
    ('Дебат клубы', 'Science & Logic', 'https://picsum.photos/seed/debate/200/200'),
    ('Би үйірмесі', 'Art & Dance', 'https://picsum.photos/seed/dance/200/200'),
    ('IT & Robotics', 'Technology', 'https://picsum.photos/seed/robot/200/200'),
    ('Волонтерлер ұйымы', 'Social', 'https://picsum.photos/seed/vol/200/200');

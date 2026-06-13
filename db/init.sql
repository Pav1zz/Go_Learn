CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  email         TEXT UNIQUE NOT NULL,
  password      TEXT NOT NULL,
  xp            INT DEFAULT 0,
  streak        INT DEFAULT 0,
  last_activity DATE,
  username      TEXT,
  bio           TEXT,
  country       TEXT,
  avatar_color  TEXT DEFAULT '#00d4a0',
  role          TEXT NOT NULL DEFAULT 'user',
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);  

CREATE TABLE IF NOT EXISTS lessons (
  id         SERIAL PRIMARY KEY,
  title      TEXT NOT NULL,
  theory     TEXT NOT NULL,
  question   TEXT NOT NULL,
  options    JSONB NOT NULL,
  answer     INT NOT NULL,
  difficulty TEXT DEFAULT 'easy',
  category   TEXT DEFAULT 'Основы',
  xp_reward  INT DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS progress (
  id         SERIAL PRIMARY KEY,
  user_id    INT REFERENCES users(id) ON DELETE CASCADE,
  lesson_id  INT REFERENCES lessons(id) ON DELETE CASCADE,
  is_correct BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--  SEED LESSONS

-- Урок 1
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Переменные в Go',
  'В Go переменные объявляются двумя способами: через ключевое слово `var` или через короткое объявление `:=`. Например: `var x int = 5` или `x := 5`. Второй способ работает только внутри функций.',
  'Как правильно объявить переменную в Go?',
  '["let x = 5","var x int","x = int"]'::jsonb,
  1, 'easy', 'Основы', 10
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 1);

-- Урок 2
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Типы данных',
  'В Go есть несколько базовых типов данных: `int` — целые числа, `float64` — числа с плавающей точкой, `string` — текстовые строки, `bool` — логические значения (true/false). Go — строго типизированный язык, типы нельзя смешивать без явного приведения.',
  'Какой тип данных хранит текст в Go?',
  '["int","string","bool"]'::jsonb,
  1, 'easy', 'Основы', 10
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 2);

-- Урок 3
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Функции в Go',
  'Функции в Go объявляются с помощью ключевого слова `func`. Пример: `func add(a int, b int) int { return a + b }`. Функции могут возвращать несколько значений — это уникальная особенность Go. Например: `func divide(a, b int) (int, error)`.',
  'Какое ключевое слово используется для объявления функции?',
  '["function","def","func"]'::jsonb,
  2, 'easy', 'Основы', 10
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 3);

-- Урок 4
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Циклы в Go',
  'В Go есть только один вид цикла — `for`. Но он очень гибкий. Обычный цикл: `for i := 0; i < 10; i++ {}`. Цикл как while: `for x < 100 {}`. Бесконечный цикл: `for {}`. Также есть `range` для перебора коллекций: `for i, v := range slice {}`.',
  'Какой цикл существует в Go?',
  '["while","for","foreach"]'::jsonb,
  1, 'easy', 'Основы', 10
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 4);

-- Урок 5
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Массивы и слайсы',
  'Массив в Go имеет фиксированный размер: `var arr [5]int`. Слайс — более гибкая структура: `s := []int{1, 2, 3}`. Слайсы можно расширять через `append`: `s = append(s, 4)`. Функция `len(s)` возвращает длину, `cap(s)` — ёмкость.',
  'Как добавить элемент в слайс?',
  '["s.push(4)","append(s, 4)","s.add(4)"]'::jsonb,
  1, 'medium', 'Основы', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 5);

-- Урок 6
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Горутины',
  'Горутины — это лёгкие потоки выполнения в Go. Запустить горутину просто: добавь `go` перед вызовом функции: `go myFunc()`. Горутины намного легче системных потоков — можно запустить тысячи одновременно. Для общения между горутинами используются каналы (`chan`).',
  'Как запустить горутину?',
  '["thread myFunc()","async myFunc()","go myFunc()"]'::jsonb,
  2, 'medium', 'Горутины', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 6);

-- Урок 7
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Структуры (struct)',
  'Структуры в Go позволяют группировать данные: `type Person struct { Name string; Age int }`. Создание: `p := Person{Name: "Alice", Age: 30}`. К полям обращаются через точку: `p.Name`. Методы можно прикреплять к структурам: `func (p Person) Greet() string { return "Hello, " + p.Name }`.',
  'Как называется тип для группировки данных в Go?',
  '["class","object","struct"]'::jsonb,
  2, 'medium', 'Типы', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 7);

-- Урок 8
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Интерфейсы',
  'Интерфейс в Go — это набор методов. Тип автоматически реализует интерфейс, если у него есть все нужные методы. Пример: `type Animal interface { Sound() string }`. Любая структура с методом `Sound()` реализует этот интерфейс. Это называется утиной типизацией.',
  'Как тип реализует интерфейс в Go?',
  '["Через ключевое слово implements","Автоматически если есть нужные методы","Через наследование"]'::jsonb,
  1, 'hard', 'Типы', 30
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 8);

-- Урок 9
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Указатели в Go',
  'Указатель хранит адрес переменной в памяти. Объявление: `var p *int`. Получить адрес: `p = &x`. Получить значение по указателю: `*p`. Указатели позволяют изменять переменную внутри функции: `func increment(n *int) { *n++ }`.',
  'Какой символ используется для получения адреса переменной?',
  '["*","&","@"]'::jsonb,
  1, 'medium', 'Основы', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 9);

-- Урок 10
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Обработка ошибок',
  'В Go нет исключений. Ошибки возвращаются как второе значение функции: `result, err := divide(10, 0)`. Проверка: `if err != nil { return err }`. Создать ошибку: `errors.New("что-то пошло не так")` или `fmt.Errorf("ошибка: %w", err)`.',
  'Как в Go принято обрабатывать ошибки?',
  '["try/catch блоками","Через возвращаемое значение","Через глобальный обработчик"]'::jsonb,
  1, 'medium', 'Основы', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 10);

-- Урок 11
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Каналы (channels)',
  'Каналы — основной способ общения между горутинами. Создание: `ch := make(chan int)`. Отправка: `ch <- 42`. Получение: `value := <-ch`. Буферизованный канал: `ch := make(chan int, 10)` — не блокирует пока буфер не заполнен.',
  'Как создать канал в Go?',
  '["channel int","make(chan int)","new(chan int)"]'::jsonb,
  1, 'hard', 'Горутины', 30
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 11);

-- Урок 12
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Maps (словари)',
  'Map — коллекция пар ключ-значение. Создание: `m := make(map[string]int)` или `m := map[string]int{"one": 1}`. Добавить: `m["key"] = value`. Удалить: `delete(m, "key")`. Проверить наличие: `val, ok := m["key"]`.',
  'Как проверить существует ли ключ в map?',
  '["m.has(key)","val, ok := m[key]","m.contains(key)"]'::jsonb,
  1, 'medium', 'Основы', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 12);

-- Урок 13
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Defer',
  '`defer` откладывает выполнение функции до момента возврата из текущей функции. Часто используется для закрытия ресурсов: `defer file.Close()`. Если несколько defer — выполняются в обратном порядке (LIFO). Очень удобно для очистки ресурсов.',
  'В каком порядке выполняются несколько defer?',
  '["В прямом порядке","В обратном порядке (LIFO)","Одновременно"]'::jsonb,
  1, 'medium', 'Основы', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 13);

-- Урок 14
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Panic и Recover',
  '`panic` останавливает выполнение программы — используй только в критических ситуациях. `recover` позволяет перехватить панику и продолжить работу. Recover работает только внутри defer: `defer func() { if r := recover(); r != nil { fmt.Println("recovered") } }()`.',
  'Где можно использовать recover?',
  '["В любом месте кода","Только внутри defer","Только в main()"]'::jsonb,
  1, 'hard', 'Основы', 30
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 14);

-- Урок 15
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Пакеты и импорты',
  'Каждый файл Go принадлежит пакету: `package main`. Импорт пакетов: `import "fmt"`. Несколько импортов: `import ( "fmt"; "os" )`. Публичные функции начинаются с заглавной буквы: `func MyFunc()`. Приватные — со строчной: `func myFunc()`.',
  'Как сделать функцию публичной в Go?',
  '["Добавить слово public","Начать имя с заглавной буквы","Добавить слово export"]'::jsonb,
  1, 'easy', 'Основы', 10
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 15);

-- Урок 16
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Работа со строками',
  'Пакет `strings` содержит много полезных функций: `strings.Contains(s, "Go")`, `strings.ToUpper(s)`, `strings.Split(s, ",")`, `strings.TrimSpace(s)`. Конкатенация: `s1 + s2`. Форматирование: `fmt.Sprintf("Hello, %s!", name)`. Длина строки в байтах: `len(s)`.',
  'Какой пакет содержит функции для работы со строками?',
  '["strutil","strings","string"]'::jsonb,
  1, 'easy', 'Основы', 10
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 16);

-- Урок 17
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Методы структур',
  'К структуре можно прикреплять методы. Метод с value receiver: `func (p Person) Name() string { return p.Name }` — работает с копией. Метод с pointer receiver: `func (p *Person) SetName(n string) { p.Name = n }` — изменяет оригинал. Pointer receiver нужен когда метод изменяет структуру.',
  'Когда нужно использовать pointer receiver?',
  '["Всегда","Когда метод изменяет структуру","Никогда"]'::jsonb,
  1, 'hard', 'Типы', 30
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 17);

-- Урок 18
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'Работа с файлами',
  'Чтение файла: `data, err := os.ReadFile("file.txt")`. Запись: `os.WriteFile("file.txt", data, 0644)`. Открыть файл: `f, err := os.Open("file.txt")`, не забудь `defer f.Close()`. Пакет `os` содержит все необходимые функции для работы с файловой системой.',
  'Какой пакет используется для работы с файлами в Go?',
  '["io","file","os"]'::jsonb,
  2, 'medium', 'Стандартная библиотека', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 18);

-- Урок 19
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'HTTP сервер на Go',
  'Go имеет встроенный пакет `net/http`. Простой сервер: `http.HandleFunc("/", handler)` и `http.ListenAndServe(":8080", nil)`. Обработчик: `func handler(w http.ResponseWriter, r *http.Request) { fmt.Fprintf(w, "Hello!") }`. Go отлично подходит для создания веб-серверов.',
  'Какой пакет используется для HTTP сервера в Go?',
  '["http","web","net/http"]'::jsonb,
  2, 'hard', 'Веб', 30
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 19);

-- Урок 20
INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
SELECT
  'JSON в Go',
  'Пакет `encoding/json` позволяет работать с JSON. Сериализация: `data, err := json.Marshal(obj)`. Десериализация: `err := json.Unmarshal(data, &obj)`. Теги структур управляют именами полей: `json:"name"`. Пропустить пустые поля: `json:"name,omitempty"`.',
  'Какой пакет используется для работы с JSON в Go?',
  '["json","encoding/json","go/json"]'::jsonb,
  1, 'medium', 'Стандартная библиотека', 20
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE id = 20);

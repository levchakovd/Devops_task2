#!/bin/bash

# Проверяем, передан ли аргумент (путь к файлу output.txt)
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <output.txt>"
    exit 1
fi

# Сохраняем путь к файлу output.txt в переменной
input_file="$1"

# Используем Python для обработки и конвертации данных
python3 - <<END
import re
import json

# Читаем содержимое файла output.txt
with open('$input_file', 'r') as f:
    lines = f.readlines()

# Инициализируем переменные для хранения результатов
results = {}
success = 0
failed = 0

# Обрабатываем каждую строку файла
for line in lines:
    # Если строка содержит символ "[" (начало теста)
    if '[' in line:
        # Извлекаем имя теста из квадратных скобок
        test_name = re.search(r'\[(.*)\]', line).group(1).strip()
        # Сохраняем имя теста в результирующей структуре
        results["testName"] = test_name
        # Инициализируем список тестов
        results["tests"] = []
    # Если строка содержит "ok" (результат теста)
    elif 'ok' in line:
        # Извлекаем части строки, используя регулярное выражение
        parts = re.search(r'^([^0-9]*)([0-9]+)(.*),(.*)ms$', line).groups()
        # Определяем статус теста (успешно/неуспешно)
        status = False if 'not' in parts[0] else True
        # Увеличиваем счетчик успешных или неуспешных тестов
        if status:
            success += 1
        else:
            failed += 1
        # Создаем структуру данных для теста
        test = {
            "name": parts[2].strip(),
            "status": status,
            "duration": parts[3].strip() + "ms"
        }
        # Добавляем тест в список тестов
        results["tests"].append(test)

# Рассчитываем рейтинг успешных тестов
rating = round(success / (success + failed) * 100, 2)
# Если рейтинг целое число, преобразуем его в int
if rating == int(rating):
    rating = int(rating)

# Добавляем общий итог в результирующую структуру
results["summary"] = {
    "success": success,
    "failed": failed,
    "rating": rating,
    "duration": lines[-1].split()[-1]
}

# Записываем результат в файл output.json с отступами в виде табуляции
with open('output.json', 'w') as f:
    json.dump(results, f, indent='\t')

# Выводим сообщение об успешном завершении
print("Conversion completed. Output written to output.json.")
END


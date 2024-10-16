#!/usr/bin/env bash

# Тестовый скрипт для проверки архиватора
# Проверка на наличие аргументов
if [ "$#" -lt 2 ]; then
echo "ERROR - Not enough arguments. Enter: size of disk and file size"
exit 1
fi
# Параметры
log_dir="./log"
main_dir="./backup"
test_file_size_mb="${2:-50}" # Размер каждого файла в МБ

# Создание раздела диска
function create_disk() {
    local size_of_disk="$1"
    ./create_vd_script.sh "$size_of_disk"
}

# Очистка старых данных перед началом тестов
clean() {
    echo "Cleaning directories $log_dir & $main_dir..."
    rm -rf "$log_dir" "$main_dir"
    mkdir -p "$log_dir" "$main_dir"
    echo "SUCCESS - Directories are cleaned up"
}

# Очистка последнего созданного диска
function delete_disk() {
    local file_to_delete=$(ls -t virtual_disk* 2>/dev/null | head -n 1)
    local file_to_delete_no_extension=$(basename "$file_to_delete" | cut -d. -f1)
    echo "Cleaning up the virtual disk $file_to_delete..."

    # Проверяем, есть ли файлы для удаления
    if [ -z "$file_to_delete" ]; then
        echo "No file to be deleted."
    else
        ./delete_vd_script.sh "$file_to_delete_no_extension"
    fi
}

# Генерация файлов в папке /log
function generate_data() {
    local folder_size_mb="$1"
    local file_count=$((folder_size_mb / test_file_size_mb))
    echo "Generation $file_count files $test_file_size_mb МБ each in the $log_dir directory..."

    for i in $(seq 1 "$file_count"); do
        # Генерируем файл заданного размера
        dd if=/dev/zero of="$log_dir/logfile$i.log" bs=1M count="$test_file_size_mb" status=none
        sleep 0.1
    done
}

# Функция для запуска основного скрипта и проверки результатов
run_test() {
    local threshold="$1"
    local n_files="${2:-5}"
    echo "Starting test: max = $threshold%, archieve $n_files files"

    # Запуск основного скрипта
    ./main_script.sh "$log_dir" "$threshold" "$n_files"
    # Проверка результатов
    local archived_files=$(tar -tzf "$main_dir"/*.tar.gz 2> /dev/null | wc -l)
    local remaining_files=$(ls "$log_dir" | wc -l)

    echo "SUCCESS - Files archieved: $archived_files"
    echo "SUCCESS - Files remaining: $remaining_files"
}

# Основная функция для тестов
run_tests() {
    # Тест 0: Проверка корректной работы
    echo "Test 0: Check of the correct accomplishment"
    create_disk 1024 # 1,5 ГБ
    generate_data 500
    run_test 30 20

    # Очистка после теста
    clean
    delete_disk

    # Тест 1: Проверка архивирования при превышении порога, архивирование 10 файлов
    echo "Test 1: Checking archiving when the threshold is exceeded"
    create_disk 1024 # 1 ГБ
    generate_data 900
    run_test 80 10

    # Очистка после теста
    clean
    delete_disk

    # Тест 2: Нет архивации при нормальной заполненности
    echo "Test 2: No archiving at normal occupancy"
    create_disk 5120 # 5 ГБ
    generate_data 2000
    run_test 50 20

    # Очистка после теста
    clean
    delete_disk

    # Тест 3: Проверка корректной работы без аргументов
    echo "Test 3: Checking the correct operation without arguments"
    create_disk 1024 # 1 ГБ
    generate_data folder_size_mb=600
    run_test 50

    # Очистка после теста
    clean
    delete_disk

    # Тест 4: Проверка корректной работы при параметре N > количество файлов
    echo "Test 4: Checking the correct operation with the parameter N > number of files"
    create_disk 1536 # 1,5 ГБ
    generate_data folder_size_mb=1200
    run_test 70 50

    # Очистка после теста
    clean
    delete_disk


}

# Запуск тестов
clean
run_tests


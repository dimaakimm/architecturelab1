#!/usr/bin/env bash

# Проверка на наличие аргументов
if [ "$#" -lt 2 ]; then
echo "ERROR - Not enough arguments. Enter: $0 <path to dir> <precentage of fullness> [number of files to be archieved]"
exit 1
fi

# Переменные
log_dir="$1"
limit="$2"
count="${3:-3}" # По умолчанию архивируем 3 файлов, если N не указано
backup_dir="$HOME/backup_laba"

# Поиск последнего созданного виртуального диска (файл-образ)
if [ -n "$(ls disk*.img 2>/dev/null)" ]; then
  img_file=$(ls -t disk*.img 2>/dev/null | head -n 1)
else
  echo "ERROR - The virtual disk image file was not found: $img_file"
  exit 1
fi

# Проверка на существование папки
if [ ! -d "$log_dir" ]; then
  echo "Directory $log_dir does not exist"
  exit 1
fi

# Создание папки для архивации, если её не существует
if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir"
fi

# Получаем размер папки в байтах суммирование всех файлов в папке
folder_size=$(du -sb "$log_dir" 2>/dev/null | awk '{print $1}')
echo "Size of the directory $log_dir: $folder_size bytes"



# Получаем размер виртуального раздела в байтах
total_space=$(du -b "$img_file" | awk '{print $1}')

# Вычисляем процент заполненности папки относительно виртуального раздела
folder_usage_percent=$(echo "scale=2; 100 * $folder_size / $total_space" | bc)
echo "Directory is full by $folder_usage_percent%"


# Если процент заполненности превышает введенный порог, архивируем и удаляем count самых старых файлов в зависимости от даты модификации
if [ $(echo "$folder_usage_percent > $limit" | bc) -eq 1 ]; then
  echo "Fullness is over $limit%. Archiving $count oldest files..."

  old_files=$(ls -t "$log_dir" | head -n $count)

  # Проверка что есть файлы для архивирования
  if [ -z "$old_files" ]; then
    echo "No files to archieve"
    exit 0
  fi

  # Создаем архив
  archive_name="$backup_dir/archive_$(date +%Y%m%d_%H%M%S).tar.gz"
  tar -czf "$archive_name" -C "$log_dir" $old_files

  # Проверяем, был ли создан архив
  if [ $? -eq 0 ]; then
    echo "SUCCESS - Files are archieved into $archive_name"

    echo "Удаляем заархивированные файлы..."
    for file in $old_files; do
      sudo rm -rf "$log_dir/$file"
      echo "SUCCESS - File deleted: $file"
    done
  else
    echo "ERROR - Archieve was not initialized"
    exit 1
  fi

else
  echo "Fullness is not over $limit%. No need in archivation"
  echo "The end."
  exit 0
fi

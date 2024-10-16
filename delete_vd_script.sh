#!/usr/bin/env bash

# Проверка наличия аргумента
if [ "$#" -ne 1 ]; then
    echo "ERROR - Please type a directory to delete as an argument"
    exit 1
fi

# Переменные
img_file="$HOME/backup_laba/$1.img" # Путь к файлу-образу виртуального диска
mounted_dir="$HOME/backup_laba/$1" # Определяем точку монтирования из пути к файлу


# Размонтирование виртуального диска
echo "Unmounting virtual disk from $mounted_dir..."
sudo umount "$mounted_dir"
if [ $? -eq 0 ]; then
    echo "SUCCESS - Virtual disk is unmounted"
else
    echo "ERROR - Error while unmounting vireual disk"
fi

# Удаление файла-образа
echo "Удаляем файл-образ виртуального диска: $img_file..."
rm "$img_file"
if [ $? -eq 0 ]; then
    echo "SUCCESS - Virtual disk image is deleted"
else
    echo "ERROR - Error while deleting virtual disk image file"
fi

# Удаление директории
rm -r "$mounted_dir"
if [ $? -eq 0 ]; then
    echo "SUCCESS - The directory is deleted"
else
    echo "ERROR - The directory is not deleted"
fi

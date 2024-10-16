#!/usr/bin/env bash

# Создаем виртуальный раздел с уникальным именем на основе текущей даты и времени
date_time=$(date +%Y%m%d_%H%M%S)
img_file="$HOME/backup_laba/disk_$date_time.img"
mount_dir="$HOME/backup_laba/disk_$date_time"

# Размер в МБ, можно передавать параметром
size_mb=${1:-1000}

# Создаем виртуальный раздел (файл-образ)
echo "Creating virtul disk with a size of ${size_mb} MB..."
dd if=/dev/zero of=$img_file bs=1M count=$size_mb

# Форматируем файл как ext4
echo "Formating virtual disk into a file system ext4..."
mke2fs -t ext4 -F "$img_file" > /dev/null 2>&1

# Создаем директорию для монтирования, если она не существует
echo "Creating a directory to mount..."
mkdir -p $mount_dir

# Монтируем через sudo mount
echo "Mounting using command sudo mount..."
sudo mount "$img_file" "$mount_dir" 
 
echo "SUCCESS - Virtual disk is mounted in $mount_dir"


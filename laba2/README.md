**Лабораторная работа №2**
==========================
*Задание 1 (Установка ОС и настройка LVM, RAID)*
-------------------------------------------------
1. Создаем виртуальную машину, выдав ей следующие характеристики: 

* 1 gb ram
* 1 cpu
* 2 hdd - ssd1 и ssd2, с равным размером и возможностью горячей замены
* SATA контроллер настроен на 4 порта

![изображение 1](https://i.imgur.com/oznSpNL.png)

2. Далее нужно добавить и настроить RAID и LVM, чтобы конечный результат получился таким:

![изображение 2](https://i.imgur.com/hmKhtWi.png)

3. Устанавливаем  grub на первое устройство, загружаем систему и копируем раздел /boot с sda на sdb, с помощью `dd if=/dev/sda1 of=/dev/sdb1`:

![изображение 3](https://i.imgur.com/DXctZ6n.png)

4. Просматриваем диски в системе `lsblk`, получается два hdd диска - sda и sdb:

![изображение 4](https://i.imgur.com/mrIeZ95.png)

5. Устанавливаем grub на второе устройство `grub-install /dev/sdb` и с помощью `cat /proc/mdstat` просматриваем, что RAID-массив проинициализирован корректно, так как в этом файле отражается его текущее состояние:

![изображение 5](https://i.imgur.com/MZ21qBr.png)

Также с помощью некоторых команд можно узнать: 
* pvs - информацию о физическом томе;
* lvs - информацию о логическом томе;
* vgs - информацию о группе физических томов;
* mount - просмотр примонтированных устройств.

***Результат проделанного задания - я создал виртуальную машину с двумя дисками, настроил LVM и RAID.***



Задание 2 (Эмуляция отказа одного из дисков)
--------------------------------------------

1. Так как я поставил галочку в hot swap, то мне доступно удаление дисков на лету. Поэтому я удаляю диск ssd1 из свойств машины и все файлы связанные с ним (ssd1.vmdk). С помощью перезагрузки нужно убедиться, что все работает. 

2. Проверяю статус RAID-массива при помощи `cat /proc/mdstat`:

![изображение2.1](https://i.imgur.com/aGocepf.png)

3. Добавляю новый диск ssd3 такого же размера.

![изображение2.2](https://i.imgur.com/yi5Nif9.png)

4. С помощью команды `fdisk -l` проверяю, что новый диск приехал:

![изображение 2.3](https://i.imgur.com/32p5KFa.png)

5. Копирую таблицу разделов со старого диска на новый при помощи  `sfdisk -d /dev/sda | sfdisk /dev/sdb`:

![изображение 2.4](https://i.imgur.com/pooUeJm.png)

6. Просматриваю результат при помощи команды fdisk -l:

![изображение 2.5](https://i.imgur.com/ZlZv3MM.png)

7. Добавляю в RAID-массив новый диск при помощи  `mdadm -manage /dev/md0 -add /dev/sdb` и просматриваю результат  `cat /proc/mdstat`:

![изображение 2.6](https://i.imgur.com/cQ9yJLy.png)

8. Теперь я вручную выполняю синхронизацию разделов, которые не входят в RAID. Для этого я использую утилиту dd, которая выполняет копирование данных из одного места в другое. Копируем с "живого" диска на новый.  `dd if=/dev/sda1 of=/dev/sdb1`:

![изображение 2.7](https://i.imgur.com/wwhmDm2.png)

9. Выполняю перезагрузку, чтобы убедиться, что все работает.

***Результат проделанного задания - я проэмулировал отказ одного из дисков, сохранил диск ssd2 и добавил новый диск ssd3***



Задание 3 (Добавление новых дисков и перенос раздела)
---------------------------------------------------------------
1. Проэмулирую отказ диска ssd2, удаляю все из свойств машины и перезагружаюсь, с помощью lsblk -o просматриваю что получилось:

![изображение 3.1](https://i.imgur.com/eWogfiG.png)

2. Добавляю новый диск ssd4 и смотрю что произошло  `lsblk -o`:

![изображение 3.2](https://i.imgur.com/QE62k82.png)

3. Так как все может полететь к чертям, то на этот раз данные буду переносить с помощью LVM. Поэтому копируем файловую таблицу со старого диска на новый `sfdisk -d /dev/sda | sfdisk /dev.sdb`:


![изображение 3.3](https://i.imgur.com/RF91zbN.png)

4. Теперь выполняю команду  `lsblk -o` и замечаю, что по сравнению с прошлым выводом данной команды, сейчас на новом диске sdb появились разделы sdb1 и sdb2. А далее копирую данные /boot на новый диск  `dd if=/dev/sda1 of=/dev/sdb1`:

![изображение 3.4](https://i.imgur.com/TInOiGL.png)

5. Устанавливаю загрузчик на новый диск  `grub-install /dev/sdb` потому что он загружает ОС и этот загрузчик нужен на новом диске после удаления старого, без него ничего не получится. После этого создаю рейд-массив с включением туда только одного нового ssd диска  `mdadm --level=1 --raid-devices=1 /dev/sdb2` и с помощью команды `cat /proc/mdstat` проверяю, что  установлен новый RAID-массив md63:

![изображение 3.5](https://i.imgur.com/h5TcTs3.png)

6. Настройка Logical Volume Manager. Создаю новый физический том и включаю в него недавно созданный RAID-массив `pvcreate /dev/md63` и проверяю это все командой `lsbls -o`:

![изображение 3.6](https://i.imgur.com/M1cVD5R.png)

7. При выполнении LV var, log, root видим, что находятся они на физическом диске sda:

![изображение 3.7](https://i.imgur.com/HScQsJh.png)

8. Теперь нужно выполнить перемещение данный со старого диска на новый `pvmove -i 10 -n /dev/system/root /dev/md0 /dev/md63`:

![изображение 3.8](https://i.imgur.com/pyajsF4.png)

9. Далее надо проверить все ли данные ходятся на одном диске, делаю это при помощи `lvs -a -o+devices` и `lsblk -o`:

![изображение 3.9](https://i.imgur.com/QXfoEai.png)

10. Изменяю Volume Group, удаляя из него диск старого raid и обязательно проверяю что раздел /boot не пустой:

![изображение 3.10](https://i.imgur.com/EWBiHT8.png)

11. Теперь я удаляю ssd3 и добавляю ssd5, hdd1, hdd2. По идее должно получиться:
* ssd4 - первый новый ssd
* ssd5 - второй новый ssd 
* hdd1 - первый новый hdd
* hdd2 - второй новый hdd
С помощью `lsblk -o` проверяем:

![изображение 3.11](https://i.imgur.com/LzbsSxp.png)

Диски появились!

12. Перехожу к восстанавлению работы основного RAID-массива. Выполняю копирование таблицы разделов и оказывается, что новый размер не использует весь объем жесткого диска. Поэтому в скором времени придется изменить размер этого раздела и расширить raid, видно это при использовании команды `lsblk -o`:

![изображение 3.12](https://i.imgur.com/LQ6pp8i.png)

13. Копирую загрузочный раздел /boot с диска ssd4 на ssd5 `dd if=/dev/sda1 of=/dev/sdb1` и сразу же установлю grub на новый диск ssd5 `grub install /dev/sdb`:

![изображение 3.13](https://i.imgur.com/sUqGrrc.png)

14. Сначала меняю размер второго раздела диска ssd5 (sdb), а потом перечитываю таблицу разделов `partx -u /dev/sdb` и получаю такой результат `lsblk -o`:

![изображение 3.14](https://i.imgur.com/9O9QyAR.png)

15. Теперь я добавляю новый диск к текущему raid-массиву `mdadm --manage /dev/md127 --add /dev/sdb2`, расширяю количество дисков в массиве до 2-х штук `mdadm --grow /dev/md127 --raid-devices=2`, и просматриваю результат `lsblk -o`:

![изображение 3.15](https://i.imgur.com/1jHaSqG.png)

16. Теперь увеличиваю размер раздела на диске ssd4, перечитываю таблицу разделов `partx -u /dev/sda` и в результате получаю разделы sda2 и sdb2, у которых размер больше, чем размер raid-устройства:

![изображение 3.16](https://i.imgur.com/225AA96.png)

17. И вот настал момент расширения raid-массива `mdadm --grow /dev/md127 --size=max`, просматриваю при помощи `lsblk -o`:

![изображение 3.17](https://i.imgur.com/EbKDZFp.png)

Хоть я и изменил размер raid, сами размеры vg root, log, var не изменились. При помощи команды `pvs` смотрю чему равен PV, расширяю его размер `pvresize /dev/md127` и вновь при помощи `pvs` смотрю чему равен размер PV:

![изображение 3.18](https://i.imgur.com/FWUJD2n.png)

Увеличили объем памяти ssd4, ssd5

18. ДОбавляю вновь появившееся место VG var, root используя `lvextend -l +50%FREE /dev/system/root` и `lvextend -l +100%FREE /dev/system/var`, при помощи `lvs` смотрю результат:

![изображение 3.19](https://i.imgur.com/vrUoDVe.png)

На этом этапе завершена миграция основного массива на новые диски. Работа с ssd1, ssd2 закончена.

19. Следующая задача - переместить `/var/log` на новые диски, для этого создаю raid-массив `mdadm --create /dev/md127 --level1 --raid-devices=2 /dev/sdc dev/sdd`, создаю новый PV на рейде из больших дисков `pvcreate data /dev/md127`, создаю в этом PV группу с названием data `vgcreate data /dev/md127`, создаю логический том размеров всего свободного пространства и называю его val_log `lvcreate -l 100%FREE -n var_log data`, форматирую созданные разделы в ext4 `mkfs.ext4 /dev/mapper/data-var_log` и наконец смотрим результат `lsblk`:

![изображение 3.20](https://i.imgur.com/JbiI3Wk.png)

20. Настало время переноса данных логов со старого раздела на новый. Поэтому примонтирую временное новое хранилище логов `mount /dev/mapper/data-var-log /mnt`, выполню синхронизацию разделов `apt install rsync   rsync -avzr /var/log/ /mnt/`, выясняю какие процессы работают сейчас с /var/log `apt install lsof   lsof | grep '/var/log`, останавливаю все эти процессы `systemctl stop rsyslog.service syslog.socket`, выполняю синхронизацию разделов `rsyns -avzr /var/log /mnt/`, меняю местами разделы `umount /mnt   umount /var/log   mount /dev/mapper/data-var_log /var/log` и наконец проверяю что получилось:

![изображение 3.21](https://i.imgur.com/arEJBb2.png)

21. Правлю /etc/fstab - это файл, в котором записываются правила, по которым при загрузке будут смонтированы разделы. Ищу ту строку, в которой монтируется /var/log и поправляю устройства `system-log` на `data-var_log` и использую команду `resize2fs` для изменения ФС:

![изображение 3.22](https://i.imgur.com/3GUd1d8.png)

22. И НАКОНЕЦ-ТО ВЫПОЛНЯЕМ ПЕРЕЗАГРУЗКУ, А ЗАТЕМ ПРОВЕРКУ, ЧТО ВСЕ, ЧТО ХОТЕЛ АЛЕКСАНДР СЕРГЕЕВИЧ СДЕЛАНО!!!!!!!

![изображение 3.23](https://i.imgur.com/stJhtlf.png)

***Результат проделанного задания - замена дисков на лету, добавление новых дисков и переносы разделов***

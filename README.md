# staff
## b24_comment.exe  
	Принимаемые аргументы: 
* /P - Путь к существующему файлу шаблонов, либо путь куда необходимо сохранить новый. Пример С:\filename.st
* /T - Токен битрикс 24
* /U - ID пользователя битрикс 24. Используется для отбора задач
* /S - Обабатываемые ключи замены. Принимает строку разделенную запятыми
* /N - Имя разработчика для конфигуратора. Будет подставлено при создании нового шаблона

### НЕ РЕКОМЕНДУЕТСЯ УКАЗЫВАТЬ В ПАРАМЕТРЕ /Р ПОЛЬЗОВАТЕЛЬСКИЙ ФАЙЛ ШАБЛОНОВ
## Предпочтительнее создать новый файл при первом запуске и работать с ним

Пример использования: 
```powershell
PS E:\git\staff> oscript.exe .\КомментарииПодЗадачи.os /P '.\test\test.st' /T "3d361t7rgvn5guqk" /U "13583" /S "коммент" /N 'Нечуй Левицкий'
``` - запуск скрипта из исходников
```
```powershell
PS E:\git\staff> .\b24_comment /P '.\test\test.st' /T "3d361t7rgvn5guqk" /U "13783" /S "коммент" /N 'Нечуй Левицкий'
``` - запуск собранного .ехе

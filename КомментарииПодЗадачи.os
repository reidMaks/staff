﻿//TODO:
// * Настройка параметров адреса ресурса
// * Добавление выбора к существующему файлу. Пример = параметром передана ключевая фраза "/+" - 
//							осуществим поиск по ключевому слову - обновим блок выбора/добавим в случае отсутствия 
// * Добавить возможность формировать шаблон Описания из полей задачи в битрикс

#Использовать cmdline
#Использовать restler

Перем ИмяФайлаШаблона;
Перем юсПарсер;
Перем юсПараметры;

Процедура ЗадатьНачальныеНастройки()
	юсПарсер = Новый ПарсерАргументовКоманднойСтроки();
	
	
	Если АргументыКоманднойСтроки.Количество() = 0 Тогда
		юсСообщить("ERROR", "Не заданы аргументы командной строки!");
		
		юсСообщить("INFO", "Принимаемые аргументы: ");
		юсСообщить("*", "/P - Путь к существующему файлу шаблонов, либо путь куда необходимо сохранить новый. Пример С:\filename.st");
		юсСообщить("*", "/T - Токен битрикс 24");
		юсСообщить("*", "/U - ID пользователя битрикс 24. Используется для отбора задач");
		
		ЗавершитьРаботу(1);
	КонецЕсли;
	ЗаполнитьПараметры();
КонецПроцедуры

Процедура ЗаполнитьПараметры()
	Завершить = Ложь;
	юсПарсер.ДобавитьИменованныйПараметр("/P"); // Путь к файлу шаблонов
	юсПарсер.ДобавитьИменованныйПараметр("/T"); // Токен битрикс 24
	юсПарсер.ДобавитьИменованныйПараметр("/U"); // ID пользователя битрикс 24
	
	юсПараметры = юсПарсер.Разобрать(АргументыКоманднойСтроки);
	
	//Проверка значений
	
	Если ТипЗнч(юсПараметры["/U"]) <> Тип("Строка") Тогда
		юсСообщить("ERROR", "Не задано значение аргумента /U командной строки!");
		Завершить = Истина;
	КонецЕсли;
	Если ТипЗнч(юсПараметры["/T"]) <> Тип("Строка") Тогда
		юсСообщить("ERROR", "Не задано значение аргумента /T командной строки!");
		Завершить = Истина;
	КонецЕсли;
	Если ТипЗнч(юсПараметры["/P"]) <> Тип("Строка") Тогда
		юсСообщить("ERROR", "Не задано значение аргумента /P командной строки!");
		Завершить = Истина;
	КонецЕсли;
	
	Если Завершить Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
КонецПроцедуры

Процедура юсСообщить(ТипСообщения, ТекстСообщения)
	
	ТекстСообщения = "[" + ТекущаяДата() + "] " + "[" + ТипСообщения + "] " + ТекстСообщения;
	
	
	Сообщить(ТекстСообщения);
	
	
КонецПроцедуры

Процедура ПолучитьСтрокуЗадач() // &filter[REAL_STATUS]=5
	юсСообщить("INFO", "Получаю задачи из bitrix 24");
	Токен = юсПараметры["/T"]; // 3d361t7rnvn5guqk
	ID = юсПараметры["/U"]; // 13083	
	
	Соединение = Новый HTTPСоединение("https://b24.esteam.band", 443);
	
	Клиент = Новый КлиентВебAPI();
	Клиент.ИспользоватьСоединение(Соединение);
	Запрос = "/rest/13083/" + Токен + "/tasks.task.list?filter[RESPONSIBLE_ID]=" + ID + "&filter[REAL_STATUS]=5&select[0]=ID&select[1]=TITLE";
	Результат = Клиент.Получить(Запрос);
	
	БлокЗамены = "<?""""Шо за задача?"""", ВыборВарианта";
	Для каждого Элемент Из Результат["result"]["tasks"] Цикл
		БлокЗамены = БлокЗамены + ", " + """""" + Элемент["title"] + """""" + ", " + """""" + Элемент["id"] + """""";
	КонецЦикла;
	БлокЗамены = БлокЗамены + ">";
	
	юсПараметры.Вставить("блок", БлокЗамены);
КонецПроцедуры

Функция НужноОбработатьСтроку(текСтрока)
	Если СтрНачинаетсяС(текСтрока, "{""Фрагмент добавлен"",")
		ИЛИ СтрНачинаетсяС(текСтрока, "{""Фрагмент удален"",")
		ИЛИ СтрНачинаетсяС(текСтрока, "{""Фрагмент ИЗМЕНЕН"",") Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции

Процедура ПолучитьФайлШаблона()
	ИмяФайлаШаблона = юсПараметры["/P"];
	Файл = Новый Файл(ИмяФайлаШаблона);
	Если Файл.Существует() Тогда
		ОбновитьШаблон();
	Иначе
		СоздатьНовыйФайлШаблона();
	КонецЕсли;
КонецПроцедуры
Процедура ОбновитьШаблон()
	юсСообщить("INFO", "Обновляю файл шаблонов");
	ИмяФайлаШаблона = юсПараметры["/P"];
	БлокЗамены = юсПараметры["блок"];
	
	ТекстДок = Новый ТекстовыйДокумент;
	ТекстДок.Прочитать(ИмяФайлаШаблона);
	Для а = 0 По ТекстДок.КоличествоСтрок() Цикл
		позицияНач = 0;
		КонецБлока = 0;
		текСтрока = ТекстДок.ПолучитьСтроку(а);
		Если НужноОбработатьСтроку(текСтрока) Тогда
			
			Пока СтрНайти(текСтрока, "<?", , позицияНач) <> 0 Цикл
				НачалоБлока = СтрНайти(текСтрока, "<?", , позицияНач);
				КонецБлока = СтрНайти(текСтрока, ">", , НачалоБлока);
				Если НачалоБлока = 0 ИЛИ КонецБлока = 1 Тогда
					позицияНач = КонецБлока;
					Продолжить;
				КонецЕсли;
				блок = Сред(текСтрока, НачалоБлока, КонецБлока - НачалоБлока + 1);
				Если СтрНайти(блок, " ВыборВарианта,") > 0 Тогда
					НоваяСтрока = СтрЗаменить(текСтрока, блок, БлокЗамены);
					ТекстДок.ЗаменитьСтроку(а, НоваяСтрока);
					Прервать;
				КонецЕсли;
				позицияНач = КонецБлока;
				
			КонецЦикла;
		КонецЕсли;
		
	КонецЦикла;
	
	ТекстДок.Записать(ИмяФайлаШаблона);
	юсСообщить("INFO", "Обновление завершено.");
КонецПроцедуры

Процедура СоздатьНовыйФайлШаблона()
	юсСообщить("INFO", "Файл не найден. Создаю новый файл шаблонов");
	ИмяФайлаШаблона = юсПараметры["/P"];
	БлокЗамены = юсПараметры["блок"];
	
	Текст = Новый ТекстовыйДокумент();
	Текст.ДобавитьСтроку("{1,");
	Текст.ДобавитьСтроку("{1,");
	Текст.ДобавитьСтроку("{""b24_comment"",1,0,"""",""""},");
	Текст.ДобавитьСтроку("{0,");
	Текст.ДобавитьСтроку("{""b24_comment"",0,1,""/+"",""//{[+] " + БлокЗамены + " EFSOL, Козлов Максим <?"""""""", ДатаВремя, """"ДЛФ=DT"""">");
	Текст.ДобавитьСтроку("<?>");
	Текст.ДобавитьСтроку("//}<?"""""""", ДатаВремя, """"ДЛФ=DT""""> EFSOL""}");
	Текст.ДобавитьСтроку("}");
	Текст.ДобавитьСтроку("}");
	Текст.ДобавитьСтроку("}");
	
	Текст.Записать(ИмяФайлаШаблона);
	
	юсСообщить("INFO", "Создан файл шаблона: " + ИмяФайлаШаблона);
КонецПроцедуры

ЗадатьНачальныеНастройки();
ПолучитьСтрокуЗадач();
ПолучитьФайлШаблона();
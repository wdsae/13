Процедура ОбработкаПроведения(Отказ,Режим)
	// регистр ОстаткиТоваров
	Перем ДанныеЗаполнения;
	Перем Запрос;
	Движения.ОстаткиТоваров.Записывать = Истина;
	Для Каждого ТекСтрокаТовары из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.Период = Дата;
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Количество = ТекСтрокаТовары.Количество;
		Движение.Выручка = ТекСтрокаТовары.Сумма;
	КонецЦикла;

   Движения.Записать();
   
   Если Режим = РежимПроведенияДокумента.Оперативный Тогда
   
   Запрос = Новый Запрос;
  	Запрос.Текст =
  	"ВЫБРАТЬ
  	|	ОстаткиТоваровОстатки.Номенклатура,
  	|	ОстаткиТоваровОстатки.КоличествоОстаток КАК Количество
  	|ИЗ
  	|	РегистрНакопления.ОстаткиТоваров.Остатки(, Номенклатура В
  	|		(ВЫБРАТЬ
  	|			РеализацияТоваровТовары.Номенклатура
  	|		ИЗ
  	|			Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
  	|		ГДЕ
  	|			РеализацияТоваровТовары.Ссылка = &Ссылка)) КАК ОстаткиТоваровОстатки
  	|ГДЕ
  	|	ОстаткиТоваровОстатки.КоличествоОстаток < 0";
  
  Запрос.УстановитьПараметр("Ссылка", Ссылка);
  
  РезультатЗапроса = Запрос.Выполнить();
  
  ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
  
  Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
  	Сообщить("По номенклатуре "+ВыборкаДетальныеЗаписи.Номенклатура+" остаток "+ВыборкаДетальныеЗаписи.Количество);
  КонецЦикла;
  
  КонецЕсли;
   
   Если Отказ Тогда
   	Возврат;
   КонецЕсли;
   
   
   Запрос = Новый Запрос;
   Запрос.Текст =
   	"ВЫБРАТЬ
   	|	ОстаткиТоваровОстатки.Номенклатура,
   	|	ОстаткиТоваровОстатки.КоличествоОстаток КАК Количество,
   	|	ОстаткиТоваровОстатки.СуммаОстаток КАК Сумма
   	|ИЗ
   	|	РегистрНакопления.ОстаткиТоваров.Остатки(&МоментВремени, Номенклатура В
   	|		(ВЫБРАТЬ
   	|			РеализацияТоваровТовары.Номенклатура
   	|		ИЗ
   	|			Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
   	|		ГДЕ
   	|			РеализацияТоваровТовары.Ссылка = &Ссылка)) КАК ОстаткиТоваровОстатки";
   
   Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
   Запрос.УстановитьПараметр("Ссылка", Ссылка);
   
   РезультатЗапроса = Запрос.Выполнить();
   
   ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
   
   Движения.ОстаткиТоваров.Записывать = Истина;
   Движения.Продажи.Записывать = Истина;
   
   Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
   	
   	Для Каждого Движение Из Движения.ОстаткиТоваров Цикл
   		
   		Если Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура Тогда
   			
   			Движение.Сумма = Движение.Количество * ВыборкаДетальныеЗаписи.Сумма/ВыборкаДетальныеЗаписи.Количество;
   			//@skip-warning
   			ДвижениеПродажи = Движение.Продажи.Добавить();
   			ДвижениеПродажи.Период = Дата;
   			ДвижениеПродажи.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
   			ДвижениеПродажи.Контрагент = Контрагент;
   			ДвижениеПродажи.Сумма = Движение.Выручка;
   			ДвижениеПродажи.Себестоимость = Движение.Сумма;
   			ДвижениеПродажи.Количество = Движение.Количество;
   	КонецЕсли;
   	КонецЦикла;
   	КонецЦикла;
   


	//@skip-warning
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ПоступлениеТоваров") Тогда
		// Заполнение шапки
		Контрагент = ДанныеЗаполнения.Контрагент;
		Ответственный = ДанныеЗаполнения.Ответственный;

		Для Каждого ТекСтрокаТовары из ДанныеЗаполнения.Товары Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Номенклатура = ТекСтрокаТовары.Номенклатура;
			НоваяСтрока.Количество = ТекСтрокаТовары.Количество;
			НоваяСтрока.Цена = ТекСтрокаТовары.Цена;
			НоваяСтрока.Сумма = ТекСтрокаТовары.Сумма;
		КонецЦикла;
	КонецЕсли;

	//}}__КОНСТРУКТОР_ВВОД_НА_ОСНОВАНИИ

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	СуммаДокумента = Товары.Итог("Сумма")
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	// Вставить содержимое обработчика.
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	

BuyUnlimitedChangelog = {
    ["1.0.3"] = {
        ["enUS"] = {
            "Added the display of any other currency in the main menu and the automatic purchase menu. And also how much total currency is needed to purchase the entire list specified in the automatic purchase menu.",
            "The logic of buying a product now applies to other products in a different currency, not just money.", 
            "The automatic purchase window has been expanded for the convenience of viewing product names, as well as the volume of all information displaying the currency of the goods included in the automatic purchase.",
            "Added logic for checking - numAvailable (the number of available items from the seller).",
            "Fixed a bug with individual items when using the «Auto-buy» button. When the items from the stack, due to the quick purchase of individual items (occupying a whole separate slot in the backpack), were not fully purchased. The logic of C_Timer now extends to them as well.",
            "Added the correct sorting of the display of builds in /bu fix. The correct sorting by name in the «Auto-buy» menu has also been added. Now the items in the «Auto-buy» menu will be sorted alphabetically according to the current localization of the game."
        },
        ["ruRU"] = {
            "Добавлено отображение любой другой валюты в главном меню и меню автоматической покупки. А также сколько общей валюты необходимо для покупки всего списка, указанного в меню автоматической покупки.",
            "Логика покупки товара теперь распространяется и на другие товары в другой валюте, а не только на деньги.", 
            "Окно автоматической покупки было расширено для удобства просмотра наименований товаров, а также объема всей информации отображения валюты товаров, включенных в автоматическую покупку.",
            "Добавлена логика для проверки - numAvailable (количества доступных товаров у продавца).",
            "Исправлена ошибка с отдельными предметами при использовании кнопки Автопокупка. Когда предметы из стака, из-за быстрой покупки отдельных предметов (занимающих целый отдельный слот в рюкзаке), не были куплены полностью. Логика C_Timer теперь распространяется и на них.",
            "Добавлена правильная сортировка отображения билдов в /bu fix. Также добавлена правильная сортировка по имени в меню Автопокупки. Теперь предметы в меню Автопокупки будут отсортированы по алфавиту в соответствии с текущей локализацией игры."
        }
    },    
    ["1.0.2"] = {
        ["enUS"] = {
            "Added the /bu and /bu fix command to view the changes.",
            "Fixed bugs with the purchase and «Auto-buy» of items/bags/quantities/time/delays.", 
            "An alert showing a timer until the end of the purchase will now appear smoothly once at the beginning of the purchase, remain on the screen without flickering during the process and disappear smoothly at the end. The notification was static before, and the animation logic was changed.",
            "Added a tooltip for displaying item information when hovering over any item in the «Auto-buy» menu.",
            "Added the purchase delay setting (C_Timer). The input field to the right of the «Auto-buy» button. The value range is from 0.1 to 5.0 seconds. The value is saved between game sessions. Instant application without the need for confirmation. Support for decimal numbers (e.g. 0.15)."
        },
        ["ruRU"] = {
            "Добавлена команда /bu и /bu fix для просмотра изменений.",
            "Исправлены баги с покупкой и автопокупкой предметов/сумки/количества/времени/задержки.", 
            "Оповещение, показывающее таймер до конца покупки, теперь будет появляться плавно один раз в начале покупки, оставаться на экране без мерцания во время процесса и плавно исчезать в конце. Оповещение до этого было статичным, была изменена логика анимации.",
            "Добавлен тултип отображения информации предмета при наведении курсора на любой предмет в меню «Автопокупки».",
            "Добавлена настройка задержки покупки (C_Timer). Поле ввода справа от кнопки «Автопокупка». Диапазон значений от 0.1 до 5.0 секунд. Значение сохраняется между сессиями игры. Мгновенное применение без необходимости подтверждения. Поддержка десятичных чисел (например, 0.15)."
        }
    },
    ["1.0.1"] = {
        ["enUS"] = {
            "Added visual purchase timer in raid-warning style, fixed 'Object is busy' error during rapid item purchases, added 0.20 second delay between purchases for stability, improved item stack purchase logic, added fade in/out animation for purchase timer, added remaining time display until purchase completion, fixed item quantity display in timer.",
            "Optimized purchase function to work correctly with server limitations, added recursive purchase function with delay, improved item stack size handling, added visual feedback for bulk purchases.",
            "If the item purchase is not completing fully, change the value of C_Timer.After(0.20, function() in two places in the BuyUnlimited.lua file to what works best for you. The optimal value is between 0.20-0.25.C_Timer.After(0.20, function()"
        },
        ["ruRU"] = {
            "Добавлен визуальный таймер покупки в стиле raid-предупреждения, исправлена ошибка «Объект занят» при быстрой покупке товара, добавлена задержка в 0,20 секунды между покупками для стабильности, улучшена логика покупки стека товаров, добавлена анимация постепенного увеличения/уменьшения времени для таймера покупки, добавлено отображение оставшегося времени до завершения покупки, исправлено отображение количества товара в таймере.",
            "Оптимизирована функция покупки для корректной работы с учетом ограничений сервера, добавлена функция рекурсивной покупки с задержкой, улучшена обработка размера стопки товаров, добавлена визуальная обратная связь для массовых покупок.",
            "Если покупка товара не завершена полностью, измените значение параметра C_Timer.After(0.20, function()) в двух местах в файле BuyUnlimited.lua на то, что лучше всего подходит для вас. Оптимальное значение находится в диапазоне 0,20–0,25. C_Timer.После(0,20, функция()"
        }
    },
    ["1.0.0"] = {
        ["enUS"] = {
            "Initial release"
        },
        ["ruRU"] = {
            "Первый релиз аддона"
        }
    }
}
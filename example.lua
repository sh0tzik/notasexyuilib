-- ===============================================
-- ПРИМЕР ИСПОЛЬЗОВАНИЯ BEAUTIFUL UI LIBRARY
-- ===============================================

-- Загрузка библиотеки
local Library = loadstring(game:HttpGet(""))()

-- Создание UI с Discord вебхуком (ЗАМЕНИ НА СВОЙ ВЕБХУК!)
local UI = Library:new("https://discord.com/api/webhooks/1234567890/abcdefghijklmnop", "users.json")

-- Получение информации о пользователе
local uid = UI:GetUID()
local userInfo = UI:GetUserInfo()
print("Добро пожаловать! Ваш UID:", uid)
print("Ранг:", userInfo.rank)

-- Добавление уведомления при запуске
UI:Notify("UI Library загружена! UID: #" .. uid, 3, "success")

-- ===============================================
-- СОЗДАНИЕ КОМПОНЕНТОВ
-- ===============================================

-- Переключатель для аимбота
local aimbotSwitch = UI:AddSwitch(20, 20, 60, 30, "Включить аимбот", function(value)
    UI:Notify("Аимбот " .. (value and "включен" or "выключен"), 2, value and "success" or "info")
end)

-- Ползунок для FOV
local aimbotSlider = UI:AddSlider(20, 60, 200, 20, 0, 100, 50, function(value)
    print("FOV установлен:", value)
end)

-- Переключатель для ESP
local espSwitch = UI:AddSwitch(20, 100, 60, 30, "Включить ESP", function(value)
    UI:Notify("ESP " .. (value and "включен" or "выключен"), 2, value and "success" or "info")
end)

-- Ползунок для скорости
local speedSlider = UI:AddSlider(20, 140, 200, 20, 16, 100, 16, function(value)
    print("Скорость установлена:", value)
end)

-- Кнопка сохранения
local saveButton = UI:AddButton(20, 180, 120, 35, "Сохранить", function()
    UI:Notify("Настройки сохранены!", 2, "success")
end)

-- Кнопка загрузки
local loadButton = UI:AddButton(150, 180, 120, 35, "Загрузить", function()
    UI:Notify("Настройки загружены!", 2, "success")
end)

-- Кнопка сброса
local resetButton = UI:AddButton(20, 220, 120, 35, "Сбросить", function()
    UI:Notify("Настройки сброшены!", 2, "warning")
end)

-- ===============================================
-- ОСНОВНОЙ ЦИКЛ
-- ===============================================

-- Переменные для мыши
local mouseX, mouseY = 0, 0
local mousePressed = false

-- Функции для получения позиции мыши (заглушки)
function GetMousePosition()
    return mouseX, mouseY
end

function IsMousePressed()
    return mousePressed
end

-- Основной цикл обновления
function Update()
    -- Обновление UI
    UI:Update(mouseX, mouseY, mousePressed)
    
    -- Рендер UI
    UI:Render(800, 600) -- Размер экрана
end

-- Запуск основного цикла
spawn(function()
    while true do
        Update()
        wait(1/60) -- 60 FPS
    end
end)

-- Отправка уведомления о входе в Discord
UI:SendDiscordNotification("login")

-- Симуляция движения мыши для демонстрации
spawn(function()
    while true do
        mouseX = mouseX + math.random(-5, 5)
        mouseY = mouseY + math.random(-5, 5)
        
        -- Ограничение координат
        mouseX = math.max(0, math.min(800, mouseX))
        mouseY = math.max(0, math.min(600, mouseY))
        
        wait(0.1)
    end
end)

-- Симуляция кликов мыши
spawn(function()
    while true do
        wait(math.random(2, 5))
        mousePressed = true
        wait(0.1)
        mousePressed = false
    end
end)

-- ===============================================
-- ДОПОЛНИТЕЛЬНЫЕ ПРИМЕРЫ
-- ===============================================

-- Переключение темы
function SwitchTheme()
    local themes = {"Dark", "Light", "Neon"}
    local currentTheme = 1
    
    return function()
        currentTheme = currentTheme % #themes + 1
        UI:SetTheme(themes[currentTheme])
        UI:Notify("Тема изменена на: " .. themes[currentTheme], 2, "info")
    end
end

-- Создание кнопки переключения темы
local themeButton = UI:AddButton(20, 260, 120, 35, "Сменить тему", SwitchTheme())

-- Функция для показа информации о пользователе
function ShowUserInfo()
    local userInfo = UI:GetUserInfo()
    if userInfo then
        UI:Notify("UID: #" .. userInfo.uid .. " | Ранг: " .. userInfo.rank, 5, "info")
    end
end

-- Создание кнопки информации
local infoButton = UI:AddButton(150, 260, 120, 35, "Информация", ShowUserInfo)

-- ===============================================
-- ПРИМЕР С РАЗНЫМИ ТИПАМИ УВЕДОМЛЕНИЙ
-- ===============================================

-- Функция для демонстрации уведомлений
function DemoNotifications()
    UI:Notify("Это информационное уведомление", 3, "info")
    
    wait(1)
    UI:Notify("Операция выполнена успешно!", 3, "success")
    
    wait(1)
    UI:Notify("Внимание! Проверьте настройки", 3, "warning")
    
    wait(1)
    UI:Notify("Произошла ошибка!", 3, "error")
end

-- Кнопка для демонстрации уведомлений
local demoButton = UI:AddButton(20, 300, 120, 35, "Демо уведомлений", DemoNotifications)

-- ===============================================
-- ПРИМЕР С АНИМАЦИЯМИ
-- ===============================================

-- Функция для демонстрации анимаций
function DemoAnimations()
    local animatedSwitch = UI:AddSwitch(20, 340, 60, 30, "Анимированный", function(value)
        print("Анимированный переключатель:", value)
    end)
    
    -- Анимация изменения позиции
    local startX = 20
    local endX = 200
    local duration = 2.0
    
    Library.CreateAnimation(startX, endX, duration, Easing.easeOutBack, function(value)
        animatedSwitch.x = value
    end)
end

-- Кнопка для демонстрации анимаций
local animationButton = UI:AddButton(150, 300, 120, 35, "Демо анимаций", DemoAnimations)

print("Beautiful UI Library загружена!")
print("Ваш UID:", UI:GetUID())
print("Ваш ранг:", UI:GetUserRank())

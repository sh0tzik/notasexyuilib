# Beautiful UI Library v1.1

Современная UI библиотека с анимациями, системой UID и Discord интеграцией.

## Getting Started

Для использования Beautiful UI Library, загрузите её через loadstring:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh0tzik/notasexyuilib/refs/heads/main/src.lua",true))()
```

Затем создайте экземпляр библиотеки:

```lua
local UI = Library:new("https://discord.com/api/webhooks/YOUR_WEBHOOK_URL", "users.json")
```

## Основные возможности

### 🆔 Система UID
Каждый пользователь получает уникальный номер по порядку регистрации:

```lua
-- Получение UID пользователя
local uid = UI:GetUID()
print("Ваш UID:", uid) -- Например: 1, 2, 3...

-- Получение информации о пользователе
local userInfo = UI:GetUserInfo()
print("Ранг:", userInfo.rank)
print("Дата регистрации:", userInfo.joinDate)
```

### 🎨 Система тем
Переключение между темами:

```lua
UI:SetTheme("Dark")   -- Темная тема (по умолчанию)
UI:SetTheme("Light")  -- Светлая тема
UI:SetTheme("Neon")   -- Неоновая тема
```

### 🔔 Уведомления
Красивые уведомления с разными типами:

```lua
UI:Notify("Операция выполнена!", 3, "success")
UI:Notify("Внимание!", 5, "warning")
UI:Notify("Ошибка!", 3, "error")
```

## Компоненты

### Переключатели (Switches)
Красивые переключатели с анимациями:

```lua
local switch = UI:AddSwitch(100, 100, 60, 30, "Включить функцию", function(value)
    print("Переключатель:", value)
end)
```

### Ползунки (Sliders)
Интерактивные ползунки для настройки значений:

```lua
local slider = UI:AddSlider(100, 150, 200, 20, 0, 100, 50, function(value)
    print("Значение:", value)
end)
```

### Кнопки (Buttons)
Красивые кнопки с hover эффектами:

```lua
local button = UI:AddButton(100, 200, 120, 35, "Нажми меня", function()
    print("Кнопка нажата!")
end)
```

## Полный пример

```lua
-- Загрузка библиотеки
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/beautiful-ui-library/main/Library.lua"))()

-- Создание UI с Discord вебхуком
local UI = Library:new("https://discord.com/api/webhooks/YOUR_WEBHOOK_URL", "users.json")

-- Получение информации о пользователе
local uid = UI:GetUID()
print("Добро пожаловать! Ваш UID:", uid)

-- Добавление уведомления
UI:Notify("UI Library загружена! UID: #" .. uid, 3, "success")

-- Создание компонентов
local aimbotSwitch = UI:AddSwitch(20, 20, 60, 30, "Включить аимбот", function(value)
    UI:Notify("Аимбот " .. (value and "включен" or "выключен"), 2, value and "success" or "info")
end)

local aimbotSlider = UI:AddSlider(20, 60, 200, 20, 0, 100, 50, function(value)
    print("FOV:", value)
end)

local saveButton = UI:AddButton(20, 100, 120, 35, "Сохранить", function()
    UI:Notify("Настройки сохранены!", 2, "success")
end)

-- Основной цикл
function Update()
    local mouseX, mouseY = GetMousePosition() -- ваша функция
    local mousePressed = IsMousePressed()     -- ваша функция
    
    UI:Update(mouseX, mouseY, mousePressed)
    UI:Render(screenWidth, screenHeight)
end
```

## Ранги пользователей

- **UID 1** - 👑 Основатель
- **UID 2-10** - ⭐ VIP
- **UID 11-100** - 🔥 Ранний пользователь
- **UID 101-1000** - 💎 Премиум
- **UID 1001+** - 👤 Пользователь

## Настройка Discord вебхука

1. Создайте вебхук в настройках Discord сервера
2. Скопируйте URL вебхука
3. Передайте его в конструктор UI:

```lua
local UI = Library:new("https://discord.com/api/webhooks/YOUR_WEBHOOK_URL", "users.json")
```

## API Reference

### Основные функции

| Функция | Описание |
|---------|----------|
| `Library:new(webhookUrl, databasePath)` | Создает новый экземпляр UI |
| `UI:AddSwitch(x, y, w, h, text, callback)` | Добавляет переключатель |
| `UI:AddSlider(x, y, w, h, min, max, value, callback)` | Добавляет ползунок |
| `UI:AddButton(x, y, w, h, text, callback)` | Добавляет кнопку |
| `UI:Notify(text, duration, type)` | Показывает уведомление |
| `UI:SetTheme(themeName)` | Устанавливает тему |

### UID функции

| Функция | Описание |
|---------|----------|
| `UI:GetUID()` | Получает UID пользователя |
| `UI:GetUserInfo()` | Получает информацию о пользователе |
| `UI:GetUserRank()` | Получает ранг пользователя |

### Типы уведомлений

- `"info"` - Информационное (по умолчанию)
- `"success"` - Успех (зеленый)
- `"warning"` - Предупреждение (оранжевый)
- `"error"` - Ошибка (красный)

## Особенности

- ✅ **Красивые анимации** - плавные переходы для всех компонентов
- ✅ **Система UID** - уникальные номера пользователей как в Discord
- ✅ **Discord интеграция** - уведомления в Discord сервер
- ✅ **Система тем** - легко переключать между темами
- ✅ **Без лагов** - оптимизированная производительность
- ✅ **Простота использования** - интуитивный API

## Лицензия

MIT License - используйте свободно в своих проектах!

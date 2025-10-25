-- ===============================================
-- BEAUTIFUL UI LIBRARY v1.0
-- Современная UI библиотека с анимациями и красивыми компонентами
-- ===============================================

local UI = {}
UI.__index = UI

-- ===============================================
-- КОНФИГУРАЦИЯ И НАСТРОЙКИ
-- ===============================================

UI.Config = {
    -- Основные настройки
    FPS = 60,
    AnimationSpeed = 0.15,
    EasingType = "easeOutQuart",
    
    -- Цвета по умолчанию
    Colors = {
        Primary = {0.2, 0.6, 1.0, 1.0},      -- Синий
        Secondary = {0.3, 0.3, 0.3, 1.0},   -- Серый
        Success = {0.2, 0.8, 0.2, 1.0},     -- Зеленый
        Warning = {1.0, 0.6, 0.0, 1.0},     -- Оранжевый
        Error = {1.0, 0.2, 0.2, 1.0},       -- Красный
        Background = {0.1, 0.1, 0.1, 0.95},  -- Темный фон
        Surface = {0.15, 0.15, 0.15, 0.95},  -- Поверхность
        Text = {1.0, 1.0, 1.0, 1.0},        -- Белый текст
        TextSecondary = {0.7, 0.7, 0.7, 1.0} -- Серый текст
    },
    
    -- Шрифты
    Fonts = {
        Default = "Arial",
        Bold = "Arial Bold",
        Small = "Arial Small"
    },
    
    -- Размеры
    Sizes = {
        ButtonHeight = 35,
        InputHeight = 30,
        SliderHeight = 20,
        SwitchSize = 50,
        TabHeight = 40
    }
}

-- ===============================================
-- СИСТЕМА АНИМАЦИЙ
-- ===============================================

local Animations = {}
local activeAnimations = {}

-- Easing функции
local Easing = {
    linear = function(t) return t end,
    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return t * (2 - t) end,
    easeInOutQuad = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end,
    easeOutQuart = function(t) return 1 - math.pow(1 - t, 4) end,
    easeOutBack = function(t) return 1 + 2.7 * math.pow(t - 1, 3) + 1.7 * math.pow(t - 1, 2) end
}

function UI.CreateAnimation(from, to, duration, easing, callback)
    local animation = {
        from = from,
        to = to,
        duration = duration,
        easing = easing or Easing.easeOutQuart,
        callback = callback,
        startTime = os.clock(),
        finished = false
    }
    
    table.insert(activeAnimations, animation)
    return animation
end

function UI.UpdateAnimations()
    local currentTime = os.clock()
    
    for i = #activeAnimations, 1, -1 do
        local anim = activeAnimations[i]
        local elapsed = currentTime - anim.startTime
        local progress = math.min(elapsed / anim.duration, 1)
        
        local easedProgress = anim.easing(progress)
        local currentValue = anim.from + (anim.to - anim.from) * easedProgress
        
        if anim.callback then
            anim.callback(currentValue)
        end
        
        if progress >= 1 then
            anim.finished = true
            table.remove(activeAnimations, i)
        end
    end
end

-- ===============================================
-- УТИЛИТЫ И ХЕЛПЕРЫ
-- ===============================================

function UI.Lerp(a, b, t)
    return a + (b - a) * t
end

function UI.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function UI.Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function UI.Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function UI.IsPointInRect(x, y, rectX, rectY, rectW, rectH)
    return x >= rectX and x <= rectX + rectW and y >= rectY and y <= rectY + rectH
end

-- ===============================================
-- СИСТЕМА ТЕМ
-- ===============================================

UI.Themes = {
    Dark = {
        Background = {0.1, 0.1, 0.1, 0.95},
        Surface = {0.15, 0.15, 0.15, 0.95},
        Primary = {0.2, 0.6, 1.0, 1.0},
        Text = {1.0, 1.0, 1.0, 1.0},
        TextSecondary = {0.7, 0.7, 0.7, 1.0},
        Border = {0.3, 0.3, 0.3, 1.0}
    },
    
    Light = {
        Background = {0.95, 0.95, 0.95, 0.95},
        Surface = {1.0, 1.0, 1.0, 0.95},
        Primary = {0.2, 0.6, 1.0, 1.0},
        Text = {0.1, 0.1, 0.1, 1.0},
        TextSecondary = {0.4, 0.4, 0.4, 1.0},
        Border = {0.8, 0.8, 0.8, 1.0}
    },
    
    Neon = {
        Background = {0.05, 0.05, 0.1, 0.95},
        Surface = {0.1, 0.1, 0.2, 0.95},
        Primary = {0.0, 1.0, 1.0, 1.0},
        Text = {1.0, 1.0, 1.0, 1.0},
        TextSecondary = {0.7, 0.9, 1.0, 1.0},
        Border = {0.0, 0.8, 1.0, 1.0}
    }
}

UI.CurrentTheme = UI.Themes.Dark

function UI.SetTheme(themeName)
    UI.CurrentTheme = UI.Themes[themeName] or UI.Themes.Dark
end

-- ===============================================
-- СИСТЕМА UID (USER ID) С DISCORD ВЕБХУКОМ
-- ===============================================

local UIDSystem = {}
UIDSystem.__index = UIDSystem

function UIDSystem:new(webhookUrl, databasePath)
    local obj = {
        webhookUrl = webhookUrl or "",
        databasePath = databasePath or "users.json",
        users = {},
        nextUID = 1,
        currentUser = nil,
        isRegistered = false
    }
    setmetatable(obj, UIDSystem)
    obj:LoadDatabase()
    return obj
end

function UIDSystem:LoadDatabase()
    -- Загрузка базы данных пользователей
    -- В реальной реализации здесь будет чтение из файла
    self.users = {
        -- Пример данных
        -- {uid = 1, username = "User1", joinDate = "2024-01-01", hwid = "abc123"},
        -- {uid = 2, username = "User2", joinDate = "2024-01-02", hwid = "def456"}
    }
    
    -- Определение следующего UID
    if #self.users > 0 then
        local maxUID = 0
        for _, user in ipairs(self.users) do
            if user.uid > maxUID then
                maxUID = user.uid
            end
        end
        self.nextUID = maxUID + 1
    else
        self.nextUID = 1
    end
end

function UIDSystem:SaveDatabase()
    -- Сохранение базы данных
    -- В реальной реализации здесь будет запись в файл
    print("Сохранение базы данных пользователей...")
end

function UIDSystem:GetHardwareID()
    -- Получение уникального ID устройства
    -- В реальной реализации здесь будет получение HWID
    return "HWID_" .. math.random(100000, 999999)
end

function UIDSystem:GetUsername()
    -- Получение имени пользователя
    -- В реальной реализации здесь будет получение имени пользователя системы
    return "User_" .. math.random(1000, 9999)
end

function UIDSystem:RegisterUser()
    if self.isRegistered then
        return self.currentUser
    end
    
    local hwid = self:GetHardwareID()
    local username = self:GetUsername()
    
    -- Проверка, зарегистрирован ли уже пользователь с таким HWID
    for _, user in ipairs(self.users) do
        if user.hwid == hwid then
            self.currentUser = user
            self.isRegistered = true
            return user
        end
    end
    
    -- Создание нового пользователя
    local newUser = {
        uid = self.nextUID,
        username = username,
        hwid = hwid,
        joinDate = os.date("%Y-%m-%d %H:%M:%S"),
        lastSeen = os.date("%Y-%m-%d %H:%M:%S"),
        totalSessions = 1
    }
    
    table.insert(self.users, newUser)
    self.currentUser = newUser
    self.isRegistered = true
    self.nextUID = self.nextUID + 1
    
    -- Отправка уведомления в Discord
    self:SendDiscordNotification(newUser, "register")
    
    -- Сохранение базы данных
    self:SaveDatabase()
    
    return newUser
end

function UIDSystem:UpdateLastSeen()
    if self.currentUser then
        self.currentUser.lastSeen = os.date("%Y-%m-%d %H:%M:%S")
        self.currentUser.totalSessions = (self.currentUser.totalSessions or 0) + 1
        self:SaveDatabase()
    end
end

function UIDSystem:SendDiscordNotification(user, action)
    if not self.webhookUrl or self.webhookUrl == "" then
        return
    end
    
    local embed = {
        title = "🔔 Новый пользователь зарегистрирован!",
        color = 0x00ff00, -- Зеленый цвет
        fields = {
            {
                name = "👤 Пользователь",
                value = user.username,
                inline = true
            },
            {
                name = "🆔 UID",
                value = "#" .. user.uid,
                inline = true
            },
            {
                name = "📅 Дата регистрации",
                value = user.joinDate,
                inline = true
            },
            {
                name = "🖥️ HWID",
                value = "`" .. user.hwid .. "`",
                inline = false
            }
        },
        footer = {
            text = "UI Library v1.1 | Система UID"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    if action == "login" then
        embed.title = "🟢 Пользователь вошел в систему"
        embed.color = 0x0099ff -- Синий цвет
        embed.fields[1].name = "👤 Пользователь"
        embed.fields[2].name = "🆔 UID"
        embed.fields[3].name = "🕒 Последний вход"
        embed.fields[3].value = user.lastSeen
        embed.fields[4].name = "📊 Всего сессий"
        embed.fields[4].value = tostring(user.totalSessions or 1)
    end
    
    local payload = {
        username = "UI Library Bot",
        avatar_url = "https://cdn.discordapp.com/attachments/1234567890/avatar.png",
        embeds = {embed}
    }
    
    -- Отправка HTTP запроса (заглушка)
    print("Отправка уведомления в Discord...")
    print("Webhook URL:", self.webhookUrl)
    print("Payload:", json.encode(payload))
end

function UIDSystem:GetUserInfo()
    if not self.currentUser then
        return nil
    end
    
    return {
        uid = self.currentUser.uid,
        username = self.currentUser.username,
        joinDate = self.currentUser.joinDate,
        lastSeen = self.currentUser.lastSeen,
        totalSessions = self.currentUser.totalSessions or 1,
        rank = self:GetUserRank()
    }
end

function UIDSystem:GetUserRank()
    if not self.currentUser then
        return "Неизвестно"
    end
    
    local uid = self.currentUser.uid
    
    if uid == 1 then
        return "👑 Основатель"
    elseif uid <= 10 then
        return "⭐ VIP"
    elseif uid <= 100 then
        return "🔥 Ранний пользователь"
    elseif uid <= 1000 then
        return "💎 Премиум"
    else
        return "👤 Пользователь"
    end
end

function UIDSystem:GetTotalUsers()
    return #self.users
end

function UIDSystem:GetUserByUID(uid)
    for _, user in ipairs(self.users) do
        if user.uid == uid then
            return user
        end
    end
    return nil
end

-- ===============================================
-- КОМПОНЕНТ ОТОБРАЖЕНИЯ UID
-- ===============================================

local UIDDisplay = setmetatable({}, Component)
UIDDisplay.__index = UIDDisplay

function UIDDisplay:new(x, y, width, height, uidSystem)
    local obj = Component:new(x, y, width, height)
    obj.uidSystem = uidSystem
    obj.showRank = true
    obj.showJoinDate = true
    obj.showTotalSessions = true
    obj.animationProgress = 0
    
    setmetatable(obj, UIDDisplay)
    return obj
end

function UIDDisplay:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    self.hovered = self:IsHovered(mouseX, mouseY)
    
    -- Анимация появления
    if self.animationProgress < 1 then
        UI.CreateAnimation(
            self.animationProgress,
            1,
            0.5,
            Easing.easeOutBack,
            function(value) self.animationProgress = value end
        )
    end
end

function UIDDisplay:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    if not self.uidSystem or not self.uidSystem.currentUser then
        -- Показываем загрузку
        UI.DrawRoundedRect(absX, absY, self.width, self.height, 8, theme.Surface)
        UI.DrawText("Загрузка UID...", absX + self.width / 2, absY + self.height / 2, theme.TextSecondary, "center", "center")
        return
    end
    
    local userInfo = self.uidSystem:GetUserInfo()
    local scale = self.animationProgress
    
    -- Фон с анимацией
    local bgColor = self.hovered and {theme.Primary[1] * 0.1, theme.Primary[2] * 0.1, theme.Primary[3] * 0.1, 0.5} or theme.Surface
    UI.DrawRoundedRect(absX, absY, self.width * scale, self.height * scale, 8, bgColor)
    
    -- Заголовок
    UI.DrawText("🆔 User ID", absX + 10, absY + 10, theme.Text, "left", "center")
    
    -- UID номер
    local uidText = "#" .. userInfo.uid
    UI.DrawText(uidText, absX + 10, absY + 30, theme.Primary, "left", "center")
    
    -- Ранг
    if self.showRank then
        UI.DrawText(userInfo.rank, absX + 10, absY + 50, theme.TextSecondary, "left", "center")
    end
    
    -- Дополнительная информация
    if self.showJoinDate then
        UI.DrawText("📅 " .. userInfo.joinDate, absX + 10, absY + 70, theme.TextSecondary, "left", "center")
    end
    
    if self.showTotalSessions then
        UI.DrawText("📊 Сессий: " .. userInfo.totalSessions, absX + 10, absY + 90, theme.TextSecondary, "left", "center")
    end
    
    -- Индикатор статуса
    local statusColor = {0.2, 0.8, 0.2, 1.0} -- Зеленый
    UI.DrawCircle(absX + self.width - 15, absY + 15, 5, statusColor)
end

function UIDDisplay:SetShowRank(show)
    self.showRank = show
end

function UIDDisplay:SetShowJoinDate(show)
    self.showJoinDate = show
end

function UIDDisplay:SetShowTotalSessions(show)
    self.showTotalSessions = show
end

-- ===============================================
-- СИСТЕМА UID ДЛЯ КОМПОНЕНТОВ
-- ===============================================

local nextUID = 1
function UI.GenerateUID()
    nextUID = nextUID + 1
    return "ui_" .. nextUID
end

-- ===============================================
-- БАЗОВЫЙ КОМПОНЕНТ
-- ===============================================

local Component = {}
Component.__index = Component

function Component:new(x, y, width, height)
    local obj = {
        x = x or 0,
        y = y or 0,
        width = width or 100,
        height = height or 30,
        visible = true,
        enabled = true,
        uid = UI.GenerateUID(),
        parent = nil,
        children = {},
        animations = {},
        theme = UI.CurrentTheme
    }
    setmetatable(obj, Component)
    return obj
end

function Component:SetPosition(x, y)
    self.x = x
    self.y = y
end

function Component:SetSize(width, height)
    self.width = width
    self.height = height
end

function Component:SetVisible(visible)
    self.visible = visible
end

function Component:SetEnabled(enabled)
    self.enabled = enabled
end

function Component:AddChild(child)
    child.parent = self
    table.insert(self.children, child)
end

function Component:RemoveChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            break
        end
    end
end

function Component:GetAbsolutePosition()
    local x, y = self.x, self.y
    if self.parent then
        local parentX, parentY = self.parent:GetAbsolutePosition()
        x = x + parentX
        y = y + parentY
    end
    return x, y
end

function Component:IsHovered(mouseX, mouseY)
    local absX, absY = self:GetAbsolutePosition()
    return UI.IsPointInRect(mouseX, mouseY, absX, absY, self.width, self.height)
end

-- ===============================================
-- КРАСИВЫЕ ПЕРЕКЛЮЧАТЕЛИ
-- ===============================================

local Switch = setmetatable({}, Component)
Switch.__index = Switch

function Switch:new(x, y, width, height, text, callback)
    local obj = Component:new(x, y, width or 60, height or 30)
    obj.text = text or ""
    obj.callback = callback
    obj.value = false
    obj.animationProgress = 0
    obj.hovered = false
    obj.pressed = false
    
    setmetatable(obj, Switch)
    return obj
end

function Switch:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    local wasHovered = self.hovered
    self.hovered = self:IsHovered(mouseX, mouseY)
    
    if mousePressed and self.hovered then
        self.pressed = true
    end
    
    if mouseReleased and self.pressed and self.hovered then
        self.value = not self.value
        if self.callback then
            self.callback(self.value)
        end
        self.pressed = false
    end
    
    if not mousePressed then
        self.pressed = false
    end
    
    -- Анимация переключения
    local targetProgress = self.value and 1 or 0
    if self.animationProgress ~= targetProgress then
        UI.CreateAnimation(
            self.animationProgress,
            targetProgress,
            UI.Config.AnimationSpeed,
            Easing.easeOutBack,
            function(value) self.animationProgress = value end
        )
    end
end

function Switch:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Фон переключателя
    local bgColor = self.hovered and {theme.Primary[1] * 0.3, theme.Primary[2] * 0.3, theme.Primary[3] * 0.3, 0.5} or theme.Surface
    UI.DrawRoundedRect(absX, absY, self.width, self.height, 15, bgColor)
    
    -- Переключатель
    local switchSize = self.height - 4
    local switchX = absX + 2 + (self.width - switchSize - 4) * self.animationProgress
    local switchY = absY + 2
    
    local switchColor = self.value and theme.Primary or {0.5, 0.5, 0.5, 1.0}
    UI.DrawRoundedRect(switchX, switchY, switchSize, switchSize, switchSize / 2, switchColor)
    
    -- Текст
    if self.text and self.text ~= "" then
        UI.DrawText(self.text, absX + self.width + 10, absY + self.height / 2, theme.Text, "center", "center")
    end
end

-- ===============================================
-- ДРАГАБЕЛЬНОЕ МЕНЮ
-- ===============================================

local DraggableMenu = setmetatable({}, Component)
DraggableMenu.__index = DraggableMenu

function DraggableMenu:new(x, y, width, height, title)
    local obj = Component:new(x, y, width, height)
    obj.title = title or "Menu"
    obj.dragging = false
    obj.dragOffsetX = 0
    obj.dragOffsetY = 0
    obj.headerHeight = 30
    obj.minimized = false
    
    setmetatable(obj, DraggableMenu)
    return obj
end

function DraggableMenu:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local headerRect = {absX, absY, self.width, self.headerHeight}
    
    -- Проверка на клик по заголовку для перетаскивания
    if mousePressed and UI.IsPointInRect(mouseX, mouseY, headerRect[1], headerRect[2], headerRect[3], headerRect[4]) then
        self.dragging = true
        self.dragOffsetX = mouseX - absX
        self.dragOffsetY = mouseY - absY
    end
    
    if self.dragging then
        if mousePressed then
            self.x = mouseX - self.dragOffsetX
            self.y = mouseY - self.dragOffsetY
        else
            self.dragging = false
        end
    end
    
    -- Обновление дочерних компонентов
    for _, child in ipairs(self.children) do
        child:Update(mouseX, mouseY, mousePressed, mouseReleased)
    end
end

function DraggableMenu:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Основной фон меню
    UI.DrawRoundedRect(absX, absY, self.width, self.height, 8, theme.Background)
    
    -- Заголовок
    UI.DrawRoundedRect(absX, absY, self.width, self.headerHeight, 8, theme.Surface)
    UI.DrawText(self.title, absX + 10, absY + self.headerHeight / 2, theme.Text, "left", "center")
    
    -- Кнопка закрытия
    local closeBtnX = absX + self.width - 25
    local closeBtnY = absY + 5
    UI.DrawRoundedRect(closeBtnX, closeBtnY, 20, 20, 4, {1.0, 0.3, 0.3, 0.8})
    UI.DrawText("×", closeBtnX + 10, closeBtnY + 10, {1.0, 1.0, 1.0, 1.0}, "center", "center")
    
    -- Рендер дочерних компонентов
    for _, child in ipairs(self.children) do
        child:Render()
    end
end

-- ===============================================
-- КРАСИВЫЙ КОЛОР ПИКЕР
-- ===============================================

local ColorPicker = setmetatable({}, Component)
ColorPicker.__index = ColorPicker

function ColorPicker:new(x, y, width, height, callback)
    local obj = Component:new(x, y, width or 200, height or 150)
    obj.callback = callback
    obj.color = {1.0, 0.0, 0.0, 1.0}
    obj.hue = 0
    obj.saturation = 1.0
    obj.brightness = 1.0
    obj.alpha = 1.0
    obj.draggingHue = false
    obj.draggingSaturation = false
    
    setmetatable(obj, ColorPicker)
    return obj
end

function ColorPicker:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    local absX, absY = self:GetAbsolutePosition()
    
    -- Hue slider
    local hueSliderY = absY + 10
    if mousePressed and UI.IsPointInRect(mouseX, mouseY, absX + 10, hueSliderY, self.width - 20, 20) then
        self.draggingHue = true
    end
    
    if self.draggingHue then
        if mousePressed then
            local hueX = UI.Clamp(mouseX - absX - 10, 0, self.width - 20)
            self.hue = hueX / (self.width - 20) * 360
            self:UpdateColor()
        else
            self.draggingHue = false
        end
    end
    
    -- Saturation/Brightness area
    local sbAreaY = absY + 40
    if mousePressed and UI.IsPointInRect(mouseX, mouseY, absX + 10, sbAreaY, self.width - 20, self.height - 50) then
        self.draggingSaturation = true
    end
    
    if self.draggingSaturation then
        if mousePressed then
            local sbX = UI.Clamp(mouseX - absX - 10, 0, self.width - 20)
            local sbY = UI.Clamp(mouseY - sbAreaY, 0, self.height - 50)
            self.saturation = sbX / (self.width - 20)
            self.brightness = 1.0 - (sbY / (self.height - 50))
            self:UpdateColor()
        else
            self.draggingSaturation = false
        end
    end
end

function ColorPicker:UpdateColor()
    local r, g, b = UI.HSVToRGB(self.hue, self.saturation, self.brightness)
    self.color = {r, g, b, self.alpha}
    if self.callback then
        self.callback(self.color)
    end
end

function ColorPicker:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Фон
    UI.DrawRoundedRect(absX, absY, self.width, self.height, 8, theme.Surface)
    
    -- Hue slider
    local hueSliderY = absY + 10
    for i = 0, self.width - 20 do
        local hue = (i / (self.width - 20)) * 360
        local r, g, b = UI.HSVToRGB(hue, 1.0, 1.0)
        UI.DrawRect(absX + 10 + i, hueSliderY, 1, 20, {r, g, b, 1.0})
    end
    
    -- Hue slider handle
    local hueHandleX = absX + 10 + (self.hue / 360) * (self.width - 20)
    UI.DrawRoundedRect(hueHandleX - 2, hueSliderY - 2, 4, 24, 2, {1.0, 1.0, 1.0, 1.0})
    
    -- Saturation/Brightness area
    local sbAreaY = absY + 40
    local sbAreaW = self.width - 20
    local sbAreaH = self.height - 50
    
    -- Рендер градиента
    for y = 0, sbAreaH do
        for x = 0, sbAreaW do
            local sat = x / sbAreaW
            local bright = 1.0 - (y / sbAreaH)
            local r, g, b = UI.HSVToRGB(self.hue, sat, bright)
            UI.DrawRect(absX + 10 + x, sbAreaY + y, 1, 1, {r, g, b, 1.0})
        end
    end
    
    -- SB handle
    local sbHandleX = absX + 10 + self.saturation * sbAreaW
    local sbHandleY = sbAreaY + (1.0 - self.brightness) * sbAreaH
    UI.DrawRoundedRect(sbHandleX - 3, sbHandleY - 3, 6, 6, 3, {1.0, 1.0, 1.0, 1.0})
    
    -- Показ текущего цвета
    local colorPreviewY = absY + self.height - 25
    UI.DrawRoundedRect(absX + 10, colorPreviewY, 30, 15, 4, self.color)
    UI.DrawText(string.format("RGB: %.0f, %.0f, %.0f", 
        self.color[1] * 255, self.color[2] * 255, self.color[3] * 255),
        absX + 50, colorPreviewY + 7, theme.Text, "left", "center")
end

-- ===============================================
-- СИСТЕМА БИНДОВ
-- ===============================================

local Bind = {}
Bind.__index = Bind

function Bind:new(key, mode, callback)
    local obj = {
        key = key,
        mode = mode or "toggle", -- "toggle" или "hold"
        callback = callback,
        active = false,
        pressed = false,
        lastState = false
    }
    setmetatable(obj, Bind)
    return obj
end

function Bind:Update()
    local currentState = self:IsKeyPressed(self.key)
    
    if self.mode == "toggle" then
        if currentState and not self.lastState then
            self.active = not self.active
            if self.callback then
                self.callback(self.active)
            end
        end
    elseif self.mode == "hold" then
        if currentState ~= self.active then
            self.active = currentState
            if self.callback then
                self.callback(self.active)
            end
        end
    end
    
    self.lastState = currentState
end

function Bind:IsKeyPressed(key)
    -- Здесь должна быть реализация проверки нажатия клавиши
    -- Зависит от конкретной среды выполнения
    return false -- Заглушка
end

-- ===============================================
-- КРАСИВЫЕ ПОЛЗУНКИ
-- ===============================================

local Slider = setmetatable({}, Component)
Slider.__index = Slider

function Slider:new(x, y, width, height, min, max, value, callback)
    local obj = Component:new(x, y, width, height or 20)
    obj.min = min or 0
    obj.max = max or 100
    obj.value = value or min
    obj.callback = callback
    obj.dragging = false
    obj.hovered = false
    
    setmetatable(obj, Slider)
    return obj
end

function Slider:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    local absX, absY = self:GetAbsolutePosition()
    self.hovered = self:IsHovered(mouseX, mouseY)
    
    if mousePressed and self.hovered then
        self.dragging = true
    end
    
    if self.dragging then
        if mousePressed then
            local sliderX = UI.Clamp(mouseX - absX, 0, self.width)
            local progress = sliderX / self.width
            self.value = self.min + (self.max - self.min) * progress
            if self.callback then
                self.callback(self.value)
            end
        else
            self.dragging = false
        end
    end
end

function Slider:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Фон ползунка
    local bgColor = self.hovered and {theme.Primary[1] * 0.2, theme.Primary[2] * 0.2, theme.Primary[3] * 0.2, 0.5} or theme.Surface
    UI.DrawRoundedRect(absX, absY + self.height / 2 - 2, self.width, 4, 2, bgColor)
    
    -- Прогресс
    local progress = (self.value - self.min) / (self.max - self.min)
    local progressWidth = self.width * progress
    UI.DrawRoundedRect(absX, absY + self.height / 2 - 2, progressWidth, 4, 2, theme.Primary)
    
    -- Handle
    local handleX = absX + progressWidth - 6
    local handleY = absY + self.height / 2 - 6
    local handleColor = self.dragging and theme.Primary or (self.hovered and {theme.Primary[1] * 0.8, theme.Primary[2] * 0.8, theme.Primary[3] * 0.8, 1.0} or theme.Surface)
    UI.DrawRoundedRect(handleX, handleY, 12, 12, 6, handleColor)
    
    -- Значение
    UI.DrawText(string.format("%.1f", self.value), absX + self.width + 10, absY + self.height / 2, theme.Text, "left", "center")
end

-- ===============================================
-- КРАСИВЫЕ ДРОПДАУНЫ
-- ===============================================

local Dropdown = setmetatable({}, Component)
Dropdown.__index = Dropdown

function Dropdown:new(x, y, width, height, items, callback)
    local obj = Component:new(x, y, width, height or 30)
    obj.items = items or {}
    obj.selectedIndex = 1
    obj.open = false
    obj.callback = callback
    obj.hovered = false
    obj.hoveredIndex = -1
    
    setmetatable(obj, Dropdown)
    return obj
end

function Dropdown:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    local absX, absY = self:GetAbsolutePosition()
    self.hovered = self:IsHovered(mouseX, mouseY)
    
    if mousePressed then
        if self.hovered then
            self.open = not self.open
        elseif self.open then
            -- Проверка клика по элементам
            local itemY = absY + self.height
            for i, item in ipairs(self.items) do
                if UI.IsPointInRect(mouseX, mouseY, absX, itemY, self.width, 25) then
                    self.selectedIndex = i
                    self.open = false
                    if self.callback then
                        self.callback(item, i)
                    end
                    break
                end
                itemY = itemY + 25
            end
        end
    end
    
    -- Hover эффект для элементов
    if self.open then
        local itemY = absY + self.height
        self.hoveredIndex = -1
        for i, item in ipairs(self.items) do
            if UI.IsPointInRect(mouseX, mouseY, absX, itemY, self.width, 25) then
                self.hoveredIndex = i
                break
            end
            itemY = itemY + 25
        end
    end
end

function Dropdown:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Основной элемент
    local bgColor = self.hovered and {theme.Primary[1] * 0.2, theme.Primary[2] * 0.2, theme.Primary[3] * 0.2, 0.5} or theme.Surface
    UI.DrawRoundedRect(absX, absY, self.width, self.height, 4, bgColor)
    
    -- Текст выбранного элемента
    local selectedText = self.items[self.selectedIndex] or "Выберите..."
    UI.DrawText(selectedText, absX + 10, absY + self.height / 2, theme.Text, "left", "center")
    
    -- Стрелка
    local arrowX = absX + self.width - 20
    local arrowY = absY + self.height / 2
    UI.DrawText(self.open and "▲" or "▼", arrowX, arrowY, theme.TextSecondary, "center", "center")
    
    -- Выпадающий список
    if self.open then
        local dropdownY = absY + self.height
        local dropdownHeight = #self.items * 25
        
        -- Фон списка
        UI.DrawRoundedRect(absX, dropdownY, self.width, dropdownHeight, 4, theme.Background)
        
        -- Элементы списка
        for i, item in ipairs(self.items) do
            local itemY = dropdownY + (i - 1) * 25
            local itemColor = (i == self.hoveredIndex) and {theme.Primary[1] * 0.3, theme.Primary[2] * 0.3, theme.Primary[3] * 0.3, 0.5} or theme.Surface
            UI.DrawRoundedRect(absX, itemY, self.width, 25, 0, itemColor)
            UI.DrawText(item, absX + 10, itemY + 12, theme.Text, "left", "center")
        end
    end
end

-- ===============================================
-- СИСТЕМА ВОДЯНЫХ ЗНАКОВ
-- ===============================================

local Watermark = {}
Watermark.__index = Watermark

function Watermark:new(text, position, style)
    local obj = {
        text = text or "UI Library",
        position = position or "top-right", -- "top-left", "top-right", "bottom-left", "bottom-right"
        style = style or "default",
        visible = true,
        color = {1.0, 1.0, 1.0, 0.7},
        backgroundColor = {0.0, 0.0, 0.0, 0.3}
    }
    setmetatable(obj, Watermark)
    return obj
end

function Watermark:Render(screenWidth, screenHeight)
    if not self.visible then return end
    
    local x, y = 10, 10
    
    if self.position == "top-right" then
        x = screenWidth - 200
        y = 10
    elseif self.position == "bottom-left" then
        x = 10
        y = screenHeight - 30
    elseif self.position == "bottom-right" then
        x = screenWidth - 200
        y = screenHeight - 30
    end
    
    -- Фон
    UI.DrawRoundedRect(x - 5, y - 5, 190, 25, 4, self.backgroundColor)
    
    -- Текст
    UI.DrawText(self.text, x, y + 10, self.color, "left", "center")
end

-- ===============================================
-- BIND LIST
-- ===============================================

local BindList = setmetatable({}, Component)
BindList.__index = BindList

function BindList:new(x, y, width, height)
    local obj = Component:new(x, y, width, height)
    obj.binds = {}
    obj.visible = true
    
    setmetatable(obj, BindList)
    return obj
end

function BindList:AddBind(bind)
    table.insert(self.binds, bind)
end

function BindList:Update()
    for _, bind in ipairs(self.binds) do
        bind:Update()
    end
end

function BindList:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Фон
    UI.DrawRoundedRect(absX, absY, self.width, self.height, 8, theme.Background)
    
    -- Заголовок
    UI.DrawText("Active Binds", absX + 10, absY + 10, theme.Text, "left", "center")
    
    -- Список биндов
    local yOffset = 35
    for i, bind in ipairs(self.binds) do
        if bind.active then
            local statusColor = bind.active and theme.Success or theme.TextSecondary
            UI.DrawText(string.format("%s: %s (%s)", bind.key, bind.mode, bind.active and "ON" or "OFF"), 
                absX + 10, absY + yOffset, statusColor, "left", "center")
            yOffset = yOffset + 20
        end
    end
end

-- ===============================================
-- КРАСИВЫЕ ВКЛАДКИ
-- ===============================================

local TabContainer = setmetatable({}, Component)
TabContainer.__index = TabContainer

function TabContainer:new(x, y, width, height)
    local obj = Component:new(x, y, width, height)
    obj.tabs = {}
    obj.activeTab = 1
    obj.tabHeight = 40
    
    setmetatable(obj, TabContainer)
    return obj
end

function TabContainer:AddTab(name, content)
    table.insert(self.tabs, {name = name, content = content})
end

function TabContainer:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    
    if mousePressed then
        -- Проверка клика по вкладкам
        for i, tab in ipairs(self.tabs) do
            local tabX = absX + (i - 1) * (self.width / #self.tabs)
            if UI.IsPointInRect(mouseX, mouseY, tabX, absY, self.width / #self.tabs, self.tabHeight) then
                self.activeTab = i
                break
            end
        end
    end
    
    -- Обновление активной вкладки
    if self.tabs[self.activeTab] and self.tabs[self.activeTab].content then
        self.tabs[self.activeTab].content:Update(mouseX, mouseY, mousePressed, mouseReleased)
    end
end

function TabContainer:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Фон вкладок
    UI.DrawRoundedRect(absX, absY, self.width, self.tabHeight, 8, theme.Surface)
    
    -- Вкладки
    for i, tab in ipairs(self.tabs) do
        local tabX = absX + (i - 1) * (self.width / #self.tabs)
        local tabWidth = self.width / #self.tabs
        local isActive = i == self.activeTab
        
        local tabColor = isActive and theme.Primary or theme.Surface
        UI.DrawRoundedRect(tabX, absY, tabWidth, self.tabHeight, 8, tabColor)
        UI.DrawText(tab.name, tabX + tabWidth / 2, absY + self.tabHeight / 2, theme.Text, "center", "center")
    end
    
    -- Контент активной вкладки
    if self.tabs[self.activeTab] and self.tabs[self.activeTab].content then
        self.tabs[self.activeTab].content:Render()
    end
end

-- ===============================================
-- БАЗОВЫЕ КОМПОНЕНТЫ
-- ===============================================

-- Label
local Label = setmetatable({}, Component)
Label.__index = Label

function Label:new(x, y, text, color)
    local obj = Component:new(x, y, 100, 20)
    obj.text = text or ""
    obj.color = color or UI.CurrentTheme.Text
    
    setmetatable(obj, Label)
    return obj
end

function Label:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    UI.DrawText(self.text, absX, absY, self.color, "left", "center")
end

-- Button
local Button = setmetatable({}, Component)
Button.__index = Button

function Button:new(x, y, width, height, text, callback)
    local obj = Component:new(x, y, width, height)
    obj.text = text or "Button"
    obj.callback = callback
    obj.hovered = false
    obj.pressed = false
    
    setmetatable(obj, Button)
    return obj
end

function Button:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    self.hovered = self:IsHovered(mouseX, mouseY)
    
    if mousePressed and self.hovered then
        self.pressed = true
    end
    
    if mouseReleased and self.pressed and self.hovered then
        if self.callback then
            self.callback()
        end
        self.pressed = false
    end
    
    if not mousePressed then
        self.pressed = false
    end
end

function Button:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    local bgColor = self.pressed and {theme.Primary[1] * 0.8, theme.Primary[2] * 0.8, theme.Primary[3] * 0.8, 1.0} or 
                   (self.hovered and theme.Primary or theme.Surface)
    
    UI.DrawRoundedRect(absX, absY, self.width, self.height, 4, bgColor)
    UI.DrawText(self.text, absX + self.width / 2, absY + self.height / 2, theme.Text, "center", "center")
end

-- Checkbox
local Checkbox = setmetatable({}, Component)
Checkbox.__index = Checkbox

function Checkbox:new(x, y, text, callback)
    local obj = Component:new(x, y, 20, 20)
    obj.text = text or ""
    obj.callback = callback
    obj.checked = false
    obj.hovered = false
    
    setmetatable(obj, Checkbox)
    return obj
end

function Checkbox:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    self.hovered = self:IsHovered(mouseX, mouseY)
    
    if mouseReleased and self.hovered then
        self.checked = not self.checked
        if self.callback then
            self.callback(self.checked)
        end
    end
end

function Checkbox:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    local theme = self.theme
    
    -- Фон чекбокса
    local bgColor = self.hovered and {theme.Primary[1] * 0.2, theme.Primary[2] * 0.2, theme.Primary[3] * 0.2, 0.5} or theme.Surface
    UI.DrawRoundedRect(absX, absY, 20, 20, 4, bgColor)
    
    -- Галочка
    if self.checked then
        UI.DrawRoundedRect(absX + 2, absY + 2, 16, 16, 2, theme.Primary)
        UI.DrawText("✓", absX + 10, absY + 10, {1.0, 1.0, 1.0, 1.0}, "center", "center")
    end
    
    -- Текст
    if self.text and self.text ~= "" then
        UI.DrawText(self.text, absX + 30, absY + 10, theme.Text, "left", "center")
    end
end

-- Divider
local Divider = setmetatable({}, Component)
Divider.__index = Divider

function Divider:new(x, y, width, orientation)
    local obj = Component:new(x, y, width, orientation == "vertical" and 100 or 1)
    obj.orientation = orientation or "horizontal"
    obj.color = UI.CurrentTheme.Border
    
    setmetatable(obj, Divider)
    return obj
end

function Divider:Render()
    if not self.visible then return end
    
    local absX, absY = self:GetAbsolutePosition()
    
    if self.orientation == "horizontal" then
        UI.DrawRect(absX, absY, self.width, 1, self.color)
    else
        UI.DrawRect(absX, absY, 1, self.height, self.color)
    end
end

-- Tooltip
local Tooltip = setmetatable({}, Component)
Tooltip.__index = Tooltip

function Tooltip:new(text)
    local obj = Component:new(0, 0, 200, 30)
    obj.text = text or ""
    obj.visible = false
    obj.targetComponent = nil
    
    setmetatable(obj, Tooltip)
    return obj
end

function Tooltip:Show(component, text)
    self.targetComponent = component
    self.text = text or self.text
    self.visible = true
end

function Tooltip:Hide()
    self.visible = false
    self.targetComponent = nil
end

function Tooltip:Render()
    if not self.visible or not self.targetComponent then return end
    
    local absX, absY = self.targetComponent:GetAbsolutePosition()
    local theme = self.theme
    
    -- Позиционирование относительно компонента
    local tooltipX = absX + self.targetComponent.width + 10
    local tooltipY = absY
    
    -- Фон
    UI.DrawRoundedRect(tooltipX, tooltipY, self.width, self.height, 4, theme.Background)
    
    -- Текст
    UI.DrawText(self.text, tooltipX + 10, tooltipY + self.height / 2, theme.Text, "left", "center")
end

-- ===============================================
-- ФУНКЦИИ РЕНДЕРИНГА
-- ===============================================

function UI.DrawRect(x, y, width, height, color)
    -- Заглушка для рендеринга прямоугольника
    -- В реальной реализации здесь должен быть код отрисовки
    print(string.format("DrawRect: x=%.1f, y=%.1f, w=%.1f, h=%.1f, color=(%.2f,%.2f,%.2f,%.2f)", 
        x, y, width, height, color[1], color[2], color[3], color[4]))
end

function UI.DrawRoundedRect(x, y, width, height, radius, color)
    -- Заглушка для рендеринга скругленного прямоугольника
    print(string.format("DrawRoundedRect: x=%.1f, y=%.1f, w=%.1f, h=%.1f, r=%.1f, color=(%.2f,%.2f,%.2f,%.2f)", 
        x, y, width, height, radius, color[1], color[2], color[3], color[4]))
end

function UI.DrawText(text, x, y, color, alignX, alignY)
    -- Заглушка для рендеринга текста
    print(string.format("DrawText: '%s' at (%.1f,%.1f), color=(%.2f,%.2f,%.2f,%.2f), align=(%s,%s)", 
        text, x, y, color[1], color[2], color[3], color[4], alignX or "left", alignY or "center"))
end

function UI.DrawCircle(x, y, radius, color)
    -- Заглушка для рендеринга круга
    print(string.format("DrawCircle: center=(%.1f,%.1f), r=%.1f, color=(%.2f,%.2f,%.2f,%.2f)", 
        x, y, radius, color[1], color[2], color[3], color[4]))
end

-- ===============================================
-- УТИЛИТЫ ДЛЯ ЦВЕТОВ
-- ===============================================

function UI.HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return r, g, b
end

function UI.RGBToHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local diff = max - min
    
    local h = 0
    if diff ~= 0 then
        if max == r then
            h = (g - b) / diff % 6
        elseif max == g then
            h = (b - r) / diff + 2
        else
            h = (r - g) / diff + 4
        end
    end
    
    h = h / 6
    local s = max == 0 and 0 or diff / max
    local v = max
    
    return h, s, v
end

-- ===============================================
-- ОСНОВНОЙ КЛАСС UI
-- ===============================================

function UI:new()
    local obj = {
        components = {},
        watermarks = {},
        bindList = nil,
        mouseX = 0,
        mouseY = 0,
        mousePressed = false,
        mouseReleased = false,
        lastMousePressed = false
    }
    setmetatable(obj, UI)
    return obj
end

function UI:AddComponent(component)
    table.insert(self.components, component)
end

function UI:RemoveComponent(component)
    for i, comp in ipairs(self.components) do
        if comp == component then
            table.remove(self.components, i)
            break
        end
    end
end

function UI:Update(mouseX, mouseY, mousePressed)
    self.mouseX = mouseX
    self.mouseY = mouseY
    self.mouseReleased = self.lastMousePressed and not mousePressed
    self.lastMousePressed = mousePressed
    
    -- Обновление анимаций
    UI.UpdateAnimations()
    
    -- Обновление компонентов
    for _, component in ipairs(self.components) do
        if component.Update then
            component:Update(mouseX, mouseY, mousePressed, self.mouseReleased)
        end
    end
    
    -- Обновление водяных знаков
    for _, watermark in ipairs(self.watermarks) do
        if watermark.Update then
            watermark:Update()
        end
    end
    
    -- Обновление bind list
    if self.bindList then
        self.bindList:Update()
    end
end

function UI:Render(screenWidth, screenHeight)
    -- Рендер компонентов
    for _, component in ipairs(self.components) do
        if component.Render then
            component:Render()
        end
    end
    
    -- Рендер водяных знаков
    for _, watermark in ipairs(self.watermarks) do
        if watermark.Render then
            watermark:Render(screenWidth, screenHeight)
        end
    end
    
    -- Рендер bind list
    if self.bindList then
        self.bindList:Render()
    end
end

function UI:AddWatermark(text, position, style)
    local watermark = Watermark:new(text, position, style)
    table.insert(self.watermarks, watermark)
    return watermark
end

function UI:SetBindList(bindList)
    self.bindList = bindList
end

-- ===============================================
-- СИСТЕМА УВЕДОМЛЕНИЙ
-- ===============================================

local Notification = {}
Notification.__index = Notification

function Notification:new(text, duration, type)
    local obj = {
        text = text or "Notification",
        duration = duration or 5,
        type = type or "info", -- "info", "success", "warning", "error"
        visible = true,
        startTime = os.clock(),
        position = {0, 0},
        size = {200, 50}
    }
    setmetatable(obj, Notification)
    return obj
end

function Notification:Update()
    local elapsed = os.clock() - self.startTime
    if elapsed >= self.duration then
        self.visible = false
    end
end

function Notification:Render()
    if not self.visible then return end
    
    local theme = UI.CurrentTheme
    local color = theme.Primary
    
    if self.type == "success" then
        color = theme.Success or {0.2, 0.8, 0.2, 1.0}
    elseif self.type == "warning" then
        color = theme.Warning or {1.0, 0.6, 0.0, 1.0}
    elseif self.type == "error" then
        color = theme.Error or {1.0, 0.2, 0.2, 1.0}
    end
    
    -- Фон уведомления
    UI.DrawRoundedRect(self.position[1], self.position[2], self.size[1], self.size[2], 8, theme.Background)
    
    -- Текст
    UI.DrawText(self.text, self.position[1] + 10, self.position[2] + self.size[2] / 2, theme.Text, "left", "center")
    
    -- Индикатор типа
    UI.DrawRoundedRect(self.position[1], self.position[2], 4, self.size[2], 2, color)
end

-- ===============================================
-- СИСТЕМА ПОИСКА
-- ===============================================

local SearchSystem = {}
SearchSystem.__index = SearchSystem

function SearchSystem:new()
    local obj = {
        query = "",
        results = {},
        active = false
    }
    setmetatable(obj, SearchSystem)
    return obj
end

function SearchSystem:SetQuery(query)
    self.query = query:lower()
    self:UpdateResults()
end

function SearchSystem:UpdateResults()
    self.results = {}
    if self.query == "" then return end
    
    -- Поиск по всем компонентам
    for _, component in ipairs(UI.components or {}) do
        if component.text and component.text:lower():match(self.query) then
            table.insert(self.results, component)
        end
    end
end

function SearchSystem:GetResults()
    return self.results
end

-- ===============================================
-- КОНТЕКСТНЫЕ МЕНЮ
-- ===============================================

local ContextMenu = {}
ContextMenu.__index = ContextMenu

function ContextMenu:new(x, y, items)
    local obj = {
        x = x or 0,
        y = y or 0,
        items = items or {},
        visible = false,
        width = 150,
        itemHeight = 30
    }
    setmetatable(obj, ContextMenu)
    return obj
end

function ContextMenu:Show(x, y)
    self.x = x
    self.y = y
    self.visible = true
end

function ContextMenu:Hide()
    self.visible = false
end

function ContextMenu:AddItem(text, callback)
    table.insert(self.items, {text = text, callback = callback})
end

function ContextMenu:Update(mouseX, mouseY, mousePressed)
    if not self.visible then return end
    
    -- Проверка клика по элементам
    if mousePressed then
        for i, item in ipairs(self.items) do
            local itemY = self.y + (i - 1) * self.itemHeight
            if UI.IsPointInRect(mouseX, mouseY, self.x, itemY, self.width, self.itemHeight) then
                if item.callback then
                    item.callback()
                end
                self:Hide()
                break
            end
        end
    end
end

function ContextMenu:Render()
    if not self.visible then return end
    
    local theme = UI.CurrentTheme
    local height = #self.items * self.itemHeight
    
    -- Фон меню
    UI.DrawRoundedRect(self.x, self.y, self.width, height, 4, theme.Background)
    
    -- Элементы меню
    for i, item in ipairs(self.items) do
        local itemY = self.y + (i - 1) * self.itemHeight
        UI.DrawRoundedRect(self.x, itemY, self.width, self.itemHeight, 0, theme.Surface)
        UI.DrawText(item.text, self.x + 10, itemY + self.itemHeight / 2, theme.Text, "left", "center")
    end
end

-- ===============================================
-- УЛУЧШЕННАЯ СИСТЕМА АНИМАЦИЙ
-- ===============================================

local AdvancedAnimations = {}

function AdvancedAnimations.CreateTween(from, to, duration, easing, callback)
    local tween = {
        from = from,
        to = to,
        duration = duration,
        easing = easing or Easing.easeOutQuart,
        callback = callback,
        startTime = os.clock(),
        finished = false,
        paused = false,
        reverse = false
    }
    
    table.insert(activeAnimations, tween)
    return tween
end

function AdvancedAnimations.Pause(tween)
    tween.paused = true
end

function AdvancedAnimations.Resume(tween)
    tween.paused = false
end

function AdvancedAnimations.Reverse(tween)
    tween.reverse = not tween.reverse
    tween.from, tween.to = tween.to, tween.from
end

function AdvancedAnimations.Cancel(tween)
    for i, anim in ipairs(activeAnimations) do
        if anim == tween then
            table.remove(activeAnimations, i)
            break
        end
    end
end

-- ===============================================
-- СИСТЕМА МОДАЛЬНЫХ ОКОН
-- ===============================================

local Modal = {}
Modal.__index = Modal

function Modal:new(title, content, width, height)
    local obj = {
        title = title or "Modal",
        content = content or "",
        width = width or 400,
        height = height or 300,
        visible = false,
        x = 0,
        y = 0,
        buttons = {}
    }
    setmetatable(obj, Modal)
    return obj
end

function Modal:Show()
    self.visible = true
    -- Центрирование модального окна
    self.x = (screenWidth or 800) / 2 - self.width / 2
    self.y = (screenHeight or 600) / 2 - self.height / 2
end

function Modal:Hide()
    self.visible = false
end

function Modal:AddButton(text, callback)
    table.insert(self.buttons, {text = text, callback = callback})
end

function Modal:Update(mouseX, mouseY, mousePressed)
    if not self.visible then return end
    
    if mousePressed then
        -- Проверка клика по кнопкам
        local buttonY = self.y + self.height - 50
        local buttonWidth = (self.width - 20) / #self.buttons
        
        for i, button in ipairs(self.buttons) do
            local buttonX = self.x + 10 + (i - 1) * buttonWidth
            if UI.IsPointInRect(mouseX, mouseY, buttonX, buttonY, buttonWidth - 5, 30) then
                if button.callback then
                    button.callback()
                end
                break
            end
        end
    end
end

function Modal:Render()
    if not self.visible then return end
    
    local theme = UI.CurrentTheme
    
    -- Фон модального окна
    UI.DrawRoundedRect(self.x, self.y, self.width, self.height, 8, theme.Background)
    
    -- Заголовок
    UI.DrawRoundedRect(self.x, self.y, self.width, 40, 8, theme.Surface)
    UI.DrawText(self.title, self.x + 15, self.y + 20, theme.Text, "left", "center")
    
    -- Контент
    UI.DrawText(self.content, self.x + 15, self.y + 60, theme.Text, "left", "top")
    
    -- Кнопки
    local buttonY = self.y + self.height - 50
    local buttonWidth = (self.width - 20) / #self.buttons
    
    for i, button in ipairs(self.buttons) do
        local buttonX = self.x + 10 + (i - 1) * buttonWidth
        UI.DrawRoundedRect(buttonX, buttonY, buttonWidth - 5, 30, 4, theme.Primary)
        UI.DrawText(button.text, buttonX + (buttonWidth - 5) / 2, buttonY + 15, {1.0, 1.0, 1.0, 1.0}, "center", "center")
    end
end

-- ===============================================
-- СИСТЕМА ХОТКЕЕВ
-- ===============================================

local HotkeySystem = {}
HotkeySystem.__index = HotkeySystem

function HotkeySystem:new()
    local obj = {
        hotkeys = {},
        listening = false,
        currentKey = nil
    }
    setmetatable(obj, HotkeySystem)
    return obj
end

function HotkeySystem:Register(key, callback, description)
    self.hotkeys[key] = {
        callback = callback,
        description = description or "",
        active = true
    }
end

function HotkeySystem:Unregister(key)
    self.hotkeys[key] = nil
end

function HotkeySystem:Update()
    -- Здесь должна быть логика проверки нажатий клавиш
    -- Зависит от конкретной среды выполнения
    for key, hotkey in pairs(self.hotkeys) do
        if hotkey.active and self:IsKeyPressed(key) then
            if hotkey.callback then
                hotkey.callback()
            end
        end
    end
end

function HotkeySystem:IsKeyPressed(key)
    -- Заглушка для проверки нажатия клавиши
    return false
end

function HotkeySystem:StartListening()
    self.listening = true
end

function HotkeySystem:StopListening()
    self.listening = false
end

-- ===============================================
-- УЛУЧШЕННЫЙ ОСНОВНОЙ КЛАСС UI
-- ===============================================

function UI:new(webhookUrl, databasePath)
    local obj = {
        components = {},
        watermarks = {},
        bindList = nil,
        notifications = {},
        searchSystem = SearchSystem:new(),
        contextMenu = nil,
        modal = nil,
        hotkeySystem = HotkeySystem:new(),
        uidSystem = UIDSystem:new(webhookUrl, databasePath),
        mouseX = 0,
        mouseY = 0,
        mousePressed = false,
        mouseReleased = false,
        lastMousePressed = false,
        screenWidth = 800,
        screenHeight = 600
    }
    setmetatable(obj, UI)
    
    -- Автоматическая регистрация пользователя при создании UI
    obj.uidSystem:RegisterUser()
    
    return obj
end

function UI:AddNotification(text, duration, type)
    local notification = Notification:new(text, duration, type)
    table.insert(self.notifications, notification)
    return notification
end

function UI:ShowContextMenu(x, y, items)
    if not self.contextMenu then
        self.contextMenu = ContextMenu:new()
    end
    
    for _, item in ipairs(items) do
        self.contextMenu:AddItem(item.text, item.callback)
    end
    
    self.contextMenu:Show(x, y)
end

function UI:ShowModal(title, content, width, height)
    if not self.modal then
        self.modal = Modal:new()
    end
    
    self.modal.title = title
    self.modal.content = content
    self.modal.width = width or 400
    self.modal.height = height or 300
    self.modal:Show()
    
    return self.modal
end

function UI:RegisterHotkey(key, callback, description)
    self.hotkeySystem:Register(key, callback, description)
end

function UI:SetScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
end

function UI:Update(mouseX, mouseY, mousePressed)
    self.mouseX = mouseX
    self.mouseY = mouseY
    self.mouseReleased = self.lastMousePressed and not mousePressed
    self.lastMousePressed = mousePressed
    
    -- Обновление анимаций
    UI.UpdateAnimations()
    
    -- Обновление компонентов
    for _, component in ipairs(self.components) do
        if component.Update then
            component:Update(mouseX, mouseY, mousePressed, self.mouseReleased)
        end
    end
    
    -- Обновление уведомлений
    for i = #self.notifications, 1, -1 do
        local notification = self.notifications[i]
        notification:Update()
        if not notification.visible then
            table.remove(self.notifications, i)
        end
    end
    
    -- Обновление контекстного меню
    if self.contextMenu then
        self.contextMenu:Update(mouseX, mouseY, mousePressed)
    end
    
    -- Обновление модального окна
    if self.modal then
        self.modal:Update(mouseX, mouseY, mousePressed)
    end
    
    -- Обновление водяных знаков
    for _, watermark in ipairs(self.watermarks) do
        if watermark.Update then
            watermark:Update()
        end
    end
    
    -- Обновление bind list
    if self.bindList then
        self.bindList:Update()
    end
    
    -- Обновление хоткеев
    self.hotkeySystem:Update()
end

function UI:Render(screenWidth, screenHeight)
    self.screenWidth = screenWidth or self.screenWidth
    self.screenHeight = screenHeight or self.screenHeight
    
    -- Рендер компонентов
    for _, component in ipairs(self.components) do
        if component.Render then
            component:Render()
        end
    end
    
    -- Рендер уведомлений
    local notificationY = 10
    for _, notification in ipairs(self.notifications) do
        notification.position = {self.screenWidth - 220, notificationY}
        notification:Render()
        notificationY = notificationY + 60
    end
    
    -- Рендер контекстного меню
    if self.contextMenu then
        self.contextMenu:Render()
    end
    
    -- Рендер модального окна
    if self.modal then
        self.modal:Render()
    end
    
    -- Рендер водяных знаков
    for _, watermark in ipairs(self.watermarks) do
        if watermark.Render then
            watermark:Render(self.screenWidth, self.screenHeight)
        end
    end
    
    -- Рендер bind list
    if self.bindList then
        self.bindList:Render()
    end
end

function UI:Search(query)
    self.searchSystem:SetQuery(query)
    return self.searchSystem:GetResults()
end

function UI:GetSearchResults()
    return self.searchSystem:GetResults()
end

-- ===============================================
-- МЕТОДЫ ДЛЯ РАБОТЫ С UID СИСТЕМОЙ
-- ===============================================

function UI:GetUID()
    if not self.uidSystem or not self.uidSystem.currentUser then
        return nil
    end
    return self.uidSystem.currentUser.uid
end

function UI:GetUserInfo()
    if not self.uidSystem then
        return nil
    end
    return self.uidSystem:GetUserInfo()
end

function UI:GetUserRank()
    if not self.uidSystem then
        return "Неизвестно"
    end
    return self.uidSystem:GetUserRank()
end

function UI:GetTotalUsers()
    if not self.uidSystem then
        return 0
    end
    return self.uidSystem:GetTotalUsers()
end

function UI:AddUIDDisplay(x, y, width, height)
    local uidDisplay = UIDDisplay:new(x, y, width, height, self.uidSystem)
    self:AddComponent(uidDisplay)
    return uidDisplay
end

function UI:UpdateUserActivity()
    if self.uidSystem then
        self.uidSystem:UpdateLastSeen()
    end
end

function UI:SendDiscordNotification(action)
    if self.uidSystem and self.uidSystem.currentUser then
        self.uidSystem:SendDiscordNotification(self.uidSystem.currentUser, action)
    end
end

-- ===============================================
-- ЭКСПОРТ
-- ===============================================

return UI

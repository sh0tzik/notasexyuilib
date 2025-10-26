-- ===============================================
-- BEAUTIFUL UI LIBRARY v1.1 - LOADSTRING VERSION
-- Современная UI библиотека с анимациями
-- ===============================================

local Library = {}

-- ===============================================
-- КОНФИГУРАЦИЯ И НАСТРОЙКИ
-- ===============================================

Library.Config = {
    FPS = 60,
    AnimationSpeed = 0.15,
    EasingType = "easeOutQuart",
    
    Colors = {
        Primary = {0.2, 0.6, 1.0, 1.0},
        Secondary = {0.3, 0.3, 0.3, 1.0},
        Success = {0.2, 0.8, 0.2, 1.0},
        Warning = {1.0, 0.6, 0.0, 1.0},
        Error = {1.0, 0.2, 0.2, 1.0},
        Background = {0.1, 0.1, 0.1, 0.95},
        Surface = {0.15, 0.15, 0.15, 0.95},
        Text = {1.0, 1.0, 1.0, 1.0},
        TextSecondary = {0.7, 0.7, 0.7, 1.0}
    },
    
    Fonts = {
        Default = "Arial",
        Bold = "Arial Bold",
        Small = "Arial Small"
    },
    
    Sizes = {
        ButtonHeight = 35,
        InputHeight = 30,
        SliderHeight = 20,
        SwitchSize = 50,
        TabHeight = 40
    }
}

-- ===============================================
-- СИСТЕМА ТЕМ
-- ===============================================

Library.Themes = {
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

Library.CurrentTheme = Library.Themes.Dark

-- ===============================================
-- СИСТЕМА UID
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
    self.users = {}
    self.nextUID = 1
end

function UIDSystem:RegisterUser()
    if self.isRegistered then
        return self.currentUser
    end
    
    local hwid = "HWID_" .. math.random(100000, 999999)
    local username = "User_" .. math.random(1000, 9999)
    
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
    
    return newUser
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

function UIDSystem:SendDiscordNotification(user, action)
    if not self.webhookUrl or self.webhookUrl == "" then
        print("⚠️ Discord вебхук не указан, уведомление не отправлено")
        return
    end
    
    print("📤 Отправка уведомления в Discord...")
    print("🔗 Webhook URL:", self.webhookUrl)
    
    local OSTime = os.time()
    local Time = os.date('!*t', OSTime)
    local Avatar = 'https://cdn.discordapp.com/embed/avatars/4.png'
    
    local embed = {
        title = "🔔 Новый пользователь зарегистрирован!",
        color = 0x00ff00, -- Зеленый цвет
        footer = { 
            text = "UI Library v1.1 | Система UID"
        },
        author = {
            name = "UI Library Bot",
            url = "https://github.com/yourusername/beautiful-ui-library"
        },
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
        timestamp = string.format('%d-%d-%dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
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
        avatar_url = Avatar,
        embeds = {embed}
    }
    
    -- Простая отправка HTTP запроса
    local success, response = pcall(function()
        local message = "🔔 **Новый пользователь зарегистрирован!**\n"
        message = message .. "👤 **Пользователь:** " .. user.username .. "\n"
        message = message .. "🆔 **UID:** #" .. user.uid .. "\n"
        message = message .. "📅 **Дата регистрации:** " .. user.joinDate .. "\n"
        message = message .. "🖥️ **HWID:** `" .. user.hwid .. "`\n"
        message = message .. "🏷️ **Ранг:** " .. self:GetUserRank()
        
        if action == "login" then
            message = "🟢 **Пользователь вошел в систему**\n"
            message = message .. "👤 **Пользователь:** " .. user.username .. "\n"
            message = message .. "🆔 **UID:** #" .. user.uid .. "\n"
            message = message .. "🕒 **Последний вход:** " .. user.lastSeen .. "\n"
            message = message .. "📊 **Всего сессий:** " .. (user.totalSessions or 1) .. "\n"
            message = message .. "🏷️ **Ранг:** " .. self:GetUserRank()
        end
        
        return (syn and syn.request or http_request) {
            Url = self.webhookUrl,
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json'
            },
            Body = '{"content":"' .. message .. '"}'
        }
    end)
    
    if success then
        print("✅ Уведомление отправлено в Discord!")
    else
        print("❌ Ошибка отправки в Discord:", response)
    end
end

-- ===============================================
-- СИСТЕМА АНИМАЦИЙ
-- ===============================================

local activeAnimations = {}

local Easing = {
    linear = function(t) return t end,
    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return t * (2 - t) end,
    easeInOutQuad = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end,
    easeOutQuart = function(t) return 1 - math.pow(1 - t, 4) end,
    easeOutBack = function(t) return 1 + 2.7 * math.pow(t - 1, 3) + 1.7 * math.pow(t - 1, 2) end
}

function Library.CreateAnimation(from, to, duration, easing, callback)
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

function Library.UpdateAnimations()
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
-- УТИЛИТЫ
-- ===============================================

function Library.Lerp(a, b, t)
    return a + (b - a) * t
end

function Library.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Library.Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Library.Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function Library.IsPointInRect(x, y, rectX, rectY, rectW, rectH)
    return x >= rectX and x <= rectX + rectW and y >= rectY and y <= rectY + rectH
end

-- ===============================================
-- ФУНКЦИИ РЕНДЕРИНГА (ЗАГЛУШКИ)
-- ===============================================

function Library.DrawRect(x, y, width, height, color)
    print(string.format("DrawRect: x=%.1f, y=%.1f, w=%.1f, h=%.1f, color=(%.2f,%.2f,%.2f,%.2f)", 
        x, y, width, height, color[1], color[2], color[3], color[4]))
end

function Library.DrawRoundedRect(x, y, width, height, radius, color)
    print(string.format("DrawRoundedRect: x=%.1f, y=%.1f, w=%.1f, h=%.1f, r=%.1f, color=(%.2f,%.2f,%.2f,%.2f)", 
        x, y, width, height, radius, color[1], color[2], color[3], color[4]))
end

function Library.DrawText(text, x, y, color, alignX, alignY)
    print(string.format("DrawText: '%s' at (%.1f,%.1f), color=(%.2f,%.2f,%.2f,%.2f), align=(%s,%s)", 
        text, x, y, color[1], color[2], color[3], color[4], alignX or "left", alignY or "center"))
end

function Library.DrawCircle(x, y, radius, color)
    print(string.format("DrawCircle: center=(%.1f,%.1f), r=%.1f, color=(%.2f,%.2f,%.2f,%.2f)", 
        x, y, radius, color[1], color[2], color[3], color[4]))
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
        type = type or "info",
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
    
    local theme = Library.CurrentTheme
    local color = theme.Primary
    
    if self.type == "success" then
        color = theme.Success or {0.2, 0.8, 0.2, 1.0}
    elseif self.type == "warning" then
        color = theme.Warning or {1.0, 0.6, 0.0, 1.0}
    elseif self.type == "error" then
        color = theme.Error or {1.0, 0.2, 0.2, 1.0}
    end
    
    Library.DrawRoundedRect(self.position[1], self.position[2], self.size[1], self.size[2], 8, theme.Background)
    Library.DrawText(self.text, self.position[1] + 10, self.position[2] + self.size[2] / 2, theme.Text, "left", "center")
    Library.DrawRoundedRect(self.position[1], self.position[2], 4, self.size[2], 2, color)
end

-- ===============================================
-- ОСНОВНОЙ КЛАСС UI
-- ===============================================

function Library:new(webhookUrl, databasePath)
    local obj = {
        components = {},
        watermarks = {},
        bindList = nil,
        notifications = {},
        uidSystem = UIDSystem:new(webhookUrl, databasePath),
        mouseX = 0,
        mouseY = 0,
        mousePressed = false,
        mouseReleased = false,
        lastMousePressed = false,
        screenWidth = 800,
        screenHeight = 600
    }
    setmetatable(obj, Library)
    
    -- Автоматическая регистрация пользователя
    obj.uidSystem:RegisterUser()
    
    return obj
end

function Library:AddComponent(component)
    table.insert(self.components, component)
end

function Library:AddNotification(text, duration, type)
    local notification = Notification:new(text, duration, type)
    table.insert(self.notifications, notification)
    return notification
end

function Library:GetUID()
    if not self.uidSystem or not self.uidSystem.currentUser then
        return nil
    end
    return self.uidSystem.currentUser.uid
end

function Library:GetUserInfo()
    if not self.uidSystem then
        return nil
    end
    return self.uidSystem:GetUserInfo()
end

function Library:GetUserRank()
    if not self.uidSystem then
        return "Неизвестно"
    end
    return self.uidSystem:GetUserRank()
end

function Library:SendDiscordNotification(action)
    if self.uidSystem and self.uidSystem.currentUser then
        self.uidSystem:SendDiscordNotification(self.uidSystem.currentUser, action)
    end
end

function Library:Update(mouseX, mouseY, mousePressed)
    self.mouseX = mouseX
    self.mouseY = mouseY
    self.mouseReleased = self.lastMousePressed and not mousePressed
    self.lastMousePressed = mousePressed
    
    -- Обновление анимаций
    Library.UpdateAnimations()
    
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
end

function Library:Render(screenWidth, screenHeight)
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
end

function Library:SetTheme(themeName)
    Library.CurrentTheme = Library.Themes[themeName] or Library.Themes.Dark
end

-- ===============================================
-- КОМПОНЕНТЫ
-- ===============================================

-- Переключатели
local Switch = {}
Switch.__index = Switch

function Switch:new(x, y, width, height, text, callback)
    local obj = {
        x = x or 0,
        y = y or 0,
        width = width or 60,
        height = height or 30,
        text = text or "",
        callback = callback,
        value = false,
        animationProgress = 0,
        hovered = false,
        pressed = false,
        visible = true,
        enabled = true
    }
    setmetatable(obj, Switch)
    return obj
end

function Switch:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    self.hovered = Library.IsPointInRect(mouseX, mouseY, self.x, self.y, self.width, self.height)
    
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
        Library.CreateAnimation(
            self.animationProgress,
            targetProgress,
            Library.Config.AnimationSpeed,
            Easing.easeOutBack,
            function(value) self.animationProgress = value end
        )
    end
end

function Switch:Render()
    if not self.visible then return end
    
    local theme = Library.CurrentTheme
    
    -- Фон переключателя
    local bgColor = self.hovered and {theme.Primary[1] * 0.3, theme.Primary[2] * 0.3, theme.Primary[3] * 0.3, 0.5} or theme.Surface
    Library.DrawRoundedRect(self.x, self.y, self.width, self.height, 15, bgColor)
    
    -- Переключатель
    local switchSize = self.height - 4
    local switchX = self.x + 2 + (self.width - switchSize - 4) * self.animationProgress
    local switchY = self.y + 2
    
    local switchColor = self.value and theme.Primary or {0.5, 0.5, 0.5, 1.0}
    Library.DrawRoundedRect(switchX, switchY, switchSize, switchSize, switchSize / 2, switchColor)
    
    -- Текст
    if self.text and self.text ~= "" then
        Library.DrawText(self.text, self.x + self.width + 10, self.y + self.height / 2, theme.Text, "left", "center")
    end
end

-- Ползунки
local Slider = {}
Slider.__index = Slider

function Slider:new(x, y, width, height, min, max, value, callback)
    local obj = {
        x = x or 0,
        y = y or 0,
        width = width or 200,
        height = height or 20,
        min = min or 0,
        max = max or 100,
        value = value or min,
        callback = callback,
        dragging = false,
        hovered = false,
        visible = true,
        enabled = true
    }
    setmetatable(obj, Slider)
    return obj
end

function Slider:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    self.hovered = Library.IsPointInRect(mouseX, mouseY, self.x, self.y, self.width, self.height)
    
    if mousePressed and self.hovered then
        self.dragging = true
    end
    
    if self.dragging then
        if mousePressed then
            local sliderX = Library.Clamp(mouseX - self.x, 0, self.width)
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
    
    local theme = Library.CurrentTheme
    
    -- Фон ползунка
    local bgColor = self.hovered and {theme.Primary[1] * 0.2, theme.Primary[2] * 0.2, theme.Primary[3] * 0.2, 0.5} or theme.Surface
    Library.DrawRoundedRect(self.x, self.y + self.height / 2 - 2, self.width, 4, 2, bgColor)
    
    -- Прогресс
    local progress = (self.value - self.min) / (self.max - self.min)
    local progressWidth = self.width * progress
    Library.DrawRoundedRect(self.x, self.y + self.height / 2 - 2, progressWidth, 4, 2, theme.Primary)
    
    -- Handle
    local handleX = self.x + progressWidth - 6
    local handleY = self.y + self.height / 2 - 6
    local handleColor = self.dragging and theme.Primary or (self.hovered and {theme.Primary[1] * 0.8, theme.Primary[2] * 0.8, theme.Primary[3] * 0.8, 1.0} or theme.Surface)
    Library.DrawRoundedRect(handleX, handleY, 12, 12, 6, handleColor)
    
    -- Значение
    Library.DrawText(string.format("%.1f", self.value), self.x + self.width + 10, self.y + self.height / 2, theme.Text, "left", "center")
end

-- Кнопки
local Button = {}
Button.__index = Button

function Button:new(x, y, width, height, text, callback)
    local obj = {
        x = x or 0,
        y = y or 0,
        width = width or 120,
        height = height or 35,
        text = text or "Button",
        callback = callback,
        hovered = false,
        pressed = false,
        visible = true,
        enabled = true
    }
    setmetatable(obj, Button)
    return obj
end

function Button:Update(mouseX, mouseY, mousePressed, mouseReleased)
    if not self.visible or not self.enabled then return end
    
    self.hovered = Library.IsPointInRect(mouseX, mouseY, self.x, self.y, self.width, self.height)
    
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
    
    local theme = Library.CurrentTheme
    
    local bgColor = self.pressed and {theme.Primary[1] * 0.8, theme.Primary[2] * 0.8, theme.Primary[3] * 0.8, 1.0} or 
                   (self.hovered and theme.Primary or theme.Surface)
    
    Library.DrawRoundedRect(self.x, self.y, self.width, self.height, 4, bgColor)
    Library.DrawText(self.text, self.x + self.width / 2, self.y + self.height / 2, theme.Text, "center", "center")
end

-- ===============================================
-- ГЛАВНЫЕ ФУНКЦИИ
-- ===============================================

function Library:CreateWindow(options)
    options = options or {}
    
    local window = {
        title = options.Title or "Window",
        x = options.Position and options.Position.X.Offset or 100,
        y = options.Position and options.Position.Y.Offset or 100,
        width = options.Size and options.Size.X.Offset or 400,
        height = options.Size and options.Size.Y.Offset or 300,
        visible = options.AutoShow ~= false,
        components = {}
    }
    
    return window
end

function Library:AddSwitch(x, y, width, height, text, callback)
    local switch = Switch:new(x, y, width, height, text, callback)
    self:AddComponent(switch)
    return switch
end

function Library:AddSlider(x, y, width, height, min, max, value, callback)
    local slider = Slider:new(x, y, width, height, min, max, value, callback)
    self:AddComponent(slider)
    return slider
end

function Library:AddButton(x, y, width, height, text, callback)
    local button = Button:new(x, y, width, height, text, callback)
    self:AddComponent(button)
    return button
end

function Library:Notify(text, duration, type)
    return self:AddNotification(text, duration, type)
end

function Library:SetTheme(themeName)
    Library.CurrentTheme = Library.Themes[themeName] or Library.Themes.Dark
end

-- ===============================================
-- ЭКСПОРТ
-- ===============================================

return Library

local BuyUnlimited = CreateFrame("Frame")
local ADDON_VERSION = "1.3"
local BUILD_NUMBER = "1.0.3"
local SAVED_ITEMS_FILE = "WTF/Account/" .. GetRealmName() .. "_" .. UnitName("player") .. "_BuyUnlimitedData.txt"
BuyUnlimited:RegisterEvent("ADDON_LOADED")
BuyUnlimited:RegisterEvent("PLAYER_LOGOUT")
BuyUnlimited:RegisterEvent("MERCHANT_SHOW")
BuyUnlimited:RegisterEvent("MERCHANT_CLOSED")

local currentSlot = nil
BuyUnlimited.savedVariables = nil

local CHANGELOG = BuyUnlimitedChangelog

local L = {
    ["enUS"] = {
        ["ENTER_AMOUNT"] = "Enter amount:",
        ["TOTAL_COST"] = "Total cost:",
        ["NOT_ENOUGH"] = "You need:",
        ["ERROR_MULTIPLE"] = "|cffff0000Error:|r Amount must be multiple of %d",
        ["PURCHASED"] = "|cff00ff00Purchased:|r %d items (%d purchases of %d)",
        ["REPEAT_PURCHASE"] = "Auto-Buy",
        ["TOOLTIP_TITLE"] = "Repeat Purchase",
        ["TOOLTIP_EMPTY"] = "Empty",
        ["TOOLTIP_LEFT_CLICK"] = "|cffffffffLeft Click:|r Buy saved items",
        ["TOOLTIP_RIGHT_CLICK"] = "|cffffffffRight Click:|r Open/close auto-buy settings",
        ["ERROR_BAG_SPACE"] = "|cffff0000Error:|r Not enough bag space for |cffffd100%s|r (free slots: |cffffd100%d|r)",
        ["AUTO_PURCHASE"] = "Auto-purchase |cffffd100%s|r quantity |cff00ff00%d|r",
        ["NO_ITEMS"] = "|cffff0000No items in auto-buy list|r",
        ["ITEM_REMOVED"] = "|cffffd100%s|r removed from auto-buy list",
        ["ITEM_ADDED"] = "|cffffd100%s|r added to list with quantity |cff00ff00%d|r",
        ["WELCOME_1"] = "|cffffcc00BuyUnlimited|r |cff999999v2.1|r",
        ["WELCOME_2"] = "|cff33ccffAddon successfully loaded!|r",
        ["WELCOME_3"] = "|cff999999Shift + Right Click to buy|r",
        ["PURCHASE_TIMER"] = "|cff00ff00Buying|r %s: |cffffd100%d of %d|r remaining (|cff33ccff%.1f sec|r)",
        ["DELAY_SECONDS"] = "sec",
        ["DELAY_TOOLTIP"] = "Purchase delay (0.15 - 5.0 seconds)",
        ["CHANGELOG_TITLE"] = "BuyUnlimited - Change Log",
        ["CHECK_UPDATES"] = "Check for updates on CurseForge!",
        ["BUILD"] = "Build",
        ["AVAILABLE_COMMANDS"] = "Available commands:",
        ["FIX_COMMAND_DESC"] = "/bu fix - show changelog",
        ["ADDON_UPDATED"] = "|cffffcc00BuyUnlimited|r updated to version %s (build %s)",
        ["ENTER_COMMAND"] = "Enter |cff33ccff/bu fix|r to view changelog",
        ["NOT_ENOUGH_AVAILABLE"] = "Only %d items available"
    },
    ["ruRU"] = {
        ["ENTER_AMOUNT"] = "Введите количество:",
        ["TOTAL_COST"] = "Общая стоимость:",
        ["NOT_ENOUGH"] = "Вам не хватает:",
        ["ERROR_MULTIPLE"] = "|cffff0000Ошибка:|r Количество должно быть кратно %d",
        ["PURCHASED"] = "|cff00ff00Куплено:|r %d предметов (%d покупок по %d)",
        ["REPEAT_PURCHASE"] = "Автопокупка",
        ["TOOLTIP_TITLE"] = "Повторить покупку",
        ["TOOLTIP_EMPTY"] = "Пусто",
        ["TOOLTIP_LEFT_CLICK"] = "|cffffffffЛевый клик:|r Купить сохранённые предметы",
        ["TOOLTIP_RIGHT_CLICK"] = "|cffffffffПравый клик:|r Открыть/закрыть настройки автопокупки",
        ["ERROR_BAG_SPACE"] = "|cffff0000Ошибка:|r Недостаточно места в сумках для |cffffd100%s|r (свободно |cffffd100%d|r слотов)",
        ["AUTO_PURCHASE"] = "Автопокупка |cffffd100%s|r в количестве |cff00ff00%d|r",
        ["NO_ITEMS"] = "|cffff0000Нет предметов для покупки в списке|r",
        ["ITEM_REMOVED"] = "|cffffd100%s|r убран из списка автопокупки",
        ["ITEM_ADDED"] = "|cffffd100%s|r добавлен в список в количестве |cff00ff00%d|r",
        ["WELCOME_1"] = "|cffffcc00BuyUnlimited|r |cff999999v2.1|r",
        ["WELCOME_2"] = "|cff33ccffАддон успешно загружен!|r",
        ["WELCOME_3"] = "|cff999999Shift + ПКМ для покупки|r",
        ["PURCHASE_TIMER"] = "|cff00ff00Покупка|r %s: |cffffd100%d из %d|r осталось (|cff33ccff%.1f сек|r)",
        ["DELAY_SECONDS"] = "сек",
        ["DELAY_TOOLTIP"] = "Задержка покупки (0.15 - 5.0 секунд)",
        ["CHANGELOG_TITLE"] = "BuyUnlimited - История изменений",
        ["CHECK_UPDATES"] = "Проверяйте обновления на CurseForge!",
        ["BUILD"] = "Билд",
        ["AVAILABLE_COMMANDS"] = "Доступные команды:",
        ["FIX_COMMAND_DESC"] = "/bu fix - показать историю изменений",
        ["ADDON_UPDATED"] = "|cffffcc00BuyUnlimited|r обновлен до версии %s (build %s)",
        ["ENTER_COMMAND"] = "Введите |cff33ccff/bu fix|r для просмотра списка изменений",
        ["NOT_ENOUGH_AVAILABLE"] = "Доступно только %d предметов"
    }
}

local locale = GetLocale()
if not L[locale] then locale = "enUS" end

local ChangelogFrame = CreateFrame("Frame", "BuyUnlimitedChangelogFrame", UIParent, "BasicFrameTemplateWithInset")
ChangelogFrame:Hide()
ChangelogFrame:SetSize(400, 600)
ChangelogFrame:SetPoint("CENTER")
ChangelogFrame:SetMovable(true)
ChangelogFrame:EnableMouse(true)
ChangelogFrame:RegisterForDrag("LeftButton")
ChangelogFrame:SetScript("OnDragStart", ChangelogFrame.StartMoving)
ChangelogFrame:SetScript("OnDragStop", ChangelogFrame.StopMovingOrSizing)

ChangelogFrame.scrollFrame = CreateFrame("ScrollFrame", nil, ChangelogFrame, "UIPanelScrollFrameTemplate")
ChangelogFrame.scrollFrame:SetPoint("TOPLEFT", 12, -30)
ChangelogFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

ChangelogFrame.content = CreateFrame("Frame", nil, ChangelogFrame.scrollFrame)
ChangelogFrame.content:SetSize(360, 1)
ChangelogFrame.scrollFrame:SetScrollChild(ChangelogFrame.content)

local function UpdateChangelogContent()
    local yOffset = 0
    local lineHeight = 16
    local buildSpacing = 25
    local maxWidth = 360
    local paddingLeft = 15
    local lineSpacing = 8
    
    local updateInfo = ChangelogFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    updateInfo:SetPoint("TOPLEFT", 5, -yOffset)
    updateInfo:SetText("|cff33ccff" .. L[locale]["CHECK_UPDATES"] .. "|r")
    
    yOffset = yOffset + lineHeight + buildSpacing
    
    local sortedBuilds = {}
    for build in pairs(CHANGELOG) do
        table.insert(sortedBuilds, build)
    end
    table.sort(sortedBuilds, function(a, b)
        local a1, a2, a3 = string.match(a, "(%d+)%.(%d+)%.(%d+)")
        local b1, b2, b3 = string.match(b, "(%d+)%.(%d+)%.(%d+)")
        a1, a2, a3 = tonumber(a1), tonumber(a2), tonumber(a3)
        b1, b2, b3 = tonumber(b1), tonumber(b2), tonumber(b3)
        
        if a1 ~= b1 then return a1 > b1 end
        if a2 ~= b2 then return a2 > b2 end
        return a3 > b3
    end)
    
    for _, build in ipairs(sortedBuilds) do
        local changes = CHANGELOG[build]
        
        local buildTitle = ChangelogFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        buildTitle:SetPoint("TOPLEFT", 5, -yOffset)
        buildTitle:SetText("|cff999999" .. L[locale]["BUILD"] .. " " .. build .. "|r")
        
        yOffset = yOffset + lineHeight + lineSpacing
        
        for _, change in ipairs(changes[locale] or changes["enUS"]) do
            local changeLine = ChangelogFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            changeLine:SetPoint("TOPLEFT", paddingLeft, -yOffset)
            changeLine:SetWidth(maxWidth - paddingLeft - 5)
            changeLine:SetJustifyH("LEFT")
            changeLine:SetWordWrap(true)
            changeLine:SetText("• " .. change)
            
            local textHeight = changeLine:GetHeight()
            yOffset = yOffset + textHeight + lineSpacing
        end
        
        yOffset = yOffset + buildSpacing
    end
    
    ChangelogFrame.content:SetHeight(yOffset)
end

local function ShowChangelog()
    if not ChangelogFrame.contentCreated then
        UpdateChangelogContent()
        ChangelogFrame.contentCreated = true
    end
    
    local updateInfo = ChangelogFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    updateInfo:SetPoint("BOTTOM", 0, -10)
    updateInfo:SetText("|cff33ccff" .. L[locale]["CHECK_UPDATES"] .. "|r")
    
    ChangelogFrame:Show()
end

local purchaseTimer = CreateFrame("Frame", "BuyUnlimitedPurchaseTimer", UIParent)
purchaseTimer:SetSize(400, 50)
purchaseTimer:SetPoint("TOP", 0, -100)
purchaseTimer.text = purchaseTimer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
purchaseTimer.text:SetPoint("CENTER")
purchaseTimer:Hide()

local function ShowPurchaseTimer(itemLink, remainingPurchases, totalPurchases)
    purchaseTimer.text:SetText(string.format(
        L[locale]["PURCHASE_TIMER"], 
        itemLink, 
        remainingPurchases, 
        totalPurchases, 
        remainingPurchases * 0.25
    ))
    
    if not purchaseTimer:IsShown() then
        purchaseTimer:Show()
        
        if not purchaseTimer.fadeIn then
            purchaseTimer.fadeIn = purchaseTimer:CreateAnimationGroup()
            local fade = purchaseTimer.fadeIn:CreateAnimation("Alpha")
            fade:SetFromAlpha(0)
            fade:SetToAlpha(1)
            fade:SetDuration(0.2)
        end
        purchaseTimer.fadeIn:Play()
    end
end

local function HidePurchaseTimer()
    if purchaseTimer:IsShown() then
        if not purchaseTimer.fadeOut then
            purchaseTimer.fadeOut = purchaseTimer:CreateAnimationGroup()
            local fade = purchaseTimer.fadeOut:CreateAnimation("Alpha")
            fade:SetFromAlpha(1)
            fade:SetToAlpha(0)
            fade:SetDuration(0.2)
            purchaseTimer.fadeOut:SetScript("OnFinished", function()
                purchaseTimer:Hide()
            end)
        end
        purchaseTimer.fadeOut:Play()
    end
end

local GUI_SETTINGS = {

    PADDING = {
        TOP_TEXT = -30,     
        EDIT_BOX = 45,     
        PRICE_TEXT = 55,   
        BUTTONS = 45,       
    },
    

    WINDOW = {
        WIDTH = 200,        
        HEIGHT_BONUS = 70,  
    },
    

    BUTTONS = {
        SPACING = 5,        
    },
    

    TOOLTIP = {
        OFFSET_X = 5,      
        OFFSET_Y = 0,      
    },
    

    REPEAT_BUTTON = {
        WIDTH = 100,
        HEIGHT = 22,
        BOTTOM_OFFSET = 15,  
    },
    

    AUTOBOY_WINDOW = {
        WIDTH = 600,
        HEIGHT = 400,
        ITEM_HEIGHT = 30,     
        INPUT_WIDTH = 40,     
    }
}

local function PrintMessage(message)
    print("|cff00ff00BuyUnlimited|r|cffffffff:|r " .. message)
end


local function ShowWelcomeMessage()
    if not BuyUnlimitedDB.lastSeenBuild then
        BuyUnlimitedDB.lastSeenBuild = BUILD_NUMBER
    elseif BuyUnlimitedDB.lastSeenBuild ~= BUILD_NUMBER then
        print(string.format(L[locale]["ADDON_UPDATED"], ADDON_VERSION, BUILD_NUMBER))
        print(L[locale]["ENTER_COMMAND"])
        BuyUnlimitedDB.lastSeenBuild = BUILD_NUMBER
    end
end

local function InitSavedVariables()
    if not BuyUnlimitedDB then
        BuyUnlimitedDB = {
            vendors = {},
            welcomeShown = false,
            purchaseDelay = 0.20,
            lastSeenBuild = BUILD_NUMBER
        }
    end
    if not BuyUnlimitedDB.vendors then
        BuyUnlimitedDB.vendors = {}
    end
    if BuyUnlimitedDB.welcomeShown == nil then 
        BuyUnlimitedDB.welcomeShown = false
    end
    if BuyUnlimitedDB.purchaseDelay == nil then
        BuyUnlimitedDB.purchaseDelay = 0.20
    end
    BuyUnlimited.savedVariables = BuyUnlimitedDB
    savedVendorData = BuyUnlimited.savedVariables.vendors
end

local function GetVendorIdentifier()
    local guid = UnitGUID("npc")
    local name = UnitName("npc")
    return guid and name and (guid .. "_" .. name) or nil
end


local function SaveVendorSettings(vendorID, itemID, count)
    if not savedVendorData[vendorID] then
        savedVendorData[vendorID] = {
            items = {},
            name = UnitName("npc")
        }
    end
    
    local itemLink = GetMerchantItemLink(itemID)
    if count and count > 0 then
        savedVendorData[vendorID].items[itemID] = count
    else
        savedVendorData[vendorID].items[itemID] = nil
    end
    
    BuyUnlimitedDB.vendors = savedVendorData
end


local function FormatMoney(copper)
    local gold = floor(copper / 10000)
    local silver = floor((copper % 10000) / 100)
    local bronze = copper % 100
    
    local text = ""
    if gold > 0 then
        text = text .. gold .. "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t "
    end
    if silver > 0 or gold > 0 then
        text = text .. silver .. "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t "
    end
    text = text .. bronze .. "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t"
    
    return text
end

local function HasEnoughMoney(requiredCopper)
    return GetMoney() >= requiredCopper
end

local function GetItemCurrencyInfo(slot)
    local itemLink = GetMerchantItemLink(slot)
    if not itemLink then return nil end
    
    local _, _, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost = GetMerchantItemInfo(slot)
    if not extendedCost then
        return {
            type = "gold",
            price = price,
            stackCount = stackCount,
            numAvailable = numAvailable,
            icon = nil
        }
    end
    
    local currencies = {}
    for i = 1, GetMerchantItemCostInfo(slot) do
        local texture, itemCount, itemLink, currencyName = GetMerchantItemCostItem(slot, i)
        if texture then
            local currentCount = 0
            if itemLink then
                if currencyName then
                    local info = C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink)
                    currentCount = info and info.quantity or 0
                else
                    currentCount = GetItemCount(itemLink, true) or 0
                end
            end
            
            table.insert(currencies, {
                texture = texture,
                count = itemCount,
                name = currencyName or itemLink,
                current = currentCount
            })
        end
    end
    
    return {
        type = "currency",
        currencies = currencies,
        stackCount = stackCount,
        numAvailable = numAvailable
    }
end

local function FormatCurrency(currencyInfo, count)
    if not currencyInfo then return "" end
    
    if currencyInfo.type == "gold" then
        return FormatMoney((count / currencyInfo.stackCount) * currencyInfo.price)
    else
        local text = ""
        for _, currency in ipairs(currencyInfo.currencies) do
            local required = math.ceil(count / currencyInfo.stackCount) * currency.count
            if text ~= "" then
                text = text .. " "
            end
            text = text .. required .. " |T" .. currency.texture .. ":12:12:2:0|t"
        end
        return text
    end
end

-- just called by 'HandleShiftRightClick' function below, MerchantItemButton only.
local function DisableStackSplit()
    if _G["StackSplitFrame"] then
        _G["StackSplitFrame"]:Hide()
        -- don't override the default function, they can be using on container frame.
        -- _G["StackSplitFrame"].RegisterForClicks = function() end
        -- _G["StackSplitFrame"].Show = function() end
    end
end

local function GetBagFreeSpace()
    local totalFree = 0
    for bag = 0, NUM_BAG_SLOTS do
        local numFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(bag)
        if numFreeSlots and bagType == 0 then 
            totalFree = totalFree + numFreeSlots
        end
    end
    return totalFree
end


local function CanBuyAmount(count)
    local _, _, _, vendorStackSize = GetMerchantItemInfo(currentSlot)
    local itemLink = GetMerchantItemLink(currentSlot)
    local _, _, _, _, _, _, _, maxStackSize = GetItemInfo(itemLink)
    
    if vendorStackSize > 1 then
        if count % vendorStackSize ~= 0 then
            count = math.ceil(count / vendorStackSize) * vendorStackSize
        end
    end
    
    local requiredSlots = math.ceil(count / maxStackSize)
    local freeSpace = GetBagFreeSpace()
    
    return freeSpace >= requiredSlots, freeSpace, count, vendorStackSize, maxStackSize
end

local AutobuyFrame = CreateFrame("Frame", "BuyUnlimitedAutobuyFrame", UIParent, "BasicFrameTemplateWithInset")
AutobuyFrame:Hide()
AutobuyFrame:SetSize(GUI_SETTINGS.AUTOBOY_WINDOW.WIDTH, GUI_SETTINGS.AUTOBOY_WINDOW.HEIGHT)
AutobuyFrame:SetPoint("CENTER")
AutobuyFrame:SetMovable(true)
AutobuyFrame:EnableMouse(true)
AutobuyFrame:RegisterForDrag("LeftButton")
AutobuyFrame:SetScript("OnDragStart", AutobuyFrame.StartMoving)
AutobuyFrame:SetScript("OnDragStop", AutobuyFrame.StopMovingOrSizing)

AutobuyFrame.title = AutobuyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
AutobuyFrame.title:SetPoint("TOPLEFT", 10, -5)

AutobuyFrame.totalCost = AutobuyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
AutobuyFrame.totalCost:SetPoint("TOPRIGHT", -30, -5)

AutobuyFrame.scrollFrame = CreateFrame("ScrollFrame", nil, AutobuyFrame, "UIPanelScrollFrameTemplate")
AutobuyFrame.scrollFrame:SetPoint("TOPLEFT", 10, -30)
AutobuyFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)

AutobuyFrame.itemContainer = CreateFrame("Frame", nil, AutobuyFrame.scrollFrame)
AutobuyFrame.scrollFrame:SetScrollChild(AutobuyFrame.itemContainer)

AutobuyFrame.buyButton = CreateFrame("Button", nil, AutobuyFrame, "UIPanelButtonTemplate")
AutobuyFrame.buyButton:SetSize(100, 22)
AutobuyFrame.buyButton:SetPoint("BOTTOMRIGHT", -10, 10)
AutobuyFrame.buyButton:SetText(ACCEPT)

AutobuyFrame.buyButton:SetScript("OnClick", function()
    local vendorID = GetVendorIdentifier()
    if vendorID then
        local newItems = {}
        for _, child in pairs({AutobuyFrame.itemContainer:GetChildren()}) do
            if child.itemData then
                local count = tonumber(child.input:GetText()) or 0
                if count > 0 then
                    newItems[child.itemData.slot] = count
                end
            end
        end
        
        if savedVendorData[vendorID] then
            for slot, count in pairs(savedVendorData[vendorID].items) do
                if count > 0 and (not newItems[slot] or newItems[slot] == 0) then
                    local itemLink = GetMerchantItemLink(slot)
                    if itemLink then
                        PrintMessage(string.format(L[locale]["ITEM_REMOVED"], itemLink))
                    end
                end
            end
        end
        
        for slot, count in pairs(newItems) do
            local oldCount = (savedVendorData[vendorID] and savedVendorData[vendorID].items[slot]) or 0
            if count ~= oldCount then
                local itemLink = GetMerchantItemLink(slot)
                if itemLink then
                    PrintMessage(string.format(L[locale]["ITEM_ADDED"], itemLink, count))
                end
            end
        end
        
        if not savedVendorData[vendorID] then
            savedVendorData[vendorID] = {
                items = {},
                name = UnitName("npc")
            }
        end
        savedVendorData[vendorID].items = newItems
        BuyUnlimitedDB.vendors = savedVendorData
    end
    
    AutobuyFrame:Hide()
end)

AutobuyFrame.cancelButton = CreateFrame("Button", nil, AutobuyFrame, "UIPanelButtonTemplate")
AutobuyFrame.cancelButton:SetSize(100, 22)
AutobuyFrame.cancelButton:SetPoint("BOTTOMLEFT", 10, 10)
AutobuyFrame.cancelButton:SetText(CANCEL)
AutobuyFrame.cancelButton:SetScript("OnClick", function()
    AutobuyFrame:Hide()
end)

local function CreateItemRow(parent, itemData, index)
    local row = CreateFrame("Frame", nil, parent)
    row.itemData = itemData  
    row:SetSize(GUI_SETTINGS.AUTOBOY_WINDOW.WIDTH - 40, GUI_SETTINGS.AUTOBOY_WINDOW.ITEM_HEIGHT)
    row:SetPoint("TOPLEFT", 0, -(index - 1) * GUI_SETTINGS.AUTOBOY_WINDOW.ITEM_HEIGHT)
    
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(GUI_SETTINGS.AUTOBOY_WINDOW.ITEM_HEIGHT - 2, GUI_SETTINGS.AUTOBOY_WINDOW.ITEM_HEIGHT - 2)
    row.icon:SetPoint("LEFT", 2, 0)
    row.icon:SetTexture(itemData.texture)
    
    row.input = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    row.input:SetSize(GUI_SETTINGS.AUTOBOY_WINDOW.INPUT_WIDTH, 20)
    row.input:SetPoint("RIGHT", -5, 0)
    row.input:SetNumeric(true)
    row.input:SetMaxLetters(4)
    row.input:SetAutoFocus(false)
    
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 5, 0)
    row.name:SetPoint("RIGHT", row.input, "LEFT", -5, 0) 
    row.name:SetText(itemData.link)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    
    row.priceText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.priceText:SetPoint("TOP", row.input, "BOTTOM", 0, -2)
    
    row.icon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("RIGHT", row, "LEFT", -5, 0)
        GameTooltip:SetHyperlink(itemData.link)
        GameTooltip:Show()
    end)
    
    row.icon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    row.iconButton = CreateFrame("Button", nil, row)
    row.iconButton:SetAllPoints(row.icon)
    row.iconButton:EnableMouse(true)
    row.iconButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("RIGHT", row, "LEFT", -5, 0)
        GameTooltip:SetHyperlink(itemData.link)
        GameTooltip:Show()
    end)
    
    row.iconButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    row.input:SetScript("OnTextChanged", function(self)
        local count = tonumber(self:GetText()) or 0
        
        if count > 0 then
            row.name:SetAlpha(1)
        else
            row.name:SetAlpha(0.5)
        end
        
        row.priceText:SetText("")
        
        if parent and parent:GetParent() and parent:GetParent():GetParent() then
            local autobuyFrame = parent:GetParent():GetParent()
            if autobuyFrame.UpdateTotalCost then
                autobuyFrame:UpdateTotalCost()
            end
        end
    end)
    
    local vendorID = GetVendorIdentifier()
    if vendorID and savedVendorData[vendorID] and savedVendorData[vendorID].items[itemData.slot] then
        row.input:SetText(savedVendorData[vendorID].items[itemData.slot])
        row.name:SetAlpha(1)
    else
        row.name:SetAlpha(0.5)
    end
    
    return row
end

local function PerformAutobuy()
    local vendorID = GetVendorIdentifier()
    if not vendorID or not savedVendorData[vendorID] then return end
    
    local function BuyItemWithDelay(slot, count, stackCount, remaining, totalPurchases)
        if remaining <= 0 then
            local itemLink = GetMerchantItemLink(slot)
            PrintMessage(string.format(L[locale]["PURCHASED"], count, totalPurchases, stackCount))
            HidePurchaseTimer()
            return
        end
        
        local itemLink = GetMerchantItemLink(slot)
        ShowPurchaseTimer(itemLink, remaining, totalPurchases)
        
        if stackCount > 1 then
            BuyMerchantItem(slot)
        else

            BuyMerchantItem(slot, 1)
        end
        
        C_Timer.After(BuyUnlimitedDB.purchaseDelay, function()
            BuyItemWithDelay(slot, count, stackCount, remaining - 1, totalPurchases)
        end)
    end

    local purchaseCount = 0
    for slot, count in pairs(savedVendorData[vendorID].items) do
        if count and count > 0 then
            local itemLink = GetMerchantItemLink(slot)
            local _, _, _, stackCount = GetMerchantItemInfo(slot)
            local _, _, _, _, _, _, _, maxStack = GetItemInfo(itemLink)
            
            local canBuy, freeSpace = CanBuyAmount(count, stackCount or maxStack or 1)
            if not canBuy then
                PrintMessage(string.format(L[locale]["ERROR_BAG_SPACE"], itemLink, freeSpace))
                return
            end
            
            if stackCount and stackCount > 1 then
                local numPurchases = math.ceil(count / stackCount)
                local actualCount = numPurchases * stackCount
                BuyItemWithDelay(slot, actualCount, stackCount, numPurchases, numPurchases)
            else
                BuyItemWithDelay(slot, count, 1, count, count)
            end
            purchaseCount = purchaseCount + 1
        end
    end
    
    if purchaseCount == 0 then
        PrintMessage(L[locale]["NO_ITEMS"])
    end
end

function AutobuyFrame:UpdateTotalCost()
    local totalGold = 0
    local totalCurrencies = {}
    
    local vendorID = GetVendorIdentifier()
    if vendorID then
        for _, child in pairs({self.itemContainer:GetChildren()}) do
            if child.itemData then
                local count = tonumber(child.input:GetText()) or 0
                if count > 0 then
                    local currencyInfo = GetItemCurrencyInfo(child.itemData.slot)
                    if currencyInfo then
                        if currencyInfo.type == "gold" then
                            totalGold = totalGold + ((count / currencyInfo.stackCount) * currencyInfo.price)
                        else
                            for _, currency in ipairs(currencyInfo.currencies) do
                                local required = math.ceil(count / currencyInfo.stackCount) * currency.count
                                totalCurrencies[currency.texture] = (totalCurrencies[currency.texture] or 0) + required
                            end
                        end
                    end
                end
            end
        end
    end
    
    local costText = ""
    if totalGold > 0 then
        costText = FormatMoney(totalGold)
    end
    
    for texture, count in pairs(totalCurrencies) do
        if costText ~= "" then
            costText = costText .. " | "
        end
        costText = costText .. count .. " |T" .. texture .. ":12:12:2:0|t"
    end
    
    if costText ~= "" then
        self.totalCost:SetText("(" .. costText .. ")")
    else
        self.totalCost:SetText("")
    end
end

local function UpdateAutobuyList()
    for _, child in pairs({AutobuyFrame.itemContainer:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local vendorID = GetVendorIdentifier()
    if not vendorID then return end
    
    AutobuyFrame.title:SetText(UnitName("npc"))
    AutobuyFrame.totalCost:SetText("")
    
    local items = {}
    for i = 1, GetMerchantNumItems() do
        local link = GetMerchantItemLink(i)
        if link then
            local name, texture, price, stackCount = GetMerchantItemInfo(i)
            local plainName = link:match("%[(.-)%]")
            table.insert(items, {
                link = link,
                texture = texture,
                price = price,
                stackCount = stackCount,
                slot = i,
                name = plainName or name
            })
        end
    end
    
    if locale == "ruRU" then
        table.sort(items, function(a, b)
            return a.name < b.name
        end)
    else
        table.sort(items, function(a, b)
            return string.lower(a.name) < string.lower(b.name)
        end)
    end
    
    local height = 0
    for i, itemData in ipairs(items) do
        local row = CreateItemRow(AutobuyFrame.itemContainer, itemData, i)
        height = height + GUI_SETTINGS.AUTOBOY_WINDOW.ITEM_HEIGHT
    end
    
    AutobuyFrame.itemContainer:SetSize(GUI_SETTINGS.AUTOBOY_WINDOW.WIDTH - 40, height)
    AutobuyFrame:UpdateTotalCost()
end

StaticPopupDialogs["BuyUnlimited_AMOUNT"] = {
    text = L[locale]["ENTER_AMOUNT"],
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 4,
    width = GUI_SETTINGS.WINDOW.WIDTH,
    OnShow = function(self)
        self.editBox:SetNumeric(true)
        self.editBox:SetFocus()
        

        if not self.priceText then
            self.priceText = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        end
        

        if currentSlot then
            local itemLink = GetMerchantItemLink(currentSlot)
            if itemLink then
                self.text:SetText(itemLink.." - "..L[locale]["ENTER_AMOUNT"])
                
                local _, _, price, _, _, _, _, extendedCost = GetMerchantItemInfo(currentSlot)
                if not extendedCost then
                    self.itemPrice = price
                else
                    self.itemPrice = nil
                end
                self.priceText:SetText(L[locale]["TOTAL_COST"].." 0")
                

                if not self.tooltipFrame then
                    self.tooltipFrame = CreateFrame("GameTooltip", "BuyUnlimitedTooltip", self, "GameTooltipTemplate")
                end
                self.tooltipFrame:SetOwner(self, "ANCHOR_NONE")
                self.tooltipFrame:SetPoint("LEFT", self, "RIGHT", GUI_SETTINGS.TOOLTIP.OFFSET_X, GUI_SETTINGS.TOOLTIP.OFFSET_Y)
                self.tooltipFrame:SetHyperlink(itemLink)
                self.tooltipFrame:Show()
            end
        end
        

        if not self.repeatButton then
            self.repeatButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
            self.repeatButton:SetSize(GUI_SETTINGS.REPEAT_BUTTON.WIDTH, GUI_SETTINGS.REPEAT_BUTTON.HEIGHT)
            self.repeatButton:SetPoint("BOTTOM", 0, GUI_SETTINGS.REPEAT_BUTTON.BOTTOM_OFFSET)
            self.repeatButton:SetText(L[locale]["REPEAT_PURCHASE"])
            
            self.delayEdit = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
            self.delayEdit:SetSize(40, 20)
            self.delayEdit:SetPoint("LEFT", self.repeatButton, "RIGHT", 10, 0)
            self.delayEdit:SetNumeric(false)
            self.delayEdit:SetMaxLetters(4)
            self.delayEdit:SetAutoFocus(false)
            self.delayEdit:SetText(format("%.2f", BuyUnlimitedDB.purchaseDelay))
            
            self.delayLabel = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.delayLabel:SetPoint("LEFT", self.delayEdit, "RIGHT", 5, 0)
            self.delayLabel:SetText(L[locale]["DELAY_SECONDS"])

            self.delayEdit:SetScript("OnChar", function(editBox, char)
                local text = editBox:GetText()
                if not char:match("[%d%.]") then
                    editBox:SetText(text:sub(1, -2))
                end

                if char == "." and text:match("%..*%.") then
                    editBox:SetText(text:sub(1, -2))
                end
            end)

            self.delayEdit:SetScript("OnTextChanged", function(editBox)
                local newDelay = tonumber(editBox:GetText())
                if newDelay and newDelay >= 0.1 and newDelay <= 5.0 then
                    BuyUnlimitedDB.purchaseDelay = newDelay
                end
            end)

            self.delayEdit:SetScript("OnEditFocusLost", function(editBox)
                editBox:SetText(format("%.2f", BuyUnlimitedDB.purchaseDelay))
            end)

            self.delayEdit:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                GameTooltip:SetText(L[locale]["DELAY_TOOLTIP"])
                GameTooltip:Show()
            end)
            
            self.delayEdit:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            self.repeatButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                GameTooltip:AddLine(L[locale]["TOOLTIP_TITLE"])
                GameTooltip:AddLine(L[locale]["TOOLTIP_LEFT_CLICK"])
                GameTooltip:AddLine(L[locale]["TOOLTIP_RIGHT_CLICK"])
                GameTooltip:Show()
            end)
            
            self.repeatButton:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            
            self.repeatButton:SetScript("OnClick", function(button, buttonPressed)
                if buttonPressed == "LeftButton" then
                    PerformAutobuy()
                elseif buttonPressed == "RightButton" then
                    if AutobuyFrame:IsShown() then
                        AutobuyFrame:Hide()
                    else
                        UpdateAutobuyList()
                        AutobuyFrame:Show()
                    end
                end
            end)
            
            self.repeatButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        end
        

        self:ClearAllPoints()
        self:SetPoint("CENTER", MerchantFrame, "CENTER", 0, 0)
        

        self.text:SetPoint("TOP", 0, GUI_SETTINGS.PADDING.TOP_TEXT)
        self.editBox:SetPoint("TOP", self.text, "BOTTOM", 0, GUI_SETTINGS.PADDING.EDIT_BOX)
        self.priceText:SetPoint("TOP", self.editBox, "BOTTOM", 0, GUI_SETTINGS.PADDING.PRICE_TEXT)
        

        self.button1:ClearAllPoints()
        self.button2:ClearAllPoints()
        self.button1:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -GUI_SETTINGS.BUTTONS.SPACING, GUI_SETTINGS.PADDING.BUTTONS)
        self.button2:SetPoint("BOTTOMLEFT", self, "BOTTOM", GUI_SETTINGS.BUTTONS.SPACING, GUI_SETTINGS.PADDING.BUTTONS)
        

        self:SetHeight(self:GetHeight() + GUI_SETTINGS.WINDOW.HEIGHT_BONUS)
    end,
    
    OnHide = function(self)
        self.editBox:SetText("")
        self.priceText:SetText("")
        if self.tooltipFrame then
            self.tooltipFrame:Hide()
        end
    end,
    
    EditBoxOnTextChanged = function(self)
        local parent = self:GetParent()
        local count = tonumber(self:GetText()) or 0
        local currencyInfo = GetItemCurrencyInfo(currentSlot)
        
        if currencyInfo then
            local priceText = ""
            local canAfford = true
            local canBuySpace = true
            local wasButtonEnabled = parent.button1:IsEnabled()
            
            if currencyInfo.numAvailable > 0 and count > currencyInfo.numAvailable then
                canAfford = false
                if wasButtonEnabled then
                    PrintMessage("|cffff0000" .. L[locale]["NOT_ENOUGH_AVAILABLE"]:format(currencyInfo.numAvailable) .. "|r")
                end
            end
            
            local canBuy, freeSpace = CanBuyAmount(count)
            if not canBuy then
                canBuySpace = false
            end
            
            if currencyInfo.type == "gold" then
                local totalPrice = (count / currencyInfo.stackCount) * currencyInfo.price
                if not HasEnoughMoney(totalPrice) then
                    local missingAmount = totalPrice - GetMoney()
                    priceText = L[locale]["NOT_ENOUGH"] .. " " .. FormatMoney(missingAmount)
                    priceText = "|cffff0000" .. priceText .. "|r"
                    canAfford = false
                else
                    priceText = L[locale]["TOTAL_COST"] .. " " .. FormatMoney(totalPrice)
                end
            else
                local missingText = ""
                local costText = ""
                local requiredCurrencies = {}
                
                for _, currency in ipairs(currencyInfo.currencies) do
                    local required = math.ceil(count / currencyInfo.stackCount) * currency.count
                    requiredCurrencies[currency.texture] = {
                        required = required,
                        current = currency.current,
                        missing = math.max(0, required - currency.current)
                    }
                end
                
                for texture, data in pairs(requiredCurrencies) do
                    if data.missing > 0 then
                        canAfford = false
                        if missingText ~= "" then
                            missingText = missingText .. " "
                        end
                        missingText = missingText .. data.missing .. " |T" .. texture .. ":12:12:2:0|t"
                    end
                    
                    if costText ~= "" then
                        costText = costText .. " "
                    end
                    costText = costText .. data.required .. " |T" .. texture .. ":12:12:2:0|t"
                end
                
                if not canAfford then
                    priceText = L[locale]["NOT_ENOUGH"] .. " " .. missingText
                    priceText = "|cffff0000" .. priceText .. "|r"
                else
                    priceText = L[locale]["TOTAL_COST"] .. " " .. costText
                end
            end
            
            parent.priceText:ClearAllPoints()
            parent.priceText:SetPoint("TOP", parent.editBox, "BOTTOM", 0, GUI_SETTINGS.PADDING.PRICE_TEXT)
            parent.priceText:SetText(priceText)
            
            if canAfford and canBuySpace then
                parent.button1:Enable()
            else
                parent.button1:Disable()
                if wasButtonEnabled and parent.button1:IsEnabled() ~= wasButtonEnabled then
                    if not canBuySpace then
                        PrintMessage(string.format(L[locale]["ERROR_BAG_SPACE"], GetMerchantItemLink(currentSlot), freeSpace))
                    end
                end
            end
        end
    end,
    
    OnAccept = function(self)
        local count = tonumber(self.editBox:GetText())
        if count and count > 0 and currentSlot then
            local itemLink = GetMerchantItemLink(currentSlot)
            if itemLink then
                local canBuy, freeSpace, adjustedCount, vendorStackSize, maxStackSize = CanBuyAmount(count)
                
                if not canBuy then
                    PrintMessage(string.format(L[locale]["ERROR_BAG_SPACE"], itemLink, freeSpace))
                    return
                end
                
                local function BuyWithDelay(remaining, totalPurchases)
                    if remaining <= 0 then
                        PrintMessage(string.format(L[locale]["PURCHASED"], adjustedCount, totalPurchases, vendorStackSize))
                        HidePurchaseTimer()
                        return
                    end
                    
                    ShowPurchaseTimer(itemLink, remaining, totalPurchases)
                    BuyMerchantItem(currentSlot)
                    C_Timer.After(BuyUnlimitedDB.purchaseDelay, function()
                        BuyWithDelay(remaining - 1, totalPurchases)
                    end)
                end
                
                if vendorStackSize > 1 then
                    local numPurchases = adjustedCount / vendorStackSize
                    BuyWithDelay(numPurchases, numPurchases)
                else
                    local function BuyStacksWithDelay(remaining)
                        if remaining <= 0 then
                            PrintMessage(string.format(L[locale]["PURCHASED"], count, count, 1))
                            HidePurchaseTimer()
                            return
                        end
                        
                        local buyCount = math.min(maxStackSize, remaining)
                        local totalStacks = math.ceil(count / buyCount)
                        local currentStack = totalStacks - math.ceil(remaining / buyCount)
                        
                        ShowPurchaseTimer(itemLink, totalStacks - currentStack, totalStacks)
                        BuyMerchantItem(currentSlot, buyCount)
                        C_Timer.After(BuyUnlimitedDB.purchaseDelay, function()
                            BuyStacksWithDelay(remaining - buyCount)
                        end)
                    end
                    
                    BuyStacksWithDelay(count)
                end
            end
        end
    end,
    
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        if parent.button1:IsEnabled() then
            parent.button1:Click()
        end
    end,
    
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function UpdateTotalCost()
    local totalGold = 0
    local totalCurrencies = {}
    
    local vendorID = GetVendorIdentifier()
    if vendorID and savedVendorData[vendorID] then
        for slot, count in pairs(savedVendorData[vendorID].items) do
            if count and count > 0 then
                local _, _, price, stackCount, _, _, _, extendedCost = GetMerchantItemInfo(slot)
                
                if not extendedCost then
                    totalGold = totalGold + ((count / stackCount) * price)
                else
                    for i = 1, GetMerchantItemCostInfo(slot) do
                        local texture, itemCount = GetMerchantItemCostItem(slot, i)
                        if texture then
                            local required = math.ceil(count / stackCount) * itemCount
                            totalCurrencies[texture] = (totalCurrencies[texture] or 0) + required
                        end
                    end
                end
            end
        end
    end
    
    local costText = ""
    if totalGold > 0 then
        costText = FormatMoney(totalGold)
    end
    
    for texture, count in pairs(totalCurrencies) do
        if costText ~= "" then
            costText = costText .. " | "
        end
        costText = costText .. count .. " |T" .. texture .. ":12:12:2:0|t"
    end
    
    if costText ~= "" then
        AutobuyFrame.totalCost:SetText("(" .. L[locale]["TOTAL_COST"] .. " " .. costText .. ")")
    else
        AutobuyFrame.totalCost:SetText("")
    end
end

local function SaveDataToFile()
    local file = io.open(SAVED_ITEMS_FILE, "w")
    if file then
        for vendorID, data in pairs(savedVendorData) do
            file:write(string.format("VENDOR:%s:%s\n", vendorID, data.name))
            for itemID, count in pairs(data.items) do
                if count and count > 0 then
                    file:write(string.format("ITEM:%s:%d:%d\n", vendorID, itemID, count))
                end
            end
        end
        file:close()
    end
end


local function LoadDataFromFile()
    local file = io.open(SAVED_ITEMS_FILE, "r")
    if file then
        local currentVendor = nil
        for line in file:lines() do
            local prefix, data = strsplit(":", line, 2)
            if prefix == "VENDOR" then
                local vendorID, name = strsplit(":", data)
                savedVendorData[vendorID] = {
                    items = {},
                    name = name
                }
                currentVendor = vendorID
            elseif prefix == "ITEM" and currentVendor then
                local vendorID, itemID, count = strsplit(":", data)
                if vendorID == currentVendor then
                    savedVendorData[vendorID].items[tonumber(itemID)] = tonumber(count)
                end
            end
        end
        file:close()
    end
end

local function ShowBuyDialog(slot)
    currentSlot = slot
    StaticPopup_Show("BuyUnlimited_AMOUNT")
end

local function HandleShiftRightClick(self, button)
    if button == "RightButton" and IsShiftKeyDown() then
        DisableStackSplit()
        local slot = self:GetID()
        local itemLink = GetMerchantItemLink(slot)
        
        if itemLink then
            ShowBuyDialog(slot)
        end
    end
end

SLASH_BUYUNLIMITED1 = "/bu"
SLASH_BUYUNLIMITED2 = "/buyunlimited"
SlashCmdList["BUYUNLIMITED"] = function(msg)
    msg = msg:lower()
    if msg == "fix" or msg == "changelog" then
        ShowChangelog()
    else
        print("|cffffcc00BuyUnlimited|r v" .. ADDON_VERSION)
        print(L[locale]["AVAILABLE_COMMANDS"])
        print(L[locale]["FIX_COMMAND_DESC"])
    end
end

BuyUnlimited:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "BuyUnlimited" then
        InitSavedVariables()
        -- Don't disable stack split frame on addon loaded.
        -- DisableStackSplit()
        for i = 1, MERCHANT_ITEMS_PER_PAGE do
            local button = _G["MerchantItem"..i.."ItemButton"]
            if button then
                button:HookScript("OnClick", HandleShiftRightClick)
            end
        end
        ShowWelcomeMessage()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGOUT" then
        BuyUnlimitedDB = BuyUnlimited.savedVariables
    elseif event == "MERCHANT_SHOW" then
        if AutobuyFrame:IsShown() then
            UpdateAutobuyList()
        end
    elseif event == "MERCHANT_CLOSED" then
        AutobuyFrame:Hide()
        StaticPopup_Hide("BuyUnlimited_AMOUNT")
    end
end)
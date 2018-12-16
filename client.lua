local sx, sy = guiGetScreenSize();
local rX, rY = sx/1920, sy/1080;

local width, height = 500, 350;

local panelPos = {(sx/2) - (width/2), (sy/2) - (height/2)};
local bankPanelShowing = false;

local tickCount = getTickCount();

local fonts = {dxCreateFont("roboto.ttf", 17), dxCreateFont("roboto.ttf", 12)};

local moneyText = "";
local buttonText = "";
local input = {{"", false, ""}, {"", false, "Játékos neve"}};

local options = {
    {"Kifizetés", true},
    {"Befizetés", false},
    {"Átutalás", false};
};

addEventHandler("onClientRender", getRootElement(), function()
    if bankPanelShowing then
        dxDrawRectangle(panelPos[1], panelPos[2], width, height, tocolor(0, 0, 0, 150));
        dxDrawRectangle(panelPos[1] + 5, panelPos[2] + 5, width - 10, height - 10, tocolor(0, 0, 0, 100));
        dxDrawRectangle(panelPos[1] + 25, panelPos[2] + 45, width - 50, 60, tocolor(0, 0, 0, 100));
        dxDrawRectangle(panelPos[1] + 25, panelPos[2] + 125, width - 50, 145, tocolor(0, 0, 0, 100));
            
        dxDrawText("Számla kezelése", panelPos[1] + width/2, panelPos[2] + 25, panelPos[1] + width/2, panelPos[2] + 25, tocolor(255, 255, 255), 1, fonts[1], "center", "center", false, false, false, false, true);
            
        for i = 1, 3 do
            dxDrawToolbar(options[i][1], options[i][2], panelPos[1] + i*160 - 130, panelPos[2] + 50, 120, 50);
        end
            
        if options[1][2] then
            moneyText = "Bankszámla: #ea8220$"..formatMoney(bankMoney);
            buttonText = "Kifizetés";
            input[1][3] = "Összeg kifizetni";
        elseif options[2][2] then
            moneyText = "Készpénz: #ea8220$"..formatMoney(playerMoney);
            buttonText = "Befizetés";
            input[1][3] = "Összeg befizetni";
        else
            moneyText = "Bankszámla: #ea8220$"..formatMoney(bankMoney);
            buttonText = "Átutalás";
            input[1][3] = "Összeg átutalni";
        end
            
        dxDrawText(moneyText, panelPos[1] + width/2, panelPos[2] + 135, panelPos[1] + width/2, panelPos[2] + height/2, tocolor(255, 255, 255), 1, fonts[2], "center", "center", false, false, false, true);
            
        local formattedMoney = "$"..formatMoney(tonumber(input[1][1]));
            
        if options[3][2] then
            dxDrawEditBox(input[2][2] and input[2][1]..(getTickCount() - tickCount < 500 and "|" or "") or (input[2][1] == "" and input[2][3]) or input[2][1], input[2][2], panelPos[1] + 40, panelPos[2] + 205, 250, 40, (not input[2][2] and input[2][1] == "" and 180 or 255));    
                
            dxDrawEditBox(input[1][2] and formattedMoney..(getTickCount() - tickCount < 500 and "|" or "") or (input[1][1] == "" and input[1][3]) or formattedMoney, input[1][2], panelPos[1] + 310, panelPos[2] + 205, 150, 40, (not input[1][2] and input[1][1] == "" and 180 or 255));
        else
            dxDrawEditBox(input[1][2] and formattedMoney..(getTickCount() - tickCount < 500 and "|" or "") or (input[1][1] == "" and input[1][3]) or formattedMoney, input[1][2], panelPos[1] + 170, panelPos[2] + 205, 150, 40, (not input[1][2] and input[1][1] == "" and 180 or 255));
        end

        dxDrawRoundedRectangle(panelPos[1] + 155, panelPos[2] + 290, 175, 35, tocolor(234, 130, 32, isCursorHover(panelPos[1] + 155, panelPos[2] + 290, 175, 35) and 255 or 150), 3.5);
        dxDrawText(buttonText, panelPos[1] + 155 + 87.5, panelPos[2] + 290 + 17.5, panelPos[1] + 155 + 87.5, panelPos[2] + 290 + 17.5, isCursorHover(panelPos[1] + 155, panelPos[2] + 290, 175, 35) and tocolor(0, 0, 0) or tocolor(255, 255, 255), 1, fonts[2], "center", "center", false, false, false, false);
    end
end);

function processTransaction()
    for i = 1, 3 do
        if options[i][2] then
            type = i;
            break;
        end
    end
    
    if (type == 3) then
        target = getPlayerFromPartialName(input[2][1]);
        if not target then
            outputChatBox("Nem található játékos ilyen névvel vagy ID-vel!", 255, 0, 0, true);
            return;
        elseif target == localPlayer then
            outputChatBox("Magadnak nem utalhatsz át pénzt!", 255, 0, 0, true);
            return;
        else
            targetName = getPlayerName(targetName);
        end
    else
        target, targetName = false, false;
    end
    
    if input[1][1] == "" then
        outputChatBox("A beírt összegnek nagyobb kell lenni 0-nál!", 255, 0, 0, true);
        return;
    end
           
    triggerServerEvent("server->processTransaction", resourceRoot, type, tonumber(input[1][1]), {target, targetName});
end

addEventHandler("onClientElementDataChange", getRootElement(), function(theKey)
    if bankPanelShowing then
        if theKey == MONEY_ELEMENTDATA then
            playerMoney = tonumber(getElementData(localPlayer, theKey));
        elseif theKey == BANKMONEY_ELEMENTDATA then
            bankMoney = tonumber(getElementData(localPlayer, theKey));
        end
    end
end);

addEventHandler("onClientClick", getRootElement(), function(button, state, _, _, _, _, _, clickedElement)
    if state == "down" then
        if button == "right" then
            if clickedElement and getElementType(clickedElement) == "ped" and getElementData(clickedElement, "bankped") then
                playerMoney = tonumber(getElementData(localPlayer, MONEY_ELEMENTDATA)) or 0;
                bankMoney = tonumber(getElementData(localPlayer, BANKMONEY_ELEMENTDATA)) or 0;
                options[1][2], options[2][2], options[3][2] = true, false, false;
                input[1][1], input[2][1] = "", "";
                bankPanelShowing = true;
                guiSetInputEnabled(true);
            end
        elseif button == "left" then
            if not bankPanelShowing then return; end
            input[1][2], input[2][2] = false, false;
            if options[3][2] and isCursorHover(panelPos[1] + 40, panelPos[2] + 205, 250, 40) then
                input[2][2] = true;
            elseif options[3][2] and isCursorHover(panelPos[1] + 310, panelPos[2] + 205, 150, 40) then
                input[1][2] = true;
            elseif (options[1][2] or options[2][2]) and isCursorHover(panelPos[1] + 170, panelPos[2] + 205, 150, 40) then
                input[1][2] = true;
            elseif isCursorHover(panelPos[1] + 155, panelPos[2] + 290, 175, 35) then
                processTransaction();
            else
                for i = 1, 3 do
                    if isCursorHover(panelPos[1] + i*150 - 110, panelPos[2] + 50, 120, 50) then
                        options[1][2], options[2][2], options[3][2] = false, false, false;
                        input[1][1], input[2][1] = "", "";
                        options[i][2] = true;
                        return;
                    end
                end
            end
        end
    end
end);

addEventHandler("onClientCharacter", getRootElement(), function(character)
    if bankPanelShowing then
        if input[1][2] and tonumber(character) and (string.len(input[1][1]) < 12) then
            input[1][1] = input[1][1]..((input[1][1] == "" and tonumber(character) == 0) and "" or character);
        elseif input[2][2] and (string.len(input[2][1]) < 22) then
            input[2][1] = input[2][1]..character;
        end
    end
end);

addEventHandler("onClientKey", getRootElement(), function(button, state)
    if bankPanelShowing and state then
        if button == "backspace" then
            if input[1][2] then
                input[1][1] = input[1][1]:sub(1, -2);
            elseif input[2][2] then
                input[2][1] = input[2][1]:sub(1, -2);
            else
                bankPanelShowing = false;
                guiSetInputEnabled(false);
            end
        elseif button == "delete" then
            for i = 1, 2 do
                if input[i][2] then
                    input[i][1] = "";
                    return;
                end
            end
        elseif button == "enter" then
            processTransaction();
        end
    end
end);

addEventHandler("onClientPedDamage", getRootElement(), function()
    if getElementData(source, "bankped") then
        cancelEvent();
    end
end);

setTimer(function()
	tickCount = getTickCount();
end, 1000, 0);

function dxDrawToolbar(text, active, x, y, w, h)
    dxDrawRectangle(x, y, w, h, tocolor(234, 130, 32, isCursorHover(x, y, w, h) and 75 or 0));
    
    dxDrawText(text, x + w/2, y + h/2, x + w/2, y + h/2, tocolor(255, 255, 255), 1, fonts[2], "center", "center", false, false, false, false, true);
    
    dxDrawRectangle(x, y + h - 2, w, 2, tocolor(234, 130, 32, active and 255 or 0));
end

function dxDrawEditBox(text, active, x, y, w, h, a)
    dxDrawRectangle(x, y, w, h, tocolor(234, 130, 32, isCursorHover(x, y, w, h) and (active and 75 or 25) or (active and 50 or 0)));
    
    dxDrawText(text, x + w/2, y + h/2, x + w/2, y + h/2, tocolor(255, 255, 255, a), 1, fonts[2], "center", "center", false, false, false, false, false);
    
    dxDrawRectangle(x, y + h - 2, w, 2, tocolor(234, 130, 32));
end

function dxDrawRoundedRectangle(x, y, rx, ry, color, radius)
    rx = rx - radius * 2;
    ry = ry - radius * 2;
    x = x + radius;
    y = y + radius;

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color);
        dxDrawRectangle(x, y + ry, rx, radius, color);
        dxDrawRectangle(x - radius, y, radius, ry, color);
        dxDrawRectangle(x + rx, y, radius, ry, color);

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7);
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7);
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7);
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7);
    end
end

function getPlayerFromPartialName(name)
    local name = (name and name ~= "") and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil;
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower();
            if name_:find(name, 1, true) then
                return player;
            end
        end
    end
end

function isCursorHover(rectX, rectY, rectW, rectH)
    if isCursorShowing() then
        local cursorX, cursorY = getCursorPosition();
        cursorX, cursorY = cursorX * sx, cursorY * sy;
        return (cursorX >= rectX and cursorX <= rectX+rectW) and (cursorY >= rectY and cursorY <= rectY+rectH);
    else
        return false;
    end
end

function formatMoney(amount)
	local amount = math.floor(amount or 0);
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$');
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right;
end
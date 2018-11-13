local bankPed = createPed(unpack(PED_DATA));

setElementFrozen(bankPed, true);
setElementData(bankPed, "bankped", true);

addEvent("server->processTransaction", true);
addEventHandler("server->processTransaction", resourceRoot, function(type, amount, targetPlayer)
    if not client then return; end
        
    local playerMoney = tonumber(getElementData(client, MONEY_ELEMENTDATA)) or 0;
    local bankMoney = tonumber(getElementData(client, BANKMONEY_ELEMENTDATA)) or 0;
    local fAmount = formatMoney(amount);
    local target, targetName = unpack(targetPlayer);
        
    if (type == 1) then
        if (bankMoney >= amount) then
            setElementData(client, BANKMONEY_ELEMENTDATA, bankMoney - amount);
            setElementData(client, MONEY_ELEMENTDATA, playerMoney + amount);
            outputChatBox("Sikeresen kivettél #ea8220$"..fAmount.." #ffffff-t a bankszámládról!", client, 255, 255, 255, true);
        else
            outputChatBox("Nincs ennyi pénzed a bankszámládon!", client, 255, 255, 255, true);
        end
    elseif (type == 2) then
        if (playerMoney >= amount) then
            setElementData(client, BANKMONEY_ELEMENTDATA, bankMoney + amount);
            setElementData(client, MONEY_ELEMENTDATA, playerMoney - amount);
            outputChatBox("Sikeresen beraktál #ea8220$"..fAmount.." #ffffff-t a bankszámládra!", client, 255, 255, 255, true);
        else
            outputChatBox("Nincs ennyi készpénzed!", client, 255, 255, 255, true);
        end
    elseif (type == 3) then
        if (bankMoney >= amount) then
            setElementData(client, BANKMONEY_ELEMENTDATA, bankMoney - amount);
            setElementData(target, BANKMONEY_ELEMENTDATA, tonumber(getElementData(target, BANKMONEY_ELEMENTDATA)) + amount);
            outputChatBox("Sikeresen elküldtél #ea8220$"..fAmount.." #ffffff-t #ea8220"..targetName.."#ffffff-nak/nek!", client, 255, 255, 255, true);
            outputChatBox("#ea8220"..getPlayerName(client):gsub("_", " ").." #ffffffutalt neked #ea8220$"..fAmount.." #ffffff-t a bankszámládra!", target, 255, 255, 255, true);
        else
            outputChatBox("Nincs ennyi pénzed a bankszámládon!", client, 255, 255, 255, true);
        end
    end
end);

function formatMoney(amount)
	local amount = math.floor(amount or 0);
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$');
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right;
end
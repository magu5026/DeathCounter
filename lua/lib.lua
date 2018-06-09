Libary = Libary or {}

function NeedMigration(data,modname)
	if data 
	 and data.mod_changes 
	 and data.mod_changes[modname] 
	 and data.mod_changes[modname].old_version then 
		return true 
	end
	return false
end

function GetOldVersion(data,modname)
	return FormatVersion(data.mod_changes[modname].old_version)
end

function GetNewVersion(data,modname)
	return FormatVersion(data.mod_changes[modname].new_version)
end

function FormatVersion(version)
	return string.format("%02d.%02d.%02d", string.match(version, "(%d+).(%d+).(%d+)"))
end

function Contains(tab,element)
	for _,item in pairs(tab) do
		if item == element then
			return true
		end
	end
	return false
end

function Libary:add(num)
	self = self + num
end

function Libary:sub(num)
	self = self - num
end

function Libary:remove(item)
	for i,v in pairs(self) do
		if v == item then
			table.remove(self,i)
			break
		end
	end
end

function Libary:insert(item)
	table.insert(self,item)
end
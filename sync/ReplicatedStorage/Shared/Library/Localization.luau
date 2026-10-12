-- The supplied translation table is empty; authored text is the fallback.
local Data = require(script.Parent.MasterReference.Localization)
local Localization = {}
function Localization.Text(key, fallback, locale)
 local row = Data[key]
 if type(row) == "string" then return row end
 if type(row) == "table" then return row[locale or "en-us"] or row["en-us"] or fallback or key end
 return fallback or key
end
return Localization

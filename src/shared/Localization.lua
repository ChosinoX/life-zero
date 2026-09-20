--!strict
local strings = {
	en={TITLE="LIFE ZERO", SUBTITLE="From Nothing to Millionaire", WORK="WORK", BUY="BUY", REPAIR="REPAIR", SELL="SELL", CLAIM="CLAIM", TUTORIAL="Clean your first trash pile in Town Square!", QUEST="Current goal", MARKET="USED CAR MARKET"},
	cs={TITLE="LIFE ZERO", SUBTITLE="Z ničeho milionářem", WORK="PRÁCE", BUY="KOUPIT", REPAIR="OPRAVIT", SELL="PRODAT", CLAIM="VYZVEDNOUT", TUTORIAL="Ukliď první hromádku odpadků na náměstí!", QUEST="Aktuální cíl", MARKET="BAZAR AUT"},
}
return function(locale: string, key: string): string
	local lang = if string.sub(locale,1,2) == "cs" then strings.cs else strings.en
	return lang[key] or strings.en[key] or key
end

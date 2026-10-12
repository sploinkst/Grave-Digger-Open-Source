local Quotes = {}

Quotes.Title = "You have fallen in the war."
Quotes.Standard = {
	"It wasn't your fault.",
	"You will be remembered.",
	"You will be missed.",
	"You're the good guys.",
	"Remember them.",
	"We're waiting for you.",
	"Don't give up.",
	"You are a hero.",
	"A hero has to make sacrifices.",
	"You did what you had to do.",
	"We all honour you.",
	"Don't forget about them.",
	"Your glory will be remembered.",
	"History will talk greatly of you.",
	"What's done is done.",
	"You did your best.",
	"You fought for the right reasons.",
	"Don't look back.",
	"You have nothing to regret.",
	"Your life had meaning.",
	"Everything will be alright.",
	"You'll be reunited with them soon.",
	"You did a good job.",
	"Don't cry, it's almost over.",
	"You're heading to a better place.",
	"Keep fighting, it's not over yet.",
	"A better future awaits you.",
	"Don't think, just act.",
	"Your allies depend on you.",
}
Quotes.Elite = {
	"You are an example to your comrades behind you.",
	"You have contributed to a better future.",
	"There is a place reserved for heroes like you.",
	"You are a beacon of hope to your people.",
	"You give meaning to those that follow you.",
	"Books will be written about people like you.",
	"Your country is proud of you.",
	"Your actions today will be remembered forever.",
	"No-one will doubt your heroism.",
	"Tales will be told about your bravery.",
}

function Quotes.Choose(elite: boolean): string
	local pool = elite and Quotes.Elite or Quotes.Standard
	return pool[math.random(1, #pool)]
end

return Quotes

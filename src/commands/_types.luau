export type Flag = {
	name: string,
	value: string?,
}

export type CommandHandler = (args: { string }, flags: { Flag }) -> ()

export type Command = {
	aliases: { string },
	help: string?,
	run: (args: { string }, flags: { Flag }) -> (),
}

return nil

module modulang;
import std::io;

faultdef UNKNOWN_INSTRUCTION;

const bool DEBUG_MODE = false;

// ------------
// Logging  
// ------------
fn void print_error(String message, args...)
{
	io::print("\x1b[31;1m[ERROR]\x1b[0m ");
	io::printfn(message, ...args);
}

fn void print_info(String message, args...)
{
	if (DEBUG_MODE) {
		io::print("\x1b[32;1m[INFO]\x1b[0m ");
		io::printfn(message, ...args);
	}
}

struct ModulangEnvironment (Printable)
{
	char current_memory_cell;
	int[256] memory;
}
fn usz? ModulangEnvironment.to_format(&self, Formatter* f) @dynamic => io::struct_to_format(*self, f, false);

// ------------
// Instruction stuff
// ------------
fn void increment_current_memory_cell(ModulangEnvironment* env)
{
	env.memory[env.current_memory_cell] += 1;
	print_info("incremented current memory cell by 1");
}

fn void decrement_current_memory_cell(ModulangEnvironment* env) 
{
	env.memory[env.current_memory_cell] -= 1;
	print_info("decremented current memory cell by 1");
}

fn void go_to_next_memory_cell(ModulangEnvironment* env)
{
	env.current_memory_cell += 1;
	print_info("went to next memory cell");
}

fn void go_to_previous_memory_cell(ModulangEnvironment* env)
{
	env.current_memory_cell -= 1;
	print_info("went to previous memory cell");
}

fn void print_current_memory_cell_ascii(ModulangEnvironment env)
{
	print_info("printed character: %c", env.memory[env.current_memory_cell]);
	io::printf("%c", env.memory[env.current_memory_cell]);
	if (DEBUG_MODE) io::printn();
}

fn void print_current_memory_cell_decimal(ModulangEnvironment env)
{
	print_info("printed number: %d", env.memory[env.current_memory_cell]);
	io::printf("%d", env.memory[env.current_memory_cell]);
	if (DEBUG_MODE) io::printn();
}

fn void? procces_instruction(char instruction, ModulangEnvironment* env)
{
	switch (instruction) {
		case '+': increment_current_memory_cell(env);
		case '-': decrement_current_memory_cell(env);
		case '>': go_to_next_memory_cell(env);
		case '<': go_to_previous_memory_cell(env);
		case '@': print_current_memory_cell_decimal(*env);
		case 'p': print_current_memory_cell_ascii(*env);
		default : return UNKNOWN_INSTRUCTION?;
	}
}

// ------------
// Main function
// ------------
fn int main(String[] args)
{
	if (args.len < 2) {
		print_error("Not enough arguments!");
		return 1;
	}

	ModulangEnvironment env;

	foreach(instruction: args[1])
	if (catch err = procces_instruction(instruction, &env)) {
		switch (err) {
			case UNKNOWN_INSTRUCTION: print_error("Unknown instruction: %c", instruction);
		}
	}
	print_info("%s", env);
	
	return 0;
}

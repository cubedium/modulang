module modulang;
import std::io;

faultdef UNKNOWN_INSTRUCTION, CLOSED_NONEXISTENT_BLOCK;

bool debug_mode = false;

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
	if (debug_mode) {
		io::print("\x1b[32;1m[INFO]\x1b[0m ");
		io::printfn(message, ...args);
	}
}

struct ModulangEnvironment (Printable)
{
	int[256] memory;
	int loop_location;
	int loop_counter;
	int current_instruction;
	char current_memory_cell;
	bool in_loop;
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
	if (debug_mode) io::printn();
}

fn void print_current_memory_cell_decimal(ModulangEnvironment env)
{
	print_info("printed number: %d", env.memory[env.current_memory_cell]);
	io::printf("%d", env.memory[env.current_memory_cell]);
	if (debug_mode) io::printn();
}

fn void start_loop(ModulangEnvironment* env)
{
	print_info("started loop");
	env.loop_location = env.current_instruction;
	env.loop_counter = env.memory[env.current_memory_cell];
	env.in_loop = true;
}

fn void? close_block(ModulangEnvironment* env)
{
	print_info("attempting to close block");
	if (env.in_loop) {
		print_info("closing loop block");
		if (env.loop_counter == 1) {
			env.in_loop = false;
		} else {
			env.loop_counter -= 1;
			env.current_instruction = env.loop_location;
		}

		return;
	}

	return CLOSED_NONEXISTENT_BLOCK?;
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
		case '[': start_loop(env);
		case ';': return close_block(env);
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

	if (args.len > 2) {
		if (args[2] == "--debug") {
			debug_mode = true;
		} 
	}

	ModulangEnvironment env;

	for (env.current_instruction = 0;env.current_instruction<args[1].len;env.current_instruction++) {
		char instruction = args[1][env.current_instruction];
		if (catch err = procces_instruction(instruction, &env)) {
			switch (err) {
				case UNKNOWN_INSTRUCTION: print_error("Unknown instruction at instruction %d: %c", env.current_instruction + 1, instruction);
				case CLOSED_NONEXISTENT_BLOCK: print_error("closed nonexistent block at instruction %d", env.current_instruction + 1);
			}
		}
		print_info("%s", env);
	}
	
	return 0;
}

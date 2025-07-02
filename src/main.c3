module modulang;
import std::io;

faultdef UNKNOWN_INSTRUCTION, CLOSED_NONEXISTENT_BLOCK, MAX_MEMORY_CELL_LIMIT;

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

// ------------
// Structs
// ------------
struct ModulangLoopBlock (Printable)
{
	int location;
	int counter;
}
fn usz? ModulangLoopBlock.to_format(&self, Formatter* f) @dynamic => io::struct_to_format(*self, f, false);


struct ModulangBlocks (Printable)
{
	bool in_loop;
	bool in_set_digit;
	ModulangLoopBlock loop;
}
fn usz? ModulangBlocks.to_format(&self, Formatter* f) @dynamic => io::struct_to_format(*self, f, false);

struct ModulangEnvironment (Printable)
{
	char[256] memory;
	int current_instruction;
	char current_memory_cell;
	ModulangBlocks block;
}
fn usz? ModulangEnvironment.to_format(&self, Formatter* f) @dynamic => io::struct_to_format(*self, f, false);

// ------------
// Instruction stuff
// ------------
fn void increment_current_memory_cell(ModulangEnvironment* env)
{
	print_info("incremented current memory cell by 1");
	env.memory[env.current_memory_cell] += 1;
}

fn void decrement_current_memory_cell(ModulangEnvironment* env) 
{
	print_info("decremented current memory cell by 1");
	env.memory[env.current_memory_cell] -= 1;
}

fn void go_to_next_memory_cell(ModulangEnvironment* env)
{
	print_info("went to next memory cell");
	env.current_memory_cell += 1;
}

fn void go_to_previous_memory_cell(ModulangEnvironment* env)
{
	print_info("went to previous memory cell");
	env.current_memory_cell -= 1;
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
	env.block.loop.location = env.current_instruction;
	env.block.loop.counter = env.memory[env.current_memory_cell];
	env.block.in_loop = true;
}

fn void? close_block(ModulangEnvironment* env)
{
	print_info("attempting to close block");
	if (env.block.in_loop) {
		print_info("closing loop block");
		if (env.block.loop.counter <= 1) {
			env.block.in_loop = false;
		} else {
			env.block.loop.counter -= 1;
			env.current_instruction = env.block.loop.location;
		}
		return;
	} else if (env.block.in_set_digit) {
		print_info("closing set digit block");
		env.block.in_set_digit = false;
		return;
	}

	return CLOSED_NONEXISTENT_BLOCK?;
}

fn void do_nothing(char instruction)
{
	print_info("doing nothing at instruction '%c'", instruction);
}

fn void? procces_digit(ModulangEnvironment* env, char digit)
{
	print_info("proccessing digit: %d", digit);
	if (env.block.in_set_digit) {
		if (env.memory[env.current_memory_cell] * 10 + digit > 255) {
			return MAX_MEMORY_CELL_LIMIT?;
		}
		env.memory[env.current_memory_cell] = env.memory[env.current_memory_cell] * 10 + digit;
	} else {
		return UNKNOWN_INSTRUCTION?;
	}
}

fn void start_set_digit(ModulangEnvironment* env)
{
	print_info("started set digit");
	env.block.in_set_digit = true;
	env.memory[env.current_memory_cell] = 0;
}

fn void? procces_instruction(char instruction, ModulangEnvironment* env)
{
	switch (instruction) {
		case '+'     : increment_current_memory_cell(env);
		case '-'     : decrement_current_memory_cell(env);
		case '>'     : go_to_next_memory_cell(env);
		case '<'     : go_to_previous_memory_cell(env);
		case '#'     : print_current_memory_cell_decimal(*env);
		case 'p'     : print_current_memory_cell_ascii(*env);
		case '['     : start_loop(env);
		case '@'     : start_set_digit(env);
		case ';'     : return close_block(env);
		case '0'..'9': return procces_digit(env, instruction - '0');
		case ' '     : do_nothing(instruction);
		case '\n'    : do_nothing(instruction);
		case '\0'    : do_nothing(instruction);
		default      : return UNKNOWN_INSTRUCTION?;
	}
}

// ------------
// Main function
// ------------
fn int main(String[] args)
{
	String input;
	char[] input_buffer = mem::new_array(char, 4096);
	defer free(input_buffer);
	String filename;
	ModulangEnvironment env;

	foreach (i, arg : args) {
		if (i==0) { continue; }
		switch (arg) {
			case "--debug": debug_mode = true;
			case "--file" : if (args.len >= i+2) filename = args[i+1];
			case "--input": if (args.len >= i+2) input    = args[i+1]; filename = "__got_input";
			default       : if (filename == "" && arg.ends_with(".modlang")) filename = arg;
		}
		print_info("%d: \"%s\". is it a possible file?: %s", i, arg, (arg.ends_with(".modlang")) ? "yes" : "no");
	}

	print_info("input: %s", input);
	print_info("filename: %s", filename);

	print_info("starting to read file");
	if (filename != "__got_input" && filename != "") {
		File? file = file::open(filename, "r");
		if (catch err = file) {
			print_error("Couldn't open file! Does the file exist?");
			print_info("Error: %s", err);
			return 1;
		}
		defer (void)file.close();

		usz? bytes_read = file.read(input_buffer);
		if (catch err = bytes_read) {
			print_error("Error while reading file! Use --debug for more info on the error.");
			print_info("Error: %s", err);
			return 1;
		}
		input = (String) input_buffer[0..bytes_read];
	}
	print_info("successfully read file");

	if (input == "") {
		print_error("You did not give a program to run! Maybe %s?", (filename != "__got_input") ? "the file is missing the .modlang extension" : "you left the input flag empty");
		return 1;
	}

	for (env.current_instruction = 0;env.current_instruction<input.len;env.current_instruction++) {
		char instruction = input[env.current_instruction];
		if (catch err = procces_instruction(instruction, &env)) {
			switch (err) {
				case UNKNOWN_INSTRUCTION     : print_error("Unknown instruction at instruction %d: \"%c\"", env.current_instruction + 1, instruction);
				case CLOSED_NONEXISTENT_BLOCK: print_error("Closed nonexistent block at instruction %d", env.current_instruction + 1);
				case MAX_MEMORY_CELL_LIMIT   : print_error("Attempted to set memory cell to %d, which is higher than the limit (255) at instruction %d", (int) env.memory[env.current_memory_cell] * 10 + instruction - '0', env.current_instruction + 1);
			}
		}
		print_info("%s", env);
	}
	
	return 0;
}

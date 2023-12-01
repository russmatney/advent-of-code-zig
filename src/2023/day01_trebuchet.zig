const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const expectEqual = std.testing.expectEqual;
const pr = std.debug.print;
const parseInt = std.fmt.parseInt;

const input = @embedFile("day01_input.txt");

fn build_digits() !ArrayList([]const u8) {
    var digits = ArrayList([]const u8).init(allocator);
    try digits.append("1");
    try digits.append("2");
    try digits.append("3");
    try digits.append("4");
    try digits.append("5");
    try digits.append("6");
    try digits.append("7");
    try digits.append("8");
    try digits.append("9");
    // try digits.append("one");
    // try digits.append("two");
    // try digits.append("three");
    // try digits.append("four");
    // try digits.append("five");
    // try digits.append("six");
    // try digits.append("seven");
    // try digits.append("eight");
    // try digits.append("nine");

    return digits;
}

fn line_to_numbers(digits: ArrayList([]const u8), line: []const u8) !u32 {
    var first_index = line.len;
    var first_digit: []const u8 = "";
    var last_index: usize = 0;
    var last_digit: []const u8 = "";

    if (line.len == 0) {
        return 0;
    }

    for (digits.items) |digit| {
        var ix = mem.indexOf(u8, line, digit) orelse first_index;
        if (ix < first_index) {
            first_index = ix;
            first_digit = digit;
        }
    }

    for (digits.items) |digit| {
        var ix = mem.lastIndexOf(u8, line, digit) orelse last_index;
        if (ix > last_index) {
            last_index = ix;
            last_digit = digit;
        }
    }

    if (mem.eql(u8, last_digit, "")) {
        last_digit = first_digit;
    }

    pr("{c}", .{first_digit[0]});
    pr("{c}\n", .{last_digit[0]});

    var str_num = try std.fmt.allocPrint(allocator, "{c}{c}", .{first_digit[0], last_digit[0]});
    var num = try parseInt(u32, str_num, 10);

    return num;
}

test "part 1" {
    var digits = try build_digits();
    defer digits.deinit();

    try expectEqual(line_to_numbers(digits, "1abc2"), 12);
    try expectEqual(line_to_numbers(digits, "pqr3stu8vwx"), 38);
    try expectEqual(line_to_numbers(digits, "a1b2c3d4e5f"), 15);
    try expectEqual(line_to_numbers(digits, "treb7uchet"), 77);
    try expectEqual(line_to_numbers(digits, "4dtlmkfnm"), 44);
}

// test "part 2" {
//     var digits = try build_digits();
//     defer digits.deinit();

//     try expectEqual(line_to_numbers(digits, "two1nine"), 29);
//     try expectEqual(line_to_numbers(digits, "eightwothree"), 83);
//     try expectEqual(line_to_numbers(digits, "abcone2threexyz"), 13);
//     try expectEqual(line_to_numbers(digits, "xtwone3four"), 24);
//     try expectEqual(line_to_numbers(digits, "4nineeightseven2"), 42);
//     try expectEqual(line_to_numbers(digits, "zoneight234"), 14);
//     try expectEqual(line_to_numbers(digits, "7pqrstsixteen"), 76);
// }


pub fn main() !void {
    pr("main running\n", .{});
    var digits = try build_digits();
    defer digits.deinit();

    var lines = mem.split(u8, input, "\n");

    var sum: u32 = 0;
    while (lines.next()) |line| {
        sum += try line_to_numbers(digits, line);
    }

    pr("total: {any}\n", .{sum});
}

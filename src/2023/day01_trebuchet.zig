const std = @import("std");
const mem = std.mem;
const StringHashMap = std.StringHashMap;
const allocator = std.heap.page_allocator;

const expectEqual = std.testing.expectEqual;
const pr = std.debug.print;
const parseInt = std.fmt.parseInt;

const input = @embedFile("day01_input.txt");

fn build_digits() !StringHashMap(u32) {
    var digits = StringHashMap(u32).init(allocator);

    try digits.put("1", 1);
    try digits.put("2", 2);
    try digits.put("3", 3);
    try digits.put("4", 4);
    try digits.put("5", 5);
    try digits.put("6", 6);
    try digits.put("7", 7);
    try digits.put("8", 8);
    try digits.put("9", 9);

    try digits.put("one", 1);
    try digits.put("two", 2);
    try digits.put("three", 3);
    try digits.put("four", 4);
    try digits.put("five", 5);
    try digits.put("six", 6);
    try digits.put("seven", 7);
    try digits.put("eight", 8);
    try digits.put("nine", 9);

    return digits;
}

fn line_to_numbers(digits: StringHashMap(u32), line: []const u8) !u32 {
    var first_index = line.len;
    var first_digit: u32 = 0;
    var last_index: usize = 0;
    var last_digit: u32 = 0;

    if (line.len == 0) {
        return 0;
    }

    var it = digits.iterator();
    while (it.next()) |entry| {
        var digit = entry.key_ptr.*;
        var ix = mem.indexOf(u8, line, digit) orelse first_index;
        if (ix < first_index) {
            first_index = ix;
            first_digit = entry.value_ptr.*;
        }
    }

    var it2 = digits.iterator();
    while (it2.next()) |entry| {
        var digit = entry.key_ptr.*;
        var ix = mem.lastIndexOf(u8, line, digit) orelse last_index;
        if (ix > last_index) {
            last_index = ix;
            last_digit = entry.value_ptr.*;
        }
    }

    if (last_digit == 0) {
        last_digit = first_digit;
    }

    pr("{d}", .{first_digit});
    pr("{d}\n", .{last_digit});

    var str_num = try std.fmt.allocPrint(allocator, "{d}{d}", .{first_digit, last_digit});
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

test "part 2" {
    var digits = try build_digits();
    defer digits.deinit();

    try expectEqual(line_to_numbers(digits, "two1nine"), 29);
    try expectEqual(line_to_numbers(digits, "eightwothree"), 83);
    try expectEqual(line_to_numbers(digits, "abcone2threexyz"), 13);
    try expectEqual(line_to_numbers(digits, "xtwone3four"), 24);
    try expectEqual(line_to_numbers(digits, "4nineeightseven2"), 42);
    try expectEqual(line_to_numbers(digits, "zoneight234"), 14);
    try expectEqual(line_to_numbers(digits, "7pqrstsixteen"), 76);
}

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

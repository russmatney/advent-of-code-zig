const std = @import("std");
const mem = std.mem;

const expectEqual = std.testing.expectEqual;
const pr = std.debug.print;

const input = @embedFile("day01_input.txt");

pub fn main() void {
    pr("main running", .{});

    var lines = mem.split(u8, input, "\n");

    var sum: u32 = 0;
    while (lines.next()) |line| {
        sum += line_to_numbers(line);
    }

    pr("total: {any}", .{sum});
}

fn line_to_numbers(line: []const u8) u32 {
    _ = line;
    return 0;
}

test "line_to_numbers" {
    try expectEqual(line_to_numbers("1abc2"), 12);
    try expectEqual(line_to_numbers("pqr3stu8vwx"), 38);
    try expectEqual(line_to_numbers("a1b2c3d4e5f"), 15);
    try expectEqual(line_to_numbers("treb7uchet"), 77);

    try expectEqual(line_to_numbers("two1nine"), 29);
    try expectEqual(line_to_numbers("eightwothree"), 83);
    try expectEqual(line_to_numbers("abcone2threexyz"), 13);
    try expectEqual(line_to_numbers("xtwone3four"), 24);
    try expectEqual(line_to_numbers("4nineeightseven2"), 42);
    try expectEqual(line_to_numbers("zoneight234"), 14);
    try expectEqual(line_to_numbers("7pqrstsixteen"), 76);
}

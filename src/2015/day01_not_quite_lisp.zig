const std = @import("std");
const aoc = @import("aoc.zig");
const fs = std.fs;
const mem = std.mem;
const expectEqual = std.testing.expectEqual;
const allocator = std.heap.page_allocator;

fn solve(input: []const u8) i32 {
    var floor: i32 = 0;

    var it = mem.window(u8, input, 1, 1);
    while (it.next()) |p| {
        if (mem.eql(u8, p, "(")) {
            floor += 1;
        } else if (mem.eql(u8, p, ")")) {
            floor -= 1;
        }
    }

    return floor;
}

test "part 1 cases" {
    try expectEqual(solve("(())"), 0);
    try expectEqual(solve("()()"), 0);
    try expectEqual(solve("((("), 3);
    try expectEqual(solve("(()(()("), 3);
    try expectEqual(solve("))((((("), 3);
    try expectEqual(solve("())"), -1);
    try expectEqual(solve("))("), -1);
    try expectEqual(solve(")))"), -3);
    try expectEqual(solve(")())())"), -3);
}


fn solve_2(input: []const u8) i32 {
    var floor: i32 = 0;
    var pos: i32 = 0;

    var it = mem.window(u8, input, 1, 1);
    while (it.next()) |p| {
        pos += 1;
        if (mem.eql(u8, p, "(")) {
            floor += 1;
        } else if (mem.eql(u8, p, ")")) {
            floor -= 1;
        }

        if (floor == -1) {
            return pos;
        }
    }

    return 0;
}

test "part 2 cases" {
    try expectEqual(solve_2(")"), 1);
    try expectEqual(solve_2("()())"), 5);
}

pub fn main() !void {
    std.debug.print("Hello, code!\n", .{});

    var data = try aoc.input_data("2015", "1");

    std.debug.print("final floor: {}\n", .{solve(data)});
    std.debug.print("first -1 floor at position: {}\n", .{solve_2(data)});
}

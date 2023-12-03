const std = @import("std");
const aoc = @import("aoc.zig");
const AutoHashMap = std.AutoHashMap;
const allocator = std.heap.page_allocator;
const pr = std.debug.print;
const expectEqual = std.testing.expectEqual;

const example_data = @embedFile("day3_example.txt");

const Point = union(enum) {
    empty: bool,
    symbol: u8,
    digit: u32,
};

const Coord = struct {
    x: usize,
    y: usize,
};

fn is_digit(char: u8) bool {
    return char > "0"[0] and char < "9"[0];
}

pub fn build_grid(data: []const u8) !AutoHashMap(Coord, Point) {
    var lines = std.mem.split(u8, data, "\n");
    var _lines = std.ArrayList([]const u8).init(allocator);
    while (lines.next()) |t| try _lines.append(t);

    var grid = AutoHashMap(Coord, Point).init(allocator);

    for (_lines.items, 0..) |line, y| {
        for (line, 0..) |char, x| {
            var p: Point = Point{.empty = true};
            if ("."[0] == char) {
                p = Point{.empty = true};
            } else if (is_digit(char)) {
                var s = "0".*;
                s[0] = char;
                var d = try std.fmt.parseInt(u32, &s, 10);
                p = Point{.digit = d};
            } else {
                p = Point{.symbol = char};
            }

            try grid.put(Coord{.x=x, .y=y}, p);
        }
    }

    return grid;
}

test "build_grid" {
    const g = try build_grid(example_data);

    try expectEqual(g.get(Coord{.x=0,.y=0}), Point{.digit = 4});
    try expectEqual(g.get(Coord{.x=1,.y=0}), Point{.digit = 6});
    try expectEqual(g.get(Coord{.x=2,.y=2}), Point{.digit = 3});
    try expectEqual(g.get(Coord{.x=0,.y=2}), Point{.empty = true});
    try expectEqual(g.get(Coord{.x=3,.y=1}), Point{.symbol = "*"[0]});
}

pub fn main() !void {
    pr("Day 3", .{});

    var data = aoc.input_data("2023", "3");
    // pr("day 3 data {any}\n", .{data});
    // pr("day 3 example data {any}\n", .{example_data});


    var grid = build_grid(data);
    _ = grid;

}

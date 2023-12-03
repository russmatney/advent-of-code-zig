const std = @import("std");
const aoc = @import("aoc.zig");
const expectEqual = std.testing.expectEqual;
const split = std.mem.split;
const tokenizeAny = std.mem.tokenizeAny;
const allocator = std.heap.page_allocator;

const pr = std.debug.print;

const Game = struct {
    id: u32,
    max_red: u32 = 0,
    max_green: u32 = 0,
    max_blue: u32 = 0,
    fn power() u32 {
        return .max_red * .max_blue * .max_green;
    }
};

fn parse_id(line: []const u8) !u32 {
    var parts = split(u8, line, ":");
    var first = parts.next() orelse return 0;
    var _parts = split(u8, first, " ");
    _ = _parts.next();
    var _id = _parts.next() orelse return 0;
    return try std.fmt.parseInt(u32, _id, 10);
}

test "parse_id" {
    try expectEqual(parse_id("Game 3: blah"), 3);
    try expectEqual(parse_id("Game 34: blah"), 34);
}

fn parse_max(line: []const u8, color: []const u8) !u32 {
    var tokens = tokenizeAny(u8, line, ";,: ");
    var parts = std.ArrayList([]const u8).init(allocator);
    while (tokens.next()) |t| try parts.append(t);

    var it = std.mem.window([]const u8, parts.items, 2, 2);
    _ = it.next(); // Game id

    while (it.next()) |pair| {
        var c = pair[0];
        var n = std.fmt.parseInt(u32, pair[1], 10);
        if (std.mem.eql(u8, color, c)) {
            return n;
        }
    }

    return 0;
}

test "parse_max" {
    try expectEqual(parse_max("Game 3: red 14; blue 1; red 4", "red"), 14);
    try expectEqual(parse_max("Game 3: red 9; blue 1; red 4", "blue"), 1);
    try expectEqual(parse_max("Game 3: green 3, red 9; blue 1; red 4", "green"), 3);
}

fn parse_game(line: []const u8) !Game {
    return Game{
        .id = try parse_id(line),
        .max_red = try parse_max(line, "red"),
        .max_green = try parse_max(line, "green"),
        .max_blue = try parse_max(line, "blue"),
    };
}

pub fn main() !void {
    var data = try aoc.input_data("2023", "2");
    var lines = split(u8, data, "\n");
    var possible_games: u32 = 0;

    while (lines.next()) |line| {
        var game = try parse_game(line);
        pr("Game: {}\n", .{game});
    }

    pr("possible games: {}\n", .{possible_games});
}

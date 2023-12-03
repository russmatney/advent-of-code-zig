const std = @import("std");
const aoc = @import("aoc.zig");
const allocator = std.heap.page_allocator;
const pr = std.debug.print;
const expectEqual = std.testing.expectEqual;

const split = std.mem.split;
const tokenizeAny = std.mem.tokenizeAny;


const Game = struct {
    id: u32,
    max_red: u32 = 0,
    max_green: u32 = 0,
    max_blue: u32 = 0,
    fn power(s: *Game) u32 {
        return s.max_red * s.max_blue * s.max_green;
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

    var max: u32 = 0;

    while (it.next()) |pair| {
        var n = try std.fmt.parseInt(u32, pair[0], 10);
        if (std.mem.eql(u8, color, pair[1])) {
            if (n > max) {
                max = n;
            }
        }
    }

    return max;
}

test "parse_max" {
    try expectEqual(parse_max("Game 3: 14 red; 1 blue; 4 red", "red"), 14);
    try expectEqual(parse_max("Game 3: 4 red; 1 blue; 14 red", "red"), 14);
    try expectEqual(parse_max("Game 3: 9 red; 1 blue; 4 red", "blue"), 1);
    try expectEqual(parse_max("Game 3: 3 green, 9 red; 1 blue; 4 red", "green"), 3);
}

fn parse_game(line: []const u8) !Game {
    return Game{
        .id = try parse_id(line),
        .max_red = try parse_max(line, "red"),
        .max_green = try parse_max(line, "green"),
        .max_blue = try parse_max(line, "blue"),
    };
}

test "parse_game" {
    var g = try parse_game("Game 3: 14 red; 1 blue; 4 red");
    try expectEqual(g.id, 3);
    try expectEqual(g.max_red, 14);
    try expectEqual(g.max_green, 0);
    try expectEqual(g.max_blue, 1);
    try expectEqual(
        parse_game("Game 3: 14 red; 1 blue; 4 red"),
        Game{.id = 33, .max_red = 14, .max_blue = 1, .max_green = 0});
}

pub fn main() !void {
    var data = try aoc.input_data("2023", "2");
    var lines = split(u8, data, "\n");

    var possible_game_ids: u32 = 0;
    var total_power: u32 = 0;

    var max_red: u32 = 12;
    var max_green: u32 = 13;
    var max_blue: u32 = 14;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var game = try parse_game(line);

        if (game.max_red <= max_red
            and game.max_green <= max_green
                and game.max_blue <= max_blue) {
            possible_game_ids += game.id;
        }

        total_power += game.power();
    }

    pr("possible games: {}\n", .{possible_game_ids});
    pr("total power: {}\n", .{total_power});
}

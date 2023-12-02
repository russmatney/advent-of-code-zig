const std = @import("std");
const aoc = @import("./aoc.zig");
const AutoHashMap = std.AutoHashMap;
const mem = std.mem;
const pr = std.debug.print;
const fs = std.fs;
const http = std.http;
const expectEqual = std.testing.expectEqual;
const allocator = std.heap.page_allocator;

pub fn main() !void {
    pr("[Day 3]", .{});

    var data = try aoc.input_data("2015", "3");
    defer allocator.free(data);
    // pr("data: {s}\n", .{data});

    var count = try count_houses(data);
    var count_2 = try count_houses2(data);
    pr("houses: {}, {}\n", .{count, count_2});
}

const Pos = struct {
    x: i32 = 0,
    y: i32 = 0,
    fn eq(self: *Pos, p: Pos) bool {
        return self.x == p.x and self.y == p.y;
    }
};

fn count_houses(path: []const u8) !u32 {
    var pos = Pos{};
    var positions = AutoHashMap(Pos, bool).init(allocator);
    defer positions.deinit();
    try positions.put(pos, true);

    var it = mem.window(u8, path, 1, 1);
    while (it.next()) |step| {
        if (mem.eql(u8, step, ">")) {
            pos.x += 1;
        } else if (mem.eql(u8, step, "<")) {
            pos.x -= 1;
        } else if (mem.eql(u8, step, "^")) {
            pos.y += 1;
        } else if (mem.eql(u8, step, "v")) {
            pos.y -= 1;
        }

        var new_pos = Pos{.x = pos.x, .y = pos.y};
        if (!positions.contains(new_pos)) {
            try positions.put(new_pos, true);
        }
    }

    return positions.count();
}

test "counts" {
    try expectEqual(count_houses(">"), 2);
    try expectEqual(count_houses("^>v<"), 4);
    try expectEqual(count_houses("^v^v^v^v^v"), 2);
}


fn count_houses2(path: []const u8) !u32 {
    var santa_pos = Pos{};
    var robo_pos = Pos{};
    var positions = AutoHashMap(Pos, bool).init(allocator);
    defer positions.deinit();
    try positions.put(Pos{}, true);

    var is_santa = true;

    var it = mem.window(u8, path, 1, 1);
    while (it.next()) |step| {
        var new_pos = Pos{};
        if (is_santa) {
            if (mem.eql(u8, step, ">")) {
                santa_pos.x += 1;
            } else if (mem.eql(u8, step, "<")) {
                santa_pos.x -= 1;
            } else if (mem.eql(u8, step, "^")) {
                santa_pos.y += 1;
            } else if (mem.eql(u8, step, "v")) {
                santa_pos.y -= 1;
            }
            new_pos = Pos{.x = santa_pos.x, .y = santa_pos.y};
        } else {
            if (mem.eql(u8, step, ">")) {
                robo_pos.x += 1;
            } else if (mem.eql(u8, step, "<")) {
                robo_pos.x -= 1;
            } else if (mem.eql(u8, step, "^")) {
                robo_pos.y += 1;
            } else if (mem.eql(u8, step, "v")) {
                robo_pos.y -= 1;
            }
            new_pos = Pos{.x = robo_pos.x, .y = robo_pos.y};
        }

        is_santa = !is_santa;
        if (!positions.contains(new_pos)) {
            try positions.put(new_pos, true);
        }
    }

    return positions.count();
}

test "w/ robo counts" {
    try expectEqual(count_houses2("^v"), 3);
    try expectEqual(count_houses2("^>v<"), 3);
    try expectEqual(count_houses2("^v^v^v^v^v"), 11);
}

const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const mem = std.mem;
const pr = std.debug.print;
const fs = std.fs;
const http = std.http;
const expectEqual = std.testing.expectEqual;
const allocator = std.heap.page_allocator;

const input_file = "day03_input.txt";

fn fetch_input(filename: []const u8) !void {
    var splits = std.mem.split(u8, @embedFile("session.txt"), "\n");
    var session = splits.first();

    var client = http.Client{
        .allocator = allocator,
    };

    const uri = try std.Uri.parse("https://adventofcode.com/2015/day/3/input");
    var headers = http.Headers{
        .allocator = allocator,
        .owned = false
    };
    try headers.append("accept", "*/*");
    var cookie_str = try std.fmt.allocPrint(allocator, "session={s}", .{session});
    try headers.append("cookie", cookie_str);

    var req = try client.request(.GET, uri, headers, .{});
    defer req.deinit();

    try req.start();
    try req.wait();

    const max_bytes = 8192;
    const body = req.reader().readAllAlloc(allocator, max_bytes) catch |err| {
        switch (err) {
            // error.FileTooBig => {
            //     pr("Question input bigger than expected! Max Bytes read from request - bump this allocator a bit!", .{});
            //     return err;
            // },
            else => {
                pr("Some error from AOC input request", .{});
                return err;
            }
        }
    };

    defer allocator.free(body);

    var file = try fs.cwd().createFile(filename, .{});
    defer file.close();
    try file.writeAll(body);

    pr("input data written to file {s}", .{filename});
}

pub fn main() !void {
    pr("[Day 3]", .{});

    var file = fs.cwd().openFile(input_file, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            pr("Input file not found, fetching...\n", .{});
            try fetch_input(input_file);
            return err;
        },
        else => return err
    };
    defer file.close();
    pr("Input file found, continuing...\n", .{});

    const max_bytes = 8192;
    var data = file.readToEndAlloc(allocator, max_bytes) catch |err| {
        switch (err) {
            error.FileTooBig => {
                pr("Max Bytes read! Bump this allocator a bit!", .{});
                return err;
            },
            else => return err
        }
    };
    defer allocator.free(data);

    var count = try count_houses(data);
    var count_2 = try count_houses2(data);
    pr("houses: {}, {}", .{count, count_2});
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

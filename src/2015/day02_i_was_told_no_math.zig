const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const parseInt = std.fmt.parseInt;
const expectEqual = std.testing.expectEqual;
const data = @embedFile("day02_input.txt");

fn line_to_area_and_ribbon(line: []const u8) ![2]u32 {
    var it = mem.tokenizeAny(u8, line, "x");

    var dims = [_]u32{0, 0, 0};

    while (it.next()) |d| {
        const n = parseInt(u32, d, 10) catch |err| {
            std.debug.print("unable to parse str: {s} {}\n", .{d, err});
            break;
        };
        if (dims[0] == 0) {
            dims[0] = n;
        } else if (dims[1] == 0) {
            dims[1] = n;
        } else if (dims[2] == 0) {
            dims[2] = n;
        }
    }

    mem.sort(u32, &dims, {}, std.sort.asc(u32));
    var smallest:u32 = dims[0];
    var next_smallest:u32 = dims[1];

    var l = dims[0];
    var w = dims[1];
    var h = dims[2];

    return [_]u32{
        2*l*w + 2*w*h + 2*l*h + smallest*next_smallest,
        smallest+smallest+next_smallest+next_smallest+l*w*h
    };
}

test "area per package" {
    var res = try line_to_area_and_ribbon("2x3x4");
    try expectEqual(res[0], 58);
    try expectEqual(res[1], 34);
    var res_1 = try line_to_area_and_ribbon("1x1x10");
    try expectEqual(res_1[0], 43);
    try expectEqual(res_1[1], 14);
}

pub fn main() !void {
    var splits = mem.split(u8, data, "\n");

    var total_area: u32 = 0;
    var total_ribbon: u32 = 0;

    while (splits.next()) |line| {
        var res = try line_to_area_and_ribbon(line);
        total_area += res[0];
        total_ribbon += res[1];
    }

    std.debug.print("area: {}\n", .{total_area});
    std.debug.print("ribbon: {}\n", .{total_ribbon});
}

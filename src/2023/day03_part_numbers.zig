const std = @import("std");
const aoc = @import("aoc.zig");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const allocator = std.heap.page_allocator;
const pr = std.debug.print;
const expectEqual = std.testing.expectEqual;

const example_data = @embedFile("day3_example.txt");

const Point = union(enum) {
    empty: bool,
    symbol: u8,
    digit: u8,
};

const Coord = struct {
    x: i32 = undefined,
    y: i32 = undefined,
};

const Grid = AutoHashMap(Coord, Point);

fn is_digit(char: u8) bool {
    return char >= "0"[0] and char <= "9"[0];
}

fn build_grid(data: []const u8) !Grid {
    var lines = std.mem.split(u8, data, "\n");
    var _lines = ArrayList([]const u8).init(allocator);
    while (lines.next()) |t| try _lines.append(t);

    var grid = Grid.init(allocator);

    for (_lines.items, 0..) |line, y| {
        for (line, 0..) |char, x| {
            var p: Point = Point{.empty = true};
            if ("."[0] == char) {
                p = Point{.empty = true};
            } else if (is_digit(char)) {
                p = Point{.digit = char};
            } else {
                p = Point{.symbol = char};
            }

            try grid.put(Coord{.x=@as(i32, @intCast(x)), .y=@as(i32, @intCast(y))}, p);
        }
    }

    return grid;
}

test "build_grid" {
    const g = try build_grid(example_data);

    try expectEqual(g.get(Coord{.x=0,.y=0}), Point{.digit = "4"[0]});
    try expectEqual(g.get(Coord{.x=1,.y=0}), Point{.digit = "6"[0]});
    try expectEqual(g.get(Coord{.x=3,.y=6}), Point{.digit = "9"[0]});
    try expectEqual(g.get(Coord{.x=2,.y=2}), Point{.digit = "3"[0]});
    try expectEqual(g.get(Coord{.x=0,.y=2}), Point{.empty = true});
    try expectEqual(g.get(Coord{.x=3,.y=1}), Point{.symbol = "*"[0]});
}

fn collect_symbols(g: Grid) !Grid {
    var symbols = Grid.init(allocator);

    var git = g.iterator();
    while (git.next()) |entry| {
        var point = entry.value_ptr.*;
        switch (point) {
            .symbol => try symbols.put(entry.key_ptr.*, point),
            else => {}
        }
    }

    return symbols;
}

test "collect_symbols" {
    const g = try build_grid(example_data);
    const p = try collect_symbols(g);

    try expectEqual(p.count(), 6);
    try expectEqual(p.get(Coord{.x=6, .y=3}), Point{.symbol=35});
    try expectEqual(p.get(Coord{.x=6, .y=3}), Point{.symbol="#"[0]});
}

fn neighbor_coords(c: Coord) ![]Coord {
    var cs = ArrayList(Coord).init(allocator);
    for (0..3) |x| {
        for (0..3) |y| {
            if (x == 1 and y == 1) continue;
            var _x = @as(i32, @intCast(x));
            var _y = @as(i32, @intCast(y));
            var new = Coord{
                .x=c.x + _x - 1,
                .y=c.y + _y - 1
            };
            try cs.append(new);
        }
    }
    return cs.items;
}

test "neighbor_coords" {
    var nbrs = try neighbor_coords(Coord{.x=0, .y=0});
    try expectEqual(nbrs.len, 8);
}

const NumAt = struct {
    num: u32,
    at: Coord,
};

fn number_at(grid: Grid, c: Coord) !?NumAt {
    var midpoint = grid.get(c) orelse return null;
    var mid_s = switch (midpoint) {
        .digit => midpoint.digit,
        .empty => return null,
        .symbol => return null,
    };

    var left_nums = ArrayList(u8).init(allocator);
    var left_most_coord = c;
    var lc = Coord{.x=c.x - 1, .y=c.y};
    while (grid.get(lc)) |point| : (lc = Coord{.x=lc.x - 1, .y=c.y}) {
        switch (point) {
            .digit => {
                try left_nums.append(point.digit);
                left_most_coord = lc;
            },
            .empty => break,
            .symbol => break,
        }
    }

    var right_nums = ArrayList(u8).init(allocator);
    var rc = Coord{.x=c.x + 1, .y=c.y};
    while (grid.get(rc)) |point| : (rc = Coord{.x=rc.x + 1, .y=c.y}) {
        switch (point) {
            .digit => try right_nums.append(point.digit),
            .empty => break,
            .symbol => break,
        }
    }
    var left = left_nums.items;
    std.mem.reverse(u8, left);
    var right = right_nums.items;

    var num_str = try std.fmt.allocPrint(allocator, "{s}{c}{s}", .{left, mid_s, right});
    var num = try std.fmt.parseInt(u32, num_str, 10);

    return NumAt{.num=num, .at=left_most_coord};
}

test "number_at" {
    var g = try build_grid(example_data);
    try expectEqual(number_at(g, Coord{.x=0, .y=0}), NumAt{.num=467, .at=Coord{.x=0,.y=0}});
    try expectEqual(number_at(g, Coord{.x=1, .y=0}), NumAt{.num=467, .at=Coord{.x=0,.y=0}});
    try expectEqual(number_at(g, Coord{.x=2, .y=0}), NumAt{.num=467, .at=Coord{.x=0,.y=0}});
    try expectEqual(number_at(g, Coord{.x=2, .y=2}), NumAt{.num=35, .at=Coord{.x=2,.y=2}});
    try expectEqual(number_at(g, Coord{.x=3, .y=2}), NumAt{.num=35, .at=Coord{.x=2,.y=2}});
}

fn nums_touching_coord(g: Grid, c: Coord) ![]u32 {
    var num_map = AutoHashMap(Coord, u32).init(allocator);
    for (try neighbor_coords(c)) |ngbr| {
        var num = (try number_at(g, ngbr)) orelse null;
        if (num != null) {
            try num_map.put(num.?.at, num.?.num);
        }
    }
    var nums = ArrayList(u32).init(allocator);
    var numit = num_map.valueIterator();
    while (numit.next()) |num| try nums.append(num.*);
    return nums.items;
}

test "nums_touching_coord" {
    var g = try build_grid(example_data);
    var nums = try nums_touching_coord(g, Coord{.x=3, .y=1});
    try expectEqual(nums[0], 467);
    try expectEqual(nums[1], 35);
}

const Part = struct {
    symbol: u8,
    numbers: []u32,
};

fn collect_parts(g: Grid) ![]Part {
    var symbols = try collect_symbols(g);
    var sit = symbols.iterator();

    var parts = ArrayList(Part).init(allocator);

    while (sit.next()) |sym_entry| {
        var nums = try nums_touching_coord(g, sym_entry.key_ptr.*);
        var symbol = sym_entry.value_ptr.*.symbol;
        try parts.append(Part{.symbol=symbol, .numbers=nums});
    }

    return parts.items;
}

test "collect_parts" {
    var g = try build_grid(example_data);
    var ps = try collect_parts(g);

    try expectEqual(ps.len, 6);

    try expectEqual(ps[0].symbol, "*"[0]);
    try expectEqual(ps[0].numbers[0], 467);
    try expectEqual(ps[0].numbers[1], 35);
}

pub fn main() !void {
    pr("Day 3", .{});

    var data = try aoc.input_data("2023", "3");
    // var data = example_data;

    var grid = try build_grid(data);
    var parts = try collect_parts(grid);

    var sum_of_parts: u32 = 0;
    for (parts) |p| {
        for (p.numbers) |num| {
            sum_of_parts += num;
        }
    }

    pr("Sum of parts: {d}", .{sum_of_parts});


}

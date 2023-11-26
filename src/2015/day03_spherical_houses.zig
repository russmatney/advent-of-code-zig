const std = @import("std");
const aoc = @import("aoc");
const pr = std.debug.print;
const fs = std.fs;

const input_file = "day03_input.txt";

pub fn main() !void {
    pr("[Day 3]", .{});

    fs.cwd().access(input_file, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            pr("Input file not found, fetching...", .{});
            try aoc.fetch_input(input_file);
            return err;
        },
        else => return err
    };
    pr("Input file found, continuing...", .{});
    var data = @embedFile(input_file);
    _ = data;

}
